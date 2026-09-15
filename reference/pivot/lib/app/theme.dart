import 'package:flutter/material.dart';

import '../engine/design.dart';

/// Original visual tokens supplied by the selected design.
class G {
  G(this.data, {this.onCue});
  final void Function(String)? onCue;
  final Json data;
  String get headingFont => data['headingFont'] as String;
  String get bodyFont => data['bodyFont'] as String;
  Color paint(String token) =>
      Color(int.parse(data['paintedPalette'][token] as String, radix: 16));
  Color get purple => paint('FF5A2A9C');
  Color get purpleDark => paint('FF3D1A66');
  Color get purpleDeep => paint('FF3A1D5C');
  Color get purpleNight => paint('FF2F1546');
  Color get purpleLight => paint('FF8D4BE0');
  Color get purpleTitle => paint('FF44207F');
  Color get purpleRoyal => paint('FF592BA1');
  Color get gold => paint('FFE0B24A');
  Color get goldLight => paint('FFFFE08A');
  Color get goldDark => paint('FFA8781E');
  Color get goldPale => paint('FFE2CDA5');
  Color get goldWash => paint('FFF5E6B4');
  Color get marble => paint('FFF8F0DE');
  Color get marbleDark => paint('FFE3D5B8');
  Color get parchment => paint('FFFBF5EA');
  Color get ink => paint('FF2B2140');
  Color get inkSoft => paint('FF5E5470');
  Color get green => paint('FF3CBF55');
  Color get greenDark => paint('FF1E8E3E');
  Color get red => paint('FFE83240');
  Color get redDark => paint('FFB0202E');
  Color get blue => paint('FF1F74EC');
  Color get amber => paint('FFDB9C39');
  Color get grey => paint('FF6B6360');
  Color get sky => paint('FF6FC3FF');
  Color get gem => paint('FFE52EC2');
  Color get gemGreen => paint('FF34C759');
  Color get white => paint('FFFFFFFF');
  List<Color> get inscriptionGold => [
    paint('FFFFF3B0'),
    paint('FFF8DE84'),
    paint('FFE8BF58'),
  ];
  List<Shadow> get headingShadow => [
    Shadow(color: paint('FF24103F'), offset: const Offset(0, 2), blurRadius: 2),
    Shadow(color: paint('FF200A40'), blurRadius: 5),
    Shadow(color: paint('CC200A40'), blurRadius: 14),
  ];

  /// Small labels were hard to read: every size below 16 is raised by 3 points.
  double _readable(double size) => size < 16 ? size + 3 : size;

  TextStyle display(
    double size, {
    Color? color,
    double weight = 700,
    double letterSpacing = 1.2,
  }) => TextStyle(
    fontFamily: headingFont,
    fontSize: _readable(size),
    color: color ?? gold,
    fontVariations: [FontVariation('wght', weight)],
    letterSpacing: letterSpacing,
    height: 1.15,
  );

  TextStyle body(
    double size, {
    Color? color,
    double weight = 500,
    FontStyle style = FontStyle.normal,
    double height = 1.3,
  }) => TextStyle(
    fontFamily: bodyFont,
    fontSize: _readable(size),
    color: color ?? ink,
    fontVariations: [FontVariation('wght', weight)],
    fontStyle: style,
    height: height,
  );

  ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: purple,
        primary: purple,
        secondary: gold,
        surface: marble,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: purpleDark,
      textTheme: base.textTheme.apply(
        fontFamily: bodyFont,
        bodyColor: ink,
        displayColor: ink,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: marble,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: gold, width: 3),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: marble,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
        overlayColor: paint('33E0B24A'),
        activeTickMarkColor: goldLight,
        inactiveTickMarkColor: marbleDark,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 13, elevation: 2),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 22),
        valueIndicatorColor: purpleDeep,
        valueIndicatorTextStyle: body(14, color: goldLight, weight: 800),
      ),
      // On: royal purple track with a gold thumb. Off: grey track, cream thumb.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? gold : paint('FFE8DCBF'),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? paint('FF6834B2')
              : paint('FF7E7A82'),
        ),
        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
        trackOutlineWidth: WidgetStatePropertyAll(0),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? purple : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(Colors.white),
        side: BorderSide(color: purple, width: 2),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: purpleDeep,
        contentTextStyle: body(15, color: goldLight, weight: 700),
      ),
    );
  }
}
