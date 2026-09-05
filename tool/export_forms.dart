// Dev tool: exports every generated form as JSON for the corpus pipeline.
// Usage: dart run tool/export_forms.dart [out.json]
import 'dart:convert';
import 'dart:io';

import 'package:latin_game/linguistics/engine/conjugator.dart';
import 'package:latin_game/linguistics/lexicon/verbs.dart';

void main(List<String> args) {
  final out = args.isEmpty ? 'tool/corpus/out/forms_export.json' : args[0];
  final conj = Conjugator();
  final verbs = <Map<String, Object?>>[];
  for (final v in kVerbs) {
    final p = conj.conjugate(v);
    verbs.add({
      'id': v.id,
      'lemma': v.lemma,
      'lemmaPlain': stripMacrons(v.lemma),
      'pp': v.principalParts,
      'conj': v.conjugation.key,
      'kind': v.kind.key,
      'family': v.family,
      'intransitive': v.intransitive,
      'forms': [
        for (final f in p.forms)
          {
            's': f.surface,
            'plain': stripMacrons(f.surface),
            'sel': f.analysis.selector,
            'var': f.analysis.variant.key,
            'comp': f.analysis.composite,
          }
      ],
      'absent': [for (final a in p.absent) {'sel': a.selectorPrefix, 'status': a.status.key, 'note': a.note}],
    });
  }
  File(out).writeAsStringSync(const JsonEncoder.withIndent(' ').convert({'generatedAt': DateTime.now().toIso8601String(), 'verbs': verbs}));
  // ignore: avoid_print
  print('exported ${verbs.length} verbs to $out');
}
