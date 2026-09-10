import 'dart:io';
import 'dart:ui' as ui;

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/engine/application.dart';
import 'package:grammaticon/engine/design.dart';
import 'package:grammaticon/engine/session.dart';
import 'package:grammaticon/game/encounter_scene.dart';
import 'package:grammaticon/ui/activity/presentation_binding.dart';
import 'package:grammaticon/ui/widgets/roman_widgets.dart';

import 'design_test.dart' show readFile;

void main() {
  setUpAll(() async {
    for (final family in ['Nunito', 'Cinzel']) {
      await (FontLoader(
        family,
      )..addFont(rootBundle.load('assets/fonts/$family.ttf'))).load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final width in [420.0, 1500.0]) {
    testWidgets('integrated reading and temple scenes at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final design = (await tester.runAsync(
        () => GameDesign.load('assets/designs/grammaticon/game.json', readFile),
      ))!;
      await tester.runAsync(() async {
        Flame.images.prefix = '';
        for (final resource in design.resources.values.where(
          (r) => r['type'] == 'image',
        )) {
          await Flame.images.load(resource['path']);
        }
      });
      for (final address in [
        'theatrum/11-synthesis/reading',
        'templum/11-synthesis/theme',
      ]) {
        final card = design.cards[address]!;
        final session = GameSession(design, {}, (_) async {});
        session.state['settings']['sound'] = false;
        session.state['settings']['music'] = false;
        session.state['purchased'] = [...design.nodes.keys];
        await tester.runAsync(() async {
          await design.lesson(card);
        });
        final boundary = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: DesignApp(session: session, audioEnabled: false),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final context = tester.element(find.byType(Scaffold).last);
          for (final resource in design.resources.values.where(
            (r) => r['type'] == 'image',
          )) {
            await precacheImage(AssetImage(resource['path']), context);
          }
        });
        final place = TrialView(session, card).place;
        await tester.tap(find.text(session.text(place.data['name'])));
        await tester.pumpAndSettle();
        expect(
          find.byIcon(
            place.id == 'theatrum'
                ? Icons.theater_comedy
                : Icons.account_balance,
          ),
          findsWidgets,
        );
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File('/tmp/${place.id}-selection-${width.toInt()}.png')
              .writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.tap(find.byIcon(Icons.arrow_back).first);
        await tester.pumpAndSettle();
        await tester.runAsync(() => session.start(card));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(
            RomanButton,
            TrialView(session, card).label('resume'),
          ),
        );
        await tester.pump();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 150)),
        );
        await tester.pump(const Duration(milliseconds: 300));
        final scene =
            tester
                    .widget<GameWidget>(
                      find.byWidgetPredicate((w) => w is GameWidget),
                    )
                    .game
                as EncounterScene;
        scene.pauseEngine();
        await tester.tap(find.widgetWithText(RomanButton, 'Incipe!'));
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        expect(session.question!.id, 'q1');
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File('/tmp/${address.split('/').first}-${width.toInt()}.png')
              .writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
        final q = session.question!;
        final text = session.text(
          q.choices.firstWhere((c) => c['id'] == q.accepted.first)['text'],
        );
        final answer = find.widgetWithText(RomanButton, text);
        await tester.ensureVisible(answer);
        await tester.pumpAndSettle();
        expect(tester.widget<RomanButton>(answer).onPressed, isNotNull);
        await tester.tap(answer);
        await tester.pump(const Duration(milliseconds: 100));
        expect(session.encounter!['phase'], 'feedback');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
        session.dispose();
      }
    });
  }
}
