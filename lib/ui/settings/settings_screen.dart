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
    final wide = MediaQuery.sizeOf(context).width > 1100;

    final panels = <Widget>[
      RomanPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelHeader(
              icon: Icons.music_note,
              title: 'Sonus',
              subtitle: 'Mūsica et sonī certāminis',
              trailing: Switch(
                value: s.soundOn,
                onChanged: (v) {
                  p.updateSettings(s.copyWith(soundOn: v));
                  if (v) audio.play(Sfx.tactus);
                },
              ),
            ),
            _SliderRow(
              icon: s.volume == 0 ? Icons.volume_off : Icons.volume_up,
              label: 'Volūmen',
              valueText: '${(s.volume * 100).round()} %',
              value: s.volume,
              min: 0,
              max: 1,
              divisions: 20,
              enabled: s.soundOn,
              onChanged: (v) => p.updateSettings(s.copyWith(volume: v)),
              onChangeEnd: (_) => audio.play(Sfx.gemma),
            ),
          ],
        ),
      ),
      RomanPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelHeader(
              icon: Icons.animation,
              title: 'Mōtus et tempora',
              subtitle: 'Animātiōnēs et morae inter quaestiōnēs',
              trailing: Switch(
                value: s.reducedMotion,
                onChanged: (v) => p.updateSettings(s.copyWith(reducedMotion: v)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 56, bottom: 10),
              child: Text('Mōtus minor: minus animātiōnum, gemmae nōn volant.', style: G.body(13, color: G.inkSoft)),
            ),
            _SliderRow(
              icon: Icons.bolt,
              label: 'Mora post respōnsum rēctum',
              valueText: '${s.correctDelayMs} ms',
              value: s.correctDelayMs.toDouble(),
              min: 200,
              max: 800,
              divisions: 12,
              onChanged: (v) => p.updateSettings(s.copyWith(correctDelayMs: v.round())),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 4),
              child: Text('Post errōrem explicātiō manet dōnec "Perge" premis (aut spatium / Enter).', style: G.body(13, color: G.inkSoft)),
            ),
          ],
        ),
      ),
      RomanPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelHeader(icon: Icons.diamond, title: 'Gemmae: praemia et poenae', subtitle: 'Ūna trānsāctiō prō ūnā respōnsiōne; perītia ante respōnsum computātur'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: G.marbleDark, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    color: G.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Perītia', style: G.body(13, color: Colors.white, weight: 800)),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text(
                            'Rēctē',
                            textAlign: TextAlign.center,
                            style: G.body(13, color: Colors.white, weight: 800),
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text(
                            'Errāns',
                            textAlign: TextAlign.center,
                            style: G.body(13, color: Colors.white, weight: 800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final (i, t) in MasteryTier.values.indexed)
                    Container(
                      color: i.isOdd ? const Color(0xFFFAF6EC) : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Align(alignment: Alignment.centerLeft, child: MasteryBadge(t)),
                          ),
                          _GemDelta(kEconomy.gains[t]!, positive: true),
                          _GemDelta(-kEconomy.losses[t]!, positive: false),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _Rule(Icons.help_outline, 'Auxiliō adhibitō: +${kEconomy.aidedGain} sī rēctē, nūlla poena.'),
            _Rule(Icons.emoji_events, 'Victōria: +${kEconomy.victoryBonus} gemmae, ×${kEconomy.catchUpMultiplier} sī nihil emī potest.'),
            _Rule(Icons.repeat, 'Idem verbum post ${kEconomy.lemmaSaturation} respōnsa rēcta nihil affert.'),
            _Rule(Icons.heart_broken, 'Clādēs: gemmae certāminis āmittuntur et quārta pars summae (ad ${kEconomy.defeatTributeMax}) tribūtum solvitur. Emptiōnēs manent.'),
            const _Rule(Icons.shield, 'Summa nunquam īnfrā 0; emptiōnēs perpetuae sunt.'),
          ],
        ),
      ),
      RomanPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelHeader(icon: Icons.save, title: 'Cōnservātiō', subtitle: 'Servātur post omne respōnsum et omnem emptiōnem · schēma ${save.schemaVersion}'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                RomanButton(
                  label: 'Exportā in tabellam',
                  icon: Icons.upload,
                  style: RomanButtonStyle.gold,
                  dense: true,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: p.exportJson()));
                    if (context.mounted) showLatinSnack(context, 'Cōnservātiō in tabellam cōpiāta est.');
                  },
                ),
                RomanButton(
                  label: 'Importā ē tabellā',
                  icon: Icons.download,
                  style: RomanButtonStyle.outline,
                  dense: true,
                  onPressed: () async {
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
                  },
                ),
                RomanButton(
                  label: 'Dēlē omnia',
                  icon: Icons.delete_forever,
                  style: RomanButtonStyle.danger,
                  dense: true,
                  onPressed: () async {
                    final ok = await confirmLatin(context, title: 'Dēlēre omnia?', body: 'Gemmae, emptiōnēs et perītiae dēlēbuntur. Hoc revocārī nōn potest.', yes: 'Dēlē');
                    if (ok) await p.resetAll();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      RomanPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelHeader(icon: Icons.account_balance, title: 'Dē fontibus'),
            _Rule(Icons.menu_book, 'Grammatica: Allen & Greenough, New Latin Grammar (1903), ēditiō Dickinson College Commentaries (CC BY-SA).'),
            const _Rule(Icons.fact_check, 'Fōrmae in ipsō lūdō generantur; cum Collatinō (GPL-3.0) in officīnā tantum comparātae sunt.'),
            const _Rule(Icons.brush, 'Litterae Cinzel et Nunito (OFL). Imāginēs et sonī hīc factī (CC0), prōvīsōriī.'),
          ],
        ),
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: kScreenGradient,
        child: Column(
          children: [
            TopBar(title: 'Optiōnēs', gems: save.gems),
            Expanded(
              child: Stack(
                children: [
                  if (wide) Positioned(right: 24, bottom: 0, child: Opacity(opacity: 0.95, child: Image.asset('assets/images/hero_victory.png', height: 360))),
                  ContentColumn(
                    maxWidth: 760,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: panels.length,
                      separatorBuilder: (context, i) => const SizedBox(height: 14),
                      itemBuilder: (context, i) => panels[i],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.icon,
    required this.label,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.onChangeEnd,
    this.enabled = true,
  });
  final IconData icon;
  final String label;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(icon, color: G.purple, size: 22),
        const SizedBox(width: 10),
        SizedBox(width: 190, child: Text(label, style: G.body(14, weight: 700))),
        Expanded(
          child: Slider(value: value, min: min, max: max, divisions: divisions, onChanged: enabled ? onChanged : null, onChangeEnd: onChangeEnd),
        ),
        SizedBox(
          width: 64,
          child: Text(
            valueText,
            textAlign: TextAlign.right,
            style: G.body(14, weight: 800, color: G.purpleDark),
          ),
        ),
      ],
    ),
  );
}

class _GemDelta extends StatelessWidget {
  const _GemDelta(this.value, {required this.positive});
  final int value;
  final bool positive;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 90,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(positive ? 'assets/images/gem.png' : 'assets/images/gem_green.png', width: 18, height: 18, color: positive ? null : G.red, colorBlendMode: positive ? null : BlendMode.srcATop),
        const SizedBox(width: 4),
        Text('${value > 0 ? '+' : ''}$value', style: G.body(16, weight: 800, color: value > 0 ? G.greenDark : (value == 0 ? G.inkSoft : G.redDark))),
      ],
    ),
  );
}

class _Rule extends StatelessWidget {
  const _Rule(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: G.goldDark),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: G.body(14, color: G.ink)),
        ),
      ],
    ),
  );
}
