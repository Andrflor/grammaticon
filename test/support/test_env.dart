// Shared test environment: analyzers built once, provider overrides for a
// container or a widget tree with an in-memory save store.
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grammaticon/arbor/contextus.dart';
import 'package:grammaticon/arbor/evidence.dart';
import 'package:grammaticon/pedagogy/mastery.dart';
import 'package:grammaticon/pedagogy/frames/frame_content.dart';
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

/// Les tests d'écran Iter doivent réellement lancer une séance guidée après
/// ses découvertes, et non un combat manuel sans cible ni exposition.
ArborEvidence testDiscoveries(Set<String> sections) {
  final now = DateTime.now();
  var record = const SkillRecord();
  for (var i = 0; i < 5; i++) {
    record = record.apply(Observation(at: now, correct: true, lemmaId: 'example-$i',
      quality: AnswerQuality.autonoma, trialId: 'fixture'), const MasteryConfig());
  }
  return ArborEvidence(records: {
    for (final node in contextusNodes())
      if (sections.any((s) => node.id.startsWith('lect.intellectus.$s.') || node.id.startsWith('lect.thema.$s.'))) node.id: record,
  });
}

/// The shipped Theatrum content, read from the asset files on disk.
final ReadingLibrary testReadingLibrary = ReadingLibrary.parse(
  latinJson: File(ReadingLibrary.latinAsset).readAsStringSync(),
  renderingsJson: {
    for (final lang in ReadingLibrary.languages)
      if (File(ReadingLibrary.renderingsAsset(lang)).existsSync()) lang: File(ReadingLibrary.renderingsAsset(lang)).readAsStringSync(),
  },
);

/// Frame cards of the Theatrum and Templum, read from the embedded assets.
final FrameLibrary testFrameLibrary = FrameLibrary(
  [
    for (final place in ['theatrum', 'templum'])
      if (File('assets/arbor/frames/$place.json').existsSync()) ...FrameLibrary.parse(File('assets/arbor/frames/$place.json').readAsStringSync()).frames,
  ],
  help: File('assets/arbor/frames/help.json').existsSync() ? FrameLibrary.parseHelp(File('assets/arbor/frames/help.json').readAsStringSync()) : const {},
);

/// A [ProviderScope] with both lexicons, an in-memory store and silent audio.
Widget testScope(MemorySaveStore store, {SaveData? initial, required Widget child}) => ProviderScope(
      overrides: [
        analyzerProvider.overrideWithValue(testAnalyzer),
        nounAnalyzerProvider.overrideWithValue(testNounAnalyzer),
        nominalAnalyzerProvider.overrideWithValue(testNominalAnalyzer),
        readingLibraryProvider.overrideWithValue(testReadingLibrary),
        frameLibraryProvider.overrideWithValue(testFrameLibrary),
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
      frameLibraryProvider.overrideWithValue(testFrameLibrary),
      saveRepositoryProvider.overrideWithValue(SaveRepository(store)),
      initialSaveProvider.overrideWithValue(initial ?? SaveData(createdAt: DateTime(2026, 1, 1))),
      audioProvider.overrideWithValue(AudioService(enabled: false)),
    ],
  );
  return (c, store);
}
