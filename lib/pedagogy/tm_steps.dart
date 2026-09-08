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
