// Dev tool: exports every declined noun form as JSON for the corpus pipeline.
// Usage: dart run tool/export_nouns.dart [out.json]
import 'dart:convert';
import 'dart:io';

import 'package:grammaticon/linguistics/engine/conjugator.dart' show stripMacrons;
import 'package:grammaticon/linguistics/engine/declinator.dart';
import 'package:grammaticon/linguistics/lexicon/nouns.dart';

void main(List<String> args) {
  final out = args.isEmpty ? 'tool/corpus/out/nouns_export.json' : args[0];
  const decl = Declinator();
  final nouns = <Map<String, Object?>>[];
  for (final n in kNouns) {
    final p = decl.decline(n);
    nouns.add({
      'id': n.id,
      'lemma': n.lemma,
      'lemmaPlain': stripMacrons(n.lemma),
      'genitive': n.genitive,
      'gender': n.gender.key,
      'decl': n.declension.key,
      'number': n.number.name,
      'forms': [
        for (final f in p.forms) {'s': f.surface, 'plain': stripMacrons(f.surface), 'sel': f.analysis.selector, 'var': f.analysis.variant.key},
      ],
    });
  }
  File(out).writeAsStringSync(const JsonEncoder.withIndent(' ').convert({'generatedAt': DateTime.now().toIso8601String(), 'nouns': nouns}));
  // ignore: avoid_print
  print('exported ${nouns.length} nouns to $out');
}
