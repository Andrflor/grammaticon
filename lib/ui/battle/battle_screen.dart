import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../app/theme.dart';
import '../../engine/design.dart';
import '../../engine/session.dart';
import '../../game/arena_game.dart';
import '../../game/forum_game.dart';
import '../activity/presentation_binding.dart';
import '../widgets/roman_widgets.dart';
import '../help/help_sheet.dart';

class BattleScreen extends HookWidget {
 const BattleScreen({super.key,required this.session,required this.skin,required this.node,required this.onLeave,required this.onHelp});
 final GameSession session;
 final G skin;
 final ContentNode node;
 final VoidCallback onLeave;
 final Future<void> Function(BuildContext,QuestionEntry,ContentNode) onHelp;
 @override
 Widget build(BuildContext context){
 useListenable(session);
 final trial=TrialView(session,node);
 final state=BattleView(session,trial);
 final reduced=session.state['settings']['reducedMotion']==true;
 final game=useMemoized(()=>trial.presentation['motion']=='projectile'?ProjectileScene(design:session.design,view:trial.presentation,skin:skin,reducedMotion:reduced):StrikeScene(design:session.design,view:trial.presentation,skin:skin,reducedMotion:reduced),[trial.id]);
 game.reducedMotion=reduced;
 final cardKey=useMemoized(()=>GlobalKey(debugLabel:'questionCard'));
 final startTiers=useMemoized(()=>{for(final id in trial.skillIds)id:session.level(id)},[session.encounter?['id']]);
 final flights=useState<List<_GemFlightSpec>>([]);
 final timers=useRef(<Timer>[]);
 final lesson=useFuture(useMemoized(()=>session.design.lesson(node),[trial.id]));
 final currencyAsset=session.design.asset(session.design.root['presentation']['currency']);
 final lastAnswer=useRef(state.answered);
 final lastPhase=useRef(state.phase);
 void later(int ms,VoidCallback action){timers.value.add(Timer(Duration(milliseconds:ms),action));}
 useEffect((){return (){for(final t in timers.value){t.cancel();}};},[]);
 useEffect((){
 if(state.answered!=lastAnswer.value&&state.last!=null){
 lastAnswer.value=state.answered;
 if(state.last!.correct){game.playerStrikes();
 if(state.last!.gemsDelta>0&&!reduced){
 final from=_centerOf(cardKey),to=_centerOf(GemTarget.key);
 if(from!=null&&to!=null){final id=DateTime.now().microsecondsSinceEpoch;later(0,()=>flights.value=[...flights.value,_GemFlightSpec(id,from,to,min(state.last!.gemsDelta,8))]);later(1500,()=>flights.value=flights.value.where((f)=>f.id!=id).toList());}
 }
 }else{game.opponentStrikes();}
 }
 if(lastPhase.value!=state.phase){
 lastPhase.value=state.phase;
 if(state.phase==BattlePhase.victory)game.victory();
 if(state.phase==BattlePhase.defeat)game.defeat();
 if(state.phase==BattlePhase.intro||state.phase==BattlePhase.question)game.resetPoses();
 }
 return null;
 },[state.answered,state.phase]);
 Future<void> leave()async{if(state.isOver){await session.finish();}else{await session.pause();}onLeave();}
 Future<void> retry()async{await session.finish();await session.start(node);}
 final route=ModalRoute.of(context);
 useEffect((){
 bool handler(KeyEvent e){
 if(e is! KeyDownEvent||!(route?.isCurrent??true))return false;
 final key=e.logicalKey;
 final proceed=key==LogicalKeyboardKey.space||key==LogicalKeyboardKey.enter||key==LogicalKeyboardKey.numpadEnter;
 if(key==LogicalKeyboardKey.escape){state.isOver?leave():state.paused?session.resume():session.pause();return true;}
 if(proceed){state.isOver?retry():state.phase==BattlePhase.intro?session.begin():session.advance();return true;}
 final digit=_digitOf(e);
 if(digit!=null&&state.acceptsInput&&digit<=state.question!.choices.length){session.answer(state.question!.choices[digit-1].value);return true;}return false;
 }
 HardwareKeyboard.instance.addHandler(handler);return()=>HardwareKeyboard.instance.removeHandler(handler);
 },[state.phase,state.answered,route]);
 return PopScope(canPop:false,onPopInvokedWithResult:(didPop,_){if(!didPop)leave();},child:Focus(autofocus:true,child:Scaffold(backgroundColor:skin.purpleDark,body:Stack(fit:StackFit.expand,children:[
 GameWidget(game:game),
 _Hud(skin:skin,state:state,config:trial,onLeave:leave,onPause:()=>state.paused?session.resume():session.pause()),
 _Center(skin:skin,state:state,cardKey:cardKey,trial:trial,config:trial,onHelp:onHelp),
 if(state.phase==BattlePhase.intro&&lesson.hasData)_IntroOverlay(skin:skin,trial:trial,lesson:objects(lesson.data),onStart:session.begin),
 if(state.paused)_PauseOverlay(skin:skin,session:session,body:trial.label('pausedBody'),onResume:session.resume,onLeave:leave),
 if(state.isOver)_ResultOverlay(skin:skin,state:state,config:trial,startTiers:startTiers,onLeave:leave,onRetry:retry),
 for(final f in flights.value)_GemFlight(key:ValueKey(f.id),currencyAsset:currencyAsset,spec:f),
 ]))));
 }
  static const _row = [PhysicalKeyboardKey.digit1, PhysicalKeyboardKey.digit2, PhysicalKeyboardKey.digit3, PhysicalKeyboardKey.digit4, PhysicalKeyboardKey.digit5, PhysicalKeyboardKey.digit6, PhysicalKeyboardKey.digit7, PhysicalKeyboardKey.digit8, PhysicalKeyboardKey.digit9];
  static const _numpad = [PhysicalKeyboardKey.numpad1, PhysicalKeyboardKey.numpad2, PhysicalKeyboardKey.numpad3, PhysicalKeyboardKey.numpad4, PhysicalKeyboardKey.numpad5, PhysicalKeyboardKey.numpad6, PhysicalKeyboardKey.numpad7, PhysicalKeyboardKey.numpad8, PhysicalKeyboardKey.numpad9];

  /// The digit 1–9 a key press stands for, or null.
  ///
  /// The physical key comes first so that the number row answers whatever the
  /// layout (on an AZERTY keyboard the unshifted row types `&é"'(-è_ç`, and
  /// its logical keys and characters are not digits); the logical key and the
  /// typed character cover keyboards without a standard row (remapped or
  /// on-screen).
  static int? _digitOf(KeyEvent e) {
    var i = _row.indexOf(e.physicalKey);
    if (i < 0) i = _numpad.indexOf(e.physicalKey);
    if (i >= 0) return i + 1;
    final k = e.logicalKey;
    if (k.keyId >= LogicalKeyboardKey.digit1.keyId && k.keyId <= LogicalKeyboardKey.digit9.keyId) return k.keyId - LogicalKeyboardKey.digit0.keyId;
    if (k.keyId >= LogicalKeyboardKey.numpad1.keyId && k.keyId <= LogicalKeyboardKey.numpad9.keyId) return k.keyId - LogicalKeyboardKey.numpad0.keyId;
    final c = int.tryParse(e.character ?? '');
    return c != null && c >= 1 && c <= 9 ? c : null;
  }

  static Offset? _centerOf(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }
}

class _Hud extends StatelessWidget {
 String get currencyAsset=>state.session.design.asset(state.session.design.root['presentation']['currency']);
 final G skin;
  const _Hud({required this.skin,required this.state, required this.config, required this.onLeave, required this.onPause});
  final BattleView state;
  final TrialView config;
  final VoidCallback onLeave;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final gems = state.session.balance;
    final enemyName = config.session.text(config.presentation['opponentName']);
    // The opponent's remaining resource: health in the arena, resolve in the Forum.
    final resource = config.label('opponentResource');
    final compact = MediaQuery.sizeOf(context).width < 600;
    final bar = Column(
      children: [
        Text(enemyName, style: skin.display(14, color: skin.goldLight), maxLines: 1, overflow: TextOverflow.ellipsis),
        SizedBox(height: 3),
        // Stadium shapes, not a clipped stack: Impeller on OpenGL ES does not
        // anti-alias clips.
        Stack(
          children: [
            Container(height: 14, decoration: ShapeDecoration(shape: StadiumBorder(), color: Color(0xAA200A40))),
            AnimatedFractionallySizedBox(
              duration: Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              widthFactor: (state.enemyHp / state.enemyMaxHp).clamp(0.0, 1.0),
              child: Container(
                height: 14,
                decoration: ShapeDecoration(shape: StadiumBorder(), gradient: LinearGradient(colors: [skin.red, Color(0xFFFF8A94)])),
              ),
            ),
          ],
        ),
        Text('${resource.isEmpty ? '' : '$resource '}${state.enemyHp} / ${state.enemyMaxHp}', style: skin.body(11, color: Colors.white, weight: 700)),
      ],
    );
    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RomanButton(skin:skin,label: '', icon: Icons.arrow_back, style: RomanButtonStyle.ghost, dense: true, onPressed: onLeave),
        SizedBox(width: 6),
        RomanButton(skin:skin,label: '', icon: state.paused ? Icons.play_arrow : Icons.pause, style: RomanButtonStyle.ghost, dense: true, onPressed: state.isOver ? null : onPause),
        SizedBox(width: 10),
        for (var i = 0; i < state.maxHearts; i++)
          Padding(padding: EdgeInsets.only(right: 2), child: Image.asset(i < state.hearts ? state.session.design.asset(state.session.design.root['presentation']['life']) : state.session.design.asset(state.session.design.root['presentation']['emptyLife']), width: 30, height: 30)),
      ],
    );
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(kHudSidePadding, kHudTopPadding, kHudSidePadding, 0),
        child: Column(
          children: [
            HudRow(
              left: controls,
              // Wide screens: the opponent bar sits between the hearts and the gems,
              // centred on the screen whatever the width of either side.
              center: compact ? null : bar,
              // Size 34 gives the counter the same 46 px pill height as the ghost
              // buttons, in the same place as on every other screen. No cog here:
              // the Optiōnēs are not opened from inside a trial.
              right: CurrencyCounter(skin:skin,asset:currencyAsset,count:gems,size:34,isFlightTarget:true),
            ),
            // Narrow screens: the bar takes its own line under the controls.
            if (compact) Padding(padding: EdgeInsets.fromLTRB(40, 4, 40, 0), child: bar),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- question, choices, feedback

class _Center extends StatelessWidget {
 String get currencyAsset=>state.session.design.asset(state.session.design.root['presentation']['currency']);
 final Future<void> Function(BuildContext,QuestionEntry,ContentNode) onHelp;
 final G skin;
  const _Center({required this.onHelp,required this.skin,required this.state, required this.cardKey, required this.trial, required this.config});
  final BattleView state;
  final GlobalKey cardKey;
  final TrialView trial;
  final TrialView config;

  @override
  Widget build(BuildContext context) {
    final ctrl = state.session;
    final q = state.question ?? state.last?.question;
    if (q == null || state.phase == BattlePhase.intro || state.isOver) return SizedBox.shrink();
    final outcome = state.phase == BattlePhase.correct || state.phase == BattlePhase.wrong ? state.last : null;
    final showFeedback = outcome != null && outcome.question.id == q.id;
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 600;
    // A sentence (Theatrum) wraps at a readable size; an isolated form is
    // scaled to the width.
    final long = config.presentation['longText']==true;
    final surfaceSize = long ? (compact ? (q.surface.length > 140 ? 15.0 : 17.0) : (q.surface.length > 160 ? 19.0 : (q.surface.length > 100 ? 21.0 : 25.0))) : (w / (q.surface.length + 6)).clamp(22.0, compact ? 34.0 : 48.0);

    return SafeArea(
      child: Column(
        children: [
          // Room for the HUD (two lines on narrow screens).
          SizedBox(height: compact ? 132 : 72),
          // Question card
          RomanPanel(skin:skin,
            key: cardKey,
            width: min(w - 24, long ? 900 : 760),
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('${trial.name} · ${state.answered}/${state.enemyMaxHp}', style: skin.body(12, color: skin.inkSoft, weight: 700)),
                    ),
                    RomanButton(skin:skin,
                      label: state.session.label('actions.help'),
                      icon: Icons.help_outline,
                      style: RomanButtonStyle.neutral,
                      dense: true,
                      sound: null,
                      onPressed: () async {
                        final open = state.phase == BattlePhase.question;
                        if (open) ctrl.help();
                        
                        await onHelp(context, q.entry, trial.node);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 6),
                // A contextual item shows the whole phrase with the asked
                // word highlighted; an isolated form is scaled to the width.
                if (q.syntagma != null)
                  QuestionContent(session:state.session,parts:q.syntagma!,size: (w / (q.surface.length + 4)).clamp(18.0, compact ? 26.0 : 34.0))
                else
                  Text(
                    q.surface,
                    textAlign: TextAlign.center,
                    style: skin.display(surfaceSize, color: skin.purpleDark, letterSpacing: long ? 0.3 : 2).copyWith(height: long ? 1.3 : null),
                  ),
                // Context lines (dictionary entry) never give the answer away.
                for (final line in q.context) Text(line, textAlign: TextAlign.center, style: skin.body(compact ? 13 : 15, color: skin.inkSoft, style: FontStyle.italic)),
                SizedBox(height: 4),
                Text(q.prompt, style: skin.body(compact ? 16 : 20, color: skin.inkSoft, weight: 700)),
                if (q.ambiguous)
                  Text(
                    state.session.label('labels.multipleCorrect'),
                    style: skin.body(12, color: skin.inkSoft, style: FontStyle.italic),
                  ),
              ],
            ),
          ),
          SizedBox(height: 10),
          // Feedback
          SizedBox(
            height: compact ? 44 : 52,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 180),
              transitionBuilder: (c, a) => ScaleTransition(
                scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
                child: c,
              ),
              child: showFeedback
                  ? Row(
                      key: ValueKey(outcome.sequence),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.session.label(outcome.correct?'state.correct':'state.incorrect'), style: skin.display(compact ? 26 : 34, color: outcome.correct ? skin.green : skin.red)),
                        if (outcome.gemsDelta != 0) ...[
                          SizedBox(width: 12),
                          Text('${outcome.gemsDelta > 0 ? '+' : ''}${outcome.gemsDelta}', style: skin.display(compact ? 22 : 28, color: outcome.gemsDelta > 0 ? skin.goldLight : Color(0xFFFF8A94))),
                          SizedBox(width: 4),
                          Image.asset(currencyAsset, width: 26, height: 26),
                        ],
                      ],
                    )
                  : SizedBox.shrink(),
            ),
          ),
          // The lower block (correction and choices) is anchored to the bottom
          // and scrolls only when sentences do not fit (small screens).
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
          // Wrong-answer explanation
          if (showFeedback && !outcome.correct)
            Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: RomanPanel(skin:skin,
                width: min(w - 24, long ? 900 : 760),
                color: Color(0xFFFFF4F5),
                borderColor: skin.red,
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(outcome.explanation, style: skin.body(15, weight: 800, color: skin.purpleDark)),
                    SizedBox(height: 4),
                    SizedBox(height: 8),
                    // Wraps on narrow screens instead of overflowing.
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        RomanButton(skin:skin,
                          label: state.session.label('actions.explain'),
                          icon: Icons.menu_book,
                          style: RomanButtonStyle.neutral,
                          dense: true,
                          sound: null,
                          onPressed: () async {
                            
                            await onHelp(context, q.entry, trial.node);
                          },
                        ),
                        RomanButton(skin:skin,label: state.session.label('actions.continue'), icon: Icons.arrow_forward, style: RomanButtonStyle.gold, onPressed: ctrl.advance),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          // Choices (stable order while the question is shown)
          Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: _Choices(skin:skin,q: q, state: state, onPick: (i) => ctrl.answer(q.choices[i].value)),
          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Choices extends StatelessWidget {
 final G skin;
  const _Choices({required this.skin,required this.q, required this.state, required this.onPick});
  final QuestionView q;
  final BattleView state;
  final void Function(int) onPick;

  @override
  Widget build(BuildContext context) {
    final outcome = state.last;
    final answered = state.phase != BattlePhase.question && outcome != null && outcome.question.id == q.id;
    final w = MediaQuery.sizeOf(context).width;
    final n = q.choices.length;
    // Narrow screens: long labels (Nōminātīvus, Plūsquamperfectum) get a full row
    // so they never break mid-word.
    final longest = q.choices.fold(0, (m, c) => max(m, c.label.length));
    // Sentences (Theatrum): one per row, two on wide screens.
    final sentences = longest > 32;
    final perRow = sentences ? (w < 900 ? 1 : 2) : (w < 600 ? (n <= 2 ? n : (longest > 9 ? 1 : 2)) : (n <= 4 ? n : 3));
    final bw = ((min(w, sentences ? 1200 : 1000) - 24) - (perRow - 1) * 10) / perRow;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < n; i++)
          SizedBox(
            width: bw,
            child: _ChoiceButton(skin:skin,
              index: i,
              label: q.choices[i].label,
              enabled: state.acceptsInput,
              isCorrect: answered && q.correctValues.contains(q.choices[i].value),
              isChosen: answered && outcome.chosenValue == q.choices[i].value,
              wrong: answered && outcome.chosenValue == q.choices[i].value && !outcome.correct,
              dense: sentences,
              onTap: () => onPick(i),
            ),
          ),
      ],
    );
  }
}

class _ChoiceButton extends HookWidget {
 final G skin;
  const _ChoiceButton({required this.skin,required this.index, required this.label, required this.enabled, required this.isCorrect, required this.isChosen, required this.wrong, required this.onTap, this.dense = false});
  final int index;
  final String label;
  final bool enabled;
  final bool isCorrect;
  final bool isChosen;
  final bool wrong;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final shake = useAnimationController(duration: Duration(milliseconds: 320));
    useEffect(() {
      if (wrong) shake.forward(from: 0);
      return null;
    }, [wrong]);
    final style = isCorrect ? RomanButtonStyle.success : (wrong ? RomanButtonStyle.danger : RomanButtonStyle.primary);
    return AnimatedBuilder(
      animation: shake,
      builder: (context, child) {
        final dx = sin(shake.value * pi * 6) * (1 - shake.value) * 8;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: AnimatedScale(
        duration: Duration(milliseconds: 120),
        scale: isChosen ? 1.04 : 1,
        child: RomanButton(skin:skin,
          label: label,
          badge: '${index + 1}',
          style: style,
          expand: true,
          dense: dense,
          sound: null,
          onPressed: enabled ? onTap : null,
          trailing: isCorrect ? Icon(Icons.check_circle, color: Colors.white) : (wrong ? Icon(Icons.cancel, color: Colors.white) : null),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- overlays

class _IntroOverlay extends StatelessWidget {
 final G skin;
 final List<Json> lesson;
  const _IntroOverlay({required this.skin,required this.trial, required this.lesson, required this.onStart});
  final TrialView trial;
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) => _Dim(
    child: RomanPanel(skin:skin,
      width: min(MediaQuery.sizeOf(context).width - 32, 640),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(trial.name, style: skin.display(24, color: skin.purple)),
            Text(trial.subtitle, style: skin.body(14, color: skin.inkSoft, weight: 700)),
            SizedBox(height: 10),
            Text(lesson.where((b)=>b['type']=='text').map((b)=>trial.session.text(b['text'])).join('\n\n'), style: skin.body(16, height: 1.45)),
            SizedBox(height: 10),
            for (final e in lesson.where((b)=>b['type']=='example').map((b)=>trial.session.text(b['text'])))
              Padding(
                padding: EdgeInsets.symmetric(vertical: 3),
                child: RomanPanel(skin:skin,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: Colors.white,
                  borderColor: skin.marbleDark,
                  shadow: false,
                  radius: 12,
                  child: Text(e, style: skin.body(17, weight: 700, color: skin.purpleDark)),
                ),
              ),
            SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.warning_amber, color: skin.redDark, size: 18),
                SizedBox(width: 6),
                Expanded(
                  child: Text('${trial.hearts} ${trial.session.label('labels.lives')}. ${trial.session.text(trial.session.design.rules['economy']['description'])}', style: skin.body(13, color: skin.redDark, weight: 700)),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [RomanButton(skin:skin,label: trial.session.label('actions.start'), icon: Icons.play_arrow, style: RomanButtonStyle.gold, sound: null, onPressed: onStart)],
            ),
          ],
        ),
      ),
    ),
  );
}

class _PauseOverlay extends StatelessWidget {
 final G skin;
 final GameSession session;
  const _PauseOverlay({required this.skin,required this.session,required this.body, required this.onResume, required this.onLeave});
  final String body;
  final VoidCallback onResume;
  final VoidCallback onLeave;
  @override
  Widget build(BuildContext context) => _Dim(
    child: RomanPanel(skin:skin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(session.label('actions.pause'), style: skin.display(28, color: skin.purple)),
          SizedBox(height: 8),
          Text(body, style: skin.body(16)),
          SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              RomanButton(skin:skin,label: session.label('actions.continue'), icon: Icons.play_arrow, style: RomanButtonStyle.gold, onPressed: onResume),
              RomanButton(skin:skin,label: session.label('actions.leave'), icon: Icons.exit_to_app, style: RomanButtonStyle.neutral, onPressed: onLeave),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ResultOverlay extends StatelessWidget {
 final G skin;
  const _ResultOverlay({required this.skin,required this.state, required this.config, required this.startTiers, required this.onLeave, required this.onRetry});
  final BattleView state;
  final TrialView config;
  final Map<String, int> startTiers;
  final VoidCallback onLeave;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final won = state.phase == BattlePhase.victory;
    final session = state.session;


    return _Dim(
      child: RomanPanel(skin:skin,
        width: min(MediaQuery.sizeOf(context).width - 32, 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(won ? config.label('victoryTitle') : config.label('defeatTitle'), style: skin.display(32, color: won ? skin.green : skin.red)),
            SizedBox(height: 6),
            Text(won ? config.label('victoryBody') : config.label('defeatBody'), style: skin.body(16), textAlign: TextAlign.center),
            SizedBox(height: 14),
            _line(session.label('labels.correctAnswers'), '${state.correctCount} / ${state.answered}'),
            _line(config.label('gemsLine'), '${state.gemsDelta >= 0 ? '+' : ''}${state.gemsDelta}'),
            if (won) _line(session.label('labels.victoryBonus'), '+${state.victoryBonus}'),

            if (!won) _line(config.label('penaltyLine'), '−${state.defeatPenalty}'),
            if (!won)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  session.text(session.design.rules['economy']['description']),
                  style: skin.body(12, color: skin.inkSoft, style: FontStyle.italic),
                ),
              ),
            SizedBox(height: 10),
            Text(session.label('labels.skills'), style: skin.display(15, color: skin.goldDark)),
            for (final s in state.trial.skillIds)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(child: Text(session.text(session.design.knowledge[s]?['name']), style: skin.body(14, weight: 700))),
                    LevelBadge(session:session,skin:skin,level:startTiers[s]??0,dense:true),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.arrow_forward, size: 16)),
                    LevelBadge(session:session,skin:skin,level:session.level(s),dense:true),
                  ],
                ),
              ),
            SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                RomanButton(skin:skin,label: config.label('back'), icon: Icons.stadium, style: RomanButtonStyle.gold, onPressed: onLeave),
                RomanButton(skin:skin,label: session.label('actions.retry'), icon: Icons.replay, style: RomanButtonStyle.primary, onPressed: onRetry),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(String k, String v) => Row(
    children: [
      Expanded(child: Text(k, style: skin.body(15))),
      Text(v, style: skin.body(16, weight: 800)),
    ],
  );
}

class _Dim extends StatelessWidget {
  const _Dim({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(color: Color(0xAA1A0A30), alignment: Alignment.center, padding: EdgeInsets.all(16), child: child);
}

// ---------------------------------------------------------------- flying gems

class _GemFlightSpec {
  _GemFlightSpec(this.id, this.from, this.to, this.count);
  final int id;
  final Offset from;
  final Offset to;
  final int count;
}

class _GemFlight extends HookWidget {
 final String currencyAsset;
  const _GemFlight({required this.currencyAsset,super.key, required this.spec});
  final _GemFlightSpec spec;

  @override
  Widget build(BuildContext context) {
    final c = useAnimationController(duration: Duration(milliseconds: 950));
    useEffect(() {
      c.forward();
      return null;
    }, []);
    final rnd = useMemoized(() => Random(spec.id));
    final offsets = useMemoized(() => [for (var i = 0; i < spec.count; i++) Offset((rnd.nextDouble() - 0.5) * 120, (rnd.nextDouble() - 0.5) * 60)]);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: c,
        builder: (context, _) {
          return Stack(
            children: [
              for (var i = 0; i < spec.count; i++)
                Builder(
                  builder: (context) {
                    final delay = i * 0.06;
                    final t = ((c.value - delay) / (1 - delay)).clamp(0.0, 1.0);
                    final e = Curves.easeInOutCubic.transform(t);
                    final start = spec.from + offsets[i];
                    final ctrl = Offset((start.dx + spec.to.dx) / 2, min(start.dy, spec.to.dy) - 140);
                    final p = _bezier(start, ctrl, spec.to, e);
                    final scale = 1.1 - 0.6 * e;
                    return Positioned(
                      left: p.dx - 14,
                      top: p.dy - 14,
                      child: Opacity(
                        opacity: (t < 0.95 ? 1.0 : 1 - (t - 0.95) / 0.05).clamp(0.0, 1.0),
                        child: Transform.scale(scale: scale, child: Image.asset(currencyAsset, width: 28, height: 28)),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  static Offset _bezier(Offset a, Offset b, Offset c, double t) {
    final u = 1 - t;
    return a * (u * u) + b * (2 * u * t) + c * (t * t);
  }
}
