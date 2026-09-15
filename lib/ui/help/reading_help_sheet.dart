import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../pedagogy/question.dart';
import '../../pedagogy/reading/reading_question_source.dart';
import '../../pedagogy/reading/reading_trials.dart';
import '../widgets/roman_widgets.dart';

/// Consultable help (Auxilium) for a reading question, through the same
/// mechanism as the other activities: before the answer, the vocabulary of the
/// passage (lemma and meaning) and a non-revealing grammatical hint; after the
/// answer, the analysis of the decisive form, the faithful rendering with its
/// source, why each other rendering misreads the Latin, and the whole verse in
/// both texts. The passage's French is never shown while the question is open.
Future<void> showReadingHelpSheet(BuildContext context, WidgetRef ref, {required Question q, required bool revealForm, String? note}) {
  final library = ref.read(readingLibraryProvider);
  final entry = q.reading.entry;
  final item = entry.item;
  final passage = entry.passage;
  final r = entry.renderings;
  final hint = item.hint.isNotEmpty ? item.hint : (ReadingTrials.hints[item.trialId] ?? '');
  final correct = r.correct.first;
  final sourceLabel = correct.source == 'LSG' ? 'Louis Segond 1910${correct.ref.isEmpty ? '' : ' (${correct.ref})'}' : 'interpretātiō paedagōgica (nōn Segond)';

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
            Expanded(child: Text(library.corpus.latinRef(passage.ref), style: G.display(22, color: G.purple))),
            RomanButton(label: 'Claude', style: RomanButtonStyle.neutral, dense: true, onPressed: () => Navigator.pop(ctx)),
          ]),
          const SizedBox(height: 6),
          Text(passage.text, style: G.body(18, weight: 800, color: G.purpleDark, height: 1.35)),
          if (note != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(note, style: G.body(15, weight: 700))),
          if (!revealForm && hint.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Cōnsilium', style: G.display(14, color: G.goldDark)),
            Text(hint, style: G.body(14, height: 1.35)),
          ],
          if (revealForm) ...[
            const SizedBox(height: 12),
            RomanPanel(
              color: Colors.white,
              borderColor: G.gold,
              radius: 14,
              shadow: false,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.target.span, style: G.display(26, color: G.purpleDark)),
                Text('${item.target.analysis} (${item.target.lemmaId})', style: G.body(15, weight: 700)),
                if (item.note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(item.note, style: G.body(13, color: G.inkSoft, style: FontStyle.italic))),
                const SizedBox(height: 8),
                Text('Interpretātiō vēra', style: G.display(14, color: G.goldDark)),
                Text(correct.text, style: G.body(16, weight: 700, color: G.greenDark)),
                Text('Fōns: $sourceLabel', style: G.body(11, color: G.inkSoft)),
                if (r.correct.length > 1) ...[
                  const SizedBox(height: 4),
                  Text('Etiam accipitur: ${r.correct.skip(1).map((c) => '«${c.text}»').join(' · ')}', style: G.body(13, color: G.inkSoft, style: FontStyle.italic)),
                ],
              ]),
            ),
            const SizedBox(height: 14),
            Text('Interpretātiōnēs falsae', style: G.display(16, color: G.goldDark)),
            for (final d in r.distractors)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: RomanPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: const Color(0xFFFFF4F5),
                  borderColor: G.marbleDark,
                  shadow: false,
                  radius: 12,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d.text, style: G.body(15, weight: 700, color: G.redDark)),
                    Text('«${d.span}»: ${d.correctAnalysis}, nōn ${d.wrongAnalysis}. ${d.explanation}', style: G.body(13, height: 1.3)),
                    Text(d.shift, style: G.body(12, color: G.inkSoft, style: FontStyle.italic)),
                    Text(ReadingQuestionSource.skillName(d.skillId), style: G.body(11, color: G.purple, weight: 700)),
                  ]),
                ),
              ),
            if (r.verse.isNotEmpty || passage.verse != passage.text) ...[
              const SizedBox(height: 14),
              Text('Versus integer', style: G.display(16, color: G.goldDark)),
              Text(passage.verse, style: G.body(14, height: 1.35)),
              if (r.verse.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text('${r.verse}${r.verseRef.isEmpty ? '' : '  (${r.verseRef})'}', style: G.body(14, color: G.inkSoft, height: 1.35))),
            ],
          ],
          const SizedBox(height: 14),
          Text('Vocābula', style: G.display(16, color: G.goldDark)),
          const SizedBox(height: 4),
          for (final w in passage.words)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(width: 130, child: Text(w.form, style: G.body(15, weight: 800, color: G.purpleDark))),
                Expanded(child: Text('${w.lemma}${(entry.gloss(w.lemma) ?? '').isEmpty ? '' : ' — ${entry.gloss(w.lemma)}'}', style: G.body(14))),
              ]),
            ),
          const SizedBox(height: 20),
          Text('Fontēs: ${library.corpus.edition.title} · ${entry.renderings.correct.first.source == 'LSG' ? 'Louis Segond 1910' : 'Louis Segond 1910 (versus), interpretātiō paedagōgica (sententia)'} · glōssae: Collatinus (GPL) et auctōrēs lūdī.', style: G.body(11, color: G.inkSoft)),
        ],
      ),
    ),
  );
}
