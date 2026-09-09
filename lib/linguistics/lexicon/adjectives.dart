/// Verified adjective lexicon of Grammaticon (Allen & Greenough §109–§131,
/// §113 pronominal adjectives, §134 ordinals). The lexicon is a representative
/// corpus of every declension pattern and every irregular comparison, drawn
/// from the vocabulary of *Lingua Latina per se illustrata* (ch. 1–19); it is
/// not a dictionary. Irregular cells go in `overrides`.
library;

import '../model/adjective.dart';

const _ag = 'A&G';

/// First-class adjective in -us, -a, -um.
AdjectiveEntry _a12(String id, String lemma, String stem, String gloss, {ComparisonKind comparison = ComparisonKind.regularis, String? comparative, String? superlativeStem, Set<String> tags = const {}, Map<String, List<String>> overrides = const {}, List<String> prov = const ['$_ag §110'], String notes = ''}) =>
    AdjectiveEntry(id: id, lemma: lemma, entry: '$lemma, -a, -um', cls: AdjClass.primaSecunda, stem: stem, glossFr: gloss, comparison: comparison, comparative: comparative, superlativeStem: superlativeStem, tags: tags, overrides: overrides, provenance: prov, notes: notes);

/// First-class adjective in -er (pulcher, -chra, -chrum; miser, -era, -erum).
AdjectiveEntry _er(String id, String lemma, String stem, String gloss, {ComparisonKind comparison = ComparisonKind.regularis, Set<String> tags = const {}, Map<String, List<String>> overrides = const {}, String notes = '', String? superlativeStem}) =>
    AdjectiveEntry(id: id, lemma: lemma, entry: '$lemma, ${stem}a, ${stem}um', cls: AdjClass.primaSecunda, stem: stem, nomM: lemma, glossFr: gloss, comparison: comparison, superlativeStem: superlativeStem, tags: {'er', ...tags}, overrides: overrides, provenance: const ['$_ag §111', '$_ag §112'], notes: notes);

/// Pronominal adjective (genitive -īus, dative -ī; A&G §113).
AdjectiveEntry _pron(String id, String lemma, String stem, String gloss, {String? nomM, String? nomN, Map<String, List<String>> overrides = const {}, String notes = '', Set<String> tags = const {}}) => AdjectiveEntry(
      id: id,
      lemma: lemma,
      entry: '$lemma, ${nomM == null ? '-a, -um' : '${stem}a, ${nomN ?? '${stem}um'}'}',
      cls: AdjClass.primaSecunda,
      stem: stem,
      nomM: nomM,
      nomN: nomN,
      glossFr: gloss,
      pronominal: true,
      comparison: ComparisonKind.nulla,
      overrides: overrides,
      absent: const ['voc'],
      tags: {'pronominale', ...tags},
      provenance: const ['$_ag §113'],
      notes: notes.isEmpty ? 'Genetīvus -īus, datīvus -ī in tribus generibus.' : notes,
    );

/// Third-class adjective, two terminations (fortis, -e).
AdjectiveEntry _a3duo(String id, String lemma, String stem, String gloss, {ComparisonKind comparison = ComparisonKind.regularis, Set<String> tags = const {}, String? superlativeStem, String? comparative, Map<String, List<String>> overrides = const {}, String notes = ''}) =>
    AdjectiveEntry(id: id, lemma: lemma, entry: '$lemma, -e', cls: AdjClass.tertia, stem: stem, terminations: 2, glossFr: gloss, comparison: comparison, comparative: comparative, superlativeStem: superlativeStem, tags: tags, overrides: overrides, provenance: const ['$_ag §116'], notes: notes);

/// Third-class adjective, one termination (fēlīx, -īcis).
AdjectiveEntry _a3una(String id, String lemma, String genitive, String stem, String gloss, {bool consonantStem = false, ComparisonKind comparison = ComparisonKind.regularis, String? comparative, String? superlativeStem, Set<String> tags = const {}, Map<String, List<String>> overrides = const {}, String notes = ''}) =>
    AdjectiveEntry(id: id, lemma: lemma, entry: '$lemma, $genitive', cls: AdjClass.tertia, stem: stem, terminations: 1, nomM: lemma, glossFr: gloss, consonantStem: consonantStem, comparison: comparison, comparative: comparative, superlativeStem: superlativeStem, tags: tags, overrides: overrides, provenance: [consonantStem ? '$_ag §121' : '$_ag §117', '$_ag §118'], notes: notes);

/// Third-class adjective, three terminations (ācer, ācris, ācre).
AdjectiveEntry _a3tria(String id, String lemma, String stem, String gloss, {ComparisonKind comparison = ComparisonKind.regularis, String? superlativeStem, Set<String> tags = const {}, String notes = ''}) =>
    AdjectiveEntry(id: id, lemma: lemma, entry: '$lemma, ${stem}is, ${stem}e', cls: AdjClass.tertia, stem: stem, terminations: 3, nomM: lemma, nomF: '${stem}is', nomN: '${stem}e', glossFr: gloss, comparison: comparison, superlativeStem: superlativeStem, tags: tags, provenance: const ['$_ag §115'], notes: notes);

/// Ordinal numeral (first class).
AdjectiveEntry _ord(String id, String lemma, String stem, int value, String gloss) => AdjectiveEntry(id: id, lemma: lemma, entry: '$lemma, -a, -um', cls: AdjClass.primaSecunda, stem: stem, glossFr: gloss, comparison: ComparisonKind.nulla, tags: const {'ordinale', 'numerale'}, ordinalValue: value, provenance: const ['$_ag §134']);

/// Comparative without positive (prior, ulterior): lemma is the comparative.
AdjectiveEntry _compOnly(String id, String comparative, String superlativeStem, String gloss, {String notes = ''}) => AdjectiveEntry(
      id: id,
      lemma: comparative,
      entry: '$comparative, -ius; ${superlativeStem}us',
      cls: AdjClass.tertia,
      stem: comparative,
      glossFr: gloss,
      hasPositive: false,
      comparison: ComparisonKind.irregularis,
      comparative: comparative,
      superlativeStem: superlativeStem,
      tags: const {'comp-irreg'},
      provenance: const ['$_ag §130'],
      notes: notes.isEmpty ? 'Positīvum dēest (ā praepositiōne aut adverbiō dērīvātum).' : notes,
    );

final List<AdjectiveEntry> kAdjectives = List.unmodifiable([
  // ------------------------------------------------------------ prīma et secunda (A&G §110)
  _a12('bonus', 'bonus', 'bon', 'bon', comparison: ComparisonKind.irregularis, comparative: 'melior', superlativeStem: 'optim', tags: {'comp-irreg'}, prov: ['$_ag §110', '$_ag §129'], notes: 'Comparātiō irregulāris: bonus, melior (melius), optimus.'),
  _a12('malus', 'malus', 'mal', 'mauvais', comparison: ComparisonKind.irregularis, comparative: 'peior', superlativeStem: 'pessim', tags: {'comp-irreg'}, prov: ['$_ag §110', '$_ag §129'], notes: 'Malus, peior (peius), pessimus.'),
  _a12('magnus', 'magnus', 'magn', 'grand', comparison: ComparisonKind.irregularis, comparative: 'maior', superlativeStem: 'maxim', tags: {'comp-irreg'}, prov: ['$_ag §110', '$_ag §129'], notes: 'Magnus, maior (maius), maximus.'),
  _a12('parvus', 'parvus', 'parv', 'petit', comparison: ComparisonKind.irregularis, comparative: 'minor', superlativeStem: 'minim', tags: {'comp-irreg'}, prov: ['$_ag §110', '$_ag §129'], notes: 'Parvus, minor (minus), minimus.'),
  _a12(
    'multus',
    'multus',
    'mult',
    'nombreux, beaucoup de',
    comparison: ComparisonKind.irregularis,
    comparative: 'plūs',
    superlativeStem: 'plūrim',
    tags: {'comp-irreg'},
    overrides: {
      // plūs: neuter singular noun-like, plural plūrēs/plūra (A&G §129, §120b).
      'comp.nom.sg.m': [], 'comp.acc.sg.m': [], 'comp.gen.sg.m': [], 'comp.dat.sg.m': [], 'comp.abl.sg.m': [], 'comp.voc.sg.m': [],
      'comp.nom.sg.f': [], 'comp.acc.sg.f': [], 'comp.gen.sg.f': [], 'comp.dat.sg.f': [], 'comp.abl.sg.f': [], 'comp.voc.sg.f': [],
      'comp.nom.sg.n': ['plūs'], 'comp.voc.sg.n': [], 'comp.acc.sg.n': ['plūs'], 'comp.gen.sg.n': ['plūris'], 'comp.dat.sg.n': [], 'comp.abl.sg.n': ['plūre'],
      'comp.nom.pl.m': ['plūrēs'], 'comp.voc.pl.m': ['plūrēs'], 'comp.acc.pl.m': ['plūrēs', 'plūrīs'], 'comp.gen.pl.m': ['plūrium'], 'comp.dat.pl.m': ['plūribus'], 'comp.abl.pl.m': ['plūribus'],
      'comp.nom.pl.f': ['plūrēs'], 'comp.voc.pl.f': ['plūrēs'], 'comp.acc.pl.f': ['plūrēs', 'plūrīs'], 'comp.gen.pl.f': ['plūrium'], 'comp.dat.pl.f': ['plūribus'], 'comp.abl.pl.f': ['plūribus'],
      'comp.nom.pl.n': ['plūra'], 'comp.voc.pl.n': ['plūra'], 'comp.acc.pl.n': ['plūra'], 'comp.gen.pl.n': ['plūrium'], 'comp.dat.pl.n': ['plūribus'], 'comp.abl.pl.n': ['plūribus'],
    },
    prov: ['$_ag §110', '$_ag §129'],
    notes: 'Multus, plūs (neutrum singulāre: plūs, plūris, plūre; plūrālis plūrēs, plūra, plūrium), plūrimus.',
  ),
  _a12('longus', 'longus', 'long', 'long'),
  _a12('altus', 'altus', 'alt', 'haut, profond'),
  _a12('latus', 'lātus', 'lāt', 'large'),
  _a12('novus', 'novus', 'nov', 'nouveau', notes: 'Comparātīvus recentior ūsitātior; superlātīvus novissimus.'),
  _a12('antiquus', 'antīquus', 'antīqu', 'ancien'),
  _a12('laetus', 'laetus', 'laet', 'joyeux'),
  _a12('plenus', 'plēnus', 'plēn', 'plein'),
  _a12('vacuus', 'vacuus', 'vacu', 'vide', comparison: ComparisonKind.periphrastica, notes: 'Adiectīva in -uus comparātiōnem perīphrasticam habent: magis vacuus, maximē vacuus.'),
  _a12('idoneus', 'idōneus', 'idōne', 'convenable', comparison: ComparisonKind.periphrastica, notes: 'Adiectīva in -eus: magis idōneus, maximē idōneus.'),
  _a12('clarus', 'clārus', 'clār', 'clair, célèbre'),
  _a12('doctus', 'doctus', 'doct', 'savant'),
  _a12('stultus', 'stultus', 'stult', 'sot'),
  _a12('probus', 'probus', 'prob', 'honnête'),
  _a12('improbus', 'improbus', 'improb', 'malhonnête'),
  _a12('severus', 'sevērus', 'sevēr', 'sévère'),
  _a12('carus', 'cārus', 'cār', 'cher'),
  _a12('iucundus', 'iūcundus', 'iūcund', 'agréable'),
  _a12('amicus_adi', 'amīcus', 'amīc', 'ami, amical'),
  _a12('inimicus_adi', 'inimīcus', 'inimīc', 'ennemi, hostile'),
  _a12('certus', 'certus', 'cert', 'certain'),
  _a12('tardus', 'tardus', 'tard', 'lent'),
  _a12('vivus', 'vīvus', 'vīv', 'vivant', comparison: ComparisonKind.nulla),
  _a12('mortuus', 'mortuus', 'mortu', 'mort', comparison: ComparisonKind.nulla),
  _a12('dignus', 'dignus', 'dign', 'digne'),
  _a12('aequus', 'aequus', 'aequ', 'égal, juste'),
  _a12('albus', 'albus', 'alb', 'blanc'),
  _a12('candidus', 'candidus', 'candid', 'blanc éclatant'),
  _a12('durus', 'dūrus', 'dūr', 'dur'),
  _a12('calidus', 'calidus', 'calid', 'chaud'),
  _a12('frigidus', 'frīgidus', 'frīgid', 'froid'),
  _a12('timidus', 'timidus', 'timid', 'craintif'),
  _a12('cupidus', 'cupidus', 'cupid', 'désireux'),
  _a12('aegrotus', 'aegrōtus', 'aegrōt', 'malade', comparison: ComparisonKind.nulla),
  _a12('sanus', 'sānus', 'sān', 'sain, bien portant'),
  _a12('romanus', 'Rōmānus', 'Rōmān', 'romain', comparison: ComparisonKind.nulla),
  _a12('graecus', 'Graecus', 'Graec', 'grec', comparison: ComparisonKind.nulla),
  _a12('latinus', 'Latīnus', 'Latīn', 'latin', comparison: ComparisonKind.nulla),
  _a12('medius', 'medius', 'medi', 'du milieu', comparison: ComparisonKind.nulla),
  _a12('pauci', 'paucī', 'pauc', 'peu nombreux', comparative: 'paucior', superlativeStem: 'paucissim', notes: 'Plūrālī ferē ūsitātum.'),
  _a12('ceteri', 'cēterī', 'cēter', 'les autres', comparison: ComparisonKind.nulla, notes: 'Plūrāle tantum ferē.'),
  _a12('dexter', 'dexter', 'dextr', 'droit', comparison: ComparisonKind.irregularis, comparative: 'dexterior', superlativeStem: 'dextim', overrides: {'nom.sg.m': ['dexter'], 'voc.sg.m': ['dexter'], 'nom.sg.f': ['dextra', 'dextera'], 'voc.sg.f': ['dextra', 'dextera']}, prov: ['$_ag §111a', '$_ag §130'], notes: 'Dexter, dextra (dextera), dextrum; dexterior, dextimus.'),
  // ------------------------------------------------------------ in -er (A&G §111–§112)
  _er('pulcher', 'pulcher', 'pulchr', 'beau', notes: 'E cadit: pulchra, pulchrum; superlātīvus pulcherrimus.'),
  _er('miser', 'miser', 'miser', 'malheureux', notes: 'E manet: misera, miserum; superlātīvus miserrimus.'),
  _er('aeger', 'aeger', 'aegr', 'malade'),
  _er('niger', 'niger', 'nigr', 'noir'),
  _er('ruber', 'ruber', 'rubr', 'rouge'),
  _er('piger', 'piger', 'pigr', 'paresseux'),
  _er('sacer', 'sacer', 'sacr', 'sacré', comparison: ComparisonKind.nulla),
  _er('liber_adi', 'līber', 'līber', 'libre', notes: 'E manet: lībera, līberum; superlātīvus līberrimus.'),
  _er('tener', 'tener', 'tener', 'tendre'),
  _er('asper', 'asper', 'asper', 'rude'),
  _er('sinister', 'sinister', 'sinistr', 'gauche', comparison: ComparisonKind.nulla),
  // possessives (A&G §145)
  _a12('meus', 'meus', 'me', 'mon, mien', comparison: ComparisonKind.nulla, tags: {'possessivum'}, overrides: {'voc.sg.m': ['mī', 'meus']}, prov: ['$_ag §145'], notes: 'Vocātīvus mī (mī fīlī).'),
  _a12('tuus', 'tuus', 'tu', 'ton, tien', comparison: ComparisonKind.nulla, tags: {'possessivum'}, prov: ['$_ag §145'], notes: 'Vocātīvum nōn habet.'),
  _a12('suus', 'suus', 'su', 'son, sien (réfléchi)', comparison: ComparisonKind.nulla, tags: {'possessivum'}, prov: ['$_ag §145'], notes: 'Ad subiectum refertur: Iūlius fīlium suum vocat (fīlium ipsīus Iūliī).'),
  _er('noster', 'noster', 'nostr', 'notre', comparison: ComparisonKind.nulla, tags: {'possessivum'}),
  _er('vester', 'vester', 'vestr', 'votre', comparison: ComparisonKind.nulla, tags: {'possessivum'}),
  // ------------------------------------------------------------ prōnōminālia (A&G §113)
  _pron('unus', 'ūnus', 'ūn', 'un, un seul', tags: {'numerale', 'cardinale'}, notes: 'Genetīvus ūnīus, datīvus ūnī; plūrālis cum plūrālibus tantum (ūna castra).'),
  _pron('solus', 'sōlus', 'sōl', 'seul'),
  _pron('totus', 'tōtus', 'tōt', 'tout entier'),
  _pron('alius', 'alius', 'ali', 'autre (parmi plusieurs)', nomM: 'alius', nomN: 'aliud', overrides: {'gen.sg.m': ['alīus', 'alterīus'], 'gen.sg.f': ['alīus', 'alterīus'], 'gen.sg.n': ['alīus', 'alterīus']}, notes: 'Neutrum aliud; genetīvus alīus rārus, alterīus saepe prō eō.'),
  _pron('alter', 'alter', 'alter', 'l’autre (de deux)', nomM: 'alter', notes: 'Alter, altera, alterum; genetīvus alterīus (i brevis), datīvus alterī.'),
  _pron('uter', 'uter', 'utr', 'lequel des deux', nomM: 'uter', notes: 'Uter, utra, utrum; utrīus, utrī.'),
  _pron('neuter', 'neuter', 'neutr', 'ni l’un ni l’autre', nomM: 'neuter', notes: 'Neuter, neutra, neutrum; neutrīus, neutrī.'),
  _pron('nullus', 'nūllus', 'nūll', 'aucun', notes: 'Nūllīus et nūllō genetīvum et ablātīvum nēminī praebent.'),
  _pron('ullus', 'ūllus', 'ūll', 'quelque (après négation)'),
  // ------------------------------------------------------------ tertia: duae termīnātiōnēs (A&G §116)
  _a3duo('fortis', 'fortis', 'fort', 'courageux, fort'),
  _a3duo('omnis', 'omnis', 'omn', 'tout, chaque', comparison: ComparisonKind.nulla),
  _a3duo('brevis', 'brevis', 'brev', 'court'),
  _a3duo('levis', 'levis', 'lev', 'léger'),
  _a3duo('gravis', 'gravis', 'grav', 'lourd, grave'),
  _a3duo('dulcis', 'dulcis', 'dulc', 'doux'),
  _a3duo('tristis', 'trīstis', 'trīst', 'triste'),
  _a3duo('turpis', 'turpis', 'turp', 'honteux'),
  _a3duo('utilis', 'ūtilis', 'ūtil', 'utile'),
  _a3duo('nobilis', 'nōbilis', 'nōbil', 'noble'),
  _a3duo('mortalis', 'mortālis', 'mortāl', 'mortel'),
  _a3duo('facilis', 'facilis', 'facil', 'facile', tags: {'ilis'}, notes: 'Superlātīvus facillimus (sex adiectīva in -ilis: facilis, difficilis, similis, dissimilis, gracilis, humilis).'),
  _a3duo('difficilis', 'difficilis', 'difficil', 'difficile', tags: {'ilis'}, notes: 'Superlātīvus difficillimus.'),
  _a3duo('similis', 'similis', 'simil', 'semblable', tags: {'ilis'}, notes: 'Superlātīvus simillimus.'),
  _a3duo('dissimilis', 'dissimilis', 'dissimil', 'dissemblable', tags: {'ilis'}),
  _a3duo('humilis', 'humilis', 'humil', 'bas, humble', tags: {'ilis'}),
  _a3duo('gracilis', 'gracilis', 'gracil', 'mince', tags: {'ilis'}),
  _a3duo('talis', 'tālis', 'tāl', 'tel', comparison: ComparisonKind.nulla, tags: {'correlativum'}),
  _a3duo('qualis', 'quālis', 'quāl', 'quel, tel que', comparison: ComparisonKind.nulla, tags: {'correlativum'}),
  _a3duo('mollis', 'mollis', 'moll', 'mou, souple'),
  _a3duo('tenuis', 'tenuis', 'tenu', 'fin, mince'),
  _a3duo('crudelis', 'crūdēlis', 'crūdēl', 'cruel'),
  _a3duo('fidelis', 'fidēlis', 'fidēl', 'fidèle'),
  _a3duo('communis', 'commūnis', 'commūn', 'commun'),
  _a3duo('immortalis', 'immortālis', 'immortāl', 'immortel', comparison: ComparisonKind.nulla),
  // ------------------------------------------------------------ tertia: ūna termīnātiō (A&G §117–§118, §121)
  _a3una('felix', 'fēlīx', 'fēlīcis', 'fēlīc', 'heureux'),
  _a3una('ingens', 'ingēns', 'ingentis', 'ingent', 'énorme'),
  _a3una('prudens', 'prūdēns', 'prūdentis', 'prūdent', 'avisé'),
  _a3una('audax', 'audāx', 'audācis', 'audāc', 'audacieux'),
  _a3una('ferox', 'ferōx', 'ferōcis', 'ferōc', 'farouche'),
  _a3una('sapiens', 'sapiēns', 'sapientis', 'sapient', 'sage'),
  _a3una('diligens', 'dīligēns', 'dīligentis', 'dīligent', 'appliqué'),
  _a3una('potens', 'potēns', 'potentis', 'potent', 'puissant'),
  _a3una('velox', 'vēlōx', 'vēlōcis', 'vēlōc', 'rapide'),
  _a3una('atrox', 'atrōx', 'atrōcis', 'atrōc', 'atroce'),
  _a3una('par', 'pār', 'paris', 'par', 'égal', comparison: ComparisonKind.nulla, notes: 'Ablātīvus parī, genetīvus plūrālis parium.'),
  _a3una('vetus', 'vetus', 'veteris', 'veter', 'vieux', consonantStem: true, comparison: ComparisonKind.irregularis, comparative: 'vetustior', superlativeStem: 'veterrim', overrides: {'nom.sg.n': ['vetus'], 'voc.sg.n': ['vetus'], 'acc.sg.n': ['vetus']}, tags: {'comp-irreg'}, notes: 'Thema cōnsonāns: vetere, veterum, vetera. Comparātiō: vetustior, veterrimus.'),
  _a3una('pauper', 'pauper', 'pauperis', 'pauper', 'pauvre', consonantStem: true, notes: 'Thema cōnsonāns: paupere, pauperum, paupera.'),
  _a3una('dives', 'dīves', 'dīvitis', 'dīvit', 'riche', consonantStem: true, comparison: ComparisonKind.irregularis, comparative: 'dīvitior', superlativeStem: 'dīvitissim', tags: {'comp-irreg'}, notes: 'Thema cōnsonāns: dīvite, dīvitum; etiam dīs, dītior, dītissimus.'),
  _a3una('princeps_adi', 'prīnceps', 'prīncipis', 'prīncip', 'premier, principal', consonantStem: true, comparison: ComparisonKind.nulla),
  // ------------------------------------------------------------ tertia: trēs termīnātiōnēs (A&G §115)
  _a3tria('acer', 'ācer', 'ācr', 'vif, âpre', notes: 'Ācer, ācris, ācre; superlātīvus ācerrimus.'),
  _a3tria('celer', 'celer', 'celer', 'rapide', notes: 'Celer, celeris, celere (e manet); superlātīvus celerrimus.'),
  _a3tria('alacer', 'alacer', 'alacr', 'alerte'),
  _a3tria('equester', 'equester', 'equestr', 'de cavalier', comparison: ComparisonKind.nulla),
  _a3tria('pedester', 'pedester', 'pedestr', 'à pied', comparison: ComparisonKind.nulla),
  _a3tria('campester', 'campester', 'campestr', 'de plaine', comparison: ComparisonKind.nulla),
  _a3tria('saluber', 'salūber', 'salūbr', 'salubre'),
  // ------------------------------------------------------------ comparātīva sine positīvō (A&G §130)
  _compOnly('prior', 'prior', 'prīm', 'antérieur; premier', notes: 'Prior, prius; prīmus. Ā prae.'),
  _compOnly('propior', 'propior', 'proxim', 'plus proche; le plus proche', notes: 'Ā prope.'),
  _compOnly('ulterior', 'ulterior', 'ultim', 'plus éloigné; dernier', notes: 'Ab ultrā.'),
  _compOnly('interior', 'interior', 'intim', 'intérieur; le plus intime', notes: 'Ab intrā.'),
  _compOnly('exterior', 'exterior', 'extrēm', 'extérieur; extrême', notes: 'Ab exterus (rārum): exterior, extrēmus (extimus).'),
  _compOnly('superior', 'superior', 'suprēm', 'supérieur; suprême', notes: 'Ā superus: superior, suprēmus (summus).'),
  _compOnly('inferior', 'īnferior', 'īnfim', 'inférieur; le plus bas', notes: 'Ab īnferus: īnferior, īnfimus (īmus).'),
  _compOnly('posterior', 'posterior', 'postrēm', 'postérieur; dernier', notes: 'Ā posterus: posterior, postrēmus (postumus).'),
  _compOnly('deterior', 'dēterior', 'dēterrim', 'pire, moins bon', notes: 'Ā dē: dēterior, dēterrimus.'),
  // ------------------------------------------------------------ correlātīva (A&G §152)
  _a12('tantus', 'tantus', 'tant', 'si grand, aussi grand', comparison: ComparisonKind.nulla, tags: {'correlativum'}, prov: ['$_ag §152']),
  _a12('quantus', 'quantus', 'quant', 'combien grand, aussi grand que', comparison: ComparisonKind.nulla, tags: {'correlativum'}, prov: ['$_ag §152']),
  // ------------------------------------------------------------ ōrdinālia (A&G §134)
  _ord('primus', 'prīmus', 'prīm', 1, 'premier'),
  _ord('secundus', 'secundus', 'secund', 2, 'deuxième'),
  _ord('tertius', 'tertius', 'terti', 3, 'troisième'),
  _ord('quartus', 'quārtus', 'quārt', 4, 'quatrième'),
  _ord('quintus', 'quīntus', 'quīnt', 5, 'cinquième'),
  _ord('sextus', 'sextus', 'sext', 6, 'sixième'),
  _ord('septimus', 'septimus', 'septim', 7, 'septième'),
  _ord('octavus', 'octāvus', 'octāv', 8, 'huitième'),
  _ord('nonus', 'nōnus', 'nōn', 9, 'neuvième'),
  _ord('decimus', 'decimus', 'decim', 10, 'dixième'),
  _ord('undecimus', 'ūndecimus', 'ūndecim', 11, 'onzième'),
  _ord('duodecimus', 'duodecimus', 'duodecim', 12, 'douzième'),
  _ord('vicesimus', 'vīcēsimus', 'vīcēsim', 20, 'vingtième'),
  _ord('tricesimus', 'trīcēsimus', 'trīcēsim', 30, 'trentième'),
  _ord('quadragesimus', 'quadrāgēsimus', 'quadrāgēsim', 40, 'quarantième'),
  _ord('quinquagesimus', 'quīnquāgēsimus', 'quīnquāgēsim', 50, 'cinquantième'),
  _ord('centesimus', 'centēsimus', 'centēsim', 100, 'centième'),
  _ord('millesimus', 'mīllēsimus', 'mīllēsim', 1000, 'millième'),
]);
