import 'dart:io';
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
import 'package:grammaticon/pedagogy/frames/frame_cards.dart';
import 'package:grammaticon/pedagogy/frames/frame_content.dart';
import 'package:grammaticon/pedagogy/frames/frame_question_source.dart';
import 'package:grammaticon/pedagogy/frames/frame_trials.dart';
import 'package:grammaticon/pedagogy/question_generator.dart';
import 'package:grammaticon/pedagogy/trials.dart';

void main() {
  final library = FrameLibrary(FrameLibrary.parse(File('assets/arbor/frames/theatrum.json').readAsStringSync()).frames + FrameLibrary.parse(File('assets/arbor/frames/templum.json').readAsStringSync()).frames);
  final analyzer = Analyzer(kVerbs, Conjugator());
  final nominal = buildNominalAnalyzer();
  final arbor = Arbor.standard(analyzer: analyzer, nominal: nominal);
  final dx = Diagnostician(arbor, QuestionGenerator(analyzer), ForumQuestionSource(nominal, kSyntagmata));
  final source = FrameQuestionSource(library);

  test('chaque carte du Theatrum et du Templum a des cadres, et chaque nœud visé existe dans l\'arbre', () {
    final trials = Trials.all.where((t) => t.filter is FrameFilter).toList();
    expect(trials.length, 274);
    final missing = <String>[];
    final unknown = <String>{};
    for (final t in trials) {
      final card = (t.filter as FrameFilter).card;
      if (library.forCard(card).isEmpty) missing.add(card);
      for (final n in frameCardNodes(card)) {
        if (!arbor.nodes.containsKey(n)) unknown.add('$card → $n');
      }
    }
    expect(missing, isEmpty, reason: 'cartes sans cadre');
    expect(unknown, isEmpty, reason: 'nœuds inconnus');
    // Chaque carte de la table pointe vers une carte existante.
    final cards = {for (final t in trials) '${templumAlias[(t.filter as FrameFilter).card.split('/')[1]] ?? (t.filter as FrameFilter).card.split('/')[1]}/${(t.filter as FrameFilter).card.split('/')[2]}'};
    final orphan = kFrameCardNodes.keys.where((k) => !cards.contains(k)).toList();
    expect(orphan, isEmpty, reason: 'entrées de table sans carte');
  });

  test('chaque carte génère des questions cohérentes dont les distracteurs ont un diagnostic', () {
    final rng = Random(2);
    var questions = 0, distractors = 0, empty = 0;
    final samples = <String>[];
    for (final t in Trials.all.where((t) => t.filter is FrameFilter)) {
      for (var i = 0; i < 6; i++) {
        final q = source.generate(trial: t, componentIds: const [], rng: rng, id: '${t.id}-$i');
        expect(q, isNotNull, reason: t.id);
        questions++;
        expect(q!.correctValues, isNotEmpty);
        expect(q.choices.length, greaterThanOrEqualTo(2));
        // Aucun emplacement non rempli.
        expect(q.surface.contains('{'), isFalse, reason: q.surface);
        for (final c in q.choices) {
          expect(c.label.contains('{'), isFalse, reason: c.label);
          if (q.isCorrect(c.value)) continue;
          distractors++;
          final d = dx.diagnose(q, c.value);
          if (d.observedElementa.isEmpty) {
            empty++;
            if (samples.length < 5) samples.add('${t.id} «${q.surface}» → ${c.label}');
          }
        }
      }
    }
    // ignore: avoid_print
    print('cadres: questions=$questions distracteurs=$distractors sans diagnostic=$empty');
    for (final s in samples) {
      // ignore: avoid_print
      print('  $s');
    }
    expect(empty, 0);
  });
}
