/// L'Iter à l'écran : la prochaine carte proposée par le parcours automatique,
/// pourquoi, à quel prix, et le bouton qui y va (en achetant si besoin).
library;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/app.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../audio/audio_service.dart';
import '../../pedagogy/iter.dart';
import '../activity/activity_config.dart';
import '../battle/battle_screen.dart';
import '../widgets/roman_widgets.dart';

/// Choix courant de l'Iter pour la sauvegarde courante.
final iterChoiceProvider = Provider<IterChoice?>((ref) => Iter.next(save: ref.watch(profileProvider), arbor: ref.watch(arborProvider), coverage: ref.watch(trialCoverageProvider), cfg: ref.watch(masteryConfigProvider)));

String causaLatin(IterCausa c) => switch (c) {
  IterCausa.remediatio => 'Remediātiō: quod nūper errātum est',
  IterCausa.repetitio => 'Repetītiō: quod repetendum est',
  IterCausa.frontier => 'Prōgressus: quod nunc discī potest',
};

/// Propose la prochaine carte et, si le joueur accepte, l'achète au besoin et
/// l'ouvre. [replace] remplace l'écran courant (depuis un combat terminé).
Future<void> showIter(BuildContext context, WidgetRef ref, {bool replace = false}) async {
  final choice = ref.read(iterChoiceProvider);
  final arbor = ref.read(arborProvider);
  if (choice == null) {
    showLatinSnack(context, 'Iter: nihil nunc prōpōnendum est.');
    return;
  }
  final t = choice.trial;
  final config = configFor(t.activity);
  final go = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: RomanPanel(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Iter · proximum', style: G.display(20, color: G.purpleTitle, letterSpacing: 1.0)),
            const SizedBox(height: 8),
            Text('${t.name} · ${t.activity.latin}', style: G.body(17, weight: 800)),
            if (t.subtitle.isNotEmpty) Text(t.subtitle, style: G.body(14, color: G.inkSoft)),
            const SizedBox(height: 10),
            Text(causaLatin(choice.causa), style: G.body(14, weight: 700, color: G.purpleTitle)),
            const SizedBox(height: 4),
            for (final n in choice.nodes) Text('• ${arbor[n]?.nomen ?? n}', style: G.body(14)),
            if (choice.mustBuy) ...[
              const SizedBox(height: 10),
              Text('Carta nōndum aperta: pretium ${t.price} gemmae, statim solvētur.', style: G.body(14, color: G.inkSoft, style: FontStyle.italic)),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                RomanButton(label: choice.mustBuy ? 'Eme et perge' : 'Perge', icon: config.startIcon, style: RomanButtonStyle.gold, onPressed: () => Navigator.of(ctx).pop(true)),
                RomanButton(label: 'Claude', style: RomanButtonStyle.neutral, onPressed: () => Navigator.of(ctx).pop(false)),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (go != true || !context.mounted) return;
  if (choice.mustBuy) {
    final done = await ref.read(profileProvider.notifier).purchase(t);
    if (!context.mounted) return;
    if (!done) {
      showLatinSnack(context, 'Emptiō nōn perfecta est.');
      return;
    }
    ref.read(audioProvider).play(Sfx.emptio);
  }
  final screen = BattleScreen(trial: t, focus: choice.nodes);
  if (replace) {
    await Navigator.of(context).pushReplacement(PageRouteBuilder(pageBuilder: (c, a, s) => screen, transitionsBuilder: (c, a, s, child) => FadeTransition(opacity: a, child: child), transitionDuration: const Duration(milliseconds: 220)));
  } else {
    await pushScreen(context, screen);
  }
}
