import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/app.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../audio/audio_service.dart';
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
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [G.purpleDark, Color(0xFF2A1148)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Column(children: [
          TopBar(title: 'Amphitheātrum · Coniugātiōnēs', gems: save.gems),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                for (final g in groups) ...[
                  SectionTitle(g),
                  LayoutBuilder(builder: (context, c) {
                    final cols = (c.maxWidth / 320).floor().clamp(1, 4);
                    final w = (c.maxWidth - (cols - 1) * 12) / cols;
                    return Wrap(spacing: 12, runSpacing: 12, children: [
                      for (final t in Trials.all.where((t) => t.group == g)) SizedBox(width: w, child: TrialCard(trial: t, highlighted: t.id == highlightTrialId)),
                    ]);
                  }),
                ],
              ],
            ),
          ),
        ]),
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

    Color badgeColor = switch (status.access) {
      TrialAccess.accessible => G.green,
      TrialAccess.purchasable => G.gold,
      TrialAccess.locked => G.inkSoft,
    };

    return RomanPanel(
      borderColor: highlighted ? G.goldLight : (accessible ? G.gold : G.marbleDark),
      color: accessible ? G.marble : const Color(0xFFE9E0CC),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(trial.name, style: G.display(17, color: G.purple)),
              Text(trial.subtitle, style: G.body(13, color: G.inkSoft, weight: 700)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
            child: Text(status.access.latin, style: G.body(12, color: Colors.white, weight: 800)),
          ),
        ]),
        const SizedBox(height: 10),
        // Skills worked and estimated mastery.
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final s in summaries)
            Tooltip(
              message: Skills.byId(s.skillId).name,
              child: MasteryBadge(s.tier, dense: true, label: '${Skills.byId(s.skillId).name} · ${s.evaluated ? s.estimateText : 'nōn aestimāta'}'),
            ),
          if (trial.isMixta) StatChip('Mixta: ${Progression.componentsFor(save, trial).length}/${trial.components.length} partēs', icon: Icons.tune),
        ]),
        const SizedBox(height: 10),
        if (!accessible) ...[
          Row(children: [
            Image.asset('assets/images/gem.png', width: 20, height: 20),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '${trial.price} gemmae${status.affordable ? '' : '  (habēs ${save.gems})'}',
                overflow: TextOverflow.ellipsis,
                style: G.body(15, weight: 800, color: status.affordable ? G.greenDark : G.redDark),
              ),
            ),
          ]),
          if (status.missing.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Praerequīsīta dēsunt: ${status.missing.map((m) => m.name).join(', ')}', style: G.body(13, color: G.redDark, weight: 700)),
          ],
          const SizedBox(height: 10),
        ],
        Row(children: [
          Expanded(child: RomanButton(label: 'Dē certāmine', style: RomanButtonStyle.neutral, dense: true, icon: Icons.info_outline, onPressed: () => showTrialSheet(context, trial))),
          const SizedBox(width: 8),
          if (accessible) ...[
            Expanded(
              child: RomanButton(label: 'Certāmen', style: RomanButtonStyle.primary, dense: true, icon: Icons.sports_martial_arts, onPressed: () {
                audio.play(Sfx.tactus);
                pushScreen(context, BattleScreen(trial: trial, mode: BattleMode.certamen));
              }),
            ),
          ] else if (status.access == TrialAccess.purchasable) ...[
            Expanded(
              child: RomanButton(
                label: 'Eme · ${trial.price}',
                style: RomanButtonStyle.gold,
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
            ),
          ] else ...[
            Expanded(child: RomanButton(label: 'Clausa', style: RomanButtonStyle.neutral, dense: true, icon: Icons.lock, onPressed: null)),
          ],
        ]),
        if (accessible) ...[
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: RomanButton(label: 'Exercitātiō (sine gemmīs)', style: RomanButtonStyle.ghost, dense: true, icon: Icons.school, onPressed: () {
                audio.play(Sfx.tactus);
                pushScreen(context, BattleScreen(trial: trial, mode: BattleMode.exercitatio));
              }),
            ),
            if (trial.isMixta) ...[
              const SizedBox(width: 8),
              RomanButton(label: 'Partēs', style: RomanButtonStyle.gold, dense: true, icon: Icons.tune, onPressed: () => showMixtaConfig(context, ref, trial)),
            ],
          ]),
        ],
      ]),
    );
  }
}

/// Introduction sheet: what the trial teaches, with contrasting examples.
void showTrialSheet(BuildContext context, Trial trial) {
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
              child: RomanPanel(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), color: Colors.white, borderColor: G.marbleDark, shadow: false, radius: 12, child: Text(e, style: G.body(17, weight: 700, color: G.purpleDark))),
            ),
          const SizedBox(height: 14),
          Text('Quaestiōnēs', style: G.display(16, color: G.goldDark)),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final d in trial.dimensions) StatChip(d.prompt)]),
          const SizedBox(height: 14),
          Text('Perītiae', style: G.display(16, color: G.goldDark)),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final s in trial.skillIds) StatChip(Skills.byId(s).name, color: G.purple, textColor: Colors.white)]),
          if (trial.prerequisites.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('Praerequīsīta', style: G.display(16, color: G.goldDark)),
            Wrap(spacing: 6, runSpacing: 6, children: [for (final p in trial.prerequisites) StatChip(Trials.byId(p).name)]),
          ],
          const SizedBox(height: 14),
          Text('Pretium: ${trial.isFree ? 'grātīs' : '${trial.price} gemmae'} · ${trial.questionsToWin} ictūs · ${trial.hearts} corda', style: G.body(14, color: G.inkSoft, weight: 700)),
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
            child: Column(mainAxisSize: MainAxisSize.min, children: [
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
            ]),
          ),
        ),
        actions: [
          RomanButton(label: 'Omnēs', style: RomanButtonStyle.neutral, dense: true, onPressed: () => setState(() => selected.addAll(trial.components.map((c) => c.id)))),
          RomanButton(label: 'Servā', style: RomanButtonStyle.gold, dense: true, onPressed: () {
            ref.read(profileProvider.notifier).setMixtaComponents(trial, trial.components.map((c) => c.id).where(selected.contains).toList());
            Navigator.pop(ctx);
          }),
        ],
      ),
    ),
  );
}
