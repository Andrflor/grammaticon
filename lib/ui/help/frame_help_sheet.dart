/// Aide consultable d'une question de cadre (Theatrum / Templum) : la
/// consigne, les nœuds visés par la carte et, une fois la question résolue,
/// la ou les réponses acceptées avec leur explication.
library;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../pedagogy/frames/frame_question_source.dart';
import '../../pedagogy/question.dart';
import '../widgets/roman_widgets.dart';

Future<void> showFrameHelpSheet(BuildContext context, WidgetRef ref, {required Question q, required bool revealForm, String? note}) {
  final p = q.frame;
  final arbor = ref.read(arborProvider);
  final nodes = [for (final id in p.nodes) arbor[id]].whereType<Object>().toList();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, controller) => RomanPanel(
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(18),
          children: [
            Text(q.prompt, style: G.display(20, color: G.purpleTitle)),
            const SizedBox(height: 8),
            Text(p.instance.surface, style: G.body(16, height: 1.4)),
            const SizedBox(height: 14),
            Text('Quid hīc exercētur', style: G.display(16, color: G.purpleTitle)),
            const SizedBox(height: 6),
            for (final n in nodes)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• ${(n as dynamic).nomen}', style: G.body(15)),
              ),
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(note, style: G.body(14, height: 1.4)),
            ],
            const SizedBox(height: 14),
            RomanButton(label: 'Claude', icon: Icons.close, style: RomanButtonStyle.gold, onPressed: () => Navigator.of(ctx).pop()),
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
          ],
        ),
      ),
    ),
  );
}
