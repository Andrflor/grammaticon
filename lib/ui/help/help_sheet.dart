import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../linguistics/help/paradigm_help.dart';
import '../../linguistics/model/analysis.dart';
import '../../linguistics/model/grammar.dart';
import '../widgets/roman_widgets.dart';

/// Consultable help: principal parts, relevant tables, decomposition and a
/// near-form contrast. Returns when the sheet is closed.
Future<void> showHelpSheet(BuildContext context, WidgetRef ref, {required String lemmaId, FormEntry? form, String? note}) {
  final analyzer = ref.read(analyzerProvider);
  final paradigm = analyzer.paradigmOf(lemmaId);
  final help = ParadigmHelp(paradigm);
  final verb = paradigm.verb;
  final tables = form == null ? [help.finiteTable(Mood.indicativus, Voice.activum, Tense.values), help.nominalTable()] : help.tablesFor(form.analysis);
  final decomposition = form == null ? null : help.decompose(form);
  final near = form == null ? null : help.nearForm(form.analysis);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.4,
      builder: (ctx, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.all(18),
        children: [
          Row(children: [
            Expanded(child: Text(verb.lemma, style: G.display(26, color: G.purple))),
            RomanButton(label: 'Claude', style: RomanButtonStyle.neutral, dense: true, onPressed: () => Navigator.pop(ctx)),
          ]),
          Text(help.principalParts(), style: G.body(18, weight: 800, color: G.purpleDark)),
          Text(help.classification(), style: G.body(14, color: G.inkSoft)),
          if (verb.notes.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(verb.notes, style: G.body(13, color: G.inkSoft, style: FontStyle.italic))),
          if (note != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(note, style: G.body(15, weight: 700))),
          if (form != null) ...[
            const SizedBox(height: 12),
            RomanPanel(
              color: Colors.white,
              borderColor: G.gold,
              radius: 14,
              shadow: false,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(form.surface, style: G.display(28, color: G.purpleDark)),
                Text(form.analysis.describe(), style: G.body(15, weight: 700)),
                if (form.analysis.effectiveSemanticVoice != form.analysis.voice)
                  Text('Fōrma passīva, sēnsus āctīvus (dēpōnēns).', style: G.body(13, color: G.inkSoft, style: FontStyle.italic)),
                if (form.analysis.semanticTense != null)
                  Text('Fōrma ${form.analysis.tense!.latin.toLowerCase()}, sēnsus ${form.analysis.semanticTense!.latin.toLowerCase()}.', style: G.body(13, color: G.inkSoft, style: FontStyle.italic)),
                if (decomposition != null) ...[
                  const SizedBox(height: 8),
                  Text('Dīvīsiō', style: G.display(14, color: G.goldDark)),
                  Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 6, children: [
                    _Piece(decomposition.stem, 'thema', G.purple),
                    if (decomposition.marker.isNotEmpty) ...[Text('+', style: G.body(18)), _Piece(decomposition.marker, 'signum', G.goldDark)],
                    if (decomposition.ending.isNotEmpty) ...[Text('+', style: G.body(18)), _Piece(decomposition.ending, 'dēsinentia', G.greenDark)],
                  ]),
                  Text(decomposition.note, style: G.body(12, color: G.inkSoft)),
                ] else
                  Padding(padding: const EdgeInsets.only(top: 6), child: Text('Dīvīsiō in thema et dēsinentiam hīc nōn datur (fōrma irregulāris, composita aut nōminālis).', style: G.body(12, color: G.inkSoft, style: FontStyle.italic))),
                if (near != null) ...[
                  const SizedBox(height: 8),
                  Text('Comparā', style: G.display(14, color: G.goldDark)),
                  Text('${form.surface} (${_short(form.analysis)})  ≠  ${near.surface} (${_short(near.analysis)})', style: G.body(15, weight: 700)),
                ],
              ]),
            ),
          ],
          for (final t in tables) ...[
            const SizedBox(height: 14),
            Text(t.title, style: G.display(16, color: G.goldDark)),
            const SizedBox(height: 6),
            HelpTableView(t, highlight: form?.surface),
            if (t.note.isNotEmpty) Text(t.note, style: G.body(12, color: G.inkSoft, style: FontStyle.italic)),
          ],
          if (paradigm.absent.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('Fōrmae absentēs', style: G.display(16, color: G.goldDark)),
            for (final a in paradigm.absent.take(12))
              Text('• ${a.selectorPrefix}: ${a.status.latin}${a.note.isNotEmpty ? ' — ${a.note}' : ''}', style: G.body(12, color: G.inkSoft)),
          ],
          const SizedBox(height: 20),
          Text('Fōns: Allen & Greenough, New Latin Grammar (${verb.provenance.join(', ')}).', style: G.body(11, color: G.inkSoft)),
        ],
      ),
    ),
  );
}

String _short(Analysis a) {
  final b = <String>[];
  if (a.person != null) b.add('${a.person!.index1} ${a.number!.key}');
  if (a.tense != null) b.add(a.tense!.latin.toLowerCase());
  if (a.mood != Mood.indicativus) b.add(a.mood.latin.toLowerCase());
  if (a.voice == Voice.passivum) b.add('pass.');
  return b.join(' ');
}

class _Piece extends StatelessWidget {
  const _Piece(this.text, this.label, this.color);
  final String text;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), child: Text(text, style: G.display(18, color: Colors.white))),
        Text(label, style: G.body(11, color: G.inkSoft)),
      ]);
}

/// Paradigm table with an optional highlighted surface. A cell may list
/// several surfaces separated by " / "; any of them matches.
class HelpTableView extends StatelessWidget {
  const HelpTableView(this.t, {super.key, this.highlight});
  final HelpTable t;
  final String? highlight;

  bool _matches(String cell) => highlight != null && (cell == highlight || cell.split(' / ').contains(highlight));
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.all(color: G.marbleDark, width: 1, borderRadius: BorderRadius.circular(8)),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: G.purple),
              children: [
                const Padding(padding: EdgeInsets.all(6), child: SizedBox()),
                for (final c in t.columns) Padding(padding: const EdgeInsets.all(6), child: Text(c, style: G.body(13, color: Colors.white, weight: 800))),
              ],
            ),
            for (final r in t.rows)
              TableRow(children: [
                Padding(padding: const EdgeInsets.all(6), child: Text(r.label, style: G.body(13, color: G.inkSoft, weight: 800))),
                for (final c in r.cells)
                  Container(
                    padding: const EdgeInsets.all(6),
                    color: _matches(c) ? G.goldLight : null,
                    child: Text(c, style: G.body(14, weight: _matches(c) ? 800 : 600, color: c.startsWith('—') || c.startsWith('(') ? G.inkSoft : G.ink)),
                  ),
              ]),
          ],
        ),
      );
}
