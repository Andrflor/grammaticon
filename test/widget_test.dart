// Smoke test: the city opens, the Amphitheatrum lists the trials and a fight
// can be started and answered with the keyboard.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latin_game/app/app.dart';
import 'package:latin_game/app/providers.dart';
import 'package:latin_game/battle/battle_controller.dart';
import 'package:latin_game/persistence/save_data.dart';
import 'package:latin_game/persistence/save_repository.dart';

import 'support/test_env.dart';

void main() {
  Widget app(MemorySaveStore store, {SaveData? initial}) => testScope(store, initial: initial, child: const GrammaticonApp());

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

  testWidgets('city → Forum → debate with keyboard; the wallet is shared', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = MemorySaveStore();
    await tester.pumpWidget(app(store, initial: SaveData(gems: 5)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forum'));
    await tester.pumpAndSettle();
    expect(find.text('Forum · Dēclīnātiōnēs'.toUpperCase()), findsOneWidget); // top-bar inscription
    expect(find.textContaining('Prīma dēclīnātiō'), findsWidgets);
    expect(find.text('Contrōversia'), findsOneWidget); // only the free trial is open
    expect(find.text('Clausa'), findsWidgets);
    expect(find.textContaining('Eme · 20'), findsWidgets); // next trials are purchasable

    await tester.tap(find.widgetWithText(InkWell, 'Contrōversia').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Incipe!'), findsOneWidget);
    expect(find.textContaining('Prīma dēclīnātiō nōmina in -a'), findsOneWidget);
    await tester.tap(find.text('Incipe!'));
    await tester.pump();
    final element = tester.element(find.byType(Scaffold).last);
    final container = ProviderScope.containerOf(element);
    var s = container.read(battleProvider)!;
    expect(s.trial.id, 'd1-recti');
    final q = s.question!;
    // Dictionary entry and Latin prompt are on screen; the opponent bar shows resolve.
    expect(find.text(q.surface), findsOneWidget);
    expect(find.textContaining(', f.').evaluate().isNotEmpty || find.textContaining(', m.').evaluate().isNotEmpty, isTrue);
    expect(find.textContaining('cōnstantia'), findsOneWidget);
    expect(find.text('Rhētor Graecus'), findsOneWidget);
    final correct = q.choices.indexWhere((c) => q.correctValues.contains(c.value));
    await tester.sendKeyEvent(LogicalKeyboardKey(0x30 + correct + 1), character: '${correct + 1}');
    await tester.pump();
    s = container.read(battleProvider)!;
    expect(s.phase, BattlePhase.correct);
    expect(find.text('RECTE!'), findsOneWidget);
    expect(container.read(profileProvider).gems, 13);
    // Repeat must not pay twice.
    await tester.sendKeyEvent(LogicalKeyboardKey(0x30 + correct + 1), character: '${correct + 1}');
    await tester.pump();
    expect(container.read(profileProvider).gems, 13);
    await tester.pump(const Duration(milliseconds: 500));
    expect(container.read(battleProvider)!.phase, BattlePhase.question);
    // Mouse answer on the next question.
    final q2 = container.read(battleProvider)!.question!;
    final wrong = q2.choices.indexWhere((c) => !q2.correctValues.contains(c.value));
    await tester.tap(find.widgetWithText(InkWell, q2.choices[wrong].label).first);
    await tester.pump();
    expect(container.read(battleProvider)!.phase, BattlePhase.wrong);
    expect(find.text('ERRAT…'), findsOneWidget);
    expect(find.textContaining('Rēctum:'), findsOneWidget);
    expect(find.text('Perge'), findsOneWidget);
    container.read(battleProvider.notifier).abandon();
    await tester.pump();
    expect(store.raw, contains('"d.1.'));
  });

  testWidgets('portrait phone: Forum selection and debate layout', (tester) async {
    tester.view.physicalSize = const Size(420, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(MemorySaveStore(), initial: SaveData(introSeen: {'d1-recti'})));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Forum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forum'));
    await tester.pumpAndSettle();
    expect(find.text('Forum · Dēclīnātiōnēs'.toUpperCase()), findsOneWidget); // top-bar inscription
    await tester.tap(find.widgetWithText(InkWell, 'Contrōversia').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final element = tester.element(find.byType(Scaffold).last);
    final container = ProviderScope.containerOf(element);
    final q = container.read(battleProvider)!.question!;
    expect(find.text(q.surface), findsOneWidget);
    for (final c in q.choices) {
      expect(find.text(c.label), findsOneWidget);
    }
    expect(tester.takeException(), isNull); // no overflow on a phone
  });

  testWidgets('Tabula lists the declension tree with unevaluated skills', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(MemorySaveStore()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tabula'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Contrōversiae victae'), findsOneWidget);
    // Roots are expanded by default: the declension tree follows the verb tree.
    await tester.scrollUntilVisible(find.text('Dēclīnātiōnēs'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Dēclīnātiōnēs'), findsOneWidget);
    expect(find.text('Ventūrum: structūra parāta, nōndum lūditur.'), findsNothing);
    await tester.scrollUntilVisible(find.text('Mixta dēclīnātiōnum'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Prīma dēclīnātiō'), findsOneWidget);
    expect(find.text('Locātīvus'), findsOneWidget);
    // Unpractised skills stay unevaluated.
    await tester.ensureVisible(find.text('Prīma dēclīnātiō'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prīma dēclīnātiō'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Accūsātīvus'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Accūsātīvus'), findsOneWidget);
  });

  testWidgets('portrait phone layout lists the buildings and opens the Tabula', (tester) async {
    tester.view.physicalSize = const Size(420, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(MemorySaveStore()));
    await tester.pumpAndSettle();
    expect(find.text('Amphitheātrum'), findsOneWidget);
    expect(find.text('Theātrum'), findsOneWidget);
    expect(find.text('Thermae'), findsNothing);
    await tester.tap(find.text('Tabula'));
    await tester.pumpAndSettle();
    expect(find.text('Tabula perītiārum'.toUpperCase()), findsOneWidget); // top-bar inscription
    await tester.scrollUntilVisible(find.text('Coniugātiōnēs'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Coniugātiōnēs'), findsOneWidget);
    expect(find.textContaining('Nōn aestimāta'), findsWidgets);
  });

  testWidgets('city → Theatrum → performance with keyboard and mouse; long French choices; Auxilium; correction', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = MemorySaveStore();
    await tester.pumpWidget(app(store, initial: SaveData(gems: 5)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Theātrum'));
    await tester.pumpAndSettle();
    expect(find.text('Theātrum · Interpretātiō'.toUpperCase()), findsOneWidget); // top-bar inscription
    expect(find.textContaining('Numerus in sententiā'), findsWidgets);
    expect(find.text('Fābula'), findsOneWidget); // only the free trial is open
    expect(find.text('Clausa'), findsWidgets);
    expect(find.textContaining('Eme · 15'), findsWidgets);
    expect(find.text('Cōmoedus Rīdēns'), findsNothing); // opponent names appear in the encounter, portraits on the cards

    await tester.tap(find.widgetWithText(InkWell, 'Fābula').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Incipe!'), findsOneWidget);
    expect(find.textContaining('In Theātrō sententia Latīna legitur'), findsOneWidget);
    await tester.tap(find.text('Incipe!'));
    await tester.pump();
    final element = tester.element(find.byType(Scaffold).last);
    final container = ProviderScope.containerOf(element);
    var s = container.read(battleProvider)!;
    expect(s.trial.id, 'th-numerus');
    final q = s.question!;
    // The Latin passage, its reference and the four French renderings are on screen.
    expect(find.text(q.surface), findsOneWidget);
    expect(find.text(q.context.single), findsOneWidget);
    for (final c in q.choices) {
      expect(find.text(c.label), findsOneWidget);
    }
    expect(find.textContaining('favor populī'), findsOneWidget);
    expect(find.text('Cōmoedus Rīdēns'), findsOneWidget);
    expect(tester.takeException(), isNull);
    // Auxilium before answering: vocabulary and a hint, never the French of the passage.
    await tester.tap(find.text('Auxilium'));
    await tester.pumpAndSettle();
    expect(find.text('Vocābula'), findsOneWidget);
    expect(find.text('Cōnsilium'), findsOneWidget);
    expect(find.text('Interpretātiō vēra'), findsNothing);
    expect(container.read(battleProvider)!.helpUsed, isTrue);
    await tester.tap(find.text('Claude'));
    await tester.pumpAndSettle();
    final correct = q.choices.indexWhere((c) => q.correctValues.contains(c.value));
    await tester.sendKeyEvent(LogicalKeyboardKey(0x30 + correct + 1), character: '${correct + 1}');
    await tester.pump();
    s = container.read(battleProvider)!;
    expect(s.phase, BattlePhase.correct);
    expect(find.text('RECTE!'), findsOneWidget);
    expect(container.read(profileProvider).gems, 6); // aided: +1
    await tester.sendKeyEvent(LogicalKeyboardKey(0x30 + correct + 1), character: '${correct + 1}');
    await tester.pump();
    expect(container.read(profileProvider).gems, 6);
    await tester.pump(const Duration(milliseconds: 500));
    expect(container.read(battleProvider)!.phase, BattlePhase.question);
    // Mouse answer, wrong: the existing correction flow with the morphological explanation.
    final q2 = container.read(battleProvider)!.question!;
    final wrong = q2.choices.indexWhere((c) => !q2.correctValues.contains(c.value));
    await tester.tap(find.widgetWithText(InkWell, q2.choices[wrong].label).first);
    await tester.pump();
    expect(container.read(battleProvider)!.phase, BattlePhase.wrong);
    expect(find.text('ERRAT…'), findsOneWidget);
    expect(find.textContaining('Rēctum:'), findsOneWidget);
    expect(find.text('Perge'), findsOneWidget);
    expect(tester.takeException(), isNull);
    // Explicā plūs reveals the analysis and the faithful rendering with its source.
    await tester.tap(find.text('Explicā plūs'));
    await tester.pumpAndSettle();
    expect(find.text('Interpretātiō vēra'), findsOneWidget);
    expect(find.text('Interpretātiōnēs falsae'), findsOneWidget);
    expect(find.textContaining('Fōns:'), findsWidgets);
    await tester.tap(find.text('Claude'));
    await tester.pumpAndSettle();
    container.read(battleProvider.notifier).abandon();
    await tester.pump();
    expect(store.raw, contains('"l.numerus"'));
    expect(store.raw, contains('"expo"'));
  });

  testWidgets('portrait phone: Theatrum performance layout with long text does not overflow', (tester) async {
    tester.view.physicalSize = const Size(420, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(MemorySaveStore(), initial: SaveData(introSeen: {'th-numerus'})));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Theātrum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Theātrum'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'Fābula').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final element = tester.element(find.byType(Scaffold).last);
    final container = ProviderScope.containerOf(element);
    final q = container.read(battleProvider)!.question!;
    expect(find.text(q.surface), findsOneWidget);
    for (final c in q.choices) {
      expect(find.text(c.label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
    // A wrong answer adds the correction panel above the four sentences: still no overflow.
    final wrong = q.choices.indexWhere((c) => !q.correctValues.contains(c.value));
    container.read(battleProvider.notifier).answer(q.id, wrong);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Perge'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Anglicē is prepared but unavailable: not selectable in the options, and the Theatrum shows no French', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(MemorySaveStore(), initial: SaveData(settings: const Settings(translationLanguage: TranslationLanguage.anglice))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Theātrum'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Anglicē: nōndum parāta'), findsOneWidget);
    expect(find.text('Fābula'), findsNothing);
    expect(find.textContaining('Numerus in sententiā'), findsNothing);
    await tester.tap(find.text('Optiōnēs'));
    await tester.pumpAndSettle();
    expect(find.text('Lingua interpretātiōnis'), findsOneWidget);
    expect(find.text('Anglicē · nōndum parāta'), findsOneWidget);
    expect(find.text('Gallicē'), findsOneWidget);
    await tester.tap(find.text('Gallicē'));
    await tester.pumpAndSettle();
    final element = tester.element(find.text('Gallicē'));
    expect(ProviderScope.containerOf(element).read(profileProvider).settings.translationLanguage, TranslationLanguage.gallice);
  });

  testWidgets('Tabula shows the Lēctiō branch and the vocabulary exposure panel apart from mastery', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(MemorySaveStore()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tabula'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Fābulae victae'), findsOneWidget);
    expect(find.textContaining('Vocābula Theātrī'), findsOneWidget);
    expect(find.textContaining('Obvia: 0'), findsOneWidget);
    // Vocabulary acquisition by frequency band, with the gradus that gates selection.
    expect(find.textContaining('Gradus 1 /'), findsOneWidget);
    expect(find.textContaining('Gradus I'), findsWidgets);
    expect(find.textContaining('clausus'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Lēctiō · Theātrum'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Lēctiō · Theātrum'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Mixta lēctiōnis'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Verbum in sententiā'), findsOneWidget);
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
    expect(find.text('Optiōnēs'.toUpperCase()), findsOneWidget); // top-bar inscription
    // The panels above it are tall with the test font: bring the table into view first.
    await tester.scrollUntilVisible(find.text('Gemmae: praemia et poenae'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Gemmae: praemia et poenae'), findsOneWidget);
    expect(find.text('+8'), findsOneWidget);
    expect(find.text('−4').evaluate().isNotEmpty || find.text('-4').evaluate().isNotEmpty, isTrue);
    await tester.scrollUntilVisible(find.text('Exportā in tabellam'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Exportā in tabellam'), findsOneWidget);
    expect(find.text('Dēlē omnia'), findsOneWidget);
  });
}
