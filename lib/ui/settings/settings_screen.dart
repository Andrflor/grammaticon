import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../engine/design.dart';
import '../../engine/session.dart';
import '../widgets/roman_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.session,
    required this.skin,
    required this.onBack,
    required this.onAudioChanged,
  });
  final GameSession session;
  final G skin;
  final VoidCallback onBack;
  final Future<void> Function() onAudioChanged;
  String text(String key) => session.label(key);

  @override
  Widget build(BuildContext context) {
    final s = SettingsSnapshot(object(session.state['settings']));
    final p = SettingsBinding(session, onAudioChanged);
    final levels = objects(session.mastery['levels']);
    final economy = session.economy;
    final wide = MediaQuery.sizeOf(context).width > 1100;
    final panelPadding = EdgeInsets.fromLTRB(18, 16, 18, 16);

    final panels = <Widget>[
      RomanPanel(
        skin: skin,
        padding: panelPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelHeader(
              skin: skin,
              icon: s.soundOn ? Icons.volume_up : Icons.volume_off,
              title: text('settings.text.0'),
              subtitle: text('settings.text.1'),
              trailing: _Toggle(
                value: s.soundOn,
                onChanged: (v) {
                  p.updateSettings(s.copyWith(soundOn: v));
                },
              ),
            ),
            _SliderRow(
              skin: skin,
              icon: s.volume == 0
                  ? Icons.notifications_off
                  : Icons.notifications_active,
              label: text('settings.text.2'),
              valueText: '${(s.volume * 100).round()} %',
              value: s.volume,
              min: 0,
              max: 1,
              divisions: 20,
              enabled: s.soundOn,
              onChanged: (v) => p.updateSettings(s.copyWith(volume: v)),
            ),
            _SliderRow(
              skin: skin,
              icon: s.musicVolume == 0 ? Icons.music_off : Icons.music_note,
              label: text('settings.text.3'),
              valueText: '${(s.musicVolume * 100).round()} %',
              value: s.musicVolume,
              min: 0,
              max: 1,
              divisions: 20,
              enabled: s.soundOn,
              onChanged: (v) =>
                  p.updateSettings(s.copyWith(musicVolume: v, musicOn: true)),
            ),
          ],
        ),
      ),
      RomanPanel(
        skin: skin,
        padding: panelPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelHeader(
              skin: skin,
              icon: Icons.animation,
              title: text('settings.text.4'),
              subtitle: text('settings.text.5'),
              trailing: _Toggle(
                value: s.reducedMotion,
                onChanged: (v) =>
                    p.updateSettings(s.copyWith(reducedMotion: v)),
              ),
            ),
            _Note(text('settings.text.6'), indent: 66, skin: skin),
            SizedBox(height: 6),
            _SliderRow(
              skin: skin,
              icon: Icons.bolt,
              label: text('settings.text.7'),
              valueText: '${s.correctDelayMs} ms',
              value: s.correctDelayMs.toDouble(),
              min: 200,
              max: 800,
              divisions: 12,
              onChanged: (v) =>
                  p.updateSettings(s.copyWith(correctDelayMs: v.round())),
            ),
            _Note(text('settings.text.8'), indent: 66, skin: skin),
          ],
        ),
      ),
      RomanPanel(
        skin: skin,
        padding: panelPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelHeader(
              skin: skin,
              icon: Icons.translate,
              title: text('settings.text.9'),
              subtitle: text('settings.text.10'),
            ),
            Padding(
              padding: EdgeInsets.only(left: 6),
              child: Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  for (final option in objects(
                    session
                        .design
                        .root['presentation']['languageControl']['options'],
                  ))
                    Builder(
                      builder: (context) {
                        final available = option['available'] == true;
                        final field =
                            session
                                    .design
                                    .root['presentation']['languageControl']['field']
                                as String;
                        final selected =
                            session.state['settings'][field] == option['value'];
                        return RomanButton(
                          skin: skin,
                          label: session.text(option['name']),
                          icon: selected
                              ? Icons.check_circle
                              : (available
                                    ? Icons.circle_outlined
                                    : Icons.lock),
                          style: selected
                              ? RomanButtonStyle.chosen
                              : (available
                                    ? RomanButtonStyle.outline
                                    : RomanButtonStyle.locked),
                          dense: true,
                          onPressed: available && !selected
                              ? () {
                                  session.setting(field, option['value']);
                                }
                              : null,
                        );
                      },
                    ),
                ],
              ),
            ),
            SizedBox(height: 10),
            _Note(text('settings.text.12'), indent: 6, skin: skin),
          ],
        ),
      ),
      RomanPanel(
        skin: skin,
        padding: panelPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelHeader(
              skin: skin,
              icon: Icons.diamond,
              title: text('settings.text.13'),
              subtitle: text('settings.text.14'),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: skin.marbleDark, width: 1.5),
              ),
              // Rows are rounded inside the border instead of clipped: Impeller
              // on OpenGL ES does not anti-alias clips.
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: skin.purpleRoyal,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10.5),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            text('settings.text.15'),
                            style: skin.body(
                              15,
                              color: Colors.white,
                              weight: 800,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            text('settings.text.16'),
                            textAlign: TextAlign.center,
                            style: skin.body(
                              15,
                              color: Colors.white,
                              weight: 800,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            text('settings.text.17'),
                            textAlign: TextAlign.center,
                            style: skin.body(
                              15,
                              color: Colors.white,
                              weight: 800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (var i = 0; i < levels.length; i++)
                    Container(
                      decoration: BoxDecoration(
                        color: i.isOdd ? skin.parchment : Colors.white,
                        borderRadius: i == levels.length - 1
                            ? BorderRadius.vertical(
                                bottom: Radius.circular(10.5),
                              )
                            : null,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: LevelBadge(
                                session: session,
                                skin: skin,
                                level: i,
                              ),
                            ),
                          ),
                          _GemDelta(
                            skin: skin,
                            currencyAsset: session.design.asset(
                              session.design.root['presentation']['currency'],
                            ),
                            objects(economy['levels'])[i]['gain'] as int,
                            positive: true,
                          ),
                          _GemDelta(
                            skin: skin,
                            currencyAsset: session.design.asset(
                              session.design.root['presentation']['currency'],
                            ),
                            -(objects(economy['levels'])[i]['loss'] as int),
                            positive: false,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 10),
            for (final rule in objects(economy['displayRules']))
              _Rule(Icons.info_outline, session.text(rule['text']), skin: skin),
          ],
        ),
      ),
      RomanPanel(
        skin: skin,
        padding: panelPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelHeader(
              skin: skin,
              icon: Icons.save,
              title: text('settings.text.18'),
              subtitle: text('settings.persistence.subtitle'),
            ),
            Padding(
              padding: EdgeInsets.only(left: 6),
              child: Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  RomanButton(
                    skin: skin,
                    label: text('settings.text.19'),
                    icon: Icons.upload,
                    style: RomanButtonStyle.gold,
                    dense: true,
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: p.exportJson()),
                      );
                      if (context.mounted) {
                        showSnack(context, text('settings.text.20'));
                      }
                    },
                  ),
                  RomanButton(
                    skin: skin,
                    label: text('settings.text.21'),
                    icon: Icons.download,
                    style: RomanButtonStyle.outline,
                    dense: true,
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      final raw = data?.text;
                      if (raw == null || raw.isEmpty) {
                        if (context.mounted) {
                          showSnack(context, text('settings.text.22'));
                        }
                        return;
                      }
                      if (!context.mounted) return;
                      final ok = await confirmAction(
                        context,
                        skin: skin,
                        no: session.label('actions.cancel'),
                        title: text('settings.text.23'),
                        body: text('settings.text.24'),
                        yes: text('settings.text.25'),
                      );
                      if (!ok) return;
                      try {
                        await p.importJson(raw);
                        if (context.mounted) {
                          showSnack(context, text('settings.text.26'));
                        }
                      } on FormatException catch (e) {
                        if (context.mounted) {
                          showSnack(context, e.message.toString());
                        }
                      }
                    },
                  ),
                  RomanButton(
                    skin: skin,
                    label: text('settings.text.27'),
                    icon: Icons.delete_forever,
                    style: RomanButtonStyle.danger,
                    dense: true,
                    onPressed: () async {
                      final ok = await confirmAction(
                        context,
                        skin: skin,
                        no: session.label('actions.cancel'),
                        title: text('settings.text.28'),
                        body: text('settings.text.29'),
                        yes: text('settings.text.30'),
                      );
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
        skin: skin,
        padding: panelPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelHeader(
              skin: skin,
              icon: Icons.account_balance,
              title: text('settings.text.31'),
            ),
            _Rule(Icons.menu_book, text('settings.text.32'), skin: skin),
            _Rule(Icons.auto_stories, text('settings.text.33'), skin: skin),
            _Rule(Icons.fact_check, text('settings.text.34'), skin: skin),
            _Rule(Icons.brush, text('settings.text.35'), skin: skin),
          ],
        ),
      ),
    ];

    return Scaffold(
      body: ScreenBackground(
        asset: session.design.asset(
          session.design.root['presentation']['settingsBackground'],
        ),
        child: Column(
          children: [
            TopBar(
              skin: skin,
              onBack: onBack,
              backLabel: session.label('actions.back'),
              currencyAsset: session.design.asset(
                session.design.root['presentation']['currency'],
              ),
              title: text('settings.text.36'),
              gems: session.balance,
            ),
            Expanded(
              child: Stack(
                children: [
                  // The hero greets the player from the carpet on wide screens.
                  if (wide)
                    Positioned(
                      right: 48,
                      bottom: 0,
                      child: Image.asset(
                        session.design.asset(
                          session.design.root['presentation']['settingsHero'],
                        ),
                        height: 380,
                      ),
                    ),
                  ContentColumn(
                    maxWidth: 740,
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: panels.length,
                      separatorBuilder: (context, i) => SizedBox(height: 16),
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
  final G skin;
  const _Note(this.text, {required this.skin, this.indent = 0});
  final String text;
  final double indent;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: indent, top: 4),
    child: Text(text, style: skin.body(15, color: skin.inkSoft)),
  );
}

class _SliderRow extends StatelessWidget {
  final G skin;
  const _SliderRow({
    required this.skin,
    required this.icon,
    required this.label,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.enabled = true,
  }) : onChangeEnd = null;
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
    final iconBox = SizedBox(
      width: 30,
      child: Icon(icon, color: skin.purpleRoyal, size: 24),
    );
    final labelText = Text(label, style: skin.body(17, weight: 800));
    final slider = Slider(
      value: value,
      min: min,
      max: max,
      divisions: divisions,
      onChanged: enabled ? onChanged : null,
      onChangeEnd: onChangeEnd,
    );
    final valueBox = SizedBox(
      width: 76,
      child: Text(
        valueText,
        textAlign: TextAlign.right,
        style: skin.body(17, weight: 800, color: skin.purpleDark),
      ),
    );
    // On phones the label takes its own line so the track keeps its length.
    if (compact) {
      return Padding(
        padding: EdgeInsets.only(top: 6, bottom: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                iconBox,
                SizedBox(width: 10),
                Expanded(child: labelText),
              ],
            ),
            Row(
              children: [
                Expanded(child: slider),
                valueBox,
              ],
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(top: 4, bottom: 2),
      child: Row(
        children: [
          iconBox,
          SizedBox(width: 10),
          SizedBox(width: 200, child: labelText),
          Expanded(child: slider),
          valueBox,
        ],
      ),
    );
  }
}

class _GemDelta extends StatelessWidget {
  final G skin;
  const _GemDelta(
    this.value, {
    required this.skin,
    required this.currencyAsset,
    required this.positive,
  });
  final String currencyAsset;
  final int value;
  final bool positive;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 100,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (positive)
          Image.asset(currencyAsset, width: 20, height: 20)
        else
          Icon(Icons.diamond, size: 18, color: skin.red),
        SizedBox(width: 5),
        Text(
          '${value > 0 ? '+' : ''}$value',
          style: skin.body(
            17,
            weight: 800,
            color: value > 0
                ? skin.greenDark
                : (value == 0 ? skin.inkSoft : skin.redDark),
          ),
        ),
      ],
    ),
  );
}

class _Rule extends StatelessWidget {
  final G skin;
  const _Rule(this.icon, this.text, {required this.skin});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: 6, left: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: skin.purpleRoyal),
        SizedBox(width: 8),
        Expanded(
          child: Text(text, style: skin.body(16, color: skin.ink)),
        ),
      ],
    ),
  );
}

class SettingsSnapshot {
  SettingsSnapshot(this.data);
  final Json data;
  bool get soundOn => data['sound'] == true;
  bool get reducedMotion => data['reducedMotion'] == true;
  double get volume => (data['volume'] as num).toDouble();
  double get musicVolume => (data['musicVolume'] as num? ?? volume).toDouble();
  int get correctDelayMs => data['correctDelayMs'] as int;
  Json copyWith({
    bool? soundOn,
    bool? reducedMotion,
    double? volume,
    double? musicVolume,
    bool? musicOn,
    int? correctDelayMs,
    String? locale,
  }) => {
    if (soundOn != null) 'sound': soundOn,
    if (reducedMotion != null) 'reducedMotion': reducedMotion,
    if (volume != null) 'volume': volume,
    if (musicVolume != null) 'musicVolume': musicVolume,
    if (musicOn != null) 'music': musicOn,
    if (correctDelayMs != null) 'correctDelayMs': correctDelayMs,
    if (locale != null) 'locale': locale,
  };
}

class SettingsBinding {
  SettingsBinding(this.session, this.onAudioChanged);
  final GameSession session;
  final Future<void> Function() onAudioChanged;
  Future<void> updateSettings(Json values) async {
    for (final e in values.entries) {
      await session.setting(e.key, e.value);
    }
    await onAudioChanged();
  }

  String exportJson() => session.exportJson;
  Future<void> importJson(String raw) => session.importSave(raw);
  Future<void> resetAll() async {
    final fresh = GameSession(session.design, {}, (_) async {});
    await session.importSave(fresh.exportJson);
    fresh.dispose();
  }
}
