/// Adverbs derived from adjectives, with their degrees (A&G §214–§218): -ē
/// from the first class, -iter / -ter from the third; comparative = neuter
/// comparative in -ius; superlative in -issimē / -errimē / -illimē.
library;

import 'grammar.dart';
import 'nominal.dart';

class AdverbEntry implements Lexeme {
  const AdverbEntry({
    required this.id,
    required this.lemma,
    required this.glossFr,
    this.comparative = const [],
    this.superlative = const [],
    this.adjectiveId,
    this.provenance = const [],
    this.notes = '',
  });

  @override
  final String id;

  /// Positive form (`fortiter`, `bene`); empty comparison lists mean the
  /// degree is not formed.
  @override
  final String lemma;
  @override
  final String glossFr;
  final List<String> comparative;
  final List<String> superlative;

  /// Adjective the adverb is derived from (`fortis`), when any.
  final String? adjectiveId;
  @override
  final List<String> provenance;
  @override
  final String notes;

  @override
  WordClass get wordClass => WordClass.adverbium;
  @override
  String get dictionaryEntry => [lemma, if (comparative.isNotEmpty) comparative.first, if (superlative.isNotEmpty) superlative.first].join(', ');
  @override
  bool get isProper => false;

  List<NominalForm> get forms => [
        NominalForm(lemma, NominalAnalysis(lemmaId: id, wordClass: WordClass.adverbium, degree: Degree.positivus)),
        for (final (i, s) in comparative.indexed) NominalForm(s, NominalAnalysis(lemmaId: id, wordClass: WordClass.adverbium, degree: Degree.comparativus, variant: i == 0 ? VariantKind.norma : VariantKind.altera)),
        for (final (i, s) in superlative.indexed) NominalForm(s, NominalAnalysis(lemmaId: id, wordClass: WordClass.adverbium, degree: Degree.superlativus, variant: i == 0 ? VariantKind.norma : VariantKind.altera)),
      ];
}
