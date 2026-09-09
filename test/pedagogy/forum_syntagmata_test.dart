// Every contextual item of the Forum is validated against the lexicon: the
// target really has the declared reading under the declared lemma, heads and
// candidates are real forms of their lemmas, exactly one noun agrees on
// quodNomen items, tags are cards, ids are unique, notes are present; and
// every card that draws items has enough of them to ask each dimension.
import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/pedagogy/forum/forum_filters.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/trials.dart';

import '../support/test_env.dart';

void main() {
  final analyzer = testNominalAnalyzer;
  final src = ForumQuestionSource(analyzer, kSyntagmata);
  final forum = Trials.ofActivity(Activity.forum);
  final cardIds = forum.map((t) => t.id).toSet();

  test('items are well formed and linguistically consistent with the lexicon', () {
    final ids = <String>{};
    final problems = <String>[];
    for (final s in kSyntagmata) {
      if (!ids.add(s.id)) problems.add('${s.id}: duplicate id');
      if (RegExp(r'\{').allMatches(s.text).length != 1) problems.add('${s.id}: one {target} required');
      if (s.tags.isEmpty || !s.tags.every(cardIds.contains)) problems.add('${s.id}: bad tags ${s.tags}');
      if (s.note.isEmpty) problems.add('${s.id}: empty note');
      if (analyzer.maybeLexeme(s.lemmaId) == null) {
        problems.add('${s.id}: unknown lemma ${s.lemmaId}');
        continue;
      }
      final reading = src.readingOf(s);
      if (reading == null) problems.add('${s.id}: "${s.target}" is not ${s.lemmaId}:${s.casus.key}.${s.number.key}');
      // A sentence-initial target keeps its capital on screen while the
      // lexicon is consulted for the lower-case form.
      if (reading != null) expect(reading.surface, src.lexiconTarget(s));
      if (s.head != null) {
        if (s.headSurface == null || analyzer.analyzeAs(s.headSurface!, s.head!).isEmpty) problems.add('${s.id}: head ${s.head} not marked or not a form');
      }
      final cs = s.candidateSurfaces;
      if (cs.length != s.candidates.length) problems.add('${s.id}: candidate count mismatch');
      for (var i = 0; i < cs.length && i < s.candidates.length; i++) {
        if (analyzer.analyzeAs(cs[i], s.candidates[i]).isEmpty) problems.add('${s.id}: candidate ${cs[i]} is not ${s.candidates[i]}');
      }
      if (s.head != null && s.candidates.isNotEmpty && reading != null) {
        var agreeing = 0;
        for (final (lemma, surface) in [(s.head!, s.headSurface!), for (var i = 0; i < cs.length && i < s.candidates.length; i++) (s.candidates[i], cs[i])]) {
          if (analyzer.analyzeAs(surface, lemma).any((f) => f.analysis.agreesWith(reading.analysis))) agreeing++;
        }
        if (agreeing != 1) problems.add('${s.id}: $agreeing nouns agree with the target');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
    expect(kSyntagmata.length, greaterThan(500));
  });

  test('every card that draws contextual items has enough of them for each of its dimensions', () {
    for (final t in forum) {
      final f = t.filter as ForumFilter;
      if (!f.hasSyntagmata && t.components.every((c) => !(c.filter as ForumFilter).hasSyntagmata)) continue;
      final comps = t.components.map((c) => c.id).toList();
      final pool = src.pool(t, comps).where((e) => e.isContextual).toList();
      expect(pool.length, greaterThanOrEqualTo(12), reason: t.id);
      final values = src.poolValues(t, comps);
      for (final d in t.dimensions) {
        if (d == Dimension.analysis || d == Dimension.quodNomen) continue;
        if (t.fixedChoices && d == Dimension.casus) continue;
        expect(values[d]!.length, greaterThanOrEqualTo(2), reason: '${t.id}: ${d.name} has a single value');
      }
    }
  });
}
