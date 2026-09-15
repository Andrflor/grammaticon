/// L5 — compétences en contexte : comprendre (Theātrum) et rendre (Templum)
/// chaque concept dans une phrase.
///
/// Reconnaître ou produire une forme sur demande morphologique (Amphitheātrum,
/// Forum) n'est pas la compétence qui consiste à comprendre cette forme dans
/// une phrase latine (versiō), ni celle qui consiste à la produire pour rendre
/// une phrase française (thema). Chaque carte du Theātrum a donc son nœud
/// `lect.intellectus.<section>.<carte>`, chaque carte du Templum son nœud
/// `lect.thema.<section>.<carte>` ; leurs prérequis sont les maillons
/// morphologiques et syntaxiques que la carte met en jeu, et le thema exige
/// l'intellectus du même concept (comprendre avant de produire). Une erreur au
/// Theātrum débite le nœud de contexte et rend suspects ses prérequis directs :
/// c'est le Forum ou l'Amphitheātrum qui tranchera.
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

/// Les nœuds de contexte de toutes les cartes du Theātrum et du Templum.
List<Skill> contextusNodes() {
  final out = <Skill>[];
  final templumNames = {for (final c in kTemplumCards) '${c.section}/${c.card}': c.name};
  for (final c in kTheatrumCards) {
    final key = '${c.section}/${c.card}';
    final base = c.card == 'vocabula' ? const <String>[] : (kFrameCardNodes[key] ?? const <String>[]);
    final intellectus = contextNodeId(c.id);
    final thema = contextNodeId('templum/${_templumSection[c.section] ?? c.section}/${c.card}');
    final themaName = templumNames['${_templumSection[c.section] ?? c.section}/${c.card}'] ?? c.name;
    if (c.card == 'vocabula') {
      out.add(Skill(intellectus, nomen: '${c.name} · Gallicē', quid: 'Donner le sens français du vocabulaire de la section « ${c.section} ».', stratum: Stratum.lectio, parens: _intellectus, requirit: const ['lect.vocabula.gallice'], probatur: const [Dimensio.vocabulum]));
      out.add(Skill(thema, nomen: '$themaName · Latīnē', quid: 'Donner le mot latin du vocabulaire de la section « ${c.section} ».', stratum: Stratum.lectio, parens: _thema, requirit: ['lect.vocabula.latine', intellectus], probatur: const [Dimensio.vocabulum]));
      continue;
    }
    out.add(Skill(intellectus, nomen: c.name, quid: 'Comprendre dans une phrase latine ce que met en jeu la carte « ${c.name} » (${c.section}).', stratum: Stratum.lectio, parens: _intellectus, requirit: base, probatur: const [Dimensio.sensus]));
    out.add(Skill(thema, nomen: themaName, quid: 'Rendre en latin, depuis le français, ce que met en jeu la carte « $themaName » (${_templumSection[c.section] ?? c.section}).', stratum: Stratum.lectio, parens: _thema, requirit: [...base, intellectus], probatur: const [Dimensio.productio]));
  }
  return out;
}
