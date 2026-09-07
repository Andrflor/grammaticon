// The curated Theatrum content: shipped data is validated the way the build
// script validates it, and the reading source builds well-formed questions
// aligned with the morphological progression.
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:latin_game/battle/answer_resolver.dart';
import 'package:latin_game/pedagogy/mastery.dart';
import 'package:latin_game/pedagogy/progression.dart';
import 'package:latin_game/pedagogy/question.dart';
import 'package:latin_game/pedagogy/reading/reading_content.dart';
import 'package:latin_game/pedagogy/reading/reading_question_source.dart';
import 'package:latin_game/pedagogy/reading/reading_trials.dart';
import 'package:latin_game/pedagogy/skills.dart';
import 'package:latin_game/pedagogy/trials.dart';
import 'package:latin_game/persistence/save_data.dart';

import '../support/test_env.dart';

void main() {
  final lib = testReadingLibrary;
  final set = lib.forLanguage('fr')!;
  final theatrum = Trials.ofActivity(Activity.theatrum);
  final base = theatrum.where((t) => !t.isMixta).toList();

  test('the shipped datasets carry explicit edition identifiers and never claim the 1901 printing', () {
    expect(lib.corpus.edition.id, 'latVUC');
    expect(lib.corpus.edition.language, 'la');
    expect(lib.corpus.edition.title, contains('Migne 1880'));
    expect(lib.corpus.edition.title, isNot(contains('1901')));
    expect(lib.corpus.edition.requested, contains('1901'));
    expect(lib.corpus.edition.note, isNotEmpty);
    expect(set.renderings.edition.id, 'fraLSG');
    expect(set.renderings.language, 'fr');
    expect(set.renderings.edition.title, contains('Louis Segond 1910'));
    expect(lib.supports('fr'), isTrue);
    expect(lib.supports('en'), isFalse, reason: 'English content does not exist yet');
    expect(lib.forLanguage('en'), isNull);
  });

  test('every item is validated, complete and unique; every passage is an exact span of its verse', () {
    expect(set.entries.length, greaterThanOrEqualTo(120));
    final ids = <String>{};
    for (final e in set.entries) {
      expect(ids.add(e.item.id), isTrue, reason: e.item.id);
      expect(e.item.status, 'validated');
      expect(e.passage.verse, contains(e.passage.text));
      expect(e.passage.text.length, lessThanOrEqualTo(240));
      expect(e.passage.text, contains(e.item.target.span), reason: e.item.id);
      expect(e.passage.words, isNotEmpty);
      for (final w in e.passage.words) {
        expect(e.gloss(w.lemma), isNotNull, reason: '${e.item.id}: gloss for ${w.lemma}');
      }
      expect(e.renderings.correct, isNotEmpty);
      expect(e.renderings.distractors.length, 3, reason: e.item.id);
      final texts = <String>{for (final c in e.renderings.correct) c.text.toLowerCase()};
      for (final d in e.renderings.distractors) {
        expect(texts.add(d.text.toLowerCase()), isTrue, reason: '${e.item.id}: distractor identical to another choice');
        expect(d.span, isNotEmpty);
        expect(e.passage.text, contains(d.span), reason: '${e.item.id}: ${d.span}');
        expect(d.correctAnalysis, isNotEmpty);
        expect(d.wrongAnalysis, isNotEmpty);
        expect(d.shift, isNotEmpty);
        expect(d.explanation, isNotEmpty);
        expect(Distinctions.all, contains(d.distinction));
        expect(Skills.maybe(d.skillId), isNotNull, reason: d.skillId);
        if (d.formSkillId.isNotEmpty) expect(Skills.maybe(d.formSkillId), isNotNull, reason: '${e.item.id}: ${d.formSkillId}');
      }
      // Every choice uses the same typography: the faithful rendering must not stand out.
      for (final c in [...e.renderings.correct, ...e.renderings.distractors.map((d) => Rendering(id: d.id, text: d.text, source: 'x'))]) {
        expect(c.text, isNot(contains("'")), reason: '${e.item.id}: straight apostrophe in "${c.text}"');
      }
      final correct = e.renderings.correct.first;
      expect(['LSG', 'paed'], contains(correct.source));
      if (correct.source == 'LSG') {
        expect(e.renderings.verse.toLowerCase().replaceAll(' ', ''), contains(correct.text.toLowerCase().replaceAll(' ', '')), reason: e.item.id);
        expect(correct.ref, isNotEmpty);
      }
    }
  });

  test('distractors never require a distinction above the trial\'s level (progression alignment)', () {
    for (final e in set.entries) {
      final allowed = ReadingTrials.allowedDistinctions(e.item.trialId, Trials.byId);
      for (final d in e.renderings.distractors) {
        expect(allowed, contains(d.distinction), reason: '${e.item.id}: ${d.distinction} not allowed in ${e.item.trialId}');
      }
      expect(e.item.distinctions, e.renderings.distractors.map((d) => d.distinction).toSet());
      // The trial's own distinction is what the item credits.
      expect(e.item.skillId, Trials.byId(e.item.trialId).primarySkill);
      expect(Skills.isWithin(e.item.skillId, 'l'), isTrue);
    }
    // The first trial is free and relies on number alone.
    final first = Trials.byId('th-numerus');
    expect(first.isFree, isTrue);
    expect(ReadingTrials.allowedDistinctions('th-numerus', Trials.byId), {Distinctions.numerus});
  });

  test('every Theatrum trial, base or mixed, has at least ten playable items and the graph is acyclic and reachable', () {
    final src = ReadingQuestionSource(lib, language: 'fr');
    for (final t in theatrum) {
      final comps = Progression.componentsFor(const SaveData(), t);
      expect(src.pool(t, comps).length, greaterThanOrEqualTo(10), reason: t.id);
      for (final p in t.prerequisites) {
        expect(Trials.byId(p).activity, Activity.theatrum, reason: 'prerequisites stay inside the activity');
      }
    }
    // Reachability from the free trial by buying everything in order.
    var save = SaveData(gems: 100000);
    var progress = true;
    while (progress) {
      progress = false;
      for (final t in theatrum) {
        if (Progression.canPurchase(save, t)) {
          save = save.copyWith(gems: save.gems - t.price, purchased: {...save.purchased, t.id});
          progress = true;
        }
      }
    }
    for (final t in theatrum) {
      expect(Progression.isAccessible(save, t), isTrue, reason: t.id);
    }
    expect(base.length, 11);
    expect(theatrum.length, 14);
  });

  test('generated questions show the passage, four renderings, the Latin reference and credit only reading skills', () {
    final src = ReadingQuestionSource(lib, language: 'fr');
    for (final t in theatrum) {
      final comps = Progression.componentsFor(const SaveData(), t);
      for (var seed = 0; seed < 20; seed++) {
        final q = src.generate(trial: t, componentIds: comps, rng: Random(seed), id: '$seed')!;
        expect(q.dimension, Dimension.sensus);
        expect(q.choices.length, 4, reason: q.id);
        expect(q.choices.where((c) => q.correctValues.contains(c.value)).length, 1);
        expect(q.choices.map((c) => c.label).toSet().length, 4);
        expect(q.payload, isA<ReadingQuestionPayload>());
        expect(q.reading.entry.passage.text, q.surface);
        expect(q.context.single, isNot(startsWith('MAT ')));
        expect(q.exposure, isNotNull);
        expect(q.exposure!.lemmas, isNotEmpty);
        expect(q.exposure!.targetLemma, q.lemmaId);
        for (final s in q.skillIds) {
          expect(Skills.isWithin(s, 'l'), isTrue, reason: 'reading questions never credit form-recognition skills ($s)');
        }
        if (t.isMixta) {
          expect(q.primarySkill, t.primarySkill);
          expect(q.componentId, isNotNull);
        }
      }
    }
    // The reference line is Latin (book name), e.g. "Matthaeus 5, 8".
    expect(lib.corpus.latinRef('MAT 5:8'), 'Matthaeus 5, 8');
    expect(lib.corpus.latinRef('PSA 22:1'), 'Psalmi 22, 1');
  });

  test('the shuffled choice order is deterministic for a seed and the correct answer is not always in the same place', () {
    final src = ReadingQuestionSource(lib, language: 'fr');
    final t = Trials.byId('th-numerus');
    final positions = <int>{};
    for (var seed = 0; seed < 40; seed++) {
      final a = src.generate(trial: t, componentIds: const [], rng: Random(seed), id: 'a')!;
      final b = src.generate(trial: t, componentIds: const [], rng: Random(seed), id: 'b')!;
      expect(a.choices.map((c) => c.value).toList(), b.choices.map((c) => c.value).toList());
      positions.add(a.choices.indexWhere((c) => a.correctValues.contains(c.value)));
    }
    expect(positions.length, 4);
  });

  test('a valid paraphrase listed as accepted is never rejected; equivalent readings are not opposed', () {
    // Build a question the way the source does, with a second accepted rendering.
    final e = set.entries.first;
    final q = Question(
      id: 'q',
      trialId: e.item.trialId,
      dimension: Dimension.sensus,
      prompt: Dimension.sensus.prompt,
      surface: e.passage.text,
      lemmaId: e.item.target.lemmaId,
      choices: [const Choice('c1', 'rendu publié'), const Choice('c2', 'paraphrase équivalente'), Choice(e.renderings.distractors[0].id, e.renderings.distractors[0].text), Choice(e.renderings.distractors[1].id, e.renderings.distractors[1].text)],
      correctValues: const {'c1', 'c2'},
      skillIds: [e.item.skillId],
      payload: ReadingQuestionPayload(entry: e, language: 'fr'),
      ambiguous: true,
      exposure: ExposureNote(itemId: e.item.id, passageId: e.passage.id, lemmas: e.passage.lemmas, targetLemma: e.item.target.lemmaId),
    );
    const resolver = AnswerResolver();
    const save = SaveData();
    for (final v in ['c1', 'c2']) {
      final r = resolver.resolve(save: save, q: q, chosenValue: v, quality: AnswerQuality.autonoma, mode: BattleMode.certamen, now: DateTime(2026, 9, 6));
      expect(r.correct, isTrue, reason: v);
      expect(r.delta, 8);
    }
    final wrong = resolver.resolve(save: save, q: q, chosenValue: e.renderings.distractors[0].id, quality: AnswerQuality.autonoma, mode: BattleMode.certamen, now: DateTime(2026, 9, 6));
    expect(wrong.correct, isFalse);
    // In the shipped data no distractor is a mere paraphrase of the faithful
    // rendering: each one names the misread span and the changed meaning.
    for (final x in set.entries) {
      for (final d in x.renderings.distractors) {
        expect(d.wrongAnalysis, isNot(equals(d.correctAnalysis)), reason: x.item.id);
      }
    }
  });

  test('the correction names the misread span, both analyses and the French shift', () {
    final src = ReadingQuestionSource(lib, language: 'fr');
    final t = Trials.byId('th-vox');
    final q = src.generate(trial: t, componentIds: const [], rng: Random(3), id: 'q')!;
    final d = q.reading.entry.renderings.distractors.first;
    final ex = src.explain(q: q, chosenValue: d.id, correct: false);
    expect(ex.headline, contains(q.reading.entry.item.target.span));
    expect(ex.detail, contains('Rēctum'));
    expect(ex.detail, contains(d.span));
    expect(ex.detail, contains(d.correctAnalysis));
    expect(ex.detail, contains(d.wrongAnalysis));
    expect(ex.detail, contains(d.shift));
    final ok = src.explain(q: q, chosenValue: q.reading.entry.renderings.correct.first.id, correct: true);
    expect(ok.detail, isNotEmpty);
  });

  test('coverage-oriented selection prefers unseen items and unmet vocabulary, and stops neglecting rare words', () {
    final src = ReadingQuestionSource(lib, language: 'fr');
    final t = Trials.byId('th-tempus-praeteritum');
    // Within the bands a beginner is offered (the gate opens band 1 and widens
    // only until five items are available, exactly as the source does).
    final full = src.pool(t, const []);
    var widen = 1;
    while (full.where((e) => e.item.band <= widen).length < 5 && widen < set.corpus.bandCount) {
      widen++;
    }
    final pool = full.where((e) => e.item.band <= widen).toList();
    expect(pool.length, greaterThanOrEqualTo(5));
    // Mark every item but one as played many times with all its vocabulary met twice.
    var ledger = const ExposureLedger();
    final rare = pool.last;
    for (final e in pool) {
      if (e.item.id == rare.item.id) continue;
      for (var i = 0; i < 4; i++) {
        ledger = ledger.record(ExposureNote(itemId: e.item.id, passageId: '${e.passage.id}#$i', lemmas: e.passage.lemmas, targetLemma: e.item.target.lemmaId), autonomousCorrect: true);
      }
    }
    expect(src.weight(rare, ledger), greaterThan(src.weight(pool.first, ledger) * 3));
    var hits = 0;
    for (var seed = 0; seed < 60; seed++) {
      final q = src.generate(trial: t, componentIds: const [], rng: Random(seed), id: '$seed', exposure: ledger)!;
      if (q.reading.entry.item.id == rare.item.id) hits++;
    }
    expect(hits, greaterThan(20), reason: 'the neglected item must be drawn far more often than 1/${pool.length}');
    // Once met, exposure distinguishes "met", "met again elsewhere" and "tested".
    final first = pool.first;
    var l2 = const ExposureLedger().record(ExposureNote(itemId: first.item.id, passageId: first.passage.id, lemmas: first.passage.lemmas, targetLemma: first.item.target.lemmaId), autonomousCorrect: false);
    final target = l2.of(first.item.target.lemmaId);
    expect(target.seen, 1);
    expect(target.tested, 1);
    expect(target.testedCorrect, 0);
    expect(target.revisited, isFalse);
    l2 = l2.record(ExposureNote(itemId: 'other', passageId: 'other-passage', lemmas: [first.item.target.lemmaId], targetLemma: 'x'), autonomousCorrect: true);
    expect(l2.of(first.item.target.lemmaId).revisited, isTrue);
    expect(l2.of(first.item.target.lemmaId).tested, 1, reason: 'meeting a word again is not being tested on it');
  });

  test('an unavailable translation language yields no questions instead of another language\'s content', () {
    final en = ReadingQuestionSource(lib, language: 'en');
    expect(en.available, isFalse);
    expect(en.generate(trial: Trials.byId('th-numerus'), componentIds: const [], rng: Random(1), id: 'q'), isNull);
  });

  test('every Theatrum trial credits a Lēctiō skill and every Lēctiō leaf has a trial', () {
    for (final t in theatrum) {
      for (final s in t.skillIds) {
        expect(Skills.isWithin(s, 'l'), isTrue);
      }
    }
    for (final leaf in Skills.leaves('l')) {
      expect(Trials.forSkill(leaf), isNotEmpty, reason: leaf);
    }
  });

  testWidgets('the shipped assets load offline from the bundle exactly as the app does at start-up', (tester) async {
    // Real asynchronous I/O (asset decoding runs off the fake-async clock).
    await tester.runAsync(() async {
      final lib2 = await ReadingLibrary.load(rootBundle);
      expect(lib2.supports('fr'), isTrue);
      expect(lib2.supports('en'), isFalse);
      expect(lib2.forLanguage('fr')!.entries.length, set.entries.length);
      // The complete source texts are shipped too (no run-time fetching).
      final la = await rootBundle.loadString('assets/corpus/latVUC_vpl.txt');
      final fr = await rootBundle.loadString('assets/corpus/fraLSG_vpl.txt');
      expect(la, startsWith('GEN 1:1 In principio creavit Deus'));
      expect(fr, startsWith('GEN 1:1 Au commencement, Dieu créa'));
    });
  });
}
