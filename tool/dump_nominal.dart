// Dev tool: prints the nominal lexicon (ids, classes, entries) and paradigms.
//
//   dart run tool/dump_nominal.dart --ids
//   dart run tool/dump_nominal.dart bonus hic duo
// ignore_for_file: avoid_print
import 'package:grammaticon/linguistics/lexicon/forum_lexicon.dart';

void main(List<String> args) {
  final a = buildNominalAnalyzer();
  if (args.length == 1 && args.first == '--ids') {
    // One line per lexeme: id, class, dictionary entry (for content authors).
    for (final l in a.lexemes) {
      print('${l.id.padRight(18)} ${l.wordClass.key.padRight(3)} ${l.dictionaryEntry}');
    }
    return;
  }
  print('lexemes ${a.lexemes.length} surfaces ${a.surfaceCount} forms ${a.formCount}');
  for (final id in args) {
    print('== $id ${a.lexeme(id).dictionaryEntry}');
    final forms = a.formsOf(id);
    final bySel = <String, List<String>>{};
    for (final f in forms) {
      (bySel[f.analysis.selector] ??= []).add(f.surface);
    }
    for (final e in bySel.entries) {
      print('  ${e.key.padRight(16)} ${e.value.join(' / ')}');
    }
  }
  for (final s in ['rosae', 'bonae', 'meliōre', 'fortium', 'fortius', 'hōc', 'quem', 'plūs', 'ūnīus', 'ācerrimus', 'facillimus', 'pulcherrimus', 'mī', 'tribus', 'mīlia']) {
    print('$s → ${a.analyze(s).map((f) => '${f.analysis.lemmaId}:${f.analysis.selector}').join(', ')}');
  }
}
