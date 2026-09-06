import '../model/noun.dart';
import 'conjugator.dart' show stripMacrons;
import 'declinator.dart';

/// Whole-noun-lexicon index: surface form -> every analysis across all nouns.
///
/// As for verbs, two indexes are kept: exact (macron-sensitive, used by the
/// questions) and macron-insensitive (lookups and tooling). Merging spellings
/// never discards an analysis: `rosae` keeps its four analyses, and the loose
/// index adds `rosā` to `rosa`.
class NounAnalyzer {
  NounAnalyzer(this.nouns, this.declinator) {
    for (final n in nouns) {
      final p = declinator.decline(n);
      _paradigms[n.id] = p;
      for (final f in p.forms) {
        (_exact[f.surface] ??= []).add(f);
        (_loose[stripMacrons(f.surface)] ??= []).add(f);
      }
    }
  }

  final List<NounEntry> nouns;
  final Declinator declinator;
  final Map<String, NounParadigm> _paradigms = {};
  final Map<String, List<NounForm>> _exact = {};
  final Map<String, List<NounForm>> _loose = {};

  NounParadigm paradigmOf(String lemmaId) => _paradigms[lemmaId]!;
  Iterable<NounParadigm> get paradigms => _paradigms.values;
  NounEntry noun(String lemmaId) => nouns.firstWhere((n) => n.id == lemmaId);
  NounEntry? maybeNoun(String lemmaId) => nouns.where((n) => n.id == lemmaId).firstOrNull;

  /// Every analysis of [surface] (macron-sensitive).
  List<NounForm> analyze(String surface) => _exact[surface] ?? const [];

  /// Every analysis of [surface] ignoring vowel quantity.
  List<NounForm> analyzeLoose(String surface) => _loose[stripMacrons(surface)] ?? const [];

  int get formCount => _exact.values.fold(0, (a, b) => a + b.length);
  int get surfaceCount => _exact.length;
}
