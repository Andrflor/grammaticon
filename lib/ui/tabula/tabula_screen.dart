import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/app.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../pedagogy/mastery.dart';
import '../../pedagogy/mastery_view.dart';
import '../../pedagogy/progression.dart';
import '../../pedagogy/skills.dart';
import '../../pedagogy/trials.dart';
import '../coliseum/coliseum_screen.dart';
import '../widgets/roman_widgets.dart';

/// Skill tree with honest mastery estimates fed by real answers.
class TabulaScreen extends ConsumerWidget {
  const TabulaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(profileProvider);
    return Scaffold(
      body: Container(
        decoration: kScreenGradient,
        child: Column(
          children: [
            TopBar(title: 'Tabula perītiārum', gems: save.gems),
            Expanded(
              child: ContentColumn(
                maxWidth: 960,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  children: [
                    RomanPanel(
                      color: G.purpleDark,
                      borderColor: G.gold,
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('Gradūs:', style: G.body(14, color: G.goldLight, weight: 800)),
                          for (final t in MasteryTier.values) MasteryBadge(t, dense: true),
                          Text('· Certāmina victa: ${save.battlesWon} · āmissa: ${save.battlesLost}', style: G.body(13, color: Colors.white)),
                        ],
                      ),
                    ),
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
    final indent = widget.depth * 14.0;

    return Padding(
      padding: EdgeInsets.only(left: indent, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RomanPanel(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: s.future ? const Color(0xFFE9E0CC) : (leaf ? Colors.white : G.marble),
            borderColor: widget.depth == 0 ? G.gold : G.marbleDark,
            radius: 14,
            shadow: widget.depth == 0,
            child: InkWell(
              onTap: leaf ? () => _showSkill(context, s, sum) : () => setState(() => _open = !_open),
              child: Row(
                children: [
                  if (!leaf) Icon(_open ? Icons.expand_more : Icons.chevron_right, color: G.purple),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: widget.depth == 0 ? G.display(20, color: G.purple) : G.body(16, weight: 800)),
                        if (s.hint.isNotEmpty) Text(s.hint, style: G.body(13, color: G.inkSoft)),
                        if (s.future)
                          Text(
                            'Ventūrum: structūra parāta, nōndum lūditur.',
                            style: G.body(12, color: G.inkSoft, style: FontStyle.italic),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!s.future) ...[
                    if (!leaf && sum.totalLeaves > 1)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text('${sum.evaluatedLeaves}/${sum.totalLeaves}', style: G.body(13, color: G.inkSoft, weight: 700)),
                      ),
                    if (sum.evaluated)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(sum.estimateText, style: G.body(15, weight: 800, color: tierColor(sum.tier))),
                      ),
                    MasteryBadge(sum.tier, dense: true),
                    if (sum.reviewDue)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(Icons.history, color: G.red, size: 20),
                      ),
                  ],
                ],
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
                    child: Text(s.name, style: G.display(22, color: G.purple)),
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
                _row('Repetītiō dēbita', sum.reviewDue ? 'Ita' : 'Nōn'),
                _row('Fīdūcia aestimātiōnis', sum.reliability.latin),
                if (sum.reliability == Reliability.incerta)
                  Text(
                    'Paucae observātiōnēs: aestimātiō incerta.',
                    style: G.body(13, color: G.inkSoft, style: FontStyle.italic),
                  ),
              ],
              const SizedBox(height: 14),
              Text('Certāmina', style: G.display(16, color: G.goldDark)),
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
      TrialAccess.purchasable => G.gold,
      TrialAccess.locked => G.inkSoft,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RomanPanel(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.white,
        borderColor: G.marbleDark,
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
                pushScreen(context, ColiseumScreen(highlightTrialId: t.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}
