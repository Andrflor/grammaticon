import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../audio/audio_service.dart';
import '../pedagogy/mastery.dart';
import '../pedagogy/mastery_view.dart';
import '../pedagogy/progression.dart';
import '../pedagogy/question.dart';
import '../pedagogy/trials.dart';
import '../persistence/save_data.dart';
import 'answer_resolver.dart';

enum BattlePhase { intro, question, correct, wrong, victory, defeat }

class AnswerOutcome {
  const AnswerOutcome({required this.sequence, required this.question, required this.chosenValue, required this.correct, required this.resolution, required this.explanation});

  /// Monotonic counter so the UI can react once per outcome.
  final int sequence;
  final Question question;
  final String chosenValue;
  final bool correct;
  final Resolution resolution;
  final Explanation explanation;

  int get gemsDelta => resolution.delta;
  String? get contrastSurface => explanation.contrastSurface;
}

class BattleState {
  const BattleState({
    required this.trial,
    required this.mode,
    required this.componentIds,
    required this.phase,
    required this.seed,
    this.question,
    required this.hearts,
    required this.maxHearts,
    required this.enemyHp,
    required this.enemyMaxHp,
    this.answered = 0,
    this.correctCount = 0,
    this.gemsDelta = 0,
    this.questionIndex = 0,
    this.helpUsed = false,
    this.last,
    this.explanationOpen = false,
    this.paused = false,
    this.victoryBonus = 0,
    this.defeatPenalty = 0,
    this.recentLemmas = const [],
    this.recentSurfaces = const [],
    this.resumed = false,
    this.outcomeCount = 0,
  });

  final Trial trial;
  final BattleMode mode;
  final List<String> componentIds;
  final BattlePhase phase;
  final int seed;
  final Question? question;
  final int hearts;
  final int maxHearts;
  final int enemyHp;
  final int enemyMaxHp;
  final int answered;
  final int correctCount;

  /// Gems won or lost during this fight (bonus excluded).
  final int gemsDelta;
  final int questionIndex;
  final bool helpUsed;
  final AnswerOutcome? last;
  final bool explanationOpen;
  final bool paused;
  final int victoryBonus;

  /// Gems that will be lost if this fight ends in defeat (computed when it does).
  final int defeatPenalty;
  final List<String> recentLemmas;
  final List<String> recentSurfaces;
  final bool resumed;
  final int outcomeCount;

  bool get isOver => phase == BattlePhase.victory || phase == BattlePhase.defeat;
  bool get acceptsInput => phase == BattlePhase.question && !paused;
  bool get isTraining => mode == BattleMode.exercitatio;

  BattleState copyWith({
    BattlePhase? phase,
    Question? question,
    bool clearQuestion = false,
    int? hearts,
    int? enemyHp,
    int? answered,
    int? correctCount,
    int? gemsDelta,
    int? questionIndex,
    bool? helpUsed,
    AnswerOutcome? last,
    bool? explanationOpen,
    bool? paused,
    int? victoryBonus,
    int? defeatPenalty,
    List<String>? recentLemmas,
    List<String>? recentSurfaces,
    int? outcomeCount,
  }) => BattleState(
    trial: trial,
    mode: mode,
    componentIds: componentIds,
    phase: phase ?? this.phase,
    seed: seed,
    question: clearQuestion ? null : (question ?? this.question),
    hearts: hearts ?? this.hearts,
    maxHearts: maxHearts,
    enemyHp: enemyHp ?? this.enemyHp,
    enemyMaxHp: enemyMaxHp,
    answered: answered ?? this.answered,
    correctCount: correctCount ?? this.correctCount,
    gemsDelta: gemsDelta ?? this.gemsDelta,
    questionIndex: questionIndex ?? this.questionIndex,
    helpUsed: helpUsed ?? this.helpUsed,
    last: last ?? this.last,
    explanationOpen: explanationOpen ?? this.explanationOpen,
    paused: paused ?? this.paused,
    victoryBonus: victoryBonus ?? this.victoryBonus,
    defeatPenalty: defeatPenalty ?? this.defeatPenalty,
    recentLemmas: recentLemmas ?? this.recentLemmas,
    recentSurfaces: recentSurfaces ?? this.recentSurfaces,
    resumed: resumed,
    outcomeCount: outcomeCount ?? this.outcomeCount,
  );

  ActiveBattle snapshot() => ActiveBattle(
    trialId: trial.id,
    mode: mode,
    hearts: hearts,
    enemyHp: enemyHp,
    answered: answered,
    gemsDelta: gemsDelta,
    seed: seed,
    questionIndex: questionIndex,
    componentIds: componentIds,
    correctCount: correctCount,
  );
}

final battleProvider = NotifierProvider<BattleController, BattleState?>(BattleController.new);

/// Drives one encounter (a fight in the Amphitheatrum, a debate in the Forum).
/// The controller is activity-neutral: questions and corrections come from the
/// [QuestionSource] of the trial's activity. Every answer is resolved exactly
/// once, by [AnswerResolver], and persisted before any animation starts.
class BattleController extends Notifier<BattleState?> {
  Timer? _timer;
  Random? _rng;

  @override
  BattleState? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  QuestionSource get _source => ref.read(questionSourcesProvider);
  ProfileController get _profile => ref.read(profileProvider.notifier);
  Settings get _settings => ref.read(settingsProvider);
  AudioService get _audio => ref.read(audioProvider);

  // ----- lifecycle --------------------------------------------------------------

  void start(Trial trial, BattleMode mode, {ActiveBattle? resume}) {
    _timer?.cancel();
    final save = ref.read(profileProvider);
    final componentIds = resume?.componentIds ?? Progression.componentsFor(save, trial);
    final seed = resume?.seed ?? DateTime.now().millisecondsSinceEpoch & 0x7fffffff;
    _rng = Random(seed);
    final showIntro = resume == null && !save.introSeen.contains(trial.id);
    var s = BattleState(
      trial: trial,
      mode: mode,
      componentIds: componentIds,
      phase: showIntro ? BattlePhase.intro : BattlePhase.question,
      seed: seed,
      hearts: resume?.hearts ?? trial.hearts,
      maxHearts: trial.hearts,
      enemyHp: resume?.enemyHp ?? trial.questionsToWin,
      enemyMaxHp: trial.questionsToWin,
      answered: resume?.answered ?? 0,
      correctCount: resume?.correctCount ?? 0,
      gemsDelta: resume?.gemsDelta ?? 0,
      questionIndex: resume?.questionIndex ?? 0,
      resumed: resume != null,
    );
    // Advance the deterministic generator to the resumed position.
    for (var i = 0; i < s.questionIndex; i++) {
      _rng!.nextInt(1 << 20);
    }
    s = _withNewQuestion(s);
    state = s;
    _profile.setActiveBattle(s.snapshot());
  }

  void beginAfterIntro() {
    final s = state;
    if (s == null || s.phase != BattlePhase.intro) return;
    _profile.markIntroSeen(s.trial.id);
    state = s.copyWith(phase: BattlePhase.question);
  }

  void abandon() {
    _timer?.cancel();
    state = null;
    _profile.setActiveBattle(null);
  }

  /// Finishes a won or lost fight: pays the bonus and clears the snapshot.
  Future<void> finish() async {
    final s = state;
    if (s == null || !s.isOver) return;
    _timer?.cancel();
    final won = s.phase == BattlePhase.victory;
    await _profile.recordBattleEnd(activity: s.trial.activity, won: won, bonus: won ? s.victoryBonus : 0, penalty: won ? 0 : s.defeatPenalty);
    state = null;
  }

  // ----- questions ---------------------------------------------------------------------

  BattleState _withNewQuestion(BattleState s) {
    final save = ref.read(profileProvider);
    final rng = _rng!;
    final q = _source.generate(
      trial: s.trial,
      componentIds: s.componentIds,
      rng: Random(rng.nextInt(1 << 20) ^ s.seed),
      id: '${s.seed}-${s.questionIndex}',
      recentLemmas: s.recentLemmas,
      recentSurfaces: s.recentSurfaces,
      skills: save.skills,
      cfg: ref.read(masteryConfigProvider),
    );
    return s.copyWith(question: q, helpUsed: false, explanationOpen: false);
  }

  /// Answers the current question. Ignored when the question id does not
  /// match (late or duplicate input) or when input is not accepted.
  void answer(String questionId, int choiceIndex) {
    final s = state;
    if (s == null || !s.acceptsInput) return;
    final q = s.question;
    if (q == null || q.id != questionId) return;
    if (choiceIndex < 0 || choiceIndex >= q.choices.length) return;
    final chosen = q.choices[choiceIndex].value;
    final quality = s.helpUsed ? AnswerQuality.adiuta : AnswerQuality.autonoma;

    final save = ref.read(profileProvider);
    final res = ref.read(answerResolverProvider).resolve(save: save, q: q, chosenValue: chosen, quality: quality, mode: s.mode, now: DateTime.now());
    final explanation = _source.explain(q: q, chosenValue: chosen, correct: res.correct);

    final hearts = res.correct || s.isTraining ? s.hearts : s.hearts - 1;
    final enemyHp = res.correct ? s.enemyHp - 1 : s.enemyHp;
    final recentL = [...s.recentLemmas, q.lemmaId];
    while (recentL.length > 3) {
      recentL.removeAt(0);
    }
    final recentS = [...s.recentSurfaces, q.surface];
    while (recentS.length > 12) {
      recentS.removeAt(0);
    }
    var next = s.copyWith(
      phase: res.correct ? BattlePhase.correct : BattlePhase.wrong,
      hearts: hearts,
      enemyHp: enemyHp,
      answered: s.answered + 1,
      correctCount: s.correctCount + (res.correct ? 1 : 0),
      gemsDelta: s.gemsDelta + res.delta,
      questionIndex: s.questionIndex + 1,
      recentLemmas: recentL,
      recentSurfaces: recentS,
      outcomeCount: s.outcomeCount + 1,
      last: AnswerOutcome(sequence: s.outcomeCount + 1, question: q, chosenValue: chosen, correct: res.correct, resolution: res, explanation: explanation),
    );
    final over = enemyHp <= 0 || (hearts <= 0 && !s.isTraining);
    if (over && enemyHp <= 0) {
      next = next.copyWith(victoryBonus: _computeVictoryBonus(save, s));
    } else if (over && !s.isTraining) {
      final eco = ref.read(answerResolverProvider).economy;
      next = next.copyWith(
        defeatPenalty: eco.defeatPenalty(balance: res.gemsAfter, fightDelta: next.gemsDelta),
      );
    }
    // Persist first: the transaction and the arena snapshot together.
    _profile.applyResolution(res, over ? null : next.snapshot());
    state = next;
    _audio.play(res.correct ? Sfx.recte : Sfx.errat);
    _schedule(over ? (enemyHp <= 0 ? BattlePhase.victory : BattlePhase.defeat) : BattlePhase.question);
  }

  int _computeVictoryBonus(SaveData save, BattleState s) {
    if (s.isTraining) return 0;
    final eco = ref.read(answerResolverProvider).economy;
    final cheapest = Progression.cheapestPurchasable(save);
    // The trial's skill may be an aggregate (a whole declension): use the summary.
    final tier = MasterySummary.forSkill(save, s.trial.primarySkill, ref.read(masteryConfigProvider)).tier;
    final catchUp = cheapest != null && save.gems < cheapest && tier == MasteryTier.perita;
    return eco.victoryBonus(catchUp: catchUp);
  }

  /// Correct answers advance automatically after a short delay; after an
  /// error the explanation stays on screen until the player proceeds.
  void _schedule(BattlePhase target) {
    _timer?.cancel();
    final s = state;
    if (s == null) return;
    if (s.phase == BattlePhase.wrong) return;
    _timer = Timer(Duration(milliseconds: _settings.correctDelayMs), () => _advance(target));
  }

  void _advance(BattlePhase target) {
    final s = state;
    if (s == null || s.paused || s.explanationOpen) return;
    if (s.phase != BattlePhase.correct && s.phase != BattlePhase.wrong) return;
    if (target == BattlePhase.question) {
      state = _withNewQuestion(s.copyWith(phase: BattlePhase.question));
      _profile.setActiveBattle(state!.snapshot());
    } else {
      state = s.copyWith(phase: target, clearQuestion: true);
      _audio.play(target == BattlePhase.victory ? Sfx.victoria : Sfx.clades);
    }
  }

  /// Skips the remaining feedback delay.
  void proceed() {
    final s = state;
    if (s == null) return;
    if (s.phase != BattlePhase.correct && s.phase != BattlePhase.wrong) return;
    if (s.explanationOpen) return;
    _timer?.cancel();
    final over = s.enemyHp <= 0 || (s.hearts <= 0 && !s.isTraining);
    _advance(over ? (s.enemyHp <= 0 ? BattlePhase.victory : BattlePhase.defeat) : BattlePhase.question);
  }

  // ----- help, explanation, pause ------------------------------------------------------

  /// Marks the current question as aided (help consulted before answering).
  void markHelpUsed() {
    final s = state;
    if (s == null || s.phase != BattlePhase.question) return;
    state = s.copyWith(helpUsed: true);
  }

  void openExplanation() {
    final s = state;
    if (s == null) return;
    _timer?.cancel();
    state = s.copyWith(explanationOpen: true);
  }

  void closeExplanation() {
    final s = state;
    if (s == null) return;
    state = s.copyWith(explanationOpen: false);
    if (s.phase == BattlePhase.correct || s.phase == BattlePhase.wrong) {
      final over = s.enemyHp <= 0 || (s.hearts <= 0 && !s.isTraining);
      _schedule(over ? (s.enemyHp <= 0 ? BattlePhase.victory : BattlePhase.defeat) : BattlePhase.question);
    }
  }

  void pause() {
    final s = state;
    if (s == null || s.isOver) return;
    _timer?.cancel();
    state = s.copyWith(paused: true);
  }

  void resume() {
    final s = state;
    if (s == null || !s.paused) return;
    state = s.copyWith(paused: false);
    if (s.phase == BattlePhase.correct || s.phase == BattlePhase.wrong) {
      final over = s.enemyHp <= 0 || (s.hearts <= 0 && !s.isTraining);
      _schedule(over ? (s.enemyHp <= 0 ? BattlePhase.victory : BattlePhase.defeat) : BattlePhase.question);
    }
  }

  /// Restart after a defeat (purchases and mastery are untouched).
  void retry() {
    final s = state;
    if (s == null) return;
    final trial = s.trial;
    final mode = s.mode;
    _timer?.cancel();
    if (s.isOver) {
      final won = s.phase == BattlePhase.victory;
      _profile.recordBattleEnd(activity: s.trial.activity, won: won, bonus: won ? s.victoryBonus : 0, penalty: won ? 0 : s.defeatPenalty);
    } else {
      _profile.setActiveBattle(null);
    }
    start(trial, mode);
  }
}
