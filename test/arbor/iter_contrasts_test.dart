import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/app/providers.dart';
import 'package:grammaticon/arbor/arbor.dart';
import 'package:grammaticon/arbor/diagnosis.dart';
import 'package:grammaticon/arbor/evidence.dart';
import 'package:grammaticon/battle/battle_controller.dart';
import 'package:grammaticon/linguistics/model/grammar.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/syntagma.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/iter.dart';
import 'package:grammaticon/pedagogy/mastery.dart';
import 'package:grammaticon/pedagogy/question_generator.dart';
import 'package:grammaticon/pedagogy/target_question_cache.dart';
import 'package:grammaticon/pedagogy/trials.dart';
import 'package:grammaticon/persistence/save_data.dart';

import '../support/test_env.dart';

void main() {
  final arbor = Arbor.standard(analyzer: testAnalyzer, nominal: testNominalAnalyzer);
  final verbs = QuestionGenerator(testAnalyzer);
  final forum = ForumQuestionSource(testNominalAnalyzer, kSyntagmata);
  final dx = Diagnostician(arbor, verbs, forum);
  final now = DateTime.now();
  final discovery = List.generate(5, (i) => i).fold(const SkillRecord(), (r, i) => r.apply(
    Observation(at: now, correct: true, lemmaId: 'example-$i', quality: AnswerQuality.autonoma, trialId: 'fixture'),
    const MasteryConfig(),
  ));

  ArborEvidence evidence(Set<String> sections) => ArborEvidence(records: {
    for (final n in arbor.omnes)
      if (Iter.isContext(n.id) && sections.any((s) => n.id.startsWith('lect.thema.$s.') || n.id.startsWith('lect.intellectus.$s.'))) n.id: discovery,
  });

  ArborNeeds needs(String target, Set<String> sections) => ArborNeeds(arbor, evidence(sections), now,
    focus: {target}, credit: dx.credited, contrast: dx.chosenComponents, presented: dx.targetComponents);

  List<Question> session(QuestionSource source, Trial trial, ArborNeeds needs, {int seed = 7}) {
    final out = <Question>[];
    final rng = Random(seed);
    for (var i = 0; i < trial.questionsToWin; i++) {
      final q = source.generate(trial: trial, componentIds: const [], rng: rng, id: 'q$i', needs: needs,
        recentSurfaces: out.map((q) => q.surface).toList(), recentLemmas: out.map((q) => q.lemmaId).toList());
      expect(q, isNotNull, reason: '${trial.id} question $i');
      expect(needs.canPresent(dx.targetComponents(q!)), isTrue);
      for (final choice in q.choices) {
        expect(needs.canPresent(dx.chosenComponents(q, choice.value)!), isTrue);
      }
      if (out.length >= 2) {
        final common = TargetPractice.answers(out.last).intersection(TargetPractice.answers(out[out.length - 2]));
        if (common.isNotEmpty) expect(TargetPractice.answers(q).containsAll(common), isFalse, reason: 'réponse répétée : ${q.correctValues}');
      }
      out.add(q);
    }
    expect(out.map((q) => q.surface).toSet().length, greaterThanOrEqualTo(8));
    expect(out.map((q) => q.choices.indexWhere((c) => q.isCorrect(c.value))).toSet().length,
      greaterThan(1), reason: 'le même bouton ne doit pas réussir toute la séance');
    return out;
  }

  test('la première déclinaison se compare à la deuxième dès leur découverte', () {
    final qs = session(forum, Trials.byId('dec-1'), needs('n.thema.d1', {'loca', 'personae'}));
    expect(qs.map((q) => q.forum.target.analysis.declension).toSet(), {Declension.prima, Declension.secunda});
    expect(qs.map((q) => dx.credited(q)).any((c) => c.contains('n.thema.d1')), isTrue);
  });

  test('la séance ciblée sur la troisième contient de vrais contrastes déjà découverts', () {
    final qs = session(forum, Trials.byId('dec-3-cons'), needs('n.thema.d3.cons', {'loca', 'personae', 'nomina'}));
    final declensions = qs.map((q) => q.forum.target.analysis.declension).toSet();
    expect(declensions, contains(Declension.tertia));
    expect(declensions.intersection({Declension.prima, Declension.secunda}), isNotEmpty);
    expect(declensions, isNot(contains(Declension.quarta)));
    expect(qs.every((q) => q.dimension == Dimension.thema), isTrue);
    expect(qs.where((q) => q.forum.target.analysis.declension == Declension.tertia)
      .every((q) => dx.credited(q).contains('n.thema.d3.cons')), isTrue);
    expect(qs.where((q) => q.forum.target.analysis.declension != Declension.tertia)
      .every((q) => !dx.credited(q).contains('n.thema.d3.cons')), isTrue);
  });

  test('un seul type admissible ne donne pas une fausse séance de reconnaissance', () {
    final q = forum.forTarget(trial: Trials.byId('dec-1'), componentIds: const [], target: 'n.thema.d1',
      rng: Random(1), id: 'single', proves: (q) => dx.credited(q).contains('n.thema.d1'),
      canPresent: (parts) => !parts.any((p) => p.startsWith('not.declinatio.') && p != 'not.declinatio.1'));
    expect(q, isNull);
  });

  test('le nom de la déclinaison ne valide pas les sous-types de thème', () {
    final item = forum.pool(Trials.byId('dec-3-i'), const []).firstWhere((e) => e.lexeme.id == 'civis');
    final q = Question(id: 'credit', trialId: 'dec-3-i', dimension: Dimension.declinatio, prompt: '',
      surface: item.surface, lemmaId: item.lexeme.id, choices: const [Choice('d3', 'Tertia'), Choice('d1', 'Prima')],
      correctValues: const {'d3'}, skillIds: const [],
      payload: ForumQuestionPayload(target: item.form, analyses: testNominalAnalyzer.analyze(item.surface), lexeme: item.lexeme));
    expect(dx.credited(q), isNot(contains('n.thema.d3.i')));
  });

  test('le présent seul ne sert pas de questionnaire de temps à réponse constante', () {
    final n = needs('v.sig.praes', {'loca', 'personae'});
    final q = verbs.generate(trial: Trials.byId('ind-praes-act'), componentIds: const [], rng: Random(1), id: 'present', needs: n);
    expect(q, isNull);
    final qs = session(verbs, Trials.byId('ind-praes-act'), needs('v.des.act.3.sg.t', {'loca'}));
    expect(qs.map((q) => q.dimension), isNot(contains(Dimension.tempus)));
  });

  test('les temps découverts fournissent les contrastes sans attendre une carte Mixta tardive', () {
    final qs = session(verbs, Trials.byId('ind-imperf-act'), needs('v.sig.imperf.ba', {'loca', 'personae', 'tempora'}));
    expect(qs.map((q) => q.correctValues).expand((v) => v), containsAll(['praes', 'imperf']));
    expect(qs.every((q) => q.verb.target.analysis.tense != Tense.futurumExactum), isTrue);
  });

  test('la reprise garde l’historique des contrastes et les anciennes sauvegardes restent lisibles', () async {
    final trial = Trials.byId('dec-3-cons');
    final (c, _) = testContainer(initial: SaveData(arbor: evidence({'loca', 'personae', 'nomina'}), introSeen: {trial.id}));
    addTearDown(c.dispose);
    final ctrl = c.read(battleProvider.notifier);
    ctrl.start(trial, focus: ['n.thema.d3.cons']);
    for (var i = 0; i < 3; i++) {
      final q = c.read(battleProvider)!.question!;
      ctrl.answer(q.id, q.choices.indexWhere((choice) => q.isCorrect(choice.value)));
      ctrl.proceed();
    }
    final saved = c.read(profileProvider);
    final snapshot = ActiveBattle.fromJson(saved.activeBattle!.toJson());
    expect(snapshot.recentSurfaces.length, 3);
    expect(snapshot.recentQuestions.length, 3);
    final (resumed, _) = testContainer(initial: saved.copyWith(activeBattle: snapshot));
    addTearDown(resumed.dispose);
    resumed.read(battleProvider.notifier).start(trial, resume: snapshot);
    final state = resumed.read(battleProvider)!;
    expect(state.phase, BattlePhase.question);
    expect(state.focus, ['n.thema.d3.cons']);
    expect(state.recentSurfaces, snapshot.recentSurfaces);
    expect(state.recentQuestions, snapshot.recentQuestions);
    expect(snapshot.recentSurfaces, isNot(contains(state.question!.surface)));
    final old = snapshot.toJson()..remove('rl')..remove('rs')..remove('rq');
    expect(ActiveBattle.fromJson(old).recentSurfaces, isEmpty);
    expect(ActiveBattle.fromJson(old).recentQuestions, isEmpty);
  });

  test('des réponses ambiguës ne doivent pas laisser un choix toujours gagnant', () {
    final builder = TargetPracticeBuilder();
    for (final (lemma, surface) in [('rosa', 'rosae'), ('puer', 'puerō')]) {
      final form = testNominalAnalyzer.analyzeAs(surface, lemma).first;
      final correct = testNominalAnalyzer.analyzeAs(surface, lemma).map((f) => f.analysis.casus!.key).toSet();
      final q = Question(id: lemma, trialId: 'test', dimension: Dimension.casus, prompt: '', surface: surface, lemmaId: lemma,
        choices: [for (final c in Casus.values) Choice(c.key, c.latin)], correctValues: correct, skillIds: const [],
        payload: ForumQuestionPayload(target: form, analyses: testNominalAnalyzer.analyze(surface), lexeme: testNominalAnalyzer.lexeme(lemma)));
      builder.add(q, correct);
    }
    expect(builder.finish((q) => true), isNull, reason: 'datif réussirait les deux questions');
  });

  test('l’anti-répétition distingue les cas d’une même surface selon le contexte', () {
    final builder = TargetPracticeBuilder();
    final questions = <Question>[];
    for (final s in const [
      Syntagma(id: 'gen', text: 'servus {dominae} venit', lemmaId: 'domina', casus: Casus.genetivus, number: Numerus.singularis, tags: {}),
      Syntagma(id: 'dat', text: 'servus {dominae} pāret', lemmaId: 'domina', casus: Casus.dativus, number: Numerus.singularis, tags: {}),
      Syntagma(id: 'acc', text: 'servus {dominam} timet', lemmaId: 'domina', casus: Casus.accusativus, number: Numerus.singularis, tags: {}),
    ]) {
      final item = forum.itemOf(s)!;
      final q = Question(id: s.id, trialId: 'test', dimension: Dimension.casus, prompt: '', surface: s.target, lemmaId: s.lemmaId,
        syntagma: s.display, choices: [for (final c in Casus.values) Choice(c.key, c.latin)], correctValues: {s.casus.key}, skillIds: const [],
        payload: ForumQuestionPayload(target: item.form, analyses: testNominalAnalyzer.analyze(s.target), lexeme: item.lexeme, syntagma: s));
      questions.add(q);
      builder.add(q, q.correctValues);
    }
    bool proves(Question q) => q.correctValues.contains('dat');
    final practice = builder.finish(proves)!;
    final next = practice.draw(rng: Random(1), id: 'next', proves: proves,
      recentSurfaces: const ['dominae', 'dominae'],
      recentQuestions: [questions[1].repetitionKey, questions[1].repetitionKey]);
    expect(next.correctValues, isNot(contains('dat')));
  });
}
