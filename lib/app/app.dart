import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../ui/city/city_screen.dart';
import 'providers.dart';
import 'theme.dart';

class GrammaticonApp extends HookConsumerWidget {
  const GrammaticonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Music follows the app: silent in the background, back on resume.
    final audio = ref.read(audioProvider);
    useOnAppLifecycleStateChange((prev, cur) {
      if (cur == AppLifecycleState.resumed) {
        audio.resumeMusic();
      } else if (cur == AppLifecycleState.paused || cur == AppLifecycleState.hidden || cur == AppLifecycleState.inactive) {
        audio.pauseMusic();
      }
    });
    return MaterialApp(title: 'Grammaticon', debugShowCheckedModeBanner: false, theme: G.theme(), home: const CityScreen());
  }
}

/// Pushes a screen with a short fade.
Future<T?> pushScreen<T>(BuildContext context, Widget screen) => Navigator.of(context).push<T>(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondary) => screen,
    transitionsBuilder: (context, a, secondary, child) => FadeTransition(opacity: a, child: child),
    transitionDuration: const Duration(milliseconds: 220),
  ),
);
