import '../../engine/design.dart';
import '../../engine/session.dart';

/// Read-only presentation adapters. They expose stored text and resolved state;
/// no content, answers, or pedagogical relationships are produced here.
class TrialView {
  TrialView(this.session, this.node);
  final GameSession session;
  final ContentNode node;
  String get id => node.address;
  String get name => session.text(node.data['name']);
  String get subtitle => session.text(node.data['subtitle']);
  int get hearts => node.data['encounter']['lives'] as int;
  int get target => node.data['encounter']['target'] as int;
  List<String> get skillIds => strings(node.data['skills']);
  ContentNode get place { var n=node; while(n.parent!=null){n=n.parent!;} return n; }
  Json get presentation => object(node.data['presentation']);
  String label(String key) => session.text(place.data['presentation']['labels'][key]);
}

enum BattlePhase { intro, question, correct, wrong, victory, defeat }
class BattleView {
  BattleView(this.session, this.trial);
  final GameSession session;
  final TrialView trial;
  Json get data => session.encounter!;
  bool get paused => data['phase']=='paused';
  BattlePhase get phase => switch(data['phase']) {
    'introduction'=>BattlePhase.intro,
    'feedback'=>data['lastCorrect']==true?BattlePhase.correct:BattlePhase.wrong,
    'victory'=>BattlePhase.victory,
    'defeat'=>BattlePhase.defeat,
    _=>BattlePhase.question,
  };
  bool get isOver => phase==BattlePhase.victory||phase==BattlePhase.defeat;
  bool get acceptsInput => !session.busy&&data['phase']=='question';
  int get enemyHp => data['remaining'] as int;
  int get enemyMaxHp => trial.target;
  int get hearts => data['lives'] as int;
  int get maxHearts => trial.hearts;
  int get answered => data['answered'] as int;
  int get correctCount => data['correct'] as int;
  int get gemsDelta => data['gain'] as int;
  int get victoryBonus => data['adjustment'] as int? ?? 0;
  int get defeatPenalty => -(data['adjustment'] as int? ?? 0);
  QuestionView? get question => session.question==null?null:QuestionView(session,session.question!);
  OutcomeView? get last => data['chosen']==null||question==null?null:OutcomeView(this,question!);
}
class QuestionView {
  QuestionView(this.session,this.entry);
  final GameSession session;
  final QuestionEntry entry;
  String get id=>entry.id;
  String get surface=>objects(entry.data['content']).map((p)=>session.text(p['text'])).join();
  List<Json>? get syntagma=>entry.interaction=='choice'?null:objects(entry.data['content']);
  List<String> get context=>(entry.data['context'] as List? ?? []).map(session.text).toList();
  String get prompt=>session.text(entry.data['prompt']);
  bool get ambiguous=>entry.accepted.length>1;
  List<ChoiceView> get choices=>entry.choices.map((c)=>ChoiceView(c['id'] as String,session.text(c['text']))).toList();
  List<String> get correctValues=>entry.accepted;
}
class ChoiceView {
  const ChoiceView(this.value,this.label);
  final String value,label;
}
class OutcomeView {
  OutcomeView(this.state,this.question);
  final BattleView state;
  final QuestionView question;
  bool get correct=>state.data['lastCorrect']==true;
  String get chosenValue=>state.data['chosen'] as String;
  int get sequence=>state.answered;
  int get gemsDelta {
    final observations=objects(state.session.state['observations']);
    return observations.isEmpty?0:observations.last['delta'] as int? ?? 0;
  }
  String get explanation=>state.session.text(question.entry.outcome(chosenValue)['feedback']);
}
