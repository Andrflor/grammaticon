import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/app.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../audio/audio_service.dart';
import '../../battle/battle_controller.dart';
import '../../pedagogy/trials.dart';
import '../activity/activity_config.dart';
import '../battle/battle_screen.dart';
import '../coliseum/coliseum_screen.dart';
import '../forum/forum_screen.dart';
import '../settings/settings_screen.dart';
import '../tabula/tabula_screen.dart';
import '../theatrum/theatrum_screen.dart';
import '../widgets/roman_widgets.dart';

class _Building {
  const _Building({required this.id, required this.name, required this.activity, required this.asset, required this.x, required this.y, required this.width, this.future = false});
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

const _buildings = [
  _Building(id: 'templum', name: 'Templum', activity: 'Gallicē → Latīnē · ventūrum', asset: 'assets/images/bld_templum.png', x: 0.50, y: 0.42, width: 0.20, future: true),
  _Building(id: 'amphitheatrum', name: 'Amphitheātrum', activity: 'Coniugātiōnēs', asset: 'assets/images/bld_amphitheatrum.png', x: 0.84, y: 0.56, width: 0.30),
  _Building(id: 'theatrum', name: 'Theātrum', activity: 'Latīnē → Gallicē', asset: 'assets/images/bld_theatrum.png', x: 0.22, y: 0.74, width: 0.26),
  _Building(id: 'forum', name: 'Forum', activity: 'Dēclīnātiōnēs', asset: 'assets/images/bld_forum.png', x: 0.68, y: 0.86, width: 0.26),
];

/// The Roman city: an interactive scene with four buildings (three open, the
/// Templum announced).
class CityScreen extends HookConsumerWidget {
  const CityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(profileProvider);
    final audio = ref.read(audioProvider);
    final battle = ref.watch(battleProvider);

    void open(_Building b) {
      if (b.future) {
        audio.play(Sfx.vetitum);
        showLatinSnack(context, '${b.name}: aedificium ventūrum. Nōndum aperītur.');
        return;
      }
      audio.play(Sfx.tactus);
      pushScreen(context, switch (b.id) { 'forum' => const ForumScreen(), 'theatrum' => const TheatrumScreen(), _ => const ColiseumScreen() });
    }

    final interrupted = save.activeBattle == null ? null : Trials.maybe(save.activeBattle!.trialId);
    final interruptedLabels = interrupted == null ? null : configFor(interrupted.activity).labels;

    return Scaffold(
      body: LayoutBuilder(builder: (context, c) {
        final portrait = c.maxWidth < c.maxHeight;
        return Stack(fit: StackFit.expand, children: [
          Image.asset('assets/images/city_bg.png', fit: BoxFit.cover, alignment: Alignment.bottomCenter),
          if (portrait) _PortraitCity(onOpen: open, narrow: c.maxWidth < 700) else _StageCity(onOpen: open),
          // HUD: Tabula flush left, the title centred on the screen, the cog and
          // the gems flush right in the same place as on every other screen.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(kHudSidePadding, kHudTopPadding, kHudSidePadding, 12),
              child: Column(children: [
                _CityHud(narrow: c.maxWidth < 700, gems: save.gems),
                const Spacer(),
                if (interrupted != null && interruptedLabels != null && battle == null)
                  RomanPanel(
                    color: G.purpleDark,
                    child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 12, runSpacing: 8, children: [
                      Text('${interruptedLabels.interrupted}: ${interrupted.name}', style: G.body(16, color: G.goldLight, weight: 700)),
                      RomanButton(label: interruptedLabels.resume, style: RomanButtonStyle.gold, dense: true, sound: null, onPressed: () {
                        final ab = save.activeBattle!;
                        pushScreen(context, BattleScreen(trial: interrupted, resume: ab));
                      }),
                      RomanButton(label: 'Omitte', style: RomanButtonStyle.neutral, dense: true, onPressed: () => ref.read(profileProvider.notifier).setActiveBattle(null)),
                    ]),
                  ),
              ]),
            ),
          ),
        ]);
      }),
    );
  }
}

class _CityHud extends StatelessWidget {
  const _CityHud({required this.narrow, required this.gems});
  final bool narrow;
  final int gems;

  @override
  Widget build(BuildContext context) {
    final tabula = SizedBox(
      height: kPillHeight,
      child: RomanButton(label: 'Tabula', icon: Icons.menu_book, style: RomanButtonStyle.gold, dense: true, onPressed: () => pushScreen(context, const TabulaScreen())),
    );
    final right = Row(mainAxisSize: MainAxisSize.min, children: [
      SettingsButton(onPressed: () => pushScreen(context, const SettingsScreen())),
      const SizedBox(width: kHudGap),
      // Same 46 px pill height as the top bars and the arena HUD.
      AnimatedGemCounter(count: gems, size: 34),
    ]);
    final title = RomanPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: G.purpleDark,
      child: Text('GRAMMATICON', style: G.display(narrow ? 20 : 26)),
    );
    if (narrow) {
      // Phone: the title takes its own line under the pills.
      return Column(children: [
        HudRow(height: kPillHeight, left: tabula, right: right),
        Padding(padding: const EdgeInsets.only(top: 10), child: title),
      ]);
    }
    return HudRow(left: tabula, right: right, center: Center(child: title));
  }
}

/// Height of the HUD (pills and title) that the portrait list must clear.
double _cityHudHeight(bool narrow) => kHudTopPadding + (narrow ? kPillHeight + 10 + 48 : HudRow.defaultHeight) + 12;

class _StageCity extends StatelessWidget {
  const _StageCity({required this.onOpen});
  final void Function(_Building) onOpen;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        // 16:9 stage fitted in the available box, anchored bottom-centre like the background.
        var w = c.maxWidth;
        var h = w * 9 / 16;
        if (h > c.maxHeight) {
          h = c.maxHeight;
          w = h * 16 / 9;
        }
        final left = (c.maxWidth - w) / 2;
        final top = c.maxHeight - h;
        return Stack(children: [
          for (final b in _buildings)
            Positioned(
              left: left + b.x * w - b.width * w / 2,
              top: top + b.y * h - b.width * w * 0.75,
              width: b.width * w,
              height: b.width * w * 0.75 + 44,
              child: _BuildingSpot(b: b, onTap: () => onOpen(b)),
            ),
        ]);
      });
}

class _PortraitCity extends StatelessWidget {
  const _PortraitCity({required this.onOpen, required this.narrow});
  final void Function(_Building) onOpen;
  final bool narrow;
  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, _cityHudHeight(narrow) + 20, 16, 24),
          children: [
            for (final b in _buildings)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(height: 200, child: _BuildingSpot(b: b, onTap: () => onOpen(b))),
              ),
          ],
        ),
      );
}

class _BuildingSpot extends HookWidget {
  const _BuildingSpot({required this.b, required this.onTap});
  final _Building b;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hover = useState(false);
    final pressed = useState(false);
    final scale = pressed.value ? 0.97 : (hover.value ? 1.05 : 1.0);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => hover.value = true,
      onExit: (_) => hover.value = false,
      child: GestureDetector(
        onTapDown: (_) => pressed.value = true,
        onTapCancel: () => pressed.value = false,
        onTapUp: (_) => pressed.value = false,
        onTap: onTap,
        child: Semantics(
          button: true,
          label: '${b.name}: ${b.activity}',
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Expanded(
              child: AnimatedScale(
                scale: scale,
                duration: const Duration(milliseconds: 140),
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(boxShadow: hover.value ? const [BoxShadow(color: Color(0xAAFFE08A), blurRadius: 30, spreadRadius: 4)] : null, shape: BoxShape.circle),
                  child: Opacity(
                    opacity: b.future ? 0.9 : 1,
                    child: Image.asset(b.asset, fit: BoxFit.contain, alignment: Alignment.bottomCenter),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: hover.value ? G.gold : G.purpleDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: G.gold, width: 2),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(b.name, style: G.display(16, color: hover.value ? G.purpleDark : G.goldLight)),
                Text(b.activity, style: G.body(12, color: hover.value ? G.purpleDark : Colors.white, weight: 700)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
