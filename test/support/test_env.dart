// Shared test environment: analyzers built once, provider overrides for a
// container or a widget tree with an in-memory save store.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latin_game/app/providers.dart';
import 'package:latin_game/audio/audio_service.dart';
import 'package:latin_game/linguistics/engine/analyzer.dart';
import 'package:latin_game/linguistics/engine/conjugator.dart';
import 'package:latin_game/linguistics/engine/declinator.dart';
import 'package:latin_game/linguistics/engine/noun_analyzer.dart';
import 'package:latin_game/linguistics/lexicon/nouns.dart';
import 'package:latin_game/linguistics/lexicon/verbs.dart';
import 'package:latin_game/persistence/save_data.dart';
import 'package:latin_game/persistence/save_repository.dart';

final Analyzer testAnalyzer = Analyzer(kVerbs, Conjugator());
final NounAnalyzer testNounAnalyzer = NounAnalyzer(kNouns, const Declinator());

/// A [ProviderScope] with both lexicons, an in-memory store and silent audio.
Widget testScope(MemorySaveStore store, {SaveData? initial, required Widget child}) => ProviderScope(
      overrides: [
        analyzerProvider.overrideWithValue(testAnalyzer),
        nounAnalyzerProvider.overrideWithValue(testNounAnalyzer),
        saveRepositoryProvider.overrideWithValue(SaveRepository(store)),
        initialSaveProvider.overrideWithValue(initial ?? SaveData(createdAt: DateTime(2026, 1, 1))),
        audioProvider.overrideWithValue(AudioService(enabled: false)),
      ],
      child: child,
    );

(ProviderContainer, MemorySaveStore) testContainer({SaveData? initial}) {
  final store = MemorySaveStore();
  final c = ProviderContainer(
    overrides: [
      analyzerProvider.overrideWithValue(testAnalyzer),
      nounAnalyzerProvider.overrideWithValue(testNounAnalyzer),
      saveRepositoryProvider.overrideWithValue(SaveRepository(store)),
      initialSaveProvider.overrideWithValue(initial ?? SaveData(createdAt: DateTime(2026, 1, 1))),
      audioProvider.overrideWithValue(AudioService(enabled: false)),
    ],
  );
  return (c, store);
}
