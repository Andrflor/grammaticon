// Shared test environment: analyzers built once, provider overrides for a
// container or a widget tree with an in-memory save store.
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grammaticon/app/providers.dart';
import 'package:grammaticon/audio/audio_service.dart';
import 'package:grammaticon/linguistics/engine/analyzer.dart';
import 'package:grammaticon/linguistics/engine/conjugator.dart';
import 'package:grammaticon/linguistics/engine/declinator.dart';
import 'package:grammaticon/linguistics/engine/nominal_analyzer.dart';
import 'package:grammaticon/linguistics/engine/noun_analyzer.dart';
import 'package:grammaticon/linguistics/lexicon/forum_lexicon.dart';
import 'package:grammaticon/linguistics/lexicon/nouns.dart';
import 'package:grammaticon/linguistics/lexicon/verbs.dart';
import 'package:grammaticon/pedagogy/reading/reading_content.dart';
import 'package:grammaticon/persistence/save_data.dart';
import 'package:grammaticon/persistence/save_repository.dart';

final Analyzer testAnalyzer = Analyzer(kVerbs, Conjugator());
final NounAnalyzer testNounAnalyzer = NounAnalyzer(kNouns, const Declinator());

/// The whole nominal lexicon of the Forum, built once for every test.
final NominalAnalyzer testNominalAnalyzer = buildNominalAnalyzer(nouns: testNounAnalyzer);

/// The shipped Theatrum content, read from the asset files on disk.
final ReadingLibrary testReadingLibrary = ReadingLibrary.parse(
  latinJson: File(ReadingLibrary.latinAsset).readAsStringSync(),
  renderingsJson: {
    for (final lang in ReadingLibrary.languages)
      if (File(ReadingLibrary.renderingsAsset(lang)).existsSync()) lang: File(ReadingLibrary.renderingsAsset(lang)).readAsStringSync(),
  },
);

/// A [ProviderScope] with both lexicons, an in-memory store and silent audio.
Widget testScope(MemorySaveStore store, {SaveData? initial, required Widget child}) => ProviderScope(
      overrides: [
        analyzerProvider.overrideWithValue(testAnalyzer),
        nounAnalyzerProvider.overrideWithValue(testNounAnalyzer),
        nominalAnalyzerProvider.overrideWithValue(testNominalAnalyzer),
        readingLibraryProvider.overrideWithValue(testReadingLibrary),
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
      nominalAnalyzerProvider.overrideWithValue(testNominalAnalyzer),
      readingLibraryProvider.overrideWithValue(testReadingLibrary),
      saveRepositoryProvider.overrideWithValue(SaveRepository(store)),
      initialSaveProvider.overrideWithValue(initial ?? SaveData(createdAt: DateTime(2026, 1, 1))),
      audioProvider.overrideWithValue(AudioService(enabled: false)),
    ],
  );
  return (c, store);
}
