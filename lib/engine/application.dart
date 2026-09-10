import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import '../app/theme.dart';
import '../ui/city/city_screen.dart';
import '../ui/trials/trial_selection_screen.dart';
import '../ui/battle/battle_screen.dart';
import '../ui/settings/settings_screen.dart';
import '../ui/tabula/tabula_screen.dart';
import '../ui/widgets/roman_widgets.dart';
import 'design.dart';
import 'session.dart';

/// Shared navigation, interaction and progress screens driven by one design.
class DesignApp extends StatefulWidget {
  const DesignApp({super.key, required this.session});
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
  bool get painted => d.root['presentation']?['layout']=='painted';
  G get skin => G(theme);
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
    final settings = object(s.state['settings']);

    final id = d.root['presentation']?['music'];
    if (settings['music'] == true && id != null) {
      music ??= AudioPlayer();
      await music!.setVolume((settings['musicVolume'] as num? ?? settings['volume'] as num? ?? 0.5).toDouble());
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
        if (s.state['settings']['sound'] == true) {
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

  ThemeData get appTheme {
    if(painted)return skin.theme();
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color('primary'),
        primary: color('primary'),
        secondary: color('accent'),
        surface: color('surface'),
        error: color('error'),
      ),
      fontFamily: theme['bodyFont'] as String,
    );
    return base.copyWith(
      scaffoldBackgroundColor: color('background'),
      textTheme: base.textTheme.apply(
        bodyColor: color('text'),
        displayColor: color('text'),
      ),
      cardTheme: CardThemeData(
        color: color('surface'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(number('radius')),
          side: BorderSide(color: color('accent')),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size(44, number('buttonHeight')),
          textStyle: TextStyle(
            fontSize: number('bodySize'),
            fontFamily: theme['bodyFont'] as String,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(number('radius')),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: color('background'),
        foregroundColor: color('onBackground'),
      ),
      dialogTheme: DialogThemeData(backgroundColor: color('surface')),
    );
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
    theme: appTheme,
    home: Builder(
      builder: (context) => CallbackShortcuts(
        bindings: painted ? {} : {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              s.encounter?['phase'] == 'question'
              ? s.pause()
              : s.encounter?['phase'] == 'paused'
              ? s.resume()
              : null,
          const SingleActivator(LogicalKeyboardKey.enter): () =>
              s.encounter?['phase'] == 'feedback' ? s.advance() : null,
          for (var i = 0; i < 9; i++)
            SingleActivator(
              [
                LogicalKeyboardKey.digit1,
                LogicalKeyboardKey.digit2,
                LogicalKeyboardKey.digit3,
                LogicalKeyboardKey.digit4,
                LogicalKeyboardKey.digit5,
                LogicalKeyboardKey.digit6,
                LogicalKeyboardKey.digit7,
                LogicalKeyboardKey.digit8,
                LogicalKeyboardKey.digit9,
              ][i],
            ): () => s.question != null && i < s.question!.choices.length
                ? s.answer(s.question!.choices[i]['id'] as String)
                : null,
        },
        child: Focus(
          autofocus: true,
          child: painted ? restoredScreen(context) : Scaffold(
            appBar: AppBar(
              title: Text(s.text(d.root['name'])),
              leading: screen != 'world' || location != null
                  ? IconButton(
                      tooltip: s.label('actions.back'),
                      onPressed: back,
                      icon: const Icon(Icons.arrow_back),
                    )
                  : null,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: IconTheme(
                  data: IconThemeData(color: color('onBackground')),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '${s.label('labels.currency')} ${s.balance}',
                          style: TextStyle(color: color('onBackground')),
                        ),
                      ),
                      IconButton(
                        tooltip: s.label('actions.progress'),
                        onPressed: () => setState(() => screen = 'progress'),
                        icon: const Icon(Icons.insights),
                      ),
                      IconButton(
                        tooltip: s.label('actions.errors'),
                        onPressed: () => setState(() => screen = 'errors'),
                        icon: const Icon(Icons.history_edu),
                      ),
                      IconButton(
                        tooltip: s.label('actions.settings'),
                        onPressed: () => setState(() => screen = 'settings'),
                        icon: const Icon(Icons.settings),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: switch (screen) {
                'encounter' => encounter(context),
                'progress' => progress(),
                'errors' => errors(context),
                'settings' => settings(context),
                _ => world(context),
              },
            ),
          ),
        ),
      ),
    ),
  );
  Widget restoredScreen(BuildContext context){
 void settings()=>setState(()=>screen='settings');
 void openCard(ContentNode card){setState((){screen='world';location=card.parent;});}
 if(screen=='encounter'&&s.encounter!=null){
 return BattleScreen(session:s,skin:skin,node:d.cards[s.encounter!['card']]!,onLeave:back,onHelp:showHelp);
 }
 if(screen=='settings')return SettingsScreen(session:s,skin:skin,onBack:back,onAudioChanged:configureAudio);
 if(screen=='progress')return TabulaScreen(session:s,skin:skin,onBack:back,onSettings:settings,onCard:openCard,onErrors:()=>setState(()=>screen='errors'));
 if(screen=='errors')return Scaffold(body:ScreenBackground(asset:d.asset(d.root['presentation']['progressBackground']),child:Column(children:[TopBar(skin:skin,title:s.label('actions.errors'),backLabel:s.label('actions.back'),currencyAsset:d.asset(d.root['presentation']['currency']),gems:s.balance,onBack:back,onSettings:settings),Expanded(child:errors(context))])));
 if(location!=null){
 var place=location!;while(place.parent!=null){place=place.parent!;}
 return TrialSelectionScreen(session:s,skin:skin,place:place,onBack:(){setState(()=>location=null);},onSettings:settings,onStart:(card)async{await s.start(card);if(mounted)setState(()=>screen='encounter');},onInfo:(card)=>showCourse(context,card),requirementText:requirementText);
 }
 return CityScreen(session:s,skin:skin,onOpen:(node)=>setState(()=>location=node),onProgress:()=>setState(()=>screen='progress'),onSettings:settings,onResume:()=>setState(()=>screen='encounter'));
 }
 Future<void> showCourse(BuildContext context,ContentNode card)async{
 final lesson=await d.lesson(card);if(!context.mounted)return;
 await showModalBottomSheet<void>(context:context,isScrollControlled:true,builder:(ctx)=>Padding(padding:const EdgeInsets.all(20),child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
 Text(s.text(card.data['name']),style:skin.display(24,color:skin.purpleTitle)),Text(s.text(card.data['subtitle']),style:skin.body(14,color:skin.inkSoft)),const SizedBox(height:10),...blocks(lesson),const SizedBox(height:12),RomanButton(skin:skin,label:s.label('actions.close'),style:RomanButtonStyle.gold,onPressed:()=>Navigator.pop(ctx)),
 ]))));
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
  Widget panel(Widget child) => painted ? Padding(padding:const EdgeInsets.only(bottom:10),child:RomanPanel(skin:skin,child:child)) : Card(
    child: Padding(padding: EdgeInsets.all(number('spacing')), child: child),
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
  Widget world(BuildContext context) {
    final nodes = location?.children ?? d.places;
    final bg =
        location?.data['presentation']?['background'] ??
        d.root['presentation']?['background'];
    return Stack(
      fit: StackFit.expand,
      children: [
        if (bg != null) picture(bg as String, fit: BoxFit.cover),
        constrained(
          ListView(
            padding: EdgeInsets.all(number('spacing')),
            children: [
              panel(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading(s.text(location?.data['name'] ?? d.root['name'])),
                    Text(
                      s.text(location?.data['subtitle'] ?? d.root['subtitle']),
                    ),
                  ],
                ),
              ),
              if (s.encounter != null)
                panel(
                  FilledButton(
                    onPressed: () => setState(() => screen = 'encounter'),
                    child: Text(s.label('actions.resume')),
                  ),
                ),
              for (final node in nodes)
                panel(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (node.data['presentation']?['image'] != null)
                        picture(
                          node.data['presentation']['image'] as String,
                          height: 130,
                        ),
                      heading(s.text(node.data['name'])),
                      Text(s.text(node.data['subtitle'])),
                      if (node.kind == 'card')
                        Wrap(
                          spacing: 16,
                          children: [
                            Text(
                              '${s.label('labels.lives')}: ${node.data['encounter']['lives']}',
                            ),
                            Text(
                              '${s.label('labels.target')}: ${node.data['encounter']['target']}',
                            ),
                          ],
                        ),
                      if (!s.unlocked(node))
                        Text(
                          '${s.label('labels.price')}: ${node.price} ${s.label('labels.currency')}',
                        ),
                      if (!s.meets(node.requirements))
                        Text(
                          '${s.label('labels.requirements')}: ${requirementText(node.requirements)}',
                        ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: s.busy
                            ? null
                            : s.unlocked(node)
                            ? () async {
                                if (node.kind == 'card') {
                                  await s.start(node);
                                  if (mounted) {
                                    setState(() => screen = 'encounter');
                                  }
                                } else {
                                  setState(() => location = node);
                                }
                              }
                            : s.purchasable(node)
                            ? () => s.buy(node)
                            : null,
                        child: Text(
                          s.unlocked(node)
                              ? s.label('actions.start')
                              : s.purchasable(node)
                              ? s.label('actions.buy')
                              : s.label('state.locked'),
                        ),
                      ),
                    ],
                  ),
                ),
              if (nodes.isEmpty) panel(Text(s.label('state.empty'))),
            ],
          ),
        ),
      ],
    );
  }

  String requirementText(Json rule) {
    final e = rule.entries.single;
    if (e.key == 'all' || e.key == 'any') {
      return objects(e.value)
          .map(requirementText)
          .join(e.key == 'all' ? (painted ? ', ' : ' ∧ ') : ' ∨ ');
    }
    if (e.key == 'not') return '¬ (${requirementText(object(e.value))})';
    if (e.key == 'skill') {
      return '${s.text(d.knowledge[e.value['id']]?['name'])} ≥ ${s.text(objects(s.mastery['levels'])[e.value['minLevel'] ?? 0]['name'])}';
    }
    final id = e.key == 'count' ? e.value['card'] : e.value;
    return s.text(d.nodes[id]?.data['name']);
  }

  Widget encounter(BuildContext context) {
    final b = s.encounter;
    if (b == null) return Center(child: Text(s.label('state.empty')));
    final card = d.cards[b['card']];
    if (card == null) return Center(child: Text(s.label('state.empty')));
    final phase = b['phase'];
    if (phase == 'introduction') {
      return constrained(
        Column(
          children: [
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: d.lesson(card),
                builder: (context, snapshot) => snapshot.hasData
                    ? ListView(
                        padding: EdgeInsets.all(number('spacing')),
                        children: [
                          panel(heading(s.text(card.data['name']))),
                          ...blocks(snapshot.data!),
                        ],
                      )
                    : Center(child: Text(s.label('state.loading'))),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(number('spacing')),
              child: FilledButton(
                onPressed: s.begin,
                child: Text(s.label('actions.start')),
              ),
            ),
          ],
        ),
      );
    }
    if (phase == 'paused') {
      return Center(
        child: panel(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              heading(s.label('actions.pause')),
              FilledButton(
                onPressed: s.resume,
                child: Text(s.label('actions.resume')),
              ),
              TextButton(
                onPressed: back,
                child: Text(s.label('actions.leave')),
              ),
            ],
          ),
        ),
      );
    }
    if (phase == 'victory' || phase == 'defeat') {
      return Center(
        child: panel(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              heading(s.label('state.$phase')),
              Text(
                '${s.label('labels.correctAnswers')}: ${b['correct']} / ${b['answered']}',
              ),
              Text(
                '${s.label('labels.currency')}: ${b['gain']} + (${b['adjustment']})',
              ),
              FilledButton(
                onPressed: () async {
                  await s.finish();
                  if (mounted) setState(() => screen = 'world');
                },
                child: Text(s.label('actions.continue')),
              ),
            ],
          ),
        ),
      );
    }
    final q = s.question!;
    final view = object(card.data['presentation'] ?? {});
    return constrained(
      ListView(
        padding: EdgeInsets.all(number('spacing')),
        children: [
          panel(
            Row(
              children: [
                Expanded(
                  child: Text('${s.label('labels.lives')}: ${b['lives']}'),
                ),
                Text('${s.label('labels.target')}: ${b['remaining']}'),
                IconButton(
                  tooltip: s.label('actions.pause'),
                  onPressed: s.pause,
                  icon: const Icon(Icons.pause),
                ),
              ],
            ),
          ),
          if (view['hero'] != null)
            SceneView(
              design: d,
              view: view,
              phase: phase,
              correct: b['lastCorrect'] == true,
              reducedMotion: s.state['settings']['reducedMotion'] == true,
            ),
          panel(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                heading(s.text(q.data['prompt'])),
                const SizedBox(height: 16),
                content(q, b['chosen'] as String?),
                for (final c in q.data['context'] as List? ?? [])
                  Text(s.text(c)),
                const SizedBox(height: 16),
                for (var i = 0; i < q.choices.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: FilledButton.tonal(
                      onPressed: phase == 'question' && !s.busy
                          ? () => s.answer(q.choices[i]['id'] as String)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          '${i + 1}. ${s.text(q.choices[i]['text'])}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () async {
                    if (phase == 'question') await s.help();
                    if (context.mounted) await showHelp(context, q, card);
                  },
                  child: Text(s.label('actions.help')),
                ),
              ],
            ),
          ),
          if (phase == 'feedback')
            panel(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  heading(
                    s.label(
                      b['lastCorrect'] == true
                          ? 'state.correct'
                          : 'state.incorrect',
                    ),
                  ),
                  Text(
                    s.text(q.outcome(b['chosen'])['feedback']),
                    style: TextStyle(fontSize: number('bodySize')),
                  ),
                  FilledButton(
                    onPressed: s.advance,
                    child: Text(s.label('actions.continue')),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                for (final c in b['columns'] as List)
                  DataColumn(label: Text(s.text(c))),
              ],
              rows: [
                for (final row in b['rows'] as List)
                  DataRow(
                    cells: [
                      for (final c in row as List) DataCell(Text(s.text(c))),
                    ],
                  ),
              ],
            ),
          ),
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
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 750),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: heading(s.label('actions.help')),
              ),
              Expanded(child: ListView(children: blocks(content))),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(s.label('actions.close')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget progress() {
    Widget node(Json n, int depth) {
      final children = d.knowledge.values
          .where((c) => c['parent'] == n['id'] && c['visible'] != false)
          .toList();
      final r = s.skill(n['id'] as String);
      final est = s.estimate(r);
      final title = Text(
        s.text(n['name']),
        style: TextStyle(
          fontSize: number('bodySize'),
          fontWeight: FontWeight.bold,
        ),
      );
      if (children.isNotEmpty) {
        return ExpansionTile(
          title: title,
          children: [for (final child in children) node(child, depth + 1)],
        );
      }
      return ListTile(
        title: title,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.text(objects(s.mastery['levels'])[s.level(n['id'])]['name']),
            ),
            LinearProgressIndicator(value: est ?? 0),
            Text(
              '${s.label('labels.successes')}: ${r['correct'] ?? 0} · ${s.label('labels.failures')}: ${r['wrong'] ?? 0}',
            ),
          ],
        ),
        trailing: Text(est == null ? '—' : '${(est * 100).round()}%'),
      );
    }

    return constrained(
      ListView(
        padding: EdgeInsets.all(number('spacing')),
        children: [
          panel(heading(s.label('actions.progress'))),
          for (final n in d.knowledge.values.where(
            (n) => n['parent'] == null && n['visible'] != false,
          ))
            panel(node(n, 0)),
        ],
      ),
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
          TextButton(
            onPressed: () {
              setState(() {
                screen = 'world';
                location = d.cards[target['card']]!.parent;
              });
            },
            child: Text(
              '${s.text(d.cards[target['card']]!.data['name'])}${s.unlocked(d.cards[target['card']]!) ? '' : ' · ${s.label('state.locked')}'}',
            ),
          ),
      ],
    );
  }

  Widget settings(BuildContext context) => constrained(
    ListView(
      padding: EdgeInsets.all(number('spacing')),
      children: [
        panel(heading(s.label('actions.settings'))),
        panel(
          Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: s.locale,
                decoration: InputDecoration(
                  labelText: s.label('labels.language'),
                ),
                items: [
                  for (final locale in d.locales.keys)
                    DropdownMenuItem(
                      value: locale,
                      child: Text(
                        d.locales[locale]?['locale.name'] as String? ?? locale,
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) s.setting('locale', v);
                },
              ),
              for (final key in ['sound', 'music', 'reducedMotion'])
                SwitchListTile(
                  title: Text(s.label('labels.$key')),
                  value: s.state['settings'][key] == true,
                  onChanged: (v) async {
                    await s.setting(key, v);
                    await configureAudio();
                  },
                ),
              Text(s.label('labels.volume')),
              Slider(
                value: (s.state['settings']['volume'] as num? ?? 0.5)
                    .toDouble(),
                onChanged: (v) async {
                  await s.setting('volume', v);
                  await configureAudio();
                },
              ),
              TextButton(
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: s.exportJson)),
                child: Text(s.label('actions.export')),
              ),
              TextButton(
                onPressed: () => importDialog(context),
                child: Text(s.label('actions.import')),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Future<void> importDialog(BuildContext context) async {
    final input = TextEditingController();
    String? error;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: Text(s.label('actions.import')),
          content: SizedBox(
            width: 600,
            child: TextField(
              controller: input,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: s.label('labels.importData'),
                errorText: error,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.label('actions.cancel')),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await s.importSave(input.text);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  update(() => error = e.toString());
                }
              },
              child: Text(s.label('actions.save')),
            ),
          ],
        ),
      ),
    );
    input.dispose();
  }
}

/// A generic two-actor scene. Assets and motion parameters belong to the card.
class SceneView extends StatelessWidget {
  const SceneView({
    super.key,
    required this.design,
    required this.view,
    required this.phase,
    required this.correct,
    required this.reducedMotion,
  });
  final GameDesign design;
  final Json view;
  final String phase;
  final bool correct, reducedMotion;
  @override
  Widget build(BuildContext context) {
    final theme = object(design.root['theme']);
    double n(String key) => (theme[key] as num).toDouble();
    final pose =
        view[switch (phase) {
          'feedback' => correct ? 'heroCorrect' : 'heroWrong',
          'victory' => 'heroVictory',
          'defeat' => 'heroDefeat',
          _ => 'hero',
        }] ??
        view['hero'];
    Widget image(String id) =>
        Image.asset(design.asset(id), fit: BoxFit.contain);
    return SizedBox(
      height: n('sceneHeight'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(n('sceneRadius')),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (view['background'] != null)
              Image.asset(design.asset(view['background']), fit: BoxFit.cover),
            AnimatedAlign(
              duration: Duration(
                milliseconds: reducedMotion
                    ? 0
                    : (theme['motionDurationMs'] as int),
              ),
              alignment: Alignment(
                phase == 'feedback' && correct && view['motion'] == 'lunge'
                    ? n('strikeX')
                    : n('heroX'),
                n('actorY'),
              ),
              child: SizedBox(
                height: n('sceneActorHeight'),
                width: n('sceneActorWidth'),
                child: image(pose),
              ),
            ),
            Align(
              alignment: Alignment(n('opponentX'), n('actorY')),
              child: AnimatedOpacity(
                opacity: phase == 'feedback' && correct ? n('hitOpacity') : 1,
                duration: Duration(
                  milliseconds: reducedMotion
                      ? 0
                      : (theme['motionDurationMs'] as int),
                ),
                child: SizedBox(
                  height: n('sceneActorHeight'),
                  width: n('sceneActorWidth'),
                  child: image(view['opponent']),
                ),
              ),
            ),
            if (phase == 'feedback' && correct && view['projectile'] != null)
              Center(
                child: SizedBox(
                  height: n('effectSize'),
                  width: n('effectSize'),
                  child: image(view['projectile']),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
