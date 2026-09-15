import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'arbor_panel.dart';
import '../../app/app.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../pedagogy/errata.dart';
import '../../pedagogy/mastery.dart';
import '../../pedagogy/trials.dart';
import '../activity/activity_config.dart';
import '../settings/settings_screen.dart';
import '../widgets/roman_widgets.dart';

/// Skill tree with honest mastery estimates fed by real answers.
class TabulaScreen extends ConsumerWidget {
  const TabulaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(profileProvider);
    final light = G.body(16, color: Colors.white);
    return Scaffold(
      body: ScreenBackground(
        asset: 'assets/images/tabula_bg.png',
        child: Column(
          children: [
            TopBar(title: 'Tabula perītiārum', gems: save.gems, onSettings: () => pushScreen(context, const SettingsScreen())),
            Expanded(
              child: ContentColumn(
                maxWidth: 960,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  children: [
                    // Legend of the tiers and the tallies of the three activities.
                    RomanPanel(
                      color: G.purpleDeep,
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('Gradūs:', style: G.body(16, color: const Color(0xFFF3E9D2), weight: 800)),
                          for (final t in MasteryTier.values) MasteryBadge(t, dense: true),
                          for (final a in Activity.values)
                            Text(
                              '· ${configFor(a).labels.wonTally}: ${save.activityStats[a.key]?.won ?? 0} · ${configFor(a).labels.lostTally}: ${save.activityStats[a.key]?.lost ?? 0}',
                              style: light,
                            ),
                        ],
                      ),
                    ),
                    const _ErrataPanel(),
                    const ArborTabula(),
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

/// Error analysis: the forms actually missed, grouped by paradigm cell with
/// the usual confusion. These come back more often in the next fights until
/// answered correctly twice.
class _ErrataPanel extends ConsumerWidget {
  const _ErrataPanel();

  static const int _maxGroups = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final led = ref.watch(profileProvider.select((s) => s.errata));
    final groups = led.groups();
    final light = G.body(16, color: Colors.white);
    final strong = G.body(16, color: Colors.white, weight: 800);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: RomanPanel(
        color: G.purpleDeep,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Errāta', style: G.display(18, color: G.goldLight, letterSpacing: 1.0))),
                StatChip('${led.openCount} aperta', icon: Icons.error_outline, color: led.isEmpty ? G.green : G.red, textColor: Colors.white),
              ],
            ),
            const SizedBox(height: 4),
            if (led.isEmpty)
              Text(led.retired == 0 ? 'Nūllum errātum adhūc.' : 'Omnia errāta corrēcta sunt (${led.retired}).', style: light)
            else ...[
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'Fōrmae errātae: ${led.openCount}', style: strong),
                  TextSpan(text: '  ·  Corrēcta: ${led.retired}', style: light),
                ]),
              ),
              const SizedBox(height: 8),
              for (final g in groups.take(_maxGroups)) _ErrataRow(g),
              if (groups.length > _maxGroups) Text('… et ${groups.length - _maxGroups} aliae cellae.', style: G.body(13, color: G.goldLight)),
              const SizedBox(height: 6),
              Text(
                'Fōrmae errātae in certāminibus proximīs saepius redeunt (nōn in eōdem), dōnec bis rēctē respōnsae sint.',
                style: G.body(14, color: G.goldLight, style: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One cell of the error analysis: analysis, missed forms, usual confusion.
class _ErrataRow extends StatelessWidget {
  const _ErrataRow(this.g);
  final ErrataGroup g;

  @override
  Widget build(BuildContext context) {
    final forms = g.surfaces.take(4).join(', ') + (g.surfaces.length > 4 ? '…' : '');
    final conf = g.topConfusion;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(g.activity == 'v' ? Icons.stadium : Icons.account_balance, size: 16, color: G.goldLight),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: forms, style: G.body(15, color: Colors.white, weight: 800)),
                TextSpan(text: '  ·  ${g.analysis}', style: G.body(14, color: Colors.white)),
                if (conf != null) TextSpan(text: '  ·  prō: $conf', style: G.body(14, color: G.goldLight, style: FontStyle.italic)),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          Text('×${g.misses}', style: G.body(14, color: G.goldLight, weight: 800)),
        ],
      ),
    );
  }
}

