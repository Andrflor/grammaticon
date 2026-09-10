import 'package:grammaticon/ui/activity/presentation_binding.dart';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/engine/application.dart';
import 'package:grammaticon/engine/session.dart';
import 'package:grammaticon/game/encounter_scene.dart';
import 'package:grammaticon/ui/city/city_screen.dart';
import 'package:grammaticon/ui/trials/trial_selection_screen.dart';
import 'package:grammaticon/ui/settings/settings_screen.dart';
import 'package:grammaticon/ui/tabula/tabula_screen.dart';
import 'package:grammaticon/ui/widgets/roman_widgets.dart';

import 'design_test.dart' show demo;

void main() {
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    for (final family in ['Nunito', 'Cinzel']) {
      await (FontLoader(
        family,
      )..addFont(rootBundle.load('assets/fonts/$family.ttf'))).load();
    }
  });
  for (final width in [420.0, 1500.0]) {
    testWidgets('all Compass activities use original screens at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final d = (await tester.runAsync(demo))!;
      await tester.runAsync(() async {
        Flame.images.prefix = '';
        for (final r in d.resources.values.where((r) => r['type'] == 'image')) {
          await Flame.images.load(r['path'] as String);
        }
        for (final card in d.cards.values) {
          await d.lesson(card);
        }
      });
      for (final card in d.cards.values) {
        final s = GameSession(d, {}, (_) async {});
        s.state['settings']['sound'] = false;
        s.state['settings']['music'] = false;
        s.state['balance'] = 1000;
        // All content must render even when its prerequisites were completed earlier.
        s.state['purchased'] = [...d.nodes.keys];
        final boundary = GlobalKey();
        Future<void> capture(String name) async {
          await tester.runAsync(() async {
            final image =
                await (boundary.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            File('/tmp/compass-$name-${width.toInt()}.png')
                .writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }

        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: DesignApp(session: s, audioEnabled: false),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CityScreen), findsOneWidget);
        if (card == d.cards.values.first) {
          await capture('city');
          for (final place in d.places) {
            await tester.ensureVisible(find.text(s.text(place.data['name'])));
            await tester.tap(find.text(s.text(place.data['name'])));
            await tester.pumpAndSettle();
            expect(find.byType(TrialSelectionScreen), findsOneWidget);
            await capture('${place.id}-selection');
            expect(tester.takeException(), isNull);
            await tester.tap(find.widgetWithText(RomanButton, 'Retour').first);
            await tester.pumpAndSettle();
          }
          await tester.tap(find.byIcon(Icons.settings).first);
          await tester.pumpAndSettle();
          expect(find.byType(SettingsScreen), findsOneWidget);
          await tester.ensureVisible(find.text('English'));
          await tester.tap(find.text('English'));
          await tester.pumpAndSettle();
          expect(s.locale, 'en');
          expect(find.text('Game language'), findsOneWidget);
          await tester.tap(find.widgetWithText(RomanButton, 'Back').first);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Progress'));
          await tester.pumpAndSettle();
          expect(find.byType(TabulaScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(find.widgetWithText(RomanButton, 'Back').first);
          await tester.pumpAndSettle();
          await s.setting('locale', 'fr');
        }
        await tester.runAsync(() => s.start(card));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(RomanButton, TrialView(s, card).label('resume')),
        );
        await tester.pump();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump(const Duration(milliseconds: 300));
        final game =
            tester
                    .widget<GameWidget>(
                      find.byWidgetPredicate((w) => w is GameWidget),
                    )
                    .game
                as EncounterScene;
        game.pauseEngine();
        await tester.tap(find.widgetWithText(RomanButton, 'Commencer'));
        await tester.pump(const Duration(milliseconds: 300));
        expect(s.encounter!['phase'], 'question');
        expect(tester.takeException(), isNull);
        await capture(card.id);
        await tester.runAsync(() => d.help(s.question!.data['help'] as String));
        await tester.tap(find.widgetWithText(RomanButton, 'Aide'));
        await tester.pumpAndSettle();
        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
        await tester.tap(find.widgetWithText(RomanButton, 'Fermer'));
        await tester.pumpAndSettle();
        final q = s.question!;
        final wrong = q.choices.firstWhere(
          (c) => !q.accepted.contains(c['id']),
        );
        await tester.tap(
          find.widgetWithText(RomanButton, s.text(wrong['text'])),
        );
        await tester.pump(const Duration(milliseconds: 800));
        expect(s.encounter!['phase'], 'feedback');
        expect(tester.takeException(), isNull);
        final balance = s.balance;
        final observations = s.state['observations'].toString();
        await tester.tap(find.byIcon(Icons.arrow_back).first);
        await tester.pumpAndSettle();
        expect(find.byType(CityScreen), findsOneWidget);
        expect(find.text(TrialView(s, card).label('resume')), findsOneWidget);
        final omit = find.widgetWithText(
          RomanButton,
          TrialView(s, card).label('omit'),
        );
        expect(
          tester.widget<RomanButton>(omit).style,
          RomanButtonStyle.neutral,
        );
        await tester.tap(omit);
        await tester.pumpAndSettle();
        expect(s.encounter, isNull);
        expect(s.balance, balance);
        expect(s.state['observations'].toString(), observations);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 2));
        s.dispose();
      }
    });
  }
}
