/// Aide consultable d'une question de cadre (Theatrum / Templum) : la fiche
/// d'aide de la carte (leçon, vocabulaire de la section), ce que la carte
/// exerce et, une fois la question résolue, la réponse acceptée expliquée.
library;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../arbor/skill.dart';
import '../../pedagogy/frames/frame_question_source.dart';
import '../../pedagogy/frames/frame_trials.dart';
import '../../pedagogy/question.dart';
import '../widgets/roman_widgets.dart';

Future<void> showFrameHelpSheet(BuildContext context, WidgetRef ref, {required Question q, required bool revealForm, String? note}) {
  final p = q.frame;
  final arbor = ref.read(arborProvider);
  final library = ref.read(frameLibraryProvider);
  // Le nœud de contexte de la carte, puis les maillons de grammaire qu'il suppose.
  final ids = <String>{...p.nodes, for (final id in p.nodes) ...(arbor[id]?.requirit ?? const <String>[])};
  final nodes = [for (final id in ids) arbor[id]].whereType<Skill>().where((s) => !s.id.startsWith('lect.vocabula.')).toList();
  final card = FrameTrials.cardsById[p.frame.card];
  final blocks = library.helpFor(p.frame);
  final paragraphs = <String>{...?card?.lesson, ...blocks.where((b) => b.type == 'text').map((b) => b.text)}.toList();
  final vocabulary = <String>{...blocks.where((b) => b.type == 'example').map((b) => b.text), ...?card?.examples}.toList();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, controller) => RomanPanel(
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              children: [
                Expanded(child: Text(card?.name ?? q.prompt, style: G.display(20, color: G.purpleTitle))),
                RomanButton(label: 'Claude', icon: Icons.close, style: RomanButtonStyle.gold, dense: true, onPressed: () => Navigator.of(ctx).pop()),
              ],
            ),
            const SizedBox(height: 4),
            Text(q.prompt, style: G.body(14, color: G.inkSoft)),
            const SizedBox(height: 8),
            Text(p.instance.surface, style: G.body(16, height: 1.4)),
            if (revealForm) ...[
              const SizedBox(height: 14),
              Text('Respōnsum', style: G.display(16, color: G.purpleTitle)),
              const SizedBox(height: 6),
              for (var i = 0; i < p.frame.choices.length; i++)
                if (p.frame.choices[i].accepted) ...[
                  Text(p.instance.choices[i], style: G.body(15, weight: 700)),
                  if (p.frame.choices[i].feedback.isNotEmpty) Text(p.frame.choices[i].feedback, style: G.body(14, height: 1.4)),
                ],
            ],
            if (paragraphs.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Lēctiō', style: G.display(16, color: G.purpleTitle)),
              const SizedBox(height: 6),
              for (final t in paragraphs) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: G.body(15, height: 1.4))),
            ],
            if (nodes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Quid hīc exercētur', style: G.display(16, color: G.purpleTitle)),
              const SizedBox(height: 6),
              for (final n in nodes) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• ${n.nomen}', style: G.body(15))),
            ],
            if (vocabulary.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Vocābula', style: G.display(16, color: G.purpleTitle)),
              const SizedBox(height: 6),
              Wrap(spacing: 12, runSpacing: 4, children: [for (final v in vocabulary) Text(v, style: G.body(14))]),
            ],
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(note, style: G.body(14, height: 1.4)),
            ],
          ],
        ),
      ),
    ),
  );
}
