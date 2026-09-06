/// Activity-neutral question contract shared by the encounter engine.
///
/// A question never decides whether an answer is right by itself: it records
/// every legitimate value of the asked dimension in [Question.correctValues]
/// and the engine compares the chosen value against that set. Activities
/// attach their own linguistic detail in a [QuestionPayload].
library;

import 'dart:math';

import 'exposure.dart';
import 'mastery.dart';
import 'trials.dart';

export 'exposure.dart' show ExposureLedger, ExposureNote;

class Choice {
  const Choice(this.value, this.label);
  final String value;
  final String label;

  Map<String, Object?> toJson() => {'v': value, 'l': label};
}

/// Activity-specific data carried by a question (the analysed form, its
/// alternatives…). Read only by the activity that produced the question.
abstract class QuestionPayload {
  const QuestionPayload();
}

class Question {
  const Question({
    required this.id,
    required this.trialId,
    required this.dimension,
    required this.prompt,
    required this.surface,
    required this.lemmaId,
    required this.choices,
    required this.correctValues,
    required this.skillIds,
    required this.payload,
    this.componentId,
    this.ambiguous = false,
    this.context = const [],
    this.exposure,
  });

  final String id;
  final String trialId;
  final Dimension dimension;
  final String prompt;
  final String surface;
  final String lemmaId;
  final List<Choice> choices;

  /// Every value accepted as correct (not only the one the form was drawn for).
  final Set<String> correctValues;

  /// Skills credited by this question; the first one drives rewards.
  final List<String> skillIds;
  final QuestionPayload payload;
  final String? componentId;

  /// More than one *offered* choice is legitimate (all are accepted).
  final bool ambiguous;

  /// Short lines shown under the form (dictionary entry, hint). Never a
  /// sentence that has not been checked.
  final List<String> context;

  /// Vocabulary met by this question (Theatrum); null for isolated forms.
  final ExposureNote? exposure;

  String get primarySkill => skillIds.first;
  bool isCorrect(String value) => correctValues.contains(value);
}

/// Latin feedback built from a resolved answer.
class Explanation {
  const Explanation({required this.headline, required this.detail, this.contrastSurface, this.also = const []});

  /// One line: what the form is.
  final String headline;

  /// Short contrast with the chosen (wrong) answer, or a confirmation.
  final String detail;

  /// Form of the same lemma matching the wrong choice (amāvit for "perfectum").
  final String? contrastSurface;

  /// Other legitimate analyses of the surface (ambiguity).
  final List<String> also;
}

/// What an activity must provide to the shared encounter engine: questions
/// for its trials and corrections for its answers.
abstract class QuestionSource {
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
  });

  Explanation explain({required Question q, required String chosenValue, required bool correct});
}

/// Dispatches to the source of the trial's activity.
class QuestionSources implements QuestionSource {
  const QuestionSources(this._resolve);

  /// Resolved lazily so that an activity's lexicon is only built when one of
  /// its trials is played.
  final QuestionSource Function(Activity) _resolve;

  QuestionSource forTrial(Trial t) => _resolve(t.activity);

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
  }) =>
      forTrial(trial).generate(trial: trial, componentIds: componentIds, rng: rng, id: id, recentLemmas: recentLemmas, recentSurfaces: recentSurfaces, skills: skills, cfg: cfg, exposure: exposure);

  @override
  Explanation explain({required Question q, required String chosenValue, required bool correct}) =>
      forTrial(Trials.byId(q.trialId)).explain(q: q, chosenValue: chosenValue, correct: correct);
}

/// Weighted random pick shared by the generators.
T weightedPick<T>(List<T> items, List<double> weights, Random rng) {
  final total = weights.fold(0.0, (a, b) => a + b);
  var r = rng.nextDouble() * total;
  for (var i = 0; i < items.length; i++) {
    r -= weights[i];
    if (r <= 0) return items[i];
  }
  return items.last;
}
