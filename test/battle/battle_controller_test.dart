import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latin_game/app/providers.dart';
import 'package:latin_game/battle/battle_controller.dart';
import 'package:latin_game/pedagogy/progression.dart';
import 'package:latin_game/pedagogy/trials.dart';
import 'package:latin_game/persistence/save_data.dart';
import 'package:latin_game/persistence/save_repository.dart';

import '../support/test_env.dart';

void main() {
  (ProviderContainer, MemorySaveStore) make({SaveData? initial}) => testContainer(initial: initial);

  test('a correct answer damages the enemy, pays gems once and saves', () async {
    final (c, store) = make();
    final ctrl = c.read(battleProvider.notifier);
    ctrl.start(Trials.byId('ind-praes-act'));
    ctrl.beginAfterIntro();
    var s = c.read(battleProvider)!;
    expect(s.phase, BattlePhase.question);
    final q = s.question!;
    final correctIndex = q.choices.indexWhere((ch) => q.correctValues.contains(ch.value));
    ctrl.answer(q.id, correctIndex);
    s = c.read(battleProvider)!;
    expect(s.phase, BattlePhase.correct);
    expect(s.enemyHp, s.enemyMaxHp - 1);
    expect(s.hearts, s.maxHearts);
    expect(s.last!.gemsDelta, 8);
    final save = c.read(profileProvider);
    expect(save.gems, 8);
    expect(save.lastTransactionId, 1);
    expect(save.skills['v.ind.praes.act']!.autonomousCorrect, 1);
    await Future<void>.delayed(Duration.zero);
    expect(store.raw, isNotNull);
    expect(store.raw, contains('"gems":8'));
    // Late / duplicate input on the same question is ignored.
    ctrl.answer(q.id, correctIndex);
    ctrl.answer(q.id, (correctIndex + 1) % q.choices.length);
    expect(c.read(profileProvider).gems, 8);
    expect(c.read(profileProvider).lastTransactionId, 1);
    expect(c.read(battleProvider)!.answered, 1);
    ctrl.proceed();
    s = c.read(battleProvider)!;
    expect(s.phase, BattlePhase.question);
    expect(s.question!.id, isNot(q.id));
    c.dispose();
  });

  test('a wrong answer costs a heart and a gem, never below zero', () async {
    final (c, _) = make();
    final ctrl = c.read(battleProvider.notifier);
    ctrl.start(Trials.byId('ind-praes-act'));
    ctrl.beginAfterIntro();
    final s0 = c.read(battleProvider)!;
    final q = s0.question!;
    final wrong = q.choices.indexWhere((ch) => !q.correctValues.contains(ch.value));
    ctrl.answer(q.id, wrong);
    final s = c.read(battleProvider)!;
    expect(s.phase, BattlePhase.wrong);
    expect(s.hearts, s.maxHearts - 1);
    expect(s.enemyHp, s.enemyMaxHp);
    expect(c.read(profileProvider).gems, 0);
    expect(s.last!.explanation.detail, contains('Rēctum'));
    c.dispose();
  });

  test('help before answering marks the answer as aided', () async {
    final (c, _) = make();
    final ctrl = c.read(battleProvider.notifier);
    ctrl.start(Trials.byId('ind-praes-act'));
    ctrl.beginAfterIntro();
    final q = c.read(battleProvider)!.question!;
    ctrl.markHelpUsed();
    final ok = q.choices.indexWhere((ch) => q.correctValues.contains(ch.value));
    ctrl.answer(q.id, ok);
    final save = c.read(profileProvider);
    expect(save.gems, 1);
    expect(save.skills['v.ind.praes.act']!.aidedCorrect, 1);
    expect(save.skills['v.ind.praes.act']!.autonomousCorrect, 0);
    c.dispose();
  });

  test('defeat after losing all hearts; retry keeps gems and purchases', () async {
    final (c, _) = make(
      initial: SaveData(gems: 50, purchased: {'ind-imperf-act'}, introSeen: {'ind-imperf-act'}),
    );
    final ctrl = c.read(battleProvider.notifier);
    final t = Trials.byId('ind-imperf-act');
    ctrl.start(t);
    for (var i = 0; i < t.hearts; i++) {
      final s = c.read(battleProvider)!;
      expect(s.phase, BattlePhase.question);
      final q = s.question!;
      final wrong = q.choices.indexWhere((ch) => !q.correctValues.contains(ch.value));
      ctrl.answer(q.id, wrong);
      ctrl.proceed();
    }
    var s = c.read(battleProvider)!;
    expect(s.phase, BattlePhase.defeat);
    final gemsAfter = c.read(profileProvider).gems;
    // −1 at tier nova, then −2 once the skill is discēns.
    expect(gemsAfter, 50 - 1 - 2 * (t.hearts - 1));
    // Defeat costs a bounded tribute (a quarter of the balance here), paid on retry/finish.
    expect(s.defeatPenalty, (gemsAfter * 0.25).ceil());
    ctrl.retry();
    expect(c.read(profileProvider).gems, gemsAfter - (gemsAfter * 0.25).ceil());
    expect(c.read(battleProvider)!.phase, BattlePhase.question);
    expect(c.read(profileProvider).purchased, contains('ind-imperf-act'));
    expect(c.read(profileProvider).battlesLost, 1);
    c.dispose();
  });

  test('victory pays a bounded bonus and clears the snapshot', () async {
    final (c, _) = make();
    final ctrl = c.read(battleProvider.notifier);
    final t = Trials.byId('ind-praes-act');
    ctrl.start(t);
    ctrl.beginAfterIntro();
    for (var i = 0; i < t.questionsToWin; i++) {
      final s = c.read(battleProvider)!;
      final q = s.question!;
      final ok = q.choices.indexWhere((ch) => q.correctValues.contains(ch.value));
      ctrl.answer(q.id, ok);
      ctrl.proceed();
    }
    final s = c.read(battleProvider)!;
    expect(s.phase, BattlePhase.victory);
    expect(s.victoryBonus, 6);
    final before = c.read(profileProvider).gems;
    await ctrl.finish();
    final save = c.read(profileProvider);
    expect(save.gems, before + 6);
    expect(save.activeBattle, isNull);
    expect(save.battlesWon, 1);
    expect(c.read(battleProvider), isNull);
    c.dispose();
  });

  test('snapshot is saved mid-fight and can be resumed', () async {
    final (c, store) = make();
    final ctrl = c.read(battleProvider.notifier);
    ctrl.start(Trials.byId('ind-praes-act'));
    ctrl.beginAfterIntro();
    final q = c.read(battleProvider)!.question!;
    ctrl.answer(q.id, q.choices.indexWhere((ch) => q.correctValues.contains(ch.value)));
    await Future<void>.delayed(Duration.zero);
    final saved = await SaveRepository(store).load();
    expect(saved.activeBattle, isNotNull);
    expect(saved.activeBattle!.enemyHp, 9);
    expect(saved.activeBattle!.answered, 1);
    // Resume in a fresh container.
    final (c2, _) = make(initial: saved);
    final ctrl2 = c2.read(battleProvider.notifier);
    ctrl2.start(Trials.byId(saved.activeBattle!.trialId), resume: saved.activeBattle);
    final s2 = c2.read(battleProvider)!;
    expect(s2.enemyHp, 9);
    expect(s2.answered, 1);
    expect(s2.question, isNotNull);
    expect(s2.resumed, isTrue);
    c.dispose();
    c2.dispose();
  });

  test('purchase deducts once, requires prerequisites and explicit action', () async {
    final (c, _) = make(initial: SaveData(gems: 100));
    final p = c.read(profileProvider.notifier);
    final imperf = Trials.byId('ind-imperf-act');
    final fut = Trials.byId('ind-fut-act');
    expect(Progression.status(c.read(profileProvider), fut).access, TrialAccess.locked);
    expect(await p.purchase(fut), isFalse);
    expect(await p.purchase(imperf), isTrue);
    expect(c.read(profileProvider).gems, 80);
    expect(await p.purchase(imperf), isFalse); // never twice
    expect(c.read(profileProvider).gems, 80);
    expect(Progression.status(c.read(profileProvider), fut).access, TrialAccess.purchasable);
    expect(await p.purchase(fut), isTrue);
    expect(c.read(profileProvider).gems, 55);
    c.dispose();
  });

  test('no economic dead end: mastered skills still allow winning gems', () {
    // With every skill mastered, a correct answer pays 0 but victory pays a
    // bonus; the cheapest purchasable trial is always reachable by winning.
    final save = SaveData(gems: 0);
    final cheapest = Progression.cheapestPurchasable(save)!;
    expect(cheapest, lessThanOrEqualTo(6 * 10));
  });
}
