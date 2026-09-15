/// L3 — Syntaxis : fonctions des cas, accord, ordre, propositions,
/// constructions. Un nœud = une lecture que l'on peut faire échouer seule dans
/// une phrase : c'est le niveau où travaillent le Theatrum et le Templum, et
/// les syntagmes contextuels du Forum.
///
/// Les confusions de type `functio` relient deux emplois voisins d'un même cas
/// ou deux constructions que le lecteur intervertit : ce sont les distracteurs
/// des cadres authored.
library;

import 'skill.dart';

const _ag = 'A&G';

Skill _s(
  String id,
  String nomen,
  String quid, {
  List<String> not = const [],
  List<String> pars = const [],
  List<String> req = const [],
  List<Confusio> conf = const [],
  List<Dimensio> prob = const [Dimensio.sensus, Dimensio.productio, Dimensio.functio],
  List<String> ag = const [],
  String? parens,
}) => Skill(
  id,
  nomen: nomen,
  quid: quid,
  stratum: Stratum.syntaxis,
  notiones: not,
  pars: pars,
  requirit: req,
  confunditur: conf,
  probatur: prob,
  fontes: [for (final s in ag) '$_ag $s'],
  parens: parens,
);

Confusio _c(String cum, Modus m, [String nota = '']) => Confusio(cum, m, nota: nota);

final List<Skill> kSyntaxisGroups = [
  _s('syn', 'Syntaxis', 'La syntaxe : fonctions, accord, propositions.', prob: []),
  _s('syn.nom', 'Nōminātīvus in sententiā', 'Les emplois du nominatif.', parens: 'syn', prob: []),
  _s('syn.voc', 'Vocātīvus in sententiā', 'L\'interpellation.', parens: 'syn', prob: []),
  _s('syn.acc', 'Accūsātīvus in sententiā', 'Les emplois de l\'accusatif.', parens: 'syn', prob: []),
  _s('syn.gen', 'Genetīvus in sententiā', 'Les emplois du génitif.', parens: 'syn', prob: []),
  _s('syn.dat', 'Datīvus in sententiā', 'Les emplois du datif.', parens: 'syn', prob: []),
  _s('syn.abl', 'Ablātīvus in sententiā', 'Les emplois de l\'ablatif.', parens: 'syn', prob: []),
  _s('syn.locus', 'Locus et tempus', 'Où, d\'où, vers où, quand, combien de temps.', parens: 'syn', prob: []),
  _s('syn.praep', 'Praepositiōnēs', 'Les prépositions et leur cas.', parens: 'syn', prob: []),
  _s('syn.concordia', 'Cōnsēnsus', 'L\'accord.', parens: 'syn', prob: []),
  _s('syn.ordo', 'Ōrdō verbōrum', 'L\'ordre des mots et les particules.', parens: 'syn', prob: []),
  _s('syn.interrog', 'Interrogātiō', 'Poser une question.', parens: 'syn', prob: []),
  _s('syn.neg', 'Negātiō', 'Nier.', parens: 'syn', prob: []),
  _s('syn.voluntas', 'Voluntās et imperium', 'Ordonner, exhorter, souhaiter, délibérer, interdire.', parens: 'syn', prob: []),
  _s('syn.tempora', 'Tempora in nārrātiōne', 'La valeur des temps dans le récit.', parens: 'syn', prob: []),
  _s('syn.inf', 'Īnfīnītīvus in sententiā', 'Infinitives et discours indirect.', parens: 'syn', prob: []),
  _s('syn.part', 'Participia in sententiā', 'Participe conjoint, ablatif absolu, adjectif verbal, gérondif, supin.', parens: 'syn', prob: []),
  _s('syn.sub', 'Sententiae subordinātae', 'Les subordonnées et leurs modes.', parens: 'syn', prob: []),
  _s('syn.rel', 'Sententia relātīva', 'Les relatives.', parens: 'syn', prob: []),
  _s('syn.cond', 'Condiciōnēs', 'Les périodes conditionnelles.', parens: 'syn', prob: []),
  _s('syn.comp', 'Comparātiō in sententiā', 'Comparer.', parens: 'syn', prob: []),
  _s('syn.obl', 'Ōrātiō oblīqua', 'Rapporter des paroles.', parens: 'syn', prob: []),
  _s('syn.impers', 'Cōnstrūctiōnēs impersōnālēs', 'Les impersonnels et le passif impersonnel.', parens: 'syn', prob: []),
  _s('syn.regimen', 'Rēgimen verbōrum', 'Le cas que chaque verbe demande.', parens: 'syn', prob: []),
  _s('syn.pron', 'Prōnōmina in sententiā', 'Ce à quoi renvoie un pronom.', parens: 'syn', prob: []),
  _s('syn.numeri', 'Numerī in sententiā', 'Compter, ordonner, répartir, répéter.', parens: 'syn', prob: []),
];

final List<Skill> kSyntaxis = [
  // =====================================================================
  // Nominatif, vocatif
  // =====================================================================
  _s('syn.nom.subiectum', 'Subiectum', 'Reconnaître le sujet au nominatif et l\'accorder au verbe (puella cantat).', not: ['not.casus.nom'], parens: 'syn.nom', ag: ['§339'], req: ['n.des.a', 'v.des.act.3.sg.t'],
      conf: [_c('syn.acc.obiectum', Modus.functio, 'māter / mātrem : qui fait, qui subit'), _c('syn.nom.praedicativum', Modus.functio, 'Mārcus cōnsul est : deux nominatifs')]),
  _s('syn.nom.praedicativum', 'Nōminātīvus praedicātīvus', 'Reconnaître l\'attribut du sujet au nominatif avec sum, fīō, videor, appellor (Mārcus cōnsul est).', not: ['not.casus.nom'], parens: 'syn.nom', ag: ['§283–284'], req: ['syn.nom.subiectum'],
      conf: [_c('syn.nom.subiectum', Modus.functio, 'lequel des deux nominatifs est le sujet')]),
  _s('syn.nom.nci', 'Nōminātīvus cum īnfīnītīvō', 'Reconnaître le sujet au nominatif d\'un verbe passif de déclaration + infinitif (Mārcus dīcitur venīre : on dit que Marcus vient).', not: ['not.casus.nom', 'not.modus.inf'], parens: 'syn.nom', ag: ['§582'], req: ['syn.inf.aci', 'syn.nom.subiectum'],
      conf: [_c('syn.inf.aci', Modus.functio, 'dīcitur Mārcus venīre / dīcunt Mārcum venīre'), _c('syn.impers.passivum', Modus.functio, 'dīcitur personnel / trāditur impersonnel')]),
  _s('syn.voc.appellatio', 'Vocātīvus', 'Reconnaître l\'interpellation, avec ou sans ō (ō amīce ! Mārce !), et sa place hors de la phrase.', not: ['not.casus.voc'], parens: 'syn.voc', ag: ['§340'], req: ['n.des.e'],
      conf: [_c('syn.nom.subiectum', Modus.functio, 'Mārce (interpellé) / Mārcus (sujet)')]),

  // =====================================================================
  // Accusatif
  // =====================================================================
  _s('syn.acc.obiectum', 'Obiectum dīrēctum', 'Reconnaître l\'objet direct à l\'accusatif (puer librum legit).', not: ['not.casus.acc'], parens: 'syn.acc', ag: ['§387'], req: ['n.des.um', 'n.des.am'],
      conf: [_c('syn.nom.subiectum', Modus.functio, 'mātrem / māter'), _c('syn.acc.directio', Modus.functio, 'urbem videt / in urbem it'), _c('syn.dat.attributio', Modus.functio, 'puerum vocat / puerō dat')]),
  _s('syn.acc.directio', 'Accūsātīvus dīrēctiōnis (quō?)', 'Reconnaître la direction : in/ad + acc., noms de villes sans préposition (Rōmam it).', not: ['not.casus.acc'], parens: 'syn.acc', ag: ['§426', '§427'], req: ['syn.praep.in.duplex'],
      conf: [_c('syn.abl.locus', Modus.functio, 'in urbem (quō) / in urbe (ubi)'), _c('syn.abl.separatio', Modus.functio, 'Rōmam / Rōmā'), _c('syn.acc.obiectum', Modus.functio, 'Rōmam it / Rōmam videt')]),
  _s('syn.acc.spatium', 'Accūsātīvus spatiī', 'Reconnaître l\'étendue dans l\'espace (trēs mīlia passuum ambulat ; fossa decem pedēs lāta).', not: ['not.casus.acc'], parens: 'syn.acc', ag: ['§425'], req: ['syn.acc.obiectum'],
      conf: [_c('syn.acc.tempus', Modus.functio, 'trēs mīlia passuum / trēs hōrās'), _c('syn.abl.mensura', Modus.functio, 'decem pedēs lāta / decem pedibus lātior')]),
  _s('syn.acc.tempus', 'Accūsātīvus temporis (quam diū?)', 'Reconnaître la durée à l\'accusatif (trēs hōrās manet ; sex mēnsēs).', not: ['not.casus.acc'], parens: 'syn.acc', ag: ['§423'], req: ['syn.acc.obiectum'],
      conf: [_c('syn.abl.tempus', Modus.functio, 'trēs hōrās (pendant) / tertiā hōrā (à)'), _c('syn.numeri.ord', Modus.functio, 'sex mēnsēs / sextō mēnse')]),
  _s('syn.acc.duplex', 'Duplex accūsātīvus', 'Reconnaître les deux accusatifs de doceō, rogō, cēlō (persōna et rēs : puerōs grammaticam docet) et des verbes d\'appellation (Cicerōnem cōnsulem creant).', not: ['not.casus.acc'], parens: 'syn.acc', ag: ['§391–393'], req: ['syn.acc.obiectum'],
      conf: [_c('syn.dat.attributio', Modus.functio, 'puerōs docet, non *puerīs'), _c('syn.acc.obiectum', Modus.functio, 'lequel est la personne, lequel la chose')]),
  _s('syn.acc.exclamatio', 'Accūsātīvus exclāmātiōnis', 'Reconnaître l\'exclamation à l\'accusatif (mē miserum ! ō tempora !).', not: ['not.casus.acc'], parens: 'syn.acc', ag: ['§397 d'], req: ['syn.acc.obiectum'],
      conf: [_c('syn.voc.appellatio', Modus.functio, 'mē miserum / ō amīce')]),
  _s('syn.acc.adverbialis', 'Accūsātīvus adverbiālis', 'Reconnaître les neutres adverbiaux (multum, nihil, prīmum, cētera) et id temporis.', not: ['not.casus.acc'], parens: 'syn.acc', ag: ['§397 a'], req: ['adj.adv.o'],
      conf: [_c('syn.acc.obiectum', Modus.functio, 'multum ambulat / multum vīnum bibit')]),
  _s('syn.acc.praep', 'Praepositiōnēs cum accūsātīvō', 'Connaître ad, ante, apud, circum, contrā, inter, ob, per, post, prope, propter, trāns et leur sens.', not: ['not.casus.acc'], parens: 'syn.acc', ag: ['§220'],
      conf: [_c('syn.abl.praep', Modus.functio, 'ad urbem / ab urbe'), _c('syn.praep.in.duplex', Modus.functio, 'in + acc. / in + abl.')]),

  // =====================================================================
  // Génitif
  // =====================================================================
  _s('syn.gen.possessivus', 'Genetīvus possessīvus', 'Reconnaître le possesseur au génitif (liber puerī ; est patris = appartient au père).', not: ['not.casus.gen'], parens: 'syn.gen', ag: ['§343'], req: ['n.des.ae', 'n.des.i_long', 'n.des.is'],
      conf: [_c('syn.dat.possessoris', Modus.functio, 'liber puerī / puerō est liber'), _c('syn.gen.obiectivus', Modus.functio, 'amor patris : du père ou pour le père'), _c('syn.dat.attributio', Modus.functio, 'puerī (de) / puerō (à)')]),
  _s('syn.gen.partitivus', 'Genetīvus partītīvus', 'Reconnaître le tout au génitif après une partie (ūnus multōrum, pars mīlitum, nihil novī, quid cōnsiliī, plūs pecūniae).', not: ['not.casus.gen'], parens: 'syn.gen', ag: ['§346'], req: ['syn.gen.possessivus'],
      conf: [_c('syn.gen.possessivus', Modus.functio, 'ūnus nautārum (un des) / nāvis nautārum (des marins)'), _c('syn.abl.praep', Modus.functio, 'ūnus ē nautīs / ūnus nautārum'), _c('syn.gen.quantitatis', Modus.functio, 'tria mīlia mīlitum')]),
  _s('syn.gen.qualitatis', 'Genetīvus quālitātis', 'Reconnaître la qualité au génitif, toujours avec un adjectif (vir magnī animī ; puer decem annōrum).', not: ['not.casus.gen'], parens: 'syn.gen', ag: ['§345'], req: ['syn.gen.possessivus', 'syn.concordia.adiectivum'],
      conf: [_c('syn.abl.qualitatis', Modus.functio, 'magnī animī / magnō animō'), _c('syn.gen.possessivus', Modus.functio, 'vir magnī animī / animus virī')]),
  _s('syn.gen.obiectivus', 'Genetīvus obiectīvus et subiectīvus', 'Distinguer amor patris (le père aime : subjectif) et metus hostium (on craint les ennemis : objectif).', not: ['not.casus.gen'], parens: 'syn.gen', ag: ['§347–348'], req: ['syn.gen.possessivus'],
      conf: [_c('syn.gen.possessivus', Modus.functio, 'timor hostium : des ennemis ou envers les ennemis')]),
  _s('syn.gen.pretii', 'Genetīvus pretiī', 'Reconnaître l\'estimation au génitif avec les adjectifs magnī, parvī, plūris, tantī, nihilī (magnī aestimat).', not: ['not.casus.gen'], parens: 'syn.gen', ag: ['§417'], req: ['syn.gen.possessivus'],
      conf: [_c('syn.abl.pretii', Modus.functio, 'magnī aestimat / magnō pretiō ēmit')]),
  _s('syn.gen.memoriae', 'Genetīvus cum verbīs memoriae et adiectīvīs', 'Reconnaître le génitif après meminī, oblīvīscor, potior et après plēnus, cupidus, perītus, similis.', not: ['not.casus.gen'], parens: 'syn.gen', ag: ['§349–350'], req: ['syn.gen.possessivus'],
      conf: [_c('syn.acc.obiectum', Modus.functio, 'meminī patris / meminī patrem (les deux existent : nuance)'), _c('syn.abl.instrumentum', Modus.functio, 'plēnus vīnī / plēnus vīnō')]),
  _s('syn.gen.criminis', 'Genetīvus crīminis', 'Reconnaître le chef d\'accusation au génitif (accūsāre fūrtī, damnāre capitis).', not: ['not.casus.gen'], parens: 'syn.gen', ag: ['§352'], req: ['syn.gen.possessivus']),
  _s('syn.gen.quantitatis', 'Genetīvus post mīlia', 'Savoir que mīlia est suivi du génitif (tria mīlia mīlitum) mais mīlle non (mīlle mīlitēs).', not: ['not.casus.gen'], parens: 'syn.gen', ag: ['§134 d'], req: ['num.mille', 'syn.gen.partitivus'],
      conf: [_c('syn.concordia.adiectivum', Modus.functio, 'mīlle mīlitēs (accord) / mīlia mīlitum (génitif)')]),

  // =====================================================================
  // Datif
  // =====================================================================
  _s('syn.dat.attributio', 'Datīvus attribūtiōnis (cui?)', 'Reconnaître le destinataire au datif (puerō librum dat ; mātrī dīcit).', not: ['not.casus.dat'], parens: 'syn.dat', ag: ['§361–362'], req: ['n.des.o_long', 'n.des.i_long', 'n.des.ae'],
      conf: [_c('syn.acc.obiectum', Modus.functio, 'puerō dat / puerum vocat'), _c('syn.gen.possessivus', Modus.functio, 'puerō / puerī'), _c('syn.abl.instrumentum', Modus.functio, 'puerō (dat.) / puerō (abl.) : le verbe décide')]),
  _s('syn.dat.possessoris', 'Datīvus possessōris', 'Reconnaître la possession au datif avec sum (est mihi liber = j\'ai un livre).', not: ['not.casus.dat'], parens: 'syn.dat', ag: ['§373'], req: ['syn.dat.attributio'],
      conf: [_c('syn.gen.possessivus', Modus.functio, 'puerō est liber / liber puerī'), _c('syn.dat.attributio', Modus.functio, 'mihi est / mihi dat')]),
  _s('syn.dat.finalis', 'Datīvus fīnālis', 'Reconnaître le but au datif (auxiliō venit ; locum castrīs dēligit ; dōnō dat).', not: ['not.casus.dat'], parens: 'syn.dat', ag: ['§382'], req: ['syn.dat.attributio'],
      conf: [_c('syn.abl.instrumentum', Modus.functio, 'auxiliō venit (pour aider) / auxiliō vincit (grâce à l\'aide)'), _c('syn.dat.duplex', Modus.functio, 'auxiliō / auxiliō alicui')]),
  _s('syn.dat.duplex', 'Duplex datīvus', 'Reconnaître les deux datifs, but + personne (auxiliō Caesarī venit ; hoc mihi cūrae est).', not: ['not.casus.dat'], parens: 'syn.dat', ag: ['§382'], req: ['syn.dat.finalis', 'syn.dat.attributio'],
      conf: [_c('syn.dat.finalis', Modus.functio, 'lequel des deux datifs est le but')]),
  _s('syn.dat.commodi', 'Datīvus commodī et incommodī', 'Reconnaître l\'intéressé au datif (nōn sibi sed patriae labōrat).', not: ['not.casus.dat'], parens: 'syn.dat', ag: ['§376'], req: ['syn.dat.attributio'],
      conf: [_c('syn.dat.attributio', Modus.functio, 'patriae labōrat / patriae dat')]),
  _s('syn.dat.agentis', 'Datīvus agentis', 'Reconnaître l\'agent au datif avec l\'adjectif verbal (mihi legendum est : je dois lire).', not: ['not.casus.dat'], parens: 'syn.dat', ag: ['§374'], req: ['v.comp.peri.pass', 'syn.dat.attributio'],
      conf: [_c('syn.abl.agens', Modus.functio, 'mihi legendum est / ā mē legitur'), _c('syn.dat.possessoris', Modus.functio, 'mihi legendum est / mihi est liber')]),
  _s('syn.dat.verba', 'Verba cum datīvō', 'Connaître les verbes intransitifs à datif : pāreō, placeō, noceō, crēdō, imperō, faveō, studeō, persuādeō, ignōscō, invideō.', not: ['not.casus.dat'], parens: 'syn.dat', ag: ['§367'], req: ['syn.dat.attributio'],
      conf: [_c('syn.acc.obiectum', Modus.functio, 'patrī pāret, non *patrem'), _c('syn.impers.passivum', Modus.functio, 'mihi persuādētur au passif')]),
  _s('syn.dat.composita', 'Datīvus cum verbīs compositīs', 'Reconnaître le datif après les composés de ad-, ante-, con-, in-, inter-, ob-, post-, prae-, sub- (praeesse exercituī).', not: ['not.casus.dat'], parens: 'syn.dat', ag: ['§370'], req: ['syn.dat.verba', 'v.kind.comp']),
  _s('syn.dat.adiectiva', 'Datīvus cum adiectīvīs', 'Reconnaître le datif après similis, ūtilis, grātus, cārus, proximus, pār, aptus.', not: ['not.casus.dat'], parens: 'syn.dat', ag: ['§384'], req: ['syn.dat.attributio'],
      conf: [_c('syn.gen.memoriae', Modus.functio, 'similis patrī / similis patris')]),

  // =====================================================================
  // Ablatif
  // =====================================================================
  _s('syn.abl.separatio', 'Ablātīvus sēparātiōnis (unde?)', 'Reconnaître l\'origine et la séparation : ā/ab, ē/ex, dē + abl. ; noms de villes sans préposition (Rōmā venit) ; verbes de séparation (carēre, līberāre).', not: ['not.casus.abl'], parens: 'syn.abl', ag: ['§400–402', '§427'], req: ['n.des.a_long', 'n.des.o_long', 'n.des.e'],
      conf: [_c('syn.acc.directio', Modus.functio, 'Rōmā / Rōmam'), _c('syn.abl.locus', Modus.functio, 'ex urbe / in urbe'), _c('syn.abl.agens', Modus.functio, 'ā Rōmā venit / ā Mārcō vidētur')]),
  _s('syn.abl.agens', 'Ablātīvus agentis', 'Reconnaître l\'agent d\'un passif : ā/ab + personne (rāmus ab agricolā secātur).', not: ['not.casus.abl', 'not.vox.pass'], parens: 'syn.abl', ag: ['§405'], req: ['v.des.pass.3.sg.tur', 'syn.abl.separatio'],
      conf: [_c('syn.abl.instrumentum', Modus.functio, 'ab agricolā (agent) / cultrō (instrument) : pas de ā/ab devant une chose'), _c('syn.nom.subiectum', Modus.functio, 'rāmus … secātur : rāmus est sujet, agricola agent'), _c('syn.abl.separatio', Modus.functio, 'ab agricolā (par) / ab urbe (depuis)')]),
  _s('syn.abl.instrumentum', 'Ablātīvus īnstrūmentī', 'Reconnaître l\'instrument à l\'ablatif sans préposition (cultrō secat ; oculīs videt).', not: ['not.casus.abl'], parens: 'syn.abl', ag: ['§409'], req: ['syn.abl.separatio'],
      conf: [_c('syn.abl.agens', Modus.functio, 'cultrō / ab agricolā'), _c('syn.abl.modi', Modus.functio, 'gladiō pugnat / (cum) virtūte pugnat'), _c('syn.abl.causae', Modus.functio, 'gladiō perit (par l\'épée) / famē perit (de faim)'), _c('syn.dat.attributio', Modus.functio, 'servō (avec) / servō (à)')]),
  _s('syn.abl.causae', 'Ablātīvus causae', 'Reconnaître la cause à l\'ablatif (famē perit ; timōre tremit ; amōre ardet).', not: ['not.casus.abl'], parens: 'syn.abl', ag: ['§404'], req: ['syn.abl.instrumentum'],
      conf: [_c('syn.abl.instrumentum', Modus.functio, 'famē perit / gladiō perit'), _c('syn.sub.causalis', Modus.functio, 'famē / quia famem patitur'), _c('syn.abl.modi', Modus.functio, 'timōre tremit / cum timōre loquitur')]),
  _s('syn.abl.modi', 'Ablātīvus modī', 'Reconnaître la manière : cum + abl. (cum cūrā), ou ablatif seul avec un adjectif (magnā cūrā, magnā cum cūrā).', not: ['not.casus.abl'], parens: 'syn.abl', ag: ['§412'], req: ['syn.abl.instrumentum'],
      conf: [_c('syn.abl.instrumentum', Modus.functio, 'magnā vōce / gladiō'), _c('syn.abl.comitatus', Modus.functio, 'cum cūrā (manière) / cum amīcō (accompagnement)'), _c('syn.abl.qualitatis', Modus.functio, 'magnā cūrā legit / vir magnā cūrā')]),
  _s('syn.abl.comitatus', 'Ablātīvus comitātūs', 'Reconnaître l\'accompagnement : cum + personne (cum mātre ambulat ; cum exercitū).', not: ['not.casus.abl'], parens: 'syn.abl', ag: ['§413'], req: ['syn.abl.separatio'],
      conf: [_c('syn.abl.modi', Modus.functio, 'cum mātre / cum cūrā'), _c('syn.abl.instrumentum', Modus.functio, 'cum mātre, non *mātre seul'), _c('syn.acc.praep', Modus.functio, 'cum mātre, non *cum mātrem')]),
  _s('syn.abl.qualitatis', 'Ablātīvus quālitātis', 'Reconnaître la qualité à l\'ablatif avec un adjectif (vir magnā virtūte ; puella capillīs longīs).', not: ['not.casus.abl'], parens: 'syn.abl', ag: ['§415'], req: ['syn.abl.modi', 'syn.concordia.adiectivum'],
      conf: [_c('syn.gen.qualitatis', Modus.functio, 'magnā virtūte / magnae virtūtis'), _c('syn.abl.modi', Modus.functio, 'vir magnā virtūte / magnā virtūte pugnat')]),
  _s('syn.abl.comparationis', 'Ablātīvus comparātiōnis', 'Reconnaître le second terme de la comparaison à l\'ablatif sans quam (Mārcō altior = altior quam Mārcus).', not: ['not.casus.abl', 'not.gradus.comp'], parens: 'syn.abl', ag: ['§406'], req: ['adj.gradus.comp.ior', 'syn.comp.quam'],
      conf: [_c('syn.comp.quam', Modus.functio, 'Mārcō altior / altior quam Mārcus'), _c('syn.abl.mensura', Modus.functio, 'Mārcō altior (que Marcus) / multō altior (de beaucoup)'), _c('syn.abl.agens', Modus.functio, 'servō senior : servō n\'est pas un agent')]),
  _s('syn.abl.mensura', 'Ablātīvus mēnsūrae', 'Reconnaître la mesure de la différence à l\'ablatif (multō maior ; tribus pedibus altior ; quō … eō).', not: ['not.casus.abl', 'not.gradus.comp'], parens: 'syn.abl', ag: ['§414'], req: ['syn.abl.comparationis'],
      conf: [_c('syn.abl.comparationis', Modus.functio, 'multō / Mārcō'), _c('syn.acc.spatium', Modus.functio, 'tribus pedibus altior / trēs pedēs altus')]),
  _s('syn.abl.tempus', 'Ablātīvus temporis (quandō?)', 'Reconnaître le moment à l\'ablatif sans préposition (hōrā sextā ; nocte ; eō diē ; hieme).', not: ['not.casus.abl'], parens: 'syn.abl', ag: ['§423'], req: ['syn.abl.separatio'],
      conf: [_c('syn.acc.tempus', Modus.functio, 'tertiā hōrā (à) / trēs hōrās (pendant)'), _c('syn.abl.locus', Modus.functio, 'nocte / in urbe'), _c('syn.abl.tempus.intra', Modus.functio, 'tribus diēbus : au bout de ou en l\'espace de')]),
  _s('syn.abl.tempus.intra', 'Ablātīvus temporis: intrā quod', 'Reconnaître l\'espace de temps dans lequel (tribus diēbus rediit : en trois jours).', not: ['not.casus.abl'], parens: 'syn.abl', ag: ['§424 b'], req: ['syn.abl.tempus'],
      conf: [_c('syn.acc.tempus', Modus.functio, 'tribus diēbus rediit / trēs diēs mānsit')]),
  _s('syn.abl.locus', 'Ablātīvus locī (ubi?)', 'Reconnaître le lieu où l\'on est : in/sub + abl. (in hortō est), et sans préposition avec locus, tōtus (tōtā urbe).', not: ['not.casus.abl'], parens: 'syn.abl', ag: ['§421', '§429'], req: ['syn.praep.in.duplex'],
      conf: [_c('syn.acc.directio', Modus.functio, 'in hortō / in hortum'), _c('syn.locus.locativus', Modus.functio, 'in urbe / Rōmae'), _c('syn.abl.separatio', Modus.functio, 'in hortō / ex hortō')]),
  _s('syn.abl.pretii', 'Ablātīvus pretiī', 'Reconnaître le prix à l\'ablatif (magnō pretiō ēmit ; decem sēstertiīs vēndit).', not: ['not.casus.abl'], parens: 'syn.abl', ag: ['§416'], req: ['syn.abl.instrumentum'],
      conf: [_c('syn.gen.pretii', Modus.functio, 'magnō ēmit / magnī aestimat')]),
  _s('syn.abl.deponentia', 'Ablātīvus cum ūtor, fruor, fungor, potior, vēscor', 'Reconnaître l\'ablatif complément de ūtor, fruor, fungor, potior, vēscor (gladiō ūtitur).', not: ['not.casus.abl'], parens: 'syn.abl', ag: ['§410'], req: ['v.kind.dep', 'syn.abl.instrumentum'],
      conf: [_c('syn.acc.obiectum', Modus.functio, 'gladiō ūtitur, non *gladium')]),
  _s('syn.abl.opus', 'Opus est cum ablātīvō', 'Reconnaître opus est + abl. de la chose et dat. de la personne (mihi gladiō opus est).', not: ['not.casus.abl'], parens: 'syn.abl', ag: ['§411'], req: ['syn.abl.deponentia', 'syn.dat.attributio']),
  _s('syn.abl.adiectiva', 'Ablātīvus cum dignus, contentus, frētus', 'Reconnaître l\'ablatif après dignus, indignus, contentus, frētus, praeditus.', not: ['not.casus.abl'], parens: 'syn.abl', ag: ['§418'], req: ['syn.abl.instrumentum'],
      conf: [_c('syn.gen.memoriae', Modus.functio, 'dignus laude / plēnus laudis')]),
  _s('syn.abl.praep', 'Praepositiōnēs cum ablātīvō', 'Connaître ā/ab, cum, dē, ē/ex, prō, sine, cōram, prae et leur sens.', not: ['not.casus.abl'], parens: 'syn.abl', ag: ['§221'],
      conf: [_c('syn.acc.praep', Modus.functio, 'ab urbe / ad urbem'), _c('syn.praep.in.duplex', Modus.functio, 'in + abl. / in + acc.')]),
  _s('syn.abl.absolutus', 'Ablātīvus absolūtus', 'Reconnaître le groupe nom + participe à l\'ablatif, détaché de la phrase (puerō cantante ; epistulā lēctā ; Cicerōne cōnsule).', not: ['not.casus.abl', 'not.forma.part'], parens: 'syn.abl', ag: ['§419–420'], req: ['v.nom.part.praes.nt', 'v.nom.part.perf.tus', 'syn.concordia.participium'],
      conf: [_c('syn.part.coniunctum', Modus.functio, 'puerō cantante (absolu) / puer cantāns (conjoint)'), _c('syn.abl.instrumentum', Modus.functio, 'epistulā lēctā : pas un instrument'), _c('syn.sub.temporalis', Modus.functio, 'epistulā lēctā = postquam epistula lēcta est')]),
  _s('syn.abl.absolutus.praes', 'Ablātīvus absolūtus cum participiō praesentī', 'Lire la simultanéité : puerō cantante (pendant que le garçon chante).', not: ['not.tempus.praes'], parens: 'syn.abl', ag: ['§419', '§489'], req: ['syn.abl.absolutus'],
      conf: [_c('syn.abl.absolutus.perf', Modus.functio, 'cantante (pendant) / cantātō (après)')]),
  _s('syn.abl.absolutus.perf', 'Ablātīvus absolūtus cum participiō perfectō', 'Lire l\'antériorité et le passif : epistulā lēctā (la lettre ayant été lue, après avoir lu la lettre).', not: ['not.tempus.perf', 'not.vox.pass'], parens: 'syn.abl', ag: ['§419', '§489'], req: ['syn.abl.absolutus'],
      conf: [_c('syn.abl.absolutus.praes', Modus.functio, 'lēctā / legente'), _c('v.kind.dep.part', Modus.functio, 'secūtō : actif malgré la forme')]),
  _s('syn.abl.absolutus.nominalis', 'Ablātīvus absolūtus sine participiō', 'Lire nom + nom/adjectif à l\'ablatif comme une circonstance (Cicerōne cōnsule ; mē invītō).', not: ['not.casus.abl'], parens: 'syn.abl', ag: ['§419 a'], req: ['syn.abl.absolutus'],
      conf: [_c('syn.abl.comitatus', Modus.functio, 'Cicerōne cōnsule (sous le consulat de) / cum Cicerōne')]),

  // =====================================================================
  // Lieu et temps ; prépositions
  // =====================================================================
  _s('syn.locus.locativus', 'Locātīvus: Rōmae, domī', 'Reconnaître le locatif des noms de villes et de domus, rūs, humus (Rōmae, Corinthī, Carthāgine, domī, rūrī).', not: ['not.casus.loc'], parens: 'syn.locus', ag: ['§427', '§428'], req: ['n.thema.proprium'],
      conf: [_c('syn.abl.locus', Modus.functio, 'Rōmae / in urbe'), _c('syn.gen.possessivus', Modus.functio, 'Rōmae (à Rome) / Rōmae (de Rome)'), _c('syn.acc.directio', Modus.functio, 'Rōmae / Rōmam')]),
  _s('syn.locus.triplex', 'Ubi, quō, unde', 'Choisir le cas et la préposition selon la question : ubi (in + abl., locatif), quō (in/ad + acc., acc. seul), unde (ā/ē + abl., abl. seul).', not: [], parens: 'syn.locus', ag: ['§426–428'], req: ['syn.abl.locus', 'syn.acc.directio', 'syn.abl.separatio', 'syn.locus.locativus'], prob: [Dimensio.constructio, Dimensio.productio, Dimensio.sensus]),
  _s('syn.locus.domus', 'Domum, domō, domī', 'Reconnaître domum (vers la maison), domō (de la maison), domī (à la maison) sans préposition.', not: [], parens: 'syn.locus', ag: ['§427 a'], req: ['syn.locus.triplex']),
  _s('syn.praep.in.duplex', 'In et sub: duplex cāsus', 'Choisir in/sub + acc. pour le mouvement (in hortum it) et + abl. pour le lieu (in hortō est).', not: ['not.casus.acc', 'not.casus.abl'], parens: 'syn.praep', ag: ['§221 b'], req: ['n.des.um', 'n.des.o_long'], prob: [Dimensio.constructio, Dimensio.productio, Dimensio.sensus],
      conf: [_c('syn.acc.directio', Modus.functio, 'in hortum'), _c('syn.abl.locus', Modus.functio, 'in hortō')]),
  _s('syn.praep.in', 'In: dans, vers, contre', 'Connaître le sens de in selon le cas : in + abl. (dans, sur), in + acc. (vers, dans, contre).', not: [], parens: 'syn.praep', ag: ['§221 b'], req: ['syn.praep.in.duplex'], prob: [Dimensio.constructio, Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.praep.sub', Modus.sensus, 'in hortō (dans) / sub arbore (sous)')]),
  _s('syn.praep.sub', 'Sub: sous, au pied de', 'Connaître le sens de sub : sub + abl. (sous, au pied de), sub + acc. (jusque sous).', not: [], parens: 'syn.praep', ag: ['§221 b'], req: ['syn.praep.in.duplex'], prob: [Dimensio.constructio, Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.praep.in', Modus.sensus, 'sub / in')]),
  _s('syn.praep.cum.enclitica', 'Cum enclitique', 'Reconnaître mēcum, tēcum, sēcum, nōbīscum, quōcum (cum postposé aux pronoms).', not: [], parens: 'syn.praep', ag: ['§143 f'], req: ['syn.abl.comitatus', 'pron.ego']),

  // =====================================================================
  // Accord
  // =====================================================================
  _s('syn.concordia.adiectivum', 'Cōnsēnsus adiectīvī', 'Accorder l\'adjectif au nom en genre, nombre et cas, même de déclinaison différente (rēx bonus, manus magna, corpus magnum).', not: ['not.genus', 'not.numerus', 'not.casus'], parens: 'syn.concordia', ag: ['§286'], req: ['adj.classis.12', 'adj.classis.3.duo'], prob: [Dimensio.quodNomen, Dimensio.productio, Dimensio.sensus],
      conf: [_c('syn.concordia.distans', Modus.functio, 'l\'adjectif n\'est pas forcément à côté du nom'), _c('n.thema.d4.m', Modus.analogia, '*manus magnus : la 4e en -us peut être féminine')]),
  _s('syn.concordia.distans', 'Adiectīvum ā nōmine distāns', 'Retrouver le nom d\'un adjectif éloigné par l\'accord (magnam in silvā vīdit umbram).', not: [], parens: 'syn.concordia', ag: ['§286', '§598'], req: ['syn.concordia.adiectivum'], prob: [Dimensio.quodNomen, Dimensio.sensus],
      conf: [_c('syn.concordia.adiectivum', Modus.functio, 'magnam … silvā : magnam ne va pas avec silvā')]),
  _s('syn.concordia.plura', 'Ūnum adiectīvum, plūra nōmina', 'Accorder un adjectif à plusieurs noms : pluriel ; masculin pour des personnes de genres différents, neutre pour des choses (pater et māter laetī).', not: ['not.genus', 'not.numerus.pl'], parens: 'syn.concordia', ag: ['§287'], req: ['syn.concordia.adiectivum'],
      conf: [_c('syn.concordia.adiectivum', Modus.functio, 'pater et māter laetī, non *laeta')]),
  _s('syn.concordia.praedicativum', 'Adiectīvum praedicātīvum', 'Accorder l\'attribut au sujet (puella laeta est ; puerī laetī sunt).', not: [], parens: 'syn.concordia', ag: ['§283–286'], req: ['syn.concordia.adiectivum', 'syn.nom.praedicativum']),
  _s('syn.concordia.appositio', 'Appositiō', 'Reconnaître l\'apposition au même cas que son nom (Iūlius, pater Mārcī ; Rōma, urbs magna ; urbs Rōma).', not: ['not.casus'], parens: 'syn.concordia', ag: ['§282'], req: ['syn.nom.subiectum'],
      conf: [_c('syn.gen.possessivus', Modus.functio, 'urbs Rōma (apposition) / urbs Rōmae (génitif : non classique)')]),
  _s('syn.concordia.participium', 'Cōnsēnsus participiī', 'Accorder le participe comme un adjectif avec le nom qu\'il qualifie (puella cantāns ; puerī vocātī).', not: ['not.genus', 'not.numerus', 'not.casus'], parens: 'syn.concordia', ag: ['§286', '§494'], req: ['syn.concordia.adiectivum', 'v.nom.part.praes.nt']),
  _s('syn.concordia.relativum', 'Cōnsēnsus relātīvī', 'Accorder le relatif en genre et nombre avec l\'antécédent, en cas avec sa fonction dans la relative (puer quem videō ; puella cui dō).', not: ['not.genus', 'not.numerus', 'not.casus'], parens: 'syn.concordia', ag: ['§305–306'], req: ['pron.qui'], prob: [Dimensio.genusNumerus, Dimensio.casus, Dimensio.productio, Dimensio.sensus],
      conf: [_c('syn.concordia.adiectivum', Modus.analogia, 'le cas du relatif ne vient pas de l\'antécédent')]),
  _s('syn.concordia.verbum', 'Cōnsēnsus verbī cum subiectō', 'Accorder le verbe au sujet en personne et en nombre ; sujets coordonnés → pluriel (pater et fīlius veniunt).', not: ['not.persona', 'not.numerus'], parens: 'syn.concordia', ag: ['§316–317'], req: ['syn.nom.subiectum', 'v.des.act.3.pl.nt'],
      conf: [_c('syn.nom.subiectum', Modus.functio, 'puerī currit : impossible, currunt')]),
  _s('syn.concordia.collectivum', 'Nōmen collēctīvum', 'Accorder un collectif (pars, multitūdō, turba) au singulier ou, par le sens, au pluriel.', not: [], parens: 'syn.concordia', ag: ['§317 d'], req: ['syn.concordia.verbum']),

  // =====================================================================
  // Ordre des mots, particules
  // =====================================================================
  _s('syn.ordo.verbum.finale', 'Verbum in fīne', 'Savoir que le verbe est d\'ordinaire en fin de phrase et que l\'ordre ne marque pas la fonction (puer puellam videt = puellam puer videt).', not: [], parens: 'syn.ordo', ag: ['§596'], req: ['syn.nom.subiectum', 'syn.acc.obiectum'],
      conf: [_c('syn.nom.subiectum', Modus.functio, 'le premier mot n\'est pas forcément le sujet')]),
  _s('syn.ordo.emphasis', 'Ōrdō et emphasis', 'Lire un ordre inhabituel comme une mise en relief (magnam vīdit umbram).', not: [], parens: 'syn.ordo', ag: ['§597–598'], req: ['syn.ordo.verbum.finale', 'syn.concordia.distans']),
  _s('syn.ordo.encliticae', 'Encliticae -que, -ne, -ve', 'Détacher -que (et), -ne (est-ce que), -ve (ou) du mot qui les porte (puerīque = et puerī).', not: [], parens: 'syn.ordo', ag: ['§599 b'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('n.des.ae', Modus.similitudo, 'puellaeque : -ae + -que')]),
  _s('syn.ordo.postpositiva', 'Autem, enim, igitur, vērō', 'Reconnaître les particules qui se placent en seconde position (autem, enim, igitur, vērō, quidem).', not: [], parens: 'syn.ordo', ag: ['§599 b'], prob: [Dimensio.sensus]),
  _s('syn.ordo.coordinatio', 'Coniūnctiōnēs coōrdinantēs', 'Lire et produire et, -que, atque/ac, etiam, sed, at, autem, aut, vel, nec/neque, nam, enim, ergō, itaque, igitur.', not: [], parens: 'syn.ordo', ag: ['§223–224', '§324'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.sub.causalis', Modus.functio, 'nam, enim (coordonnants) / quia, quod (subordonnants)'), _c('syn.ordo.encliticae', Modus.functio, 'et / -que')]),

  // =====================================================================
  // Interrogation
  // =====================================================================
  _s('syn.interrog.ne', 'Interrogātiō cum -ne', 'Reconnaître la question neutre : -ne sur le premier mot (Venitne puer ?).', not: [], parens: 'syn.interrog', ag: ['§332'], req: ['syn.ordo.encliticae'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.interrog.nonne', Modus.functio, '-ne (neutre) / nōnne (attend oui)'), _c('syn.interrog.num', Modus.functio, '-ne / num (attend non)')]),
  _s('syn.interrog.nonne', 'Nōnne', 'Reconnaître la question qui attend oui : nōnne venit ? (n\'est-ce pas qu\'il vient ?).', not: [], parens: 'syn.interrog', ag: ['§332 b'], req: ['syn.interrog.ne'],
      conf: [_c('syn.interrog.num', Modus.functio, 'nōnne / num'), _c('syn.neg.non', Modus.functio, 'nōnne n\'est pas une négation')]),
  _s('syn.interrog.num', 'Num', 'Reconnaître la question qui attend non : num venit ? (est-ce qu\'il vient, vraiment ?) ; num = si dans l\'interrogative indirecte.', not: [], parens: 'syn.interrog', ag: ['§332 b'], req: ['syn.interrog.ne'],
      conf: [_c('syn.interrog.nonne', Modus.functio, 'num / nōnne'), _c('syn.sub.interrogativa', Modus.functio, 'num dans une indirecte = si')]),
  _s('syn.interrog.verba', 'Verba interrogātīva', 'Lire quis, quid, cūr, ubi, quō, unde, quandō, quōmodo, quot, quālis, quantus, uter et y répondre.', not: [], parens: 'syn.interrog', ag: ['§333'], req: ['pron.quis'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.interrog.cur_quia', Modus.functio, 'cūr ? … quia'), _c('syn.locus.triplex', Modus.functio, 'ubi / quō / unde')]),
  _s('syn.interrog.cur_quia', 'Cūr … quia', 'Apparier la question cūr ? et la réponse quia / quod (pourquoi ? parce que).', not: [], parens: 'syn.interrog', ag: ['§333', '§540'], req: ['syn.interrog.verba', 'syn.sub.causalis']),
  _s('syn.interrog.utrum_an', 'Utrum … an', 'Reconnaître la question double : utrum … an, -ne … an, an seul (utrum venit an manet ?) ; annōn / necne.', not: [], parens: 'syn.interrog', ag: ['§334–335'], req: ['syn.interrog.ne']),
  _s('syn.interrog.responsa', 'Respōnsa', 'Répondre sans oui/non : par le verbe (venit), ita, etiam, sānē, minimē, nōn.', not: [], parens: 'syn.interrog', ag: ['§336'], req: ['syn.interrog.ne']),

  // =====================================================================
  // Négation
  // =====================================================================
  _s('syn.neg.non', 'Nōn', 'Placer nōn devant le mot nié ; nōn devant le verbe nie la phrase.', not: [], parens: 'syn.neg', ag: ['§325'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.neg.ne', Modus.functio, 'nōn (fait) / nē (volonté)')]),
  _s('syn.neg.ne', 'Nē', 'Employer nē pour la volonté et le but : nē veniat, nē + subj. parfait (interdiction), ut nē.', not: ['not.modus.subj'], parens: 'syn.neg', ag: ['§450', '§563'], req: ['syn.neg.non'],
      conf: [_c('syn.neg.non', Modus.functio, 'nē / nōn'), _c('syn.sub.timendi', Modus.functio, 'nē après timeō = que (positif)')]),
  _s('syn.neg.verba', 'Nēmō, nihil, nūllus, numquam, nusquam', 'Employer les négatifs lexicaux et savoir qu\'ils ne se cumulent pas avec nōn au sens négatif.', not: [], parens: 'syn.neg', ag: ['§326'], req: ['pron.indef.nemo', 'syn.neg.non'],
      conf: [_c('syn.neg.duplex', Modus.functio, 'nēmō nōn = tout le monde')]),
  _s('syn.neg.duplex', 'Duplex negātiō', 'Lire deux négations comme une affirmation renforcée (nōn nēmō = quelqu\'un ; nēmō nōn = chacun ; nōn possum nōn).', not: [], parens: 'syn.neg', ag: ['§326'], req: ['syn.neg.verba']),
  _s('syn.neg.neque', 'Neque … neque, nec', 'Lire neque/nec (et ne pas) et la double coordination négative (neque … neque = ni … ni).', not: [], parens: 'syn.neg', ag: ['§328'], req: ['syn.neg.non', 'syn.ordo.coordinatio'],
      conf: [_c('syn.ordo.coordinatio', Modus.functio, 'nec = et nōn')]),
  _s('syn.neg.nisi', 'Nōn … nisi, nisi', 'Lire nōn … nisi (ne … que) et nisi (si … ne … pas, sauf si).', not: [], parens: 'syn.neg', ag: ['§525 a'], req: ['syn.neg.non', 'syn.cond.realis']),

  // =====================================================================
  // Volonté, ordre
  // =====================================================================
  _s('syn.voluntas.imperativus', 'Imperātīvus: iussum', 'Donner un ordre à l\'impératif présent, singulier ou pluriel (venī ! venīte !).', not: ['not.modus.imp'], parens: 'syn.voluntas', ag: ['§448'], req: ['v.des.imp.2.sg', 'v.des.imp.2.pl.te'], prob: [Dimensio.sensus, Dimensio.productio, Dimensio.numerus],
      conf: [_c('syn.voluntas.hortativus', Modus.functio, 'venīte (vous) / veniāmus (nous)'), _c('syn.voluntas.prohibitio', Modus.functio, 'venī / nōlī venīre')]),
  _s('syn.voluntas.imperativus.fut', 'Imperātīvus futūrus', 'Lire l\'impératif futur des lois et des préceptes (amātō, scītōte, suntō).', not: ['not.modus.imp', 'not.tempus.fut'], parens: 'syn.voluntas', ag: ['§449'], req: ['v.sig.imp.fut.to', 'syn.voluntas.imperativus']),
  _s('syn.voluntas.prohibitio', 'Prohibitiō: nōlī, nē + perfectum', 'Interdire par nōlī/nōlīte + infinitif (nōlī venīre) ou nē + subjonctif parfait (nē vēneris), jamais *nōn venī.', not: ['not.modus.imp', 'not.modus.subj'], parens: 'syn.voluntas', ag: ['§450'], req: ['v.anom.nolo', 'v.sig.subj.perf.eri', 'syn.voluntas.imperativus'],
      conf: [_c('syn.voluntas.imperativus', Modus.functio, 'nōlī venīre / venī'), _c('syn.neg.non', Modus.analogia, '*nōn venī pour nōlī venīre')]),
  _s('syn.voluntas.hortativus', 'Subiūnctīvus hortātīvus', 'Exhorter à la 1re personne du pluriel (eāmus ! servēmus !) ; négation nē.', not: ['not.modus.subj', 'not.persona.1'], parens: 'syn.voluntas', ag: ['§439'], req: ['v.sig.subj.praes.e', 'v.sig.subj.praes.a'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.voluntas.optativus', Modus.functio, 'servēmus ! (exhortons) / utinam servēmus (pourvu que)'), _c('v.sig.praes', Modus.analogia, 'servāmus (nous gardons) / servēmus (gardons)'), _c('syn.voluntas.deliberativus', Modus.functio, 'eāmus ! / quid faciāmus ?')]),
  _s('syn.voluntas.iussivus', 'Subiūnctīvus iussīvus', 'Ordonner à la 3e personne (veniat ! ; nē veniant).', not: ['not.modus.subj', 'not.persona.3'], parens: 'syn.voluntas', ag: ['§439'], req: ['syn.voluntas.hortativus'],
      conf: [_c('syn.voluntas.imperativus', Modus.functio, 'veniat (qu\'il vienne) / venī (viens)')]),
  _s('syn.voluntas.optativus', 'Subiūnctīvus optātīvus: utinam', 'Souhaiter : utinam + subj. présent (réalisable), imparfait (irréel présent), plus-que-parfait (irréel passé) ; négation nē.', not: ['not.modus.subj'], parens: 'syn.voluntas', ag: ['§441–442'], req: ['syn.voluntas.hortativus', 'v.sig.subj.imperf.re'],
      conf: [_c('syn.voluntas.hortativus', Modus.functio, 'utinam veniat / veniāmus'), _c('syn.cond.irrealis.praes', Modus.functio, 'utinam venīret / sī venīret')]),
  _s('syn.voluntas.potentialis', 'Subiūnctīvus potentiālis', 'Lire le possible : dīcat quis (on pourrait dire), velim, crēdās ; parfait pour le passé (dīxerit quis).', not: ['not.modus.subj'], parens: 'syn.voluntas', ag: ['§445–447'], req: ['syn.voluntas.hortativus'],
      conf: [_c('syn.voluntas.optativus', Modus.functio, 'velim (je voudrais) / utinam velit'), _c('v.sig.praes', Modus.analogia, 'dīcat quis / dīcit quis')]),
  _s('syn.voluntas.deliberativus', 'Subiūnctīvus dēlīberātīvus', 'Lire la délibération : quid faciam ? (que faire ?) ; imparfait pour le passé (quid facerem ?).', not: ['not.modus.subj'], parens: 'syn.voluntas', ag: ['§444'], req: ['syn.voluntas.hortativus', 'syn.interrog.verba'],
      conf: [_c('syn.interrog.verba', Modus.functio, 'quid faciam ? (que faire) / quid faciō ? (que fais-je)')]),
  _s('syn.voluntas.concessivus', 'Subiūnctīvus concessīvus', 'Lire la concession au subjonctif : sit fūr (admettons qu\'il soit voleur).', not: ['not.modus.subj'], parens: 'syn.voluntas', ag: ['§440'], req: ['syn.voluntas.iussivus']),

  // =====================================================================
  // Temps dans le récit
  // =====================================================================
  _s('syn.tempora.praes_fut', 'Praesēns an futūrum', 'Distinguer dans la phrase -at/-ābit, -et/-ēbit, -it/-et (cantat / cantābit ; legit / leget).', not: ['not.tempus.praes', 'not.tempus.fut'], parens: 'syn.tempora', ag: ['§465', '§472'], req: ['v.sig.fut.b', 'v.sig.fut.a_e'], prob: [Dimensio.sensus, Dimensio.productio, Dimensio.tempus]),
  _s('syn.tempora.imperf_perf', 'Imperfectum an perfectum in nārrātiōne', 'Lire l\'imparfait comme arrière-plan, durée ou répétition (cantābat) et le parfait comme événement (cantāvit).', not: ['not.tempus.imperf', 'not.tempus.perf'], parens: 'syn.tempora', ag: ['§470–473'], req: ['v.sig.imperf.ba', 'v.sig.perf'], prob: [Dimensio.sensus, Dimensio.productio, Dimensio.tempus],
      conf: [_c('syn.tempora.plusq', Modus.functio, 'cantāvit / cantāverat')]),
  _s('syn.tempora.plusq', 'Plūsquamperfectum: anteriōritās', 'Lire le plus-que-parfait comme antérieur à un passé (iam fēcerat cum vēnit).', not: ['not.tempus.plusq'], parens: 'syn.tempora', ag: ['§477'], req: ['v.sig.plusq.era', 'syn.tempora.imperf_perf'],
      conf: [_c('syn.tempora.imperf_perf', Modus.functio, 'fēcerat / fēcit')]),
  _s('syn.tempora.futex', 'Futūrum exāctum: anteriōritās in futūrō', 'Lire le futur antérieur comme achevé avant un futur (cum vēnerit, videbit).', not: ['not.tempus.futex'], parens: 'syn.tempora', ag: ['§478'], req: ['v.sig.futex.eri', 'syn.tempora.praes_fut'],
      conf: [_c('syn.tempora.praes_fut', Modus.functio, 'vēnerit / veniet')]),
  _s('syn.tempora.praesens.historicum', 'Praesēns historicum', 'Lire un présent dans un récit au passé comme un présent de narration.', not: ['not.tempus.praes'], parens: 'syn.tempora', ag: ['§469'], req: ['syn.tempora.imperf_perf']),
  _s('syn.tempora.perfectum.praesens', 'Perfectum praesēns', 'Lire le parfait comme un accompli présent (vīxit : il a vécu, il n\'est plus ; nōvī : je sais).', not: ['not.tempus.perf'], parens: 'syn.tempora', ag: ['§473'], req: ['v.kind.def', 'syn.tempora.imperf_perf']),
  _s('syn.tempora.epistolare', 'Tempora epistulārum', 'Lire les temps d\'une lettre du point de vue du destinataire (scrībēbam = j\'écris).', not: [], parens: 'syn.tempora', ag: ['§479'], req: ['syn.tempora.imperf_perf']),

  // =====================================================================
  // Infinitif, discours indirect
  // =====================================================================
  _s('syn.inf.complementum', 'Īnfīnītīvus complēmentum', 'Reconnaître l\'infinitif complément de possum, volō, dēbeō, soleō, incipiō, cōnor (venīre potest).', not: ['not.modus.inf'], parens: 'syn.inf', ag: ['§456'], req: ['v.sig.inf.praes.act.re'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.inf.aci', Modus.functio, 'vult venīre (lui-même) / vult mē venīre (moi)'), _c('syn.sub.finalis', Modus.functio, 'venit petere : non classique pour le but')]),
  _s('syn.inf.subiectum', 'Īnfīnītīvus subiectum', 'Reconnaître l\'infinitif sujet d\'un impersonnel ou de est + adjectif (errāre hūmānum est ; licet īre).', not: ['not.modus.inf'], parens: 'syn.inf', ag: ['§452–455'], req: ['syn.inf.complementum']),
  _s('syn.inf.aci', 'Accūsātīvus cum īnfīnītīvō', 'Reconnaître la proposition infinitive après un verbe de parole, de pensée, de perception : sujet à l\'accusatif, verbe à l\'infinitif (dīcit puerum cantāre).', not: ['not.modus.inf', 'not.casus.acc'], parens: 'syn.inf', ag: ['§579–581'], req: ['syn.inf.complementum', 'syn.acc.obiectum'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.acc.obiectum', Modus.functio, 'puerum cantāre : puerum est sujet de cantāre, pas objet de dīcit'), _c('syn.sub.ut.completiva', Modus.functio, 'dīcit puerum cantāre / imperat ut puer cantet'), _c('syn.sub.quod', Modus.analogia, '*dīcit quod puer cantat')]),
  _s('syn.inf.aci.tempus.praes', 'Īnfīnītīvus praesēns: simultāneitās', 'Lire l\'infinitif présent comme simultané au verbe principal, quel que soit son temps (dīcit/dīxit puerum cantāre : chante / chantait).', not: ['not.tempus.praes'], parens: 'syn.inf', ag: ['§584'], req: ['syn.inf.aci'],
      conf: [_c('syn.inf.aci.tempus.perf', Modus.functio, 'cantāre / cantāvisse'), _c('syn.inf.aci.tempus.fut', Modus.functio, 'cantāre / cantātūrum esse')]),
  _s('syn.inf.aci.tempus.perf', 'Īnfīnītīvus perfectus: anteriōritās', 'Lire l\'infinitif parfait comme antérieur au verbe principal (dīcit puerum cantāvisse : a chanté ; dīxit : avait chanté).', not: ['not.tempus.perf'], parens: 'syn.inf', ag: ['§584'], req: ['syn.inf.aci', 'v.sig.inf.perf.act.isse'],
      conf: [_c('syn.inf.aci.tempus.praes', Modus.functio, 'cantāvisse / cantāre'), _c('syn.inf.aci.tempus.fut', Modus.functio, 'cantāvisse / cantātūrum esse')]),
  _s('syn.inf.aci.tempus.fut', 'Īnfīnītīvus futūrus: posteriōritās', 'Lire l\'infinitif futur comme postérieur au verbe principal (dīcit puerum cantātūrum esse : chantera ; dīxit : chanterait) ; le participe s\'accorde au sujet.', not: ['not.tempus.fut'], parens: 'syn.inf', ag: ['§584'], req: ['syn.inf.aci', 'v.comp.inf.fut.act'],
      conf: [_c('syn.inf.aci.tempus.perf', Modus.functio, 'cantātūrum esse / cantāvisse'), _c('syn.inf.aci.tempus.praes', Modus.functio, 'cantātūrum esse / cantāre'), _c('v.comp.peri.act', Modus.functio, 'cantātūrum esse / cantātūrus est')]),
  _s('syn.inf.aci.passivum', 'Īnfīnītīvus passīvus in AcI', 'Lire l\'infinitive au passif (dīcit puerum laudārī / laudātum esse / laudātum īrī).', not: ['not.vox.pass'], parens: 'syn.inf', ag: ['§584'], req: ['syn.inf.aci', 'v.comp.inf.perf.pass'],
      conf: [_c('syn.inf.aci.tempus.perf', Modus.functio, 'laudātum esse (passif) / laudāvisse (actif)')]),
  _s('syn.inf.aci.reflexivum', 'Sē in AcI', 'Lire sē / suus dans l\'infinitive comme renvoyant au sujet du verbe de parole (dīcit sē venīre : il dit qu\'il vient, lui-même) ; eum renvoie à un autre.', not: [], parens: 'syn.inf', ag: ['§580'], req: ['syn.inf.aci', 'pron.se', 'pron.suus_eius'], prob: [Dimensio.relatio, Dimensio.sensus, Dimensio.productio],
      conf: [_c('pron.is', Modus.functio, 'dīcit sē venīre / dīcit eum venīre')]),
  _s('syn.inf.iubeo', 'Iubeō, vetō, sinō + īnfīnītīvō', 'Savoir que iubeō, vetō, sinō, patior prennent l\'infinitive et non ut (iubet puerum venīre).', not: [], parens: 'syn.inf', ag: ['§563 a'], req: ['syn.inf.aci', 'syn.sub.ut.completiva'],
      conf: [_c('syn.sub.ut.completiva', Modus.functio, 'iubet puerum venīre / imperat puerō ut veniat')]),
  _s('syn.inf.historicum', 'Īnfīnītīvus historicus', 'Lire l\'infinitif de narration avec sujet au nominatif (hostēs fugere).', not: [], parens: 'syn.inf', ag: ['§463'], req: ['syn.inf.aci', 'syn.tempora.imperf_perf']),

  // =====================================================================
  // Participes, gérondif, adjectif verbal, supin
  // =====================================================================
  _s('syn.part.coniunctum', 'Participium coniūnctum', 'Lire le participe accordé à un nom de la phrase comme une circonstance (medicus mercātōrem salūtāns urbem intrat : en saluant).', not: ['not.forma.part'], parens: 'syn.part', ag: ['§496'], req: ['syn.concordia.participium'], prob: [Dimensio.sensus, Dimensio.productio, Dimensio.quodNomen],
      conf: [_c('syn.abl.absolutus', Modus.functio, 'salūtāns (conjoint) / salūtante (absolu)'), _c('syn.concordia.participium', Modus.functio, 'salūtāns (le médecin) / salūtantem (le marchand)'), _c('syn.part.coniunctum.perf', Modus.functio, 'salūtāns (en saluant) / salūtātus (ayant été salué)')]),
  _s('syn.part.coniunctum.perf', 'Participium perfectum coniūnctum', 'Lire le participe parfait conjoint comme antérieur et passif (puer vocātus venit : appelé, le garçon vient) ; actif pour les déponents (secūtus).', not: ['not.tempus.perf', 'not.vox.pass'], parens: 'syn.part', ag: ['§489', '§496'], req: ['syn.part.coniunctum', 'v.nom.part.perf.tus'],
      conf: [_c('syn.part.coniunctum', Modus.functio, 'vocātus / vocāns'), _c('v.kind.dep.part', Modus.functio, 'secūtus : ayant suivi')]),
  _s('syn.part.coniunctum.fut', 'Participium futūrum coniūnctum', 'Lire le participe futur comme intention ou imminence (moritūrus tē salūtat).', not: ['not.tempus.fut'], parens: 'syn.part', ag: ['§498'], req: ['syn.part.coniunctum', 'v.nom.part.fut.urus'],
      conf: [_c('syn.part.gerundivum', Modus.functio, 'moritūrus (qui va mourir) / amandus (à aimer)')]),
  _s('syn.part.valores', 'Valōrēs participiī coniūnctī', 'Choisir la nuance du participe conjoint : temporelle, causale, concessive, conditionnelle, selon le contexte.', not: [], parens: 'syn.part', ag: ['§496'], req: ['syn.part.coniunctum', 'syn.sub.temporalis', 'syn.sub.causalis']),
  _s('syn.part.gerundivum', 'Gerundīvum: obligātiō', 'Lire l\'adjectif verbal avec sum comme une obligation passive (liber legendus est : le livre doit être lu) ; agent au datif.', not: ['not.forma.gdv'], parens: 'syn.part', ag: ['§500', '§194'], req: ['v.comp.peri.pass', 'syn.dat.agentis'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.part.periphrastica.act', Modus.functio, 'legendus est / lectūrus est'), _c('v.comp.perf.pass', Modus.functio, 'legendus est / lēctus est')]),
  _s('syn.part.gerundivum.attractio', 'Gerundīvī attractiō', 'Remplacer le gérondif + objet par l\'adjectif verbal accordé (ad urbem capiendam, non *ad capiendum urbem).', not: ['not.forma.gdv'], parens: 'syn.part', ag: ['§503'], req: ['syn.part.gerundium', 'syn.part.gerundivum'],
      conf: [_c('syn.part.gerundium', Modus.functio, 'ad urbem capiendam / ad capiendum')]),
  _s('syn.part.gerundium', 'Gerundium', 'Employer le gérondif aux cas obliques : ad + acc. (but), causā + gén., gén. après un adjectif (cupidus discendī), abl. de moyen (legendō discit).', not: ['not.forma.ger'], parens: 'syn.part', ag: ['§501–507'], req: ['v.nom.ger.nd'], prob: [Dimensio.sensus, Dimensio.productio, Dimensio.casus],
      conf: [_c('syn.inf.complementum', Modus.functio, 'ad discendum (pour apprendre) / discere (apprendre)'), _c('syn.part.gerundivum', Modus.syncretismus, 'discendī : gérondif ou adjectif verbal')]),
  _s('syn.part.gerundium.ad', 'Ad + gerundium', 'Exprimer le but par ad + gérondif (ad discendum venit).', not: [], parens: 'syn.part', ag: ['§506'], req: ['syn.part.gerundium'],
      conf: [_c('syn.part.gerundium.causa', Modus.functio, 'ad discendum / discendī causā'), _c('syn.sub.finalis', Modus.functio, 'ad discendum / ut discat')]),
  _s('syn.part.gerundium.causa', 'Gerundium + causā', 'Exprimer le but par le génitif du gérondif + causā (discendī causā).', not: [], parens: 'syn.part', ag: ['§504 b'], req: ['syn.part.gerundium'],
      conf: [_c('syn.part.gerundium.ad', Modus.functio, 'discendī causā / ad discendum')]),
  _s('syn.part.gerundium.gen', 'Gerundium post adiectīva et nōmina', 'Lire le génitif du gérondif après cupidus, studiōsus, ars, tempus (cupidus discendī).', not: [], parens: 'syn.part', ag: ['§504'], req: ['syn.part.gerundium', 'syn.gen.memoriae']),
  _s('syn.part.gerundium.abl', 'Gerundium ablātīvus: modus', 'Lire l\'ablatif du gérondif comme moyen (legendō discit : en lisant).', not: [], parens: 'syn.part', ag: ['§507'], req: ['syn.part.gerundium', 'syn.abl.instrumentum'],
      conf: [_c('syn.part.coniunctum', Modus.functio, 'legendō (en lisant, moyen) / legēns (en lisant, circonstance)')]),
  _s('syn.part.periphrastica.act', 'Periphrastica āctīva in sententiā', 'Lire -ūrus sum comme imminence ou intention (scrīptūrus sum : je vais écrire).', not: [], parens: 'syn.part', ag: ['§195'], req: ['v.comp.peri.act'],
      conf: [_c('syn.part.gerundivum', Modus.functio, 'scrīptūrus sum / scrībendus sum'), _c('syn.tempora.praes_fut', Modus.functio, 'scrīptūrus sum / scrībam')]),
  _s('syn.part.supinum.um', 'Supīnum in -um', 'Lire le supin en -um après un verbe de mouvement comme un but (dormītum it ; lēgātōs mittunt pācem petītum).', not: ['not.forma.sup'], parens: 'syn.part', ag: ['§509'], req: ['v.nom.sup.um'],
      conf: [_c('syn.part.gerundium.ad', Modus.functio, 'dormītum it / ad dormiendum it'), _c('v.nom.part.perf.tus', Modus.syncretismus, 'petītum : supin ou participe')]),
  _s('syn.part.supinum.u', 'Supīnum in -ū', 'Lire le supin en -ū après un adjectif comme un point de vue (mīrābile dictū ; facile factū).', not: ['not.forma.sup'], parens: 'syn.part', ag: ['§510'], req: ['v.nom.sup.u'],
      conf: [_c('syn.part.supinum.um', Modus.functio, 'dictū / dictum')]),

  // =====================================================================
  // Subordonnées
  // =====================================================================
  _s('syn.sub.consecutio', 'Cōnsecūtiō temporum', 'Choisir le temps du subjonctif selon le verbe principal : présent/parfait après un présent ou un futur ; imparfait/plus-que-parfait après un passé (rogat quid faciat ; rogāvit quid faceret).', not: ['not.modus.subj'], parens: 'syn.sub', ag: ['§482–485'], req: ['v.sig.subj.praes.a', 'v.sig.subj.imperf.re', 'v.sig.subj.perf.eri', 'v.sig.subj.plusq.isse'], prob: [Dimensio.sensus, Dimensio.productio, Dimensio.tempus],
      conf: [_c('syn.tempora.imperf_perf', Modus.analogia, 'faceret (subordonnée) ne traduit pas un imparfait absolu')]),
  _s('syn.sub.consecutio.anterior', 'Cōnsecūtiō: anteriōritās', 'Marquer l\'antériorité dans la subordonnée : parfait après un présent, plus-que-parfait après un passé (rogāvit quid fēcisset).', not: [], parens: 'syn.sub', ag: ['§483'], req: ['syn.sub.consecutio'],
      conf: [_c('syn.sub.consecutio', Modus.functio, 'fēcisset (avant) / faceret (pendant)')]),
  _s('syn.sub.consecutio.posterior', 'Cōnsecūtiō: posteriōritās', 'Marquer la postériorité : -ūrus sim / essem (rogāvit quid factūrus esset).', not: [], parens: 'syn.sub', ag: ['§483'], req: ['syn.sub.consecutio', 'v.comp.peri.act'],
      conf: [_c('syn.sub.consecutio', Modus.functio, 'factūrus esset (après) / faceret (pendant)')]),
  _s('syn.sub.interrogativa', 'Interrogātiō indīrēcta', 'Reconnaître l\'interrogative indirecte : mot interrogatif + subjonctif (rogat ubi habitet ; nescit num veniat).', not: ['not.modus.subj'], parens: 'syn.sub', ag: ['§573–576'], req: ['syn.sub.consecutio', 'syn.interrog.verba'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.rel.indicativus', Modus.functio, 'rogat quid faciat (interrogative) / videt quod facit (relative)'), _c('syn.interrog.verba', Modus.functio, 'directe (indicatif) / indirecte (subjonctif)')]),
  _s('syn.sub.finalis', 'Ut / nē fīnāle', 'Reconnaître le but : ut + subj. (pour que), nē + subj. (pour ne pas) ; temps selon la concordance (venit ut videat ; vēnit ut vidēret).', not: ['not.modus.subj'], parens: 'syn.sub', ag: ['§531'], req: ['syn.sub.consecutio', 'syn.neg.ne'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.sub.consecutiva', Modus.functio, 'ut videat (pour voir) / tam … ut videat (si bien qu\'il voit)'), _c('syn.sub.causalis', Modus.functio, 'ut videat / quia videt'), _c('syn.sub.ut.completiva', Modus.functio, 'ut final / ut complétif après imperō'), _c('syn.part.gerundium.ad', Modus.functio, 'ut videat / ad videndum')]),
  _s('syn.sub.consecutiva', 'Ut cōnsecūtīvum', 'Reconnaître la conséquence : tam, tantus, ita, sīc … ut + subj. (tam fortis est ut vincat) ; négation ut nōn.', not: ['not.modus.subj'], parens: 'syn.sub', ag: ['§537–538'], req: ['syn.sub.finalis'],
      conf: [_c('syn.sub.finalis', Modus.functio, 'ut nōn (conséquence) / nē (but)'), _c('syn.sub.finalis', Modus.functio, 'tam … ut : chercher l\'annonce')]),
  _s('syn.sub.ut.completiva', 'Ut / nē complētīvum', 'Reconnaître la complétive de volonté après imperō, rogō, petō, moneō, hortor, cūrō, faciō : ut/nē + subj. (imperat ut veniat).', not: ['not.modus.subj'], parens: 'syn.sub', ag: ['§563'], req: ['syn.sub.finalis'],
      conf: [_c('syn.inf.aci', Modus.functio, 'imperat ut veniat / dīcit eum venīre'), _c('syn.inf.iubeo', Modus.functio, 'imperat ut / iubet + inf.'), _c('syn.sub.finalis', Modus.functio, 'complétive (objet du verbe) / finale (circonstance)')]),
  _s('syn.sub.timendi', 'Verba timendī: nē, ut', 'Lire nē après un verbe de crainte comme « que … (positif) » et ut / nē nōn comme « que … ne … pas » (timet nē veniat : il craint qu\'il vienne).', not: ['not.modus.subj'], parens: 'syn.sub', ag: ['§564'], req: ['syn.sub.ut.completiva'],
      conf: [_c('syn.sub.finalis', Modus.functio, 'timet nē veniat : nē n\'est pas négatif'), _c('syn.neg.ne', Modus.functio, 'nē après timeō / nē prohibitif')]),
  _s('syn.sub.impediendi', 'Verba impediendī: nē, quōminus, quīn', 'Lire nē / quōminus après impediō, prohibeō, dēterreō (impedit nē veniat : il l\'empêche de venir) ; quīn après une négation.', not: ['not.modus.subj'], parens: 'syn.sub', ag: ['§558'], req: ['syn.sub.timendi'],
      conf: [_c('syn.sub.timendi', Modus.functio, 'impedit nē / timet nē'), _c('syn.sub.quin', Modus.functio, 'nōn impedit quīn')]),
  _s('syn.sub.quin', 'Quīn post dubitātiōnem negātam', 'Lire quīn + subj. après nōn dubitō, nōn est dubium (nōn dubitō quīn veniat : je ne doute pas qu\'il vienne).', not: ['not.modus.subj'], parens: 'syn.sub', ag: ['§558 a'], req: ['syn.sub.impediendi', 'syn.neg.non'],
      conf: [_c('syn.sub.interrogativa', Modus.functio, 'dubitō num veniat (je me demande si) / nōn dubitō quīn veniat')]),
  _s('syn.sub.quod', 'Quod complētīvum: rēs facta', 'Reconnaître quod + indicatif (le fait que) après gaudeō, doleō, addō, bene facis (gaudeō quod venīs).', not: ['not.modus.ind'], parens: 'syn.sub', ag: ['§572'], req: ['syn.sub.causalis'],
      conf: [_c('syn.inf.aci', Modus.functio, 'gaudeō quod venīs / gaudeō tē venīre'), _c('syn.sub.causalis', Modus.functio, 'quod (le fait que) / quod (parce que)')]),
  _s('syn.sub.causalis', 'Quod, quia, quoniam', 'Reconnaître la cause : quod, quia, quoniam + indicatif (cause donnée par le locuteur) ; subjonctif pour une cause rapportée.', not: ['not.modus.ind'], parens: 'syn.sub', ag: ['§539–540'], req: ['syn.ordo.coordinatio'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.sub.finalis', Modus.functio, 'quia (parce que) / ut (pour que)'), _c('syn.sub.cum.causale', Modus.functio, 'quod + ind. / cum + subj.'), _c('syn.abl.causae', Modus.functio, 'quia famem patitur / famē'), _c('syn.sub.temporalis', Modus.functio, 'quod / quandō')]),
  _s('syn.sub.cum.temporale', 'Cum temporāle (indicātīvus)', 'Lire cum + indicatif comme une pure datation (cum Caesar vēnit, … ; cum + futur antérieur).', not: ['not.modus.ind'], parens: 'syn.sub', ag: ['§545'], req: ['syn.tempora.imperf_perf'],
      conf: [_c('syn.sub.cum.historicum', Modus.functio, 'cum vēnit (ind.) / cum vēnisset (subj.)')]),
  _s('syn.sub.cum.historicum', 'Cum historicum (subiūnctīvus)', 'Lire cum + subj. imparfait ou plus-que-parfait dans un récit comme circonstance (cum Caesar vēnisset, hostēs fūgērunt : comme / lorsque).', not: ['not.modus.subj'], parens: 'syn.sub', ag: ['§546'], req: ['syn.sub.consecutio', 'syn.sub.cum.temporale'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.sub.cum.temporale', Modus.functio, 'cum vēnisset / cum vēnit'), _c('syn.sub.cum.causale', Modus.functio, 'circonstance ou cause'), _c('syn.sub.cum.concessivum', Modus.functio, 'cum … tamen')]),
  _s('syn.sub.cum.causale', 'Cum causāle', 'Lire cum + subj. comme cause (cum aeger esset, domī mānsit : comme il était malade).', not: ['not.modus.subj'], parens: 'syn.sub', ag: ['§549'], req: ['syn.sub.cum.historicum'],
      conf: [_c('syn.sub.causalis', Modus.functio, 'cum esset / quod erat')]),
  _s('syn.sub.cum.concessivum', 'Cum concessīvum', 'Lire cum + subj. … tamen comme concession (cum aeger esset, tamen vēnit : bien que).', not: ['not.modus.subj'], parens: 'syn.sub', ag: ['§549'], req: ['syn.sub.cum.historicum'],
      conf: [_c('syn.sub.concessiva', Modus.functio, 'cum … tamen / quamquam')]),
  _s('syn.sub.cum.inversum', 'Cum inversum', 'Lire cum + indicatif parfait après une principale à l\'imparfait comme l\'événement soudain (iam dormiēbat cum subitō vēnit).', not: [], parens: 'syn.sub', ag: ['§546 a'], req: ['syn.sub.cum.temporale']),
  _s('syn.sub.temporalis', 'Postquam, ubi, ut, simul ac', 'Lire postquam, ubi, ut, simul ac, cum prīmum + parfait de l\'indicatif comme « après que, dès que » (postquam vēnit).', not: ['not.modus.ind'], parens: 'syn.sub', ag: ['§543'], req: ['syn.tempora.imperf_perf'],
      conf: [_c('syn.sub.cum.historicum', Modus.functio, 'postquam vēnit (ind.) / cum vēnisset (subj.)'), _c('syn.sub.finalis', Modus.functio, 'ut + ind. (dès que) / ut + subj. (pour que)')]),
  _s('syn.sub.dum', 'Dum, dōnec, quoad', 'Lire dum + présent de l\'indicatif comme « pendant que » (dum haec geruntur), dum/dōnec + subj. comme « jusqu\'à ce que », dum + ind. « tant que ».', not: [], parens: 'syn.sub', ag: ['§553–556'], req: ['syn.sub.temporalis'],
      conf: [_c('syn.sub.antequam', Modus.functio, 'dum (pendant/jusqu\'à) / antequam (avant que)'), _c('syn.abl.absolutus.praes', Modus.functio, 'dum cantat / cantante')]),
  _s('syn.sub.antequam', 'Antequam, priusquam', 'Lire antequam/priusquam + indicatif (fait) ou subjonctif (attente, intention) comme « avant que ».', not: [], parens: 'syn.sub', ag: ['§551'], req: ['syn.sub.dum']),
  _s('syn.sub.concessiva', 'Quamquam, quamvīs, etsī, licet', 'Reconnaître la concession : quamquam + indicatif, quamvīs / licet + subjonctif, etsī comme sī ; tamen dans la principale.', not: [], parens: 'syn.sub', ag: ['§527'], req: ['syn.sub.causalis'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.sub.causalis', Modus.functio, 'quamquam (bien que) / quia (parce que)'), _c('syn.sub.cum.concessivum', Modus.functio, 'quamquam / cum … tamen')]),
  _s('syn.sub.comparativa', 'Sententiae comparātīvae: ut … ita, quasi', 'Lire ut/sīcut … ita (comme … ainsi) + indicatif, et quasi, tamquam, velut sī + subjonctif (comme si).', not: [], parens: 'syn.sub', ag: ['§524', '§323 g'], req: ['syn.comp.quam'],
      conf: [_c('syn.sub.finalis', Modus.functio, 'ut … ita (comparaison) / ut + subj. (but)')]),

  // =====================================================================
  // Relatives
  // =====================================================================
  _s('syn.rel.indicativus', 'Relātīva cum indicātīvō', 'Lire la relative déterminative à l\'indicatif ; trouver l\'antécédent par l\'accord et la fonction du relatif par son cas (puer quī currit ; puer quem videō).', not: ['not.modus.ind'], parens: 'syn.rel', ag: ['§303–308'], req: ['syn.concordia.relativum'], prob: [Dimensio.sensus, Dimensio.productio, Dimensio.casus],
      conf: [_c('syn.sub.interrogativa', Modus.functio, 'quem videō (relative) / rogat quem videam (interrogative)'), _c('syn.rel.finalis', Modus.functio, 'quī currit (ind.) / quī currat (subj.)')]),
  _s('syn.rel.finalis', 'Relātīva fīnālis', 'Lire quī + subj. comme un but (mīsit lēgātōs quī pācem peterent = ut peterent).', not: ['not.modus.subj'], parens: 'syn.rel', ag: ['§531 2'], req: ['syn.rel.indicativus', 'syn.sub.finalis'],
      conf: [_c('syn.rel.indicativus', Modus.functio, 'quī peterent (pour demander) / quī petēbant (qui demandaient)'), _c('syn.rel.characteristica', Modus.functio, 'but / caractéristique')]),
  _s('syn.rel.characteristica', 'Relātīva charactēristica', 'Lire quī + subj. après sunt quī, nēmō est quī, dignus quī, is quī comme une propriété (sunt quī dīcant : il y a des gens pour dire).', not: ['not.modus.subj'], parens: 'syn.rel', ag: ['§535'], req: ['syn.rel.finalis'],
      conf: [_c('syn.rel.indicativus', Modus.functio, 'sunt quī dīcant / sunt quī dīcunt'), _c('syn.rel.finalis', Modus.functio, 'caractéristique / but')]),
  _s('syn.rel.causalis', 'Relātīva causālis et concessīva', 'Lire quī + subj. comme cause ou concession (quī hoc fēcerit, laudandus est : pour avoir fait cela).', not: ['not.modus.subj'], parens: 'syn.rel', ag: ['§535 e'], req: ['syn.rel.characteristica']),
  _s('syn.rel.connexum', 'Relātīvum coniūnctīvum', 'Lire un relatif en tête de phrase comme un démonstratif de liaison (Quae cum ita sint = et comme il en est ainsi).', not: [], parens: 'syn.rel', ag: ['§308 f'], req: ['syn.rel.indicativus'],
      conf: [_c('syn.rel.indicativus', Modus.functio, 'quī en tête de phrase = et is')]),
  _s('syn.rel.antecedens.omissum', 'Antecēdēns omissum', 'Lire une relative sans antécédent exprimé (quī hoc dīcit, errat : celui qui).', not: [], parens: 'syn.rel', ag: ['§307 c'], req: ['syn.rel.indicativus']),
  _s('syn.rel.attractio', 'Attractiō relātīvī', 'Reconnaître l\'attraction : l\'antécédent attiré dans la relative (urbem quam statuō vestra est).', not: [], parens: 'syn.rel', ag: ['§306 a'], req: ['syn.rel.indicativus']),
  _s('syn.rel.indefinita', 'Relātīva indēfīnīta et generālis', 'Lire quīcumque, quisquis, ubicumque + indicatif (quiconque, où que).', not: [], parens: 'syn.rel', ag: ['§518'], req: ['pron.rel.indef', 'syn.rel.indicativus']),

  // =====================================================================
  // Conditionnelles
  // =====================================================================
  _s('syn.cond.realis', 'Condiciō aperta (realis)', 'Lire sī + indicatif, principale à l\'indicatif, comme une condition ouverte (sī hospes adest, iānuam aperit).', not: ['not.modus.ind'], parens: 'syn.cond', ag: ['§514–515'], req: ['syn.tempora.praes_fut'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.cond.potentialis', Modus.functio, 'aperit / aperiat'), _c('syn.cond.irrealis.praes', Modus.functio, 'aperit / aperīret'), _c('syn.sub.causalis', Modus.functio, 'sī (si) / quia (puisque)')]),
  _s('syn.cond.realis.fut', 'Condiciō in futūrō: futūrum exāctum', 'Employer le futur antérieur dans la condition et le futur dans la principale (sī vēnerit, videbit).', not: ['not.tempus.futex'], parens: 'syn.cond', ag: ['§516 c'], req: ['syn.cond.realis', 'syn.tempora.futex'],
      conf: [_c('syn.cond.realis', Modus.functio, 'sī vēnerit / sī venit')]),
  _s('syn.cond.potentialis', 'Condiciō possibilis (potentiālis)', 'Lire sī + subj. présent (ou parfait), principale au subj. présent, comme un possible (sī hospes adsit, iānuam aperiat : si un hôte venait, il ouvrirait).', not: ['not.modus.subj'], parens: 'syn.cond', ag: ['§516 b'], req: ['syn.cond.realis', 'v.sig.subj.praes.a'],
      conf: [_c('syn.cond.realis', Modus.functio, 'aperiat / aperit'), _c('syn.cond.irrealis.praes', Modus.functio, 'aperiat (possible) / aperīret (irréel)'), _c('syn.voluntas.hortativus', Modus.functio, 'aperiat conditionnel / aperiat jussif')]),
  _s('syn.cond.irrealis.praes', 'Condiciō contrā vēritātem praesentem', 'Lire sī + subj. imparfait, principale au subj. imparfait, comme un irréel du présent (sī hospes adesset, iānuam aperīret : s\'il était là, il ouvrirait — mais il n\'est pas là).', not: ['not.modus.subj', 'not.tempus.imperf'], parens: 'syn.cond', ag: ['§517'], req: ['syn.cond.potentialis', 'v.sig.subj.imperf.re'],
      conf: [_c('syn.cond.potentialis', Modus.functio, 'aperīret / aperiat'), _c('syn.cond.irrealis.praet', Modus.functio, 'aperīret / aperuisset'), _c('syn.tempora.imperf_perf', Modus.analogia, 'aperīret n\'est pas un imparfait du récit')]),
  _s('syn.cond.irrealis.praet', 'Condiciō contrā vēritātem praeteritam', 'Lire sī + subj. plus-que-parfait, principale au subj. plus-que-parfait, comme un irréel du passé (sī adfuisset, aperuisset : s\'il avait été là, il aurait ouvert).', not: ['not.modus.subj', 'not.tempus.plusq'], parens: 'syn.cond', ag: ['§517'], req: ['syn.cond.irrealis.praes', 'v.sig.subj.plusq.isse'],
      conf: [_c('syn.cond.irrealis.praes', Modus.functio, 'aperuisset / aperīret')]),
  _s('syn.cond.mixta', 'Condiciō temporibus dīversīs', 'Lire une période aux temps mixtes (sī adfuisset, nunc aperīret : s\'il avait été là, il ouvrirait maintenant).', not: [], parens: 'syn.cond', ag: ['§517 a'], req: ['syn.cond.irrealis.praet']),
  _s('syn.cond.nisi', 'Nisi, sī nōn, sīn', 'Choisir nisi (si ne … pas, sauf si), sī nōn (nie un mot), sīn (mais si), sī minus.', not: [], parens: 'syn.cond', ag: ['§525'], req: ['syn.cond.realis', 'syn.neg.non']),
  _s('syn.cond.obliqua', 'Condiciō in ōrātiōne oblīquā', 'Reconnaître la condition rapportée : protase au subjonctif, apodose à l\'infinitif (dīxit sē, sī posset, ventūrum esse).', not: [], parens: 'syn.cond', ag: ['§589'], req: ['syn.cond.realis', 'syn.obl.subordinatae']),

  // =====================================================================
  // Comparaison
  // =====================================================================
  _s('syn.comp.quam', 'Comparātīvus cum quam', 'Lire le comparatif suivi de quam et du même cas (Mārcus altior est quam Iūlius).', not: ['not.gradus.comp'], parens: 'syn.comp', ag: ['§406–407'], req: ['adj.gradus.comp.ior', 'syn.concordia.praedicativum'], prob: [Dimensio.sensus, Dimensio.productio, Dimensio.gradus],
      conf: [_c('syn.abl.comparationis', Modus.functio, 'quam Iūlius / Iūliō'), _c('syn.comp.superlativus', Modus.functio, 'altior quam / altissimus omnium'), _c('syn.comp.tam_quam', Modus.functio, 'altior quam (plus que) / tam altus quam (aussi que)')]),
  _s('syn.comp.superlativus', 'Superlātīvus in sententiā', 'Lire le superlatif relatif avec génitif partitif ou ē/ex (altissimus omnium, ē puerīs) et le superlatif absolu (très).', not: ['not.gradus.sup'], parens: 'syn.comp', ag: ['§291'], req: ['adj.gradus.sup.issimus', 'syn.gen.partitivus'],
      conf: [_c('syn.comp.quam', Modus.functio, 'altissimus / altior')]),
  _s('syn.comp.quam.superlativus', 'Quam + superlātīvus', 'Lire quam + superlatif comme « le plus … possible » (quam celerrimē).', not: ['not.gradus.sup'], parens: 'syn.comp', ag: ['§291 c'], req: ['syn.comp.superlativus'],
      conf: [_c('syn.comp.quam', Modus.functio, 'quam celerrimē (le plus vite possible) / celerius quam (plus vite que)')]),
  _s('syn.comp.tam_quam', 'Tam … quam, tantus … quantus', 'Lire la comparaison d\'égalité par les corrélatifs (tam altus quam ; tantus quantus ; tot quot).', not: [], parens: 'syn.comp', ag: ['§323 g'], req: ['pron.corr'],
      conf: [_c('syn.comp.quam', Modus.functio, 'tam … quam / -ior quam')]),
  _s('syn.comp.quo_eo', 'Quō … eō, quantō … tantō', 'Lire quō … eō / quantō … tantō + comparatifs (plus … plus).', not: [], parens: 'syn.comp', ag: ['§414 a'], req: ['syn.abl.mensura', 'pron.corr']),
  _s('syn.comp.absolutus', 'Comparātīvus absolūtus', 'Lire le comparatif sans second terme comme « assez, trop, plutôt » (senior : assez âgé).', not: ['not.gradus.comp'], parens: 'syn.comp', ag: ['§291 a'], req: ['syn.comp.quam']),
  _s('syn.comp.adverbia', 'Adverbia comparāta in sententiā', 'Lire et produire les degrés de l\'adverbe dans la phrase (fortius pugnat ; fortissimē omnium).', not: ['not.gradus'], parens: 'syn.comp', ag: ['§218'], req: ['adj.adv.comp.ius', 'adj.adv.sup.issime', 'syn.comp.quam'],
      conf: [_c('adj.gradus.comp.ior', Modus.syncretismus, 'fortius : adverbe ou adjectif neutre')]),

  // =====================================================================
  // Discours indirect
  // =====================================================================
  _s('syn.obl.enuntiativa', 'Ōrātiō oblīqua: ēnūntiātiō', 'Rapporter une déclaration par l\'infinitive, avec ses trois temps relatifs (nūntius dīxit nautam nāvigāvisse).', not: ['not.modus.inf'], parens: 'syn.obl', ag: ['§580', '§584'], req: ['syn.inf.aci', 'syn.inf.aci.tempus.perf', 'syn.inf.aci.tempus.fut'], prob: [Dimensio.sensus, Dimensio.productio, Dimensio.tempus],
      conf: [_c('syn.obl.imperativa', Modus.functio, 'dīxit eum venīre / imperāvit ut venīret'), _c('syn.obl.interrogativa', Modus.functio, 'déclaration / question rapportée')]),
  _s('syn.obl.imperativa', 'Iussa oblīqua', 'Rapporter un ordre par ut/nē + subjonctif (imperāvit ut venīret ; monuit nē venīret) ou iubeō + infinitif.', not: ['not.modus.subj'], parens: 'syn.obl', ag: ['§588'], req: ['syn.sub.ut.completiva', 'syn.sub.consecutio'],
      conf: [_c('syn.obl.enuntiativa', Modus.functio, 'ut venīret / eum venīre'), _c('syn.inf.iubeo', Modus.functio, 'imperāvit ut / iussit + inf.')]),
  _s('syn.obl.interrogativa', 'Interrogātiōnēs in nārrātiōne', 'Rapporter une question : interrogative indirecte au subjonctif, temps selon la concordance (rogāvit ubi habitāret).', not: ['not.modus.subj'], parens: 'syn.obl', ag: ['§586'], req: ['syn.sub.interrogativa'],
      conf: [_c('syn.obl.enuntiativa', Modus.functio, 'rogāvit ubi habitāret / dīxit eum habitāre')]),
  _s('syn.obl.pronomina', 'Prōnōmina in ōrātiōne oblīquā', 'Déplacer les personnes : ego → sē, tū → is/ille, meus → suus, hic → is/ille (dīxit sē suum librum eī datūrum esse).', not: [], parens: 'syn.obl', ag: ['§580–581'], req: ['syn.inf.aci.reflexivum', 'pron.suus_eius'], prob: [Dimensio.relatio, Dimensio.sensus, Dimensio.productio],
      conf: [_c('pron.is', Modus.functio, 'sē (le locuteur) / eum (un autre)')]),
  _s('syn.obl.subordinatae', 'Subordinātae in ōrātiōne oblīquā', 'Mettre au subjonctif les subordonnées du discours rapporté (dīxit sē venīre quia aeger esset).', not: ['not.modus.subj'], parens: 'syn.obl', ag: ['§580', '§583'], req: ['syn.obl.enuntiativa', 'syn.sub.consecutio'],
      conf: [_c('syn.sub.causalis', Modus.functio, 'quia esset (rapporté) / quia erat (assumé)')]),
  _s('syn.obl.tempora', 'Tempora relātīva in ōrātiōne oblīquā', 'Lire les temps par rapport au verbe de parole, non par rapport au présent du lecteur (dīxit eum venīre : venait).', not: [], parens: 'syn.obl', ag: ['§584–585'], req: ['syn.obl.enuntiativa', 'syn.sub.consecutio'],
      conf: [_c('syn.inf.aci.tempus.praes', Modus.functio, 'venīre après dīxit = venait')]),

  // =====================================================================
  // Constructions impersonnelles
  // =====================================================================
  _s('syn.impers.verba', 'Licet, oportet, decet, libet', 'Lire les impersonnels avec datif + infinitif (mihi licet īre) ou infinitive (oportet tē īre) ; pas de sujet « il ».', not: ['not.persona.3'], parens: 'syn.impers', ag: ['§207', '§454–455'], req: ['v.kind.impers', 'syn.inf.subiectum'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.dat.attributio', Modus.functio, 'mihi licet : datif de la personne'), _c('syn.inf.aci', Modus.functio, 'oportet tē īre : infinitive')]),
  _s('syn.impers.interest', 'Interest, rēfert', 'Lire interest / rēfert avec génitif de la personne ou meā, tuā, nostrā (meā interest).', not: [], parens: 'syn.impers', ag: ['§355'], req: ['syn.impers.verba', 'syn.gen.possessivus']),
  _s('syn.impers.natura', 'Verba nātūrae: pluit, ningit, tonat', 'Lire pluit, ningit, tonat, lūcēscit sans sujet.', not: [], parens: 'syn.impers', ag: ['§208 a'], req: ['v.kind.impers']),
  _s('syn.impers.passivum', 'Passīvum impersōnāle', 'Lire le passif impersonnel d\'un intransitif (pugnātur : on combat ; mihi persuādētur ; ventum est).', not: ['not.vox.pass'], parens: 'syn.impers', ag: ['§208 d', '§372'], req: ['v.kind.impers.pass', 'syn.dat.verba'],
      conf: [_c('syn.abl.agens', Modus.functio, 'ā mīlitibus pugnātur : agent d\'un impersonnel'), _c('syn.nom.subiectum', Modus.functio, 'pugnātur n\'a pas de sujet')]),

  // =====================================================================
  // Régime des verbes
  // =====================================================================
  _s('syn.regimen.deponentia', 'Dēpōnentia in sententiā', 'Employer un déponent avec son sens actif et son objet (medicus amīcum sequitur : le médecin suit l\'ami).', not: ['not.vox.dep'], parens: 'syn.regimen', ag: ['§190'], req: ['v.kind.dep', 'syn.acc.obiectum'], prob: [Dimensio.sensus, Dimensio.productio, Dimensio.voxSensus],
      conf: [_c('syn.abl.agens', Modus.functio, 'amīcum sequitur / ab amīcō sequitur (impossible)'), _c('v.des.pass.3.sg.tur', Modus.analogia, '*sequit : forme active inexistante')]),
  _s('syn.regimen.semideponentia', 'Sēmidēpōnentia in sententiā', 'Employer audeō, gaudeō, soleō au parfait déponent (ausus est venīre).', not: ['not.vox.dep'], parens: 'syn.regimen', ag: ['§192'], req: ['v.kind.semidep', 'syn.regimen.deponentia']),
  _s('syn.regimen.defectiva', 'Dēfectīva in sententiā', 'Employer ōdī, meminī, nōvī au parfait avec sens présent (meminī tē : je me souviens de toi) et au plus-que-parfait avec sens passé.', not: [], parens: 'syn.regimen', ag: ['§205'], req: ['v.kind.def', 'syn.tempora.perfectum.praesens'], prob: [Dimensio.sensus, Dimensio.productio, Dimensio.tempusSensus]),
  _s('syn.regimen.casus', 'Verba cum genetīvō, datīvō, ablātīvō', 'Choisir le cas demandé par le verbe : meminī + gén., pāreō + dat., ūtor + abl., doceō + deux acc.', not: [], parens: 'syn.regimen', ag: ['§349', '§367', '§410'], req: ['syn.gen.memoriae', 'syn.dat.verba', 'syn.abl.deponentia', 'syn.acc.duplex'], prob: [Dimensio.constructio, Dimensio.productio, Dimensio.sensus]),
  _s('syn.regimen.praepositiva', 'Verba composita cum praepositiōne repetītā', 'Reconnaître le composé qui répète sa préposition (ad urbem accēdit ; ex urbe exit).', not: [], parens: 'syn.regimen', ag: ['§370 b'], req: ['v.kind.comp', 'syn.acc.praep']),

  // =====================================================================
  // Pronoms dans la phrase
  // =====================================================================
  _s('syn.pron.is.anaphora', 'Is, ea, id: anaphora', 'Retrouver le référent de is, ea, id par le genre et le nombre (puerī adsunt ; magister eōs vocat).', not: [], parens: 'syn.pron', ag: ['§297'], req: ['pron.is'], prob: [Dimensio.relatio, Dimensio.sensus, Dimensio.productio],
      conf: [_c('pron.se', Modus.functio, 'eum / sē'), _c('syn.pron.hic_ille', Modus.functio, 'eum / hunc, illum')]),
  _s('syn.pron.hic_ille', 'Hic, ille, iste: dēmōnstrātiō', 'Choisir hic (proche du locuteur, ce … -ci), ille (éloigné, célèbre), iste (de l\'interlocuteur) ; hic … ille (le second … le premier).', not: [], parens: 'syn.pron', ag: ['§297'], req: ['pron.hic', 'pron.ille', 'pron.iste'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.pron.is.anaphora', Modus.functio, 'hic / is')]),
  _s('syn.pron.reflexivum', 'Sē, suus: reflexīvum', 'Lire sē et suus comme renvoyant au sujet de la proposition (ou du verbe principal dans une infinitive) ; eius, eum pour un autre.', not: [], parens: 'syn.pron', ag: ['§299–301'], req: ['pron.se', 'pron.suus_eius'], prob: [Dimensio.relatio, Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.pron.is.anaphora', Modus.functio, 'suum / eius')]),
  _s('syn.pron.ipse_idem', 'Ipse et īdem in sententiā', 'Lire ipse (lui-même, en personne, précisément) et īdem (le même, aussi).', not: [], parens: 'syn.pron', ag: ['§298'], req: ['pron.ipse', 'pron.idem'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('syn.pron.reflexivum', Modus.functio, 'ipse / sē')]),
  _s('syn.pron.indefinita', 'Indēfīnīta in sententiā', 'Lire aliquis (quelqu\'un), quīdam (un certain), quisque (chacun), quisquam (personne, avec négation), nēmō, nihil dans une phrase.', not: [], parens: 'syn.pron', ag: ['§310–315'], req: ['pron.indef', 'pron.indef.quisque', 'pron.indef.nemo'], prob: [Dimensio.sensus, Dimensio.productio],
      conf: [_c('pron.indef.si_ne', Modus.functio, 'sī quis = sī aliquis')]),
  _s('syn.pron.quisque.superlativus', 'Quisque cum superlātīvō et ōrdināle', 'Lire optimus quisque (tous les meilleurs), decimus quisque (un sur dix), suum cuique.', not: [], parens: 'syn.pron', ag: ['§313 b'], req: ['syn.pron.indefinita', 'syn.comp.superlativus']),
  _s('syn.pron.interrogativa', 'Quis, quid, quī in sententiā', 'Lire quis (qui ?), quid (quoi ?), quī vir (quel homme ?) et les distinguer du relatif par le contexte.', not: [], parens: 'syn.pron', ag: ['§333'], req: ['pron.quis_qui', 'syn.interrog.verba'], prob: [Dimensio.sensus, Dimensio.productio]),
  _s('syn.pron.alius_alter', 'Alius, alter, cēterī, reliquī', 'Lire alter (l\'autre de deux), alius (un autre), aliī … aliī (les uns … les autres), cēterī (tous les autres).', not: [], parens: 'syn.pron', ag: ['§315'], req: ['adj.classis.pron']),

  // =====================================================================
  // Numéraux dans la phrase
  // =====================================================================
  _s('syn.numeri.card', 'Quot? Cardinālia in sententiā', 'Lire et produire le nombre d\'objets (ūnam gallīnam videt ; tribus puerīs dat).', not: [], parens: 'syn.numeri', ag: ['§134'], req: ['num.unus', 'num.duo', 'num.tres', 'num.card.indecl'], prob: [Dimensio.sensus, Dimensio.productio, Dimensio.valor],
      conf: [_c('syn.numeri.ord', Modus.functio, 'ūnam (une) / prīmam (la première)'), _c('syn.numeri.distr', Modus.functio, 'duās (deux) / bīnās (deux chacun)'), _c('syn.numeri.adv', Modus.functio, 'ūnam (une) / semel (une fois)')]),
  _s('syn.numeri.ord', 'Quō ōrdine? Ōrdinālia in sententiā', 'Lire et produire le rang (prīmam gallīnam videt ; tertiō diē).', not: [], parens: 'syn.numeri', ag: ['§134'], req: ['num.ord'], prob: [Dimensio.sensus, Dimensio.productio, Dimensio.valor],
      conf: [_c('syn.numeri.card', Modus.functio, 'prīmam / ūnam'), _c('syn.abl.tempus', Modus.functio, 'tertiō diē (le troisième jour) / trēs diēs (trois jours)')]),
  _s('syn.numeri.distr', 'Quot singulī? Distribūtīva in sententiā', 'Lire et produire la répartition (bīnās gallīnās habent : deux chacun) et le pluriel des pluralia tantum (bīnae litterae).', not: [], parens: 'syn.numeri', ag: ['§136–137'], req: ['num.distr'], prob: [Dimensio.sensus, Dimensio.productio, Dimensio.valor],
      conf: [_c('syn.numeri.card', Modus.functio, 'bīnās / duās')]),
  _s('syn.numeri.adv', 'Quotiēns? Adverbia numerālia in sententiā', 'Lire et produire la fréquence (semel, bis, ter videt).', not: [], parens: 'syn.numeri', ag: ['§138'], req: ['num.adv'], prob: [Dimensio.sensus, Dimensio.productio, Dimensio.valor],
      conf: [_c('syn.numeri.card', Modus.functio, 'bis / duo'), _c('syn.numeri.distr', Modus.functio, 'bis / bīnī')]),
  _s('syn.numeri.mille', 'Mīlle et mīlia in sententiā', 'Produire mīlle mīlitēs (adjectif) et duo mīlia mīlitum (nom + génitif).', not: [], parens: 'syn.numeri', ag: ['§134 d'], req: ['num.mille', 'syn.gen.quantitatis'], prob: [Dimensio.sensus, Dimensio.productio]),
];
