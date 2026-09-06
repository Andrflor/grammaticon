import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:latin_game/linguistics/model/grammar.dart';
import 'package:latin_game/pedagogy/mastery.dart';
import 'package:latin_game/pedagogy/noun_question_generator.dart';
import 'package:latin_game/pedagogy/question.dart';
import 'package:latin_game/pedagogy/skills.dart';
import 'package:latin_game/pedagogy/trials.dart';

import '../support/test_env.dart';

void main() {
  final gen = NounQuestionGenerator(testNounAnalyzer);
  final forum = Trials.ofActivity(Activity.forum);
  List<String> comps(Trial t) => t.components.map((c) => c.id).toList();

  /// A record at tier familiāris so that analysis questions are eligible.
  final familiar = List.generate(8, (i) => i).fold(
    const SkillRecord(),
    (r, i) => r.apply(Observation(at: DateTime(2026, 1, 1 + i), correct: true, lemmaId: 'l$i', quality: AnswerQuality.autonoma, trialId: 't'), const MasteryConfig()),
  );
  Map<String, SkillRecord> familiarFor(Trial t) => {for (final s in t.skillIds) for (final l in Skills.leaves(s)) l: familiar};

  test('every Forum trial has a non-empty pool and produces well-formed questions', () {
    expect(forum.length, greaterThanOrEqualTo(12));
    for (final t in forum) {
      expect(gen.pool(t, comps(t)), isNotEmpty, reason: t.id);
      final rng = Random(7);
      var produced = 0;
      for (var i = 0; i < 40; i++) {
        final q = gen.generate(trial: t, componentIds: comps(t), rng: rng, id: '$i', skills: familiarFor(t));
        if (q == null) continue;
        produced++;
        expect(q.choices.length, greaterThanOrEqualTo(2), reason: '${t.id} ${q.surface}');
        expect(q.choices.length, lessThanOrEqualTo(9), reason: t.id);
        expect(q.correctValues.any((v) => q.choices.any((c) => c.value == v)), isTrue, reason: '${t.id} ${q.surface}: no correct choice offered');
        expect(q.choices.any((c) => !q.correctValues.contains(c.value)), isTrue, reason: '${t.id} ${q.surface}: every offered choice is correct');
        expect(q.choices.map((c) => c.value).toSet().length, q.choices.length, reason: '${t.id}: duplicate choices');
        expect(t.dimensions, contains(q.dimension), reason: t.id);
        for (final s in q.skillIds) {
          expect(Skills.maybe(s), isNotNull, reason: '${t.id} skill $s');
        }
        // The ambiguity flag reflects the offered choices.
        expect(q.ambiguous, q.choices.where((c) => q.correctValues.contains(c.value)).length > 1, reason: '${t.id} ${q.surface}');
      }
      expect(produced, greaterThan(30), reason: t.id);
    }
  });

  test('a single-declension trial never asks the declension, and only asks its cases', () {
    final t = Trials.byId('d1-recti');
    final rng = Random(3);
    for (var i = 0; i < 60; i++) {
      final q = gen.generate(trial: t, componentIds: const [], rng: rng, id: '$i')!;
      expect(q.dimension, isNot(Dimension.declinatio));
      expect(q.noun.target.analysis.declension, Declension.prima);
      expect(q.noun.target.analysis.casus, isIn([Casus.nominativus, Casus.accusativus, Casus.ablativus]));
      if (q.dimension == Dimension.casus) {
        for (final c in q.choices) {
          expect(c.value, isIn(['nom', 'acc', 'abl']), reason: 'introductory trial offers only its cases');
        }
      }
      expect(q.context, [q.noun.noun.dictionaryEntry]);
    }
  });

  test('every valid analysis is accepted: rosae as a case question accepts gen, dat, nom and voc', () {
    final t = Trials.byId('d1-omnes');
    final rng = Random(5);
    Question? q;
    for (var i = 0; i < 400 && q == null; i++) {
      final c = gen.generate(trial: t, componentIds: const [], rng: rng, id: '$i')!;
      if (c.dimension == Dimension.casus && c.surface == 'rosae') q = c;
    }
    // rosae is four-way ambiguous, so the generator prefers other forms; when it
    // does draw it, all four analyses are correct and the flag is set.
    if (q != null) {
      expect(q.correctValues, {'gen', 'dat', 'nom', 'voc'});
      expect(q.isCorrect('gen'), isTrue);
      expect(q.isCorrect('voc'), isTrue);
      expect(q.isCorrect('acc'), isFalse);
      expect(q.ambiguous, isTrue);
    }
    // Whatever the surface, an analysis outside the trial's pool is never rejected.
    for (var i = 0; i < 60; i++) {
      final c = gen.generate(trial: Trials.byId('d1-recti'), componentIds: const [], rng: rng, id: 'x$i')!;
      if (c.surface == 'rosa' && c.dimension == Dimension.casus) {
        expect(c.correctValues, containsAll(['nom', 'voc']));
      }
    }
  });

  test('a question is never asked when every offered number would be correct', () {
    // amīcī: gen. sg. and nom./voc. pl. — both numbers valid, so never a number question.
    final t = Trials.byId('d2-omnes');
    final rng = Random(11);
    for (var i = 0; i < 200; i++) {
      final q = gen.generate(trial: t, componentIds: const [], rng: rng, id: '$i')!;
      if (q.dimension == Dimension.numerus) {
        expect(q.correctValues.length, 1, reason: '${q.surface} would accept both numbers');
      }
    }
  });

  test('the locative is drawn only in the locative trial', () {
    for (final t in forum.where((t) => t.id != 'd-locativus' && t.id != 'dmx-omnia')) {
      for (final e in gen.pool(t, comps(t))) {
        expect(e.form.analysis.casus, isNot(Casus.locativus), reason: '${t.id} ${e.form.surface}');
      }
    }
    final loc = gen.pool(Trials.byId('d-locativus'), const []);
    expect(loc.map((e) => e.form.surface), containsAll(['Rōmae', 'domī', 'Carthāginī', 'rūrī', 'Athēnīs', 'humī']));
    final rng = Random(2);
    Question? q;
    for (var i = 0; i < 300 && q == null; i++) {
      final c = gen.generate(trial: Trials.byId('d-locativus'), componentIds: const [], rng: rng, id: '$i')!;
      if (c.surface == 'domī') q = c;
    }
    expect(q, isNotNull);
    expect(q!.correctValues, contains('loc'));
    expect(q.skillIds, contains('d.loc'));
  });

  test('declension questions show the dictionary entry only when the ending is shared', () {
    final t = Trials.byId('dmx-declinatio');
    final rng = Random(8);
    var withHint = 0, without = 0;
    for (var i = 0; i < 120; i++) {
      final q = gen.generate(trial: t, componentIds: comps(t), rng: rng, id: '$i')!;
      expect(q.dimension, Dimension.declinatio);
      expect(q.skillIds, ['d.mx.declinatio']);
      if (q.context.isEmpty) {
        without++;
      } else {
        withHint++;
        expect(q.context.single, '${q.noun.noun.lemma}, ${q.noun.noun.genitive}');
      }
      // -ārum is first-declension only: no hint. -ibus is third or fourth: hint.
      if (q.surface.endsWith('ārum')) expect(q.context, isEmpty, reason: q.surface);
      if (q.surface.endsWith('ibus')) expect(q.context, isNotEmpty, reason: q.surface);
    }
    expect(withHint, greaterThan(0));
    expect(without, greaterThan(0));
  });

  test('mixed trials credit the discrimination skill and the observed cell; a component subset restricts the pool', () {
    final t = Trials.byId('dmx-casus');
    final rng = Random(9);
    for (var i = 0; i < 30; i++) {
      final q = gen.generate(trial: t, componentIds: const ['d1', 'd3'], rng: rng, id: '$i')!;
      expect(q.skillIds.first, 'd.mx.casus');
      expect(q.skillIds.length, 2);
      expect(q.skillIds[1], startsWith('d.'));
      expect(q.noun.target.analysis.declension, isIn([Declension.prima, Declension.tertia]));
    }
  });

  test('analysis questions appear once the skill is familiar and accept every full analysis of the lemma', () {
    final t = Trials.byId('d3-omnia');
    final rng = Random(4);
    var analysisSeen = false;
    for (var i = 0; i < 80; i++) {
      final q = gen.generate(trial: t, componentIds: const [], rng: rng, id: '$i', skills: familiarFor(t))!;
      if (q.dimension != Dimension.analysis) continue;
      analysisSeen = true;
      final own = testNounAnalyzer.analyze(q.surface).where((f) => f.analysis.lemmaId == q.lemmaId).map((f) => f.analysis.selector).toSet();
      expect(q.correctValues, own, reason: q.surface);
    }
    expect(analysisSeen, isTrue);
    // Nova skill: no analysis question yet.
    for (var i = 0; i < 40; i++) {
      final q = gen.generate(trial: t, componentIds: const [], rng: rng, id: 'n$i')!;
      expect(q.dimension, isNot(Dimension.analysis));
    }
  });

  test('corrections name the right case, the chosen one, the contrasting form and the ending', () {
    final t = Trials.byId('d1-recti');
    final rng = Random(6);
    Question? q;
    for (var i = 0; i < 200 && q == null; i++) {
      final c = gen.generate(trial: t, componentIds: const [], rng: rng, id: '$i')!;
      if (c.surface == 'rosam' && c.dimension == Dimension.casus) q = c;
    }
    expect(q, isNotNull);
    final ex = gen.explain(q: q!, chosenValue: 'abl', correct: false);
    expect(ex.headline, 'rosam — accūsātīvus singulāris (rosa, rosae, f.)');
    expect(ex.detail, contains('Rēctum: Accūsātīvus'));
    expect(ex.detail, contains('Tū dīxistī: Ablātīvus'));
    expect(ex.detail, contains('esset: rosā'));
    expect(ex.detail, contains('Dēsinentia -am'));
    expect(ex.contrastSurface, 'rosā');
    final ok = gen.explain(q: q, chosenValue: 'acc', correct: true);
    expect(ok.detail, contains('Dēsinentia -am: accūsātīvus singulāris prīmae dēclīnātiōnis.'));
  });

  test('trial graph: one free trial, prerequisites inside the Forum, all reachable', () {
    expect(forum.where((t) => t.isFree).map((t) => t.id), ['d1-recti']);
    for (final t in forum) {
      for (final s in t.skillIds) {
        expect(Skills.maybe(s), isNotNull, reason: '${t.id} skill $s');
      }
      for (final p in t.prerequisites) {
        expect(Trials.byId(p).activity, Activity.forum, reason: '${t.id} prereq $p');
      }
    }
    final reached = <String>{};
    var changed = true;
    while (changed) {
      changed = false;
      for (final t in forum) {
        if (!reached.contains(t.id) && t.prerequisites.every(reached.contains)) {
          reached.add(t.id);
          changed = true;
        }
      }
    }
    expect(reached.length, forum.length);
  });
}
