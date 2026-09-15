import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../audio/audio_service.dart';
import '../../economy/economy.dart';
import '../../pedagogy/mastery.dart';
import '../../persistence/save_data.dart';
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
    const panelPadding = EdgeInsets.fromLTRB(18, 16, 18, 16);

    final panels = <Widget>[
      RomanPanel(
        padding: panelPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelHeader(
              icon: s.soundOn ? Icons.volume_up : Icons.volume_off,
              title: 'Sonus',
              subtitle: 'Sonī certāminis et mūsica · interruptor omnia tacet',
              trailing: _Toggle(
                value: s.soundOn,
                onChanged: (v) {
                  p.updateSettings(s.copyWith(soundOn: v));
                  if (v) audio.play(Sfx.tactus);
                },
              ),
            ),
            _SliderRow(
              icon: s.volume == 0 ? Icons.notifications_off : Icons.notifications_active,
              label: 'Sonī',
              valueText: '${(s.volume * 100).round()} %',
              value: s.volume,
              min: 0,
              max: 1,
              divisions: 20,
              enabled: s.soundOn,
              onChanged: (v) => p.updateSettings(s.copyWith(volume: v)),
              onChangeEnd: (_) => audio.play(Sfx.gemma),
            ),
            _SliderRow(
              icon: s.musicVolume == 0 ? Icons.music_off : Icons.music_note,
              label: 'Mūsica',
              valueText: '${(s.musicVolume * 100).round()} %',
              value: s.musicVolume,
              min: 0,
              max: 1,
              divisions: 20,
              enabled: s.soundOn,
              onChanged: (v) => p.updateSettings(s.copyWith(musicVolume: v, musicOn: true)),
            ),
          ],
        ),
      ),
      RomanPanel(
        padding: panelPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelHeader(
              icon: Icons.animation,
              title: 'Mōtus et tempora',
              subtitle: 'Animātiōnēs et morae inter quaestiōnēs',
              trailing: _Toggle(
                value: s.reducedMotion,
                onChanged: (v) => p.updateSettings(s.copyWith(reducedMotion: v)),
              ),
            ),
            const _Note('Mōtus minor: minus animātiōnum, gemmae nōn volant.', indent: 66),
            const SizedBox(height: 6),
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
            const _Note('Post errōrem explicātiō manet dōnec "Perge" premis (aut spatium / Enter).', indent: 66),
          ],
        ),
      ),
      RomanPanel(
        padding: panelPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelHeader(icon: Icons.translate, title: 'Lingua interpretātiōnis', subtitle: 'Theātrum: sententiae Latīnae, interpretātiōnēs in linguā ēlēctā · interfaciēs Latīna manet.'),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  for (final lang in TranslationLanguage.values)
                    Builder(builder: (context) {
                      final available = ref.watch(readingLibraryProvider).supports(lang.code);
                      final selected = s.translationLanguage == lang;
                      return RomanButton(
                        label: available ? lang.latin : '${lang.latin} · nōndum parāta',
                        icon: selected ? Icons.check_circle : (available ? Icons.circle_outlined : Icons.lock),
                        style: selected ? RomanButtonStyle.chosen : (available ? RomanButtonStyle.outline : RomanButtonStyle.locked),
                        dense: true,
                        onPressed: available && !selected
                            ? () {
                                p.updateSettings(s.copyWith(translationLanguage: lang));
                              }
                            : null,
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const _Note('Lingua nōndum parāta ēligī nōn potest: nihil aliā linguā ostenditur.', indent: 6),
          ],
        ),
      ),
      RomanPanel(
        padding: panelPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelHeader(icon: Icons.diamond, title: 'Gemmae: praemia et poenae', subtitle: 'Ūna trānsāctiō prō ūnā respōnsiōne; perītia ante respōnsum computātur.'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: G.marbleDark, width: 1.5),
              ),
              // Rows are rounded inside the border instead of clipped: Impeller
              // on OpenGL ES does not anti-alias clips.
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(color: G.purpleRoyal, borderRadius: BorderRadius.vertical(top: Radius.circular(10.5))),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    child: Row(
                      children: [
                        Expanded(child: Text('Perītia', style: G.body(15, color: Colors.white, weight: 800))),
                        SizedBox(width: 100, child: Text('Rēctē', textAlign: TextAlign.center, style: G.body(15, color: Colors.white, weight: 800))),
                        SizedBox(width: 100, child: Text('Errāns', textAlign: TextAlign.center, style: G.body(15, color: Colors.white, weight: 800))),
                      ],
                    ),
                  ),
                  for (final (i, t) in MasteryTier.values.indexed)
                    Container(
                      decoration: BoxDecoration(
                        color: i.isOdd ? G.parchment : Colors.white,
                        borderRadius: i == MasteryTier.values.length - 1 ? const BorderRadius.vertical(bottom: Radius.circular(10.5)) : null,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      child: Row(
                        children: [
                          Expanded(child: Align(alignment: Alignment.centerLeft, child: MasteryBadge(t))),
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
        padding: panelPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelHeader(icon: Icons.save, title: 'Cōnservātiō', subtitle: 'Servātur post omne respōnsum et omnem emptiōnem · schēma ${save.schemaVersion}.'),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Wrap(
                spacing: 12,
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
            ),
          ],
        ),
      ),
      RomanPanel(
        padding: panelPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelHeader(icon: Icons.account_balance, title: 'Dē fontibus'),
            _Rule(Icons.menu_book, 'Grammatica: Allen & Greenough, New Latin Grammar (1903), ēditiō Dickinson College Commentaries (CC BY-SA).'),
            const _Rule(Icons.auto_stories, 'Theātrum: Biblia Sacra Vulgata Clementina (textus 1598, ēditiō Migne 1880) et La Sainte Bible, Louis Segond 1910 — eBible.org, in pūblicō (ēditiō Desclée 1901 postulāta, digitāliter nōn exstat).'),
            const _Rule(Icons.fact_check, 'Fōrmae in ipsō lūdō generantur; cum Collatinō (GPL-3.0) in officīnā tantum comparātae sunt.'),
            const _Rule(Icons.brush, 'Litterae Cinzel et Nunito (OFL). Imāginēs et sonī hīc factī (CC0), prōvīsōriī.'),
          ],
        ),
      ),
    ];

    return Scaffold(
      body: ScreenBackground(
        asset: 'assets/images/optiones_bg.png',
        child: Column(
          children: [
            TopBar(title: 'Optiōnēs', gems: save.gems),
            Expanded(
              child: Stack(
                children: [
                  // The hero greets the player from the carpet on wide screens.
                  if (wide) Positioned(right: 48, bottom: 0, child: Image.asset('assets/images/hero_victory.png', height: 380)),
                  ContentColumn(
                    maxWidth: 740,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: panels.length,
                      separatorBuilder: (context, i) => const SizedBox(height: 16),
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

/// Large switch: royal purple with a gold thumb when on.
class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Transform.scale(
        scale: 1.2,
        alignment: Alignment.centerRight,
        child: Switch(value: value, onChanged: onChanged),
      );
}

/// Explanatory line under a control, aligned with the header text.
class _Note extends StatelessWidget {
  const _Note(this.text, {this.indent = 0});
  final String text;
  final double indent;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(left: indent, top: 4),
        child: Text(text, style: G.body(15, color: G.inkSoft)),
      );
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
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720;
    final iconBox = SizedBox(width: 30, child: Icon(icon, color: G.purpleRoyal, size: 24));
    final labelText = Text(label, style: G.body(17, weight: 800));
    final slider = Slider(value: value, min: min, max: max, divisions: divisions, onChanged: enabled ? onChanged : null, onChangeEnd: onChangeEnd);
    final valueBox = SizedBox(width: 76, child: Text(valueText, textAlign: TextAlign.right, style: G.body(17, weight: 800, color: G.purpleDark)));
    // On phones the label takes its own line so the track keeps its length.
    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [iconBox, const SizedBox(width: 10), Expanded(child: labelText)]),
            Row(children: [Expanded(child: slider), valueBox]),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Row(
        children: [
          iconBox,
          const SizedBox(width: 10),
          SizedBox(width: 200, child: labelText),
          Expanded(child: slider),
          valueBox,
        ],
      ),
    );
  }
}

class _GemDelta extends StatelessWidget {
  const _GemDelta(this.value, {required this.positive});
  final int value;
  final bool positive;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (positive) Image.asset('assets/images/gem.png', width: 20, height: 20) else const Icon(Icons.diamond, size: 18, color: G.red),
            const SizedBox(width: 5),
            Text('${value > 0 ? '+' : ''}$value', style: G.body(17, weight: 800, color: value > 0 ? G.greenDark : (value == 0 ? G.inkSoft : G.redDark))),
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
        padding: const EdgeInsets.only(top: 6, left: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: G.purpleRoyal),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: G.body(16, color: G.ink))),
          ],
        ),
      );
}
