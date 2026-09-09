/// Whole-nominal-lexicon index for the Forum: every surface of every noun,
/// adjective, pronoun, numeral and adverb, with all its analyses.
///
/// Nouns come from the existing [NounAnalyzer] (kept for its cells, help
/// tables and errata keys); the other classes are declined or listed here.
/// Two indexes are kept, exact (macron-sensitive, used by the questions) and
/// macron-insensitive (tooling); merging never discards an analysis.
library;

import '../model/adjective.dart';
import '../model/adverb.dart';
import '../model/grammar.dart';
import '../model/nominal.dart';
import '../model/numeral.dart';
import '../model/pronoun.dart';
import 'adjective_declinator.dart';
import 'conjugator.dart' show stripMacrons;
import 'noun_analyzer.dart';

class NominalAnalyzer {
  NominalAnalyzer({
    required this.nouns,
    required List<AdjectiveEntry> adjectives,
    required List<PronounEntry> pronouns,
    required List<NumeralEntry> numerals,
    required List<AdverbEntry> adverbs,
    AdjectiveDeclinator adjectiveDeclinator = const AdjectiveDeclinator(),
  })  : adjectives = List.unmodifiable(adjectives),
        pronouns = List.unmodifiable(pronouns),
        numerals = List.unmodifiable(numerals),
        adverbs = List.unmodifiable(adverbs) {
    for (final n in nouns.nouns) {
      _lexemes[n.id] = n;
      _index(n.id, [for (final f in nouns.paradigmOf(n.id).forms) f.nominal]);
    }
    for (final a in adjectives) {
      _lexemes[a.id] = a;
      final p = adjectiveDeclinator.decline(a);
      _adjParadigms[a.id] = p;
      _index(a.id, p.forms);
    }
    for (final p in pronouns) {
      _lexemes[p.id] = p;
      _index(p.id, p.forms);
    }
    for (final n in numerals) {
      _lexemes[n.id] = n;
      _index(n.id, n.forms);
    }
    for (final a in adverbs) {
      _lexemes[a.id] = a;
      _index(a.id, a.forms);
    }
  }

  final NounAnalyzer nouns;
  final List<AdjectiveEntry> adjectives;
  final List<PronounEntry> pronouns;
  final List<NumeralEntry> numerals;
  final List<AdverbEntry> adverbs;

  final Map<String, Lexeme> _lexemes = {};
  final Map<String, List<NominalForm>> _forms = {};
  final Map<String, AdjectiveParadigm> _adjParadigms = {};
  final Map<String, List<NominalForm>> _exact = {};
  final Map<String, List<NominalForm>> _loose = {};

  void _index(String id, List<NominalForm> forms) {
    if (_forms.containsKey(id)) throw StateError('duplicate lexeme id $id');
    _forms[id] = List.unmodifiable(forms);
    for (final f in forms) {
      (_exact[f.surface] ??= []).add(f);
      (_loose[stripMacrons(f.surface)] ??= []).add(f);
    }
  }

  Iterable<Lexeme> get lexemes => _lexemes.values;
  Lexeme lexeme(String id) => _lexemes[id] ?? (throw ArgumentError('unknown lexeme $id'));
  Lexeme? maybeLexeme(String id) => _lexemes[id];
  bool has(String id) => _lexemes.containsKey(id);

  /// Every form (primary and variants) of one lexeme.
  List<NominalForm> formsOf(String id) => _forms[id] ?? const [];

  /// Forms of a lexeme at one selector.
  List<NominalForm> cell(String id, String selector) => formsOf(id).where((f) => f.analysis.selector == selector).toList();
  NominalForm? primary(String id, String selector) => cell(id, selector).where((f) => f.isPrimary).firstOrNull;

  AdjectiveParadigm adjectiveParadigm(String id) => _adjParadigms[id]!;
  AdjectiveEntry? maybeAdjective(String id) => _lexemes[id] is AdjectiveEntry ? _lexemes[id] as AdjectiveEntry : null;
  PronounEntry? maybePronoun(String id) => _lexemes[id] is PronounEntry ? _lexemes[id] as PronounEntry : null;

  /// Every analysis of [surface] (macron-sensitive), across all word classes.
  List<NominalForm> analyze(String surface) => _exact[surface] ?? const [];

  /// Every analysis of [surface] ignoring vowel quantity.
  List<NominalForm> analyzeLoose(String surface) => _loose[stripMacrons(surface)] ?? const [];

  /// Analyses of [surface] belonging to [lemmaId].
  List<NominalForm> analyzeAs(String surface, String lemmaId) => analyze(surface).where((f) => f.analysis.lemmaId == lemmaId).toList();

  /// Surfaces of [lemmaId] that could stand for [casus]/[number]/[gender]
  /// (gender ignored when the lexeme has none in that cell).
  List<NominalForm> matching(String lemmaId, {Casus? casus, Numerus? number, Gender? gender, Degree? degree}) => formsOf(lemmaId)
      .where((f) =>
          (casus == null || f.analysis.casus == casus) &&
          (number == null || f.analysis.number == number) &&
          (gender == null || f.analysis.gender == null || f.analysis.gender == gender) &&
          (degree == null || f.analysis.degree == degree))
      .toList();

  int get formCount => _exact.values.fold(0, (a, b) => a + b.length);
  int get surfaceCount => _exact.length;
}
