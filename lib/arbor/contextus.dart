/// L5 — compétences en contexte : comprendre (Theātrum) et rendre (Templum)
/// chaque concept dans une phrase.
///
/// Reconnaître ou produire une forme sur demande morphologique (Amphitheātrum,
/// Forum) n'est pas la compétence qui consiste à comprendre cette forme dans
/// une phrase latine (versiō), ni celle qui consiste à la produire pour rendre
/// une phrase française (thema). Chaque carte du Theātrum a donc son nœud
/// `lect.intellectus.<section>.<carte>`, chaque carte du Templum son nœud
/// `lect.thema.<section>.<carte>`.
///
/// Ordre pédagogique : **l'exposition d'abord**. On rencontre un fait de langue
/// dans une phrase (version), on le produit (thème), puis on en travaille la
/// morphologie et la grammaire à l'Amphitheātrum et au Forum. Les arêtes vont
/// donc du contexte vers la grammaire : l'intellectus n'exige que la chaîne des
/// cartes (carte requise, section précédente), le thema exige l'intellectus du
/// même concept, et chaque maillon de grammaire qu'une carte introduit exige
/// le thema de la première carte du catalogue qui le met en jeu
/// ([exposureEdges]). Une erreur au Theātrum débite le nœud de contexte et
/// rend suspecte la carte d'avant ; une erreur de forme au Templum rend
/// suspect le maillon de grammaire (`Diagnosis.suspecta`), que l'Amphitheātrum
/// ou le Forum vérifiera ensuite.
library;

import '../pedagogy/frames/frame_cards.dart';
import '../pedagogy/frames/frame_catalogue.dart';
import 'skill.dart';

const _intellectus = 'lect.intellectus';
const _thema = 'lect.thema';

String _seg(String s) => s.replaceAll('-', '_');

/// Section du Templum qui traite le concept d'une section du Theātrum.
final Map<String, String> _templumSection = {for (final e in templumAlias.entries) e.value: e.key};

/// Nœud de contexte d'une carte (adresse `place/section/card`).
String contextNodeId(String cardAddress) {
  final p = cardAddress.split('/');
  final section = templumAlias[p[1]] ?? p[1];
  return '${p[0] == 'templum' ? _thema : _intellectus}.${_seg(section)}.${_seg(p[2])}';
}

/// Maillons de grammaire (morphologie, syntaxe) qu'une carte met en jeu.
List<String> contextBaseNodes(String cardAddress) {
  final p = cardAddress.split('/');
  final section = templumAlias[p[1]] ?? p[1];
  if (p[2] == 'vocabula') return const [];
  return kFrameCardNodes['$section/${p[2]}'] ?? const [];
}

final List<Skill> kContextusGroups = [
  Skill(_intellectus, nomen: 'Intellēctus in sententiā', quid: 'Comprendre un fait de langue dans une phrase latine (Theātrum).', stratum: Stratum.lectio, parens: 'lect', probatur: const []),
  Skill(_thema, nomen: 'Thema Latīnum', quid: 'Rendre en latin un fait de langue depuis le français (Templum).', stratum: Stratum.lectio, parens: 'lect', probatur: const []),
];

/// Prérequis de section : la progression du jeu enchaîne les sections dans
/// l'ordre du catalogue. Les cartes racines d'une section (sans `requires`)
/// exigent le vocabulaire de la section précédente, dont la carte demande
/// toutes les autres — « finir une section avant d'ouvrir la suivante ».
/// Comprendre un subjonctif d'exhortation dans une phrase suppose de savoir
/// lire la phrase : cas, accord, sujet et objet, appris dans les premières.
Map<String, String> _sectionGates(List<FrameSectionMeta> sections, List<FrameCardMeta> cards, String place) {
  final out = <String, String>{};
  for (var i = 1; i < sections.length; i++) {
    final prev = sections[i - 1], cur = sections[i];
    final gate = contextNodeId('$place/${prev.id}/vocabula');
    for (final c in cards.where((c) => c.section == cur.id &&
        (c.card == cur.cards.first || c.requires.isEmpty || c.requires.every((r) => !r.startsWith('$place/${cur.id}/'))))) {
      out[c.id] = gate;
    }
  }
  return out;
}

/// Les nœuds de contexte de toutes les cartes du Theātrum et du Templum.
List<Skill> contextusNodes() {
  final out = <Skill>[];
  final templumNames = {for (final c in kTemplumCards) '${c.section}/${c.card}': c.name};
  final gates = {..._sectionGates(kTheatrumSections, kTheatrumCards, 'theatrum'), ..._sectionGates(kTemplumSections, kTemplumCards, 'templum')};
  final templumById = {for (final c in kTemplumCards) c.id: c};
  for (final c in kTheatrumCards) {
    final key = '${c.section}/${c.card}';
    final base = c.card == 'vocabula' ? const <String>[] : (kFrameCardNodes[key] ?? const <String>[]);
    final intellectus = contextNodeId(c.id);
    final templumCardId = 'templum/${_templumSection[c.section] ?? c.section}/${c.card}';
    final thema = contextNodeId(templumCardId);
    final themaName = templumNames['${_templumSection[c.section] ?? c.section}/${c.card}'] ?? c.name;
    // La chaîne de la section : la carte requise par la carte (ordre du jeu),
    // puis la porte de section pour les racines.
    List<String> chain(FrameCardMeta? meta, String id) => [
      if (meta != null) ...meta.requires.map(contextNodeId),
      if (gates[id] != null) gates[id]!,
    ];
    final intellectusChain = chain(c, c.id);
    if (gates[c.id] != null) {
      // Une nouvelle section commence après le vocabulaire de la précédente
      // en version ET en thème, même si sa première carte a déjà un `requires`.
      intellectusChain.add(gates[c.id]!.replaceFirst('lect.intellectus.', 'lect.thema.'));
    }
    final themaChain = chain(templumById[templumCardId], templumCardId);
    if (c.card == 'vocabula') {
      out.add(Skill(intellectus, nomen: '${c.name} · Gallicē', quid: 'Donner le sens français du vocabulaire de la section « ${c.section} ».', stratum: Stratum.lectio, parens: _intellectus, requirit: intellectusChain, probatur: const [Dimensio.vocabulum]));
      out.add(Skill(thema, nomen: '$themaName · Latīnē', quid: 'Donner le mot latin du vocabulaire de la section « ${c.section} ».', stratum: Stratum.lectio, parens: _thema, requirit: [intellectus, ...themaChain], probatur: const [Dimensio.vocabulum]));
      continue;
    }
    // Les maillons de grammaire (`base`) ne sont pas des prérequis : ils sont
    // exposés ici et travaillés ensuite ; ils restent liés comme exemples.
    out.add(Skill(intellectus, nomen: c.name, quid: 'Comprendre dans une phrase latine ce que met en jeu la carte « ${c.name} » (${c.section}).', stratum: Stratum.lectio, parens: _intellectus, requirit: intellectusChain, exempla: base, probatur: const [Dimensio.sensus]));
    out.add(Skill(thema, nomen: themaName, quid: 'Rendre en latin, depuis le français, ce que met en jeu la carte « $themaName » (${_templumSection[c.section] ?? c.section}).', stratum: Stratum.lectio, parens: _thema, requirit: [intellectus, ...themaChain], exempla: base, probatur: const [Dimensio.productio]));
  }
  return out;
}

/// Maillon de grammaire → thema de la première carte du catalogue (ordre des
/// sections, puis des cartes dans la section) qui le met en jeu. C'est l'arête
/// « exposition avant morphologie » : la désinence -um se travaille au Forum
/// après avoir été lue et produite dans les phrases qui l'introduisent.
Map<String, String> exposureEdges() {
  final out = <String, String>{};
  for (final s in kTheatrumSections) {
    for (final card in s.cards) {
      if (card == 'vocabula') continue;
      final id = 'theatrum/${s.id}/$card';
      final thema = contextNodeId('templum/${_templumSection[s.id] ?? s.id}/$card');
      for (final n in contextBaseNodes(id)) {
        out.putIfAbsent(n, () => thema);
      }
    }
  }
  return out;
}

/// Découvertes des grandes notions morphologiques. Ces liens pédagogiques
/// sont inscrits dans le graphe : une forme au parfait ne doit pas servir à
/// apprendre le présent avant la découverte du passé en version et en thème.
/// Les notions sans découverte déclarée restent signalables comme lacunes.
const Map<String, String?> kNotionDiscoveries = {
  'not.declinatio.1': 'loca/a-ablative',
  'not.declinatio.2': 'loca/a-ablative',
  'not.declinatio.3': 'nomina/third-subject-object',
  // Pas encore de découverte dédiée dans les banques de contexte : une
  // absence de cours ne doit pas autoriser ces formes au début de l'Iter.
  'not.declinatio.4': null,
  'not.declinatio.5': null,
  'not.classis.12': 'loca/concordia',
  'not.numerus.sg': 'loca/a-ablative',
  'not.numerus.pl': 'loca/numerus',
  'not.persona.1': 'personae/reference',
  'not.persona.2': 'personae/reference',
  'not.persona.3': 'loca/negatio',
  'not.coniugatio.1': 'loca/negatio',
  'not.coniugatio.2': 'loca/negatio',
  'not.coniugatio.3': 'loca/negatio',
  'not.coniugatio.3io': 'loca/negatio',
  'not.coniugatio.4': 'loca/negatio',
  'not.tempus.praes': 'loca/negatio',
  'not.tempus.systema.praes': 'loca/negatio',
  'not.tempus.imperf': 'tempora/05-narrative',
  'not.tempus.perf': 'tempora/05-narrative',
  'not.tempus.systema.perf': 'tempora/05-narrative',
  'not.tempus.fut': 'tempora/04-time',
  'not.tempus.plusq': 'tempora/pluperfect-anteriority',
  'not.modus.subj': 'sententiae/07-purpose',
  'not.modus.imp': 'sermo/singular-command',
  'not.modus.inf': 'orationes/infinitive-subject',
  'not.forma.inf': 'orationes/infinitive-subject',
  'not.forma.part': 'formae-non-finitae/1',
  'not.forma.ger': 'gerundium/gerund-ad',
  'not.forma.gdv': 'formae-non-finitae/2',
  'not.forma.sup': 'formae-non-finitae/6',
  'not.vox.pass': 'actiones/passive-patient',
  'not.vox.dep': 'verbis-intellegendis/1',
  'not.gradus.comp': 'res-comparatae/1',
  'not.gradus.sup': 'res-comparatae/2',
};

String discoveryThema(String concept) {
  final slash = concept.indexOf('/');
  final section = concept.substring(0, slash);
  return contextNodeId('templum/${_templumSection[section] ?? section}/${concept.substring(slash + 1)}');
}

/// Les cas sont vérifiés sur la lecture précise d'une forme. Une désinence
/// syncrétique peut réaliser plusieurs cas sans imposer de les découvrir tous
/// avant de rencontrer sa première lecture.
const Map<String, String> kCaseDiscoveries = {
  'not.casus.nom': 'loca/a-ablative',
  'not.casus.abl': 'loca/a-ablative',
  'not.casus.acc': 'personae/agents',
  'not.casus.gen': 'personae/possession',
  'not.casus.dat': 'personae/giving',
  'not.casus.voc': 'sermo/vocative',
  'not.casus.loc': 'itinera/town-location',
};
