// Dev tool: prints the paradigm of one verb.
// Usage: dart run tool/dump_paradigm.dart amo [selectorPattern]
import 'package:grammaticon/linguistics/engine/conjugator.dart';
import 'package:grammaticon/linguistics/lexicon/verbs.dart';

void main(List<String> args) {
  final id = args.isEmpty ? 'amo' : args[0];
  final pattern = args.length > 1 ? args[1] : null;
  final v = kVerbs.firstWhere((v) => v.id == id);
  final p = Conjugator().conjugate(v);
  final forms = pattern == null ? p.forms : p.select(pattern);
  for (final f in forms) {
    // ignore: avoid_print
    print('${f.analysis.selector.padRight(32)} ${f.surface}${f.analysis.isPrimary ? '' : '  [${f.analysis.variant.key}]'}');
  }
  // ignore: avoid_print
  print('-- ${forms.length} forms; absent: ${p.absent.map((a) => '${a.selectorPrefix}(${a.status.key})').join(', ')}');
}
