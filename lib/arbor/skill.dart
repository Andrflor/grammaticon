/// L'arbre des compétences : nœuds, arêtes et couches.
///
/// Un nœud est un *maillon isolable* (voir `doc/arbor/00_schema.md`) : un savoir
/// ou une opération qu'un distracteur peut faire échouer seul et qui se retrouve
/// dans plusieurs formes ou plusieurs phrases. Les couches 0, 1, 3, 4 (cœur) et 5
/// sont rédigées à la main ; la couche 2 (cases de paradigme) est dérivée.
library;

/// Couche du nœud.
enum Stratum {
  /// L0 — catégories grammaticales (cas, temps, mode, voix, degré, classe).
  notio,

  /// L1 — maillons morphologiques : thèmes, marqueurs, désinences, alternances.
  elementum,

  /// L2 — cases de paradigme, composées de maillons L1.
  cella,

  /// L3 — syntaxe : fonctions, accord, propositions, constructions.
  syntaxis,

  /// L4 — lexique : un nœud par lexème, procédés de formation.
  lexicon,

  /// L5 — lecture, traduction, prosodie, écriture.
  lectio,
}

/// Mécanisme d'une confusion entre deux nœuds.
enum Modus {
  /// Même surface : *rosae* génitif, datif ou nominatif pluriel.
  syncretismus,

  /// Surfaces proches : -bā- (imparfait) et -bi- (futur).
  similitudo,

  /// Transfert d'une classe à l'autre : *audiēbat* lu comme un futur de 1re/2e.
  analogia,

  /// Sens voisins : *petere* / *quaerere*.
  sensus,

  /// Même cas, fonctions voisines : ablatif de moyen / de cause.
  functio,
}

/// Dimension par laquelle un nœud se teste (la consigne posée au joueur).
enum Dimensio {
  persona('Quae persōna?'),
  numerus('Quī numerus?'),
  personaNumerus('Quae persōna et quī numerus?'),
  tempus('Quod tempus?'),
  tempusSensus('Quod tempus sēnsū?'),
  modus('Quī modus?'),
  tempusModus('Quod tempus, quī modus?'),
  vox('Quae vōx?'),
  voxSensus('Quae vōx sēnsū?'),
  coniugatio('Quae coniugātiō?'),
  declinatio('Quae dēclīnātiō?'),
  thema('Quod thema nōminis?'),
  genus('Quod genus?'),
  casus('Quī cāsus?'),
  forma('Quae fōrma?'),
  lemma('Quod verbum?'),
  formaPlena('Quae fōrma plēna?'),
  analysis('Quae analysis?'),
  genusNumerus('Quod genus, quī numerus?'),
  classis('Quae classis adiectīvī?'),
  gradus('Quī gradus?'),
  functio('Quae fūnctiō in sententiā?'),
  constructio('Quae cōnstrūctiō?'),
  relatio('Ad quem refertur?'),
  quodNomen('Cum quō nōmine congruit?'),
  correlativum('Quod correlātīvum respondet?'),
  valor('Quantum significat?'),
  /// Theatrum : quelle traduction française rend fidèlement la phrase.
  sensus('Sententiārum sēnsum Gallicē redde.'),
  /// Templum : quelle forme ou quelle phrase latine rend le français.
  productio('Sententiam Latīnē complē.'),
  /// Vocabulaire dans les deux sens.
  vocabulum('Quid significat?');

  const Dimensio(this.rogatio);

  /// Consigne latine affichée.
  final String rogatio;
}

/// Arête « A se confond avec B ». Écrite une fois ; l'arbre la rend symétrique.
class Confusio {
  const Confusio(this.cum, this.modus, {this.nota = ''});

  /// Identifiant du nœud confondu.
  final String cum;
  final Modus modus;

  /// Note d'auteur (français), jamais affichée.
  final String nota;
}

/// Un nœud de l'arbre.
class Skill {
  const Skill(
    this.id, {
    required this.nomen,
    required this.quid,
    required this.stratum,
    this.notiones = const [],
    this.pars = const [],
    this.requirit = const [],
    this.confunditur = const [],
    this.exempla = const [],
    this.probatur = const [],
    this.fontes = const [],
    this.visibilis = true,
    this.parens,
  });

  /// Identifiant stable (clé de sauvegarde).
  final String id;

  /// Nom latin, affiché dans la Tabula.
  final String nomen;

  /// Ce que sait faire le joueur qui maîtrise ce nœud (français, pour l'auteur).
  final String quid;
  final Stratum stratum;

  /// Notions L0 que ce nœud met en jeu.
  final List<String> notiones;

  /// Composants de ce nœud (`pars`) : une case L2 liste les maillons L1 qui la
  /// composent ; une construction L3 liste les fonctions et formes qu'elle met
  /// en jeu. Vide pour un maillon.
  final List<String> pars;

  /// Nœuds que ce lexème réalise ou illustre (`exemplum`) : sa classe, ses cases
  /// irrégulières. Vide hors de la couche lexicale.
  final List<String> exempla;

  /// Prérequis pédagogiques (jamais déduits de la composition). Acyclique.
  final List<String> requirit;
  final List<Confusio> confunditur;

  /// Dimensions qui isolent ce nœud.
  final List<Dimensio> probatur;

  /// Renvois à Allen & Greenough (« A&G §184 »).
  final List<String> fontes;

  /// Affiché dans la Tabula ? Les cases L2 et les lexèmes sont visibles par
  /// leurs agrégats, pas un à un.
  final bool visibilis;

  /// Parent d'affichage (hiérarchie de la Tabula), indépendant de `pars`.
  final String? parens;

  Skill copyWith({
    List<String>? pars,
    List<Confusio>? confunditur,
    List<String>? requirit,
    String? parens,
    bool? visibilis,
  }) => Skill(
    id,
    nomen: nomen,
    quid: quid,
    stratum: stratum,
    notiones: notiones,
    pars: pars ?? this.pars,
    exempla: exempla,
    requirit: requirit ?? this.requirit,
    confunditur: confunditur ?? this.confunditur,
    probatur: probatur,
    fontes: fontes,
    visibilis: visibilis ?? this.visibilis,
    parens: parens ?? this.parens,
  );

  @override
  String toString() => '$id ($nomen)';
}
