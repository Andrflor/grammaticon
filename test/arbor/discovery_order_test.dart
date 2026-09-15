import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/arbor/arbor.dart';
import 'package:grammaticon/arbor/diagnosis.dart';
import 'package:grammaticon/arbor/evidence.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/iter.dart';
import 'package:grammaticon/pedagogy/mastery.dart';
import 'package:grammaticon/pedagogy/question_generator.dart';
import 'package:grammaticon/pedagogy/trials.dart';
import 'package:grammaticon/persistence/save_data.dart';

import '../support/test_env.dart';

void main() {
  final arbor = Arbor.standard(
    analyzer: testAnalyzer,
    nominal: testNominalAnalyzer,
  );
  final verbs = QuestionGenerator(testAnalyzer);
  final forum = ForumQuestionSource(testNominalAnalyzer, kSyntagmata);
  final dx = Diagnostician(arbor, verbs, forum);
  final coverage = TrialCoverage.build(verbs, forum, diagnostician: dx);
  final now = DateTime(2026, 9, 15, 10);
  const cfg = MasteryConfig();

  SkillRecord discovery(String trial) {
    var r = const SkillRecord();
    for (var i = 0; i < 5; i++) {
      r = r.apply(
        Observation(
          at: now,
          correct: true,
          lemmaId: 'example-$i',
          quality: AnswerQuality.autonoma,
          trialId: trial,
        ),
        cfg,
      );
    }
    return r;
  }

  test('une sauvegarde neuve commence par la version puis le thème, même avec toutes les cartes achetées', () {
    var save = SaveData(
      gems: 10000,
      purchased: Trials.all.map((t) => t.id).toSet(),
    );
    final first = Iter.next(
      save: save,
      arbor: arbor,
      coverage: coverage,
      now: now,
    )!;
    expect(first.trial.id, 'th-loca-a-ablative');
    save = save.copyWith(
      arbor: ArborEvidence(
        records: {
          'lect.intellectus.loca.a_ablative': discovery(first.trial.id),
        },
      ),
    );
    final second = Iter.next(
      save: save,
      arbor: arbor,
      coverage: coverage,
      now: now,
    )!;
    expect(second.trial.id, 'tp-loca-a-ablative');
  });

  test('la première déclinaison exige la version ET le thème du concept', () {
    final version = discovery('th-loca-a-ablative');
    final theme = discovery('tp-loca-a-ablative');
    bool introduced(Map<String, SkillRecord> records) => ArborNeeds(
      arbor,
      ArborEvidence(records: records),
      now,
    ).introduced('n.thema.d1');
    expect(introduced({}), isFalse);
    expect(introduced({'lect.intellectus.loca.a_ablative': version}), isFalse);
    expect(introduced({'lect.thema.loca.a_ablative': theme}), isFalse);
    expect(
      introduced({
        'lect.intellectus.loca.a_ablative': version,
        'lect.thema.loca.a_ablative': theme,
      }),
      isTrue,
    );
    expect(arbor['n.thema.d2.us']!.requirit, contains('n.thema.d1'));
  });

  test('un thème commun ne permet pas de présenter le futur antérieur avant sa découverte', () {
    final records = <String, SkillRecord>{
      for (final node in arbor.omnes)
        if (node.id.startsWith('lect.intellectus.loca.') ||
            node.id.startsWith('lect.thema.loca.'))
          node.id: discovery(
            node.id.startsWith('lect.thema.')
                ? 'tp-loca-negatio'
                : 'th-loca-negatio',
          ),
    };
    final needs = ArborNeeds(
      arbor,
      ArborEvidence(records: records),
      now,
      focus: {'v.thema.praes.c1'},
      credit: dx.credited,
      contrast: dx.chosenComponents,
      presented: dx.targetComponents,
    );
    expect(needs.introduced('v.thema.praes.c1'), isTrue);
    final present = verbs.generate(
      trial: Trials.byId('ind-praes-act'),
      componentIds: const [],
      rng: Random(1),
      id: 'present',
      needs: needs,
    );
    expect(present, isNotNull);
    expect(dx.credited(present!), contains('v.thema.praes.c1'));
    for (final choice in present.choices) {
      expect(
        needs.canPresent(dx.chosenComponents(present, choice.value)!),
        isTrue,
      );
    }
    expect(
      coverage.canProve(
        Trials.byId('ind-futex-act'),
        'v.thema.perf',
        needs: needs,
      ),
      isFalse,
    );
    expect(
      arbor['v.sig.futex.eri']!.requirit,
      containsAll([
        'v.sig.perf',
        'v.sig.fut.b',
        'v.sig.fut.a_e',
        'syn.tempora.futex',
      ]),
    );
  });

  test('une dépendance testable sans exercice reste bloquante', () {
    // Même si toute la morphologie est acquise, le futur antérieur attend
    // encore sa découverte du sens, absente des banques de contexte actuelles.
    final records = <String, SkillRecord>{};
    for (final node in arbor.omnes) {
      if (node.id == 'syn.tempora.futex' || node.id == 'v.sig.futex.eri') {
        continue;
      }
      var r = const SkillRecord();
      for (var i = 0; i < 15; i++) {
        r = r.apply(
          Observation(
            at: now,
            correct: true,
            lemmaId: 'lemma-${i % 5}',
            quality: AnswerQuality.autonoma,
            trialId: 'fixture',
          ),
          cfg,
        );
      }
      records[node.id] = r;
    }
    final targets = Iter.targets(
      arbor: arbor,
      ev: ArborEvidence(records: records),
      coverage: coverage,
      now: now,
    );
    expect(targets.map((t) => t.$2), isNot(contains('v.sig.futex.eri')));
  });

  test(
    'le futur antérieur ne réapparaît pas parmi les distracteurs de temps',
    () {
      final records = <String, SkillRecord>{
        for (final node in arbor.omnes)
          if (node.id.startsWith('lect.intellectus.') ||
              node.id.startsWith('lect.thema.'))
            node.id: discovery('fixture'),
      };
      final needs = ArborNeeds(arbor, ArborEvidence(records: records), now);
      final trial = Trials.byId('tm-tempora-ind-act');
      final rng = Random(3);
      Question? sample;
      for (var i = 0; i < 100; i++) {
        final q = verbs.generate(
          trial: trial,
          componentIds: trial.components.map((c) => c.id).toList(),
          rng: rng,
          id: 'q$i',
        );
        if (q != null &&
            q.correctValues.contains('praes') &&
            q.choices.any((c) => c.value == 'futex')) {
          sample = q;
          break;
        }
      }
      expect(
        sample,
        isNotNull,
        reason: 'le test part bien d’une question proposant le futur antérieur',
      );
      final safe = needs.constrain(sample!, dx.chosenComponents);
      expect(safe, isNotNull);
      expect(safe!.choices.map((c) => c.value), isNot(contains('futex')));
      expect(safe.choices.any((c) => safe.isCorrect(c.value)), isTrue);
      expect(safe.choices.any((c) => !safe.isCorrect(c.value)), isTrue);
    },
  );
}
