import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/arbor/arbor.dart';
import 'package:grammaticon/arbor/diagnosis.dart';
import 'package:grammaticon/arbor/evidence.dart';
import 'package:grammaticon/battle/answer_resolver.dart';
import 'package:grammaticon/linguistics/engine/analyzer.dart';
import 'package:grammaticon/linguistics/engine/conjugator.dart';
import 'package:grammaticon/linguistics/lexicon/forum_lexicon.dart';
import 'package:grammaticon/linguistics/lexicon/verbs.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/iter.dart';
import 'package:grammaticon/pedagogy/mastery.dart';
import 'package:grammaticon/pedagogy/question_generator.dart';
import 'package:grammaticon/pedagogy/trials.dart';
import 'package:grammaticon/persistence/save_data.dart';

void main() {
  final analyzer = Analyzer(kVerbs, Conjugator());
  final nominal = buildNominalAnalyzer();
  final arbor = Arbor.standard(analyzer: analyzer, nominal: nominal);
  final verbs = QuestionGenerator(analyzer);
  final forum = ForumQuestionSource(nominal, kSyntagmata);
  final dx = Diagnostician(arbor, verbs, forum);
  final resolver = AnswerResolver(arbor: arbor, diagnostician: dx);
  const cfg = MasteryConfig();
  late final TrialCoverage coverage;

  SkillRecord proven(DateTime at, {int n = 15, String trial = 't', String? place, SkillRecord base = const SkillRecord()}) {
    var r = base;
    for (var i = 0; i < n; i++) {
      r = r.apply(Observation(at: at.add(Duration(seconds: i)), correct: true, lemmaId: 'l${i % 5}', quality: AnswerQuality.autonoma, trialId: trial), cfg, place: place ?? Trials.maybe(trial)?.activity.key);
    }
    return r;
  }

  setUpAll(() {
    coverage = TrialCoverage.build(verbs, forum);
  });

  test('toute carte couvre au moins un maillon', () {
    for (final t in Trials.all) {
      expect(coverage.of(t.id), isNotEmpty, reason: t.id);
    }
  });

  test('sauvegarde neuve : la cible est une base du graphe, très portante, et la carte qui la contient est gratuite', () {
    final c = Iter.next(save: const SaveData(), arbor: arbor, coverage: coverage)!;
    expect(c.causa, IterCausa.frontier);
    expect(Iter.depth(arbor, c.target), 0);
    expect(Iter.fanOut(arbor, c.target), greaterThan(5));
    expect(coverage.of(c.trial.id), contains(c.target));
    expect(c.trial.isFree, isTrue);
    expect(c.mustBuy, isFalse);
  });

  test('invariant : une cible de frontière a tous ses prérequis maîtrisés ; une remédiation vise le maillon suspect ou son prérequis non sûr', () {
    final now = DateTime(2026, 9, 15, 10);
    // Quelques bases maîtrisées : la frontière doit monter d'un cran, pas plus.
    final records = <String, SkillRecord>{for (final id in ['v.sig.praes', 'v.thema.praes.c1', 'v.voc.a', 'v.des.act.3.sg.t', 'v.des.act.1.sg.o']) id: proven(now)};
    final save = SaveData(arbor: ArborEvidence(records: records));
    for (final (causa, id, _) in Iter.targets(arbor: arbor, ev: save.arbor, now: now).take(40)) {
      if (causa == IterCausa.frontier) {
        for (final p in arbor[id]!.requirit) {
          expect(Iter.mastered(save.arbor, p, cfg, now) || arbor[p]!.probatur.isEmpty, isTrue, reason: '$id requiert $p non maîtrisé');
        }
      }
    }
    // -bā- requiert le présent, maîtrisé : il est maintenant à la frontière.
    final ids = Iter.targets(arbor: arbor, ev: save.arbor, now: now).map((t) => t.$2).toList();
    expect(ids, contains('v.sig.imperf.ba'));
  });

  test('après des erreurs sur -bā- (présent non sûr), la remédiation redescend sur le présent', () {
    var save = const SaveData(gems: 200, purchased: {'ind-imperf-act', 'tm-tempora-ind-act-praes-imperf'});
    final trial = Trials.byId('tm-tempora-ind-act-praes-imperf');
    final rng = Random(9);
    var misses = 0;
    for (var i = 0; i < 300 && misses < 6; i++) {
      final q = verbs.generate(trial: trial, componentIds: const [], rng: rng, id: 'm$i')!;
      if (!q.correctValues.contains('imperf') || !q.choices.any((c) => c.value == 'praes')) continue;
      final res = resolver.resolve(save: save, q: q, chosenValue: 'praes', quality: AnswerQuality.autonoma, now: DateTime(2026, 9, 15, 10, i));
      save = save.copyWith(arbor: res.arborAfter);
      misses++;
    }
    final c = Iter.next(save: save, arbor: arbor, coverage: coverage, now: DateTime(2026, 9, 15, 11))!;
    expect(c.causa, IterCausa.remediatio);
    expect(c.target, anyOf('v.sig.praes', 'v.sig.imperf.ba'));
    expect(coverage.of(c.trial.id), contains(c.target));
    // Une fois le présent prouvé, c'est -bā- lui-même qui est visé.
    save = save.copyWith(arbor: ArborEvidence(records: {...save.arbor.records, 'v.sig.praes': proven(DateTime(2026, 9, 15, 12))}, hypotheses: {...save.arbor.hypotheses}..remove('v.sig.praes')));
    final c2 = Iter.next(save: save, arbor: arbor, coverage: coverage, now: DateTime(2026, 9, 15, 13))!;
    expect(c2.causa, IterCausa.remediatio);
    expect(c2.target, 'v.sig.imperf.ba');
  });

  test('après une défaite sur Dēpōnentia sans ses bases, on ne rejoue pas Dēpōnentia : on redescend', () {
    var save = SaveData(gems: 500, purchased: {for (final t in Trials.all) t.id});
    final trial = Trials.byId('deponentia');
    final rng = Random(3);
    var misses = 0;
    for (var i = 0; i < 400 && misses < 6; i++) {
      final q = verbs.generate(trial: trial, componentIds: const [], rng: rng, id: 'd$i')!;
      final wrong = q.choices.where((c) => !q.isCorrect(c.value)).firstOrNull;
      if (wrong == null) continue;
      final res = resolver.resolve(save: save, q: q, chosenValue: wrong.value, quality: AnswerQuality.autonoma, now: DateTime(2026, 9, 15, 14, i));
      save = save.copyWith(arbor: res.arborAfter, skills: res.skillsAfter);
      misses++;
    }
    final c = Iter.next(save: save, arbor: arbor, coverage: coverage, now: DateTime(2026, 9, 15, 16))!;
    // ignore: avoid_print
    print('après défaite : ${c.trial.id} → ${c.target} (${c.causa.name})');
    expect(c.causa, IterCausa.remediatio);
    expect(c.trial.id, isNot('deponentia'));
    // La cible est un maillon dont les prérequis sont sûrs (ou une base).
    for (final p in arbor[c.target]!.requirit) {
      expect(Iter.mastered(save.arbor, p, cfg, DateTime(2026, 9, 15, 16)) || arbor[p]!.probatur.isEmpty, isTrue, reason: '${c.target} requiert $p');
    }
  });

  test('un maillon dont la révision est due revient en rappel avant toute frontière', () {
    final old = DateTime(2026, 8, 1);
    final save = SaveData(arbor: ArborEvidence(records: {'v.sig.praes': proven(old, trial: 'ind-praes-act')}));
    final c = Iter.next(save: save, arbor: arbor, coverage: coverage, now: DateTime(2026, 9, 15))!;
    expect(c.causa, IterCausa.repetitio);
    expect(c.target, 'v.sig.praes');
    expect(c.trial.id, 'ind-praes-act');
  });

  test('progression simulée : la frontière monte, jamais la même cible deux fois de suite, et les lieux s\'ouvrent quand le graphe le permet', () {
    var save = const SaveData(gems: 400);
    var now = DateTime(2026, 9, 15, 9);
    final path = <String>[];
    final activities = <String>{};
    String? previous;
    for (var i = 0; i < 60; i++) {
      final c = Iter.next(save: save, arbor: arbor, coverage: coverage, now: now);
      if (c == null) break;
      expect(c.target, isNot(previous), reason: 'cible répétée à l\'étape $i');
      previous = c.target;
      path.add('${c.trial.id}:${c.target}${c.mustBuy ? '*' : ''}');
      activities.add(c.trial.activity.key);
      if (c.mustBuy) save = save.copyWith(gems: save.gems - c.trial.price + 30, purchased: {...save.purchased, c.trial.id});
      // Le combat prouve la cible et les maillons visés (palier expert).
      final records = Map<String, SkillRecord>.from(save.arbor.records);
      for (final n in c.nodes) {
        records[n] = proven(now, trial: c.trial.id, base: records[n] ?? const SkillRecord());
      }
      save = save.copyWith(arbor: ArborEvidence(records: records, hypotheses: save.arbor.hypotheses), gems: save.gems + 10);
      now = now.add(const Duration(minutes: 20));
    }
    // ignore: avoid_print
    print('parcours : ${path.join(' → ')}');
    expect(path.length, greaterThan(20));
    expect(activities, containsAll(['amphitheatrum', 'forum', 'theatrum', 'templum']), reason: path.join(' → '));
    // La syntaxe (Theatrum / Templum) est travaillée dès que ses bases le permettent, pas après toute la morphologie.
    final firstSyntax = path.indexWhere((p) => p.contains(':syn.'));
    expect(firstSyntax, allOf(greaterThanOrEqualTo(0), lessThan(12)), reason: path.join(' → '));
  });

  test('la consigne de combat concentre les questions sur la cible', () {
    final trial = Trials.byId('tm-tempora-ind-act');
    const target = 'v.sig.imperf.ba';
    double share(Set<String> focus) {
      final rng = Random(11);
      var hits = 0;
      for (var i = 0; i < 300; i++) {
        final q = verbs.generate(trial: trial, componentIds: const [], rng: rng, id: 'q$i', needs: ArborNeeds(arbor, const ArborEvidence(), DateTime(2026, 9, 15), focus: focus))!;
        if (dx.targetComponents(q).contains(target)) hits++;
      }
      return hits / 300;
    }
    final before = share(const {}), after = share(const {target});
    // ignore: avoid_print
    print('part des questions sur -bā- : sans consigne ${(100 * before).toStringAsFixed(0)} %, avec ${(100 * after).toStringAsFixed(0)} %');
    expect(after, greaterThan(before * 1.5));
  });

  test('l\'ancien historique par carte amorce les maillons de l\'arbre', () {
    final old = DateTime(2026, 8, 20);
    final save = SaveData(skills: {Trials.byId('ind-praes-act').primarySkill: proven(old, trial: 'ind-praes-act')});
    final ev = Iter.seedFromCardSkills(save, arbor, coverage);
    expect(ev.records.keys, containsAll(['v.sig.praes', 'v.des.act.3.sg.t']));
    expect(ev.records.keys.any((k) => k.startsWith('cella.')), isFalse);
  });
}
