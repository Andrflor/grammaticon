/// Builds verb questions from the analysed lexicon for a given trial
/// (Amphitheatrum).
///
/// The generator never decides whether an answer is right: it records every
/// legitimate value of the asked dimension in [Question.correctValues], and the
/// encounter engine compares the chosen value against that set.
library;

import 'dart:math';

import '../linguistics/engine/analyzer.dart';
import '../linguistics/engine/conjugator.dart';
import '../linguistics/model/analysis.dart';
import '../linguistics/model/grammar.dart';
import '../linguistics/model/verb.dart';
import 'explanations.dart';
import 'mastery.dart';
import 'question.dart';
import 'skills.dart';
import 'trials.dart';

export 'question.dart';

/// Verb-specific detail of a question: the form it was drawn for and every
/// analysis of its surface.
class VerbQuestionPayload extends QuestionPayload {
  const VerbQuestionPayload({required this.target, required this.analyses});

  /// The analysis the form was drawn for.
  final FormEntry target;

  /// Every analysis of the surface in the verb lexicon.
  final List<FormEntry> analyses;
}

extension VerbQuestion on Question {
  /// The verb payload; only valid for Amphitheatrum questions.
  VerbQuestionPayload get verb => payload as VerbQuestionPayload;
}

/// Pool entry: a verb, one of its forms and the component it came from.
class PoolEntry {
  const PoolEntry(this.verb, this.form, this.componentId);
  final VerbEntry verb;
  final FormEntry form;
  final String? componentId;
}

class QuestionGenerator implements QuestionSource {
  QuestionGenerator(this.analyzer);
  final Analyzer analyzer;
  final Map<String, List<PoolEntry>> _pools = {};
  final Map<String, Map<Dimension, Set<String>>> _poolValues = {};

  // ----- pool ------------------------------------------------------------------

  String _poolKey(Trial t, List<String> componentIds) => '${t.id}|${(componentIds.toList()..sort()).join(',')}';

  List<PoolEntry> pool(Trial t, List<String> componentIds) {
    final key = _poolKey(t, componentIds);
    return _pools[key] ??= _buildPool(t, componentIds);
  }

  List<PoolEntry> _buildPool(Trial t, List<String> componentIds) {
    final out = <PoolEntry>[];
    // Only verb trials reach this generator, so the filters are verb filters.
    final filter = t.filter as FormFilter;
    final comps = t.isMixta ? t.components.where((c) => componentIds.contains(c.id)).toList() : const <TrialComponent>[];
    for (final v in analyzer.verbs) {
      final p = analyzer.paradigmOf(v.id);
      if (comps.isEmpty) {
        if (!filter.matchesVerb(v)) continue;
        for (final f in p.forms) {
          if (filter.matchesForm(v, f)) out.add(PoolEntry(v, f, null));
        }
      } else {
        for (final c in comps) {
          final cf = c.filter as FormFilter;
          if (!cf.matchesVerb(v)) continue;
          for (final f in p.forms) {
            if (cf.matchesForm(v, f)) out.add(PoolEntry(v, f, c.id));
          }
        }
      }
    }
    return out;
  }

  /// Distinct values of each dimension within the pool (a dimension with a
  /// single value is never asked: its answer would always be identical).
  Map<Dimension, Set<String>> poolValues(Trial t, List<String> componentIds) {
    final key = _poolKey(t, componentIds);
    return _poolValues[key] ??= _computeValues(pool(t, componentIds));
  }

  Map<Dimension, Set<String>> _computeValues(List<PoolEntry> entries) {
    final m = <Dimension, Set<String>>{};
    for (final d in Dimension.values) {
      if (d == Dimension.formaPlena || d == Dimension.analysis) continue;
      final s = <String>{};
      for (final e in entries) {
        final v = valueOf(d, e.verb, e.form.analysis);
        if (v != null) s.add(v);
      }
      m[d] = s;
    }
    return m;
  }

  // ----- dimension values ---------------------------------------------------------

  /// Value of [d] for one analysis, or null when the dimension does not apply.
  String? valueOf(Dimension d, VerbEntry v, Analysis a) {
    switch (d) {
      case Dimension.persona:
        return a.person?.key;
      case Dimension.numerus:
        return a.isFinite || a.mood == Mood.participium || a.mood == Mood.gerundivum ? a.number?.key : null;
      case Dimension.tempus:
        return a.tense?.key;
      case Dimension.tempusSensus:
        return a.effectiveSemanticTense?.key;
      case Dimension.modus:
        return a.mood.key;
      case Dimension.vox:
        return a.voice?.key;
      case Dimension.coniugatio:
        return v.conjugation.key;
      case Dimension.declinatio:
        return null;
      case Dimension.genus:
        return a.gender?.key;
      case Dimension.casus:
        return a.casus?.key;
      case Dimension.forma:
        return FormKind.of(a).name;
      case Dimension.lemma:
        return a.lemmaId;
      case Dimension.formaPlena:
        return null;
      case Dimension.analysis:
      case Dimension.sensus:
        return null;
    }
  }

  String labelOf(Dimension d, String value) {
    switch (d) {
      case Dimension.persona:
        return Person.fromKey(value).latin;
      case Dimension.numerus:
        return Numerus.fromKey(value).latin;
      case Dimension.tempus:
      case Dimension.tempusSensus:
        return Tense.fromKey(value).latin;
      case Dimension.modus:
        return Mood.fromKey(value).latin;
      case Dimension.vox:
        return Voice.fromKey(value).latin;
      case Dimension.coniugatio:
        return Conjugation.fromKey(value).latin;
      case Dimension.declinatio:
        return Declension.fromKey(value).latin;
      case Dimension.genus:
        return Gender.fromKey(value).latin;
      case Dimension.casus:
        return Casus.fromKey(value).latin;
      case Dimension.forma:
        return FormKind.values.firstWhere((k) => k.name == value).latin;
      case Dimension.lemma:
        return analyzer.verb(value).lemma;
      case Dimension.formaPlena:
      case Dimension.analysis:
      case Dimension.sensus:
        return value;
    }
  }

  /// Compact analysis descriptor used as the value of [Dimension.analysis].
  static String analysisKey(Analysis a) {
    final parts = <String>[a.mood.key];
    if (a.periphrasis != Periphrasis.nulla) parts.insert(0, a.periphrasis.key);
    if (a.tense != null) parts.add(a.tense!.key);
    if (a.voice != null) parts.add(a.voice!.key);
    if (a.person != null) parts.add(a.person!.key);
    if (a.casus != null && !a.isFinite && a.mood != Mood.infinitivus) parts.add(a.casus!.key);
    if (a.number != null && a.mood != Mood.infinitivus) parts.add(a.number!.key);
    if (a.gender != null && a.mood != Mood.infinitivus && !a.isFinite) parts.add(a.gender!.key);
    return parts.join('.');
  }

  static String analysisLabel(Analysis a) {
    final b = <String>[];
    if (a.periphrasis != Periphrasis.nulla) b.add(a.periphrasis.latin.toLowerCase());
    if (a.isFinite) {
      b.add('${a.person!.latin.toLowerCase()} ${a.number!.latin.toLowerCase()}');
      b.add('${a.mood.latin.toLowerCase()} ${a.tense!.latin.toLowerCase()}');
      if (a.voice != null) b.add(a.voice!.latin.toLowerCase());
    } else if (a.mood == Mood.infinitivus) {
      b.add('īnfīnītīvus ${a.tense!.latin.toLowerCase()}');
      if (a.voice != null) b.add(a.voice!.latin.toLowerCase());
    } else if (a.mood == Mood.participium) {
      b.add('participium ${a.tense!.latin.toLowerCase()} ${a.voice!.latin.toLowerCase()}');
      b.add('${a.casus!.latin.toLowerCase()} ${a.number!.latin.toLowerCase()} ${a.gender!.latin.toLowerCase()}');
    } else if (a.mood == Mood.gerundivum) {
      b.add('gerundīvum ${a.casus!.latin.toLowerCase()} ${a.number!.latin.toLowerCase()} ${a.gender!.latin.toLowerCase()}');
    } else {
      b.add('${a.mood.latin.toLowerCase()} ${a.casus!.latin.toLowerCase()}');
    }
    return b.join(' · ');
  }

  // ----- generation ------------------------------------------------------------------

  @override
  Explanation explain({required Question q, required String chosenValue, required bool correct}) => Explanations.build(q: q, chosenValue: chosenValue, correct: correct, gen: this);

  /// Generates one question, or null when the trial pool is empty.
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
    final values = poolValues(trial, componentIds);

    // Eligible dimensions: at least two distinct values in the pool.
    final primaryRecord = skills[trial.primarySkill];
    final tier = primaryRecord?.tier(cfg) ?? MasteryTier.nova;
    final dims = <Dimension>[];
    for (final d in trial.dimensions) {
      if (d == Dimension.analysis) {
        if (tier.index >= MasteryTier.familiaris.index) dims.add(d);
        continue;
      }
      if (d == Dimension.formaPlena) {
        dims.add(d);
        continue;
      }
      if ((values[d]?.length ?? 0) >= 2) dims.add(d);
    }
    if (dims.isEmpty) return null;

    // Weighted pick: lemma questions are less frequent.
    final weights = [for (final d in dims) d == Dimension.lemma ? 0.5 : 1.0];
    final dim = _weightedPick(dims, weights, rng);

    // Candidate forms with a value for this dimension, avoiding recent lemmas
    // and surfaces; prefer forms whose answer is unambiguous.
    List<PoolEntry> candidates = entries.where((e) => dim == Dimension.formaPlena || dim == Dimension.analysis || valueOf(dim, e.verb, e.form.analysis) != null).toList();
    if (dim == Dimension.formaPlena) candidates = candidates.where((e) => !e.form.isPrimary).toList();
    if (dim == Dimension.analysis) candidates = candidates.where((e) => e.form.isPrimary).toList();
    if (candidates.isEmpty) return null;
    var fresh = candidates.where((e) => !recentLemmas.contains(e.verb.id) && !recentSurfaces.contains(e.form.surface)).toList();
    if (fresh.length < 4) fresh = candidates.where((e) => !recentSurfaces.contains(e.form.surface)).toList();
    if (fresh.isEmpty) fresh = candidates;

    // Diversity: lemmas with fewer observations in the primary skill weigh more.
    final seenLemmas = primaryRecord?.lemmas ?? const <String>{};
    PoolEntry? chosen;
    var chosenAmbiguous = true;
    for (var attempt = 0; attempt < 12; attempt++) {
      final e = _weightedPick(fresh, [for (final e in fresh) seenLemmas.contains(e.verb.id) ? 1.0 : 2.0], rng);
      final correct = _correctValues(dim, e);
      if (correct.length == 1) {
        chosen = e;
        chosenAmbiguous = false;
        break;
      }
      chosen ??= e;
    }
    final e = chosen!;
    final correct = _correctValues(dim, e);
    if (correct.isEmpty) return null;

    final choices = _buildChoices(dim, e, correct, values[dim] ?? const {}, trial, rng);
    if (choices.length < 2) return null;
    final ambiguous = chosenAmbiguous && correct.length > 1;

    final skillIds = <String>[trial.primarySkill];
    final comp = trial.components.where((c) => c.id == e.componentId).firstOrNull;
    if (comp?.skillId != null && !skillIds.contains(comp!.skillId)) skillIds.add(comp.skillId!);
    // Mixta questions also credit the tense skill actually observed.
    final a = e.form.analysis;
    if (trial.isMixta && a.isFinite && a.tense != null && a.voice != null && a.periphrasis == Periphrasis.nulla && a.mood != Mood.imperativus) {
      final s = Skills.finite(a.mood.key, a.tense!.key, a.voice!.key);
      if (Skills.maybe(s) != null && !skillIds.contains(s)) skillIds.add(s);
    }

    return Question(
      id: id,
      trialId: trial.id,
      dimension: dim,
      prompt: dim.prompt,
      surface: e.form.surface,
      lemmaId: e.verb.id,
      payload: VerbQuestionPayload(target: e.form, analyses: analyzer.analyze(e.form.surface)),
      choices: choices,
      correctValues: correct,
      skillIds: skillIds,
      componentId: e.componentId,
      ambiguous: ambiguous,
    );
  }

  Set<String> _correctValues(Dimension dim, PoolEntry e) {
    if (dim == Dimension.formaPlena) {
      final p = analyzer.paradigmOf(e.verb.id);
      final prim = p.primary(e.form.analysis.selector);
      return prim == null ? {} : {prim.surface};
    }
    if (dim == Dimension.analysis) {
      // Every complete analysis of the surface for this lemma is correct.
      return analyzer.analyze(e.form.surface).where((f) => f.analysis.lemmaId == e.verb.id).map((f) => analysisKey(f.analysis)).toSet();
    }
    final out = <String>{};
    for (final f in analyzer.analyze(e.form.surface)) {
      final v = valueOf(dim, analyzer.verb(f.analysis.lemmaId), f.analysis);
      if (v != null) out.add(v);
    }
    return out;
  }

  List<Choice> _buildChoices(Dimension dim, PoolEntry e, Set<String> correct, Set<String> poolVals, Trial trial, Random rng) {
    final a = e.form.analysis;
    List<String> values;
    switch (dim) {
      case Dimension.formaPlena:
        final p = analyzer.paradigmOf(e.verb.id);
        final distractors = <String>{};
        final sameTense = p.forms.where((f) => f.isPrimary && !f.composite && f.analysis.mood == a.mood && f.analysis.tense == a.tense && f.analysis.voice == a.voice && f.surface != correct.first).map((f) => f.surface).toList();
        final otherTense = p.forms.where((f) => f.isPrimary && !f.composite && f.analysis.isFinite == a.isFinite && f.analysis.person == a.person && f.analysis.number == a.number && f.analysis.voice == a.voice && f.surface != correct.first).map((f) => f.surface).toList();
        final all = [...sameTense, ...otherTense]..shuffle(rng);
        for (final s in all) {
          if (distractors.length >= 3) break;
          if (s != e.form.surface) distractors.add(s);
        }
        values = [...correct, ...distractors];
      case Dimension.analysis:
        final p = analyzer.paradigmOf(e.verb.id);
        final distractors = <String>{};
        // Neighbours: same form class, one dimension changed.
        final neighbours = p.forms.where((f) => f.isPrimary && f.analysis.mood == a.mood && f.analysis.periphrasis == a.periphrasis && analysisKey(f.analysis) != analysisKey(a)).toList()..shuffle(rng);
        // Prefer same person/number (tense changed) then same tense (person changed).
        neighbours.sort((x, y) {
          int score(FormEntry f) {
            var s = 0;
            if (f.analysis.person == a.person && f.analysis.number == a.number) s -= 2;
            if (f.analysis.tense == a.tense) s -= 1;
            if (f.analysis.voice == a.voice) s -= 1;
            return s;
          }
          return score(x).compareTo(score(y));
        });
        for (final f in neighbours) {
          final k = analysisKey(f.analysis);
          if (correct.contains(k)) continue;
          distractors.add(k);
          if (distractors.length >= 3) break;
        }
        values = [...correct, ...distractors];
      case Dimension.lemma:
        final others = poolVals.where((v) => !correct.contains(v)).toList()..shuffle(rng);
        // Prefer lemmas of the same family/conjugation as distractors.
        others.sort((x, y) {
          int score(String id) {
            final v = analyzer.verb(id);
            var s = 0;
            if (v.family != null && v.family == e.verb.family) s -= 2;
            if (v.conjugation == e.verb.conjugation) s -= 1;
            return s;
          }
          return score(x).compareTo(score(y));
        });
        values = [...correct.take(2), ...others.take(4 - min(2, correct.length))];
      default:
        final others = poolVals.where((v) => !correct.contains(v)).toList()..shuffle(rng);
        final max = switch (dim) {
          Dimension.persona => 3,
          Dimension.numerus => 2,
          Dimension.vox => 2,
          Dimension.genus => 3,
          Dimension.coniugatio => 5,
          _ => 4,
        };
        final need = max - correct.length;
        values = [...correct, ...others.take(need < 1 ? 1 : need)];
        // Keep a canonical order for stable enumerations (tenses, persons, cases).
        values.sort((x, y) => _canonicalIndex(dim, x).compareTo(_canonicalIndex(dim, y)));
        return [for (final v in values) Choice(v, labelOf(dim, v))];
    }
    values.shuffle(rng);
    return [
      for (final v in values)
        Choice(v, dim == Dimension.analysis ? analysisLabel(_analysisFromKey(e.verb.id, v)) : labelOf(dim, v)),
    ];
  }

  Analysis _analysisFromKey(String lemmaId, String key) {
    final p = analyzer.paradigmOf(lemmaId);
    return p.forms.firstWhere((f) => analysisKey(f.analysis) == key).analysis;
  }

  int _canonicalIndex(Dimension d, String v) {
    switch (d) {
      case Dimension.persona:
        return Person.fromKey(v).index;
      case Dimension.numerus:
        return Numerus.fromKey(v).index;
      case Dimension.tempus:
      case Dimension.tempusSensus:
        return Tense.fromKey(v).index;
      case Dimension.modus:
        return Mood.fromKey(v).index;
      case Dimension.vox:
        return Voice.fromKey(v).index;
      case Dimension.coniugatio:
        return Conjugation.fromKey(v).index;
      case Dimension.declinatio:
        return Declension.fromKey(v).index;
      case Dimension.genus:
        return Gender.fromKey(v).index;
      case Dimension.casus:
        return Casus.fromKey(v).index;
      case Dimension.forma:
        return FormKind.values.indexWhere((k) => k.name == v);
      default:
        return 0;
    }
  }

  /// Form of the same verb that would match the chosen (wrong) value, used in
  /// feedback: "amāvit is the perfect; amābat is the imperfect".
  FormEntry? contrastForm(Question q, String chosenValue) {
    final a = q.verb.target.analysis;
    final p = analyzer.paradigmOf(q.lemmaId);
    switch (q.dimension) {
      case Dimension.persona:
        return p.primary(a.copyWith(person: Person.fromKey(chosenValue)).selector);
      case Dimension.numerus:
        return p.primary(a.copyWith(number: Numerus.fromKey(chosenValue)).selector);
      case Dimension.tempus:
        return p.primary(a.copyWith(tense: Tense.fromKey(chosenValue)).selector) ?? _firstOf(p, (x) => x.tense?.key == chosenValue && x.mood == a.mood && x.voice == a.voice);
      case Dimension.tempusSensus:
        return null;
      case Dimension.modus:
        return p.primary(a.copyWith(mood: Mood.fromKey(chosenValue)).selector) ?? _firstOf(p, (x) => x.mood.key == chosenValue && x.tense == a.tense && x.voice == a.voice);
      case Dimension.vox:
        return p.primary(a.copyWith(voice: Voice.fromKey(chosenValue)).selector) ?? _firstOf(p, (x) => x.voice?.key == chosenValue && x.mood == a.mood && x.tense == a.tense && x.person == a.person && x.number == a.number);
      case Dimension.genus:
        return p.primary(a.copyWith(gender: Gender.fromKey(chosenValue)).selector);
      case Dimension.casus:
        return p.primary(a.copyWith(casus: Casus.fromKey(chosenValue)).selector);
      case Dimension.forma:
        return _firstOf(p, (x) => FormKind.of(x).name == chosenValue);
      case Dimension.lemma:
        final other = analyzer.paradigmOf(chosenValue);
        return other.primary(a.copyWith(lemmaId: chosenValue).selector);
      case Dimension.formaPlena:
        return _firstOf(p, (x) => p.primary(x.selector)?.surface == chosenValue);
      case Dimension.analysis:
        return p.forms.where((f) => analysisKey(f.analysis) == chosenValue && f.isPrimary).firstOrNull;
      case Dimension.sensus:
        return null;
      case Dimension.coniugatio:
      case Dimension.declinatio:
        return null;
    }
  }

  FormEntry? _firstOf(Paradigm paradigm, bool Function(Analysis) test) {
    for (final f in paradigm.forms) {
      if (f.isPrimary && test(f.analysis)) return f;
    }
    return null;
  }

  T _weightedPick<T>(List<T> items, List<double> weights, Random rng) => weightedPick(items, weights, rng);
}
