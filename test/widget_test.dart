// Smoke test: the city opens, the Amphitheatrum lists the trials and a fight
// can be started and answered with the keyboard.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/app/app.dart';
import 'package:grammaticon/app/providers.dart';
import 'package:grammaticon/battle/battle_controller.dart';
import 'package:grammaticon/persistence/save_data.dart';
import 'package:grammaticon/persistence/save_repository.dart';

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
    expect(find.text('Forum · Nōminālia'.toUpperCase()), findsWidgets); // top-bar inscription, drawn in two layers
    expect(find.textContaining('Dēclīnātiō prīma'), findsWidgets);
    // The first section is on screen; its only free card is the first
    // declension. The second free door (the personal pronouns) lives further
    // down the page, in its own section.
    expect(find.text('Contrōversia'), findsOneWidget);
    expect(find.text('Clausa'), findsWidgets);
    expect(find.textContaining('Eme · 15'), findsWidgets); // next trials are purchasable

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
    expect(s.trial.id, 'dec-1');
    final q = s.question!;
    // The form and the Latin prompt are on screen; the opponent bar shows resolve.
    expect(find.text(q.surface), findsOneWidget);
    // The dictionary entry is shown under the form, except on a question it
    // would answer by itself (the entry names the gender).
    if (q.context.isNotEmpty) {
      expect(find.text(q.context.single), findsOneWidget);
      expect(q.context.single, matches(RegExp(r', [mfn]\.$')));
    }
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
    await tester.pumpWidget(app(MemorySaveStore(), initial: SaveData(introSeen: {'dec-1'})));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Forum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forum'));
    await tester.pumpAndSettle();
    expect(find.text('Forum · Nōminālia'.toUpperCase()), findsWidgets); // top-bar inscription, drawn in two layers
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

  testWidgets('Tabula lists the skill tree with unevaluated links', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(MemorySaveStore()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tabula'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Contrōversiae victae'), findsOneWidget);
    // Roots are expanded by default: the verbal groups first, then the nominal system.
    expect(find.text('Verbum'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Themata nōminum'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Nōmen'), findsOneWidget);
    expect(find.text('Themata nōminum'), findsOneWidget);
    // Unpractised links stay unevaluated.
    expect(find.textContaining('Nōn aestimāta'), findsWidgets);
    await tester.ensureVisible(find.text('Themata nōminum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Themata nōminum'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Thema in -ā (prīma)'), 300, scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.text('Thema in -ā (prīma)'));
    await tester.pumpAndSettle();
    expect(find.text('Thema in -ā (prīma)'), findsOneWidget);
    await tester.tap(find.text('Thema in -ā (prīma)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Reconnaître un nom de 1re déclinaison'), findsOneWidget);
    expect(find.text('Cōnfunditur cum'), findsOneWidget);
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
    expect(find.text('Tabula perītiārum'.toUpperCase()), findsWidgets); // top-bar inscription, drawn in two layers
    await tester.scrollUntilVisible(find.text('Verbum'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Verbum'), findsOneWidget);
    expect(find.textContaining('Nōn aestimāta'), findsWidgets);
  });

  testWidgets('city → Theatrum → performance with keyboard and mouse; French choices; Auxilium; correction', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = MemorySaveStore();
    await tester.pumpWidget(app(store, initial: SaveData(gems: 5)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Theātrum'));
    await tester.pumpAndSettle();
    expect(find.text('Theātrum · Interpretātiō'.toUpperCase()), findsWidgets); // top-bar inscription, drawn in two layers
    expect(find.textContaining('In Italiā'), findsWidgets);
    expect(find.text('Fābula'), findsOneWidget); // only the free card is open
    expect(find.text('Clausa'), findsWidgets);
    expect(find.text('Cōmoedus Rīdēns'), findsNothing); // opponent names appear in the encounter, portraits on the cards

    await tester.tap(find.widgetWithText(InkWell, 'Fābula').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Incipe!'), findsOneWidget);
    expect(find.textContaining('Sententiās Latīnās lege'), findsOneWidget);
    await tester.tap(find.text('Incipe!'));
    await tester.pump();
    final element = tester.element(find.byType(Scaffold).last);
    final container = ProviderScope.containerOf(element);
    var s = container.read(battleProvider)!;
    expect(s.trial.id, 'th-loca-a-ablative');
    final q = s.question!;
    // The Latin sentence and its French renderings are on screen.
    expect(find.text(q.surface), findsOneWidget);
    for (final c in q.choices) {
      expect(find.text(c.label), findsOneWidget);
    }
    expect(find.textContaining('favor populī'), findsOneWidget);
    expect(find.text('Cōmoedus Rīdēns'), findsOneWidget);
    expect(tester.takeException(), isNull);
    // Auxilium before answering: what the card exercises, never the answer.
    await tester.tap(find.text('Auxilium'));
    await tester.pumpAndSettle();
    expect(find.text('Quid hīc exercētur'), findsOneWidget);
    expect(find.text('Respōnsum'), findsNothing);
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
    // Mouse answer, wrong: the correction flow with the frame's explanation.
    final q2 = container.read(battleProvider)!.question!;
    final wrong = q2.choices.indexWhere((c) => !q2.correctValues.contains(c.value));
    await tester.tap(find.widgetWithText(InkWell, q2.choices[wrong].label).first);
    await tester.pump();
    expect(container.read(battleProvider)!.phase, BattlePhase.wrong);
    expect(find.text('ERRAT…'), findsOneWidget);
    expect(find.textContaining('Rēctum:'), findsOneWidget);
    expect(find.text('Perge'), findsOneWidget);
    expect(tester.takeException(), isNull);
    // Explicā plūs reveals the accepted rendering.
    await tester.tap(find.text('Explicā plūs'));
    await tester.pumpAndSettle();
    expect(find.text('Respōnsum'), findsOneWidget);
    await tester.tap(find.text('Claude'));
    await tester.pumpAndSettle();
    container.read(battleProvider.notifier).abandon();
    await tester.pump();
    expect(store.raw, contains('"expo"'));
    expect(store.raw, contains('"arbor"'));
  });

  testWidgets('portrait phone: Theatrum performance layout with long text does not overflow', (tester) async {
    tester.view.physicalSize = const Size(420, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(MemorySaveStore(), initial: SaveData(introSeen: {'th-loca-a-ablative'})));
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
    // A wrong answer adds the correction panel above the sentences: still no overflow.
    final wrong = q.choices.indexWhere((c) => !q.correctValues.contains(c.value));
    container.read(battleProvider.notifier).answer(q.id, wrong);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Perge'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('city → Templum → a production rite with French prompt and Latin choices', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(MemorySaveStore(), initial: SaveData(introSeen: {'tp-loca-a-ablative'})));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Templum'));
    await tester.pumpAndSettle();
    expect(find.text('Templum · Compositiō'.toUpperCase()), findsWidgets);
    await tester.tap(find.widgetWithText(InkWell, 'Rītus').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final element = tester.element(find.byType(Scaffold).last);
    final container = ProviderScope.containerOf(element);
    final s = container.read(battleProvider)!;
    expect(s.trial.id, 'tp-loca-a-ablative');
    final q = s.question!;
    expect(find.text(q.surface), findsOneWidget);
    for (final c in q.choices) {
      expect(find.text(c.label), findsOneWidget);
    }
    expect(find.textContaining('favor deōrum'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Anglicē is prepared but unavailable: not selectable in the options', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(MemorySaveStore(), initial: SaveData(settings: const Settings(translationLanguage: TranslationLanguage.anglice))));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings));
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
    await tester.scrollUntilVisible(find.text('Via legendī'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Lēctiō'), findsOneWidget);
    expect(find.text('Via legendī'), findsOneWidget);
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
    expect(find.text('Optiōnēs'.toUpperCase()), findsWidgets); // top-bar inscription, drawn in two layers
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
