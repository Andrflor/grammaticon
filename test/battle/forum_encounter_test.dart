import 'dart:math';

// The shared encounter engine driving a Forum debate: same transitions,
// wallet and persistence as the Amphitheatrum, noun questions and corrections.
import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/app/providers.dart';
import 'package:grammaticon/battle/battle_controller.dart';

import 'package:grammaticon/pedagogy/mastery.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/progression.dart';
import 'package:grammaticon/pedagogy/question.dart';
import 'package:grammaticon/pedagogy/trials.dart';
import 'package:grammaticon/persistence/save_data.dart';
import 'package:grammaticon/persistence/save_repository.dart';

import '../support/test_env.dart';

void main() {
  int correctIndex(Question q) => q.choices.indexWhere((c) => q.correctValues.contains(c.value));
  int wrongIndex(Question q) => q.choices.indexWhere((c) => !q.correctValues.contains(c.value));

  test('a correct argument lowers the opponent\'s resolve, pays gems once, credits the cell and saves', () async {
    final (c, store) = testContainer();
    final ctrl = c.read(battleProvider.notifier);
    final t = Trials.byId('dec-1');
    expect(t.activity, Activity.forum);
    ctrl.start(t);
    expect(c.read(battleProvider)!.phase, BattlePhase.intro);
    ctrl.beginAfterIntro();
    var s = c.read(battleProvider)!;
    final q = s.question!;
    expect(q.payload, isA<ForumQuestionPayload>());
    // The introductory card shows the dictionary entry, except on the
    // questions it would answer (the gender is written in the entry itself).
    if (q.dimension == Dimension.casus || q.dimension == Dimension.numerus) {
      expect(q.context, [q.forum.lexeme.dictionaryEntry]);
    }
    ctrl.answer(q.id, correctIndex(q));
    s = c.read(battleProvider)!;
    expect(s.phase, BattlePhase.correct);
    expect(s.enemyHp, s.enemyMaxHp - 1);
    expect(s.last!.gemsDelta, 8);
    final save = c.read(profileProvider);
    expect(save.gems, 8);
    expect(save.lastTransactionId, 1);
    expect(save.skills[q.primarySkill]!.autonomousCorrect, 1);
    expect(q.primarySkill, 'f.dec.1');
    expect(q.skillIds.last, startsWith('d.1.'), reason: 'the paradigm cell is credited too');
    expect(save.skills[q.skillIds.last]!.autonomousCorrect, 1);
    // Duplicate and late input is ignored: one answer, one transaction.
    ctrl.answer(q.id, correctIndex(q));
    ctrl.answer(q.id, wrongIndex(q));
    expect(c.read(profileProvider).gems, 8);
    expect(c.read(profileProvider).lastTransactionId, 1);
    expect(c.read(battleProvider)!.answered, 1);
    await Future<void>.delayed(Duration.zero);
    expect(store.raw, contains('"gems":8'));
    expect(store.raw, contains('"dec-1"'));
    c.dispose();
  });

  test('a rebuttal costs a heart and shows a noun correction with the ending', () {
    final (c, _) = testContainer(initial: SaveData(introSeen: {'dec-1'}));
    final ctrl = c.read(battleProvider.notifier);
    ctrl.start(Trials.byId('dec-1'));
    final q = c.read(battleProvider)!.question!;
    ctrl.answer(q.id, wrongIndex(q));
    final s = c.read(battleProvider)!;
    expect(s.phase, BattlePhase.wrong);
    expect(s.hearts, s.maxHearts - 1);
    expect(s.enemyHp, s.enemyMaxHp);
    expect(s.last!.explanation.detail, contains('Rēctum'));
    expect(s.last!.explanation.headline, contains(q.forum.lexeme.dictionaryEntry));
    c.dispose();
  });

  test('an ambiguous form accepts every valid offered analysis through the shared resolver', () {
    // A case question on "rosae" (gen./dat. sg., nom./voc. pl.) built the way
    // the generator builds it: every analysis in the lexicon is correct.
    final forms = testNominalAnalyzer.analyze('rosae');
    final correct = forms.map((f) => f.analysis.casus!.key).toSet();
    expect(correct, {'gen', 'dat', 'nom', 'voc'});
    final q = Question(
      id: 'q',
      trialId: 'dec-1',
      dimension: Dimension.casus,
      prompt: Dimension.casus.prompt,
      surface: 'rosae',
      lemmaId: 'rosa',
      choices: const [Choice('nom', 'Nōminātīvus'), Choice('acc', 'Accūsātīvus'), Choice('gen', 'Genetīvus'), Choice('dat', 'Datīvus')],
      correctValues: correct,
      skillIds: const ['d.1.gen.sg'],
      payload: ForumQuestionPayload(target: forms.first, analyses: forms, lexeme: testNominalAnalyzer.lexeme('rosa')),
      ambiguous: true,
    );
    final (c, _) = testContainer();
    final resolver = c.read(answerResolverProvider);
    final save = c.read(profileProvider);
    for (final v in ['nom', 'gen', 'dat']) {
      final r = resolver.resolve(save: save, q: q, chosenValue: v, quality: AnswerQuality.autonoma, now: DateTime(2026, 3, 1));
      expect(r.correct, isTrue, reason: v);
      expect(r.delta, 8, reason: v);
    }
    final wrong = resolver.resolve(save: save, q: q, chosenValue: 'acc', quality: AnswerQuality.autonoma, now: DateTime(2026, 3, 1));
    expect(wrong.correct, isFalse);
    // The generator itself never draws rosae as a case question when it has a
    // less ambiguous form available, and never offers only correct choices.
    final gen = ForumQuestionSource(testNominalAnalyzer, kSyntagmata);
    for (var seed = 0; seed < 300; seed++) {
      final g = gen.generate(trial: Trials.byId('dec-1'), componentIds: const [], rng: Random(seed), id: '$seed')!;
      expect(g.choices.any((ch) => !g.correctValues.contains(ch.value)), isTrue, reason: g.surface);
    }
    c.dispose();
  });

  test('the Amphitheatrum and the Forum share one gem balance and distinct tallies', () async {
    final (c, _) = testContainer(initial: SaveData(gems: 10, introSeen: {'ind-praes-act', 'dec-1'}));
    final ctrl = c.read(battleProvider.notifier);
    // One correct verb answer…
    ctrl.start(Trials.byId('ind-praes-act'));
    var q = c.read(battleProvider)!.question!;
    ctrl.answer(q.id, correctIndex(q));
    expect(c.read(profileProvider).gems, 18);
    ctrl.abandon();
    // …then a Forum debate spends from and earns into the same wallet.
    ctrl.start(Trials.byId('dec-1'));
    q = c.read(battleProvider)!.question!;
    ctrl.answer(q.id, correctIndex(q));
    final save = c.read(profileProvider);
    expect(save.gems, 26);
    expect(save.lastTransactionId, 2);
    expect(save.skills.keys.where((k) => k.startsWith('v.')), isNotEmpty);
    expect(save.skills.keys.where((k) => k.startsWith('d.')), isNotEmpty);
    // Win the debate: the Forum tally moves, the Amphitheatrum tally does not.
    for (var i = 0; i < 9; i++) {
      ctrl.proceed();
      final s = c.read(battleProvider)!;
      ctrl.answer(s.question!.id, correctIndex(s.question!));
    }
    ctrl.proceed();
    expect(c.read(battleProvider)!.phase, BattlePhase.victory);
    await ctrl.finish();
    final after = c.read(profileProvider);
    expect(after.activityStats['forum']?.won, 1);
    expect(after.activityStats['amphitheatrum']?.won ?? 0, 0);
    expect(after.battlesWon, 1);
    c.dispose();
  });

  test('Forum purchases are permanent and gated by Forum prerequisites; the free trial is open', () async {
    final (c, _) = testContainer(initial: SaveData(gems: 100));
    final p = c.read(profileProvider.notifier);
    final d1 = Trials.byId('dec-1');
    final d2mf = Trials.byId('dec-2-mf');
    final d2n = Trials.byId('dec-2-n');
    expect(Progression.status(c.read(profileProvider), d1).access, TrialAccess.accessible);
    expect(Progression.status(c.read(profileProvider), Trials.byId('pron-ego-tu')).access, TrialAccess.accessible, reason: 'the second free door');
    expect(Progression.status(c.read(profileProvider), d2n).access, TrialAccess.locked);
    expect(await p.purchase(d2n), isFalse);
    expect(await p.purchase(d2mf), isTrue);
    expect(c.read(profileProvider).gems, 85);
    expect(await p.purchase(d2mf), isFalse);
    expect(Progression.status(c.read(profileProvider), d2n).access, TrialAccess.purchasable);
    expect(await p.purchase(d2n), isTrue);
    expect(c.read(profileProvider).gems, 65);
    c.dispose();
  });

  test('a Forum debate is snapshotted and resumes into the Forum trial', () async {
    final (c, store) = testContainer(initial: SaveData(introSeen: {'dec-2-n'}, purchased: {'dec-2-n'}));
    final ctrl = c.read(battleProvider.notifier);
    ctrl.start(Trials.byId('dec-2-n'));
    final q = c.read(battleProvider)!.question!;
    ctrl.answer(q.id, correctIndex(q));
    await Future<void>.delayed(Duration.zero);
    final saved = await SaveRepository(store).load();
    expect(saved.activeBattle!.trialId, 'dec-2-n');
    final (c2, _) = testContainer(initial: saved);
    final ctrl2 = c2.read(battleProvider.notifier);
    final t = Trials.byId(saved.activeBattle!.trialId);
    expect(t.activity, Activity.forum);
    ctrl2.start(t, resume: saved.activeBattle);
    final s2 = c2.read(battleProvider)!;
    expect(s2.enemyHp, 9);
    expect(s2.question!.payload, isA<ForumQuestionPayload>());
    c.dispose();
    c2.dispose();
  });
}
