/// Contextual items — section "syncretismi" (second half: -us, -e, -ēs, -is,
/// -ibus, neuters, vowel quantity). See syntagma.dart for the markers.
library;

import '../../../linguistics/model/grammar.dart';
import '../../../linguistics/model/nominal.dart';
import '../syntagma.dart';

// ignore_for_file: unused_import

const List<Syntagma> kSyncretismiBSyntagmata = [
  // ── syn-us: -us / -ūs ────────────────────────────────────────────────────
  // nom. sg. 2nd
  Syntagma(id: 'syn-us-001', text: '{servus} in hortō labōrat', lemmaId: 'servus', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Servus subiectum verbī labōrat: nōminātīvus singulāris secundae dēclīnātiōnis.'),
  Syntagma(id: 'syn-us-002', text: '{dominus} servōs vocat', lemmaId: 'dominus', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Dominus vocat, servōs (accūsātīvum) vocat: dominus subiectum est, nōminātīvus singulāris.'),
  // nom. sg. 4th
  Syntagma(id: 'syn-us-003', text: '{exercitus} Rōmānus venit', lemmaId: 'exercitus', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Exercitus subiectum verbī venit, cui Rōmānus congruit: nōminātīvus singulāris quārtae dēclīnātiōnis.'),
  Syntagma(id: 'syn-us-004', text: '{manus} puerī parva est', lemmaId: 'manus', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Manus (-us brevis) subiectum est, parva fēminīnum congruit: nōminātīvus singulāris quārtae.'),
  Syntagma(id: 'syn-us-005', text: '{senātus} lēgem facit', lemmaId: 'senatus', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Senātus facit, lēgem (accūsātīvum) facit: senātus subiectum, nōminātīvus singulāris quārtae.'),
  // neuter 3rd nom. sg.
  Syntagma(id: 'syn-us-006', text: '{corpus} puerī aegrum est', lemmaId: 'corpus', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Corpus neutrum tertiae est, nōn masculīnum secundae: subiectum verbī est, aegrum neutrum congruit.'),
  Syntagma(id: 'syn-us-007', text: '{tempus} fugit', lemmaId: 'tempus', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Tempus subiectum verbī fugit: nōminātīvus singulāris neutrī tertiae (tempus, temporis).'),
  Syntagma(id: 'syn-us-008', text: '{genus} hominum mortāle est', lemmaId: 'genus', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Genus subiectum est, mortāle neutrum congruit: nōminātīvus singulāris neutrī tertiae.'),
  // neuter 3rd acc. sg.
  Syntagma(id: 'syn-us-009', text: 'Iūlius {opus} servōrum spectat', lemmaId: 'opus', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Iūlius spectat: quid spectat? opus, obiectum verbī, accūsātīvus singulāris neutrī tertiae.'),
  Syntagma(id: 'syn-us-010', text: 'mīles {vulnus} accipit', lemmaId: 'vulnus', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Mīles accipit: quid? vulnus, obiectum verbī, accūsātīvus singulāris neutrī.'),
  Syntagma(id: 'syn-us-011', text: 'Mārcus {mūnus} ā patre accipit', lemmaId: 'munus', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Mārcus subiectum est; mūnus obiectum verbī accipit: accūsātīvus singulāris neutrī.'),
  Syntagma(id: 'syn-us-012', text: 'asinus {onus} portat', lemmaId: 'onus', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Asinus portat: quid? onus, obiectum verbī, accūsātīvus singulāris neutrī tertiae.'),
  Syntagma(id: 'syn-us-013', text: 'medicus {pectus} puerī tangit', lemmaId: 'pectus', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Medicus tangit: quid? pectus puerī, obiectum verbī, accūsātīvus singulāris neutrī.'),
  Syntagma(id: 'syn-us-014', text: 'Iūlius {corpus} in aquā lavat', lemmaId: 'corpus', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Iūlius lavat: quid? corpus, obiectum verbī, accūsātīvus singulāris neutrī tertiae.'),
  // gen. sg. 4th -ūs
  Syntagma(id: 'syn-us-015', text: 'digitus pars {manūs} est', lemmaId: 'manus', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Pars manūs: cuius pars? genetīvus singulāris quārtae, -ūs longa.'),
  Syntagma(id: 'syn-us-016', text: 'dux {exercitūs} fortis est', lemmaId: 'exercitus', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Dux exercitūs: cuius dux? genetīvus singulāris quārtae; verbum est singulāre dūcī respondet.'),
  Syntagma(id: 'syn-us-017', text: 'cōnsul verba {senātūs} audit', lemmaId: 'senatus', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Verba senātūs: cuius verba? genetīvus singulāris quārtae dēclīnātiōnis.'),
  Syntagma(id: 'syn-us-018', text: 'iānua {domūs} clausa est', lemmaId: 'domus', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Iānua domūs: cuius iānua? genetīvus singulāris; clausa iānuae, nōn domuī, congruit.'),
  Syntagma(id: 'syn-us-019', text: 'sapor {frūctūs} dulcis est', lemmaId: 'fructus', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Sapor frūctūs: cuius sapor? genetīvus singulāris quārtae; est singulāre sapōrī respondet.'),
  // nom./acc. pl. 4th -ūs
  Syntagma(id: 'syn-us-020', text: 'puer {manūs} lavat', lemmaId: 'manus', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-us'}, note: 'Puer lavat: quid? manūs ambās, obiectum verbī: accūsātīvus plūrālis quārtae.'),
  Syntagma(id: 'syn-us-021', text: 'duo {exercitūs} pugnant', lemmaId: 'exercitus', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-us'}, note: 'Duo exercitūs pugnant: subiectum plūrāle verbī plūrālis, nōminātīvus plūrālis quārtae.'),
  Syntagma(id: 'syn-us-022', text: '{manūs} puerī sordidae sunt', lemmaId: 'manus', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-us'}, note: 'Manūs subiectum verbī sunt, sordidae fēminīnum plūrāle congruit: nōminātīvus plūrālis.'),
  Syntagma(id: 'syn-us-023', text: 'nautae {portūs} Italiae vident', lemmaId: 'portus', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-us'}, note: 'Nautae vident: quid? portūs, obiectum verbī: accūsātīvus plūrālis quārtae, nōn genetīvus.'),
  Syntagma(id: 'syn-us-024', text: 'multī {flūctūs} nāvem pulsant', lemmaId: 'fluctus', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-us'}, note: 'Multī flūctūs pulsant: subiectum plūrāle cui multī congruit, nōminātīvus plūrālis quārtae.'),
  // voc.
  Syntagma(id: 'syn-us-025', text: 'ō {deus}, nōs servā!', lemmaId: 'deus', casus: Casus.vocativus, number: Numerus.singularis, tags: {'syn-us'}, note: 'Ō deus: alloquitur, imperātīvus servā sequitur: vocātīvus singulāris, quī apud deus fōrmam nōminātīvī servat.'),

  // ── syn-e: -e / -ē ───────────────────────────────────────────────────────
  // abl. sg. 3rd
  Syntagma(id: 'syn-e-001', text: 'Iūlius cum {patre} ambulat', lemmaId: 'pater', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Cum praepositiō ablātīvum regit: cum patre, ablātīvus singulāris tertiae.'),
  Syntagma(id: 'syn-e-002', text: 'mīlitēs ā {rēge} veniunt', lemmaId: 'rex', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Ā praepositiō ablātīvum regit: ā rēge, unde veniunt, ablātīvus singulāris.'),
  Syntagma(id: 'syn-e-003', text: 'Aemilia in {urbe} habitat', lemmaId: 'urbs', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'In cum verbō habitat locum ubi significat: ablātīvus singulāris urbe.'),
  Syntagma(id: 'syn-e-004', text: 'puer {nōmine} Mārcus est', lemmaId: 'nomen', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Nōmine Mārcus: quā rē Mārcus? ablātīvus singulāris neutrī tertiae (nōmen, nōminis).'),
  Syntagma(id: 'syn-e-005', text: 'eō {tempore} Rōma parva erat', lemmaId: 'tempus', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Eō tempore: quandō? ablātīvus temporis, cui eō congruit.'),
  Syntagma(id: 'syn-e-006', text: 'Quīntus {pede} aeger est', lemmaId: 'pes', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Aeger pede: quā parte aeger? ablātīvus singulāris tertiae (pēs, pedis).'),
  Syntagma(id: 'syn-e-007', text: 'pāstor sub {arbore} dormit', lemmaId: 'arbor', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Sub cum verbō dormit locum ubi significat: ablātīvus singulāris arbore.'),
  // abl. sg. 5th -ē
  Syntagma(id: 'syn-e-008', text: 'eō {diē} Iūlius Rōmam it', lemmaId: 'dies', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Eō diē: quandō? ablātīvus temporis quīntae dēclīnātiōnis, -ē longa.'),
  Syntagma(id: 'syn-e-009', text: 'Iūlius dē {rē} magnā cōgitat', lemmaId: 'res', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Dē praepositiō ablātīvum regit: dē rē magnā, ablātīvus singulāris quīntae.'),
  Syntagma(id: 'syn-e-010', text: 'servus {spē} lībertātis vīvit', lemmaId: 'spes', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Spē vīvit: quā rē vīvit? ablātīvus singulāris quīntae dēclīnātiōnis.'),
  Syntagma(id: 'syn-e-011', text: 'mercātor sine {fidē} est', lemmaId: 'fides', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Sine praepositiō ablātīvum regit: sine fidē, ablātīvus singulāris quīntae.'),
  // voc. sg. 2nd
  Syntagma(id: 'syn-e-012', text: '{Mārce}, venī hūc!', lemmaId: 'marcus', casus: Casus.vocativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Mārce alloquitur puerum, imperātīvus venī sequitur: vocātīvus singulāris secundae.'),
  Syntagma(id: 'syn-e-013', text: '{serve}, aquam fer!', lemmaId: 'servus', casus: Casus.vocativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Serve alloquitur servum cui imperātur: vocātīvus singulāris secundae, nōn ablātīvus.'),
  Syntagma(id: 'syn-e-014', text: 'salvē, {domine}!', lemmaId: 'dominus', casus: Casus.vocativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Salvē salūtat, domine alloquitur: vocātīvus singulāris secundae dēclīnātiōnis.'),
  Syntagma(id: 'syn-e-015', text: '{Quīnte}, cūr plōrās?', lemmaId: 'quintus_n', casus: Casus.vocativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Quīnte alloquitur, verbum plōrās secundae persōnae est: vocātīvus singulāris.'),
  Syntagma(id: 'syn-e-016', text: 'ō {amīce}, mē audī!', lemmaId: 'amicus', casus: Casus.vocativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Ō amīce alloquitur, imperātīvus audī sequitur: vocātīvus singulāris secundae.'),
  Syntagma(id: 'syn-e-017', text: '{Dāve}, ubi est Mēdus?', lemmaId: 'davus', casus: Casus.vocativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Dāve interrogātur: vocātīvus singulāris secundae dēclīnātiōnis.'),
  // nom./acc. sg. neuter i-stem: mare
  Syntagma(id: 'syn-e-018', text: '{mare} magnum est', lemmaId: 'mare', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Mare subiectum verbī est, magnum neutrum congruit: nōminātīvus singulāris neutrī in -e.'),
  Syntagma(id: 'syn-e-019', text: '{mare} nāvēs portat', lemmaId: 'mare', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-e'}, tier: 1, note: 'Portat singulāre est: mare subiectum, nāvēs obiectum plūrāle; nōminātīvus singulāris.'),
  Syntagma(id: 'syn-e-020', text: '{mare} ventō turbātur', lemmaId: 'mare', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Turbātur passīvum est: mare subiectum, ventō ablātīvus causae; nōminātīvus singulāris.'),
  Syntagma(id: 'syn-e-021', text: '{mare} inter Italiam et Graeciam est', lemmaId: 'mare', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Mare subiectum verbī est: nōminātīvus singulāris neutrī tertiae.'),
  Syntagma(id: 'syn-e-022', text: 'nautae {mare} timent', lemmaId: 'mare', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Nautae timent: quid? mare, obiectum verbī, accūsātīvus singulāris neutrī.'),
  Syntagma(id: 'syn-e-023', text: 'ex nāve {mare} spectāmus', lemmaId: 'mare', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Spectāmus: quid? mare, obiectum verbī; nāve ablātīvus est, mare accūsātīvus.'),
  Syntagma(id: 'syn-e-024', text: 'Neptūnus {mare} regit', lemmaId: 'mare', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Neptūnus regit: quid? mare, obiectum verbī, accūsātīvus singulāris neutrī in -e.'),
  Syntagma(id: 'syn-e-025', text: 'puerī {mare} vident', lemmaId: 'mare', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-e'}, note: 'Puerī vident (plūrāle): mare obiectum verbī, accūsātīvus singulāris neutrī.'),

  // ── syn-es: -ēs ──────────────────────────────────────────────────────────
  // nom. pl. 3rd
  Syntagma(id: 'syn-es-001', text: '{rēgēs} in urbem veniunt', lemmaId: 'rex', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-es'}, note: 'Rēgēs subiectum verbī plūrālis veniunt: nōminātīvus plūrālis tertiae.'),
  Syntagma(id: 'syn-es-002', text: '{mīlitēs} fortiter pugnant', lemmaId: 'miles', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-es'}, note: 'Mīlitēs subiectum verbī pugnant: nōminātīvus plūrālis tertiae dēclīnātiōnis.'),
  Syntagma(id: 'syn-es-003', text: '{cīvēs} in forō clāmant', lemmaId: 'civis', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-es'}, note: 'Cīvēs subiectum verbī clāmant: nōminātīvus plūrālis tertiae.'),
  Syntagma(id: 'syn-es-004', text: '{patrēs} fīliōs amant', lemmaId: 'pater', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-es'}, note: 'Fīliōs accūsātīvus est, ergō patrēs subiectum verbī amant: nōminātīvus plūrālis.'),
  Syntagma(id: 'syn-es-005', text: '{nāvēs} in portū sunt', lemmaId: 'navis', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-es'}, note: 'Nāvēs subiectum verbī sunt: nōminātīvus plūrālis tertiae.'),
  Syntagma(id: 'syn-es-006', text: '{mātrēs} līberōs amant', lemmaId: 'mater', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-es'}, note: 'Līberōs accūsātīvus est, ergō mātrēs subiectum verbī amant: nōminātīvus plūrālis.'),
  Syntagma(id: 'syn-es-007', text: '{nūbēs} caelum tegunt', lemmaId: 'nubes', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-es'}, tier: 1, note: 'Tegunt plūrāle est: nūbēs multae subiectum sunt, nōminātīvus plūrālis; caelum obiectum.'),
  Syntagma(id: 'syn-es-008', text: '{diēs} aestāte longī sunt', lemmaId: 'dies', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-es'}, note: 'Sunt plūrāle, longī plūrāle congruit: diēs nōminātīvus plūrālis quīntae.'),
  Syntagma(id: 'syn-es-009', text: '{rēs} novae populum terrent', lemmaId: 'res', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-es'}, note: 'Terrent plūrāle est, novae congruit: rēs subiectum plūrāle, populum obiectum; nōminātīvus plūrālis.'),
  // acc. pl. 3rd
  Syntagma(id: 'syn-es-010', text: 'dux {mīlitēs} in pugnam dūcit', lemmaId: 'miles', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-es'}, note: 'Dux dūcit (singulāre): quōs dūcit? mīlitēs, obiectum verbī, accūsātīvus plūrālis.'),
  Syntagma(id: 'syn-es-011', text: 'populus {rēgēs} timet', lemmaId: 'rex', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-es'}, note: 'Populus timet (singulāre): quōs timet? rēgēs, obiectum verbī, accūsātīvus plūrālis.'),
  Syntagma(id: 'syn-es-012', text: 'Iūlius {hostēs} nōn timet', lemmaId: 'hostis', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-es'}, note: 'Iūlius subiectum est: hostēs obiectum verbī timet, accūsātīvus plūrālis tertiae.'),
  Syntagma(id: 'syn-es-013', text: 'pāstor {ovēs} in campō videt', lemmaId: 'ovis', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-es'}, note: 'Pāstor videt: quās videt? ovēs, obiectum verbī, accūsātīvus plūrālis.'),
  Syntagma(id: 'syn-es-014', text: 'nauta {nūbēs} in caelō videt', lemmaId: 'nubes', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-es'}, tier: 1, note: 'Nauta subiectum singulāre est; nūbēs obiectum verbī videt; accūsātīvus singulāris esset nūbem, ergō plūrālis.'),
  Syntagma(id: 'syn-es-015', text: 'Aemilia {rēs} multās habet', lemmaId: 'res', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-es'}, note: 'Aemilia habet: quid? rēs multās, obiectum verbī, accūsātīvus plūrālis quīntae.'),
  Syntagma(id: 'syn-es-016', text: 'Mārcus multōs {diēs} exspectat', lemmaId: 'dies', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-es'}, note: 'Multōs diēs: accūsātīvus plūrālis, quam diū exspectat? multōs congruit.'),
  Syntagma(id: 'syn-es-017', text: 'medicus {dentēs} puerī spectat', lemmaId: 'dens', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-es'}, note: 'Medicus spectat: quid? dentēs puerī, obiectum verbī, accūsātīvus plūrālis.'),
  // nom. sg. 5th and 3rd nouns in -ēs
  Syntagma(id: 'syn-es-018', text: '{rēs} difficilis est', lemmaId: 'res', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-es'}, note: 'Est singulāre est, difficilis singulāre congruit: rēs nōminātīvus singulāris quīntae.'),
  Syntagma(id: 'syn-es-019', text: '{diēs} longus est', lemmaId: 'dies', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-es'}, note: 'Est singulāre, longus singulāre congruit: diēs nōminātīvus singulāris quīntae.'),
  Syntagma(id: 'syn-es-020', text: '{nūbēs} caelum tegit', lemmaId: 'nubes', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-es'}, tier: 1, note: 'Tegit singulāre est: nūbēs ūna subiectum, nōminātīvus singulāris tertiae (nūbēs, nūbis).'),
  Syntagma(id: 'syn-es-021', text: 'sōla {spēs} manet', lemmaId: 'spes', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-es'}, note: 'Manet singulāre, sōla congruit: spēs nōminātīvus singulāris quīntae dēclīnātiōnis.'),
  Syntagma(id: 'syn-es-022', text: '{fidēs} amīcōrum magna est', lemmaId: 'fides', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-es'}, note: 'Fidēs subiectum verbī est, magna congruit: nōminātīvus singulāris quīntae.'),
  Syntagma(id: 'syn-es-023', text: '{caedēs} in urbe fit', lemmaId: 'caedes', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-es'}, note: 'Fit singulāre est: caedēs ūna subiectum, nōminātīvus singulāris tertiae (caedēs, caedis).'),
  Syntagma(id: 'syn-es-024', text: '{aciēs} hostium prōcēdit', lemmaId: 'acies', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-es'}, note: 'Prōcēdit singulāre est: aciēs subiectum, nōminātīvus singulāris quīntae dēclīnātiōnis.'),

  // ── syn-is: -is / -īs ────────────────────────────────────────────────────
  // gen. sg. 3rd
  Syntagma(id: 'syn-is-001', text: 'fīlius {rēgis} venit', lemmaId: 'rex', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-is'}, note: 'Fīlius rēgis: cuius fīlius? genetīvus singulāris tertiae, -is brevis.'),
  Syntagma(id: 'syn-is-002', text: 'nōmen {patris} Iūlius est', lemmaId: 'pater', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-is'}, note: 'Nōmen patris: cuius nōmen? genetīvus singulāris tertiae dēclīnātiōnis.'),
  Syntagma(id: 'syn-is-003', text: 'gladius {mīlitis} longus est', lemmaId: 'miles', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-is'}, note: 'Gladius mīlitis: cuius gladius? genetīvus singulāris tertiae.'),
  Syntagma(id: 'syn-is-004', text: 'domus {cīvis} magna est', lemmaId: 'civis', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-is'}, tier: 1, note: 'Domus subiectum est cui magna congruit; cīvis igitur nōn nōminātīvus sed genetīvus: cuius domus?'),
  Syntagma(id: 'syn-is-005', text: 'vōx {mātris} dulcis est', lemmaId: 'mater', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-is'}, note: 'Vōx mātris: cuius vōx? genetīvus singulāris tertiae dēclīnātiōnis.'),
  Syntagma(id: 'syn-is-006', text: 'lūx {sōlis} clāra est', lemmaId: 'sol', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-is'}, note: 'Lūx sōlis: cuius lūx? genetīvus singulāris tertiae (sōl, sōlis).'),
  // nom. sg. i-stem in -is
  Syntagma(id: 'syn-is-007', text: '{cīvis} Rōmānus in forō stat', lemmaId: 'civis', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-is'}, note: 'Cīvis subiectum verbī stat, Rōmānus congruit: nōminātīvus singulāris, quī in -is exit.'),
  Syntagma(id: 'syn-is-008', text: '{nāvis} magna est', lemmaId: 'navis', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-is'}, note: 'Nāvis subiectum verbī est, magna congruit: nōminātīvus singulāris tertiae.'),
  Syntagma(id: 'syn-is-009', text: '{hostis} ad urbem venit', lemmaId: 'hostis', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-is'}, note: 'Hostis subiectum verbī venit: nōminātīvus singulāris; genetīvus sine nōmine cui serviat nōn stat.'),
  Syntagma(id: 'syn-is-010', text: '{canis} puerum mordet', lemmaId: 'canis', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-is'}, note: 'Canis mordet, puerum (accūsātīvum) mordet: canis subiectum, nōminātīvus singulāris.'),
  Syntagma(id: 'syn-is-011', text: '{avis} in arbore cantat', lemmaId: 'avis', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-is'}, note: 'Avis subiectum verbī cantat: nōminātīvus singulāris tertiae in -is.'),
  Syntagma(id: 'syn-is-012', text: '{piscis} in aquā natat', lemmaId: 'piscis', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-is'}, note: 'Piscis subiectum verbī natat: nōminātīvus singulāris tertiae in -is.'),
  // dat. pl. 1st/2nd -īs
  Syntagma(id: 'syn-is-013', text: 'Iūlius {servīs} pecūniam dat', lemmaId: 'servus', casus: Casus.dativus, number: Numerus.pluralis, tags: {'syn-is'}, note: 'Dat: cui dat? servīs, datīvus plūrālis secundae, -īs longa.'),
  Syntagma(id: 'syn-is-014', text: 'Aemilia {puellīs} rosās dat', lemmaId: 'puella', casus: Casus.dativus, number: Numerus.pluralis, tags: {'syn-is'}, note: 'Dat: cui dat? puellīs, datīvus plūrālis prīmae dēclīnātiōnis.'),
  Syntagma(id: 'syn-is-015', text: 'dominus {servīs} imperat', lemmaId: 'servus', casus: Casus.dativus, number: Numerus.pluralis, tags: {'syn-is'}, note: 'Imperat datīvum regit: cui imperat? servīs, datīvus plūrālis secundae.'),
  Syntagma(id: 'syn-is-016', text: 'magister {discipulīs} librum ostendit', lemmaId: 'discipulus', casus: Casus.dativus, number: Numerus.pluralis, tags: {'syn-is'}, note: 'Ostendit: cui ostendit? discipulīs, datīvus plūrālis secundae dēclīnātiōnis.'),
  Syntagma(id: 'syn-is-017', text: 'māter {fīliīs} cibum parat', lemmaId: 'filius', casus: Casus.dativus, number: Numerus.pluralis, tags: {'syn-is'}, note: 'Parat: cui parat? fīliīs, datīvus plūrālis secundae.'),
  // abl. pl. 1st/2nd -īs
  Syntagma(id: 'syn-is-018', text: 'Iūlius cum {servīs} venit', lemmaId: 'servus', casus: Casus.ablativus, number: Numerus.pluralis, tags: {'syn-is'}, note: 'Cum praepositiō ablātīvum regit: cum servīs, ablātīvus plūrālis secundae.'),
  Syntagma(id: 'syn-is-019', text: 'in {vīllīs} Rōmānī habitant', lemmaId: 'villa', casus: Casus.ablativus, number: Numerus.pluralis, tags: {'syn-is'}, note: 'In cum verbō habitant locum ubi significat: ablātīvus plūrālis prīmae.'),
  Syntagma(id: 'syn-is-020', text: 'puer ā {puellīs} discēdit', lemmaId: 'puella', casus: Casus.ablativus, number: Numerus.pluralis, tags: {'syn-is'}, note: 'Ā praepositiō ablātīvum regit: ā puellīs, unde discēdit, ablātīvus plūrālis.'),
  Syntagma(id: 'syn-is-021', text: 'Iūlia {rosīs} gaudet', lemmaId: 'rosa', casus: Casus.ablativus, number: Numerus.pluralis, tags: {'syn-is'}, note: 'Gaudet ablātīvum regit: quā rē gaudet? rosīs, ablātīvus plūrālis prīmae.'),
  Syntagma(id: 'syn-is-022', text: 'mīlitēs {gladiīs} pugnant', lemmaId: 'gladius', casus: Casus.ablativus, number: Numerus.pluralis, tags: {'syn-is'}, note: 'Gladiīs pugnant: quō īnstrūmentō? ablātīvus plūrālis secundae.'),
  // acc. pl. -īs of i-stems (alternative form)
  Syntagma(id: 'syn-is-023', text: 'Rōmānī {hostīs} vincunt', lemmaId: 'hostis', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-is'}, tier: 2, note: 'Rōmānī vincunt: quōs? hostīs (= hostēs), accūsātīvus plūrālis alter nōminum in -i-.'),
  Syntagma(id: 'syn-is-024', text: 'cōnsul {cīvīs} convocat', lemmaId: 'civis', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-is'}, tier: 2, note: 'Cōnsul convocat: quōs? cīvīs (= cīvēs), accūsātīvus plūrālis alter, -īs longa.'),

  // ── syn-ibus: -ibus ──────────────────────────────────────────────────────
  // dat. pl.
  Syntagma(id: 'syn-ibus-001', text: 'Iūlius {mīlitibus} pecūniam dat', lemmaId: 'miles', casus: Casus.dativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Dat: cui dat? mīlitibus, datīvus plūrālis; pecūniam obiectum est.'),
  Syntagma(id: 'syn-ibus-002', text: 'lēx {cīvibus} placet', lemmaId: 'civis', casus: Casus.dativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Placet datīvum regit: cui placet? cīvibus, datīvus plūrālis.'),
  Syntagma(id: 'syn-ibus-003', text: 'mīlitēs {ducibus} pārent', lemmaId: 'dux', casus: Casus.dativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Pārent datīvum regit: cui pārent? ducibus, datīvus plūrālis.'),
  Syntagma(id: 'syn-ibus-004', text: 'māter {īnfantibus} lac dat', lemmaId: 'infans', casus: Casus.dativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Dat: cui dat? īnfantibus, datīvus plūrālis; lac obiectum est.'),
  Syntagma(id: 'syn-ibus-005', text: 'rēx {hominibus} lēgēs dat', lemmaId: 'homo', casus: Casus.dativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Dat: cui dat? hominibus, datīvus plūrālis; lēgēs obiectum est.'),
  Syntagma(id: 'syn-ibus-006', text: 'pāstor {ovibus} herbam dat', lemmaId: 'ovis', casus: Casus.dativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Dat: cui dat? ovibus, datīvus plūrālis tertiae.'),
  Syntagma(id: 'syn-ibus-007', text: 'Aemilia {frātribus} epistulās mittit', lemmaId: 'frater', casus: Casus.dativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Mittit: cui mittit? frātribus, datīvus plūrālis; epistulās obiectum est.'),
  Syntagma(id: 'syn-ibus-008', text: 'senātus {cōnsulibus} imperium dat', lemmaId: 'consul', casus: Casus.dativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Dat: cui dat? cōnsulibus, datīvus plūrālis tertiae.'),
  Syntagma(id: 'syn-ibus-009', text: 'puer {parentibus} pāret', lemmaId: 'parens', casus: Casus.dativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Pāret datīvum regit: cui pāret? parentibus, datīvus plūrālis.'),
  Syntagma(id: 'syn-ibus-010', text: 'Iūlius {mercātōribus} nummōs solvit', lemmaId: 'mercator', casus: Casus.dativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Solvit: cui solvit? mercātōribus, datīvus plūrālis; nummōs obiectum est.'),
  // abl. pl.
  Syntagma(id: 'syn-ibus-011', text: 'dux cum {mīlitibus} venit', lemmaId: 'miles', casus: Casus.ablativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Cum praepositiō ablātīvum regit: cum mīlitibus, ablātīvus plūrālis.'),
  Syntagma(id: 'syn-ibus-012', text: 'cōnsul ā {cīvibus} laudātur', lemmaId: 'civis', casus: Casus.ablativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Ā praepositiō ablātīvum regit: ā cīvibus laudātur, ablātīvus plūrālis auctōris.'),
  Syntagma(id: 'syn-ibus-013', text: 'puer pilam {manibus} tenet', lemmaId: 'manus', casus: Casus.ablativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Manibus tenet: quō īnstrūmentō? ablātīvus plūrālis quārtae dēclīnātiōnis.'),
  Syntagma(id: 'syn-ibus-014', text: 'Rōmānī in {urbibus} habitant', lemmaId: 'urbs', casus: Casus.ablativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'In cum verbō habitant locum ubi significat: ablātīvus plūrālis urbibus.'),
  Syntagma(id: 'syn-ibus-015', text: 'aqua ex {montibus} fluit', lemmaId: 'mons', casus: Casus.ablativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Ex praepositiō ablātīvum regit: ex montibus, unde fluit, ablātīvus plūrālis.'),
  Syntagma(id: 'syn-ibus-016', text: 'nāvēs in {portibus} sunt', lemmaId: 'portus', casus: Casus.ablativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'In cum verbō sunt locum ubi significat: ablātīvus plūrālis quārtae.'),
  Syntagma(id: 'syn-ibus-017', text: 'lupus {dentibus} agnum capit', lemmaId: 'dens', casus: Casus.ablativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Dentibus capit: quō īnstrūmentō? ablātīvus plūrālis; agnum obiectum est.'),
  Syntagma(id: 'syn-ibus-018', text: 'mīlitēs {pedibus} iter faciunt', lemmaId: 'pes', casus: Casus.ablativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Pedibus iter faciunt: quō modō? ablātīvus plūrālis tertiae.'),
  Syntagma(id: 'syn-ibus-019', text: 'avēs in {arboribus} cantant', lemmaId: 'arbor', casus: Casus.ablativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'In cum verbō cantant locum ubi significat: ablātīvus plūrālis arboribus.'),
  Syntagma(id: 'syn-ibus-020', text: 'Iūlia {flōribus} gaudet', lemmaId: 'flos', casus: Casus.ablativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Gaudet ablātīvum regit: quā rē gaudet? flōribus, ablātīvus plūrālis.'),
  Syntagma(id: 'syn-ibus-021', text: 'sine {lēgibus} cīvitās nōn est', lemmaId: 'lex', casus: Casus.ablativus, number: Numerus.pluralis, tags: {'syn-ibus'}, note: 'Sine praepositiō ablātīvum regit: sine lēgibus, ablātīvus plūrālis.'),

  // ── syn-neutra: neuter nom. = acc. ───────────────────────────────────────
  // nom. sg.
  Syntagma(id: 'syn-neutra-001', text: '{bellum} populum terret', lemmaId: 'bellum', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-neutra'}, note: 'Populum accūsātīvus est, ergō bellum subiectum verbī terret: nōminātīvus singulāris.'),
  Syntagma(id: 'syn-neutra-002', text: '{dōnum} puerō placet', lemmaId: 'donum', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-neutra'}, note: 'Placet datīvum (puerō) regit, nōn accūsātīvum: dōnum subiectum, nōminātīvus singulāris.'),
  Syntagma(id: 'syn-neutra-003', text: '{flūmen} per campōs fluit', lemmaId: 'flumen', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-neutra'}, note: 'Flūmen subiectum verbī fluit, quod obiectum nōn habet: nōminātīvus singulāris.'),
  Syntagma(id: 'syn-neutra-004', text: '{caput} mihi dolet', lemmaId: 'caput', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-neutra'}, note: 'Caput dolet: subiectum verbī, mihi datīvus; nōminātīvus singulāris neutrī.'),
  Syntagma(id: 'syn-neutra-005', text: '{mare} nautās terret', lemmaId: 'mare', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-neutra'}, note: 'Nautās accūsātīvus est, ergō mare subiectum verbī terret: nōminātīvus singulāris.'),
  Syntagma(id: 'syn-neutra-006', text: '{cornū} taurī longum est', lemmaId: 'cornu', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-neutra'}, note: 'Cornū subiectum verbī est, longum neutrum congruit: nōminātīvus singulāris quārtae.'),
  Syntagma(id: 'syn-neutra-007', text: '{templum} in forō stat', lemmaId: 'templum', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-neutra'}, note: 'Templum subiectum verbī stat: nōminātīvus singulāris neutrī secundae.'),
  Syntagma(id: 'syn-neutra-008', text: 'populum terret {bellum}', lemmaId: 'bellum', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-neutra'}, tier: 2, note: 'Etsī ultimum stat, bellum subiectum est: populum accūsātīvus obiectum, bellum nōminātīvus.'),
  // acc. sg.
  Syntagma(id: 'syn-neutra-009', text: 'populus {bellum} timet', lemmaId: 'bellum', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-neutra'}, note: 'Populus nōminātīvus subiectum est: bellum obiectum verbī timet, accūsātīvus singulāris.'),
  Syntagma(id: 'syn-neutra-010', text: 'puer {dōnum} accipit', lemmaId: 'donum', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-neutra'}, note: 'Puer accipit: quid? dōnum, obiectum verbī, accūsātīvus singulāris.'),
  Syntagma(id: 'syn-neutra-011', text: 'mīles {genū} flectit', lemmaId: 'genu', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-neutra'}, note: 'Mīles flectit: quid? genū, obiectum verbī, accūsātīvus singulāris quārtae neutrī.'),
  Syntagma(id: 'syn-neutra-012', text: '{bellum} populus timet', lemmaId: 'bellum', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-neutra'}, tier: 2, note: 'Etsī prīmum stat, bellum obiectum est: populus nōminātīvus subiectum, bellum accūsātīvus.'),
  Syntagma(id: 'syn-neutra-013', text: '{opus} servī faciunt', lemmaId: 'opus', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-neutra'}, tier: 2, note: 'Faciunt plūrāle servīs respondet, nōn operī: opus obiectum, accūsātīvus singulāris.'),
  Syntagma(id: 'syn-neutra-014', text: 'Rōmānī {flūmen} trānseunt', lemmaId: 'flumen', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-neutra'}, note: 'Rōmānī trānseunt: quid? flūmen, obiectum verbī, accūsātīvus singulāris neutrī.'),
  // nom. pl.
  Syntagma(id: 'syn-neutra-015', text: '{bella} populōs terrent', lemmaId: 'bellum', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-neutra'}, note: 'Populōs accūsātīvus est, ergō bella subiectum verbī terrent: nōminātīvus plūrālis.'),
  Syntagma(id: 'syn-neutra-016', text: '{corpora} mīlitum in campō iacent', lemmaId: 'corpus', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-neutra'}, note: 'Corpora subiectum verbī iacent, quod obiectum nōn habet: nōminātīvus plūrālis.'),
  Syntagma(id: 'syn-neutra-017', text: '{cornua} taurī longa sunt', lemmaId: 'cornu', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-neutra'}, note: 'Cornua subiectum verbī sunt, longa neutrum plūrāle congruit: nōminātīvus plūrālis.'),
  Syntagma(id: 'syn-neutra-018', text: '{flūmina} in mare fluunt', lemmaId: 'flumen', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-neutra'}, note: 'Flūmina subiectum verbī fluunt: nōminātīvus plūrālis; in mare accūsātīvus quō.'),
  Syntagma(id: 'syn-neutra-019', text: '{maria} nautās terrent', lemmaId: 'mare', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-neutra'}, note: 'Nautās accūsātīvus est, ergō maria subiectum verbī terrent: nōminātīvus plūrālis.'),
  Syntagma(id: 'syn-neutra-020', text: 'nautās terrent {maria}', lemmaId: 'mare', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-neutra'}, tier: 2, note: 'Etsī ultimum stat, maria subiectum est: nautās accūsātīvus obiectum; nōminātīvus plūrālis.'),
  // acc. pl.
  Syntagma(id: 'syn-neutra-021', text: 'Rōmānī {bella} gerunt', lemmaId: 'bellum', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-neutra'}, note: 'Rōmānī nōminātīvus subiectum est: bella obiectum verbī gerunt, accūsātīvus plūrālis.'),
  Syntagma(id: 'syn-neutra-022', text: 'puerī {dōna} accipiunt', lemmaId: 'donum', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-neutra'}, note: 'Puerī accipiunt: quid? dōna, obiectum verbī, accūsātīvus plūrālis.'),
  Syntagma(id: 'syn-neutra-023', text: 'nautae {maria} nāvigant', lemmaId: 'mare', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-neutra'}, note: 'Nautae nōminātīvus subiectum est: maria obiectum verbī nāvigant, accūsātīvus plūrālis.'),
  Syntagma(id: 'syn-neutra-024', text: '{cornua} taurus habet', lemmaId: 'cornu', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-neutra'}, tier: 2, note: 'Habet singulāre taurō respondet, nōn cornibus: cornua obiectum, accūsātīvus plūrālis.'),
  Syntagma(id: 'syn-neutra-025', text: 'mīles {vulnera} multa accipit', lemmaId: 'vulnus', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-neutra'}, note: 'Mīles accipit (singulāre): quid? vulnera multa, obiectum verbī, accūsātīvus plūrālis.'),
  Syntagma(id: 'syn-neutra-026', text: '{membra} medicus tangit', lemmaId: 'membrum', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-neutra'}, tier: 2, note: 'Tangit singulāre medicō respondet: membra obiectum, accūsātīvus plūrālis, etsī prīmum stat.'),

  // ── syn-quantitas: vowel length ──────────────────────────────────────────
  // rosa / rosā
  Syntagma(id: 'syn-quantitas-001', text: '{rosa} in hortō flōret', lemmaId: 'rosa', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Rosa (-a brevis) subiectum verbī flōret: nōminātīvus singulāris.'),
  Syntagma(id: 'syn-quantitas-002', text: 'puella {rosā} gaudet', lemmaId: 'rosa', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Rosā (-ā longa): gaudet ablātīvum regit, puella subiectum est; ablātīvus singulāris.'),
  // puella / puellā
  Syntagma(id: 'syn-quantitas-003', text: '{puella} in hortō cantat', lemmaId: 'puella', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Puella (-a brevis) subiectum verbī cantat: nōminātīvus singulāris.'),
  Syntagma(id: 'syn-quantitas-004', text: 'Mārcus cum {puellā} ambulat', lemmaId: 'puella', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Puellā (-ā longa): cum praepositiō ablātīvum regit; ablātīvus singulāris.'),
  // fēmina / fēminā
  Syntagma(id: 'syn-quantitas-005', text: '{fēmina} īnfantem portat', lemmaId: 'femina', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Fēmina (-a brevis) subiectum est, īnfantem obiectum: nōminātīvus singulāris.'),
  Syntagma(id: 'syn-quantitas-006', text: 'servus ā {fēminā} discēdit', lemmaId: 'femina', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Fēminā (-ā longa): ā praepositiō ablātīvum regit; ablātīvus singulāris.'),
  // īnsula / īnsulā
  Syntagma(id: 'syn-quantitas-007', text: '{īnsula} in marī est', lemmaId: 'insula', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Īnsula (-a brevis) subiectum verbī est: nōminātīvus singulāris.'),
  Syntagma(id: 'syn-quantitas-008', text: 'nauta in {īnsulā} habitat', lemmaId: 'insula', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Īnsulā (-ā longa): in cum habitat locum ubi significat; ablātīvus singulāris.'),
  // fīlia / fīliā
  Syntagma(id: 'syn-quantitas-009', text: '{fīlia} patrem amat', lemmaId: 'filia', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Fīlia (-a brevis) subiectum est, patrem obiectum: nōminātīvus singulāris.'),
  Syntagma(id: 'syn-quantitas-010', text: 'pater cum {fīliā} ambulat', lemmaId: 'filia', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Fīliā (-ā longa): cum praepositiō ablātīvum regit; ablātīvus singulāris.'),
  // manus / manūs
  Syntagma(id: 'syn-quantitas-011', text: '{manus} puerī sordida est', lemmaId: 'manus', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Manus (-us brevis) subiectum est, sordida singulāre congruit: nōminātīvus singulāris.'),
  Syntagma(id: 'syn-quantitas-012', text: 'digitī {manūs} quīnque sunt', lemmaId: 'manus', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Manūs (-ūs longa): digitī manūs, cuius digitī? genetīvus singulāris quārtae.'),
  // exercitus / exercitūs
  Syntagma(id: 'syn-quantitas-013', text: '{exercitus} Rōmam dēfendit', lemmaId: 'exercitus', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Exercitus (-us brevis) subiectum verbī dēfendit: nōminātīvus singulāris.'),
  Syntagma(id: 'syn-quantitas-014', text: 'dux {exercitūs} venit', lemmaId: 'exercitus', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Exercitūs (-ūs longa): dux exercitūs, cuius dux? genetīvus singulāris; venit singulāre dūcī respondet.'),
  // cīvis / cīvīs
  Syntagma(id: 'syn-quantitas-015', text: '{cīvis} Rōmānus venit', lemmaId: 'civis', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Cīvis (-is brevis) subiectum verbī venit, Rōmānus congruit: nōminātīvus singulāris.'),
  Syntagma(id: 'syn-quantitas-016', text: 'cōnsul {cīvīs} convocat', lemmaId: 'civis', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-quantitas'}, tier: 1, note: 'Cīvīs (-īs longa) = cīvēs: cōnsul convocat, quōs? accūsātīvus plūrālis alter.'),
  // hostis / hostīs
  Syntagma(id: 'syn-quantitas-017', text: '{hostis} urbem oppugnat', lemmaId: 'hostis', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Hostis (-is brevis) subiectum est, urbem obiectum: nōminātīvus singulāris.'),
  Syntagma(id: 'syn-quantitas-018', text: 'mīlitēs {hostīs} vincunt', lemmaId: 'hostis', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-quantitas'}, tier: 1, note: 'Hostīs (-īs longa) = hostēs: mīlitēs vincunt, quōs? accūsātīvus plūrālis alter.'),
  // nāvis / nāvīs
  Syntagma(id: 'syn-quantitas-019', text: '{nāvis} in portū est', lemmaId: 'navis', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Nāvis (-is brevis) subiectum verbī est: nōminātīvus singulāris.'),
  Syntagma(id: 'syn-quantitas-020', text: 'ventus {nāvīs} mergit', lemmaId: 'navis', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-quantitas'}, tier: 1, note: 'Nāvīs (-īs longa) = nāvēs: ventus mergit, quid? accūsātīvus plūrālis alter.'),
  // mare / marī
  Syntagma(id: 'syn-quantitas-021', text: '{mare} altum est', lemmaId: 'mare', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Mare (-e brevis) subiectum verbī est, altum congruit: nōminātīvus singulāris.'),
  Syntagma(id: 'syn-quantitas-022', text: 'nāvis in {marī} est', lemmaId: 'mare', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Marī (-ī longa): in cum verbō est locum ubi significat; ablātīvus singulāris neutrī in -i-.'),
  // diē / diem
  Syntagma(id: 'syn-quantitas-023', text: 'eō {diē} Iūlius venit', lemmaId: 'dies', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Diē (-ē longa): eō diē, quandō? ablātīvus temporis quīntae.'),
  Syntagma(id: 'syn-quantitas-024', text: 'Mārcus tōtum {diem} dormit', lemmaId: 'dies', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Diem (-em): tōtum diem, quam diū? accūsātīvus dūrātiōnis, cui tōtum congruit.'),
  // rēs / rē
  Syntagma(id: 'syn-quantitas-025', text: '{rēs} magna est', lemmaId: 'res', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Rēs subiectum verbī est, magna singulāre congruit: nōminātīvus singulāris quīntae.'),
  Syntagma(id: 'syn-quantitas-026', text: 'senātus dē {rē} pūblicā cōnsulit', lemmaId: 'res', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Rē (-ē longa): dē praepositiō ablātīvum regit; ablātīvus singulāris quīntae.'),
  // spēs / spē
  Syntagma(id: 'syn-quantitas-027', text: '{spēs} in animō manet', lemmaId: 'spes', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Spēs subiectum verbī manet: nōminātīvus singulāris quīntae dēclīnātiōnis.'),
  Syntagma(id: 'syn-quantitas-028', text: 'Mēdus {spē} lībertātis vīvit', lemmaId: 'spes', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-quantitas'}, note: 'Spē (-ē longa): quā rē vīvit? ablātīvus singulāris quīntae.'),
];
