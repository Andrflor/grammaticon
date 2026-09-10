import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/engine/application.dart';
import 'package:grammaticon/engine/session.dart';

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
    testWidgets('unrelated design navigates and plays at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final d = (await tester.runAsync(demo))!;
      final s = GameSession(d, {}, (_) async {});
      s.state['settings']['sound'] = false;
      s.state['settings']['music'] = false;
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: DesignApp(session: s),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Le Cabinet des repères'), findsWidgets);
      expect(find.text('Observatoire'), findsOneWidget);
      await tester.runAsync(
        () => s.start(d.cards['observatory/discovery/durations']!),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reprendre'));
      await tester.pumpAndSettle();
      expect(find.text('Commencer'), findsOneWidget);
      await tester.tap(find.text('Commencer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Aide'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        for (final id in ['forum_bg', 'orator_idle', 'rhetor_rhetor']) {
          await precacheImage(AssetImage(d.asset(id)), context);
        }
      });
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('/tmp/design-compass-${width.toInt()}.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
      final q = s.question!;
      final wrong = q.choices.firstWhere((c) => !q.accepted.contains(c['id']));
      final choice = find.text(
        '${q.choices.indexWhere((c) => c['id'] == wrong['id']) + 1}. ${s.text(wrong['text'])}',
      );
      await tester.ensureVisible(choice);
      await tester.tap(choice);
      await tester.pumpAndSettle();
      expect(s.state['observations'], hasLength(1));
      expect(s.encounter!['phase'], 'feedback');
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Observations'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Hypothèses'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
