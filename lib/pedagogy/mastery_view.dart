/// Read models of mastery for the Tabula and trial cards.
library;

import '../persistence/save_data.dart';
import 'mastery.dart';
import 'skills.dart';

class MasterySummary {
  const MasterySummary({
    required this.skillId,
    required this.tier,
    required this.estimate,
    required this.observations,
    required this.lemmas,
    required this.sessions,
    required this.recentFirstTry,
    required this.lastPractice,
    required this.reviewDue,
    required this.reliability,
    required this.evaluatedLeaves,
    required this.totalLeaves,
  });

  final String skillId;
  final MasteryTier tier;
  final double? estimate;
  final int observations;
  final int lemmas;
  final int sessions;
  final double? recentFirstTry;
  final DateTime? lastPractice;
  final bool reviewDue;
  final Reliability reliability;
  final int evaluatedLeaves;
  final int totalLeaves;

  bool get evaluated => observations > 0;

  /// Percentage text or "—".
  String get estimateText => estimate == null ? '—' : '${(estimate! * 100).round()} %';

  static MasterySummary forSkill(SaveData save, String skillId, MasteryConfig cfg, {DateTime? now}) {
    now ??= DateTime.now();
    final leaves = Skills.leaves(skillId);
    if (leaves.length == 1 && leaves.first == skillId) {
      final r = save.skills[skillId] ?? const SkillRecord();
      return MasterySummary(
        skillId: skillId,
        tier: r.tier(cfg),
        estimate: r.estimate,
        observations: r.autonomousCount,
        lemmas: r.lemmas.length,
        sessions: r.sessionDays.length,
        recentFirstTry: r.recentFirstTrySuccess,
        lastPractice: r.lastPractice,
        reviewDue: r.reviewDue(now, cfg),
        reliability: r.reliability(cfg),
        evaluatedLeaves: r.autonomousCount > 0 ? 1 : 0,
        totalLeaves: 1,
      );
    }
    // Aggregate: weighted by observations; tier = lowest tier among evaluated
    // leaves (a branch is only as strong as its weakest evaluated skill).
    var n = 0, lem = 0, evaluated = 0;
    double sum = 0;
    MasteryTier? lowest;
    DateTime? last;
    var due = false;
    final days = <String>{};
    for (final id in leaves) {
      final r = save.skills[id];
      if (r == null || r.autonomousCount == 0) continue;
      evaluated++;
      n += r.autonomousCount;
      lem += r.lemmas.length;
      sum += (r.estimate ?? 0) * r.autonomousCount;
      final t = r.tier(cfg);
      if (lowest == null || t.index < lowest.index) lowest = t;
      if (last == null || (r.lastPractice != null && r.lastPractice!.isAfter(last))) last = r.lastPractice;
      due = due || r.reviewDue(now, cfg);
      days.addAll(r.sessionDays);
    }
    return MasterySummary(
      skillId: skillId,
      tier: lowest ?? MasteryTier.nova,
      estimate: n == 0 ? null : sum / n,
      observations: n,
      lemmas: lem,
      sessions: days.length,
      recentFirstTry: null,
      lastPractice: last,
      reviewDue: due,
      reliability: n == 0 ? Reliability.nulla : (evaluated < leaves.length ? Reliability.incerta : Reliability.mediocris),
      evaluatedLeaves: evaluated,
      totalLeaves: leaves.length,
    );
  }
}
