/// Deterministic resolution of one answer: correctness, the single gem
/// transaction and the mastery updates. Pure function of its inputs; the UI
/// only renders the result.
library;

import '../economy/economy.dart';
import '../pedagogy/mastery.dart';
import '../pedagogy/question_generator.dart';
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

  int get delta => gemsAfter - gemsBefore;
}

class AnswerResolver {
  const AnswerResolver({this.economy = const Economy(kEconomy), this.mastery = const MasteryConfig()});
  final Economy economy;
  final MasteryConfig mastery;

  Resolution resolve({
    required SaveData save,
    required Question q,
    required String chosenValue,
    required AnswerQuality quality,
    required BattleMode mode,
    required DateTime now,
  }) {
    final correct = q.isCorrect(chosenValue);
    final primary = save.skills[q.primarySkill] ?? const SkillRecord();
    final tierBefore = primary.rewardTier(mastery);
    final dayKey = SkillRecord.dayKey(now);
    final satKey = '${q.primarySkill}|${q.lemmaId}|$dayKey';
    final satCount = save.lemmaDaily[satKey] ?? 0;
    final saturated = satCount >= economy.cfg.lemmaSaturation;

    final rawDelta = mode == BattleMode.exercitatio
        ? 0
        : economy.rewardFor(tierBefore: tierBefore, correct: correct, quality: quality, lemmaSaturated: saturated);
    final gemsAfter = economy.applyToBalance(save.gems, rawDelta);
    final reason = mode == BattleMode.exercitatio
        ? 'exercitātiō: sine gemmīs'
        : economy.reasonFor(tierBefore: tierBefore, correct: correct, quality: quality, lemmaSaturated: saturated);
    final tx = Transaction(
      id: save.lastTransactionId + 1,
      delta: gemsAfter - save.gems,
      reason: reason,
      tierBefore: tierBefore,
      skillId: q.primarySkill,
      lemmaId: q.lemmaId,
      quality: quality,
    );

    // Each observed skill is updated exactly once.
    final skills = Map<String, SkillRecord>.from(save.skills);
    final obs = Observation(at: now, correct: correct, lemmaId: q.lemmaId, quality: quality, trialId: q.trialId);
    for (final s in q.skillIds.toSet()) {
      skills[s] = (skills[s] ?? const SkillRecord()).apply(obs, mastery);
    }
    final daily = Map<String, int>.from(save.lemmaDaily);
    if (correct && quality == AnswerQuality.autonoma) daily[satKey] = satCount + 1;
    // Keep the daily map small: drop other days.
    daily.removeWhere((k, _) => !k.endsWith('|$dayKey'));

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
    );
  }
}
