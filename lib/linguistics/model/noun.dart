/// Noun model: lexicon entries and analyses of declined forms.
///
/// Nouns are deliberately kept apart from the verbal [Analysis] model: a noun
/// form has a case, a number, a fixed gender and a declension, nothing else.
library;

import 'analysis.dart' show AbsentForm;
import 'grammar.dart';
import 'nominal.dart';

/// Whether a noun is declined in both numbers or only one (A&G §101–103).
enum NounNumber { ambo, singulareTantum, pluraleTantum }

/// Third-declension stem class (A&G §56–71).
enum ThirdStem {
  /// Consonant stem: gen. pl. -um, abl. sg. -e, neuter pl. -a.
  consonans,

  /// i-stem (masc./fem.): gen. pl. -ium, acc. pl. -ēs / -īs.
  vocalisI,

  /// Pure i-stem: acc. sg. -im, abl. sg. -ī (vīs, sitis, tussis).
  vocalisIPura,

  /// Neuter i-stem (-e, -al, -ar): abl. sg. -ī, pl. -ia, gen. pl. -ium.
  neutrumI,
}

/// A noun of the lexicon with its dictionary entry and stem.
///
/// Forms are derived from [stem] by the declinator; whatever no rule produces
/// (irregular nominatives are given directly, other irregular cells go in
/// [overrides]) is stored explicitly with its source.
class NounEntry implements Lexeme {
  const NounEntry({
    required this.id,
    required this.lemma,
    required this.genitive,
    required this.gender,
    required this.declension,
    required this.stem,
    this.thirdStem = ThirdStem.consonans,
    this.number = NounNumber.ambo,
    this.locative = false,
    this.overrides = const {},
    this.absent = const [],
    this.provenance = const [],
    this.notes = '',
    this.glossFr = '',
  });

  /// Stable ASCII identifier (`rosa`, `rex`, `iuppiter`).
  @override
  final String id;

  /// Nominative singular (nominative plural for plūrālia tantum) with macrons.
  @override
  final String lemma;

  /// Genitive singular (plural for plūrālia tantum) as printed in the
  /// dictionary entry, e.g. `rosae`, `rēgis`, `castrōrum`.
  final String genitive;
  final Gender gender;
  final Declension declension;

  /// Stem to which the endings are added (`ros`, `serv`, `rēg`, `man`, `r`).
  final String stem;
  final ThirdStem thirdStem;
  final NounNumber number;

  /// True when a locative is attested for this noun (towns, small islands,
  /// domus, rūs, humus). Generated only then (A&G §427).
  final bool locative;

  /// Explicit cells by selector (`gen.sg`, `dat.pl`, `loc.sg`). The first
  /// surface is primary, the others are free alternatives.
  final Map<String, List<String>> overrides;

  /// Cells that must not be generated, with the reason.
  final List<AbsentForm> absent;

  /// Source references (A&G sections).
  @override
  final List<String> provenance;
  @override
  final String notes;
  @override
  final String glossFr;

  @override
  WordClass get wordClass => WordClass.nomen;

  @override
  bool get isProper => lemma[0].toUpperCase() == lemma[0] && lemma[0].toLowerCase() != lemma[0];

  bool get isNeuter => gender == Gender.neutrum;
  bool get pluralOnly => number == NounNumber.pluraleTantum;
  bool get singularOnly => number == NounNumber.singulareTantum;

  /// Dictionary entry as shown to the player: `rosa, rosae, f.`
  @override
  String get dictionaryEntry => '$lemma, $genitive, ${gender.abbreviation}';

  /// True for second-declension nouns in -ius / -ium (fīlius, cōnsilium).
  bool get isIusStem => declension == Declension.secunda && (lemma.endsWith('ius') || lemma.endsWith('ium'));

  /// True for second-declension nouns whose nominative is not stem + us
  /// (puer, ager, vir): vocative = nominative.
  bool get isErStem => declension == Declension.secunda && !isNeuter && !lemma.endsWith('us');
}

extension GenderAbbreviation on Gender {
  String get abbreviation => switch (this) {
        Gender.masculinum => 'm.',
        Gender.femininum => 'f.',
        Gender.neutrum => 'n.',
      };
}

/// One complete analysis of a declined noun form.
class NounAnalysis {
  const NounAnalysis({
    required this.lemmaId,
    required this.casus,
    required this.number,
    required this.gender,
    required this.declension,
    this.variant = VariantKind.norma,
  });

  final String lemmaId;
  final Casus casus;
  final Numerus number;
  final Gender gender;
  final Declension declension;
  final VariantKind variant;

  bool get isPrimary => variant.isPrimary;

  /// Stable selector, e.g. `acc.sg`, `gen.pl`, `loc.sg`.
  String get selector => '${casus.key}.${number.key}';

  /// Skill id of this cell in the Tabula: `d.1.acc.sg`; the locative has its
  /// own skill (`d.loc`).
  String get skillId => casus == Casus.locativus ? 'd.loc' : 'd.${declension.ordinal}.${casus.key}.${number.key}';

  NounAnalysis copyWith({Casus? casus, Numerus? number, VariantKind? variant}) => NounAnalysis(
        lemmaId: lemmaId,
        casus: casus ?? this.casus,
        number: number ?? this.number,
        gender: gender,
        declension: declension,
        variant: variant ?? this.variant,
      );

  /// Case and number only: `accūsātīvus singulāris`.
  String describeCell() => '${casus.latin.toLowerCase()} ${number.latin.toLowerCase()}';

  /// Latin description with the variant kind when relevant.
  String describe({bool withDeclension = false}) {
    final b = '${casus.latin.toLowerCase()} ${number.latin.toLowerCase()}';
    final v = variant == VariantKind.norma ? '' : ' · ${variant.latin}';
    return withDeclension ? '$b · ${declension.latin.toLowerCase()} dēclīnātiō$v' : '$b$v';
  }

  Map<String, Object?> toJson() => {
        'l': lemmaId,
        'c': casus.key,
        'n': number.key,
        'g': gender.key,
        'd': declension.key,
        if (variant != VariantKind.norma) 'va': variant.key,
      };

  @override
  bool operator ==(Object other) =>
      other is NounAnalysis && other.lemmaId == lemmaId && other.casus == casus && other.number == number && other.gender == gender && other.declension == declension && other.variant == variant;

  @override
  int get hashCode => Object.hash(lemmaId, casus, number, gender, declension, variant);

  @override
  String toString() => '$lemmaId:$selector${variant.isPrimary ? '' : '[${variant.key}]'}';
}

/// A declined surface form with its analysis.
class NounForm {
  const NounForm(this.surface, this.analysis);
  final String surface;
  final NounAnalysis analysis;

  bool get isPrimary => analysis.isPrimary;

  @override
  String toString() => '$surface ⟨${analysis.describe()}⟩';
}
