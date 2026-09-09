/// Pronoun model: explicit paradigms (A&G §142–§152). Nothing is derived by
/// rule here — pronoun declension is where rules end.
library;

import 'grammar.dart';
import 'nominal.dart';

enum PronounKind {
  personale('Persōnāle'),
  reflexivum('Reflexīvum'),
  demonstrativum('Dēmōnstrātīvum'),
  relativum('Relātīvum'),
  interrogativum('Interrogātīvum'),
  indefinitum('Indēfīnītum'),
  correlativum('Correlātīvum');

  const PronounKind(this.latin);
  final String latin;
}

class PronounEntry implements Lexeme {
  const PronounEntry({
    required this.id,
    required this.lemma,
    required this.entry,
    required this.kind,
    required this.cells,
    required this.glossFr,
    this.person,
    this.hasGender = true,
    this.correlative,
    this.provenance = const [],
    this.notes = '',
  });

  @override
  final String id;
  @override
  final String lemma;

  /// Dictionary entry (`hic, haec, hoc`; `ego, meī`).
  final String entry;
  final PronounKind kind;

  /// Every cell by selector: `nom.sg.m` for pronouns with gender, `nom.sg`
  /// for personal pronouns. The first surface is primary, the others free
  /// alternatives.
  final Map<String, List<String>> cells;
  @override
  final String glossFr;

  /// Person of a personal / reflexive pronoun.
  final Person? person;
  final bool hasGender;

  /// Id of the correlative partner (tantus ↔ quantus, is ↔ quī).
  final String? correlative;
  @override
  final List<String> provenance;
  @override
  final String notes;

  @override
  WordClass get wordClass => WordClass.pronomen;
  @override
  String get dictionaryEntry => entry;
  @override
  bool get isProper => false;

  /// Forms of the entry, in selector order of [cells].
  List<NominalForm> get forms {
    final out = <NominalForm>[];
    for (final e in cells.entries) {
      final p = parseSelector(e.key);
      for (var i = 0; i < e.value.length; i++) {
        out.add(NominalForm(
          e.value[i],
          NominalAnalysis(
            lemmaId: id,
            wordClass: WordClass.pronomen,
            casus: p.casus,
            number: p.number,
            gender: p.gender,
            person: person,
            variant: i == 0 ? VariantKind.norma : VariantKind.altera,
          ),
        ));
      }
    }
    return out;
  }
}
