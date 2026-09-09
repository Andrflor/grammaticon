/// Adjective model (A&G §109–§131): entries of the two classes, with their
/// comparison, and the analyses produced by the adjective declinator.
library;

import 'nominal.dart';

/// The two classes of adjectives.
enum AdjClass {
  /// bonus, -a, -um; pulcher, -chra, -chrum; miser, -era, -erum (A&G §110–§112).
  primaSecunda('12', 'Prīma et secunda'),

  /// ācer, fortis, fēlīx and the consonant stems (A&G §114–§122).
  tertia('3', 'Tertia');

  const AdjClass(this.key, this.latin);
  final String key;
  final String latin;
  static AdjClass fromKey(String k) => values.firstWhere((e) => e.key == k);
}

/// How the comparative and superlative are formed.
enum ComparisonKind {
  /// -ior / -issimus (-errimus for -er, -illimus for six -ilis adjectives).
  regularis,

  /// Given explicitly on the entry (bonus, melior, optimus).
  irregularis,

  /// Periphrastic with magis / maximē (idōneus, arduus): no forms.
  periphrastica,

  /// No comparison (numerals, possessives, most pronominal adjectives).
  nulla,
}

class AdjectiveEntry implements Lexeme {
  const AdjectiveEntry({
    required this.id,
    required this.lemma,
    required this.entry,
    required this.cls,
    required this.stem,
    required this.glossFr,
    this.terminations = 3,
    this.nomM,
    this.nomF,
    this.nomN,
    this.pronominal = false,
    this.consonantStem = false,
    this.comparison = ComparisonKind.regularis,
    this.comparative,
    this.superlativeStem,
    this.hasPositive = true,
    this.overrides = const {},
    this.absent = const [],
    this.tags = const {},
    this.ordinalValue,
    this.provenance = const [],
    this.notes = '',
  });

  @override
  final String id;

  /// Masculine nominative singular of the positive (or of the comparative
  /// when the positive is missing: `prior`).
  @override
  final String lemma;

  /// Dictionary entry (`bonus, -a, -um`; `fortis, -e`; `fēlīx, -īcis`).
  final String entry;
  final AdjClass cls;

  /// Stem of the positive to which endings are added (`bon`, `pulchr`,
  /// `fort`, `fēlīc`, `ācr`).
  final String stem;
  @override
  final String glossFr;

  /// Number of nominative singular forms of a third-class adjective
  /// (3 ācer/ācris/ācre, 2 fortis/forte, 1 fēlīx). Ignored for the first
  /// class.
  final int terminations;

  /// Explicit nominatives singular when they are not stem + ending
  /// (pulcher, ācer, fēlīx). Null: derived (stem + us/a/um; stem + is/e).
  final String? nomM;
  final String? nomF;
  final String? nomN;

  /// Genitive singular -īus and dative -ī in all genders (ūnus, sōlus, tōtus,
  /// alius, alter, uter, neuter, nūllus, ūllus; A&G §113).
  final bool pronominal;

  /// Third-class adjective declined like a consonant stem: ablative -e,
  /// genitive plural -um, neuter plural -a (vetus, pauper, dīves; A&G §121).
  final bool consonantStem;
  final ComparisonKind comparison;

  /// Masculine/feminine nominative singular of the comparative when it is
  /// irregular (`melior`); the neuter and oblique stem are derived.
  final String? comparative;

  /// Stem of the superlative when irregular (`optim`).
  final String? superlativeStem;

  /// False for comparatives without positive (prior, ulterior): the entry's
  /// lemma is the comparative and only comparative and superlative forms exist.
  final bool hasPositive;

  /// Explicit cells by selector (`voc.sg.m`, `comp.nom.sg.n`, `sup.acc.pl.f`).
  final Map<String, List<String>> overrides;

  /// Selector prefixes never generated (`voc` for pronominal adjectives).
  final List<String> absent;

  /// Free tags used by trial filters (`possessivum`, `pronominale`,
  /// `ordinale`, `correlativum`, `ilis`, `er`).
  final Set<String> tags;

  /// Value of an ordinal numeral (prīmus = 1).
  final int? ordinalValue;
  @override
  final List<String> provenance;
  @override
  final String notes;

  @override
  WordClass get wordClass => WordClass.adiectivum;
  @override
  String get dictionaryEntry => entry;
  @override
  bool get isProper => lemma[0].toUpperCase() == lemma[0] && lemma[0].toLowerCase() != lemma[0];

  bool get isFirstClass => cls == AdjClass.primaSecunda;
  bool get isThirdClass => cls == AdjClass.tertia;

  /// Masculine nominative singular of the positive.
  String get nominativeM => nomM ?? (isFirstClass ? '${stem}us' : '${stem}is');
  String get nominativeF => nomF ?? (isFirstClass ? '${stem}a' : nominativeM);
  String get nominativeN => nomN ?? (isFirstClass ? '${stem}um' : (terminations == 1 ? nominativeM : '${stem}e'));

  /// True for first-class adjectives in -er (pulcher, miser, noster).
  bool get isErType => isFirstClass && nominativeM.endsWith('er');

  bool get hasComparison => comparison == ComparisonKind.regularis || comparison == ComparisonKind.irregularis;
}
