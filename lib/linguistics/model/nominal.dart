/// Shared model of every declinable (or degree-bearing) word of the Forum:
/// nouns, adjectives, pronouns, numerals and adverbs.
///
/// A [NominalAnalysis] is the common currency of the Forum's questions: one
/// reading of one surface. Nouns keep their own [NounAnalysis] (cells, skills,
/// errata keys) and are adapted to this model by `NounNominal`; the other word
/// classes produce it directly.
library;

import 'grammar.dart';
import 'noun.dart';

/// Word class of a lexeme. The key is stable (save data, selectors).
enum WordClass {
  nomen('n', 'Nōmen'),
  adiectivum('a', 'Adiectīvum'),
  pronomen('p', 'Prōnōmen'),
  numerale('num', 'Numerāle'),
  adverbium('adv', 'Adverbium');

  const WordClass(this.key, this.latin);
  final String key;
  final String latin;
  static WordClass fromKey(String k) => values.firstWhere((e) => e.key == k);
}

/// Degree of comparison (A&G §123–§131).
enum Degree {
  positivus('pos', 'Positīvus'),
  comparativus('comp', 'Comparātīvus'),
  superlativus('sup', 'Superlātīvus');

  const Degree(this.key, this.latin);
  final String key;
  final String latin;
  static Degree fromKey(String k) => values.firstWhere((e) => e.key == k);
}

/// Anything the Forum can ask about: a dictionary word with forms.
abstract class Lexeme {
  String get id;

  /// Headword with macrons (`bonus`, `hic`, `ego`, `fortiter`).
  String get lemma;
  WordClass get wordClass;

  /// Dictionary entry as shown to the player (`bonus, -a, -um`).
  String get dictionaryEntry;
  String get notes;
  List<String> get provenance;
  String get glossFr;

  /// Proper names (Rōma, Iūlius) are excluded from isolated-form pools unless
  /// a filter asks for them.
  bool get isProper => lemma[0].toUpperCase() == lemma[0] && lemma[0].toLowerCase() != lemma[0];
}

/// One reading of one nominal surface.
class NominalAnalysis {
  const NominalAnalysis({
    required this.lemmaId,
    required this.wordClass,
    this.casus,
    this.number,
    this.gender,
    this.degree = Degree.positivus,
    this.declension,
    this.person,
    this.variant = VariantKind.norma,
  });

  final String lemmaId;
  final WordClass wordClass;

  /// Null for indeclinable words (adverbs, cardinal numerals from four on).
  final Casus? casus;

  /// Null for indeclinable words.
  final Numerus? number;

  /// Null for nouns without variable gender in their forms (nouns carry a
  /// fixed gender, which is still recorded here), personal pronouns and
  /// indeclinables.
  final Gender? gender;
  final Degree degree;

  /// Declension of a noun (the five declensions); null for other classes.
  final Declension? declension;

  /// Person of a personal or reflexive pronoun.
  final Person? person;
  final VariantKind variant;

  bool get isPrimary => variant.isPrimary;
  bool get isDeclined => casus != null && number != null;

  /// Stable selector: `acc.sg` (noun, personal pronoun), `acc.sg.m`
  /// (adjective, pronoun with gender), `comp.acc.sg.m` (comparative),
  /// `pos` / `comp` / `sup` alone for indeclinables with a degree, `indecl`
  /// for a plain indeclinable.
  String get selector {
    final parts = <String>[];
    if (degree != Degree.positivus || (casus == null && wordClass == WordClass.adverbium)) parts.add(degree.key);
    if (casus != null) parts.add(casus!.key);
    if (number != null) parts.add(number!.key);
    if (gender != null && wordClass != WordClass.nomen) parts.add(gender!.key);
    if (parts.isEmpty) return 'indecl';
    return parts.join('.');
  }

  /// Case and number selector without gender or degree (`acc.sg`), used for
  /// cross-class comparison (agreement); null for indeclinables.
  String? get cellSelector => isDeclined ? '${casus!.key}.${number!.key}' : null;

  /// Tabula cell of a noun form (`d.1.acc.sg`, `d.loc`); null for other classes.
  String? get nounSkillId {
    if (wordClass != WordClass.nomen || declension == null || casus == null || number == null) return null;
    return casus == Casus.locativus ? 'd.loc' : 'd.${declension!.ordinal}.${casus!.key}.${number!.key}';
  }

  /// Latin description, e.g. `accūsātīvus singulāris masculīnum`,
  /// `comparātīvus · ablātīvus singulāris fēminīnum`.
  String describe({bool withGender = true, bool withDegree = true}) {
    final b = <String>[];
    if (withDegree && (degree != Degree.positivus || wordClass == WordClass.adverbium)) b.add(degree.latin.toLowerCase());
    if (casus != null && number != null) b.add('${casus!.latin.toLowerCase()} ${number!.latin.toLowerCase()}');
    if (withGender && gender != null && wordClass != WordClass.nomen) b.add(gender!.latin.toLowerCase());
    if (person != null) b.add('${person!.latin.toLowerCase()} persōna');
    if (b.isEmpty) b.add('indēclīnābile');
    final v = variant == VariantKind.norma ? '' : ' · ${variant.latin}';
    return '${b.join(' · ')}$v';
  }

  NominalAnalysis copyWith({Casus? casus, Numerus? number, Gender? gender, Degree? degree, VariantKind? variant}) => NominalAnalysis(
        lemmaId: lemmaId,
        wordClass: wordClass,
        casus: casus ?? this.casus,
        number: number ?? this.number,
        gender: gender ?? this.gender,
        degree: degree ?? this.degree,
        declension: declension,
        person: person,
        variant: variant ?? this.variant,
      );

  /// True when [other] agrees with this analysis in case, number and gender
  /// (a noun's fixed gender counts).
  bool agreesWith(NominalAnalysis other) => casus == other.casus && number == other.number && (gender == null || other.gender == null || gender == other.gender);

  @override
  bool operator ==(Object other) =>
      other is NominalAnalysis &&
      other.lemmaId == lemmaId &&
      other.wordClass == wordClass &&
      other.casus == casus &&
      other.number == number &&
      other.gender == gender &&
      other.degree == degree &&
      other.declension == declension &&
      other.person == person &&
      other.variant == variant;

  @override
  int get hashCode => Object.hash(lemmaId, wordClass, casus, number, gender, degree, declension, person, variant);

  @override
  String toString() => '$lemmaId:$selector${variant.isPrimary ? '' : '[${variant.key}]'}';
}

/// A surface with one analysis.
class NominalForm {
  const NominalForm(this.surface, this.analysis);
  final String surface;
  final NominalAnalysis analysis;
  bool get isPrimary => analysis.isPrimary;

  @override
  String toString() => '$surface ⟨${analysis.describe()}⟩';
}

/// Adapters from the noun model.
extension NounNominal on NounAnalysis {
  NominalAnalysis get nominal => NominalAnalysis(
        lemmaId: lemmaId,
        wordClass: WordClass.nomen,
        casus: casus,
        number: number,
        gender: gender,
        declension: declension,
        variant: variant,
      );
}

extension NounFormNominal on NounForm {
  NominalForm get nominal => NominalForm(surface, analysis.nominal);
}

/// Parses a selector produced by [NominalAnalysis.selector] back into its
/// parts (degree, case, number, gender); missing parts are null.
({Degree degree, Casus? casus, Numerus? number, Gender? gender}) parseSelector(String sel) {
  var degree = Degree.positivus;
  Casus? casus;
  Numerus? number;
  Gender? gender;
  for (final p in sel.split('.')) {
    if (p == 'indecl') continue;
    if (p == 'pos' || p == 'comp' || p == 'sup') {
      degree = Degree.fromKey(p);
    } else if (p == 'sg' || p == 'pl') {
      number = Numerus.fromKey(p);
    } else if (p == 'm' || p == 'f' || p == 'n') {
      gender = Gender.fromKey(p);
    } else {
      casus = Casus.fromKey(p);
    }
  }
  return (degree: degree, casus: casus, number: number, gender: gender);
}
