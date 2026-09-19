import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/arbor/arbor.dart';
import 'package:grammaticon/arbor/contextus.dart';
import 'package:grammaticon/arbor/diagnosis.dart';
import 'package:grammaticon/arbor/evidence.dart';
import 'package:grammaticon/linguistics/engine/analyzer.dart';
import 'package:grammaticon/linguistics/engine/conjugator.dart';
import 'package:grammaticon/linguistics/lexicon/forum_lexicon.dart';
import 'package:grammaticon/linguistics/lexicon/verbs.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/frames/frame_catalogue.dart';
import 'package:grammaticon/pedagogy/frames/frame_content.dart';
import 'package:grammaticon/pedagogy/frames/frame_lexicon.dart';
import 'package:grammaticon/pedagogy/frames/frame_question_source.dart';
import 'package:grammaticon/pedagogy/frames/frame_trials.dart';
import 'package:grammaticon/pedagogy/iter.dart';
import 'package:grammaticon/pedagogy/mastery.dart';
import 'package:grammaticon/pedagogy/question_generator.dart';
import 'package:grammaticon/pedagogy/trials.dart';

void main() {
  final library = FrameLibrary([
    for (final place in ['theatrum', 'templum'])
      ...FrameLibrary.parse(File('assets/arbor/frames/$place.json').readAsStringSync()).frames,
  ]);
  final source = FrameQuestionSource(library);
  final trials = Trials.all.where((t) => t.filter is FrameFilter).toList();

  test('every authored variant is playable; every sentence card has 200 distinct questions', () {
    var total = 0;
    final seenFrames = <String>{};
    final counts = <String, int>{};
    for (final trial in trials) {
      final pool = source.pool(trial);
      final signatures = <String>{};
      for (final frame in pool) {
        seenFrames.add(frame.id);
        expect(frame.variantCount, frame.instances, reason: '${frame.id}: silently sampled bank');
        for (var i = 0; i < frame.variantCount; i++) {
          final instance = frame.instantiateAt(i);
          final correct = [for (var c = 0; c < frame.choices.length; c++) if (frame.choices[c].accepted) instance.choices[c]];
          expect(instance.surface, isNotEmpty, reason: frame.id);
          expect(correct, isNotEmpty, reason: frame.id);
          expect(instance.choices.toSet().length, instance.choices.length, reason: '${frame.id}: duplicated choices');
          expect(instance.vocabulary.every(kFrameLexemes.containsKey), isTrue, reason: frame.id);
          expect(instance.evidenceId, isNotEmpty, reason: frame.id);
          signatures.add(jsonEncode([instance.surface, correct]));
          total++;
        }
      }
      if (!pool.first.isVocabulary) {
        expect(signatures.length, greaterThanOrEqualTo(200), reason: trial.id);
        counts[pool.first.card] = signatures.length;
      }
    }
    // This is deliberately a lower bound on the original retained bank, not a
    // snapshot that can pass after throwing away hundreds of thousands of rows.
    expect(total, greaterThan(700000));
    expect(seenFrames.length, library.frames.length, reason: 'no authored frame may be silently filtered out');
    for (final place in ['theatrum', 'templum']) {
      final values = counts.entries.where((e) => e.key.startsWith('$place/')).map((e) => e.value);
      // ignore: avoid_print
      print('$place: ${values.length} cartes, ${values.reduce((a, b) => a + b)} questions distinctes, minimum ${values.reduce(min)}');
    }
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('five new lexical entries per card; finals contain only this section’s introductions', () {
    for (final tuple in [(kTheatrumSections, kTheatrumCards, 'theatrum'), (kTemplumSections, kTemplumCards, 'templum')]) {
      final (sections, cards, place) = tuple;
      final byId = {for (final c in cards) c.id: c};
      final previous = <String>{};
      for (final section in sections) {
        final newWords = <String>{};
        for (final id in section.cards.where((id) => id != 'vocabula')) {
          final card = byId['$place/${section.id}/$id']!;
          final first = card.vocabulary.toSet().difference(previous);
          expect(card.newVocabulary.toSet(), first, reason: card.id);
          expect(first.length, greaterThanOrEqualTo(5), reason: card.id);
          newWords.addAll(first);
          previous.addAll(card.vocabulary);
          final introducedInQuestions = <String>{};
          // Introductions carry lexical metadata with the exact variant. Do
          // not substitute the union of all frame variants for actual exposure.
          for (final frame in library.forCard(card.id)) {
            if (frame.aligned case PackedFrameRows rows) {
              for (final encoded in rows.columns[frame.slotCount]) {
                introducedInQuestions.addAll((jsonDecode(encoded) as List).cast<String>());
              }
            }
          }
          expect(introducedInQuestions, containsAll(first), reason: card.id);
        }
        final finals = library.forCard('$place/${section.id}/vocabula');
        expect(finals.map((f) => f.targetLexeme).toSet(), newWords, reason: '$place/${section.id}');
      }
    }
  });

  test('selection never replays one of the twelve recent surfaces when alternatives exist', () {
    final rng = Random(907);
    for (final trial in trials) {
      var exposure = const ExposureLedger();
      final recent = <String>[], evidence = <String>[];
      for (var i = 0; i < 30; i++) {
        final q = source.generate(trial: trial, componentIds: const [], rng: rng, id: '$i',
          recentSurfaces: recent, recentLemmas: evidence, exposure: exposure)!;
        expect(recent, isNot(contains(q.surface)), reason: '${trial.id}: ${q.surface}');
        recent.add(q.surface);
        if (recent.length > 12) recent.removeAt(0);
        evidence.add(q.lemmaId);
        if (evidence.length > 3) evidence.removeAt(0);
        exposure = exposure.record(q.exposure!, autonomousCorrect: true);
      }
    }
  });

  test('lexical success and confusion affect the tested words, independently in both directions', () {
    final analyzer = Analyzer(kVerbs, Conjugator());
    final nominal = buildNominalAnalyzer();
    final arbor = Arbor.standard(analyzer: analyzer, nominal: nominal);
    final verbs = QuestionGenerator(analyzer);
    final forum = ForumQuestionSource(nominal, kSyntagmata);
    final dx = Diagnostician(arbor, verbs, forum);
    final coverage = TrialCoverage.build(verbs, forum, diagnostician: dx, frames: source);
    final q = source.generate(trial: Trials.byId('th-loca-vocabula'), componentIds: const [], rng: Random(17), id: 'lex')!;
    final word = q.frame.frame.targetLexeme!;
    final read = vocabularyNodeId('theatrum', word), write = vocabularyNodeId('templum', word);
    expect(dx.credited(q), {contextNodeId('theatrum/loca/vocabula'), read});
    expect(coverage.of(q.trialId), contains(read));
    final wrong = q.choices.firstWhere((c) => !q.isCorrect(c.value));
    final index = int.parse(wrong.value.substring(1));
    final chosen = q.frame.frame.choices[index].lexeme!;
    final diagnosis = dx.diagnose(q, wrong.value);
    expect(diagnosis.observed, contains(read));
    expect(diagnosis.confusedWith, {vocabularyNodeId('theatrum', chosen)});
    final evidence = const ArborEvidence().observe(arbor: arbor, diagnosis: const Diagnosis(), credited: dx.credited(q),
      correct: true, quality: AnswerQuality.autonoma, lemmaId: q.lemmaId, trialId: q.trialId, now: DateTime(2026, 9, 19),
      place: 'theatrum', availableLemmas: q.frame.lemmaCapacity);
    expect(evidence.of(read).autonomousCorrect, 1);
    expect(evidence.of(read).lemmaCapacity, 1);
    expect(evidence.records.containsKey(write), isFalse);
    final sentence = source.generate(trial: Trials.byId('th-loca-a-ablative'), componentIds: const [], rng: Random(9), id: 'sentence')!;
    expect(sentence.exposure!.lemmas, isNotEmpty);
    expect(sentence.exposure!.targetLemma, isEmpty);
    expect(dx.credited(sentence).any((id) => id.startsWith('lect.vocabula.')), isFalse);
  });
}
