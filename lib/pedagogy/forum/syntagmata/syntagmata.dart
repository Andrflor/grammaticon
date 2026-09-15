/// Registry of the Forum's contextual items, section by section. Each file is
/// authored by hand and validated against the lexicon by
/// `test/pedagogy/forum_syntagmata_test.dart` (and `dart run tool/check_syntagmata.dart`).
library;

import '../syntagma.dart';
import 'casus.dart';
import 'comparatio.dart';
import 'consensus.dart';
import 'numeralia.dart';
import 'pronomina.dart';
import 'relativa.dart';
import 'syncretismi.dart';
import 'syncretismi_b.dart';

final List<Syntagma> kSyntagmata = List.unmodifiable([
  ...kComparatioSyntagmata,
  ...kPronominaSyntagmata,
  ...kRelativaSyntagmata,
  ...kNumeraliaSyntagmata,
  ...kSyncretismiSyntagmata,
  ...kSyncretismiBSyntagmata,
  ...kConsensusSyntagmata,
  ...kCasusSyntagmata,
]);
