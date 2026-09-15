/// Vocabulary acquisition of the Theatrum: where the player stands in the
/// Vulgate's vocabulary, by frequency band, from the exposure ledger.
///
/// Acquisition is *not* grammatical mastery ([SkillRecord]) and is kept
/// apart from it: a word is `obvium` once met, `nōtum` once met in two
/// different passages or answered correctly as the decisive word, `firmum`
/// once it has been the decisive word of two correct autonomous answers.
/// The player's *gradus vocābulōrum* opens the next frequency band when the
/// current one is largely known; question selection uses it so that rare
/// vocabulary arrives progressively.
library;

import '../exposure.dart';
import 'reading_content.dart';

enum VocabState {
  ignotum('Ignōtum'),
  obvium('Obvium'),
  notum('Nōtum'),
  firmum('Firmum');

  const VocabState(this.latin);
  final String latin;
}

VocabState vocabStateOf(LemmaExposure x) {
  if (x.testedCorrect >= 2) return VocabState.firmum;
  if (x.revisited || x.testedCorrect >= 1) return VocabState.notum;
  if (x.seen > 0) return VocabState.obvium;
  return VocabState.ignotum;
}

/// Counts of one frequency band (or of the proper-name group, band 0).
class BandProgress {
  const BandProgress({required this.band, required this.total, required this.obvia, required this.nota, required this.firma});
  final int band;

  /// Entries of this band present in the playable content.
  final int total;
  final int obvia;
  final int nota;
  final int firma;

  /// Share of entries at least nōta.
  double get knownShare => total == 0 ? 0 : (nota + firma) / total;
  double get metShare => total == 0 ? 0 : (obvia + nota + firma) / total;

  /// Latin label: "Vocābula I" … "Vocābula V"; band 0 = names.
  String get latin => band == 0 ? 'Nōmina propria' : 'Gradus ${'I II III IV V VI VII'.split(' ')[band - 1]}';
}

class VocabProgress {
  const VocabProgress({required this.bands, required this.level, required this.names});

  /// Bands 1..n in order.
  final List<BandProgress> bands;

  /// Highest band whose items are offered (1-based). Band `level` is open;
  /// band `level + 1` opens when band `level` is largely known.
  final int level;
  final BandProgress names;

  /// Share of a band that must be nōta before the next band opens.
  static const double openShare = 0.6;

  static VocabProgress compute(ReadingSet set, ExposureLedger ledger) {
    final bandOf = set.corpus.lemmaBands;
    final maxBand = set.corpus.bandCount;
    final counts = {for (var b = 0; b <= maxBand; b++) b: [0, 0, 0, 0]};
    for (final lemma in set.playableLemmas) {
      final b = bandOf[lemma] ?? 0;
      final st = vocabStateOf(ledger.of(lemma));
      counts[b]![0]++;
      switch (st) {
        case VocabState.ignotum:
          break;
        case VocabState.obvium:
          counts[b]![1]++;
        case VocabState.notum:
          counts[b]![2]++;
        case VocabState.firmum:
          counts[b]![3]++;
      }
    }
    BandProgress bp(int b) => BandProgress(band: b, total: counts[b]![0], obvia: counts[b]![1], nota: counts[b]![2], firma: counts[b]![3]);
    final bands = [for (var b = 1; b <= maxBand; b++) bp(b)];
    var level = 1;
    for (final b in bands) {
      if (b.total > 0 && b.knownShare >= openShare && level < maxBand) {
        level = b.band + 1;
      } else {
        break;
      }
    }
    return VocabProgress(bands: bands, level: level, names: bp(0));
  }
}
