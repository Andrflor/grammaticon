/// Mastery model: per-skill estimate built from real answers.
library;

enum AnswerQuality {
  /// Answered without help, first attempt.
  autonoma('autonoma', 'Autonoma'),
  /// Help (paradigm table) consulted before answering.
  adiuta('adiuta', 'Adiūta'),
  /// Answered after the solution or a correction had been shown.
  correcta('correcta', 'Correcta');

  const AnswerQuality(this.key, this.latin);
  final String key;
  final String latin;
  static AnswerQuality fromKey(String k) => values.firstWhere((e) => e.key == k);
}

enum MasteryTier {
  nova('nova', 'Nova'),
  discens('discens', 'Discēns'),
  familiaris('familiaris', 'Familiāris'),
  perita('perita', 'Perīta');

  const MasteryTier(this.key, this.latin);
  final String key;
  final String latin;
  static MasteryTier fromKey(String k) => values.firstWhere((e) => e.key == k);
}

enum Reliability {
  nulla('Nōn aestimāta'),
  incerta('Incerta'),
  mediocris('Mediocris'),
  firma('Firma');

  const Reliability(this.latin);
  final String latin;
}

class MasteryConfig {
  const MasteryConfig({
    this.alpha = 0.2,
    this.highWaterDecay = 0.02,
    this.familiarisThreshold = 0.6,
    this.peritaThreshold = 0.85,
    this.minObservationsFamiliaris = 5,
    this.minObservationsPerita = 12,
    this.minLemmasPerita = 4,
    this.recentWindow = 20,
    this.reviewDaysDiscens = 2,
    this.reviewDaysFamiliaris = 5,
    this.reviewDaysPerita = 14,
  });

  final double alpha;
  final double highWaterDecay;
  final double familiarisThreshold;
  final double peritaThreshold;
  final int minObservationsFamiliaris;
  final int minObservationsPerita;
  final int minLemmasPerita;
  final int recentWindow;
  final int reviewDaysDiscens;
  final int reviewDaysFamiliaris;
  final int reviewDaysPerita;
}

class Observation {
  const Observation({required this.at, required this.correct, required this.lemmaId, required this.quality, required this.trialId});
  final DateTime at;
  final bool correct;
  final String lemmaId;
  final AnswerQuality quality;
  final String trialId;

  Map<String, Object?> toJson() => {'t': at.millisecondsSinceEpoch, 'c': correct, 'l': lemmaId, 'q': quality.key, 'tr': trialId};
  factory Observation.fromJson(Map<String, Object?> j) => Observation(
        at: DateTime.fromMillisecondsSinceEpoch(j['t'] as int),
        correct: j['c'] as bool,
        lemmaId: j['l'] as String,
        quality: AnswerQuality.fromKey(j['q'] as String),
        trialId: j['tr'] as String? ?? '',
      );
}

/// Weight of a form for question selection, from the record of the skill it
/// would credit: unknown skills are drawn twice as often as mastered ones,
/// weak skills up to three times, and a skill due for review half as much
/// again. Never zero: mastered material keeps appearing.
double selectionWeight(SkillRecord? r, MasteryConfig cfg, DateTime now) {
  if (r == null || r.autonomousCount == 0 || r.estimate == null) return 2.0;
  var w = 1.0 + 2.0 * (1.0 - r.estimate!.clamp(0.0, 1.0));
  if (r.reviewDue(now, cfg)) w *= 1.5;
  return w;
}

/// Immutable record of one skill.
class SkillRecord {
  const SkillRecord({
    this.autonomousCorrect = 0,
    this.autonomousWrong = 0,
    this.aidedCorrect = 0,
    this.aidedWrong = 0,
    this.correctedCorrect = 0,
    this.estimate,
    this.highWater = 0,
    this.recent = const [],
    this.lemmas = const {},
    this.sessionDays = const {},
    this.lastPractice,
  });

  final int autonomousCorrect;
  final int autonomousWrong;
  final int aidedCorrect;
  final int aidedWrong;
  final int correctedCorrect;

  /// Exponential moving estimate of first-attempt success (0..1); null before
  /// the first autonomous observation.
  final double? estimate;

  /// Slowly decaying high-water mark of [estimate]; drives the reward tier so a
  /// deliberate error does not immediately restore high rewards.
  final double highWater;
  final List<Observation> recent;
  final Set<String> lemmas;

  /// Distinct practice days (yyyymmdd) — diversity across sessions.
  final Set<String> sessionDays;
  final DateTime? lastPractice;

  int get autonomousCount => autonomousCorrect + autonomousWrong;
  int get totalCount => autonomousCount + aidedCorrect + aidedWrong + correctedCorrect;

  static String dayKey(DateTime d) => '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  SkillRecord apply(Observation o, MasteryConfig cfg) {
    var ac = autonomousCorrect, aw = autonomousWrong, aidC = aidedCorrect, aidW = aidedWrong, corC = correctedCorrect;
    var est = estimate;
    var hw = highWater;
    switch (o.quality) {
      case AnswerQuality.autonoma:
        if (o.correct) {
          ac++;
        } else {
          aw++;
        }
        final x = o.correct ? 1.0 : 0.0;
        est = est == null ? (o.correct ? 0.55 : 0.2) : est + cfg.alpha * (x - est);
        hw = (hw - cfg.highWaterDecay).clamp(0.0, 1.0);
        if (est > hw) hw = est;
      case AnswerQuality.adiuta:
        if (o.correct) {
          aidC++;
        } else {
          aidW++;
        }
        // Aided answers inform the estimate weakly and never raise the tier.
        if (est != null && !o.correct) est = est + cfg.alpha * 0.5 * (0.0 - est);
      case AnswerQuality.correcta:
        if (o.correct) corC++;
    }
    final rec = [...recent, o];
    while (rec.length > cfg.recentWindow) {
      rec.removeAt(0);
    }
    final lem = {...lemmas, o.lemmaId};
    final days = {...sessionDays, dayKey(o.at)};
    return SkillRecord(
      autonomousCorrect: ac,
      autonomousWrong: aw,
      aidedCorrect: aidC,
      aidedWrong: aidW,
      correctedCorrect: corC,
      estimate: est,
      highWater: hw,
      recent: rec,
      lemmas: lem.length > 60 ? lem.skip(lem.length - 60).toSet() : lem,
      sessionDays: days,
      lastPractice: o.at,
    );
  }

  /// Tier used for the Tabula (honest, current estimate).
  MasteryTier tier(MasteryConfig cfg) => _tierOf(estimate, cfg, requireRecent: true);

  /// Tier used for rewards (slow to fall back after errors).
  MasteryTier rewardTier(MasteryConfig cfg) {
    if (estimate == null) return MasteryTier.nova;
    final honest = tier(cfg);
    final hwTier = _tierOf(highWater, cfg, requireRecent: false);
    return hwTier.index > honest.index ? hwTier : honest;
  }

  MasteryTier _tierOf(double? e, MasteryConfig cfg, {required bool requireRecent}) {
    if (e == null || autonomousCount == 0) return MasteryTier.nova;
    final recentOk = !requireRecent || (recentFirstTrySuccess ?? 0) >= 0.85;
    if (e >= cfg.peritaThreshold && autonomousCount >= cfg.minObservationsPerita && lemmas.length >= cfg.minLemmasPerita && recentOk) {
      return MasteryTier.perita;
    }
    if (e >= cfg.familiarisThreshold && autonomousCount >= cfg.minObservationsFamiliaris) return MasteryTier.familiaris;
    return MasteryTier.discens;
  }

  /// Success rate of recent autonomous (first-attempt) answers.
  double? get recentFirstTrySuccess {
    final auto = recent.where((o) => o.quality == AnswerQuality.autonoma).toList();
    if (auto.isEmpty) return null;
    return auto.where((o) => o.correct).length / auto.length;
  }

  Reliability reliability(MasteryConfig cfg) {
    if (autonomousCount == 0) return Reliability.nulla;
    if (autonomousCount < 5 || lemmas.length < 2) return Reliability.incerta;
    if (autonomousCount < 12 || lemmas.length < 4 || sessionDays.length < 2) return Reliability.mediocris;
    return Reliability.firma;
  }

  bool reviewDue(DateTime now, MasteryConfig cfg) {
    final last = lastPractice;
    if (last == null) return false;
    final days = now.difference(last).inDays;
    switch (tier(cfg)) {
      case MasteryTier.nova:
        return false;
      case MasteryTier.discens:
        return days >= cfg.reviewDaysDiscens;
      case MasteryTier.familiaris:
        return days >= cfg.reviewDaysFamiliaris;
      case MasteryTier.perita:
        return days >= cfg.reviewDaysPerita;
    }
  }

  Map<String, Object?> toJson() => {
        'ac': autonomousCorrect,
        'aw': autonomousWrong,
        'aidc': aidedCorrect,
        'aidw': aidedWrong,
        'corc': correctedCorrect,
        if (estimate != null) 'est': estimate,
        'hw': highWater,
        'recent': recent.map((o) => o.toJson()).toList(),
        'lemmas': lemmas.toList(),
        'days': sessionDays.toList(),
        if (lastPractice != null) 'last': lastPractice!.millisecondsSinceEpoch,
      };

  factory SkillRecord.fromJson(Map<String, Object?> j) => SkillRecord(
        autonomousCorrect: (j['ac'] as num?)?.toInt() ?? 0,
        autonomousWrong: (j['aw'] as num?)?.toInt() ?? 0,
        aidedCorrect: (j['aidc'] as num?)?.toInt() ?? 0,
        aidedWrong: (j['aidw'] as num?)?.toInt() ?? 0,
        correctedCorrect: (j['corc'] as num?)?.toInt() ?? 0,
        estimate: (j['est'] as num?)?.toDouble(),
        highWater: (j['hw'] as num?)?.toDouble() ?? 0,
        recent: ((j['recent'] as List?) ?? const []).map((e) => Observation.fromJson((e as Map).cast<String, Object?>())).toList(),
        lemmas: ((j['lemmas'] as List?) ?? const []).cast<String>().toSet(),
        sessionDays: ((j['days'] as List?) ?? const []).cast<String>().toSet(),
        lastPractice: j['last'] == null ? null : DateTime.fromMillisecondsSinceEpoch(j['last'] as int),
      );
}
