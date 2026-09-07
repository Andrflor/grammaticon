/// Per-activity presentation: Latin labels, opponents, scene, help and sound
/// cues. The encounter and selection screens are written once against this
/// configuration; nothing in them tests which activity is running.
library;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../audio/audio_service.dart';
import '../../game/arena_game.dart';
import '../../game/encounter_scene.dart';
import '../../game/forum_game.dart';
import '../../game/theatrum_game.dart';
import '../../pedagogy/question_generator.dart';
import '../../pedagogy/trial.dart';
import '../help/help_sheet.dart';
import '../help/noun_help_sheet.dart';
import '../help/reading_help_sheet.dart';

/// A sound played [delayMs] after an outcome is shown.
class SoundCue {
  const SoundCue(this.delayMs, this.sfx);
  final int delayMs;
  final Sfx sfx;
}

/// Latin wording that differs between a fight and a debate. Nouns keep their
/// own gender: certāmen (n.) interruptum, contrōversia (f.) interrupta.
class ActivityLabels {
  const ActivityLabels({
    required this.title,
    required this.blurb,
    required this.encounter,
    required this.interrupted,
    required this.resume,
    required this.back,
    required this.leaveTitle,
    required this.leaveBody,
    required this.pausedBody,
    required this.victoryTitle,
    required this.victoryBody,
    required this.defeatTitle,
    required this.defeatBody,
    required this.gemsLine,
    required this.penaltyLine,
    required this.hits,
    required this.opponentResource,
    required this.wonTally,
    required this.lostTally,
    required this.trainingBlurb,
  });

  /// Selection screen title, e.g. "Amphitheātrum · Coniugātiōnēs".
  final String title;

  /// One short line spoken by the hero on the selection screen ("Ēlige
  /// certāmen."); prices and rules are on the cards and in the info sheet.
  final String blurb;

  /// Name of one encounter (button label): Certāmen / Contrōversia.
  final String encounter;
  final String interrupted;
  final String resume;
  final String back;
  final String leaveTitle;
  final String leaveBody;
  final String pausedBody;
  final String victoryTitle;
  final String victoryBody;
  final String defeatTitle;
  final String defeatBody;
  final String gemsLine;
  final String penaltyLine;

  /// Unit of the opponent's resource: ictūs / argūmenta.
  final String hits;

  /// Caption of the opponent bar (null: none — it is plainly health).
  final String? opponentResource;
  final String wonTally;
  final String lostTally;
  final String trainingBlurb;
}

class ActivityConfig {
  const ActivityConfig({
    required this.activity,
    required this.labels,
    required this.heroAsset,
    required this.startIcon,
    required this.opponentNames,
    required this.opponentAssetPrefix,
    required this.createScene,
    required this.showHelp,
    required this.correctCues,
    required this.wrongCues,
    this.longText = false,
  });

  final Activity activity;
  final ActivityLabels labels;
  final String heroAsset;
  final IconData startIcon;
  final Map<String, String> opponentNames;
  final String opponentAssetPrefix;
  final EncounterScene Function(Trial trial, {required bool reducedMotion}) createScene;

  /// Opens the consultable help for a question. [revealForm] is false while
  /// the question is open (help must not show the answer).
  final Future<void> Function(BuildContext context, WidgetRef ref, Question q, {required bool revealForm, String? note}) showHelp;
  final List<SoundCue> correctCues;
  final List<SoundCue> wrongCues;

  /// The question surface is a sentence and the choices are sentences
  /// (Theatrum): wrapping text, one or two choices per row.
  final bool longText;

  String opponentName(String id) => opponentNames[id] ?? 'Adversārius';
  String opponentAsset(String id) => 'assets/images/$opponentAssetPrefix$id.png';
}

final ActivityConfig kAmphitheatrumConfig = ActivityConfig(
  activity: Activity.amphitheatrum,
  labels: const ActivityLabels(
    title: 'Amphitheātrum · Coniugātiōnēs',
    blurb: 'Ēlige certāmen.',
    encounter: 'Certāmen',
    interrupted: 'Certāmen interruptum',
    resume: 'Redī in arēnam',
    back: 'Redī in Amphitheātrum',
    leaveTitle: 'Relinquere arēnam?',
    leaveBody: 'Certāmen servātur: postea redīre poteris.',
    pausedBody: 'Certāmen suspēnsum est.',
    victoryTitle: 'VICTŌRIA!',
    victoryBody: 'Adversārius victus est.',
    defeatTitle: 'CLĀDĒS',
    defeatBody: 'Corda āmissa sunt. Emptiōnēs et perītiae manent: iterum temptā!',
    gemsLine: 'Gemmae certāminis',
    penaltyLine: 'Tribūtum clādis',
    hits: 'ictūs',
    opponentResource: null,
    wonTally: 'Certāmina victa',
    lostTally: 'āmissa',
    trainingBlurb: 'Exercitātiō: eaedem quaestiōnēs sine gemmīs et sine cordibus, ad repetendum. Respōnsa in Tabulā numerantur.',
  ),
  heroAsset: 'assets/images/hero_idle.png',
  startIcon: Icons.sports_martial_arts,
  opponentNames: const {'statua': 'Statua Animāta', 'gladiator': 'Gladiātor Thrāx', 'leo': 'Leō Āfricānus', 'sphinx': 'Sphinx Aegyptia', 'cyclops': 'Cyclōps', 'hydra': 'Hydra Lernaea'},
  opponentAssetPrefix: 'enemy_',
  createScene: (trial, {required reducedMotion}) => ArenaGame(enemyId: trial.opponentId, reducedMotion: reducedMotion),
  showHelp: (context, ref, q, {required revealForm, note}) => showHelpSheet(context, ref, lemmaId: q.lemmaId, form: revealForm ? q.verb.target : null, note: note),
  correctCues: const [SoundCue(60, Sfx.impetus), SoundCue(170, Sfx.ictus)],
  wrongCues: const [SoundCue(170, Sfx.vulnus)],
);

final ActivityConfig kForumConfig = ActivityConfig(
  activity: Activity.forum,
  labels: const ActivityLabels(
    title: 'Forum · Dēclīnātiōnēs',
    blurb: 'Ēlige contrōversiam.',
    encounter: 'Contrōversia',
    interrupted: 'Contrōversia interrupta',
    resume: 'Redī in forum',
    back: 'Redī in Forum',
    leaveTitle: 'Relinquere forum?',
    leaveBody: 'Contrōversia servātur: postea redīre poteris.',
    pausedBody: 'Contrōversia suspēnsa est.',
    victoryTitle: 'CAUSA VICTA!',
    victoryBody: 'Adversārius ōrātiōne superātus est; populus tibi plaudit.',
    defeatTitle: 'CAUSA ĀMISSA',
    defeatBody: 'Cōnstantia tua dēfēcit. Emptiōnēs et perītiae manent: iterum temptā!',
    gemsLine: 'Gemmae contrōversiae',
    penaltyLine: 'Tribūtum causae āmissae',
    hits: 'argūmenta',
    opponentResource: 'cōnstantia',
    wonTally: 'Contrōversiae victae',
    lostTally: 'āmissae',
    trainingBlurb: 'Exercitātiō: eaedem quaestiōnēs sine gemmīs et sine cordibus, ad repetendum. Respōnsa in Tabulā numerantur.',
  ),
  heroAsset: 'assets/images/orator_idle.png',
  startIcon: Icons.record_voice_over,
  opponentNames: const {'rhetor': 'Rhētor Graecus', 'senator': 'Senātor Vetus', 'causidicus': 'Causidicus Astūtus', 'philosophus': 'Philosophus Stōicus', 'censor': 'Cēnsor Sevērus'},
  opponentAssetPrefix: 'rhetor_',
  createScene: (trial, {required reducedMotion}) => ForumGame(opponentId: trial.opponentId, reducedMotion: reducedMotion),
  showHelp: (context, ref, q, {required revealForm, note}) => showNounHelpSheet(context, ref, q: q, revealForm: revealForm, note: note),
  correctCues: const [SoundCue(60, Sfx.oratio), SoundCue(300, Sfx.plausus)],
  wrongCues: const [SoundCue(120, Sfx.refutatio), SoundCue(320, Sfx.murmur)],
);

final ActivityConfig kTheatrumConfig = ActivityConfig(
  activity: Activity.theatrum,
  labels: const ActivityLabels(
    title: 'Theātrum · Interpretātiō',
    blurb: 'Ēlige fābulam.',
    encounter: 'Fābula',
    interrupted: 'Fābula interrupta',
    resume: 'Redī in theātrum',
    back: 'Redī in Theātrum',
    leaveTitle: 'Relinquere scaenam?',
    leaveBody: 'Fābula servātur: postea redīre poteris.',
    pausedBody: 'Fābula suspēnsa est.',
    victoryTitle: 'PLAUSUS!',
    victoryBody: 'Adversārius ē scaenā cessit; populus tibi plaudit.',
    defeatTitle: 'FĀBULA ĀMISSA',
    defeatBody: 'Adversārius scaenam vīcit. Emptiōnēs et perītiae manent: iterum temptā!',
    gemsLine: 'Gemmae fābulae',
    penaltyLine: 'Tribūtum fābulae āmissae',
    hits: 'versūs',
    opponentResource: 'favor populī',
    wonTally: 'Fābulae victae',
    lostTally: 'āmissae',
    trainingBlurb: 'Exercitātiō: eaedem sententiae sine gemmīs et sine cordibus, ad repetendum. Respōnsa in Tabulā numerantur.',
  ),
  heroAsset: 'assets/images/histrio_idle.png',
  startIcon: Icons.theater_comedy,
  opponentNames: const {
    'comoedus': 'Cōmoedus Rīdēns',
    'tragoedus': 'Tragoedus Cothurnātus',
    'mimus': 'Mīmus Versicolor',
    'pantomimus': 'Pantomīmus Ēlegāns',
    'chorus': 'Chorī Magister',
    'dominus': 'Dominus Gregis',
  },
  opponentAssetPrefix: 'actor_',
  createScene: (trial, {required reducedMotion}) => TheatrumGame(opponentId: trial.opponentId, reducedMotion: reducedMotion),
  showHelp: (context, ref, q, {required revealForm, note}) => showReadingHelpSheet(context, ref, q: q, revealForm: revealForm, note: note),
  correctCues: const [SoundCue(60, Sfx.tibia), SoundCue(320, Sfx.plausus)],
  wrongCues: const [SoundCue(120, Sfx.refutatio), SoundCue(340, Sfx.sibilus)],
  longText: true,
);

ActivityConfig configFor(Activity a) => switch (a) {
      Activity.amphitheatrum => kAmphitheatrumConfig,
      Activity.forum => kForumConfig,
      Activity.theatrum => kTheatrumConfig,
    };
