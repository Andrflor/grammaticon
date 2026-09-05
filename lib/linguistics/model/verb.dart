import 'analysis.dart';
import 'grammar.dart';

/// A verb of the lexicon with its principal parts, class and irregularities.
///
/// Stems are always derived from the principal parts by the conjugator; the
/// lexicon never stores derived forms except in [overrides], which are used
/// for irregular paradigms and attested variants that no rule produces.
class VerbEntry {
  const VerbEntry({
    required this.id,
    required this.lemma,
    required this.principalParts,
    required this.conjugation,
    required this.kind,
    this.family,
    this.glossFr = '',
    this.intransitive = false,
    this.hasSupine = true,
    this.hasPerfect = true,
    this.hasPresentSystem = true,
    this.overrides = const {},
    this.absent = const [],
    this.provenance = const [],
    this.notes = '',
    this.compoundOf,
    this.prefix,
    this.prefixBeforeVowel,
    this.shortA = false,
    this.perfectHasPresentSense = false,
    this.explicitOnly = false,
  });

  /// Stable identifier, ASCII, e.g. `amo`, `sum`, `sequor`, `odi`.
  final String id;

  /// Lemma with macrons as displayed, e.g. `amō`.
  final String lemma;

  /// Principal parts with macrons: [1sg present, infinitive, 1sg perfect,
  /// supine/perfect participle]. Missing parts are given as `-`.
  final List<String> principalParts;
  final Conjugation conjugation;
  final VerbKind kind;

  /// Irregular family this verb belongs to (`sum`, `eo`, `fero`, `volo`,
  /// `fio`, `do`, `edo`).
  final String? family;
  final String glossFr;

  /// Intransitive verbs only have impersonal (3 sg neuter) passive forms.
  final bool intransitive;
  final bool hasSupine;
  final bool hasPerfect;

  /// False for perfect-only defectives (ōdī, meminī, coepī).
  final bool hasPresentSystem;

  /// Explicit forms by selector. First surface is the primary form, following
  /// ones are variants (see [VerbEntry.variantOf]). A selector may be a full
  /// key (`ind.praes.act.1.sg`) or a periphrasis-free nominal key
  /// (`part.praes.act.nom.sg.m`).
  final Map<String, List<String>> overrides;

  /// Forms that must not be generated, with the reason.
  final List<AbsentForm> absent;

  /// Human-readable source references, e.g. `A&G §184`.
  final List<String> provenance;
  final String notes;

  /// Compounds inherit the irregular paradigm of [compoundOf] with [prefix].
  final String? compoundOf;
  final String? prefix;

  /// Alternative prefix before a vowel (prōsum: prōd-est).
  final String? prefixBeforeVowel;

  /// dō and its compounds: short a everywhere except dās, dā, dāns.
  final bool shortA;

  /// ōdī, meminī: perfect morphology with present meaning.
  final bool perfectHasPresentSense;

  /// Only the forms listed in [overrides] exist (inquam, āiō, quaesō).
  final bool explicitOnly;

  String get presentFirst => principalParts[0];
  String get infinitive => principalParts.length > 1 ? principalParts[1] : '-';
  String get perfectFirst => principalParts.length > 2 ? principalParts[2] : '-';
  String get supine => principalParts.length > 3 ? principalParts[3] : '-';

  bool get isDeponent =>
      kind == VerbKind.deponens || kind == VerbKind.semideponensInversum;
  bool get isSemiDeponent => kind == VerbKind.semideponens;
  bool get isImpersonal => kind == VerbKind.impersonale;
  bool get isDefective => kind == VerbKind.defectivum;
  bool get isIrregular => kind == VerbKind.anomalum || conjugation == Conjugation.anomala;

  /// Present stem: infinitive without -re / -rī / -ī (deponent III).
  String get presentStem {
    final inf = infinitive;
    if (isDeponent) {
      if (inf.endsWith('ārī')) return inf.substring(0, inf.length - 2); // hortā
      if (inf.endsWith('ērī')) return inf.substring(0, inf.length - 2); // verē
      if (inf.endsWith('īrī')) return inf.substring(0, inf.length - 2); // potī
      if (inf.endsWith('ī')) return inf.substring(0, inf.length - 1); // sequ, pat
      return inf;
    }
    if (inf.endsWith('re')) return inf.substring(0, inf.length - 2);
    return inf;
  }

  /// Perfect stem: 1sg perfect without final ī (amāv, fu, tul).
  String? get perfectStem {
    final p = perfectFirst;
    if (p == '-' || p.isEmpty) return null;
    // Deponent / semi-deponent perfect is composite: "secūtus sum".
    if (p.endsWith(' sum')) return null;
    // Impersonal verbs list the 3 sg perfect (licuit -> licu-).
    if (kind == VerbKind.impersonale && p.endsWith('it')) return p.substring(0, p.length - 2);
    if (p.endsWith('ī')) return p.substring(0, p.length - 1);
    return p;
  }

  /// Participle stem: supine / perfect participle without -um / -us.
  String? get supineStem {
    var s = supine;
    if (s == '-' || s.isEmpty) return null;
    if (s.endsWith(' sum')) s = s.substring(0, s.length - 4);
    if (s.endsWith('um') || s.endsWith('us')) return s.substring(0, s.length - 2);
    return s;
  }

  /// Perfect participle stem taken from the deponent perfect (secūtus sum).
  String? get deponentParticipleStem {
    final p = perfectFirst;
    if (!p.endsWith(' sum')) return null;
    final part = p.substring(0, p.length - 4);
    return part.substring(0, part.length - 2);
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'lemma': lemma,
        'pp': principalParts,
        'conj': conjugation.key,
        'kind': kind.key,
        if (family != null) 'family': family,
        'gloss': glossFr,
        if (intransitive) 'intr': true,
        if (!hasSupine) 'noSup': true,
        if (!hasPerfect) 'noPerf': true,
        if (!hasPresentSystem) 'noPraes': true,
        if (overrides.isNotEmpty) 'over': overrides,
        if (absent.isNotEmpty)
          'absent': absent
              .map((a) => {'sel': a.selectorPrefix, 'st': a.status.key, if (a.note.isNotEmpty) 'note': a.note})
              .toList(),
        'prov': provenance,
        if (notes.isNotEmpty) 'notes': notes,
        if (compoundOf != null) 'compoundOf': compoundOf,
        if (prefix != null) 'prefix': prefix,
        if (prefixBeforeVowel != null) 'prefixV': prefixBeforeVowel,
        if (shortA) 'shortA': true,
        if (perfectHasPresentSense) 'perfPraes': true,
        if (explicitOnly) 'explicitOnly': true,
      };
}
