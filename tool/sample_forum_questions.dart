// Prints sample questions of Forum cards, with the pool size and the
// dimensions actually asked (a card whose pool has a single value for a
// dimension never asks it).
//
//   dart run tool/sample_forum_questions.dart            # every card, 3 samples
//   dart run tool/sample_forum_questions.dart syn-ae 12  # one card, 12 samples
import 'dart:io';
import 'dart:math';

import 'package:grammaticon/linguistics/lexicon/forum_lexicon.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/mastery.dart';
import 'package:grammaticon/pedagogy/skills.dart';
import 'package:grammaticon/pedagogy/trials.dart';

void main(List<String> args) {
  final src = ForumQuestionSource(buildNominalAnalyzer(), kSyntagmata);
  final trials = args.isEmpty ? Trials.ofActivity(Activity.forum) : [Trials.byId(args[0])];
  final n = args.length > 1 ? int.parse(args[1]) : 3;
  final strong = SkillRecord(autonomousCorrect: 20, estimate: 0.95, highWater: 0.95, lemmas: {'a', 'b', 'c', 'd', 'e'}, sessionDays: {'1', '2'}, lastPractice: DateTime.now());
  var missing = 0;
  for (final t in trials) {
    final comps = t.components.map((c) => c.id).toList();
    final pool = src.pool(t, comps);
    final skills = {for (final l in Skills.leaves(t.primarySkill)) l: strong};
    final rng = Random(7);
    final asked = <Dimension>{};
    final lines = <String>[];
    for (var i = 0; i < max(n, 40); i++) {
      final q = src.generate(trial: t, componentIds: comps, rng: rng, id: '$i', skills: skills);
      if (q == null) continue;
      asked.add(q.dimension);
      if (q.followUp != null) asked.add(q.followUp!.dimension);
      if (lines.length < n) {
        final where = q.syntagma == null ? q.surface : q.syntagma!;
        lines.add('    $where  [${q.dimension.name}] → ${q.choices.map((c) => (q.correctValues.contains(c.value) ? '✓' : ' ') + c.label).join(' | ')}${q.followUp == null ? '' : '   ⤷ ${q.followUp!.dimension.name}'}');
      }
    }
    final never = t.dimensions.where((d) => !asked.contains(d)).map((d) => d.name).toList();
    stdout.writeln('${t.id.padRight(18)} pool ${pool.length.toString().padLeft(5)} · asked ${asked.map((d) => d.name).join(',')}${never.isEmpty ? '' : '   NEVER: ${never.join(',')}'}');
    if (pool.isEmpty) missing++;
    lines.forEach(stdout.writeln);
  }
  if (missing > 0) stderr.writeln('$missing card(s) without content');
}
