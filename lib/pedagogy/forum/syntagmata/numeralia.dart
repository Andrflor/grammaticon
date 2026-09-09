/// Contextual items — section "numeralia". Authored by hand; see syntagma.dart for
/// the markers (`{target}`, `[head]`, `<candidate>`).
library;

import '../../../linguistics/model/grammar.dart';
import '../../../linguistics/model/nominal.dart';
import '../syntagma.dart';

// ignore_for_file: unused_import

const List<Syntagma> kNumeraliaSyntagmata = [
  // ---------------------------------------------------------------- num-mille
  // Mīlle: indeclinable adjective, the noun keeps the case of the sentence.
  Syntagma(id: 'num-mille-001', text: 'mīlle {mīlitēs} veniunt', lemmaId: 'miles', casus: Casus.nominativus, number: Numerus.pluralis, constructio: Constructio.milleAdiectivum, tags: {'num-mille'}, note: 'Mīlle adiectīvum indēclīnābile est: mīlitēs subiectum, nōminātīvus plūrālis.'),
  Syntagma(id: 'num-mille-002', text: 'dux mīlle {mīlitēs} videt', lemmaId: 'miles', casus: Casus.accusativus, number: Numerus.pluralis, constructio: Constructio.milleAdiectivum, tags: {'num-mille'}, note: 'Mīlle adiectīvum est: mīlitēs obiectum verbī videt, accūsātīvus plūrālis.'),
  Syntagma(id: 'num-mille-003', text: 'dux cum mīlle {mīlitibus} venit', lemmaId: 'miles', casus: Casus.ablativus, number: Numerus.pluralis, constructio: Constructio.milleAdiectivum, tags: {'num-mille'}, note: 'Mīlle adiectīvum est: mīlitibus ablātīvus quia cum praepositiō ablātīvum regit.'),
  Syntagma(id: 'num-mille-004', text: 'mīlle {nāvēs} in portū sunt', lemmaId: 'navis', casus: Casus.nominativus, number: Numerus.pluralis, constructio: Constructio.milleAdiectivum, tags: {'num-mille'}, note: 'Mīlle adiectīvum indēclīnābile: nāvēs subiectum, nōminātīvus plūrālis.'),
  Syntagma(id: 'num-mille-005', text: 'rēx mīlle {equitēs} habet', lemmaId: 'eques', casus: Casus.accusativus, number: Numerus.pluralis, constructio: Constructio.milleAdiectivum, tags: {'num-mille'}, note: 'Mīlle adiectīvum est: equitēs obiectum verbī habet, accūsātīvus plūrālis.'),
  Syntagma(id: 'num-mille-006', text: 'Iūlius mīlle {nummōs} habet', lemmaId: 'nummus', casus: Casus.accusativus, number: Numerus.pluralis, constructio: Constructio.milleAdiectivum, tags: {'num-mille'}, note: 'Mīlle adiectīvum est: nummōs obiectum verbī habet, accūsātīvus plūrālis.'),
  Syntagma(id: 'num-mille-007', text: 'dominus mīlle {servīs} cibum dat', lemmaId: 'servus', casus: Casus.dativus, number: Numerus.pluralis, constructio: Constructio.milleAdiectivum, tags: {'num-mille'}, note: 'Mīlle adiectīvum est: servīs datīvus, quibus cibus datur.'),
  Syntagma(id: 'num-mille-008', text: 'mīlle {annī} praetereunt', lemmaId: 'annus', casus: Casus.nominativus, number: Numerus.pluralis, constructio: Constructio.milleAdiectivum, tags: {'num-mille'}, note: 'Mīlle adiectīvum indēclīnābile: annī subiectum verbī praetereunt, nōminātīvus plūrālis.'),
  Syntagma(id: 'num-mille-009', text: 'in mīlle {nāvibus} mīlitēs veniunt', lemmaId: 'navis', casus: Casus.ablativus, number: Numerus.pluralis, constructio: Constructio.milleAdiectivum, tags: {'num-mille'}, note: 'Mīlle adiectīvum est: nāvibus ablātīvus quia in locum ubi ablātīvō significat.'),
  // Mīlia: plural neuter noun governing the genitive.
  Syntagma(id: 'num-mille-010', text: 'tria {mīlia} mīlitum veniunt', lemmaId: 'milia', casus: Casus.nominativus, number: Numerus.pluralis, gender: Gender.neutrum, constructio: Constructio.miliaGenetivus, tags: {'num-mille'}, note: 'Mīlia nōmen neutrum plūrāle est: subiectum verbī veniunt, nōminātīvus; mīlitum genetīvus.'),
  Syntagma(id: 'num-mille-011', text: 'tria mīlia {mīlitum} veniunt', lemmaId: 'miles', casus: Casus.genetivus, number: Numerus.pluralis, constructio: Constructio.miliaGenetivus, tags: {'num-mille'}, note: 'Mīlia nōmen est et genetīvum regit: mīlitum genetīvus plūrālis.'),
  Syntagma(id: 'num-mille-012', text: 'dux duo {mīlia} equitum videt', lemmaId: 'milia', casus: Casus.accusativus, number: Numerus.pluralis, gender: Gender.neutrum, constructio: Constructio.miliaGenetivus, tags: {'num-mille'}, note: 'Mīlia nōmen neutrum est: obiectum verbī videt, accūsātīvus plūrālis; equitum genetīvus.'),
  Syntagma(id: 'num-mille-013', text: 'dux cum duōbus {mīlibus} equitum venit', lemmaId: 'milia', casus: Casus.ablativus, number: Numerus.pluralis, gender: Gender.neutrum, constructio: Constructio.miliaGenetivus, tags: {'num-mille'}, note: 'Mīlibus ablātīvus plūrālis post cum; equitum genetīvus ā mīlibus regitur.'),
  Syntagma(id: 'num-mille-014', text: 'duo mīlia {equitum} in castrīs sunt', lemmaId: 'eques', casus: Casus.genetivus, number: Numerus.pluralis, constructio: Constructio.miliaGenetivus, tags: {'num-mille'}, note: 'Mīlia nōmen genetīvum regit: equitum genetīvus plūrālis.'),
  Syntagma(id: 'num-mille-015', text: 'rēx tria mīlia {nāvium} habet', lemmaId: 'navis', casus: Casus.genetivus, number: Numerus.pluralis, constructio: Constructio.miliaGenetivus, tags: {'num-mille'}, note: 'Mīlia nōmen est: nāvium genetīvus plūrālis ā mīlia regitur, nōn accūsātīvus.'),
  Syntagma(id: 'num-mille-016', text: 'tria mīlia {hominum} in urbe sunt', lemmaId: 'homo', casus: Casus.genetivus, number: Numerus.pluralis, constructio: Constructio.miliaGenetivus, tags: {'num-mille'}, note: 'Mīlia nōmen genetīvum regit: hominum genetīvus plūrālis.'),
  Syntagma(id: 'num-mille-017', text: 'Iūlius duo {mīlia} nummōrum habet', lemmaId: 'milia', casus: Casus.accusativus, number: Numerus.pluralis, gender: Gender.neutrum, constructio: Constructio.miliaGenetivus, tags: {'num-mille'}, note: 'Mīlia nōmen neutrum est: obiectum verbī habet, accūsātīvus plūrālis; nummōrum genetīvus.'),
  Syntagma(id: 'num-mille-018', text: 'duo mīlia {cīvium} in forō sunt', lemmaId: 'civis', casus: Casus.genetivus, number: Numerus.pluralis, constructio: Constructio.miliaGenetivus, tags: {'num-mille'}, note: 'Mīlia nōmen genetīvum regit: cīvium genetīvus plūrālis.'),
  Syntagma(id: 'num-mille-019', text: 'dux trium {mīlium} mīlitum venit', lemmaId: 'milia', casus: Casus.genetivus, number: Numerus.pluralis, gender: Gender.neutrum, constructio: Constructio.miliaGenetivus, tags: {'num-mille'}, note: 'Mīlium genetīvus plūrālis nōminis mīlia, ā dux pendēns; mīlitum genetīvus ā mīlium regitur.'),
  Syntagma(id: 'num-mille-020', text: 'tribus {mīlibus} mīlitum cibum dat', lemmaId: 'milia', casus: Casus.dativus, number: Numerus.pluralis, gender: Gender.neutrum, constructio: Constructio.miliaGenetivus, tags: {'num-mille'}, note: 'Mīlibus datīvus plūrālis, quibus cibus datur; mīlitum genetīvus ā mīlibus regitur.'),
];
