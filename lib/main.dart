import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'app/theme.dart';
import 'audio/audio_service.dart';
import 'linguistics/engine/analyzer.dart';
import 'linguistics/engine/conjugator.dart';
import 'linguistics/engine/declinator.dart';
import 'linguistics/engine/noun_analyzer.dart';
import 'linguistics/lexicon/nouns.dart';
import 'linguistics/lexicon/verbs.dart';
import 'pedagogy/reading/reading_content.dart';
import 'persistence/save_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _Splash());
  // Whole-lexicon index (about 60 000 forms) built once at start-up.
  final analyzer = Analyzer(kVerbs, Conjugator());
  final nounAnalyzer = NounAnalyzer(kNouns, const Declinator());
  // Curated Theatrum content (Latin passages + shipped translation languages).
  final reading = await ReadingLibrary.load(rootBundle);
  final repo = SaveRepository(PrefsSaveStore());
  final save = await repo.load();
  final audio = AudioService();
  await audio.preload();
  audio.volume = save.settings.volume;
  audio.soundOn = save.settings.soundOn;
  audio.setMusic(on: save.settings.musicOn, volume: save.settings.musicVolume);
  unawaited(audio.startMusic());
  runApp(
    ProviderScope(
      overrides: [
        analyzerProvider.overrideWithValue(analyzer),
        nounAnalyzerProvider.overrideWithValue(nounAnalyzer),
        readingLibraryProvider.overrideWithValue(reading),
        saveRepositoryProvider.overrideWithValue(repo),
        initialSaveProvider.overrideWithValue(save),
        audioProvider.overrideWithValue(audio),
      ],
      child: const GrammaticonApp(),
    ),
  );
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: G.theme(),
    home: Scaffold(
      backgroundColor: G.purpleDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('GRAMMATICON', style: G.display(40)),
            const SizedBox(height: 12),
            Text('Fōrmae parantur…', style: G.body(18, color: G.goldLight)),
          ],
        ),
      ),
    ),
  );
}
