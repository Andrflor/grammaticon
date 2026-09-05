import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../audio/audio_service.dart';
import '../../economy/economy.dart';
import '../../pedagogy/mastery.dart';
import '../widgets/roman_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(profileProvider);
    final s = save.settings;
    final p = ref.read(profileProvider.notifier);
    final audio = ref.read(audioProvider);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [G.purpleDark, Color(0xFF2A1148)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Column(children: [
          TopBar(title: 'Optiōnēs', gems: save.gems),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                RomanPanel(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Sonus', style: G.display(18, color: G.purple)),
                    SwitchListTile(
                      value: s.soundOn,
                      title: Text('Sonī', style: G.body(16, weight: 700)),
                      onChanged: (v) {
                        p.updateSettings(s.copyWith(soundOn: v));
                        if (v) audio.play(Sfx.tactus);
                      },
                    ),
                    Text('Volūmen: ${(s.volume * 100).round()} %', style: G.body(15)),
                    Slider(value: s.volume, onChanged: (v) => p.updateSettings(s.copyWith(volume: v)), onChangeEnd: (_) => audio.play(Sfx.gemma)),
                  ]),
                ),
                const SizedBox(height: 12),
                RomanPanel(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Mōtus et tempora', style: G.display(18, color: G.purple)),
                    SwitchListTile(
                      value: s.reducedMotion,
                      title: Text('Mōtus minor', style: G.body(16, weight: 700)),
                      subtitle: Text('Minus animātiōnum; gemmae nōn volant.', style: G.body(13, color: G.inkSoft)),
                      onChanged: (v) => p.updateSettings(s.copyWith(reducedMotion: v)),
                    ),
                    Text('Mora post respōnsum rēctum: ${s.correctDelayMs} ms', style: G.body(15)),
                    Slider(min: 200, max: 800, divisions: 12, value: s.correctDelayMs.toDouble(), onChanged: (v) => p.updateSettings(s.copyWith(correctDelayMs: v.round()))),
                    Text('Mora lēctiōnis post errōrem: ${(s.wrongDelayMs / 1000).toStringAsFixed(1)} s', style: G.body(15)),
                    Slider(min: 1500, max: 8000, divisions: 13, value: s.wrongDelayMs.toDouble(), onChanged: (v) => p.updateSettings(s.copyWith(wrongDelayMs: v.round()))),
                  ]),
                ),
                const SizedBox(height: 12),
                RomanPanel(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Gemmae: praemia et poenae', style: G.display(18, color: G.purple)),
                    const SizedBox(height: 6),
                    Text('Prō ūnā respōnsiōne ūna trānsāctiō. Perītia ante respōnsum computātur.', style: G.body(14, color: G.inkSoft)),
                    const SizedBox(height: 8),
                    for (final t in MasteryTier.values)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(children: [
                          MasteryBadge(t, dense: true),
                          const Spacer(),
                          Text('rēctē +${kEconomy.gains[t]}  ·  errāns −${kEconomy.losses[t]}', style: G.body(15, weight: 700)),
                        ]),
                      ),
                    const SizedBox(height: 6),
                    Text('Auxiliō adhibitō: +${kEconomy.aidedGain} / −${kEconomy.aidedLoss}. Victōria: +${kEconomy.victoryBonus} (×${kEconomy.catchUpMultiplier} sī nihil emī potest). Idem verbum post ${kEconomy.lemmaSaturation} respōnsa nihil affert. Summa nunquam īnfrā 0.', style: G.body(13, color: G.inkSoft)),
                  ]),
                ),
                const SizedBox(height: 12),
                RomanPanel(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Cōnservātiō', style: G.display(18, color: G.purple)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      RomanButton(label: 'Exportā (in tabellam)', icon: Icons.upload, style: RomanButtonStyle.gold, dense: true, onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: p.exportJson()));
                        if (context.mounted) showLatinSnack(context, 'Cōnservātiō in tabellam cōpiāta est.');
                      }),
                      RomanButton(label: 'Importā (ē tabellā)', icon: Icons.download, style: RomanButtonStyle.neutral, dense: true, onPressed: () async {
                        final data = await Clipboard.getData('text/plain');
                        final raw = data?.text;
                        if (raw == null || raw.isEmpty) {
                          if (context.mounted) showLatinSnack(context, 'Tabella vacua est.');
                          return;
                        }
                        if (!context.mounted) return;
                        final ok = await confirmLatin(context, title: 'Importāre?', body: 'Cōnservātiō praesēns dēlēbitur et ē tabellā restituētur.', yes: 'Importā');
                        if (!ok) return;
                        try {
                          await p.importJson(raw);
                          if (context.mounted) showLatinSnack(context, 'Cōnservātiō importāta est.');
                        } on FormatException catch (e) {
                          if (context.mounted) showLatinSnack(context, 'Error: ${e.message}');
                        }
                      }),
                      RomanButton(label: 'Dēlē omnia', icon: Icons.delete_forever, style: RomanButtonStyle.danger, dense: true, onPressed: () async {
                        final ok = await confirmLatin(context, title: 'Dēlēre omnia?', body: 'Gemmae, emptiōnēs et perītiae dēlēbuntur. Hoc revocārī nōn potest.', yes: 'Dēlē');
                        if (ok) await p.resetAll();
                      }),
                    ]),
                    const SizedBox(height: 8),
                    Text('Servātur post omne respōnsum et omnem emptiōnem. Schēma ${save.schemaVersion}.', style: G.body(13, color: G.inkSoft)),
                  ]),
                ),
                const SizedBox(height: 12),
                RomanPanel(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Dē fontibus', style: G.display(18, color: G.purple)),
                    const SizedBox(height: 6),
                    Text('Grammatica: Allen & Greenough, New Latin Grammar (1903), ēditiō Dickinson College Commentaries (CC BY-SA). Fōrmae in ipsō lūdō generantur et cum Collatinō (GPL-3.0) in officīnā tantum comparātae sunt. Litterae: Cinzel et Nunito (OFL). Imāginēs et sonī hīc factī (CC0), prōvīsōriī.', style: G.body(13, color: G.inkSoft)),
                  ]),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
