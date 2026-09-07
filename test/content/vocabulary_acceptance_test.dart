// Acceptance check of the Theatrum's learning content: the share of the
// corpus vocabulary taught by validated, shipped questions must reach the
// minimum. The measure is produced by `python3 tool/theatrum/build_content.py`
// (tool/theatrum/vocab.py) from the shipped assets and the corpus inventory;
// this test fails while the content is incomplete, by design.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('taught vocabulary coverage reaches the 90 % minimum (all entries in the denominator)', () {
    final f = File('tool/corpus/out/theatrum_coverage.json');
    expect(f.existsSync(), isTrue, reason: 'run python3 tool/theatrum/build_content.py');
    final m = (jsonDecode(f.readAsStringSync()) as Map).cast<String, Object?>();
    final entries = m['entries'] as int;
    final taught = m['taught'] as int;
    final kinds = (m['entries_by_kind'] as Map).cast<String, Object?>();
    // The denominator keeps proper names and unresolved forms.
    expect(kinds.keys.toSet(), containsAll(['common', 'proper', 'unresolved']));
    expect(entries, (kinds['common'] as int) + (kinds['proper'] as int) + (kinds['unresolved'] as int));
    expect(m['min_coverage_pct'], 90.0);
    final pct = 100 * taught / entries;
    expect(pct, greaterThanOrEqualTo(90.0), reason: 'taught $taught / $entries = ${pct.toStringAsFixed(2)} % — content unfinished');
  });
}
