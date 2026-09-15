/// Besoins de sélection dérivés de l'évidence : quel poids donner à une forme
/// candidate selon les maillons qu'elle met en jeu.
library;

import '../linguistics/model/analysis.dart';
import '../linguistics/model/nominal.dart';
import '../linguistics/model/verb.dart';
import '../pedagogy/mastery.dart';
import 'arbor.dart';
import 'cellae.dart';
import 'evidence.dart';

class ArborNeeds {
  ArborNeeds(this.arbor, this.evidence, this.now, {this.cfg = const MasteryConfig(), this.focus = const {}});

  /// Maillons visés par l'Iter pour ce combat : les formes qui les portent
  /// pèsent quatre fois plus.
  final Set<String> focus;
  final Arbor arbor;
  final ArborEvidence evidence;
  final DateTime now;
  final MasteryConfig cfg;

  double nodes(Iterable<String> ids) {
    final base = evidence.need(ids, now, cfg: cfg);
    return focus.isNotEmpty && ids.any(focus.contains) ? base * 4 : base;
  }
  double verb(Analysis a, VerbEntry v) => nodes(verbalComponents(a, v));
  double nominal(NominalForm f, Lexeme l) => nodes(nominalComponents(f, l));
}
