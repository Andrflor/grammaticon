import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/app/providers.dart';
import 'package:grammaticon/arbor/arbor.dart';
import 'package:grammaticon/arbor/cellae.dart';
import 'package:grammaticon/arbor/diagnosis.dart';
import 'package:grammaticon/arbor/evidence.dart';
import 'package:grammaticon/battle/battle_controller.dart';
import 'package:grammaticon/linguistics/model/grammar.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/mastery.dart';
import 'package:grammaticon/pedagogy/question_generator.dart';
import 'package:grammaticon/pedagogy/trials.dart';
import 'package:grammaticon/persistence/save_data.dart';

import '../support/test_env.dart';

void main() {
  final arbor = Arbor.standard(analyzer: testAnalyzer, nominal: testNominalAnalyzer);
  final forum = ForumQuestionSource(testNominalAnalyzer, kSyntagmata);
  final dx = Diagnostician(arbor, QuestionGenerator(testAnalyzer), forum);
  final now = DateTime.now();
  final discovery = List.generate(5, (i) => i).fold(const SkillRecord(), (r, i) => r.apply(
    Observation(at: now, correct: true, lemmaId: 'example-$i', quality: AnswerQuality.autonoma, trialId: 'fixture'),
    const MasteryConfig(),
  ));
  final evidence = ArborEvidence(records: {
    for (final n in arbor.omnes)
      if (RegExp(r'^lect\.(intellectus|thema)\.(loca|personae)\.').hasMatch(n.id)) n.id: discovery,
  });
  ArborNeeds needs(Set<String> focus) => ArborNeeds(arbor, evidence, now,
    focus: focus, credit: dx.credited, contrast: dx.chosenComponents, presented: dx.targetComponents);

  test('les déclinaisons non découvertes ne passent pas par une lacune du graphe', () {
    final n = needs({'syn.dat.verba'});
    for (final lemma in ['portus', 'res', 'dux']) {
      final f = testNominalAnalyzer.primary(lemma, 'dat.sg')!;
      expect(n.canPresent(nominalComponents(f, testNominalAnalyzer.lexeme(lemma))), isFalse, reason: lemma);
    }
    expect(n.introduced('n.des.ui'), isFalse);
    expect(n.introduced('n.des.ei'), isFalse);
    expect(n.canPresent({'n.thema.d4.m'}), isFalse);
    expect(forum.generate(trial: Trials.byId('cas-verba-dat'), componentIds: const [],
      rng: Random(1), id: 'portui-loop', needs: needs({'n.des.ui'})), isNull);
    for (final lemma in ['dominus', 'puella']) {
      final f = testNominalAnalyzer.primary(lemma, 'dat.sg')!;
      expect(n.canPresent(nominalComponents(f, testNominalAnalyzer.lexeme(lemma))), isTrue, reason: lemma);
    }
  });

  test('un combat ciblé varie les phrases et fait produire des formes des deux premières déclinaisons', () {
    final trial = Trials.byId('cas-verba-dat');
    final n = needs({'syn.dat.verba'});
    final surfaces = <String>[];
    final lemmas = <String>[];
    final cases = <Casus>{};
    final declensions = <Declension>{};
    final rng = Random(12);
    for (var i = 0; i < trial.questionsToWin; i++) {
      final q = forum.generate(trial: trial, componentIds: const [], rng: rng, id: 'q$i',
        needs: n, recentSurfaces: surfaces, recentLemmas: lemmas);
      expect(q, isNotNull, reason: 'question $i');
      expect(q!.dimension, Dimension.productio);
      expect(q.syntagma, contains('{…}'));
      expect(q.syntagma, isNot(contains('{${q.surface}}')));
      expect(surfaces, isNot(contains(q.surface)), reason: q.syntagma);
      final a = q.forum.target.analysis;
      expect(a.declension, isIn([Declension.prima, Declension.secunda]));
      expect(dx.credited(q).where((id) => id.startsWith('syn.')), isNotEmpty);
      for (final c in q.choices) {
        expect(testNominalAnalyzer.analyzeAs(c.label, q.lemmaId), isNotEmpty);
        expect(n.canPresent(dx.chosenComponents(q, c.value)!), isTrue);
      }
      surfaces.add(q.surface);
      lemmas.add(q.lemmaId);
      cases.add(a.casus!);
      declensions.add(a.declension!);
    }
    expect(cases, containsAll([Casus.dativus, Casus.accusativus]));
    expect(declensions, {Declension.prima, Declension.secunda});
  });

  test('le contexte aussi respecte les déclinaisons découvertes', () {
    final source = ForumQuestionSource(testNominalAnalyzer, [
      kSyntagmata.firstWhere((s) => s.id == 'cas-verba-dat-009'), // pater {fīliō}
    ]);
    final q = source.generate(trial: Trials.byId('cas-verba-dat'), componentIds: const [],
      rng: Random(1), id: 'context', needs: needs({'syn.dat.verba'}));
    expect(q, isNull, reason: 'fīliō est connu, mais pater est encore de la troisième déclinaison');
  });

  test('la diversité des lexèmes ne force pas la répétition immédiate d’une forme', () {
    final trial = Trials.byId('dec-1');
    const target = 'n.des.am';
    Question? draw(String id, {List<String> recent = const [], Set<String> seen = const {}}) => forum.forTarget(
      trial: trial, componentIds: const [], target: target, rng: Random(7), id: id,
      proves: (q) => dx.credited(q).contains(target), recentSurfaces: recent, seenLemmas: seen,
    );
    final first = draw('first')!;
    final next = draw('next', recent: [first.surface], seen: {
      for (final e in forum.pool(trial, const [])) if (e.lexeme.id != first.lemmaId) e.lexeme.id,
    })!;
    expect(next.surface, isNot(first.surface));
    expect(dx.credited(next), contains(target));
  });

  test('le combat Iter termine avec des phrases variées et crédite le régime réellement travaillé', () async {
    final trial = Trials.byId('cas-verba-dat');
    final (c, _) = testContainer(initial: SaveData(arbor: evidence, introSeen: {trial.id}, purchased: {'dec-2-mf', trial.id}));
    addTearDown(c.dispose);
    final ctrl = c.read(battleProvider.notifier);
    ctrl.start(trial, focus: ['syn.dat.verba']);
    final surfaces = <String>{};
    final expected = <String, int>{};
    for (var i = 0; i < trial.questionsToWin; i++) {
      final state = c.read(battleProvider)!;
      expect(state.phase, BattlePhase.question);
      final q = state.question!;
      expect(q.dimension, Dimension.productio);
      expect(surfaces.add(q.surface), isTrue, reason: q.syntagma);
      final node = switch (q.forum.syntagma!.functio!.key) {
        'obiectum-dat' => 'syn.dat.verba',
        'obiectum' => 'syn.acc.obiectum',
        'datum' => 'syn.dat.attributio',
        _ => throw StateError('Fonction inattendue'),
      };
      expected[node] = (expected[node] ?? 0) + 1;
      ctrl.answer(q.id, q.choices.indexWhere((choice) => q.isCorrect(choice.value)));
      ctrl.proceed();
    }
    expect(c.read(battleProvider)!.phase, BattlePhase.victory);
    final records = c.read(profileProvider).arbor.records;
    expect(expected['syn.dat.verba'], inInclusiveRange(3, 7));
    expect(expected['syn.acc.obiectum'], greaterThan(0));
    for (final e in expected.entries) {
      expect(records[e.key]!.autonomousCount, e.value);
    }
    await ctrl.finish();
    expect(c.read(profileProvider).activeBattle, isNull);
  });
}
