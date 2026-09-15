import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/arbor/arbor.dart';
import 'package:grammaticon/arbor/contextus.dart';
import 'package:grammaticon/arbor/evidence.dart';
import 'package:grammaticon/arbor/skill.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/frames/frame_catalogue.dart';
import 'package:grammaticon/pedagogy/iter.dart';
import 'package:grammaticon/pedagogy/mastery.dart';
import 'package:grammaticon/pedagogy/question_generator.dart';
import 'package:grammaticon/pedagogy/trials.dart';
import 'package:grammaticon/persistence/save_data.dart';

import '../support/test_env.dart';

void main() {
  final now = DateTime(2026, 9, 15, 10);
  const cfg = MasteryConfig();
  SkillRecord proven(String trial, String place) {
    var r = const SkillRecord();
    for (var i = 0; i < 15; i++) {
      r = r.apply(Observation(at: now, correct: true, lemmaId: 'lemma-${i % 5}', quality: AnswerQuality.autonoma, trialId: trial), cfg, place: place);
    }
    return r;
  }

  test('le repli vers un lieu manquant ne propose pas eō sans question admissible', () {
    const version = 'lect.intellectus.loca.a_ablative';
    const theme = 'lect.thema.loca.a_ablative';
    final graph = Arbor.of(const [
      Skill(version, nomen: 'Version', quid: 'Découverte', stratum: Stratum.lectio, probatur: [Dimensio.sensus]),
      Skill(theme, nomen: 'Thème', quid: 'Découverte', stratum: Stratum.lectio, requirit: [version], probatur: [Dimensio.productio]),
      Skill('n.des.um', nomen: '-um', quid: 'Terminaison', stratum: Stratum.elementum, requirit: [theme], probatur: [Dimensio.casus]),
    ]);
    final coverage = TrialCoverage({
      'fam-eo': {'n.des.um'},
      'dec-2-mf': {'n.des.um'},
    }, proves: (trial, node, components, needs) => needs == null || trial.activity == Activity.forum);
    final save = SaveData(gems: 695, purchased: {'fam-eo', 'dec-2-mf'}, arbor: ArborEvidence(records: {
      version: proven('th-loca-a-ablative', 'theatrum'),
      theme: proven('tp-loca-a-ablative', 'templum'),
      'n.des.um': proven('dec-2-mf', 'forum'),
    }));
    // Maîtrisé au Forum, non encore prouvable à l'Amphitheatrum : attendre
    // une vraie question au lieu d'ouvrir eō et perdre sans avoir répondu.
    expect(Iter.next(save: save, arbor: graph, coverage: coverage, now: now), isNull);
    expect(Iter.next(save: save, arbor: graph, coverage: coverage, now: now), isNull);
  });

  test('chaque section attend le vocabulaire de la précédente dans les deux sens', () {
    final graph = Arbor.standard(analyzer: testAnalyzer, nominal: testNominalAnalyzer);
    for (var i = 1; i < kTheatrumSections.length; i++) {
      final previous = kTheatrumSections[i - 1];
      final section = kTheatrumSections[i];
      final first = graph[contextNodeId('theatrum/${section.id}/${section.cards.first}')]!;
      expect(first.requirit, contains(contextNodeId('theatrum/${previous.id}/vocabula')), reason: first.id);
      expect(first.requirit, contains(contextNodeId('templum/${previous.id}/vocabula')), reason: first.id);
    }
  });

  test('le premier choix ne génère pas des questions pour tout le catalogue', () {
    final graph = Arbor.standard(analyzer: testAnalyzer, nominal: testNominalAnalyzer);
    final source = TrialCoverage.build(QuestionGenerator(testAnalyzer), ForumQuestionSource(testNominalAnalyzer, kSyntagmata));
    var probes = 0;
    final coverage = TrialCoverage(source.nodesByTrial,
      lemmaCapacities: source.lemmaCapacities, lemmasByTrial: source.lemmasByTrial,
      proves: (t, n, c, needs) {
        probes++;
        return source.proves!(t, n, c, needs);
      });
    final timer = Stopwatch()..start();
    final choice = Iter.next(save: const SaveData(), arbor: graph, coverage: coverage, now: now);
    timer.stop();
    // ignore: avoid_print
    print('premier choix: ${timer.elapsedMilliseconds} ms, $probes vérifications de contenu');
    expect(choice?.trial.id, 'th-loca-a-ablative');
    expect(probes, lessThan(50), reason: 'les compétences pas encore découvertes ne doivent pas lancer de recherche de questions');
  });
}
