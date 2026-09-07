import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/app.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../audio/audio_service.dart';
import '../../economy/economy.dart';
import '../../pedagogy/mastery.dart';
import '../../pedagogy/mastery_view.dart';
import '../../pedagogy/progression.dart';
import '../../pedagogy/skills.dart';
import '../../pedagogy/trials.dart';
import '../../persistence/save_data.dart';
import '../activity/activity_config.dart';
import '../battle/battle_screen.dart';
import '../widgets/roman_widgets.dart';

/// Trial selection of one activity (the Amphitheatrum's certāmina, the
/// Forum's contrōversiae): free introductory trial, visible locked trials with
/// prices and prerequisites, permanent purchases, Mixta configuration.
class TrialSelectionScreen extends ConsumerWidget {
  const TrialSelectionScreen({super.key, required this.activity, this.highlightTrialId});
  final Activity activity;

  /// Trial to highlight when arriving from the Tabula.
  final String? highlightTrialId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(profileProvider);
    final config = configFor(activity);
    final groups = Trials.groupsOf(activity);
    final trials = Trials.ofActivity(activity);
    final wide = MediaQuery.sizeOf(context).width >= 1100;
    final bubble = SpeechBubble(text: config.labels.blurb, heroAsset: config.heroAsset);
    return Scaffold(
      body: ScreenBackground(
        asset: 'assets/images/certamina_bg.png',
        child: Column(
          children: [
            TopBar(title: config.labels.title, gems: save.gems, center: wide ? bubble : null),
            Expanded(
              child: ContentColumn(
                // Four cards of ~305 px on a wide screen, leaving the painted
                // banners visible on both sides as on the mock-up.
                maxWidth: 1310,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  children: [
                    if (!wide)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 6, 0, 4),
                        child: Align(alignment: Alignment.centerLeft, child: bubble),
                      ),
                    for (final g in groups) _GroupSection(title: g, trials: trials.where((t) => t.group == g).toList(), highlightTrialId: highlightTrialId),
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
  const _GroupSection({required this.title, required this.trials, this.highlightTrialId});
  final String title;
  final List<Trial> trials;
  final String? highlightTrialId;
  @override
  State<_GroupSection> createState() => _GroupSectionState();
}

class _GroupSectionState extends State<_GroupSection> {
  bool _open = true;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionTitle(widget.title, open: _open, onTap: () => setState(() => _open = !_open)),
      if (_open)
        LayoutBuilder(
          builder: (context, c) {
            const gap = 14.0;
            final cols = (c.maxWidth / 300).floor().clamp(1, 4);
            final rows = <List<Trial>>[];
            for (var i = 0; i < widget.trials.length; i += cols) {
              rows.add(widget.trials.sublist(i, (i + cols).clamp(0, widget.trials.length)));
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
                              child: TrialCard(trial: t, highlighted: t.id == widget.highlightTrialId),
                            ),
                          ],
                          // Keep the last row's cards the same width as the others.
                          for (var i = row.length; i < cols; i++) ...[const SizedBox(width: gap), const Expanded(child: SizedBox.shrink())],
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
    final config = configFor(trial.activity);
    final summaries = [for (final s in trial.skillIds) MasterySummary.forSkill(save, s, cfg)];
    final accessible = status.access == TrialAccess.accessible;
    final locked = status.access == TrialAccess.locked;
    // Long names ("Indicātīvus plūsquamperfectum") get a tighter title so the
    // word is never broken next to the portrait; Cinzel is a wide face.
    final longName = trial.name.length > 24 || trial.name.split(' ').any((w) => w.length > 13);
    final titleStyle = (longName ? G.display(12, color: Colors.white, letterSpacing: 0.4) : G.display(16, color: Colors.white, letterSpacing: 1.5)).copyWith(
      shadows: const [Shadow(color: Color(0x80000000), offset: Offset(0, 1), blurRadius: 2)],
    );

    final (Color badgeColor, IconData badgeIcon) = switch (status.access) {
      TrialAccess.accessible => (const Color(0xFF22B15C), Icons.lock_open_outlined),
      TrialAccess.purchasable => (const Color(0xFFEAA249), Icons.lock_outline),
      TrialAccess.locked => (const Color(0xFF625A5C), Icons.lock_outline),
    };
    // Colours sampled on the mock-up: violet, amber and greyed purple bands.
    final headerColors = switch (status.access) {
      TrialAccess.accessible => const [Color(0xFF6D39C6), Color(0xFF6A3FB0)],
      TrialAccess.purchasable => const [Color(0xFFE2AA48), Color(0xFFB57F2A)],
      TrialAccess.locked => const [Color(0xFF6F5E7C), Color(0xFF4C3D55)],
    };

    // The frame is a solid gold box; the body is clipped inside it with a
    // smaller radius, so the header band meets the frame without a seam. A
    // thin darker ring (a spread-only shadow) separates the gold from the
    // painting, and the card casts a soft shadow on it.
    final frame = highlighted
        ? const [Color(0xFFFFF0B0), Color(0xFFF0C860)]
        : locked
        ? const [Color(0xFFE9DBBC), Color(0xFFC9B283)]
        : const [Color(0xFFF7DA8E), Color(0xFFDDA544)];
    final ring = locked ? const Color(0x99826A4A) : const Color(0xB3A06E1E);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: frame, begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: ring, spreadRadius: 1),
          const BoxShadow(color: Color(0x66200A40), blurRadius: 18, offset: Offset(0, 8)),
          const BoxShadow(color: Color(0x40200A40), blurRadius: 4, offset: Offset(0, 2)),
          if (highlighted) const BoxShadow(color: Color(0x99FFE08A), blurRadius: 22, spreadRadius: 2),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: ColoredBox(
          color: locked ? const Color(0xFFEFE6D6) : G.marble,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header band with the opponent's portrait. The Stack clips the
              // portrait, which stands taller than the band, so the figure
              // looks planted behind the cream body rather than floating.
              Container(
                constraints: const BoxConstraints(minHeight: 112),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: headerColors, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Sheen along the top edge of the band.
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0x2CFFFFFF), Color(0x00FFFFFF)], stops: [0, 0.4], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                        ),
                      ),
                    ),
                    // The figures fill their images almost edge to edge, so
                    // the box runs well below the band: legs and paws are cut
                    // by the cream body, as on the mock-up.
                    Positioned(
                      right: 6,
                      top: 4,
                      bottom: -52,
                      width: 112,
                      child: Opacity(
                        opacity: locked ? 0.45 : 1,
                        child: ColorFiltered(
                          colorFilter: locked ? const ColorFilter.mode(Color(0xFF8E7E9C), BlendMode.srcATop) : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                          child: Image.asset(config.opponentAsset(trial.opponentId), fit: BoxFit.contain, alignment: Alignment.topRight),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 9, 110, 9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(trial.name, style: titleStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
                          Text(
                            trial.subtitle,
                            style: G.body(14, color: const Color(0xFFF3C86A), weight: 700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xE6FFFFFF), width: 2),
                              boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(badgeIcon, size: 15, color: Colors.white),
                                const SizedBox(width: 5),
                                Text(status.access.latin, style: G.body(12, color: Colors.white, weight: 700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Shadow the band casts on the cream body.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0x30200A40), Color(0x00200A40)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                child: SizedBox(height: 10),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Skills worked and estimated mastery, as bars.
                      for (final sm in summaries) _MasteryBar(summary: sm, named: summaries.length > 1),
                      if (trial.isMixta)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: StatChip('Mixta: ${Progression.componentsFor(save, trial).length}/${trial.components.length} partēs', icon: Icons.tune, color: G.purple, textColor: Colors.white),
                          ),
                        ),
                      if (!accessible) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Image.asset('assets/images/gem.png', width: 22, height: 22),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${trial.price}${status.affordable ? '' : '  (habēs ${save.gems})'}',
                                overflow: TextOverflow.ellipsis,
                                style: G.body(16, weight: 800, color: status.affordable ? G.ink : G.redDark),
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
                      const Spacer(),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          RomanButton(
                            label: 'i',
                            style: RomanButtonStyle.outline,
                            dense: true,
                            circular: true,
                            onPressed: () => showTrialSheet(context, trial, canTrain: accessible),
                          ),
                          const SizedBox(width: 10),
                          if (accessible)
                            Expanded(
                              child: RomanButton(
                                label: config.labels.encounter,
                                style: RomanButtonStyle.primary,
                                dense: true,
                                expand: true,
                                icon: config.startIcon,
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
                                expand: true,
                                leading: Image.asset('assets/images/gem.png', width: 22, height: 22),
                                onPressed: status.affordable
                                    ? () async {
                                        final ok = await confirmLatin(
                                          context,
                                          title: 'Emere ${trial.name}?',
                                          body: 'Pretium: ${trial.price} gemmae. Habēs ${save.gems}. Aditus perpetuus erit.',
                                          yes: 'Eme',
                                        );
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
                              child: RomanButton(label: 'Clausa', style: RomanButtonStyle.locked, dense: true, expand: true, icon: Icons.lock),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mastery of one skill as a coloured bar with its tier and percentage.
class _MasteryBar extends StatelessWidget {
  const _MasteryBar({required this.summary, this.named = false});
  final MasterySummary summary;
  final bool named;

  @override
  Widget build(BuildContext context) {
    final sm = summary;
    final color = sm.evaluated ? tierColor(sm.tier) : G.grey;
    final label = sm.evaluated ? '${tierLabel(sm.tier)} · ${sm.estimateText}' : tierLabel(MasteryTier.nova);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (named)
            Text(
              Skills.byId(sm.skillId).name,
              style: G.body(13, weight: 700, color: G.inkSoft),
              overflow: TextOverflow.ellipsis,
            ),
          Row(
            children: [
              // Pill-shaped gauge: a recessed grey rail and a glossy fill.
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFFC4BFB9), Color(0xFFD9D4CE)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: (sm.estimate ?? 0).clamp(0.0, 1.0),
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: LinearGradient(
                              colors: [Color.lerp(color, Colors.white, 0.22)!, color, Color.lerp(color, Colors.black, 0.12)!],
                              stops: const [0, 0.55, 1],
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
                style: G.body(14, weight: 700, color: sm.evaluated ? color : G.ink),
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

/// Introduction sheet: what the trial teaches, with contrasting examples.
void showTrialSheet(BuildContext context, Trial trial, {bool canTrain = false}) {
  final labels = configFor(trial.activity).labels;
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
          Text(trial.name, style: G.display(24, color: G.purpleTitle)),
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
                borderColor: G.goldPale,
                borderWidth: 2,
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
          Text('Pretium: ${trial.isFree ? 'grātīs' : '${trial.price} gemmae'} · ${trial.questionsToWin} ${labels.hits} · ${trial.hearts} corda', style: G.body(14, color: G.inkSoft, weight: 700)),
          const SizedBox(height: 6),
          Text(const Economy(kEconomy).defeatRule(), style: G.body(13, color: G.redDark, weight: 700)),
          if (canTrain) ...[
            const SizedBox(height: 16),
            RomanPanel(
              color: Colors.white,
              borderColor: G.goldPale,
              borderWidth: 2,
              shadow: false,
              radius: 12,
              child: Row(
                children: [
                  Expanded(
                    child: Text(labels.trainingBlurb, style: G.body(13, color: G.inkSoft)),
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
        title: Text('Ēlige partēs · ${trial.name}', style: G.display(18, color: G.purpleTitle)),
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
