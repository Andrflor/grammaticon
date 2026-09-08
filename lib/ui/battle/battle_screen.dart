import 'dart:async';
import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../audio/audio_service.dart';
import '../../battle/battle_controller.dart';
import '../../pedagogy/mastery.dart';
import '../../pedagogy/mastery_view.dart';
import '../../pedagogy/question.dart';
import '../../pedagogy/skills.dart';
import '../../pedagogy/trials.dart';
import '../../persistence/save_data.dart';
import '../activity/activity_config.dart';
import '../widgets/roman_widgets.dart';

/// One encounter: a fight in the arena, a debate in the Forum or a performance
/// in the Theatrum. Every encounter is played for real: there is no training
/// mode. Activity-specific presentation comes from the trial's [ActivityConfig].
class BattleScreen extends HookConsumerWidget {
  const BattleScreen({super.key, required this.trial, this.resume});
  final Trial trial;
  final ActiveBattle? resume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final ctrl = ref.read(battleProvider.notifier);
    final audio = ref.read(audioProvider);
    final config = configFor(trial.activity);
    // The scene instance is stable across rebuilds (keyed by the trial).
    final game = useMemoized(() => config.createScene(trial, reducedMotion: settings.reducedMotion), [trial.id]);
    game.reducedMotion = settings.reducedMotion;
    final cardKey = useMemoized(() => GlobalKey(debugLabel: 'questionCard'));
    final flights = useState<List<_GemFlightSpec>>(const []);
    final timers = useRef(<Timer>[]);
    final startTiers = useRef<Map<String, MasteryTier>>({});

    // Start (or resume) the encounter once.
    useEffect(() {
      final save = ref.read(profileProvider);
      final cfg = ref.read(masteryConfigProvider);
      startTiers.value = {for (final s in trial.skillIds) s: MasterySummary.forSkill(save, s, cfg).tier};
      Future.microtask(() => ctrl.start(trial, resume: resume));
      return () {
        for (final t in timers.value) {
          t.cancel();
        }
      };
    }, const []);

    // Pause when the app loses focus.
    useOnAppLifecycleStateChange((prev, cur) {
      if (cur != AppLifecycleState.resumed) ctrl.pause();
    });

    void later(int ms, VoidCallback f) {
      final t = Timer(Duration(milliseconds: ms), f);
      timers.value.add(t);
    }

    // React to resolved outcomes: choreography, sounds, flying gems.
    ref.listen<BattleState?>(battleProvider, (prev, next) {
      if (next == null) return;
      final o = next.last;
      if (o != null && o.sequence != prev?.last?.sequence) {
        if (o.correct) {
          game.playerStrikes();
          for (final cue in config.correctCues) {
            later(cue.delayMs, () => audio.play(cue.sfx));
          }
          if (o.gemsDelta > 0 && !settings.reducedMotion) {
            final from = _centerOf(cardKey);
            final to = _centerOf(GemTarget.key);
            if (from != null && to != null) {
              final id = DateTime.now().microsecondsSinceEpoch;
              flights.value = [...flights.value, _GemFlightSpec(id, from, to, min(o.gemsDelta, 8))];
              later(900, () => audio.play(Sfx.gemma));
              later(1500, () => flights.value = flights.value.where((f) => f.id != id).toList());
            }
          }
        } else {
          game.opponentStrikes();
          for (final cue in config.wrongCues) {
            later(cue.delayMs, () => audio.play(cue.sfx));
          }
        }
      }
      if (prev?.phase != next.phase) {
        if (next.phase == BattlePhase.victory) game.victory();
        if (next.phase == BattlePhase.defeat) game.defeat();
        if (next.phase == BattlePhase.question && (prev?.phase == BattlePhase.victory || prev?.phase == BattlePhase.defeat)) game.resetPoses();
      }
    });

    final state = ref.watch(battleProvider);

    Future<void> leave() async {
      final s = ref.read(battleProvider);
      if (s != null && s.isOver) {
        await ctrl.finish();
      } else if (s != null) {
        ctrl.pause();
        final ok = await confirmLatin(context, title: config.labels.leaveTitle, body: config.labels.leaveBody, yes: 'Relinque', no: 'Mane');
        if (!ok) {
          ctrl.resume();
          return;
        }
      }
      if (context.mounted) Navigator.of(context).pop();
    }

    // Keyboard: digits 1–9 answer, Escape pauses, Space/Enter proceeds; on the
    // result screen Space/Enter retries and Escape leaves. Only
    // KeyDownEvent counts (held keys repeat, releases never answer), and only
    // while this route is on top (no dialog or help sheet open).
    final route = ModalRoute.of(context);
    useEffect(() {
      bool handler(KeyEvent e) {
        if (e is! KeyDownEvent) return false;
        if (route != null && !route.isCurrent) return false;
        final s = ref.read(battleProvider);
        if (s == null) return false;
        final k = e.logicalKey;
        final proceedKey = k == LogicalKeyboardKey.space || k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter;
        // Result screen: Space/Enter is "Iterum", Escape returns to the activity.
        if (s.isOver) {
          if (proceedKey) {
            ctrl.retry();
            return true;
          }
          if (k == LogicalKeyboardKey.escape) {
            leave();
            return true;
          }
          return false;
        }
        if (k == LogicalKeyboardKey.escape) {
          if (s.paused) {
            ctrl.resume();
          } else {
            ctrl.pause();
          }
          return true;
        }
        if (proceedKey) {
          if (s.phase == BattlePhase.intro) {
            ctrl.beginAfterIntro();
          } else {
            ctrl.proceed();
          }
          return true;
        }
        final digit = _digitOf(k) ?? int.tryParse(e.character ?? '');
        if (digit != null && digit >= 1 && digit <= 9 && s.question != null && s.acceptsInput) {
          ctrl.answer(s.question!.id, digit - 1);
          return true;
        }
        return false;
      }

      HardwareKeyboard.instance.addHandler(handler);
      return () => HardwareKeyboard.instance.removeHandler(handler);
    }, [route]);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) leave();
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: G.purpleDark,
          body: Stack(
            fit: StackFit.expand,
            children: [
              GameWidget(game: game),
              if (state != null) ...[
                _Hud(state: state, config: config, onLeave: leave, onPause: () => state.paused ? ctrl.resume() : ctrl.pause()),
                _Center(state: state, cardKey: cardKey, trial: trial, config: config),
                if (state.phase == BattlePhase.intro) _IntroOverlay(trial: trial, onStart: ctrl.beginAfterIntro),
                if (state.paused) _PauseOverlay(body: config.labels.pausedBody, onResume: ctrl.resume, onLeave: leave),
                if (state.isOver) _ResultOverlay(state: state, config: config, startTiers: startTiers.value, onLeave: leave, onRetry: ctrl.retry),
              ],
              for (final f in flights.value) _GemFlight(key: ValueKey(f.id), spec: f),
            ],
          ),
        ),
      ),
    );
  }

  static final Map<LogicalKeyboardKey, int> _digits = {
    LogicalKeyboardKey.digit1: 1,
    LogicalKeyboardKey.digit2: 2,
    LogicalKeyboardKey.digit3: 3,
    LogicalKeyboardKey.digit4: 4,
    LogicalKeyboardKey.digit5: 5,
    LogicalKeyboardKey.digit6: 6,
    LogicalKeyboardKey.digit7: 7,
    LogicalKeyboardKey.digit8: 8,
    LogicalKeyboardKey.digit9: 9,
    LogicalKeyboardKey.numpad1: 1,
    LogicalKeyboardKey.numpad2: 2,
    LogicalKeyboardKey.numpad3: 3,
    LogicalKeyboardKey.numpad4: 4,
    LogicalKeyboardKey.numpad5: 5,
    LogicalKeyboardKey.numpad6: 6,
    LogicalKeyboardKey.numpad7: 7,
    LogicalKeyboardKey.numpad8: 8,
    LogicalKeyboardKey.numpad9: 9,
  };

  static int? _digitOf(LogicalKeyboardKey k) => _digits[k];

  static Offset? _centerOf(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }
}

// ---------------------------------------------------------------- HUD

class _Hud extends ConsumerWidget {
  const _Hud({required this.state, required this.config, required this.onLeave, required this.onPause});
  final BattleState state;
  final ActivityConfig config;
  final VoidCallback onLeave;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gems = ref.watch(profileProvider.select((s) => s.gems));
    final enemyName = config.opponentName(state.trial.opponentId);
    // The opponent's remaining resource: health in the arena, resolve in the Forum.
    final resource = config.labels.opponentResource;
    final compact = MediaQuery.sizeOf(context).width < 600;
    final bar = Column(
      children: [
        Text(enemyName, style: G.display(14, color: G.goldLight), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        // Stadium shapes, not a clipped stack: Impeller on OpenGL ES does not
        // anti-alias clips.
        Stack(
          children: [
            Container(height: 14, decoration: const ShapeDecoration(shape: StadiumBorder(), color: Color(0xAA200A40))),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              widthFactor: (state.enemyHp / state.enemyMaxHp).clamp(0.0, 1.0),
              child: Container(
                height: 14,
                decoration: const ShapeDecoration(shape: StadiumBorder(), gradient: LinearGradient(colors: [G.red, Color(0xFFFF8A94)])),
              ),
            ),
          ],
        ),
        Text('${resource == null ? '' : '$resource '}${state.enemyHp} / ${state.enemyMaxHp}', style: G.body(11, color: Colors.white, weight: 700)),
      ],
    );
    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RomanButton(label: '', icon: Icons.arrow_back, style: RomanButtonStyle.ghost, dense: true, onPressed: onLeave),
        const SizedBox(width: 6),
        RomanButton(label: '', icon: state.paused ? Icons.play_arrow : Icons.pause, style: RomanButtonStyle.ghost, dense: true, onPressed: state.isOver ? null : onPause),
        const SizedBox(width: 10),
        for (var i = 0; i < state.maxHearts; i++)
          Padding(padding: const EdgeInsets.only(right: 2), child: Image.asset(i < state.hearts ? 'assets/images/heart.png' : 'assets/images/heart_empty.png', width: 30, height: 30)),
      ],
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(kHudSidePadding, kHudTopPadding, kHudSidePadding, 0),
        child: Column(
          children: [
            HudRow(
              left: controls,
              // Wide screens: the opponent bar sits between the hearts and the gems,
              // centred on the screen whatever the width of either side.
              center: compact ? null : bar,
              // Size 34 gives the counter the same 46 px pill height as the ghost
              // buttons, in the same place as on every other screen. No cog here:
              // the Optiōnēs are not opened from inside a trial.
              right: AnimatedGemCounter(count: gems, size: 34, isFlightTarget: true),
            ),
            // Narrow screens: the bar takes its own line under the controls.
            if (compact) Padding(padding: const EdgeInsets.fromLTRB(40, 4, 40, 0), child: bar),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- question, choices, feedback

class _Center extends ConsumerWidget {
  const _Center({required this.state, required this.cardKey, required this.trial, required this.config});
  final BattleState state;
  final GlobalKey cardKey;
  final Trial trial;
  final ActivityConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(battleProvider.notifier);
    final q = state.question ?? state.last?.question;
    if (q == null || state.phase == BattlePhase.intro || state.isOver) return const SizedBox.shrink();
    final outcome = state.phase == BattlePhase.correct || state.phase == BattlePhase.wrong ? state.last : null;
    final showFeedback = outcome != null && outcome.question.id == q.id;
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 600;
    // A sentence (Theatrum) wraps at a readable size; an isolated form is
    // scaled to the width.
    final long = config.longText;
    final surfaceSize = long ? (compact ? (q.surface.length > 140 ? 15.0 : 17.0) : (q.surface.length > 160 ? 19.0 : (q.surface.length > 100 ? 21.0 : 25.0))) : (w / (q.surface.length + 6)).clamp(22.0, compact ? 34.0 : 48.0);

    return SafeArea(
      child: Column(
        children: [
          // Room for the HUD (two lines on narrow screens).
          SizedBox(height: compact ? 132 : 72),
          // Question card
          RomanPanel(
            key: cardKey,
            width: min(w - 24, long ? 900 : 760),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('${trial.name} · ${state.answered}/${state.enemyMaxHp}', style: G.body(12, color: G.inkSoft, weight: 700)),
                    ),
                    RomanButton(
                      label: 'Auxilium',
                      icon: Icons.help_outline,
                      style: RomanButtonStyle.neutral,
                      dense: true,
                      sound: Sfx.folium,
                      onPressed: () async {
                        final open = state.phase == BattlePhase.question;
                        if (open) ctrl.markHelpUsed();
                        ctrl.openExplanation();
                        await config.showHelp(
                          context,
                          ref,
                          q,
                          revealForm: !open,
                          note: open ? 'Auxilium ante respōnsum: haec respōnsiō "adiūta" numerābitur (praemium minus, nūlla poena).' : null,
                        );
                        ctrl.closeExplanation();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  q.surface,
                  textAlign: TextAlign.center,
                  style: G.display(surfaceSize, color: G.purpleDark, letterSpacing: long ? 0.3 : 2).copyWith(height: long ? 1.3 : null),
                ),
                // Context lines (dictionary entry) never give the answer away.
                for (final line in q.context) Text(line, textAlign: TextAlign.center, style: G.body(compact ? 13 : 15, color: G.inkSoft, style: FontStyle.italic)),
                const SizedBox(height: 4),
                Text(q.prompt, style: G.body(compact ? 16 : 20, color: G.inkSoft, weight: 700)),
                if (q.ambiguous)
                  Text(
                    'Plūrēs respōnsiōnēs rēctae fierī possunt.',
                    style: G.body(12, color: G.inkSoft, style: FontStyle.italic),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Feedback
          SizedBox(
            height: compact ? 44 : 52,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (c, a) => ScaleTransition(
                scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
                child: c,
              ),
              child: showFeedback
                  ? Row(
                      key: ValueKey(outcome.sequence),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(outcome.correct ? 'RECTE!' : 'ERRAT…', style: G.display(compact ? 26 : 34, color: outcome.correct ? G.green : G.red)),
                        if (outcome.gemsDelta != 0) ...[
                          const SizedBox(width: 12),
                          Text('${outcome.gemsDelta > 0 ? '+' : ''}${outcome.gemsDelta}', style: G.display(compact ? 22 : 28, color: outcome.gemsDelta > 0 ? G.goldLight : const Color(0xFFFF8A94))),
                          const SizedBox(width: 4),
                          Image.asset('assets/images/gem.png', width: 26, height: 26),
                        ],
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          // The lower block (correction and choices) is anchored to the bottom
          // and scrolls only when sentences do not fit (small screens).
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
          // Wrong-answer explanation
          if (showFeedback && !outcome.correct)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: RomanPanel(
                width: min(w - 24, long ? 900 : 760),
                color: const Color(0xFFFFF4F5),
                borderColor: G.red,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(outcome.explanation.headline, style: G.body(15, weight: 800, color: G.purpleDark)),
                    const SizedBox(height: 4),
                    Text(outcome.explanation.detail, style: G.body(14)),
                    if (outcome.explanation.also.isNotEmpty)
                      Text(
                        'Etiam: ${outcome.explanation.also.take(3).join(' · ')}',
                        style: G.body(12, color: G.inkSoft, style: FontStyle.italic),
                      ),
                    const SizedBox(height: 8),
                    // Wraps on narrow screens instead of overflowing.
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        RomanButton(
                          label: 'Explicā plūs',
                          icon: Icons.menu_book,
                          style: RomanButtonStyle.neutral,
                          dense: true,
                          sound: Sfx.folium,
                          onPressed: () async {
                            ctrl.openExplanation();
                            await config.showHelp(context, ref, q, revealForm: true);
                            ctrl.closeExplanation();
                          },
                        ),
                        RomanButton(label: 'Perge', icon: Icons.arrow_forward, style: RomanButtonStyle.gold, onPressed: ctrl.proceed),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (showFeedback && outcome.correct && outcome.explanation.also.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'Etiam: ${outcome.explanation.also.take(2).join(' · ')}',
                style: G.body(12, color: G.goldLight, style: FontStyle.italic),
              ),
            ),
          // Choices (stable order while the question is shown)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: _Choices(q: q, state: state, onPick: (i) => ctrl.answer(q.id, i)),
          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Choices extends StatelessWidget {
  const _Choices({required this.q, required this.state, required this.onPick});
  final Question q;
  final BattleState state;
  final void Function(int) onPick;

  @override
  Widget build(BuildContext context) {
    final outcome = state.last;
    final answered = state.phase != BattlePhase.question && outcome != null && outcome.question.id == q.id;
    final w = MediaQuery.sizeOf(context).width;
    final n = q.choices.length;
    // Narrow screens: long labels (Nōminātīvus, Plūsquamperfectum) get a full row
    // so they never break mid-word.
    final longest = q.choices.fold(0, (m, c) => max(m, c.label.length));
    // Sentences (Theatrum): one per row, two on wide screens.
    final sentences = longest > 32;
    final perRow = sentences ? (w < 900 ? 1 : 2) : (w < 600 ? (n <= 2 ? n : (longest > 9 ? 1 : 2)) : (n <= 4 ? n : 3));
    final bw = ((min(w, sentences ? 1200 : 1000) - 24) - (perRow - 1) * 10) / perRow;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < n; i++)
          SizedBox(
            width: bw,
            child: _ChoiceButton(
              index: i,
              label: q.choices[i].label,
              enabled: state.acceptsInput,
              isCorrect: answered && q.correctValues.contains(q.choices[i].value),
              isChosen: answered && outcome.chosenValue == q.choices[i].value,
              wrong: answered && outcome.chosenValue == q.choices[i].value && !outcome.correct,
              dense: sentences,
              onTap: () => onPick(i),
            ),
          ),
      ],
    );
  }
}

class _ChoiceButton extends HookWidget {
  const _ChoiceButton({required this.index, required this.label, required this.enabled, required this.isCorrect, required this.isChosen, required this.wrong, required this.onTap, this.dense = false});
  final int index;
  final String label;
  final bool enabled;
  final bool isCorrect;
  final bool isChosen;
  final bool wrong;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final shake = useAnimationController(duration: const Duration(milliseconds: 320));
    useEffect(() {
      if (wrong) shake.forward(from: 0);
      return null;
    }, [wrong]);
    final style = isCorrect ? RomanButtonStyle.success : (wrong ? RomanButtonStyle.danger : RomanButtonStyle.primary);
    return AnimatedBuilder(
      animation: shake,
      builder: (context, child) {
        final dx = sin(shake.value * pi * 6) * (1 - shake.value) * 8;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: isChosen ? 1.04 : 1,
        child: RomanButton(
          label: label,
          badge: '${index + 1}',
          style: style,
          expand: true,
          dense: dense,
          sound: null,
          onPressed: enabled ? onTap : null,
          trailing: isCorrect ? const Icon(Icons.check_circle, color: Colors.white) : (wrong ? const Icon(Icons.cancel, color: Colors.white) : null),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- overlays

class _IntroOverlay extends ConsumerWidget {
  const _IntroOverlay({required this.trial, required this.onStart});
  final Trial trial;
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context, WidgetRef ref) => _Dim(
    child: RomanPanel(
      width: min(MediaQuery.sizeOf(context).width - 32, 640),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(trial.name, style: G.display(24, color: G.purple)),
            Text(trial.subtitle, style: G.body(14, color: G.inkSoft, weight: 700)),
            const SizedBox(height: 10),
            Text(trial.intro, style: G.body(16, height: 1.45)),
            const SizedBox(height: 10),
            for (final e in trial.examples)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: RomanPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: Colors.white,
                  borderColor: G.marbleDark,
                  shadow: false,
                  radius: 12,
                  child: Text(e, style: G.body(17, weight: 700, color: G.purpleDark)),
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.warning_amber, color: G.redDark, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('${trial.hearts} corda. ${ref.read(answerResolverProvider).economy.defeatRule()}', style: G.body(13, color: G.redDark, weight: 700)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [RomanButton(label: 'Incipe!', icon: Icons.play_arrow, style: RomanButtonStyle.gold, sound: null, onPressed: onStart)],
            ),
          ],
        ),
      ),
    ),
  );
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({required this.body, required this.onResume, required this.onLeave});
  final String body;
  final VoidCallback onResume;
  final VoidCallback onLeave;
  @override
  Widget build(BuildContext context) => _Dim(
    child: RomanPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Pausa', style: G.display(28, color: G.purple)),
          const SizedBox(height: 8),
          Text(body, style: G.body(16)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              RomanButton(label: 'Perge', icon: Icons.play_arrow, style: RomanButtonStyle.gold, onPressed: onResume),
              RomanButton(label: 'Relinque', icon: Icons.exit_to_app, style: RomanButtonStyle.neutral, onPressed: onLeave),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ResultOverlay extends ConsumerWidget {
  const _ResultOverlay({required this.state, required this.config, required this.startTiers, required this.onLeave, required this.onRetry});
  final BattleState state;
  final ActivityConfig config;
  final Map<String, MasteryTier> startTiers;
  final VoidCallback onLeave;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final won = state.phase == BattlePhase.victory;
    final save = ref.watch(profileProvider);
    final cfg = ref.watch(masteryConfigProvider);
    final labels = config.labels;
    return _Dim(
      child: RomanPanel(
        width: min(MediaQuery.sizeOf(context).width - 32, 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(won ? labels.victoryTitle : labels.defeatTitle, style: G.display(32, color: won ? G.green : G.red)),
            const SizedBox(height: 6),
            Text(won ? labels.victoryBody : labels.defeatBody, style: G.body(16), textAlign: TextAlign.center),
            const SizedBox(height: 14),
            _line('Respōnsa rēcta', '${state.correctCount} / ${state.answered}'),
            _line(labels.gemsLine, '${state.gemsDelta >= 0 ? '+' : ''}${state.gemsDelta}'),
            if (won) _line('Praemium victōriae', '+${state.victoryBonus}'),
            if (save.errata.forTrial(state.trial.id).isNotEmpty) _line('Repetenda (errāta aperta)', '${save.errata.forTrial(state.trial.id).length}'),
            if (!won) _line(labels.penaltyLine, '−${state.defeatPenalty}'),
            if (!won)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${labels.gemsLine} āmittuntur et quārta pars summae solvitur. Emptiōnēs manent.',
                  style: G.body(12, color: G.inkSoft, style: FontStyle.italic),
                ),
              ),
            const SizedBox(height: 10),
            Text('Perītiae', style: G.display(15, color: G.goldDark)),
            for (final s in state.trial.skillIds)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(child: Text(Skills.byId(s).name, style: G.body(14, weight: 700))),
                    MasteryBadge(startTiers[s] ?? MasteryTier.nova, dense: true),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.arrow_forward, size: 16)),
                    MasteryBadge(MasterySummary.forSkill(save, s, cfg).tier, dense: true),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                RomanButton(label: labels.back, icon: Icons.stadium, style: RomanButtonStyle.gold, onPressed: onLeave),
                RomanButton(label: 'Iterum', icon: Icons.replay, style: RomanButtonStyle.primary, onPressed: onRetry),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(String k, String v) => Row(
    children: [
      Expanded(child: Text(k, style: G.body(15))),
      Text(v, style: G.body(16, weight: 800)),
    ],
  );
}

class _Dim extends StatelessWidget {
  const _Dim({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(color: const Color(0xAA1A0A30), alignment: Alignment.center, padding: const EdgeInsets.all(16), child: child);
}

// ---------------------------------------------------------------- flying gems

class _GemFlightSpec {
  const _GemFlightSpec(this.id, this.from, this.to, this.count);
  final int id;
  final Offset from;
  final Offset to;
  final int count;
}

class _GemFlight extends HookWidget {
  const _GemFlight({super.key, required this.spec});
  final _GemFlightSpec spec;

  @override
  Widget build(BuildContext context) {
    final c = useAnimationController(duration: const Duration(milliseconds: 950));
    useEffect(() {
      c.forward();
      return null;
    }, const []);
    final rnd = useMemoized(() => Random(spec.id));
    final offsets = useMemoized(() => [for (var i = 0; i < spec.count; i++) Offset((rnd.nextDouble() - 0.5) * 120, (rnd.nextDouble() - 0.5) * 60)]);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: c,
        builder: (context, _) {
          return Stack(
            children: [
              for (var i = 0; i < spec.count; i++)
                Builder(
                  builder: (context) {
                    final delay = i * 0.06;
                    final t = ((c.value - delay) / (1 - delay)).clamp(0.0, 1.0);
                    final e = Curves.easeInOutCubic.transform(t);
                    final start = spec.from + offsets[i];
                    final ctrl = Offset((start.dx + spec.to.dx) / 2, min(start.dy, spec.to.dy) - 140);
                    final p = _bezier(start, ctrl, spec.to, e);
                    final scale = 1.1 - 0.6 * e;
                    return Positioned(
                      left: p.dx - 14,
                      top: p.dy - 14,
                      child: Opacity(
                        opacity: (t < 0.95 ? 1.0 : 1 - (t - 0.95) / 0.05).clamp(0.0, 1.0),
                        child: Transform.scale(scale: scale, child: Image.asset('assets/images/gem.png', width: 28, height: 28)),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  static Offset _bezier(Offset a, Offset b, Offset c, double t) {
    final u = 1 - t;
    return a * (u * u) + b * (2 * u * t) + c * (t * t);
  }
}
