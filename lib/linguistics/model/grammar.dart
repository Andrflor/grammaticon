/// Grammatical categories of the Latin verb.
///
/// Every enum carries a Latin display label (`latin`) because the whole UI is
/// written in Latin, and a stable `key` used for serialisation and for form
/// selectors such as `ind.praes.act.1.sg`.
library;

enum Mood {
  indicativus('ind', 'Indicātīvus'),
  subiunctivus('subj', 'Subiūnctīvus'),
  imperativus('imp', 'Imperātīvus'),
  infinitivus('inf', 'Īnfīnītīvus'),
  participium('part', 'Participium'),
  gerundium('ger', 'Gerundium'),
  gerundivum('gdv', 'Gerundīvum'),
  supinum('sup', 'Supīnum');

  const Mood(this.key, this.latin);
  final String key;
  final String latin;

  /// Finite moods carry person and number.
  bool get isFinite =>
      this == indicativus || this == subiunctivus || this == imperativus;

  /// Nominal (declinable) verb forms carry case, gender and number.
  bool get isNominal =>
      this == participium || this == gerundivum || this == gerundium || this == supinum;

  static Mood fromKey(String k) => values.firstWhere((m) => m.key == k);
}

enum Tense {
  praesens('praes', 'Praesēns'),
  imperfectum('imperf', 'Imperfectum'),
  futurum('fut', 'Futūrum'),
  perfectum('perf', 'Perfectum'),
  plusquamperfectum('plusq', 'Plūsquamperfectum'),
  futurumExactum('futex', 'Futūrum exāctum');

  const Tense(this.key, this.latin);
  final String key;
  final String latin;

  bool get isPerfectSystem =>
      this == perfectum || this == plusquamperfectum || this == futurumExactum;

  static Tense fromKey(String k) => values.firstWhere((m) => m.key == k);
}

enum Voice {
  activum('act', 'Āctīvum'),
  passivum('pass', 'Passīvum');

  const Voice(this.key, this.latin);
  final String key;
  final String latin;
  static Voice fromKey(String k) => values.firstWhere((m) => m.key == k);
}

enum Person {
  prima(1, 'Prīma'),
  secunda(2, 'Secunda'),
  tertia(3, 'Tertia');

  const Person(this.index1, this.latin);
  final int index1;
  final String latin;
  String get key => '$index1';
  static Person fromKey(String k) => values.firstWhere((m) => m.key == k);
}

enum Numerus {
  singularis('sg', 'Singulāris'),
  pluralis('pl', 'Plūrālis');

  const Numerus(this.key, this.latin);
  final String key;
  final String latin;
  static Numerus fromKey(String k) => values.firstWhere((m) => m.key == k);
}

enum Gender {
  masculinum('m', 'Masculīnum'),
  femininum('f', 'Fēminīnum'),
  neutrum('n', 'Neutrum');

  const Gender(this.key, this.latin);
  final String key;
  final String latin;
  static Gender fromKey(String k) => values.firstWhere((m) => m.key == k);
}

enum Casus {
  nominativus('nom', 'Nōminātīvus'),
  vocativus('voc', 'Vocātīvus'),
  accusativus('acc', 'Accūsātīvus'),
  genetivus('gen', 'Genetīvus'),
  dativus('dat', 'Datīvus'),
  ablativus('abl', 'Ablātīvus'),
  /// Locative: only for nouns where it is attested (A&G §427); never part
  /// of verbal paradigms.
  locativus('loc', 'Locātīvus');

  const Casus(this.key, this.latin);
  final String key;
  final String latin;
  static Casus fromKey(String k) => values.firstWhere((m) => m.key == k);

  /// The six cases of every paradigm (locative excluded).
  static const List<Casus> ordinary = [nominativus, vocativus, accusativus, genetivus, dativus, ablativus];
}

/// Noun declensions (A&G §37).
enum Declension {
  prima('d1', 'Prīma'),
  secunda('d2', 'Secunda'),
  tertia('d3', 'Tertia'),
  quarta('d4', 'Quārta'),
  quinta('d5', 'Quīnta');

  const Declension(this.key, this.latin);
  final String key;
  final String latin;

  /// 1-based ordinal used in skill ids (`d.3.acc.sg`).
  int get ordinal => index + 1;
  static Declension fromKey(String k) => values.firstWhere((m) => m.key == k);
}

enum Conjugation {
  prima('c1', 'Prīma'),
  secunda('c2', 'Secunda'),
  tertia('c3', 'Tertia'),
  tertiaIo('c3io', 'Tertia (-iō)'),
  quarta('c4', 'Quārta'),
  anomala('anom', 'Anōmala');

  const Conjugation(this.key, this.latin);
  final String key;
  final String latin;
  static Conjugation fromKey(String k) => values.firstWhere((m) => m.key == k);
}

/// Morphosyntactic class of the lemma.
enum VerbKind {
  regulare('reg', 'Regulāre'),
  deponens('dep', 'Dēpōnēns'),
  semideponens('semidep', 'Sēmidēpōnēns'),
  /// Present system deponent, perfect system active (revertor, revertī).
  semideponensInversum('semidepinv', 'Sēmidēpōnēns inversum'),
  anomalum('anom', 'Anōmalum'),
  defectivum('def', 'Dēfectīvum'),
  impersonale('impers', 'Impersōnāle');

  const VerbKind(this.key, this.latin);
  final String key;
  final String latin;
  static VerbKind fromKey(String k) => values.firstWhere((m) => m.key == k);
}

/// Periphrastic conjugations (A&G §193–196).
enum Periphrasis {
  nulla('-', ''),
  /// Future active participle + sum: amātūrus sum.
  activa('pa', 'Periphrastica āctīva'),
  /// Gerundive + sum: amandus sum.
  passiva('pp', 'Periphrastica passīva');

  const Periphrasis(this.key, this.latin);
  final String key;
  final String latin;
  static Periphrasis fromKey(String k) => values.firstWhere((m) => m.key == k);
}

/// How a form deviates from the primary paradigm.
enum VariantKind {
  /// Primary, standard form.
  norma('norma', ''),
  /// Free alternative of equal standing (amante / amantī).
  altera('alt', 'forma altera'),
  /// Attested but rare (present indicative 2 sg passive in -re).
  rara('rara', 'forma rāra'),
  /// Third plural perfect in -ēre (amāvēre).
  perfectumEre('ere', 'forma in -ēre'),
  /// Second singular passive in -re (amābāre).
  passivumRe('re', 'forma in -re'),
  /// Syncopated perfect (amāstī, audiit, nōsse).
  syncopa('sync', 'forma contracta'),
  /// Composite with fuī instead of sum (amātus fuī).
  fuiAuxiliare('fui', 'cum auxiliārī fuī'),
  /// forem / fore for essem / futūrus esse.
  forem('forem', 'forma forem/fore'),
  /// Gerundive in -undus (dīcundus).
  undus('undus', 'forma in -undus'),
  /// Archaic or otherwise rare but attested alternative.
  archaica('arch', 'forma archaica'),
  /// Late / Vulgate register.
  seriora('ser', 'forma sērior');

  const VariantKind(this.key, this.latin);
  final String key;
  final String latin;
  static VariantKind fromKey(String k) => values.firstWhere((m) => m.key == k);

  bool get isPrimary => this == norma;
}

/// Why a form is absent for a given verb.
enum AbsenceStatus {
  /// Grammatically impossible for this verb (a deponent has no active forms).
  nonExstat('nonexstat', 'nōn exstat'),
  /// Possible in principle but not attested in the sources consulted.
  nonAttestatur('nonattest', 'nōn attestātur'),
  /// Attested but not used in classical prose (imperative scī).
  nonUsitatur('nonusit', 'nōn ūsitātur'),
  /// Data missing from this lexicon: not a linguistic statement.
  datumDeest('deest', 'datum dēest');

  const AbsenceStatus(this.key, this.latin);
  final String key;
  final String latin;
  static AbsenceStatus fromKey(String k) => values.firstWhere((m) => m.key == k);
}
