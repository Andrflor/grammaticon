// ignore_for_file: avoid_print
// Dev tool: samples questions and corrections of the Forum trials.
// Usage: dart run tool/sample_forum_questions.dart [trialId] [count]
import 'dart:math';

import 'package:grammaticon/linguistics/engine/declinator.dart';
import 'package:grammaticon/linguistics/engine/noun_analyzer.dart';
import 'package:grammaticon/linguistics/lexicon/nouns.dart';
import 'package:grammaticon/pedagogy/mastery.dart';
import 'package:grammaticon/pedagogy/noun_question_generator.dart';
import 'package:grammaticon/pedagogy/trials.dart';

void main(List<String> args) {
  final gen = NounQuestionGenerator(NounAnalyzer(kNouns, const Declinator()));
  final trials = args.isEmpty ? Trials.ofActivity(Activity.forum) : [Trials.byId(args[0])];
  final count = args.length > 1 ? int.parse(args[1]) : 4;
  // A "familiar" record so that analysis questions are eligible.
  final rec = List.generate(8, (i) => i).fold(const SkillRecord(), (r, i) => r.apply(Observation(at: DateTime(2026, 1, 1 + i), correct: true, lemmaId: 'l$i', quality: AnswerQuality.autonoma, trialId: 't'), const MasteryConfig()));
  for (final t in trials) {
    print('=== ${t.id} · ${t.name}');
    final rng = Random(42);
    final skills = {for (final s in t.skillIds) for (final l in ['$s.nom.sg', '$s.acc.sg', s]) l: rec};
    for (var i = 0; i < count; i++) {
      final q = gen.generate(trial: t, componentIds: t.components.map((c) => c.id).toList(), rng: rng, id: '$i', skills: skills);
      if (q == null) {
        print('  (null)');
        continue;
      }
      final wrong = q.choices.firstWhere((c) => !q.correctValues.contains(c.value));
      final ex = gen.explain(q: q, chosenValue: wrong.value, correct: false);
      print('  ${q.surface}  ${q.context.join(' | ')}  → ${q.prompt}${q.ambiguous ? ' [ambigua]' : ''}');
      print('     choices: ${q.choices.map((c) => '${q.correctValues.contains(c.value) ? '*' : ''}${c.label}').join(' · ')}   skills: ${q.skillIds}');
      print('     ✗ ${ex.headline}');
      print('       ${ex.detail}${ex.also.isEmpty ? '' : '  Etiam: ${ex.also.join(' · ')}'}');
    }
  }
}
