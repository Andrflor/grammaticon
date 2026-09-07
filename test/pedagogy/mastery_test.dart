import 'package:flutter_test/flutter_test.dart';
import 'package:latin_game/pedagogy/mastery.dart';

Observation _o(bool c, {String lemma = 'amo', AnswerQuality q = AnswerQuality.autonoma, int day = 1}) =>
    Observation(at: DateTime(2026, 1, day, 10), correct: c, lemmaId: lemma, quality: q, trialId: 't');

void main() {
  const cfg = MasteryConfig();
  test('unpracticed skill is nova with no estimate', () {
    const r = SkillRecord();
    expect(r.tier(cfg), MasteryTier.nova);
    expect(r.estimate, isNull);
    expect(r.reliability(cfg), Reliability.nulla);
  });
  test('tier rises with sustained autonomous success across lemmas', () {
    var r = const SkillRecord();
    const lemmas = ['amo', 'moneo', 'rego', 'audio', 'capio'];
    for (var i = 0; i < 20; i++) {
      r = r.apply(_o(true, lemma: lemmas[i % 5], day: 1 + i ~/ 10), cfg);
    }
    expect(r.tier(cfg), MasteryTier.perita);
    expect(r.reliability(cfg), Reliability.firma);
    expect(r.autonomousCount, 20);
  });
  test('aided answers never raise the tier', () {
    var r = const SkillRecord();
    for (var i = 0; i < 20; i++) {
      r = r.apply(_o(true, q: AnswerQuality.adiuta), cfg);
    }
    expect(r.tier(cfg), MasteryTier.nova);
    expect(r.aidedCorrect, 20);
  });
  test('corrected answers count separately from first-attempt success', () {
    var r = const SkillRecord();
    r = r.apply(_o(false), cfg);
    r = r.apply(_o(true, q: AnswerQuality.correcta), cfg);
    expect(r.autonomousWrong, 1);
    expect(r.correctedCorrect, 1);
    expect(r.recentFirstTrySuccess, 0);
  });
  test('deliberate errors lower the estimate but the reward tier falls slowly', () {
    var r = const SkillRecord();
    const lemmas = ['amo', 'moneo', 'rego', 'audio', 'capio'];
    for (var i = 0; i < 20; i++) {
      r = r.apply(_o(true, lemma: lemmas[i % 5], day: 1 + i ~/ 10), cfg);
    }
    expect(r.rewardTier(cfg), MasteryTier.perita);
    for (var i = 0; i < 4; i++) {
      r = r.apply(_o(false, lemma: lemmas[i % 5], day: 3), cfg);
    }
    expect(r.tier(cfg).index, lessThan(MasteryTier.perita.index));
    expect(r.rewardTier(cfg), MasteryTier.perita);
  });
  test('review due depends on tier and time', () {
    var r = const SkillRecord();
    for (var i = 0; i < 6; i++) {
      r = r.apply(_o(true, lemma: 'l$i'), cfg);
    }
    expect(r.tier(cfg), MasteryTier.familiaris);
    expect(r.reviewDue(DateTime(2026, 1, 3), cfg), isFalse);
    expect(r.reviewDue(DateTime(2026, 1, 9), cfg), isTrue);
  });
  test('json round trip', () {
    var r = const SkillRecord();
    r = r.apply(_o(true), cfg);
    r = r.apply(_o(false, lemma: 'rego'), cfg);
    final back = SkillRecord.fromJson(r.toJson());
    expect(back.autonomousCorrect, 1);
    expect(back.autonomousWrong, 1);
    expect(back.estimate, r.estimate);
    expect(back.lemmas, {'amo', 'rego'});
    expect(back.recent.length, 2);
  });

  test('the estimate recedes with absence beyond the review delay of the tier, and the tier follows', () {
    var r = const SkillRecord();
    const lemmas = ['amo', 'moneo', 'rego', 'audio', 'capio'];
    for (var i = 0; i < 20; i++) {
      r = r.apply(_o(true, lemma: lemmas[i % 5], day: 1 + i ~/ 10), cfg);
    }
    expect(r.tier(cfg), MasteryTier.perita);
    final last = r.lastPractice!;
    // Within the 14-day delay of perīta: nothing moves.
    expect(r.asOf(last.add(const Duration(days: 14)), cfg).estimate, r.estimate);
    // One day late: two points lost, still green.
    final d15 = r.asOf(last.add(const Duration(days: 15)), cfg);
    expect(d15.estimate, closeTo(r.estimate! - cfg.decayPerDay, 1e-9));
    expect(d15.tier(cfg), MasteryTier.perita);
    // Long enough late: below 85 % it is familiāris, below 60 % discēns.
    final d24 = r.asOf(last.add(const Duration(days: 24)), cfg);
    expect(d24.estimate, lessThan(cfg.peritaThreshold));
    expect(d24.tier(cfg), MasteryTier.familiaris);
    final d40 = r.asOf(last.add(const Duration(days: 40)), cfg);
    expect(d40.estimate, lessThan(cfg.familiarisThreshold));
    expect(d40.tier(cfg), MasteryTier.discens);
    // Never below zero, never nova: the answers were given.
    final far = r.asOf(last.add(const Duration(days: 400)), cfg);
    expect(far.estimate, 0);
    expect(far.tier(cfg), MasteryTier.discens);
    // Nothing is stored: the raw record is untouched.
    expect(r.estimate, greaterThan(cfg.peritaThreshold));
  });

  test('the delay before receding depends on the tier: discēns after 2 days, familiāris after 5', () {
    var d = const SkillRecord().apply(_o(false), cfg); // estimate 0.2, discēns
    expect(d.tier(cfg), MasteryTier.discens);
    expect(d.asOf(DateTime(2026, 1, 3, 10), cfg).estimate, d.estimate);
    expect(d.asOf(DateTime(2026, 1, 4, 10), cfg).estimate, lessThan(d.estimate!));
    var f = const SkillRecord();
    for (var i = 0; i < 6; i++) {
      f = f.apply(_o(true, lemma: 'l$i'), cfg);
    }
    expect(f.tier(cfg), MasteryTier.familiaris);
    expect(f.asOf(DateTime(2026, 1, 6, 10), cfg).estimate, f.estimate);
    expect(f.asOf(DateTime(2026, 1, 7, 10), cfg).estimate, lessThan(f.estimate!));
  });

  test('after a long absence the next answer starts from the receded estimate', () {
    var r = const SkillRecord();
    const lemmas = ['amo', 'moneo', 'rego', 'audio', 'capio'];
    for (var i = 0; i < 20; i++) {
      r = r.apply(_o(true, lemma: lemmas[i % 5], day: 1 + i ~/ 10), cfg);
    }
    final before = r.estimate!;
    final back = r.apply(Observation(at: DateTime(2026, 3, 1, 10), correct: true, lemmaId: 'amo', quality: AnswerQuality.autonoma, trialId: 't'), cfg);
    // A single correct answer after two months does not restore the bar.
    expect(back.estimate, lessThan(before - 0.2));
    expect(back.tier(cfg), isNot(MasteryTier.perita));
    // Once practised again, the delay counts from the new date.
    expect(back.asOf(DateTime(2026, 3, 2, 10), cfg).estimate, back.estimate);
  });

}
