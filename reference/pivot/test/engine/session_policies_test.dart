import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/engine/design.dart';
import 'package:grammaticon/engine/session.dart';
import 'package:grammaticon/ui/activity/presentation_binding.dart';

import 'design_test.dart' show demo, readFile;

Future<GameDesign> choiceDesign(Map<String, bool> settings) => GameDesign.load(
  'assets/designs/compass/game.json',
  (path) async {
    final text = await readFile(path);
    if (!path.contains('/cards/durations/')) return text;
    final data = jsonDecode(text);
    if (path.endsWith('/card.json') && settings.containsKey('card')) {
      data['shuffleChoices'] = settings['card'];
    }
    if (path.endsWith('/questions.json') && settings.containsKey('question')) {
      for (final q in data) {
        q['shuffleChoices'] = settings['question'];
      }
    }
    return jsonEncode(data);
  },
);

void main() {
  test('zero lives or zero target cannot accept another answer, including restored saves', () async {
    for (final exhausted in ['lives', 'remaining']) {
      for (final phase in ['question', 'paused', 'introduction', 'feedback']) {
        final d = await demo();
        final card = d.cards['observatory/discovery/durations']!;
        final session = GameSession(d, {}, (_) async {});
        await session.start(card);
        await session.begin();
        session.state['encounter'][exhausted] = 0;
        session.state['encounter']['phase'] = phase;
        session.state['encounter']['lastCorrect'] = exhausted == 'remaining';
        final restored = GameSession(
          d,
          object(jsonDecode(session.exportJson)),
          (_) async {},
        );
        expect(
          BattleView(restored, TrialView(restored, card)).acceptsInput,
          false,
        );
        await restored.recover();
        expect(
          restored.encounter!['phase'],
          exhausted == 'lives' ? 'defeat' : 'victory',
        );
        final transaction = restored.state['transaction'];
        await restored.answer(restored.question!.accepted.first);
        await restored.advance();
        expect(restored.encounter!['answered'], 0);
        expect(restored.state['transaction'], transaction);
        restored.dispose();
        session.dispose();
      }
    }
  });

  test(
    'third unassisted error ends a three-heart battle without another question',
    () async {
      final d = await demo();
      final card = d.cards['observatory/discovery/durations']!;
      card.data['encounter'] = {...object(card.data['encounter']), 'lives': 3};
      final s = GameSession(d, {}, (_) async {});
      await s.start(card);
      await s.begin();
      for (var i = 0; i < 3; i++) {
        final q = s.question!;
        await s.answer(
          q.choices.firstWhere((c) => !q.accepted.contains(c['id']))['id'],
        );
        expect(BattleView(s, TrialView(s, card)).acceptsInput, false);
        await s.advance();
      }
      expect(s.encounter!['phase'], 'defeat');
      expect(s.encounter!['lives'], 0);
      expect(s.encounter!['answered'], 3);
      s.dispose();
    },
  );

  test(
    'adaptive relevance uses individual results and saved recent questions',
    () async {
      final d = await demo();
      final card = d.cards['observatory/discovery/durations']!;
      card.data['questionSelection'] = 'adaptive';
      final s = GameSession(d, {}, (_) async {}, random: Random(8));
      await s.start(card);
      await s.begin();
      final q = s.question!;
      final unseen = (await d.questions(card)).firstWhere((x) => x.id != q.id);
      await s.answer(q.accepted.first);
      expect(s.weight(card, unseen), greaterThan(s.weight(card, q)));
      final saved = object(jsonDecode(s.exportJson));
      final restored = GameSession(d, saved, (_) async {}, random: Random(8));
      await restored.discardEncounter();
      await restored.start(card);
      expect(restored.question!.id, isNot(q.id));
      await restored.begin();
      final mistaken = restored.question!;
      await restored.answer(
        mistaken.choices.firstWhere(
          (c) => !mistaken.accepted.contains(c['id']),
        )['id'],
      );
      expect(
        restored.weight(card, mistaken),
        greaterThan(restored.weight(card, q)),
      );
      expect(
        restored.state['questionResults'][card.address][mistaken.id]['wrong'],
        1,
      );
      restored.dispose();
      s.dispose();
    },
  );

  test('choice shuffling defaults off, inherits the card and permits a question override', () async {
    for (final settings in [
      <String, bool>{},
      {'card': true, 'question': false},
      {'card': false, 'question': true},
      {'card': true},
    ]) {
      var changed = false;
      for (var seed = 0; seed < 8; seed++) {
        final d = await choiceDesign(settings);
        final card = d.cards['observatory/discovery/durations']!;
        final bank = await d.questions(card);
        final s = GameSession(d, {}, (_) async {}, random: Random(seed));
        await s.start(card);
        final original = bank.firstWhere((q) => q.id == s.question!.id);
        final expected = original.choices.map((c) => c['id']).toList();
        final actual = s.question!.choices.map((c) => c['id']).toList();
        expect(actual.toSet(), expected.toSet());
        expect(s.question!.accepted, original.accepted);
        changed |= jsonEncode(actual) != jsonEncode(expected);
        final restored = GameSession(
          d,
          object(jsonDecode(s.exportJson)),
          (_) async {},
        );
        expect(restored.question!.choices, s.question!.choices);
        restored.dispose();
        s.dispose();
      }
      expect(changed, settings['question'] ?? settings['card'] ?? false);
    }
  });
}
