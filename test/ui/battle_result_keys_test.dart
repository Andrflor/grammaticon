// On the result screen, Space/Enter presses "Iterum" and Escape returns to
// the activity.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/app/theme.dart';
import 'package:grammaticon/battle/battle_controller.dart';
import 'package:grammaticon/pedagogy/trials.dart';
import 'package:grammaticon/persistence/save_data.dart';
import 'package:grammaticon/persistence/save_repository.dart';
import 'package:grammaticon/ui/battle/battle_screen.dart';

import '../support/test_env.dart';

void main() {
  const trialId = 'ind-praes-act';

  testWidgets('result screen: Enter retries, Escape leaves', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // One heart left: a single wrong answer ends the fight.
    final resume = ActiveBattle(trialId: trialId, hearts: 1, enemyHp: 10, answered: 0, gemsDelta: 0, seed: 20260907, questionIndex: 0, componentIds: const [], correctCount: 0);
    await tester.pumpWidget(testScope(
      MemorySaveStore(),
      initial: SaveData(gems: 40, introSeen: {trialId}),
      child: MaterialApp(
        theme: G.theme(),
        home: Scaffold(
          body: Builder(
            builder: (ctx) => TextButton(
              onPressed: () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => BattleScreen(trial: Trials.byId(trialId), resume: resume))),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final container = ProviderScope.containerOf(tester.element(find.byType(BattleScreen)));

    Future<void> loseFight() async {
      var s = container.read(battleProvider)!;
      while (!s.isOver) {
        expect(s.phase, BattlePhase.question);
        final q = s.question!;
        final wrong = q.choices.indexWhere((c) => !q.correctValues.contains(c.value));
        await tester.sendKeyEvent(LogicalKeyboardKey(0x30 + wrong + 1), character: '${wrong + 1}');
        await tester.pump();
        expect(container.read(battleProvider)!.phase, BattlePhase.wrong);
        // Space skips the explanation: next question, or the defeat screen.
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        s = container.read(battleProvider)!;
      }
      expect(s.phase, BattlePhase.defeat);
      expect(find.text('Iterum'), findsOneWidget);
    }

    await loseFight();
    // Enter on the result screen = Iterum: a fresh fight starts at once.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    var s = container.read(battleProvider)!;
    expect(s.isOver, isFalse);
    expect(s.hearts, Trials.byId(trialId).hearts);
    expect(find.text('Iterum'), findsNothing);
    expect(find.byType(BattleScreen), findsOneWidget);

    await loseFight();
    // Escape on the result screen returns to the activity.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(BattleScreen), findsNothing);
    expect(find.text('go'), findsOneWidget);
  });

  testWidgets('victory screen: Enter retries, Escape leaves', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // One hit point left: a single correct answer wins the fight.
    final resume = ActiveBattle(trialId: trialId, hearts: 3, enemyHp: 1, answered: 9, gemsDelta: 0, seed: 20260907, questionIndex: 9, componentIds: const [], correctCount: 9);
    await tester.pumpWidget(testScope(
      MemorySaveStore(),
      initial: SaveData(gems: 40, introSeen: {trialId}),
      child: MaterialApp(
        theme: G.theme(),
        home: Scaffold(
          body: Builder(
            builder: (ctx) => TextButton(
              onPressed: () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => BattleScreen(trial: Trials.byId(trialId), resume: resume))),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final container = ProviderScope.containerOf(tester.element(find.byType(BattleScreen)));

    var s = container.read(battleProvider)!;
    expect(s.phase, BattlePhase.question);
    final q = s.question!;
    final right = q.choices.indexWhere((c) => q.correctValues.contains(c.value));
    await tester.sendKeyEvent(LogicalKeyboardKey(0x30 + right + 1), character: '${right + 1}');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    s = container.read(battleProvider)!;
    expect(s.phase, BattlePhase.victory);
    expect(find.text('Iterum'), findsOneWidget);

    // Enter on the victory screen = Iterum.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    s = container.read(battleProvider)!;
    expect(s.isOver, isFalse);
    expect(s.phase, BattlePhase.question);
    expect(find.text('Iterum'), findsNothing);

    // Win again, then Escape returns to the activity.
    while (!container.read(battleProvider)!.isOver) {
      final s2 = container.read(battleProvider)!;
      final q2 = s2.question!;
      final r = q2.choices.indexWhere((c) => q2.correctValues.contains(c.value));
      await tester.sendKeyEvent(LogicalKeyboardKey(0x30 + r + 1), character: '${r + 1}');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(container.read(battleProvider)!.phase, BattlePhase.victory);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(BattleScreen), findsNothing);
    expect(find.text('go'), findsOneWidget);
  });
}
