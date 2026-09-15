import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/app/providers.dart';
import 'package:grammaticon/app/theme.dart';
import 'package:grammaticon/battle/battle_controller.dart';
import 'package:grammaticon/pedagogy/trials.dart';
import 'package:grammaticon/persistence/save_data.dart';
import 'package:grammaticon/persistence/save_repository.dart';
import 'package:grammaticon/ui/battle/battle_screen.dart';
import 'package:grammaticon/ui/iter/iter_sheet.dart';

import '../support/test_env.dart';

void main() {
  Future<ProviderContainer> finishBattle(WidgetTester tester, {bool won = true, bool noNextCard = false}) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const trialId = 'ind-praes-act';
    final resume = ActiveBattle(trialId: trialId, hearts: 1, enemyHp: 1, answered: 9, gemsDelta: 0, seed: 20260907, questionIndex: 9, componentIds: const [], correctCount: 9);
    await tester.pumpWidget(
      testScope(
        MemorySaveStore(),
        initial: const SaveData(gems: 40, introSeen: {trialId}),
        child: ProviderScope(
          overrides: [if (noNextCard) iterChoiceProvider.overrideWithValue(null)],
          child: MaterialApp(
            theme: G.theme(),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BattleScreen(trial: Trials.byId(trialId), resume: resume),
                    ),
                  ),
                  child: const Text('Activity menu'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Activity menu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final container = ProviderScope.containerOf(tester.element(find.byType(BattleScreen)));
    final ctrl = container.read(battleProvider.notifier);
    final q = container.read(battleProvider)!.question!;
    ctrl.answer(q.id, q.choices.indexWhere((c) => q.isCorrect(c.value) == won));
    ctrl.proceed();
    await tester.pump();
    expect(container.read(battleProvider)!.phase, won ? BattlePhase.victory : BattlePhase.defeat);
    return container;
  }

  testWidgets('end Iter dialog ignores outside taps, Escape and back; explicit leave exits the battle', (tester) async {
    final container = await finishBattle(tester);
    await tester.tap(find.text('Iter'));
    await tester.pumpAndSettle();
    expect(find.text('Iter · proximum'), findsOneWidget);
    expect(container.read(battleProvider), isNull);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Iter · proximum'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Iter · proximum'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Iter · proximum'), findsOneWidget);

    await tester.tap(find.text('Relinque'));
    await tester.pumpAndSettle();
    expect(find.byType(BattleScreen), findsNothing);
    expect(find.text('Activity menu'), findsOneWidget);
    expect(container.read(profileProvider).battlesWon, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('end Iter dialog can start the next battle after defeat', (tester) async {
    final container = await finishBattle(tester, won: false);
    await tester.tap(find.text('Iter'));
    await tester.pumpAndSettle();
    final choice = container.read(iterChoiceProvider)!;
    await tester.tap(find.text(choice.mustBuy ? 'Eme et perge' : 'Perge'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Iter · proximum'), findsNothing);
    expect(container.read(battleProvider)!.trial.id, choice.trial.id);
    expect(container.read(battleProvider)!.question, isNotNull);
    expect(container.read(profileProvider).battlesLost, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no next Iter card returns to the activity instead of an empty battle', (tester) async {
    final container = await finishBattle(tester, noNextCard: true);
    await tester.tap(find.text('Iter'));
    await tester.pumpAndSettle();
    expect(find.byType(BattleScreen), findsNothing);
    expect(find.text('Activity menu'), findsOneWidget);
    expect(container.read(profileProvider).battlesWon, 1);
    expect(tester.takeException(), isNull);
  });
}
