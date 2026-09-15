import '../model/analysis.dart';
import '../model/verb.dart';
import 'conjugator.dart';

/// Whole-lexicon index: surface form -> every analysis across all verbs.
///
/// Two indexes are kept: exact (macron-sensitive) and macron-insensitive.
/// Questions display forms with macrons and use the exact index; the loose
/// index serves lookups of user-typed text and the coverage tooling.
class Analyzer {
  Analyzer(this.verbs, this.conjugator) {
    for (final v in verbs) {
      final p = conjugator.conjugate(v);
      _paradigms[v.id] = p;
      for (final f in p.forms) {
        (_exact[f.surface] ??= []).add(f);
        (_loose[stripMacrons(f.surface)] ??= []).add(f);
      }
    }
  }

  final List<VerbEntry> verbs;
  final Conjugator conjugator;
  final Map<String, Paradigm> _paradigms = {};
  final Map<String, List<FormEntry>> _exact = {};
  final Map<String, List<FormEntry>> _loose = {};

  Paradigm paradigmOf(String lemmaId) => _paradigms[lemmaId]!;
  Iterable<Paradigm> get paradigms => _paradigms.values;
  VerbEntry verb(String lemmaId) => verbs.firstWhere((v) => v.id == lemmaId);

  /// Every analysis of [surface] (macron-sensitive).
  List<FormEntry> analyze(String surface) => _exact[surface] ?? const [];

  /// Every analysis of [surface] ignoring vowel quantity.
  List<FormEntry> analyzeLoose(String surface) => _loose[stripMacrons(surface)] ?? const [];

  /// Total number of indexed (surface, analysis) pairs.
  int get formCount => _exact.values.fold(0, (a, b) => a + b.length);
  int get surfaceCount => _exact.length;
}
