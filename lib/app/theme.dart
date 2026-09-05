import 'package:flutter/material.dart';

/// Palette and typography of Grammaticon: Roman purple and gold on marble.
abstract final class G {
  static const Color purple = Color(0xFF5A2A9C);
  static const Color purpleDark = Color(0xFF3D1A66);
  static const Color purpleLight = Color(0xFF8D4BE0);
  static const Color gold = Color(0xFFE0B24A);
  static const Color goldLight = Color(0xFFFFE08A);
  static const Color goldDark = Color(0xFFA8781E);
  static const Color marble = Color(0xFFF6EED9);
  static const Color marbleDark = Color(0xFFD9C9A3);
  static const Color ink = Color(0xFF3A2A1A);
  static const Color inkSoft = Color(0xFF6B5A48);
  static const Color green = Color(0xFF34C759);
  static const Color greenDark = Color(0xFF1E7F38);
  static const Color red = Color(0xFFE0333F);
  static const Color redDark = Color(0xFF8A1030);
  static const Color sky = Color(0xFF6FC3FF);
  static const Color gem = Color(0xFFE52EC2);
  static const Color gemGreen = Color(0xFF34C759);
  static const Color white = Color(0xFFFFFFFF);

  static TextStyle display(double size, {Color color = gold, double weight = 700, double letterSpacing = 1.2}) => TextStyle(
        fontFamily: 'Cinzel',
        fontSize: size,
        color: color,
        fontVariations: [FontVariation('wght', weight)],
        letterSpacing: letterSpacing,
        height: 1.15,
      );

  static TextStyle body(double size, {Color color = ink, double weight = 500, FontStyle style = FontStyle.normal, double height = 1.3}) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: size,
        color: color,
        fontVariations: [FontVariation('wght', weight)],
        fontStyle: style,
        height: height,
      );

  static ThemeData theme() {
    final base = ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: purple, primary: purple, secondary: gold, surface: marble));
    return base.copyWith(
      scaffoldBackgroundColor: purpleDark,
      textTheme: base.textTheme.apply(fontFamily: 'Nunito', bodyColor: ink, displayColor: ink),
      dialogTheme: DialogThemeData(backgroundColor: marble, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: gold, width: 3))),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: marble, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24)))),
      sliderTheme: base.sliderTheme.copyWith(activeTrackColor: gold, thumbColor: gold, inactiveTrackColor: marbleDark),
      switchTheme: SwitchThemeData(thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? gold : marbleDark), trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? purple : inkSoft)),
      snackBarTheme: SnackBarThemeData(backgroundColor: purpleDark, contentTextStyle: body(15, color: goldLight, weight: 700)),
    );
  }
}
