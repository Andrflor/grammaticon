// Vocabulary acquisition of the Theatrum: states from the exposure ledger,
// frequency bands, the gradus that opens the next band, and the selection
// gate that keeps rare vocabulary for later.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/pedagogy/exposure.dart';
import 'package:grammaticon/pedagogy/reading/reading_question_source.dart';
import 'package:grammaticon/pedagogy/reading/vocab_progress.dart';
import 'package:grammaticon/pedagogy/trials.dart';

import '../support/test_env.dart';

void main() {
  final lib = testReadingLibrary;
  final set = lib.forLanguage('fr')!;

  test('a word is obvium once met, nōtum once met twice elsewhere or answered correctly, firmum after two correct answers', () {
    expect(vocabStateOf(const LemmaExposure()), VocabState.ignotum);
    expect(vocabStateOf(const LemmaExposure(seen: 1, passages: ['a'])), VocabState.obvium);
    expect(vocabStateOf(const LemmaExposure(seen: 2, passages: ['a', 'b'])), VocabState.notum);
    expect(vocabStateOf(const LemmaExposure(seen: 1, passages: ['a'], tested: 1, testedCorrect: 1)), VocabState.notum);
    expect(vocabStateOf(const LemmaExposure(seen: 3, passages: ['a', 'b', 'c'], tested: 2, testedCorrect: 2)), VocabState.firmum);
    expect(vocabStateOf(const LemmaExposure(seen: 2, passages: ['a'], tested: 2, testedCorrect: 0)), VocabState.obvium, reason: 'wrong answers do not make a word known');
  });

  test('the dataset assigns every common lemma a frequency band and every item the band of its rarest common word', () {
    expect(set.corpus.bandLimits, isNotEmpty);
    expect(set.corpus.lemmaBands, isNotEmpty);
    for (final e in set.entries) {
      final bands = [for (final l in e.passage.lemmas) set.corpus.lemmaBands[l] ?? 0];
      expect(e.item.band, bands.fold(1, max), reason: e.item.id);
      expect(e.item.band, inInclusiveRange(1, set.corpus.bandCount));
    }
  });

  test('a fresh player is at gradus 1; the next band opens when 60 % of the band is known', () {
    final fresh = VocabProgress.compute(set, const ExposureLedger());
    expect(fresh.level, 1);
    expect(fresh.bands.first.total, greaterThan(0));
    expect(fresh.bands.every((b) => b.nota == 0 && b.obvia == 0), isTrue);
    // Know 60 % of band 1 (met in two passages each).
    final band1 = set.playableLemmas.where((l) => set.corpus.lemmaBands[l] == 1).toList();
    var ledger = const ExposureLedger();
    for (final l in band1.take((band1.length * 0.65).ceil())) {
      ledger = ledger.record(ExposureNote(itemId: 'x', passageId: 'p1', lemmas: [l], targetLemma: ''), autonomousCorrect: false);
      ledger = ledger.record(ExposureNote(itemId: 'y', passageId: 'p2', lemmas: [l], targetLemma: ''), autonomousCorrect: false);
    }
    final vp = VocabProgress.compute(set, ledger);
    expect(vp.level, 2);
    expect(vp.bands.first.knownShare, greaterThanOrEqualTo(0.6));
    expect(vp.bands[1].nota, 0);
  });

  test('question selection only offers items of open bands, widening only when too few remain', () {
    final src = ReadingQuestionSource(lib, language: 'fr');
    for (final t in Trials.ofActivity(Activity.theatrum)) {
      final pool = src.pool(t, t.isMixta ? t.components.map((c) => c.id).toList() : const []);
      final atLevel1 = pool.where((e) => e.item.band <= 1).length;
      final drawn = <int>{};
      for (var seed = 0; seed < 40; seed++) {
        final q = src.generate(trial: t, componentIds: t.isMixta ? t.components.map((c) => c.id).toList() : const [], rng: Random(seed), id: '$seed')!;
        drawn.add(q.reading.entry.item.band);
      }
      if (atLevel1 >= 5) {
        expect(drawn, {1}, reason: '${t.id}: a beginner only meets the most frequent vocabulary');
      } else {
        // widened just enough: never beyond the smallest band set holding 5 items
        var widen = 1;
        while (pool.where((e) => e.item.band <= widen).length < 5 && widen < set.corpus.bandCount) {
          widen++;
        }
        expect(drawn.reduce(max), lessThanOrEqualTo(widen), reason: t.id);
      }
    }
  });
}
