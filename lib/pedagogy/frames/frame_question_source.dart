/// Questions du Theatrum et du Templum tirées des cadres authored.
library;

import 'dart:math';

import '../mastery.dart';
import '../question.dart';
import '../trials.dart';
import 'frame_cards.dart';
import 'frame_content.dart';
import 'frame_trials.dart';

class FrameQuestionPayload extends QuestionPayload {
  const FrameQuestionPayload({required this.instance, required this.nodes});
  final FrameInstance instance;

  /// Nœuds de l'arbre visés par la carte.
  final List<String> nodes;
  Frame get frame => instance.frame;
}

extension FrameQuestion on Question {
  FrameQuestionPayload get frame => payload as FrameQuestionPayload;
}

class FrameQuestionSource implements QuestionSource {
  FrameQuestionSource(this.library);
  final FrameLibrary library;

  List<Frame> pool(Trial trial) => trial.filter is FrameFilter ? library.forCard((trial.filter as FrameFilter).card) : const [];

  @override
  Question? generate({
    required Trial trial,
    required List<String> componentIds,
    required Random rng,
    required String id,
    List<String> recentLemmas = const [],
    List<String> recentSurfaces = const [],
    Map<String, SkillRecord> skills = const {},
    MasteryConfig cfg = const MasteryConfig(),
    ExposureLedger exposure = const ExposureLedger(),
    Recall recall = Recall.none,
    ArborNeeds? needs,
  }) {
    final frames = pool(trial);
    if (frames.isEmpty) return null;
    final nodes = frameCardNodes((trial.filter as FrameFilter).card);
    // Un cadre peu joué pèse plus ; les besoins de l'arbre (maillons faibles,
    // hypothèses ouvertes) s'appliquent à la carte entière puisque tous ses
    // cadres visent les mêmes nœuds.
    // Les cadres joués récemment dans ce combat (recentLemmas porte leurs
    // identifiants) reculent ; un cadre peu joué pèse plus.
    final weights = [for (final f in frames) (1.0 / (1 + exposure.seenCount(f.id))) * (recentLemmas.contains(f.id) ? 0.15 : 1.0)];
    final frame = weightedPick(frames, weights, rng);
    final inst = frame.instantiate(rng);
    final choices = <Choice>[];
    final correct = <String>{};
    for (var i = 0; i < inst.choices.length; i++) {
      final v = 'c$i';
      choices.add(Choice(v, inst.choices[i]));
      if (frame.choices[i].accepted) correct.add(v);
    }
    if (correct.isEmpty || correct.length == choices.length) return null;
    choices.shuffle(rng);
    return Question(
      id: id,
      trialId: trial.id,
      dimension: trial.dimensions.first,
      prompt: frame.prompt.isEmpty ? trial.dimensions.first.prompt : frame.prompt,
      surface: inst.surface,
      lemmaId: frame.id,
      choices: choices,
      correctValues: correct,
      skillIds: [trial.primarySkill],
      payload: FrameQuestionPayload(instance: inst, nodes: nodes),
      ambiguous: correct.length > 1,
      exposure: ExposureNote(itemId: frame.id, passageId: frame.card, lemmas: const [], targetLemma: ''),
    );
  }

  @override
  Explanation explain({required Question q, required String chosenValue, required bool correct}) {
    final p = q.frame;
    final idx = int.tryParse(chosenValue.substring(1)) ?? 0;
    final chosen = idx < p.frame.choices.length ? p.frame.choices[idx] : null;
    final accepted = [for (var i = 0; i < p.frame.choices.length; i++) if (p.frame.choices[i].accepted) p.instance.choices[i]];
    final headline = p.instance.surface;
    final feedback = chosen?.feedback ?? '';
    if (correct) return Explanation(headline: headline, detail: feedback.isEmpty ? 'Rēctē.' : feedback);
    var detail = 'Rēctum: ${accepted.join(' aut ')}.';
    if (feedback.isNotEmpty) detail += ' $feedback';
    return Explanation(headline: headline, detail: detail);
  }
}
