/// Builds Theatrum questions from the curated reading content.
///
/// Rules:
/// * a question shows an exact Latin passage and four renderings in the
///   selected translation language: every accepted rendering is correct
///   (paraphrases are never rejected for differing from the published text);
/// * nothing is generated at run time: distractors and their annotations are
///   authored, validated data;
/// * selection is coverage-oriented: items never played, and items whose
///   vocabulary the player has met least, weigh more, so rare words are not
///   neglected indefinitely; recent passages are avoided;
/// * the question credits the reading skill of the distinction only — the
///   words of the passage are recorded as exposure, never as mastery.
library;

import 'dart:math';

import '../mastery.dart';
import '../question.dart';
import '../skills.dart';
import '../trial.dart';
import 'reading_content.dart';
import 'reading_trials.dart';

/// Reading-specific detail of a question.
class ReadingQuestionPayload extends QuestionPayload {
  const ReadingQuestionPayload({required this.entry, required this.language});
  final ReadingEntry entry;
  final String language;

  Distractor? distractor(String value) {
    for (final d in entry.renderings.distractors) {
      if (d.id == value) return d;
    }
    return null;
  }
}

extension ReadingQuestion on Question {
  /// The reading payload; only valid for Theatrum questions.
  ReadingQuestionPayload get reading => payload as ReadingQuestionPayload;
}

class ReadingQuestionSource implements QuestionSource {
  ReadingQuestionSource(this.library, {required this.language});
  final ReadingLibrary library;

  /// Translation language code (`fr`); content of another language is never
  /// substituted when this one is unavailable.
  final String language;

  ReadingSet? get set => library.forLanguage(language);
  bool get available => set != null && set!.entries.isNotEmpty;

  final Map<String, List<ReadingEntry>> _pools = {};

  String _poolKey(Trial t, List<String> componentIds) => '${t.id}|${(componentIds.toList()..sort()).join(',')}';

  /// Items playable in [trial] with the selected components.
  List<ReadingEntry> pool(Trial trial, List<String> componentIds) => _pools[_poolKey(trial, componentIds)] ??= _buildPool(trial, componentIds);

  List<ReadingEntry> _buildPool(Trial trial, List<String> componentIds) {
    final s = set;
    if (s == null) return const [];
    final out = <ReadingEntry>[];
    final comps = trial.isMixta ? trial.components.where((c) => componentIds.contains(c.id)).toList() : const <TrialComponent>[];
    for (final e in s.entries) {
      if (comps.isEmpty) {
        if ((trial.filter as ReadingFilter).matches(trial.id, e.item.trialId)) out.add(e);
      } else if (comps.any((c) => (c.filter as ReadingFilter).matches(trial.id, e.item.trialId))) {
        out.add(e);
      }
    }
    return out;
  }

  String? _componentOf(Trial trial, List<String> componentIds, ReadingEntry e) {
    for (final c in trial.components) {
      if (componentIds.contains(c.id) && (c.filter as ReadingFilter).matches(trial.id, e.item.trialId)) return c.id;
    }
    return null;
  }

  // ----- selection -------------------------------------------------------------

  /// Coverage weight of an item: unseen items and unmet vocabulary weigh
  /// more; a due review of the skill favours familiar items instead.
  double weight(ReadingEntry e, ExposureLedger exposure, {bool reviewDue = false}) {
    final plays = exposure.seenCount(e.item.id);
    var w = plays == 0 ? 3.0 : 1.0 / (1 + plays);
    var novel = 0.0;
    for (final l in e.passage.lemmas.toSet()) {
      final x = exposure.of(l);
      if (x.seen == 0) {
        novel += 1;
      } else if (!x.revisited) {
        novel += 0.5;
      }
    }
    w += novel / max(1, e.passage.words.length) * 2;
    if (reviewDue && plays > 0) w += 1.5;
    return w;
  }

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
  }) {
    final entries = pool(trial, componentIds);
    if (entries.isEmpty) return null;
    var fresh = entries.where((e) => !recentSurfaces.contains(e.passage.text) && !recentLemmas.contains(e.item.target.lemmaId)).toList();
    if (fresh.length < 3) fresh = entries.where((e) => !recentSurfaces.contains(e.passage.text)).toList();
    if (fresh.isEmpty) fresh = entries;
    final due = (skills[trial.primarySkill] ?? const SkillRecord()).reviewDue(DateTime.now(), cfg);
    final e = weightedPick(fresh, [for (final x in fresh) weight(x, exposure, reviewDue: due)], rng);
    return _question(trial, componentIds, e, id, rng);
  }

  Question _question(Trial trial, List<String> componentIds, ReadingEntry e, String id, Random rng) {
    final r = e.renderings;
    final choices = [
      for (final c in r.correct) Choice(c.id, c.text),
      for (final d in r.distractors) Choice(d.id, d.text),
    ]..shuffle(rng);
    final correct = {for (final c in r.correct) c.id};
    final skillIds = <String>[];
    if (trial.isMixta) skillIds.add(trial.primarySkill);
    if (!skillIds.contains(e.item.skillId)) skillIds.add(e.item.skillId);
    final passage = e.passage;
    return Question(
      id: id,
      trialId: trial.id,
      dimension: Dimension.sensus,
      prompt: Dimension.sensus.prompt,
      surface: passage.text,
      lemmaId: e.item.target.lemmaId,
      choices: choices,
      correctValues: correct,
      skillIds: skillIds,
      payload: ReadingQuestionPayload(entry: e, language: language),
      componentId: _componentOf(trial, componentIds, e),
      ambiguous: correct.length > 1,
      context: [library.corpus.latinRef(passage.ref)],
      exposure: ExposureNote(itemId: e.item.id, passageId: passage.id, lemmas: passage.lemmas, targetLemma: e.item.target.lemmaId),
    );
  }

  // ----- corrections -------------------------------------------------------------

  @override
  Explanation explain({required Question q, required String chosenValue, required bool correct}) {
    final p = q.reading;
    final e = p.entry;
    final t = e.item.target;
    final headline = '«${t.span}» — ${t.analysis} (${t.lemmaId})';
    if (correct) {
      final detail = q.ambiguous ? 'Rēctē: plūrēs interpretātiōnēs aequē vērae sunt.' : (e.item.note.isNotEmpty ? e.item.note : 'Rēctē.');
      return Explanation(headline: headline, detail: detail);
    }
    final d = p.distractor(chosenValue);
    final right = e.renderings.correct.first.text;
    if (d == null) {
      return Explanation(headline: headline, detail: 'Rēctum: «$right».');
    }
    final detail = 'Rēctum: «$right». Tū ēlēgistī: «${d.text}». «${d.span}» est ${d.correctAnalysis}, nōn ${d.wrongAnalysis}: ${d.explanation} Gallicē: ${d.shift}';
    return Explanation(headline: headline, detail: detail);
  }

  /// Latin label of the skill credited (for the help sheet).
  static String skillName(String id) => Skills.maybe(id)?.name ?? id;
}
