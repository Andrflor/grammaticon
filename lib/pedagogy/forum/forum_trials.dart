/// Trial (contrōversia) catalogue of the Forum: the nominal system of Latin
/// (LLPSI ch. 1–19) in 78 cards, 11 sections — declensions, adjectives,
/// comparison, pronouns, numerals, syncretisms, agreement, case functions and
/// mixed drills. One card per confusion, not per grammar chapter; the
/// prerequisites follow the real ambiguities of the system.
///
/// Cards of the flexion sections (1–7) draw isolated forms from the nominal
/// lexicon; the sections that turn on context (8–11) draw contextual items
/// (`Syntagma`), because `rosae` alone has no case.
library;

import '../../linguistics/model/adjective.dart';
import '../../linguistics/model/grammar.dart';
import '../../linguistics/model/nominal.dart';
import '../../linguistics/model/noun.dart';
import '../../linguistics/model/pronoun.dart';
import '../trial.dart';
import 'forum_filters.dart';

// ----- shared pieces -----------------------------------------------------------

const _six = {Casus.nominativus, Casus.vocativus, Casus.accusativus, Casus.genetivus, Casus.dativus, Casus.ablativus};
const _bothVariants = {VariantKind.norma, VariantKind.altera};
const _n = {WordClass.nomen};
const _adi = {WordClass.adiectivum};
const _pron = {WordClass.pronomen};

const _casNum = [Dimension.casus, Dimension.numerus];
const _casNumGen = [Dimension.casus, Dimension.numerus, Dimension.genus];

/// Irregular third-declension nouns kept out of the regular cards.
const _irregularThird = {'vis', 'bos', 'senex', 'iuppiter', 'iter', 'carthago'};

/// Nouns of the second declension whose nominative is not stem + -us and
/// other oddities kept out of the plain -us / -um cards.
const _oddSecond = {'deus', 'humus', 'corinthus'};

/// Section names, in display order (groups of the selection screen).
class ForumSections {
  ForumSections._();
  static const declinationes = 'Dēclīnātiōnēs';
  static const adiectiva = 'Adiectīva';
  static const comparatio = 'Comparātiō';
  static const personalia = 'Prōnōmina persōnālia';
  static const demonstrativa = 'Prōnōmina dēmōnstrātīva';
  static const relativa = 'Relātīva et interrogātīva';
  static const numeralia = 'Numerālia';
  static const syncretismi = 'Syncretismī';
  static const consensus = 'Cōnsēnsus';
  static const casus = 'Cāsūs in sententiā';
  static const mixta = 'Mixta';

  static const all = [declinationes, adiectiva, comparatio, personalia, demonstrativa, relativa, numeralia, syncretismi, consensus, casus, mixta];

  /// Skill id of the section node in the Tabula.
  static String skillOf(String section) => switch (section) {
        declinationes => 'f.dec',
        adiectiva => 'f.adi',
        comparatio => 'f.comp',
        personalia => 'f.pers',
        demonstrativa => 'f.dem',
        relativa => 'f.rel',
        numeralia => 'f.num',
        syncretismi => 'f.syn',
        consensus => 'f.con',
        casus => 'f.cas',
        mixta => 'f.mx',
        _ => throw ArgumentError(section),
      };
}

/// Skill id of a card: `dec-2-mf` → `f.dec.2mf`, `pron-suus-eius` → `f.pron.suuseius`.
String forumSkillId(String trialId) {
  final i = trialId.indexOf('-');
  return 'f.${trialId.substring(0, i)}.${trialId.substring(i + 1).replaceAll('-', '')}';
}

Trial _card({
  required String id,
  required String name,
  required String subtitle,
  required int price,
  required List<String> prereq,
  required ForumFilter filter,
  required List<Dimension> dimensions,
  required String intro,
  required List<String> examples,
  required String enemy,
  required String group,
  List<TrialComponent> components = const [],
  List<Dimension> chain = const [],
  bool showDictionaryEntry = false,
  bool fixedChoices = false,
  String helpNote = '',
}) =>
    Trial(
      id: id,
      activity: Activity.forum,
      name: name,
      subtitle: subtitle,
      skillIds: [forumSkillId(id)],
      price: price,
      prerequisites: prereq,
      filter: filter,
      dimensions: dimensions,
      components: components,
      chain: chain,
      intro: intro,
      examples: examples,
      opponentId: enemy,
      group: group,
      showDictionaryEntry: showDictionaryEntry,
      fixedChoices: fixedChoices,
      helpNote: helpNote,
    );

ForumFilter _forms(NominalFilter f) => ForumFilter(forms: [f]);
ForumFilter _syn(String tag, {Set<int>? tiers}) => ForumFilter(syntagmata: SyntagmaFilter({tag}, tiers: tiers));
ForumFilter _synAll(Set<String> tags) => ForumFilter(syntagmata: SyntagmaFilter(tags));

/// Component of a Mixta card whose content is another card's content.
TrialComponent _comp(String id, String name, ForumFilter filter, {required String from}) => TrialComponent(id, name, filter, skillId: forumSkillId(from), requires: from);

// ----- section filters reused by the Mixta cards -------------------------------------

const _dec1 = NominalFilter(classes: _n, declensions: {Declension.prima}, cases: _six, variantKinds: _bothVariants);
const _dec2mf = NominalFilter(classes: _n, declensions: {Declension.secunda}, genders: {Gender.masculinum, Gender.femininum}, erStem: false, cases: _six, excludeLemmaIds: _oddSecond);
const _dec2n = NominalFilter(classes: _n, declensions: {Declension.secunda}, genders: {Gender.neutrum}, cases: _six);
const _dec2er = NominalFilter(classes: _n, declensions: {Declension.secunda}, erStem: true, cases: _six);
const _dec2 = NominalFilter(classes: _n, declensions: {Declension.secunda}, cases: _six, variantKinds: _bothVariants);
const _dec3cons = NominalFilter(classes: _n, declensions: {Declension.tertia}, thirdStems: {ThirdStem.consonans}, genders: {Gender.masculinum, Gender.femininum}, cases: _six, excludeLemmaIds: _irregularThird);
const _dec3n = NominalFilter(classes: _n, declensions: {Declension.tertia}, thirdStems: {ThirdStem.consonans}, genders: {Gender.neutrum}, cases: _six, excludeLemmaIds: _irregularThird);
const _dec3i = NominalFilter(classes: _n, declensions: {Declension.tertia}, thirdStems: {ThirdStem.vocalisI, ThirdStem.vocalisIPura, ThirdStem.neutrumI}, cases: _six, excludeLemmaIds: {'vis'}, variantKinds: _bothVariants);
const _dec3 = NominalFilter(classes: _n, declensions: {Declension.tertia}, cases: _six, variantKinds: _bothVariants, excludeLemmaIds: {'carthago'});
const _dec4 = NominalFilter(classes: _n, declensions: {Declension.quarta}, cases: _six, variantKinds: _bothVariants);
const _dec5 = NominalFilter(classes: _n, declensions: {Declension.quinta}, cases: _six);

const _plainAdjTags = {'possessivum', 'pronominale', 'ordinale', 'numerale', 'correlativum', 'comp-irreg'};
const _adi12 = NominalFilter(classes: _adi, adjClasses: {AdjClass.primaSecunda}, erStem: false, pronominal: false, excludeTags: _plainAdjTags, cases: _six);
const _adi12er = NominalFilter(classes: _adi, adjClasses: {AdjClass.primaSecunda}, erStem: true, excludeTags: {'possessivum', 'pronominale'}, cases: _six);
const _adi3duo = NominalFilter(classes: _adi, adjClasses: {AdjClass.tertia}, terminations: {2}, excludeTags: {'correlativum'}, cases: _six);
const _adi3una = NominalFilter(classes: _adi, adjClasses: {AdjClass.tertia}, terminations: {1}, cases: _six);
const _adi3tria = NominalFilter(classes: _adi, adjClasses: {AdjClass.tertia}, terminations: {3}, cases: _six);
const _adi3 = NominalFilter(classes: _adi, adjClasses: {AdjClass.tertia}, excludeTags: {'correlativum'}, cases: _six);
const _adiPron = NominalFilter(classes: _adi, pronominal: true, excludeTags: {'numerale'}, cases: _six);
const _adiPoss = NominalFilter(classes: _adi, tags: {'possessivum'}, cases: _six, variantKinds: _bothVariants);
const _compAll = NominalFilter(classes: _adi, hasComparison: true, degrees: {Degree.comparativus, Degree.superlativus}, cases: _six, variantKinds: _bothVariants);
const _compOnly = NominalFilter(classes: _adi, hasComparison: true, degrees: {Degree.comparativus}, cases: _six, variantKinds: _bothVariants);
const _gradus = NominalFilter(classes: _adi, hasComparison: true, excludeTags: {'comp-irreg'}, degrees: {Degree.positivus, Degree.comparativus, Degree.superlativus}, cases: _six);
const _compIrreg = NominalFilter(classes: _adi, tags: {'comp-irreg'}, degrees: {Degree.positivus, Degree.comparativus, Degree.superlativus}, cases: _six, variantKinds: _bothVariants);
const _adverbia = NominalFilter(classes: {WordClass.adverbium}, degrees: null, variantKinds: _bothVariants);

const _egoTuSg = NominalFilter(lemmaIds: {'ego', 'tu'}, numbers: {Numerus.singularis}, variantKinds: _bothVariants);
const _nosVos = NominalFilter(lemmaIds: {'ego', 'tu'}, numbers: {Numerus.pluralis}, variantKinds: _bothVariants);
const _reflexiva = NominalFilter(lemmaIds: {'se', 'ego', 'tu'}, variantKinds: _bothVariants);
const _persFilter = NominalFilter(classes: _pron, pronounKinds: {PronounKind.personale, PronounKind.reflexivum}, variantKinds: _bothVariants);
NominalFilter _one(String id) => NominalFilter(lemmaIds: {id}, variantKinds: _bothVariants);
const _demFilter = NominalFilter(classes: _pron, pronounKinds: {PronounKind.demonstrativum}, variantKinds: _bothVariants);
const _relInt = NominalFilter(classes: _pron, pronounKinds: {PronounKind.relativum, PronounKind.interrogativum}, variantKinds: _bothVariants);
const _indefinita = NominalFilter(classes: _pron, pronounKinds: {PronounKind.indefinitum}, variantKinds: _bothVariants);
const _indefAdi = NominalFilter(lemmaIds: {'nullus', 'ullus'}, cases: _six);
const _correlativa = NominalFilter(lemmaIds: {'tantus', 'quantus', 'talis', 'qualis', 'tot', 'quot', 'totiens', 'quotiens', 'tam', 'quam', 'ibi', 'ubi', 'eo', 'quo', 'inde', 'unde', 'tum', 'quando'}, variantKinds: _bothVariants);

const _num13 = NominalFilter(lemmaIds: {'unus', 'duo', 'tres'}, cases: _six, variantKinds: _bothVariants);
const _cardinalia = NominalFilter(classes: {WordClass.numerale}, excludeLemmaIds: {'milia', 'ambo'}, variantKinds: _bothVariants);
const _ordinalia = NominalFilter(classes: _adi, tags: {'ordinale'}, cases: _six);
const _milleMilia = NominalFilter(lemmaIds: {'mille', 'milia'}, cases: _six);

const _synTags = {'syn-ae', 'syn-a', 'syn-i', 'syn-o', 'syn-um', 'syn-us', 'syn-e', 'syn-es', 'syn-is', 'syn-ibus', 'syn-neutra', 'syn-quantitas'};
const _conTags = {'con-1-2', 'con-3-1', 'con-distans', 'con-plura', 'con-appositio'};
const _casTags = {'cas-verba-dat', 'cas-verba-abl', 'cas-verba-gen', 'cas-prep-duplex', 'cas-prep-abl', 'cas-prep-acc', 'cas-loci', 'cas-temporis'};
const _prepTags = {'cas-prep-duplex', 'cas-prep-abl', 'cas-prep-acc'};

class ForumTrials {
  ForumTrials._();

  static List<Trial> build() => [
        ..._declinationes(),
        ..._adiectiva(),
        ..._comparatio(),
        ..._personalia(),
        ..._demonstrativa(),
        ..._relativa(),
        ..._numeralia(),
        ..._syncretismi(),
        ..._consensus(),
        ..._casus(),
        ..._mixta(),
      ];

  // ================================================================ 1. Dēclīnātiōnēs
  static List<Trial> _declinationes() {
    const g = ForumSections.declinationes;
    return [
      _card(
        id: 'dec-1',
        name: 'Dēclīnātiō prīma',
        subtitle: 'rosa, rosae · puella · poēta',
        price: 0,
        prereq: const [],
        filter: _forms(_dec1),
        dimensions: _casNumGen,
        intro: 'Prīma dēclīnātiō nōmina in -a continet, ferē fēminīna (rosa, puella); poēta, nauta, agricola masculīna sunt. Singulāris: rosa, rosa, rosam, rosae, rosae, rosā; plūrālis: rosae, rosae, rosās, rosārum, rosīs, rosīs. Dea et fīlia habent deābus, fīliābus.',
        examples: ['rosa · rosam · rosā', 'rosae: gen. sg. · dat. sg. · nōm. pl.', 'rosārum · rosīs · deābus'],
        enemy: 'rhetor',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'dec-2-mf',
        name: 'Dēclīnātiō secunda · masculīna',
        subtitle: 'servus, servī · dominus · fīlius',
        price: 15,
        prereq: const ['dec-1'],
        filter: _forms(_dec2mf),
        // Every noun of this card is masculine (humus and the town names have
        // their own place): there is no gender to discriminate.
        dimensions: _casNum,
        intro: 'Secunda dēclīnātiō, thema in -o: servus, serve, servum, servī, servō, servō; plūrālis servī, servī, servōs, servōrum, servīs, servīs. Vocātīvus in -e (serve), sed fīlī (nōmina in -ius). Humus et nōmina urbium fēminīna sunt.',
        examples: ['servus · serve · servum', 'servī: gen. sg. · nōm. pl.', 'servō: dat. sg. · abl. sg.'],
        enemy: 'rhetor',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'dec-2-n',
        name: 'Dēclīnātiō secunda · neutra',
        subtitle: 'bellum, bellī · templum · dōnum',
        price: 20,
        prereq: const ['dec-2-mf'],
        filter: _forms(_dec2n),
        dimensions: _casNum,
        intro: 'Neutra in -um: nōminātīvus, vocātīvus et accūsātīvus eandem fōrmam habent (bellum; plūrālis bella). Hīc prīmum fōrma sōla fūnctiōnem nōn ostendit: bellum subiectum aut obiectum esse potest. Cēterī cāsūs ut servus: bellī, bellō, bellōrum, bellīs.',
        examples: ['bellum (nōm. = acc. = voc.)', 'bella (nōm. = acc. pl.)', 'bellī · bellō · bellōrum · bellīs'],
        enemy: 'rhetor',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'dec-2-er',
        name: 'Nōmina in -er',
        subtitle: 'puer, puerī · ager, agrī · vir',
        price: 20,
        prereq: const ['dec-2-mf'],
        filter: _forms(_dec2er),
        dimensions: const [Dimension.casus, Dimension.numerus, Dimension.lemma],
        intro: 'Nōnnūlla masculīna secundae dēclīnātiōnis nōminātīvum sine -us habent. Puer servat e (puer, puerī), ager perdit (ager, agrī), ut magister, magistrī et liber, librī. Vir, virī. Vocātīvus = nōminātīvus. Thema ē genetīvō cognōscitur.',
        examples: ['puer · puerī · puerō', 'ager · agrī · agrō (e cadit)', 'magister · magistrī · liber · librī'],
        enemy: 'rhetor',
        group: g,
        showDictionaryEntry: false,
      ),
      _card(
        id: 'dec-3-cons',
        name: 'Dēclīnātiō tertia · cōnsonāns',
        subtitle: 'rēx, rēgis · cōnsul · pater',
        price: 30,
        prereq: const ['dec-2-n'],
        filter: _forms(_dec3cons),
        dimensions: const [Dimension.casus, Dimension.numerus, Dimension.genus, Dimension.lemma],
        intro: 'Tertia dēclīnātiō omnia genera continet; nōminātīvus varius est, thema ē genetīvō cognōscitur: rēx, rēg-is; pater, patr-is. Dēsinentiae: -is, -ī, -em, -e; plūrālis -ēs, -um, -ibus. Genus ē vocābulō, nōn ē dēsinentiā discitur (arbor f., soror f., labor m.).',
        examples: ['rēx · rēgis · rēgī · rēgem · rēge', 'rēgēs · rēgum · rēgibus', 'pater, patris · cōnsul, cōnsulis'],
        enemy: 'grammaticus',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'dec-3-n',
        name: 'Dēclīnātiō tertia · neutra',
        subtitle: 'corpus, corporis · nōmen · caput',
        price: 35,
        prereq: const ['dec-3-cons'],
        filter: _forms(_dec3n),
        dimensions: const [Dimension.casus, Dimension.numerus, Dimension.lemma],
        intro: 'Neutra tertiae: nōminātīvus = accūsātīvus (corpus, nōmen, caput), plūrālis in -a (corpora, nōmina, capita). Cavē: corpus, tempus, genus, opus in -us dēsinunt, sed neutra tertiae sunt, nōn masculīna secundae: genetīvus corporis id ostendit.',
        examples: ['corpus · corporis · corpore', 'corpora · corporum · corporibus', 'nōmen, nōminis · caput, capitis'],
        enemy: 'grammaticus',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'dec-3-i',
        name: 'Dēclīnātiō tertia · thema in -i-',
        subtitle: 'cīvis, cīvium · urbs · mare, maria',
        price: 40,
        prereq: const ['dec-3-n'],
        filter: _forms(_dec3i),
        dimensions: _casNumGen,
        intro: 'Themata in -i-: genetīvus plūrālis -ium (cīvium, urbium), accūsātīvus plūrālis -ēs aut -īs. Neutra in -e, -al, -ar: ablātīvus -ī (marī), plūrālis -ia (maria, animālia), -ium. Turris et nāvis accūsātīvum -im et ablātīvum -ī admittunt. Differentia vēra ā themate cōnsonante, et error diūturnus.',
        examples: ['cīvis · cīvium · cīvēs / cīvīs', 'mare · marī · maria · marium', 'urbs · urbium ≠ rēx · rēgum'],
        enemy: 'grammaticus',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'dec-4',
        name: 'Dēclīnātiō quārta',
        subtitle: 'manus, manūs · exercitus · cornū',
        price: 30,
        prereq: const ['dec-3-cons'],
        filter: const ForumFilter(forms: [_dec4, _dec2mf]),
        dimensions: const [Dimension.casus, Dimension.numerus, Dimension.declinatio],
        intro: 'Quārta dēclīnātiō, thema in -u: manus, manūs, manuī, manum, manū; plūrālis manūs, manuum, manibus. Neutra in -ū: cornū, cornūs, cornua. Īnsidiae: exercitus nōmen secundae esse videtur — genetīvus exercitūs (nōn exercitī) quārtam ostendit. Hīc nōmina secundae quoque miscentur: dēclīnātiōnem agnōsce.',
        examples: ['manus · manūs · manuī · manum · manū', 'exercitus (IV) ≠ servus (II)', 'cornū · cornūs · cornua · cornuum'],
        enemy: 'grammaticus',
        group: g,
        showDictionaryEntry: false,
      ),
      _card(
        id: 'dec-5',
        name: 'Dēclīnātiō quīnta',
        subtitle: 'rēs, reī · diēs, diēī · spēs',
        price: 25,
        prereq: const ['dec-4'],
        filter: _forms(_dec5),
        dimensions: const [Dimension.casus, Dimension.numerus, Dimension.analysis],
        intro: 'Quīnta dēclīnātiō, thema in -ē: rēs, reī, reī, rem, rēs, rē; plūrālis rēs, rērum, rēbus. Genetīvus et datīvus ambō in -eī (ē longa post vōcālem: diēī; brevis post cōnsonantem: reī, fideī). Parva classis, sed rēs et diēs ubīque sunt.',
        examples: ['rēs · reī · rem · rē', 'reī: gen. sg. = dat. sg.', 'diēs · diēī · diem · diēbus'],
        enemy: 'grammaticus',
        group: g,
        showDictionaryEntry: true,
      ),
    ];
  }

  // ================================================================ 2. Adiectīva
  static List<Trial> _adiectiva() {
    const g = ForumSections.adiectiva;
    return [
      _card(
        id: 'adi-1-2',
        name: 'Adiectīva prīmae et secundae',
        subtitle: 'bonus, -a, -um · magnus · longus',
        price: 20,
        prereq: const ['dec-2-n'],
        filter: _forms(_adi12),
        dimensions: _casNumGen,
        intro: 'Adiectīva prīmae classis tria genera habent: bonus (ut servus), bona (ut rosa), bonum (ut bellum). Cum nōmine congruunt cāsū, numerō, genere: fōrma adiectīvī genus ostendit quod nōmen cēlat (poēta bonus, m.).',
        examples: ['bonus · bona · bonum', 'bonae: gen./dat. sg. f. · nōm. pl. f.', 'bonī: gen. sg. m./n. · nōm. pl. m.'],
        enemy: 'grammaticus',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'adi-1-2-er',
        name: 'Adiectīva in -er',
        subtitle: 'pulcher, -chra, -chrum · miser, -era · noster',
        price: 25,
        prereq: const ['adi-1-2'],
        filter: _forms(_adi12er),
        dimensions: const [Dimension.casus, Dimension.numerus, Dimension.genus, Dimension.lemma],
        intro: 'Ut puer et ager: pulcher perdit e (pulchra, pulchrum), miser servat (misera, miserum); noster, nostra, nostrum. Nōminātīvus masculīnus sōlus sine -us est; cēterae fōrmae ut bonus.',
        examples: ['pulcher · pulchra · pulchrum', 'miser · misera · miserum', 'pulchrī · pulchrō · pulchrōrum'],
        enemy: 'grammaticus',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'adi-3-duo',
        name: 'Adiectīva tertiae · duae termīnātiōnēs',
        subtitle: 'fortis, -e · omnis · brevis',
        price: 35,
        prereq: const ['adi-1-2', 'dec-3-i'],
        filter: _forms(_adi3duo),
        dimensions: _casNumGen,
        intro: 'Adiectīva tertiae classis thema in -i- sequuntur: ablātīvus -ī (fortī), genetīvus plūrālis -ium (fortium), neutrum plūrāle -ia (fortia) — dum plēraque nōmina tertiae thema cōnsonāns habent (rēge, rēgum). Duae termīnātiōnēs: fortis (m. f.), forte (n.).',
        examples: ['fortis (m. f.) · forte (n.)', 'fortī · fortium · fortia', 'fortī (adi.) ≠ rēge (nōmen)'],
        enemy: 'grammaticus',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'adi-3-una',
        name: 'Adiectīva tertiae · ūna termīnātiō',
        subtitle: 'fēlīx, -īcis · ingēns · vetus',
        price: 40,
        prereq: const ['adi-3-duo'],
        filter: _forms(_adi3una),
        dimensions: const [Dimension.casus, Dimension.numerus, Dimension.genus, Dimension.lemma],
        intro: 'Ūna fōrma nōminātīvī tribus generibus: fēlīx, ingēns, prūdēns. Thema ē genetīvō: fēlīc-is, ingent-is. Cēterae fōrmae ut fortis (fēlīcī, fēlīcium, fēlīcia). Vetus, pauper, dīves thema cōnsonāns servant: vetere, veterum, vetera.',
        examples: ['fēlīx · fēlīcis · fēlīcī · fēlīcem', 'ingēns · ingentia · ingentium', 'vetus · vetere · veterum (cōnsonāns)'],
        enemy: 'grammaticus',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'adi-3-tria',
        name: 'Adiectīva tertiae · tria genera',
        subtitle: 'ācer, ācris, ācre · celer',
        price: 40,
        prereq: const ['adi-3-duo'],
        filter: _forms(_adi3tria),
        dimensions: _casNumGen,
        intro: 'Trēs termīnātiōnēs in nōminātīvō singulārī: ācer (m.), ācris (f.), ācre (n.); celer, celeris, celere. Cēterae fōrmae ut fortis: ācrī, ācrium, ācria. Sōlus nōminātīvus masculīnus differt.',
        examples: ['ācer · ācris · ācre', 'ācrem · ācrī · ācrium', 'celer · celeris · celere'],
        enemy: 'grammaticus',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'adi-pron',
        name: 'Adiectīva prōnōminālia',
        subtitle: 'ūnus, sōlus, tōtus, alius, alter, uter, neuter, nūllus, ūllus',
        price: 45,
        prereq: const ['adi-1-2'],
        filter: _forms(_adiPron),
        dimensions: const [Dimension.casus, Dimension.numerus, Dimension.genus, Dimension.lemma],
        intro: 'Novem adiectīva frequentissima ut bonus dēclīnantur praeter genetīvum singulārem in -īus (ūnīus, sōlīus, alterīus) et datīvum in -ī (ūnī, sōlī, alterī) tribus generibus. Neutrum aliud. Irregulāria ibi ubi nōn exspectās.',
        examples: ['ūnīus · ūnī (gen. · dat., m. f. n.)', 'alius · alia · aliud · alterīus', 'tōtīus · sōlī · nūllīus · ūllī'],
        enemy: 'grammaticus',
        group: g,
        showDictionaryEntry: true,
        helpNote: 'Eaedem dēsinentiae -īus et -ī in prōnōminibus ille, ipse, iste, hic (huius, huic) et quī (cuius, cui) redeunt.',
      ),
    ];
  }

  // ================================================================ 3. Comparātiō
  static List<Trial> _comparatio() {
    const g = ForumSections.comparatio;
    return [
      _card(
        id: 'comp-forma',
        name: 'Comparātīvus et superlātīvus',
        subtitle: 'longus · longior · longissimus',
        price: 30,
        prereq: const ['adi-1-2'],
        filter: _forms(_gradus),
        dimensions: const [Dimension.gradus, Dimension.casus, Dimension.numerus],
        intro: 'Comparātīvus: thema + -ior (m. f.), -ius (n.): longior, longius; fortior, fortius. Superlātīvus: -issimus (longissimus), sed -errimus post -er (pulcherrimus, ācerrimus) et -illimus in facilis, difficilis, similis, dissimilis, gracilis, humilis (facillimus).',
        examples: ['longus · longior · longissimus', 'pulcher · pulchrior · pulcherrimus', 'facilis · facilior · facillimus'],
        enemy: 'poeta',
        group: g,
      ),
      _card(
        id: 'comp-flexio',
        name: 'Flexiō comparātīvī',
        subtitle: 'fortior, fortiōris · fortiōre · fortiōrum',
        price: 40,
        prereq: const ['comp-forma', 'dec-3-cons'],
        filter: const ForumFilter(forms: [_compOnly, _adi3]),
        dimensions: const [Dimension.casus, Dimension.numerus, Dimension.genus, Dimension.gradus, Dimension.analysis],
        intro: 'Comparātīvus in -ior tertiam dēclīnātiōnem sequitur — sed thema cōnsonāns: ablātīvus -e (fortiōre), genetīvus plūrālis -um (fortiōrum), neutrum plūrāle -a (fortiōra). Contrā adiectīva tertiae positīvī gradūs thema in -i- habent: fortī, fortium, fortia. Fortī sed fortiōre.',
        examples: ['fortior · fortiōris · fortiōrem · fortiōre', 'fortiōrēs · fortiōrum · fortiōribus', 'fortī (pos.) ≠ fortiōre (comp.)'],
        enemy: 'poeta',
        group: g,
      ),
      _card(
        id: 'comp-irreg',
        name: 'Comparātiō irregulāris',
        subtitle: 'bonus · melior · optimus',
        price: 35,
        prereq: const ['comp-forma'],
        filter: _forms(_compIrreg),
        dimensions: const [Dimension.gradus, Dimension.lemma, Dimension.casus, Dimension.genus],
        intro: 'Bonus, melior, optimus; malus, peior, pessimus; magnus, maior, maximus; parvus, minor, minimus; multus, plūs, plūrimus. Neutra maius, melius, peius, minus, plūs saepe prō aliō vocābulō habentur. Prior, propior, ulterior, superior positīvum nōn habent.',
        examples: ['melior · melius · optimus', 'maior · maius · maximus', 'plūs · plūrēs · plūrimus'],
        enemy: 'poeta',
        group: g,
      ),
      _card(
        id: 'comp-adv',
        name: 'Adverbia et gradūs eōrum',
        subtitle: 'fortiter · fortius · fortissimē',
        price: 35,
        prereq: const ['comp-forma'],
        filter: _forms(_adverbia),
        dimensions: const [Dimension.gradus, Dimension.lemma],
        intro: 'Adverbia ab adiectīvīs: -ē ā prīmā classe (longē, pulchrē), -iter ā tertiā (fortiter, breviter; prūdenter post -nt-). Comparātīvus = neutrum comparātīvī adiectīvī: fortius, longius. Superlātīvus -ē: fortissimē, pulcherrimē, facillimē. Irregulāria: bene, melius, optimē; male, peius, pessimē; magis, maximē; minus, minimē.',
        examples: ['longē · longius · longissimē', 'fortiter · fortius · fortissimē', 'bene · melius · optimē'],
        enemy: 'poeta',
        group: g,
      ),
      _card(
        id: 'comp-abl',
        name: 'Ablātīvus comparātiōnis',
        subtitle: 'Mārcō altior · altior quam Mārcus',
        price: 30,
        prereq: const ['comp-forma', 'dec-1'],
        filter: _syn('comp-abl'),
        dimensions: const [Dimension.constructio, Dimension.casus],
        intro: 'Duae cōnstrūctiōnēs post comparātīvum: ablātīvus sōlus (Mārcō altior est: ablātīvus comparātiōnis) aut quam cum eōdem cāsū quō rēs comparāta (altior quam Mārcus). Quaeritur: quae cōnstrūctiō, et quō cāsū vocābulum notātum sit.',
        examples: ['Quīntus Mārcō altior est', 'Quīntus altior est quam Mārcus', 'nihil est melius sapientiā'],
        enemy: 'poeta',
        group: g,
        fixedChoices: true,
      ),
    ];
  }

  // ================================================================ 4. Prōnōmina persōnālia
  static List<Trial> _personalia() {
    const g = ForumSections.personalia;
    return [
      _card(
        id: 'pron-ego-tu',
        name: 'Ego et tū',
        subtitle: 'ego, mē, meī, mihi, mē · tū, tē, tuī, tibi, tē',
        price: 0,
        prereq: const [],
        filter: _forms(_egoTuSg),
        dimensions: const [Dimension.casus, Dimension.persona],
        intro: 'Prōnōmina persōnālia in omnī ferē sententiā redeunt. Ego, mē, meī, mihi, mē; tū, tē, tuī, tibi, tē. Mē et tē accūsātīvus et ablātīvus sunt; mihi et tibi datīvus sōlus. Porta est, nōn praemium: grātīs.',
        examples: ['ego · mē · meī · mihi · mē', 'tū · tē · tuī · tibi · tē', 'mē: acc. = abl. · mihi: dat.'],
        enemy: 'matrona',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'pron-nos-vos',
        name: 'Nōs et vōs',
        subtitle: 'nōs, nostrum, nōbīs · vōs, vestrum, vōbīs',
        price: 15,
        prereq: const ['pron-ego-tu'],
        filter: _forms(_nosVos),
        dimensions: const [Dimension.casus, Dimension.persona],
        intro: 'Nōs et vōs nōminātīvus et accūsātīvus sunt; nōbīs et vōbīs datīvus et ablātīvus. Genetīvus duplex: nostrum, vestrum partītīvus (ūnus nostrum), nostrī, vestrī obiectīvus (memor nostrī).',
        examples: ['nōs: nōm. = acc. · nōbīs: dat. = abl.', 'vōs · vōbīs · vestrum / vestrī', 'ūnus nostrum · memor vestrī'],
        enemy: 'matrona',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'pron-se',
        name: 'Prōnōmen reflexīvum',
        subtitle: 'sē, suī, sibi, sē',
        price: 30,
        prereq: const ['pron-ego-tu'],
        filter: _forms(_reflexiva),
        dimensions: const [Dimension.casus, Dimension.persona],
        intro: 'Sē (sēsē), suī, sibi, sē nōminātīvum nōn habet et ad subiectum sententiae refertur: Iūlius sē lavat. Eaedem fōrmae singulārī et plūrālī serviunt. Hīc cum mē, tē, mihi, tibi miscētur: persōnam et cāsum agnōsce.',
        examples: ['sē · suī · sibi · sē', 'sibi ≠ tibi ≠ mihi', 'sē lavat (ipsum) · eum lavat (alium)'],
        enemy: 'matrona',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'pron-me-mihi',
        name: 'Mē an mihi?',
        subtitle: 'mē videt · mihi dat',
        price: 25,
        prereq: const ['pron-ego-tu'],
        filter: _syn('pron-me-mihi'),
        dimensions: const [Dimension.casus, Dimension.functio],
        chain: const [Dimension.casus, Dimension.functio],
        intro: 'Gallicē "me" et obiectum et eī cui datur significat; Latīnē nōn. Mē videt (accūsātīvus, obiectum), mihi dat (datīvus, cui datur). Error invisibilis: fōrmam falsam nōn gignit, lēctiōnem falsam gignit. Duae quaestiōnēs: cāsus, deinde fūnctiō.',
        examples: ['Iūlia mē videt (acc.)', 'Iūlia mihi rosam dat (dat.)', 'tē vocō · tibi respondeō'],
        enemy: 'matrona',
        group: g,
        fixedChoices: true,
      ),
      _card(
        id: 'pron-poss',
        name: 'Possessīva',
        subtitle: 'meus, tuus, suus · noster, vester',
        price: 25,
        prereq: const ['adi-1-2'],
        filter: _forms(_adiPoss),
        dimensions: const [Dimension.casus, Dimension.numerus, Dimension.genus, Dimension.lemma],
        intro: 'Possessīva adiectīva sunt: meus, tuus, suus ut bonus; noster, vester ut pulcher. Cum rē possessā congruunt, nōn cum possessōre: fīlia mea, fīlius meus. Vocātīvus meī: mī (mī fīlī).',
        examples: ['meus · mea · meum · mī fīlī', 'noster · nostra · nostrum', 'liber tuus · librī tuī · librō tuō'],
        enemy: 'matrona',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'pron-suus-eius',
        name: 'Suus an eius?',
        subtitle: 'fīlium suum · fīlium eius',
        price: 45,
        prereq: const ['pron-poss', 'pron-se', 'pron-is'],
        filter: _syn('pron-suus-eius'),
        dimensions: const [Dimension.relatio],
        intro: 'Suus ad subiectum sententiae refertur, eius ad alium: Iūlius fīlium suum vocat (fīlium ipsīus Iūliī); Iūlius fīlium eius vocat (fīlium alterīus). Gallicē "son" utrumque dīcit, itaque discrīmen fugit. Sōlus contextus respondet, numquam fōrma.',
        examples: ['Iūlius fīlium suum vocat → ipsīus', 'Iūlius fīlium eius vocat → alterīus', 'Aemilia sē videt · Aemilia eam videt'],
        enemy: 'matrona',
        group: g,
      ),
    ];
  }

  // ================================================================ 5. Dēmōnstrātīva
  static List<Trial> _demonstrativa() {
    const g = ForumSections.demonstrativa;
    return [
      _card(
        id: 'pron-is',
        name: 'Is, ea, id',
        subtitle: 'is, eum, eius, eī, eō',
        price: 35,
        prereq: const ['dec-2-n'],
        filter: _forms(_one('is')),
        dimensions: _casNumGen,
        intro: 'Is, ea, id: prōnōmen tertiae persōnae et dēmōnstrātīvum levius. Eius genetīvus omnium generum; eī datīvus singulāris aut nōminātīvus plūrālis masculīnus; eīs datīvus et ablātīvus plūrālis; eā ablātīvus fēminīnus. Plūrālis eī (iī), eae, ea.',
        examples: ['is · ea · id · eum · eam', 'eius · eī · eō · eā', 'eī: dat. sg. aut nōm. pl. m.'],
        enemy: 'matrona',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'pron-hic',
        name: 'Hic, haec, hoc',
        subtitle: 'hic, hunc, huius, huic, hōc',
        price: 40,
        prereq: const ['pron-is'],
        filter: _forms(_one('hic')),
        dimensions: _casNumGen,
        intro: 'Dēclīnātiō arbitrāria videtur; dīmidiō tantum est. Hōs, hās, hōrum, hārum, hīs dēsinentiās adiectīvī bonus habent. Sōlae septem fōrmae propriae sunt: hic, haec, hoc, hunc, hanc, huius, huic. Septem fōrmae discendae, nōn trīgintā.',
        examples: ['hic · haec · hoc · hunc · hanc', 'huius · huic (m. f. n.)', 'hōs · hās · hōrum · hīs ut bonus'],
        enemy: 'matrona',
        group: g,
        showDictionaryEntry: true,
        helpNote: 'Septem fōrmae propriae: hic, haec, hoc, hunc, hanc, huius, huic. Cēterae bonus sequuntur. Cuius / huius / eius / illīus; cui / huic / eī / illī: īdem ōrdō ubīque.',
      ),
      _card(
        id: 'pron-ille',
        name: 'Ille, illa, illud',
        subtitle: 'ille, illum, illīus, illī, illō',
        price: 35,
        prereq: const ['pron-is'],
        filter: _forms(_one('ille')),
        dimensions: _casNumGen,
        intro: 'Ille ut bonus dēclīnātur praeter tria: neutrum illud, genetīvum illīus, datīvum illī — eaedem dēsinentiae quae in ūnus, sōlus, tōtus. Illī datīvus singulāris aut nōminātīvus plūrālis masculīnus.',
        examples: ['ille · illa · illud', 'illīus · illī (ut ūnīus, ūnī)', 'illī: dat. sg. aut nōm. pl. m.'],
        enemy: 'matrona',
        group: g,
        showDictionaryEntry: true,
        helpNote: 'Radix + dēsinentiae ōrdināriae, praeter gen. -īus et dat. -ī (ut adiectīva prōnōminālia).',
      ),
      _card(
        id: 'pron-iste',
        name: 'Iste, ista, istud',
        subtitle: 'iste, istum, istīus, istī, istō',
        price: 30,
        prereq: const ['pron-ille'],
        filter: _forms(_one('iste')),
        dimensions: _casNumGen,
        intro: 'Iste ut ille prōrsus dēclīnātur: istud, istīus, istī. Ad secundam persōnam spectat (iste liber: liber tuus), saepe cum contemptū.',
        examples: ['iste · ista · istud', 'istīus · istī · istō', 'istōs · istās · istōrum'],
        enemy: 'matrona',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'pron-ipse',
        name: 'Ipse, ipsa, ipsum',
        subtitle: 'ipse, ipsum, ipsīus, ipsī, ipsō',
        price: 35,
        prereq: const ['pron-ille'],
        filter: _forms(_one('ipse')),
        dimensions: _casNumGen,
        intro: 'Ipse ut ille, sed neutrum ipsum (nōn -ud): ipsum accūsātīvus masculīnus aut nōminātīvus/accūsātīvus neuter. Genetīvus ipsīus, datīvus ipsī.',
        examples: ['ipse · ipsa · ipsum', 'ipsīus · ipsī · ipsō', 'ipsum: acc. m. aut nōm./acc. n.'],
        enemy: 'matrona',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'pron-idem',
        name: 'Īdem, eadem, idem',
        subtitle: 'īdem, eundem, eiusdem, eīdem',
        price: 40,
        prereq: const ['pron-is'],
        filter: _forms(_one('idem')),
        dimensions: _casNumGen,
        intro: 'Is + -dem: eundem (nōn eumdem), eōrundem, eārundem — m ante d in n vertitur. Īdem masculīnum (ī longa), idem neutrum (i brevis): sōla vōcālis longa discernit.',
        examples: ['īdem (m.) ≠ idem (n.)', 'eundem · eandem · eiusdem', 'eōrundem · eīsdem'],
        enemy: 'matrona',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'pron-dem-omnia',
        name: 'Dēmōnstrātīva omnia',
        subtitle: 'is · hic · ille · iste · ipse · īdem',
        price: 55,
        prereq: const ['pron-is', 'pron-hic', 'pron-ille', 'pron-iste', 'pron-ipse', 'pron-idem'],
        filter: _forms(_demFilter),
        dimensions: const [Dimension.lemma, Dimension.casus, Dimension.numerus, Dimension.genus],
        intro: 'Omnia dēmōnstrātīva mixta. Parallēlismus: cuius / huius / eius / illīus; cui / huic / eī / illī — īdem ōrdō ubīque. Quod prōnōmen, quī cāsus, quod genus?',
        examples: ['huius · eius · illīus · ipsīus', 'huic · eī · illī · ipsī', 'hōc · eō · illō · eōdem'],
        enemy: 'causidicus',
        group: g,
      ),
    ];
  }

  // ================================================================ 6. Relātīva et interrogātīva
  static List<Trial> _relativa() {
    const g = ForumSections.relativa;
    return [
      _card(
        id: 'pron-quis',
        name: 'Quis, quid',
        subtitle: 'quis, quem, cuius, cui, quō',
        price: 20,
        prereq: const ['dec-2-n'],
        filter: _forms(_one('quis')),
        dimensions: _casNumGen,
        intro: 'Quis? quid? interrogat: quis, quem, cuius, cui, quō; neutrum quid. Cuius et cui sicut huius, huic. Plūrālis ut relātīvum: quī, quae, quae.',
        examples: ['quis · quem · cuius · cui · quō', 'quid (n.) · quis (m. f.)', 'cuius liber? cui dat?'],
        enemy: 'philosophus',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'pron-qui',
        name: 'Quī, quae, quod',
        subtitle: 'quī, quem, cuius, cui, quō · quae · quod',
        price: 40,
        prereq: const ['pron-quis', 'pron-is'],
        filter: _forms(_one('qui')),
        dimensions: _casNumGen,
        intro: 'Relātīvum quī, quae, quod sententiās iungit. Singulāris: quī, quem, cuius, cui, quō; quae, quam, cuius, cui, quā; quod. Plūrālis: quī, quae, quae; quōs, quās; quōrum, quārum; quibus. Quae fēminīnum singulāre aut plūrāle, aut neutrum plūrāle est.',
        examples: ['quī · quem · cuius · cui · quō', 'quae: f. sg. · f. pl. · n. pl.', 'quibus: dat. = abl. pl.'],
        enemy: 'philosophus',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'rel-consensus',
        name: 'Cōnsēnsus relātīvī',
        subtitle: 'puer quī currit · puer quem videō',
        price: 55,
        prereq: const ['pron-qui', 'dec-3-cons'],
        filter: _syn('rel-consensus'),
        dimensions: const [Dimension.genusNumerus, Dimension.casus],
        chain: const [Dimension.genusNumerus, Dimension.casus],
        intro: 'Rēgula duplex: relātīvum genus et numerum ab antecēdente sūmit, cāsum ā fūnctiōne suā in sententiā relātīvā. Puer quī currit (subiectum), puer quem videō (obiectum), puer cuius liber est. Duae operātiōnēs, duae quaestiōnēs: prīmum genus et numerus, deinde cāsus.',
        examples: ['puer quī currit → m. sg. · nōm.', 'puer quem videō → m. sg. · acc.', 'ovis quam pāstor videt → f. sg. · acc.'],
        enemy: 'philosophus',
        group: g,
        fixedChoices: true,
        helpNote: 'Genus et numerus: quaere antecēdēns. Cāsus: quaere quid relātīvum in suā sententiā faciat (subiectum? obiectum? possessor?).',
      ),
      _card(
        id: 'pron-quis-qui',
        name: 'Quis an quī?',
        subtitle: 'quis vēnit? · vir quī vēnit',
        price: 45,
        prereq: const ['pron-qui'],
        filter: _syn('pron-quis-qui'),
        dimensions: const [Dimension.forma, Dimension.casus],
        intro: 'Quis interrogat, quī relātīvē iungit. Eadem radix, fōrmae commūnēs (quem, cuius, cui, quō), fūnctiōnēs oppositae. Contextus discernit: signum interrogātiōnis, verbum quaerendī, antecēdēns.',
        examples: ['Quis clāmat? (interrogātīvum)', 'Puer quī clāmat (relātīvum)', 'Quem vidēs? · quem videō'],
        enemy: 'philosophus',
        group: g,
        fixedChoices: true,
      ),
      _card(
        id: 'pron-indef',
        name: 'Indēfīnīta',
        subtitle: 'aliquis · quīdam · quisque · quisquam · nēmō · nihil · nūllus',
        price: 45,
        prereq: const ['pron-qui'],
        filter: const ForumFilter(forms: [_indefinita, _indefAdi]),
        dimensions: const [Dimension.casus, Dimension.numerus, Dimension.genus, Dimension.lemma],
        intro: 'Indēfīnīta ā quis/quī cum particulīs fōrmantur: ali-quis, quī-dam, quis-que, quis-quam. Nēmō et nihil dēfectīva sunt: genetīvus et ablātīvus ā nūllus sūmuntur (nūllīus, nūllō; nūllīus reī, nūllā rē). Nūllus et ūllus adiectīva prōnōminālia.',
        examples: ['aliquis · aliquem · alicuius', 'quīdam · quendam · cuiusdam', 'nēmō · nēminem · nūllīus · nēminī'],
        enemy: 'philosophus',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'pron-corr',
        name: 'Correlātīva',
        subtitle: 'tantus … quantus · tālis … quālis · tot … quot',
        price: 35,
        prereq: const ['pron-hic', 'pron-qui'],
        filter: _forms(_correlativa),
        dimensions: const [Dimension.correlativum, Dimension.casus, Dimension.genus, Dimension.lemma],
        intro: 'Correlātīva bīna respondent: tantus … quantus, tālis … quālis, tot … quot, totiēns … quotiēns, tam … quam, ibi … ubi, eō … quō, inde … unde, tum … quandō. Dēmōnstrātīvum t- incipit, relātīvum qu-.',
        examples: ['tantus … quantus · tālis … quālis', 'tot … quot · totiēns … quotiēns', 'ibi … ubi · eō … quō · inde … unde'],
        enemy: 'philosophus',
        group: g,
      ),
    ];
  }

  // ================================================================ 7. Numerālia
  static List<Trial> _numeralia() {
    const g = ForumSections.numeralia;
    return [
      _card(
        id: 'num-1-3',
        name: 'Ūnus, duo, trēs',
        subtitle: 'ūnīus · duōbus · tribus',
        price: 30,
        prereq: const ['adi-pron'],
        filter: _forms(_num13),
        dimensions: const [Dimension.casus, Dimension.genus, Dimension.lemma, Dimension.valor],
        intro: 'Trēs prīmī numerī dēclīnantur, cēterī ūsque ad centum nōn. Ūnus ut adiectīva prōnōminālia (ūnīus, ūnī); duo fōrmās proprias cum reliquiīs duālis habet (duo, duae, duo; duōbus, duābus); trēs, tria tertiam sequitur (trium, tribus). Tria systēmata tribus vocābulīs.',
        examples: ['ūnus · ūna · ūnum · ūnīus · ūnī', 'duo · duae · duo · duōrum · duōbus · duābus', 'trēs · tria · trium · tribus'],
        enemy: 'causidicus',
        group: g,
        showDictionaryEntry: true,
      ),
      _card(
        id: 'num-card',
        name: 'Cardinālia',
        subtitle: 'quattuor · decem · vīgintī · centum · ducentī',
        price: 20,
        prereq: const ['num-1-3'],
        filter: _forms(_cardinalia),
        dimensions: const [Dimension.valor, Dimension.forma],
        intro: 'Ā quattuor ad centum cardinālia indēclīnābilia sunt: quattuor, quīnque, sex … decem, ūndecim, duodecim … vīgintī, trīgintā … centum. Centēna (ducentī, -ae, -a) ut adiectīva plūrālia dēclīnantur. Duodēvīgintī (XVIII) et ūndēvīgintī (XIX) subtrahunt.',
        examples: ['IV quattuor · V quīnque · X decem', 'XX vīgintī · C centum (indēcl.)', 'CC ducentī, -ae, -a (dēclīn.)'],
        enemy: 'causidicus',
        group: g,
      ),
      _card(
        id: 'num-ord',
        name: 'Ōrdinālia',
        subtitle: 'prīmus · secundus · tertius · decimus',
        price: 20,
        prereq: const ['adi-1-2'],
        filter: _forms(_ordinalia),
        dimensions: const [Dimension.valor, Dimension.casus, Dimension.numerus, Dimension.genus],
        intro: 'Ōrdinālia adiectīva prīmae classis sunt: prīmus, secundus (alter), tertius, quārtus, quīntus, sextus, septimus, octāvus, nōnus, decimus; vīcēsimus, centēsimus, mīllēsimus. Ut bonus dēclīnantur et cum nōmine congruunt: capitulum tertium, hōra sexta.',
        examples: ['prīmus · secundus · tertius', 'septimus VII · octāvus VIII · nōnus IX', 'capitulō tertiō · hōrā sextā'],
        enemy: 'causidicus',
        group: g,
      ),
      _card(
        id: 'num-mille',
        name: 'Mīlle et mīlia',
        subtitle: 'mīlle mīlitēs · tria mīlia mīlitum',
        price: 30,
        prereq: const ['num-card'],
        filter: const ForumFilter(forms: [_milleMilia], syntagmata: SyntagmaFilter({'num-mille'})),
        dimensions: const [Dimension.constructio, Dimension.casus],
        intro: 'Mīlle singulāre adiectīvum indēclīnābile est: mīlle mīlitēs (mīlitēs cāsum sententiae habent). Mīlia plūrāle nōmen neutrum tertiae est (mīlia, mīlium, mīlibus) quod genetīvum regit: tria mīlia mīlitum. Inter singulārem et plūrālem tōta syntaxis vertitur.',
        examples: ['mīlle mīlitēs (adi. indēcl.)', 'tria mīlia mīlitum (nōmen + gen.)', 'cum duōbus mīlibus equitum'],
        enemy: 'causidicus',
        group: g,
        fixedChoices: true,
      ),
    ];
  }

  // ================================================================ 8. Syncretismī
  static Trial _syncretism({
    required String id,
    required String name,
    required String subtitle,
    required int price,
    required List<String> prereq,
    required String intro,
    required List<String> examples,
    ForumFilter? filter,
    List<Dimension> dimensions = _casNum,
  }) =>
      _card(
        id: id,
        name: name,
        subtitle: subtitle,
        price: price,
        prereq: prereq,
        filter: filter ?? _syn(id),
        dimensions: dimensions,
        intro: intro,
        examples: examples,
        enemy: 'sophista',
        group: ForumSections.syncretismi,
        fixedChoices: true,
        helpNote: 'Fōrma sōla nōn respondet: quaere verbum, praepositiōnem, nōmen cui vocābulum servit.',
      );

  static List<Trial> _syncretismi() => [
        _syncretism(
          id: 'syn-ae',
          name: 'Dēsinentia -ae',
          subtitle: 'rosae: gen. sg. · dat. sg. · nōm. pl.',
          price: 35,
          prereq: const ['dec-1'],
          intro: 'Fōrma Latīna maximē polyvalēns: -ae est genetīvus singulāris, datīvus singulāris, nōminātīvus (et vocātīvus) plūrālis prīmae dēclīnātiōnis. Tria valōra in omnī occursū certant, iam ā capitulō secundō. Sōlus contextus dīrimit: rosae spīnae (gen.), rosae aqua nocet (dat.), rosae flōrent (nōm. pl.).',
          examples: ['rosae spīnae → gen. sg.', 'rosae aqua nocet → dat. sg.', 'rosae flōrent → nōm. pl.'],
        ),
        _syncretism(
          id: 'syn-a',
          name: 'Dēsinentia -a / -ā',
          subtitle: 'rosa · rosā · bella',
          price: 35,
          prereq: const ['syn-ae', 'dec-2-n'],
          intro: '-a brevis: nōminātīvus singulāris prīmae (rosa) aut nōminātīvus/accūsātīvus plūrālis neutrōrum (bella, corpora, maria). -ā longa: ablātīvus singulāris prīmae (rosā). Verbum et praepositiō (cum, in, ā) respondent.',
          examples: ['puella cantat → nōm. sg.', 'cum puellā → abl. sg.', 'bella gerunt → acc. pl. n.'],
        ),
        _syncretism(
          id: 'syn-i',
          name: 'Dēsinentia -ī',
          subtitle: 'servī · rēgī · marī',
          price: 45,
          prereq: const ['syn-a', 'dec-2-mf', 'dec-3-i'],
          intro: '-ī: genetīvus singulāris et nōminātīvus plūrālis secundae (servī), datīvus singulāris tertiae (rēgī), ablātīvus neutrōrum in -i- (marī) et locātīvus (domī, Corinthī). Dēclīnātiō vocābulī prīmum quaerenda est, deinde contextus.',
          examples: ['servī dominī → gen. sg.', 'servī labōrant → nōm. pl.', 'rēgī pāret → dat. sg.'],
        ),
        _syncretism(
          id: 'syn-o',
          // Every -ō / -e / -ibus reading has one number: only the case is asked.
          dimensions: const [Dimension.casus],
          name: 'Dēsinentia -ō',
          subtitle: 'servō: dat. sg. · abl. sg.',
          price: 30,
          prereq: const ['syn-i', 'dec-2-mf'],
          intro: '-ō secundae dēclīnātiōnis datīvus et ablātīvus singulāris est. Datīvus: cui datur, pāret, placet. Ablātīvus: cum praepositiōne (cum servō, ā dominō, in hortō) aut īnstrūmentum (gladiō pugnat).',
          examples: ['servō pecūniam dat → dat. sg.', 'cum servō ambulat → abl. sg.', 'gladiō pugnat → abl. sg.'],
        ),
        _syncretism(
          id: 'syn-um',
          name: 'Dēsinentia -um',
          subtitle: 'servum · bellum · rēgum',
          price: 40,
          prereq: const ['syn-o', 'dec-3-cons'],
          intro: '-um: accūsātīvus singulāris secundae (servum) et quārtae (manum), nōminātīvus/accūsātīvus neutrōrum secundae (bellum), genetīvus plūrālis tertiae (rēgum, mīlitum) et prīmae/secundae in -ārum, -ōrum. Rēgum (gen. pl.) ≠ rēgem (acc. sg.).',
          examples: ['servum vocat → acc. sg.', 'bellum longum est → nōm. sg. n.', 'rēx rēgum → gen. pl.'],
        ),
        _syncretism(
          id: 'syn-us',
          name: 'Dēsinentia -us / -ūs',
          subtitle: 'servus · manus · manūs · corpus',
          price: 50,
          prereq: const ['syn-um', 'dec-4', 'dec-3-n'],
          intro: 'Quattuor orīginēs: nōminātīvus secundae (servus), nōminātīvus et genetīvus singulāris quārtae (manus, manūs), nōminātīvus/accūsātīvus plūrālis quārtae (manūs), neutra tertiae (corpus, tempus, genus, opus) quae "masculīnum secundae" clāmant sed nōn sunt. Carta ūberrima: multī errōrēs hinc veniunt.',
          examples: ['servus labōrat → nōm. sg.', 'digitī manūs → gen. sg.', 'corpus aegrum est → nōm. sg. n.'],
        ),
        _syncretism(
          id: 'syn-e',
          // Every -ō / -e / -ibus reading has one number: only the case is asked.
          dimensions: const [Dimension.casus],
          name: 'Dēsinentia -e / -ē',
          subtitle: 'rēge · serve · rē · mare',
          price: 45,
          prereq: const ['syn-us', 'dec-5', 'dec-3-i'],
          intro: '-e: ablātīvus singulāris tertiae (rēge), vocātīvus singulāris secundae (serve!), nōminātīvus/accūsātīvus neutrōrum in -e (mare). -ē longa: ablātīvus quīntae (rē, diē). Vocātīvus alloquitur, ablātīvus praepositiōnem aut verbum comitātur.',
          examples: ['ā rēge → abl. sg.', 'serve, venī! → voc. sg.', 'mare vidēmus → acc. sg. n.'],
        ),
        _syncretism(
          id: 'syn-es',
          name: 'Dēsinentia -ēs',
          subtitle: 'rēgēs · rēs · diēs',
          price: 45,
          prereq: const ['syn-e', 'dec-5'],
          intro: '-ēs: nōminātīvus et accūsātīvus plūrālis tertiae (rēgēs, cīvēs), nōminātīvus singulāris et plūrālis quīntae (rēs, diēs). Rēgēs veniunt (nōm.) aut rēgēs videt (acc.): verbum dīrimit. Rēs ūna aut multae: verbum numerum ostendit.',
          examples: ['rēgēs veniunt → nōm. pl.', 'rēgēs videt → acc. pl.', 'rēs difficilis est → nōm. sg.'],
        ),
        _syncretism(
          id: 'syn-is',
          name: 'Dēsinentia -is / -īs',
          subtitle: 'rēgis · rosīs · servīs',
          price: 45,
          prereq: const ['syn-es', 'dec-3-cons'],
          intro: '-is brevis: genetīvus singulāris tertiae (rēgis, cīvis) — et nōminātīvus cīvis, nāvis. -īs longa: datīvus et ablātīvus plūrālis prīmae et secundae (rosīs, servīs), accūsātīvus plūrālis in -i- (cīvīs). Dēclīnātiō vocābulī prīmum.',
          examples: ['fīlius rēgis → gen. sg.', 'servīs pecūniam dat → dat. pl.', 'cum servīs → abl. pl.'],
        ),
        _syncretism(
          id: 'syn-ibus',
          // Every -ō / -e / -ibus reading has one number: only the case is asked.
          dimensions: const [Dimension.casus],
          name: 'Dēsinentia -ibus',
          subtitle: 'rēgibus · manibus',
          price: 30,
          prereq: const ['syn-is', 'dec-4'],
          intro: '-ibus tertiae et quārtae datīvus et ablātīvus plūrālis est (rēgibus, cīvibus, manibus; quīnta -ēbus: rēbus). Datīvus aut ablātīvus: verbum (dat, pāret / cum, ā, in) respondet, nōn fōrma.',
          examples: ['mīlitibus pecūniam dat → dat. pl.', 'cum mīlitibus → abl. pl.', 'manibus tenet → abl. pl.'],
        ),
        _syncretism(
          id: 'syn-neutra',
          name: 'Neutra: nōminātīvus = accūsātīvus',
          subtitle: 'bellum · corpus · mare · cornū',
          price: 40,
          prereq: const ['syn-ibus', 'dec-3-n'],
          intro: 'In omnibus dēclīnātiōnibus neutrum nōminātīvum et accūsātīvum eundem habet (bellum, corpus, mare, cornū; plūrālis bella, corpora, maria, cornua). Itaque sōla syntaxis dīrimit: positiō, verbum, numerus verbī. Haec carta lēctiōnem vēram dīrēctē parat.',
          examples: ['bellum populum terret → nōm. (subiectum)', 'populus bellum timet → acc. (obiectum)', 'maria nāvēs portant → nōm. pl.'],
        ),
        _syncretism(
          id: 'syn-quantitas',
          name: 'Quantitās vōcālium',
          subtitle: 'rosa / rosā · servis / servīs · diē / diem',
          price: 50,
          prereq: const ['syn-neutra', 'dec-5'],
          intro: 'Quantitās vōcālis cāsūs discernit: rosa (nōm.) / rosā (abl.); manus (nōm.) / manūs (gen. sg., nōm. pl.); cīvis (nōm./gen.) / cīvīs (acc. pl.). Ørberg līneolās scrībit, textūs vērī nōn: hīc līneolam observā, posteā contextum sōlum habēbis.',
          examples: ['rosa (nōm.) ≠ rosā (abl.)', 'manus (nōm.) ≠ manūs (gen.)', 'diē (abl.) ≠ diem (acc.)'],
        ),
        _syncretism(
          id: 'syn-omnia',
          name: 'Syncretismī omnēs',
          subtitle: 'omnēs dēsinentiae ambiguae',
          price: 60,
          prereq: const ['syn-quantitas'],
          filter: _synAll(_synTags),
          intro: 'Omnēs dēsinentiae ambiguae mixtae: -ae, -a, -ī, -ō, -um, -us, -e, -ēs, -is, -ibus, neutra, quantitās. Grātia plēna: quī cāsus, quī numerus — ex contextū sōlō.',
          examples: ['rosae · servī · rēgēs · manūs', 'bellum · corpus · mare', 'rosā · manū · rē'],
        ),
      ];

  // ================================================================ 9. Cōnsēnsus
  static List<Trial> _consensus() {
    const g = ForumSections.consensus;
    return [
      _card(
        id: 'con-1-2',
        name: 'Cōnsēnsus simplex',
        subtitle: 'puella pulchra · servus bonus · bellum longum',
        price: 30,
        prereq: const ['adi-1-2', 'dec-2-n'],
        filter: _syn('con-1-2'),
        dimensions: _casNumGen,
        intro: 'Adiectīvum cum nōmine cāsū, numerō, genere congruit: puella pulchra, servus bonus, bellum longum. Eiusdem dēclīnātiōnis nōmen et adiectīvum eandem dēsinentiam habent — sed dēsinentia ambigua (puellae pulchrae) tantum contextū solvitur. Quaeritur cāsus, numerus, genus adiectīvī notātī.',
        examples: ['puella pulchra cantat', 'servī bonī labōrant', 'in bellō longō'],
        enemy: 'grammaticus',
        group: g,
        fixedChoices: true,
      ),
      _card(
        id: 'con-3-1',
        name: 'Adiectīvum et nōmen dīversae dēclīnātiōnis',
        subtitle: 'rēx bonus · corpus magnum · manus magna',
        price: 50,
        prereq: const ['adi-3-duo', 'dec-3-cons'],
        filter: _syn('con-3-1'),
        dimensions: _casNumGen,
        intro: 'Rēx bonus, corpus magnum, mīlitēs fortēs, manus magna: eōdem cāsū sunt, sed dēsinentiae dīversae, quia dēclīnātiōnēs dīversae. Contrā intuitum — et hoc ipsum videndum est ut ablātīvus absolūtus posteā agnōscātur. Cāsus, numerus, genus adiectīvī notātī quaeritur.',
        examples: ['rēx bonus · rēgem bonum · rēge bonō', 'corpus magnum · corpora magna', 'manūs fortēs · manibus fortibus'],
        enemy: 'grammaticus',
        group: g,
        fixedChoices: true,
      ),
      _card(
        id: 'con-distans',
        name: 'Adiectīvum ā nōmine distāns',
        subtitle: 'magnam in silvā vīdit umbram',
        price: 55,
        prereq: const ['con-3-1'],
        filter: _syn('con-distans'),
        dimensions: const [Dimension.quodNomen, Dimension.casus],
        intro: 'In Latīnō vērō adiectīvum nōminī suō nōn adhaeret: magnam in silvā vīdit umbram. Trēs aut quattuor nōmina in sententiā, ūnum sōlum cāsū, genere, numerō congruit. Quaeritur: cum quō nōmine adiectīvum notātum congruat. Exercitātiō lēctiōnī vērae proxima.',
        examples: ['magnam in silvā vīdit umbram → umbram', 'parvus in hortō puer canem videt → puer', 'fortium mīlitum ducem laudat → mīlitum'],
        enemy: 'senator',
        group: g,
        fixedChoices: true,
      ),
      _card(
        id: 'con-plura',
        name: 'Plūra nōmina, ūnum adiectīvum',
        subtitle: 'pater et māter laetī',
        price: 45,
        prereq: const ['con-3-1'],
        filter: _syn('con-plura'),
        dimensions: const [Dimension.quodNomen, Dimension.casus, Dimension.genus],
        intro: 'Ūnum adiectīvum plūribus nōminibus: cum persōnīs dīversī generis masculīnum plūrāle (pater et māter laetī sunt); cum rēbus saepe neutrum plūrāle aut cum proximō congruit (mūrus et porta alta). Quaeritur cum quō nōmine (aut quibus) adiectīvum congruat, et quō cāsū.',
        examples: ['pater et māter laetī sunt', 'Mārcus et Iūlia bonī sunt', 'puerī et puellae fessī'],
        enemy: 'senator',
        group: g,
        fixedChoices: true,
      ),
      _card(
        id: 'con-appositio',
        name: 'Appositiō',
        subtitle: 'Iūlius, pater Mārcī · Rōma, urbs magna',
        price: 35,
        prereq: const ['con-1-2'],
        filter: _syn('con-appositio'),
        dimensions: const [Dimension.casus, Dimension.functio],
        intro: 'Appositiō nōmen alterī nōminī apponit eōdem cāsū: Iūlius, pater Mārcī, venit; Rōmam, urbem magnam, videt. Nōmen appositum cāsum nōminis suī sequitur, nōn verbī. Quaeritur cāsus et fūnctiō vocābulī notātī.',
        examples: ['Iūlius, pater Mārcī, venit', 'Rōmam, urbem magnam, vident', 'Aemiliae, mātrī Iūliae, dat'],
        enemy: 'senator',
        group: g,
        fixedChoices: true,
      ),
      _card(
        id: 'con-omnia',
        name: 'Cōnsēnsus omnis',
        subtitle: 'omnia genera cōnsēnsūs',
        price: 60,
        prereq: const ['con-1-2', 'con-3-1', 'con-distans', 'con-plura', 'con-appositio'],
        filter: _synAll(_conTags),
        dimensions: const [Dimension.casus, Dimension.numerus, Dimension.genus, Dimension.quodNomen],
        intro: 'Omnia genera cōnsēnsūs mixta: adiectīvum eiusdem aut dīversae dēclīnātiōnis, distāns, cum plūribus nōminibus, appositiō. Participium et ablātīvus absolūtus hōc cōnsēnsū agnōscuntur: sī cāsūs incertī sunt, cōnstrūctiō invisibilis manet.',
        examples: ['rēge bonō · magnam … umbram', 'pater et māter laetī', 'Rōma, urbs magna'],
        enemy: 'censor',
        group: g,
        fixedChoices: true,
      ),
    ];
  }

  // ================================================================ 10. Cāsūs in sententiā
  static List<Trial> _casus() {
    const g = ForumSections.casus;
    Trial cas({required String id, required String name, required String subtitle, required int price, required List<String> prereq, required String intro, required List<String> examples, List<Dimension> dimensions = const [Dimension.casus, Dimension.functio], String helpNote = ''}) => _card(
          id: id,
          name: name,
          subtitle: subtitle,
          price: price,
          prereq: prereq,
          filter: _syn(id),
          dimensions: dimensions,
          intro: intro,
          examples: examples,
          enemy: 'iurisconsultus',
          group: g,
          fixedChoices: true,
          helpNote: helpNote,
        );
    return [
      cas(
        id: 'cas-verba-dat',
        name: 'Verba cum datīvō',
        subtitle: 'pāreō · placeō · noceō · crēdō · imperō',
        price: 45,
        prereq: const ['dec-2-mf'],
        intro: 'Pāreō, serviō, placeō, noceō, faveō, crēdō, parcō, studeō, persuādeō, imperō datīvum regunt. Ē Gallicō dīvīnārī nōn potest: persuādeō et imperō trānsitīva videntur. Nōn irregulāre est, sed regulāre Latīnē vīsum: pāreō = oboediēns sum alicui. Sēnsum proprium quaere, nōn exceptiōnem memoriā tenē.',
        examples: ['mīlitēs ducī pārent (dat.)', 'mīlitēs ducem laudant (acc.)', 'servus dominō nōn nocet'],
        helpNote: 'Verba cum datīvō: pāreō, serviō, placeō, noceō, faveō, crēdō, parcō, studeō, persuādeō, imperō, respondeō, appropinquō.',
      ),
      cas(
        id: 'cas-verba-abl',
        name: 'Verba cum ablātīvō',
        subtitle: 'ūtor · fruor · fungor · potior · opus est',
        price: 45,
        prereq: const ['dec-2-mf'],
        intro: 'Ūtor, fruor, fungor, potior, vescor ablātīvum regunt (gladiō ūtitur), item opus est (mihi pecūniā opus est) et careō, egeō. Ablātīvus sine praepositiōne, ubi Gallicē obiectum exspectās.',
        examples: ['mīles gladiō ūtitur (abl.)', 'mīles gladium tenet (acc.)', 'nōbīs aquā opus est'],
        helpNote: 'Verba cum ablātīvō: ūtor, fruor, fungor, potior, vescor; careō, egeō; opus est.',
      ),
      cas(
        id: 'cas-verba-gen',
        name: 'Verba cum genetīvō',
        subtitle: 'meminī · oblīvīscor · plēnus · cupidus',
        price: 40,
        prereq: const ['dec-2-mf'],
        intro: 'Meminī et oblīvīscor genetīvum admittunt (meminī patris), item adiectīva plēnus, cupidus, memor, perītus (plēnus aquae, cupidus glōriae) et verba iūdiciī (accūsō fūrtī). Genetīvus partītīvus post nihil, multum, satis (satis pecūniae).',
        examples: ['Mārcus patris meminit (gen.)', 'Mārcus patrem videt (acc.)', 'saccus plēnus nummōrum'],
        helpNote: 'Genetīvus: meminī, oblīvīscor; plēnus, cupidus, memor, perītus, ignārus; partītīvus post nihil, multum, satis, parum.',
      ),
      cas(
        id: 'cas-prep-duplex',
        name: 'Praepositiōnēs duplicis cāsūs',
        subtitle: 'in hortō · in hortum · sub arbore · sub arborem',
        price: 35,
        prereq: const ['dec-2-mf'],
        dimensions: const [Dimension.constructio, Dimension.casus],
        intro: 'In et sub ablātīvum capiunt ubi rēs est (in hortō, sub arbore), accūsātīvum quō rēs it (in hortum, sub arborem). Mēchanicum et frequentissimum: verbum mōtūs accūsātīvum vocat, verbum statūs ablātīvum.',
        examples: ['in hortō ambulat (abl.: ubi)', 'in hortum intrat (acc.: quō)', 'sub arbore sedet · sub arborem currit'],
      ),
      cas(
        id: 'cas-prep-abl',
        name: 'Praepositiōnēs cum ablātīvō',
        subtitle: 'ā, ab · cum · dē · ē, ex · prō · sine',
        price: 25,
        prereq: const ['dec-2-mf'],
        intro: 'Ablātīvum semper regunt: ā/ab, cum, dē, ē/ex, prō, sine, cōram, prae. Ā puerō, cum amīcīs, dē montē, ex urbe, prō patriā, sine pecūniā. Hīc et accūsātīvī sine praepositiōne miscentur: cāsum et fūnctiōnem agnōsce.',
        examples: ['cum amīcīs ambulat (abl.)', 'ex urbe venit (abl.)', 'sine pecūniā · prō patriā'],
      ),
      cas(
        id: 'cas-prep-acc',
        name: 'Praepositiōnēs cum accūsātīvō',
        subtitle: 'ad · ante · apud · inter · per · post · trāns',
        price: 25,
        prereq: const ['dec-2-mf'],
        intro: 'Accūsātīvum semper regunt: ad, ante, apud, circum, contrā, inter, intrā, ob, per, post, prope, propter, trāns. Ad urbem, ante portam, apud amīcum, inter montēs, per silvam, post tergum, trāns flūmen.',
        examples: ['ad urbem it (acc.)', 'per silvam currit (acc.)', 'inter montēs · trāns flūmen'],
      ),
      cas(
        id: 'cas-loci',
        name: 'Nōmina urbium et locātīvus',
        subtitle: 'Rōmam · Rōmā · Rōmae',
        price: 40,
        prereq: const ['dec-1', 'dec-2-mf'],
        dimensions: const [Dimension.casus, Dimension.constructio],
        intro: 'Nōmina urbium sine praepositiōne: Rōmam (quō: accūsātīvus), Rōmā (unde: ablātīvus), Rōmae (ubi: locātīvus). Locātīvus cāsus residuus est quem Ørberg nōn nōminat sed quī iam capitulō sextō appāret: prīma et secunda -ae, -ī (Rōmae, Tūsculī, domī), tertia -ī/-e, plūrālis ut ablātīvus (Athēnīs).',
        examples: ['Rōmam it → acc. (quō)', 'Rōmā venit → abl. (unde)', 'Rōmae habitat → loc. (ubi)'],
      ),
      cas(
        id: 'cas-temporis',
        name: 'Ablātīvus temporis',
        subtitle: 'hōrā sextā · trēs hōrās · nocte',
        price: 35,
        prereq: const ['dec-3-cons'],
        dimensions: const [Dimension.casus, Dimension.constructio],
        intro: 'Tempus quandō ablātīvō sine praepositiōne dīcitur: hōrā sextā, nocte, hieme, eō diē. Tempus quam diū accūsātīvō: trēs hōrās, multōs annōs, tōtam noctem. Ablātīvus pūnctum, accūsātīvus spatium.',
        examples: ['hōrā sextā venit → abl. (quandō)', 'trēs hōrās dormit → acc. (quam diū)', 'nocte · hieme · eō diē'],
      ),
    ];
  }

  // ================================================================ 11. Mixta
  static List<Trial> _mixta() {
    const g = ForumSections.mixta;
    return [
      _card(
        id: 'mx-declinationes',
        name: 'Dēclīnātiōnēs omnēs',
        subtitle: 'quīnque dēclīnātiōnēs mixtae',
        price: 60,
        prereq: const ['dec-5', 'dec-3-i', 'dec-2-er'],
        filter: const ForumFilter(forms: [_dec1, _dec2, _dec3, _dec4, _dec5]),
        dimensions: const [Dimension.analysis, Dimension.casus, Dimension.numerus, Dimension.declinatio],
        components: [
          _comp('d1', 'Prīma dēclīnātiō', _forms(_dec1), from: 'dec-1'),
          _comp('d2', 'Secunda dēclīnātiō', _forms(_dec2), from: 'dec-2-n'),
          _comp('d3', 'Tertia dēclīnātiō', _forms(_dec3), from: 'dec-3-i'),
          _comp('d4', 'Quārta dēclīnātiō', _forms(_dec4), from: 'dec-4'),
          _comp('d5', 'Quīnta dēclīnātiō', _forms(_dec5), from: 'dec-5'),
        ],
        intro: 'Quīnque dēclīnātiōnēs mixtae, cum nōminibus irregulāribus (vīs, bōs, deus, domus). Dēclīnātiō nōn datur: ex dēsinentiā et genetīvō eam agnōsce. Analysis complēta rogātur: cāsus et numerus.',
        examples: ['rosīs (I) · servīs (II) · rēgibus (III)', 'corpus (III) · manus (IV) · rēs (V)', 'vīribus · diēbus · bōbus'],
        enemy: 'censor',
        group: g,
      ),
      _card(
        id: 'mx-adiectiva',
        name: 'Adiectīva omnia',
        subtitle: 'duae classēs et comparātiō',
        price: 55,
        prereq: const ['adi-3-una', 'adi-3-tria', 'adi-1-2-er', 'comp-flexio', 'comp-irreg'],
        filter: const ForumFilter(forms: [_adi12, _adi12er, _adi3, _compAll]),
        dimensions: const [Dimension.analysis, Dimension.casus, Dimension.numerus, Dimension.genus, Dimension.classis, Dimension.gradus],
        components: [
          _comp('a12', 'Prīma et secunda classis', const ForumFilter(forms: [_adi12, _adi12er]), from: 'adi-1-2-er'),
          _comp('a3', 'Tertia classis', _forms(_adi3), from: 'adi-3-una'),
          _comp('comp', 'Comparātīvus et superlātīvus', _forms(_compAll), from: 'comp-flexio'),
        ],
        intro: 'Ambae classēs adiectīvōrum cum comparātīvō et superlātīvō mixtae: bonus, pulcher, fortis, fēlīx, ācer; melior, optimus. Quae classis, quī gradus, quae analysis?',
        examples: ['bonī · fortī · fēlīcī · meliōre', 'bonōrum · fortium · meliōrum', 'pulcherrimus · facillimus · optimus'],
        enemy: 'censor',
        group: g,
      ),
      _card(
        id: 'mx-pronomina',
        name: 'Prōnōmina omnia',
        subtitle: 'persōnālia · dēmōnstrātīva · relātīva · indēfīnīta',
        price: 65,
        prereq: const ['pron-nos-vos', 'pron-se', 'pron-dem-omnia', 'pron-quis-qui', 'pron-indef'],
        filter: const ForumFilter(forms: [_persFilter, _demFilter, _relInt, _indefinita]),
        dimensions: const [Dimension.analysis, Dimension.lemma, Dimension.casus, Dimension.numerus, Dimension.genus],
        components: [
          _comp('pers', 'Persōnālia et reflexīvum', _forms(_persFilter), from: 'pron-se'),
          _comp('dem', 'Dēmōnstrātīva', _forms(_demFilter), from: 'pron-dem-omnia'),
          _comp('rel', 'Relātīvum et interrogātīvum', _forms(_relInt), from: 'pron-qui'),
          _comp('indef', 'Indēfīnīta', _forms(_indefinita), from: 'pron-indef'),
        ],
        intro: 'Quattuor seriēs prōnōminum mixtae: ego, tū, sē; is, hic, ille, iste, ipse, īdem; quī, quis; aliquis, quīdam, quisque, nēmō. Quod prōnōmen, quae analysis?',
        examples: ['mihi · tibi · sibi · eī · huic · cui', 'eius · huius · illīus · cuius · alicuius', 'quem · quendam · quemque · nēminem'],
        enemy: 'censor',
        group: g,
      ),
      _card(
        id: 'mx-syncretismi',
        name: 'Syncretismī omnēs',
        subtitle: 'grātia plēna dēsinentiārum',
        price: 70,
        prereq: const ['syn-omnia'],
        filter: _synAll(_synTags),
        dimensions: const [Dimension.casus, Dimension.numerus, Dimension.analysis],
        components: [for (final t in _synTags) _comp(t, 'Dēsinentia ${t.substring(4)}', _syn(t), from: t)],
        intro: 'Omnēs syncretismī ex contextū solvendī, analysī complētā: quī cāsus et quī numerus vocābulī notātī. Nūlla fōrma per sē respondet.',
        examples: ['rosae · servī · rēgēs', 'bellum · corpus · manūs', 'rosā · rēge · rē'],
        enemy: 'sophista',
        group: g,
        fixedChoices: true,
      ),
      _card(
        id: 'mx-consensus',
        name: 'Cōnsēnsus in sententiā',
        subtitle: 'cōnsēnsus distāns et mixtus',
        price: 70,
        prereq: const ['con-omnia'],
        filter: _synAll(_conTags),
        dimensions: const [Dimension.quodNomen, Dimension.casus, Dimension.genus, Dimension.numerus],
        components: [for (final t in _conTags) _comp(t, _conName(t), _syn(t), from: t)],
        intro: 'Cōnsēnsus in sententiā vērā: adiectīvum ā nōmine distāns, plūra nōmina, appositiō, dēclīnātiōnēs dīversae. Cum quō nōmine congruit, quō cāsū est?',
        examples: ['magnam in silvā vīdit umbram', 'rēge bonō · corpora magna', 'pater et māter laetī'],
        enemy: 'censor',
        group: g,
        fixedChoices: true,
      ),
      _card(
        id: 'mx-casus',
        name: 'Cāsūs et fūnctiōnēs',
        subtitle: 'fōrma et fūnctiō simul',
        price: 65,
        prereq: const ['cas-verba-dat', 'cas-verba-abl', 'cas-verba-gen', 'cas-prep-duplex', 'cas-prep-abl', 'cas-prep-acc', 'cas-loci', 'cas-temporis'],
        filter: _synAll(_casTags),
        dimensions: const [Dimension.casus, Dimension.functio, Dimension.constructio],
        components: [for (final t in _casTags) _comp(t, _casName(t), _syn(t), from: t)],
        intro: 'Fōrma et fūnctiō simul: verba cum datīvō, ablātīvō, genetīvō; praepositiōnēs; nōmina urbium; tempus. Quī cāsus, quae fūnctiō, quae cōnstrūctiō?',
        examples: ['ducī pāret · gladiō ūtitur · patris meminit', 'in hortō · in hortum · Rōmae · Rōmam', 'hōrā sextā · trēs hōrās'],
        enemy: 'iurisconsultus',
        group: g,
        fixedChoices: true,
      ),
      _card(
        id: 'mx-instrumenta',
        name: 'Verba minōra',
        subtitle: 'prōnōmina · praepositiōnēs · numerālia',
        price: 60,
        prereq: const ['pron-dem-omnia', 'cas-prep-duplex', 'num-mille', 'pron-corr'],
        filter: const ForumFilter(forms: [_persFilter, _demFilter, _relInt, _indefinita, _correlativa, _num13, _cardinalia, _ordinalia], syntagmata: SyntagmaFilter(_prepTags)),
        dimensions: const [Dimension.analysis, Dimension.casus, Dimension.lemma, Dimension.valor, Dimension.constructio, Dimension.correlativum],
        components: [
          _comp('pron', 'Prōnōmina', const ForumFilter(forms: [_persFilter, _demFilter, _relInt, _indefinita, _correlativa]), from: 'pron-dem-omnia'),
          _comp('prep', 'Praepositiōnēs', _synAll(_prepTags), from: 'cas-prep-duplex'),
          _comp('num', 'Numerālia', const ForumFilter(forms: [_num13, _cardinalia, _ordinalia]), from: 'num-mille'),
        ],
        intro: 'Verba minōra quae sententiam tenent: prōnōmina omnia, praepositiōnēs cum cāsibus suīs, numerālia. Parva vocābula, magnum pondus.',
        examples: ['huic · cui · eīdem · cuidam', 'in hortō · in hortum · ad urbem', 'duōbus · tribus · septem · tertius'],
        enemy: 'causidicus',
        group: g,
      ),
      _card(
        id: 'mx-nominalia',
        name: 'Omnia nōminālia',
        subtitle: 'summa contrōversia',
        price: 80,
        prereq: const ['mx-declinationes', 'mx-adiectiva', 'mx-pronomina', 'mx-syncretismi', 'mx-consensus', 'mx-casus', 'mx-instrumenta'],
        filter: const ForumFilter(forms: [_dec1, _dec2, _dec3, _dec4, _dec5, _adi12, _adi12er, _adi3, _compAll, _persFilter, _demFilter, _relInt, _indefinita], syntagmata: SyntagmaFilter({..._synTags, ..._conTags, ..._casTags})),
        dimensions: const [Dimension.analysis, Dimension.casus, Dimension.numerus, Dimension.genus, Dimension.quodNomen, Dimension.functio],
        components: [
          _comp('dec', 'Dēclīnātiōnēs', const ForumFilter(forms: [_dec1, _dec2, _dec3, _dec4, _dec5]), from: 'mx-declinationes'),
          _comp('adi', 'Adiectīva', const ForumFilter(forms: [_adi12, _adi12er, _adi3, _compAll]), from: 'mx-adiectiva'),
          _comp('pron', 'Prōnōmina', const ForumFilter(forms: [_persFilter, _demFilter, _relInt, _indefinita]), from: 'mx-pronomina'),
          _comp('syn', 'Syncretismī', _synAll(_synTags), from: 'mx-syncretismi'),
          _comp('con', 'Cōnsēnsus et cāsūs', _synAll({..._conTags, ..._casTags}), from: 'mx-consensus'),
        ],
        intro: 'Omnia nōminālia: quodlibet nōmen, adiectīvum, prōnōmen, sōlum aut in sententiā. Analysis complēta rogātur. Quod didicistī, hīc dēfende.',
        examples: ['vīribus · meliōre · huic · cuidam', 'rosae spīnae · rēge bonō', 'magnam in silvā vīdit umbram'],
        enemy: 'censor',
        group: g,
      ),
    ];
  }

  static String _conName(String t) => switch (t) {
        'con-1-2' => 'Cōnsēnsus simplex',
        'con-3-1' => 'Dīversae dēclīnātiōnis',
        'con-distans' => 'Adiectīvum distāns',
        'con-plura' => 'Plūra nōmina',
        'con-appositio' => 'Appositiō',
        _ => t,
      };

  static String _casName(String t) => switch (t) {
        'cas-verba-dat' => 'Verba cum datīvō',
        'cas-verba-abl' => 'Verba cum ablātīvō',
        'cas-verba-gen' => 'Verba cum genetīvō',
        'cas-prep-duplex' => 'In et sub',
        'cas-prep-abl' => 'Praepositiōnēs cum ablātīvō',
        'cas-prep-acc' => 'Praepositiōnēs cum accūsātīvō',
        'cas-loci' => 'Nōmina urbium',
        'cas-temporis' => 'Tempus',
        _ => t,
      };
}
