import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../linguistics/help/declension_help.dart';
import '../../pedagogy/noun_question_generator.dart';
import '../../pedagogy/question.dart';
import '../widgets/roman_widgets.dart';
import 'help_sheet.dart' show HelpTableView;

/// Consultable help for a noun question: dictionary entry, classification,
/// declension table (the asked form highlighted once revealed) and the
/// stem/ending segmentation when it is sound.
Future<void> showNounHelpSheet(BuildContext context, WidgetRef ref, {required Question q, required bool revealForm, String? note}) {
  final analyzer = ref.read(nounAnalyzerProvider);
  final paradigm = analyzer.paradigmOf(q.lemmaId);
  final help = DeclensionHelp(paradigm);
  final noun = paradigm.noun;
  final form = revealForm ? q.noun.target : null;
  final seg = form == null ? null : help.segment(form);
  final others = form == null
      ? const <String>[]
      : q.noun.analyses.where((f) => f.analysis != form.analysis).map((f) => '${f.analysis.describe()} (${analyzer.noun(f.analysis.lemmaId).lemma})').toSet().toList();

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
            Expanded(child: Text(noun.lemma, style: G.display(26, color: G.purple))),
            RomanButton(label: 'Claude', style: RomanButtonStyle.neutral, dense: true, onPressed: () => Navigator.pop(ctx)),
          ]),
          Text(noun.dictionaryEntry, style: G.body(18, weight: 800, color: G.purpleDark)),
          Text(help.classification(), style: G.body(14, color: G.inkSoft)),
          if (noun.notes.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(noun.notes, style: G.body(13, color: G.inkSoft, style: FontStyle.italic))),
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
                Text(form.analysis.describe(withDeclension: true), style: G.body(15, weight: 700)),
                if (seg != null) ...[
                  const SizedBox(height: 8),
                  Text('Dīvīsiō', style: G.display(14, color: G.goldDark)),
                  Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 6, children: [
                    _Piece(seg.stem, 'thema', G.purple),
                    Text('+', style: G.body(18)),
                    _Piece(seg.ending, 'dēsinentia', G.greenDark),
                  ]),
                ] else
                  Padding(padding: const EdgeInsets.only(top: 6), child: Text('Fōrma irregulāris: dīvīsiō in thema et dēsinentiam hīc nōn datur.', style: G.body(12, color: G.inkSoft, style: FontStyle.italic))),
                if (others.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Etiam', style: G.display(14, color: G.goldDark)),
                  Text(others.join(' · '), style: G.body(14, weight: 700)),
                ],
              ]),
            ),
          ],
          const SizedBox(height: 14),
          Text('Dēclīnātiō', style: G.display(16, color: G.goldDark)),
          const SizedBox(height: 6),
          HelpTableView(help.table(), highlight: form?.surface),
          const SizedBox(height: 20),
          Text('Fōns: Allen & Greenough, New Latin Grammar (${noun.provenance.join(', ')}).', style: G.body(11, color: G.inkSoft)),
        ],
      ),
    ),
  );
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
