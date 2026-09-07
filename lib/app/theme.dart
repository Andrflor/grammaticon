import 'package:flutter/material.dart';

/// Palette and typography of Grammaticon: Roman purple and gold on marble.
///
/// The values follow the reference mock-ups (Tabula, Optiōnēs, certāmina):
/// cream panels framed in gold on a painted marble background, deep purple
/// for the dark panels and the pills of the top bar, Cinzel headings in a
/// dark purple, Nunito for everything else.
abstract final class G {
  // Purples.
  static const Color purple = Color(0xFF5A2A9C);
  static const Color purpleDark = Color(0xFF3D1A66);
  /// Dark panels (Gradūs, Vocābula, speech bubble).
  static const Color purpleDeep = Color(0xFF3A1D5C);
  /// Pills of the top bar (Redī, gem counter).
  static const Color purpleNight = Color(0xFF2F1546);
  static const Color purpleLight = Color(0xFF8D4BE0);
  /// Cinzel headings on cream.
  static const Color purpleTitle = Color(0xFF44207F);
  /// Table headers, toggles.
  static const Color purpleRoyal = Color(0xFF592BA1);

  // Golds.
  static const Color gold = Color(0xFFE0B24A);
  static const Color goldLight = Color(0xFFFFE08A);
  static const Color goldDark = Color(0xFFA8781E);
  /// Thin frames of nested panels, inactive slider track.
  static const Color goldPale = Color(0xFFE2CDA5);
  /// Selected chip background.
  static const Color goldWash = Color(0xFFF5E6B4);

  // Creams.
  static const Color marble = Color(0xFFF8F0DE);
  static const Color marbleDark = Color(0xFFE3D5B8);
  static const Color parchment = Color(0xFFFBF5EA);

  // Inks (purple-tinted greys).
  static const Color ink = Color(0xFF2B2140);
  static const Color inkSoft = Color(0xFF5E5470);

  // Status colours.
  static const Color green = Color(0xFF3CBF55);
  static const Color greenDark = Color(0xFF1E8E3E);
  static const Color red = Color(0xFFE83240);
  static const Color redDark = Color(0xFFB0202E);
  static const Color blue = Color(0xFF1F74EC);
  static const Color amber = Color(0xFFDB9C39);
  static const Color grey = Color(0xFF6B6360);
  static const Color sky = Color(0xFF6FC3FF);
  static const Color gem = Color(0xFFE52EC2);
  static const Color gemGreen = Color(0xFF34C759);
  static const Color white = Color(0xFFFFFFFF);

  /// Small labels were hard to read: every size below 16 is raised by 3 points.
  static double _readable(double size) => size < 16 ? size + 3 : size;

  static TextStyle display(double size, {Color color = gold, double weight = 700, double letterSpacing = 1.2}) =>
      TextStyle(fontFamily: 'Cinzel', fontSize: _readable(size), color: color, fontVariations: [FontVariation('wght', weight)], letterSpacing: letterSpacing, height: 1.15);

  static TextStyle body(double size, {Color color = ink, double weight = 500, FontStyle style = FontStyle.normal, double height = 1.3}) =>
      TextStyle(fontFamily: 'Nunito', fontSize: _readable(size), color: color, fontVariations: [FontVariation('wght', weight)], fontStyle: style, height: height);

  static ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: purple, primary: purple, secondary: gold, surface: marble),
    );
    return base.copyWith(
      scaffoldBackgroundColor: purpleDark,
      textTheme: base.textTheme.apply(fontFamily: 'Nunito', bodyColor: ink, displayColor: ink),
      dialogTheme: DialogThemeData(
        backgroundColor: marble,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: gold, width: 3),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: marble,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      // Gold track and thumb on a pale gold rail, like the mock-up sliders.
      sliderTheme: base.sliderTheme.copyWith(
        trackHeight: 8,
        activeTrackColor: gold,
        inactiveTrackColor: goldPale,
        disabledActiveTrackColor: goldPale,
        disabledInactiveTrackColor: marbleDark,
        thumbColor: gold,
        disabledThumbColor: goldPale,
        overlayColor: const Color(0x33E0B24A),
        activeTickMarkColor: goldLight,
        inactiveTickMarkColor: marbleDark,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 13, elevation: 2),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
        valueIndicatorColor: purpleDeep,
        valueIndicatorTextStyle: body(14, color: goldLight, weight: 800),
      ),
      // On: royal purple track with a gold thumb. Off: grey track, cream thumb.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? gold : const Color(0xFFE8DCBF)),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? const Color(0xFF6834B2) : const Color(0xFF7E7A82)),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        trackOutlineWidth: const WidgetStatePropertyAll(0),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? purple : Colors.transparent),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: const BorderSide(color: purple, width: 2),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: purpleDeep,
        contentTextStyle: body(15, color: goldLight, weight: 700),
      ),
    );
  }
}
