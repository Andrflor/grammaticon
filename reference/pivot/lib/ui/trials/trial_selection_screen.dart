import 'package:flutter/material.dart';

import '../../engine/design.dart';
import '../../engine/session.dart';
import '../../app/theme.dart';
import '../widgets/roman_widgets.dart';

class TrialCard extends StatelessWidget {
  const TrialCard({
    super.key,
    required this.session,
    required this.skin,
    required this.trial,
    required this.place,
    required this.width,
    required this.onStart,
    required this.onInfo,
    required this.requirementText,
    this.highlighted = false,
  });
  final GameSession session;
  final G skin;
  final ContentNode trial, place;
  final double width;
  final bool highlighted;
  final void Function(ContentNode) onStart, onInfo;
  final String Function(Json) requirementText;
  static const double _ring = 1, _frame = 4, _inset = 17, _portraitSlot = 110;
  TextStyle _titleStyle(double size) => TextStyle(
    fontFamily: skin.headingFont,
    fontSize: size,
    color: Colors.white,
    fontVariations: const [FontVariation('wght', 700)],
    letterSpacing: size >= 16 ? 1.2 : .4,
    height: 1.35,
    shadows: [
      Shadow(
        color: skin.paint('80000000'),
        offset: const Offset(0, 1),
        blurRadius: 2,
      ),
    ],
  );
  TextStyle _fitTitle() {
    final maxWidth = width - 2 * (_ring + _frame) - _inset - _portraitSlot;
    final text = session.text(trial.data['name']);
    for (final size in [16.0, 15.0, 14.0, 13.0]) {
      final style = _titleStyle(size);
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 2,
      )..layout(maxWidth: maxWidth);
      final fits =
          !painter.didExceedMaxLines &&
          text.split(' ').every((w) => measureText(w, style) <= maxWidth);
      painter.dispose();
      if (fits || size == 13) return style;
    }
    return _titleStyle(13);
  }

  @override
  Widget build(BuildContext context) {
    final accessible = session.unlocked(trial);
    final eligible = session.meets(trial.requirements);
    final affordable = session.balance >= trial.price;
    final locked = !accessible && !eligible;
    final access = accessible
        ? 'accessible'
        : eligible
        ? 'purchasable'
        : 'locked';
    final titleStyle = _fitTitle();
    final badgeColor = skin.paint(
      accessible
          ? 'FF22B15C'
          : locked
          ? 'FF625A5C'
          : 'FFEAA249',
    );
    final badgeIcon = accessible
        ? Icons.lock_open_outlined
        : Icons.lock_outline;
    // Colours sampled on the mock-up: violet, amber and greyed purple bands.
    final headerColors = switch (access) {
      'accessible' => [skin.paint('FF6A37C4'), skin.paint('FF6840AE')],
      'purchasable' => [skin.paint('FFE2AA48'), skin.paint('FFB57F2A')],
      _ => [skin.paint('FF6F5E7C'), skin.paint('FF4C3D55')],
    };

    // The frame is a 4 px gilt box (a diagonal metal gradient); the body sits
    // inside it with a smaller radius, so the header band meets the frame
    // without a seam. Nothing is clipped: Impeller on OpenGL ES (the Linux
    // desktop) does not anti-alias clips, so rounded corners are drawn by the
    // decorations themselves. A 1 px darker ring, drawn as a real box (a
    // zero-blur shadow is aliased too), separates the gold from the painting,
    // and the card casts a soft shadow on it.
    final frame = highlighted
        ? [
            skin.paint('FFFFF4C0'),
            skin.paint('FFFFFAE0'),
            skin.paint('FFF5D470'),
            skin.paint('FFE0B040'),
          ]
        : locked
        ? [
            skin.paint('FFD9CBAA'),
            skin.paint('FFEDE2C8'),
            skin.paint('FFC9B58C'),
            skin.paint('FFAE9970'),
          ]
        : [
            skin.paint('FFE9BE5E'),
            skin.paint('FFFBE7A3'),
            skin.paint('FFE2B04C'),
            skin.paint('FFC48E33'),
          ];
    final ring = locked ? skin.paint('99826A4A') : skin.paint('B3A06E1E');
    // The status badge straddles the lower edge of the band, as on the mock-up.
    const badgeOverhang = 10.0;
    const inset = _inset;
    final badge = Container(
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.lerp(badgeColor, Colors.white, 0.12)!,
            badgeColor,
            Color.lerp(badgeColor, Colors.black, 0.08)!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: skin.paint('F2FFFFFF'), width: 2),
        boxShadow: [
          BoxShadow(
            color: skin.paint('40000000'),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 17, color: Colors.white),
          SizedBox(width: 6),
          Text(
            session.label('access.$access'),
            style: skin.body(13, color: Colors.white, weight: 700),
          ),
        ],
      ),
    );
    return Container(
      padding: EdgeInsets.all(_ring),
      decoration: BoxDecoration(
        color: ring,
        borderRadius: BorderRadius.circular(20 + _ring),
        boxShadow: [
          BoxShadow(
            color: skin.paint('66200A40'),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: skin.paint('40200A40'),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
          if (highlighted)
            BoxShadow(
              color: skin.paint('99FFE08A'),
              blurRadius: 22,
              spreadRadius: 2,
            ),
        ],
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 160),
        padding: EdgeInsets.all(_frame),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: frame,
            stops: [0, 0.35, 0.72, 1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: locked ? skin.paint('FFEFE6D6') : skin.marble,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header band (98 px on the mock-up) with the opponent's
                      // portrait. The inner Stack clips the portrait, which
                      // stands taller than the band, so the figure looks
                      // planted behind the cream body rather than floating.
                      Container(
                        constraints: BoxConstraints(minHeight: 98),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: headerColors,
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            // Sheen along the top edge of the band.
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      skin.paint('24FFFFFF'),
                                      skin.paint('00FFFFFF'),
                                    ],
                                    stops: [0, 0.4],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            // The figures fill their images almost edge to
                            // edge, so the box runs well below the band: legs
                            // and paws are cut by the cream body.
                            Positioned(
                              right: 6,
                              top: 4,
                              bottom: -52,
                              width: 112,
                              child: Opacity(
                                opacity: locked ? 0.45 : 1,
                                child: ColorFiltered(
                                  colorFilter: locked
                                      ? ColorFilter.mode(
                                          skin.paint('FF8E7E9C'),
                                          BlendMode.srcATop,
                                        )
                                      : ColorFilter.mode(
                                          Colors.transparent,
                                          BlendMode.dst,
                                        ),
                                  child: Image.asset(
                                    session.design.asset(
                                      trial.data['presentation']['opponent'],
                                    ),
                                    fit: BoxFit.contain,
                                    alignment: Alignment.topRight,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              // Room at the bottom for the part of the badge
                              // that stays inside the band.
                              padding: EdgeInsets.fromLTRB(
                                inset,
                                8,
                                _portraitSlot,
                                26,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    session.text(trial.data['name']),
                                    style: titleStyle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    session.text(trial.data['subtitle']),
                                    style: skin.body(
                                      13,
                                      color: skin.paint('FFF3C86A'),
                                      weight: 700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Shadow the band casts on the cream body.
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              skin.paint('30200A40'),
                              skin.paint('00200A40'),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: SizedBox(height: badgeOverhang),
                      ),
                    ],
                  ),
                  Positioned(left: inset, bottom: 0, child: badge),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(inset, 3, inset, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Skills worked and estimated mastery, as bars.
                      for (final id in strings(trial.data['skills']))
                        SkillGauge(
                          session: session,
                          skin: skin,
                          id: id,
                          named: strings(trial.data['skills']).length > 1,
                        ),
                      if (!accessible) ...[
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Image.asset(
                              session.design.asset(
                                session.design.root['presentation']['currency'],
                              ),
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${trial.price}${affordable ? '' : '  (${session.label('labels.balance')} ${session.balance})'}',
                                overflow: TextOverflow.ellipsis,
                                style: skin.body(
                                  13,
                                  weight: 700,
                                  color: affordable ? skin.ink : skin.redDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!session.meets(trial.requirements)) ...[
                          SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.key_off,
                                size: 16,
                                color: skin.redDark,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${session.label('labels.requirements')}: ${requirementText(trial.requirements)}',
                                  style: skin.body(
                                    13,
                                    color: skin.redDark,
                                    weight: 700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                      Spacer(),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          RomanButton(
                            skin: skin,
                            label: 'i',
                            style: RomanButtonStyle.outline,
                            dense: true,
                            circular: true,
                            onPressed: () => onInfo(trial),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: RomanButton(
                              skin: skin,
                              label: accessible
                                  ? session.text(
                                      place
                                          .data['presentation']['labels']['encounter'],
                                    )
                                  : eligible
                                  ? '${session.label('actions.buy')} · ${trial.price}'
                                  : session.label('state.locked'),
                              style: accessible
                                  ? RomanButtonStyle.primary
                                  : eligible && affordable
                                  ? RomanButtonStyle.gold
                                  : RomanButtonStyle.locked,
                              dense: true,
                              expand: true,
                              icon: accessible
                                  ? switch (place
                                        .data['presentation']['startIcon']) {
                                      'speak' => Icons.record_voice_over,
                                      'theater' => Icons.theater_comedy,
                                      'temple' => Icons.account_balance,
                                      _ => Icons.sports_martial_arts,
                                    }
                                  : !eligible
                                  ? Icons.lock
                                  : null,
                              leading: !accessible && eligible
                                  ? Image.asset(
                                      session.design.asset(
                                        session
                                            .design
                                            .root['presentation']['currency'],
                                      ),
                                      width: 20,
                                      height: 20,
                                    )
                                  : null,
                              onPressed: session.busy
                                  ? null
                                  : accessible
                                  ? () => onStart(trial)
                                  : session.purchasable(trial)
                                  ? () async {
                                      String text(String key) => session
                                          .label(key)
                                          .replaceAll(
                                            '{name}',
                                            session.text(trial.data['name']),
                                          )
                                          .replaceAll(
                                            '{price}',
                                            '${trial.price}',
                                          )
                                          .replaceAll(
                                            '{balance}',
                                            '${session.balance}',
                                          );
                                      final ok = await confirmAction(
                                        context,
                                        skin: skin,
                                        title: text('purchase.title'),
                                        body: text('purchase.body'),
                                        yes: session.label('actions.buy'),
                                        no: session.label('actions.no'),
                                      );
                                      if (!ok) return;
                                      await session.buy(trial);
                                      final done = session.unlocked(trial);
                                      if (!context.mounted) return;
                                      if (done) skin.onCue?.call('purchase');
                                      showSnack(
                                        context,
                                        text(
                                          done
                                              ? 'purchase.success'
                                              : 'purchase.failure',
                                        ),
                                      );
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrialSelectionScreen extends StatelessWidget {
  const TrialSelectionScreen({
    super.key,
    required this.session,
    required this.skin,
    required this.place,
    required this.onStart,
    required this.onInfo,
    required this.onBack,
    required this.onSettings,
    required this.requirementText,
    this.highlightTrialId,
  });
  final GameSession session;
  final G skin;
  final ContentNode place;
  final VoidCallback onBack, onSettings;
  final void Function(ContentNode) onStart, onInfo;
  final String Function(Json) requirementText;
  final String? highlightTrialId;
  @override
  Widget build(BuildContext context) {
    final config = object(place.data['presentation']);
    final groups = place.children;
    final wide = MediaQuery.sizeOf(context).width >= 1100;
    final bubble = SpeechBubble(
      skin: skin,
      text: session.text(config['labels']['blurb']),
      heroAsset: session.design.asset(config['hero']),
    );
    return Scaffold(
      body: ScreenBackground(
        asset: session.design.asset(
          session.design.root['presentation']['selectionBackground'],
        ),
        child: Column(
          children: [
            TopBar(
              skin: skin,
              backLabel: session.label('actions.back'),
              currencyAsset: session.design.asset(
                session.design.root['presentation']['currency'],
              ),
              title: session.text(config['labels']['title']),
              gems: session.balance,
              onSettings: onSettings,
              onBack: onBack,
              center: wide ? bubble : null,
            ),
            Expanded(
              child: ContentColumn(
                // Four cards of ~310 px on a wide screen, leaving the painted
                // banners visible on both sides as on the mock-up.
                maxWidth: 1305,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    wide ? 0 : SpeechBubble.heroOverflow + 4,
                    16,
                    32,
                  ),
                  children: [
                    if (!wide)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: bubble,
                        ),
                      ),
                    for (final g in groups)
                      _GroupSection(
                        session: session,
                        skin: skin,
                        place: place,
                        onStart: onStart,
                        onInfo: onInfo,
                        requirementText: requirementText,
                        title: session.text(g.data['name']),
                        trials: g.children,
                        highlightTrialId: highlightTrialId,
                        topPadding: wide ? 6 : 16,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One group of trials under a folding heading, laid out in rows of equal
/// height (four cards on a wide screen).
class _GroupSection extends StatefulWidget {
  final GameSession session;
  final G skin;
  final ContentNode place;
  final void Function(ContentNode) onStart, onInfo;
  final String Function(Json) requirementText;
  const _GroupSection({
    required this.session,
    required this.skin,
    required this.place,
    required this.onStart,
    required this.onInfo,
    required this.requirementText,
    required this.title,
    required this.trials,
    this.highlightTrialId,
    this.topPadding = 16,
  });
  final String title;
  final List<ContentNode> trials;
  final String? highlightTrialId;
  final double topPadding;
  @override
  State<_GroupSection> createState() => _GroupSectionState();
}

class _GroupSectionState extends State<_GroupSection> {
  bool _open = true;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionTitle(
        skin: widget.skin,
        widget.title,
        open: _open,
        topPadding: widget.topPadding,
        onTap: () => setState(() => _open = !_open),
      ),
      if (_open)
        LayoutBuilder(
          builder: (context, c) {
            const gap = 12.0;
            final cols = (c.maxWidth / 300).floor().clamp(1, 4);
            final rows = <List<ContentNode>>[];
            for (var i = 0; i < widget.trials.length; i += cols) {
              rows.add(
                widget.trials.sublist(
                  i,
                  (i + cols).clamp(0, widget.trials.length),
                ),
              );
            }
            return Column(
              children: [
                for (final row in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: gap),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (i, t) in row.indexed) ...[
                            if (i > 0) const SizedBox(width: gap),
                            Expanded(
                              child: TrialCard(
                                session: widget.session,
                                skin: widget.skin,
                                place: widget.place,
                                onStart: widget.onStart,
                                onInfo: widget.onInfo,
                                requirementText: widget.requirementText,
                                trial: t,
                                highlighted:
                                    t.address == widget.highlightTrialId,
                                width: (c.maxWidth - gap * (cols - 1)) / cols,
                              ),
                            ),
                          ],
                          // Keep the last row's cards the same width as the others.
                          for (var i = row.length; i < cols; i++) ...[
                            const SizedBox(width: gap),
                            const Expanded(child: SizedBox.shrink()),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
    ],
  );
}

class SkillGauge extends StatelessWidget {
  const SkillGauge({
    super.key,
    required this.session,
    required this.skin,
    required this.id,
    this.named = false,
  });
  final GameSession session;
  final G skin;
  final String id;
  final bool named;
  @override
  Widget build(BuildContext context) {
    final estimate = session.progress(id);
    final level = objects(session.mastery['levels'])[session.level(id)];
    final color = Color(int.parse(level['color'] as String, radix: 16));
    final label = estimate == null
        ? session.label('labels.unassessed')
        : '${session.text(level['name'])} · ${(estimate * 100).round()} %';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (named)
            Text(
              session.text(session.design.knowledge[id]?['name']),
              style: skin.body(13, weight: 700, color: skin.inkSoft),
              overflow: TextOverflow.ellipsis,
            ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: ShapeDecoration(
                          shape: const StadiumBorder(),
                          gradient: LinearGradient(
                            colors: [
                              skin.paint('FFC4BFB9'),
                              skin.paint('FFD9D4CE'),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: (estimate ?? 0).clamp(0, 1),
                        child: Container(
                          height: 12,
                          decoration: ShapeDecoration(
                            shape: const StadiumBorder(),
                            gradient: LinearGradient(
                              colors: [
                                Color.lerp(color, Colors.white, .3)!,
                                color,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: skin.body(
                  13,
                  weight: 800,
                  color: estimate == null
                      ? skin.ink
                      : Color.lerp(color, Colors.black, .38),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
