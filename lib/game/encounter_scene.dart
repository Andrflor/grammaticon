import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Colors, Curves;

/// Contract between the encounter screen and a Flame scene. The scene only
/// *represents* outcomes already resolved by the controller; it never decides
/// anything. Each activity provides its own scene (arena, forum).
abstract class EncounterScene extends FlameGame {
  EncounterScene({required this.reducedMotion});

  bool reducedMotion;

  /// The player's successful answer: an attack or an argument.
  void playerStrikes();

  /// The player's error: a counterattack or a rebuttal.
  void opponentStrikes();
  void victory();
  void defeat();
  void resetPoses();
}

/// A sprite that breathes, can swap its pose temporarily, flash and recoil.
class Fighter extends SpriteComponent {
  Fighter({required this.idle, required this.facingRight, super.priority})
    : super(sprite: idle, anchor: Anchor.bottomCenter);

  final Sprite idle;
  final bool facingRight;
  Vector2 _base = Vector2.zero();
  double _t = 0;
  int _poseToken = 0;
  bool _defeated = false;

  Vector2 get base => _base;

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
    angle = 0;
    position = _base.clone();
  }

  void flash({Color color = Colors.white}) {
    paint.colorFilter = ColorFilter.mode(
      color.withValues(alpha: 0.75),
      BlendMode.srcATop,
    );
    Future<void>.delayed(const Duration(milliseconds: 110), () {
      if (isMounted) paint.colorFilter = null;
    });
  }

  void recoil(Vector2 d) {
    add(
      MoveByEffect(
        d,
        EffectController(
          duration: 0.08,
          reverseDuration: 0.16,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  void defeated() {
    _defeated = true;
    add(OpacityEffect.to(0.35, EffectController(duration: 0.6)));
    add(
      MoveByEffect(
        Vector2(0, 30),
        EffectController(duration: 0.6, curve: Curves.easeIn),
      ),
    );
    add(
      RotateEffect.by(
        facingRight ? -0.35 : 0.35,
        EffectController(duration: 0.6),
      ),
    );
  }
}
