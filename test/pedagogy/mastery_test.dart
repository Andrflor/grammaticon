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
}
