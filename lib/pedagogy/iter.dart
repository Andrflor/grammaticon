/// L'Iter : le parcours automatique. À partir de l'évidence de l'arbre, il
/// choisit la prochaine carte à jouer — remédiation d'abord (hypothèses
/// ouvertes), puis rappels dus, puis frontière (maillons dont les prérequis
/// sont acquis) — et dit s'il faut l'acheter.
library;

import 'dart:math';

import '../arbor/arbor.dart';
import '../arbor/cellae.dart';
import '../arbor/diagnosis.dart';
import '../arbor/evidence.dart';
import '../arbor/skill.dart';
import '../persistence/save_data.dart';
import 'forum/forum_question_source.dart';
import 'frames/frame_cards.dart';
import 'frames/frame_trials.dart';
import 'mastery.dart';
import 'progression.dart';
import 'question_generator.dart';
import 'trials.dart';

/// Maillons que chaque carte peut faire travailler : l'union des composants
/// des formes de son vivier (Amphitheatrum, Forum) ou ses nœuds visés
/// (Theatrum, Templum). Calculé une fois.
class TrialCoverage {
  TrialCoverage(this.nodesByTrial);
  final Map<String, Set<String>> nodesByTrial;

  /// Tous les maillons qu'au moins une carte peut prouver.
  late final Set<String> covered = {for (final s in nodesByTrial.values) ...s};

  Set<String> of(String trialId) => nodesByTrial[trialId] ?? const {};

  factory TrialCoverage.build(QuestionGenerator verbs, ForumQuestionSource forum) {
    final out = <String, Set<String>>{};
    final verbCache = <String, Set<String>>{};
    for (final t in Trials.all) {
      final comps = t.components.map((c) => c.id).toList();
      final nodes = <String>{};
      switch (t.activity) {
        case Activity.amphitheatrum:
          for (final e in verbs.pool(t, comps)) {
            final key = '${e.verb.id}|${e.form.analysis.selector}';
            nodes.addAll(verbCache[key] ??= verbalComponents(e.form.analysis, e.verb));
          }
        case Activity.forum:
          for (final e in forum.pool(t, comps)) {
            nodes.addAll(nominalComponents(e.form, e.lexeme));
            final s = e.syntagma;
            if (s != null) {
              if (s.functio != null) nodes.add(Diagnostician.functioNode(s.functio!.key, s));
              if (s.constructio != null) nodes.addAll(Diagnostician.constructioNodes(s.constructio!.key));
              if (s.relatio != null) nodes.addAll({'syn.pron.reflexivum', 'syn.pron.is.anaphora', 'pron.suus_eius'});
              if (s.head != null) nodes.addAll({'syn.concordia.adiectivum', 'syn.concordia.distans'});
            }
          }
        case Activity.theatrum:
        case Activity.templum:
          if (t.filter is FrameFilter) nodes.addAll(frameCardNodes((t.filter as FrameFilter).card));
      }
      nodes.removeWhere((n) => n.startsWith('not.') || n.startsWith('cella.') || n.startsWith('lex.'));
      out[t.id] = nodes;
    }
    return TrialCoverage(out);
  }
}

/// Pourquoi un maillon est visé.
enum IterCausa { remediatio, repetitio, frontier }

class IterChoice {
  const IterChoice({required this.trial, required this.mustBuy, required this.causa, required this.nodes, required this.score});

  /// La carte qui isole le mieux la cible : le véhicule, pas la décision.
  final Trial trial;

  /// La carte n'est pas encore ouverte : il faut l'acheter (achetable, solde suffisant).
  final bool mustBuy;
  final IterCausa causa;

  /// Maillons visés : la cible d'abord, puis les autres maillons de la carte
  /// qui ont besoin de travail. Le combat concentre ses questions sur eux.
  final List<String> nodes;
  final double score;

  String get target => nodes.first;
}

/// Le parcours automatique, piloté par le graphe seul.
///
/// La cible est un **maillon**, jamais une carte :
/// 1. remédiation — un maillon suspect (raté) dont les prérequis sont sûrs ;
///    si un prérequis ne l'est pas, c'est lui la cible (on redescend) ;
/// 2. rappel — un maillon acquis dont l'échéance de révision est passée ;
/// 3. frontière — un maillon jamais prouvé dont tous les prérequis sont
///    maîtrisés (palier expert), le plus fondamental d'abord : celui dont
///    dépend le plus grand nombre d'autres maillons.
/// La carte choisie est celle qui contient la cible et dont le reste est le
/// plus connu possible (à peine plus difficile que ce que l'on sait), ouverte
/// ou achetable ; l'achat est automatique. Le combat reçoit la cible en
/// consigne de sélection.
class Iter {
  const Iter._();

  /// Profondeur d'un maillon : 0 pour une base, 1 + max des prérequis sinon.
  static int depth(Arbor arbor, String id, [Map<String, int>? memo]) {
    final m = memo ?? <String, int>{};
    if (m.containsKey(id)) return m[id]!;
    m[id] = 0;
    final pre = arbor[id]?.requirit ?? const <String>[];
    final d = pre.isEmpty ? 0 : 1 + pre.map((p) => depth(arbor, p, m)).reduce(max);
    m[id] = d;
    return d;
  }

  /// Nombre de maillons qui dépendent (transitivement) de [id] : sa portée.
  static int fanOut(Arbor arbor, String id, [Map<String, int>? memo]) {
    final m = memo ?? <String, int>{};
    if (m.containsKey(id)) return m[id]!;
    final seen = <String>{};
    void visit(String x) {
      for (final d in arbor.requiritur[x] ?? const <String>{}) {
        if (seen.add(d)) visit(d);
      }
    }
    visit(id);
    return m[id] = seen.length;
  }

  /// Maîtrisé = palier expert et révision non due.
  static bool mastered(ArborEvidence ev, String id, MasteryConfig cfg, DateTime now) {
    final r = ev.records[id];
    if (r == null || r.autonomousCount == 0) return false;
    final rr = r.asOf(now, cfg);
    return rr.tier(cfg).index >= MasteryTier.perita.index && !rr.reviewDue(now, cfg);
  }

  /// Les lieux (activités) dont au moins une carte couvre le maillon : les
  /// « plans » sur lesquels il doit être maîtrisé.
  static Set<String> placesOf(TrialCoverage coverage, String id) => {for (final t in Trials.all) if (coverage.of(t.id).contains(id)) t.activity.key};

  /// Maîtrisé sur tous ses plans : expert, non dû, et prouvé dans chaque lieu
  /// qui le couvre (comprendre au Theātrum ne suffit pas si le Templum le
  /// demande aussi).
  static bool masteredEverywhere(ArborEvidence ev, TrialCoverage coverage, String id, MasteryConfig cfg, DateTime now) {
    if (!mastered(ev, id, cfg, now)) return false;
    final places = ev.records[id]?.places ?? const <String>{};
    return placesOf(coverage, id).every(places.contains);
  }

  /// Dernière carte jouée, d'après l'observation la plus récente de l'arbre.
  static String? lastTrialPlayed(ArborEvidence ev) {
    String? best;
    DateTime? at;
    for (final r in ev.records.values) {
      for (final o in r.recent) {
        if (at == null || o.at.isAfter(at)) {
          at = o.at;
          best = o.trialId;
        }
      }
    }
    return best;
  }

  /// Les maillons que le graphe désigne, par priorité : (cause, id, poids).
  static List<(IterCausa, String, double)> targets({required Arbor arbor, required ArborEvidence ev, TrialCoverage? coverage, MasteryConfig cfg = const MasteryConfig(), DateTime? now}) {
    final at = now ?? DateTime.now();
    final depths = <String, int>{}, fans = <String, int>{};
    bool isNode(String id) {
      final s = arbor[id];
      return s != null && s.stratum != Stratum.notio && s.stratum != Stratum.cella && s.stratum != Stratum.lexicon && s.probatur.isNotEmpty;
    }
    bool sure(String id) => mastered(ev, id, cfg, at);
    bool complete(String id) => coverage == null ? sure(id) : masteredEverywhere(ev, coverage, id, cfg, at);
    // Un prérequis qu'aucune carte ne prouve (geste de lecture, construction
    // sans carte) ne bloque pas : il se lit sur ce qui en dépend.
    bool coverable(String id) => coverage == null || coverage.covered.contains(id);
    bool gating(String id) => isNode(id) && coverable(id);
    // Un prérequis est satisfait s'il est maîtrisé ; s'il n'est prouvable par
    // aucune carte, si ses propres prérequis le sont (la dépendance passe à
    // travers lui : la syntaxe des déponents attend la morphologie des déponents).
    final satisfiedMemo = <String, bool>{};
    bool satisfied(String id) {
      final memo = satisfiedMemo[id];
      if (memo != null) return memo;
      satisfiedMemo[id] = true; // garde contre un cycle
      final ok = coverable(id) ? (!isNode(id) || sure(id)) : (arbor[id]?.requirit ?? const <String>[]).every(satisfied);
      return satisfiedMemo[id] = ok;
    }
    final out = <(IterCausa, String, double)>[];
    // 1. Remédiation : hypothèses dont les prérequis sont sûrs ; sinon on
    //    remonte l'hypothèse sur le prérequis le plus profond non sûr.
    for (final id in ev.hypotheses.keys.where(gating)) {
      final pre = (arbor[id]?.requirit ?? const <String>[]).where(gating).toList();
      if ((arbor[id]?.requirit ?? const <String>[]).every(satisfied)) {
        out.add((IterCausa.remediatio, id, 3.0));
      } else {
        for (final p in pre.where((p) => !sure(p))) {
          out.add((IterCausa.remediatio, p, 2.5));
        }
      }
    }
    // 2. Rappels dus.
    for (final e in ev.records.entries) {
      if (!gating(e.key) || e.value.autonomousCount == 0) continue;
      final rr = e.value.asOf(at, cfg);
      if (rr.reviewDue(at, cfg) && !ev.hypotheses.containsKey(e.key)) out.add((IterCausa.repetitio, e.key, 1.5 + (1 - (rr.estimate ?? 0.5))));
    }
    // 3. Frontière : jamais prouvé, pas encore expert, ou expert sur un plan
    //    seulement (compris au Theātrum, jamais produit au Templum) ; prérequis
    //    tous maîtrisés ; le plus fondamental (portée) puis le plus bas.
    for (final s in arbor.omnes) {
      if (!gating(s.id) || ev.hypotheses.containsKey(s.id) || complete(s.id)) continue;
      final r = ev.records[s.id];
      if (r != null && r.autonomousCount > 0 && r.asOf(at, cfg).reviewDue(at, cfg)) continue; // déjà compté en rappel
      if (!s.requirit.every(satisfied)) continue;
      final known = r != null && r.autonomousCount > 0;
      // Compléter un maillon déjà sûr sur un plan passe avant d'en ouvrir un autre.
      final w = (sure(s.id) ? 1.2 : known ? 1.0 : 0.8) + fanOut(arbor, s.id, fans) / 50 - depth(arbor, s.id, depths) * 0.05;
      out.add((IterCausa.frontier, s.id, w));
    }
    out.sort((a, b) {
      if (a.$1 != b.$1) return a.$1.index.compareTo(b.$1.index);
      return b.$3.compareTo(a.$3);
    });
    return out;
  }

  /// Branche du graphe d'un maillon : `v` (verbe), `n` (nom, adjectif, pronom,
  /// numéral), `syn` (syntaxe), `lect` (lecture).
  static String branchOf(String id) {
    final p = id.split('.');
    return switch (p.first) {
      'adj' || 'pron' || 'num' => 'n',
      'lect' when p.length > 1 && (p[1] == 'intellectus' || p[1] == 'thema') => p[1],
      _ => p.first,
    };
  }

  /// Dernier moment où chaque branche a été travaillée, d'après les observations.
  static Map<String, DateTime> lastPlayedByBranch(ArborEvidence ev) {
    final out = <String, DateTime>{};
    for (final e in ev.records.entries) {
      final b = branchOf(e.key);
      for (final o in e.value.recent) {
        if (out[b] == null || o.at.isAfter(out[b]!)) out[b] = o.at;
      }
    }
    return out;
  }

  /// La prochaine carte, ou null si rien n'est jouable.
  static IterChoice? next({required SaveData save, required Arbor arbor, required TrialCoverage coverage, MasteryConfig cfg = const MasteryConfig(), DateTime? now}) {
    final at = now ?? DateTime.now();
    final ev = save.arbor;
    var list = targets(arbor: arbor, ev: ev, coverage: coverage, cfg: cfg, now: at);
    if (list.isEmpty) return null;
    // La frontière tourne entre les branches du graphe : la branche travaillée
    // le moins récemment passe d'abord (verbe, nom, syntaxe, lecture), pour que
    // la syntaxe et la lecture avancent avec la morphologie et non après elle.
    if (list.first.$1 == IterCausa.frontier) {
      final lastPlayed = lastPlayedByBranch(ev);
      final branches = list.map((t) => branchOf(t.$2)).toSet().toList()
        ..sort((a, b) {
          final ta = lastPlayed[a], tb = lastPlayed[b];
          if (ta == null && tb != null) return -1;
          if (tb == null && ta != null) return 1;
          if (ta != null && tb != null) return ta.compareTo(tb);
          return a.compareTo(b);
        });
      final order = {for (var i = 0; i < branches.length; i++) branches[i]: i};
      list = [...list]..sort((a, b) {
        final oa = order[branchOf(a.$2)]!, ob = order[branchOf(b.$2)]!;
        if (oa != ob) return oa.compareTo(ob);
        return b.$3.compareTo(a.$3);
      });
    }
    final last = lastTrialPlayed(ev);
    bool sure(String id) => mastered(ev, id, cfg, at);
    // Cartes jouables ou achetables.
    final candidates = <Trial, bool>{};
    for (final t in Trials.all) {
      final status = Progression.status(save, t);
      if (status.access == TrialAccess.accessible) candidates[t] = false;
      if (status.access == TrialAccess.purchasable && status.affordable) candidates[t] = true;
    }
    // Pour chaque cible atteignable dans l'ordre, la carte qui l'isole le mieux.
    final all = list;
    list = list.where((t) => candidates.keys.any((c) => coverage.of(c.id).contains(t.$2))).toList();
    IterCausa? topCausa;
    for (final (causa, target, weight) in list) {
      topCausa ??= causa;
      if (causa != topCausa) break; // on reste dans la classe de priorité la plus haute
      IterChoice? best;
      final proved = ev.records[target]?.places ?? const <String>{};
      final planes = placesOf(coverage, target);
      final targetSure = sure(target);
      for (final e in candidates.entries) {
        final cov = coverage.of(e.key.id);
        if (!cov.contains(target)) continue;
        // Une cible déjà sûre sur ce plan ne s'y rejoue pas hors rappel : c'est
        // le plan manquant qu'il faut ouvrir (quand sa carte sera atteignable).
        if (causa == IterCausa.frontier && targetSure && proved.contains(e.key.activity.key)) continue;
        // « À peine plus difficile » : la part de la carte déjà maîtrisée, et le
        // moins possible de maillons qui ne sont ni la cible ni maîtrisés.
        // Les gestes de traduction (lect.versio.*) accompagnent toute carte du
        // Theatrum ou du Templum : ils ne comptent pas comme difficulté ajoutée.
        final others = cov.where((n) => n != target && !sure(n) && !n.startsWith('lect.versio.')).length;
        var score = weight * (0.5 + cov.where(sure).length / cov.length) / (1 + others / 4);
        if (e.value) score *= 0.85;
        if (e.key.id == last) score *= 0.5;
        // Le plan manquant d'abord : une cible déjà prouvée au Theātrum se joue
        // au Templum (et inversement), un plan déjà prouvé ne repasse qu'en rappel.
        if (planes.length > 1 && !proved.contains(e.key.activity.key)) score *= 3;
        // À cible égale, changer de lieu.
        if (last != null && Trials.maybe(last)?.activity == e.key.activity) score *= 0.7;
        if (best == null || score > best.score) {
          final needy = [target, ...cov.where((n) => n != target && !sure(n)).take(5)];
          best = IterChoice(trial: e.key, mustBuy: e.value, causa: causa, nodes: needy, score: score);
        }
      }
      if (best != null) return best;
    }
    // Aucune carte ne porte les cibles sur leur plan manquant : on ouvre le lieu
    // qui les débloque — la carte achetable ou jouable de ce lieu qui couvre le
    // plus de cibles encore incomplètes (sa chaîne mène aux cartes voulues).
    final wanted = <String, Set<String>>{}; // lieu manquant → cibles
    for (final (causa, target, _) in all) {
      if (causa != IterCausa.frontier || !sure(target)) continue;
      final proved = ev.records[target]?.places ?? const <String>{};
      for (final p in placesOf(coverage, target).where((p) => !proved.contains(p))) {
        (wanted[p] ??= {}).add(target);
      }
    }
    if (wanted.isNotEmpty) {
      IterChoice? best;
      for (final e in candidates.entries) {
        final targetsHere = wanted[e.key.activity.key];
        if (targetsHere == null) continue;
        final cov = coverage.of(e.key.id);
        final hit = cov.where(targetsHere.contains).length;
        final unsureHere = cov.where((n) => !sure(n)).toList();
        final score = (hit + 0.5) * (e.value ? 0.85 : 1.0) / (1 + unsureHere.length / 4);
        if (best == null || score > best.score) {
          best = IterChoice(trial: e.key, mustBuy: e.value, causa: IterCausa.frontier, nodes: [...cov.where(targetsHere.contains), ...unsureHere.take(3)], score: score);
        }
      }
      if (best != null && best.nodes.isNotEmpty) return best;
    }
    // Aucune carte n'atteint les cibles prioritaires : la première atteignable.
    for (final (causa, target, weight) in list) {
      for (final e in candidates.entries) {
        if (coverage.of(e.key.id).contains(target)) {
          return IterChoice(trial: e.key, mustBuy: e.value, causa: causa, nodes: [target], score: weight);
        }
      }
    }
    return null;
  }

  /// Amorce l'évidence de l'arbre depuis l'ancien historique par carte : les
  /// maillons couverts par une carte pratiquée héritent de son enregistrement
  /// (estimation, compte, dernière pratique) s'ils n'en ont pas encore.
  static ArborEvidence seedFromCardSkills(SaveData save, Arbor arbor, TrialCoverage coverage) {
    final records = Map<String, SkillRecord>.from(save.arbor.records);
    for (final t in Trials.all) {
      final r = save.skills[t.primarySkill];
      if (r == null || r.autonomousCount == 0) continue;
      for (final n in coverage.of(t.id)) {
        if (!arbor.nodes.containsKey(n) || n.startsWith('cella.') || n.startsWith('lex.')) continue;
        final cur = records[n];
        if (cur == null || cur.autonomousCount < r.autonomousCount) records[n] = r.apply(Observation(at: r.lastPractice ?? DateTime.now(), correct: true, lemmaId: '', quality: AnswerQuality.autonoma, trialId: t.id), MasteryConfig(), place: t.activity.key);
      }
    }
    return ArborEvidence(records: records, hypotheses: save.arbor.hypotheses);
  }
}
