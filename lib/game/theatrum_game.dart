import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart' show Curves;

import 'encounter_scene.dart';

/// Flame scene of the Theatrum: the stage of a Roman theatre, the player as
/// an actor (histriō) on the left, the opposing actor on the right, the
/// audience in the cavea on both sides. A correct answer is a line delivered
/// with a gesture (a golden mask flies across the stage, the opponent
/// flinches, the audience applauds); an error is the opponent's rebuttal (a
/// dark wave, the player recoils, the audience hisses). Victory is a bow
/// under a rain of laurels; on defeat the opposing actor takes the bow.
/// Same engine as the arena and the Forum; different choreography.
class TheatrumGame extends EncounterScene {
  TheatrumGame({required this.opponentId, super.reducedMotion = false});

  final String opponentId;

  late final SpriteComponent _bg;
  late final Fighter histrio;
  late final Fighter opponent;
  final Map<String, Sprite> _sprites = {};
  bool _ready = false;

  @override
  Color backgroundColor() => const Color(0xFF2A1440);

  @override
  Future<void> onLoad() async {
    final names = ['theatrum_bg', 'histrio_idle', 'histrio_gesture', 'histrio_hurt', 'histrio_victory', 'histrio_defeat', 'actor_$opponentId', 'persona', 'laurel'];
    for (final n in names) {
      _sprites[n] = Sprite(await images.load('$n.png'));
    }
    _bg = SpriteComponent(sprite: _sprites['theatrum_bg'], anchor: Anchor.center, priority: 0);
    histrio = Fighter(idle: _sprites['histrio_idle']!, facingRight: true, priority: 2);
    opponent = Fighter(idle: _sprites['actor_$opponentId']!, facingRight: false, priority: 1);
    addAll([_bg, histrio, opponent]);
    _ready = true;
    _layout(size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_ready) _layout(size);
  }

  void _layout(Vector2 s) {
    final scale = max(s.x / 1920, s.y / 1080);
    _bg.size = Vector2(1920 * scale, 1080 * scale);
    _bg.position = s / 2;
    // Actors stand on the stage (~86 % of the height), facing each other.
    final fh = (s.y * 0.42).clamp(140.0, 520.0);
    histrio.setBase(Vector2(s.x * 0.24, s.y * 0.86), fh);
    opponent.setBase(Vector2(s.x * 0.76, s.y * 0.86), fh);
  }

  // ----- choreography -----------------------------------------------------------------

  /// The actor delivers the line: a step forward with a declaiming gesture, a
  /// golden mask arcs to the opponent, who flinches; the cavea applauds.
  @override
  void playerStrikes() {
    if (!_ready) return;
    histrio.swapSprite(_sprites['histrio_gesture']!, const Duration(milliseconds: 640));
    final from = histrio.position - Vector2(-histrio.size.x * 0.3, histrio.size.y * 0.62);
    final to = opponent.position - Vector2(0, opponent.size.y * 0.6);
    if (reducedMotion) {
      opponent.flash();
      _applause(intensity: 0.6);
      return;
    }
    histrio.add(MoveByEffect(Vector2(18, 0), EffectController(duration: 0.14, reverseDuration: 0.3, curve: Curves.easeOutCubic)));
    _mask(from, to);
    Future<void>.delayed(const Duration(milliseconds: 260), () {
      if (!isMounted) return;
      opponent.flash();
      opponent.recoil(Vector2(22, 0));
      _burst(to, const Color(0xFFFFE08A), 14);
      _applause(intensity: 1);
    });
  }

  /// The opponent's rebuttal: a dark wave reaches the actor, who recoils;
  /// the audience hisses.
  @override
  void opponentStrikes() {
    if (!_ready) return;
    final to = histrio.position - Vector2(0, histrio.size.y * 0.6);
    final from = opponent.position - Vector2(opponent.size.x * 0.3, opponent.size.y * 0.62);
    Future<void>.delayed(const Duration(milliseconds: 240), () {
      if (!isMounted) return;
      histrio.swapSprite(_sprites['histrio_hurt']!, const Duration(milliseconds: 700));
    });
    if (reducedMotion) {
      histrio.flash(color: const Color(0xFFE0333F));
      return;
    }
    opponent.add(MoveByEffect(Vector2(-18, 0), EffectController(duration: 0.14, reverseDuration: 0.3, curve: Curves.easeOutCubic)));
    _wave(from, to);
    Future<void>.delayed(const Duration(milliseconds: 260), () {
      if (!isMounted) return;
      histrio.flash(color: const Color(0xFFE0333F));
      histrio.recoil(Vector2(-20, 0));
      _hiss();
    });
  }

  /// A theatrical bow under applause and laurels; the opponent leaves the stage.
  @override
  void victory() {
    if (!_ready) return;
    histrio.swapSprite(_sprites['histrio_victory']!, const Duration(days: 1));
    opponent.defeated();
    if (!reducedMotion) {
      // The bow: a dip forward and back, twice.
      histrio.add(MoveByEffect(Vector2(10, 14), EffectController(duration: 0.35, reverseDuration: 0.35, repeatCount: 2, curve: Curves.easeInOut)));
      _laurels();
      _applause(intensity: 1.8);
    }
  }

  /// The opposing actor wins the exchange and takes the bow.
  @override
  void defeat() {
    if (!_ready) return;
    histrio.swapSprite(_sprites['histrio_defeat']!, const Duration(days: 1));
    if (!reducedMotion) {
      histrio.add(MoveByEffect(Vector2(0, 22), EffectController(duration: 0.4, curve: Curves.easeIn)));
      opponent.add(MoveByEffect(Vector2(-30, 0), EffectController(duration: 0.4, curve: Curves.easeOut)));
      opponent.add(MoveByEffect(Vector2(-8, 14), EffectController(duration: 0.35, reverseDuration: 0.35, startDelay: 0.45, curve: Curves.easeInOut)));
      opponent.flash(color: const Color(0xFFFFE08A));
      _applause(intensity: 0.8, forOpponent: true);
      _hiss(heavy: true);
    }
  }

  @override
  void resetPoses() {
    if (!_ready) return;
    histrio.resetIdle();
    opponent.resetIdle();
  }

  // ----- effects --------------------------------------------------------------------

  /// A golden mask arcs from the actor's hand to the opponent, spinning.
  void _mask(Vector2 from, Vector2 to) {
    final s = histrio.size.y * 0.24;
    final c = SpriteComponent(sprite: _sprites['persona'], size: Vector2.all(s), anchor: Anchor.center, position: from, priority: 5);
    final mid = Vector2((from.x + to.x) / 2, min(from.y, to.y) - histrio.size.y * 0.4);
    c.add(MoveAlongPathEffect(Path()..quadraticBezierTo(mid.x - from.x, mid.y - from.y, to.x - from.x, to.y - from.y), EffectController(duration: 0.26, curve: Curves.easeIn)));
    c.add(RotateEffect.by(pi, EffectController(duration: 0.26)));
    c.add(OpacityEffect.fadeOut(EffectController(duration: 0.1, startDelay: 0.24)));
    c.add(RemoveEffect(delay: 0.4));
    add(c);
  }

  /// The rebuttal: a widening dark-purple ring travelling to the actor.
  void _wave(Vector2 from, Vector2 to) {
    final ring = CircleComponent(radius: 10, position: from, anchor: Anchor.center, priority: 5, paint: Paint()..color = const Color(0xCC5A2A9C)..style = PaintingStyle.stroke..strokeWidth = 6);
    ring.add(MoveToEffect(to, EffectController(duration: 0.26, curve: Curves.easeIn)));
    ring.add(ScaleEffect.to(Vector2.all(3.2), EffectController(duration: 0.26)));
    ring.add(OpacityEffect.fadeOut(EffectController(duration: 0.12, startDelay: 0.22)));
    ring.add(RemoveEffect(delay: 0.4));
    add(ring);
  }

  void _burst(Vector2 at, Color color, int n) {
    final rnd = Random();
    add(ParticleSystemComponent(
      position: at,
      priority: 6,
      particle: Particle.generate(
        count: n,
        lifespan: 0.5,
        generator: (i) {
          final a = rnd.nextDouble() * pi * 2;
          final sp = 120 + rnd.nextDouble() * 160;
          return AcceleratedParticle(
            speed: Vector2(cos(a) * sp, sin(a) * sp - 80),
            acceleration: Vector2(0, 380),
            child: CircleParticle(radius: 2.5 + rnd.nextDouble() * 3, paint: Paint()..color = color),
          );
        },
      ),
    ));
  }

  /// Applause: bright sparks rising from the cavea on both sides of the stage.
  void _applause({double intensity = 1, bool forOpponent = false}) {
    final rnd = Random();
    final n = (10 * intensity).round();
    for (final side in [0.14, 0.86]) {
      add(ParticleSystemComponent(
        position: Vector2(size.x * side, size.y * 0.62),
        priority: 6,
        particle: Particle.generate(
          count: n,
          lifespan: 0.7,
          generator: (i) {
            final x = (rnd.nextDouble() - 0.5) * size.x * 0.24;
            final sp = 160 + rnd.nextDouble() * 200;
            return AcceleratedParticle(
              position: Vector2(x, rnd.nextDouble() * 20),
              speed: Vector2((rnd.nextDouble() - 0.5) * 60, -sp),
              acceleration: Vector2(0, 260),
              child: CircleParticle(radius: 3 + rnd.nextDouble() * 3, paint: Paint()..color = i.isEven ? const Color(0xFFFFE08A) : (forOpponent ? const Color(0xFFD0B0FF) : const Color(0xFFFFFFFF))),
            );
          },
        ),
      ));
    }
  }

  /// Hissing: dull particles sinking from the cavea.
  void _hiss({bool heavy = false}) {
    final rnd = Random();
    for (final side in [0.14, 0.86]) {
      add(ParticleSystemComponent(
        position: Vector2(size.x * side, size.y * 0.6),
        priority: 6,
        particle: Particle.generate(
          count: heavy ? 16 : 7,
          lifespan: 0.8,
          generator: (i) {
            final x = (rnd.nextDouble() - 0.5) * size.x * 0.24;
            return AcceleratedParticle(
              position: Vector2(x, 0),
              speed: Vector2((rnd.nextDouble() - 0.5) * 40, 20 + rnd.nextDouble() * 40),
              acceleration: Vector2(0, 60),
              child: CircleParticle(radius: 3 + rnd.nextDouble() * 4, paint: Paint()..color = const Color(0x99504060)),
            );
          },
        ),
      ));
    }
  }

  /// Victory: laurel leaves rain down on the stage.
  void _laurels() {
    final rnd = Random();
    final leaf = _sprites['laurel']!;
    add(ParticleSystemComponent(
      position: Vector2(size.x / 2, size.y * 0.15),
      priority: 6,
      particle: Particle.generate(
        count: 40,
        lifespan: 2.4,
        generator: (i) {
          final a = -pi / 2 + (rnd.nextDouble() - 0.5) * pi;
          final sp = 160 + rnd.nextDouble() * 300;
          return AcceleratedParticle(
            speed: Vector2(cos(a) * sp, sin(a) * sp),
            acceleration: Vector2(0, 300),
            child: RotatingParticle(to: rnd.nextDouble() * pi * 4, child: SpriteParticle(sprite: leaf, size: Vector2.all(18 + rnd.nextDouble() * 10))),
          );
        },
      ),
    ));
  }
}
