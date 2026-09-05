import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/app.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../audio/audio_service.dart';
import '../../economy/economy.dart';
import '../../pedagogy/mastery_view.dart';
import '../../pedagogy/progression.dart';
import '../../pedagogy/skills.dart';
import '../../pedagogy/trials.dart';
import '../../persistence/save_data.dart';
import '../battle/battle_screen.dart';
import '../widgets/roman_widgets.dart';

/// Trial selection inside the Amphitheatrum.
class ColiseumScreen extends ConsumerWidget {
  const ColiseumScreen({super.key, this.highlightTrialId});

  /// Trial to scroll to / open when arriving from the Tabula.
  final String? highlightTrialId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(profileProvider);
    final groups = Trials.groups;
    return Scaffold(
      body: Container(
        decoration: kScreenGradient,
        child: Column(
          children: [
            TopBar(title: 'Amphitheātrum · Coniugātiōnēs', gems: save.gems),
            Expanded(
              child: ContentColumn(
                maxWidth: 1480,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  children: [
                    RomanPanel(
                      color: G.purpleDark,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Image.asset('assets/images/hero_idle.png', height: 56),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Ēlige certāmen. Prīmum grātīs est; cētera gemmīs emuntur et in perpetuum manent.', style: G.body(14, color: G.goldLight, weight: 700)),
                          ),
                        ],
                      ),
                    ),
                    for (final g in groups) ...[
                      SectionTitle(g),
                      LayoutBuilder(
                        builder: (context, c) {
                          final cols = (c.maxWidth / 340).floor().clamp(1, 4);
                          final w = (c.maxWidth - (cols - 1) * 14) / cols;
                          return Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            children: [
                              for (final t in Trials.all.where((t) => t.group == g))
                                SizedBox(
                                  width: w,
                                  child: TrialCard(trial: t, highlighted: t.id == highlightTrialId),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
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

class TrialCard extends ConsumerWidget {
  const TrialCard({super.key, required this.trial, this.highlighted = false});
  final Trial trial;
  final bool highlighted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(profileProvider);
    final cfg = ref.watch(masteryConfigProvider);
    final status = Progression.status(save, trial);
    final audio = ref.read(audioProvider);
    final summaries = [for (final s in trial.skillIds) MasterySummary.forSkill(save, s, cfg)];
    final accessible = status.access == TrialAccess.accessible;
    final locked = status.access == TrialAccess.locked;

    final (Color badgeColor, IconData badgeIcon) = switch (status.access) {
      TrialAccess.accessible => (G.green, Icons.lock_open),
      TrialAccess.purchasable => (G.gold, Icons.shopping_bag),
      TrialAccess.locked => (const Color(0xFF8A7E70), Icons.lock),
    };
    final headerColors = locked ? [const Color(0xFF6B5A7A), const Color(0xFF4A3A5A)] : (accessible ? [G.purpleLight, G.purple] : [const Color(0xFFB07A2A), G.goldDark]);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: locked ? const Color(0xFFEDE4D2) : G.marble,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: highlighted ? G.goldLight : (locked ? G.marbleDark : G.gold), width: 3),
        boxShadow: const [BoxShadow(color: Color(0x55200A40), blurRadius: 12, offset: Offset(0, 6))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header band with the enemy portrait.
          Container(
            constraints: const BoxConstraints(minHeight: 84),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: headerColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -6,
                  top: -6,
                  bottom: -6,
                  child: Opacity(
                    opacity: locked ? 0.45 : 1,
                    child: ColorFiltered(
                      colorFilter: locked ? const ColorFilter.mode(Color(0xFF7A6A88), BlendMode.srcATop) : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                      child: Image.asset('assets/images/enemy_${trial.enemyId}.png', width: 96, fit: BoxFit.contain, alignment: Alignment.bottomRight),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 104, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trial.name,
                        style: G.display(15, color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        trial.subtitle,
                        style: G.body(13, color: G.goldLight, weight: 700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 14,
                  bottom: -12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(status.access.latin, style: G.body(12, color: Colors.white, weight: 800)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 20, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skills worked and estimated mastery.
                for (final sm in summaries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            Skills.byId(sm.skillId).name,
                            style: G.body(13, weight: 700, color: G.inkSoft),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        MasteryBadge(sm.tier, dense: true, label: sm.evaluated ? '${sm.tier.latin} · ${sm.estimateText}' : 'Nōn aestimāta'),
                      ],
                    ),
                  ),
                if (trial.isMixta)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: StatChip('Mixta: ${Progression.componentsFor(save, trial).length}/${trial.components.length} partēs', icon: Icons.tune, color: G.purple, textColor: Colors.white),
                  ),
                if (!accessible) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Image.asset('assets/images/gem.png', width: 22, height: 22),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${trial.price} gemmae${status.affordable ? '' : '  (habēs ${save.gems})'}',
                          overflow: TextOverflow.ellipsis,
                          style: G.body(15, weight: 800, color: status.affordable ? G.greenDark : G.redDark),
                        ),
                      ),
                    ],
                  ),
                  if (status.missing.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.key_off, size: 16, color: G.redDark),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text('Prius: ${status.missing.map((m) => m.name).join(', ')}', style: G.body(13, color: G.redDark, weight: 700)),
                        ),
                      ],
                    ),
                  ],
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    RomanButton(
                      label: '',
                      style: RomanButtonStyle.outline,
                      dense: true,
                      icon: Icons.info_outline,
                      onPressed: () => showTrialSheet(context, trial, canTrain: accessible),
                    ),
                    const SizedBox(width: 8),
                    if (accessible)
                      Expanded(
                        child: RomanButton(
                          label: 'Certāmen',
                          style: RomanButtonStyle.primary,
                          dense: true,
                          icon: Icons.sports_martial_arts,
                          onPressed: () {
                            audio.play(Sfx.tactus);
                            pushScreen(context, BattleScreen(trial: trial, mode: BattleMode.certamen));
                          },
                        ),
                      )
                    else if (status.access == TrialAccess.purchasable)
                      Expanded(
                        child: RomanButton(
                          label: 'Eme · ${trial.price}',
                          style: status.affordable ? RomanButtonStyle.gold : RomanButtonStyle.locked,
                          dense: true,
                          icon: Icons.shopping_bag,
                          onPressed: status.affordable
                              ? () async {
                                  final ok = await confirmLatin(context, title: 'Emere ${trial.name}?', body: 'Pretium: ${trial.price} gemmae. Habēs ${save.gems}. Aditus perpetuus erit.', yes: 'Eme');
                                  if (!ok) return;
                                  final done = await ref.read(profileProvider.notifier).purchase(trial);
                                  if (!context.mounted) return;
                                  if (done) {
                                    audio.play(Sfx.emptio);
                                    showLatinSnack(context, '${trial.name} aperta est!');
                                  } else {
                                    showLatinSnack(context, 'Emptiō nōn facta.');
                                  }
                                }
                              : null,
                        ),
                      )
                    else
                      const Expanded(
                        child: RomanButton(label: 'Clausa', style: RomanButtonStyle.locked, dense: true, icon: Icons.lock),
                      ),
                  ],
                ),
                if (accessible && trial.isMixta) ...[
                  const SizedBox(height: 8),
                  RomanButton(label: 'Partēs mixtae', style: RomanButtonStyle.gold, dense: true, icon: Icons.tune, expand: true, onPressed: () => showMixtaConfig(context, ref, trial)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Introduction sheet: what the trial teaches, with contrasting examples.
void showTrialSheet(BuildContext context, Trial trial, {bool canTrain = false}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      builder: (ctx, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.all(20),
        children: [
          Text(trial.name, style: G.display(24, color: G.purple)),
          Text(trial.subtitle, style: G.body(15, color: G.inkSoft, weight: 700)),
          const SizedBox(height: 12),
          Text(trial.intro, style: G.body(16, height: 1.45)),
          const SizedBox(height: 14),
          Text('Exempla', style: G.display(16, color: G.goldDark)),
          const SizedBox(height: 6),
          for (final e in trial.examples)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: RomanPanel(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.white,
                borderColor: G.marbleDark,
                shadow: false,
                radius: 12,
                child: Text(e, style: G.body(17, weight: 700, color: G.purpleDark)),
              ),
            ),
          const SizedBox(height: 14),
          Text('Quaestiōnēs', style: G.display(16, color: G.goldDark)),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final d in trial.dimensions) StatChip(d.prompt)]),
          const SizedBox(height: 14),
          Text('Perītiae', style: G.display(16, color: G.goldDark)),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final s in trial.skillIds) StatChip(Skills.byId(s).name, color: G.purple, textColor: Colors.white)],
          ),
          if (trial.prerequisites.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('Praerequīsīta', style: G.display(16, color: G.goldDark)),
            Wrap(spacing: 6, runSpacing: 6, children: [for (final p in trial.prerequisites) StatChip(Trials.byId(p).name)]),
          ],
          const SizedBox(height: 14),
          Text('Pretium: ${trial.isFree ? 'grātīs' : '${trial.price} gemmae'} · ${trial.questionsToWin} ictūs · ${trial.hearts} corda', style: G.body(14, color: G.inkSoft, weight: 700)),
          const SizedBox(height: 6),
          Text(const Economy(kEconomy).defeatRule(), style: G.body(13, color: G.redDark, weight: 700)),
          if (canTrain) ...[
            const SizedBox(height: 16),
            RomanPanel(
              color: Colors.white,
              borderColor: G.marbleDark,
              shadow: false,
              radius: 12,
              child: Row(
                children: [
                  Expanded(
                    child: Text('Exercitātiō: eaedem quaestiōnēs sine gemmīs et sine cordibus, ad repetendum. Respōnsa in Tabulā numerantur.', style: G.body(13, color: G.inkSoft)),
                  ),
                  const SizedBox(width: 10),
                  RomanButton(
                    label: 'Exercē',
                    icon: Icons.school,
                    style: RomanButtonStyle.outline,
                    dense: true,
                    onPressed: () {
                      Navigator.pop(ctx);
                      pushScreen(context, BattleScreen(trial: trial, mode: BattleMode.exercitatio));
                    },
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

/// Component picker for Mixta trials (at least [Trial.minComponents]).
void showMixtaConfig(BuildContext context, WidgetRef ref, Trial trial) {
  final save = ref.read(profileProvider);
  final selected = Progression.componentsFor(save, trial).toSet();
  showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text('Ēlige partēs · ${trial.name}', style: G.display(18, color: G.purple)),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Saltem ${trial.minComponents} partēs. Discrīmen vērum tunc rogātur cum plūrēs partēs miscentur.', style: G.body(14, color: G.inkSoft)),
                const SizedBox(height: 8),
                for (final c in trial.components)
                  CheckboxListTile(
                    value: selected.contains(c.id),
                    activeColor: G.purple,
                    title: Text(c.name, style: G.body(15, weight: 700)),
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        selected.add(c.id);
                      } else if (selected.length > trial.minComponents) {
                        selected.remove(c.id);
                      }
                    }),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          RomanButton(label: 'Omnēs', style: RomanButtonStyle.neutral, dense: true, onPressed: () => setState(() => selected.addAll(trial.components.map((c) => c.id)))),
          RomanButton(
            label: 'Servā',
            style: RomanButtonStyle.gold,
            dense: true,
            onPressed: () {
              ref.read(profileProvider.notifier).setMixtaComponents(trial, trial.components.map((c) => c.id).where(selected.contains).toList());
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    ),
  );
}
