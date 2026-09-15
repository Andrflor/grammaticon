import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/arbor/arbor.dart';
import 'package:grammaticon/arbor/diagnosis.dart';
import 'package:grammaticon/linguistics/engine/analyzer.dart';
import 'package:grammaticon/linguistics/engine/conjugator.dart';
import 'package:grammaticon/linguistics/lexicon/forum_lexicon.dart';
import 'package:grammaticon/linguistics/lexicon/verbs.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/question_generator.dart';
import 'package:grammaticon/pedagogy/trials.dart';

void main() {
  final analyzer = Analyzer(kVerbs, Conjugator());
  final nominal = buildNominalAnalyzer();
  final arbor = Arbor.standard(analyzer: analyzer, nominal: nominal);
  final verbs = QuestionGenerator(analyzer);
  final forum = ForumQuestionSource(nominal, kSyntagmata);
  final dx = Diagnostician(arbor, verbs, forum);

  test('chaque distracteur généré porte un diagnostic non vide, distinct de la bonne réponse', () {
    final rng = Random(7);
    var questions = 0, distractors = 0, empty = 0, unknownNodes = 0;
    final emptyByDim = <String, int>{};
    final byDim = <String, int>{};
    final samples = <String>[];
    final unknown = <String>{};
    final perDim = <String, int>{};
    for (final trial in Trials.all.where((t) => t.activity == Activity.amphitheatrum || t.activity == Activity.forum)) {
      final source = trial.activity == Activity.amphitheatrum ? verbs : forum;
      final comps = trial.components.map((c) => c.id).toList();
      for (var i = 0; i < 40; i++) {
        final q = source.generate(trial: trial, componentIds: comps, rng: rng, id: '${trial.id}-$i');
        if (q == null) continue;
        questions++;
        final target = dx.targetComponents(q);
        for (final c in q.choices) {
          if (q.isCorrect(c.value)) continue;
          distractors++;
          byDim[q.dimension.name] = (byDim[q.dimension.name] ?? 0) + 1;
          final d = dx.diagnose(q, c.value);
          for (final id in [...d.observed, ...d.confusedWith]) {
            if (!arbor.nodes.containsKey(id)) {
              unknownNodes++;
              unknown.add(id);
            }
          }
          if (d.observedElementa.isEmpty) {
            empty++;
            emptyByDim[q.dimension.name] = (emptyByDim[q.dimension.name] ?? 0) + 1;
            if ((perDim[q.dimension.name] = (perDim[q.dimension.name] ?? 0) + 1) <= 3) samples.add('${trial.id} ${q.dimension.name} «${q.surface}» → ${c.label} | cible=${target.where((x) => !x.startsWith('not.')).join(',')}');
          }
        }
      }
    }
    // ignore: avoid_print
    print('questions=$questions distracteurs=$distractors sans diagnostic=$empty (${(100 * empty / max(1, distractors)).toStringAsFixed(1)} %) nœuds inconnus=$unknownNodes');
    // ignore: avoid_print
    print('vides par dimension: ${emptyByDim.entries.map((e) => '${e.key}=${e.value}/${byDim[e.key]}').join(' ')}');
    // ignore: avoid_print
    for (final s in samples) {
      print('  $s');
    }
    // ignore: avoid_print
    print('inconnus: ${unknown.join(' ')}');
    expect(questions, greaterThan(1000));
    expect(unknownNodes, 0);
    expect(empty / max(1, distractors), lessThan(0.02));
  });
}
