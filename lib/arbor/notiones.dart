/// L0 — Nōtiōnēs : les catégories grammaticales.
///
/// Une notion n'est pas un maillon (on ne la fait pas échouer seule) ; elle sert
/// d'agrégat dans la Tabula et de dimension d'analyse. Les maillons L1 la citent
/// dans `notiones`.
library;

import 'skill.dart';

Skill _n(String id, String nomen, String quid, {String? parens, List<String> fontes = const []}) =>
    Skill(id, nomen: nomen, quid: quid, stratum: Stratum.notio, parens: parens, fontes: fontes);

const _ag = 'A&G';

final List<Skill> kNotiones = [
  // ----- racines d'affichage -----
  _n('not', 'Nōtiōnēs grammaticae', 'Catégories de la grammaire latine.'),
  _n('not.casus', 'Cāsus', 'Les cas : ce qu\'un nom fait dans la phrase.', parens: 'not', fontes: ['$_ag §35']),
  _n('not.numerus', 'Numerus', 'Singulier et pluriel.', parens: 'not', fontes: ['$_ag §35']),
  _n('not.genus', 'Genus', 'Masculin, féminin, neutre.', parens: 'not', fontes: ['$_ag §30–34']),
  _n('not.persona', 'Persōna', 'Première, deuxième, troisième personne.', parens: 'not', fontes: ['$_ag §154']),
  _n('not.tempus', 'Tempus', 'Les temps du verbe.', parens: 'not', fontes: ['$_ag §154, §160']),
  _n('not.modus', 'Modus', 'Les modes du verbe.', parens: 'not', fontes: ['$_ag §154, §157']),
  _n('not.vox', 'Vōx', 'Actif, passif ; déponents.', parens: 'not', fontes: ['$_ag §154, §156']),
  _n('not.gradus', 'Gradus', 'Positif, comparatif, superlatif.', parens: 'not', fontes: ['$_ag §123']),
  _n('not.declinatio', 'Dēclīnātiō', 'Les cinq déclinaisons et leurs types de thème.', parens: 'not', fontes: ['$_ag §37']),
  _n('not.coniugatio', 'Coniugātiō', 'Les quatre conjugaisons et la 3e mixte.', parens: 'not', fontes: ['$_ag §171']),
  _n('not.classis', 'Classis adiectīvī', 'Adjectifs de 1re/2e classe et de 3e classe.', parens: 'not', fontes: ['$_ag §109–121']),
  _n('not.forma', 'Fōrmae nōminālēs verbī', 'Infinitif, participe, gérondif, adjectif verbal, supin.', parens: 'not', fontes: ['$_ag §155']),

  // ----- cas -----
  _n('not.casus.nom', 'Nōminātīvus', 'Cas du sujet et de l\'attribut.', parens: 'not.casus', fontes: ['$_ag §339']),
  _n('not.casus.voc', 'Vocātīvus', 'Cas de l\'interpellation.', parens: 'not.casus', fontes: ['$_ag §340']),
  _n('not.casus.acc', 'Accūsātīvus', 'Cas de l\'objet direct et de la direction.', parens: 'not.casus', fontes: ['$_ag §386']),
  _n('not.casus.gen', 'Genetīvus', 'Cas du complément du nom.', parens: 'not.casus', fontes: ['$_ag §342']),
  _n('not.casus.dat', 'Datīvus', 'Cas de l\'attribution.', parens: 'not.casus', fontes: ['$_ag §361']),
  _n('not.casus.abl', 'Ablātīvus', 'Cas de la séparation, du moyen, du lieu, du temps.', parens: 'not.casus', fontes: ['$_ag §398']),
  _n('not.casus.loc', 'Locātīvus', 'Cas du lieu où l\'on est (villes, petites îles, domī, rūrī).', parens: 'not.casus', fontes: ['$_ag §427']),

  // ----- nombre, genre, personne -----
  _n('not.numerus.sg', 'Singulāris', 'Un seul.', parens: 'not.numerus'),
  _n('not.numerus.pl', 'Plūrālis', 'Plusieurs.', parens: 'not.numerus'),
  _n('not.genus.m', 'Masculīnum', 'Genre masculin.', parens: 'not.genus'),
  _n('not.genus.f', 'Fēminīnum', 'Genre féminin.', parens: 'not.genus'),
  _n('not.genus.n', 'Neutrum', 'Genre neutre : nominatif = accusatif, pluriel en -a.', parens: 'not.genus', fontes: ['$_ag §38 b']),
  _n('not.persona.1', 'Prīma persōna', 'Celui qui parle.', parens: 'not.persona'),
  _n('not.persona.2', 'Secunda persōna', 'Celui à qui l\'on parle.', parens: 'not.persona'),
  _n('not.persona.3', 'Tertia persōna', 'Celui dont on parle.', parens: 'not.persona'),

  // ----- temps -----
  _n('not.tempus.praes', 'Praesēns', 'Le présent.', parens: 'not.tempus', fontes: ['$_ag §465']),
  _n('not.tempus.imperf', 'Imperfectum', 'Le passé en cours, répété ou habituel.', parens: 'not.tempus', fontes: ['$_ag §470']),
  _n('not.tempus.fut', 'Futūrum', 'Le futur.', parens: 'not.tempus', fontes: ['$_ag §472']),
  _n('not.tempus.perf', 'Perfectum', 'Le passé accompli (parfait).', parens: 'not.tempus', fontes: ['$_ag §473']),
  _n('not.tempus.plusq', 'Plūsquamperfectum', 'L\'antérieur d\'un passé.', parens: 'not.tempus', fontes: ['$_ag §477']),
  _n('not.tempus.futex', 'Futūrum exāctum', 'L\'antérieur d\'un futur.', parens: 'not.tempus', fontes: ['$_ag §478']),
  _n('not.tempus.systema.praes', 'Systēma praesentis', 'Présent, imparfait, futur : bâtis sur le radical du présent.', parens: 'not.tempus', fontes: ['$_ag §164']),
  _n('not.tempus.systema.perf', 'Systēma perfectī', 'Parfait, plus-que-parfait, futur antérieur : bâtis sur le radical du parfait.', parens: 'not.tempus', fontes: ['$_ag §164']),

  // ----- modes -----
  _n('not.modus.ind', 'Indicātīvus', 'Mode du fait.', parens: 'not.modus', fontes: ['$_ag §157 a']),
  _n('not.modus.subj', 'Subiūnctīvus', 'Mode de la volonté, du possible, de la subordination.', parens: 'not.modus', fontes: ['$_ag §157 b, §436']),
  _n('not.modus.imp', 'Imperātīvus', 'Mode de l\'ordre.', parens: 'not.modus', fontes: ['$_ag §157 c, §448']),
  _n('not.modus.inf', 'Īnfīnītīvus', 'Nom verbal ; sujet ou objet ; discours indirect.', parens: 'not.modus', fontes: ['$_ag §451']),

  // ----- voix -----
  _n('not.vox.act', 'Āctīvum', 'Le sujet fait l\'action.', parens: 'not.vox'),
  _n('not.vox.pass', 'Passīvum', 'Le sujet subit l\'action.', parens: 'not.vox'),
  _n('not.vox.dep', 'Dēpōnēns', 'Forme passive, sens actif.', parens: 'not.vox', fontes: ['$_ag §190']),

  // ----- degrés -----
  _n('not.gradus.pos', 'Positīvus', 'Le degré de base.', parens: 'not.gradus'),
  _n('not.gradus.comp', 'Comparātīvus', 'Plus … que ; assez, trop.', parens: 'not.gradus', fontes: ['$_ag §124, §291']),
  _n('not.gradus.sup', 'Superlātīvus', 'Le plus … ; très.', parens: 'not.gradus', fontes: ['$_ag §124, §291']),

  // ----- déclinaisons et conjugaisons -----
  _n('not.declinatio.1', 'Dēclīnātiō prīma', 'Thèmes en -ā.', parens: 'not.declinatio', fontes: ['$_ag §40']),
  _n('not.declinatio.2', 'Dēclīnātiō secunda', 'Thèmes en -o.', parens: 'not.declinatio', fontes: ['$_ag §45']),
  _n('not.declinatio.3', 'Dēclīnātiō tertia', 'Thèmes consonantiques et en -i.', parens: 'not.declinatio', fontes: ['$_ag §56']),
  _n('not.declinatio.4', 'Dēclīnātiō quārta', 'Thèmes en -u.', parens: 'not.declinatio', fontes: ['$_ag §89']),
  _n('not.declinatio.5', 'Dēclīnātiō quīnta', 'Thèmes en -ē.', parens: 'not.declinatio', fontes: ['$_ag §96']),
  _n('not.coniugatio.1', 'Coniugātiō prīma', 'Thème du présent en -ā : amāre.', parens: 'not.coniugatio', fontes: ['$_ag §171']),
  _n('not.coniugatio.2', 'Coniugātiō secunda', 'Thème du présent en -ē : monēre.', parens: 'not.coniugatio', fontes: ['$_ag §171']),
  _n('not.coniugatio.3', 'Coniugātiō tertia', 'Thème consonantique ou en -u : regere.', parens: 'not.coniugatio', fontes: ['$_ag §171']),
  _n('not.coniugatio.3io', 'Coniugātiō tertia in -iō', 'Thème en -i bref : capere, capiō.', parens: 'not.coniugatio', fontes: ['$_ag §176']),
  _n('not.coniugatio.4', 'Coniugātiō quārta', 'Thème du présent en -ī : audīre.', parens: 'not.coniugatio', fontes: ['$_ag §171']),
  _n('not.coniugatio.anom', 'Verba anōmala', 'sum, possum, eō, ferō, volō, nōlō, mālō, fīō, dō, edō.', parens: 'not.coniugatio', fontes: ['$_ag §170, §197–204']),
  _n('not.classis.12', 'Adiectīva prīmae et secundae', 'bonus, -a, -um.', parens: 'not.classis', fontes: ['$_ag §110']),
  _n('not.classis.3', 'Adiectīva tertiae', 'fortis, -e ; ācer ; fēlīx.', parens: 'not.classis', fontes: ['$_ag §114']),

  // ----- formes nominales du verbe -----
  _n('not.forma.inf', 'Īnfīnītīvus', 'amāre, amāvisse, amātūrum esse.', parens: 'not.forma', fontes: ['$_ag §155']),
  _n('not.forma.part', 'Participium', 'amāns, amātus, amātūrus.', parens: 'not.forma', fontes: ['$_ag §155, §488']),
  _n('not.forma.ger', 'Gerundium', 'amandī, amandō, amandum.', parens: 'not.forma', fontes: ['$_ag §155, §501']),
  _n('not.forma.gdv', 'Gerundīvum', 'amandus, -a, -um.', parens: 'not.forma', fontes: ['$_ag §155, §500']),
  _n('not.forma.sup', 'Supīnum', 'amātum, amātū.', parens: 'not.forma', fontes: ['$_ag §155, §509']),
];
