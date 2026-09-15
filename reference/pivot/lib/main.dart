import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'engine/application.dart';
import 'engine/assets.dart';
import 'engine/design.dart';
import 'engine/session.dart';

const designPath = String.fromEnvironment(
  'GAME_DESIGN',
  defaultValue: 'assets/designs/grammaticon/game.json',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final design = await GameDesign.load(designPath, readDesignAsset);
    for (final font in design.resources.values.where(
      (r) => r['type'] == 'font',
    )) {
      await (FontLoader(
        font['family'] as String,
      )..addFont(rootBundle.load(font['path'] as String))).load();
    }
    final preferences = await SharedPreferences.getInstance();
    final key = '${design.id}.save';
    final raw = preferences.getString(key);
    final session = GameSession(
      design,
      raw == null ? {} : object(jsonDecode(raw)),
      (value) async {
        if (!await preferences.setString(key, value)) {
          throw StateError('Could not persist the transaction');
        }
      },
    );
    await session.recover();
    runApp(DesignApp(session: session));
  } catch (error) {
    // A malformed design cannot supply a reliable localized application UI.
    runApp(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: SelectableText('Unable to load the game design:\n$error'),
          ),
        ),
      ),
    );
  }
}
