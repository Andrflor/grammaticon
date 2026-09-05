import 'package:flutter/material.dart';

import '../ui/city/city_screen.dart';
import 'theme.dart';

class GrammaticonApp extends StatelessWidget {
  const GrammaticonApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Grammaticon',
        debugShowCheckedModeBanner: false,
        theme: G.theme(),
        home: const CityScreen(),
      );
}

/// Pushes a screen with a short fade.
Future<T?> pushScreen<T>(BuildContext context, Widget screen) => Navigator.of(context).push<T>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondary) => screen,
        transitionsBuilder: (context, a, secondary, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
