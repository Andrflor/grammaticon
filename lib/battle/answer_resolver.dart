/// Deterministic resolution of one answer: correctness, the single gem
/// transaction and the mastery updates. Pure function of its inputs; the UI
/// only renders the result.
library;

import '../arbor/arbor.dart';
import '../arbor/diagnosis.dart';
import '../arbor/evidence.dart';
import '../economy/economy.dart';
import '../pedagogy/mastery.dart';
import '../pedagogy/frames/frame_question_source.dart';
import '../pedagogy/question.dart';
import '../pedagogy/trials.dart';
import '../persistence/save_data.dart';

class Resolution {
  const Resolution({
    required this.correct,
    required this.transaction,
    required this.gemsBefore,
    required this.gemsAfter,
    required this.skillsAfter,
    required this.lemmaDailyAfter,
    required this.tierBefore,
    required this.tiersAfter,
    required this.quality,
    required this.exposureAfter,
    required this.errataAfter,
    this.arborAfter = const ArborEvidence(),
    this.diagnosis = const Diagnosis(),
    this.credited = const {},
  });

  final bool correct;
  final Transaction transaction;
  final int gemsBefore;
  final int gemsAfter;
  final Map<String, SkillRecord> skillsAfter;
  final Map<String, int> lemmaDailyAfter;
  final MasteryTier tierBefore;
  final Map<String, MasteryTier> tiersAfter;
  final AnswerQuality quality;

  /// Vocabulary exposure after this answer (unchanged for isolated forms).
  final ExposureLedger exposureAfter;

  /// Error ledger after this answer: a miss recorded, or a fix counted.
  final ErrorLedger errataAfter;

  /// Évidence de l'arbre après cette réponse.
  final ArborEvidence arborAfter;

  /// Maillons mis en cause par une mauvaise réponse (vide si correcte).
  final Diagnosis diagnosis;

  /// Maillons prouvés par une bonne réponse.
  final Set<String> credited;

  int get delta => gemsAfter - gemsBefore;
}

class AnswerResolver {
  const AnswerResolver({this.economy = const Economy(kEconomy), this.mastery = const MasteryConfig(), this.arbor, this.diagnostician, this.lemmaCapacities = const {}});
  final Economy economy;
  final MasteryConfig mastery;
  final Arbor? arbor;
  final Diagnostician? diagnostician;
  final Map<String, int> lemmaCapacities;

  Resolution resolve({required SaveData save, required Question q, required String chosenValue, required AnswerQuality quality, required DateTime now, int battleSeed = 0}) {
    final correct = q.isCorrect(chosenValue);
    final primary = (save.skills[q.primarySkill] ?? const SkillRecord()).asOf(now, mastery);
    final tierBefore = primary.rewardTier(mastery);
    final dayKey = SkillRecord.dayKey(now);
    final satKey = '${q.primarySkill}|${q.lemmaId}|$dayKey';
    final satCount = save.lemmaDaily[satKey] ?? 0;
    final saturated = satCount >= economy.cfg.lemmaSaturation;

    final rawDelta = economy.rewardFor(tierBefore: tierBefore, correct: correct, quality: quality, lemmaSaturated: saturated);
    final gemsAfter = economy.applyToBalance(save.gems, rawDelta);
    final reason = economy.reasonFor(tierBefore: tierBefore, correct: correct, quality: quality, lemmaSaturated: saturated);
    final tx = Transaction(id: save.lastTransactionId + 1, delta: gemsAfter - save.gems, reason: reason, tierBefore: tierBefore, skillId: q.primarySkill, lemmaId: q.lemmaId, quality: quality);

    // Each observed skill is updated exactly once.
    final skills = Map<String, SkillRecord>.from(save.skills);
    final obs = Observation(at: now, correct: correct, lemmaId: q.lemmaId, quality: quality, trialId: q.trialId);
    final capacity = q.payload is FrameQuestionPayload ? (q.payload as FrameQuestionPayload).lemmaCapacity : null;
    for (final s in q.skillIds.toSet()) {
      skills[s] = (skills[s] ?? const SkillRecord()).apply(obs, mastery, availableLemmas: capacity);
    }
    final daily = Map<String, int>.from(save.lemmaDaily);
    if (correct && quality == AnswerQuality.autonoma) daily[satKey] = satCount + 1;
    // Keep the daily map small: drop other days.
    daily.removeWhere((k, _) => !k.endsWith('|$dayKey'));
    // Words met in a passage are exposure, never mastery: recorded apart.
    final exposure = q.exposure == null ? save.exposure : save.exposure.record(q.exposure!, autonomousCorrect: correct && quality == AnswerQuality.autonoma);
    // The missed form itself is remembered, with what it was taken for; an
    // autonomous correct answer on a missed form counts towards retiring it.
    var errata = save.errata;
    if (q.errata != null) {
      if (!correct) {
        final chosenLabel = q.choices.where((c) => c.value == chosenValue).map((c) => c.label).firstOrNull ?? chosenValue;
        errata = errata.miss(q.errata!, lemmaId: q.lemmaId, surface: q.surface, chosenLabel: chosenLabel, trialId: q.trialId, now: now, battleSeed: battleSeed);
      } else if (quality == AnswerQuality.autonoma) {
        errata = errata.fix(q.errata!.formKey);
      }
    }

    // L'arbre : diagnostic par différence de maillons, crédit de ce que la
    // question distinguait, hypothèses sur les prérequis d'un maillon raté.
    var arborAfter = save.arbor;
    var diagnosis = const Diagnosis();
    var credited = const <String>{};
    if (arbor != null && diagnostician != null) {
      diagnosis = correct ? const Diagnosis() : diagnostician!.diagnose(q, chosenValue);
      credited = correct ? diagnostician!.credited(q) : const {};
      arborAfter = save.arbor.observe(arbor: arbor!, diagnosis: diagnosis, credited: credited, correct: correct, quality: quality, lemmaId: q.lemmaId, trialId: q.trialId, now: now, place: Trials.maybe(q.trialId)?.activity.key, cfg: mastery, availableLemmas: capacity, lemmaCapacities: lemmaCapacities);
    }

    return Resolution(
      correct: correct,
      transaction: tx,
      gemsBefore: save.gems,
      gemsAfter: gemsAfter,
      skillsAfter: skills,
      lemmaDailyAfter: daily,
      tierBefore: tierBefore,
      tiersAfter: {for (final s in q.skillIds) s: skills[s]!.tier(mastery)},
      quality: quality,
      exposureAfter: exposure,
      errataAfter: errata,
      arborAfter: arborAfter,
      diagnosis: diagnosis,
      credited: credited,
    );
  }
}
