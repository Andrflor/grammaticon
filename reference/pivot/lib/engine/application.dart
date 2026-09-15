import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../app/theme.dart';
import '../ui/city/city_screen.dart';
import '../ui/trials/trial_selection_screen.dart';
import '../ui/battle/battle_screen.dart';
import '../ui/help/help_sheet.dart' as help_view;
import '../ui/settings/settings_screen.dart';
import '../ui/tabula/tabula_screen.dart';
import '../ui/widgets/roman_widgets.dart';
import 'design.dart';
import 'session.dart';

/// Shared navigation, interaction and progress screens driven by one design.
class DesignApp extends StatefulWidget {
  const DesignApp({super.key, required this.session, this.audioEnabled = true});
  final bool audioEnabled;
  final GameSession session;
  @override
  State<DesignApp> createState() => _DesignAppState();
}

class _DesignAppState extends State<DesignApp> with WidgetsBindingObserver {
  GameSession get s => widget.session;
  GameDesign get d => s.design;
  ContentNode? location;
  String screen = 'world';
  String? lastOutcome;
  Timer? advanceTimer;
  AudioPlayer? music;
  AudioPlayer? effects;
  G get skin => G(theme, onCue: (cue) => unawaited(playCue(cue)));
  Json get theme => object(d.root['theme']);
  Color color(String key) =>
      Color(int.parse(theme['colors'][key] as String, radix: 16));
  double number(String key) => (theme[key] as num).toDouble();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    s.addListener(changed);
    unawaited(configureAudio());
  }

  @override
  void dispose() {
    advanceTimer?.cancel();
    s.removeListener(changed);
    WidgetsBinding.instance.removeObserver(this);
    if (music != null) unawaited(music!.dispose());
    if (effects != null) unawaited(effects!.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(s.pause());
  }

  Future<void> configureAudio() async {
    if (!widget.audioEnabled) return;
    final settings = object(s.state['settings']);

    final id = d.root['presentation']?['music'];
    if (settings['music'] == true && settings['sound'] != false && id != null) {
      music ??= AudioPlayer();
      await music!.setVolume(
        (settings['musicVolume'] as num? ?? settings['volume'] as num? ?? 0.5)
            .toDouble(),
      );
      await music!.setReleaseMode(ReleaseMode.loop);
      await music!.play(
        AssetSource(
          d.asset(id as String).replaceFirst(RegExp(r'^assets/'), ''),
        ),
      );
    } else {
      if (music != null) await music!.stop();
    }
  }

  Future<void> playCue(String cue) async {
    if (!widget.audioEnabled || s.state['settings']['sound'] != true) return;
    final id = d.root['presentation']?['sounds']?[cue];
    if (id == null) return;
    effects ??= AudioPlayer();
    await effects!.setVolume(
      (s.state['settings']['volume'] as num? ?? .8).toDouble(),
    );
    await effects!.play(
      AssetSource(d.asset(id as String).replaceFirst(RegExp(r'^assets/'), '')),
    );
  }

  void changed() {
    if (!mounted) return;
    final b = s.encounter;
    if (b != null && b['phase'] == 'feedback') {
      final token = '${b['id']}:${b['answered']}';
      if (lastOutcome != token) {
        lastOutcome = token;
        final card = d.cards[b['card']]!;
        final view = object(card.data['presentation'] ?? {});
        final cues = objects(
          view['cues']?[b['lastCorrect'] == true ? 'correct' : 'incorrect'],
        );
        if (cues.isEmpty) {
          final asset =
              view[b['lastCorrect'] == true ? 'correctSound' : 'wrongSound'];
          if (asset != null) cues.add({'sound': asset, 'delayMs': 0});
        }
        if (widget.audioEnabled && s.state['settings']['sound'] == true) {
          for (final cue in cues) {
            unawaited(
              Future<void>.delayed(
                Duration(milliseconds: cue['delayMs'] as int),
                () async {
                  if (mounted && lastOutcome == token) {
                    await (effects ??= AudioPlayer()).play(
                      AssetSource(
                        d
                            .asset(cue['sound'])
                            .replaceFirst(RegExp(r'^assets/'), ''),
                      ),
                    );
                  }
                },
              ),
            );
          }
        }
        if (b['lastCorrect'] == true) {
          advanceTimer?.cancel();
          advanceTimer = Timer(
            Duration(
              milliseconds:
                  (s.state['settings']['correctDelayMs'] as int? ?? 350),
            ),
            () => s.advance(),
          );
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: s.text(d.root['name']),
    builder: (context, child) => Directionality(
      textDirection: d.locales[s.locale]?['locale.direction'] == 'rtl'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: child!,
    ),
    debugShowCheckedModeBanner: false,
    theme: skin.theme(),
    home: Builder(builder: (context) => gameScreen(context)),
  );
  Widget gameScreen(BuildContext context) {
    void settings() => setState(() => screen = 'settings');
    void openCard(ContentNode card) {
      setState(() {
        screen = 'world';
        location = card.parent;
      });
    }

    if (screen == 'encounter' && s.encounter != null) {
      return BattleScreen(
        session: s,
        skin: skin,
        node: d.cards[s.encounter!['card']]!,
        onLeave: back,
        onHelp: showHelp,
      );
    }
    if (screen == 'settings') {
      return SettingsScreen(
        session: s,
        skin: skin,
        onBack: back,
        onAudioChanged: configureAudio,
      );
    }
    if (screen == 'progress') {
      return TabulaScreen(
        session: s,
        skin: skin,
        onBack: back,
        onSettings: settings,
        onCard: openCard,
        onErrors: () => setState(() => screen = 'errors'),
      );
    }
    if (screen == 'errors') {
      return Scaffold(
        body: ScreenBackground(
          asset: d.asset(d.root['presentation']['progressBackground']),
          child: Column(
            children: [
              TopBar(
                skin: skin,
                title: s.label('actions.errors'),
                backLabel: s.label('actions.back'),
                currencyAsset: d.asset(d.root['presentation']['currency']),
                gems: s.balance,
                onBack: back,
                onSettings: settings,
              ),
              Expanded(child: errors(context)),
            ],
          ),
        ),
      );
    }
    if (location != null) {
      var place = location!;
      while (place.parent != null) {
        place = place.parent!;
      }
      return TrialSelectionScreen(
        session: s,
        skin: skin,
        place: place,
        onBack: () {
          setState(() => location = null);
        },
        onSettings: settings,
        onStart: (card) async {
          await s.start(card);
          if (mounted) setState(() => screen = 'encounter');
        },
        onInfo: (card) => showCourse(context, card),
        requirementText: requirementText,
      );
    }
    return CityScreen(
      session: s,
      skin: skin,
      onOpen: (node) => setState(() => location = node),
      onProgress: () => setState(() => screen = 'progress'),
      onSettings: settings,
      onResume: () => setState(() => screen = 'encounter'),
    );
  }

  Future<void> showCourse(BuildContext context, ContentNode card) async {
    final lesson = await d.lesson(card);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.text(card.data['name']),
                style: skin.display(24, color: skin.purpleTitle),
              ),
              Text(
                s.text(card.data['subtitle']),
                style: skin.body(14, color: skin.inkSoft),
              ),
              const SizedBox(height: 10),
              ...blocks(lesson),
              const SizedBox(height: 12),
              RomanButton(
                skin: skin,
                label: s.label('actions.close'),
                style: RomanButtonStyle.gold,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void back() {
    if (screen == 'encounter' && s.encounter?['phase'] == 'question') {
      unawaited(s.pause());
    }
    setState(() {
      if (screen != 'world') {
        screen = 'world';
      } else {
        location = location?.parent;
      }
    });
  }

  Widget heading(String value) => Text(
    value,
    style: TextStyle(
      fontFamily: theme['headingFont'] as String,
      fontSize: number('headingSize'),
      fontWeight: FontWeight.bold,
      color: color('primary'),
    ),
  );
  Widget panel(Widget child) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: RomanPanel(skin: skin, child: child),
  );
  Widget constrained(Widget child) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: number('maxWidth')),
      child: child,
    ),
  );
  Widget picture(String id, {double? height, BoxFit fit = BoxFit.contain}) =>
      Image.asset(
        d.asset(id),
        height: height,
        fit: fit,
        errorBuilder: (context, error, trace) => const SizedBox.shrink(),
      );
  String requirementText(Json rule) {
    final e = rule.entries.single;
    if (e.key == 'all' || e.key == 'any') {
      return objects(e.value)
          .map(requirementText)
          .join(e.key == 'all' ? ', ' : ' ∨ ');
    }
    if (e.key == 'not') return '¬ (${requirementText(object(e.value))})';
    if (e.key == 'skill') {
      return '${s.text(d.knowledge[e.value['id']]?['name'])} ≥ ${s.text(objects(s.mastery['levels'])[e.value['minLevel'] ?? 0]['name'])}';
    }
    final id = e.key == 'count' ? e.value['card'] : e.value;
    return s.text(d.nodes[id]?.data['name']);
  }

  Widget content(QuestionEntry q, String? selected) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      for (final part in objects(q.data['content']))
        if (part['type'] == 'image')
          picture(part['asset'] as String, height: 160)
        else
          Container(
            padding: EdgeInsets.all(
              part['type'] == 'highlight' || part['type'] == 'gap' ? 5 : 0,
            ),
            decoration: BoxDecoration(
              color: part['type'] == 'highlight'
                  ? color('accent').withValues(alpha: 0.3)
                  : null,
              border: part['type'] == 'gap'
                  ? Border(
                      bottom: BorderSide(color: color('primary'), width: 2),
                    )
                  : null,
            ),
            child: Text(
              part['type'] == 'gap' && selected != null
                  ? s.text(
                      q.choices.firstWhere((c) => c['id'] == selected)['text'],
                    )
                  : s.text(part['text']),
              style: TextStyle(
                fontSize: number('questionSize'),
                fontWeight: part['type'] == 'highlight'
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
    ],
  );
  List<Widget> blocks(List<dynamic> content) => [
    for (final raw in content) panel(block(object(raw))),
  ];
  Widget block(Json b) {
    if (b['type'] == 'table') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (b['title'] != null) heading(s.text(b['title'])),
          help_view.HelpTableView(help_view.HelpTableData(s, b), skin: skin),
          if (b['note'] != null) Text(s.text(b['note'])),
        ],
      );
    }
    return Text(
      s.text(b['text']),
      style: TextStyle(
        fontSize: number('bodySize'),
        fontWeight: b['type'] == 'example'
            ? FontWeight.bold
            : FontWeight.normal,
      ),
    );
  }

  Future<void> showHelp(
    BuildContext context,
    QuestionEntry q,
    ContentNode card,
  ) async {
    final content = await d.help(q.data['help'] as String);
    if (!context.mounted) return;
    await help_view.showHelpSheet(
      context,
      s,
      skin,
      objects(content),
      highlight: s.text(q.data['helpHighlight']),
    );
  }

  Widget errors(BuildContext context) => constrained(
    ListView(
      padding: EdgeInsets.all(number('spacing')),
      children: [
        panel(heading(s.label('actions.errors'))),
        if (object(s.state['errors']).isEmpty)
          panel(Text(s.label('state.empty'))),
        for (final raw in object(s.state['errors']).values)
          panel(errorDetails(context, object(raw))),
      ],
    ),
  );
  Widget errorDetails(BuildContext context, Json error) {
    final q = error['question'] == null
        ? null
        : QuestionEntry(object(error['question']));
    final outcome = object(error['outcome'] ?? {});
    final targets = s.practiceTargets(error);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (q != null) ...[
          heading(s.text(q.data['prompt'])),
          content(q, error['chosen'] as String?),
          Text(
            '${s.label('labels.yourAnswer')}: ${s.text(q.choices.firstWhere((c) => c['id'] == error['chosen'])['text'])}',
          ),
          Text(s.text(outcome['feedback'])),
        ],
        Text(
          '${s.label('labels.responseTime')}: ${error['responseTimeMs'] == null ? s.label('labels.notMeasured') : '${error['responseTimeMs']} ms'}',
        ),
        Text(
          '${s.label('labels.observed')}: ${strings(outcome['observed']).map((id) => s.text(d.knowledge[id]?['name'] ?? id)).join(' · ')}',
        ),
        Text(
          '${s.label('labels.hypotheses')}: ${strings(outcome['hypotheses']).map((id) => s.text(d.knowledge[id]?['name'] ?? id)).join(' · ')}',
        ),
        if (targets.isNotEmpty) heading(s.label('labels.related')),
        for (final target in targets)
          RomanButton(
            skin: skin,
            onPressed: () {
              setState(() {
                screen = 'world';
                location = d.cards[target['card']]!.parent;
              });
            },
            label:
                '${s.text(d.cards[target['card']]!.data['name'])}${s.unlocked(d.cards[target['card']]!) ? '' : ' · ${s.label('state.locked')}'}',
          ),
      ],
    );
  }
}
