/// Trial (certāmen) catalogue of the Amphitheatrum (verbs) and registry of
/// every trial of the city. The shared model lives in `trial.dart`; the Forum
/// catalogue in `forum/forum_trials.dart`, the Theatrum's in `reading/reading_trials.dart`.
library;

import '../linguistics/model/analysis.dart';
import '../linguistics/model/grammar.dart';
import '../linguistics/model/verb.dart';
import 'forum/forum_trials.dart';
import 'reading/reading_trials.dart';
import 'skills.dart';
import 'tm_steps.dart';
import 'trial.dart';

export 'trial.dart';

/// Kinds of non-finite / special forms for the [Dimension.forma] question.
enum FormKind {
  infinitivus('Īnfīnītīvus'),
  participium('Participium'),
  gerundium('Gerundium'),
  gerundivum('Gerundīvum'),
  supinum('Supīnum'),
  periphrasticaActiva('Periphrastica āctīva'),
  periphrasticaPassiva('Periphrastica passīva'),
  finita('Fōrma persōnālis');

  const FormKind(this.latin);
  final String latin;

  static FormKind of(Analysis a) {
    if (a.periphrasis == Periphrasis.activa) return periphrasticaActiva;
    if (a.periphrasis == Periphrasis.passiva) return periphrasticaPassiva;
    switch (a.mood) {
      case Mood.infinitivus:
        return infinitivus;
      case Mood.participium:
        return participium;
      case Mood.gerundium:
        return gerundium;
      case Mood.gerundivum:
        return gerundivum;
      case Mood.supinum:
        return supinum;
      default:
        return finita;
    }
  }
}

/// Predicate over (verb, form) pairs. Null fields do not filter.
class FormFilter extends ContentFilter {
  const FormFilter({
    this.moods,
    this.tenses,
    this.voices,
    this.periphrases = const {Periphrasis.nulla},
    this.composite,
    this.kinds,
    this.conjugations,
    this.families,
    this.lemmaIds,
    this.excludeLemmaIds = const {},
    this.variantKinds = const {VariantKind.norma},
    this.excludeAnomala = true,
    this.excludeImpersonalia = true,
    this.excludeDefectiva = true,
    this.excludeDeponentia = true,
    this.excludeIntransitivePassive = false,
  });

  final Set<Mood>? moods;
  final Set<Tense>? tenses;
  final Set<Voice>? voices;
  final Set<Periphrasis>? periphrases;
  final bool? composite;
  final Set<VerbKind>? kinds;
  final Set<Conjugation>? conjugations;
  final Set<String>? families;
  final Set<String>? lemmaIds;
  final Set<String> excludeLemmaIds;
  final Set<VariantKind>? variantKinds;
  final bool excludeAnomala;
  final bool excludeImpersonalia;
  final bool excludeDefectiva;
  final bool excludeDeponentia;
  final bool excludeIntransitivePassive;

  bool matchesVerb(VerbEntry v) {
    if (lemmaIds != null && !lemmaIds!.contains(v.id)) return false;
    if (excludeLemmaIds.contains(v.id)) return false;
    if (kinds != null && !kinds!.contains(v.kind)) return false;
    if (conjugations != null && !conjugations!.contains(v.conjugation)) return false;
    if (families != null && (v.family == null || !families!.contains(v.family))) return false;
    if (excludeAnomala && v.isIrregular && kinds == null && families == null && lemmaIds == null) return false;
    if (excludeImpersonalia && v.isImpersonal && kinds == null && lemmaIds == null) return false;
    if (excludeDefectiva && v.isDefective && kinds == null && lemmaIds == null) return false;
    if (excludeDeponentia && (v.isDeponent || v.isSemiDeponent) && kinds == null && lemmaIds == null) return false;
    return true;
  }

  bool matchesForm(VerbEntry v, FormEntry f) {
    final a = f.analysis;
    if (moods != null && !moods!.contains(a.mood)) return false;
    if (tenses != null && (a.tense == null || !tenses!.contains(a.tense))) return false;
    if (voices != null && (a.voice == null || !voices!.contains(a.voice))) return false;
    if (periphrases != null && !periphrases!.contains(a.periphrasis)) return false;
    if (composite != null && a.composite != composite) return false;
    if (variantKinds != null && !variantKinds!.contains(a.variant)) return false;
    if (excludeIntransitivePassive && v.intransitive && a.voice == Voice.passivum && !v.isDeponent) return false;
    return true;
  }

  bool matches(VerbEntry v, FormEntry f) => matchesVerb(v) && matchesForm(v, f);

  FormFilter copyWith({Set<Tense>? tenses, Set<Mood>? moods, Set<Voice>? voices}) => FormFilter(
        moods: moods ?? this.moods,
        tenses: tenses ?? this.tenses,
        voices: voices ?? this.voices,
        periphrases: periphrases,
        composite: composite,
        kinds: kinds,
        conjugations: conjugations,
        families: families,
        lemmaIds: lemmaIds,
        excludeLemmaIds: excludeLemmaIds,
        variantKinds: variantKinds,
        excludeAnomala: excludeAnomala,
        excludeImpersonalia: excludeImpersonalia,
        excludeDefectiva: excludeDefectiva,
        excludeDeponentia: excludeDeponentia,
        excludeIntransitivePassive: excludeIntransitivePassive,
      );
}

// ---------------------------------------------------------------------------

const _regularConj = {Conjugation.prima, Conjugation.secunda, Conjugation.tertia, Conjugation.tertiaIo, Conjugation.quarta};

FormFilter _fin(Mood m, Tense t, Voice v) => FormFilter(
      moods: {m},
      tenses: {t},
      voices: {v},
      conjugations: _regularConj,
      excludeIntransitivePassive: true,
    );

const _finDims = [Dimension.persona, Dimension.numerus, Dimension.coniugatio, Dimension.lemma];
const _finDimsComposite = [Dimension.persona, Dimension.numerus, Dimension.genus, Dimension.coniugatio, Dimension.lemma];

Trial _tense({
  required String id,
  required Mood mood,
  required Tense tense,
  required Voice voice,
  required int price,
  required List<String> prereq,
  required String intro,
  required List<String> examples,
  required String enemy,
}) {
  final composite = voice == Voice.passivum && tense.isPerfectSystem;
  final skill = 'v.${mood.key}.${tense.key}.${voice.key}';
  return Trial(
    id: id,
    name: '${mood.latin} ${tense.latin.toLowerCase()}',
    subtitle: voice.latin,
    skillIds: [skill],
    price: price,
    prerequisites: prereq,
    filter: _fin(mood, tense, voice),
    dimensions: composite ? _finDimsComposite : _finDims,
    intro: intro,
    examples: examples,
    opponentId: enemy,
    group: mood.latin,
  );
}

const _temporaGroup = 'Tempora āctīva';
const _temporaPassGroup = 'Tempora passīva';
const _modiGroup = 'Modī';
const _amboGroup = 'Tempora et modī';

/// Tense-recognition trial: one step of the ladder of a mood and voice, with
/// its own skill leaf. The only question is the tense, the answer grid is
/// exactly the tenses mixed, and the step needs the previous steps of its
/// ladder and the conjugation trial of every tense it mixes.
Trial _tempora(Mood mood, Voice voice, TmStep step) {
  final ladder = TmLadders.of(mood, voice);
  return Trial(
    id: TmLadders.trialId(mood, voice, step),
    name: step.name,
    subtitle: '${mood.latin.toLowerCase()} ${voice.latin.toLowerCase()}',
    skillIds: [TmLadders.skillId(mood, voice, step)],
    price: step.price,
    prerequisites: [
      for (final k in step.after) TmLadders.trialId(mood, voice, ladder.firstWhere((s) => s.key == k)),
      for (final t in step.tenses) '${mood.key}-${t.key}-${voice.key}',
    ],
    filter: FormFilter(moods: {mood}, tenses: step.tenses.toSet(), voices: {voice}, conjugations: _regularConj, excludeIntransitivePassive: true),
    dimensions: const [Dimension.tempus],
    fixedChoices: true,
    components: [for (final t in step.tenses) TrialComponent('${mood.key}.${t.key}.${voice.key}', t.latin, _fin(mood, t, voice), requires: '${mood.key}-${t.key}-${voice.key}')],
    intro: step.intro,
    examples: step.examples,
    opponentId: mood == Mood.indicativus ? 'statua' : 'sphinx',
    group: voice == Voice.activum ? _temporaGroup : _temporaPassGroup,
  );
}

FormFilter _cellFilter(ModusCell c) => FormFilter(moods: {c.mood}, tenses: c.tenses, voices: const {Voice.activum}, conjugations: _regularConj);

/// Mood-recognition trial: one step of ModiLadder, with its own skill leaf.
/// The only question is the mood, the grid is exactly the moods mixed.
Trial _modi(CellStep step) => Trial(
      id: ModiLadder.trialId(step),
      name: step.name,
      subtitle: step.subtitle,
      skillIds: [ModiLadder.skillId(step)],
      price: step.price,
      prerequisites: [for (final k in step.after) ModiLadder.trialId(ModiLadder.byKey(k)), ...step.requires],
      filter: FormFilter(moods: step.moods, tenses: step.tenses, voices: const {Voice.activum}, conjugations: _regularConj),
      dimensions: const [Dimension.modus],
      fixedChoices: true,
      components: [for (final c in step.cells) TrialComponent(c.mood.key, c.mood.latin, _cellFilter(c), requires: c.requires)],
      intro: step.intro,
      examples: step.examples,
      opponentId: 'cyclops',
      group: _modiGroup,
    );

/// Combined trial: one step of AmboLadder, tense and mood in one answer,
/// distractors drawn from the cells the step mixes.
Trial _ambo(CellStep step) => Trial(
      id: AmboLadder.trialId(step),
      name: step.name,
      subtitle: step.subtitle,
      skillIds: [AmboLadder.skillId(step)],
      price: step.price,
      prerequisites: [for (final k in step.after) AmboLadder.trialId(AmboLadder.byKey(k)), ...step.requires],
      filter: FormFilter(moods: step.moods, tenses: step.tenses, voices: const {Voice.activum}, conjugations: _regularConj),
      dimensions: const [Dimension.tempusModus],
      components: [for (final c in step.cells) TrialComponent(c.mood.key, c.mood.latin, _cellFilter(c), requires: c.requires)],
      intro: step.intro,
      examples: step.examples,
      opponentId: 'hydra',
      group: _amboGroup,
    );

/// Registry of every trial of the city (both activities). Ids are unique
/// across activities; prerequisites may only point inside the same activity.
class Trials {
  Trials._();

  static final List<Trial> all = List.unmodifiable([..._build(), ...ForumTrials.build(), ...ReadingTrials.build()]);

  /// Ids are unique across activities: the save file keys purchases,
  /// introductions and the encounter snapshot by id alone, so a collision
  /// between two activities would silently unlock the wrong trial.
  static final Map<String, Trial> _byId = () {
    final m = <String, Trial>{};
    for (final t in all) {
      final clash = m[t.id];
      if (clash != null) throw StateError('duplicate trial id ${t.id}: ${clash.activity.key}/${clash.name} and ${t.activity.key}/${t.name}');
      m[t.id] = t;
    }
    return m;
  }();
  static Trial byId(String id) => _byId[id]!;
  static Trial? maybe(String id) => _byId[id];

  static List<Trial> ofActivity(Activity a) => all.where((t) => t.activity == a).toList();

  /// Trials that credit [skillId]: directly, via a component, or because the
  /// trial's skill is an ancestor of [skillId] (noun trials list the
  /// declension, questions credit its cells).
  static List<Trial> forSkill(String skillId) => all
      .where((t) => t.skillIds.contains(skillId) || t.components.any((c) => c.skillId == skillId) || t.skillIds.any((s) => Skills.leaves(s).contains(skillId)))
      .toList();

  static List<String> groupsOf(Activity a) {
    final seen = <String>[];
    for (final t in all) {
      if (t.activity == a && !seen.contains(t.group)) seen.add(t.group);
    }
    return seen;
  }

  /// Verb trials of the Amphitheatrum.
  static List<Trial> _build() => [
        // ----------------------------------------------------------- Indicātīvus āctīvum
        _tense(
          id: 'ind-praes-act',
          mood: Mood.indicativus,
          tense: Tense.praesens,
          voice: Voice.activum,
          price: 0,
          prereq: const [],
          intro: 'Praesēns dīcit quod nunc fit. Thema praesentis et dēsinentiae persōnālēs: -ō, -s, -t, -mus, -tis, -nt. Vōcālis thematica coniugātiōnem ostendit: amā-, monē-, reg-i-, cap-i-, audī-.',
          examples: ['amō · amās · amat', 'monēmus · regimus · capimus · audīmus', 'amant ≠ regunt ≠ audiunt'],
          enemy: 'statua',
        ),
        _tense(
          id: 'ind-imperf-act',
          mood: Mood.indicativus,
          tense: Tense.imperfectum,
          voice: Voice.activum,
          price: 20,
          prereq: const ['ind-praes-act'],
          intro: 'Imperfectum dīcit quod fīēbat: āctiō dūrāns in praeteritō. Signum: -ba-. Prīma et secunda: -ā-bam, -ē-bam; tertia: -ē-bam; quārta et -iō: -iē-bam.',
          examples: ['amā-ba-m · monē-ba-m', 'reg-ē-ba-m · capi-ē-ba-m · audi-ē-ba-m', 'amābat (imperf.) ≠ amat (praes.)'],
          enemy: 'statua',
        ),
        _tense(
          id: 'ind-fut-act',
          mood: Mood.indicativus,
          tense: Tense.futurum,
          voice: Voice.activum,
          price: 25,
          prereq: const ['ind-imperf-act'],
          intro: 'Futūrum dīcit quod fīet. Prīma et secunda: -bō, -bis, -bit (amābō, monēbō). Tertia et quārta: -am, -ēs, -et (regam, regēs; audiam, audiēs). Cavē: regam est etiam subiūnctīvus.',
          examples: ['amā-b-ō · amā-b-is · amā-b-it', 'reg-a-m · reg-ē-s · reg-e-t', 'amābit (fut.) ≠ amābat (imperf.)'],
          enemy: 'gladiator',
        ),
        _tense(
          id: 'ind-perf-act',
          mood: Mood.indicativus,
          tense: Tense.perfectum,
          voice: Voice.activum,
          price: 30,
          prereq: const ['ind-praes-act'],
          intro: 'Perfectum dīcit quod factum est. Thema perfectī ē tertiā parte prīncipālī sūmitur (amāv-, monu-, rēx-, cēp-, audīv-). Dēsinentiae propriae: -ī, -istī, -it, -imus, -istis, -ērunt.',
          examples: ['amāv-ī · amāv-istī · amāv-it', 'rēx-imus · rēx-istis · rēx-ērunt', 'amāvit (perf.) ≠ amat (praes.)'],
          enemy: 'gladiator',
        ),
        _tense(
          id: 'ind-plusq-act',
          mood: Mood.indicativus,
          tense: Tense.plusquamperfectum,
          voice: Voice.activum,
          price: 30,
          prereq: const ['ind-perf-act'],
          intro: 'Plūsquamperfectum dīcit quod factum erat ante aliud praeteritum. Thema perfectī + -eram, -erās, -erat, -erāmus, -erātis, -erant (ut imperfectum verbī sum).',
          examples: ['amāv-eram · rēx-erat · audīv-erant', 'amāverat (plusq.) ≠ amāvit (perf.)', 'amāverat ≠ amābat'],
          enemy: 'leo',
        ),
        _tense(
          id: 'ind-futex-act',
          mood: Mood.indicativus,
          tense: Tense.futurumExactum,
          voice: Voice.activum,
          price: 35,
          prereq: const ['ind-perf-act', 'ind-fut-act'],
          intro: 'Futūrum exāctum dīcit quod factum erit ante aliud futūrum. Thema perfectī + -erō, -eris, -erit, -erimus, -eritis, -erint. Cavē: tertia plūrālis -erint, nōn -erunt.',
          examples: ['amāv-erō · amāv-erit · amāv-erint', 'amāverit (fut. ex.) ≠ amāverat (plusq.)', 'amāverint ≠ amāvērunt'],
          enemy: 'leo',
        ),
        // ----------------------------------------------------------- Indicātīvus passīvum
        _tense(
          id: 'ind-praes-pass',
          mood: Mood.indicativus,
          tense: Tense.praesens,
          voice: Voice.passivum,
          price: 30,
          prereq: const ['ind-praes-act'],
          intro: 'Passīvum: subiectum āctiōnem patitur. Dēsinentiae passīvae: -or, -ris, -tur, -mur, -minī, -ntur. Secunda persōna etiam -re (amāre) rārō.',
          examples: ['am-or · amā-ris · amā-tur', 'reg-imur · reg-iminī · reg-untur', 'amātur (pass.) ≠ amat (act.)'],
          enemy: 'statua',
        ),
        _tense(
          id: 'ind-imperf-pass',
          mood: Mood.indicativus,
          tense: Tense.imperfectum,
          voice: Voice.passivum,
          price: 30,
          prereq: const ['ind-imperf-act', 'ind-praes-pass'],
          intro: 'Imperfectum passīvum: -ba- + dēsinentiae passīvae: amābar, amābāris, amābātur.',
          examples: ['amā-ba-r · amā-bā-ris · amā-bā-tur', 'regēbantur · audiēbāmur', 'amābātur ≠ amābat'],
          enemy: 'statua',
        ),
        _tense(
          id: 'ind-fut-pass',
          mood: Mood.indicativus,
          tense: Tense.futurum,
          voice: Voice.passivum,
          price: 35,
          prereq: const ['ind-fut-act', 'ind-praes-pass'],
          intro: 'Futūrum passīvum: prīma et secunda -bor, -beris, -bitur; tertia et quārta -ar, -ēris, -ētur.',
          examples: ['amā-b-or · amā-be-ris · amā-bi-tur', 'reg-a-r · reg-ē-ris · reg-ē-tur', 'regētur (fut.) ≠ regitur (praes.)'],
          enemy: 'gladiator',
        ),
        _tense(
          id: 'ind-perf-pass',
          mood: Mood.indicativus,
          tense: Tense.perfectum,
          voice: Voice.passivum,
          price: 40,
          prereq: const ['ind-perf-act', 'ind-praes-pass'],
          intro: 'Perfectum passīvum est fōrma composita: participium perfectī + sum. Participium cum subiectō congruit genere et numerō: amātus est, amāta est, amātī sunt.',
          examples: ['amātus sum · amāta es · amātum est', 'amātī sumus · amātae estis · amāta sunt', 'amātus est (perf.) ≠ amātur (praes.)'],
          enemy: 'leo',
        ),
        _tense(
          id: 'ind-plusq-pass',
          mood: Mood.indicativus,
          tense: Tense.plusquamperfectum,
          voice: Voice.passivum,
          price: 40,
          prereq: const ['ind-perf-pass'],
          intro: 'Plūsquamperfectum passīvum: participium perfectī + eram (amātus eram). Etiam fueram apud sēriōrēs.',
          examples: ['amātus eram · amāta erat · amātī erant', 'amātus erat ≠ amātus est', 'rēctī erant ≠ regēbantur'],
          enemy: 'leo',
        ),
        _tense(
          id: 'ind-futex-pass',
          mood: Mood.indicativus,
          tense: Tense.futurumExactum,
          voice: Voice.passivum,
          price: 40,
          prereq: const ['ind-perf-pass'],
          intro: 'Futūrum exāctum passīvum: participium perfectī + erō (amātus erō, amātus erit, amātī erunt).',
          examples: ['amātus erō · amāta erit · amātī erunt', 'amātus erit ≠ amātus erat', 'amātus erit ≠ amābitur'],
          enemy: 'sphinx',
        ),
        // ----------------------------------------------------------- Subiūnctīvus
        _tense(
          id: 'subj-praes-act',
          mood: Mood.subiunctivus,
          tense: Tense.praesens,
          voice: Voice.activum,
          price: 40,
          prereq: const ['ind-praes-act', 'ind-fut-act'],
          intro: 'Subiūnctīvus praesēns: vōcālis mūtātur. Prīma: -e- (amem, amēs); cēterae: -a- (moneam, regam, capiam, audiam). Cavē: regam est etiam futūrum indicātīvī.',
          examples: ['am-e-m · am-ē-s · am-e-t', 'mone-a-m · reg-a-m · audi-a-m', 'amet (subj.) ≠ amat (ind.)'],
          enemy: 'gladiator',
        ),
        _tense(
          id: 'subj-imperf-act',
          mood: Mood.subiunctivus,
          tense: Tense.imperfectum,
          voice: Voice.activum,
          price: 40,
          prereq: const ['subj-praes-act'],
          intro: 'Subiūnctīvus imperfectī: īnfīnītīvus praesentis + -m, -s, -t, -mus, -tis, -nt: amāre-m, regere-t, esse-nt.',
          examples: ['amāre-m · amārē-s · amāre-t', 'regere-t · caperē-mus · audīre-nt', 'amāret (subj. imperf.) ≠ amābat (ind. imperf.)'],
          enemy: 'gladiator',
        ),
        _tense(
          id: 'subj-perf-act',
          mood: Mood.subiunctivus,
          tense: Tense.perfectum,
          voice: Voice.activum,
          price: 45,
          prereq: const ['subj-praes-act', 'ind-perf-act'],
          intro: 'Subiūnctīvus perfectī: thema perfectī + -erim, -erīs, -erit, -erīmus, -erītis, -erint. Simillimus futūrō exāctō (amāverō, amāveris).',
          examples: ['amāv-erim · amāv-erīs · amāv-erit', 'rēxerint · audīverīmus', 'amāverim (subj.) ≠ amāverō (fut. ex.)'],
          enemy: 'leo',
        ),
        _tense(
          id: 'subj-plusq-act',
          mood: Mood.subiunctivus,
          tense: Tense.plusquamperfectum,
          voice: Voice.activum,
          price: 45,
          prereq: const ['subj-perf-act'],
          intro: 'Subiūnctīvus plūsquamperfectī: thema perfectī + -issem, -issēs, -isset (= īnfīnītīvus perfectī + -m).',
          examples: ['amāv-issem · amāv-issēs · amāv-isset', 'rēxissent · audīvissēmus', 'amāvisset (subj.) ≠ amāverat (ind.)'],
          enemy: 'leo',
        ),
        _tense(
          id: 'subj-praes-pass',
          mood: Mood.subiunctivus,
          tense: Tense.praesens,
          voice: Voice.passivum,
          price: 45,
          prereq: const ['subj-praes-act', 'ind-praes-pass'],
          intro: 'Subiūnctīvus praesēns passīvus: vōcālis subiūnctīvī + dēsinentiae passīvae: amer, amēris, amētur; regar, regāris, regātur.',
          examples: ['am-e-r · am-ē-ris · am-ē-tur', 'reg-a-r · reg-ā-tur · audi-a-ntur', 'amētur (subj.) ≠ amātur (ind.)'],
          enemy: 'sphinx',
        ),
        _tense(
          id: 'subj-imperf-pass',
          mood: Mood.subiunctivus,
          tense: Tense.imperfectum,
          voice: Voice.passivum,
          price: 45,
          prereq: const ['subj-imperf-act', 'subj-praes-pass'],
          intro: 'Subiūnctīvus imperfectī passīvus: īnfīnītīvus + -r, -ris, -tur: amārer, amārēris, amārētur.',
          examples: ['amāre-r · amārē-ris · amārē-tur', 'regerētur · audīrentur', 'amārētur ≠ amābātur'],
          enemy: 'sphinx',
        ),
        _tense(
          id: 'subj-perf-pass',
          mood: Mood.subiunctivus,
          tense: Tense.perfectum,
          voice: Voice.passivum,
          price: 50,
          prereq: const ['subj-perf-act', 'ind-perf-pass'],
          intro: 'Subiūnctīvus perfectī passīvus: participium perfectī + sim (amātus sim, amāta sit, amātī sint).',
          examples: ['amātus sim · amāta sīs · amātum sit', 'amātus sit ≠ amātus est', 'amātī sint ≠ amātī sunt'],
          enemy: 'sphinx',
        ),
        _tense(
          id: 'subj-plusq-pass',
          mood: Mood.subiunctivus,
          tense: Tense.plusquamperfectum,
          voice: Voice.passivum,
          price: 50,
          prereq: const ['subj-perf-pass'],
          intro: 'Subiūnctīvus plūsquamperfectī passīvus: participium perfectī + essem (amātus essem; etiam forem).',
          examples: ['amātus essem · amāta esset · amātī essent', 'amātus esset ≠ amātus erat', 'amātus esset ≠ amātus sit'],
          enemy: 'cyclops',
        ),
        // ----------------------------------------------------------- Imperātīvus
        Trial(
          id: 'imp-praes',
          name: 'Imperātīvus praesēns',
          subtitle: 'āctīvum et passīvum',
          skillIds: const ['v.imp.praes'],
          price: 25,
          prerequisites: const ['ind-praes-act'],
          filter: const FormFilter(moods: {Mood.imperativus}, tenses: {Tense.praesens}, conjugations: _regularConj, excludeIntransitivePassive: true),
          dimensions: const [Dimension.numerus, Dimension.vox, Dimension.coniugatio, Dimension.lemma],
          intro: 'Imperātīvus iubet. Praesēns āctīvum: amā, amāte; rege, regite; audī, audīte. Passīvum: amāre, amāminī. Cavē: amāre est etiam īnfīnītīvus. Irregulāria: dīc, dūc, fac, fer.',
          examples: ['amā · amāte', 'rege · regite · dīc · fac', 'amāre (imp. pass.) = amāre (īnf.)'],
          opponentId: 'statua',
          group: 'Imperātīvus',
        ),
        Trial(
          id: 'imp-fut',
          name: 'Imperātīvus futūrus',
          subtitle: 'āctīvum et passīvum',
          skillIds: const ['v.imp.fut'],
          price: 35,
          prerequisites: const ['imp-praes'],
          filter: const FormFilter(moods: {Mood.imperativus}, tenses: {Tense.futurum}, conjugations: _regularConj, excludeIntransitivePassive: true),
          dimensions: const [Dimension.persona, Dimension.numerus, Dimension.vox, Dimension.lemma],
          intro: 'Imperātīvus futūrus in lēgibus et praeceptīs: amātō (tū vel ille), amātōte (vōs), amantō (illī). Passīvum: amātor, amantor.',
          examples: ['amātō · amātōte · amantō', 'regitō · reguntō', 'amātor (pass.) ≠ amātō (act.)'],
          opponentId: 'gladiator',
          group: 'Imperātīvus',
        ),
        // ----------------------------------------------------------- Fōrmae nōminālēs
        Trial(
          id: 'infinitivi',
          name: 'Īnfīnītīvī',
          subtitle: 'praesēns, perfectum, futūrum',
          skillIds: const ['v.inf'],
          price: 35,
          prerequisites: const ['ind-praes-act', 'ind-perf-act'],
          filter: const FormFilter(moods: {Mood.infinitivus}, conjugations: _regularConj, excludeIntransitivePassive: true),
          dimensions: const [Dimension.tempus, Dimension.vox, Dimension.coniugatio, Dimension.lemma],
          intro: 'Īnfīnītīvus nōmen āctiōnis est: tempus et vōcem habet, persōnam nōn habet. Praesēns amāre / amārī; perfectum amāvisse / amātus esse; futūrum amātūrus esse / amātum īrī.',
          examples: ['amāre · amārī', 'amāvisse · amātus esse', 'amātūrus esse · amātum īrī'],
          opponentId: 'sphinx',
          group: 'Fōrmae nōminālēs',
        ),
        Trial(
          id: 'participia',
          name: 'Participia',
          subtitle: 'praesēns, perfectum, futūrum',
          skillIds: const ['v.part'],
          price: 45,
          prerequisites: const ['ind-praes-pass', 'ind-perf-act'],
          filter: const FormFilter(moods: {Mood.participium}, conjugations: _regularConj),
          dimensions: const [Dimension.tempus, Dimension.vox, Dimension.casus, Dimension.genus, Dimension.numerus],
          intro: 'Participium adiectīvum verbāle est: dēclīnātur ut adiectīvum. Praesēns āctīvum amāns, amantis; perfectum passīvum amātus, -a, -um; futūrum āctīvum amātūrus, -a, -um.',
          examples: ['amāns · amantis · amantēs', 'amātus · amāta · amātum', 'amātūrus · amātūra · amātūrum'],
          opponentId: 'sphinx',
          group: 'Fōrmae nōminālēs',
        ),
        Trial(
          id: 'gerundium',
          name: 'Gerundium et gerundīvum',
          subtitle: 'amandī · amandus',
          skillIds: const ['v.ger'],
          price: 40,
          prerequisites: const ['participia'],
          filter: const FormFilter(moods: {Mood.gerundium, Mood.gerundivum}, conjugations: _regularConj),
          dimensions: const [Dimension.forma, Dimension.casus, Dimension.genus, Dimension.numerus],
          intro: 'Gerundium nōmen verbāle neutrum est (amandī, amandō, amandum, amandō): cāsūs īnfīnītīvī supplet. Gerundīvum adiectīvum passīvum est (amandus, -a, -um): "quī amārī dēbet".',
          examples: ['ars amandī (gerundium)', 'puella amanda (gerundīvum)', 'amandum (ger. acc.) = amandum (gdv. n.)'],
          opponentId: 'cyclops',
          group: 'Fōrmae nōminālēs',
        ),
        Trial(
          id: 'supinum',
          name: 'Supīnum',
          subtitle: 'amātum · amātū',
          skillIds: const ['v.sup'],
          price: 30,
          prerequisites: const ['gerundium'],
          filter: const FormFilter(moods: {Mood.supinum, Mood.gerundium, Mood.participium}, conjugations: _regularConj),
          dimensions: const [Dimension.forma, Dimension.casus],
          intro: 'Supīnum duōs cāsūs habet: accūsātīvum in -um post verba mōtūs (venit amātum) et ablātīvum in -ū post adiectīva (mīrābile dictū). Discerne supīnum ā participiō et gerundiō.',
          examples: ['amātum (supīnum) = amātum (participium n.)', 'dictū · audītū · vīsū', 'ad amandum (gerundium) ≠ amātum (supīnum)'],
          opponentId: 'cyclops',
          group: 'Fōrmae nōminālēs',
        ),
        Trial(
          id: 'periph-act',
          name: 'Periphrastica āctīva',
          subtitle: 'amātūrus sum',
          skillIds: const ['v.periph.act'],
          price: 50,
          prerequisites: const ['participia'],
          filter: const FormFilter(moods: {Mood.indicativus, Mood.subiunctivus}, periphrases: {Periphrasis.activa}, conjugations: _regularConj),
          dimensions: const [Dimension.tempus, Dimension.modus, Dimension.persona, Dimension.numerus],
          intro: 'Coniugātiō periphrastica āctīva: participium futūrī + sum. Significat "amātūrus sum" = amāre in animō habeō, mox amābō.',
          examples: ['amātūrus sum · amātūrus eram · amātūrus erō', 'amātūrī sint · amātūra esset', 'amātūrus erat ≠ amātus erat'],
          opponentId: 'hydra',
          group: 'Coniugātiō periphrastica',
        ),
        Trial(
          id: 'periph-pass',
          name: 'Periphrastica passīva',
          subtitle: 'amandus sum',
          skillIds: const ['v.periph.pass'],
          price: 50,
          prerequisites: const ['gerundium'],
          filter: const FormFilter(moods: {Mood.indicativus, Mood.subiunctivus}, periphrases: {Periphrasis.passiva}, conjugations: _regularConj),
          dimensions: const [Dimension.tempus, Dimension.modus, Dimension.persona, Dimension.numerus],
          intro: 'Coniugātiō periphrastica passīva: gerundīvum + sum. Significat necessitātem: "amandus sum" = amārī dēbeō. Agēns datīvō pōnitur: mihi amandus es.',
          examples: ['amandus sum · amandus eram · amandus erit', 'Carthāgō dēlenda est', 'amandus erat ≠ amātus erat'],
          opponentId: 'hydra',
          group: 'Coniugātiō periphrastica',
        ),
        // ----------------------------------------------------------- Verba anōmala
        Trial(
          id: 'fam-sum',
          name: 'sum et composita',
          subtitle: 'sum · possum · absum · prōsum',
          skillIds: const ['v.fam.sum'],
          price: 20,
          prerequisites: const ['ind-praes-act'],
          filter: const FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, families: {'sum', 'possum'}, composite: false, excludeAnomala: false),
          dimensions: const [Dimension.tempus, Dimension.modus, Dimension.persona, Dimension.numerus, Dimension.lemma],
          intro: 'Verbum sum thema mūtat: es-/s- in praesentī (sum, es, est, sumus), era- in imperfectō, er- in futūrō, fu- in perfectō. Possum = pot- + sum: possum, potes, potest; poteram; potuī. Prōsum: prōd- ante vōcālem.',
          examples: ['sum · es · est · sumus · estis · sunt', 'eram · erō · fuī · sim · essem', 'possum · potes · prōdest · abest'],
          opponentId: 'statua',
          group: 'Verba anōmala',
        ),
        Trial(
          id: 'fam-eo',
          name: 'eō et composita',
          subtitle: 'eō · redeō · exeō · trānseō',
          skillIds: const ['v.fam.eo'],
          price: 35,
          prerequisites: const ['fam-sum', 'ind-imperf-act'],
          filter: const FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus, Mood.participium}, families: {'eo'}, composite: false, excludeAnomala: false),
          dimensions: const [Dimension.tempus, Dimension.modus, Dimension.persona, Dimension.numerus, Dimension.lemma],
          intro: 'Eō: thema ī-/e-: eō, īs, it, īmus, ītis, eunt. Imperfectum ībam, futūrum ībō (ut prīma coniugātiō!), perfectum iī (īstī, iit), participium iēns, euntis, gerundium eundī.',
          examples: ['eō · īs · it · eunt', 'ībam · ībō · iī · īstī', 'iēns · euntis · eundum · itum est'],
          opponentId: 'gladiator',
          group: 'Verba anōmala',
        ),
        Trial(
          id: 'fam-fero',
          name: 'ferō et composita',
          subtitle: 'ferō · auferō · referō · offerō',
          skillIds: const ['v.fam.fero'],
          price: 40,
          prerequisites: const ['fam-sum', 'ind-praes-pass'],
          filter: const FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus, Mood.participium}, families: {'fero'}, composite: false, excludeAnomala: false),
          dimensions: const [Dimension.tempus, Dimension.modus, Dimension.vox, Dimension.persona, Dimension.numerus, Dimension.lemma],
          intro: 'Ferō vōcālem āmittit: fers, fert, fertis; ferris, fertur; fer, ferte; ferre, ferrī, ferrem. Tria themata: fer-, tul-, lāt-. Composita: auferō, abstulī, ablātum; referō, rettulī, relātum.',
          examples: ['ferō · fers · fert · ferimus · fertis · ferunt', 'ferre · ferrī · ferrem · fer', 'tulī · lātus · abstulī · ablātus'],
          opponentId: 'leo',
          group: 'Verba anōmala',
        ),
        Trial(
          id: 'fam-volo',
          name: 'volō, nōlō, mālō',
          subtitle: 'vīs · nōn vult · māvult',
          skillIds: const ['v.fam.volo'],
          price: 45,
          prerequisites: const ['fam-sum', 'subj-praes-act'],
          filter: const FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus, Mood.participium}, families: {'volo', 'nolo', 'malo'}, composite: false, excludeAnomala: false),
          dimensions: const [Dimension.tempus, Dimension.modus, Dimension.persona, Dimension.numerus, Dimension.lemma],
          intro: 'Volō, vīs, vult, volumus, vultis, volunt. Subiūnctīvus velim, imperfectum vellem, īnfīnītīvus velle. Nōlō = nōn volō (nōn vīs, nōn vult) cum imperātīvō nōlī, nōlīte. Mālō = magis volō (māvīs, māvult).',
          examples: ['volō · vīs · vult · volunt', 'velim · vellem · velle', 'nōlī · nōlīte · māvult · mālim'],
          opponentId: 'sphinx',
          group: 'Verba anōmala',
        ),
        Trial(
          id: 'fam-fio',
          name: 'fīō et faciō',
          subtitle: 'fit · fīēbat · factus est',
          skillIds: const ['v.fam.fio'],
          price: 45,
          prerequisites: const ['fam-fero', 'ind-praes-pass'],
          filter: const FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, lemmaIds: {'fio', 'facio'}, excludeAnomala: false),
          dimensions: const [Dimension.tempus, Dimension.modus, Dimension.vox, Dimension.persona, Dimension.numerus, Dimension.lemma],
          intro: 'Fīō, fīs, fit, fīmus, fītis, fīunt: fōrma āctīva, sēnsus passīvus: passīvum praesentis verbī faciō. Imperfectum fīēbam, futūrum fīam, subiūnctīvus fīam / fierem, īnfīnītīvus fierī. Perfectum factus sum.',
          examples: ['fit = facitur', 'fīēbat · fīet · fīat · fieret', 'factus est · fierī · fac'],
          opponentId: 'cyclops',
          group: 'Verba anōmala',
        ),
        Trial(
          id: 'fam-minora',
          name: 'dō et edō',
          subtitle: 'dās · damus · ēst · ēsse',
          skillIds: const ['v.fam.minora'],
          price: 40,
          prerequisites: const ['fam-sum', 'ind-praes-pass'],
          filter: const FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, lemmaIds: {'do', 'circumdo', 'edo'}, excludeAnomala: false, variantKinds: {VariantKind.norma, VariantKind.altera}),
          dimensions: const [Dimension.tempus, Dimension.modus, Dimension.persona, Dimension.numerus, Dimension.lemma],
          intro: 'Dō habet a brevem: damus, datis, dabam, darem (sed dās, dā, dāns). Edō fōrmās habet similēs verbō sum: ēs, ēst, ēstis, ēsse, ēssem — cum ē longā, quae discernit ēst (edit) ab est (sum).',
          examples: ['dō · dās · dat · damus · datis · dant', 'edō · ēs · ēst · edimus · ēstis · edunt', 'ēst (edō) ≠ est (sum)'],
          opponentId: 'gladiator',
          group: 'Verba anōmala',
        ),
        // ----------------------------------------------------------- Verba speciālia
        Trial(
          id: 'deponentia',
          name: 'Dēpōnentia',
          subtitle: 'sequor · hortor · patior',
          skillIds: const ['v.dep'],
          price: 50,
          prerequisites: const ['ind-praes-pass', 'ind-perf-pass'],
          filter: const FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus, Mood.participium}, kinds: {VerbKind.deponens}, excludeLemmaIds: {'for'}),
          dimensions: const [Dimension.tempus, Dimension.modus, Dimension.persona, Dimension.numerus, Dimension.coniugatio, Dimension.lemma],
          intro: 'Dēpōnentia fōrmam passīvam, sēnsum āctīvum habent: sequor = "sequor aliquem". Participium praesentis (sequēns) et futūrī (secūtūrus) āctīva sunt; gerundīvum (sequendus) passīvum manet.',
          examples: ['sequor · sequeris · sequitur (praes.)', 'secūtus sum · secūtus eram (perf.)', 'sequere! (imp.) · sequī (īnf.)'],
          opponentId: 'hydra',
          group: 'Verba speciālia',
        ),
        Trial(
          id: 'semideponentia',
          name: 'Sēmidēpōnentia',
          subtitle: 'audeō · ausus sum',
          skillIds: const ['v.semidep'],
          price: 40,
          prerequisites: const ['deponentia'],
          filter: const FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.infinitivus, Mood.participium}, kinds: {VerbKind.semideponens, VerbKind.semideponensInversum}),
          dimensions: const [Dimension.tempus, Dimension.modus, Dimension.persona, Dimension.numerus, Dimension.lemma],
          intro: 'Sēmidēpōnentia āctīva sunt in praesentī (audeō, gaudeō, soleō, fīdō), dēpōnentia in perfectō (ausus sum, gāvīsus sum, solitus sum). Revertor contrā: praesēns dēpōnēns, perfectum āctīvum revertī.',
          examples: ['audeō · audēbam · audēbō', 'ausus sum · ausus eram · ausus esse', 'revertor · revertī (perf. act.)'],
          opponentId: 'hydra',
          group: 'Verba speciālia',
        ),
        Trial(
          id: 'defectiva',
          name: 'Dēfectīva',
          subtitle: 'ōdī · meminī · coepī · inquam',
          skillIds: const ['v.def'],
          price: 45,
          prerequisites: const ['ind-perf-act', 'imp-fut'],
          filter: const FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, kinds: {VerbKind.defectivum}),
          dimensions: const [Dimension.tempusSensus, Dimension.tempus, Dimension.persona, Dimension.numerus, Dimension.lemma],
          intro: 'Dēfectīva fōrmās quāsdam nōn habent. Ōdī et meminī perfectum sōlum habent, sed sēnsū praesentī: ōdī = "ōdiō habeō", ōderam = "ōdiō habēbam". Coepī perfectum tantum (praesēns: incipiō). Inquam, āiō, quaesō paucās fōrmās habent.',
          examples: ['ōdī (perf. fōrmā, praes. sēnsū)', 'meminī · mementō · meminisse', 'coepit · inquit · ait · quaesō'],
          opponentId: 'sphinx',
          group: 'Verba speciālia',
        ),
        Trial(
          id: 'impersonalia',
          name: 'Impersōnālia',
          subtitle: 'licet · oportet · pluit',
          skillIds: const ['v.impers'],
          price: 35,
          prerequisites: const ['ind-praes-act', 'ind-perf-act'],
          filter: const FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.infinitivus}, kinds: {VerbKind.impersonale}, variantKinds: {VariantKind.norma, VariantKind.altera}),
          dimensions: const [Dimension.tempus, Dimension.modus, Dimension.lemma],
          intro: 'Impersōnālia tertiam persōnam singulārem sōlam habent: licet, licēbat, licuit; pluit, pluēbat. Nūllus imperātīvus, nūllum participium ūsitātum.',
          examples: ['licet · licēbat · licuit · liceat', 'oportet · oportuit · oportēre', 'pluit · ningit · tonat'],
          opponentId: 'statua',
          group: 'Verba speciālia',
        ),
        Trial(
          id: 'variantes',
          name: 'Variantēs fōrmārum',
          subtitle: 'amāstī · amāvēre · amābāre · dīcundus',
          skillIds: const ['v.variantes'],
          price: 60,
          prerequisites: const ['ind-perf-act', 'ind-imperf-pass'],
          filter: const FormFilter(
            moods: {Mood.indicativus, Mood.subiunctivus, Mood.infinitivus, Mood.gerundivum},
            conjugations: _regularConj,
            periphrases: {Periphrasis.nulla},
            variantKinds: {VariantKind.syncopa, VariantKind.perfectumEre, VariantKind.passivumRe, VariantKind.undus, VariantKind.fuiAuxiliare},
            excludeIntransitivePassive: true,
          ),
          dimensions: const [Dimension.formaPlena, Dimension.tempus, Dimension.persona, Dimension.numerus],
          intro: 'Fōrmae variae attestātae: perfectum contractum (amāstī = amāvistī, audiit = audīvit, nōsse = nōvisse); tertia plūrālis -ēre (amāvēre = amāvērunt); secunda passīva -re (amābāre = amābāris); gerundīvum -undus (dīcundus); perfectum passīvum cum fuī (amātus fuit).',
          examples: ['amāstī = amāvistī · amāsse = amāvisse', 'amāvēre = amāvērunt', 'amābāre = amābāris · dīcundus = dīcendus'],
          opponentId: 'cyclops',
          group: 'Verba speciālia',
        ),
        // ----------------------------------------------------------- Tempora
        // Recognising the tense of a form, and nothing else: one question, a
        // fixed answer grid of exactly the tenses mixed. Each mood and voice
        // climbs the ladder of TmLadders, built on the confusions a learner
        // makes (praesēns an futūrum, -era- an -eri-…), pairs first, then the
        // two systems, then every tense. One section per voice.
        for (final voice in [Voice.activum, Voice.passivum]) ...[
          for (final mood in [Mood.indicativus, Mood.subiunctivus])
            for (final step in TmLadders.of(mood, voice)) _tempora(mood, voice, step),
          if (voice == Voice.activum)
            Trial(
              id: 'tm-tempora-inf',
              name: 'Tempora īnfīnītīvī',
              subtitle: 'praesēns · perfectum · futūrum',
              skillIds: const ['tm.tempus.inf'],
              price: 15,
              prerequisites: const ['infinitivi'],
              filter: const FormFilter(moods: {Mood.infinitivus}, voices: {Voice.activum}, conjugations: _regularConj),
              dimensions: const [Dimension.tempus],
              fixedChoices: true,
              components: [
                for (final t in [Tense.praesens, Tense.perfectum, Tense.futurum])
                  TrialComponent('inf.${t.key}', t.latin, FormFilter(moods: const {Mood.infinitivus}, tenses: {t}, voices: const {Voice.activum}, conjugations: _regularConj)),
              ],
              intro: 'Quod tempus īnfīnītīvī? Praesēns -re (amāre), perfectum -isse (amāvisse), futūrum participium futūrī + esse (amātūrus esse).',
              examples: ['amāre · amāvisse · amātūrus esse', 'regere · rēxisse · rēctūrus esse', 'amāvisse ≠ amāre'],
              opponentId: 'sphinx',
              group: _temporaGroup,
            ),
        ],
        // ----------------------------------------------------------- Modī
        // Recognising the mood only, on the ladder of ModiLadder: one
        // confusion at a time (amat an amet, reget an regat, amā an amāre…),
        // then the four moods in the present, then at every tense.
        for (final step in ModiLadder.steps) _modi(step),
        // ----------------------------------------------------------- Tempora et modī
        // Tense and mood in one answer, on the ladder of AmboLadder: four
        // cells first, then each system, then the two moods entire, then the
        // imperative and infinitive, then everything.
        for (final step in AmboLadder.steps) _ambo(step),
        // ----------------------------------------------------------- Mixta
        Trial(
          id: 'mx-tempora-ind-act',
          name: 'Mixta: tempora indicātīvī',
          subtitle: 'āctīvum',
          skillIds: const ['mx.tempus.ind'],
          price: 60,
          prerequisites: const ['ind-futex-act', 'tm-tempora-ind-act'],
          filter: FormFilter(moods: const {Mood.indicativus}, voices: const {Voice.activum}, conjugations: _regularConj),
          dimensions: const [Dimension.tempus, Dimension.persona, Dimension.numerus, Dimension.analysis],
          components: [for (final t in Tense.values) TrialComponent('ind.${t.key}.act', t.latin, _fin(Mood.indicativus, t, Voice.activum), skillId: 'v.ind.${t.key}.act')],
          intro: 'Nunc tempus nōn datur: id agnōscere dēbēs. Quaere signa: -ba- imperfectum, -b- futūrum (I–II), thema perfectī, -era- plūsquamperfectum, -eri- futūrum exāctum.',
          examples: ['amat · amābat · amābit', 'amāvit · amāverat · amāverit', 'regit ≠ reget ≠ rēxit'],
          opponentId: 'leo',
          group: 'Mixta',
        ),
        Trial(
          id: 'mx-tempora-ind-pass',
          name: 'Mixta: tempora indicātīvī',
          subtitle: 'passīvum',
          skillIds: const ['mx.tempus.ind'],
          price: 60,
          prerequisites: const ['ind-futex-pass', 'tm-tempora-ind-pass'],
          filter: FormFilter(moods: const {Mood.indicativus}, voices: const {Voice.passivum}, conjugations: _regularConj, excludeIntransitivePassive: true),
          dimensions: const [Dimension.tempus, Dimension.persona, Dimension.numerus, Dimension.genus, Dimension.analysis],
          components: [for (final t in Tense.values) TrialComponent('ind.${t.key}.pass', t.latin, _fin(Mood.indicativus, t, Voice.passivum), skillId: 'v.ind.${t.key}.pass')],
          intro: 'Tempora passīva mixta: fōrmae simplicēs (amātur, amābātur, amābitur) et compositae (amātus est, erat, erit). Tempus fōrmae compositae ex auxiliārī sūmitur.',
          examples: ['amātur · amābātur · amābitur', 'amātus est · amātus erat · amātus erit', 'amātus est (perf.) ≠ amātur (praes.)'],
          opponentId: 'leo',
          group: 'Mixta',
        ),
        Trial(
          id: 'mx-tempora-subj',
          name: 'Mixta: tempora subiūnctīvī',
          subtitle: 'āctīvum et passīvum',
          skillIds: const ['mx.tempus.subj'],
          price: 70,
          prerequisites: const ['subj-plusq-act', 'subj-plusq-pass', 'tm-tempora-subj-act', 'tm-tempora-subj-pass'],
          filter: FormFilter(moods: const {Mood.subiunctivus}, conjugations: _regularConj, excludeIntransitivePassive: true),
          dimensions: const [Dimension.tempus, Dimension.vox, Dimension.persona, Dimension.numerus, Dimension.analysis],
          components: [
            for (final t in [Tense.praesens, Tense.imperfectum, Tense.perfectum, Tense.plusquamperfectum])
              for (final v in Voice.values)
                TrialComponent('subj.${t.key}.${v.key}', '${t.latin} ${v.latin.toLowerCase()}', _fin(Mood.subiunctivus, t, v), skillId: 'v.subj.${t.key}.${v.key}'),
          ],
          intro: 'Quattuor tempora subiūnctīvī mixta: praesēns (amem), imperfectum (amārem), perfectum (amāverim), plūsquamperfectum (amāvissem), āctīva et passīva.',
          examples: ['amem · amārem · amāverim · amāvissem', 'amer · amārer · amātus sim · amātus essem', 'amāverim (subj.) ≠ amāverō (ind.)'],
          opponentId: 'sphinx',
          group: 'Mixta',
        ),
        Trial(
          id: 'mx-modi',
          name: 'Mixta: modī',
          subtitle: 'indicātīvus · subiūnctīvus · imperātīvus · īnfīnītīvus',
          skillIds: const ['mx.modus'],
          price: 90,
          prerequisites: const ['mx-tempora-ind-act', 'mx-tempora-subj', 'imp-fut', 'infinitivi', 'tm-modi-omnia', 'tm-ambo'],
          filter: FormFilter(moods: const {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, conjugations: _regularConj, excludeIntransitivePassive: true),
          dimensions: const [Dimension.modus, Dimension.tempus, Dimension.vox, Dimension.analysis],
          components: [
            TrialComponent('ind', 'Indicātīvus', FormFilter(moods: const {Mood.indicativus}, conjugations: _regularConj, excludeIntransitivePassive: true)),
            TrialComponent('subj', 'Subiūnctīvus', FormFilter(moods: const {Mood.subiunctivus}, conjugations: _regularConj, excludeIntransitivePassive: true)),
            TrialComponent('imp', 'Imperātīvus', FormFilter(moods: const {Mood.imperativus}, conjugations: _regularConj, excludeIntransitivePassive: true)),
            TrialComponent('inf', 'Īnfīnītīvus', FormFilter(moods: const {Mood.infinitivus}, conjugations: _regularConj, excludeIntransitivePassive: true)),
          ],
          intro: 'Modī mixtī: agnōsce indicātīvum, subiūnctīvum, imperātīvum, īnfīnītīvum. Cavē fōrmās ambiguās: regam (fut. ind. / praes. subj.), amāre (īnf. / imp. pass.).',
          examples: ['amat · amet · amā · amāre', 'regit · regat · rege · regere', 'regam: futūrum aut subiūnctīvus'],
          opponentId: 'cyclops',
          group: 'Mixta',
        ),
        Trial(
          id: 'mx-voces',
          name: 'Mixta: vōcēs',
          subtitle: 'āctīvum · passīvum · dēpōnēns',
          skillIds: const ['mx.vox'],
          price: 80,
          prerequisites: const ['mx-tempora-ind-pass', 'deponentia'],
          filter: const FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, conjugations: _regularConj, excludeDeponentia: false, excludeIntransitivePassive: true),
          dimensions: const [Dimension.vox, Dimension.tempus, Dimension.persona, Dimension.numerus],
          components: const [
            TrialComponent('act', 'Āctīvum', FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, voices: {Voice.activum}, conjugations: _regularConj)),
            TrialComponent('pass', 'Passīvum', FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, voices: {Voice.passivum}, conjugations: _regularConj, excludeIntransitivePassive: true)),
            TrialComponent('dep', 'Dēpōnentia', FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, kinds: {VerbKind.deponens}, excludeLemmaIds: {'for'}), skillId: 'v.dep'),
          ],
          intro: 'Vōcēs mixtae: fōrma āctīva, fōrma passīva, dēpōnēns (fōrma passīva, sēnsus āctīvus). Dēsinentiae -r, -ris, -tur, -mur, -minī, -ntur passīvum fōrmāle ostendunt.',
          examples: ['amat (act.) · amātur (pass.) · sequitur (dep.)', 'amāvit · amātus est · secūtus est', 'sequeris: fōrma passīva, sēnsus āctīvus'],
          opponentId: 'hydra',
          group: 'Mixta',
        ),
        Trial(
          id: 'mx-familiae',
          name: 'Mixta: verba anōmala',
          subtitle: 'sum · eō · ferō · volō · fīō · dō · edō',
          skillIds: const ['mx.familia'],
          price: 90,
          prerequisites: const ['fam-eo', 'fam-fero', 'fam-volo', 'fam-fio', 'fam-minora'],
          filter: const FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, kinds: {VerbKind.anomalum, VerbKind.regulare}, families: {'sum', 'possum', 'eo', 'fero', 'volo', 'nolo', 'malo', 'fio', 'edo'}, composite: false, excludeAnomala: false),
          dimensions: const [Dimension.lemma, Dimension.tempus, Dimension.modus, Dimension.persona, Dimension.numerus],
          components: const [
            TrialComponent('sum', 'sum et composita', FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, families: {'sum', 'possum'}, composite: false, excludeAnomala: false), skillId: 'v.fam.sum'),
            TrialComponent('eo', 'eō et composita', FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, families: {'eo'}, composite: false, excludeAnomala: false), skillId: 'v.fam.eo'),
            TrialComponent('fero', 'ferō et composita', FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, families: {'fero'}, composite: false, excludeAnomala: false), skillId: 'v.fam.fero'),
            TrialComponent('volo', 'volō, nōlō, mālō', FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, families: {'volo', 'nolo', 'malo'}, composite: false, excludeAnomala: false), skillId: 'v.fam.volo'),
            TrialComponent('fio', 'fīō et faciō', FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, lemmaIds: {'fio', 'facio'}, composite: false, excludeAnomala: false), skillId: 'v.fam.fio'),
            TrialComponent('minora', 'dō et edō', FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, lemmaIds: {'do', 'edo'}, composite: false, excludeAnomala: false), skillId: 'v.fam.minora'),
          ],
          intro: 'Verba anōmala mixta: cui verbō fōrma pertinet? Cavē paria: est (sum) / ēst (edō); it (eō) / fit (fīō); vīs (volō) / īs (eō); ferrem / vellem / essem.',
          examples: ['est · ēst · it · fit', 'vīs · īs · fers · dās', 'ferrem · vellem · essem · īrem'],
          opponentId: 'cyclops',
          group: 'Mixta',
        ),
        Trial(
          id: 'mx-omnia',
          name: 'Omnia mixta',
          subtitle: 'summum certāmen',
          skillIds: const ['mx.omnia'],
          price: 150,
          prerequisites: const ['mx-modi', 'mx-voces', 'mx-familiae', 'periph-act', 'periph-pass'],
          filter: const FormFilter(periphrases: {Periphrasis.nulla, Periphrasis.activa, Periphrasis.passiva}, excludeAnomala: false, excludeDeponentia: false, excludeDefectiva: false, excludeImpersonalia: false, excludeIntransitivePassive: true, excludeLemmaIds: {'for', 'quaeso', 'salve', 'ave'}),
          dimensions: const [Dimension.analysis, Dimension.forma, Dimension.modus, Dimension.tempus, Dimension.vox, Dimension.lemma],
          components: const [
            TrialComponent('fin', 'Fōrmae persōnālēs', FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus}, excludeAnomala: false, excludeDeponentia: false, excludeIntransitivePassive: true)),
            TrialComponent('nonfin', 'Fōrmae nōminālēs', FormFilter(moods: {Mood.infinitivus, Mood.participium, Mood.gerundium, Mood.gerundivum, Mood.supinum}, excludeAnomala: false, excludeDeponentia: false)),
            TrialComponent('periph', 'Periphrastica', FormFilter(moods: {Mood.indicativus, Mood.subiunctivus}, periphrases: {Periphrasis.activa, Periphrasis.passiva})),
            TrialComponent('anom', 'Anōmala', FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, kinds: {VerbKind.anomalum}, composite: false, excludeAnomala: false)),
            TrialComponent('spec', 'Speciālia', FormFilter(moods: {Mood.indicativus, Mood.subiunctivus, Mood.imperativus, Mood.infinitivus}, kinds: {VerbKind.deponens, VerbKind.semideponens, VerbKind.defectivum, VerbKind.impersonale}, excludeLemmaIds: {'for', 'quaeso', 'salve', 'ave'})),
          ],
          intro: 'Omnia mixta: quaelibet fōrma cuiuslibet verbī. Analysis complēta rogātur: modus, tempus, vōx, persōna, numerus — aut genus fōrmae nōminālis.',
          examples: ['amāverint · secūtī essent · ferendum erat', 'iēns · fierī · dīcundus · ōderat', 'omnia quae didicistī'],
          opponentId: 'hydra',
          group: 'Mixta',
        ),
      ];
}
