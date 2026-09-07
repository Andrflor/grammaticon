/// Builds noun questions for the Forum from the declined lexicon.
///
/// Rules of the Forum's questions:
/// * every analysis of the surface in the lexicon is accepted (`rosae` is
///   genitive, dative, nominative plural and vocative plural at once);
/// * a question is never asked when every offered choice would be correct,
///   and forms with a single correct offered answer are preferred;
/// * a dimension fixed by the trial (the declension in a first-declension
///   trial) is never asked;
/// * the dictionary entry is shown only when it does not give the answer away.
library;

import 'dart:math';

import '../linguistics/engine/noun_analyzer.dart';
import '../linguistics/help/declension_help.dart';
import '../linguistics/model/grammar.dart';
import '../linguistics/model/noun.dart';
import 'mastery.dart';
import 'noun_trials.dart';
import 'question.dart';
import 'skills.dart';
import 'trial.dart';

/// Noun-specific detail of a question.
class NounQuestionPayload extends QuestionPayload {
  const NounQuestionPayload({required this.target, required this.analyses, required this.noun});

  /// The analysis the form was drawn for.
  final NounForm target;

  /// Every analysis of the surface in the noun lexicon.
  final List<NounForm> analyses;
  final NounEntry noun;
}

extension NounQuestion on Question {
  /// The noun payload; only valid for Forum questions.
  NounQuestionPayload get noun => payload as NounQuestionPayload;
}

class NounPoolEntry {
  const NounPoolEntry(this.noun, this.form, this.componentId);
  final NounEntry noun;
  final NounForm form;
  final String? componentId;
}

class NounQuestionGenerator implements QuestionSource {
  NounQuestionGenerator(this.analyzer);
  final NounAnalyzer analyzer;
  final Map<String, List<NounPoolEntry>> _pools = {};
  final Map<String, Map<Dimension, Set<String>>> _poolValues = {};
  Map<String, Set<Declension>>? _endingDeclensions;

  static const _dimensions = [Dimension.casus, Dimension.numerus, Dimension.declinatio, Dimension.analysis];

  // ----- pool ------------------------------------------------------------------

  String _poolKey(Trial t, List<String> componentIds) => '${t.id}|${(componentIds.toList()..sort()).join(',')}';

  List<NounPoolEntry> pool(Trial t, List<String> componentIds) => _pools[_poolKey(t, componentIds)] ??= _buildPool(t, componentIds);

  List<NounPoolEntry> _buildPool(Trial t, List<String> componentIds) {
    final out = <NounPoolEntry>[];
    // Only noun trials reach this generator, so the filters are noun filters.
    final filter = t.filter as NounFilter;
    final comps = t.isMixta ? t.components.where((c) => componentIds.contains(c.id)).toList() : const <TrialComponent>[];
    for (final n in analyzer.nouns) {
      final p = analyzer.paradigmOf(n.id);
      if (comps.isEmpty) {
        if (!filter.matchesNoun(n)) continue;
        for (final f in p.forms) {
          if (filter.matchesForm(n, f)) out.add(NounPoolEntry(n, f, null));
        }
      } else {
        for (final c in comps) {
          final cf = c.filter as NounFilter;
          if (!cf.matchesNoun(n)) continue;
          for (final f in p.forms) {
            if (cf.matchesForm(n, f)) out.add(NounPoolEntry(n, f, c.id));
          }
        }
      }
    }
    return out;
  }

  /// Distinct values of each dimension within the pool.
  Map<Dimension, Set<String>> poolValues(Trial t, List<String> componentIds) => _poolValues[_poolKey(t, componentIds)] ??= _computeValues(pool(t, componentIds));

  Map<Dimension, Set<String>> _computeValues(List<NounPoolEntry> entries) {
    final m = <Dimension, Set<String>>{};
    for (final d in _dimensions) {
      if (d == Dimension.analysis) continue;
      m[d] = {for (final e in entries) valueOf(d, e.form.analysis)!};
    }
    return m;
  }

  // ----- dimension values ---------------------------------------------------------

  String? valueOf(Dimension d, NounAnalysis a) => switch (d) {
        Dimension.casus => a.casus.key,
        Dimension.numerus => a.number.key,
        Dimension.declinatio => a.declension.key,
        Dimension.genus => a.gender.key,
        Dimension.analysis => analysisKey(a),
        _ => null,
      };

  String labelOf(Dimension d, String value) => switch (d) {
        Dimension.casus => Casus.fromKey(value).latin,
        Dimension.numerus => Numerus.fromKey(value).latin,
        Dimension.declinatio => '${Declension.fromKey(value).latin} dēclīnātiō',
        Dimension.genus => Gender.fromKey(value).latin,
        Dimension.analysis => analysisLabel(value),
        _ => value,
      };

  /// `acc.sg`
  static String analysisKey(NounAnalysis a) => a.selector;

  /// `accūsātīvus singulāris`
  static String analysisLabel(String key) {
    final p = key.split('.');
    return '${Casus.fromKey(p[0]).latin.toLowerCase()} ${Numerus.fromKey(p[1]).latin.toLowerCase()}';
  }

  int _canonicalIndex(Dimension d, String v) => switch (d) {
        Dimension.casus => Casus.fromKey(v).index,
        Dimension.numerus => Numerus.fromKey(v).index,
        Dimension.declinatio => Declension.fromKey(v).index,
        Dimension.genus => Gender.fromKey(v).index,
        Dimension.analysis => Numerus.fromKey(v.split('.')[1]).index * 10 + Casus.fromKey(v.split('.')[0]).index,
        _ => 0,
      };

  // ----- generation ------------------------------------------------------------------

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

    // Eligible dimensions: at least two distinct values in the pool, so that a
    // value fixed by the trial (the declension in a first-declension trial) is
    // never asked. Full analysis is asked once the skill is at least familiar.
    final tier = _aggregateTier(trial.primarySkill, skills, cfg);
    final dims = <Dimension>[];
    for (final d in trial.dimensions) {
      if (d == Dimension.analysis) {
        if (tier.index >= MasteryTier.familiaris.index) dims.add(d);
        continue;
      }
      if ((values[d]?.length ?? 0) >= 2) dims.add(d);
    }
    if (dims.isEmpty) return null;
    final dim = weightedPick(dims, [for (final d in dims) d == Dimension.numerus ? 0.8 : 1.0], rng);
    final offered = dim == Dimension.analysis ? null : values[dim]!;

    // Candidates avoiding recent lemmas and surfaces.
    var fresh = entries.where((e) => !recentLemmas.contains(e.noun.id) && !recentSurfaces.contains(e.form.surface)).toList();
    if (fresh.length < 4) fresh = entries.where((e) => !recentSurfaces.contains(e.form.surface)).toList();
    if (fresh.isEmpty) fresh = entries;

    // Prefer forms with a single correct offered answer; never accept a form
    // where every offered choice would be correct. Lemmas with fewer
    // observations weigh more (diversity), and so do cells whose skill is
    // unknown, weak or due for review.
    final seen = _seenLemmas(trial.primarySkill, skills);
    final now = DateTime.now();
    final weights = [for (final e in fresh) (seen.contains(e.noun.id) ? 1.0 : 2.0) * selectionWeight(skills[e.form.analysis.skillId], cfg, now)];
    NounPoolEntry? chosen;
    Set<String>? chosenCorrect;
    NounPoolEntry? fallback;
    Set<String>? fallbackCorrect;
    for (var attempt = 0; attempt < 16; attempt++) {
      final e = weightedPick(fresh, weights, rng);
      final correct = _correctValues(dim, e);
      if (correct.isEmpty) continue;
      final offeredCorrect = offered == null ? correct : correct.intersection(offered);
      final wrongAvailable = offered == null ? _hasDistractor(dim, e, correct) : offered.difference(correct).isNotEmpty;
      if (offeredCorrect.isEmpty || !wrongAvailable) continue;
      if (offeredCorrect.length == 1) {
        chosen = e;
        chosenCorrect = correct;
        break;
      }
      if (fallback == null || offeredCorrect.length < fallbackCorrect!.intersection(offered ?? correct).length) {
        fallback = e;
        fallbackCorrect = correct;
      }
    }
    chosen ??= fallback;
    if (chosen == null) return null;
    final correct = chosenCorrect ?? fallbackCorrect!;
    final e = chosen;

    final choices = _buildChoices(dim, e, correct, offered, rng);
    if (choices.length < 2) return null;
    final ambiguous = choices.where((c) => correct.contains(c.value)).length > 1;

    return Question(
      id: id,
      trialId: trial.id,
      dimension: dim,
      prompt: dim.prompt,
      surface: e.form.surface,
      lemmaId: e.noun.id,
      payload: NounQuestionPayload(target: e.form, analyses: analyzer.analyze(e.form.surface), noun: e.noun),
      choices: choices,
      correctValues: correct,
      skillIds: _skillIds(trial, dim, e),
      componentId: e.componentId,
      ambiguous: ambiguous,
      context: _context(trial, dim, e),
    );
  }

  /// Every value of [dim] among all analyses of the surface (all lemmas).
  Set<String> _correctValues(Dimension dim, NounPoolEntry e) {
    final out = <String>{};
    for (final f in analyzer.analyze(e.form.surface)) {
      if (dim == Dimension.analysis && f.analysis.lemmaId != e.noun.id) continue;
      final v = valueOf(dim, f.analysis);
      if (v != null) out.add(v);
    }
    return out;
  }

  bool _hasDistractor(Dimension dim, NounPoolEntry e, Set<String> correct) {
    final p = analyzer.paradigmOf(e.noun.id);
    return p.selectors.any((s) => !correct.contains(s));
  }

  List<Choice> _buildChoices(Dimension dim, NounPoolEntry e, Set<String> correct, Set<String>? offered, Random rng) {
    List<String> values;
    if (dim == Dimension.analysis) {
      // Neighbours: other cells of the same noun, same number first.
      final a = e.form.analysis;
      final p = analyzer.paradigmOf(e.noun.id);
      final others = p.selectors.where((s) => !correct.contains(s)).toList()..shuffle(rng);
      others.sort((x, y) {
        int score(String s) => s.endsWith('.${a.number.key}') ? -1 : 0;
        return score(x).compareTo(score(y));
      });
      values = [...correct, ...others.take(max(1, 4 - correct.length))];
    } else {
      final off = offered!;
      final correctOffered = correct.intersection(off).toList();
      final others = off.difference(correct).toList()..shuffle(rng);
      final maxChoices = switch (dim) {
        Dimension.numerus => 2,
        Dimension.declinatio => 5,
        _ => 4,
      };
      final need = maxChoices - correctOffered.length;
      values = [...correctOffered, ...others.take(need < 1 ? 1 : need)];
    }
    values.sort((x, y) => _canonicalIndex(dim, x).compareTo(_canonicalIndex(dim, y)));
    return [for (final v in values) Choice(v, labelOf(dim, v))];
  }

  /// Skills credited: the cell the form belongs to (`d.1.acc.sg`, or `d.loc`),
  /// preceded in Mixta trials by the discrimination skill. A declension
  /// question tests no cell and credits the discrimination skill only.
  List<String> _skillIds(Trial trial, Dimension dim, NounPoolEntry e) {
    final cell = e.form.analysis.skillId;
    final out = <String>[];
    if (trial.isMixta) out.add(trial.primarySkill);
    if (dim != Dimension.declinatio && Skills.maybe(cell) != null) out.add(cell);
    if (out.isEmpty) out.add(trial.primarySkill);
    return out;
  }

  /// Dictionary entry under the form. Shown in introductory trials; in
  /// declension questions only when the ending alone is shared by several
  /// declensions, so recognition never rests on guessing an ambiguous ending.
  List<String> _context(Trial trial, Dimension dim, NounPoolEntry e) {
    if (dim == Dimension.declinatio) {
      return _endingIsShared(e) ? ['${e.noun.lemma}, ${e.noun.genitive}'] : const [];
    }
    return trial.showDictionaryEntry ? [e.noun.dictionaryEntry] : const [];
  }

  bool _endingIsShared(NounPoolEntry e) {
    final decls = _endingDeclensions ??= _computeEndingDeclensions();
    final ending = _endingOf(e.form);
    if (ending == null) return true;
    return (decls[ending]?.length ?? 0) > 1;
  }

  Map<String, Set<Declension>> _computeEndingDeclensions() {
    final m = <String, Set<Declension>>{};
    for (final p in analyzer.paradigms) {
      for (final f in p.forms) {
        if (!f.isPrimary) continue;
        final ending = _endingOf(f);
        if (ending != null) (m[ending] ??= {}).add(p.noun.declension);
      }
    }
    return m;
  }

  String? _endingOf(NounForm f) {
    final noun = analyzer.noun(f.analysis.lemmaId);
    return DeclensionHelp(analyzer.paradigmOf(noun.id)).segment(f)?.ending;
  }

  // ----- mastery helpers ------------------------------------------------------------

  /// Tier of a (possibly aggregate) skill: lowest tier among evaluated leaves.
  MasteryTier _aggregateTier(String skillId, Map<String, SkillRecord> skills, MasteryConfig cfg) {
    MasteryTier? lowest;
    for (final id in Skills.leaves(skillId)) {
      final r = skills[id];
      if (r == null || r.autonomousCount == 0) continue;
      final t = r.tier(cfg);
      if (lowest == null || t.index < lowest.index) lowest = t;
    }
    return lowest ?? MasteryTier.nova;
  }

  Set<String> _seenLemmas(String skillId, Map<String, SkillRecord> skills) {
    final out = <String>{};
    for (final id in Skills.leaves(skillId)) {
      out.addAll(skills[id]?.lemmas ?? const {});
    }
    return out;
  }

  // ----- corrections ------------------------------------------------------------

  /// Form of the same noun matching the chosen (wrong) value.
  NounForm? contrastForm(Question q, String chosenValue) {
    final a = q.noun.target.analysis;
    final p = analyzer.paradigmOf(q.lemmaId);
    return switch (q.dimension) {
      Dimension.casus => p.primary('$chosenValue.${a.number.key}'),
      Dimension.numerus => p.primary('${a.casus.key}.$chosenValue'),
      Dimension.analysis => p.primary(chosenValue),
      _ => null,
    };
  }

  @override
  Explanation explain({required Question q, required String chosenValue, required bool correct}) {
    final a = q.noun.target.analysis;
    final noun = q.noun.noun;
    final help = DeclensionHelp(analyzer.paradigmOf(noun.id));
    final headline = '${q.surface} — ${a.describe()} (${noun.dictionaryEntry})';
    final others = q.noun.analyses
        .where((f) => f.analysis != a && (f.analysis.lemmaId != a.lemmaId || f.analysis.selector != a.selector))
        .map((f) => '${f.analysis.describe()} (${analyzer.noun(f.analysis.lemmaId).lemma})')
        .toSet()
        .toList();
    final why = _why(q, help);
    if (correct) {
      return Explanation(headline: headline, detail: q.ambiguous ? 'Rēctē: plūrēs analysēs lēgitimae sunt.' : why, also: others);
    }
    final chosenLabel = q.choices.firstWhere((c) => c.value == chosenValue, orElse: () => Choice(chosenValue, chosenValue)).label;
    final correctLabels = q.choices.where((c) => q.correctValues.contains(c.value)).map((c) => c.label).join(' aut ');
    final contrast = contrastForm(q, chosenValue);
    var detail = 'Rēctum: $correctLabels. Tū dīxistī: $chosenLabel.';
    if (contrast != null && contrast.surface != q.surface) detail += ' Fōrma "$chosenLabel" esset: ${contrast.surface}.';
    if (why.isNotEmpty) detail += ' $why';
    return Explanation(headline: headline, detail: detail, contrastSurface: contrast?.surface, also: others);
  }

  static const _declGen = ['prīmae', 'secundae', 'tertiae', 'quārtae', 'quīntae'];

  /// One-sentence rule of thumb, with the ending when the form really is
  /// stem + ending.
  String _why(Question q, DeclensionHelp help) {
    final a = q.noun.target.analysis;
    final noun = q.noun.noun;
    final ending = help.ending(q.noun.target);
    final decl = _declGen[a.declension.index];
    // A bare nominative (rēx, senātor) is no irregularity: the stem shows in the genitive.
    final bare = a.number == Numerus.singularis && (a.casus == Casus.nominativus || a.casus == Casus.vocativus);
    final noEnding = bare ? 'Nōminātīvus singulāris sine dēsinentiā; thema ${noun.stem}- ē genetīvō ${noun.genitive} cognōscitur.' : 'Fōrma irregulāris: thema ${noun.stem}- ē genetīvō ${noun.genitive} cognōscitur.';
    switch (q.dimension) {
      case Dimension.casus:
      case Dimension.analysis:
        if (ending == null) return noEnding;
        return 'Dēsinentia $ending: ${a.describeCell()} $decl dēclīnātiōnis.';
      case Dimension.numerus:
        if (ending == null) return '$noEnding Numerus: ${a.number.latin.toLowerCase()}.';
        return 'Dēsinentia $ending: ${a.number.latin.toLowerCase()}.';
      case Dimension.declinatio:
        final genEnding = help.ending(help.paradigm.primary(noun.pluralOnly ? 'gen.pl' : 'gen.sg') ?? q.noun.target);
        return 'Genetīvus ${noun.genitive}${genEnding == null ? '' : ' ($genEnding)'} ${a.declension.latin.toLowerCase()}m dēclīnātiōnem ostendit.';
      default:
        return '';
    }
  }
}
