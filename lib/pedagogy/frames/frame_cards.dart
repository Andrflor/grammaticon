/// Cartes du Theatrum et du Templum → nœuds de l'arbre visés.
///
/// La table est écrite par section du Theatrum ; les sections du Templum qui
/// traitent le même concept en production y sont ramenées par [templumAlias].
/// Un cadre appartient à une carte ; ses distracteurs mettent en cause le nœud
/// de la carte (diagnostic de niveau carte) et, quand les choix sont des formes
/// latines analysables, la différence morphologique s'y ajoute.
library;

import '../../arbor/contextus.dart';

const Map<String, String> templumAlias = {
  'casuum-electio': 'casuum-sensus',
  'sententiae-subordinatae': 'nexus-sententiarum',
  'gradus-adiectivorum': 'res-comparatae',
  'pronomina-eligenda': 'referentiae-pronominum',
  'numeris-exprimere': 'numerorum-sensus',
  'condiciones-componendae': 'condiciones-interpretandae',
  'voluntatem-exprimere': 'voluntas-et-consilium',
  'formis-non-finitis': 'formae-non-finitae',
  'orationem-referre': 'oratio-obliqua',
  'verbis-utendis': 'verbis-intellegendis',
};

const Map<String, List<String>> kFrameCardNodes = {
  // Locī et rēs
  'loca/a-ablative': ['syn.abl.locus', 'syn.praep.in.duplex', 'n.des.a_long'],
  'loca/concordia': ['syn.concordia.adiectivum'],
  'loca/negatio': ['syn.neg.non'],
  'loca/numerus': ['syn.concordia.verbum', 'n.des.ae'],
  // Persōnae
  'personae/agents': ['syn.nom.subiectum', 'syn.acc.obiectum'],
  'personae/giving': ['syn.dat.attributio'],
  'personae/possession': ['syn.gen.possessivus'],
  'personae/reference': ['syn.pron.reflexivum', 'pron.suus_eius'],
  'personae/relative-case-role': ['syn.concordia.relativum', 'syn.rel.indicativus'],
  // Nōmina (3e déclinaison)
  'nomina/third-subject-object': ['syn.nom.subiectum', 'syn.acc.obiectum', 'n.thema.d3.cons'],
  'nomina/third-genitive': ['syn.gen.possessivus', 'n.des.is'],
  'nomina/third-dative': ['syn.dat.attributio', 'n.des.i_long'],
  'nomina/third-ablative': ['syn.abl.comitatus', 'n.des.e'],
  // Dēmōnstrātīva
  'demonstratives/demonstrative-accusative': ['pron.hic', 'syn.acc.obiectum'],
  'demonstratives/demonstrative-dative': ['pron.des.i', 'pron.hic', 'pron.ille', 'syn.dat.attributio'],
  'demonstratives/demonstrative-gender': ['pron.hic', 'syn.concordia.adiectivum'],
  'demonstratives/demonstrative-genitive': ['pron.des.ius', 'pron.hic', 'pron.ille', 'syn.gen.possessivus'],
  // Interrogātiōnēs
  'interrogationes/cur-quia': ['syn.interrog.cur_quia'],
  'interrogationes/neutral-question': ['syn.interrog.ne'],
  'interrogationes/nonne-question': ['syn.interrog.nonne'],
  'interrogationes/num-question': ['syn.interrog.num'],
  // Sermō et imperia
  'sermo/eum-eam': ['syn.pron.is.anaphora', 'pron.is'],
  'sermo/eos-eas': ['syn.pron.is.anaphora', 'pron.is'],
  'sermo/singular-command': ['syn.voluntas.imperativus', 'v.des.imp.2.sg'],
  'sermo/plural-command': ['syn.voluntas.imperativus', 'v.des.imp.2.pl.te'],
  'sermo/vocative': ['syn.voc.appellatio'],
  // Agentēs et patientēs
  'actiones/passive-patient': ['syn.nom.subiectum', 'v.des.pass.3.sg.tur'],
  'actiones/passive-number': ['v.des.pass.3.sg.tur', 'v.des.pass.3.pl.ntur', 'syn.concordia.verbum'],
  'actiones/passive-agent': ['syn.abl.agens'],
  'actiones/instrument-agent': ['syn.abl.instrumentum', 'syn.abl.agens'],
  // Itinera
  'itinera/in-place-motion': ['syn.praep.in.duplex', 'syn.locus.triplex'],
  'itinera/town-destination': ['syn.acc.directio', 'n.thema.proprium'],
  'itinera/town-location': ['syn.locus.locativus'],
  'itinera/town-origin': ['syn.abl.separatio', 'n.thema.proprium'],
  // Tempora et nārrātiō
  'tempora/04-time': ['syn.tempora.praes_fut', 'v.sig.fut.b'],
  'tempora/05-narrative': ['syn.tempora.imperf_perf'],
  'tempora/future-third-fourth': ['syn.tempora.praes_fut', 'v.sig.fut.a_e'],
  'tempora/pluperfect-anteriority': ['syn.tempora.plusq'],
  // Ōrātiōnēs (infinitives)
  'orationes/infinitive-subject': ['syn.inf.aci'],
  'orationes/infinitive-anteriority': ['syn.inf.aci.tempus.perf'],
  'orationes/infinitive-posteriority': ['syn.inf.aci.tempus.fut'],
  'orationes/past-posteriority': ['syn.inf.aci.tempus.fut', 'syn.obl.tempora'],
  // Sententiae coniūnctae
  'sententiae/07-purpose': ['syn.sub.finalis'],
  'sententiae/08-circumstances': ['syn.abl.absolutus.praes'],
  'sententiae/absolute-perfect': ['syn.abl.absolutus.perf'],
  'sententiae/purpose-past': ['syn.sub.finalis', 'syn.sub.consecutio'],
  'sententiae/10-sacred': ['syn.sub.finalis', 'syn.sub.causalis'],
  // Gerundium
  'gerundium/gerund-ad': ['syn.part.gerundium.ad'],
  'gerundium/gerund-causa': ['syn.part.gerundium.causa'],
  'gerundium/gerund-desire': ['syn.part.gerundium.gen'],
  'gerundium/gerund-means': ['syn.part.gerundium.abl'],
  // Cāsūs (13)
  'casuum-sensus/1': ['syn.gen.partitivus'],
  'casuum-sensus/2': ['syn.gen.pretii', 'syn.abl.pretii'],
  'casuum-sensus/3': ['syn.gen.qualitatis'],
  'casuum-sensus/4': ['syn.dat.possessoris'],
  'casuum-sensus/5': ['syn.dat.finalis'],
  'casuum-sensus/6': ['syn.dat.duplex'],
  'casuum-sensus/7': ['syn.acc.spatium'],
  'casuum-sensus/8': ['syn.acc.tempus'],
  'casuum-sensus/9': ['syn.acc.duplex'],
  'casuum-sensus/10': ['syn.abl.comparationis'],
  'casuum-sensus/11': ['syn.abl.qualitatis'],
  'casuum-sensus/12': ['syn.abl.causae'],
  'casuum-sensus/13': ['syn.abl.mensura'],
  // Subordonnées (12)
  'nexus-sententiarum/1': ['syn.sub.consecutio'],
  'nexus-sententiarum/2': ['syn.sub.interrogativa'],
  'nexus-sententiarum/3': ['syn.sub.consecutiva'],
  'nexus-sententiarum/4': ['syn.sub.concessiva'],
  'nexus-sententiarum/5': ['syn.sub.dum'],
  'nexus-sententiarum/6': ['syn.sub.cum.historicum'],
  'nexus-sententiarum/7': ['syn.sub.causalis'],
  'nexus-sententiarum/8': ['syn.rel.finalis'],
  'nexus-sententiarum/9': ['syn.rel.characteristica'],
  'nexus-sententiarum/10': ['syn.sub.timendi'],
  'nexus-sententiarum/11': ['syn.sub.impediendi'],
  'nexus-sententiarum/12': ['syn.sub.quin'],
  // Comparaison
  'res-comparatae/1': ['syn.comp.quam'],
  'res-comparatae/2': ['syn.comp.superlativus'],
  'res-comparatae/3': ['adj.gradus.irr', 'syn.comp.quam'],
  'res-comparatae/4': ['syn.comp.adverbia'],
  // Pronoms
  'referentiae-pronominum/1': ['syn.pron.indefinita'],
  'referentiae-pronominum/2': ['syn.pron.interrogativa'],
  'referentiae-pronominum/3': ['syn.rel.indefinita'],
  'referentiae-pronominum/4': ['syn.pron.ipse_idem'],
  // Numéraux
  'numerorum-sensus/1': ['syn.numeri.card'],
  'numerorum-sensus/2': ['syn.numeri.ord'],
  'numerorum-sensus/3': ['syn.numeri.distr'],
  'numerorum-sensus/4': ['syn.numeri.adv'],
  // Conditionnelles
  'condiciones-interpretandae/1': ['syn.cond.realis'],
  'condiciones-interpretandae/2': ['syn.cond.potentialis'],
  'condiciones-interpretandae/3': ['syn.cond.irrealis.praes', 'syn.cond.irrealis.praet'],
  'condiciones-interpretandae/4': ['syn.cond.mixta'],
  // Volonté
  'voluntas-et-consilium/1': ['syn.voluntas.hortativus'],
  'voluntas-et-consilium/2': ['syn.voluntas.optativus'],
  'voluntas-et-consilium/3': ['syn.voluntas.potentialis'],
  'voluntas-et-consilium/4': ['syn.voluntas.deliberativus'],
  'voluntas-et-consilium/5': ['syn.voluntas.prohibitio'],
  // Formes non finies
  'formae-non-finitae/1': ['syn.part.coniunctum'],
  'formae-non-finitae/2': ['syn.part.gerundivum'],
  'formae-non-finitae/3': ['syn.part.gerundivum.attractio'],
  'formae-non-finitae/4': ['syn.part.periphrastica.act'],
  'formae-non-finitae/5': ['syn.part.gerundivum', 'syn.dat.agentis'],
  'formae-non-finitae/6': ['syn.part.supinum.um'],
  'formae-non-finitae/7': ['syn.part.supinum.u'],
  // Discours indirect
  'oratio-obliqua/1': ['syn.obl.enuntiativa'],
  'oratio-obliqua/2': ['syn.nom.nci'],
  'oratio-obliqua/3': ['syn.obl.imperativa'],
  'oratio-obliqua/4': ['syn.obl.interrogativa'],
  'oratio-obliqua/5': ['syn.obl.pronomina'],
  // Verbes
  'verbis-intellegendis/1': ['syn.regimen.deponentia'],
  'verbis-intellegendis/2': ['syn.regimen.semideponentia'],
  'verbis-intellegendis/3': ['syn.impers.verba'],
  'verbis-intellegendis/4': ['syn.regimen.defectiva'],
  'verbis-intellegendis/5': ['syn.impers.passivum'],
  'verbis-intellegendis/6': ['syn.regimen.casus'],
};

/// Nœud visé par une carte (adresse `place/section/card`) : sa compétence en
/// contexte, `lect.intellectus.*` au Theātrum, `lect.thema.*` au Templum. Les
/// maillons de grammaire de [kFrameCardNodes] en sont les prérequis, pas la
/// cible : comprendre ou rendre une construction dans une phrase n'est pas la
/// même compétence que la reconnaître sur demande morphologique.
List<String> frameCardNodes(String card) => [contextNodeId(card)];

/// Maillons de grammaire que la carte met en jeu (prérequis du nœud de contexte).
List<String> frameCardBaseNodes(String card) => contextBaseNodes(card);
