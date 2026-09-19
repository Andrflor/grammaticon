/// Questions du Theatrum et du Templum tirées des cadres authored.
library;

import 'dart:math';

import '../../arbor/contextus.dart';

import '../mastery.dart';
import '../question.dart';
import '../trials.dart';
import 'frame_cards.dart';
import 'frame_content.dart';
import 'frame_trials.dart';

class FrameQuestionPayload extends QuestionPayload {
  const FrameQuestionPayload({required this.instance, required this.nodes, this.lemmaCapacity});
  final FrameInstance instance;

  /// Nœuds de l'arbre visés par la carte.
  final List<String> nodes;
  /// Nombre d'exemples distincts effectivement disponibles pour ce nœud.
  final int? lemmaCapacity;
  Frame get frame => instance.frame;
}

extension FrameQuestion on Question {
  FrameQuestionPayload get frame => payload as FrameQuestionPayload;
}

class FrameQuestionSource implements QuestionSource {
  FrameQuestionSource(this.library);
  final FrameLibrary library;
  final Map<String, List<Frame>> _pools = {};

  List<Frame> pool(Trial trial) => trial.filter is FrameFilter
    ? _pools.putIfAbsent((trial.filter as FrameFilter).card, () => library.forCard((trial.filter as FrameFilter).card).where((f) => f.choices.any((c) => c.accepted) && f.choices.any((c) => !c.accepted)).toList())
    : const [];

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
    final cardNodes = frameCardNodes((trial.filter as FrameFilter).card);
    final remaining = [...frames];
    FrameInstance? selected;
    while (remaining.isNotEmpty && selected == null) {
      final weights = [for (final f in remaining)
        (1.0 / (1 + exposure.seenCount(f.id))) *
        (needs?.nodes([...cardNodes, if (f.targetLexeme != null) vocabularyNodeId(f.place, f.targetLexeme!)]) ?? 1.0)];
      final candidate = weightedPick(remaining, weights, rng);
      remaining.remove(candidate);
      final start = rng.nextInt(candidate.variantCount);
      final options = <FrameInstance>[];
      // At most twelve recent surfaces are supplied by the encounter. Scan
      // past them without materializing the complete (potentially huge) bank.
      for (var offset = 0; offset < candidate.variantCount && options.length < 8; offset++) {
        final instance = candidate.instantiateAt((start + offset) % candidate.variantCount);
        if (!recentSurfaces.contains(instance.surface)) options.add(instance);
      }
      if (options.isNotEmpty) {
        final minimum = options.map((i) => exposure.seenCount(i.itemId)).reduce(min);
        final fresh = options.where((i) => exposure.seenCount(i.itemId) == minimum).toList();
        selected = weightedPick(fresh, [for (final i in fresh) recentLemmas.contains(i.evidenceId ?? i.frame.id) ? 0.15 : 1.0], rng);
      }
    }
    // Small lexical/test banks may have exhausted every distinct surface.
    // Only then allow a repeat, rather than reporting missing content.
    final inst = selected ?? weightedPick(frames, [for (final f in frames) 1.0 / (1 + exposure.seenCount(f.id))], rng).instantiate(rng);
    final frame = inst.frame;
    final nodes = [...cardNodes, if (frame.targetLexeme != null) vocabularyNodeId(frame.place, frame.targetLexeme!)];
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
      lemmaId: inst.evidenceId ?? frame.id,
      choices: choices,
      correctValues: correct,
      skillIds: [trial.primarySkill],
      payload: FrameQuestionPayload(instance: inst, nodes: nodes, lemmaCapacity: library.evidenceCapacity(frame.card)),
      ambiguous: correct.length > 1,
      exposure: ExposureNote(itemId: inst.itemId, groupId: frame.id, passageId: inst.itemId,
        lemmas: inst.vocabulary, targetLemma: frame.targetLexeme ?? ''),
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
