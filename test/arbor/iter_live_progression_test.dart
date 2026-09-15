import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/app/providers.dart';
import 'package:grammaticon/arbor/needs.dart';
import 'package:grammaticon/battle/battle_controller.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/iter.dart';
import 'package:grammaticon/pedagogy/trials.dart';

import '../support/test_env.dart';

void main() {
  test('depuis zéro, les vrais combats atteignent la troisième puis remédient sans séance constante', () async {
    final (c, _) = testContainer();
    addTearDown(c.dispose);
    final arbor = c.read(arborProvider);
    final coverage = c.read(trialCoverageProvider);
    final cfg = c.read(masteryConfigProvider);
    final dx = c.read(diagnosticianProvider);
    final ctrl = c.read(battleProvider.notifier);
    final path = <String>[];
    const target = 'n.thema.d3.cons';

    Future<void> play(IterChoice choice, {bool missTarget = false}) async {
      for (final t in choice.purchases) {
        expect(await c.read(profileProvider.notifier).purchase(t), isTrue);
      }
      ctrl.start(choice.trial, focus: choice.nodes);
      if (c.read(battleProvider)!.phase == BattlePhase.intro) ctrl.beginAfterIntro();
      final answers = <String>{};
      for (var i = 0; i < choice.trial.questionsToWin + 1; i++) {
        final state = c.read(battleProvider)!;
        if (state.isOver) break;
        expect(state.phase, BattlePhase.question, reason: path.join(' → '));
        final q = state.question!;
        final needs = ArborNeeds(arbor, c.read(profileProvider).arbor, DateTime.now(), cfg: cfg);
        if (q.payload is ForumQuestionPayload) {
          expect(needs.canPresent(dx.targetComponents(q)), isTrue, reason: q.surface);
        }
        answers.add('${q.dimension.name}:${(q.correctValues.toList()..sort()).join(',')}');
        final wrong = missTarget && dx.credited(q).contains(target);
        ctrl.answer(q.id, q.choices.indexWhere((ch) => q.isCorrect(ch.value) != wrong));
        if (wrong) {
          ctrl.abandon();
          return;
        }
        ctrl.proceed();
      }
      expect(c.read(battleProvider)!.phase, BattlePhase.victory, reason: path.join(' → '));
      if (choice.trial.activity == Activity.forum || choice.trial.activity == Activity.amphitheatrum) {
        expect(answers.length, greaterThan(1), reason: 'séance constante : ${path.last}');
      }
      await ctrl.finish();
    }

    for (var battle = 0; battle < 220; battle++) {
      final save = c.read(profileProvider);
      if (Iter.mastered(save.arbor, target, cfg, DateTime.now())) break;
      final choice = Iter.next(save: save, arbor: arbor, coverage: coverage, cfg: cfg);
      expect(choice, isNotNull, reason: 'parcours bloqué : ${path.join(' → ')}');
      path.add('${choice!.trial.id}:${choice.target}');
      await play(choice);
    }
    // ignore: avoid_print
    print('parcours réel : ${path.length} combats, troisième déclinaison atteinte par les réponses enregistrées');
    final save = c.read(profileProvider);
    expect(Iter.mastered(save.arbor, target, cfg, DateTime.now()), isTrue, reason: path.join(' → '));
    expect(ArborNeeds(arbor, save.arbor, DateTime.now()).introduced(target), isTrue);
    expect(save.arbor.records['n.des.ui'], isNull);
    final third = Trials.byId('dec-3-cons');
    await play(IterChoice(trial: third, mustBuy: !save.purchased.contains(third.id), causa: IterCausa.repetitio,
      nodes: const [target], score: 1), missTarget: true);
    expect(c.read(profileProvider).arbor.hypotheses, contains(target));
    final remediation = Iter.next(save: c.read(profileProvider), arbor: arbor, coverage: coverage, cfg: cfg)!;
    expect(remediation.causa, IterCausa.remediatio);
    expect({target, ...arbor.prerequisitesOf(target)}, contains(remediation.target));
    await play(remediation);
  }, timeout: const Timeout(Duration(minutes: 4)));
}
