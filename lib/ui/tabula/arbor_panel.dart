/// La Tabula de l'arbre des compétences : les nœuds visibles, groupés par leur
/// parent d'affichage, avec l'estimation agrégée de leurs maillons, le palier
/// et les hypothèses ouvertes (maillons suspects après une erreur).
library;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../arbor/arbor.dart';
import '../../arbor/evidence.dart';
import '../../arbor/skill.dart';
import '../../audio/audio_service.dart';
import '../../pedagogy/mastery.dart';
import '../widgets/roman_widgets.dart';

/// Agrégat d'un nœud : moyenne des estimations de ses maillons pratiqués, palier
/// le plus bas atteint, nombre de maillons pratiqués et d'hypothèses ouvertes.
class ArborSummary {
  const ArborSummary({required this.estimate, required this.tier, required this.practised, required this.total, required this.hypotheses, required this.observations});
  final double? estimate;
  final MasteryTier tier;
  final int practised;
  final int total;
  final int hypotheses;
  final int observations;
  bool get evaluated => estimate != null;
  String get estimateText => evaluated ? '${(estimate! * 100).round()} %' : '—';

  /// Les feuilles comptées : le nœud lui-même s'il porte des observations, et
  /// ses descendants d'affichage ainsi que ses composants (cases L2 exclues,
  /// elles pèsent par leurs maillons).
  static ArborSummary of(Arbor arbor, ArborEvidence ev, String id, MasteryConfig cfg, DateTime now) {
    final leaves = <String>{};
    void visit(String x) {
      final s = arbor[x];
      if (s == null) return;
      if (s.stratum != Stratum.notio && s.stratum != Stratum.cella && s.probatur.isNotEmpty) leaves.add(x);
      for (final c in arbor.liberi[x] ?? const <Skill>[]) {
        if (c.visibilis) visit(c.id);
      }
    }
    visit(id);
    var sum = 0.0, n = 0, obs = 0, hyp = 0;
    MasteryTier? lowest;
    for (final l in leaves) {
      final r = ev.records[l];
      if (ev.hypotheses.containsKey(l)) hyp++;
      if (r == null || r.autonomousCount == 0) continue;
      final rr = r.asOf(now, cfg);
      if (rr.estimate != null) {
        sum += rr.estimate!;
        n++;
      }
      obs += rr.autonomousCount;
      final t = rr.tier(cfg);
      if (lowest == null || t.index < lowest.index) lowest = t;
    }
    return ArborSummary(estimate: n == 0 ? null : sum / n, tier: n == 0 ? MasteryTier.nova : lowest!, practised: n, total: leaves.length, hypotheses: hyp, observations: obs);
  }
}

/// Racines d'affichage de l'arbre, dans l'ordre de la Tabula.
const kArborRoots = ['v', 'n', 'adj', 'pron', 'num', 'syn', 'lect', 'lex'];

class ArborTabula extends ConsumerWidget {
  const ArborTabula({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arbor = ref.watch(arborProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final id in kArborRoots) if (arbor[id] != null) ArborNode(arbor: arbor, id: id, depth: 0)],
    );
  }
}

class ArborNode extends ConsumerStatefulWidget {
  const ArborNode({super.key, required this.arbor, required this.id, required this.depth});
  final Arbor arbor;
  final String id;
  final int depth;
  @override
  ConsumerState<ArborNode> createState() => _ArborNodeState();
}

class _ArborNodeState extends ConsumerState<ArborNode> {
  late bool _open = widget.depth == 0;

  @override
  Widget build(BuildContext context) {
    final ev = ref.watch(profileProvider.select((s) => s.arbor));
    final cfg = ref.watch(masteryConfigProvider);
    final arbor = widget.arbor;
    final s = arbor[widget.id]!;
    final children = (arbor.liberi[s.id] ?? const <Skill>[]).where((c) => c.visibilis && c.stratum != Stratum.cella).toList();
    final leaf = children.isEmpty;
    final sum = ArborSummary.of(arbor, ev, s.id, cfg, DateTime.now());
    final root = widget.depth == 0;
    final inset = root ? 0.0 : 24.0;
    final compact = MediaQuery.sizeOf(context).width < 720;
    final stats = <Widget>[
      if (!leaf && sum.total > 1) Text('${sum.practised}/${sum.total}', style: G.body(root ? 16 : 14, color: G.inkSoft, weight: 700)),
      if (sum.hypotheses > 0) StatChip('${sum.hypotheses} suspecta', icon: Icons.help_outline, color: G.red, textColor: Colors.white),
      if (sum.evaluated) Text(sum.estimateText, style: G.body(root ? 19 : 17, weight: 800, color: tierColor(sum.tier))),
      MasteryBadge(sum.tier, dense: !root || compact),
    ];
    return Padding(
      padding: EdgeInsets.only(left: inset, right: inset, top: root ? 10 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RomanPanel(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: root ? 9 : 7),
            color: G.marble,
            borderColor: root ? G.gold : G.goldPale,
            borderWidth: root ? 3 : 2,
            radius: root ? 16 : 12,
            shadow: root,
            child: InkWell(
              onTap: () {
                AudioService.current?.play(leaf ? Sfx.folium : Sfx.tactus);
                if (leaf) {
                  _showNode(context, s, sum, ev);
                } else {
                  setState(() => _open = !_open);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Icon(leaf ? Icons.chevron_right : (_open ? Icons.expand_more : Icons.chevron_right), color: leaf ? G.goldDark : (root ? G.purpleTitle : G.purpleRoyal), size: root ? 28 : 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.nomen, style: root ? G.display(22, color: G.purpleTitle, letterSpacing: 1.0) : G.body(14, weight: 800)),
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
          if (_open) for (final c in children) ArborNode(arbor: arbor, id: c.id, depth: widget.depth + 1),
        ],
      ),
    );
  }

  void _showNode(BuildContext context, Skill s, ArborSummary sum, ArborEvidence ev) {
    final arbor = widget.arbor;
    final confusions = arbor.confusiones[s.id] ?? const [];
    final r = ev.records[s.id];
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: RomanPanel(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.nomen, style: G.display(22, color: G.purpleTitle)),
              const SizedBox(height: 6),
              Text(s.quid, style: G.body(15, height: 1.4)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  MasteryBadge(sum.tier),
                  if (sum.evaluated) StatChip(sum.estimateText, icon: Icons.insights),
                  if (r != null) StatChip('${r.autonomousCorrect} rēctē · ${r.autonomousWrong} errāta', icon: Icons.check_circle_outline),
                  if (ev.hypotheses.containsKey(s.id)) StatChip('suspectum', icon: Icons.help_outline, color: G.red, textColor: Colors.white),
                ],
              ),
              if (s.requirit.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('Requīrit', style: G.body(14, weight: 800, color: G.purpleTitle)),
                for (final id in s.requirit) Text('• ${arbor[id]?.nomen ?? id}', style: G.body(14)),
              ],
              if (confusions.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('Cōnfunditur cum', style: G.body(14, weight: 800, color: G.purpleTitle)),
                for (final c in confusions.take(6)) Text('• ${arbor[c.cum]?.nomen ?? c.cum}${c.nota.isEmpty ? '' : ' — ${c.nota}'}', style: G.body(14)),
              ],
              if (s.fontes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(s.fontes.join(' · '), style: G.body(12, color: G.inkSoft, style: FontStyle.italic)),
              ],
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: RomanButton(label: 'Claude', style: RomanButtonStyle.gold, onPressed: () => Navigator.of(ctx).pop())),
            ],
          ),
        ),
      ),
    );
  }
}
