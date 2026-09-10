import '../engine/design.dart';
import '../app/theme.dart';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart' show Curves;

import 'encounter_scene.dart';

export 'encounter_scene.dart' show Fighter;

/// Flame scene of the arena (Amphitheatrum): background, hero, enemy, impacts
/// and particles. Implements the shared [EncounterScene] contract.
class StrikeScene extends EncounterScene {
  StrikeScene({required this.design, required this.view, required this.skin, super.reducedMotion = false});

  final GameDesign design;
  final Json view;
  final G skin;

  late final SpriteComponent _bg;
  late final Fighter hero;
  late final Fighter enemy;
  final Map<String, Sprite> _sprites = {};
  bool _ready = false;

  @override
  Color backgroundColor() => skin.paint('FF3D1A66');

  @override
  Future<void> onLoad() async {
    images.prefix = '';
    for (final role in ['background', 'hero', 'heroCorrect', 'heroWrong', 'heroVictory', 'heroDefeat', 'opponent', 'projectile', 'rewardEffect']) {
      _sprites[role] = Sprite(await images.load(design.asset(view[role] as String)));
    }
    _bg = SpriteComponent(sprite: _sprites['background'], anchor: Anchor.center, priority: 0);
    hero = Fighter(idle: _sprites['hero']!, facingRight: true, priority: 2);
    enemy = Fighter(idle: _sprites['opponent']!, facingRight: false, priority: 1);
    addAll([_bg, hero, enemy]);
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
    // Fighters stand on the sand line (~83 % of the height), facing each other.
    final fh = (s.y * 0.42).clamp(140.0, 520.0);
    hero.setBase(Vector2(s.x * 0.24, s.y * 0.86), fh);
    enemy.setBase(Vector2(s.x * 0.76, s.y * 0.86), fh);
  }

  // ----- choreography -----------------------------------------------------------------

  /// Hero lunges, strikes, enemy flashes and recoils with an impact burst.
  @override
  void playerStrikes() {
    if (!_ready) return;
    final dx = enemy.position.x - hero.position.x;
    hero.swapSprite(_sprites['heroCorrect']!, Duration(milliseconds: 520));
    if (reducedMotion) {
      enemy.flash();
      _impact(enemy.position - Vector2(0, enemy.size.y * 0.55), scaleMul: 0.8);
      return;
    }
    hero.add(MoveByEffect(Vector2(dx * 0.45, 0), EffectController(duration: 0.16, reverseDuration: 0.22, curve: Curves.easeOutCubic)));
    Future<void>.delayed(Duration(milliseconds: 150), () {
      if (!isMounted) return;
      enemy.flash();
      enemy.recoil(Vector2(28, 0));
      _impact(enemy.position - Vector2(0, enemy.size.y * 0.55));
      _sparks(enemy.position - Vector2(0, enemy.size.y * 0.5), skin.paint('FFFFE08A'), 18);
    });
  }

  /// Enemy lunges, hero flashes red and recoils.
  @override
  void opponentStrikes() {
    if (!_ready) return;
    final dx = hero.position.x - enemy.position.x;
    Future<void>.delayed(Duration(milliseconds: 60), () {
      if (!isMounted) return;
      hero.swapSprite(_sprites['heroWrong']!, Duration(milliseconds: 700));
    });
    if (reducedMotion) {
      hero.flash(color: skin.paint('FFE0333F'));
      return;
    }
    enemy.add(MoveByEffect(Vector2(dx * 0.4, 0), EffectController(duration: 0.18, reverseDuration: 0.24, curve: Curves.easeOutCubic)));
    Future<void>.delayed(Duration(milliseconds: 170), () {
      if (!isMounted) return;
      hero.flash(color: skin.paint('FFE0333F'));
      hero.recoil(Vector2(-26, 0));
      _sparks(hero.position - Vector2(0, hero.size.y * 0.5), skin.paint('FFE0333F'), 10);
    });
  }

  @override
  void victory() {
    if (!_ready) return;
    hero.swapSprite(_sprites['heroVictory']!, Duration(days: 1));
    enemy.defeated();
    if (!reducedMotion) {
      hero.add(MoveByEffect(Vector2(0, -30), EffectController(duration: 0.25, reverseDuration: 0.25, repeatCount: 3, curve: Curves.easeOut)));
      _confetti();
    }
  }

  @override
  void defeat() {
    if (!_ready) return;
    hero.swapSprite(_sprites['heroDefeat']!, Duration(days: 1));
    if (!reducedMotion) hero.add(MoveByEffect(Vector2(0, 26), EffectController(duration: 0.4, curve: Curves.easeIn)));
  }

  @override
  void resetPoses() {
    if (!_ready) return;
    hero.resetIdle();
    enemy.resetIdle();
  }

  void _impact(Vector2 at, {double scaleMul = 1}) {
    final s = hero.size.y * 0.5 * scaleMul;
    final c = SpriteComponent(sprite: _sprites['projectile'], size: Vector2.all(s * 0.4), anchor: Anchor.center, position: at, priority: 5);
    c.add(ScaleEffect.to(Vector2.all(2.6), EffectController(duration: 0.22, curve: Curves.easeOutBack)));
    c.add(OpacityEffect.fadeOut(EffectController(duration: 0.3, startDelay: 0.08)));
    c.add(RemoveEffect(delay: 0.45));
    add(c);
  }

  void _sparks(Vector2 at, Color color, int n) {
    final rnd = Random();
    add(ParticleSystemComponent(
      position: at,
      priority: 6,
      particle: Particle.generate(
        count: n,
        lifespan: 0.6,
        generator: (i) {
          final a = rnd.nextDouble() * pi * 2;
          final sp = 180 + rnd.nextDouble() * 220;
          return AcceleratedParticle(
            speed: Vector2(cos(a) * sp, sin(a) * sp - 120),
            acceleration: Vector2(0, 520),
            child: CircleParticle(radius: 3 + rnd.nextDouble() * 4, paint: Paint()..color = color),
          );
        },
      ),
    ));
  }

  void _confetti() {
    final rnd = Random();
    final colors = [skin.paint('FFE52EC2'), skin.paint('FF34C759'), skin.paint('FFFFE08A'), skin.paint('FF6FC3FF')];
    add(ParticleSystemComponent(
      position: Vector2(size.x / 2, size.y * 0.2),
      priority: 6,
      particle: Particle.generate(
        count: 60,
        lifespan: 2.2,
        generator: (i) {
          final a = -pi / 2 + (rnd.nextDouble() - 0.5) * pi;
          final sp = 200 + rnd.nextDouble() * 360;
          return AcceleratedParticle(
            speed: Vector2(cos(a) * sp, sin(a) * sp),
            acceleration: Vector2(0, 420),
            child: RotatingParticle(
              to: rnd.nextDouble() * pi * 4,
              child: ComponentParticle(component: RectangleComponent(size: Vector2(10, 14), paint: Paint()..color = colors[i % colors.length], anchor: Anchor.center)),
            ),
          );
        },
      ),
    ));
  }
}
