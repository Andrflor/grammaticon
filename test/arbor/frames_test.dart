import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/arbor/arbor.dart';
import 'package:grammaticon/arbor/contextus.dart';
import 'package:grammaticon/arbor/diagnosis.dart';
import 'package:grammaticon/arbor/evidence.dart';
import 'package:grammaticon/pedagogy/mastery.dart';
import 'package:grammaticon/linguistics/engine/analyzer.dart';
import 'package:grammaticon/linguistics/engine/conjugator.dart';
import 'package:grammaticon/linguistics/lexicon/forum_lexicon.dart';
import 'package:grammaticon/linguistics/lexicon/verbs.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/frames/frame_cards.dart';
import 'package:grammaticon/pedagogy/frames/frame_catalogue.dart';
import 'package:grammaticon/pedagogy/frames/frame_content.dart';
import 'package:grammaticon/pedagogy/frames/frame_question_source.dart';
import 'package:grammaticon/pedagogy/frames/frame_trials.dart';
import 'package:grammaticon/pedagogy/question_generator.dart';
import 'package:grammaticon/pedagogy/skills.dart';
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
    // Chaque carte a sa compétence propre, enregistrée, sous sa section.
    final skillIds = trials.map((t) => t.primarySkill).toList();
    expect(skillIds.toSet().length, trials.length, reason: 'compétence propre par carte');
    for (final t in trials) {
      expect(Skills.maybe(t.primarySkill), isNotNull, reason: t.id);
      expect(Skills.maybe(t.primarySkill)!.parent, isNotNull, reason: t.id);
    }
    // Leçon et aide : chaque carte a une leçon, chaque cadre une fiche d'aide.
    for (final t in trials) {
      expect(t.intro.length, greaterThan(40), reason: '${t.id} sans leçon');
    }
    final help = FrameLibrary.parseHelp(File('assets/arbor/frames/help.json').readAsStringSync());
    final noHelp = library.frames.where((f) => f.help == null || !help.containsKey(f.help)).map((f) => f.id).toList();
    expect(noHelp, isEmpty, reason: 'cadres sans fiche d\'aide');
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

  test('une erreur en contexte débite la compétence de la carte, non la grammaire : celle-ci devient suspecte', () {
    final rng = Random(5);
    // Theātrum : le nœud observé est lect.intellectus.<section>.<carte> ; ses
    // prérequis (syntaxe, morphologie) passent en hypothèses, sans dette.
    final th = Trials.byId('th-actiones-passive-number');
    final q = source.generate(trial: th, componentIds: const [], rng: rng, id: 'q-th')!;
    final wrong = q.choices.firstWhere((c) => !q.isCorrect(c.value));
    final d = dx.diagnose(q, wrong.value);
    final node = contextNodeId('theatrum/actiones/passive-number');
    expect(d.observed, {node});
    expect(d.suspecta, isEmpty);
    // Exposition d'abord : la carte ne dépend que de la carte d'avant, la grammaire vient après elle.
    expect(arbor[node]!.requirit, ['lect.intellectus.actiones.passive_patient']);
    expect(arbor[node]!.exempla, containsAll(['v.des.pass.3.sg.tur', 'v.des.pass.3.pl.ntur', 'syn.concordia.verbum']));
    final ev = const ArborEvidence().observe(arbor: arbor, diagnosis: d, credited: const {}, correct: false, quality: AnswerQuality.autonoma, lemmaId: q.lemmaId, trialId: th.id, now: DateTime(2026, 9, 15), place: 'theatrum');
    expect(ev.records.keys, contains(node));
    expect(ev.records.containsKey('v.des.pass.3.sg.tur'), isFalse, reason: 'la forme n\'est pas débitée par une erreur de lecture');
    expect(ev.hypotheses.keys, containsAll([node, 'lect.intellectus.actiones.passive_patient']));
    expect(ev.hypotheses.containsKey('v.des.pass.3.sg.tur'), isFalse, reason: 'la grammaire n\'est pas suspectée par une erreur de lecture : elle vient après');
    // Templum : quand le distracteur est une autre forme du même mot, les
    // maillons de la forme attendue absents de la forme choisie sont suspects.
    var found = false;
    for (var i = 0; i < 40 && !found; i++) {
      final tq = source.generate(trial: Trials.byId('tp-actiones-passive-number'), componentIds: const [], rng: rng, id: 'q-tp-$i')!;
      for (final c in tq.choices.where((c) => !tq.isCorrect(c.value))) {
        final s = dx.frameSuspecta(tq, c.value);
        if (s.isEmpty) continue;
        found = true;
        final td = dx.diagnose(tq, c.value);
        expect(td.observed, {contextNodeId('templum/actiones/passive-number')});
        expect(td.suspecta, s);
        expect(s.every((id) => id.startsWith('v.') || id.startsWith('n.') || id.startsWith('adj.') || id.startsWith('pron.')), isTrue, reason: s.join(' '));
      }
    }
    expect(found, isTrue, reason: 'aucun distracteur morphologique trouvé au Templum');
    // Réussir la compétence lève le soupçon sur ses prérequis directs (la carte d'avant).
    final ok = ev.observe(arbor: arbor, diagnosis: const Diagnosis(), credited: {node}, correct: true, quality: AnswerQuality.autonoma, lemmaId: q.lemmaId, trialId: th.id, now: DateTime(2026, 9, 15, 1), place: 'theatrum');
    expect(ok.hypotheses.containsKey('lect.intellectus.actiones.passive_patient'), isFalse);
    expect(ok.records[node]!.places, {'theatrum'});
  });

  test('exposition d\'abord : le thema exige l\'intellectus, et la grammaire qu\'une carte introduit exige son thema', () {
    for (final c in kTemplumCards.where((c) => c.card != 'vocabula')) {
      final thema = arbor[contextNodeId(c.id)]!;
      final intellectus = thema.requirit.where((r) => r.startsWith('lect.intellectus.')).toList();
      expect(intellectus.length, 1, reason: c.id);
      expect(arbor.nodes.containsKey(intellectus.single), isTrue, reason: c.id);
      // Les nœuds de contexte ne dépendent d'aucun maillon de grammaire.
      expect(thema.requirit.any((r) => !r.startsWith('lect.')), isFalse, reason: c.id);
      expect(arbor[intellectus.single]!.requirit.any((r) => !r.startsWith('lect.')), isFalse, reason: c.id);
    }
    // -um est introduit par « personae/agents » (sujet et objet) : la désinence
    // attend le thema de cette carte ; -tur attend « actiones/passive-patient ».
    final edges = exposureEdges();
    for (final e in edges.entries) {
      expect(arbor[e.key]!.requirit, contains(e.value), reason: e.key);
    }
    expect(arbor['v.des.pass.3.sg.tur']!.requirit, contains('lect.thema.actiones.passive_patient'));
    expect(arbor['syn.abl.locus']!.requirit, contains('lect.thema.loca.a_ablative'));
  });
}
