import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/engine/design.dart';
import 'package:grammaticon/engine/session.dart';

import 'design_test.dart' show demo, readFile;

Json evidence({double estimate = 1, int correct = 20}) => {
  'estimate': estimate,
  'highWater': estimate,
  'correct': correct,
  'wrong': 0,
  'items': ['a', 'b', 'c', 'd'],
  'successfulItems': ['a', 'b', 'c', 'd'],
  'recent': [
    for (var i = 0; i < 20; i++) {'correct': true},
  ],
};

Future<GameDesign> graph() async {
  final d = await GameDesign.load('assets/designs/compass/game.json', (
    path,
  ) async {
    final data = jsonDecode(await readFile(path));
    if (path.endsWith('/game.json')) {
      data['masteryRevision'] = 'test-1';
      data['migration']['retiredSkillIds'] = ['fine-a'];
    }
    return jsonEncode(data);
  });
  d.knowledge['fine-a'] = {'id': 'fine-a', 'name': 'A'};
  d.knowledge['fine-b'] = {
    'id': 'fine-b',
    'name': 'B',
    'requires': ['fine-a'],
  };
  d.knowledge['nested'] = {
    'id': 'nested',
    'name': 'N',
    'aggregation': {
      'skills': ['fine-b'],
      'level': 'minimum',
    },
  };
  d.knowledge['time-units']!['aggregation'] = {
    'skills': ['fine-a', 'nested'],
    'level': 'minimum',
  };
  return d;
}

void main() {
  test(
    'selection follows transitive prerequisites without granting evidence',
    () async {
      final d = await graph();
      final card = d.cards['observatory/discovery/durations']!;
      final original = QuestionEntry({'id': 'dependency-probe'});
      d.knowledge['taxonomy'] = {'id': 'taxonomy', 'name': 'T'};
      d.knowledge['fine-c'] = {'id': 'fine-c', 'name': 'C'};
      card.data['skills'] = [...strings(card.data['skills']), 'fine-c'];
      d.knowledge['fine-a']!['requires'] = ['taxonomy', 'fine-c'];
      final s = GameSession(d, {}, (_) async {});
      addTearDown(s.dispose);
      final implicit = QuestionEntry({
        ...original.data,
        'skills': ['fine-b'],
        'requires': [],
      });
      final initial = s.weight(card, implicit);
      expect(initial, greaterThan(0));
      s.state['skills']['fine-a'] = evidence();
      expect(s.weight(card, implicit), closeTo(initial * 2.5, 0.00001));
      s.state['skills']['fine-c'] = evidence();
      expect(s.weight(card, implicit), closeTo(initial * 4, 0.00001));
      expect(s.progress('fine-b'), isNull);
      expect(s.progress('taxonomy'), isNull);

      final explicit = QuestionEntry({
        ...original.data,
        'skills': ['fine-a'],
        'requires': ['nested'],
      });
      final before = s.weight(card, explicit);
      s.state['skills']['fine-b'] = evidence();
      expect(s.weight(card, explicit), closeTo(before * 1.6, 0.00001));
      // Readiness is recomputed when prerequisite evidence changes.
      s.state['skills'].remove('fine-b');
      expect(s.weight(card, explicit), before);
    },
  );

  test(
    'adaptive stimulus groups resist scenery volume and favor missing proof',
    () async {
      Future<GameDesign> fixture(int copies) =>
          GameDesign.load('assets/designs/compass/game.json', (path) async {
            final raw = await readFile(path);
            if (!path.endsWith('/durations/questions.json')) return raw;
            final source = object((jsonDecode(raw) as List).first);
            return jsonEncode([
              for (var i = 0; i < copies; i++)
                {
                  ...source,
                  'id': 'scenery-$i',
                  'evidenceItem': 'common',
                  'selectionGroup': 'common',
                },
              {
                ...source,
                'id': 'rare',
                'evidenceItem': 'rare',
                'selectionGroup': 'rare',
              },
            ]);
          });
      Future<int> rareCount(GameDesign d, {required bool unproven}) async {
        final card = d.cards['observatory/discovery/durations']!;
        card.data['questionSelection'] = 'adaptive';
        final q = (await d.questions(card)).first;
        var rare = 0;
        for (var seed = 0; seed < 80; seed++) {
          final s = GameSession(d, {}, (_) async {}, random: Random(seed));
          for (final id in q.skills) {
            s.state['skills'][id] = evidence()
              ..['successfulItems'] = ['common', if (!unproven) 'rare'];
          }
          await s.start(card);
          await s.begin();
          if (s.question!.id == 'rare') rare++;
          s.dispose();
        }
        return rare;
      }

      final small = await fixture(2);
      final large = await fixture(120);
      final balanced = await rareCount(large, unproven: false);
      final missing = await rareCount(large, unproven: true);
      expect(missing, greaterThan(balanced));
      expect(await rareCount(small, unproven: true), missing);
    },
  );

  test('numeral cards share fine evidence without sharing victories', () async {
    final d = await GameDesign.load(
      'assets/designs/grammaticon/game.json',
      readFile,
    );
    final quantity = d.cards['templum/numeris-exprimere/1']!;
    final frequency = d.cards['templum/numeris-exprimere/4']!;
    const shared = 'compositio.numeri.quantitas-frequentia';
    expect(d.skillLeaves(quantity.data['skills'].single), contains(shared));
    expect(d.skillLeaves(frequency.data['skills'].single), contains(shared));
    final entries = await d.questions(quantity);
    final q = await d.materialize(
      quantity,
      entries.firstWhere(
        (entry) => entry.item.startsWith('compositio-numerus-1-duo|'),
      ),
    );
    expect(q.outcome('1')['observed'], ['compositio.numeri.quantitas-ordo']);
    expect(q.outcome('2')['observed'], [shared]);
    expect(q.skills, isNot(contains('compositio.curriculum.numerals.1')));
    final s = GameSession(d, {}, (_) async {});
    addTearDown(s.dispose);
    s.state['skills']['compositio.numeri.quantitas-ordo'] = evidence();
    s.state['skills']['compositio.numeri.ordo-frequentia'] = evidence();
    final before = s.progress(frequency.data['skills'].single)!;
    expect(before, greaterThan(0));
    expect(before, lessThan(1));
    s.state['purchased'].add(quantity.address);
    await s.start(quantity);
    await s.begin();
    s.state['encounter']['question'] = q.data;
    await s.answer('0');
    expect(s.skill(shared)['correct'], 1);
    expect(s.progress(frequency.data['skills'].single), greaterThan(before));
    expect(s.cardMastered(frequency), false);
    expect(s.state['completed'][frequency.address] ?? 0, 0);
  });

  test(
    'conditional completion diagnoses only the chosen consequence',
    () async {
      final d = await GameDesign.load(
        'assets/designs/grammaticon/game.json',
        readFile,
      );
      final card = d.cards['templum/condiciones-componendae/2']!;
      final entries = await d.questions(card);
      final q = await d.materialize(
        card,
        entries.firstWhere(
          (entry) => entry.item.startsWith('compositio-condicio-2-auxilium|'),
        ),
      );
      const modality = 'compositio.condiciones.potentialis';
      const consequenceTime = 'compositio.condiciones.tempus-apodosis';
      const premiseTime = 'compositio.condiciones.tempus-protasis';
      expect(q.skills, unorderedEquals([modality, consequenceTime]));
      expect(q.outcome('1')['observed'], [modality]);
      expect(q.outcome('2')['observed'], [consequenceTime]);
      final s = GameSession(d, {}, (_) async {});
      addTearDown(s.dispose);
      s.state['purchased'].add(card.address);
      await s.start(card);
      await s.begin();
      s.state['encounter']['question'] = q.data;
      await s.answer('2');
      expect(s.skill(consequenceTime)['wrong'], 1);
      expect(s.skill(modality), isEmpty);
      expect(s.skill(premiseTime), isEmpty);
    },
  );

  test(
    'production distinguishes relative purpose, number and tense failures',
    () async {
      final d = await GameDesign.load(
        'assets/designs/grammaticon/game.json',
        readFile,
      );
      final card = d.cards['templum/sententiae-subordinatae/8']!;
      final index = await d.questions(card);
      final q = await d.materialize(
        card,
        index.firstWhere((q) => q.item.startsWith('produce-purpose-plural|')),
      );
      final byText = {
        for (final c in q.choices) d.text(c['text']): c['id'] as String,
      };
      expect(q.outcome(byText['petunt']!)['observed'], [
        'compositio.curriculum.subordination.8',
      ]);
      expect(q.outcome(byText['petat']!)['observed'], [
        'compositio.relative-number',
      ]);
      expect(q.outcome(byText['peterent']!)['observed'], [
        'compositio.curriculum.subordination.1',
      ]);
      final s = GameSession(d, {}, (_) async {});
      addTearDown(s.dispose);
      s.state['purchased'].add(card.address);
      await s.start(card);
      await s.begin();
      s.state['encounter']['question'] = q.data;
      await s.answer(byText['petat']!);
      expect(s.skill('compositio.relative-number')['wrong'], 1);
      expect(s.skill('compositio.curriculum.subordination.8'), isEmpty);
      expect(s.skill('compositio.curriculum.subordination.1'), isEmpty);
    },
  );

  test(
    'exposure to four stimuli cannot replace four successful proofs',
    () async {
      final d = await graph();
      final s = GameSession(d, {}, (_) async {});
      addTearDown(s.dispose);
      final card = d.cards['observatory/discovery/durations']!;
      s.state['skills']['fine-a'] = evidence()..['successfulItems'] = ['a'];
      s.state['skills']['fine-b'] = evidence();
      expect(s.progress('fine-a'), 0.5);
      expect(s.cardMastered(card), false);
      s.state['skills']['fine-a']['successfulItems'] = ['a', 'b'];
      expect(s.cardMastered(card), true);
    },
  );

  test(
    'adaptive practice favors a new diagnostic stimulus over new scenery',
    () async {
      final d = await demo();
      final s = GameSession(d, {}, (_) async {});
      addTearDown(s.dispose);
      final card = d.cards['observatory/discovery/durations']!;
      card.data['questionSelection'] = 'adaptive';
      final original = (await d.questions(card)).first;
      for (final id in original.skills) {
        s.state['skills'][id] = evidence()
          ..['successfulItems'] = ['same-construction'];
      }
      final repeated = QuestionEntry({
        ...original.data,
        'id': 'new-scenery',
        'evidenceItem': 'same-construction',
      });
      final novel = QuestionEntry({
        ...original.data,
        'id': 'new-stimulus',
        'evidenceItem': 'different-construction',
      });
      expect(s.weight(card, novel), greaterThan(s.weight(card, repeated)));
    },
  );

  test(
    'real combined morphology attributes only the failed component',
    () async {
      final d = await GameDesign.load(
        'assets/designs/grammaticon/game.json',
        readFile,
      );
      final card = d.cards['amphitheatrum/section-1/ind-praes-act']!;
      final index = await d.questions(card);
      final q = await d.materialize(
        card,
        index.firstWhere((q) => q.dimension == 'personaNumerus'),
      );
      final wrong =
          q.choices.firstWhere((c) {
                final failed = strings(q.outcome(c['id'])['observed']);
                return failed.isNotEmpty && failed.length < q.skills.length;
              })['id']
              as String;
      final failed = strings(q.outcome(wrong)['observed']).toSet();
      final s = GameSession(d, {}, (_) async {});
      addTearDown(s.dispose);
      await s.start(card);
      await s.begin();
      s.state['encounter']['question'] = q.data;
      await s.answer(wrong);
      for (final id in q.skills) {
        if (failed.contains(id)) {
          expect(s.skill(id)['wrong'], 1);
        } else {
          expect(s.skill(id), isEmpty);
        }
      }
      expect(s.skill('v.ind.praes.act'), isEmpty);
      expect(s.cardMastered(card), false);
    },
  );

  test('mean progress counts distinct leaves, not nested aggregates', () async {
    final d = await graph();
    d.knowledge['time-units']!['aggregation']['skills'] = [
      'fine-a',
      'nested',
      'fine-b',
    ];
    final s = GameSession(d, {}, (_) async {});
    addTearDown(s.dispose);
    expect(s.progress('time-units'), isNull);
    s.state['skills']['fine-a'] = evidence(estimate: 0.8);
    expect(s.progress('time-units'), closeTo(0.4, 1e-9));
    s.state['skills']['fine-b'] = evidence(estimate: 0.4);
    expect(s.progress('time-units'), closeTo(0.6, 1e-9));
    expect(s.cardMastered(d.cards['observatory/discovery/durations']!), false);
  });

  test(
    'adaptive selection targets weakest skill despite volume and recency',
    () async {
      final d = await demo();
      final card = d.cards['observatory/discovery/durations']!;
      final bank = await d.questions(card);
      for (final id in ['fine-a', 'fine-b']) {
        d.knowledge[id] = {'id': id, 'name': id};
      }
      card.data['skills'] = ['fine-a', 'fine-b'];
      final source = bank.first.data;
      bank.clear();
      for (var i = 0; i < 101; i++) {
        bank.add(
          QuestionEntry({
            ...source,
            'id': 'target-$i',
            'skills': [i == 100 ? 'fine-b' : 'fine-a'],
            'selectionGroup': i == 100 ? 'rare' : 'common',
            'eligible': {'all': []},
          }),
        );
      }
      card.data['questionSelection'] = 'adaptive';
      for (var seed = 0; seed < 20; seed++) {
        final s = GameSession(d, {}, (_) async {}, random: Random(seed));
        addTearDown(s.dispose);
        s.state['skills']['fine-a'] = evidence();
        s.state['recentQuestions'] = {
          card.address: ['target-100'],
        };
        await s.start(card);
        await s.begin();
        expect(s.question!.skills, ['fine-b']);
      }
    },
  );

  test('malformed snapshots cannot credit composite skills', () async {
    final d = await demo();
    final s = GameSession(d, {}, (_) async {});
    addTearDown(s.dispose);
    await s.start(d.cards['observatory/discovery/durations']!);
    await s.begin();
    s.state['encounter']['question']['skills'] = ['time-units'];
    final before = s.exportJson;
    await expectLater(
      s.answer(s.question!.accepted.first),
      throwsFormatException,
    );
    expect(s.exportJson, before);
  });

  test(
    'compositions include unknown leaves and never read coarse card scores',
    () async {
      final d = await graph();
      final s = GameSession(d, {}, (_) async {});
      addTearDown(s.dispose);
      final card = d.cards['observatory/discovery/durations']!;
      s.state['completed'][card.address] = 900;
      s.state['skills']['time-units'] = evidence();
      s.state['skills']['fine-a'] = evidence();
      expect(s.progress('time-units'), 0.5);
      expect(s.level('time-units'), 0);
      expect(s.cardMastered(card), false);
      expect(s.meets({'completed': card.address}), false);
      s.state['completed'][card.address] = 0;
      s.state['skills']['fine-b'] = evidence();
      expect(s.progress('time-units'), 1);
      expect(s.cardMastered(card), true);
      expect(s.meets({'mastered': card.address}), true);
      s.state['skills']['fine-b']['estimate'] = 0.2;
      expect(s.cardMastered(card), false);
    },
  );

  test(
    'wrong choice updates only declared failed skills, not prerequisites',
    () async {
      final d = await demo();
      final s = GameSession(d, {}, (_) async {});
      addTearDown(s.dispose);
      final card = d.cards['observatory/discovery/durations']!;
      await s.start(card);
      await s.begin();
      for (final id in ['fine-a', 'fine-b', 'prerequisite']) {
        d.knowledge[id] = {'id': id, 'name': id};
      }
      final raw = object(jsonDecode(jsonEncode(s.question!.data)));
      raw['skills'] = ['fine-a', 'fine-b'];
      raw['requires'] = ['prerequisite'];
      final q = QuestionEntry(raw);
      final wrong = q.choices.firstWhere(
        (c) => !q.accepted.contains(c['id']),
      )['id'];
      raw['outcomes'][wrong]['observed'] = ['fine-b'];
      s.state['encounter']['question'] = raw;
      await s.answer(wrong);
      expect(s.skill('fine-b')['wrong'], 1);
      expect(s.skill('fine-a'), isEmpty);
      expect(s.skill('prerequisite'), isEmpty);
      expect(s.skill('time-units'), isEmpty);
    },
  );

  test(
    'shared skills link questions across cards and retire errors with evidence',
    () async {
      final d = await demo();
      final s = GameSession(d, {}, (_) async {});
      addTearDown(s.dispose);
      final card = d.cards['observatory/discovery/durations']!;
      await s.start(card);
      await s.begin();
      final q = s.question!;
      s.state['errors']['other-question'] = {
        'assessment': 'other-assessment',
        'encounterId': 'previous',
        'outcome': {'observed': q.skills},
        'question': q.data,
        'successes': 0,
      };
      final baseline = s.weight(card, q, encounterId: 'previous');
      expect(s.weight(card, q), greaterThan(baseline));
      expect(
        s.practiceTargets(object(s.state['errors']['other-question'])),
        isNotEmpty,
      );
      d.rules['selection'] = {
        ...object(d.rules['selection']),
        'retireAfter': 1,
      };
      await s.answer(q.accepted.first);
      expect(s.state['errors'], isEmpty);
    },
  );

  test(
    'old coarse evidence is archived without granting new skill mastery',
    () async {
      final d = await graph();
      final s = GameSession(d, {}, (_) async {});
      final saved = object(jsonDecode(s.exportJson));
      saved.remove('masteryRevision');
      saved['skills']['fine-a'] = evidence();
      saved['balance'] = 123;
      saved['purchased'] = ['observatory/discovery/durations'];
      final restored = GameSession(d, saved, (_) async {});
      addTearDown(s.dispose);
      addTearDown(restored.dispose);
      expect(restored.skill('fine-a'), isEmpty);
      expect(restored.state['previousMastery']['skills']['fine-a'], isNotEmpty);
      expect(restored.balance, 123);
      expect(
        restored.state['purchased'],
        contains('observatory/discovery/durations'),
      );
    },
  );

  test('dependency and composition cycles are rejected', () async {
    final d = await graph();
    d.validate();
    d.knowledge['fine-a']!['requires'] = ['fine-b'];
    expect(d.validate, throwsFormatException);
    d.knowledge['fine-a']!.remove('requires');
    d.knowledge['nested']!['aggregation'] = {
      'skills': ['time-units'],
    };
    expect(d.validate, throwsFormatException);
  });

  test('real lexical evidence is word-specific, directional and only evaluated in vocabulary cards', () async {
    final d = await GameDesign.load(
      'assets/designs/grammaticon/game.json',
      readFile,
    );
    final words = <String, Set<String>>{};
    for (final place in ['theatrum', 'templum']) {
      for (final section in d.nodes[place]!.children) {
        final encountered = <String>{};
        final lexical = <String>{};
        expect(section.children.last.id, 'vocabula');
        for (final card in section.children) {
          final bank = await d.questions(card);
          for (final entry in bank) {
            final q = await d.materialize(card, entry);
            if (card.id == 'vocabula') {
              expect(q.skills, hasLength(1));
              expect(q.skills.single, startsWith('lexicon.'));
              lexical.add(q.item);
              words.putIfAbsent(q.item, () => {}).add(q.skills.single);
            } else {
              expect(q.skills.any((id) => id.startsWith('lexicon.')), false);
              encountered.addAll(strings(q.data['vocabulary']));
            }
            for (final choice in q.choices) {
              final failed = strings(q.outcome(choice['id'])['observed']);
              expect(q.skills.toSet().containsAll(failed), true);
              expect(failed.isEmpty, q.accepted.contains(choice['id']));
            }
          }
        }
        expect(lexical, encountered, reason: section.address);
      }
    }
    for (final word in words.keys) {
      expect(d.knowledge.containsKey('lexicon.lectio.$word'), true);
      expect(d.knowledge.containsKey('lexicon.compositio.$word'), true);
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}
