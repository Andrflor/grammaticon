/// Besoins de sélection dérivés de l'évidence : quel poids donner à une forme
/// candidate selon les maillons qu'elle met en jeu.
library;

import '../linguistics/model/analysis.dart';
import '../linguistics/model/nominal.dart';
import '../linguistics/model/verb.dart';
import '../pedagogy/mastery.dart';
import '../pedagogy/question.dart' show Question;
import '../pedagogy/trial.dart' show Dimension;
import 'arbor.dart';
import 'cellae.dart';
import 'evidence.dart';
import 'skill.dart';
import 'contextus.dart';

class ArborNeeds {
  ArborNeeds(this.arbor, this.evidence, this.now, {this.cfg = const MasteryConfig(), this.focus = const {}, this.credit, this.contrast, this.presented, this.recentQuestions = const []});

  /// Maillons visés par l'Iter pour ce combat : les formes qui les portent
  /// pèsent quatre fois plus.
  final Set<String> focus;
  /// Identités exactes des questions précédentes (surface et contexte).
  final List<String> recentQuestions;
  /// Même diagnostic qu'à la résolution : afficher une forme ne suffit pas.
  final Set<String> Function(Question)? credit;
  final Set<String>? Function(Question, String)? contrast;
  final Set<String> Function(Question)? presented;
  final Arbor arbor;
  final ArborEvidence evidence;
  final DateTime now;
  final MasteryConfig cfg;

  bool exposed(String id) {
    final r = evidence.of(id).asOf(now, cfg);
    return r.autonomousCount > 0 && r.tier(cfg).index >= MasteryTier.familiaris.index;
  }

  /// La version seule ne suffit pas : les liens du graphe demandent le thème,
  /// lequel exige à son tour la version du même concept.
  bool introduced(String id) {
    if ((arbor[id]?.notiones ?? const <String>[]).any(_missingDiscovery)) return false;
    final gates = arbor.discoveriesOf(id);
    if (gates.isEmpty) return false;
    return gates.every((gate) => exposed(gate) &&
      (arbor[gate]?.requirit ?? const <String>[])
        .where((pre) => pre.startsWith('lect.intellectus.') || pre.startsWith('lect.thema.'))
        .every(exposed));
  }

  static bool _missingDiscovery(String id) => kNotionDiscoveries.containsKey(id) && kNotionDiscoveries[id] == null;

  /// Toute la forme doit appartenir aux notions déjà découvertes, y compris
  /// ses composants qui ne sont pas la cible de la question.
  bool canPresent(Iterable<String> components) {
    for (final id in components) {
      if (_missingDiscovery(id)) return false;
      final concept = kCaseDiscoveries[id] ?? kNotionDiscoveries[id];
      if (concept != null && !introduced(discoveryThema(concept))) return false;
      if (id == 'not.tempus.futex' && !exposed('syn.tempora.futex')) return false;
      final node = arbor[id];
      if (node == null || (node.stratum != Stratum.elementum && node.stratum != Stratum.syntaxis)) continue;
      if (node.notiones.any(_missingDiscovery)) return false;
      if (node.notiones.contains('not.tempus.futex') && !exposed('syn.tempora.futex')) return false;
      if (arbor.discoveriesOf(id).isNotEmpty && !introduced(id)) return false;
    }
    return true;
  }

  /// Empêche aussi les distracteurs d'introduire des temps, modes ou cas qui
  /// n'ont pas encore été découverts. Aucun choix nouveau n'est inventé ici.
  Question? constrain(Question q, Set<String>? Function(Question, String) componentsOfChoice, {Set<String>? surfaceComponents}) {
    final parts = surfaceComponents ?? presented?.call(q);
    if (parts != null && !canPresent(parts)) return null;
    final choices = q.choices.where((c) {
      final parts = componentsOfChoice(q, c.value);
      return parts != null && canPresent(parts);
    }).toList();
    if (!choices.any((c) => q.isCorrect(c.value)) || !choices.any((c) => !q.isCorrect(c.value))) return null;
    return q.withChoices(choices);
  }

  late final String exposureKey = ([
    for (final id in evidence.records.keys)
      if ((id.startsWith('lect.intellectus.') || id.startsWith('lect.thema.') || id == 'syn.tempora.futex') && exposed(id)) id,
  ]..sort()).join('|');

  String get questionCacheKey => '${identityHashCode(arbor)}:$exposureKey';

  static List<Dimension> dimensionsFor(Arbor arbor, String target) {
    final node = arbor[target];
    if (node == null) return const [];
    return [
      for (final d in node.probatur)
        ...Dimension.values.where((v) => v.name == d.name),
    ];
  }

  Iterable<String> targets(String place) {
    final eligible = focus.where(introduced).toList();
    final pending = eligible.where((id) {
      final r = evidence.of(id).asOf(now, cfg);
      return r.tier(cfg) != MasteryTier.perita || r.reviewDue(now, cfg) || !r.places.contains(place);
    }).toList();
    // Terminer les quelques questions du combat après acquisition de la cible,
    // même si ses maillons secondaires ne sont pas prouvables par cette carte.
    return [...pending, ...eligible.where((id) => !pending.contains(id))];
  }

  double nodes(Iterable<String> ids) {
    final base = evidence.need(ids, now, cfg: cfg);
    return focus.isNotEmpty && ids.any(focus.contains) ? base * 4 : base;
  }
  double verb(Analysis a, VerbEntry v) => nodes(verbalComponents(a, v));
  double nominal(NominalForm f, Lexeme l) => nodes(nominalComponents(f, l));
}
