/// Cardinal numerals (A&G §132–§135): ūnus, duo, trēs decline, the following
/// cardinals up to one hundred do not, the hundreds decline as plural
/// adjectives, mīlle is an indeclinable adjective and mīlia a neuter noun.
/// Ordinals are first-class adjectives and live in the adjective lexicon.
library;

import 'grammar.dart';
import 'nominal.dart';

enum NumeralKind {
  cardinale('Cardināle'),
  /// mīlia: a neuter plural noun governing the genitive.
  substantivum('Nōmen numerāle');

  const NumeralKind(this.latin);
  final String latin;
}

class NumeralEntry implements Lexeme {
  const NumeralEntry({
    required this.id,
    required this.lemma,
    required this.entry,
    required this.value,
    required this.glossFr,
    this.kind = NumeralKind.cardinale,
    this.cells = const {},
    this.hasGender = true,
    this.provenance = const [],
    this.notes = '',
  });

  @override
  final String id;
  @override
  final String lemma;
  final String entry;
  final int value;
  @override
  final String glossFr;
  final NumeralKind kind;

  /// Declined cells by selector (`nom.pl.m`); empty for an indeclinable
  /// numeral, whose single form is the lemma.
  final Map<String, List<String>> cells;
  final bool hasGender;
  @override
  final List<String> provenance;
  @override
  final String notes;

  @override
  WordClass get wordClass => WordClass.numerale;
  @override
  String get dictionaryEntry => entry;
  @override
  bool get isProper => false;

  bool get isIndeclinable => cells.isEmpty;

  /// Roman numeral of [value] (`VII`, `MDC`).
  String get roman => romanNumeral(value);

  List<NominalForm> get forms {
    if (isIndeclinable) return [NominalForm(lemma, NominalAnalysis(lemmaId: id, wordClass: WordClass.numerale))];
    final out = <NominalForm>[];
    for (final e in cells.entries) {
      final p = parseSelector(e.key);
      for (var i = 0; i < e.value.length; i++) {
        out.add(NominalForm(e.value[i], NominalAnalysis(lemmaId: id, wordClass: WordClass.numerale, casus: p.casus, number: p.number, gender: p.gender, variant: i == 0 ? VariantKind.norma : VariantKind.altera)));
      }
    }
    return out;
  }
}

String romanNumeral(int n) {
  const table = [(1000, 'M'), (900, 'CM'), (500, 'D'), (400, 'CD'), (100, 'C'), (90, 'XC'), (50, 'L'), (40, 'XL'), (10, 'X'), (9, 'IX'), (5, 'V'), (4, 'IV'), (1, 'I')];
  var v = n;
  final b = StringBuffer();
  for (final (k, s) in table) {
    while (v >= k) {
      b.write(s);
      v -= k;
    }
  }
  return b.toString();
}
