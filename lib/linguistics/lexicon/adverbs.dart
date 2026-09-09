/// Adverbs and their degrees (A&G §214–§218): -ē from first-class
/// adjectives, -iter / -ter from the third class; comparative = neuter
/// comparative (-ius); superlative -issimē (-errimē, -illimē). Irregular
/// series are written out.
library;

import '../model/adverb.dart';

const _ag = 'A&G';

AdverbEntry _adv(String id, String pos, String comp, String sup, String gloss, {String? adj, String notes = '', List<String> prov = const ['$_ag §218']}) =>
    AdverbEntry(id: id, lemma: pos, comparative: comp.isEmpty ? const [] : comp.split('/').map((s) => s.trim()).toList(), superlative: sup.isEmpty ? const [] : sup.split('/').map((s) => s.trim()).toList(), glossFr: gloss, adjectiveId: adj, provenance: prov, notes: notes);

final List<AdverbEntry> kAdverbs = List.unmodifiable([
  // irregular series (A&G §218)
  _adv('bene', 'bene', 'melius', 'optimē', 'bien', adj: 'bonus', notes: 'Bene, melius, optimē.'),
  _adv('male', 'male', 'peius', 'pessimē', 'mal', adj: 'malus', notes: 'Male, peius, pessimē.'),
  _adv('magnopere', 'magnopere', 'magis', 'maximē', 'grandement; plus, le plus', adj: 'magnus', notes: 'Magnopere (magnō opere), magis, maximē.'),
  _adv('parum', 'parum', 'minus', 'minimē', 'trop peu; moins, le moins', adj: 'parvus', notes: 'Parum, minus, minimē.'),
  _adv('multum', 'multum', 'plūs', 'plūrimum', 'beaucoup; plus, le plus', adj: 'multus', notes: 'Multum, plūs, plūrimum.'),
  _adv('diu', 'diū', 'diūtius', 'diūtissimē', 'longtemps', notes: 'Diū, diūtius, diūtissimē.'),
  _adv('saepe', 'saepe', 'saepius', 'saepissimē', 'souvent'),
  _adv('prope', 'prope', 'propius', 'proximē', 'près', notes: 'Prope, propius, proximē.'),
  _adv('nuper', 'nūper', '', 'nūperrimē', 'récemment', notes: 'Comparātīvus dēest.'),
  _adv('potius', 'potius', 'potius', 'potissimum', 'plutôt; surtout', notes: 'Positīvum dēest: potius, potissimum.'),
  _adv('prius', 'prius', 'prius', 'prīmum / prīmō', 'auparavant; d’abord', notes: 'Positīvum dēest: prius, prīmum (prīmō).'),
  _adv('satis', 'satis', 'satius', '', 'assez; mieux, préférable', notes: 'Satis, satius; superlātīvus dēest.'),
  _adv('cito', 'cito', 'citius', 'citissimē', 'vite'),
  _adv('sero', 'sērō', 'sērius', 'sērissimē', 'tard'),
  // -ē from the first class
  _adv('longe', 'longē', 'longius', 'longissimē', 'loin', adj: 'longus'),
  _adv('alte', 'altē', 'altius', 'altissimē', 'haut, profondément', adj: 'altus'),
  _adv('late', 'lātē', 'lātius', 'lātissimē', 'largement', adj: 'latus'),
  _adv('laete', 'laetē', 'laetius', 'laetissimē', 'joyeusement', adj: 'laetus'),
  _adv('clare', 'clārē', 'clārius', 'clārissimē', 'clairement', adj: 'clarus'),
  _adv('docte', 'doctē', 'doctius', 'doctissimē', 'savamment', adj: 'doctus'),
  _adv('stulte', 'stultē', 'stultius', 'stultissimē', 'sottement', adj: 'stultus'),
  _adv('severe', 'sevērē', 'sevērius', 'sevērissimē', 'sévèrement', adj: 'severus'),
  _adv('care', 'cārē', 'cārius', 'cārissimē', 'chèrement', adj: 'carus'),
  _adv('iucunde', 'iūcundē', 'iūcundius', 'iūcundissimē', 'agréablement', adj: 'iucundus'),
  _adv('certe', 'certē', 'certius', 'certissimē', 'certainement', adj: 'certus'),
  _adv('tarde', 'tardē', 'tardius', 'tardissimē', 'lentement', adj: 'tardus'),
  _adv('digne', 'dignē', 'dignius', 'dignissimē', 'dignement', adj: 'dignus'),
  _adv('aeque', 'aequē', 'aequius', 'aequissimē', 'également', adj: 'aequus'),
  _adv('dure', 'dūrē', 'dūrius', 'dūrissimē', 'durement', adj: 'durus'),
  _adv('timide', 'timidē', 'timidius', 'timidissimē', 'timidement', adj: 'timidus'),
  _adv('pulchre', 'pulchrē', 'pulchrius', 'pulcherrimē', 'joliment', adj: 'pulcher', notes: 'Superlātīvus pulcherrimē (ab adiectīvō in -er).'),
  _adv('misere', 'miserē', 'miserius', 'miserrimē', 'misérablement', adj: 'miser'),
  _adv('libere', 'līberē', 'līberius', 'līberrimē', 'librement', adj: 'liber_adi'),
  _adv('aegre', 'aegrē', 'aegrius', 'aegerrimē', 'péniblement', adj: 'aeger'),
  // -iter / -ter from the third class
  _adv('fortiter', 'fortiter', 'fortius', 'fortissimē', 'courageusement', adj: 'fortis', notes: 'Fortius etiam neutrum comparātīvī adiectīvī est.'),
  _adv('breviter', 'breviter', 'brevius', 'brevissimē', 'brièvement', adj: 'brevis'),
  _adv('leviter', 'leviter', 'levius', 'levissimē', 'légèrement', adj: 'levis'),
  _adv('graviter', 'graviter', 'gravius', 'gravissimē', 'gravement', adj: 'gravis'),
  _adv('dulciter', 'dulciter', 'dulcius', 'dulcissimē', 'doucement', adj: 'dulcis'),
  _adv('turpiter', 'turpiter', 'turpius', 'turpissimē', 'honteusement', adj: 'turpis'),
  _adv('utiliter', 'ūtiliter', 'ūtilius', 'ūtilissimē', 'utilement', adj: 'utilis'),
  _adv('crudeliter', 'crūdēliter', 'crūdēlius', 'crūdēlissimē', 'cruellement', adj: 'crudelis'),
  _adv('fideliter', 'fidēliter', 'fidēlius', 'fidēlissimē', 'fidèlement', adj: 'fidelis'),
  _adv('similiter', 'similiter', 'similius', 'simillimē', 'semblablement', adj: 'similis', notes: 'Superlātīvus simillimē (ab -ilis).'),
  _adv('facile', 'facile', 'facilius', 'facillimē', 'facilement', adj: 'facilis', notes: 'Adverbium facile (neutrum), nōn faciliter; superlātīvus facillimē.'),
  _adv('difficulter', 'difficulter', 'difficilius', 'difficillimē', 'difficilement', adj: 'difficilis'),
  _adv('feliciter', 'fēlīciter', 'fēlīcius', 'fēlīcissimē', 'heureusement', adj: 'felix'),
  _adv('prudenter', 'prūdenter', 'prūdentius', 'prūdentissimē', 'prudemment', adj: 'prudens', notes: 'Themata in -nt-: -nter (prūdenter).'),
  _adv('audacter', 'audācter', 'audācius', 'audācissimē', 'audacieusement', adj: 'audax', notes: 'Audācter (audāciter), audācius, audācissimē.'),
  _adv('ferociter', 'ferōciter', 'ferōcius', 'ferōcissimē', 'farouchement', adj: 'ferox'),
  _adv('sapienter', 'sapienter', 'sapientius', 'sapientissimē', 'sagement', adj: 'sapiens'),
  _adv('diligenter', 'dīligenter', 'dīligentius', 'dīligentissimē', 'soigneusement', adj: 'diligens'),
  _adv('velociter', 'vēlōciter', 'vēlōcius', 'vēlōcissimē', 'rapidement', adj: 'velox'),
  _adv('acriter', 'ācriter', 'ācrius', 'ācerrimē', 'vivement', adj: 'acer', notes: 'Superlātīvus ācerrimē.'),
  _adv('celeriter', 'celeriter', 'celerius', 'celerrimē', 'rapidement', adj: 'celer'),
]);
