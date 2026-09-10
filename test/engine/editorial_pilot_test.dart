import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/engine/design.dart';
import 'package:grammaticon/engine/session.dart';

import 'design_test.dart' show readFile;

const pilotRoot = 'doc/pedagogy/pilot';
const designRoot = 'assets/designs/grammaticon/';

/// The authored pilot is now integrated in the shipped design.
Future<GameDesign> loadEditorialPilot() =>
    GameDesign.load('${designRoot}game.json', readFile);

void main() {
  late GameDesign d;
  setUpAll(() async {
    d = await loadEditorialPilot();
  });
  bool pilot(ContentNode c) =>
      c.address.startsWith('theatrum/giving/') ||
      c.address.startsWith('templum/giving/');

  test('six integrated introductory cards and every explicit remediation target validate against the real engine', () async {
    final cards = d.cards.values.where(pilot).toList();
    expect(cards.length, 6);
    var total = 0;
    final identities = <String>{};
    for (final card in cards) {
      final questions = await d.questions(card);
      total += questions.length;
      expect(await d.lesson(card), isNotEmpty);
      for (final q in questions) {
        expect(identities.add('${card.address}#${q.id}'), true);
        expect(await d.help(q.data['help'] as String), isNotEmpty);
        expect(
          q.data['next'],
          isNull,
          reason: 'This pilot does not certify an exhaustive sequence.',
        );
        for (final choice in q.choices) {
          final outcome = q.outcome(choice['id'] as String);
          expect(d.text(outcome['feedback']), isNotEmpty);
          if (!q.accepted.contains(choice['id'])) {
            expect(outcome['observed'], isNotEmpty);
            expect(outcome['practice'], isNotEmpty);
          }
        }
      }
    }
    expect(total, 40);
    for (final set in objects(
      d.pedagogy['practiceSets'],
    ).where((p) => (p['id'] as String).startsWith('pilot.'))) {
      for (final target in objects(set['targets'])) {
        final bank = await d.questions(d.cards[target['card']]!);
        expect(
          bank.map((q) => q.id).toSet(),
          containsAll(strings(target['questions'])),
          reason: set['id'],
        );
      }
    }
    final review = object(jsonDecode(await readFile('$pilotRoot/review.json')));
    expect(
      objects(review['questions']).map((r) => r['question']).toSet(),
      identities,
    );
    expect(
      objects(review['questions'])
          .every((r) => r['linguisticReview'] == 'pending'),
      true,
    );
  });

  test('lexical and role distractors follow different authored links in a live session', () async {
    final card = d.cards['theatrum/giving/versions']!;
    final bank = await d.questions(card);
    final gift = bank.singleWhere((q) => q.id == 'gift');
    for (final choice in ['0', '2']) {
      String? persisted;
      final s = GameSession(d, {}, (raw) async {
        persisted = raw;
      });
      s.state['completed']['theatrum/giving/words'] = 1;
      s.state['completed']['theatrum/giving/roles'] = 1;
      await s.start(card);
      await s.begin();
      s.state['encounter']['question'] = gift.data;
      await s.answer(choice);
      final error = object(object(s.state['errors']).values.single);
      final outcome = object(error['outcome']);
      expect(
        outcome['practice'],
        choice == '0' ? ['pilot.review.recipient'] : ['pilot.word.bread'],
      );
      expect(
        outcome['observed'],
        choice == '0'
            ? ['pilot.evidence.agent-recipient-swap']
            : ['pilot.evidence.object-change'],
      );
      expect(s.practiceTargets(error), isNotEmpty);
      final restored = GameSession(
        d,
        object(jsonDecode(persisted!)),
        (_) async {},
      );
      expect(restored.question!.id, 'gift');
      expect(restored.state['errors'], s.state['errors']);
      s.dispose();
      restored.dispose();
    }
  });

  test('introductory access and dictionary recall are distinct from completed coverage', () async {
    final s = GameSession(d, {}, (_) async {});
    expect(s.unlocked(d.cards['theatrum/giving/words']!), true);
    expect(s.unlocked(d.cards['theatrum/giving/roles']!), false);
    s.state['completed']['theatrum/giving/words'] = 1;
    expect(s.unlocked(d.cards['theatrum/giving/roles']!), true);
    expect(s.unlocked(d.cards['templum/giving/construction']!), false);
    final read = (await d.questions(d.cards['theatrum/giving/words']!)).first;
    final produce = (await d.questions(d.cards['templum/giving/words']!)).first;
    expect(read.skills.toSet().intersection(produce.skills.toSet()), isEmpty);
    final coverage = object(
      jsonDecode(await readFile('doc/pedagogy/coverage.json')),
    );
    final units = objects(coverage['books'])
        .expand((b) => objects(b['units']))
        .toList();
    expect(units.length, 361);
    expect(units.every((u) => u['status'] == 'not-audited'), true);
    s.dispose();
  });
}
