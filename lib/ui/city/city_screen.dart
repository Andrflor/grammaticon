import 'package:flutter/material.dart';

import '../../engine/design.dart';
import '../../engine/session.dart';
import '../../app/theme.dart';
import '../widgets/roman_widgets.dart';

class _Building {
  const _Building({
    required this.id,
    required this.name,
    required this.activity,
    required this.asset,
    required this.x,
    required this.y,
    required this.width,
    this.future = false,
  });
  final String id;
  final String name;
  final String activity;
  final String asset;

  /// Anchor (bottom-centre) as fractions of the 16:9 stage.
  final double x;
  final double y;

  /// Width as a fraction of the stage width.
  final double width;
  final bool future;
}

class CityScreen extends StatelessWidget {
  const CityScreen({
    super.key,
    required this.session,
    required this.skin,
    required this.onOpen,
    required this.onProgress,
    required this.onSettings,
    required this.onResume,
  });
  final GameSession session;
  final G skin;
  final void Function(ContentNode) onOpen;
  final VoidCallback onProgress, onSettings, onResume;
  @override
  Widget build(BuildContext context) {
    final design = session.design;
    final layout = object(design.root['presentation']);
    final buildings =
        [
          for (final node in design.places)
            _Building(
              id: node.address,
              name: session.text(node.data['name']),
              activity: session.text(node.data['subtitle']),
              asset: design.asset(node.data['presentation']['image']),
              x: (node.data['presentation']['position']['x'] as num).toDouble(),
              y: (node.data['presentation']['position']['y'] as num).toDouble(),
              width: (node.data['presentation']['width'] as num).toDouble(),
            ),
          for (final item in objects(layout['decorations']))
            _Building(
              id: item['id'],
              name: session.text(item['name']),
              activity: session.text(item['subtitle']),
              asset: design.asset(item['image']),
              x: (item['x'] as num).toDouble(),
              y: (item['y'] as num).toDouble(),
              width: (item['width'] as num).toDouble(),
              future: item['future'] == true,
            ),
        ]..sort(
          (a, b) =>
              strings(layout['worldOrder'])
                  .indexOf(a.id)
                  .compareTo(strings(layout['worldOrder']).indexOf(b.id)),
        );
    void open(_Building b) {
      final node = design.nodes[b.id];
      if (node != null) {
        skin.onCue?.call('tap');
        onOpen(node);
      } else {
        skin.onCue?.call('rejected');
      }
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          final portrait = c.maxWidth < c.maxHeight;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                design.asset(layout['background']),
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
              if (portrait)
                _PortraitCity(
                  skin: skin,
                  buildings: buildings,
                  onOpen: open,
                  narrow: c.maxWidth < 700,
                )
              else
                _StageCity(skin: skin, buildings: buildings, onOpen: open),
              // HUD: Tabula flush left, the title centred on the screen, the cog and
              // the gems flush right in the same place as on every other screen.
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    kHudSidePadding,
                    kHudTopPadding,
                    kHudSidePadding,
                    12,
                  ),
                  child: Column(
                    children: [
                      _CityHud(
                        skin: skin,
                        session: session,
                        onProgress: onProgress,
                        onSettings: onSettings,
                        narrow: c.maxWidth < 700,
                        gems: session.balance,
                      ),
                      const Spacer(),
                      if (session.encounter != null)
                        RomanPanel(
                          skin: skin,
                          color: skin.purpleDark,
                          child: RomanButton(
                            skin: skin,
                            label: session.label('actions.resume'),
                            style: RomanButtonStyle.gold,
                            dense: true,
                            onPressed: onResume,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CityHud extends StatelessWidget {
  final G skin;
  final GameSession session;
  final VoidCallback onProgress, onSettings;
  const _CityHud({
    required this.skin,
    required this.session,
    required this.onProgress,
    required this.onSettings,
    required this.narrow,
    required this.gems,
  });
  final bool narrow;
  final int gems;

  @override
  Widget build(BuildContext context) {
    final tabula = SizedBox(
      height: kPillHeight,
      child: RomanButton(
        skin: skin,
        label: session.label('actions.progress'),
        icon: Icons.menu_book,
        style: RomanButtonStyle.gold,
        dense: true,
        onPressed: onProgress,
      ),
    );
    final right = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RomanButton(
          skin: skin,
          label: '',
          icon: Icons.settings,
          style: RomanButtonStyle.ghost,
          dense: true,
          circular: true,
          onPressed: onSettings,
        ),
        const SizedBox(width: kHudGap),
        // Same 46 px pill height as the top bars and the arena HUD.
        CurrencyCounter(
          skin: skin,
          asset: session.design.asset(
            session.design.root['presentation']['currency'],
          ),
          count: gems,
          size: 34,
        ),
      ],
    );
    final title = RomanPanel(
      skin: skin,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: skin.purpleDark,
      child: Text(
        session.text(session.design.root['name']).toUpperCase(),
        style: skin.display(narrow ? 20 : 26),
      ),
    );
    if (narrow) {
      // Phone: the title takes its own line under the pills.
      return Column(
        children: [
          HudRow(height: kPillHeight, left: tabula, right: right),
          Padding(padding: const EdgeInsets.only(top: 10), child: title),
        ],
      );
    }
    return HudRow(
      left: tabula,
      right: right,
      center: Center(child: title),
    );
  }
}

/// Height of the HUD (pills and title) that the portrait list must clear.
double _cityHudHeight(bool narrow) =>
    kHudTopPadding +
    (narrow ? kPillHeight + 10 + 48 : HudRow.defaultHeight) +
    12;

class _StageCity extends StatelessWidget {
  final G skin;
  final List<_Building> buildings;
  const _StageCity({
    required this.skin,
    required this.buildings,
    required this.onOpen,
  });
  final void Function(_Building) onOpen;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      // 16:9 stage fitted in the available box, anchored bottom-centre like the background.
      var w = c.maxWidth;
      var h = w * 9 / 16;
      if (h > c.maxHeight) {
        h = c.maxHeight;
        w = h * 16 / 9;
      }
      final left = (c.maxWidth - w) / 2;
      final top = c.maxHeight - h;
      return Stack(
        children: [
          for (final b in buildings)
            Positioned(
              left: left + b.x * w - b.width * w / 2,
              top: top + b.y * h - b.width * w * 0.75,
              width: b.width * w,
              height: b.width * w * 0.75 + 44,
              child: _BuildingSpot(skin: skin, b: b, onTap: () => onOpen(b)),
            ),
        ],
      );
    },
  );
}

class _PortraitCity extends StatelessWidget {
  final G skin;
  final List<_Building> buildings;
  const _PortraitCity({
    required this.skin,
    required this.buildings,
    required this.onOpen,
    required this.narrow,
  });
  final void Function(_Building) onOpen;
  final bool narrow;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: EdgeInsets.fromLTRB(16, _cityHudHeight(narrow) + 20, 16, 24),
      children: [
        for (final b in buildings)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              height: 200,
              child: _BuildingSpot(skin: skin, b: b, onTap: () => onOpen(b)),
            ),
          ),
      ],
    ),
  );
}

class _BuildingSpot extends StatefulWidget {
  final G skin;
  const _BuildingSpot({
    required this.skin,
    required this.b,
    required this.onTap,
  });
  final _Building b;
  final VoidCallback onTap;

  @override
  State<_BuildingSpot> createState() => _BuildingSpotState();
}

class _BuildingSpotState extends State<_BuildingSpot> {
  bool hover = false, pressed = false;
  _Building get b => widget.b;
  G get skin => widget.skin;
  VoidCallback get onTap => widget.onTap;
  @override
  Widget build(BuildContext context) {
    final scale = pressed ? 0.97 : (hover ? 1.05 : 1.0);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => pressed = true),
        onTapCancel: () => setState(() => pressed = false),
        onTapUp: (_) => setState(() => pressed = false),
        onTap: onTap,
        child: Semantics(
          button: true,
          label: '${b.name}: ${b.activity}',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: AnimatedScale(
                  scale: scale,
                  duration: const Duration(milliseconds: 140),
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      boxShadow: hover
                          ? [
                              BoxShadow(
                                color: skin.paint('AAFFE08A'),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ]
                          : null,
                      shape: BoxShape.circle,
                    ),
                    child: Opacity(
                      opacity: b.future ? 0.9 : 1,
                      child: Image.asset(
                        b.asset,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: hover ? skin.gold : skin.purpleDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: skin.gold, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      b.name,
                      style: skin.display(
                        16,
                        color: hover ? skin.purpleDark : skin.goldLight,
                      ),
                    ),
                    Text(
                      b.activity,
                      style: skin.body(
                        12,
                        color: hover ? skin.purpleDark : Colors.white,
                        weight: 700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
