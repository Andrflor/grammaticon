// Smoke test: the city opens, the Amphitheatrum lists the trials and a fight
// can be started and answered with the keyboard.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latin_game/app/app.dart';
import 'package:latin_game/app/providers.dart';
import 'package:latin_game/audio/audio_service.dart';
import 'package:latin_game/battle/battle_controller.dart';
import 'package:latin_game/linguistics/engine/analyzer.dart';
import 'package:latin_game/linguistics/engine/conjugator.dart';
import 'package:latin_game/linguistics/lexicon/verbs.dart';
import 'package:latin_game/persistence/save_data.dart';
import 'package:latin_game/persistence/save_repository.dart';

void main() {
  final analyzer = Analyzer(kVerbs, Conjugator());

  Widget app(MemorySaveStore store, {SaveData? initial}) => ProviderScope(
        overrides: [
          analyzerProvider.overrideWithValue(analyzer),
          saveRepositoryProvider.overrideWithValue(SaveRepository(store)),
          initialSaveProvider.overrideWithValue(initial ?? SaveData(createdAt: DateTime(2026, 1, 1))),
          audioProvider.overrideWithValue(AudioService(enabled: false)),
        ],
        child: const GrammaticonApp(),
      );

  testWidgets('city → Amphitheatrum → fight with keyboard', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = MemorySaveStore();
    await tester.pumpWidget(app(store));
    await tester.pumpAndSettle();
    expect(find.text('GRAMMATICON'), findsOneWidget);
    expect(find.text('Amphitheātrum'), findsOneWidget);
    expect(find.text('Forum'), findsOneWidget);

    await tester.tap(find.text('Amphitheātrum'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Indicātīvus praesēns'), findsWidgets);
    expect(find.text('Clausa'), findsWidgets);

    // Start the free trial.
    await tester.tap(find.widgetWithText(InkWell, 'Certāmen').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));
    // Intro is shown first.
    expect(find.text('Incipe!'), findsOneWidget);
    await tester.tap(find.text('Incipe!'));
    await tester.pump();
    final element = tester.element(find.byType(Scaffold).last);
    final container = ProviderScope.containerOf(element);
    var s = container.read(battleProvider)!;
    expect(s.phase, BattlePhase.question);
    final q = s.question!;
    final correct = q.choices.indexWhere((c) => q.correctValues.contains(c.value));
    // Keyboard answer 1–9.
    await tester.sendKeyEvent(LogicalKeyboardKey(0x30 + correct + 1), character: '${correct + 1}');
    await tester.pump();
    s = container.read(battleProvider)!;
    expect(s.phase, BattlePhase.correct);
    expect(find.text('RECTE!'), findsOneWidget);
    expect(container.read(profileProvider).gems, 8);
    // Held key / repeat must not answer twice.
    await tester.sendKeyEvent(LogicalKeyboardKey(0x30 + correct + 1), character: '${correct + 1}');
    await tester.pump();
    expect(container.read(profileProvider).gems, 8);
    await tester.pump(const Duration(milliseconds: 500));
    s = container.read(battleProvider)!;
    expect(s.phase, BattlePhase.question);
    expect(s.question!.id, isNot(q.id));
    // Leave the arena (state is saved).
    container.read(battleProvider.notifier).abandon();
    await tester.pump();
    expect(store.raw, contains('"gems":8'));
  });

  testWidgets('portrait phone layout lists the buildings and opens the Tabula', (tester) async {
    tester.view.physicalSize = const Size(420, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(MemorySaveStore()));
    await tester.pumpAndSettle();
    expect(find.text('Amphitheātrum'), findsOneWidget);
    expect(find.text('Thermae'), findsOneWidget);
    await tester.tap(find.text('Tabula'));
    await tester.pumpAndSettle();
    expect(find.text('Tabula perītiārum'), findsOneWidget);
    expect(find.text('Coniugātiōnēs'), findsOneWidget);
    expect(find.textContaining('Nōn aestimāta'), findsWidgets);
  });

  testWidgets('help sheet opens during a question and marks the answer as aided', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(MemorySaveStore(), initial: SaveData(introSeen: {'ind-praes-act'})));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Amphitheātrum'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'Certāmen').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Auxilium'), findsOneWidget);
    await tester.tap(find.text('Auxilium'));
    await tester.pumpAndSettle();
    expect(find.text('Claude'), findsOneWidget);
    expect(find.textContaining('Indicātīvus āctīvum'), findsOneWidget);
    expect(find.text('Fōrmae nōminālēs'), findsOneWidget);
    final element = tester.element(find.text('Claude'));
    final container = ProviderScope.containerOf(element);
    expect(container.read(battleProvider)!.helpUsed, isTrue);
    await tester.tap(find.text('Claude'));
    await tester.pumpAndSettle();
    expect(find.text('Auxilium'), findsOneWidget);
  });

  testWidgets('settings screen renders the reward table and save actions', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(MemorySaveStore()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('Optiōnēs'), findsOneWidget);
    expect(find.text('Gemmae: praemia et poenae'), findsOneWidget);
    expect(find.text('+8'), findsOneWidget);
    expect(find.text('−4').evaluate().isNotEmpty || find.text('-4').evaluate().isNotEmpty, isTrue);
    await tester.scrollUntilVisible(find.text('Exportā in tabellam'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Exportā in tabellam'), findsOneWidget);
    expect(find.text('Dēlē omnia'), findsOneWidget);
  });
}
