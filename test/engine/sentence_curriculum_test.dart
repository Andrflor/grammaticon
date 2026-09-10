import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/engine/design.dart';
import 'package:grammaticon/engine/session.dart';

import 'design_test.dart' show readFile;

void main() {
  late GameDesign design;
  late Json report;
  setUpAll(() async {
    design = await GameDesign.load(
      'assets/designs/grammaticon/game.json',
      readFile,
    );
    report = object(
      jsonDecode(
        await readFile(
          'assets/designs/grammaticon/learning-content-report.json',
        ),
      ),
    );
  });
  test('groups have precise subjects, paid progression and final vocabulary in both directions', () async {
    for (final placeId in ['theatrum', 'templum']) {
      final place = design.nodes[placeId]!;
      final cards = place.children.expand((s) => s.children).toList();
      expect(cards.where((c) => c.price == 0).map((c) => c.address), [
        '$placeId/loca/a-ablative',
      ]);
      for (final group in place.children) {
        expect(group.children.length, greaterThanOrEqualTo(4));
        expect(group.children.last.id, 'vocabula');
        for (final card in group.children) {
          expect(card.data['skills'], hasLength(1));
          expect(['Thema', 'Versiō'], isNot(contains(card.data['name'])));
          if (card.price > 0) expect(card.requirements['all'], isNotEmpty);
        }
      }
    }
    for (final group in objects(report['groups'])) {
      final expectedWords = objects(group['vocabulary'])
          .map((w) => w['id'])
          .toSet();
      final encountered = <String>{};
      for (final topic in objects(group['topics'])) {
        for (final mode in ['version', 'theme']) {
          final card = design.cards[topic['cards'][mode]]!;
          for (final q in await design.questions(card)) {
            encountered.addAll(strings(q.data['vocabulary']));
            expect(q.data['editorial']['language'], 'la');
            expect(
              design
                  .text(objects(q.data['content']).first['text'])
                  .trim()
                  .split(RegExp(r'\s+'))
                  .length,
              greaterThan(1),
            );
            for (final c in q.choices) {
              expect(q.outcome(c['id'])['practice'], isEmpty);
            }
          }
        }
      }
      expect(encountered, expectedWords);
      for (final mode in ['version', 'theme']) {
        final card = design.cards[group['vocabularyCards'][mode]]!;
        final bank = await design.questions(card);
        expect(
          strings(
            design.knowledge[strings(card.data['skills'])
                .single]!['masteryRequirements']['successfulItems'],
          ).toSet(),
          bank.map((q) => q.item).toSet(),
        );
        expect(bank.map((q) => q.id).toSet(), expectedWords);
        expect(bank.length, expectedWords.length);
        expect(
          bank.every(
            (q) =>
                q.data['editorial']['translationDirection'] ==
                (mode == 'version' ? 'la-fr' : 'fr-la'),
          ),
          true,
        );
        final session = GameSession(design, {}, (_) async {});
        expect(session.meets(card.requirements), false);
        for (final topic in objects(group['topics'])) {
          session.state['completed'][topic['cards'][mode]] = 1;
        }
        expect(session.meets(card.requirements), true);
        expect(
          session.unlocked(card),
          false,
          reason: 'Prerequisites do not grant a paid card',
        );
        session.dispose();
      }
    }
  });
  for (final placeId in ['theatrum', 'templum']) {
    test('$placeId can be completed without grinding after correct answers', () async {
      final session = GameSession(design, {}, (_) async {});
      addTearDown(session.dispose);
      // Use real purchases and rewards, starting with the configured balance.
      // No purchases, completions or mastery records are injected by the test.
      for (final section in design.nodes[placeId]!.children) {
        for (final card in section.children) {
          if (!session.unlocked(card)) {
            expect(
              session.purchasable(card),
              true,
              reason:
                  '${card.address}: ${session.balance} gems, price ${card.price}',
            );
            await session.buy(card);
          }
          await session.start(card);
          await session.begin();
          var answers = 0;
          while (session.encounter?['phase'] == 'question') {
            expect(++answers, lessThanOrEqualTo(100), reason: card.address);
            await session.answer(session.question!.accepted.first);
            await session.advance();
          }
          expect(session.encounter?['phase'], 'victory', reason: card.address);
          expect(session.state['completed'][card.address], 1);
        }
      }
    });
  }
  test(
    'lexical mastery requires successful evidence for every authored item',
    () async {
      final card = design.cards['theatrum/itinera/vocabula']!;
      final id = strings(card.data['skills']).single;
      final bank = await design.questions(card);
      final required = bank.map((q) => q.item).toList();
      final session = GameSession(design, {}, (_) async {});
      addTearDown(session.dispose);
      session.state['skills'][id] = {
        'correct': 100,
        'wrong': 0,
        'estimate': 1.0,
        'highWater': 1.0,
        'items': required,
        'recent': [
          {'correct': true, 'assisted': false, 'item': required.first},
        ],
        'successfulItems': required.skip(1).toList(),
      };
      final mastered = objects(session.mastery['levels']).length - 1;
      expect(session.level(id), lessThan(mastered));
      expect(
        session.progress(id),
        closeTo((required.length - 1) / required.length, 0.000001),
      );
      expect(session.level(id, rewards: true), mastered);
      session.state['skills'][id]['successfulItems'] = required;
      expect(session.level(id), mastered);
      expect(session.progress(id), 1.0);
      // Legacy saves with many observations but no item-level evidence cannot
      // certify unseen items. Their recorded recent successes remain usable.
      session.state['skills'][id].remove('successfulItems');
      expect(session.level(id), lessThan(mastered));
      session.state['purchased'] = [...design.nodes.keys];
      await session.start(card);
      await session.begin();
      final item = session.question!.item;
      await session.answer(session.question!.accepted.first);
      expect(strings(session.skill(id)['successfulItems']), contains(item));
      final restored = GameSession(
        design,
        object(jsonDecode(session.exportJson)),
        (_) async {},
      );
      addTearDown(restored.dispose);
      expect(
        restored.skill(id)['successfulItems'],
        session.skill(id)['successfulItems'],
      );
      expect(restored.level(id), lessThan(mastered));
    },
  );
  test(
    'incorrect and assisted answers do not certify required items',
    () async {
      final card = design.cards['templum/itinera/vocabula']!;
      final id = strings(card.data['skills']).single;
      for (final assisted in [false, true]) {
        final session = GameSession(design, {}, (_) async {});
        addTearDown(session.dispose);
        session.state['purchased'] = [...design.nodes.keys];
        await session.start(card);
        await session.begin();
        final q = session.question!;
        session.state['skills'][id] = {
          'successfulItems': assisted ? <String>[] : [q.item],
        };
        if (assisted) await session.help();
        await session.answer(
          assisted
              ? q.accepted.first
              : q.choices.firstWhere(
                  (c) => !q.accepted.contains(c['id']),
                )['id'],
        );
        expect(
          strings(session.skill(id)['successfulItems']),
          isNot(contains(q.item)),
        );
      }
    },
  );
  test(
    'mastery requirements reject empty, duplicate and invalid item identifiers',
    () {
      final node = design.knowledge['study.lexicon.theatrum.itinera']!;
      final original = node['masteryRequirements'];
      try {
        for (final items in [
          [],
          ['x', 'x'],
          [''],
          [12],
          'x',
        ]) {
          node['masteryRequirements'] = {'successfulItems': items};
          expect(design.validate, throwsFormatException);
        }
      } finally {
        node['masteryRequirements'] = original;
      }
      expect(design.validate, returnsNormally);
    },
  );
  test('first contrast preserves and assesses the macron rather than normalizing it away', () async {
    final card = design.cards['templum/loca/a-ablative']!;
    final bank = await design.questions(card);
    final first = bank.first;
    expect(
      first.choices.map((c) => c['text']),
      containsAll(['Puella in Italiā est.', 'Puella in Italia est.']),
    );
    for (final text in ['Puella in Italiā est.', 'Puella in Italia est.']) {
      final session = GameSession(design, {}, (_) async {});
      await session.start(card);
      await session.begin();
      session.state['encounter']['question'] = first.data;
      final choice = session.question!.choices.singleWhere(
        (c) => c['text'] == text,
      );
      await session.answer(choice['id']);
      expect(session.encounter!['lastCorrect'], text.contains('Italiā'));
      session.dispose();
    }
    expect(
      design.nodes['theatrum']!.children.first.children.first.id,
      'a-ablative',
    );
    expect(
      design.nodes['templum']!.data['presentation']['labels']['encounter'],
      'Rītus',
    );
  });
}
