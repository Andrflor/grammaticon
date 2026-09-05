import '../pedagogy/mastery.dart';

/// Reward and penalty parameters. Centralised so they can be tuned by trial.
class EconomyConfig {
  const EconomyConfig({
    this.gains = const {MasteryTier.nova: 8, MasteryTier.discens: 5, MasteryTier.familiaris: 2, MasteryTier.perita: 0},
    this.losses = const {MasteryTier.nova: 1, MasteryTier.discens: 2, MasteryTier.familiaris: 3, MasteryTier.perita: 4},
    this.aidedGain = 1,
    this.aidedLoss = 0,
    this.lemmaSaturation = 3,
    this.victoryBonus = 6,
    this.catchUpMultiplier = 2,
    this.minBalance = 0,
    this.startingGems = 0,
    this.defeatLosesFightGains = true,
    this.defeatTributeRatio = 0.25,
    this.defeatTributeMax = 40,
  });

  final Map<MasteryTier, int> gains;
  final Map<MasteryTier, int> losses;

  /// Gems for a correct answer given after consulting help.
  final int aidedGain;
  final int aidedLoss;

  /// Correct answers on the same lemma in the same skill on the same day
  /// beyond this count earn nothing.
  final int lemmaSaturation;

  /// Bounded reward for winning a fight, paid even when every skill is mastered
  /// so the player can still reach the next tier.
  final int victoryBonus;

  /// Multiplier applied to [victoryBonus] when the player cannot afford any
  /// purchasable trial and no accessible skill yields gems any more.
  final int catchUpMultiplier;
  final int minBalance;
  final int startingGems;

  /// On defeat the gems won during the fight are forfeited…
  final bool defeatLosesFightGains;

  /// …and a tribute of this share of the remaining balance is paid,
  final double defeatTributeRatio;

  /// capped so that a long history of work is never wiped out.
  final int defeatTributeMax;
}

const kEconomy = EconomyConfig();

/// One resolved gem movement. Exactly one per answer.
class Transaction {
  const Transaction({required this.id, required this.delta, required this.reason, required this.tierBefore, required this.skillId, required this.lemmaId, required this.quality});
  final int id;
  final int delta;
  final String reason;
  final MasteryTier tierBefore;
  final String skillId;
  final String lemmaId;
  final AnswerQuality quality;

  Map<String, Object?> toJson() => {'id': id, 'd': delta, 'r': reason, 'tier': tierBefore.key, 's': skillId, 'l': lemmaId, 'q': quality.key};
}

class Economy {
  const Economy(this.cfg);
  final EconomyConfig cfg;

  /// Gem delta for one answer. Computed from the tier *before* the answer.
  int rewardFor({required MasteryTier tierBefore, required bool correct, required AnswerQuality quality, required bool lemmaSaturated}) {
    switch (quality) {
      case AnswerQuality.correcta:
        return 0;
      case AnswerQuality.adiuta:
        return correct ? cfg.aidedGain : -cfg.aidedLoss;
      case AnswerQuality.autonoma:
        if (correct) return lemmaSaturated ? 0 : cfg.gains[tierBefore]!;
        return -cfg.losses[tierBefore]!;
    }
  }

  String reasonFor({required MasteryTier tierBefore, required bool correct, required AnswerQuality quality, required bool lemmaSaturated}) {
    if (quality == AnswerQuality.correcta) return 'post corrēctiōnem: nūllum praemium';
    if (quality == AnswerQuality.adiuta) return correct ? 'auxiliō adhibitō' : 'auxiliō adhibitō: nūlla poena';
    if (correct && lemmaSaturated) return 'idem verbum saepius repetītum';
    return 'perītia ${tierBefore.latin.toLowerCase()}';
  }

  int applyToBalance(int balance, int delta) {
    final b = balance + delta;
    return b < cfg.minBalance ? cfg.minBalance : b;
  }

  int victoryBonus({required bool catchUp}) => catchUp ? cfg.victoryBonus * cfg.catchUpMultiplier : cfg.victoryBonus;

  /// Gems lost on defeat: the fight's net gains (if positive) plus a bounded
  /// tribute on what remains. Never takes the balance below [EconomyConfig.minBalance].
  int defeatPenalty({required int balance, required int fightDelta}) {
    var penalty = cfg.defeatLosesFightGains && fightDelta > 0 ? fightDelta : 0;
    final remaining = balance - penalty;
    final tribute = (remaining * cfg.defeatTributeRatio).ceil().clamp(0, cfg.defeatTributeMax);
    penalty += tribute;
    if (balance - penalty < cfg.minBalance) penalty = balance - cfg.minBalance;
    return penalty < 0 ? 0 : penalty;
  }

  /// Human-readable rule for the intro and cards.
  String defeatRule() => 'Clādēs: gemmae certāminis āmittuntur et quārta pars summae (ad ${cfg.defeatTributeMax}) tribūtum solvitur.';
}
