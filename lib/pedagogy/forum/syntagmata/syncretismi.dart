/// Contextual items — section "syncretismi" (first half: the ambiguous
/// endings -ae, -a/-ā, -ī, -ō, -um). Authored by hand; see syntagma.dart for
/// the markers (`{target}`, `[head]`, `<candidate>`).
///
/// Each card gathers one ending; the items are spread over its competing
/// readings so that the context (verb, preposition, head noun) — never the
/// surface — decides case and number.
library;

import '../../../linguistics/model/grammar.dart';
import '../../../linguistics/model/nominal.dart';
import '../syntagma.dart';

// ignore_for_file: unused_import

const List<Syntagma> kSyncretismiSyntagmata = [
  // ───────────────────────── syn-ae: -ae ─────────────────────────
  // gen. sg.
  Syntagma(id: 'syn-ae-001', text: 'spīnae {rosae} pungunt', lemmaId: 'rosa', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-ae'}, tier: 2, note: 'Spīnae rosae: cuius spīnae? rosae est genetīvus singulāris, nōmen spīnae dēterminat.'),
  Syntagma(id: 'syn-ae-002', text: 'ōstium {vīllae} clausum est', lemmaId: 'villa', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-ae'}, tier: 1, note: 'Ōstium vīllae: cuius ōstium? genetīvus singulāris ad nōmen ōstium pertinet.'),
  Syntagma(id: 'syn-ae-003', text: 'tunica {ancillae} sordida est', lemmaId: 'ancilla', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-ae'}, tier: 1, note: 'Tunica ancillae: cuius tunica? genetīvus singulāris possessōrem significat.'),
  Syntagma(id: 'syn-ae-004', text: 'māter {puellae} eam laudat', lemmaId: 'puella', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-ae'}, tier: 1, note: 'Māter puellae: cuius māter? genetīvus singulāris; verbum laudat obiectum eam habet.'),
  Syntagma(id: 'syn-ae-005', text: 'ōra {Italiae} longa est', lemmaId: 'italia', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-ae'}, tier: 1, note: 'Ōra Italiae: cuius ōra? genetīvus singulāris nōmen ōra dēterminat.'),
  // dat. sg.
  Syntagma(id: 'syn-ae-006', text: '{rosae} aqua nocet', lemmaId: 'rosa', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-ae'}, tier: 1, note: 'Nocet datīvum regit: cui nocet aqua? rosae, datīvus singulāris.'),
  Syntagma(id: 'syn-ae-007', text: 'Iūlius {ancillae} tunicam dat', lemmaId: 'ancilla', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-ae'}, tier: 1, note: 'Dat tunicam: cui dat? ancillae est datīvus singulāris, tunicam accūsātīvus.'),
  Syntagma(id: 'syn-ae-008', text: 'Mārcus {Iūliae} pilam dat', lemmaId: 'iulia', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-ae'}, tier: 1, note: 'Cui Mārcus pilam dat? Iūliae: datīvus singulāris apud verbum dandī.'),
  Syntagma(id: 'syn-ae-009', text: 'pater {fīliae} respondet', lemmaId: 'filia', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-ae'}, tier: 1, note: 'Respondet datīvum regit: cui respondet pater? fīliae, datīvus singulāris.'),
  Syntagma(id: 'syn-ae-010', text: 'servus {dominae} pāret', lemmaId: 'domina', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-ae'}, tier: 1, note: 'Pāret datīvum regit: cui pāret servus? dominae, datīvus singulāris.'),
  // nom. pl.
  Syntagma(id: 'syn-ae-011', text: 'rosae {spīnae} pungunt', lemmaId: 'spina', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-ae'}, tier: 2, note: 'Spīnae subiectum verbī pungunt, quod plūrāle est: nōminātīvus plūrālis.'),
  Syntagma(id: 'syn-ae-012', text: '{rosae} in hortō flōrent', lemmaId: 'rosa', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-ae'}, tier: 0, note: 'Flōrent verbum plūrāle est: rosae subiectum, nōminātīvus plūrālis.'),
  Syntagma(id: 'syn-ae-013', text: '{ancillae} cēnam parant', lemmaId: 'ancilla', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-ae'}, tier: 0, note: 'Parant verbum plūrāle subiectum plūrāle poscit: ancillae nōminātīvus plūrālis, cēnam obiectum.'),
  Syntagma(id: 'syn-ae-014', text: '{stēllae} nocte lūcent', lemmaId: 'stella', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-ae'}, tier: 0, note: 'Quid lūcet? stēllae: subiectum verbī plūrālis lūcent, nōminātīvus plūrālis.'),
  Syntagma(id: 'syn-ae-015', text: '{puellae} in hortō cantant', lemmaId: 'puella', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-ae'}, tier: 0, note: 'Cantant plūrāle est: puellae subiectum, nōminātīvus plūrālis.'),
  Syntagma(id: 'syn-ae-016', text: 'duae {fēminae} veniunt', lemmaId: 'femina', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-ae'}, tier: 0, note: 'Duae et veniunt numerum plūrālem ostendunt: fēminae subiectum, nōminātīvus plūrālis.'),
  // voc. pl.
  Syntagma(id: 'syn-ae-017', text: '{puellae}, venīte!', lemmaId: 'puella', casus: Casus.vocativus, number: Numerus.pluralis, tags: {'syn-ae'}, tier: 0, note: 'Imperātīvus venīte puellās appellat: vocātīvus plūrālis.'),
  Syntagma(id: 'syn-ae-018', text: '{ancillae}, cēnam parāte!', lemmaId: 'ancilla', casus: Casus.vocativus, number: Numerus.pluralis, tags: {'syn-ae'}, tier: 0, note: 'Parāte imperātīvus plūrālis est: ancillae appellantur, vocātīvus plūrālis.'),
  Syntagma(id: 'syn-ae-019', text: 'salvēte, {fīliae} meae!', lemmaId: 'filia', casus: Casus.vocativus, number: Numerus.pluralis, tags: {'syn-ae'}, tier: 0, note: 'Salvēte salūtātiō est ad plūrēs: fīliae meae vocātīvus plūrālis.'),
  Syntagma(id: 'syn-ae-020', text: '{amīcae}, audīte mē!', lemmaId: 'amica', casus: Casus.vocativus, number: Numerus.pluralis, tags: {'syn-ae'}, tier: 0, note: 'Audīte imperātīvus plūrālis amīcās appellat: vocātīvus plūrālis.'),
  Syntagma(id: 'syn-ae-021', text: '{fēminae}, nōlīte flēre!', lemmaId: 'femina', casus: Casus.vocativus, number: Numerus.pluralis, tags: {'syn-ae'}, tier: 0, note: 'Nōlīte flēre imperātīvus negātīvus est: fēminae appellantur, vocātīvus plūrālis.'),

  // ───────────────────────── syn-a: -a / -ā ─────────────────────────
  // nom. sg. 1st
  Syntagma(id: 'syn-a-001', text: '{puella} in hortō cantat', lemmaId: 'puella', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-a'}, tier: 0, note: 'Cantat verbum singulāre est: puella subiectum, nōminātīvus singulāris, -a brevis.'),
  Syntagma(id: 'syn-a-002', text: '{Aemilia} fīlium vocat', lemmaId: 'aemilia', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-a'}, tier: 0, note: 'Quis vocat fīlium? Aemilia: subiectum verbī vocat, nōminātīvus singulāris.'),
  Syntagma(id: 'syn-a-003', text: '{ancilla} aquam portat', lemmaId: 'ancilla', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-a'}, tier: 0, note: 'Portat singulāre est et aquam obiectum: ancilla subiectum, nōminātīvus singulāris.'),
  Syntagma(id: 'syn-a-004', text: '{rosa} pulchra est', lemmaId: 'rosa', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-a'}, tier: 0, note: 'Rosa subiectum verbī est cum praedicātō pulchra: nōminātīvus singulāris.'),
  Syntagma(id: 'syn-a-005', text: '{lūna} nocte lūcet', lemmaId: 'luna', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-a'}, tier: 0, note: 'Quid lūcet? lūna: subiectum verbī singulāris lūcet, nōminātīvus singulāris.'),
  // nom. pl. neuter
  Syntagma(id: 'syn-a-006', text: '{templa} in urbe sunt magna', lemmaId: 'templum', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-a'}, tier: 0, note: 'Sunt magna praedicātum plūrāle neutrum est: templa subiectum, nōminātīvus plūrālis.'),
  Syntagma(id: 'syn-a-007', text: '{oppida} Italiae multa sunt', lemmaId: 'oppidum', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-a'}, tier: 0, note: 'Multa sunt dē oppidīs dīcitur: oppida subiectum, nōminātīvus plūrālis neutrī.'),
  Syntagma(id: 'syn-a-008', text: '{bella} longa sunt', lemmaId: 'bellum', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-a'}, tier: 0, note: 'Bella subiectum verbī sunt cum praedicātō longa: nōminātīvus plūrālis neutrī.'),
  Syntagma(id: 'syn-a-009', text: '{verba} magistrī clāra sunt', lemmaId: 'verbum', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-a'}, tier: 1, note: 'Clāra sunt dē verbīs praedicātur: verba subiectum, nōminātīvus plūrālis; magistrī genetīvus.'),
  Syntagma(id: 'syn-a-010', text: '{ōva} in mēnsā sunt', lemmaId: 'ovum', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-a'}, tier: 0, note: 'Quid in mēnsā est? ōva: subiectum verbī plūrālis sunt, nōminātīvus plūrālis.'),
  // acc. pl. neuter
  Syntagma(id: 'syn-a-011', text: 'Rōmānī multa {bella} gerunt', lemmaId: 'bellum', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-a'}, tier: 0, note: 'Rōmānī subiectum est, bella obiectum verbī gerunt: accūsātīvus plūrālis neutrī.'),
  Syntagma(id: 'syn-a-012', text: 'nautae {oppida} vident', lemmaId: 'oppidum', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-a'}, tier: 1, note: 'Nautae vident: quid vident? oppida, obiectum, accūsātīvus plūrālis neutrī.'),
  Syntagma(id: 'syn-a-013', text: 'Mārcus {māla} edit', lemmaId: 'malum', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-a'}, tier: 0, note: 'Mārcus edit: quid edit? māla, obiectum verbī, accūsātīvus plūrālis neutrī.'),
  Syntagma(id: 'syn-a-014', text: 'puer {verba} magistrī audit', lemmaId: 'verbum', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-a'}, tier: 1, note: 'Puer audit: quid audit? verba magistrī, obiectum, accūsātīvus plūrālis neutrī.'),
  Syntagma(id: 'syn-a-015', text: 'servī {pōcula} in mēnsā pōnunt', lemmaId: 'poculum', casus: Casus.accusativus, number: Numerus.pluralis, tags: {'syn-a'}, tier: 0, note: 'Servī pōnunt: quid pōnunt? pōcula, obiectum verbī, accūsātīvus plūrālis neutrī.'),
  // abl. sg. 1st (-ā)
  Syntagma(id: 'syn-a-016', text: 'Mārcus cum {puellā} lūdit', lemmaId: 'puella', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-a'}, tier: 0, note: 'Praepositiō cum ablātīvum regit: puellā, -ā longa, ablātīvus singulāris.'),
  Syntagma(id: 'syn-a-017', text: 'Iūlius in {vīllā} habitat', lemmaId: 'villa', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-a'}, tier: 0, note: 'In cum verbō habitat locum ubi significat: ablātīvus singulāris vīllā.'),
  Syntagma(id: 'syn-a-018', text: 'Aemilia ā {fenestrā} spectat', lemmaId: 'fenestra', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-a'}, tier: 0, note: 'Praepositiō ā ablātīvum regit: fenestrā ablātīvus singulāris.'),
  Syntagma(id: 'syn-a-019', text: 'mīles {hastā} pugnat', lemmaId: 'hasta', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-a'}, tier: 1, note: 'Quō īnstrūmentō pugnat? hastā: ablātīvus īnstrūmentī, -ā longa singulāris.'),
  Syntagma(id: 'syn-a-020', text: 'fēmina cum {fīliā} ambulat', lemmaId: 'filia', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-a'}, tier: 0, note: 'Cum praepositiō ablātīvum poscit: fīliā ablātīvus singulāris.'),
  Syntagma(id: 'syn-a-021', text: 'Dāvus sine {pecūniā} est', lemmaId: 'pecunia', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-a'}, tier: 0, note: 'Sine praepositiō ablātīvum regit: pecūniā ablātīvus singulāris.'),

  // ───────────────────────── syn-i: -ī ─────────────────────────
  // gen. sg. 2nd
  Syntagma(id: 'syn-i-001', text: 'servus {dominī} labōrat', lemmaId: 'dominus', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-i'}, tier: 1, note: 'Labōrat singulāre est et servus subiectum: dominī genetīvus singulāris, cuius servus?'),
  Syntagma(id: 'syn-i-002', text: 'equus {Iūliī} albus est', lemmaId: 'iulius', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-i'}, tier: 1, note: 'Equus Iūliī: cuius equus? genetīvus singulāris possessōrem significat.'),
  Syntagma(id: 'syn-i-003', text: 'liber {puerī} in mēnsā est', lemmaId: 'puer', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-i'}, tier: 1, note: 'Liber puerī: cuius liber? genetīvus singulāris; verbum est singulāre.'),
  Syntagma(id: 'syn-i-004', text: 'porta {hortī} clausa est', lemmaId: 'hortus', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-i'}, tier: 1, note: 'Porta hortī: cuius porta? genetīvus singulāris nōmen porta dēterminat.'),
  Syntagma(id: 'syn-i-005', text: 'dominus {servī} sevērus est', lemmaId: 'servus', casus: Casus.genetivus, number: Numerus.singularis, tags: {'syn-i'}, tier: 1, note: 'Dominus servī: cuius dominus? genetīvus singulāris; est singulāre ad dominum pertinet.'),
  // nom. pl. 2nd
  Syntagma(id: 'syn-i-006', text: '{servī} in agrīs labōrant', lemmaId: 'servus', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-i'}, tier: 0, note: 'Labōrant plūrāle est: servī subiectum, nōminātīvus plūrālis.'),
  Syntagma(id: 'syn-i-007', text: '{puerī} pilā lūdunt', lemmaId: 'puer', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-i'}, tier: 0, note: 'Quī lūdunt? puerī: subiectum verbī plūrālis, nōminātīvus plūrālis.'),
  Syntagma(id: 'syn-i-008', text: 'duo {fīliī} in hortō lūdunt', lemmaId: 'filius', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-i'}, tier: 0, note: 'Duo et lūdunt plūrālem ostendunt: fīliī subiectum, nōminātīvus plūrālis.'),
  Syntagma(id: 'syn-i-009', text: 'multī {amīcī} veniunt', lemmaId: 'amicus', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-i'}, tier: 0, note: 'Multī amīcī subiectum verbī veniunt: nōminātīvus plūrālis.'),
  Syntagma(id: 'syn-i-010', text: '{equī} in campō currunt', lemmaId: 'equus', casus: Casus.nominativus, number: Numerus.pluralis, tags: {'syn-i'}, tier: 0, note: 'Currunt plūrāle est: equī subiectum, nōminātīvus plūrālis.'),
  // voc. sg. of -ius
  Syntagma(id: 'syn-i-011', text: '{fīlī}, venī ad mē!', lemmaId: 'filius', casus: Casus.vocativus, number: Numerus.singularis, tags: {'syn-i'}, tier: 2, note: 'Imperātīvus venī fīlium appellat: fīlī vocātīvus singulāris nōminum in -ius.'),
  Syntagma(id: 'syn-i-012', text: 'salvē, {Iūlī}!', lemmaId: 'iulius', casus: Casus.vocativus, number: Numerus.singularis, tags: {'syn-i'}, tier: 2, note: 'Salvē salūtātiō ad ūnum est: Iūlī vocātīvus singulāris nōminis Iūlius.'),
  // dat. sg. 3rd
  Syntagma(id: 'syn-i-013', text: 'servus {rēgī} pāret', lemmaId: 'rex', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-i'}, tier: 1, note: 'Pāret datīvum regit: cui pāret? rēgī, datīvus singulāris tertiae dēclīnātiōnis.'),
  Syntagma(id: 'syn-i-014', text: 'mīles {ducī} pāret', lemmaId: 'dux', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-i'}, tier: 1, note: 'Cui mīles pāret? ducī: datīvus singulāris apud verbum pārēre.'),
  Syntagma(id: 'syn-i-015', text: 'Aemilia {mātrī} respondet', lemmaId: 'mater', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-i'}, tier: 1, note: 'Respondet datīvum regit: cui respondet? mātrī, datīvus singulāris.'),
  Syntagma(id: 'syn-i-016', text: 'fīlius {patrī} dōnum dat', lemmaId: 'pater', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-i'}, tier: 1, note: 'Dat dōnum: cui dat? patrī, datīvus singulāris; dōnum accūsātīvus.'),
  Syntagma(id: 'syn-i-017', text: 'cīvēs {cōnsulī} pārent', lemmaId: 'consul', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-i'}, tier: 1, note: 'Pārent datīvum regit: cui pārent cīvēs? cōnsulī, datīvus singulāris.'),
  // abl. sg. 3rd neuter i-stem
  Syntagma(id: 'syn-i-018', text: 'piscēs in {marī} natant', lemmaId: 'mare', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-i'}, tier: 1, note: 'In cum verbō natant locum ubi significat: marī ablātīvus singulāris neutrī in -ī.'),
  Syntagma(id: 'syn-i-019', text: 'nautae in {marī} sunt', lemmaId: 'mare', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-i'}, tier: 1, note: 'Ubi sunt nautae? in marī: praepositiō in cum ablātīvō locum ubi ostendit.'),
  // locative
  Syntagma(id: 'syn-i-020', text: 'Iūlius {Tūsculī} habitat', lemmaId: 'tusculum', casus: Casus.locativus, number: Numerus.singularis, tags: {'syn-i'}, tier: 2, note: 'Ubi habitat Iūlius? Tūsculī: locātīvus nōminis oppidī, sine praepositiōne.'),
  Syntagma(id: 'syn-i-021', text: 'Mārcus {domī} manet', lemmaId: 'domus', casus: Casus.locativus, number: Numerus.singularis, tags: {'syn-i'}, tier: 2, note: 'Ubi manet Mārcus? domī: locātīvus nōminis domus, id est in domō suā.'),
  Syntagma(id: 'syn-i-022', text: 'mercātor {Corinthī} vīvit', lemmaId: 'corinthus', casus: Casus.locativus, number: Numerus.singularis, tags: {'syn-i'}, tier: 2, note: 'Ubi vīvit mercātor? Corinthī: locātīvus nōminis urbis, sine praepositiōne.'),

  // ───────────────────────── syn-o: -ō ─────────────────────────
  // dat. sg.
  Syntagma(id: 'syn-o-001', text: 'Iūlius {servō} pecūniam dat', lemmaId: 'servus', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 0, note: 'Dat pecūniam: cui dat? servō, datīvus singulāris; pecūniam accūsātīvus.'),
  Syntagma(id: 'syn-o-002', text: 'servus {dominō} pāret', lemmaId: 'dominus', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 1, note: 'Pāret datīvum regit: cui pāret servus? dominō, datīvus singulāris.'),
  Syntagma(id: 'syn-o-003', text: 'Mārcus {amīcō} respondet', lemmaId: 'amicus', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 1, note: 'Respondet datīvum regit: cui respondet Mārcus? amīcō, datīvus singulāris.'),
  Syntagma(id: 'syn-o-004', text: 'pater {fīliō} librum dat', lemmaId: 'filius', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 0, note: 'Dat librum: cui dat pater? fīliō, datīvus singulāris; librum obiectum.'),
  Syntagma(id: 'syn-o-005', text: 'lupus {agnō} nocet', lemmaId: 'agnus', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 1, note: 'Nocet datīvum regit: cui nocet lupus? agnō, datīvus singulāris.'),
  Syntagma(id: 'syn-o-006', text: 'mīlitēs {oppidō} appropinquant', lemmaId: 'oppidum', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 2, note: 'Appropinquant datīvum regit: cui appropinquant? oppidō, datīvus singulāris neutrī.'),
  Syntagma(id: 'syn-o-007', text: 'Iūlia {puerō} crēdit', lemmaId: 'puer', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 1, note: 'Crēdit datīvum regit: cui crēdit Iūlia? puerō, datīvus singulāris.'),
  Syntagma(id: 'syn-o-008', text: 'Aemilia {medicō} fīlium ostendit', lemmaId: 'medicus', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 1, note: 'Ostendit fīlium: cui ostendit? medicō, datīvus singulāris; fīlium accūsātīvus.'),
  Syntagma(id: 'syn-o-009', text: 'tempestās {templō} nocet', lemmaId: 'templum', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 1, note: 'Nocet datīvum regit: cui nocet tempestās? templō, datīvus singulāris neutrī.'),
  Syntagma(id: 'syn-o-010', text: 'cibus {equō} placet', lemmaId: 'equus', casus: Casus.dativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 1, note: 'Placet datīvum regit: cui placet cibus? equō, datīvus singulāris.'),
  // abl. sg.
  Syntagma(id: 'syn-o-011', text: 'Iūlius cum {servō} ambulat', lemmaId: 'servus', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 0, note: 'Praepositiō cum ablātīvum regit: servō ablātīvus singulāris comitātūs.'),
  Syntagma(id: 'syn-o-012', text: 'ancilla ā {dominō} laudātur', lemmaId: 'dominus', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 1, note: 'Ā cum verbō passīvō laudātur auctōrem significat: dominō ablātīvus singulāris.'),
  Syntagma(id: 'syn-o-013', text: 'Mārcus in {hortō} lūdit', lemmaId: 'hortus', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 0, note: 'In cum verbō lūdit locum ubi significat: hortō ablātīvus singulāris.'),
  Syntagma(id: 'syn-o-014', text: 'mīles {gladiō} pugnat', lemmaId: 'gladius', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 1, note: 'Quō īnstrūmentō pugnat mīles? gladiō: ablātīvus īnstrūmentī singulāris.'),
  Syntagma(id: 'syn-o-015', text: 'nauta ab {oppidō} discēdit', lemmaId: 'oppidum', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 0, note: 'Ab cum verbō discēdit locum unde significat: oppidō ablātīvus singulāris neutrī.'),
  Syntagma(id: 'syn-o-016', text: 'puer ē {lectō} surgit', lemmaId: 'lectus', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 0, note: 'Praepositiō ē ablātīvum regit: lectō ablātīvus singulāris, unde surgit puer.'),
  Syntagma(id: 'syn-o-017', text: 'Aemilia in {cubiculō} dormit', lemmaId: 'cubiculum', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 0, note: 'In cum verbō dormit locum ubi significat: cubiculō ablātīvus singulāris neutrī.'),
  Syntagma(id: 'syn-o-018', text: 'servus {baculō} verberātur', lemmaId: 'baculum', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 1, note: 'Quō īnstrūmentō verberātur servus? baculō: ablātīvus īnstrūmentī singulāris neutrī.'),
  Syntagma(id: 'syn-o-019', text: 'Quīntus sine {librō} venit', lemmaId: 'liber', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 0, note: 'Sine praepositiō ablātīvum regit: librō ablātīvus singulāris.'),
  Syntagma(id: 'syn-o-020', text: 'Iūlius ex {ātriō} exit', lemmaId: 'atrium', casus: Casus.ablativus, number: Numerus.singularis, tags: {'syn-o'}, tier: 0, note: 'Ex cum verbō exit locum unde significat: ātriō ablātīvus singulāris neutrī.'),

  // ───────────────────────── syn-um: -um ─────────────────────────
  // acc. sg. 2nd m.
  Syntagma(id: 'syn-um-001', text: 'Iūlius {servum} vocat', lemmaId: 'servus', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-um'}, tier: 0, note: 'Iūlius vocat: quem vocat? servum, obiectum verbī, accūsātīvus singulāris.'),
  Syntagma(id: 'syn-um-002', text: 'Mārcus {librum} legit', lemmaId: 'liber', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-um'}, tier: 0, note: 'Mārcus legit: quid legit? librum, obiectum verbī, accūsātīvus singulāris.'),
  Syntagma(id: 'syn-um-003', text: 'Aemilia {fīlium} amat', lemmaId: 'filius', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-um'}, tier: 0, note: 'Aemilia amat: quem amat? fīlium, obiectum verbī, accūsātīvus singulāris.'),
  // acc. sg. neuter 2nd
  Syntagma(id: 'syn-um-004', text: 'rēx {bellum} timet', lemmaId: 'bellum', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-um'}, tier: 1, note: 'Rēx subiectum est: quid timet? bellum, obiectum verbī, accūsātīvus singulāris neutrī.'),
  Syntagma(id: 'syn-um-005', text: 'Iūlius {templum} intrat', lemmaId: 'templum', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-um'}, tier: 1, note: 'Iūlius intrat: quid intrat? templum, obiectum verbī, accūsātīvus singulāris neutrī.'),
  Syntagma(id: 'syn-um-006', text: 'servus {pōculum} tenet', lemmaId: 'poculum', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-um'}, tier: 1, note: 'Servus tenet: quid tenet? pōculum, obiectum verbī, accūsātīvus singulāris neutrī.'),
  // acc. sg. 4th
  Syntagma(id: 'syn-um-007', text: 'Iūlia {manum} mātris tenet', lemmaId: 'manus', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-um'}, tier: 1, note: 'Iūlia tenet: quid tenet? manum mātris, obiectum verbī, accūsātīvus singulāris quārtae dēclīnātiōnis.'),
  Syntagma(id: 'syn-um-008', text: 'cōnsul {exercitum} dūcit', lemmaId: 'exercitus', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-um'}, tier: 1, note: 'Cōnsul dūcit: quid dūcit? exercitum, obiectum verbī, accūsātīvus singulāris quārtae dēclīnātiōnis.'),
  Syntagma(id: 'syn-um-009', text: 'mercātor in {portum} nāvigat', lemmaId: 'portus', casus: Casus.accusativus, number: Numerus.singularis, tags: {'syn-um'}, tier: 1, note: 'In cum verbō mōtūs nāvigat locum quō significat: portum accūsātīvus singulāris.'),
  // nom. sg. neuter
  Syntagma(id: 'syn-um-010', text: '{bellum} longum est', lemmaId: 'bellum', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-um'}, tier: 0, note: 'Bellum subiectum verbī est cum praedicātō longum: nōminātīvus singulāris neutrī.'),
  Syntagma(id: 'syn-um-011', text: '{templum} in forō stat', lemmaId: 'templum', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-um'}, tier: 0, note: 'Quid stat in forō? templum: subiectum verbī stat, nōminātīvus singulāris neutrī.'),
  Syntagma(id: 'syn-um-012', text: '{pōculum} plēnum est', lemmaId: 'poculum', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-um'}, tier: 0, note: 'Pōculum subiectum est, plēnum praedicātum: nōminātīvus singulāris neutrī.'),
  Syntagma(id: 'syn-um-013', text: '{oppidum} in monte est', lemmaId: 'oppidum', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-um'}, tier: 0, note: 'Quid in monte est? oppidum: subiectum verbī est, nōminātīvus singulāris neutrī.'),
  Syntagma(id: 'syn-um-014', text: '{vīnum} in pōculō est', lemmaId: 'vinum', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-um'}, tier: 0, note: 'Quid in pōculō est? vīnum: subiectum verbī est, nōminātīvus singulāris neutrī.'),
  // gen. pl. 3rd (consonant stems)
  Syntagma(id: 'syn-um-015', text: 'dux {mīlitum} fortis est', lemmaId: 'miles', casus: Casus.genetivus, number: Numerus.pluralis, tags: {'syn-um'}, tier: 1, note: 'Dux mīlitum: quōrum dux? mīlitum genetīvus plūrālis tertiae dēclīnātiōnis.'),
  Syntagma(id: 'syn-um-016', text: 'vōx {hominum} audītur', lemmaId: 'homo', casus: Casus.genetivus, number: Numerus.pluralis, tags: {'syn-um'}, tier: 2, note: 'Vōx hominum: quōrum vōx? hominum genetīvus plūrālis; audītur ad vōcem pertinet.'),
  Syntagma(id: 'syn-um-017', text: '{patrum} cōnsilia bona sunt', lemmaId: 'pater', casus: Casus.genetivus, number: Numerus.pluralis, tags: {'syn-um'}, tier: 2, note: 'Cōnsilia patrum: quōrum cōnsilia? patrum genetīvus plūrālis ad cōnsilia pertinet.'),
  Syntagma(id: 'syn-um-018', text: 'Mārcus nōmina {rēgum} discit', lemmaId: 'rex', casus: Casus.genetivus, number: Numerus.pluralis, tags: {'syn-um'}, tier: 1, note: 'Nōmina rēgum: quōrum nōmina? rēgum genetīvus plūrālis; nōmina obiectum verbī discit.'),
  // gen. pl. 1st/2nd (-ārum, -ōrum)
  Syntagma(id: 'syn-um-019', text: 'Iūlius dominus {servōrum} est', lemmaId: 'servus', casus: Casus.genetivus, number: Numerus.pluralis, tags: {'syn-um'}, tier: 0, note: 'Dominus servōrum: quōrum dominus? servōrum genetīvus plūrālis secundae dēclīnātiōnis.'),
  Syntagma(id: 'syn-um-020', text: 'magister {puerōrum} sevērus est', lemmaId: 'puer', casus: Casus.genetivus, number: Numerus.pluralis, tags: {'syn-um'}, tier: 0, note: 'Magister puerōrum: quōrum magister? puerōrum genetīvus plūrālis.'),
  Syntagma(id: 'syn-um-021', text: 'māter {puellārum} venit', lemmaId: 'puella', casus: Casus.genetivus, number: Numerus.pluralis, tags: {'syn-um'}, tier: 0, note: 'Māter puellārum: quārum māter? puellārum genetīvus plūrālis prīmae dēclīnātiōnis.'),
  Syntagma(id: 'syn-um-022', text: 'Iuppiter rēx {deōrum} est', lemmaId: 'deus', casus: Casus.genetivus, number: Numerus.pluralis, tags: {'syn-um'}, tier: 0, note: 'Rēx deōrum: quōrum rēx? deōrum genetīvus plūrālis secundae dēclīnātiōnis.'),
];
