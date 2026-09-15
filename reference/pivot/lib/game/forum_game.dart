import '../engine/design.dart';
import '../app/theme.dart';

import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart' show Curves;

import 'encounter_scene.dart';

/// Flame scene of the Forum: basilica background, the player as orator, the
/// opposing speaker and the audience. A correct answer is an argument
/// delivered with a gesture (a scroll flies to the opponent, who recoils under
/// applause); an error is the opponent's rebuttal (the player recoils under a
/// murmur). Same engine as the arena; different choreography.
class ProjectileScene extends EncounterScene {
  ProjectileScene({
    required this.design,
    required this.view,
    required this.skin,
    super.reducedMotion = false,
  });

  final GameDesign design;
  final Json view;
  final G skin;

  late final SpriteComponent _bg;
  late final Fighter orator;
  late final Fighter opponent;
  final Map<String, Sprite> _sprites = {};
  bool _ready = false;

  @override
  Color backgroundColor() => skin.paint('FF2E1A4C');

  @override
  Future<void> onLoad() async {
    images.prefix = '';
    for (final role in [
      'background',
      'hero',
      'heroCorrect',
      'heroWrong',
      'heroVictory',
      'heroDefeat',
      'opponent',
      'projectile',
      'rewardEffect',
    ]) {
      _sprites[role] = Sprite(
        await images.load(design.asset(view[role] as String)),
      );
    }
    _bg = SpriteComponent(
      sprite: _sprites['background'],
      anchor: Anchor.center,
      priority: 0,
    );
    orator = Fighter(idle: _sprites['hero']!, facingRight: true, priority: 2);
    opponent = Fighter(
      idle: _sprites['opponent']!,
      facingRight: false,
      priority: 1,
    );
    addAll([_bg, orator, opponent]);
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
    // Speakers stand on the rostra (~86 % of the height), facing each other.
    final fh = (s.y * 0.42).clamp(140.0, 520.0);
    orator.setBase(Vector2(s.x * 0.24, s.y * 0.86), fh);
    opponent.setBase(Vector2(s.x * 0.76, s.y * 0.86), fh);
  }

  // ----- choreography -----------------------------------------------------------------

  /// The orator steps forward with an expressive gesture; a scroll of
  /// argument flies to the opponent, who flinches; the audience applauds.
  @override
  void playerStrikes() {
    if (!_ready) return;
    orator.swapSprite(_sprites['heroCorrect']!, Duration(milliseconds: 620));
    final from =
        orator.position - Vector2(-orator.size.x * 0.3, orator.size.y * 0.62);
    final to = opponent.position - Vector2(0, opponent.size.y * 0.6);
    if (reducedMotion) {
      opponent.flash();
      _applause(intensity: 0.6);
      return;
    }
    orator.add(
      MoveByEffect(
        Vector2(18, 0),
        EffectController(
          duration: 0.14,
          reverseDuration: 0.3,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    _scroll(from, to);
    Future<void>.delayed(Duration(milliseconds: 260), () {
      if (!isMounted) return;
      opponent.flash();
      opponent.recoil(Vector2(22, 0));
      _burst(to, skin.paint('FFFFE08A'), 14);
      _applause(intensity: 1);
    });
  }

  /// The opponent replies: a red rebuttal wave reaches the orator, who
  /// flinches; the audience murmurs.
  @override
  void opponentStrikes() {
    if (!_ready) return;
    final to = orator.position - Vector2(0, orator.size.y * 0.6);
    final from =
        opponent.position -
        Vector2(opponent.size.x * 0.3, opponent.size.y * 0.62);
    Future<void>.delayed(Duration(milliseconds: 240), () {
      if (!isMounted) return;
      orator.swapSprite(_sprites['heroWrong']!, Duration(milliseconds: 700));
    });
    if (reducedMotion) {
      orator.flash(color: skin.paint('FFE0333F'));
      return;
    }
    opponent.add(
      MoveByEffect(
        Vector2(-18, 0),
        EffectController(
          duration: 0.14,
          reverseDuration: 0.3,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    _wave(from, to);
    Future<void>.delayed(Duration(milliseconds: 260), () {
      if (!isMounted) return;
      orator.flash(color: skin.paint('FFE0333F'));
      orator.recoil(Vector2(-20, 0));
      _murmur();
    });
  }

  @override
  void victory() {
    if (!_ready) return;
    orator.swapSprite(_sprites['heroVictory']!, Duration(days: 1));
    opponent.defeated();
    if (!reducedMotion) {
      orator.add(
        MoveByEffect(
          Vector2(0, -24),
          EffectController(
            duration: 0.25,
            reverseDuration: 0.25,
            repeatCount: 3,
            curve: Curves.easeOut,
          ),
        ),
      );
      _laurels();
      _applause(intensity: 1.6);
    }
  }

  @override
  void defeat() {
    if (!_ready) return;
    orator.swapSprite(_sprites['heroDefeat']!, Duration(days: 1));
    if (!reducedMotion) {
      orator.add(
        MoveByEffect(
          Vector2(0, 22),
          EffectController(duration: 0.4, curve: Curves.easeIn),
        ),
      );
      _murmur(heavy: true);
    }
  }

  @override
  void resetPoses() {
    if (!_ready) return;
    orator.resetIdle();
    opponent.resetIdle();
  }

  // ----- effects --------------------------------------------------------------------

  /// A scroll of argument arcs from the orator's hand to the opponent.
  void _scroll(Vector2 from, Vector2 to) {
    final s = orator.size.y * 0.22;
    final c = SpriteComponent(
      sprite: _sprites['projectile'],
      size: Vector2.all(s),
      anchor: Anchor.center,
      position: from,
      priority: 5,
    );
    final mid = Vector2(
      (from.x + to.x) / 2,
      min(from.y, to.y) - orator.size.y * 0.35,
    );
    c.add(
      MoveAlongPathEffect(
        Path()..quadraticBezierTo(
          mid.x - from.x,
          mid.y - from.y,
          to.x - from.x,
          to.y - from.y,
        ),
        EffectController(duration: 0.26, curve: Curves.easeIn),
      ),
    );
    c.add(RotateEffect.by(pi * 1.5, EffectController(duration: 0.26)));
    c.add(
      OpacityEffect.fadeOut(EffectController(duration: 0.1, startDelay: 0.24)),
    );
    c.add(RemoveEffect(delay: 0.4));
    add(c);
  }

  /// A red rebuttal wave: a widening ring that travels toward the orator.
  void _wave(Vector2 from, Vector2 to) {
    final ring = CircleComponent(
      radius: 10,
      position: from,
      anchor: Anchor.center,
      priority: 5,
      paint: Paint()
        ..color = skin.paint('CCE0333F')
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    ring.add(
      MoveToEffect(to, EffectController(duration: 0.26, curve: Curves.easeIn)),
    );
    ring.add(
      ScaleEffect.to(Vector2.all(3.2), EffectController(duration: 0.26)),
    );
    ring.add(
      OpacityEffect.fadeOut(EffectController(duration: 0.12, startDelay: 0.22)),
    );
    ring.add(RemoveEffect(delay: 0.4));
    add(ring);
  }

  void _burst(Vector2 at, Color color, int n) {
    final rnd = Random();
    add(
      ParticleSystemComponent(
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
              child: CircleParticle(
                radius: 2.5 + rnd.nextDouble() * 3,
                paint: Paint()..color = color,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Applause: bright sparks rising briefly from the audience line.
  void _applause({double intensity = 1}) {
    final rnd = Random();
    final n = (16 * intensity).round();
    add(
      ParticleSystemComponent(
        position: Vector2(size.x / 2, size.y * 0.62),
        priority: 6,
        particle: Particle.generate(
          count: n,
          lifespan: 0.7,
          generator: (i) {
            final x = (rnd.nextDouble() - 0.5) * size.x * 0.9;
            final sp = 160 + rnd.nextDouble() * 200;
            return AcceleratedParticle(
              position: Vector2(x, rnd.nextDouble() * 20),
              speed: Vector2((rnd.nextDouble() - 0.5) * 60, -sp),
              acceleration: Vector2(0, 260),
              child: CircleParticle(
                radius: 3 + rnd.nextDouble() * 3,
                paint: Paint()
                  ..color = i.isEven
                      ? skin.paint('FFFFE08A')
                      : skin.paint('FFFFFFFF'),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Murmur: dull particles sinking from the audience line.
  void _murmur({bool heavy = false}) {
    final rnd = Random();
    add(
      ParticleSystemComponent(
        position: Vector2(size.x / 2, size.y * 0.6),
        priority: 6,
        particle: Particle.generate(
          count: heavy ? 26 : 12,
          lifespan: 0.8,
          generator: (i) {
            final x = (rnd.nextDouble() - 0.5) * size.x * 0.9;
            return AcceleratedParticle(
              position: Vector2(x, 0),
              speed: Vector2(
                (rnd.nextDouble() - 0.5) * 40,
                20 + rnd.nextDouble() * 40,
              ),
              acceleration: Vector2(0, 60),
              child: CircleParticle(
                radius: 3 + rnd.nextDouble() * 4,
                paint: Paint()..color = skin.paint('99605070'),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Victory: laurel leaves rain down.
  void _laurels() {
    final rnd = Random();
    final leaf = _sprites['rewardEffect']!;
    add(
      ParticleSystemComponent(
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
              child: RotatingParticle(
                to: rnd.nextDouble() * pi * 4,
                child: SpriteParticle(
                  sprite: leaf,
                  size: Vector2.all(18 + rnd.nextDouble() * 10),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
