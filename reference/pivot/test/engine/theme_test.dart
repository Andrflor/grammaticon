import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/app/theme.dart';
import 'package:grammaticon/engine/design.dart';
import 'package:grammaticon/ui/widgets/roman_widgets.dart';

import 'design_test.dart' show readFile, demo;

void main() {
  test('both palettes cover every painted UI token', () async {
    final designs = [
      await demo(),
      await GameDesign.load('assets/designs/grammaticon/game.json', readFile),
    ];
    final tokens = <String>{};
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final source = file.readAsStringSync();
      tokens.addAll(
        RegExp(r"paint\('([A-F0-9]{8})'\)")
            .allMatches(source)
            .map((m) => m[1]!),
      );
      if (file.path.startsWith('lib/ui/')) {
        expect(
          RegExp(r'Color\(0x').hasMatch(source),
          false,
          reason: '${file.path} must read authored colors',
        );
      }
    }
    for (final d in designs) {
      final skin = G(object(d.root['theme']));
      for (final token in tokens) {
        expect(
          () => skin.paint(token),
          returnsNormally,
          reason: '${d.identity}: $token',
        );
      }
    }
    final palette = object(designs.first.root['theme']['paintedPalette']);
    // The button, card header, HUD and speech-bubble shades that remained purple.
    for (final token in [
      'FF542C9D',
      'FF7E4BCC',
      'FF6A37C4',
      'FF6840AE',
      'FF3B2062',
      'FF2B1444',
      'FF3F2266',
      'FF33194F',
    ]) {
      expect(
        palette[token],
        isNot(token),
        reason: 'Compass must override $token',
      );
    }
  });

  testWidgets('button fill follows a changed JSON palette on rebuild', (
    tester,
  ) async {
    final d = (await tester.runAsync(demo))!;
    final theme = object(d.root['theme']);
    for (final hex in ['FF147D64', 'FFB24B20']) {
      final configured = {
        ...theme,
        'paintedPalette': {...object(theme['paintedPalette']), 'FF542C9D': hex},
      };
      final skin = G(configured);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RomanButton(skin: skin, label: 'Test', onPressed: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(RomanButton),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, Color(int.parse(hex, radix: 16)));
    }
  });
}
