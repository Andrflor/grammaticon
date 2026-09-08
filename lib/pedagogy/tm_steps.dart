/// Ladders of tense recognition, one per mood and voice.
///
/// The progression follows the confusions a learner actually makes, not the
/// grammar book: each step isolates one contrast on a two-cell grid (praesēns
/// against futūrum, plūsquamperfectum against futūrum exāctum…), then the two
/// systems come as triplets, then every tense at once. Each step has its own
/// skill leaf under the mood/voice skill and its own trial; the catalogue here
/// feeds both the skill tree and the trial registry.
library;

import '../linguistics/model/grammar.dart';

class TmStep {
  const TmStep({
    required this.key,
    required this.name,
    required this.tenses,
    required this.after,
    required this.price,
    required this.intro,
    required this.examples,
  });

  /// Suffix of the skill id and of the trial id (`omnia` keeps the historical
  /// trial id without suffix).
  final String key;
  final String name;
  final List<Tense> tenses;

  /// Keys of the steps of the same ladder that must be accessible first.
  final List<String> after;
  final int price;
  final String intro;
  final List<String> examples;

  String get hint => examples.first;
  bool get isLast => key == 'omnia';
}

class TmLadders {
  TmLadders._();

  static List<TmStep> of(Mood mood, Voice voice) => switch ((mood, voice)) {
        (Mood.indicativus, Voice.activum) => indActive,
        (Mood.indicativus, Voice.passivum) => indPassive,
        (Mood.subiunctivus, Voice.activum) => subjActive,
        (Mood.subiunctivus, Voice.passivum) => subjPassive,
        _ => const [],
      };

  static const ladders = [(Mood.indicativus, Voice.activum), (Mood.indicativus, Voice.passivum), (Mood.subiunctivus, Voice.activum), (Mood.subiunctivus, Voice.passivum)];

  /// Skill of the mood/voice, parent of the steps' leaves.
  static String parentSkill(Mood mood, Voice voice) => 'tm.tempus.${mood.key}.${voice.key}';
  static String skillId(Mood mood, Voice voice, TmStep s) => '${parentSkill(mood, voice)}.${s.key}';
  static String trialId(Mood mood, Voice voice, TmStep s) => s.isLast ? 'tm-tempora-${mood.key}-${voice.key}' : 'tm-tempora-${mood.key}-${voice.key}-${s.key}';

  static const _p = Tense.praesens, _i = Tense.imperfectum, _f = Tense.futurum, _pf = Tense.perfectum, _pq = Tense.plusquamperfectum, _fx = Tense.futurumExactum;

  // ------------------------------------------------------------ indicative
  static const indActive = [
    TmStep(
      key: 'praes-imperf',
      name: 'Praesēns an imperfectum',
      tenses: [_p, _i],
      after: [],
      price: 10,
      intro: 'Nunc ūnum rogātur: quod tempus? Persōna et numerus nōn quaeruntur. Praesēns nūllum signum habet (amat, regit), imperfectum -ba- (amābat, regēbat).',
      examples: ['amat · amābat', 'regit · regēbat', 'audit · audiēbat'],
    ),
    TmStep(
      key: 'praes-fut',
      name: 'Praesēns an futūrum',
      tenses: [_p, _f],
      after: ['praes-imperf'],
      price: 10,
      intro: 'Praesēns an futūrum? In prīmā et secundā -b- futūrum signat (amābit, monēbit); in tertiā et quārtā sōla vōcālis distat: regit ≠ reget, audit ≠ audiet.',
      examples: ['amat · amābit', 'regit · reget', 'audit · audiet'],
    ),
    TmStep(
      key: 'praes-perf',
      name: 'Praesēns an perfectum',
      tenses: [_p, _pf],
      after: ['praes-imperf'],
      price: 10,
      intro: 'Praesēns an perfectum? Thema mūtātur: amat ā themate praesentis, amāvit ā themate perfectī. Cavē tertiam: regit ≠ rēxit, dīcit ≠ dīxit.',
      examples: ['amat · amāvit', 'regit · rēxit', 'audit · audīvit'],
    ),
    TmStep(
      key: 'perf-plusq',
      name: 'Perfectum an plūsquamperfectum',
      tenses: [_pf, _pq],
      after: ['praes-perf'],
      price: 15,
      intro: 'Perfectum an plūsquamperfectum? Idem thema perfectī; perfectum dēsinentiās suās habet (-ī, -istī, -it), plūsquamperfectum -era- (amāverat).',
      examples: ['amāvit · amāverat', 'rēxit · rēxerat', 'amāvimus · amāverāmus'],
    ),
    TmStep(
      key: 'imperf-plusq',
      name: 'Imperfectum an plūsquamperfectum',
      tenses: [_i, _pq],
      after: ['perf-plusq'],
      price: 15,
      intro: 'Imperfectum an plūsquamperfectum? Eaedem dēsinentiae (-m, -s, -t), aliud thema: amābat ā praesentī cum -ba-, amāverat ā perfectō cum -era-.',
      examples: ['amābat · amāverat', 'regēbat · rēxerat', 'audiēbat · audīverat'],
    ),
    TmStep(
      key: 'plusq-futex',
      name: 'Plūsquamperfectum an futūrum exāctum',
      tenses: [_pq, _fx],
      after: ['perf-plusq'],
      price: 15,
      intro: 'Plūsquamperfectum an futūrum exāctum? Ūna vōcālis distat: -era- (amāverat) an -eri- (amāverit). Prīma persōna: amāveram ≠ amāverō.',
      examples: ['amāverat · amāverit', 'rēxerat · rēxerit', 'amāveram · amāverō'],
    ),
    TmStep(
      key: 'fut-futex',
      name: 'Futūrum an futūrum exāctum',
      tenses: [_f, _fx],
      after: ['praes-fut', 'plusq-futex'],
      price: 15,
      intro: 'Futūrum an futūrum exāctum? Futūrum ā themate praesentis (amābit, reget), futūrum exāctum ā themate perfectī cum -eri- (amāverit, rēxerit).',
      examples: ['amābit · amāverit', 'reget · rēxerit', 'audiet · audīverit'],
    ),
    TmStep(
      key: 'praes-imperf-fut',
      name: 'Systēma praesentis',
      tenses: [_p, _i, _f],
      after: ['praes-fut'],
      price: 20,
      intro: 'Systēma praesentis complētum: praesēns, imperfectum, futūrum, omnia ā themate praesentis. Signa: nūllum praesēns, -ba- imperfectum, -b- aut vōcālis mūtāta futūrum.',
      examples: ['amat · amābat · amābit', 'regit · regēbat · reget', 'audit · audiēbat · audiet'],
    ),
    TmStep(
      key: 'perf-plusq-futex',
      name: 'Systēma perfectī',
      tenses: [_pf, _pq, _fx],
      after: ['plusq-futex'],
      price: 20,
      intro: 'Systēma perfectī complētum: omnia ā themate perfectī. Dēsinentiae propriae perfectum (-it), -era- plūsquamperfectum, -eri- futūrum exāctum.',
      examples: ['amāvit · amāverat · amāverit', 'rēxit · rēxerat · rēxerit', 'audīvit · audīverat · audīverit'],
    ),
    TmStep(
      key: 'omnia',
      name: 'Omnia tempora indicātīvī',
      tenses: [_p, _i, _f, _pf, _pq, _fx],
      after: ['imperf-plusq', 'fut-futex', 'praes-imperf-fut', 'perf-plusq-futex'],
      price: 25,
      intro: 'Omnia sex tempora indicātīvī mixta. Signa: nūllum signum praesēns, -ba- imperfectum, -b-/vōcālis futūrum, thema perfectī perfectum, -era- plūsquamperfectum, -eri- futūrum exāctum.',
      examples: ['amat · amābat · amābit', 'amāvit · amāverat · amāverit', 'regit ≠ reget ≠ rēxit'],
    ),
  ];

  static const indPassive = [
    TmStep(
      key: 'praes-imperf',
      name: 'Praesēns an imperfectum',
      tenses: [_p, _i],
      after: [],
      price: 15,
      intro: 'Praesēns an imperfectum passīvī? Idem signum -ba- quod in āctīvō, dēsinentiae passīvae: amātur, amābātur.',
      examples: ['amātur · amābātur', 'regitur · regēbātur', 'audītur · audiēbātur'],
    ),
    TmStep(
      key: 'praes-fut',
      name: 'Praesēns an futūrum',
      tenses: [_p, _f],
      after: ['praes-imperf'],
      price: 15,
      intro: 'Praesēns an futūrum passīvī? Prīma et secunda -b- (amābitur); tertia et quārta sōlā vōcālī: regitur ≠ regētur, audītur ≠ audiētur.',
      examples: ['amātur · amābitur', 'regitur · regētur', 'audītur · audiētur'],
    ),
    TmStep(
      key: 'praes-perf',
      name: 'Praesēns an perfectum',
      tenses: [_p, _pf],
      after: ['praes-imperf'],
      price: 15,
      intro: 'Praesēns an perfectum passīvī? Praesēns simplex (amātur), perfectum compositum: participium perfectī cum est (amātus est).',
      examples: ['amātur · amātus est', 'regitur · rēctus est', 'audītur · audītus est'],
    ),
    TmStep(
      key: 'perf-plusq',
      name: 'Perfectum an plūsquamperfectum',
      tenses: [_pf, _pq],
      after: ['praes-perf'],
      price: 20,
      intro: 'Perfectum an plūsquamperfectum passīvī? Idem participium, aliud auxiliāre: est perfectum, erat plūsquamperfectum.',
      examples: ['amātus est · amātus erat', 'rēctus est · rēctus erat', 'amātī sunt · amātī erant'],
    ),
    TmStep(
      key: 'imperf-plusq',
      name: 'Imperfectum an plūsquamperfectum',
      tenses: [_i, _pq],
      after: ['perf-plusq'],
      price: 20,
      intro: 'Imperfectum an plūsquamperfectum passīvī? Simplex cum -ba- (amābātur) an compositum cum erat (amātus erat).',
      examples: ['amābātur · amātus erat', 'regēbātur · rēctus erat', 'audiēbātur · audītus erat'],
    ),
    TmStep(
      key: 'plusq-futex',
      name: 'Plūsquamperfectum an futūrum exāctum',
      tenses: [_pq, _fx],
      after: ['perf-plusq'],
      price: 20,
      intro: 'Plūsquamperfectum an futūrum exāctum passīvī? Auxiliāre discernit: erat (amātus erat) an erit (amātus erit).',
      examples: ['amātus erat · amātus erit', 'rēctus erat · rēctus erit', 'amātī erant · amātī erunt'],
    ),
    TmStep(
      key: 'fut-futex',
      name: 'Futūrum an futūrum exāctum',
      tenses: [_f, _fx],
      after: ['praes-fut', 'plusq-futex'],
      price: 20,
      intro: 'Futūrum an futūrum exāctum passīvī? Simplex (amābitur, regētur) an compositum cum erit (amātus erit, rēctus erit).',
      examples: ['amābitur · amātus erit', 'regētur · rēctus erit', 'audiētur · audītus erit'],
    ),
    TmStep(
      key: 'praes-imperf-fut',
      name: 'Systēma praesentis',
      tenses: [_p, _i, _f],
      after: ['praes-fut'],
      price: 25,
      intro: 'Systēma praesentis passīvī: fōrmae simplicēs omnēs. amātur, amābātur, amābitur; cavē tertiam: regitur ≠ regētur.',
      examples: ['amātur · amābātur · amābitur', 'regitur · regēbātur · regētur', 'audītur · audiēbātur · audiētur'],
    ),
    TmStep(
      key: 'perf-plusq-futex',
      name: 'Systēma perfectī',
      tenses: [_pf, _pq, _fx],
      after: ['plusq-futex'],
      price: 25,
      intro: 'Systēma perfectī passīvī: fōrmae compositae omnēs, tempus ex auxiliārī sūmitur: est perfectum, erat plūsquamperfectum, erit futūrum exāctum.',
      examples: ['amātus est · amātus erat · amātus erit', 'rēctus est · rēctus erat · rēctus erit', 'amātī sunt · erant · erunt'],
    ),
    TmStep(
      key: 'omnia',
      name: 'Omnia tempora indicātīvī',
      tenses: [_p, _i, _f, _pf, _pq, _fx],
      after: ['imperf-plusq', 'fut-futex', 'praes-imperf-fut', 'perf-plusq-futex'],
      price: 30,
      intro: 'Omnia tempora passīvī mixta: simplicia (amātur, amābātur, amābitur) et composita (amātus est, erat, erit). In compositīs tempus ex auxiliārī sūmitur.',
      examples: ['amātur · amābātur · amābitur', 'amātus est · amātus erat · amātus erit', 'amātus est (perf.) ≠ amātur (praes.)'],
    ),
  ];

  // ------------------------------------------------------------ subjunctive
  static const subjActive = [
    TmStep(
      key: 'praes-imperf',
      name: 'Praesēns an imperfectum',
      tenses: [_p, _i],
      after: [],
      price: 15,
      intro: 'Praesēns an imperfectum subiūnctīvī? Praesēns vōcālem mūtat (amet, regat), imperfectum īnfīnītīvum + dēsinentiam habet (amāret, regeret).',
      examples: ['amet · amāret', 'regat · regeret', 'audiat · audīret'],
    ),
    TmStep(
      key: 'praes-perf',
      name: 'Praesēns an perfectum',
      tenses: [_p, _pf],
      after: ['praes-imperf'],
      price: 15,
      intro: 'Praesēns an perfectum subiūnctīvī? Praesēns ā themate praesentis vōcāle mūtātā (amet, regat), perfectum ā themate perfectī cum -eri- (amāverit, rēxerit).',
      examples: ['amet · amāverit', 'regat · rēxerit', 'audiat · audīverit'],
    ),
    TmStep(
      key: 'perf-plusq',
      name: 'Perfectum an plūsquamperfectum',
      tenses: [_pf, _pq],
      after: ['praes-perf'],
      price: 20,
      intro: 'Perfectum an plūsquamperfectum subiūnctīvī? Idem thema perfectī: -eri- perfectum (amāverit), -isse- plūsquamperfectum (amāvisset).',
      examples: ['amāverit · amāvisset', 'rēxerit · rēxisset', 'audīverit · audīvisset'],
    ),
    TmStep(
      key: 'imperf-plusq',
      name: 'Imperfectum an plūsquamperfectum',
      tenses: [_i, _pq],
      after: ['perf-plusq'],
      price: 20,
      intro: 'Imperfectum an plūsquamperfectum subiūnctīvī? Eaedem dēsinentiae post -re- (amāret) aut -isse- (amāvisset): thema discernit.',
      examples: ['amāret · amāvisset', 'regeret · rēxisset', 'audīret · audīvisset'],
    ),
    TmStep(
      key: 'omnia',
      name: 'Omnia tempora subiūnctīvī',
      tenses: [_p, _i, _pf, _pq],
      after: ['imperf-plusq'],
      price: 25,
      intro: 'Quattuor tempora subiūnctīvī mixta. Praesēns vōcālem mūtat (amet), imperfectum -re- (amāret), perfectum -eri- (amāverit), plūsquamperfectum -isse- (amāvisset).',
      examples: ['amet · amāret', 'amāverit · amāvisset', 'regat ≠ regeret ≠ rēxerit'],
    ),
  ];

  static const subjPassive = [
    TmStep(
      key: 'praes-imperf',
      name: 'Praesēns an imperfectum',
      tenses: [_p, _i],
      after: [],
      price: 20,
      intro: 'Praesēns an imperfectum subiūnctīvī passīvī? Simplicia ambō: amētur (vōcālis mūtāta), amārētur (-rē-).',
      examples: ['amētur · amārētur', 'regātur · regerētur', 'audiātur · audīrētur'],
    ),
    TmStep(
      key: 'praes-perf',
      name: 'Praesēns an perfectum',
      tenses: [_p, _pf],
      after: ['praes-imperf'],
      price: 20,
      intro: 'Praesēns an perfectum subiūnctīvī passīvī? Simplex (amētur) an compositum cum sit (amātus sit).',
      examples: ['amētur · amātus sit', 'regātur · rēctus sit', 'audiātur · audītus sit'],
    ),
    TmStep(
      key: 'perf-plusq',
      name: 'Perfectum an plūsquamperfectum',
      tenses: [_pf, _pq],
      after: ['praes-perf'],
      price: 25,
      intro: 'Perfectum an plūsquamperfectum subiūnctīvī passīvī? Idem participium, auxiliāre discernit: sit perfectum, esset plūsquamperfectum.',
      examples: ['amātus sit · amātus esset', 'rēctus sit · rēctus esset', 'amātī sint · amātī essent'],
    ),
    TmStep(
      key: 'imperf-plusq',
      name: 'Imperfectum an plūsquamperfectum',
      tenses: [_i, _pq],
      after: ['perf-plusq'],
      price: 25,
      intro: 'Imperfectum an plūsquamperfectum subiūnctīvī passīvī? Simplex cum -rē- (amārētur) an compositum cum esset (amātus esset).',
      examples: ['amārētur · amātus esset', 'regerētur · rēctus esset', 'audīrētur · audītus esset'],
    ),
    TmStep(
      key: 'omnia',
      name: 'Omnia tempora subiūnctīvī',
      tenses: [_p, _i, _pf, _pq],
      after: ['imperf-plusq'],
      price: 30,
      intro: 'Quattuor tempora subiūnctīvī passīvī mixta. Simplicia: amētur, amārētur. Composita: amātus sit (perfectum), amātus esset (plūsquamperfectum).',
      examples: ['amētur · amārētur', 'amātus sit · amātus esset', 'amātus sit (subj.) ≠ amātus est (ind.)'],
    ),
  ];
}

// =============================================================================
// Modī and Tempora et modī: ladders of cells (mood × tenses).
// =============================================================================

/// One mood with the tenses drawn from it (null = every tense of the mood).
class ModusCell {
  const ModusCell(this.mood, [this.tenses]);
  final Mood mood;
  final Set<Tense>? tenses;

  /// Conjugation trial that must be accessible before the cell may be mixed
  /// in, when the cell is a single tense (else the step's prerequisites hold).
  String? get requires {
    if (tenses == null || tenses!.length != 1) return null;
    final t = tenses!.first;
    return switch (mood) {
      Mood.imperativus => t == Tense.praesens ? 'imp-praes' : 'imp-fut',
      Mood.infinitivus => 'infinitivi',
      _ => '${mood.key}-${t.key}-act',
    };
  }
}

/// A step of the mood ladder or of the combined ladder.
class CellStep {
  const CellStep({
    required this.key,
    required this.name,
    required this.subtitle,
    required this.cells,
    required this.after,
    required this.requires,
    required this.price,
    required this.intro,
    required this.examples,
  });
  final String key;
  final String name;
  final String subtitle;
  final List<ModusCell> cells;

  /// Keys of the steps of the same ladder that must be accessible first.
  final List<String> after;

  /// Other trials (conjugation, tense or mood recognition) needed first.
  final List<String> requires;
  final int price;
  final String intro;
  final List<String> examples;

  String get hint => examples.first;
  Set<Mood> get moods => {for (final c in cells) c.mood};

  /// Union of the tenses drawn, null when some cell draws every tense.
  Set<Tense>? get tenses => cells.any((c) => c.tenses == null) ? null : {for (final c in cells) ...c.tenses!};
}

const _ind = Mood.indicativus, _subj = Mood.subiunctivus, _imp = Mood.imperativus, _inf = Mood.infinitivus;
const _tP = Tense.praesens, _tI = Tense.imperfectum, _tF = Tense.futurum, _tPf = Tense.perfectum, _tPq = Tense.plusquamperfectum, _tFx = Tense.futurumExactum;

/// Recognising the mood only, on a fixed grid of the moods mixed. The
/// confusions first, one tense at a time (amat an amet, amābat an amāret,
/// reget an regat…), then the four moods in the present, then at every tense.
class ModiLadder {
  ModiLadder._();

  static const parentSkill = 'tm.modus';
  static String skillId(CellStep s) => '$parentSkill.${s.key}';
  static String trialId(CellStep s) => 'tm-modi-${s.key}';
  static CellStep byKey(String key) => steps.firstWhere((s) => s.key == key);

  static const steps = [
    CellStep(
      key: 'ind-subj-praes',
      name: 'Indicātīvus an subiūnctīvus',
      subtitle: 'praesēns',
      cells: [ModusCell(_ind, {_tP}), ModusCell(_subj, {_tP})],
      after: [],
      requires: ['subj-praes-act'],
      price: 10,
      intro: 'Nunc ūnum rogātur: quī modus? Duo tantum, ambō praesentia: indicātīvus dīcit (amat, regit), subiūnctīvus vōcālem mūtat (amet, regat). Prīma coniugātiō ā in e vertit, cēterae in a.',
      examples: ['amat · amet', 'regit · regat', 'audit · audiat'],
    ),
    CellStep(
      key: 'ind-subj-imperf',
      name: 'Indicātīvus an subiūnctīvus',
      subtitle: 'imperfectum',
      cells: [ModusCell(_ind, {_tI}), ModusCell(_subj, {_tI})],
      after: ['ind-subj-praes'],
      requires: ['subj-imperf-act'],
      price: 10,
      intro: 'Imperfectum utrīusque modī: indicātīvus -ba- (amābat, regēbat), subiūnctīvus īnfīnītīvum + dēsinentiam (amāret, regeret).',
      examples: ['amābat · amāret', 'regēbat · regeret', 'audiēbat · audīret'],
    ),
    CellStep(
      key: 'fut-subj-praes',
      name: 'Futūrum an praesēns subiūnctīvī',
      subtitle: 'indicātīvus · subiūnctīvus',
      cells: [ModusCell(_ind, {_tF}), ModusCell(_subj, {_tP})],
      after: ['ind-subj-praes'],
      requires: ['ind-fut-act', 'subj-praes-act'],
      price: 15,
      intro: 'Futūrum indicātīvī an praesēns subiūnctīvī? In prīmā et secundā clārum: amābit ≠ amet. In tertiā et quārtā ūna vōcālis distat: reget ≠ regat, audiet ≠ audiat. Prīma persōna regam ambigua est: ambae respōnsiōnēs accipiuntur.',
      examples: ['amābit · amet', 'reget · regat', 'regam: futūrum aut subiūnctīvus'],
    ),
    CellStep(
      key: 'ind-imp',
      name: 'Indicātīvus an imperātīvus',
      subtitle: 'praesēns',
      cells: [ModusCell(_ind, {_tP}), ModusCell(_imp, {_tP})],
      after: ['ind-subj-praes'],
      requires: ['imp-praes'],
      price: 10,
      intro: 'Indicātīvus an imperātīvus? Imperātīvus secundae persōnae dēsinentiam persōnae nōn habet (amā, rege, audī) aut -te (amāte); indicātīvus -s, -tis (amās, amātis).',
      examples: ['amās · amā', 'regitis · regite', 'audīs · audī'],
    ),
    CellStep(
      key: 'inf-imp',
      name: 'Īnfīnītīvus an imperātīvus',
      subtitle: 'praesēns',
      cells: [ModusCell(_inf, {_tP}), ModusCell(_imp, {_tP})],
      after: ['ind-imp'],
      requires: ['infinitivi', 'imp-praes'],
      price: 10,
      intro: 'Īnfīnītīvus an imperātīvus? Īnfīnītīvus -re habet (amāre, regere), imperātīvus sine -re (amā, rege). Cavē: audīre ≠ audī.',
      examples: ['amāre · amā', 'regere · rege', 'audīre · audī'],
    ),
    CellStep(
      key: 'inf-subj-imperf',
      name: 'Īnfīnītīvus an subiūnctīvus imperfectum',
      subtitle: 'īnfīnītīvus · subiūnctīvus',
      cells: [ModusCell(_inf, {_tP}), ModusCell(_subj, {_tI})],
      after: ['ind-subj-imperf', 'inf-imp'],
      requires: ['infinitivi', 'subj-imperf-act'],
      price: 15,
      intro: 'Īnfīnītīvus an imperfectum subiūnctīvī? Ex īnfīnītīvō fit imperfectum: amāre + -m, -s, -t (amārem, amārēs, amāret). Sine dēsinentiā persōnae īnfīnītīvus manet.',
      examples: ['amāre · amāret', 'regere · regeret', 'audīre · audīret'],
    ),
    CellStep(
      key: 'ind-subj-plusq',
      name: 'Indicātīvus an subiūnctīvus',
      subtitle: 'plūsquamperfectum',
      cells: [ModusCell(_ind, {_tPq}), ModusCell(_subj, {_tPq})],
      after: ['ind-subj-imperf'],
      requires: ['ind-plusq-act', 'subj-plusq-act'],
      price: 15,
      intro: 'Plūsquamperfectum utrīusque modī, idem thema perfectī: indicātīvus -era- (amāverat), subiūnctīvus -isse- (amāvisset).',
      examples: ['amāverat · amāvisset', 'rēxerat · rēxisset', 'audīverat · audīvisset'],
    ),
    CellStep(
      key: 'ind-subj-perf',
      name: 'Indicātīvus an subiūnctīvus',
      subtitle: 'perfectum',
      cells: [ModusCell(_ind, {_tPf}), ModusCell(_subj, {_tPf})],
      after: ['ind-subj-plusq'],
      requires: ['subj-perf-act'],
      price: 15,
      intro: 'Perfectum utrīusque modī: indicātīvus dēsinentiās suās habet (amāvit, amāvistī), subiūnctīvus -eri- (amāverit, amāverīs).',
      examples: ['amāvit · amāverit', 'rēxit · rēxerit', 'amāvistī · amāverīs'],
    ),
    CellStep(
      key: 'praes',
      name: 'Modī praesentis',
      subtitle: 'indicātīvus · subiūnctīvus · imperātīvus · īnfīnītīvus',
      cells: [ModusCell(_ind, {_tP}), ModusCell(_subj, {_tP}), ModusCell(_imp, {_tP}), ModusCell(_inf, {_tP})],
      after: ['ind-subj-praes', 'ind-imp', 'inf-imp'],
      requires: ['imp-praes', 'infinitivi'],
      price: 20,
      intro: 'Quī modus? Omnia praesentia sunt, ut sōlus modus discernātur. Indicātīvus dīcit (amat), subiūnctīvus vōcālem mūtat (amet), imperātīvus iubet (amā), īnfīnītīvus persōnam nōn habet (amāre).',
      examples: ['amat · amet · amā · amāre', 'regit · regat · rege · regere', 'audit · audiat · audī · audīre'],
    ),
    CellStep(
      key: 'omnia',
      name: 'Modī omnium temporum',
      subtitle: 'indicātīvus · subiūnctīvus · imperātīvus · īnfīnītīvus',
      cells: [ModusCell(_ind), ModusCell(_subj), ModusCell(_imp), ModusCell(_inf)],
      after: ['fut-subj-praes', 'inf-subj-imperf', 'ind-subj-perf', 'praes'],
      requires: ['imp-fut', 'ind-futex-act', 'subj-plusq-act'],
      price: 25,
      intro: 'Quī modus, quōcumque tempore? Cavē fōrmās ambiguās: regam (futūrum indicātīvī / praesēns subiūnctīvī), amāverit (futūrum exāctum / perfectum subiūnctīvī). Ambae respōnsiōnēs tunc accipiuntur.',
      examples: ['amābat · amāret · amātō · amāvisse', 'rēxerat · rēxisset · regitō · rēxisse', 'regam: futūrum aut subiūnctīvus'],
    ),
  ];
}

/// Tense and mood in one answer. The cells grow with what the tense and mood
/// ladders have taught: four cells first, then each system of the indicative
/// and subjunctive, then those two moods entire, then the imperative and
/// infinitive with their tenses, then everything.
class AmboLadder {
  AmboLadder._();

  static const parentSkill = 'tm.ambo';
  static String skillId(CellStep s) => '$parentSkill.${s.key}';
  static String trialId(CellStep s) => s.key == 'omnia' ? 'tm-ambo' : 'tm-ambo-${s.key}';
  static CellStep byKey(String key) => steps.firstWhere((s) => s.key == key);

  static const steps = [
    CellStep(
      key: 'praes-imperf',
      name: 'Praesēns et imperfectum',
      subtitle: 'indicātīvus · subiūnctīvus',
      cells: [ModusCell(_ind, {_tP, _tI}), ModusCell(_subj, {_tP, _tI})],
      after: [],
      requires: ['tm-tempora-ind-act-praes-imperf', 'tm-tempora-subj-act-praes-imperf', 'tm-modi-ind-subj-praes', 'tm-modi-ind-subj-imperf'],
      price: 20,
      intro: 'Tempus et modus ūnā respōnsiōne, in quattuor cellīs: amat, amābat, amet, amāret. Prīmum modum quaere (vōcālis subiūnctīvī, -re-), deinde tempus (-ba-).',
      examples: ['amat: indicātīvus · praesēns', 'amāret: subiūnctīvus · imperfectum', 'regat ≠ regit ≠ regeret'],
    ),
    CellStep(
      key: 'praesentis',
      name: 'Systēma praesentis',
      subtitle: 'indicātīvus · subiūnctīvus',
      cells: [ModusCell(_ind, {_tP, _tI, _tF}), ModusCell(_subj, {_tP, _tI})],
      after: ['praes-imperf'],
      requires: ['tm-tempora-ind-act-praes-imperf-fut', 'tm-modi-fut-subj-praes'],
      price: 25,
      intro: 'Systēma praesentis utrīusque modī: futūrum accēdit. Cavē reget (futūrum indicātīvī) ≠ regat (praesēns subiūnctīvī); regam ambiguum est, ambae respōnsiōnēs accipiuntur.',
      examples: ['reget: indicātīvus · futūrum', 'regat: subiūnctīvus · praesēns', 'regam: futūrum aut praesēns subiūnctīvī'],
    ),
    CellStep(
      key: 'perfecti',
      name: 'Systēma perfectī',
      subtitle: 'indicātīvus · subiūnctīvus',
      cells: [ModusCell(_ind, {_tPf, _tPq, _tFx}), ModusCell(_subj, {_tPf, _tPq})],
      after: ['praes-imperf'],
      requires: ['tm-tempora-ind-act-perf-plusq-futex', 'tm-tempora-subj-act-perf-plusq', 'tm-modi-ind-subj-plusq', 'tm-modi-ind-subj-perf'],
      price: 25,
      intro: 'Systēma perfectī utrīusque modī: amāvit, amāverat, amāverit; amāverit, amāvisset. Cavē amāverit: futūrum exāctum indicātīvī aut perfectum subiūnctīvī, ambae respōnsiōnēs accipiuntur; amāverō ≠ amāverim.',
      examples: ['amāverat: indicātīvus · plūsquamperfectum', 'amāvisset: subiūnctīvus · plūsquamperfectum', 'amāverit: futūrum exāctum aut perfectum subiūnctīvī'],
    ),
    CellStep(
      key: 'ind-subj',
      name: 'Indicātīvus et subiūnctīvus',
      subtitle: 'omnia tempora',
      cells: [ModusCell(_ind), ModusCell(_subj)],
      after: ['praesentis', 'perfecti'],
      requires: ['tm-tempora-ind-act', 'tm-tempora-subj-act'],
      price: 30,
      intro: 'Tempus et modus ūnā respōnsiōne, omnibus temporibus duōrum modōrum: "subiūnctīvus · imperfectum". Prīmum modum quaere (vōcālis, -re-, -isse-), deinde tempus.',
      examples: ['amāret: subiūnctīvus · imperfectum', 'amāverat: indicātīvus · plūsquamperfectum', 'regam: futūrum aut subiūnctīvus'],
    ),
    CellStep(
      key: 'imp-inf',
      name: 'Imperātīvus et īnfīnītīvus',
      subtitle: 'cum temporibus suīs',
      cells: [ModusCell(_imp, {_tP, _tF}), ModusCell(_inf, {_tP, _tPf, _tF})],
      after: [],
      requires: ['imp-fut', 'tm-tempora-inf', 'tm-modi-inf-imp'],
      price: 20,
      intro: 'Imperātīvus et īnfīnītīvus cum temporibus suīs: amā (praesēns), amātō (futūrum); amāre (praesēns), amāvisse (perfectum), amātūrus esse (futūrum).',
      examples: ['amātō: imperātīvus · futūrum', 'amāvisse: īnfīnītīvus · perfectum', 'amā ≠ amāre'],
    ),
    CellStep(
      key: 'omnia',
      name: 'Tempora et modī omnēs',
      subtitle: 'quattuor modī · omnia tempora',
      cells: [ModusCell(_ind), ModusCell(_subj), ModusCell(_imp), ModusCell(_inf)],
      after: ['ind-subj', 'imp-inf'],
      requires: ['tm-modi-omnia'],
      price: 40,
      intro: 'Tempus et modus ūnā respōnsiōne, in quattuor modīs. Prīmum modum quaere (vōcālis, -re-, -isse-, dēsinentia imperātīvī, -re īnfīnītīvī), deinde tempus.',
      examples: ['amāret: subiūnctīvus · imperfectum', 'amāverat: indicātīvus · plūsquamperfectum', 'amāvisse: īnfīnītīvus · perfectum'],
    ),
  ];
}
