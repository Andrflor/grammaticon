/// Trial (contrōversia) catalogue of the Forum: declension challenges
/// presented as oratory duels. Uses the shared [Trial] model; the content is
/// selected by [NounFilter].
library;

import '../linguistics/model/grammar.dart';
import '../linguistics/model/noun.dart';
import 'trial.dart';

/// Predicate over (noun, form) pairs. Null fields do not filter.
class NounFilter extends ContentFilter {
  const NounFilter({
    this.declensions,
    this.cases,
    this.numbers,
    this.genders,
    this.thirdStems,
    this.lemmaIds,
    this.excludeLemmaIds = const {},
    this.variantKinds = const {VariantKind.norma},
    this.includeProper = false,
    this.onlyLocativeNouns = false,
  });

  final Set<Declension>? declensions;

  /// Cases drawn as question surfaces. The locative is drawn only when listed.
  final Set<Casus>? cases;
  final Set<Numerus>? numbers;
  final Set<Gender>? genders;
  final Set<ThirdStem>? thirdStems;
  final Set<String>? lemmaIds;
  final Set<String> excludeLemmaIds;

  /// Variant kinds drawn as surfaces (introductory trials: primary only).
  final Set<VariantKind>? variantKinds;

  /// Proper names (Rōma, Athēnae, Iuppiter…) are excluded unless requested.
  final bool includeProper;

  /// Restrict to nouns that have a locative.
  final bool onlyLocativeNouns;

  bool matchesNoun(NounEntry n) {
    if (lemmaIds != null && !lemmaIds!.contains(n.id)) return false;
    if (excludeLemmaIds.contains(n.id)) return false;
    if (declensions != null && !declensions!.contains(n.declension)) return false;
    if (genders != null && !genders!.contains(n.gender)) return false;
    if (thirdStems != null && !thirdStems!.contains(n.thirdStem)) return false;
    if (!includeProper && lemmaIds == null && _isProper(n)) return false;
    if (onlyLocativeNouns && !n.locative) return false;
    return true;
  }

  bool matchesForm(NounEntry n, NounForm f) {
    final a = f.analysis;
    if (a.casus == Casus.locativus && (cases == null || !cases!.contains(Casus.locativus))) return false;
    if (cases != null && !cases!.contains(a.casus)) return false;
    if (numbers != null && !numbers!.contains(a.number)) return false;
    if (variantKinds != null && !variantKinds!.contains(a.variant)) return false;
    return true;
  }

  bool matches(NounEntry n, NounForm f) => matchesNoun(n) && matchesForm(n, f);

  static bool _isProper(NounEntry n) => n.lemma[0].toUpperCase() == n.lemma[0] && n.lemma[0].toLowerCase() != n.lemma[0];
}

const _allCases = {Casus.nominativus, Casus.vocativus, Casus.accusativus, Casus.genetivus, Casus.dativus, Casus.ablativus};
const _allVariants = {VariantKind.norma, VariantKind.altera};

class NounTrials {
  NounTrials._();

  /// Groups in display order.
  static const groups = ['Prīma dēclīnātiō', 'Secunda dēclīnātiō', 'Tertia dēclīnātiō', 'Quārta et quīnta dēclīnātiō', 'Locātīvus', 'Mixta'];

  static List<Trial> build() => [
        // ----------------------------------------------------------- Prīma
        const Trial(
          id: 'd1-recti',
          activity: Activity.forum,
          name: 'Prīma dēclīnātiō: cāsūs prīmī',
          subtitle: 'nōminātīvus · accūsātīvus · ablātīvus',
          skillIds: ['d.1'],
          price: 0,
          prerequisites: [],
          filter: NounFilter(declensions: {Declension.prima}, cases: {Casus.nominativus, Casus.accusativus, Casus.ablativus}),
          dimensions: [Dimension.casus, Dimension.numerus],
          intro: 'Prīma dēclīnātiō nōmina in -a continet, ferē fēminīna (rosa, puella); poēta, nauta, agricola masculīna sunt. Thema in -ā. Singulāris: rosa (nōm.), rosam (acc.), rosā (abl., ā longā). Plūrālis: rosae (nōm.), rosās (acc.), rosīs (abl.).',
          examples: ['rosa · rosam · rosā', 'rosae · rosās · rosīs', 'rosā (abl.) ≠ rosa (nōm.)'],
          opponentId: 'rhetor',
          group: 'Prīma dēclīnātiō',
          showDictionaryEntry: true,
        ),
        const Trial(
          id: 'd1-omnes',
          activity: Activity.forum,
          name: 'Prīma dēclīnātiō: omnēs cāsūs',
          subtitle: 'rosa, rosae, rosae, rosam, rosa, rosā',
          skillIds: ['d.1'],
          price: 20,
          prerequisites: ['d1-recti'],
          filter: NounFilter(declensions: {Declension.prima}, cases: _allCases, variantKinds: _allVariants),
          dimensions: [Dimension.casus, Dimension.numerus, Dimension.analysis],
          intro: 'Omnēs cāsūs prīmae dēclīnātiōnis. Genetīvus et datīvus singulāris in -ae, ut nōminātīvus plūrālis: rosae quattuor analysēs habet. Genetīvus plūrālis -ārum, datīvus et ablātīvus plūrālis -īs; dea et fīlia habent deābus, fīliābus.',
          examples: ['rosae: gen. sg. · dat. sg. · nōm. pl. · voc. pl.', 'rosārum · rosīs', 'deābus · fīliābus'],
          opponentId: 'rhetor',
          group: 'Prīma dēclīnātiō',
          showDictionaryEntry: true,
        ),
        // ----------------------------------------------------------- Secunda
        const Trial(
          id: 'd2-us-um',
          activity: Activity.forum,
          name: 'Secunda dēclīnātiō: -us et -um',
          subtitle: 'servus · bellum',
          skillIds: ['d.2'],
          price: 20,
          prerequisites: ['d1-recti'],
          filter: NounFilter(
            declensions: {Declension.secunda},
            cases: {Casus.nominativus, Casus.accusativus, Casus.genetivus, Casus.dativus, Casus.ablativus},
            excludeLemmaIds: {'puer', 'ager', 'magister', 'liber', 'vir', 'deus', 'filius', 'consilium', 'imperium', 'castra', 'arma', 'humus'},
          ),
          dimensions: [Dimension.casus, Dimension.numerus],
          intro: 'Secunda dēclīnātiō: masculīna in -us (servus), neutra in -um (bellum). Thema in -o. Genetīvus -ī, datīvus et ablātīvus -ō, accūsātīvus -um. Plūrālis: servī, servōrum, servīs, servōs; neutra bella, bellōrum, bellīs. Neutrum: nōminātīvus = accūsātīvus.',
          examples: ['servus · servī · servō · servum · servō', 'servī · servōrum · servīs · servōs', 'bellum (nōm. = acc.) · bella'],
          opponentId: 'causidicus',
          group: 'Secunda dēclīnātiō',
          showDictionaryEntry: true,
        ),
        const Trial(
          id: 'd2-omnes',
          activity: Activity.forum,
          name: 'Secunda dēclīnātiō: omnēs cāsūs',
          subtitle: 'puer · ager · vir · fīlius · deus',
          skillIds: ['d.2'],
          price: 25,
          prerequisites: ['d2-us-um'],
          filter: NounFilter(declensions: {Declension.secunda}, cases: _allCases, variantKinds: _allVariants),
          dimensions: [Dimension.casus, Dimension.numerus, Dimension.analysis],
          intro: 'Vocātīvus in -e (serve), sed fīlī (nōmina in -ius) et deus. Puer, ager, vir nōminātīvum sine -us habent: puerī, agrī (e cadit), virī. Deus plūrālem habet dī, deōrum (deum), dīs. Castra et arma plūrālia tantum sunt.',
          examples: ['serve! · fīlī! · deus!', 'puer, puerī · ager, agrī · vir, virī', 'dī · deōrum · dīs · castra · arma'],
          opponentId: 'causidicus',
          group: 'Secunda dēclīnātiō',
          showDictionaryEntry: true,
        ),
        // ----------------------------------------------------------- Tertia
        const Trial(
          id: 'd3-consonantia',
          activity: Activity.forum,
          name: 'Tertia dēclīnātiō: themata cōnsonantia',
          subtitle: 'rēx · cōnsul · corpus · nōmen',
          skillIds: ['d.3'],
          price: 30,
          prerequisites: ['d2-us-um'],
          filter: NounFilter(declensions: {Declension.tertia}, cases: _allCases, thirdStems: {ThirdStem.consonans}, excludeLemmaIds: {'vis', 'bos', 'senex', 'iuppiter', 'os', 'iter'}),
          dimensions: [Dimension.casus, Dimension.numerus],
          intro: 'Tertia dēclīnātiō omnia genera continet. Nōminātīvus varius est, thema ē genetīvō cognōscitur: rēx, rēg-is; corpus, corpor-is. Dēsinentiae: -is, -ī, -em, -e; plūrālis -ēs, -um, -ibus. Neutra: nōminātīvus = accūsātīvus, plūrālis in -a (corpora).',
          examples: ['rēx · rēgis · rēgī · rēgem · rēge', 'rēgēs · rēgum · rēgibus', 'corpus · corporis · corpora'],
          opponentId: 'senator',
          group: 'Tertia dēclīnātiō',
          showDictionaryEntry: true,
        ),
        const Trial(
          id: 'd3-i',
          activity: Activity.forum,
          name: 'Tertia dēclīnātiō: themata in -i',
          subtitle: 'cīvis · urbs · mare · animal',
          skillIds: ['d.3'],
          price: 35,
          prerequisites: ['d3-consonantia'],
          filter: NounFilter(declensions: {Declension.tertia}, cases: _allCases, thirdStems: {ThirdStem.vocalisI, ThirdStem.vocalisIPura, ThirdStem.neutrumI}, excludeLemmaIds: {'vis'}, variantKinds: _allVariants),
          dimensions: [Dimension.casus, Dimension.numerus],
          intro: 'Themata in -i: genetīvus plūrālis -ium (cīvium, urbium), accūsātīvus plūrālis -ēs aut -īs. Neutra in -e, -al, -ar: ablātīvus -ī (marī), plūrālis -ia (maria, animālia), -ium. Turris et nāvis accūsātīvum -im et ablātīvum -ī admittunt.',
          examples: ['cīvis · cīvium · cīvēs / cīvīs', 'mare · marī · maria · marium', 'turrim · turrī · nāvem / nāvim'],
          opponentId: 'senator',
          group: 'Tertia dēclīnātiō',
          showDictionaryEntry: true,
        ),
        const Trial(
          id: 'd3-omnia',
          activity: Activity.forum,
          name: 'Tertia dēclīnātiō: omnia',
          subtitle: 'vīs · bōs · senex · Iuppiter · iter',
          skillIds: ['d.3'],
          price: 40,
          prerequisites: ['d3-i'],
          filter: NounFilter(declensions: {Declension.tertia}, cases: _allCases, variantKinds: _allVariants, includeProper: true, excludeLemmaIds: {'carthago'}),
          dimensions: [Dimension.casus, Dimension.numerus, Dimension.analysis],
          intro: 'Tōta tertia dēclīnātiō cum nōminibus irregulāribus: vīs (vim, vī; plūrālis vīrēs, vīrium), bōs (bovis; boum, bōbus), senex (senis), Iuppiter (Iovis), iter (itineris), os (ossis, ossium). Nunc analysis complēta rogātur.',
          examples: ['vīs · vim · vī · vīrēs · vīrium', 'bōs · bovis · boum · bōbus', 'Iuppiter · Iovis · Iovem · iter · itineris'],
          opponentId: 'philosophus',
          group: 'Tertia dēclīnātiō',
          showDictionaryEntry: false,
        ),
        // ----------------------------------------------------------- Quārta et quīnta
        const Trial(
          id: 'd4',
          activity: Activity.forum,
          name: 'Quārta dēclīnātiō',
          subtitle: 'manus · exercitus · cornū · domus',
          skillIds: ['d.4'],
          price: 30,
          prerequisites: ['d2-us-um'],
          filter: NounFilter(declensions: {Declension.quarta}, cases: _allCases, variantKinds: _allVariants),
          dimensions: [Dimension.casus, Dimension.numerus, Dimension.analysis],
          intro: 'Quārta dēclīnātiō: thema in -u. Masculīna (et manus, tribus fēminīna) in -us: manus, manūs, manuī, manum, manū; plūrālis manūs, manuum, manibus. Neutra in -ū: cornū, cornūs, cornua. Domus fōrmās quārtae et secundae miscet: domō, domōrum, domī (locātīvus).',
          examples: ['manus · manūs · manuī · manum · manū', 'manūs · manuum · manibus', 'cornū · cornūs · cornua · cornuum'],
          opponentId: 'causidicus',
          group: 'Quārta et quīnta dēclīnātiō',
          showDictionaryEntry: true,
        ),
        const Trial(
          id: 'd5',
          activity: Activity.forum,
          name: 'Quīnta dēclīnātiō',
          subtitle: 'rēs · diēs · spēs · fidēs',
          skillIds: ['d.5'],
          price: 30,
          prerequisites: ['d1-omnes'],
          filter: NounFilter(declensions: {Declension.quinta}, cases: _allCases),
          dimensions: [Dimension.casus, Dimension.numerus, Dimension.analysis],
          intro: 'Quīnta dēclīnātiō: thema in -ē. Fēminīna praeter diēs (m.). Rēs, reī, reī, rem, rēs, rē; plūrālis rēs, rērum, rēbus. Ē genetīvī et datīvī longa post vōcālem (diēī), brevis post cōnsonantem (reī, fideī). Sōla rēs et diēs plūrālem plēnum habent.',
          examples: ['rēs · reī · rem · rē', 'rēs · rērum · rēbus', 'diēs · diēī · diem · diēbus'],
          opponentId: 'rhetor',
          group: 'Quārta et quīnta dēclīnātiō',
          showDictionaryEntry: true,
        ),
        // ----------------------------------------------------------- Locātīvus
        const Trial(
          id: 'd-locativus',
          activity: Activity.forum,
          name: 'Locātīvus',
          subtitle: 'Rōmae · domī · Carthāginī · rūrī',
          skillIds: ['d.loc'],
          price: 35,
          prerequisites: ['d2-omnes', 'd3-consonantia'],
          filter: NounFilter(cases: {..._allCases, Casus.locativus}, includeProper: true, onlyLocativeNouns: true, variantKinds: _allVariants),
          dimensions: [Dimension.casus, Dimension.numerus],
          intro: 'Locātīvus locum ubi aliquid est significat, in nōminibus urbium et īnsulārum parvārum, et in domus, rūs, humus. Prīma et secunda dēclīnātiō singulāris: -ae, -ī (Rōmae, Corinthī, domī, humī); tertia -ī aut -e (Carthāginī, rūrī); plūrālis ut ablātīvus (Athēnīs).',
          examples: ['Rōmae · Corinthī · Carthāginī', 'domī · rūrī · humī', 'Athēnīs (loc. = abl. pl.)'],
          opponentId: 'philosophus',
          group: 'Locātīvus',
          showDictionaryEntry: true,
        ),
        // ----------------------------------------------------------- Mixta
        Trial(
          id: 'dmx-declinatio',
          activity: Activity.forum,
          name: 'Mixta: quae dēclīnātiō?',
          subtitle: 'agnōsce dēclīnātiōnem',
          skillIds: const ['d.mx.declinatio'],
          price: 50,
          prerequisites: const ['d3-consonantia', 'd4', 'd5'],
          filter: const NounFilter(cases: _allCases),
          dimensions: const [Dimension.declinatio],
          components: [for (final d in Declension.values) TrialComponent(d.key, '${d.latin} dēclīnātiō', NounFilter(declensions: {d}, cases: _allCases))],
          intro: 'Nunc dēclīnātiō nōn datur: ex dēsinentiā eam agnōscere dēbēs. Cavē similitūdinēs: -īs (I et II datīvus/ablātīvus plūrālis), -ibus (III et IV), -us (II nōminātīvus, III neutrum, IV), -ēs (III et V).',
          examples: ['rosīs (I) · servīs (II)', 'rēgibus (III) · manibus (IV)', 'corpus (III) · manus (IV) · rēs (V)'],
          opponentId: 'senator',
          group: 'Mixta',
        ),
        Trial(
          id: 'dmx-casus',
          activity: Activity.forum,
          name: 'Mixta: cāsūs omnium dēclīnātiōnum',
          subtitle: 'cāsus et numerus',
          skillIds: const ['d.mx.casus'],
          price: 60,
          prerequisites: const ['dmx-declinatio'],
          filter: const NounFilter(cases: _allCases, variantKinds: _allVariants),
          dimensions: const [Dimension.casus, Dimension.numerus],
          components: [for (final d in Declension.values) TrialComponent(d.key, '${d.latin} dēclīnātiō', NounFilter(declensions: {d}, cases: _allCases, variantKinds: _allVariants))],
          intro: 'Cāsūs et numerī omnium dēclīnātiōnum mixtī. Eadem dēsinentia alium cāsum in aliā dēclīnātiōne significat: -ae (I) et -ēs (III) sunt nōminātīvus plūrālis; -um est accūsātīvus (II, IV) aut genetīvus plūrālis (III).',
          examples: ['rosae · rēgēs (nōm. pl.)', 'servum · manum (acc. sg.) · rēgum (gen. pl.)', 'rosā · rēge · manū · rē (abl. sg.)'],
          opponentId: 'philosophus',
          group: 'Mixta',
        ),
        Trial(
          id: 'dmx-omnia',
          activity: Activity.forum,
          name: 'Omnia mixta',
          subtitle: 'summa contrōversia',
          skillIds: const ['d.mx.omnia'],
          price: 100,
          prerequisites: const ['dmx-casus', 'd3-omnia', 'd-locativus'],
          filter: const NounFilter(cases: {..._allCases, Casus.locativus}, variantKinds: _allVariants, includeProper: true),
          dimensions: const [Dimension.analysis, Dimension.casus, Dimension.numerus, Dimension.declinatio],
          components: [
            for (final d in Declension.values) TrialComponent(d.key, '${d.latin} dēclīnātiō', NounFilter(declensions: {d}, cases: {..._allCases, Casus.locativus}, variantKinds: _allVariants, includeProper: true)),
          ],
          intro: 'Omnia mixta: quodlibet nōmen cuiuslibet dēclīnātiōnis, cum locātīvō et fōrmīs variīs. Analysis complēta rogātur: cāsus et numerus; aut dēclīnātiō.',
          examples: ['vīribus · diēbus · Athēnīs', 'fīlī · dī · boum · domī', 'omnia quae didicistī'],
          opponentId: 'censor',
          group: 'Mixta',
        ),
      ];
}
