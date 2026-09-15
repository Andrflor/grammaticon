import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/arbor/arbor.dart';
import 'package:grammaticon/arbor/skill.dart';

void main() {
  test('l\'arbre standard se construit et est structurellement sain', () {
    final problems = <String>[];
    final arbor = Arbor.standard(problems: problems);
    final structural = arbor.validate();
    // ignore: avoid_print
    print('census: ${arbor.census.map((k, v) => MapEntry(k.name, v))}, total ${arbor.nodes.length}');
    // ignore: avoid_print
    for (final p in [...problems, ...structural].take(60)) print('  ! $p');
    expect(problems, isEmpty);
    expect(structural, isEmpty);
    expect(arbor.stratum(Stratum.cella).length, greaterThan(1000));
  });
}
