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
import 'frames/frame_question_source.dart';
import 'mastery.dart';
import 'progression.dart';
import 'question_generator.dart';
import 'trials.dart';

/// Maillons que chaque carte peut faire travailler : l'union des composants
/// des formes de son vivier (Amphitheatrum, Forum) ou ses nœuds visés
/// (Theatrum, Templum). Calculé une fois.
class TrialCoverage {
  TrialCoverage(this.nodesByTrial, {this.lemmaCapacities = const {}, this.lemmasByTrial = const {}, this.proves});
  final Map<String, Set<String>> nodesByTrial;
  /// Diversité maximale du vivier de chaque maillon morphologique, tous lieux
  /// réunis : « ego » ne peut pas exiger quatre lexèmes différents.
  final Map<String, int> lemmaCapacities;
  final Map<String, Map<String, Set<String>>> lemmasByTrial;
  final bool Function(Trial, String, List<String>, ArborNeeds?)? proves;
  final Map<String, bool> _proofCache = {};
  final Map<String, bool> _coverCache = {};
  final Map<String, Set<String>> _placesCache = {};
  late final Map<String, List<Trial>> _trialsByNode = {
    for (final id in covered)
      id: [for (final t in Trials.all) if (of(t.id).contains(id)) t],
  };
  String? _exposureKey;
  final Map<String, bool> _exposedProofCache = {};

  bool canProve(Trial trial, String node, {List<String>? components, ArborNeeds? needs}) {
    if (!of(trial.id).contains(node)) return false;
    if (proves == null) return true;
    final ids = components ?? trial.components.map((c) => c.id).toList();
    final key = '${trial.id}|${ids.join(',')}|$node';
    if (needs == null) return _proofCache[key] ??= proves!(trial, node, ids, null);
    if (_exposureKey != needs.exposureKey) {
      _exposureKey = needs.exposureKey;
      _exposedProofCache.clear();
    }
    return _exposedProofCache[key] ??= proves!(trial, node, ids, needs);
  }

  List<Trial> trialsFor(String node) => _trialsByNode[node] ?? const [];

  bool canCover(String node) => _coverCache[node] ??= trialsFor(node).any((t) => canProve(t, node));

  Set<String> placesFor(String node) => _placesCache.putIfAbsent(node, () {
    final places = <String>{};
    for (final t in trialsFor(node)) {
      if (!places.contains(t.activity.key) && canProve(t, node)) places.add(t.activity.key);
    }
    return Set.unmodifiable(places);
  });

  /// Tous les maillons qu'au moins une carte peut prouver.
  late final Set<String> covered = {for (final s in nodesByTrial.values) ...s};

  Set<String> of(String trialId) => nodesByTrial[trialId] ?? const {};

  factory TrialCoverage.build(QuestionGenerator verbs, ForumQuestionSource forum, {Diagnostician? diagnostician, FrameQuestionSource? frames}) {
    final out = <String, Set<String>>{};
    final verbCache = <String, Set<String>>{};
    final lemmas = <String, Set<String>>{};
    final byTrial = <String, Map<String, Set<String>>>{};
    void count(String trial, Iterable<String> nodes, String lemma) {
      for (final n in nodes) {
        if (!n.startsWith('not.') && !n.startsWith('cella.') && !n.startsWith('lex.')) {
          (lemmas[n] ??= {}).add(lemma);
          ((byTrial[trial] ??= {})[n] ??= {}).add(lemma);
        }
      }
    }
    for (final t in Trials.all) {
      final comps = t.components.map((c) => c.id).toList();
      final nodes = <String>{};
      switch (t.activity) {
        case Activity.amphitheatrum:
          for (final e in verbs.pool(t, comps)) {
            final key = '${e.verb.id}|${e.form.analysis.selector}';
            final parts = verbCache[key] ??= verbalComponents(e.form.analysis, e.verb);
            nodes.addAll(parts);
            count(t.id, parts, e.verb.id);
          }
        case Activity.forum:
          for (final e in forum.pool(t, comps)) {
            final parts = nominalComponents(e.form, e.lexeme);
            final s = e.syntagma;
            if (s != null) {
              if (s.functio != null) parts.add(Diagnostician.functioNode(s.functio!.key, s));
              if (s.constructio != null) parts.addAll(Diagnostician.constructioNodes(s.constructio!.key));
              if (s.relatio != null) parts.addAll({s.relatio!.key == 'subiectum' ? 'syn.pron.reflexivum' : 'syn.pron.is.anaphora', 'pron.suus_eius'});
              if (s.head != null) parts.addAll({'syn.concordia.adiectivum', 'syn.concordia.distans'});
            }
            nodes.addAll(parts);
            count(t.id, parts, e.lexeme.id);
          }
        case Activity.theatrum:
        case Activity.templum:
          if (t.filter is FrameFilter) nodes.addAll(frameCardNodes((t.filter as FrameFilter).card));
      }
      nodes.removeWhere((n) => n.startsWith('not.') || n.startsWith('cella.') || n.startsWith('lex.'));
      out[t.id] = nodes;
    }
    final dx = diagnostician ?? Diagnostician(Arbor.standard(analyzer: verbs.analyzer, nominal: forum.analyzer), verbs, forum);
    return TrialCoverage(out, lemmaCapacities: {for (final e in lemmas.entries) e.key: e.value.length}, lemmasByTrial: byTrial,
      proves: (t, node, components, needs) {
        if (t.activity == Activity.theatrum || t.activity == Activity.templum) return frames == null || frames.pool(t).isNotEmpty;
        bool proves(Question q) => dx.credited(q).contains(node);
        return (t.activity == Activity.amphitheatrum
          ? verbs.forTarget(trial: t, componentIds: components, target: node, rng: Random(0), id: 'coverage', proves: proves, dimensions: ArborNeeds.dimensionsFor(dx.arbor, node), canPresent: needs?.canPresent, constrain: needs == null ? null : (q) => needs.constrain(q, dx.chosenComponents, surfaceComponents: dx.targetComponents(q)), eligibilityKey: needs?.questionCacheKey)
          : forum.forTarget(trial: t, componentIds: components, target: node, rng: Random(0), id: 'coverage', proves: proves, dimensions: ArborNeeds.dimensionsFor(dx.arbor, node), canPresent: needs?.canPresent, constrain: needs == null ? null : (q) => needs.constrain(q, dx.chosenComponents, surfaceComponents: dx.targetComponents(q)), eligibilityKey: needs?.questionCacheKey)) != null;
      });
  }
}

/// Pourquoi un maillon est visé.
enum IterCausa { remediatio, repetitio, frontier }

class IterChoice {
  const IterChoice({required this.trial, required this.mustBuy, required this.causa, required this.nodes, required this.score, this.purchasePath = const []});

  /// La carte qui isole le mieux la cible : le véhicule, pas la décision.
  final Trial trial;

  /// La carte n'est pas encore ouverte : il faut l'acheter (achetable, solde suffisant).
  final bool mustBuy;
  final List<Trial> purchasePath;
  List<Trial> get purchases => !mustBuy ? const [] : purchasePath.isEmpty ? [trial] : purchasePath;
  int get price => purchases.fold<int>(0, (n, t) => n + t.price);
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
  static Set<String> placesOf(TrialCoverage coverage, String id) => coverage.placesFor(id);

  /// Maîtrisé sur tous ses plans : expert, non dû, et prouvé dans chaque lieu
  /// qui le couvre (comprendre au Theātrum ne suffit pas si le Templum le
  /// demande aussi).
  static bool masteredEverywhere(ArborEvidence ev, TrialCoverage coverage, String id, MasteryConfig cfg, DateTime now) {
    if (!mastered(ev, id, cfg, now)) return false;
    final places = ev.records[id]?.places ?? const <String>{};
    return placesOf(coverage, id).every(places.contains);
  }

  /// Le dénominateur vient du programme, jamais des seules cartes disponibles.
  /// Une absence de proposition peut être un blocage, pas une fin de parcours.
  static List<String> pendingNodes({required SaveData save, required Arbor arbor, MasteryConfig cfg = const MasteryConfig(), DateTime? now}) {
    final at = now ?? DateTime.now();
    return [
      for (final node in arbor.omnes)
        if (node.stratum != Stratum.notio && node.stratum != Stratum.cella && node.probatur.isNotEmpty && !mastered(save.arbor, node.id, cfg, at)) node.id,
    ];
  }

  /// Moment de l'observation la plus récente de l'arbre.
  static DateTime? lastObservationAt(ArborEvidence ev) {
    DateTime? at;
    for (final r in ev.records.values) {
      for (final o in r.recent) {
        if (at == null || o.at.isAfter(at)) at = o.at;
      }
    }
    return at;
  }

  /// Compétence en contexte (Theātrum / Templum) : une carte y expose un fait
  /// de langue ; la maîtrise viendra par les rappels.
  static bool isContext(String id) => id.startsWith('lect.intellectus.') || id.startsWith('lect.thema.');

  /// Exposé : pratiqué avec au moins le palier « familiāris » (cinq réponses,
  /// estimation ≥ 0,6). C'est le seuil qui ouvre ce qui dépend d'une compétence
  /// en contexte — le thème après la version, la carte suivante, la grammaire —
  /// sans attendre le palier expert, que le nœud continue de viser.
  static bool exposed(ArborEvidence ev, String id, MasteryConfig cfg, DateTime now) {
    final r = ev.records[id];
    if (r == null || r.autonomousCount == 0) return false;
    return r.asOf(now, cfg).tier(cfg).index >= MasteryTier.familiaris.index;
  }

  /// Un prérequis est tenu : exposé s'il est une compétence en contexte,
  /// maîtrisé (expert, non dû) sinon.
  static bool holds(ArborEvidence ev, String id, MasteryConfig cfg, DateTime now) => isContext(id) && !id.endsWith('.vocabula') ? exposed(ev, id, cfg, now) : mastered(ev, id, cfg, now);

  /// Carte acquise au sens de la chaîne : ses maillons tiennent ([holds]) —
  /// une carte du Theātrum ou du Templum ouvre la suivante dès l'exposition.
  static bool cardAcquired(ArborEvidence ev, TrialCoverage coverage, Trial t, MasteryConfig cfg, DateTime now) {
    return _cardReady(coverage, t, (n) => holds(ev, n, cfg, now));
  }

  /// Le lieu où un maillon s'exerce nativement, d'après sa branche.
  static Activity nativeActivity(String id) => switch (branchOf(id)) {
    'v' => Activity.amphitheatrum,
    'n' || 'syn' => Activity.forum,
    'thema' => Activity.templum,
    _ => Activity.theatrum,
  };

  /// Carte acquise : (presque) tous les maillons qu'elle couvre sont maîtrisés
  /// — un dixième de marge pour les formes rares que ses questions tirent peu.
  static bool cardMastered(ArborEvidence ev, TrialCoverage coverage, Trial t, MasteryConfig cfg, DateTime now) {
    return _cardReady(coverage, t, (n) => mastered(ev, n, cfg, now));
  }

  static bool _cardReady(TrialCoverage coverage, Trial t, bool Function(String) ready) {
    final cov = coverage.of(t.id);
    final missing = cov.where((n) => !ready(n));
    var count = 0;
    for (final n in missing) {
      if (coverage.canProve(t, n) && ++count > cov.length ~/ 10) return false;
    }
    if (count == 0) return true;
    return count <= cov.where((n) => coverage.canProve(t, n)).length ~/ 10;
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
    final needs = ArborNeeds(arbor, ev, at, cfg: cfg);
    bool isNode(String id) {
      final s = arbor[id];
      return s != null && s.stratum != Stratum.notio && s.stratum != Stratum.cella && s.stratum != Stratum.lexicon && s.probatur.isNotEmpty;
    }
    bool sure(String id) => mastered(ev, id, cfg, at);
    bool complete(String id) => coverage == null ? sure(id) : masteredEverywhere(ev, coverage, id, cfg, at);
    // Un prérequis qu'aucune carte ne prouve (geste de lecture, construction
    // sans carte) ne bloque pas : il se lit sur ce qui en dépend.
    bool coverable(String id) => coverage == null || coverage.canCover(id);
    bool gating(String id) => isNode(id) && coverable(id);
    // Un prérequis est satisfait s'il est maîtrisé ; s'il n'est prouvable par
    // aucune carte, si ses propres prérequis le sont (la dépendance passe à
    // travers lui : la syntaxe des déponents attend la morphologie des déponents).
    final satisfiedMemo = <String, bool>{};
    bool satisfied(String id) {
      final memo = satisfiedMemo[id];
      if (memo != null) return memo;
      satisfiedMemo[id] = true; // garde contre un cycle
      final node = arbor[id];
      final ok = node != null && (node.probatur.isEmpty
        ? node.requirit.every(satisfied)
        : holds(ev, id, cfg, at));
      return satisfiedMemo[id] = ok;
    }
    final out = <(IterCausa, String, double)>[];
    // 1. Redescendre jusqu'à un prérequis réellement prêt. Un thème suspect
    // n'autorise jamais à sauter sa version encore inconnue.
    final visited = <String>{};
    void remediate(String id, double weight) {
      if (!visited.add(id)) return;
      final prerequisites = arbor[id]?.requirit ?? const <String>[];
      final missing = prerequisites.where((p) => !satisfied(p)).toList();
      if (missing.isNotEmpty) {
        for (final pre in missing) {
          remediate(pre, 2.5);
        }
      } else if (gating(id) && (isContext(id) || needs.introduced(id))) {
        out.add((IterCausa.remediatio, id, weight));
      }
    }
    for (final id in ev.hypotheses.keys) {
      remediate(id, 3.0);
    }
    // 2. Rappels dus.
    for (final e in ev.records.entries) {
      if (!isNode(e.key) || e.value.autonomousCount == 0) continue;
      if (!isContext(e.key) && !needs.introduced(e.key)) continue;
      final rr = e.value.asOf(at, cfg);
      if (rr.reviewDue(at, cfg) && !ev.hypotheses.containsKey(e.key) && gating(e.key)) out.add((IterCausa.repetitio, e.key, 1.5 + (1 - (rr.estimate ?? 0.5))));
    }
    // 3. Frontière : jamais prouvé, pas encore expert, ou expert sur un plan
    //    seulement (compris au Theātrum, jamais produit au Templum) ; prérequis
    //    tous maîtrisés ; le plus fondamental (portée) puis le plus bas.
    for (final s in arbor.omnes) {
      if (!isNode(s.id) || ev.hypotheses.containsKey(s.id)) continue;
      if (!isContext(s.id) && !needs.introduced(s.id)) continue;
      if (!s.requirit.every(satisfied)) continue;
      if (!gating(s.id) || complete(s.id)) continue;
      final r = ev.records[s.id];
      if (r != null && r.autonomousCount > 0 && r.asOf(at, cfg).reviewDue(at, cfg)) continue; // déjà compté en rappel
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
    final needs = ArborNeeds(arbor, ev, at, cfg: cfg);
    final all = targets(arbor: arbor, ev: ev, coverage: coverage, cfg: cfg, now: at);
    if (all.isEmpty) return null;
    final last = lastTrialPlayed(ev);
    bool sure(String id) => mastered(ev, id, cfg, at);
    // Cartes jouables ou achetables, et pédagogiquement ouvertes : la chaîne des
    // cartes est la progression du jeu, une carte ne sert de véhicule que si
    // les cartes qu'elle requiert sont maîtrisées (pas seulement achetées).
    // « Nōs et vōs » attend que « Ego et tū » soit acquis, même si les deux
    // portent la même désinence.
    final playable = <Trial, bool>{};
    final purchases = <String, List<Trial>>{};
    final components = <String, List<String>>{};
    for (final t in Trials.all) {
      final status = Progression.status(save, t);
      final buy = status.access == TrialAccess.purchasable && status.affordable;
      if (status.access != TrialAccess.accessible && !buy) continue;
      final path = buy ? [t] : const <Trial>[];
      purchases[t.id] = path;
      components[t.id] = Progression.componentsFor(buy ? save.copyWith(purchased: {...save.purchased, ...path.map((t) => t.id)}) : save, t);
      playable[t] = buy;
    }
    final acquired = <String, bool>{};
    bool isOpen(Trial t) => t.prerequisites.every((p) => acquired[p] ??= cardAcquired(ev, coverage, Trials.byId(p), cfg, at));
    // Un maillon se travaille d'abord dans son lieu natif (désinence nominale
    // au Forum, même si un participe la fait passer à l'Amphitheātrum) ; les
    // autres lieux qui le couvrent viennent ensuite, comme plans à compléter.
    // Si la carte native n'est pas encore ouverte par la chaîne, la cible attend.
    bool allowed(Trial c, String target) {
      // Si seule la diversité manque, reprendre les mêmes lexèmes ne peut plus
      // faire progresser ce maillon. Chercher un autre vivier, sans promouvoir
      // artificiellement la compétence ni se fier au palier global de la carte.
      final r = ev.records[target];
      final lemmas = coverage.lemmasByTrial[c.id]?[target];
      if (r != null && lemmas != null && r.autonomousCount >= cfg.minObservationsPerita &&
          (r.estimate ?? 0) >= cfg.peritaThreshold && (r.recentFirstTrySuccess ?? 0) >= 0.85 &&
          r.tier(cfg) != MasteryTier.perita && lemmas.every(r.lemmas.contains)) {
        return false;
      }
      final native = nativeActivity(target);
      if (!placesOf(coverage, target).contains(native.key) || c.activity == native) return true;
      return ev.records[target]?.places.contains(native.key) ?? false;
    }
    // La recherche de questions intervient seulement sur les candidats les
    // mieux classés, pas sur tout le programme avant d'afficher le premier choix.
    final candidates = playable;
    bool reachable((IterCausa, String, double) t) => coverage.trialsFor(t.$2).any(candidates.containsKey);
    var list = all.where(reachable).toList();
    // Progression globale : les branches du graphe tournent (verbe, nom,
    // syntaxe, intellectus, thema…), la moins récemment travaillée d'abord et
    // les jamais travaillées avant toutes — quelle que soit la cause. Une
    // pile de rappels ou d'hypothèses sur les verbes ne confisque donc pas le
    // parcours : le Forum, le Theātrum et le Templum avancent au même rythme.
    // Seule exception : les hypothèses ouvertes par le dernier combat se
    // traitent tout de suite, c'est ce qui vient de flancher.
    final lastPlayed = lastPlayedByBranch(ev);
    // Une hypothèse est fraîche si le dernier combat l'a touchée : le maillon
    // lui-même y a été observé, ou un maillon suspect qui le requiert.
    bool touched(String id) => ev.records[id]?.recent.any((o) => o.trialId == last) ?? false;
    bool fresh((IterCausa, String, double) t) =>
        t.$1 == IterCausa.remediatio && last != null && (touched(t.$2) || (arbor.requiritur[t.$2] ?? const <String>{}).any((d) => ev.hypotheses.containsKey(d) && touched(d)));
    final branches = list.map((t) => branchOf(t.$2)).toSet().toList()
      ..sort((a, b) {
        final ta = lastPlayed[a], tb = lastPlayed[b];
        if (ta == null && tb != null) return -1;
        if (tb == null && ta != null) return 1;
        if (ta != null && tb != null) return ta.compareTo(tb);
        return a.compareTo(b);
      });
    final order = {for (var i = 0; i < branches.length; i++) branches[i]: i + 1};
    int rank((IterCausa, String, double) t) => fresh(t) ? 0 : order[branchOf(t.$2)]!;
    list = [...list]..sort((a, b) {
      final ra = rank(a), rb = rank(b);
      if (ra != rb) return ra.compareTo(rb);
      if (a.$1 != b.$1) return a.$1.index.compareTo(b.$1.index);
      return b.$3.compareTo(a.$3);
    });
    // Chaque proposition doit passer la vérification de jouabilité. Si aucune
    // carte ne convient à une cible, essayer la suivante sans lancer un combat vide.
    for (final (causa, target, weight) in list) {
      final options = <(Trial, bool, bool, double)>[];
      final proved = ev.records[target]?.places ?? const <String>{};
      final planes = placesOf(coverage, target);
      final targetSure = sure(target);
      for (final trial in coverage.trialsFor(target)) {
        if (!candidates.containsKey(trial) || !allowed(trial, target)) continue;
        final buy = candidates[trial]!;
        final cov = coverage.of(trial.id);
        // Une cible déjà sûre sur ce plan ne s'y rejoue pas hors rappel : c'est
        // le plan manquant qu'il faut ouvrir (quand sa carte sera atteignable).
        if (causa == IterCausa.frontier && targetSure && proved.contains(trial.activity.key)) continue;
        // « À peine plus difficile » : la part de la carte déjà maîtrisée, et le
        // moins possible de maillons qui ne sont ni la cible ni maîtrisés.
        // Les gestes de traduction (lect.versio.*) accompagnent toute carte du
        // Theatrum ou du Templum : ils ne comptent pas comme difficulté ajoutée.
        final others = cov.where((n) => n != target && !sure(n) && !n.startsWith('lect.versio.')).length;
        var score = weight * (0.5 + cov.where(sure).length / cov.length) / (1 + others / 4);
        if (buy) score *= 0.85;
        if (trial.id == last) score *= 0.5;
        // Le plan manquant d'abord : une cible déjà prouvée au Theātrum se joue
        // au Templum (et inversement), un plan déjà prouvé ne repasse qu'en rappel.
        if (planes.length > 1 && !proved.contains(trial.activity.key)) score *= 3;
        // Le lieu natif du maillon d'abord : une désinence nominale se revoit au
        // Forum, pas dans une carte de verbes où elle passe par un participe.
        if (trial.activity != nativeActivity(target)) score *= 0.4;
        // Une carte déjà acquise ne fait plus progresser : elle ne sert de
        // véhicule qu'en rappel, ou faute d'autre carte.
        if (causa != IterCausa.repetitio && cov.every(sure)) score *= 0.3;
        // À cible égale, changer de lieu.
        if (last != null && Trials.maybe(last)?.activity == trial.activity) score *= 0.7;
        options.add((trial, buy, isOpen(trial), score));
      }
      options.sort((a, b) {
        if (a.$3 != b.$3) return a.$3 ? -1 : 1;
        return b.$4.compareTo(a.$4);
      });
      for (final (trial, buy, _, score) in options) {
        if (!coverage.canProve(trial, target, components: components[trial.id], needs: needs)) continue;
        return IterChoice(trial: trial, mustBuy: buy, causa: causa, nodes: [target], score: score, purchasePath: purchases[trial.id]!);
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
