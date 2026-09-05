import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart' show Colors, Curves;

/// Flame scene of the arena: background, hero, enemy, impacts and particles.
/// The scene only *represents* outcomes already resolved by the battle
/// controller; it never decides anything.
class ArenaGame extends FlameGame {
  ArenaGame({required this.enemyId, this.reducedMotion = false});

  final String enemyId;
  bool reducedMotion;

  late final SpriteComponent _bg;
  late final Fighter hero;
  late final Fighter enemy;
  final Map<String, Sprite> _sprites = {};
  bool _ready = false;

  @override
  Color backgroundColor() => const Color(0xFF3D1A66);

  @override
  Future<void> onLoad() async {
    final names = ['arena_bg', 'hero_idle', 'hero_attack', 'hero_hurt', 'hero_victory', 'hero_defeat', 'enemy_$enemyId', 'impact', 'gem'];
    for (final n in names) {
      _sprites[n] = Sprite(await images.load('$n.png'));
    }
    _bg = SpriteComponent(sprite: _sprites['arena_bg'], anchor: Anchor.center, priority: 0);
    hero = Fighter(idle: _sprites['hero_idle']!, facingRight: true, priority: 2);
    enemy = Fighter(idle: _sprites['enemy_$enemyId']!, facingRight: false, priority: 1);
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
  void heroAttack() {
    if (!_ready) return;
    final dx = enemy.position.x - hero.position.x;
    hero.swapSprite(_sprites['hero_attack']!, const Duration(milliseconds: 520));
    if (reducedMotion) {
      enemy.flash();
      _impact(enemy.position - Vector2(0, enemy.size.y * 0.55), scaleMul: 0.8);
      return;
    }
    hero.add(MoveByEffect(Vector2(dx * 0.45, 0), EffectController(duration: 0.16, reverseDuration: 0.22, curve: Curves.easeOutCubic)));
    Future<void>.delayed(const Duration(milliseconds: 150), () {
      if (!isMounted) return;
      enemy.flash();
      enemy.recoil(Vector2(28, 0));
      _impact(enemy.position - Vector2(0, enemy.size.y * 0.55));
      _sparks(enemy.position - Vector2(0, enemy.size.y * 0.5), const Color(0xFFFFE08A), 18);
    });
  }

  /// Enemy lunges, hero flashes red and recoils.
  void enemyAttack() {
    if (!_ready) return;
    final dx = hero.position.x - enemy.position.x;
    Future<void>.delayed(const Duration(milliseconds: 60), () {
      if (!isMounted) return;
      hero.swapSprite(_sprites['hero_hurt']!, const Duration(milliseconds: 700));
    });
    if (reducedMotion) {
      hero.flash(color: const Color(0xFFE0333F));
      return;
    }
    enemy.add(MoveByEffect(Vector2(dx * 0.4, 0), EffectController(duration: 0.18, reverseDuration: 0.24, curve: Curves.easeOutCubic)));
    Future<void>.delayed(const Duration(milliseconds: 170), () {
      if (!isMounted) return;
      hero.flash(color: const Color(0xFFE0333F));
      hero.recoil(Vector2(-26, 0));
      _sparks(hero.position - Vector2(0, hero.size.y * 0.5), const Color(0xFFE0333F), 10);
    });
  }

  void victory() {
    if (!_ready) return;
    hero.swapSprite(_sprites['hero_victory']!, const Duration(days: 1));
    enemy.defeated();
    if (!reducedMotion) {
      hero.add(MoveByEffect(Vector2(0, -30), EffectController(duration: 0.25, reverseDuration: 0.25, repeatCount: 3, curve: Curves.easeOut)));
      _confetti();
    }
  }

  void defeat() {
    if (!_ready) return;
    hero.swapSprite(_sprites['hero_defeat']!, const Duration(days: 1));
    if (!reducedMotion) hero.add(MoveByEffect(Vector2(0, 26), EffectController(duration: 0.4, curve: Curves.easeIn)));
  }

  void resetPoses() {
    if (!_ready) return;
    hero.resetIdle();
    enemy.resetIdle();
  }

  void _impact(Vector2 at, {double scaleMul = 1}) {
    final s = hero.size.y * 0.5 * scaleMul;
    final c = SpriteComponent(sprite: _sprites['impact'], size: Vector2.all(s * 0.4), anchor: Anchor.center, position: at, priority: 5);
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
    final colors = [const Color(0xFFE52EC2), const Color(0xFF34C759), const Color(0xFFFFE08A), const Color(0xFF6FC3FF)];
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

/// A sprite that breathes, can swap its pose temporarily, flash and recoil.
class Fighter extends SpriteComponent {
  Fighter({required this.idle, required this.facingRight, super.priority}) : super(sprite: idle, anchor: Anchor.bottomCenter);

  final Sprite idle;
  final bool facingRight;
  Vector2 _base = Vector2.zero();
  double _t = 0;
  int _poseToken = 0;
  bool _defeated = false;

  void setBase(Vector2 base, double height) {
    _base = base.clone();
    position = base.clone();
    final ratio = idle.srcSize.x / idle.srcSize.y;
    size = Vector2(height * ratio, height);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_defeated) return;
    _t += dt;
    // Breathing: gentle vertical scale around the feet.
    final k = 1 + sin(_t * 2.2) * 0.012;
    scale = Vector2(1, k);
  }

  void swapSprite(Sprite s, Duration d) {
    final token = ++_poseToken;
    sprite = s;
    if (d.inDays > 0) return;
    Future<void>.delayed(d, () {
      if (_poseToken == token && isMounted) sprite = idle;
    });
  }

  void resetIdle() {
    _poseToken++;
    sprite = idle;
    _defeated = false;
    paint.colorFilter = null;
    opacity = 1;
    position = _base.clone();
  }

  void flash({Color color = Colors.white}) {
    paint.colorFilter = ColorFilter.mode(color.withValues(alpha: 0.75), BlendMode.srcATop);
    Future<void>.delayed(const Duration(milliseconds: 110), () {
      if (isMounted) paint.colorFilter = null;
    });
  }

  void recoil(Vector2 d) {
    add(MoveByEffect(d, EffectController(duration: 0.08, reverseDuration: 0.16, curve: Curves.easeOut)));
  }

  void defeated() {
    _defeated = true;
    add(OpacityEffect.to(0.35, EffectController(duration: 0.6)));
    add(MoveByEffect(Vector2(0, 30), EffectController(duration: 0.6, curve: Curves.easeIn)));
    add(RotateEffect.by(facingRight ? -0.35 : 0.35, EffectController(duration: 0.6)));
  }
}
