// Dev tool: measures the time to build the whole-lexicon index.
import 'package:latin_game/linguistics/engine/analyzer.dart';
import 'package:latin_game/linguistics/engine/conjugator.dart';
import 'package:latin_game/linguistics/lexicon/verbs.dart';

void main() {
  final sw = Stopwatch()..start();
  final a = Analyzer(kVerbs, Conjugator());
  sw.stop();
  // ignore: avoid_print
  print('verbs=${a.verbs.length} forms=${a.formCount} surfaces=${a.surfaceCount} in ${sw.elapsedMilliseconds} ms');
}
