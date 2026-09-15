import '../../engine/design.dart';
import '../../engine/session.dart';

import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Cinzel inscription written directly on the painting: uppercase, widely
/// tracked, gilt gradient over a crisp dark shadow. Drawn in two layers:
/// transparent glyphs that only cast the shadows, then white glyphs masked by
/// the gradient. A foreground shader would be simpler, but Impeller on
/// OpenGL ES draws shader-painted text without anti-aliasing.
class Inscription extends StatelessWidget {
  final G skin;
  const Inscription(
    this.text, {
    required this.skin,
    super.key,
    required this.size,
    this.weight = 700,
    this.letterSpacing = 3.0,
  });
  final String text;
  final double size;
  final double weight;
  final double letterSpacing;

  static const double lineHeight = 1.15;

  /// Plain style with the same metrics, for measuring.
  static TextStyle style(
    G skin,
    double size, {
    double weight = 700,
    double letterSpacing = 3.0,
  }) => TextStyle(
    fontFamily: skin.headingFont,
    fontSize: size,
    color: skin.inscriptionGold[1],
    fontVariations: [FontVariation('wght', weight)],
    letterSpacing: letterSpacing,
    height: lineHeight,
  );

  @override
  Widget build(BuildContext context) {
    final base = style(
      skin,
      size,
      weight: weight,
      letterSpacing: letterSpacing,
    );
    return Stack(
      children: [
        Text(
          text,
          style: base.copyWith(
            color: Colors.transparent,
            shadows: skin.headingShadow,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: skin.inscriptionGold,
            stops: [0.2, 0.55, 0.92],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text(
            text,
            style: base.copyWith(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Width of [text] laid out on one line in [style].
double measureText(String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  final w = painter.width;
  painter.dispose();
  return w;
}

/// Corner radius of the regular buttons (12 on a 40 px button, as measured on
/// the mock-up's Certāmen button).
const double kButtonRadius = 12;

/// Height of the top-bar pills (Redī, gem counter): full stadiums of 46 px.
const double kPillHeight = 46;

/// Margins of the top HUD row, the same on every screen so that the gem
/// counter (always the rightmost pill) never moves from one screen to the next.
const double kHudSidePadding = 24;
const double kHudTopPadding = 8;

/// Gap between the cog and the gem counter.
const double kHudGap = 8;

/// Deep purple of the primary buttons and the pill of light purple around
/// them, sampled on the mock-up cards.

/// Fill of the top-bar pills and the gold of their text.

/// Painted marble background of a secondary screen, filling the whole body.
class ScreenBackground extends StatelessWidget {
  const ScreenBackground({
    super.key,
    required this.asset,
    required this.child,
    this.alignment = Alignment.center,
  });
  final String asset;
  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Image.asset(
        asset,
        fit: BoxFit.cover,
        alignment: alignment,
        filterQuality: FilterQuality.medium,
      ),
      child,
    ],
  );
}

/// Cream panel with a gold frame.
class RomanPanel extends StatelessWidget {
  final G skin;
  const RomanPanel({
    required this.skin,
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.borderWidth = 3,
    this.radius = 16,
    this.width,
    this.shadow = true,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final double radius;
  final double? width;
  final bool shadow;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? skin.marble,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? skin.gold, width: borderWidth),
      boxShadow: shadow
          ? [
              BoxShadow(
                color: skin.paint('40200A40'),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ]
          : null,
    ),
    // Transparent Material so list tiles and ink effects inside panels paint correctly.
    child: Material(type: MaterialType.transparency, child: child),
  );
}

enum RomanButtonStyle {
  primary,
  gold,
  ghost,
  success,
  danger,
  neutral,
  outline,
  locked,
  chosen,
}

/// Large, generous button (min height 56) with an optional key-number badge.
///
/// [circular] makes a round icon button (the "i" of the trial cards); an
/// empty [label] draws the icon alone.
class RomanButton extends StatelessWidget {
  final G skin;
  const RomanButton({
    required this.skin,
    super.key,
    required this.label,
    this.onPressed,
    this.style = RomanButtonStyle.primary,
    this.icon,
    this.leading,
    this.badge,
    this.expand = false,
    this.dense = false,
    this.circular = false,
    this.trailing,
    this.sound,
    this.cue = 'tap',
  });
  final String label;
  final VoidCallback? onPressed;

  /// Cue played on tap before [onPressed]; null for buttons whose action
  /// already has its own sound (answers, "Incipe!").
  final VoidCallback? sound;
  final String? cue;
  final RomanButtonStyle style;
  final IconData? icon;

  /// Custom leading widget (e.g. a gem image) shown before the label.
  final Widget? leading;
  final String? badge;
  final bool expand;
  final bool dense;
  final bool circular;
  final Widget? trailing;

  Color get _bg => switch (style) {
    RomanButtonStyle.primary => skin.paint('FF542C9D'),
    RomanButtonStyle.gold => skin.paint('FFE4B84F'),
    RomanButtonStyle.ghost => skin.paint('FF2B1444'),
    RomanButtonStyle.success => skin.green,
    RomanButtonStyle.danger => skin.red,
    RomanButtonStyle.neutral => skin.marbleDark,
    RomanButtonStyle.outline => Colors.white,
    RomanButtonStyle.locked => skin.paint('FF7E7670'),
    RomanButtonStyle.chosen => skin.goldWash,
  };
  Color get _fg => switch (style) {
    RomanButtonStyle.gold => skin.purpleDark,
    RomanButtonStyle.ghost => skin.paint('FFF7CC76'),
    RomanButtonStyle.neutral => skin.ink,
    RomanButtonStyle.outline => skin.purpleTitle,
    RomanButtonStyle.chosen => skin.goldDark,
    _ => Colors.white,
  };
  Color get _border => switch (style) {
    RomanButtonStyle.primary => skin.paint('FF7E4BCC'),
    RomanButtonStyle.gold => skin.paint('FFF6DC8C'),
    RomanButtonStyle.ghost => skin.gold,
    RomanButtonStyle.success => skin.paint('FF7CF0A0'),
    RomanButtonStyle.danger => skin.paint('FFFF8A94'),
    RomanButtonStyle.neutral => skin.goldDark,
    RomanButtonStyle.outline => skin.paint('FF4A1A9E'),
    RomanButtonStyle.locked => skin.paint('FFA39A92'),
    RomanButtonStyle.chosen => skin.paint('FFE6C77A'),
  };

  @override
  Widget build(BuildContext context) {
    // Locked buttons are a deliberate state, not a faded control.
    final disabled = onPressed == null && style != RomanButtonStyle.locked;
    // The ghost style is the top-bar pill: a 46 px stadium with a 3 px gold
    // rim and larger gold text, as on the mock-up's Redī.
    final pill = style == RomanButtonStyle.ghost;
    final locked = onPressed == null && style == RomanButtonStyle.locked;
    final onTap = onPressed == null
        ? (locked ? () => skin.onCue?.call('rejected') : null)
        : () {
            if (sound != null) {
              sound!();
            } else if (cue != null) {
              skin.onCue?.call(cue!);
            }
            onPressed!();
          };
    final iconSize = pill ? 24.0 : (dense ? 20.0 : 22.0);
    final hasLabel = label.isNotEmpty;
    final labelStyle = circular
        ? skin.body(dense ? 20 : 22, color: _fg, weight: 900, height: 1)
        : skin.body(pill ? 21 : (dense ? 15 : 18), color: _fg, weight: 700);
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (badge != null) ...[
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: skin.gold,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: skin.goldLight, width: 2),
            ),
            child: Text(
              badge!,
              style: skin.body(16, color: skin.purpleDark, weight: 800),
            ),
          ),
          SizedBox(width: 12),
        ],
        if (leading != null) ...[leading!, if (hasLabel) SizedBox(width: 8)],
        if (icon != null) ...[
          Icon(icon, color: _fg, size: iconSize),
          if (hasLabel) SizedBox(width: 8),
        ],
        if (hasLabel)
          Flexible(
            child: Text(label, textAlign: TextAlign.center, style: labelStyle),
          ),
        if (trailing != null) ...[SizedBox(width: 8), trailing!],
      ],
    );
    final radius = BorderRadius.circular(
      circular || pill ? 999 : kButtonRadius,
    );
    final side = pill ? kPillHeight : (dense ? 40.0 : 56.0);
    // Bevel: a light sheen at the top and a darker foot, so the buttons read
    // as raised like the mock-up's rather than as flat tiles. The overlay is
    // translucent, so the ink splash below stays visible. White buttons stay
    // plain white.
    final bevel = style == RomanButtonStyle.outline
        ? null
        : LinearGradient(
            colors: [
              skin.paint('30FFFFFF'),
              skin.paint('00FFFFFF'),
              skin.paint('24000000'),
            ],
            stops: [0, 0.45, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: skin.paint('4D200A40'),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: _bg,
          borderRadius: radius,
          // No clip: Impeller on OpenGL ES draws clips without anti-aliasing;
          // the InkWell shapes its own ink with the same radius.
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Container(
              constraints: circular
                  ? BoxConstraints.tightFor(width: side, height: side)
                  : BoxConstraints(
                      minHeight: side,
                      minWidth: hasLabel ? (dense ? 44 : 120) : side,
                    ),
              padding: circular
                  ? EdgeInsets.zero
                  : EdgeInsets.symmetric(
                      horizontal: pill ? 22 : (dense ? 16 : 18),
                      vertical: dense ? 6 : 12,
                    ),
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: bevel,
                border: Border.all(color: _border, width: pill ? 3 : 2.5),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

enum _HudSlot { left, center, right }

/// Three-slot HUD row: the side slots take their natural width and sit flush
/// with the edges, the centre slot is given the same margin on both sides (the
/// wider of the two sides), so it is centred on the screen rather than between
/// unequal neighbours. Every slot is centred on the 46 px pill band at the top
/// of the row, so the pills (and the gems) sit at the same height as in
/// [TopBar]; taller centre content simply extends below the band.
class HudRow extends StatelessWidget {
  const HudRow({
    super.key,
    this.left,
    this.center,
    this.right,
    this.height = HudRow.defaultHeight,
    this.maxCenterWidth = 640,
  });
  final Widget? left;
  final Widget? center;
  final Widget? right;
  final double height;
  final double maxCenterWidth;

  /// Tall enough for the 46 px pills and for the three-line opponent bar.
  static const double defaultHeight = 56;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: CustomMultiChildLayout(
      delegate: _HudLayout(maxCenterWidth),
      children: [
        if (left != null) LayoutId(id: _HudSlot.left, child: left!),
        if (center != null) LayoutId(id: _HudSlot.center, child: center!),
        if (right != null) LayoutId(id: _HudSlot.right, child: right!),
      ],
    ),
  );
}

class _HudLayout extends MultiChildLayoutDelegate {
  _HudLayout(this.maxCenterWidth);
  final double maxCenterWidth;
  static const double _gap = 12;

  /// Top of a child of height [h] centred on the pill band.
  static double _top(double h) => max(0, (kPillHeight - h) / 2);

  @override
  void performLayout(Size size) {
    var leftWidth = 0.0;
    var rightWidth = 0.0;
    if (hasChild(_HudSlot.left)) {
      final left = layoutChild(_HudSlot.left, BoxConstraints.loose(size));
      leftWidth = left.width;
      positionChild(_HudSlot.left, Offset(0, _top(left.height)));
    }
    if (hasChild(_HudSlot.right)) {
      final right = layoutChild(_HudSlot.right, BoxConstraints.loose(size));
      rightWidth = right.width;
      positionChild(
        _HudSlot.right,
        Offset(size.width - right.width, _top(right.height)),
      );
    }
    if (!hasChild(_HudSlot.center)) {
      return;
    }
    final side = max(leftWidth, rightWidth) + _gap;
    final width = (size.width - 2 * side).clamp(0.0, maxCenterWidth);
    final center = layoutChild(
      _HudSlot.center,
      BoxConstraints(minWidth: width, maxWidth: width, maxHeight: size.height),
    );
    positionChild(
      _HudSlot.center,
      Offset((size.width - center.width) / 2, _top(center.height)),
    );
  }

  @override
  bool shouldRelayout(covariant _HudLayout old) =>
      old.maxCenterWidth != maxCenterWidth;
}

/// Top bar with back button, title, an optional centre widget and gem counter.
///
/// Pills and title sit on one line at the top. The centre widget (the hero's
/// speech bubble) hangs lower, its top level with the middle of the pills,
/// and is centred on the screen when the title leaves room for it, as on the
/// mock-up; otherwise it follows the title. On narrow screens the title moves
/// under the pills instead of being cut to a few letters.
class TopBar extends StatelessWidget {
  final String backLabel, currencyAsset;
  final G skin;
  const TopBar({
    required this.skin,
    super.key,
    required this.title,
    required this.backLabel,
    required this.currencyAsset,
    this.gems,
    this.trailing = const [],
    this.onBack,
    this.onSettings,
    this.center,
    this.titleColor,
  });
  final String title;
  final int? gems;
  final List<Widget> trailing;
  final VoidCallback? onBack;

  /// Opens the Optiōnēs from the cog left of the gems; null hides the cog
  /// (on the Optiōnēs themselves).
  final VoidCallback? onSettings;

  /// Widget shown between the title and the gem counter (e.g. a speech bubble).
  final Widget? center;
  final Color? titleColor;

  /// Width given to [center]; the mock-up bubble is 376 px wide.
  static const double centerWidth = 376;

  /// Vertical offset of [center] below the top of the pills.
  static const double centerDrop = 22;
  static const double _centerHeight = 72;

  static const double _titleSize = 20;
  static const double _titleSpacing = 1.4;

  /// Uppercase gilt inscription, vertically centred on the 46 px pills.
  Widget get _title => SizedBox(
    height: kPillHeight,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Inscription(
        title.toUpperCase(),
        skin: skin,
        size: _titleSize,
        letterSpacing: _titleSpacing,
      ),
    ),
  );

  Widget _onPill(Widget w) => SizedBox(
    height: kPillHeight,
    child: Center(child: w),
  );

  /// Width of the Redī pill: padding, rim, icon, gap and label.
  double get _backWidth =>
      2 * 22 +
      2 * 3 +
      24 +
      8 +
      measureText(backLabel, skin.body(21, weight: 700));

  /// Width of the gem pill for [count] gems.
  double _gemsWidth(int count) =>
      2 * 16 +
      2 * 3 +
      34 +
      8 +
      measureText(
        '$count',
        Inscription.style(skin, 34 * 0.72, letterSpacing: 1.0),
      );

  /// Width of the cog and its gap before the gems.
  double get _settingsWidth => onSettings == null ? 0 : kPillHeight + kHudGap;

  @override
  Widget build(BuildContext context) {
    final back = RomanButton(
      skin: skin,
      label: backLabel,
      icon: Icons.arrow_back,
      style: RomanButtonStyle.ghost,
      dense: true,
      onPressed: onBack ?? () => Navigator.of(context).maybePop(),
    );
    final tail = [
      for (final w in trailing) ...[_onPill(w), SizedBox(width: 12)],
      if (onSettings != null) ...[
        RomanButton(
          skin: skin,
          label: '',
          icon: Icons.settings,
          style: RomanButtonStyle.ghost,
          dense: true,
          circular: true,
          onPressed: onSettings!,
        ),
        SizedBox(width: kHudGap),
      ],
      if (gems != null)
        CurrencyCounter(
          skin: skin,
          asset: currencyAsset,
          count: gems!,
          size: 34,
        ),
    ];
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          kHudSidePadding,
          kHudTopPadding,
          kHudSidePadding,
          0,
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            if (w < 700) {
              // Phone: pills on the first line, the title under them.
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [back, Spacer(), ...tail]),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Inscription(
                      title.toUpperCase(),
                      skin: skin,
                      size: 17,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              );
            }
            final row = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                back,
                SizedBox(width: 30),
                Expanded(child: _title),
                ...tail,
              ],
            );
            if (center == null) return row;
            // Centre the bubble on the screen, pushed right only if the title
            // would run under it, and kept clear of the gem pill.
            final titleEnd =
                _backWidth +
                30 +
                measureText(
                  title.toUpperCase(),
                  Inscription.style(
                    skin,
                    _titleSize,
                    letterSpacing: _titleSpacing,
                  ),
                );
            final regionEnd =
                (gems == null ? w : w - _gemsWidth(gems!)) -
                _settingsWidth -
                12;
            final minLeft = titleEnd + 16;
            final maxLeft = regionEnd - centerWidth - 16;
            var left = (w - centerWidth) / 2;
            if (left < minLeft) left = minLeft;
            if (left > maxLeft) left = maxLeft;
            if (left < minLeft) left = minLeft;
            return SizedBox(
              height: centerDrop + _centerHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  row,
                  Positioned(
                    left: left,
                    top: centerDrop,
                    width: centerWidth,
                    child: center!,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The hero speaking: a deep purple bubble framed in gold, 72 px tall, with
/// the figure standing in front of its left end, head above the rim.
class SpeechBubble extends StatelessWidget {
  final G skin;
  const SpeechBubble({
    required this.skin,
    super.key,
    required this.text,
    required this.heroAsset,
    this.maxWidth = 520,
  });
  final String text;
  final String heroAsset;
  final double maxWidth;

  /// How far the hero's head rises above the bubble; callers placing the
  /// bubble under another widget must leave this much room.
  static const double heroOverflow = 30;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: maxWidth,
      minWidth: maxWidth < 376 ? maxWidth : 376,
    ),
    child: Stack(
      clipBehavior: Clip.none,
      // Pass the width constraints on, so the bubble fills the slot the top
      // bar gives it instead of shrinking to its text.
      fit: StackFit.passthrough,
      children: [
        Container(
          constraints: BoxConstraints(minHeight: 72),
          padding: EdgeInsets.fromLTRB(112, 20, 40, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                skin.paint('FF3F2266'),
                skin.purpleDeep,
                skin.paint('FF33194F'),
              ],
              stops: [0, 0.4, 1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: skin.gold, width: 3),
            boxShadow: [
              BoxShadow(
                color: skin.paint('59200A40'),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            text,
            style: skin.body(20, color: skin.paint('FFF3ECD9'), weight: 700),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Positioned(
          left: -16,
          top: -heroOverflow,
          bottom: -10,
          child: Image.asset(
            heroAsset,
            fit: BoxFit.contain,
            alignment: Alignment.bottomLeft,
          ),
        ),
      ],
    ),
  );
}

/// Panel header: gold medallion with an icon, title and optional subtitle.
class PanelHeader extends StatelessWidget {
  final G skin;
  const PanelHeader({
    required this.skin,
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: skin.paint('FFE9C25A'),
            border: Border.all(color: skin.paint('FFF7DE8E'), width: 3),
            boxShadow: [
              BoxShadow(
                color: skin.paint('33000000'),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: skin.purpleDark, size: 26),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: skin.display(
                  22,
                  color: skin.purpleTitle,
                  letterSpacing: 1.0,
                ),
              ),
              if (subtitle case final st?)
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(st, style: skin.body(15, color: skin.inkSoft)),
                ),
            ],
          ),
        ),
        if (trailing != null) ...[SizedBox(width: 12), trailing!],
      ],
    ),
  );
}

/// Centres content in a readable column on wide screens.
class ContentColumn extends StatelessWidget {
  const ContentColumn({super.key, required this.child, this.maxWidth = 760});
  final Widget child;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

/// Stadium pill of the gem counter: dark purple lit from above, 3 px gold rim.
BoxDecoration _pillDecoration(G skin) => BoxDecoration(
  gradient: LinearGradient(
    colors: [
      skin.paint('FF3B2062'),
      skin.paint('FF2B1444'),
      skin.paint('FF26113D'),
    ],
    stops: [0, 0.35, 1],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
  borderRadius: BorderRadius.circular(999),
  border: Border.all(color: skin.gold, width: 3),
  boxShadow: [
    BoxShadow(
      color: skin.paint('59200A40'),
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
  ],
);

/// Counter digits: gilt Cinzel, scaled to the gem (34 px gem, 25 px digits).
double _counterSize(double size) => size * 0.72;

/// Top-bar pills (size >= 30) come out exactly [kPillHeight] tall, like the
/// ghost buttons beside them: 34 px gem + 2 × 3 px padding + 2 × 3 px rim.
EdgeInsets _pillPadding(double size) => EdgeInsets.symmetric(
  horizontal: size >= 30 ? 16 : 12,
  vertical: size >= 30 ? (kPillHeight - size - 6) / 2 : 4,
);

/// Animated counter that tweens from the previous value to the new one.
class GemTarget {
  static final GlobalKey key = GlobalKey(debugLabel: "gemCounter");
}

class CurrencyCounter extends StatefulWidget {
  const CurrencyCounter({
    super.key,
    required this.skin,
    required this.asset,
    required this.count,
    this.size = 28,
    this.isFlightTarget = false,
  });
  final G skin;
  final String asset;
  final int count;
  final double size;

  /// Only one counter on screen may be the target of flying gems.
  final bool isFlightTarget;
  @override
  State<CurrencyCounter> createState() => _CurrencyCounterState();
}

class _CurrencyCounterState extends State<CurrencyCounter> {
  late int _from = widget.count;
  @override
  void didUpdateWidget(covariant CurrencyCounter old) {
    super.didUpdateWidget(old);
    if (old.count != widget.count) _from = old.count;
  }

  @override
  Widget build(BuildContext context) => Container(
    key: widget.isFlightTarget ? GemTarget.key : null,
    padding: _pillPadding(widget.size),
    constraints: BoxConstraints(minHeight: widget.size >= 30 ? kPillHeight : 0),
    decoration: _pillDecoration(widget.skin),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(widget.asset, width: widget.size, height: widget.size),
        const SizedBox(width: 8),
        TweenAnimationBuilder<double>(
          key: ValueKey(widget.count),
          tween: Tween(begin: _from.toDouble(), end: widget.count.toDouble()),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => Inscription(
            '${value.round()}',
            skin: widget.skin,
            size: _counterSize(widget.size),
            letterSpacing: 1.0,
          ),
        ),
      ],
    ),
  );
}

/// Section heading as on the mock-up: a shallow gold chevron, the title as an
/// uppercase gilt inscription and a short gold rule. With [onTap] the heading
/// folds and unfolds its section.
class SectionTitle extends StatelessWidget {
  final G skin;
  const SectionTitle(
    this.text, {
    required this.skin,
    super.key,
    this.size = 24,
    this.open = true,
    this.onTap,
    this.topPadding = 16,
  });
  final String text;
  final double size;
  final bool open;
  final VoidCallback? onTap;
  final double topPadding;
  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, top: 3),
          child: _Chevron(skin: skin, open: open),
        ),
        const SizedBox(width: 18),
        // The title has priority over the rule, which only takes what is left.
        Flexible(
          flex: 3,
          child: Inscription(
            text.toUpperCase(),
            skin: skin,
            size: size,
            letterSpacing: 3.5,
          ),
        ),
        const SizedBox(width: 24),
        Flexible(
          child: Container(
            width: 150,
            height: 2,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: skin.paint('FFF7DE8C'),
              boxShadow: [
                BoxShadow(
                  color: skin.paint('CC200A40'),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(4, topPadding, 4, 10),
      child: onTap == null
          ? row
          : InkWell(
              onTap: () {
                onTap!();
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: row,
              ),
            ),
    );
  }
}

/// Wide, shallow chevron (21 × 10, 3 px round stroke) with a soft shadow,
/// pointing down when the section is open and right when folded.
class _Chevron extends StatelessWidget {
  final G skin;
  const _Chevron({required this.skin, required this.open});
  final bool open;
  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(22, 22),
    painter: _ChevronPainter(skin: skin, open: open),
  );
}

class _ChevronPainter extends CustomPainter {
  final G skin;
  const _ChevronPainter({required this.skin, required this.open});
  final bool open;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path();
    if (open) {
      path
        ..moveTo(1.5, h / 2 - 4)
        ..lineTo(w / 2, h / 2 + 5)
        ..lineTo(w - 1.5, h / 2 - 4);
    } else {
      path
        ..moveTo(w / 2 - 4, 2.5)
        ..lineTo(w / 2 + 5, h / 2)
        ..lineTo(w / 2 - 4, h - 2.5);
    }
    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = skin.paint('E624103F')
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = skin.inscriptionGold[1];
    canvas.drawPath(path.shift(const Offset(0, 2)), shadow);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter old) =>
      old.open != open || old.skin != skin;
}

class LevelBadge extends StatelessWidget {
  const LevelBadge({
    super.key,
    required this.session,
    required this.skin,
    required this.level,
    this.dense = false,
  });
  final GameSession session;
  final G skin;
  final int level;
  final bool dense;
  @override
  Widget build(BuildContext context) {
    final item = objects(session.mastery['levels'])[level];
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 11 : 13,
        vertical: dense ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Color(int.parse(item['color'], radix: 16)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: skin.paint('22000000'),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        session.text(item['displayName'] ?? item['name']),
        style: skin.body(dense ? 12 : 13, color: Colors.white, weight: 800),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
}

Future<bool> confirmAction(
  BuildContext context, {
  required G skin,
  required String title,
  required String body,
  required String yes,
  required String no,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title, style: skin.display(20, color: skin.purpleTitle)),
          content: Text(body, style: skin.body(16)),
          actions: [
            RomanButton(
              skin: skin,
              label: no,
              style: RomanButtonStyle.neutral,
              dense: true,
              onPressed: () => Navigator.pop(ctx, false),
            ),
            RomanButton(
              skin: skin,
              label: yes,
              style: RomanButtonStyle.gold,
              dense: true,
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ) ??
      false;
}

class StatChip extends StatelessWidget {
  final G skin;
  const StatChip(
    this.label, {
    required this.skin,
    super.key,
    this.icon,
    required this.color,
    required this.textColor,
  });
  final String label;
  final IconData? icon;
  final Color color;
  final Color textColor;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
        ],
        // Never overflows its parent: long labels are clipped with an ellipsis.
        Flexible(
          child: Text(
            label,
            style: skin.body(13, color: textColor, weight: 700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
