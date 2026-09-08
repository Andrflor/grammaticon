import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/economy/economy.dart';
import 'package:grammaticon/pedagogy/mastery.dart';

void main() {
  const eco = Economy(kEconomy);
  test('reward table follows the configured scale', () {
    expect(eco.rewardFor(tierBefore: MasteryTier.nova, correct: true, quality: AnswerQuality.autonoma, lemmaSaturated: false), 8);
    expect(eco.rewardFor(tierBefore: MasteryTier.nova, correct: false, quality: AnswerQuality.autonoma, lemmaSaturated: false), -1);
    expect(eco.rewardFor(tierBefore: MasteryTier.discens, correct: true, quality: AnswerQuality.autonoma, lemmaSaturated: false), 5);
    expect(eco.rewardFor(tierBefore: MasteryTier.discens, correct: false, quality: AnswerQuality.autonoma, lemmaSaturated: false), -2);
    expect(eco.rewardFor(tierBefore: MasteryTier.familiaris, correct: true, quality: AnswerQuality.autonoma, lemmaSaturated: false), 2);
    expect(eco.rewardFor(tierBefore: MasteryTier.familiaris, correct: false, quality: AnswerQuality.autonoma, lemmaSaturated: false), -3);
    expect(eco.rewardFor(tierBefore: MasteryTier.perita, correct: true, quality: AnswerQuality.autonoma, lemmaSaturated: false), 0);
    expect(eco.rewardFor(tierBefore: MasteryTier.perita, correct: false, quality: AnswerQuality.autonoma, lemmaSaturated: false), -4);
  });
  test('aided and corrected answers are not rewarded like autonomous ones', () {
    expect(eco.rewardFor(tierBefore: MasteryTier.nova, correct: true, quality: AnswerQuality.adiuta, lemmaSaturated: false), 1);
    expect(eco.rewardFor(tierBefore: MasteryTier.nova, correct: false, quality: AnswerQuality.adiuta, lemmaSaturated: false), 0);
    expect(eco.rewardFor(tierBefore: MasteryTier.nova, correct: true, quality: AnswerQuality.correcta, lemmaSaturated: false), 0);
  });
  test('repeating one lemma stops paying', () {
    expect(eco.rewardFor(tierBefore: MasteryTier.nova, correct: true, quality: AnswerQuality.autonoma, lemmaSaturated: true), 0);
  });
  test('balance never goes below zero', () {
    expect(eco.applyToBalance(0, -4), 0);
    expect(eco.applyToBalance(3, -4), 0);
    expect(eco.applyToBalance(10, -4), 6);
  });
  test('victory bonus is bounded and doubles for catch-up', () {
    expect(eco.victoryBonus(catchUp: false), 6);
    expect(eco.victoryBonus(catchUp: true), 12);
  });
  test('defeat forfeits the fight gains plus a bounded tribute, never below zero', () {
    expect(eco.defeatPenalty(balance: 45, fightDelta: -5), 12); // ceil(45 * 0.25)
    expect(eco.defeatPenalty(balance: 60, fightDelta: 20), 30); // 20 + ceil(40 * 0.25)
    expect(eco.defeatPenalty(balance: 1000, fightDelta: 0), 40); // capped tribute
    expect(eco.defeatPenalty(balance: 0, fightDelta: 0), 0);
    expect(eco.defeatPenalty(balance: 3, fightDelta: 10), 3); // never below zero
  });
}
