import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/app.dart';
import '../../app/providers.dart';
import '../../audio/audio_service.dart';
import '../../app/theme.dart';
import '../../pedagogy/errata.dart';
import '../../pedagogy/mastery.dart';
import '../../pedagogy/mastery_view.dart';
import '../../pedagogy/progression.dart';
import '../../pedagogy/reading/vocab_progress.dart';
import '../../pedagogy/skills.dart';
import '../../pedagogy/trials.dart';
import '../activity/activity_config.dart';
import '../trials/trial_selection_screen.dart';
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
            TopBar(title: 'Tabula perītiārum', gems: save.gems),
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
                    const _ExposurePanel(),
                    for (final root in Skills.roots()) _SkillNode(skill: root, depth: 0),
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

/// Vocabulary met in the Theatrum: exposure counts, deliberately shown apart
/// from the mastery tree (meeting a word is not knowing it).
class _ExposurePanel extends ConsumerWidget {
  const _ExposurePanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(profileProvider);
    final lang = save.settings.translationLanguage;
    final set = ref.watch(readingLibraryProvider).forLanguage(lang.code);
    if (set == null) return const SizedBox.shrink();
    final playable = set.playableLemmas;
    final led = save.exposure;
    final met = playable.where((l) => led.of(l).seen > 0).length;
    final repeated = playable.where((l) => led.of(l).seen > 1).length;
    final tested = playable.where((l) => led.of(l).tested > 0).length;
    final vp = VocabProgress.compute(set, led);
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
                Expanded(child: Text('Vocābula Theātrī (${lang.latin})', style: G.display(18, color: G.goldLight, letterSpacing: 1.0))),
                StatChip('Gradus ${vp.level} / ${vp.bands.length}', icon: Icons.stairs, color: G.gold, textColor: G.purpleDark),
              ],
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(children: [
                TextSpan(text: 'Parāta: ${playable.length}', style: strong),
                TextSpan(text: '  ·  Obvia: $met  ·  Iterāta: $repeated  ·  Interrogāta: $tested', style: light),
              ]),
            ),
            const SizedBox(height: 8),
            for (final b in [...vp.bands, if (vp.names.total > 0) vp.names]) _BandRow(b: b, open: b.band == 0 || b.band <= vp.level),
            const SizedBox(height: 6),
            Text(
              'Obviam fierī nōn est scīre: obvium vīsum est; nōtum bis in aliō locō vīsum aut rēctē interrogātum; firmum bis rēctē interrogātum. Hī numerī perītiam grammaticam nōn aestimant.',
              style: G.body(14, color: G.goldLight, style: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

/// One vocabulary band: known / met / total with a bar.
class _BandRow extends StatelessWidget {
  const _BandRow({required this.b, required this.open});
  final BandProgress b;
  final bool open;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(width: compact ? 92 : 136, child: Text(b.latin, style: G.body(13, color: open ? Colors.white : G.goldLight, weight: 700), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Expanded(
              // Rounded boxes, not a clipped stack: Impeller on OpenGL ES does
              // not anti-alias clips.
              child: Stack(
                children: [
                  Container(height: 12, decoration: const BoxDecoration(color: Color(0x66200A40), borderRadius: BorderRadius.all(Radius.circular(6)))),
                  FractionallySizedBox(widthFactor: b.metShare.clamp(0.0, 1.0), child: Container(height: 12, decoration: BoxDecoration(color: G.purpleLight, borderRadius: BorderRadius.circular(6)))),
                  FractionallySizedBox(widthFactor: b.knownShare.clamp(0.0, 1.0), child: Container(height: 12, decoration: BoxDecoration(color: G.gold, borderRadius: BorderRadius.circular(6)))),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text('${b.nota + b.firma}/${b.total}${open || compact ? '' : ' · clausus'}', style: G.body(13, color: Colors.white, weight: 700)),
            if (!open && compact) ...[const SizedBox(width: 4), const Icon(Icons.lock, size: 14, color: G.goldLight)],
          ],
        ),
      );
  }
}

class _SkillNode extends ConsumerStatefulWidget {
  const _SkillNode({required this.skill, required this.depth});
  final Skill skill;
  final int depth;
  @override
  ConsumerState<_SkillNode> createState() => _SkillNodeState();
}

class _SkillNodeState extends ConsumerState<_SkillNode> {
  late bool _open = widget.depth == 0;

  @override
  Widget build(BuildContext context) {
    final save = ref.watch(profileProvider);
    final cfg = ref.watch(masteryConfigProvider);
    final s = widget.skill;
    final children = Skills.children(s.id);
    final leaf = children.isEmpty;
    final sum = MasterySummary.forSkill(save, s.id, cfg);
    final root = widget.depth == 0;
    // Nested rows sit 24 px inside their parent on both sides (relative to the
    // parent row, which is itself already inset).
    final inset = root ? 0.0 : 24.0;
    final chevronColor = root ? G.purpleTitle : G.purpleRoyal;
    // On phones the figures go under the name instead of crowding the row.
    final compact = MediaQuery.sizeOf(context).width < 720;

    final stats = <Widget>[
      if (!s.future) ...[
        if (!leaf && sum.totalLeaves > 1) Text('${sum.evaluatedLeaves}/${sum.totalLeaves}', style: G.body(root ? 16 : 14, color: G.inkSoft, weight: 700)),
        if (sum.evaluated) Text(sum.estimateText, style: G.body(root ? 19 : 17, weight: 800, color: tierColor(sum.tier))),
        MasteryBadge(sum.tier, dense: !root || compact),
      ],
    ];

    return Padding(
      padding: EdgeInsets.only(left: inset, right: inset, top: root ? 10 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RomanPanel(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: root ? 9 : 7),
            color: s.future ? const Color(0xFFEFE6D4) : G.marble,
            borderColor: root ? G.gold : G.goldPale,
            borderWidth: root ? 3 : 2,
            radius: root ? 16 : 12,
            shadow: root,
            child: InkWell(
              onTap: () {
                AudioService.current?.play(leaf ? Sfx.folium : Sfx.tactus);
                if (leaf) {
                  _showSkill(context, s, sum);
                } else {
                  setState(() => _open = !_open);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      leaf ? Icons.chevron_right : (_open ? Icons.expand_more : Icons.chevron_right),
                      color: leaf ? G.goldDark : chevronColor,
                      size: root ? 28 : 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name, style: root ? G.display(22, color: G.purpleTitle, letterSpacing: 1.0) : G.body(14, weight: 800)),
                          if (s.hint.isNotEmpty) Text(s.hint, style: G.body(13, color: G.inkSoft)),
                          if (s.future)
                            Text(
                              'Ventūrum: structūra parāta, nōndum lūditur.',
                              style: G.body(12, color: G.inkSoft, style: FontStyle.italic),
                            ),
                          if (compact && stats.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Wrap(spacing: 10, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: stats),
                            ),
                        ],
                      ),
                    ),
                    if (!compact)
                      for (final w in stats) ...[const SizedBox(width: 10), w],
                  ],
                ),
              ),
            ),
          ),
          if (_open)
            for (final c in children) _SkillNode(skill: c, depth: widget.depth + 1),
        ],
      ),
    );
  }

  void _showSkill(BuildContext context, Skill s, MasterySummary sum) {
    final save = ref.read(profileProvider);
    final trials = Trials.forSkill(s.id);
    String date(DateTime? d) => d == null ? '—' : '${d.day}.${d.month}.${d.year}';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(s.name, style: G.display(22, color: G.purpleTitle)),
                  ),
                  MasteryBadge(sum.tier),
                ],
              ),
              if (s.hint.isNotEmpty) Text(s.hint, style: G.body(14, color: G.inkSoft)),
              const SizedBox(height: 12),
              if (!sum.evaluated)
                Text('Nōn aestimāta: nūlla respōnsiō autonoma adhūc.', style: G.body(15, weight: 700))
              else ...[
                _row('Perītia aestimāta', sum.estimateText),
                _row('Respōnsiōnēs autonomae', '${sum.observations}'),
                _row('Verba dīversa', '${sum.lemmas}'),
                _row('Diēs exercitātiōnis', '${sum.sessions}'),
                _row('Prīma respōnsiō recēns rēcta', sum.recentFirstTry == null ? '—' : '${(sum.recentFirstTry! * 100).round()} %'),
                _row('Ultima exercitātiō', date(sum.lastPractice)),
                _row('Fīdūcia aestimātiōnis', sum.reliability.latin),
                if (sum.reliability == Reliability.incerta)
                  Text(
                    'Paucae observātiōnēs: aestimātiō incerta.',
                    style: G.body(13, color: G.inkSoft, style: FontStyle.italic),
                  ),
              ],
              const SizedBox(height: 14),
              Text('Certāmina et contrōversiae', style: G.display(16, color: G.goldDark)),
              const SizedBox(height: 6),
              for (final t in trials) _trialLine(ctx, t, Progression.status(save, t)),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(child: Text(k, style: G.body(15))),
        Text(v, style: G.body(15, weight: 800)),
      ],
    ),
  );

  Widget _trialLine(BuildContext ctx, Trial t, TrialStatus st) {
    final color = switch (st.access) {
      TrialAccess.accessible => G.green,
      TrialAccess.purchasable => G.amber,
      TrialAccess.locked => G.grey,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RomanPanel(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.white,
        borderColor: G.goldPale,
        borderWidth: 2,
        radius: 12,
        shadow: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${t.name} · ${t.subtitle}', style: G.body(15, weight: 800)),
                  if (st.access != TrialAccess.accessible)
                    Text('${t.price} gemmae${st.missing.isEmpty ? '' : ' · dēsunt: ${st.missing.map((m) => m.name).join(', ')}'}', style: G.body(12, color: G.inkSoft)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
              child: Text(st.access.latin, style: G.body(12, color: Colors.white, weight: 800)),
            ),
            const SizedBox(width: 8),
            RomanButton(
              label: 'Ī',
              style: RomanButtonStyle.gold,
              dense: true,
              onPressed: () {
                Navigator.pop(ctx);
                pushScreen(context, TrialSelectionScreen(activity: t.activity, highlightTrialId: t.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}
