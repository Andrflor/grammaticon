// Validates the Forum's contextual items against the lexicon and the catalogue.
//
//   dart run tool/check_syntagmata.dart            # every item
//   dart run tool/check_syntagmata.dart syn-ae     # items tagged syn-ae
//
// Checks: unique ids; one {target} per item; the target has the declared
// reading under the declared lemma; head and candidates exist and their
// surfaces are analysable under their lemma; on quodNomen items exactly one
// noun (head or candidate) agrees with the target; tags are card ids; every
// card that draws syntagmata has items, and each of its asked dimensions has
// at least two values among them.
import 'dart:io';

import 'package:grammaticon/linguistics/lexicon/forum_lexicon.dart';
import 'package:grammaticon/pedagogy/forum/forum_filters.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/trials.dart';

void main(List<String> args) {
  final analyzer = buildNominalAnalyzer();
  final src = ForumQuestionSource(analyzer, kSyntagmata);
  final forum = Trials.ofActivity(Activity.forum);
  final cardIds = forum.map((t) => t.id).toSet();
  final items = args.isEmpty ? kSyntagmata : kSyntagmata.where((s) => s.tags.any(args.contains)).toList();
  final errors = <String>[];
  final ids = <String>{};

  for (final s in items) {
    void err(String m) => errors.add('${s.id}: $m   ← "${s.text}"');
    if (!ids.add(s.id)) err('duplicate id');
    if (RegExp(r'\{').allMatches(s.text).length != 1) err('exactly one {target} required');
    if (s.tags.isEmpty) err('no tags');
    for (final t in s.tags) {
      if (!cardIds.contains(t)) err('unknown card tag $t');
    }
    if (analyzer.maybeLexeme(s.lemmaId) == null) {
      err('unknown lemma ${s.lemmaId}');
      continue;
    }
    final reading = src.readingOf(s);
    if (reading == null) {
      final all = analyzer.analyze(src.lexiconTarget(s)).map((f) => '${f.analysis.lemmaId}:${f.analysis.selector}').join(', ');
      err('target "${s.target}" has no reading ${s.lemmaId}:${s.casus.key}.${s.number.key}${s.gender == null ? '' : '.${s.gender!.key}'}${s.degree.key == 'pos' ? '' : ' ${s.degree.key}'}; lexicon: ${all.isEmpty ? '—' : all}');
    }
    if (s.head != null) {
      if (s.headSurface == null) err('head lemma given but no [head] in text');
      if (analyzer.maybeLexeme(s.head!) == null) {
        err('unknown head lemma ${s.head}');
      } else if (s.headSurface != null && analyzer.analyzeAs(s.headSurface!, s.head!).isEmpty) {
        err('head "${s.headSurface}" is not a form of ${s.head}');
      }
    } else if (s.headSurface != null) {
      err('[head] marked in text but no head lemma');
    }
    final candSurfaces = s.candidateSurfaces;
    if (candSurfaces.length != s.candidates.length) err('${candSurfaces.length} <candidates> in text but ${s.candidates.length} candidate lemmas');
    for (var i = 0; i < s.candidates.length && i < candSurfaces.length; i++) {
      if (analyzer.maybeLexeme(s.candidates[i]) == null) {
        err('unknown candidate lemma ${s.candidates[i]}');
      } else if (analyzer.analyzeAs(candSurfaces[i], s.candidates[i]).isEmpty) {
        err('candidate "${candSurfaces[i]}" is not a form of ${s.candidates[i]}');
      }
    }
    // quodNomen items: exactly one head/candidate agrees with the target.
    if (s.head != null && s.candidates.isNotEmpty && reading != null) {
      var agreeing = 0;
      final all = [(s.head!, s.headSurface!), for (var i = 0; i < s.candidates.length && i < candSurfaces.length; i++) (s.candidates[i], candSurfaces[i])];
      for (final (lemma, surface) in all) {
        if (analyzer.analyzeAs(surface, lemma).any((f) => f.analysis.agreesWith(reading.analysis))) agreeing++;
      }
      if (agreeing != 1) err('$agreeing nouns agree with the target (expected exactly one: the head)');
    }
    if (s.note.isEmpty) err('empty note');
  }

  // Coverage per card.
  if (args.isEmpty) {
    for (final t in forum) {
      final f = t.filter as ForumFilter;
      if (!f.hasSyntagmata && t.components.every((c) => !(c.filter as ForumFilter).hasSyntagmata)) continue;
      final pool = src.pool(t, t.components.map((c) => c.id).toList()).where((e) => e.isContextual).toList();
      if (pool.isEmpty) {
        errors.add('${t.id}: no contextual items');
        continue;
      }
      final values = src.poolValues(t, t.components.map((c) => c.id).toList());
      for (final d in t.dimensions) {
        if (d == Dimension.analysis || d == Dimension.quodNomen) continue;
        final n = values[d]?.length ?? 0;
        if (n < 2 && !(t.fixedChoices && d == Dimension.casus)) errors.add('${t.id}: dimension ${d.name} has $n value(s) in ${pool.length} items');
      }
      stdout.writeln('${t.id.padRight(18)} ${pool.length.toString().padLeft(3)} items · ${[for (final d in t.dimensions) '${d.name}=${values[d]?.length ?? 0}'].join(' ')}');
    }
  }

  stdout.writeln('${items.length} items checked');
  if (errors.isNotEmpty) {
    stderr.writeln('\n${errors.length} problem(s):');
    for (final e in errors) {
      stderr.writeln('  $e');
    }
    exit(1);
  }
  stdout.writeln('OK');
}
