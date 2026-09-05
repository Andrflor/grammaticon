import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:latin_game/linguistics/engine/analyzer.dart';
import 'package:latin_game/linguistics/engine/conjugator.dart';
import 'package:latin_game/linguistics/lexicon/verbs.dart';
import 'package:latin_game/linguistics/model/grammar.dart';
import 'package:latin_game/pedagogy/question_generator.dart';
import 'package:latin_game/pedagogy/skills.dart';
import 'package:latin_game/pedagogy/trials.dart';

void main() {
  final analyzer = Analyzer(kVerbs, Conjugator());
  final gen = QuestionGenerator(analyzer);

  List<String> comps(Trial t) => t.components.map((c) => c.id).toList();

  test('every trial has a non-empty pool and produces questions', () {
    for (final t in Trials.all) {
      final pool = gen.pool(t, comps(t));
      expect(pool, isNotEmpty, reason: t.id);
      final rng = Random(7);
      var produced = 0;
      for (var i = 0; i < 30; i++) {
        final q = gen.generate(trial: t, componentIds: comps(t), rng: rng, id: '$i');
        if (q != null) {
          produced++;
          expect(q.choices.length, greaterThanOrEqualTo(2), reason: '${t.id} ${q.surface} ${q.dimension}');
          expect(q.choices.length, lessThanOrEqualTo(9), reason: t.id);
          expect(q.correctValues.any((v) => q.choices.any((c) => c.value == v)), isTrue, reason: '${t.id}: correct value absent from choices');
          expect(q.choices.where((c) => !q.correctValues.contains(c.value)).length, greaterThanOrEqualTo(1), reason: '${t.id}: no wrong choice');
          expect(q.choices.map((c) => c.value).toSet().length, q.choices.length, reason: '${t.id}: duplicate choices');
          expect(t.dimensions, contains(q.dimension));
        }
      }
      expect(produced, greaterThan(20), reason: t.id);
    }
  });

  test('fixed-tense trials never ask tense, mood or voice', () {
    final t = Trials.byId('ind-praes-act');
    final rng = Random(1);
    for (var i = 0; i < 60; i++) {
      final q = gen.generate(trial: t, componentIds: const [], rng: rng, id: '$i')!;
      expect(q.dimension, isNot(anyOf(Dimension.tempus, Dimension.modus, Dimension.vox)));
      expect(q.target.analysis.tense, Tense.praesens);
      expect(q.target.analysis.voice, Voice.activum);
      expect(q.target.analysis.mood, Mood.indicativus);
    }
  });

  test('present imperative never asks the person (always second)', () {
    final t = Trials.byId('imp-praes');
    final values = gen.poolValues(t, const []);
    expect(values[Dimension.persona]!.length, 1);
    final rng = Random(3);
    for (var i = 0; i < 40; i++) {
      final q = gen.generate(trial: t, componentIds: const [], rng: rng, id: '$i')!;
      expect(q.dimension, isNot(Dimension.persona));
    }
  });

  test('non-finite trials never ask person or number of infinitives', () {
    final t = Trials.byId('infinitivi');
    final rng = Random(5);
    for (var i = 0; i < 40; i++) {
      final q = gen.generate(trial: t, componentIds: const [], rng: rng, id: '$i')!;
      expect(q.dimension, isNot(anyOf(Dimension.persona, Dimension.numerus)));
      expect(q.target.analysis.mood, Mood.infinitivus);
    }
  });

  test('ambiguous forms accept every legitimate value', () {
    // regam: future indicative and present subjunctive.
    final t = Trials.byId('mx-modi');
    final e = PoolEntry(analyzer.verb('rego'), analyzer.paradigmOf('rego').primary('ind.fut.act.1.sg')!, 'ind');
    final q = Question(
      id: 'x',
      trialId: t.id,
      dimension: Dimension.modus,
      prompt: '',
      surface: e.form.surface,
      lemmaId: 'rego',
      target: e.form,
      analyses: analyzer.analyze('regam'),
      choices: const [],
      correctValues: analyzer.analyze('regam').map((f) => f.analysis.mood.key).toSet(),
      skillIds: const ['mx.modus'],
    );
    expect(q.isCorrect('ind'), isTrue);
    expect(q.isCorrect('subj'), isTrue);
    expect(q.isCorrect('imp'), isFalse);
  });

  test('lemma question on fit accepts both fīō and faciō', () {
    final t = Trials.byId('fam-fio');
    final rng = Random(11);
    Question? q;
    for (var i = 0; i < 400 && q == null; i++) {
      final c = gen.generate(trial: t, componentIds: const [], rng: rng, id: '$i')!;
      if (c.dimension == Dimension.lemma && c.surface == 'fit') q = c;
    }
    if (q != null) {
      expect(q.correctValues, containsAll(['fio', 'facio']));
    }
  });

  test('mixta questions credit the observed tense skill', () {
    final t = Trials.byId('mx-tempora-ind-act');
    final rng = Random(2);
    final q = gen.generate(trial: t, componentIds: comps(t), rng: rng, id: 'a')!;
    expect(q.skillIds.first, 'mx.tempus.ind');
    expect(q.skillIds.length, greaterThanOrEqualTo(2));
    for (final s in q.skillIds) {
      expect(Skills.maybe(s), isNotNull, reason: s);
    }
  });

  test('mixta with a component subset only draws from those components', () {
    final t = Trials.byId('mx-tempora-ind-act');
    final rng = Random(9);
    for (var i = 0; i < 30; i++) {
      final q = gen.generate(trial: t, componentIds: const ['ind.praes.act', 'ind.perf.act'], rng: rng, id: '$i')!;
      expect(q.target.analysis.tense, anyOf(Tense.praesens, Tense.perfectum));
    }
  });

  test('variantes trial asks the full form of a variant', () {
    final t = Trials.byId('variantes');
    final rng = Random(4);
    Question? q;
    for (var i = 0; i < 100 && q == null; i++) {
      final c = gen.generate(trial: t, componentIds: const [], rng: rng, id: '$i')!;
      if (c.dimension == Dimension.formaPlena) q = c;
    }
    expect(q, isNotNull);
    expect(q!.target.isPrimary, isFalse);
    expect(q.correctValues.length, 1);
  });

  test('contrast form exists for a wrong tense', () {
    final t = Trials.byId('mx-tempora-ind-act');
    final rng = Random(6);
    Question? q;
    for (var i = 0; i < 50 && q == null; i++) {
      final c = gen.generate(trial: t, componentIds: comps(t), rng: rng, id: '$i')!;
      if (c.dimension == Dimension.tempus && c.correctValues.length == 1) q = c;
    }
    expect(q, isNotNull);
    final qq = q!;
    final wrong = qq.choices.firstWhere((c) => !qq.correctValues.contains(c.value));
    final contrast = gen.contrastForm(qq, wrong.value);
    expect(contrast, isNotNull);
    expect(contrast!.analysis.tense!.key, wrong.value);
    expect(contrast.surface, isNot(qq.surface));
  });

  test('every trial skill and prerequisite exists', () {
    for (final t in Trials.all) {
      for (final s in t.skillIds) {
        expect(Skills.maybe(s), isNotNull, reason: '${t.id} skill $s');
      }
      for (final p in t.prerequisites) {
        expect(Trials.maybe(p), isNotNull, reason: '${t.id} prereq $p');
      }
      for (final c in t.components) {
        if (c.skillId != null) expect(Skills.maybe(c.skillId!), isNotNull, reason: '${t.id} component ${c.id}');
      }
    }
    expect(Trials.all.where((t) => t.isFree).length, 1);
  });

  test('prerequisite graph is acyclic and reachable from the free trial', () {
    final reached = <String>{};
    var changed = true;
    while (changed) {
      changed = false;
      for (final t in Trials.all) {
        if (reached.contains(t.id)) continue;
        if (t.prerequisites.every(reached.contains)) {
          reached.add(t.id);
          changed = true;
        }
      }
    }
    expect(reached.length, Trials.all.length, reason: 'unreachable: ${Trials.all.where((t) => !reached.contains(t.id)).map((t) => t.id)}');
  });
}
