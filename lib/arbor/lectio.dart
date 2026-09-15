/// L5 — Lēctiō : opérations de lecture et de traduction, prosodie, écriture.
///
/// Ces nœuds ne sont ni des formes ni des constructions : ce sont les gestes
/// du lecteur (trouver le verbe, délimiter, résoudre une anaphore, ordonner en
/// français). Un distracteur du Theatrum peut échouer sur l'un d'eux alors que
/// chaque mot est connu.
library;

import 'skill.dart';

const _ag = 'A&G';

Skill _l(
  String id,
  String nomen,
  String quid, {
  List<String> req = const [],
  List<Confusio> conf = const [],
  List<Dimensio> prob = const [Dimensio.sensus],
  List<String> ag = const [],
  String? parens,
}) => Skill(
  id,
  nomen: nomen,
  quid: quid,
  stratum: Stratum.lectio,
  requirit: req,
  confunditur: conf,
  probatur: prob,
  fontes: [for (final s in ag) '$_ag $s'],
  parens: parens,
);

Confusio _c(String cum, Modus m, [String nota = '']) => Confusio(cum, m, nota: nota);

final List<Skill> kLectioGroups = [
  _l('lect', 'Lēctiō', 'Lire et traduire.', prob: []),
  _l('lect.via', 'Via legendī', 'La démarche de lecture d\'une phrase.', parens: 'lect', prob: []),
  _l('lect.versio', 'Versiō', 'Rendre en français.', parens: 'lect', prob: []),
  _l('lect.scriptura', 'Scrīptūra et prosōdia', 'Lettres, quantités, accent, élision.', parens: 'lect', prob: []),
  _l('lect.vocabula', 'Vocābula', 'Apprendre et reconnaître le vocabulaire.', parens: 'lect', prob: []),
];

final List<Skill> kLectio = [
  // ----- démarche -----
  _l('lect.via.verbum', 'Verbum invenīre', 'Repérer d\'abord le verbe conjugué, lire sa personne et son nombre : ils annoncent le sujet.', parens: 'lect.via', ag: ['§596'], req: ['syn.concordia.verbum']),
  _l('lect.via.subiectum', 'Subiectum quaerere', 'Chercher un nominatif accordé au verbe ; sinon, le sujet est dans la désinence (venit = il vient).', parens: 'lect.via', ag: ['§271', '§318'], req: ['lect.via.verbum', 'syn.nom.subiectum'],
      conf: [_c('syn.ordo.verbum.finale', Modus.functio, 'le premier nom n\'est pas toujours le sujet')]),
  _l('lect.via.obiectum', 'Obiectum quaerere', 'Chercher l\'objet à l\'accusatif si le verbe est transitif ; vérifier que le verbe n\'est pas passif ni déponent.', parens: 'lect.via', ag: ['§387'], req: ['lect.via.subiectum', 'syn.acc.obiectum', 'syn.regimen.deponentia']),
  _l('lect.via.dividere', 'Sententiam dīvidere', 'Délimiter les propositions aux conjonctions, aux relatifs et aux verbes ; une proposition par verbe conjugué.', parens: 'lect.via', ag: ['§278–279'], req: ['lect.via.verbum'],
      conf: [_c('syn.rel.connexum', Modus.functio, 'un relatif en tête n\'ouvre pas une relative enchâssée')]),
  _l('lect.via.coniungere', 'Verba inter sē coniungere', 'Rattacher chaque mot à celui qu\'il complète par l\'accord (adjectif, participe) ou par le cas (complément).', parens: 'lect.via', ag: ['§286'], req: ['syn.concordia.adiectivum', 'syn.concordia.distans', 'lect.via.dividere']),
  _l('lect.via.ambiguitas', 'Ambiguitātem solvere', 'Trancher une forme ambiguë (rosae, servī, amāre) par l\'accord et par le sens de la phrase, jamais par la forme seule.', parens: 'lect.via', ag: ['§35'], req: ['n.des.ae', 'n.des.i_long', 'lect.via.coniungere'],
      conf: [_c('n.des.ae', Modus.syncretismus, 'rosae : gén., dat. ou nom. pl.')]),
  _l('lect.via.anaphora', 'Anaphoram solvere', 'Retrouver le référent d\'un pronom (is, hic, ille, quī, sē) dans la phrase précédente par le genre et le nombre.', parens: 'lect.via', ag: ['§297', '§305'], req: ['syn.pron.is.anaphora', 'syn.pron.reflexivum', 'syn.concordia.relativum'], prob: [Dimensio.sensus, Dimensio.relatio]),
  _l('lect.via.ellipsis', 'Ellipsim supplēre', 'Rétablir le mot omis : sum (dīcendum [est]), le verbe de la principale, le sujet repris de la phrase précédente.', parens: 'lect.via', ag: ['§319', '§598 f'], req: ['lect.via.subiectum']),
  _l('lect.via.negatio', 'Negātiōnis vim vidēre', 'Repérer sur quoi porte la négation et ne pas cumuler deux négations comme en français.', parens: 'lect.via', ag: ['§325–326'], req: ['syn.neg.non', 'syn.neg.duplex']),
  _l('lect.via.tempus', 'Tempora inter sē referre', 'Lire les temps relatifs : infinitif et subjonctif par rapport au verbe principal, plus-que-parfait comme antériorité.', parens: 'lect.via', ag: ['§482–485', '§584'], req: ['syn.sub.consecutio', 'syn.inf.aci.tempus.perf', 'syn.tempora.plusq']),

  // ----- rendre en français -----
  _l('lect.versio.ordo', 'Ōrdinem Gallicum restituere', 'Réordonner en sujet – verbe – complément et placer les subordonnées à la française.', parens: 'lect.versio', ag: ['§596'], req: ['lect.via.coniungere'], prob: [Dimensio.sensus, Dimensio.productio]),
  _l('lect.versio.casus', 'Cāsūs Gallicē reddere', 'Rendre chaque cas par la préposition ou la place française qui convient (de, à, par, avec, dans…) selon sa fonction, non selon son nom.', parens: 'lect.versio', ag: ['§338 sqq.'], req: ['syn.gen.possessivus', 'syn.dat.attributio', 'syn.abl.instrumentum'],
      conf: [_c('syn.abl.instrumentum', Modus.functio, 'ablatif ≠ toujours « avec »'), _c('syn.dat.attributio', Modus.functio, 'datif ≠ toujours « à »')]),
  _l('lect.versio.tempora', 'Tempora Gallicē reddere', 'Choisir imparfait / passé composé / passé simple, plus-que-parfait, futur antérieur, conditionnel pour rendre les temps et modes latins.', parens: 'lect.versio', ag: ['§464–485'], req: ['syn.tempora.imperf_perf', 'syn.cond.irrealis.praes']),
  _l('lect.versio.participia', 'Participia Gallicē reddere', 'Rendre le participe conjoint et l\'ablatif absolu par un gérondif, une subordonnée (quand, comme, bien que) ou un nom.', parens: 'lect.versio', ag: ['§496', '§420'], req: ['syn.part.coniunctum', 'syn.abl.absolutus']),
  _l('lect.versio.infinitivae', 'Īnfīnītīvās Gallicē reddere', 'Rendre l\'infinitive par « que + proposition » avec le bon temps relatif.', parens: 'lect.versio', ag: ['§580–584'], req: ['syn.inf.aci', 'lect.via.tempus']),
  _l('lect.versio.deponentia', 'Dēpōnentia Gallicē reddere', 'Rendre un déponent à l\'actif et un passif impersonnel par « on ».', parens: 'lect.versio', ag: ['§190', '§208 d'], req: ['syn.regimen.deponentia', 'syn.impers.passivum']),
  _l('lect.versio.pronomina', 'Prōnōmina Gallicē reddere', 'Rendre is/ille/hic par « il, celui-ci, celui-là, ce », sē/suus par le réfléchi ou le possesseur adéquat.', parens: 'lect.versio', ag: ['§297–301'], req: ['lect.via.anaphora']),
  _l('lect.versio.numeri', 'Numerōs Gallicē reddere', 'Rendre cardinaux, ordinaux, distributifs et adverbes numéraux par la tournure française juste (deux, deuxième, deux chacun, deux fois).', parens: 'lect.versio', ag: ['§133–138'], req: ['syn.numeri.card', 'syn.numeri.ord', 'syn.numeri.distr', 'syn.numeri.adv']),
  _l('lect.versio.fidelitas', 'Fidēlitās', 'Ne rien ajouter ni retrancher : ni sujet inventé, ni nuance absente, ni contresens sur la voix ou le temps.', parens: 'lect.versio', ag: [], req: ['lect.versio.ordo', 'lect.versio.tempora'], prob: [Dimensio.sensus, Dimensio.productio]),

  // ----- production -----
  _l('lect.versio.latine.casus', 'Cāsum Latīnē ēligere', 'Choisir le cas d\'un nom d\'après sa fonction dans la phrase française à rendre.', parens: 'lect.versio', ag: ['§338 sqq.'], req: ['syn.acc.obiectum', 'syn.dat.attributio', 'syn.abl.instrumentum'], prob: [Dimensio.productio]),
  _l('lect.versio.latine.tempus', 'Tempus et modum Latīnē ēligere', 'Choisir temps et mode latins d\'après le sens français et la concordance.', parens: 'lect.versio', ag: ['§464–485'], req: ['syn.sub.consecutio', 'syn.tempora.imperf_perf'], prob: [Dimensio.productio]),
  _l('lect.versio.latine.constructio', 'Cōnstrūctiōnem Latīnē ēligere', 'Choisir la construction latine qui rend la subordonnée française (infinitive, ut + subj., cum, ablatif absolu…).', parens: 'lect.versio', ag: ['§560 sqq.'], req: ['syn.inf.aci', 'syn.sub.ut.completiva', 'syn.abl.absolutus'], prob: [Dimensio.productio]),

  // ----- écriture, prosodie -----
  _l('lect.scriptura.macra', 'Macra legere', 'Lire les macrons comme des quantités qui changent le mot (rosa / rosā, venit / vēnit, amāveris / amāverīs).', parens: 'lect.scriptura', ag: ['§10'], req: ['n.alt.quantitas', 'v.alt.quantitas'], prob: [Dimensio.sensus, Dimensio.casus, Dimensio.tempus]),
  _l('lect.scriptura.iu', 'I/J, U/V', 'Lire i et u comme voyelles ou consonnes selon la position (iam, uīuō = vīvō) ; graphies iūlius / Julius.', parens: 'lect.scriptura', ag: ['§1 a', '§5']),
  _l('lect.scriptura.accentus', 'Accentus', 'Placer l\'accent : sur la pénultième si elle est longue, sinon sur l\'antépénultième (amā́re, ámat, régere).', parens: 'lect.scriptura', ag: ['§12'], req: ['lect.scriptura.macra']),
  _l('lect.scriptura.syllabae', 'Syllabās dīvidere', 'Couper en syllabes et reconnaître la syllabe longue par nature ou par position.', parens: 'lect.scriptura', ag: ['§11', '§14'], req: ['lect.scriptura.macra']),
  _l('lect.scriptura.elisio', 'Ēlīsiō', 'Reconnaître l\'élision d\'une voyelle finale (ou -m) devant voyelle en poésie (mult(um) ille).', parens: 'lect.scriptura', ag: ['§612'], req: ['lect.scriptura.syllabae']),
  _l('lect.scriptura.abbreviationes', 'Abbreviātiōnēs', 'Lire les abréviations usuelles (M. = Mārcus, cos. = cōnsul, S.P.Q.R.) et les chiffres romains.', parens: 'lect.scriptura', ag: ['§108 c', '§133']),

  // ----- vocabulaire -----
  _l('lect.vocabula.lemma', 'Lemma invenīre', 'Retrouver l\'entrée de dictionnaire depuis une forme fléchie (rēgibus → rēx, rēgis ; tulit → ferō).', parens: 'lect.vocabula', ag: ['§55', '§177'], req: ['n.alt.nom3', 'v.thema.perf'], prob: [Dimensio.lemma, Dimensio.vocabulum]),
  _l('lect.vocabula.sensus', 'Sēnsum ē contextū ēligere', 'Choisir le sens d\'un mot polysémique d\'après le contexte (petere : demander, chercher, attaquer).', parens: 'lect.vocabula', ag: [], req: ['lect.vocabula.lemma'], prob: [Dimensio.vocabulum, Dimensio.sensus]),
  _l('lect.vocabula.familia', 'Familiam verbōrum agnōscere', 'Reconnaître un mot par sa famille : préverbe + simple (ab-eō, re-ferō), suffixe (-tor, -tiō, -tās, -ōsus).', parens: 'lect.vocabula', ag: ['§227–267'], req: ['v.kind.comp', 'lect.vocabula.lemma'], prob: [Dimensio.vocabulum, Dimensio.lemma]),
  _l('lect.vocabula.praeverbia', 'Praeverbia', 'Connaître le sens des préverbes : ab-, ad-, con-, dē-, ex-, in-, per-, prō-, re-, sub-, trāns-, et leurs assimilations (ad-ferō → afferō).', parens: 'lect.vocabula', ag: ['§267'], req: ['lect.vocabula.familia']),
  _l('lect.vocabula.suffixa', 'Suffixa', 'Connaître les suffixes : -tor/-trīx (agent), -tiō (action), -tās/-tūdō (qualité), -ōsus/-idus (adjectifs), -ulus (diminutif), -ārium.', parens: 'lect.vocabula', ag: ['§234–254'], req: ['lect.vocabula.familia']),
  _l('lect.vocabula.falsi_amici', 'Falsī amīcī', 'Se méfier des faux amis (līber / liber, virtūs, familia, hostis / hospes).', parens: 'lect.vocabula', ag: [], req: ['lect.vocabula.sensus'], prob: [Dimensio.vocabulum],
      conf: [_c('lect.vocabula.sensus', Modus.sensus, 'le sens français attendu n\'est pas le sens latin')]),
  _l('lect.vocabula.gallice', 'Latīnē → Gallicē', 'Donner le sens français d\'un lemme latin.', parens: 'lect.vocabula', ag: [], req: ['lect.vocabula.lemma'], prob: [Dimensio.vocabulum]),
  _l('lect.vocabula.latine', 'Gallicē → Latīnē', 'Donner le lemme latin d\'un mot français, avec ses parties principales.', parens: 'lect.vocabula', ag: [], req: ['lect.vocabula.gallice'], prob: [Dimensio.vocabulum]),
];
