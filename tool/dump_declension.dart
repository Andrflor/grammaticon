// ignore_for_file: avoid_print
// Prints the paradigm of a noun: dart run tool/dump_declension.dart rosa [rex ...]
import 'package:grammaticon/linguistics/engine/declinator.dart';
import 'package:grammaticon/linguistics/engine/noun_analyzer.dart';
import 'package:grammaticon/linguistics/lexicon/nouns.dart';
import 'package:grammaticon/linguistics/model/grammar.dart';

void main(List<String> args) {
  final an = NounAnalyzer(kNouns, const Declinator());
  final ids = args.isEmpty ? kNouns.map((n) => n.id).toList() : args;
  for (final id in ids) {
    final p = an.paradigmOf(id);
    print('${p.noun.dictionaryEntry}  [${p.noun.declension.key}]');
    for (final c in [...Casus.ordinary, Casus.locativus]) {
      final sg = p.cell('${c.key}.sg').map((f) => f.surface).join('/');
      final pl = p.cell('${c.key}.pl').map((f) => f.surface).join('/');
      if (sg.isEmpty && pl.isEmpty) continue;
      print('  ${c.key.padRight(4)} ${sg.padRight(22)} $pl');
    }
  }
  print('${an.nouns.length} nouns, ${an.formCount} forms, ${an.surfaceCount} surfaces');
}
