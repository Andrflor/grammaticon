import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../audio/audio_service.dart';
import '../../pedagogy/mastery.dart';

/// Gold of the headings written directly on the painted background.
const Color kHeadingGold = Color(0xFFF6D77A);

/// Dark purple shadow that keeps the gold headings legible over the painted
/// backgrounds (banners, columns) without boxing them in.
const List<Shadow> kHeadingShadow = [
  Shadow(color: Color(0xFF24103F), offset: Offset(0, 2), blurRadius: 2),
  Shadow(color: Color(0xFF200A40), blurRadius: 5),
  Shadow(color: Color(0xCC200A40), blurRadius: 14),
];

/// Gilt of the inscriptions, sampled top to bottom on the mock-up headings: a
/// pale highlight where the light falls, warming to gold at the foot.
const List<Color> kInscriptionGold = [Color(0xFFFFF3B0), Color(0xFFF8DE84), Color(0xFFE8BF58)];

/// Cinzel inscription written directly on the painting: uppercase, widely
/// tracked, gilt gradient over a crisp dark shadow. Drawn in two layers:
/// transparent glyphs that only cast the shadows, then white glyphs masked by
/// the gradient. A foreground shader would be simpler, but Impeller on
/// OpenGL ES draws shader-painted text without anti-aliasing.
class Inscription extends StatelessWidget {
  const Inscription(this.text, {super.key, required this.size, this.weight = 700, this.letterSpacing = 3.0});
  final String text;
  final double size;
  final double weight;
  final double letterSpacing;

  static const double lineHeight = 1.15;

  /// Plain style with the same metrics, for measuring.
  static TextStyle style(double size, {double weight = 700, double letterSpacing = 3.0}) =>
      TextStyle(fontFamily: 'Cinzel', fontSize: size, color: kInscriptionGold[1], fontVariations: [FontVariation('wght', weight)], letterSpacing: letterSpacing, height: lineHeight);

  @override
  Widget build(BuildContext context) {
    final base = style(size, weight: weight, letterSpacing: letterSpacing);
    return Stack(
      children: [
        Text(
          text,
          style: base.copyWith(color: Colors.transparent, shadows: kHeadingShadow),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(colors: kInscriptionGold, stops: [0.2, 0.55, 0.92], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(bounds),
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

/// Deep purple of the primary buttons and the pill of light purple around
/// them, sampled on the mock-up cards.
const Color kButtonPurple = Color(0xFF542C9D);
const Color kButtonPurpleEdge = Color(0xFF7E4BCC);

/// Fill of the top-bar pills and the gold of their text.
const Color kPillPurple = Color(0xFF2B1444);
const Color kPillGold = Color(0xFFF7CC76);

/// Painted marble background of a secondary screen, filling the whole body.
class ScreenBackground extends StatelessWidget {
  const ScreenBackground({super.key, required this.asset, required this.child, this.alignment = Alignment.center});
  final String asset;
  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Image.asset(asset, fit: BoxFit.cover, alignment: alignment, filterQuality: FilterQuality.medium),
      child,
    ],
  );
}

/// Cream panel with a gold frame.
class RomanPanel extends StatelessWidget {
  const RomanPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = G.marble,
    this.borderColor = G.gold,
    this.borderWidth = 3,
    this.radius = 16,
    this.width,
    this.shadow = true,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double radius;
  final double? width;
  final bool shadow;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: shadow ? const [BoxShadow(color: Color(0x40200A40), blurRadius: 14, offset: Offset(0, 6))] : null,
    ),
    // Transparent Material so list tiles and ink effects inside panels paint correctly.
    child: Material(type: MaterialType.transparency, child: child),
  );
}

enum RomanButtonStyle { primary, gold, ghost, success, danger, neutral, outline, locked, chosen }

/// Large, generous button (min height 56) with an optional key-number badge.
///
/// [circular] makes a round icon button (the "i" of the trial cards); an
/// empty [label] draws the icon alone.
class RomanButton extends StatelessWidget {
  const RomanButton({
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
    this.sound = Sfx.tactus,
  });
  final String label;
  final VoidCallback? onPressed;

  /// Cue played on tap before [onPressed]; null for buttons whose action
  /// already has its own sound (answers, "Incipe!").
  final Sfx? sound;
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
    RomanButtonStyle.primary => kButtonPurple,
    RomanButtonStyle.gold => const Color(0xFFE4B84F),
    RomanButtonStyle.ghost => kPillPurple,
    RomanButtonStyle.success => G.green,
    RomanButtonStyle.danger => G.red,
    RomanButtonStyle.neutral => G.marbleDark,
    RomanButtonStyle.outline => Colors.white,
    RomanButtonStyle.locked => const Color(0xFF7E7670),
    RomanButtonStyle.chosen => G.goldWash,
  };
  Color get _fg => switch (style) {
    RomanButtonStyle.gold => G.purpleDark,
    RomanButtonStyle.ghost => kPillGold,
    RomanButtonStyle.neutral => G.ink,
    RomanButtonStyle.outline => G.purpleTitle,
    RomanButtonStyle.chosen => G.goldDark,
    _ => Colors.white,
  };
  Color get _border => switch (style) {
    RomanButtonStyle.primary => kButtonPurpleEdge,
    RomanButtonStyle.gold => const Color(0xFFF6DC8C),
    RomanButtonStyle.ghost => G.gold,
    RomanButtonStyle.success => const Color(0xFF7CF0A0),
    RomanButtonStyle.danger => const Color(0xFFFF8A94),
    RomanButtonStyle.neutral => G.goldDark,
    RomanButtonStyle.outline => const Color(0xFF4A1A9E),
    RomanButtonStyle.locked => const Color(0xFFA39A92),
    RomanButtonStyle.chosen => const Color(0xFFE6C77A),
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
        ? (locked ? () => AudioService.current?.play(Sfx.vetitum) : null)
        : () {
            if (sound != null) AudioService.current?.play(sound!);
            onPressed!();
          };
    final iconSize = pill ? 24.0 : (dense ? 20.0 : 22.0);
    final hasLabel = label.isNotEmpty;
    final labelStyle = circular ? G.body(dense ? 20 : 22, color: _fg, weight: 900, height: 1) : G.body(pill ? 21 : (dense ? 15 : 18), color: _fg, weight: 700);
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
              color: G.gold,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: G.goldLight, width: 2),
            ),
            child: Text(badge!, style: G.body(16, color: G.purpleDark, weight: 800)),
          ),
          const SizedBox(width: 12),
        ],
        if (leading != null) ...[leading!, if (hasLabel) const SizedBox(width: 8)],
        if (icon != null) ...[Icon(icon, color: _fg, size: iconSize), if (hasLabel) const SizedBox(width: 8)],
        if (hasLabel)
          Flexible(
            child: Text(label, textAlign: TextAlign.center, style: labelStyle),
          ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
    final radius = BorderRadius.circular(circular || pill ? 999 : kButtonRadius);
    final side = pill ? kPillHeight : (dense ? 40.0 : 56.0);
    // Bevel: a light sheen at the top and a darker foot, so the buttons read
    // as raised like the mock-up's rather than as flat tiles. The overlay is
    // translucent, so the ink splash below stays visible. White buttons stay
    // plain white.
    final bevel = style == RomanButtonStyle.outline
        ? null
        : const LinearGradient(colors: [Color(0x30FFFFFF), Color(0x00FFFFFF), Color(0x24000000)], stops: [0, 0.45, 1], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [BoxShadow(color: Color(0x4D200A40), blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Material(
          color: _bg,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Container(
              constraints: circular ? BoxConstraints.tightFor(width: side, height: side) : BoxConstraints(minHeight: side, minWidth: hasLabel ? (dense ? 44 : 120) : side),
              padding: circular ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: pill ? 22 : (dense ? 16 : 18), vertical: dense ? 6 : 12),
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

/// Anchor used by flying-gem animations.
class GemTarget {
  static final GlobalKey key = GlobalKey(debugLabel: 'gemCounter');
}

/// Stadium pill of the gem counter: dark purple lit from above, 3 px gold rim.
BoxDecoration _pillDecoration() => BoxDecoration(
  gradient: const LinearGradient(colors: [Color(0xFF3B2062), kPillPurple, Color(0xFF26113D)], stops: [0, 0.35, 1], begin: Alignment.topCenter, end: Alignment.bottomCenter),
  borderRadius: BorderRadius.circular(999),
  border: Border.all(color: G.gold, width: 3),
  boxShadow: const [BoxShadow(color: Color(0x59200A40), blurRadius: 8, offset: Offset(0, 3))],
);

/// Counter digits: gilt Cinzel, scaled to the gem (34 px gem, 25 px digits).
double _counterSize(double size) => size * 0.72;

/// Top-bar pills (size >= 30) come out exactly [kPillHeight] tall, like the
/// ghost buttons beside them: 34 px gem + 2 × 3 px padding + 2 × 3 px rim.
EdgeInsets _pillPadding(double size) => EdgeInsets.symmetric(horizontal: size >= 30 ? 16 : 12, vertical: size >= 30 ? (kPillHeight - size - 6) / 2 : 4);

/// Gem icon with an animated counter.
class GemCounter extends StatelessWidget {
  const GemCounter({super.key, required this.count, this.size = 28, this.useTargetKey = false});
  final int count;
  final double size;
  final bool useTargetKey;

  @override
  Widget build(BuildContext context) => Container(
    key: useTargetKey ? GemTarget.key : null,
    padding: _pillPadding(size),
    constraints: BoxConstraints(minHeight: size >= 30 ? kPillHeight : 0),
    decoration: _pillDecoration(),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/gem.png', width: size, height: size),
        const SizedBox(width: 8),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: count, end: count),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, _) => Inscription('$value', size: _counterSize(size), letterSpacing: 1.0),
        ),
      ],
    ),
  );
}

/// Animated counter that tweens from the previous value to the new one.
class AnimatedGemCounter extends StatefulWidget {
  const AnimatedGemCounter({super.key, required this.count, this.size = 28, this.isFlightTarget = false});
  final int count;
  final double size;

  /// Only one counter on screen may be the target of flying gems.
  final bool isFlightTarget;
  @override
  State<AnimatedGemCounter> createState() => _AnimatedGemCounterState();
}

class _AnimatedGemCounterState extends State<AnimatedGemCounter> {
  late int _from = widget.count;
  @override
  void didUpdateWidget(covariant AnimatedGemCounter old) {
    super.didUpdateWidget(old);
    if (old.count != widget.count) _from = old.count;
  }

  @override
  Widget build(BuildContext context) => Container(
    key: widget.isFlightTarget ? GemTarget.key : null,
    padding: _pillPadding(widget.size),
    constraints: BoxConstraints(minHeight: widget.size >= 30 ? kPillHeight : 0),
    decoration: _pillDecoration(),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/gem.png', width: widget.size, height: widget.size),
        const SizedBox(width: 8),
        TweenAnimationBuilder<double>(
          key: ValueKey(widget.count),
          tween: Tween(begin: _from.toDouble(), end: widget.count.toDouble()),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => Inscription('${value.round()}', size: _counterSize(widget.size), letterSpacing: 1.0),
        ),
      ],
    ),
  );
}

Color tierColor(MasteryTier t) => switch (t) {
  MasteryTier.nova => G.grey,
  MasteryTier.discens => G.blue,
  MasteryTier.familiaris => G.amber,
  MasteryTier.perita => G.green,
};

/// Latin name of a tier as shown to the player ("Nōn aestimāta" for nova).
String tierLabel(MasteryTier t) => t == MasteryTier.nova ? 'Nōn aestimāta' : t.latin;

class MasteryBadge extends StatelessWidget {
  const MasteryBadge(this.tier, {super.key, this.label, this.dense = false});
  final MasteryTier tier;
  final String? label;
  final bool dense;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: dense ? 11 : 13, vertical: dense ? 3 : 4),
    decoration: BoxDecoration(
      color: tierColor(tier),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 3, offset: Offset(0, 1))],
    ),
    child: Text(
      label ?? tierLabel(tier),
      style: G.body(dense ? 12 : 13, color: Colors.white, weight: 800),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

class StatChip extends StatelessWidget {
  const StatChip(this.label, {super.key, this.icon, this.color = G.marbleDark, this.textColor = G.ink});
  final String label;
  final IconData? icon;
  final Color color;
  final Color textColor;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 14, color: textColor), const SizedBox(width: 4)],
        // Never overflows its parent: long labels are clipped with an ellipsis.
        Flexible(
          child: Text(
            label,
            style: G.body(13, color: textColor, weight: 700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
  const SectionTitle(this.text, {super.key, this.size = 24, this.open = true, this.onTap, this.topPadding = 16});
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
          child: _Chevron(open: open),
        ),
        const SizedBox(width: 18),
        // The title has priority over the rule, which only takes what is left.
        Flexible(flex: 3, child: Inscription(text.toUpperCase(), size: size, letterSpacing: 3.5)),
        const SizedBox(width: 24),
        Flexible(
          child: Container(
            width: 150,
            height: 2,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Color(0xFFF7DE8C),
              boxShadow: [BoxShadow(color: Color(0xCC200A40), blurRadius: 3, offset: Offset(0, 1))],
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
                AudioService.current?.play(Sfx.tactus);
                onTap!();
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: row),
            ),
    );
  }
}

/// Wide, shallow chevron (21 × 10, 3 px round stroke) with a soft shadow,
/// pointing down when the section is open and right when folded.
class _Chevron extends StatelessWidget {
  const _Chevron({required this.open});
  final bool open;
  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(22, 22),
    painter: _ChevronPainter(open: open),
  );
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.open});
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
      ..color = const Color(0xE624103F)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = kInscriptionGold[1];
    canvas.drawPath(path.shift(const Offset(0, 2)), shadow);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter old) => old.open != open;
}

/// Top bar with back button, title, an optional centre widget and gem counter.
///
/// Pills and title sit on one line at the top. The centre widget (the hero's
/// speech bubble) hangs lower, its top level with the middle of the pills,
/// and is centred on the screen when the title leaves room for it, as on the
/// mock-up; otherwise it follows the title. On narrow screens the title moves
/// under the pills instead of being cut to a few letters.
class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, this.gems, this.trailing = const [], this.onBack, this.center, this.titleColor = kHeadingGold});
  final String title;
  final int? gems;
  final List<Widget> trailing;
  final VoidCallback? onBack;

  /// Widget shown between the title and the gem counter (e.g. a speech bubble).
  final Widget? center;
  final Color titleColor;

  /// Width given to [center]; the mock-up bubble is 376 px wide.
  static const double centerWidth = 376;

  /// Vertical offset of [center] below the top of the pills.
  static const double centerDrop = 22;
  static const double _centerHeight = 72;
  static const double _sidePadding = 24;

  static const double _titleSize = 20;
  static const double _titleSpacing = 1.4;

  /// Uppercase gilt inscription, vertically centred on the 46 px pills.
  Widget get _title => SizedBox(
    height: kPillHeight,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Inscription(title.toUpperCase(), size: _titleSize, letterSpacing: _titleSpacing),
    ),
  );

  Widget _onPill(Widget w) => SizedBox(
    height: kPillHeight,
    child: Center(child: w),
  );

  /// Width of the Redī pill: padding, rim, icon, gap and label.
  static double get _backWidth => 2 * 22 + 2 * 3 + 24 + 8 + measureText('Redī', G.body(21, weight: 700));

  /// Width of the gem pill for [count] gems.
  static double _gemsWidth(int count) => 2 * 16 + 2 * 3 + 34 + 8 + measureText('$count', Inscription.style(_counterSize(34), letterSpacing: 1.0));

  @override
  Widget build(BuildContext context) {
    final back = RomanButton(label: 'Redī', icon: Icons.arrow_back, style: RomanButtonStyle.ghost, dense: true, onPressed: onBack ?? () => Navigator.of(context).maybePop());
    final tail = [
      for (final w in trailing) _onPill(w),
      if (gems != null) ...[const SizedBox(width: 12), AnimatedGemCounter(count: gems!, size: 34)],
    ];
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_sidePadding, 8, _sidePadding, 0),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            if (w < 700) {
              // Phone: pills on the first line, the title under them.
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [back, const Spacer(), ...tail]),
                  Padding(padding: const EdgeInsets.only(top: 10), child: Inscription(title.toUpperCase(), size: 17, letterSpacing: 1.2)),
                ],
              );
            }
            final row = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                back,
                const SizedBox(width: 30),
                Expanded(child: _title),
                ...tail,
              ],
            );
            if (center == null) return row;
            // Centre the bubble on the screen, pushed right only if the title
            // would run under it, and kept clear of the gem pill.
            final titleEnd = _backWidth + 30 + measureText(title.toUpperCase(), Inscription.style(_titleSize, letterSpacing: _titleSpacing));
            final regionEnd = gems == null ? w : w - _gemsWidth(gems!) - 12;
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
                  Positioned(left: left, top: centerDrop, width: centerWidth, child: center!),
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
  const SpeechBubble({super.key, required this.text, required this.heroAsset, this.maxWidth = 520});
  final String text;
  final String heroAsset;
  final double maxWidth;

  /// How far the hero's head rises above the bubble; callers placing the
  /// bubble under another widget must leave this much room.
  static const double heroOverflow = 30;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: maxWidth, minWidth: maxWidth < 376 ? maxWidth : 376),
    child: Stack(
      clipBehavior: Clip.none,
      // Pass the width constraints on, so the bubble fills the slot the top
      // bar gives it instead of shrinking to its text.
      fit: StackFit.passthrough,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.fromLTRB(112, 20, 40, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF3F2266), G.purpleDeep, Color(0xFF33194F)], stops: [0, 0.4, 1], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: G.gold, width: 3),
            boxShadow: const [BoxShadow(color: Color(0x59200A40), blurRadius: 12, offset: Offset(0, 5))],
          ),
          child: Text(
            text,
            style: G.body(20, color: const Color(0xFFF3ECD9), weight: 700),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Positioned(
          left: -16,
          top: -heroOverflow,
          bottom: -10,
          child: Image.asset(heroAsset, fit: BoxFit.contain, alignment: Alignment.bottomLeft),
        ),
      ],
    ),
  );
}

void showLatinSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 2)));
}

Future<bool> confirmLatin(BuildContext context, {required String title, required String body, String yes = 'Ita', String no = 'Nōn'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: G.display(20, color: G.purpleTitle)),
      content: Text(body, style: G.body(16)),
      actions: [
        RomanButton(label: no, style: RomanButtonStyle.neutral, dense: true, onPressed: () => Navigator.pop(ctx, false)),
        RomanButton(label: yes, style: RomanButtonStyle.gold, dense: true, onPressed: () => Navigator.pop(ctx, true)),
      ],
    ),
  );
  return r ?? false;
}

/// Panel header: gold medallion with an icon, title and optional subtitle.
class PanelHeader extends StatelessWidget {
  const PanelHeader({super.key, required this.icon, required this.title, this.subtitle, this.trailing});
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE9C25A),
            border: Border.all(color: const Color(0xFFF7DE8E), width: 3),
            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Icon(icon, color: G.purpleDark, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: G.display(22, color: G.purpleTitle, letterSpacing: 1.0)),
              if (subtitle case final st?)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(st, style: G.body(15, color: G.inkSoft)),
                ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
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

/// Purple-to-dark gradient, kept for screens without a painted background.
const kScreenGradient = BoxDecoration(
  gradient: LinearGradient(colors: [G.purpleDark, Color(0xFF2A1148)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
);
