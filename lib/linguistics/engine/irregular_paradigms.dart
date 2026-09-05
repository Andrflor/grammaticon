/// Present-system templates of the irregular verbs (A&G §170, §198–204).
///
/// Keys are selector blocks; six-cell blocks list persons in the order
/// 1 sg, 2 sg, 3 sg, 1 pl, 2 pl, 3 pl. Cells separate alternatives with `/`
/// (first = primary; `#kind` marks the variant kind). `-` marks a cell that
/// does not exist. Stem directives (`part.praes.act`, `gdv`, `ger`,
/// `part.fut.act`) give `nom/stem` or a bare stem; `-` means no such form.
///
/// The perfect system, participles derived from the supine and composite
/// forms are always produced by the regular rules from the principal parts.
/// Compounds obtain these templates with their prefix applied.
library;

const Map<String, Map<String, List<String>>> irregularTemplates = {
  // sum, esse, fuī, futūrus — A&G §170
  'sum': {
    'ind.praes.act': ['sum', 'es', 'est', 'sumus', 'estis', 'sunt'],
    'ind.imperf.act': ['eram', 'erās', 'erat', 'erāmus', 'erātis', 'erant'],
    'ind.fut.act': ['erō', 'eris', 'erit', 'erimus', 'eritis', 'erunt'],
    'subj.praes.act': ['sim', 'sīs', 'sit', 'sīmus', 'sītis', 'sint'],
    'subj.imperf.act': [
      'essem/forem#forem', 'essēs/forēs#forem', 'esset/foret#forem',
      'essēmus/forēmus#forem', 'essētis/forētis#forem', 'essent/forent#forem'
    ],
    'imp.praes.act': ['es', 'este'],
    'imp.fut.act': ['estō', 'estō', 'estōte', 'suntō'],
    'inf.praes.act': ['esse'],
    'inf.fut.act': ['fore#forem'],
    'part.praes.act': ['-'],
    'part.fut.act': ['futūr'],
    'gdv': ['-'],
    'ger': ['-'],
  },
  // possum, posse, potuī — A&G §198
  'possum': {
    'ind.praes.act': ['possum', 'potes', 'potest', 'possumus', 'potestis', 'possunt'],
    'ind.imperf.act': ['poteram', 'poterās', 'poterat', 'poterāmus', 'poterātis', 'poterant'],
    'ind.fut.act': ['poterō', 'poteris', 'poterit', 'poterimus', 'poteritis', 'poterunt'],
    'subj.praes.act': ['possim', 'possīs', 'possit', 'possīmus', 'possītis', 'possint'],
    'subj.imperf.act': ['possem', 'possēs', 'posset', 'possēmus', 'possētis', 'possent'],
    'inf.praes.act': ['posse'],
    'part.praes.act': ['potēns/potent'],
    'part.fut.act': ['-'],
    'gdv': ['-'],
    'ger': ['-'],
  },
  // eō, īre, iī (īvī), itum — A&G §203
  'eo': {
    'ind.praes.act': ['eō', 'īs', 'it', 'īmus', 'ītis', 'eunt'],
    'ind.imperf.act': ['ībam', 'ībās', 'ībat', 'ībāmus', 'ībātis', 'ībant'],
    'ind.fut.act': ['ībō', 'ībis', 'ībit', 'ībimus', 'ībitis', 'ībunt'],
    'subj.praes.act': ['eam', 'eās', 'eat', 'eāmus', 'eātis', 'eant'],
    'subj.imperf.act': ['īrem', 'īrēs', 'īret', 'īrēmus', 'īrētis', 'īrent'],
    'imp.praes.act': ['ī', 'īte'],
    'imp.fut.act': ['ītō', 'ītō', 'ītōte', 'euntō'],
    'inf.praes.act': ['īre'],
    'ind.praes.pass': ['eor', 'īris', 'ītur', 'īmur', 'īminī', 'euntur'],
    'ind.imperf.pass': ['ībar', 'ībāris', 'ībātur', 'ībāmur', 'ībāminī', 'ībantur'],
    'ind.fut.pass': ['ībor', 'īberis', 'ībitur', 'ībimur', 'ībiminī', 'ībuntur'],
    'subj.praes.pass': ['ear', 'eāris', 'eātur', 'eāmur', 'eāminī', 'eantur'],
    'subj.imperf.pass': ['īrer', 'īrēris', 'īrētur', 'īrēmur', 'īrēminī', 'īrentur'],
    'imp.praes.pass': ['īre', 'īminī'],
    'imp.fut.pass': ['ītor', 'ītor', 'euntor'],
    'inf.praes.pass': ['īrī'],
    'part.praes.act': ['iēns/eunt'],
    'gdv': ['eund'],
    'ger': ['eund'],
  },
  // ferō, ferre, tulī, lātum — A&G §200
  'fero': {
    'ind.praes.act': ['ferō', 'fers', 'fert', 'ferimus', 'fertis', 'ferunt'],
    'ind.imperf.act': ['ferēbam', 'ferēbās', 'ferēbat', 'ferēbāmus', 'ferēbātis', 'ferēbant'],
    'ind.fut.act': ['feram', 'ferēs', 'feret', 'ferēmus', 'ferētis', 'ferent'],
    'subj.praes.act': ['feram', 'ferās', 'ferat', 'ferāmus', 'ferātis', 'ferant'],
    'subj.imperf.act': ['ferrem', 'ferrēs', 'ferret', 'ferrēmus', 'ferrētis', 'ferrent'],
    'imp.praes.act': ['fer', 'ferte'],
    'imp.fut.act': ['fertō', 'fertō', 'fertōte', 'feruntō'],
    'inf.praes.act': ['ferre'],
    'ind.praes.pass': ['feror', 'ferris', 'fertur', 'ferimur', 'feriminī', 'feruntur'],
    'ind.imperf.pass': ['ferēbar', 'ferēbāris', 'ferēbātur', 'ferēbāmur', 'ferēbāminī', 'ferēbantur'],
    'ind.fut.pass': ['ferar', 'ferēris', 'ferētur', 'ferēmur', 'ferēminī', 'ferentur'],
    'subj.praes.pass': ['ferar', 'ferāris', 'ferātur', 'ferāmur', 'ferāminī', 'ferantur'],
    'subj.imperf.pass': ['ferrer', 'ferrēris', 'ferrētur', 'ferrēmur', 'ferrēminī', 'ferrentur'],
    'imp.praes.pass': ['ferre', 'feriminī'],
    'imp.fut.pass': ['fertor', 'fertor', 'feruntor'],
    'inf.praes.pass': ['ferrī'],
    'part.praes.act': ['ferēns/ferent'],
    'gdv': ['ferend'],
    'ger': ['ferend'],
  },
  // volō, velle, voluī — A&G §199
  'volo': {
    'ind.praes.act': ['volō', 'vīs', 'vult', 'volumus', 'vultis', 'volunt'],
    'ind.imperf.act': ['volēbam', 'volēbās', 'volēbat', 'volēbāmus', 'volēbātis', 'volēbant'],
    'ind.fut.act': ['volam', 'volēs', 'volet', 'volēmus', 'volētis', 'volent'],
    'subj.praes.act': ['velim', 'velīs', 'velit', 'velīmus', 'velītis', 'velint'],
    'subj.imperf.act': ['vellem', 'vellēs', 'vellet', 'vellēmus', 'vellētis', 'vellent'],
    'inf.praes.act': ['velle'],
    'part.praes.act': ['volēns/volent'],
    'part.fut.act': ['-'],
    'gdv': ['-'],
    'ger': ['-'],
  },
  // nōlō, nōlle, nōluī — A&G §199
  'nolo': {
    'ind.praes.act': ['nōlō', 'nōn vīs', 'nōn vult', 'nōlumus', 'nōn vultis', 'nōlunt'],
    'ind.imperf.act': ['nōlēbam', 'nōlēbās', 'nōlēbat', 'nōlēbāmus', 'nōlēbātis', 'nōlēbant'],
    'ind.fut.act': ['nōlam', 'nōlēs', 'nōlet', 'nōlēmus', 'nōlētis', 'nōlent'],
    'subj.praes.act': ['nōlim', 'nōlīs', 'nōlit', 'nōlīmus', 'nōlītis', 'nōlint'],
    'subj.imperf.act': ['nōllem', 'nōllēs', 'nōllet', 'nōllēmus', 'nōllētis', 'nōllent'],
    'imp.praes.act': ['nōlī', 'nōlīte'],
    'imp.fut.act': ['nōlītō', 'nōlītō', 'nōlītōte', 'nōluntō'],
    'inf.praes.act': ['nōlle'],
    'part.praes.act': ['nōlēns/nōlent'],
    'part.fut.act': ['-'],
    'gdv': ['-'],
    'ger': ['-'],
  },
  // mālō, mālle, māluī — A&G §199
  'malo': {
    'ind.praes.act': ['mālō', 'māvīs', 'māvult', 'mālumus', 'māvultis', 'mālunt'],
    'ind.imperf.act': ['mālēbam', 'mālēbās', 'mālēbat', 'mālēbāmus', 'mālēbātis', 'mālēbant'],
    'ind.fut.act': ['mālam', 'mālēs', 'mālet', 'mālēmus', 'mālētis', 'mālent'],
    'subj.praes.act': ['mālim', 'mālīs', 'mālit', 'mālīmus', 'mālītis', 'mālint'],
    'subj.imperf.act': ['māllem', 'māllēs', 'māllet', 'māllēmus', 'māllētis', 'māllent'],
    'inf.praes.act': ['mālle'],
    'part.praes.act': ['-'],
    'part.fut.act': ['-'],
    'gdv': ['-'],
    'ger': ['-'],
  },
  // fīō, fierī, factus sum — A&G §204 (passive of faciō)
  'fio': {
    'ind.praes.act': ['fīō', 'fīs', 'fit', 'fīmus', 'fītis', 'fīunt'],
    'ind.imperf.act': ['fīēbam', 'fīēbās', 'fīēbat', 'fīēbāmus', 'fīēbātis', 'fīēbant'],
    'ind.fut.act': ['fīam', 'fīēs', 'fīet', 'fīēmus', 'fīētis', 'fīent'],
    'subj.praes.act': ['fīam', 'fīās', 'fīat', 'fīāmus', 'fīātis', 'fīant'],
    'subj.imperf.act': ['fierem', 'fierēs', 'fieret', 'fierēmus', 'fierētis', 'fierent'],
    'imp.praes.act': ['fī', 'fīte'],
    'inf.praes.act': ['fierī'],
    'part.praes.act': ['-'],
    'part.fut.act': ['-'],
    'gdv': ['faciend'],
    'ger': ['-'],
  },
  // edō, edere (ēsse), ēdī, ēsum — A&G §201
  'edo': {
    'ind.praes.act': ['edō', 'edis/ēs', 'edit/ēst', 'edimus', 'editis/ēstis', 'edunt'],
    'ind.imperf.act': ['edēbam', 'edēbās', 'edēbat', 'edēbāmus', 'edēbātis', 'edēbant'],
    'ind.fut.act': ['edam', 'edēs', 'edet', 'edēmus', 'edētis', 'edent'],
    'subj.praes.act': ['edam/edim#arch', 'edās/edīs#arch', 'edat/edit#arch', 'edāmus/edīmus#arch', 'edātis/edītis#arch', 'edant/edint#arch'],
    'subj.imperf.act': ['ederem/ēssem', 'ederēs/ēssēs', 'ederet/ēsset', 'ederēmus/ēssēmus', 'ederētis/ēssētis', 'ederent/ēssent'],
    'imp.praes.act': ['ede/ēs', 'edite/ēste'],
    'imp.fut.act': ['editō/ēstō', 'editō/ēstō', 'editōte/ēstōte', 'eduntō'],
    'inf.praes.act': ['edere/ēsse'],
    'ind.praes.pass': ['edor', 'ederis', 'editur/ēstur', 'edimur', 'ediminī', 'eduntur'],
    'ind.imperf.pass': ['edēbar', 'edēbāris', 'edēbātur', 'edēbāmur', 'edēbāminī', 'edēbantur'],
    'ind.fut.pass': ['edar', 'edēris', 'edētur', 'edēmur', 'edēminī', 'edentur'],
    'subj.praes.pass': ['edar', 'edāris', 'edātur', 'edāmur', 'edāminī', 'edantur'],
    'subj.imperf.pass': ['ederer', 'ederēris', 'ederētur/ēssētur', 'ederēmur', 'ederēminī', 'ederentur'],
    'imp.praes.pass': ['edere', 'ediminī'],
    'imp.fut.pass': ['editor', 'editor', 'eduntor'],
    'inf.praes.pass': ['edī'],
    'part.praes.act': ['edēns/edent'],
    'gdv': ['edend'],
    'ger': ['edend'],
  },
};

/// Present-system passive of faciō is supplied by fīō (A&G §204).
const Map<String, List<String>> facioPassiveFromFio = {
  'ind.praes.pass': ['fīō', 'fīs', 'fit', 'fīmus', 'fītis', 'fīunt'],
  'ind.imperf.pass': ['fīēbam', 'fīēbās', 'fīēbat', 'fīēbāmus', 'fīēbātis', 'fīēbant'],
  'ind.fut.pass': ['fīam', 'fīēs', 'fīet', 'fīēmus', 'fīētis', 'fīent'],
  'subj.praes.pass': ['fīam', 'fīās', 'fīat', 'fīāmus', 'fīātis', 'fīant'],
  'subj.imperf.pass': ['fierem', 'fierēs', 'fieret', 'fierēmus', 'fierētis', 'fierent'],
  'imp.praes.pass': ['fī', 'fīte'],
  'imp.fut.pass': ['-', '-', '-'],
  'inf.praes.pass': ['fierī'],
  'imp.praes.act': ['fac', 'facite'],
};
