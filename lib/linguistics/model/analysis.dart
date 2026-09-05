import 'grammar.dart';

/// One complete morphological analysis of a verb form.
///
/// Finite forms carry [person] and [number]; nominal forms (participles,
/// gerundive, gerund, supine) carry [casus], [gender] and [number]; infinitives
/// carry tense and voice only. Composite forms (amātus est, amātūrus sim) keep
/// the gender of their participle in [gender].
class Analysis {
  const Analysis({
    required this.lemmaId,
    required this.mood,
    this.tense,
    this.voice,
    this.person,
    this.number,
    this.gender,
    this.casus,
    this.periphrasis = Periphrasis.nulla,
    this.composite = false,
    this.variant = VariantKind.norma,
    this.semanticVoice,
    this.semanticTense,
  });

  final String lemmaId;
  final Mood mood;
  final Tense? tense;
  final Voice? voice;
  final Person? person;
  final Numerus? number;
  final Gender? gender;
  final Casus? casus;
  final Periphrasis periphrasis;

  /// True when the form is made of participle + auxiliary (amātus sum).
  final bool composite;
  final VariantKind variant;

  /// Meaning-level voice when it differs from the morphology (deponents:
  /// passive morphology, active meaning).
  final Voice? semanticVoice;

  /// Meaning-level tense when it differs from the morphology (ōdī: perfect
  /// morphology, present meaning).
  final Tense? semanticTense;

  Voice? get effectiveSemanticVoice => semanticVoice ?? voice;
  Tense? get effectiveSemanticTense => semanticTense ?? tense;

  bool get isFinite => mood.isFinite;
  bool get isNominal => mood.isNominal;
  bool get isPrimary => variant.isPrimary;

  /// Stable selector, e.g. `ind.praes.act.1.sg`, `part.perf.pass.nom.sg.m`,
  /// `pa.ind.praes.1.sg.m` (periphrastic), `ger.gen`, `sup.acc`.
  String get selector {
    final parts = <String>[];
    if (periphrasis != Periphrasis.nulla) parts.add(periphrasis.key);
    parts.add(mood.key);
    if (tense != null) parts.add(tense!.key);
    if (voice != null) parts.add(voice!.key);
    if (person != null) parts.add(person!.key);
    if (casus != null) parts.add(casus!.key);
    if (number != null) parts.add(number!.key);
    if (gender != null) parts.add(gender!.key);
    return parts.join('.');
  }

  Analysis copyWith({
    String? lemmaId,
    Mood? mood,
    Tense? tense,
    Voice? voice,
    Person? person,
    Numerus? number,
    Gender? gender,
    Casus? casus,
    Periphrasis? periphrasis,
    bool? composite,
    VariantKind? variant,
    Voice? semanticVoice,
    Tense? semanticTense,
    bool clearSemantic = false,
  }) {
    return Analysis(
      lemmaId: lemmaId ?? this.lemmaId,
      mood: mood ?? this.mood,
      tense: tense ?? this.tense,
      voice: voice ?? this.voice,
      person: person ?? this.person,
      number: number ?? this.number,
      gender: gender ?? this.gender,
      casus: casus ?? this.casus,
      periphrasis: periphrasis ?? this.periphrasis,
      composite: composite ?? this.composite,
      variant: variant ?? this.variant,
      semanticVoice: clearSemantic ? null : (semanticVoice ?? this.semanticVoice),
      semanticTense: clearSemantic ? null : (semanticTense ?? this.semanticTense),
    );
  }

  /// Full Latin description, e.g.
  /// "tertia persōna singulāris · indicātīvus imperfectum · āctīvum".
  String describe({bool withLemma = false}) {
    final b = <String>[];
    if (periphrasis != Periphrasis.nulla) b.add(periphrasis.latin.toLowerCase());
    switch (mood) {
      case Mood.indicativus:
      case Mood.subiunctivus:
      case Mood.imperativus:
        b.add('${person!.latin.toLowerCase()} persōna ${number!.latin.toLowerCase()}');
        b.add('${mood.latin.toLowerCase()} ${tense!.latin.toLowerCase()}');
        if (voice != null) b.add(voice!.latin.toLowerCase());
        if (gender != null) b.add(gender!.latin.toLowerCase());
      case Mood.infinitivus:
        b.add('${mood.latin.toLowerCase()} ${tense!.latin.toLowerCase()}');
        if (voice != null) b.add(voice!.latin.toLowerCase());
        if (gender != null) b.add(gender!.latin.toLowerCase());
        if (number != null) b.add(number!.latin.toLowerCase());
      case Mood.participium:
        b.add('${mood.latin.toLowerCase()} ${tense!.latin.toLowerCase()} ${voice!.latin.toLowerCase()}');
        b.add('${casus!.latin.toLowerCase()} ${number!.latin.toLowerCase()} ${gender!.latin.toLowerCase()}');
      case Mood.gerundivum:
        b.add(mood.latin.toLowerCase());
        b.add('${casus!.latin.toLowerCase()} ${number!.latin.toLowerCase()} ${gender!.latin.toLowerCase()}');
      case Mood.gerundium:
        b.add('${mood.latin.toLowerCase()} ${casus!.latin.toLowerCase()}');
      case Mood.supinum:
        b.add('${mood.latin.toLowerCase()} ${casus!.latin.toLowerCase()}');
    }
    if (variant != VariantKind.norma) b.add(variant.latin);
    if (withLemma) b.add('($lemmaId)');
    return b.join(' · ');
  }

  Map<String, Object?> toJson() => {
        'l': lemmaId,
        'm': mood.key,
        if (tense != null) 't': tense!.key,
        if (voice != null) 'v': voice!.key,
        if (person != null) 'p': person!.key,
        if (number != null) 'n': number!.key,
        if (gender != null) 'g': gender!.key,
        if (casus != null) 'c': casus!.key,
        if (periphrasis != Periphrasis.nulla) 'pe': periphrasis.key,
        if (composite) 'co': true,
        if (variant != VariantKind.norma) 'va': variant.key,
        if (semanticVoice != null) 'sv': semanticVoice!.key,
        if (semanticTense != null) 'st': semanticTense!.key,
      };

  factory Analysis.fromJson(Map<String, Object?> j) => Analysis(
        lemmaId: j['l'] as String,
        mood: Mood.fromKey(j['m'] as String),
        tense: j['t'] == null ? null : Tense.fromKey(j['t'] as String),
        voice: j['v'] == null ? null : Voice.fromKey(j['v'] as String),
        person: j['p'] == null ? null : Person.fromKey(j['p'] as String),
        number: j['n'] == null ? null : Numerus.fromKey(j['n'] as String),
        gender: j['g'] == null ? null : Gender.fromKey(j['g'] as String),
        casus: j['c'] == null ? null : Casus.fromKey(j['c'] as String),
        periphrasis: j['pe'] == null ? Periphrasis.nulla : Periphrasis.fromKey(j['pe'] as String),
        composite: j['co'] == true,
        variant: j['va'] == null ? VariantKind.norma : VariantKind.fromKey(j['va'] as String),
        semanticVoice: j['sv'] == null ? null : Voice.fromKey(j['sv'] as String),
        semanticTense: j['st'] == null ? null : Tense.fromKey(j['st'] as String),
      );

  @override
  bool operator ==(Object other) =>
      other is Analysis &&
      other.lemmaId == lemmaId &&
      other.mood == mood &&
      other.tense == tense &&
      other.voice == voice &&
      other.person == person &&
      other.number == number &&
      other.gender == gender &&
      other.casus == casus &&
      other.periphrasis == periphrasis &&
      other.composite == composite &&
      other.variant == variant;

  @override
  int get hashCode => Object.hash(lemmaId, mood, tense, voice, person, number,
      gender, casus, periphrasis, composite, variant);

  @override
  String toString() => '$lemmaId:$selector${variant.isPrimary ? '' : '[${variant.key}]'}';
}

/// A generated surface form with its analysis.
class FormEntry {
  const FormEntry(this.surface, this.analysis);
  final String surface;
  final Analysis analysis;

  bool get isPrimary => analysis.isPrimary;
  bool get composite => analysis.composite;

  @override
  String toString() => '$surface ⟨${analysis.describe()}⟩';
}

/// Record of a form that is deliberately absent from a paradigm.
class AbsentForm {
  const AbsentForm(this.selectorPrefix, this.status, {this.note = ''});

  /// Selector or selector prefix (e.g. `imp.` removes all imperatives).
  final String selectorPrefix;
  final AbsenceStatus status;
  final String note;

  /// Segment-wise prefix match; `*` matches any single segment.
  /// `ind.*.pass` matches `ind.praes.pass.3.sg`; `imp` matches every
  /// imperative; `pa` matches every active periphrastic form.
  bool matches(String selector) {
    final pat = selectorPrefix.split('.');
    final sel = selector.split('.');
    if (pat.length > sel.length) return false;
    for (var i = 0; i < pat.length; i++) {
      if (pat[i] != '*' && pat[i] != sel[i]) return false;
    }
    return true;
  }
}
