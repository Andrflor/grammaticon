import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/engine/design.dart';
import 'package:grammaticon/engine/session.dart';

import 'design_test.dart' show readFile;

Future<GameDesign> sequenceFixture() =>
    GameDesign.load('assets/designs/grammaticon/game.json', (path) async {
      final text = await readFile(path);
      if (!path.contains('/theatrum/sections/loca/cards/a-ablative/'))
        return text;
      dynamic data = jsonDecode(text);
      if (path.endsWith('/card.json')) {
        data['questionSelection'] = 'weighted';
        data['encounter']['completion'] = 'sequence';
        data['encounter']['target'] = 3;
      } else if (path.endsWith('/questions.json')) {
        data = (data as List).take(4).toList();
        for (var i = 0; i < data.length; i++) {
          data[i]['followUpOnly'] = i > 0;
          if (i + 1 < data.length) data[i]['next'] = data[i + 1]['id'];
        }
      }
      return jsonEncode(data);
    });

void main() {
  late GameDesign design;
  setUpAll(() async {
    design = await GameDesign.load(
      'assets/designs/grammaticon/game.json',
      readFile,
    );
  });
  test(
    'all integrated banks, lessons and explicit review destinations resolve',
    () async {
      var count = 0;
      final banks = <String, Set<String>>{};
      for (final card in design.cards.values.where(
        (c) => ['theatrum', 'templum'].contains(c.address.split('/').first),
      )) {
        expect(card.data['skills'], hasLength(1), reason: card.address);
        final questions = await design.questions(card);
        count += questions.length;
        banks[card.address] = questions.map((q) => q.id).toSet();
        expect(await design.lesson(card), isNotEmpty);
        for (final q in questions) {
          expect(
            q.skills,
            contains(card.data['skills'].single),
            reason: card.address,
          );
          expect(await design.help(q.data['help']), isNotEmpty);
          expect(
            q.choices.map((c) => design.text(c['text'])).toSet().length,
            q.choices.length,
            reason: '${card.address}#${q.id}',
          );
        }
      }
      expect(count, 2016);
      for (final set in objects(design.pedagogy['practiceSets'])) {
        for (final target in objects(set['targets'])) {
          if (banks.containsKey(target['card'])) {
            expect(
              banks[target['card']],
              containsAll(strings(target['questions'])),
              reason: set['id'],
            );
          }
        }
      }
    },
  );
  test('retired cards do not break saves or erase earned progress', () {
    final original = GameSession(design, {}, (_) async {});
    final saved = object(jsonDecode(original.exportJson));
    saved['balance'] = 79;
    saved['completed']['forum/section-1/dec-1'] = 3;
    saved['encounter'] = {
      'card': 'templum/lexicon-1/words-01',
      'phase': 'question',
    };
    saved['errors']['old-word'] = {
      'card': 'templum/lexicon-1/words-01',
      'practice': ['word.review.a'],
    };
    final restored = GameSession(design, saved, (_) async {});
    expect(restored.encounter, isNull);
    expect(restored.balance, 79);
    expect(restored.state['completed']['forum/section-1/dec-1'], 3);
    expect(restored.state['retiredEncounters'], hasLength(1));
    expect(
      restored.state['retiredErrors']['old-word'],
      saved['errors']['old-word'],
    );
    expect(restored.state['errors'], isEmpty);
    original.dispose();
    restored.dispose();
  });
  test(
    'regrouping preserves purchases without granting new learning evidence',
    () {
      final original = GameSession(design, {}, (_) async {});
      final saved = object(jsonDecode(original.exportJson));
      saved['balance'] = 91;
      saved['purchased'] = [
        'theatrum/personae/agent-object',
        'theatrum/personae/03-descriptions',
        'theatrum/personae/genitive-plural',
        'templum/loca/neuter-number',
      ];
      saved['completed']['theatrum/personae/genitive-plural'] = 2;
      final restored = GameSession(design, saved, (_) async {});
      expect(restored.balance, 91);
      for (final address in [
        'theatrum/personae/agents',
        'theatrum/personae/possession',
        'templum/loca/numerus',
      ]) {
        final card = design.cards[address]!;
        expect(restored.unlocked(card), true);
        expect(restored.state['completed'][address] ?? 0, 0);
        expect(
          restored.skill(strings(card.data['skills']).single)['correct'] ?? 0,
          0,
        );
      }
      expect(
        strings(restored.state['purchased'])
            .where((id) => id == 'theatrum/personae/agents'),
        hasLength(1),
      );
      final again = GameSession(
        design,
        object(jsonDecode(restored.exportJson)),
        (_) async {},
      );
      expect(again.exportJson, restored.exportJson);
      original.dispose();
      restored.dispose();
      again.dispose();
    },
  );
  test('purchase aliases reject destinations absent from the design', () async {
    await expectLater(
      GameDesign.load('assets/designs/grammaticon/game.json', (path) async {
        final text = await readFile(path);
        if (!path.endsWith('/game.json')) return text;
        final data = object(jsonDecode(text));
        data['migration']['purchaseAliases']['removed/card'] = 'missing/card';
        return jsonEncode(data);
      }),
      throwsFormatException,
    );
  });
  for (final correctCount in [2, 3, 4]) {
    test(
      'sequence stops at its target or end with $correctCount available successes',
      () async {
        final design = await sequenceFixture();
        final card = design.cards['theatrum/loca/a-ablative']!;
        var session = GameSession(design, {}, (_) async {});
        session.state['purchased'] = [...design.nodes.keys];
        await session.start(card);
        await session.begin();
        for (var index = 0; index < (correctCount >= 3 ? 3 : 4); index++) {
          expect(session.encounter!['phase'], 'question');
          expect(session.question!.id, 'q${index + 1}');
          final q = session.question!;
          await session.answer(
            index < correctCount
                ? q.accepted.first
                : q.choices.firstWhere(
                    (c) => !q.accepted.contains(c['id']),
                  )['id'],
          );
          final saved = object(jsonDecode(jsonEncode(session.state)));
          session.dispose();
          session = GameSession(design, saved, (_) async {});
          await session.advance();
        }
        expect(
          session.encounter!['phase'],
          correctCount >= 3 ? 'victory' : 'defeat',
        );
        expect(
          session.state['completed'][card.address] ?? 0,
          correctCount >= 3 ? 1 : 0,
        );
        session.dispose();
      },
    );
  }
  test('sequence rejects missing starts, disconnected questions and impossible targets', () async {
    final design = await sequenceFixture();
    final card = design.cards['theatrum/loca/a-ablative']!;
    final bank = await design.questions(card);
    List<QuestionEntry> altered(void Function(List<dynamic>) change) {
      final data =
          jsonDecode(jsonEncode(bank.map((q) => q.data).toList())) as List;
      change(data);
      return data.map((q) => QuestionEntry(object(q))).toList();
    }

    expect(
      () => design.validateQuestions(
        card,
        altered((q) => q[0]['followUpOnly'] = true),
      ),
      throwsFormatException,
    );
    expect(
      () => design.validateQuestions(card, altered((q) => q[0].remove('next'))),
      throwsFormatException,
    );
    final data = object(jsonDecode(jsonEncode(card.data)));
    data['encounter']['target'] = 5;
    final impossible = ContentNode(
      card.id,
      card.kind,
      data,
      card.parent,
      card.directory,
    );
    expect(
      () => design.validateQuestions(impossible, bank),
      throwsFormatException,
    );
  });
}
