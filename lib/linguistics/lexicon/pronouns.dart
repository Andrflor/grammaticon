/// Pronoun paradigms of Grammaticon, typed from Allen & Greenough, *New Latin
/// Grammar* (1903; DCC edition), sections cited per entry. Nothing here is
/// derived: every cell is written out.
library;

import '../model/grammar.dart';
import '../model/pronoun.dart';

const _ag = 'A&G';
const _cases = ['nom', 'acc', 'gen', 'dat', 'abl'];

List<String> _alts(String s) => s.split('/').map((x) => x.trim()).toList();

/// Five cells (nom, acc, gen, dat, abl) of one number and gender; `-` skips
/// a cell; alternatives separated by `/`.
void _five(Map<String, List<String>> m, String number, String? gender, List<String> forms) {
  for (var i = 0; i < 5; i++) {
    if (forms[i] == '-') continue;
    m['${_cases[i]}.$number${gender == null ? '' : '.$gender'}'] = _alts(forms[i]);
  }
}

/// Paradigm with gender: singular m/f/n then plural m/f/n.
Map<String, List<String>> _gendered({
  required List<String> sgM,
  required List<String> sgF,
  required List<String> sgN,
  List<String>? plM,
  List<String>? plF,
  List<String>? plN,
}) {
  final m = <String, List<String>>{};
  _five(m, 'sg', 'm', sgM);
  _five(m, 'sg', 'f', sgF);
  _five(m, 'sg', 'n', sgN);
  if (plM != null) _five(m, 'pl', 'm', plM);
  if (plF != null) _five(m, 'pl', 'f', plF);
  if (plN != null) _five(m, 'pl', 'n', plN);
  return m;
}

/// Paradigm without gender (personal pronouns): singular then plural.
Map<String, List<String>> _personal(List<String> sg, List<String> pl, {String? vocSg, String? vocPl}) {
  final m = <String, List<String>>{};
  _five(m, 'sg', null, sg);
  _five(m, 'pl', null, pl);
  if (vocSg != null) m['voc.sg'] = _alts(vocSg);
  if (vocPl != null) m['voc.pl'] = _alts(vocPl);
  return m;
}

const _relativePlural = (m: ['quī', 'quōs', 'quōrum', 'quibus / quīs', 'quibus / quīs'], f: ['quae', 'quās', 'quārum', 'quibus / quīs', 'quibus / quīs'], n: ['quae', 'quae', 'quōrum', 'quibus / quīs', 'quibus / quīs']);

final List<PronounEntry> kPronouns = List.unmodifiable([
  // ------------------------------------------------------------ persōnālia (A&G §143)
  PronounEntry(
    id: 'ego',
    lemma: 'ego',
    entry: 'ego, meī; nōs, nostrum / nostrī',
    kind: PronounKind.personale,
    person: Person.prima,
    hasGender: false,
    glossFr: 'je, moi; nous',
    cells: _personal(['ego', 'mē', 'meī', 'mihi / mī', 'mē'], ['nōs', 'nōs', 'nostrum / nostrī', 'nōbīs', 'nōbīs']),
    provenance: ['$_ag §143'],
    notes: 'Mē accūsātīvus et ablātīvus; nōs nōminātīvus et accūsātīvus; nōbīs datīvus et ablātīvus. Nostrum partītīvus (ūnus nostrum), nostrī obiectīvus (memor nostrī).',
  ),
  PronounEntry(
    id: 'tu',
    lemma: 'tū',
    entry: 'tū, tuī; vōs, vestrum / vestrī',
    kind: PronounKind.personale,
    person: Person.secunda,
    hasGender: false,
    glossFr: 'tu, toi; vous',
    cells: _personal(['tū', 'tē', 'tuī', 'tibi', 'tē'], ['vōs', 'vōs', 'vestrum / vestrī', 'vōbīs', 'vōbīs'], vocSg: 'tū', vocPl: 'vōs'),
    provenance: ['$_ag §143'],
    notes: 'Tē accūsātīvus et ablātīvus; vōs nōminātīvus, vocātīvus et accūsātīvus; vōbīs datīvus et ablātīvus.',
  ),
  PronounEntry(
    id: 'se',
    lemma: 'sē',
    entry: 'sē (sēsē), suī, sibi',
    kind: PronounKind.reflexivum,
    person: Person.tertia,
    hasGender: false,
    glossFr: 'se, soi (réfléchi)',
    cells: _personal(['-', 'sē / sēsē', 'suī', 'sibi', 'sē / sēsē'], ['-', 'sē / sēsē', 'suī', 'sibi', 'sē / sēsē']),
    provenance: ['$_ag §144'],
    notes: 'Nōminātīvum nōn habet; eaedem fōrmae singulāris et plūrālis. Ad subiectum sententiae refertur.',
  ),
  // ------------------------------------------------------------ dēmōnstrātīva (A&G §146)
  PronounEntry(
    id: 'is',
    lemma: 'is',
    entry: 'is, ea, id',
    kind: PronounKind.demonstrativum,
    glossFr: 'il, elle; ce, celui-ci',
    correlative: 'qui',
    cells: _gendered(
      sgM: ['is', 'eum', 'eius', 'eī', 'eō'],
      sgF: ['ea', 'eam', 'eius', 'eī', 'eā'],
      sgN: ['id', 'id', 'eius', 'eī', 'eō'],
      plM: ['eī / iī / ī', 'eōs', 'eōrum', 'eīs / iīs / īs', 'eīs / iīs / īs'],
      plF: ['eae', 'eās', 'eārum', 'eīs / iīs / īs', 'eīs / iīs / īs'],
      plN: ['ea', 'ea', 'eōrum', 'eīs / iīs / īs', 'eīs / iīs / īs'],
    ),
    provenance: ['$_ag §146'],
    notes: 'Eī datīvus singulāris aut nōminātīvus plūrālis masculīnus; eīs datīvus et ablātīvus plūrālis; eius genetīvus omnium generum.',
  ),
  PronounEntry(
    id: 'hic',
    lemma: 'hic',
    entry: 'hic, haec, hoc',
    kind: PronounKind.demonstrativum,
    glossFr: 'celui-ci, ce … -ci',
    cells: _gendered(
      sgM: ['hic', 'hunc', 'huius', 'huic', 'hōc'],
      sgF: ['haec', 'hanc', 'huius', 'huic', 'hāc'],
      sgN: ['hoc', 'hoc', 'huius', 'huic', 'hōc'],
      plM: ['hī', 'hōs', 'hōrum', 'hīs', 'hīs'],
      plF: ['hae', 'hās', 'hārum', 'hīs', 'hīs'],
      plN: ['haec', 'haec', 'hōrum', 'hīs', 'hīs'],
    ),
    provenance: ['$_ag §146'],
    notes: 'Septem fōrmae propriae: hic, haec, hoc, hunc, hanc, huius, huic. Cēterae (hōc, hāc, hī, hae, hōs, hās, hōrum, hārum, hīs) dēsinentiās adiectīvī bonus sequuntur.',
  ),
  PronounEntry(
    id: 'ille',
    lemma: 'ille',
    entry: 'ille, illa, illud',
    kind: PronounKind.demonstrativum,
    glossFr: 'celui-là, ce … -là',
    cells: _gendered(
      sgM: ['ille', 'illum', 'illīus', 'illī', 'illō'],
      sgF: ['illa', 'illam', 'illīus', 'illī', 'illā'],
      sgN: ['illud', 'illud', 'illīus', 'illī', 'illō'],
      plM: ['illī', 'illōs', 'illōrum', 'illīs', 'illīs'],
      plF: ['illae', 'illās', 'illārum', 'illīs', 'illīs'],
      plN: ['illa', 'illa', 'illōrum', 'illīs', 'illīs'],
    ),
    provenance: ['$_ag §146'],
    notes: 'Ut bonus, praeter neutrum illud, genetīvum illīus et datīvum illī (ut adiectīva prōnōminālia).',
  ),
  PronounEntry(
    id: 'iste',
    lemma: 'iste',
    entry: 'iste, ista, istud',
    kind: PronounKind.demonstrativum,
    glossFr: 'celui-là (près de toi), ce … de toi',
    cells: _gendered(
      sgM: ['iste', 'istum', 'istīus', 'istī', 'istō'],
      sgF: ['ista', 'istam', 'istīus', 'istī', 'istā'],
      sgN: ['istud', 'istud', 'istīus', 'istī', 'istō'],
      plM: ['istī', 'istōs', 'istōrum', 'istīs', 'istīs'],
      plF: ['istae', 'istās', 'istārum', 'istīs', 'istīs'],
      plN: ['ista', 'ista', 'istōrum', 'istīs', 'istīs'],
    ),
    provenance: ['$_ag §146'],
    notes: 'Ut ille; ad secundam persōnam spectat, saepe cum contemptū.',
  ),
  PronounEntry(
    id: 'ipse',
    lemma: 'ipse',
    entry: 'ipse, ipsa, ipsum',
    kind: PronounKind.demonstrativum,
    glossFr: 'lui-même, même',
    cells: _gendered(
      sgM: ['ipse', 'ipsum', 'ipsīus', 'ipsī', 'ipsō'],
      sgF: ['ipsa', 'ipsam', 'ipsīus', 'ipsī', 'ipsā'],
      sgN: ['ipsum', 'ipsum', 'ipsīus', 'ipsī', 'ipsō'],
      plM: ['ipsī', 'ipsōs', 'ipsōrum', 'ipsīs', 'ipsīs'],
      plF: ['ipsae', 'ipsās', 'ipsārum', 'ipsīs', 'ipsīs'],
      plN: ['ipsa', 'ipsa', 'ipsōrum', 'ipsīs', 'ipsīs'],
    ),
    provenance: ['$_ag §146'],
    notes: 'Neutrum ipsum (nōn -ud); genetīvus ipsīus, datīvus ipsī.',
  ),
  PronounEntry(
    id: 'idem',
    lemma: 'īdem',
    entry: 'īdem, eadem, idem',
    kind: PronounKind.demonstrativum,
    glossFr: 'le même',
    cells: _gendered(
      sgM: ['īdem', 'eundem', 'eiusdem', 'eīdem', 'eōdem'],
      sgF: ['eadem', 'eandem', 'eiusdem', 'eīdem', 'eādem'],
      sgN: ['idem', 'idem', 'eiusdem', 'eīdem', 'eōdem'],
      plM: ['eīdem / īdem / iīdem', 'eōsdem', 'eōrundem', 'eīsdem / īsdem / iīsdem', 'eīsdem / īsdem / iīsdem'],
      plF: ['eaedem', 'eāsdem', 'eārundem', 'eīsdem / īsdem / iīsdem', 'eīsdem / īsdem / iīsdem'],
      plN: ['eadem', 'eadem', 'eōrundem', 'eīsdem / īsdem / iīsdem', 'eīsdem / īsdem / iīsdem'],
    ),
    provenance: ['$_ag §146'],
    notes: 'Is + -dem; m ante d in n mūtātur (eundem, eōrundem). Īdem masculīnum (ī longa), idem neutrum (i brevis).',
  ),
  // ------------------------------------------------------------ relātīvum et interrogātīva (A&G §147–§148)
  PronounEntry(
    id: 'qui',
    lemma: 'quī',
    entry: 'quī, quae, quod (relātīvum)',
    kind: PronounKind.relativum,
    glossFr: 'qui, que, lequel (relatif)',
    correlative: 'is',
    cells: _gendered(
      sgM: ['quī', 'quem', 'cuius', 'cui', 'quō / quī'],
      sgF: ['quae', 'quam', 'cuius', 'cui', 'quā'],
      sgN: ['quod', 'quod', 'cuius', 'cui', 'quō'],
      plM: _relativePlural.m,
      plF: _relativePlural.f,
      plN: _relativePlural.n,
    ),
    provenance: ['$_ag §147'],
    notes: 'Genus et numerus ab antecēdente, cāsus ā fūnctiōne in sententiā relātīvā sūmuntur. Quīcum = quōcum.',
  ),
  PronounEntry(
    id: 'quis',
    lemma: 'quis',
    entry: 'quis, quid (interrogātīvum)',
    kind: PronounKind.interrogativum,
    glossFr: 'qui ? quoi ? (interrogatif)',
    cells: _gendered(
      sgM: ['quis', 'quem', 'cuius', 'cui', 'quō'],
      sgF: ['quis / quae', 'quam', 'cuius', 'cui', 'quā'],
      sgN: ['quid', 'quid', 'cuius', 'cui', 'quō'],
      plM: _relativePlural.m,
      plF: _relativePlural.f,
      plN: _relativePlural.n,
    ),
    provenance: ['$_ag §148'],
    notes: 'Substantīvum quis, quid; adiectīvum quī, quae, quod ut relātīvum. Quem, cuius, cui, quō relātīvō et interrogātīvō commūnia sunt.',
  ),
  // ------------------------------------------------------------ indēfīnīta (A&G §149–§151)
  PronounEntry(
    id: 'aliquis',
    lemma: 'aliquis',
    entry: 'aliquis, aliquid; adi. aliquī, aliqua, aliquod',
    kind: PronounKind.indefinitum,
    glossFr: 'quelqu’un, quelque chose; quelque',
    cells: _gendered(
      sgM: ['aliquis / aliquī', 'aliquem', 'alicuius', 'alicui', 'aliquō'],
      sgF: ['aliqua', 'aliquam', 'alicuius', 'alicui', 'aliquā'],
      sgN: ['aliquid / aliquod', 'aliquid / aliquod', 'alicuius', 'alicui', 'aliquō'],
      plM: ['aliquī', 'aliquōs', 'aliquōrum', 'aliquibus', 'aliquibus'],
      plF: ['aliquae', 'aliquās', 'aliquārum', 'aliquibus', 'aliquibus'],
      plN: ['aliqua', 'aliqua', 'aliquōrum', 'aliquibus', 'aliquibus'],
    ),
    provenance: ['$_ag §151'],
    notes: 'Fēminīnum et neutrum plūrāle aliqua (nōn aliquae/aliquae). Post sī, nisi, nē, num: quis prō aliquis.',
  ),
  PronounEntry(
    id: 'quidam',
    lemma: 'quīdam',
    entry: 'quīdam, quaedam, quiddam (quoddam)',
    kind: PronounKind.indefinitum,
    glossFr: 'un certain, quelqu’un',
    cells: _gendered(
      sgM: ['quīdam', 'quendam', 'cuiusdam', 'cuidam', 'quōdam'],
      sgF: ['quaedam', 'quandam', 'cuiusdam', 'cuidam', 'quādam'],
      sgN: ['quiddam / quoddam', 'quiddam / quoddam', 'cuiusdam', 'cuidam', 'quōdam'],
      plM: ['quīdam', 'quōsdam', 'quōrundam', 'quibusdam', 'quibusdam'],
      plF: ['quaedam', 'quāsdam', 'quārundam', 'quibusdam', 'quibusdam'],
      plN: ['quaedam', 'quaedam', 'quōrundam', 'quibusdam', 'quibusdam'],
    ),
    provenance: ['$_ag §151'],
    notes: 'Quī + -dam; m ante d in n mūtātur (quendam, quōrundam).',
  ),
  PronounEntry(
    id: 'quisque',
    lemma: 'quisque',
    entry: 'quisque, quaeque, quidque (quodque)',
    kind: PronounKind.indefinitum,
    glossFr: 'chacun, chaque',
    cells: _gendered(
      sgM: ['quisque', 'quemque', 'cuiusque', 'cuique', 'quōque'],
      sgF: ['quaeque', 'quamque', 'cuiusque', 'cuique', 'quāque'],
      sgN: ['quidque / quodque', 'quidque / quodque', 'cuiusque', 'cuique', 'quōque'],
      plM: ['quīque', 'quōsque', 'quōrumque', 'quibusque', 'quibusque'],
      plF: ['quaeque', 'quāsque', 'quārumque', 'quibusque', 'quibusque'],
      plN: ['quaeque', 'quaeque', 'quōrumque', 'quibusque', 'quibusque'],
    ),
    provenance: ['$_ag §151'],
    notes: 'Cum superlātīvō et ōrdinālī: optimus quisque, quīntō quōque annō.',
  ),
  PronounEntry(
    id: 'quisquam',
    lemma: 'quisquam',
    entry: 'quisquam, quicquam (quidquam)',
    kind: PronounKind.indefinitum,
    glossFr: 'quelqu’un, quoi que ce soit (après négation)',
    cells: _gendered(
      sgM: ['quisquam', 'quemquam', 'cuiusquam', 'cuiquam', 'quōquam'],
      sgF: ['quisquam', 'quemquam', 'cuiusquam', 'cuiquam', 'quōquam'],
      sgN: ['quicquam / quidquam', 'quicquam / quidquam', 'cuiusquam', 'cuiquam', 'quōquam'],
    ),
    provenance: ['$_ag §151'],
    notes: 'Plūrālem nōn habet; in sententiīs negātīvīs (nec quisquam). Adiectīvum: ūllus.',
  ),
  PronounEntry(
    id: 'uterque',
    lemma: 'uterque',
    entry: 'uterque, utraque, utrumque',
    kind: PronounKind.indefinitum,
    glossFr: 'l’un et l’autre, chacun des deux',
    cells: _gendered(
      sgM: ['uterque', 'utrumque', 'utrīusque', 'utrīque', 'utrōque'],
      sgF: ['utraque', 'utramque', 'utrīusque', 'utrīque', 'utrāque'],
      sgN: ['utrumque', 'utrumque', 'utrīusque', 'utrīque', 'utrōque'],
      plM: ['utrīque', 'utrōsque', 'utrōrumque', 'utrīsque', 'utrīsque'],
      plF: ['utraeque', 'utrāsque', 'utrārumque', 'utrīsque', 'utrīsque'],
      plN: ['utraque', 'utraque', 'utrōrumque', 'utrīsque', 'utrīsque'],
    ),
    provenance: ['$_ag §151'],
    notes: 'Uter + -que; genetīvus utrīusque, datīvus utrīque.',
  ),
  PronounEntry(
    id: 'nemo',
    lemma: 'nēmō',
    entry: 'nēmō, nēminem; gen. nūllīus, abl. nūllō',
    kind: PronounKind.indefinitum,
    glossFr: 'personne',
    cells: _gendered(
      sgM: ['nēmō', 'nēminem', 'nūllīus', 'nēminī', 'nūllō'],
      sgF: ['nēmō', 'nēminem', 'nūllīus', 'nēminī', 'nūllō'],
      sgN: ['-', '-', '-', '-', '-'],
    ),
    provenance: ['$_ag §314'],
    notes: 'Dēfectīvum: genetīvus et ablātīvus ā nūllus sūmuntur (nūllīus, nūllō).',
  ),
  PronounEntry(
    id: 'nihil',
    lemma: 'nihil',
    entry: 'nihil (nīl); gen. nūllīus reī, abl. nūllā rē',
    kind: PronounKind.indefinitum,
    glossFr: 'rien',
    cells: _gendered(
      sgM: ['-', '-', '-', '-', '-'],
      sgF: ['-', '-', '-', '-', '-'],
      sgN: ['nihil / nīl', 'nihil / nīl', 'nūllīus reī', 'nūllī reī', 'nūllā rē'],
    ),
    provenance: ['$_ag §314'],
    notes: 'Dēfectīvum: cāsūs oblīquī ā nūlla rēs sūmuntur.',
  ),
  // ------------------------------------------------------------ correlātīva indēclīnābilia (A&G §152)
  PronounEntry(id: 'tot', lemma: 'tot', entry: 'tot (indēcl.)', kind: PronounKind.correlativum, hasGender: false, glossFr: 'tant de, autant de', correlative: 'quot', cells: {'indecl': ['tot']}, provenance: ['$_ag §152']),
  PronounEntry(id: 'quot', lemma: 'quot', entry: 'quot (indēcl.)', kind: PronounKind.correlativum, hasGender: false, glossFr: 'combien de, autant que', correlative: 'tot', cells: {'indecl': ['quot']}, provenance: ['$_ag §152']),
  PronounEntry(id: 'totiens', lemma: 'totiēns', entry: 'totiēns (adv.)', kind: PronounKind.correlativum, hasGender: false, glossFr: 'tant de fois', correlative: 'quotiens', cells: {'indecl': ['totiēns']}, provenance: ['$_ag §152']),
  PronounEntry(id: 'quotiens', lemma: 'quotiēns', entry: 'quotiēns (adv.)', kind: PronounKind.correlativum, hasGender: false, glossFr: 'combien de fois, toutes les fois que', correlative: 'totiens', cells: {'indecl': ['quotiēns']}, provenance: ['$_ag §152']),
  PronounEntry(id: 'tam', lemma: 'tam', entry: 'tam (adv.)', kind: PronounKind.correlativum, hasGender: false, glossFr: 'si, tellement', correlative: 'quam', cells: {'indecl': ['tam']}, provenance: ['$_ag §152']),
  PronounEntry(id: 'quam', lemma: 'quam', entry: 'quam (adv.)', kind: PronounKind.correlativum, hasGender: false, glossFr: 'que, combien', correlative: 'tam', cells: {'indecl': ['quam']}, provenance: ['$_ag §152']),
  PronounEntry(id: 'ibi', lemma: 'ibi', entry: 'ibi (adv.)', kind: PronounKind.correlativum, hasGender: false, glossFr: 'là', correlative: 'ubi', cells: {'indecl': ['ibi']}, provenance: ['$_ag §152']),
  PronounEntry(id: 'ubi', lemma: 'ubi', entry: 'ubi (adv.)', kind: PronounKind.correlativum, hasGender: false, glossFr: 'où', correlative: 'ibi', cells: {'indecl': ['ubi']}, provenance: ['$_ag §152']),
  PronounEntry(id: 'eo', lemma: 'eō', entry: 'eō (adv.)', kind: PronounKind.correlativum, hasGender: false, glossFr: 'là (vers)', correlative: 'quo', cells: {'indecl': ['eō']}, provenance: ['$_ag §152']),
  PronounEntry(id: 'quo', lemma: 'quō', entry: 'quō (adv.)', kind: PronounKind.correlativum, hasGender: false, glossFr: 'où (vers)', correlative: 'eo', cells: {'indecl': ['quō']}, provenance: ['$_ag §152']),
  PronounEntry(id: 'inde', lemma: 'inde', entry: 'inde (adv.)', kind: PronounKind.correlativum, hasGender: false, glossFr: 'de là', correlative: 'unde', cells: {'indecl': ['inde']}, provenance: ['$_ag §152']),
  PronounEntry(id: 'unde', lemma: 'unde', entry: 'unde (adv.)', kind: PronounKind.correlativum, hasGender: false, glossFr: 'd’où', correlative: 'inde', cells: {'indecl': ['unde']}, provenance: ['$_ag §152']),
  PronounEntry(id: 'tum', lemma: 'tum', entry: 'tum, tunc (adv.)', kind: PronounKind.correlativum, hasGender: false, glossFr: 'alors', correlative: 'quando', cells: {'indecl': ['tum', 'tunc']}, provenance: ['$_ag §152']),
  PronounEntry(id: 'quando', lemma: 'quandō', entry: 'quandō (adv.)', kind: PronounKind.correlativum, hasGender: false, glossFr: 'quand', correlative: 'tum', cells: {'indecl': ['quandō']}, provenance: ['$_ag §152']),
]);

/// Correlative pairs across word classes (adjectives tantus/quantus,
/// tālis/quālis live in the adjective lexicon).
const Map<String, String> kCorrelativa = {
  'tantus': 'quantus',
  'quantus': 'tantus',
  'talis': 'qualis',
  'qualis': 'talis',
  'tot': 'quot',
  'quot': 'tot',
  'totiens': 'quotiens',
  'quotiens': 'totiens',
  'tam': 'quam',
  'quam': 'tam',
  'ibi': 'ubi',
  'ubi': 'ibi',
  'eo': 'quo',
  'quo': 'eo',
  'inde': 'unde',
  'unde': 'inde',
  'tum': 'quando',
  'quando': 'tum',
  'is': 'qui',
  'idem': 'qui',
};
