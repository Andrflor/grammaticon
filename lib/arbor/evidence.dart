/// Évidence par nœud de l'arbre : ce que le joueur a prouvé, raté, et les
/// hypothèses ouvertes (prérequis suspects d'un maillon raté).
///
/// Les enregistrements réutilisent `SkillRecord` (estimation lissée, fenêtre
/// récente, échéance de révision) : le modèle de maîtrise n'est pas en cause,
/// c'est l'objet qu'il mesure qui change — un maillon, pas une case de manuel.
library;

import '../pedagogy/mastery.dart';
import 'arbor.dart';
import 'diagnosis.dart';

class ArborEvidence {
  const ArborEvidence({this.records = const {}, this.hypotheses = const {}});

  /// nœud → historique.
  final Map<String, SkillRecord> records;

  /// nœud suspect → date d'ouverture de l'hypothèse. Une hypothèse se ferme
  /// quand le nœud est prouvé par une bonne réponse autonome.
  final Map<String, DateTime> hypotheses;

  SkillRecord of(String id) => records[id] ?? const SkillRecord();

  /// Enregistre le résultat d'une question.
  ///
  /// - Bonne réponse : les nœuds [credited] (ceux que la question distinguait)
  ///   reçoivent une observation positive ; leurs hypothèses se ferment.
  /// - Mauvaise réponse : les nœuds `observed` du diagnostic reçoivent une
  ///   observation négative ; leurs prérequis non encore établis deviennent
  ///   des hypothèses, ainsi que les nœuds eux-mêmes.
  ArborEvidence observe({
    required Arbor arbor,
    required Diagnosis diagnosis,
    required Set<String> credited,
    required bool correct,
    required AnswerQuality quality,
    required String lemmaId,
    required String trialId,
    required DateTime now,
    MasteryConfig cfg = const MasteryConfig(),
  }) {
    final recs = Map<String, SkillRecord>.from(records);
    final hyps = Map<String, DateTime>.from(hypotheses);
    final obs = Observation(at: now, correct: correct, lemmaId: lemmaId, quality: quality, trialId: trialId);
    if (correct) {
      for (final id in credited.where(arbor.nodes.containsKey)) {
        recs[id] = of(id).apply(obs, cfg);
        if (quality == AnswerQuality.autonoma) hyps.remove(id);
      }
    } else {
      final targets = diagnosis.observedElementa.where(arbor.nodes.containsKey).toSet();
      for (final id in targets) {
        recs[id] = of(id).apply(obs, cfg);
        hyps.putIfAbsent(id, () => now);
        for (final pre in arbor.prerequisitesOf(id)) {
          final r = recs[pre] ?? of(pre);
          if (r.tier(cfg).index < MasteryTier.familiaris.index) hyps.putIfAbsent(pre, () => now);
        }
      }
      // Les notions L0 touchées gardent aussi la trace (agrégat de la Tabula).
      for (final id in diagnosis.observed.where((id) => id.startsWith('not.') && arbor.nodes.containsKey(id))) {
        recs[id] = of(id).apply(obs, cfg);
      }
    }
    return ArborEvidence(records: recs, hypotheses: hyps);
  }

  /// Poids de sélection d'un ensemble de maillons : le plus fort besoin parmi
  /// eux. Inconnu → 2 ; faible → jusqu'à 3 ; échéance passée → ×1,5 ;
  /// hypothèse ouverte → ×3.
  double need(Iterable<String> ids, DateTime now, {MasteryConfig cfg = const MasteryConfig()}) {
    var best = 0.0;
    for (final id in ids) {
      if (id.startsWith('not.') || id.startsWith('lex.')) continue;
      var w = selectionWeight(records[id], cfg, now);
      if (hypotheses.containsKey(id)) w *= 3;
      if (w > best) best = w;
    }
    return best == 0 ? 1.0 : best;
  }

  /// Hypothèses ouvertes, la plus profonde d'abord (celle qui a le plus de
  /// prérequis eux-mêmes ouverts vient en dernier : on redescend vers la base).
  List<String> openHypotheses(Arbor arbor) {
    final ids = hypotheses.keys.toList();
    int depth(String id) => arbor.prerequisitesOf(id).where(hypotheses.containsKey).length;
    ids.sort((a, b) => depth(a).compareTo(depth(b)));
    return ids;
  }

  Map<String, Object?> toJson() => {
    'r': {for (final e in records.entries) e.key: e.value.toJson()},
    'h': {for (final e in hypotheses.entries) e.key: e.value.millisecondsSinceEpoch},
  };

  factory ArborEvidence.fromJson(Map<String, Object?> j) => ArborEvidence(
    records: {for (final e in ((j['r'] as Map?) ?? const {}).entries) e.key as String: SkillRecord.fromJson((e.value as Map).cast<String, Object?>())},
    hypotheses: {for (final e in ((j['h'] as Map?) ?? const {}).entries) e.key as String: DateTime.fromMillisecondsSinceEpoch((e.value as num).toInt())},
  );
}
