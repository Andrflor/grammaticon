// Run: flutter test tool/simulate_iter_test.dart --reporter expanded
// Optional: --dart-define=ITER_SEED=2 --dart-define=ITER_MAX_BATTLES=5000
// Add --dart-define=ITER_TRACE=true to export a readable turn-by-turn report.
// Counts real generated questions and resolved answers, with a fresh save.
// The logical clock advances 1 ms per answer: no calendar-based revisions.
// Human reading time and UI transitions are calculated separately.
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/arbor/arbor.dart';
import 'package:grammaticon/arbor/diagnosis.dart';
import 'package:grammaticon/arbor/skill.dart';
import 'package:grammaticon/battle/answer_resolver.dart';
import 'package:grammaticon/linguistics/engine/analyzer.dart';
import 'package:grammaticon/linguistics/engine/conjugator.dart';
import 'package:grammaticon/linguistics/lexicon/forum_lexicon.dart';
import 'package:grammaticon/linguistics/lexicon/verbs.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/frames/frame_content.dart';
import 'package:grammaticon/pedagogy/frames/frame_question_source.dart';
import 'package:grammaticon/pedagogy/iter.dart';
import 'package:grammaticon/pedagogy/mastery.dart';
import 'package:grammaticon/pedagogy/mastery_view.dart';
import 'package:grammaticon/pedagogy/progression.dart';
import 'package:grammaticon/pedagogy/question_generator.dart';
import 'package:grammaticon/pedagogy/trials.dart';
import 'package:grammaticon/persistence/save_data.dart';

void main() {
  test('simulate perfect Iter gameplay', () {
    const seed = int.fromEnvironment('ITER_SEED', defaultValue: 1);
    const trace = bool.fromEnvironment('ITER_TRACE');
    const maxBattles = int.fromEnvironment(
      'ITER_MAX_BATTLES',
      defaultValue: 5000,
    );
    const stallLimit = int.fromEnvironment(
      'ITER_STALL_LIMIT',
      defaultValue: 250,
    );
    const cfg = MasteryConfig();
    final timer = Stopwatch()..start();
    final analyzer = Analyzer(kVerbs, Conjugator());
    final nominal = buildNominalAnalyzer();
    final arbor = Arbor.standard(analyzer: analyzer, nominal: nominal);
    final verbs = QuestionGenerator(analyzer);
    final forum = ForumQuestionSource(nominal, kSyntagmata);
    final library = FrameLibrary([
      for (final place in ['theatrum', 'templum'])
        ...FrameLibrary.parse(
          File('assets/arbor/frames/$place.json').readAsStringSync(),
        ).frames,
    ]);
    final frames = FrameQuestionSource(library);
    final source = QuestionSources(
      (a) => switch (a) {
        Activity.amphitheatrum => verbs,
        Activity.forum => forum,
        Activity.theatrum || Activity.templum => frames,
      },
    );
    final coverage = TrialCoverage.build(verbs, forum, frames: frames);
    final inventory = {
      'cards': Trials.all.length,
      'graph_nodes': arbor.nodes.length,
      'layers': {
        for (final layer in Stratum.values) layer.name: {
          'total': arbor.stratum(layer).length,
          'with_question_dimension': arbor.stratum(layer).where((n) => n.probatur.isNotEmpty).length,
          'covered_by_iter': arbor.stratum(layer).where((n) => n.probatur.isNotEmpty && coverage.covered.contains(n.id)).length,
        },
      },
      'uncovered_testable_elementa_syntax_lectio': [
        for (final n in arbor.omnes)
          if ([Stratum.elementum, Stratum.syntaxis, Stratum.lectio].contains(n.stratum) && n.probatur.isNotEmpty && !coverage.covered.contains(n.id)) n.id,
      ],
    };
    if (!trace) print('INVENTORY ${jsonEncode(inventory)}');
    if (const bool.fromEnvironment('ITER_INVENTORY_ONLY')) return;
    final dx = Diagnostician(arbor, verbs, forum);
    final resolver = AnswerResolver(arbor: arbor, diagnostician: dx, lemmaCapacities: coverage.lemmaCapacities);
    final rng = Random(seed);
    var save = const SaveData();
    var now = DateTime(2026, 9, 15, 9);
    var questions = 0;
    var battles = 0;
    var lastProgressBattle = 0;
    var lastProgressQuestions = 0;
    var bestProgress = 0;
    var stopReason = 'battle_limit';
    final path = <Map<String, Object?>>[];
    final played = <String, int>{};
    final byActivity = <String, int>{};
    final dimensionsByCard = <String, Set<String>>{};
    final targetCreditsByCard = <String, int>{};
    final tracked = coverage.covered.where((id) {
      final node = arbor[id];
      return node != null && node.probatur.isNotEmpty;
    }).toSet();
    int progress() =>
        save.purchased.length +
        tracked.fold<int>(0, (sum, id) {
          final r = save.arbor.records[id];
          return sum +
              (r == null
                  ? 0
                  : r.autonomousCount.clamp(0, 12).toInt() +
                        r.lemmas.length.clamp(0, 4).toInt() +
                        r.places.length);
        });
    Map<String, Object?> nodeStatus(String id) {
      final r = save.arbor.of(id);
      return {
        'id': id,
        'tier': r.tier(cfg).key,
        'correct': r.autonomousCorrect,
        'lemmas': r.lemmas.toList(),
        'places': r.places.toList(),
        'required_places': Iter.placesOf(coverage, id).toList(),
        'prerequisites_not_held': [
          for (final pre in arbor[id]?.requirit ?? <String>[])
            if (coverage.covered.contains(pre) &&
                !Iter.holds(save.arbor, pre, cfg, now))
              pre,
        ],
      };
    }

    print(
      'START seed=$seed cards=${Trials.all.length} covered=${tracked.length}',
    );
    while (battles < maxBattles) {
      final choice = Iter.next(
        save: save,
        arbor: arbor,
        coverage: coverage,
        cfg: cfg,
        now: now,
      );
      if (choice == null) {
        stopReason = Iter.pendingNodes(save: save, arbor: arbor, cfg: cfg, now: now).isEmpty ? 'program_mastered' : 'iter_blocked';
        break;
      }
      final trial = choice.trial;
      if (trial.activity == Activity.amphitheatrum || trial.activity == Activity.forum) {
        expect(ArborNeeds(arbor, save.arbor, now, cfg: cfg).introduced(choice.target), isTrue,
          reason: '${trial.id} ne doit pas affiner ${choice.target} avant sa découverte en version et thème');
      }
      final targetBefore = nodeStatus(choice.target);
      for (final card in choice.purchases) {
        expect(Progression.canPurchase(save, card), isTrue);
        save = save.copyWith(
          gems: save.gems - card.price,
          purchased: {...save.purchased, card.id},
        );
      }
      final components = Progression.componentsFor(save, trial);
      final battleSeed = rng.nextInt(0x7fffffff);
      final battleRng = Random(battleSeed);
      var recentLemmas = <String>[];
      var recentSurfaces = <String>[];
      Question? pending;
      var bonus = 0;
      var generated = 0;
      final credited = <String>{};
      Map<String, Object?>? firstQuestion;
      var targetHits = 0;
      for (var i = 0; i < trial.questionsToWin; i++) {
        final q =
            pending ??
            source.generate(
              trial: trial,
              componentIds: components,
              rng: Random(battleRng.nextInt(1 << 20) ^ battleSeed),
              id: '$battleSeed-$i',
              recentLemmas: recentLemmas,
              recentSurfaces: recentSurfaces,
              skills: {
                for (final e in save.skills.entries)
                  e.key: e.value.asOf(now, cfg),
              },
              cfg: cfg,
              exposure: save.exposure,
              recall: save.errata.recall(battleSeed),
              needs: ArborNeeds(
                arbor,
                save.arbor,
                now,
                cfg: cfg,
                focus: choice.nodes.toSet(),
                credit: dx.credited,
                contrast: dx.chosenComponents,
                presented: dx.targetComponents,
              ),
            );
        if (q == null) {
          stopReason = 'empty_question_pool:${trial.id}';
          print('EMPTY ${choice.nodes.map(nodeStatus).toList()}');
          break;
        }
        pending = q.followUp;
        // BattleController computes the bonus from the save BEFORE the final answer.
        if (i == trial.questionsToWin - 1) {
          final cheapest = Progression.cheapestPurchasable(save);
          final tier = MasterySummary.forSkill(
            save,
            trial.primarySkill,
            cfg,
          ).tier;
          bonus = resolver.economy.victoryBonus(
            catchUp:
                cheapest != null &&
                save.gems < cheapest &&
                tier == MasteryTier.perita,
          );
        }
        final result = resolver.resolve(
          save: save,
          q: q,
          chosenValue: q.correctValues.first,
          quality: AnswerQuality.autonoma,
          now: now,
          battleSeed: battleSeed,
        );
        expect(result.correct, isTrue);
        if (trial.activity == Activity.amphitheatrum || trial.activity == Activity.forum) {
          final order = ArborNeeds(arbor, save.arbor, now, cfg: cfg);
          expect(order.canPresent(dx.targetComponents(q)), isTrue, reason: '${trial.id}: ${q.surface}');
          for (final c in q.choices) {
            expect(order.canPresent(dx.chosenComponents(q, c.value) ?? const {}), isTrue,
              reason: '${trial.id}: distracteur ${c.label} avant découverte');
          }
        }
        firstQuestion ??= {
          'prompt': q.prompt,
          'surface': q.syntagma ?? q.surface,
          'dimension': q.dimension.name,
          'correct_answers': [for (final c in q.choices) if (q.isCorrect(c.value)) c.label],
          'credits_target': result.credited.contains(choice.target),
        };
        credited.addAll(result.credited);
        (dimensionsByCard[trial.id] ??= {}).add(q.dimension.name);
        if (result.credited.contains(choice.target)) {
          targetHits++;
          targetCreditsByCard.update(trial.id, (n) => n + 1, ifAbsent: () => 1);
        }
        save = save.copyWith(
          gems: result.gemsAfter,
          skills: result.skillsAfter,
          lemmaDaily: result.lemmaDailyAfter,
          lastTransactionId: result.transaction.id,
          exposure: result.exposureAfter,
          errata: result.errataAfter,
          arbor: result.arborAfter,
        );
        recentLemmas = [...recentLemmas, q.lemmaId];
        if (recentLemmas.length > 3) recentLemmas.removeAt(0);
        recentSurfaces = [...recentSurfaces, q.surface];
        if (recentSurfaces.length > 12) recentSurfaces.removeAt(0);
        now = now.add(const Duration(milliseconds: 1));
        questions++;
        generated++;
        byActivity.update(trial.activity.key, (n) => n + 1, ifAbsent: () => 1);
      }
      if (generated != trial.questionsToWin) break;
      final stats =
          save.activityStats[trial.activity.key] ?? const ActivityStats();
      save = save.copyWith(
        gems: save.gems + bonus,
        battlesWon: save.battlesWon + 1,
        introSeen: {...save.introSeen, trial.id},
        activityStats: {
          ...save.activityStats,
          trial.activity.key: ActivityStats(won: stats.won + 1),
        },
      );
      battles++;
      played.update(trial.id, (n) => n + 1, ifAbsent: () => 1);
      path.add({
        'battle': battles,
        'questions': questions,
        'trial': trial.id,
        'card_name': trial.name,
        'activity': trial.activity.key,
        'target': choice.target,
        'target_name': arbor[choice.target]?.nomen,
        'target_description': arbor[choice.target]?.quid,
        'target_before': targetBefore,
        'target_hits': targetHits,
        'first_question': firstQuestion,
        'purchases': choice.purchases.map((t) => t.id).toList(),
        'cause': choice.causa.name,
        'target_credited': credited.contains(choice.target),
        'target_after': nodeStatus(choice.target),
        'unique_cards': played.length,
        'gems': save.gems,
      });
      final current = progress();
      if (current > bestProgress) {
        bestProgress = current;
        lastProgressBattle = battles;
        lastProgressQuestions = questions;
      }
      if (trace || battles <= 12 || battles % 100 == 0) {
        print(
          'battle=$battles questions=$questions unique=${played.length} target=${choice.target} card=${trial.id} lastProgress=$lastProgressBattle elapsed=${timer.elapsed.inSeconds}s',
        );
      }
      if (battles - lastProgressBattle >= stallLimit) {
        stopReason = 'no_progress_for_${stallLimit}_battles';
        break;
      }
    }
    final remaining =
        tracked
            .where(
              (id) =>
                  !Iter.masteredEverywhere(save.arbor, coverage, id, cfg, now),
            )
            .toList()
          ..sort();
    final targets = Iter.targets(
      arbor: arbor,
      ev: save.arbor,
      coverage: coverage,
      now: now,
    );
    final report = {
      'seed': seed,
      'stop_reason': stopReason,
      'battles': battles,
      'questions': questions,
      'last_progress_battle': lastProgressBattle,
      'last_progress_questions': lastProgressQuestions,
      'unique_cards_played': played.length,
      'catalogue_cards': Trials.all.length,
      'covered_nodes': tracked.length,
      'mastered_everywhere': tracked.length - remaining.length,
      'questions_by_activity': byActivity,
      'plays_by_card': played,
      'dimensions_by_card': {
        for (final e in dimensionsByCard.entries) e.key: e.value.toList(),
      },
      'questions_crediting_iter_target_by_card': targetCreditsByCard,
      'remaining': remaining.map(nodeStatus).toList(),
      'frontier': [
        for (final t in targets) {'cause': t.$1.name, ...nodeStatus(t.$2)},
      ],
      'unplayed_cards': [
        for (final t in Trials.all)
          if (!played.containsKey(t.id)) t.id,
      ],
      'frame_cards_below_4_distinct_frames': {
        for (final t in Trials.all.where(
          (t) =>
              t.activity == Activity.theatrum || t.activity == Activity.templum,
        ))
          if (frames.pool(t).map((f) => f.id).toSet().length < 4)
            t.id: frames.pool(t).map((f) => f.id).toSet().length,
      },
      'path': path,
      'program_pending': Iter.pendingNodes(save: save, arbor: arbor, cfg: cfg, now: now),
      'uncovered_testable_prerequisites': {
        for (final node in arbor.omnes)
          if (coverage.covered.contains(node.id))
            for (final pre in node.requirit)
              if ((arbor[pre]?.probatur.isNotEmpty ?? false) && !coverage.canCover(pre)) pre,
      }.toList()..sort(),
    };
    final output = '/tmp/opencode/iter-simulation-$seed.json';
    File(output)
        .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));
    if (trace) {
      String cell(Object? value) => '$value'.replaceAll('|', '\\|').replaceAll('\n', ' ');
      final text = StringBuffer()
        ..writeln('# Ordre simulé de l’Iter — graine $seed')
        ..writeln()
        ..writeln('Sauvegarde neuve, réponses autonomes toutes correctes, achats réels, horloge logique : 1 ms par réponse, sans rappels calendaires.')
        ..writeln('Arrêt : $stopReason. $battles combats, $questions réponses. Une limite de combats ne signifie pas que le parcours est terminé.')
        ..writeln()
        ..writeln('| Tour | Lieu | Carte | Compétence ciblée | Bonnes réponses créditant la cible pendant ce tour | État de la cible après |')
        ..writeln('|---:|---|---|---|---:|---|');
      for (final turn in path) {
        final after = turn['target_after']! as Map<String, Object?>;
        text.writeln('| ${turn['battle']} | ${cell(turn['activity'])} | ${cell(turn['card_name'])} | ${cell(turn['target_name'])} (`${turn['target']}`) | ${turn['target_hits']} | ${after['tier']} |');
      }
      text.writeln('\n## Première question de chaque tour\n');
      for (final turn in path) {
        final q = turn['first_question']! as Map<String, Object?>;
        text.writeln('${turn['battle']}. **${turn['card_name']}** — ${cell(q['surface'])} — ${cell(q['prompt'])} → ${cell(q['correct_answers'])}. Crédit de la cible : ${q['credits_target']}.');
      }
      final traceOutput = '/tmp/opencode/iter-order-$seed.md';
      File(traceOutput).writeAsStringSync(text.toString());
      print('TURN REPORT $traceOutput');
    }
    print(
      'RESULT ${jsonEncode({
        for (final key in ['seed', 'stop_reason', 'battles', 'questions', 'last_progress_battle', 'last_progress_questions', 'unique_cards_played', 'catalogue_cards', 'covered_nodes', 'mastered_everywhere', 'questions_by_activity']) key: report[key],
      })}',
    );
    final lastTargets = path
        .skip(max(0, path.length - 4))
        .map((p) => p['target'] as String)
        .toSet();
    print('LAST TARGETS ${jsonEncode(lastTargets.map(nodeStatus).toList())}');
    print('REPORT $output');
  }, timeout: const Timeout(Duration(minutes: 30)));
}
