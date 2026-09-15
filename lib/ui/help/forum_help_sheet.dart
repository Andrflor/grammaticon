import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../linguistics/help/nominal_help.dart';
import '../../pedagogy/forum/forum_question_source.dart';
import '../../pedagogy/forum/syntagma.dart';
import '../../pedagogy/question.dart';
import '../../pedagogy/trials.dart';
import '../widgets/roman_widgets.dart';
import 'help_sheet.dart' show HelpTableView;

/// Consultable help for a Forum question: dictionary entry, classification,
/// the card's pedagogical note, the phrase (for a contextual item), the
/// paradigm tables (the asked form highlighted once revealed) and the
/// stem/ending segmentation when it is sound.
Future<void> showForumHelpSheet(BuildContext context, WidgetRef ref, {required Question q, required bool revealForm, String? note}) {
  final analyzer = ref.read(nominalAnalyzerProvider);
  final payload = q.forum;
  final lex = payload.lexeme;
  final help = NominalHelp(analyzer, lex);
  final trial = Trials.byId(q.trialId);
  final form = revealForm ? payload.target : null;
  final seg = form == null ? null : help.segment(form);
  final others = form == null ? const <String>[] : payload.analyses.where((f) => f.analysis != form.analysis).map((f) => '${f.analysis.describe()} (${analyzer.lexeme(f.analysis.lemmaId).lemma})').toSet().toList();
  final tables = help.tables(highlight: form);
  final syntagma = q.syntagma;

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
            Expanded(child: Text(lex.lemma, style: G.display(26, color: G.purple))),
            RomanButton(label: 'Claude', style: RomanButtonStyle.neutral, dense: true, onPressed: () => Navigator.pop(ctx)),
          ]),
          Text(lex.dictionaryEntry, style: G.body(18, weight: 800, color: G.purpleDark)),
          Text(help.classification(), style: G.body(14, color: G.inkSoft)),
          if (lex.notes.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(lex.notes, style: G.body(13, color: G.inkSoft, style: FontStyle.italic))),
          if (trial.helpNote.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: RomanPanel(
                color: G.goldWash,
                borderColor: G.goldPale,
                radius: 12,
                shadow: false,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(trial.helpNote, style: G.body(14, weight: 700, color: G.purpleDark)),
              ),
            ),
          if (note != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(note, style: G.body(15, weight: 700))),
          if (syntagma != null) ...[
            const SizedBox(height: 12),
            Text('Sententia', style: G.display(14, color: G.goldDark)),
            SyntagmaText(syntagma, size: 22),
            if (form != null && payload.syntagma != null && payload.syntagma!.note.isNotEmpty) Text(payload.syntagma!.note, style: G.body(14, color: G.inkSoft, style: FontStyle.italic)),
          ],
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
                if (seg != null) ...[
                  const SizedBox(height: 8),
                  Text('Dīvīsiō', style: G.display(14, color: G.goldDark)),
                  Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 6, children: [
                    _Piece(seg.stem, 'thema', G.purple),
                    Text('+', style: G.body(18)),
                    _Piece(seg.ending, 'dēsinentia', G.greenDark),
                  ]),
                ] else
                  Padding(padding: const EdgeInsets.only(top: 6), child: Text('Fōrma propria: dīvīsiō in thema et dēsinentiam hīc nōn datur.', style: G.body(12, color: G.inkSoft, style: FontStyle.italic))),
                if (others.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Etiam', style: G.display(14, color: G.goldDark)),
                  Text(others.join(' · '), style: G.body(14, weight: 700)),
                ],
              ]),
            ),
          ],
          for (final t in tables) ...[
            const SizedBox(height: 14),
            Text(t.title, style: G.display(16, color: G.goldDark)),
            const SizedBox(height: 6),
            HelpTableView(t, highlight: form?.surface),
          ],
          const SizedBox(height: 20),
          Text('Fōns: Allen & Greenough, New Latin Grammar${lex.provenance.isEmpty ? '' : ' (${lex.provenance.join(', ')})'}.', style: G.body(11, color: G.inkSoft)),
        ],
      ),
    ),
  );
}

/// A phrase with its marked word highlighted (`rosae {spīnae} flōrent`).
class SyntagmaText extends StatelessWidget {
  const SyntagmaText(this.display, {super.key, this.size = 28, this.color = G.purpleDark, this.highlight = G.goldLight, this.align = TextAlign.center});
  final String display;
  final double size;
  final Color color;
  final Color highlight;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final runs = SyntagmaRun.parse(display);
    return Text.rich(
      TextSpan(children: [
        for (final r in runs)
          r.target
              ? WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: highlight, borderRadius: BorderRadius.circular(8), border: Border.all(color: G.gold, width: 2)),
                    child: Text(r.text, style: G.display(size, color: color, letterSpacing: 1)),
                  ),
                )
              : TextSpan(text: r.text, style: G.display(size, color: color, letterSpacing: 1)),
      ]),
      textAlign: align,
    );
  }
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
