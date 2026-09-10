import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/engine/design.dart';
import 'package:grammaticon/engine/session.dart';

import 'design_test.dart' show readFile;
import 'skill_graph_test.dart' show evidence;

void main() {
  late GameDesign design;
  setUpAll(() async {
    design = await GameDesign.load(
      'assets/designs/grammaticon/game.json',
      readFile,
    );
  });

  test('a won encounter does not validate its card or unlock a mastery prerequisite', () async {
    for (final place in ['theatrum', 'templum']) {
      final s = GameSession(design, {}, (_) async {});
      addTearDown(s.dispose);
      final card = design.cards['$place/loca/a-ablative']!;
      await s.start(card);
      await s.begin();
      while (s.encounter?['phase'] == 'question') {
        await s.answer(s.question!.accepted.first);
        await s.advance();
      }
      expect(s.encounter!['phase'], 'victory');
      expect(s.state['completed'][card.address], 1);
      expect(s.cardMastered(card), false);
      expect(s.meets({'mastered': card.address}), false);
      expect(s.skill(strings(card.data['skills']).single), isEmpty);
    }
  });

  test(
    'vocabulary card is computed from every word, not an aggregate score',
    () async {
      final card = design.cards['theatrum/itinera/vocabula']!;
      final aggregate = strings(card.data['skills']).single;
      final leaves = design.skillLeaves(aggregate).toList();
      final s = GameSession(design, {}, (_) async {});
      addTearDown(s.dispose);
      s.state['skills'][aggregate] = evidence();
      s.state['completed'][card.address] = 999;
      for (final id in leaves.skip(1)) {
        s.state['skills'][id] = evidence();
      }
      expect(s.cardMastered(card), false);
      expect(s.progress(aggregate), 0);
      s.state['skills'][leaves.first] = evidence();
      expect(s.cardMastered(card), true);
      expect(s.progress(aggregate), 1);
      // Successful vocabulary recognition provides no evidence of production.
      final production = design.cards['templum/itinera/vocabula']!;
      expect(s.cardMastered(production), false);
    },
  );

  test(
    'word evidence persists and an assisted answer does not certify it',
    () async {
      for (final assisted in [false, true]) {
        final card = design.cards['templum/itinera/vocabula']!;
        final s = GameSession(design, {}, (_) async {});
        addTearDown(s.dispose);
        s.state['purchased'] = [...design.nodes.keys];
        await s.start(card);
        await s.begin();
        final q = s.question!;
        if (assisted) await s.help();
        await s.answer(q.accepted.first);
        final id = q.skills.single;
        expect(s.skill(id)['correct'] ?? 0, assisted ? 0 : 1);
        final restored = GameSession(
          design,
          object(jsonDecode(s.exportJson)),
          (_) async {},
        );
        addTearDown(restored.dispose);
        expect(restored.skill(id), s.skill(id));
        expect(s.skill(strings(card.data['skills']).single), isEmpty);
      }
    },
  );

  test('the two places use different assessed objectives and production includes gaps', () async {
    final reading = await design.questions(
      design.cards['theatrum/loca/a-ablative']!,
    );
    final production = await design.questions(
      design.cards['templum/loca/a-ablative']!,
    );
    expect(
      reading.expand((q) => q.skills).every((id) => id.startsWith('lectio.')),
      true,
    );
    expect(
      production
          .expand((q) => q.skills)
          .every((id) => id.startsWith('compositio.')),
      true,
    );
    expect(production.any((q) => q.interaction == 'gapChoice'), true);
    final first = production.first;
    expect(
      first.choices.map((c) => c['text']),
      containsAll(['Italiā', 'Italia', 'Italiam']),
    );
    for (final text in ['Italiā', 'Italia']) {
      final s = GameSession(design, {}, (_) async {});
      addTearDown(s.dispose);
      await s.start(design.cards['templum/loca/a-ablative']!);
      await s.begin();
      s.state['encounter']['question'] = first.data;
      await s.answer(first.choices.singleWhere((c) => c['text'] == text)['id']);
      expect(s.encounter!['lastCorrect'], text == 'Italiā');
    }
  });

  test('invalid mastery evidence requirements are rejected', () {
    final node = design.knowledge['lexicon.lectio.puella']!;
    final original = node['masteryRequirements'];
    try {
      for (final requirement in [
        {'successfulItems': []},
        {
          'successfulItems': ['x', 'x'],
        },
        {
          'successfulItems': [''],
        },
        {
          'successfulItems': [12],
        },
        {'minItems': 0},
        {'minItems': '1'},
      ]) {
        node['masteryRequirements'] = requirement;
        expect(design.validate, throwsFormatException);
      }
    } finally {
      node['masteryRequirements'] = original;
    }
    expect(design.validate, returnsNormally);
  });
}
