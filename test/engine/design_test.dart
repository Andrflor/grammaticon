import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/engine/design.dart';
import 'package:grammaticon/engine/session.dart';

Future<String> readFile(String path) async => path.endsWith('.gz')
    ? utf8.decode(
        const GZipDecoder().decodeBytes(await File(path).readAsBytes()),
      )
    : File(path).readAsString();
Future<GameDesign> demo() =>
    GameDesign.load('assets/designs/compass/game.json', readFile);

void main() {
  test('unrelated design defines all places, levels, skills, languages and interactions', () async {
    final d = await demo();
    expect(d.places.map((p) => p.id), ['observatory', 'archives', 'map-room']);
    expect(d.cards.length, 6);
    expect(objects(d.rules['mastery']['levels']).length, 3);
    expect(d.label('actions.help', 'en'), 'Help');
    expect(d.label('actions.help', 'fr'), 'Aide');
    final types = <String>{};
    for (final c in d.cards.values) {
      for (final q in await d.questions(c)) {
        types.add(q.interaction);
        expect(q.choices.length, 3);
      }
    }
    expect(types, GameDesign.interactions);
  });
  test('fixed choice order and exact snapshot survive answering, saving and reloading', () async {
    final d = await demo();
    String? saved;
    var time = DateTime(2026, 9, 9);
    final s = GameSession(
      d,
      {},
      (raw) async {
        saved = raw;
      },
      random: Random(8),
      clock: () => time,
    );
    final c = d.cards['observatory/discovery/durations']!;
    await s.start(c);
    await s.begin();
    final shown = s.question!;
    final order = shown.choices.map((c) => c['id']).toList();
    time = time.add(const Duration(seconds: 90));
    s.state['encounter']['elapsedMs'] = 90000;
    await s.answer(shown.accepted.first);
    expect(s.encounter!['lastCorrect'], true);
    expect(s.state['errors'], isEmpty);
    expect(
      s.state['observations'].last['responseTimeMs'],
      greaterThanOrEqualTo(90000),
    );
    expect(
      s.state['observations'].last['question']['choices']
          .map((c) => c['id'])
          .toList(),
      order,
    );
    final restored = GameSession(d, object(jsonDecode(saved!)), (_) async {});
    expect(restored.question!.data, shown.data);
    expect(restored.state['transaction'], 1);
    await restored.answer(shown.accepted.first);
    expect(restored.state['transaction'], 1);
  });
  test('wrong choices follow explicit cross-place links only; replay excludes current encounter', () async {
    final d = await demo();
    final s = GameSession(d, {}, (_) async {}, random: Random(2));
    final c = d.cards['archives/discovery/centuries']!;
    await s.start(c);
    await s.begin();
    final q = s.question!;
    final wrong =
        q.choices.firstWhere((c) => !q.accepted.contains(c['id']))['id']
            as String;
    final before = s.weight(c, q, encounterId: s.encounter!['id']);
    await s.answer(wrong);
    final e = object(object(s.state['errors']).values.single);
    expect(
      s.practiceTargets(e).map((t) => t['card']),
      contains('observatory/discovery/durations'),
    );
    final related = d.cards['observatory/discovery/durations']!;
    final rq = (await d.questions(related)).first;
    expect(
      s.weight(related, rq),
      greaterThan(s.weight(related, rq, encounterId: s.encounter!['id'])),
    );
    // A matching dimension elsewhere creates no relation without a design edge.
    final unrelated = d.cards['map-room/discovery/orientation']!;
    final uq = (await d.questions(unrelated)).first;
    expect(
      s.weight(unrelated, uq),
      s.weight(unrelated, uq, encounterId: s.encounter!['id']),
    );
    expect(before, greaterThan(0));
  });
  test('complex access predicates are distinct from knowledge and purchase is permanent', () async {
    final d = await demo();
    final s = GameSession(d, {}, (_) async {});
    final c = d.cards['map-room/discovery/scale']!;
    expect(s.purchasable(c), false);
    s.state['completed']['observatory/discovery/durations'] = 1;
    expect(s.purchasable(c), false);
    for (final id in d.skillLeaves('time-units')) {
      s.state['skills'][id] = {
        'correct': 20,
        'wrong': 0,
        'estimate': 1.0,
        'highWater': 1.0,
        'items': ['a', 'b', 'c', 'd'],
        'successfulItems': ['a', 'b', 'c', 'd'],
        'recent': [
          for (var i = 0; i < 20; i++) {'correct': true},
        ],
      };
    }
    expect(s.purchasable(c), true);
    final initial = s.balance;
    await s.buy(c);
    expect(s.balance, initial - c.price);
    expect(s.unlocked(c), true);
    s.state['completed'].clear();
    expect(s.unlocked(c), true);
  });
  test('two autonomous successes retire only the authored assessment; assistance does not', () async {
    final d = await demo();
    final s = GameSession(d, {}, (_) async {}, random: Random(4));
    final c = d.cards['archives/discovery/centuries']!;
    await s.start(c);
    await s.begin();
    final q = s.question!;
    await s.answer(
      q.choices.firstWhere((x) => !q.accepted.contains(x['id']))['id'],
    );
    Future<void> present({bool assisted = false}) async {
      s.state['encounter']['question'] = q.data;
      s.state['encounter']['phase'] = 'question';
      s.state['encounter']['assisted'] = assisted;
      await s.answer(q.accepted.first);
    }

    await present(assisted: true);
    expect(s.state['errors'], isNotEmpty);
    await present();
    expect(s.state['errors'], isNotEmpty);
    await present();
    expect(s.state['errors'], isEmpty);
  });
  test('invalid authored choice, unsupported interaction and missing links fail validation', () async {
    final d = await demo();
    final c = d.cards.values.first;
    final source = (await d.questions(c)).first;
    Json copy() => object(jsonDecode(jsonEncode(source.data)));
    var q = copy();
    q['accepted'] = ['absent'];
    expect(
      () => d.validateQuestions(c, [QuestionEntry(q)]),
      throwsFormatException,
    );
    q = copy();
    q['interaction'] = 'subjectSpecificGenerator';
    expect(
      () => d.validateQuestions(c, [QuestionEntry(q)]),
      throwsFormatException,
    );
    q = copy();
    q['outcomes'][q['choices'][0]['id']]['practice'] = ['missing'];
    expect(
      () => d.validateQuestions(c, [QuestionEntry(q)]),
      throwsFormatException,
    );
  });
  test('runtime source has no subject-specific dependencies or question generators', () {
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  f.path.endsWith('.dart') &&
                  (f.path.startsWith('lib/engine/') ||
                      f.path == 'lib/main.dart'),
            )) {
      final text = file.readAsStringSync();
      expect(
        RegExp(
          r"import .*?(linguistics|pedagogy/|question_generator|forum|reading|config_store)",
        ).hasMatch(text),
        false,
        reason: file.path,
      );
      expect(
        RegExp(
          r'\b(Constructio|Conjugator|Declinator|Activity\.amphitheatrum|Dimension\.casus)\b',
        ).hasMatch(text),
        false,
        reason: file.path,
      );
    }
  });
}
