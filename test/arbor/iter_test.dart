import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/arbor/arbor.dart';
import 'package:grammaticon/arbor/diagnosis.dart';
import 'package:grammaticon/pedagogy/frames/frame_catalogue.dart';
import 'package:grammaticon/arbor/contextus.dart';
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

  // Les tests de grammaire commencent après les découvertes en contexte
  // correspondantes ; cela ne donne aucun crédit à la grammaire elle-même.
  Map<String, SkillRecord> discoveriesFor(String node, DateTime at) => {
    for (final id in arbor.prerequisitesOf(node))
      if (Iter.isContext(id)) id: proven(at, trial: id.startsWith('lect.thema.') ? 'tp-loca-a-ablative' : 'th-loca-a-ablative'),
  };

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
    final records = <String, SkillRecord>{...discoveriesFor('v.sig.imperf.ba', now), for (final id in ['v.sig.praes', 'v.thema.praes.c1', 'v.voc.a', 'v.des.act.3.sg.t', 'v.des.act.1.sg.o']) id: proven(now)};
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
    var save = SaveData(gems: 200, purchased: const {'ind-imperf-act', 'tm-tempora-ind-act-praes-imperf'}, arbor: ArborEvidence(records: discoveriesFor('v.sig.imperf.ba', DateTime(2026, 9, 14))));
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
    // Une fois la carte du présent acquise (la chaîne des cartes : l'imparfait
    // attend le présent), c'est -bā- lui-même qui est visé au tour des verbes ;
    // les branches jamais travaillées passent avant.
    final records = Map<String, SkillRecord>.from(save.arbor.records);
    for (final n in coverage.of('ind-praes-act')) {
      // Assez de réussites pour effacer les six erreurs de la fenêtre récente.
      records[n] = proven(DateTime(2026, 9, 15, 12), n: 40, trial: 'ind-praes-act', base: records[n] ?? const SkillRecord());
    }
    save = save.copyWith(arbor: ArborEvidence(records: records, hypotheses: {...save.arbor.hypotheses}..remove('v.sig.praes')));
    IterChoice? c2;
    var now = DateTime(2026, 9, 15, 13);
    for (var i = 0; i < 6 && c2 == null; i++) {
      final c = Iter.next(save: save, arbor: arbor, coverage: coverage, now: now)!;
      if (c.trial.activity == Activity.amphitheatrum) {
        c2 = c;
        break;
      }
      if (c.mustBuy) save = save.copyWith(gems: save.gems - c.trial.price, purchased: {...save.purchased, c.trial.id});
      final records = Map<String, SkillRecord>.from(save.arbor.records);
      for (final n in c.nodes) {
        records[n] = proven(now, trial: c.trial.id, base: records[n] ?? const SkillRecord());
      }
      save = save.copyWith(arbor: ArborEvidence(records: records, hypotheses: save.arbor.hypotheses));
      now = now.add(const Duration(minutes: 20));
    }
    expect(c2, isNotNull);
    expect(c2!.causa, IterCausa.remediatio);
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

  test('un maillon dont la révision est due revient en rappel dès que sa branche a le tour, avant la frontière de la branche', () {
    final old = DateTime(2026, 8, 1);
    var save = SaveData(gems: 200, arbor: ArborEvidence(records: {...discoveriesFor('v.sig.imperf.ba', DateTime(2026, 9, 14)), 'v.sig.praes': proven(old, trial: 'ind-praes-act')}));
    var now = DateTime(2026, 9, 15);
    // Les branches jamais travaillées (nom, syntaxe) passent d'abord ; le rappel
    // verbal vient au tour des verbes, pas après toute la frontière.
    final first = Iter.next(save: save, arbor: arbor, coverage: coverage, now: now)!;
    expect(first.trial.activity, isNot(Activity.amphitheatrum));
    IterChoice? recall;
    for (var i = 0; i < 4 && recall == null; i++) {
      final c = Iter.next(save: save, arbor: arbor, coverage: coverage, now: now)!;
      if (c.trial.activity == Activity.amphitheatrum) {
        recall = c;
        break;
      }
      if (c.mustBuy) save = save.copyWith(gems: save.gems - c.trial.price, purchased: {...save.purchased, c.trial.id});
      final records = Map<String, SkillRecord>.from(save.arbor.records);
      for (final n in c.nodes) {
        records[n] = proven(now, trial: c.trial.id, base: records[n] ?? const SkillRecord());
      }
      save = save.copyWith(arbor: ArborEvidence(records: records, hypotheses: save.arbor.hypotheses));
      now = now.add(const Duration(minutes: 20));
    }
    expect(recall, isNotNull);
    expect(recall!.causa, IterCausa.repetitio);
    expect(recall.target, 'v.sig.praes');
    expect(recall.trial.id, 'ind-praes-act');
  });

  test('un joueur qui n\'a fait que l\'Amphitheātrum est envoyé ailleurs : les quatre aspects avancent ensemble', () {
    // Historique par carte : tout le présent et le parfait actifs maîtrisés il y a
    // trois semaines (rappels dus), rien au Forum, au Theātrum, au Templum.
    final old = DateTime(2026, 8, 25);
    final cards = ['ind-praes-act', 'ind-imperf-act', 'ind-fut-act', 'ind-perf-act', 'ind-praes-pass', 'fam-sum'];
    var save = SaveData(gems: 300, purchased: cards.toSet(), skills: {for (final c in cards) Trials.byId(c).primarySkill: proven(old, trial: c)});
    save = save.copyWith(arbor: Iter.seedFromCardSkills(save, arbor, coverage));
    expect(save.arbor.records.length, greaterThan(20));
    var now = DateTime(2026, 9, 15);
    final path = <String>[];
    for (var i = 0; i < 12; i++) {
      final c = Iter.next(save: save, arbor: arbor, coverage: coverage, now: now)!;
      path.add('${c.trial.id}:${c.target}');
      if (c.mustBuy) save = save.copyWith(gems: save.gems - c.trial.price + 30, purchased: {...save.purchased, c.trial.id});
      final records = Map<String, SkillRecord>.from(save.arbor.records);
      for (final n in c.nodes) {
        records[n] = proven(now, trial: c.trial.id, base: records[n] ?? const SkillRecord());
      }
      save = save.copyWith(arbor: ArborEvidence(records: records, hypotheses: save.arbor.hypotheses));
      now = now.add(const Duration(minutes: 20));
    }
    // ignore: avoid_print
    print('après l\'Amphitheātrum seul : ${path.join(' → ')}');
    // Exposition d'abord : on commence par la première carte du Theātrum, puis
    // les quatre lieux tournent (Theātrum, Forum, Templum, Amphitheātrum…).
    int count(Activity a) => path.where((p) => Trials.byId(p.split(':').first).activity == a).length;
    expect(Trials.byId(path.first.split(':').first).activity, Activity.theatrum, reason: path.join(' → '));
    expect(path.first, startsWith('th-loca-'), reason: path.join(' → '));
    expect(count(Activity.amphitheatrum), lessThanOrEqualTo(3), reason: path.join(' → '));
    expect(count(Activity.theatrum), greaterThanOrEqualTo(3), reason: path.join(' → '));
    expect(count(Activity.templum), greaterThanOrEqualTo(2), reason: path.join(' → '));
    expect(count(Activity.forum), greaterThanOrEqualTo(3), reason: path.join(' → '));
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
    // Exposition d'abord : la première carte est la première du Theātrum, son
    // Templum suit de près, et la syntaxe du Forum vient après avoir été lue.
    expect(path.first, startsWith('th-loca-'), reason: path.join(' → '));
    expect(path.indexWhere((p) => p.startsWith('tp-loca-')), allOf(greaterThan(0), lessThan(4)), reason: path.join(' → '));
    final firstSyntax = path.indexWhere((p) => p.contains(':syn.'));
    // La syntaxe élémentaire doit être jouable avec les 1re/2e déclinaisons.
    // Le nombre exact de combats varie quand on écarte les contextes qui
    // contiennent des noms encore inconnus : comparer les découvertes, pas
    // imposer un rang qui dépend de ces phrases trop avancées.
    final thirdDeclension = path.indexWhere((p) => p.startsWith('th-nomina-third-subject-object:'));
    expect(thirdDeclension, greaterThan(0), reason: path.join(' → '));
    expect(firstSyntax, allOf(greaterThan(path.indexWhere((p) => p.startsWith('tp-loca-'))), lessThan(thirdDeclension)), reason: path.join(' → '));
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

  test('la chaîne des cartes est une progression : « Nōs et vōs » n\'est pas le véhicule de -um tant qu\'« Ego et tū » n\'est pas acquis', () {
    final old = DateTime(2026, 9, 14);
    // Tout l'indicatif actif et passif acquis à l'Amphitheātrum, dec-1 acquis au
    // Forum, nōs/vōs acheté ; le participe parfait a fait échouer -um.
    final verbal = ['ind-praes-act', 'ind-imperf-act', 'ind-fut-act', 'ind-perf-act', 'ind-praes-pass', 'ind-perf-pass'];
    final records = <String, SkillRecord>{};
    for (final c in [...verbal, 'dec-1']) {
      for (final n in coverage.of(c)) {
        records[n] = proven(old, trial: c, base: records[n] ?? const SkillRecord());
      }
    }
    // Les sections « loca » et « personae » déjà lues (Theātrum) et produites
    // (Templum) : -um a été exposé, sa morphologie peut se travailler.
    for (final s in arbor.omnes.where((s) => s.id.startsWith('lect.intellectus.loca.') || s.id.startsWith('lect.intellectus.personae.'))) {
      records[s.id] = proven(old, trial: 'th-loca-a-ablative');
    }
    for (final s in arbor.omnes.where((s) => s.id.startsWith('lect.thema.loca.') || s.id.startsWith('lect.thema.personae.'))) {
      records[s.id] = proven(old, trial: 'tp-loca-a-ablative');
    }
    records['n.des.um'] = records['n.des.um']!.apply(Observation(at: DateTime(2026, 9, 15, 8), correct: false, lemmaId: 'amo', quality: AnswerQuality.autonoma, trialId: 'ind-perf-pass'), cfg);
    final save = SaveData(gems: 100, purchased: {...verbal, 'pron-nos-vos', 'dec-2-mf'}, arbor: ArborEvidence(records: records, hypotheses: {'n.des.um': DateTime(2026, 9, 15, 8)}));
    final c = Iter.next(save: save, arbor: arbor, coverage: coverage, now: DateTime(2026, 9, 15, 9))!;
    expect(c.target, 'n.des.um');
    expect(c.trial.activity, Activity.forum, reason: 'désinence nominale : au Forum, pas dans une carte de verbes');
    expect(c.trial.id, 'dec-2-mf', reason: 'la carte native ouverte par la chaîne, pas nōs/vōs (Ego et tū non acquis) ni un participe');
    expect(Iter.cardMastered(save.arbor, coverage, Trials.byId('pron-ego-tu'), cfg, DateTime(2026, 9, 15, 9)), isFalse);
  });

  test('les sections du Theātrum et du Templum s\'enchaînent dans l\'ordre du catalogue : une racine exige le vocabulaire de la section précédente', () {
    for (final (sections, cards, place) in [(kTheatrumSections, kTheatrumCards, 'theatrum'), (kTemplumSections, kTemplumCards, 'templum')]) {
      for (var i = 1; i < sections.length; i++) {
        final gate = contextNodeId('$place/${sections[i - 1].id}/vocabula');
        for (final c in cards.where((c) => c.section == sections[i].id && c.requires.isEmpty)) {
          expect(arbor[contextNodeId(c.id)]!.requirit, contains(gate), reason: c.id);
        }
      }
    }
    expect(arbor['lect.intellectus.voluntas_et_consilium.1']!.requirit, contains('lect.intellectus.condiciones_interpretandae.vocabula'));
    // Dans une section, la carte requise par la carte (chaîne du jeu) est un prérequis.
    expect(arbor['lect.intellectus.actiones.passive_agent']!.requirit, contains('lect.intellectus.actiones.passive_number'));
    // Un joueur qui n'a que des verbes ne commence pas le Theātrum par le subjonctif d'exhortation.
    final old = DateTime(2026, 9, 1);
    final records = <String, SkillRecord>{};
    for (final c in Trials.all.where((t) => t.activity == Activity.amphitheatrum)) {
      for (final n in coverage.of(c.id)) {
        records[n] = proven(old, trial: c.id, base: records[n] ?? const SkillRecord());
      }
    }
    final save = SaveData(gems: 500, arbor: ArborEvidence(records: records));
    final ts = Iter.targets(arbor: arbor, ev: save.arbor, coverage: coverage, now: DateTime(2026, 9, 15));
    expect(ts.where((t) => t.$2.startsWith('lect.intellectus.') && !t.$2.startsWith('lect.intellectus.loca.')), isEmpty, reason: ts.where((t) => t.$2.startsWith('lect.')).map((t) => t.$2).join(' '));
  });

  test('exposition : une carte du Theātrum jouée une fois (familiāris) ouvre son Templum sans attendre le palier expert', () {
    // Sept réponses, une erreur : estimation ≈ 0,68, familiāris, pas expert.
    var r = const SkillRecord();
    final at = DateTime(2026, 9, 15, 11);
    for (var i = 0; i < 7; i++) {
      r = r.apply(Observation(at: at.add(Duration(seconds: i)), correct: i != 3, lemmaId: 'f$i', quality: AnswerQuality.autonoma, trialId: 'th-loca-a-ablative'), cfg, place: 'theatrum');
    }
    expect(r.tier(cfg), MasteryTier.familiaris);
    const node = 'lect.intellectus.loca.a_ablative';
    var save = SaveData(gems: 100, arbor: ArborEvidence(records: {node: r}));
    final seen = <String>[];
    var now = at.add(const Duration(minutes: 20));
    for (var i = 0; i < 4; i++) {
      final c = Iter.next(save: save, arbor: arbor, coverage: coverage, now: now)!;
      seen.add(c.trial.id);
      if (c.trial.id == 'tp-loca-a-ablative') break;
      if (c.mustBuy) save = save.copyWith(gems: save.gems - c.trial.price, purchased: {...save.purchased, c.trial.id});
      final records = Map<String, SkillRecord>.from(save.arbor.records);
      for (final n in c.nodes) {
        records[n] = proven(now, trial: c.trial.id, base: records[n] ?? const SkillRecord());
      }
      save = save.copyWith(arbor: ArborEvidence(records: records, hypotheses: save.arbor.hypotheses));
      now = now.add(const Duration(minutes: 20));
    }
    expect(seen, contains('tp-loca-a-ablative'), reason: seen.join(' → '));
    // Le nœud de version reste à la frontière : l'exposition ouvre, la maîtrise se poursuit.
    final ts = Iter.targets(arbor: arbor, ev: save.arbor, coverage: coverage, now: now);
    expect(ts.any((t) => t.$2 == node), isTrue);
  });
}
