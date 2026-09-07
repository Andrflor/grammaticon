import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../pedagogy/mastery.dart';

/// Marble panel with a gold frame.
class RomanPanel extends StatelessWidget {
  const RomanPanel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color = G.marble, this.borderColor = G.gold, this.radius = 20, this.width, this.shadow = true});
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;
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
          border: Border.all(color: borderColor, width: 3),
          boxShadow: shadow ? const [BoxShadow(color: Color(0x55200A40), blurRadius: 12, offset: Offset(0, 6))] : null,
        ),
        // Transparent Material so list tiles and ink effects inside panels paint correctly.
        child: Material(type: MaterialType.transparency, child: child),
      );
}

enum RomanButtonStyle { primary, gold, ghost, success, danger, neutral, outline, locked }

/// Large, generous button (min height 56) with an optional key-number badge.
class RomanButton extends StatelessWidget {
  const RomanButton({super.key, required this.label, this.onPressed, this.style = RomanButtonStyle.primary, this.icon, this.badge, this.expand = false, this.dense = false, this.trailing});
  final String label;
  final VoidCallback? onPressed;
  final RomanButtonStyle style;
  final IconData? icon;
  final String? badge;
  final bool expand;
  final bool dense;
  final Widget? trailing;

  Color get _bg => switch (style) {
        RomanButtonStyle.primary => G.purple,
        RomanButtonStyle.gold => G.gold,
        RomanButtonStyle.ghost => Colors.transparent,
        RomanButtonStyle.success => G.green,
        RomanButtonStyle.danger => G.red,
        RomanButtonStyle.neutral => G.marbleDark,
        RomanButtonStyle.outline => Colors.white,
        RomanButtonStyle.locked => const Color(0xFF8A7E70),
      };
  Color get _fg => switch (style) {
        RomanButtonStyle.gold => G.purpleDark,
        RomanButtonStyle.ghost => G.goldLight,
        RomanButtonStyle.neutral => G.ink,
        RomanButtonStyle.outline => G.purple,
        _ => Colors.white,
      };
  Color get _border => switch (style) {
        RomanButtonStyle.primary => G.purpleLight,
        RomanButtonStyle.gold => G.goldLight,
        RomanButtonStyle.ghost => G.gold,
        RomanButtonStyle.success => const Color(0xFF7CF0A0),
        RomanButtonStyle.danger => const Color(0xFFFF8A94),
        RomanButtonStyle.neutral => G.goldDark,
        RomanButtonStyle.outline => G.purple,
        RomanButtonStyle.locked => const Color(0xFFB0A493),
      };

  @override
  Widget build(BuildContext context) {
    // Locked buttons are a deliberate state, not a faded control.
    final disabled = onPressed == null && style != RomanButtonStyle.locked;
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (badge != null) ...[
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: G.gold, borderRadius: BorderRadius.circular(8), border: Border.all(color: G.goldLight, width: 2)),
            // badge
            child: Text(badge!, style: G.body(16, color: G.purpleDark, weight: 800)),
          ),
          const SizedBox(width: 12),
        ],
        if (icon != null) ...[Icon(icon, color: _fg, size: dense ? 18 : 22), const SizedBox(width: 8)],
        Flexible(child: Text(label, textAlign: TextAlign.center, style: G.body(dense ? 15 : 18, color: _fg, weight: 800))),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: Material(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: BoxConstraints(minHeight: dense ? 44 : 56, minWidth: dense ? 44 : 120),
            padding: EdgeInsets.symmetric(horizontal: dense ? 12 : 18, vertical: dense ? 8 : 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: _border, width: 3)),
            child: child,
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

/// Gem icon with an animated counter.
class GemCounter extends StatelessWidget {
  const GemCounter({super.key, required this.count, this.size = 28, this.useTargetKey = false});
  final int count;
  final double size;
  final bool useTargetKey;

  @override
  Widget build(BuildContext context) => Container(
        key: useTargetKey ? GemTarget.key : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: G.purpleDark, borderRadius: BorderRadius.circular(30), border: Border.all(color: G.gold, width: 3)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/gem.png', width: size, height: size),
            const SizedBox(width: 8),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: count, end: count),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, _) => Text('$value', style: G.display(size * 0.8, color: G.goldLight)),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: G.purpleDark, borderRadius: BorderRadius.circular(30), border: Border.all(color: G.gold, width: 3)),
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
              builder: (context, value, _) => Text('${value.round()}', style: G.display(widget.size * 0.8, color: G.goldLight)),
            ),
          ],
        ),
      );
}

Color tierColor(MasteryTier t) => switch (t) {
      MasteryTier.nova => G.inkSoft,
      MasteryTier.discens => const Color(0xFF3B8BEA),
      MasteryTier.familiaris => G.gold,
      MasteryTier.perita => G.green,
    };

class MasteryBadge extends StatelessWidget {
  const MasteryBadge(this.tier, {super.key, this.label, this.dense = false});
  final MasteryTier tier;
  final String? label;
  final bool dense;
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 2 : 4),
        decoration: BoxDecoration(color: tierColor(tier), borderRadius: BorderRadius.circular(20)),
        child: Text(label ?? (tier == MasteryTier.nova ? 'Nōn aestimāta' : tier.latin), style: G.body(dense ? 12 : 13, color: Colors.white, weight: 800)),
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
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: textColor), const SizedBox(width: 4)],
          // Never overflows its parent: long labels are clipped with an ellipsis.
          Flexible(child: Text(label, style: G.body(13, color: textColor, weight: 700), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.color = G.goldLight, this.size = 22});
  final String text;
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
        child: Row(children: [
          Image.asset('assets/images/laurel.png', width: 28, height: 28),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: G.display(size, color: color))),
        ]),
      );
}

/// Top bar with back button, title and gem counter.
class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, this.gems, this.trailing = const [], this.onBack});
  final String title;
  final int? gems;
  final List<Widget> trailing;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) => SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 4),
          child: Row(children: [
            RomanButton(label: 'Redī', icon: Icons.arrow_back, style: RomanButtonStyle.ghost, dense: true, onPressed: onBack ?? () => Navigator.of(context).maybePop()),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: G.display(22), overflow: TextOverflow.ellipsis)),
            ...trailing,
            if (gems != null) ...[const SizedBox(width: 8), AnimatedGemCounter(count: gems!, size: 24)],
          ]),
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
      title: Text(title, style: G.display(20, color: G.purple)),
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
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(shape: BoxShape.circle, color: G.gold, border: Border.all(color: G.goldLight, width: 3), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2))]),
            child: Icon(icon, color: G.purpleDark, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: G.display(19, color: G.purple)),
              if (subtitle case final st?) Text(st, style: G.body(13, color: G.inkSoft)),
            ]),
          ),
          if (trailing != null) trailing!,
        ]),
      );
}

/// Centres content in a readable column on wide screens.
class ContentColumn extends StatelessWidget {
  const ContentColumn({super.key, required this.child, this.maxWidth = 760});
  final Widget child;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child));
}

/// Purple-to-dark gradient used behind every secondary screen.
const kScreenGradient = BoxDecoration(gradient: LinearGradient(colors: [G.purpleDark, Color(0xFF2A1148)], begin: Alignment.topCenter, end: Alignment.bottomCenter));
