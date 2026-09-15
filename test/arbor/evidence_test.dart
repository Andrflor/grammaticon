import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/arbor/arbor.dart';
import 'package:grammaticon/arbor/diagnosis.dart';
import 'package:grammaticon/arbor/evidence.dart';
import 'package:grammaticon/battle/answer_resolver.dart';
import 'package:grammaticon/linguistics/engine/analyzer.dart';
import 'package:grammaticon/linguistics/engine/conjugator.dart';
import 'package:grammaticon/linguistics/lexicon/forum_lexicon.dart';
import 'package:grammaticon/linguistics/lexicon/verbs.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/mastery.dart';
import 'package:grammaticon/pedagogy/question_generator.dart';
import 'package:grammaticon/pedagogy/trials.dart';
import 'package:grammaticon/persistence/save_data.dart';

void main() {
  final analyzer = Analyzer(kVerbs, Conjugator());
  final nominal = buildNominalAnalyzer();
  final arbor = Arbor.standard(analyzer: analyzer, nominal: nominal);
  final verbs = QuestionGenerator(analyzer);
  final forum = ForumQuestionSource(nominal, kSyntagmata);
  final dx = Diagnostician(arbor, verbs, forum);
  final resolver = AnswerResolver(arbor: arbor, diagnostician: dx);

  test('une erreur ouvre des hypothèses sur le maillon raté et ses prérequis, une réussite les ferme', () {
    final trial = Trials.byId('tm-tempora-ind-act-praes-imperf');
    final rng = Random(3);
    var save = const SaveData(gems: 100);
    final now = DateTime(2026, 9, 14, 12);
    // Cherche une question « quel temps ? » dont la bonne réponse est l'imparfait.
    late var q = verbs.generate(trial: trial, componentIds: const [], rng: rng, id: 'x')!;
    for (var i = 0; i < 200 && !(q.correctValues.contains('imperf') && q.choices.any((c) => c.value == 'praes')); i++) {
      q = verbs.generate(trial: trial, componentIds: const [], rng: rng, id: 'x$i')!;
    }
    expect(q.correctValues, contains('imperf'));
    final res = resolver.resolve(save: save, q: q, chosenValue: 'praes', quality: AnswerQuality.autonoma, now: now);
    expect(res.correct, isFalse);
    expect(res.diagnosis.observed, contains('v.sig.imperf.ba'));
    expect(res.diagnosis.confusedWith, contains('v.sig.praes'));
    expect(res.arborAfter.hypotheses.keys, contains('v.sig.imperf.ba'));
    // Le prérequis du marqueur (le présent sans marqueur) devient suspect.
    expect(res.arborAfter.hypotheses.keys, contains('v.sig.praes'));
    save = save.copyWith(arbor: res.arborAfter);

    // Une bonne réponse autonome sur une question qui distingue -bā- ferme l'hypothèse.
    final ok = resolver.resolve(save: save, q: q, chosenValue: 'imperf', quality: AnswerQuality.autonoma, now: now.add(const Duration(minutes: 1)));
    expect(ok.correct, isTrue);
    expect(ok.credited, contains('v.sig.imperf.ba'));
    expect(ok.arborAfter.hypotheses.keys, isNot(contains('v.sig.imperf.ba')));

    // Aller-retour JSON.
    final back = SaveData.fromJson(jsonDecode(jsonEncode(ok.arborAfter.toJson().isEmpty ? {} : save.copyWith(arbor: ok.arborAfter).toJson())) as Map<String, Object?>);
    expect(back.arbor.records.keys, containsAll(ok.arborAfter.records.keys));
  });

  test('apprenant simulé : un maillon systématiquement raté revient plus souvent dans les tirages suivants', () {
    final trial = Trials.byId('tm-tempora-ind-act');
    const target = 'v.sig.imperf.ba';
    double share(ArborEvidence evidence, int seed) {
      final rng = Random(seed);
      final now = DateTime(2026, 9, 14, 12);
      var hits = 0;
      const n = 400;
      for (var i = 0; i < n; i++) {
        final q = verbs.generate(trial: trial, componentIds: const [], rng: rng, id: 'q$i', needs: ArborNeeds(arbor, evidence, now))!;
        if (dx.targetComponents(q).contains(target)) hits++;
      }
      return hits / n;
    }

    final before = share(const ArborEvidence(), 11);
    // L'apprenant rate dix fois l'imparfait.
    var save = const SaveData(gems: 100);
    final rng = Random(5);
    var misses = 0;
    for (var i = 0; i < 400 && misses < 10; i++) {
      final q = verbs.generate(trial: trial, componentIds: const [], rng: rng, id: 'm$i')!;
      if (!dx.targetComponents(q).contains(target) || !q.correctValues.contains('imperf')) continue;
      final wrong = q.choices.firstWhere((c) => !q.isCorrect(c.value));
      final res = resolver.resolve(save: save, q: q, chosenValue: wrong.value, quality: AnswerQuality.autonoma, now: DateTime(2026, 9, 14, 12, i));
      save = save.copyWith(arbor: res.arborAfter);
      misses++;
    }
    expect(misses, 10);
    final after = share(save.arbor, 11);
    // ignore: avoid_print
    print('part des questions sur -bā- : avant ${(100 * before).toStringAsFixed(1)} %, après dix erreurs ${(100 * after).toStringAsFixed(1)} %');
    expect(after, greaterThan(before * 1.3));
  });
}
