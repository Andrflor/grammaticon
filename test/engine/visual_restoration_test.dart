import 'package:grammaticon/ui/activity/presentation_binding.dart';

import 'dart:io';
import 'dart:convert';

import 'package:flame/game.dart';
import 'package:grammaticon/game/encounter_scene.dart';
import 'package:flame/flame.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/engine/application.dart';
import 'package:grammaticon/engine/design.dart';
import 'package:grammaticon/engine/session.dart';
import 'package:grammaticon/ui/widgets/roman_widgets.dart';
import 'package:grammaticon/ui/help/help_sheet.dart';

import 'design_test.dart' show readFile;

Future<String> readVisualBaseline(String path) async {
  if (path == 'assets/designs/grammaticon/game.json') {
    return readFile('test/fixtures/visual/original-design.json');
  }
  if (path.endsWith('/grammaticon/knowledge.json.gz')) {
    final data = jsonDecode(await readFile(path)) as Map<String, dynamic>;
    final ids = (jsonDecode(
      await readFile('test/fixtures/visual/original-knowledge-ids.json'),
    ) as List).toSet();
    data['nodes'] = (data['nodes'] as List)
        .where((n) => ids.contains(n['id']))
        .toList();
    data['practiceSets'] = (data['practiceSets'] as List)
        .where(
          (p) =>
              !(p['id'] as String).startsWith('concept.') &&
              !(p['id'] as String).startsWith('pilot.') &&
              !(p['id'] as String).startsWith('course.') &&
              !(p['id'] as String).startsWith('word.review.'),
        )
        .toList();
    return jsonEncode(data);
  }
  return readFile(path);
}

void main() {
  for (final width in [1600.0, 420.0]) {
    testWidgets('original presentation survives JSON binding at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final family in ['Nunito', 'Cinzel']) {
        await (FontLoader(
          family,
        )..addFont(rootBundle.load('assets/fonts/$family.ttf'))).load();
      }
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      final d = (await tester.runAsync(
        () => GameDesign.load(
          'assets/designs/grammaticon/game.json',
          readVisualBaseline,
        ),
      ))!;
      final s = GameSession(d, {}, (_) async {});
      s.state['settings']['sound'] = false;
      s.state['settings']['music'] = false;
      s.state['balance'] = 0;
      final boundary = GlobalKey();
      Future<void> capture(String name) async {
        await tester.runAsync(() async {
          final context = tester.element(find.byType(Scaffold).last);
          for (final item in d.resources.values.where(
            (r) => r['type'] == 'image',
          )) {
            await precacheImage(AssetImage(item['path']), context);
          }
        });
        final scenes = find.byWidgetPredicate((w) => w is GameWidget);
        if (scenes.evaluate().isNotEmpty) {
          final scene =
              tester.widget<GameWidget>(scenes).game as EncounterScene;
          scene.pauseEngine();
          for (final fighter in scene.descendants().whereType<Fighter>()) {
            fighter.scale.setValues(1, 1);
          }
          scene.renderBox.markNeedsPaint();
        }
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull);
        if (!['correction', 'help', 'forum'].contains(name)) {
          await expectLater(
            find.byKey(boundary),
            matchesGoldenFile('../goldens/$name-${width.toInt()}.png'),
          );
        }
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File('/tmp/restored-$name-${width.toInt()}.png')
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
      await capture('city');
      s.state['settings']['sound'] = true;
      await tester.tap(find.byIcon(Icons.settings).first);
      await tester.pumpAndSettle();
      await capture('settings');
      await tester.tap(find.widgetWithText(RomanButton, 'Redī').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tabula'));
      await tester.pumpAndSettle();
      await capture('progress');
      await tester.tap(find.widgetWithText(RomanButton, 'Redī').first);
      await tester.pumpAndSettle();
      s.state['settings']['sound'] = false;
      await tester.ensureVisible(find.text('Amphitheātrum'));
      await tester.tap(find.text('Amphitheātrum'));
      await tester.pumpAndSettle();
      await capture('selection');
      expect(find.text('Certāmen'), findsWidgets);
      await tester.runAsync(() async {
        final card = d.cards.values.first;
        await d.lesson(card);
        Flame.images.prefix = '';
        for (final id in [
          'arena_bg',
          'hero_idle',
          'hero_attack',
          'hero_hurt',
          'hero_victory',
          'hero_defeat',
          'enemy_statua',
          'impact',
          'gem',
        ]) {
          await Flame.images.load(d.asset(id));
        }
      });
      await tester.runAsync(() async {
        await tester.tap(find.widgetWithText(RomanButton, 'Certāmen').first);
        for (var i = 0; s.encounter == null && i < 200; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(() async {
        await d.lesson(d.cards[s.encounter!['card']]!);
      });
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final game =
          tester
                  .widget<GameWidget>(
                    find.byWidgetPredicate((w) => w is GameWidget),
                  )
                  .game
              as EncounterScene;
      game.pauseEngine();
      for (final fighter in game.descendants().whereType<Fighter>()) {
        fighter.scale.setValues(1, 1);
      }
      await capture('intro');
      expect(find.text('Incipe!'), findsOneWidget);
      await tester.tap(find.text('Incipe!'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final reference = await tester.runAsync(
        () =>
            File('test/fixtures/visual/question-${width.toInt()}.json')
                .readAsString(),
      );
      s.state['encounter']['question'] = jsonDecode(reference!);
      await s.setting('visualFixture', true);
      await tester.pump();
      await capture('battle');
      await tester.runAsync(() => d.help(s.question!.data['help'] as String));
      await tester.tap(find.widgetWithText(RomanButton, 'Auxilium'));
      await tester.pumpAndSettle();
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.byType(HelpTableView), findsWidgets);
      await capture('help');
      await tester.tap(find.widgetWithText(RomanButton, 'Claude'));
      await tester.pumpAndSettle();
      final q = s.question!;
      final wrong = q.choices.firstWhere((c) => !q.accepted.contains(c['id']));
      await tester.tap(find.widgetWithText(RomanButton, s.text(wrong['text'])));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await capture('correction');
      expect(s.encounter!['phase'], 'feedback');
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
      final forumCard = d.cards.values.firstWhere(
        (card) => card.address.startsWith('forum/'),
      );
      await tester.runAsync(() async {
        await d.lesson(forumCard);
        for (final resource in d.resources.values.where(
          (r) => r['type'] == 'image',
        )) {
          await Flame.images.load(resource['path'] as String);
        }
        await s.start(forumCard);
      });
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: DesignApp(session: s, audioEnabled: false),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(
          RomanButton,
          TrialView(s, forumCard).label('resume'),
        ),
      );
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 150)),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Incipe!'), findsOneWidget);
      await tester.tap(find.text('Incipe!'));
      await tester.pump(const Duration(milliseconds: 300));
      await capture('forum');
      expect(s.encounter!['phase'], 'question');
      expect(find.widgetWithText(RomanButton, 'Auxilium'), findsOneWidget);
      final answer = s.question!.choices.firstWhere(
        (c) => !s.question!.accepted.contains(c['id']),
      );
      await tester.tap(
        find.widgetWithText(RomanButton, s.text(answer['text'])),
      );
      await tester.pump(const Duration(milliseconds: 800));
      expect(s.encounter!['phase'], 'feedback');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
      s.dispose();
    });
  }
}
