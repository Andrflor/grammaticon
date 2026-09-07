import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../pedagogy/mastery.dart';

/// Gold of the headings written directly on the painted background.
const Color kHeadingGold = Color(0xFFF6D77A);

/// Dark purple shadow that keeps the gold headings legible over the painted
/// backgrounds (banners, columns) without boxing them in.
const List<Shadow> kHeadingShadow = [
  Shadow(color: Color(0xFF24103F), offset: Offset(0, 2), blurRadius: 3),
  Shadow(color: Color(0xE6200A40), blurRadius: 10),
  Shadow(color: Color(0xB3200A40), blurRadius: 24),
];

/// Radius of the pills and buttons (the mock-ups round them generously).
const double kButtonRadius = 16;

/// Deep purple of the primary buttons and the pill of light purple around
/// them, sampled on the mock-up cards.
const Color kButtonPurple = Color(0xFF542C9D);
const Color kButtonPurpleEdge = Color(0xFF7E4BCC);

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
  });
  final String label;
  final VoidCallback? onPressed;
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
    RomanButtonStyle.ghost => G.purpleNight,
    RomanButtonStyle.success => G.green,
    RomanButtonStyle.danger => G.red,
    RomanButtonStyle.neutral => G.marbleDark,
    RomanButtonStyle.outline => Colors.white,
    RomanButtonStyle.locked => const Color(0xFF7E7670),
    RomanButtonStyle.chosen => G.goldWash,
  };
  Color get _fg => switch (style) {
    RomanButtonStyle.gold => G.purpleDark,
    RomanButtonStyle.ghost => G.gold,
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
    final iconSize = dense ? 20.0 : 22.0;
    final hasLabel = label.isNotEmpty;
    final labelStyle = circular ? G.body(dense ? 20 : 22, color: _fg, weight: 900, height: 1) : G.body(dense ? 15 : 18, color: _fg, weight: 700);
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
    final radius = BorderRadius.circular(circular ? 999 : kButtonRadius);
    final side = dense ? 44.0 : 56.0;
    // Bevel: a light sheen at the top and a darker foot, so the buttons read
    // as raised like the mock-up's rather than as flat tiles. The overlay is
    // translucent, so the ink splash below stays visible. White buttons stay
    // plain white.
    final bevel = style == RomanButtonStyle.outline
        ? null
        : const LinearGradient(
            colors: [Color(0x30FFFFFF), Color(0x00FFFFFF), Color(0x24000000)],
            stops: [0, 0.45, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
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
            onTap: onPressed,
            borderRadius: radius,
            child: Container(
              constraints: circular ? BoxConstraints.tightFor(width: side, height: side) : BoxConstraints(minHeight: side, minWidth: hasLabel ? (dense ? 44 : 120) : side),
              padding: circular ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: dense ? 16 : 18, vertical: dense ? 8 : 12),
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: bevel,
                border: Border.all(color: _border, width: 2.5),
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

BoxDecoration _pillDecoration() => BoxDecoration(
  color: G.purpleNight,
  borderRadius: BorderRadius.circular(kButtonRadius),
  border: Border.all(color: G.gold, width: 2.5),
  boxShadow: const [BoxShadow(color: Color(0x4D200A40), blurRadius: 8, offset: Offset(0, 3))],
);

/// Gem icon with an animated counter.
class GemCounter extends StatelessWidget {
  const GemCounter({super.key, required this.count, this.size = 28, this.useTargetKey = false});
  final int count;
  final double size;
  final bool useTargetKey;

  @override
  Widget build(BuildContext context) => Container(
    key: useTargetKey ? GemTarget.key : null,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: _pillDecoration(),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/gem.png', width: size, height: size),
        const SizedBox(width: 8),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: count, end: count),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, _) => Text('$value', style: G.display(size * 0.8, color: G.gold)),
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
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
          builder: (context, value, _) => Text('${value.round()}', style: G.display(widget.size * 0.8, color: G.gold)),
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

/// Section heading: chevron, Cinzel title and a gold rule running to the
/// right edge. With [onTap] the heading folds and unfolds its section.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.color = kHeadingGold, this.size = 26, this.open = true, this.onTap});
  final String text;
  final Color color;
  final double size;
  final bool open;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Icon(open ? Icons.expand_more : Icons.chevron_right, color: color, size: size + 4, shadows: kHeadingShadow),
        const SizedBox(width: 6),
        // The title has priority over the rule, which only fills what is left.
        Flexible(
          flex: 3,
          child: Text(
            text,
            style: G.display(size, color: color, letterSpacing: 2.0).copyWith(shadows: kHeadingShadow),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(
              color: kHeadingGold,
              boxShadow: [BoxShadow(color: Color(0xB3200A40), blurRadius: 4, offset: Offset(0, 1))],
            ),
          ),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
      child: onTap == null
          ? row
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: row),
            ),
    );
  }
}

/// Top bar with back button, title, an optional centre widget and gem counter.
class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, this.gems, this.trailing = const [], this.onBack, this.center, this.titleColor = kHeadingGold});
  final String title;
  final int? gems;
  final List<Widget> trailing;
  final VoidCallback? onBack;

  /// Widget shown between the title and the gem counter (e.g. a speech bubble).
  final Widget? center;
  final Color titleColor;
  // Lighter and more widely tracked than the section headings, as on the
  // mock-ups, where the screen title is an inscription rather than a banner.
  TextStyle get _titleStyle => G.display(21, color: titleColor, weight: 600, letterSpacing: 2.6).copyWith(shadows: kHeadingShadow);
  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          RomanButton(label: 'Redī', icon: Icons.arrow_back, style: RomanButtonStyle.ghost, dense: true, onPressed: onBack ?? () => Navigator.of(context).maybePop()),
          const SizedBox(width: 16),
          if (center == null)
            Expanded(
              child: Text(title, style: _titleStyle, overflow: TextOverflow.ellipsis),
            )
          else ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Text(title, style: _titleStyle, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 16),
            Expanded(child: Center(child: center!)),
          ],
          ...trailing,
          if (gems != null) ...[const SizedBox(width: 12), AnimatedGemCounter(count: gems!, size: 24)],
        ],
      ),
    ),
  );
}

/// The hero speaking: a deep purple bubble framed in gold with the figure
/// standing at its left edge.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.text, required this.heroAsset, this.maxWidth = 520});
  final String text;
  final String heroAsset;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: maxWidth),
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerLeft,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 48, top: 14),
          padding: const EdgeInsets.fromLTRB(58, 15, 26, 15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF43236B), G.purpleDeep], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: G.gold, width: 2.5),
            boxShadow: const [BoxShadow(color: Color(0x59200A40), blurRadius: 12, offset: Offset(0, 5))],
          ),
          child: Text(
            text,
            style: G.body(17, color: const Color(0xFFF6EFE0), weight: 700),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // The hero stands in front of the bubble's left edge, head above it.
        Positioned(left: 0, bottom: -4, child: Image.asset(heroAsset, height: 98, fit: BoxFit.contain)),
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
