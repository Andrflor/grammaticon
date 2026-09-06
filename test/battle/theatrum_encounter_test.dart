// The shared encounter engine driving a Theatrum performance: same transitions,
// wallet, mastery rules and persistence as the arena and the Forum; reading
// questions; vocabulary exposure recorded apart from mastery.
import 'package:flutter_test/flutter_test.dart';
import 'package:latin_game/app/providers.dart';
import 'package:latin_game/battle/battle_controller.dart';
import 'package:latin_game/pedagogy/exposure.dart';
import 'package:latin_game/pedagogy/mastery.dart';
import 'package:latin_game/pedagogy/progression.dart';
import 'package:latin_game/pedagogy/question.dart';
import 'package:latin_game/pedagogy/reading/reading_question_source.dart';
import 'package:latin_game/pedagogy/trials.dart';
import 'package:latin_game/persistence/save_data.dart';
import 'package:latin_game/persistence/save_repository.dart';

import '../support/test_env.dart';

void main() {
  int correctIndex(Question q) => q.choices.indexWhere((c) => q.correctValues.contains(c.value));
  int wrongIndex(Question q) => q.choices.indexWhere((c) => !q.correctValues.contains(c.value));

  test('a delivered line lowers the audience\'s favour for the opponent, pays gems once, credits the reading skill and records exposure', () async {
    final (c, store) = testContainer();
    final ctrl = c.read(battleProvider.notifier);
    final t = Trials.byId('th-numerus');
    expect(t.activity, Activity.theatrum);
    ctrl.start(t, BattleMode.certamen);
    expect(c.read(battleProvider)!.phase, BattlePhase.intro);
    ctrl.beginAfterIntro();
    var s = c.read(battleProvider)!;
    final q = s.question!;
    expect(q.payload, isA<ReadingQuestionPayload>());
    expect(q.choices.length, 4);
    expect(q.context.single, isNotEmpty); // Latin reference line
    ctrl.answer(q.id, correctIndex(q));
    s = c.read(battleProvider)!;
    expect(s.phase, BattlePhase.correct);
    expect(s.enemyHp, s.enemyMaxHp - 1);
    expect(s.last!.gemsDelta, 8);
    final save = c.read(profileProvider);
    expect(save.gems, 8);
    expect(save.lastTransactionId, 1);
    expect(save.skills['l.numerus']!.autonomousCorrect, 1);
    expect(save.skills.keys.where((k) => k.startsWith('v.') || k.startsWith('d.')), isEmpty, reason: 'reading never credits form-recognition mastery');
    // Exposure: every lemma of the passage met once, the target tested once.
    for (final l in q.exposure!.lemmas) {
      expect(save.exposure.of(l).seen, greaterThanOrEqualTo(1));
    }
    expect(save.exposure.of(q.lemmaId).tested, 1);
    expect(save.exposure.of(q.lemmaId).testedCorrect, 1);
    expect(save.exposure.seenCount(q.exposure!.itemId), 1);
    // Duplicate and late input is ignored: one answer, one transaction, one exposure.
    ctrl.answer(q.id, correctIndex(q));
    ctrl.answer(q.id, wrongIndex(q));
    expect(c.read(profileProvider).gems, 8);
    expect(c.read(profileProvider).lastTransactionId, 1);
    expect(c.read(profileProvider).exposure.seenCount(q.exposure!.itemId), 1);
    expect(c.read(battleProvider)!.answered, 1);
    await Future<void>.delayed(Duration.zero);
    expect(store.raw, contains('"gems":8'));
    expect(store.raw, contains('"expo"'));
    expect(store.raw, contains('"th-numerus"'));
    c.dispose();
  });

  test('a rebuttal costs a heart, applies the existing penalty and shows the morphological correction', () {
    final (c, _) = testContainer(initial: SaveData(gems: 10, introSeen: {'th-numerus'}));
    final ctrl = c.read(battleProvider.notifier);
    ctrl.start(Trials.byId('th-numerus'), BattleMode.certamen);
    final q = c.read(battleProvider)!.question!;
    final wrong = wrongIndex(q);
    ctrl.answer(q.id, wrong);
    final s = c.read(battleProvider)!;
    expect(s.phase, BattlePhase.wrong);
    expect(s.hearts, s.maxHearts - 1);
    expect(s.enemyHp, s.enemyMaxHp);
    expect(s.last!.gemsDelta, -1);
    final d = q.reading.distractor(q.choices[wrong].value)!;
    expect(s.last!.explanation.detail, contains('Rēctum'));
    expect(s.last!.explanation.detail, contains(d.span));
    expect(s.last!.explanation.detail, contains(d.shift));
    // The word was met but the wrong answer is not counted as a correct test.
    final save = c.read(profileProvider);
    expect(save.exposure.of(q.lemmaId).tested, 1);
    expect(save.exposure.of(q.lemmaId).testedCorrect, 0);
    expect(save.skills['l.numerus']!.autonomousWrong, 1);
    c.dispose();
  });

  test('help before answering marks the answer as aided: reduced reward, no penalty, mastery unchanged in tier', () {
    final (c, _) = testContainer(initial: SaveData(introSeen: {'th-numerus'}));
    final ctrl = c.read(battleProvider.notifier);
    ctrl.start(Trials.byId('th-numerus'), BattleMode.certamen);
    final q = c.read(battleProvider)!.question!;
    ctrl.markHelpUsed();
    ctrl.answer(q.id, correctIndex(q));
    final save = c.read(profileProvider);
    expect(save.gems, 1);
    expect(save.skills['l.numerus']!.aidedCorrect, 1);
    expect(save.skills['l.numerus']!.autonomousCount, 0);
    c.dispose();
  });

  test('the three activities share one wallet and keep distinct tallies', () async {
    final (c, _) = testContainer(initial: SaveData(gems: 10, introSeen: {'ind-praes-act', 'd1-recti', 'th-numerus'}));
    final ctrl = c.read(battleProvider.notifier);
    ctrl.start(Trials.byId('ind-praes-act'), BattleMode.certamen);
    var q = c.read(battleProvider)!.question!;
    ctrl.answer(q.id, correctIndex(q));
    ctrl.abandon();
    ctrl.start(Trials.byId('d1-recti'), BattleMode.certamen);
    q = c.read(battleProvider)!.question!;
    ctrl.answer(q.id, correctIndex(q));
    ctrl.abandon();
    ctrl.start(Trials.byId('th-numerus'), BattleMode.certamen);
    q = c.read(battleProvider)!.question!;
    ctrl.answer(q.id, correctIndex(q));
    expect(c.read(profileProvider).gems, 34);
    expect(c.read(profileProvider).lastTransactionId, 3);
    for (var i = 0; i < 9; i++) {
      ctrl.proceed();
      final s = c.read(battleProvider)!;
      ctrl.answer(s.question!.id, correctIndex(s.question!));
    }
    ctrl.proceed();
    expect(c.read(battleProvider)!.phase, BattlePhase.victory);
    await ctrl.finish();
    final after = c.read(profileProvider);
    expect(after.activityStats['theatrum']?.won, 1);
    expect(after.activityStats['forum']?.won ?? 0, 0);
    expect(after.activityStats['amphitheatrum']?.won ?? 0, 0);
    c.dispose();
  });

  test('Theatrum purchases are permanent and gated by Theatrum prerequisites only; the first trial is free', () async {
    final (c, _) = testContainer(initial: SaveData(gems: 100));
    final p = c.read(profileProvider.notifier);
    final first = Trials.byId('th-numerus');
    final persona = Trials.byId('th-persona');
    final subj = Trials.byId('th-modus-subiunctivus');
    expect(Progression.status(c.read(profileProvider), first).access, TrialAccess.accessible);
    expect(Progression.status(c.read(profileProvider), persona).access, TrialAccess.purchasable);
    expect(Progression.status(c.read(profileProvider), subj).access, TrialAccess.locked);
    expect(await p.purchase(subj), isFalse);
    expect(await p.purchase(persona), isTrue);
    expect(c.read(profileProvider).gems, 85);
    expect(await p.purchase(persona), isFalse);
    for (final t in Trials.ofActivity(Activity.theatrum)) {
      for (final pre in t.prerequisites) {
        expect(Trials.byId(pre).activity, Activity.theatrum, reason: 'no cross-activity purchase requirement (${t.id})');
      }
    }
    c.dispose();
  });

  test('a performance is snapshotted mid-way and resumes into the same Theatrum trial and question', () async {
    final (c, store) = testContainer(initial: SaveData(introSeen: {'th-numerus'}));
    final ctrl = c.read(battleProvider.notifier);
    ctrl.start(Trials.byId('th-numerus'), BattleMode.certamen);
    final q = c.read(battleProvider)!.question!;
    ctrl.answer(q.id, correctIndex(q));
    ctrl.proceed();
    final q2 = c.read(battleProvider)!.question!;
    await Future<void>.delayed(Duration.zero);
    final saved = await SaveRepository(store).load();
    expect(saved.activeBattle!.trialId, 'th-numerus');
    final (c2, _) = testContainer(initial: saved);
    final ctrl2 = c2.read(battleProvider.notifier);
    ctrl2.start(Trials.byId(saved.activeBattle!.trialId), saved.activeBattle!.mode, resume: saved.activeBattle);
    final s2 = c2.read(battleProvider)!;
    expect(s2.enemyHp, 9);
    expect(s2.question!.surface, q2.surface, reason: 'deterministic seed: the same passage comes back');
    c.dispose();
    c2.dispose();
  });

  test('mixed trials draw only from the selected components and credit the mixed skill first', () {
    final t = Trials.byId('th-mx-verbum');
    final (c, _) = testContainer(initial: SaveData(gems: 0, purchased: {t.id}, introSeen: {t.id}, mixtaConfig: {t.id: ['numerus', 'tempus']}));
    final ctrl = c.read(battleProvider.notifier);
    ctrl.start(t, BattleMode.exercitatio);
    for (var i = 0; i < 9; i++) {
      final s = c.read(battleProvider)!;
      final q = s.question!;
      expect(['numerus', 'tempus'], contains(q.componentId));
      expect(['th-numerus', 'th-tempus-praeteritum', 'th-tempus-futurum'], contains(q.reading.entry.item.trialId));
      expect(q.primarySkill, 'l.mx.verbum');
      ctrl.answer(q.id, correctIndex(q));
      expect(c.read(profileProvider).gems, 0, reason: 'training pays nothing');
      ctrl.proceed();
    }
    c.dispose();
  });

  test('with English selected the Theatrum produces no question and never falls back to French', () {
    final (c, _) = testContainer(initial: SaveData(introSeen: {'th-numerus'}, settings: const Settings(translationLanguage: TranslationLanguage.anglice)));
    final src = c.read(readingQuestionSourceProvider);
    expect(src.language, 'en');
    expect(src.available, isFalse);
    final ctrl = c.read(battleProvider.notifier);
    ctrl.start(Trials.byId('th-numerus'), BattleMode.certamen);
    expect(c.read(battleProvider)!.question, isNull);
    c.dispose();
  });

  test('exposure records survive a save round trip and a schema-2 save migrates to 3 without losing anything', () async {
    final repo = SaveRepository(MemorySaveStore());
    final d = SaveData(
      gems: 9,
      purchased: const {'ind-imperf-act', 'd1-omnes', 'th-persona'},
      skills: {'l.numerus': const SkillRecord().apply(Observation(at: DateTime(2026, 9, 6), correct: true, lemmaId: 'video', quality: AnswerQuality.autonoma, trialId: 'th-numerus'), const MasteryConfig())},
      exposure: const ExposureLedger(lemmas: {'video': LemmaExposure(seen: 2, passages: ['MAT.5.8', 'JOH.9.25'], tested: 1, testedCorrect: 1)}, items: {'th-numerus|MAT 5:8|videbunt': 1}),
      settings: const Settings(translationLanguage: TranslationLanguage.gallice),
    );
    await repo.save(d);
    final back = await repo.load();
    expect(back.exposure.of('video').seen, 2);
    expect(back.exposure.of('video').revisited, isTrue);
    expect(back.exposure.of('video').tested, 1);
    expect(back.exposure.seenCount('th-numerus|MAT 5:8|videbunt'), 1);
    expect(back.settings.translationLanguage, TranslationLanguage.gallice);
    expect(back.purchased, contains('th-persona'));
    expect(back.schemaVersion, 3);

    const codec = SaveCodec();
    const v2 = '{"schema":2,"gems":37,"purchased":["ind-imperf-act","d1-omnes"],'
        '"skills":{"d.1.acc.sg":{"ac":3,"aw":1,"aidc":0,"aidw":0,"corc":0,"est":0.7,"hw":0.7,"recent":[],"lemmas":["rosa"],"days":["20260102"],"last":1767312000000}},'
        '"settings":{"vol":0.5,"snd":true,"rm":false,"cd":350,"wd":2800,"mus":true,"mvol":0.5},"mixta":{},"won":4,"lost":2,"tx":21,'
        '"battle":{"t":"d1-recti","m":"certamen","h":2,"e":6,"a":5,"g":12,"s":77,"q":5,"c":[],"ok":4},'
        '"lemmaDaily":{},"introSeen":["ind-praes-act"],"activities":{"amphitheatrum":{"w":3,"l":2},"forum":{"w":1,"l":0},"thermae":{"w":0,"l":0}}}';
    final m = codec.decode(v2);
    expect(m.schemaVersion, 3);
    expect(m.gems, 37);
    expect(m.purchased, {'ind-imperf-act', 'd1-omnes'});
    expect(m.skills['d.1.acc.sg']!.autonomousCorrect, 3);
    expect(m.activeBattle!.trialId, 'd1-recti');
    expect(m.activityStats['amphitheatrum']!.won, 3);
    expect(m.activityStats['forum']!.won, 1);
    expect(m.activityStats.containsKey('thermae'), isFalse, reason: 'the Thermae identifier is migrated, not kept');
    expect(m.activityStats['theatrum']!.won, 0);
    expect(m.exposure.lemmas, isEmpty);
    expect(m.settings.translationLanguage, TranslationLanguage.gallice, reason: 'French is the default; English is not selectable');
  });
}
