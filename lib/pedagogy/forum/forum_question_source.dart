/// Builds Forum questions from the nominal lexicon (isolated forms) and the
/// authored contextual items (syntagmata).
///
/// Rules:
/// * an isolated surface accepts every reading of its word class in the
///   lexicon (`rosae` is genitive, dative, nominative plural and vocative
///   plural at once; `bonae` likewise); when the dictionary entry is shown the
///   readings of that lemma only;
/// * a contextual item accepts exactly the reading its context imposes:
///   `rosae {spīnae}` is nominative plural, nothing else — that is the point;
/// * a question is never asked when every offered choice would be correct;
///   forms with a single correct offered answer are preferred;
/// * a dimension fixed by the trial (the declension in a first-declension
///   card) is never asked, except on a fixed grid (`fixedChoices`), where the
///   whole case scale is always offered;
/// * `Trial.chain` asks two questions in order on the same item (the relative:
///   gender and number from the antecedent, then the case from the function);
/// * Mixta questions credit the discrimination skill, then the component's
///   skill; noun forms also credit their paradigm cell (`d.1.acc.sg`).
library;

import 'dart:math';

import '../../arbor/cellae.dart';
import '../../arbor/diagnosis.dart' show Diagnostician;
import '../../linguistics/engine/nominal_analyzer.dart';
import '../../linguistics/help/declension_help.dart';
import '../../linguistics/help/nominal_help.dart';
import '../../linguistics/lexicon/pronouns.dart' show kCorrelativa;
import '../../linguistics/model/adjective.dart';
import '../../linguistics/model/grammar.dart';
import '../../linguistics/model/nominal.dart';
import '../../linguistics/model/noun.dart';
import '../../linguistics/model/numeral.dart';
import '../../linguistics/model/pronoun.dart';
import '../mastery.dart';
import '../question.dart';
import '../skills.dart';
import '../trial.dart';
import '../target_question_cache.dart';
import 'forum_filters.dart';
import 'syntagma.dart';

/// Forum-specific detail of a question.
class ForumQuestionPayload extends QuestionPayload {
  const ForumQuestionPayload({required this.target, required this.analyses, required this.lexeme, this.syntagma});

  /// The reading the question was drawn for.
  final NominalForm target;

  /// Every reading of the surface in the nominal lexicon (all classes).
  final List<NominalForm> analyses;
  final Lexeme lexeme;

  /// The contextual item, when the question comes from one.
  final Syntagma? syntagma;
}

extension ForumQuestion on Question {
  /// The Forum payload; only valid for Forum questions.
  ForumQuestionPayload get forum => payload as ForumQuestionPayload;
}

/// One drawable item: an isolated form or a contextual item, with the
/// component it came from.
class ForumItem {
  const ForumItem(this.lexeme, this.form, {this.syntagma, this.componentId});
  final Lexeme lexeme;
  final NominalForm form;
  final Syntagma? syntagma;
  final String? componentId;

  String get surface => form.surface;
  NominalAnalysis get analysis => form.analysis;
  bool get isContextual => syntagma != null;

  /// Key of this form in the error ledger (`d|rosa|nom.pl`).
  String get formKey => 'd|${lexeme.id}|${analysis.selector}';

  /// Key of the paradigm cell across lemmas (`d|1|nom.pl` for nouns,
  /// `d|a|acc.sg.m` for adjectives).
  String get cellKey {
    final a = analysis;
    if (a.wordClass == WordClass.nomen && a.declension != null) return 'd|${a.declension!.ordinal}|${a.selector}';
    return 'd|${a.wordClass.key}|${a.selector}';
  }
}

class ForumQuestionSource implements QuestionSource {
  ForumQuestionSource(this.analyzer, this.syntagmata);
  final NominalAnalyzer analyzer;
  final List<Syntagma> syntagmata;

  final Map<String, List<ForumItem>> _pools = {};
  final _targetQuestions = TargetQuestionCache();
  final Map<String, Map<Dimension, Set<String>>> _poolValues = {};
  final Map<String, List<Set<String>>> _contextDeclensions = {};
  List<ForumItem>? _nominalContrasts;
  Map<String, Set<Declension>>? _endingDeclensions;

  static const _valueDimensions = [
    Dimension.casus,
    Dimension.numerus,
    Dimension.genus,
    Dimension.genusNumerus,
    Dimension.declinatio,
    Dimension.thema,
    Dimension.classis,
    Dimension.gradus,
    Dimension.lemma,
    Dimension.persona,
    Dimension.functio,
    Dimension.constructio,
    Dimension.relatio,
    Dimension.quodNomen,
    Dimension.correlativum,
    Dimension.valor,
    Dimension.forma,
    Dimension.productio,
  ];

  // ----- pool ------------------------------------------------------------------

  String _poolKey(Trial t, List<String> componentIds) => '${t.id}|${(componentIds.toList()..sort()).join(',')}';

  List<ForumItem> pool(Trial t, List<String> componentIds) => _pools[_poolKey(t, componentIds)] ??= _buildPool(t, componentIds);

  List<ForumItem> _buildPool(Trial t, List<String> componentIds) {
    final out = <ForumItem>[];
    final comps = t.isMixta ? t.components.where((c) => componentIds.contains(c.id)).toList() : const <TrialComponent>[];
    if (comps.isEmpty) {
      _collect(t.filter as ForumFilter, null, out);
    } else {
      for (final c in comps) {
        _collect(c.filter as ForumFilter, c.id, out);
      }
    }
    return out;
  }

  void _collect(ForumFilter filter, String? componentId, List<ForumItem> out) {
    if (filter.hasForms) {
      for (final l in analyzer.lexemes) {
        if (!filter.matchesLexeme(l)) continue;
        for (final f in analyzer.formsOf(l.id)) {
          if (filter.matchesForm(l, f)) out.add(ForumItem(l, f, componentId: componentId));
        }
      }
    }
    final sf = filter.syntagmata;
    if (sf != null) {
      for (final s in syntagmata) {
        if (!sf.matches(s)) continue;
        final item = itemOf(s, componentId: componentId);
        if (item != null) out.add(item);
      }
    }
  }

  /// The pool item of a contextual item, or null when its target surface has
  /// no such reading in the lexicon (invalid item; tests reject those).
  ForumItem? itemOf(Syntagma s, {String? componentId}) {
    final lex = analyzer.maybeLexeme(s.lemmaId);
    if (lex == null) return null;
    final form = readingOf(s);
    if (form == null) return null;
    // The question shows the phrase's own spelling (capital included).
    final shown = form.surface == s.target ? form : NominalForm(s.target, form.analysis);
    return ForumItem(lex, shown, syntagma: s, componentId: componentId);
  }

  /// The lexicon reading matching the declared analysis of [s], or null.
  ///
  /// A target that opens the phrase is capitalised in Latin (`Quis clāmat?`);
  /// the lexicon holds the lower-case form, so the first letter is folded
  /// before the lookup — except for a proper name, which is capitalised in
  /// the lexicon too.
  NominalForm? readingOf(Syntagma s) {
    final lex = analyzer.maybeLexeme(s.lemmaId);
    if (lex == null) return null;
    final candidates = analyzer.analyzeAs(lexiconTarget(s), s.lemmaId).where((f) {
      final a = f.analysis;
      if (a.casus != s.casus || a.number != s.number || a.degree != s.degree) return false;
      if (s.gender != null && a.gender != null && a.gender != s.gender) return false;
      return true;
    }).toList();
    if (candidates.isEmpty) return null;
    // Prefer the primary reading of the declared gender.
    candidates.sort((x, y) {
      int score(NominalForm f) => (f.isPrimary ? 0 : 2) + (s.gender != null && f.analysis.gender == s.gender ? 0 : 1);
      return score(x).compareTo(score(y));
    });
    return candidates.first;
  }

  /// The target of [s] as the lexicon spells it. A target that opens the
  /// phrase carries a Latin sentence capital (`Quis clāmat?`); the lexicon
  /// holds `quis`. A proper name (Mārcus, Rōma) is capitalised in the lexicon
  /// too, so the spelling as written is tried first and the fold is only a
  /// fallback.
  String lexiconTarget(Syntagma s) {
    final t = s.target;
    if (t.isEmpty || analyzer.analyzeAs(t, s.lemmaId).isNotEmpty) return t;
    return '${t[0].toLowerCase()}${t.substring(1)}';
  }

  /// Distinct values of each dimension within the pool.
  Map<Dimension, Set<String>> poolValues(Trial t, List<String> componentIds) => _poolValues[_poolKey(t, componentIds)] ??= _computeValues(pool(t, componentIds));

  Map<Dimension, Set<String>> _computeValues(List<ForumItem> items) {
    final m = <Dimension, Set<String>>{};
    for (final d in _valueDimensions) {
      final s = <String>{};
      for (final e in items) {
        final v = valueOf(d, e);
        if (v != null) s.add(v);
      }
      m[d] = s;
    }
    return m;
  }

  // ----- dimension values ---------------------------------------------------------

  String? valueOf(Dimension d, ForumItem e) {
    final a = e.analysis;
    final l = e.lexeme;
    final s = e.syntagma;
    switch (d) {
      case Dimension.casus:
        return a.casus?.key;
      case Dimension.numerus:
        return a.number?.key;
      case Dimension.genus:
        return a.gender?.key;
      case Dimension.genusNumerus:
        return a.gender == null || a.number == null ? null : '${a.gender!.key}.${a.number!.key}';
      case Dimension.declinatio:
        return a.declension?.key;
      case Dimension.thema:
        return l is NounEntry ? nounStemType(l) : null;
      case Dimension.classis:
        return l is AdjectiveEntry ? (l.pronominal ? 'pron' : l.cls.key) : null;
      case Dimension.gradus:
        return (a.wordClass == WordClass.adiectivum || a.wordClass == WordClass.adverbium) ? a.degree.key : null;
      case Dimension.lemma:
        return l.id;
      case Dimension.persona:
        return a.person?.key;
      case Dimension.functio:
        return s?.functio?.key;
      case Dimension.constructio:
        return s?.constructio?.key;
      case Dimension.relatio:
        return s?.relatio?.key;
      case Dimension.quodNomen:
        return s?.head;
      case Dimension.correlativum:
        return kCorrelativa[l.id];
      case Dimension.valor:
        if (l is NumeralEntry) return '${l.value}';
        if (l is AdjectiveEntry && l.ordinalValue != null) return '${l.ordinalValue}';
        if (l.id == 'unus') return '1';
        return null;
      case Dimension.forma:
        return _formaOf(l);
      case Dimension.analysis:
        return a.selector;
      case Dimension.productio:
        return s == null ? null : e.surface;
      default:
        return null;
    }
  }

  static String? _formaOf(Lexeme l) {
    if (l is NumeralEntry) return l.isIndeclinable ? 'indeclinabile' : 'declinabile';
    if (l is PronounEntry) return l.kind.name;
    if (l is AdjectiveEntry) return l.tags.contains('numerale') && l.id == 'unus' ? 'declinabile' : 'adiectivum';
    return switch (l.wordClass) {
      WordClass.adverbium => 'adverbium',
      WordClass.nomen => 'nomen',
      _ => null,
    };
  }

  static const _themeLabels = {
    'd1': 'Prīma · rosa',
    'd2.us': 'Secunda · servus',
    'd2.er': 'Secunda · puer, ager',
    'd2.ius': 'Secunda · fīlius',
    'd2.n': 'Secunda · neutra (bellum)',
    'd3.cons': 'Tertia · cōnsonāns (rēx)',
    'd3.i': 'Tertia · in -i- (cīvis)',
    'd3.ipura': 'Tertia · in -i- pūrum (turris)',
    'd3.n': 'Tertia · neutra cōnsonantia (corpus)',
    'd3.ni': 'Tertia · neutra in -i- (mare)',
    'd4.m': 'Quārta · manus',
    'd4.n': 'Quārta · neutra (cornū)',
    'd5': 'Quīnta · rēs',
  };

  String labelOf(Dimension d, String v, {ForumItem? item}) {
    switch (d) {
      case Dimension.casus:
        return Casus.fromKey(v).latin;
      case Dimension.numerus:
        return Numerus.fromKey(v).latin;
      case Dimension.genus:
        return Gender.fromKey(v).latin;
      case Dimension.genusNumerus:
        final p = v.split('.');
        return '${Gender.fromKey(p[0]).latin} ${Numerus.fromKey(p[1]).latin.toLowerCase()}';
      case Dimension.declinatio:
        return '${Declension.fromKey(v).latin} dēclīnātiō';
      case Dimension.thema:
        return _themeLabels[v] ?? v;
      case Dimension.classis:
        return switch (v) { '12' => 'Prīma et secunda classis', '3' => 'Tertia classis', _ => 'Prōnōmināle (-īus, -ī)' };
      case Dimension.gradus:
        return Degree.fromKey(v).latin;
      case Dimension.lemma:
      case Dimension.correlativum:
        return analyzer.maybeLexeme(v)?.lemma ?? v;
      case Dimension.persona:
        return '${Person.fromKey(v).latin} persōna';
      case Dimension.functio:
        return Functio.fromKey(v).latin;
      case Dimension.constructio:
        return Constructio.fromKey(v).latin;
      case Dimension.relatio:
        return Relatio.fromKey(v).latin;
      case Dimension.quodNomen:
        return item?.syntagma == null ? (analyzer.maybeLexeme(v)?.lemma ?? v) : _surfaceOfHead(item!.syntagma!, v);
      case Dimension.valor:
        return romanNumeral(int.parse(v));
      case Dimension.forma:
        return switch (v) {
          'declinabile' => 'Dēclīnābile',
          'indeclinabile' => 'Indēclīnābile',
          'relativum' => 'Relātīvum (quī, quae, quod)',
          'interrogativum' => 'Interrogātīvum (quis, quid)',
          'indefinitum' => 'Indēfīnītum',
          'personale' => 'Persōnāle',
          'reflexivum' => 'Reflexīvum',
          'demonstrativum' => 'Dēmōnstrātīvum',
          'correlativum' => 'Correlātīvum',
          'adverbium' => 'Adverbium',
          'adiectivum' => 'Adiectīvum',
          'nomen' => 'Nōmen',
          _ => v,
        };
      case Dimension.analysis:
        return analysisLabel(v);
      case Dimension.productio:
        return v;
      default:
        return v;
    }
  }

  /// The surface in the phrase of the candidate whose lemma is [lemmaId].
  String _surfaceOfHead(Syntagma s, String lemmaId) {
    if (s.head == lemmaId && s.headSurface != null) return s.headSurface!;
    final surfaces = s.candidateSurfaces;
    for (var i = 0; i < s.candidates.length && i < surfaces.length; i++) {
      if (s.candidates[i] == lemmaId) return surfaces[i];
    }
    return analyzer.maybeLexeme(lemmaId)?.lemma ?? lemmaId;
  }

  /// `accūsātīvus singulāris masculīnum` from a selector.
  static String analysisLabel(String selector) {
    final p = parseSelector(selector);
    final b = <String>[];
    if (p.degree != Degree.positivus) b.add(p.degree.latin.toLowerCase());
    if (p.casus != null && p.number != null) b.add('${p.casus!.latin.toLowerCase()} ${p.number!.latin.toLowerCase()}');
    if (p.gender != null) b.add(p.gender!.latin.toLowerCase());
    return b.isEmpty ? 'indēclīnābile' : b.join(' ');
  }

  int _canonicalIndex(Dimension d, String v) {
    switch (d) {
      case Dimension.casus:
        return Casus.fromKey(v).index;
      case Dimension.numerus:
        return Numerus.fromKey(v).index;
      case Dimension.genus:
        return Gender.fromKey(v).index;
      case Dimension.genusNumerus:
        final p = v.split('.');
        return Numerus.fromKey(p[1]).index * 10 + Gender.fromKey(p[0]).index;
      case Dimension.declinatio:
        return Declension.fromKey(v).index;
      case Dimension.thema:
        return _themeLabels.keys.toList().indexOf(v);
      case Dimension.classis:
        return ['12', '3', 'pron'].indexOf(v);
      case Dimension.gradus:
        return Degree.fromKey(v).index;
      case Dimension.persona:
        return Person.fromKey(v).index;
      case Dimension.functio:
        return Functio.fromKey(v).index;
      case Dimension.constructio:
        return Constructio.fromKey(v).index;
      case Dimension.relatio:
        return Relatio.fromKey(v).index;
      case Dimension.valor:
        return int.parse(v);
      case Dimension.analysis:
        final p = parseSelector(v);
        return p.degree.index * 1000 + (p.number?.index ?? 0) * 100 + (p.casus?.index ?? 0) * 10 + (p.gender?.index ?? 0);
      default:
        return 0;
    }
  }

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
    Recall recall = Recall.none,
    ArborNeeds? needs,
  }) {
    if (needs?.credit != null && needs!.focus.isNotEmpty) {
      for (final target in needs.targets(trial.activity.key)) {
        final q = forTarget(trial: trial, componentIds: componentIds, target: target, rng: rng, id: id,
          recentQuestions: needs.recentQuestions,
          proves: (q) => needs.credit!(q).contains(target), recentLemmas: recentLemmas, recentSurfaces: recentSurfaces, seenLemmas: needs.evidence.of(target).lemmas, dimensions: ArborNeeds.dimensionsFor(needs.arbor, target), canPresent: needs.canPresent,
          constrain: needs.contrast == null ? null : (q) => needs.constrain(q, needs.contrast!), eligibilityKey: needs.questionCacheKey);
        if (q != null) return q;
      }
      return null;
    }
    final items = pool(trial, componentIds);
    if (items.isEmpty) return null;
    final values = poolValues(trial, componentIds);
    final tier = _aggregateTier(trial.primarySkill, skills, cfg);

    // Eligible dimensions: at least two offered values, and some item of the
    // pool with a non-trivial answer. Full analysis waits for familiarity.
    final dims = <Dimension>[];
    for (final d in trial.dimensions) {
      if (trial.chain.isNotEmpty && trial.chain.contains(d) && d != trial.chain.first) continue;
      if (d == Dimension.analysis) {
        if (tier.index >= MasteryTier.familiaris.index) dims.add(d);
        continue;
      }
      if (_offered(trial, d, values).length >= 2) dims.add(d);
    }
    if (dims.isEmpty) return null;
    final dim = weightedPick(dims, [for (final d in dims) d == Dimension.numerus ? 0.8 : (trial.chain.isNotEmpty && d == trial.chain.first ? 2.0 : 1.0)], rng);
    final offered = dim == Dimension.analysis || dim == Dimension.productio ? null : _offered(trial, dim, values);

    // Candidates avoiding recent lemmas and surfaces, applicable to the dimension.
    final applicable = items.where((e) => valueOf(dim, e) != null).toList();
    if (applicable.isEmpty) return null;
    var fresh = applicable.where((e) => !recentLemmas.contains(e.lexeme.id) && !recentSurfaces.contains(e.surface)).toList();
    if (fresh.length < 4) fresh = applicable.where((e) => !recentSurfaces.contains(e.surface)).toList();
    if (fresh.isEmpty) fresh = applicable;

    final seen = _seenLemmas(trial.primarySkill, skills);
    final now = DateTime.now();
    final weights = [
      for (final e in fresh) (seen.contains(e.lexeme.id) ? 1.0 : 2.0) * selectionWeight(skills[_cellSkill(e) ?? trial.primarySkill], cfg, now) * recall.boost(e.formKey, e.cellKey) * (needs?.nominal(e.form, e.lexeme) ?? 1.0),
    ];
    ForumItem? chosen;
    Set<String>? chosenCorrect;
    ForumItem? fallback;
    Set<String>? fallbackCorrect;
    var fallbackScore = 1 << 30;
    for (var attempt = 0; attempt < 24; attempt++) {
      final e = weightedPick(fresh, weights, rng);
      final correct = correctValues(trial, dim, e);
      if (correct.isEmpty) continue;
      final off = offered ?? _offeredFor(dim, e, correct);
      final offeredCorrect = correct.intersection(off);
      if (offeredCorrect.isEmpty || off.difference(correct).isEmpty) continue;
      if (offeredCorrect.length == 1) {
        chosen = e;
        chosenCorrect = correct;
        break;
      }
      if (offeredCorrect.length < fallbackScore) {
        fallback = e;
        fallbackCorrect = correct;
        fallbackScore = offeredCorrect.length;
      }
    }
    chosen ??= fallback;
    if (chosen == null) return null;
    final e = chosen;
    final correct = chosenCorrect ?? fallbackCorrect!;
    final q = _build(trial, dim, e, correct, offered, rng, id, skills: skills, cfg: cfg);
    if (q == null) return null;
    if (trial.chain.length > 1 && dim == trial.chain.first) {
      final next = _chained(trial, e, trial.chain.skip(1).toList(), rng, id, values);
      if (next != null) return _withFollowUp(q, next);
    }
    return q;
  }

  /// Le maillon commande la séance, sans réduire toutes ses réponses au nom
  /// de la cible. Une dimension constante après filtrage est écartée.
  Question? forTarget({required Trial trial, required List<String> componentIds, required String target,
    required Random rng, required String id, required bool Function(Question) proves,
    List<String> recentLemmas = const [], List<String> recentSurfaces = const [], List<String> recentQuestions = const [], Set<String> seenLemmas = const {}, List<Dimension> dimensions = const [], bool Function(Iterable<String>)? canPresent, Question? Function(Question)? constrain, String? eligibilityKey}) {
    final cache = eligibilityKey != null || (canPresent == null && constrain == null) ? _targetQuestions.forExposure(eligibilityKey) : null;
    final key = '${_poolKey(trial, componentIds)}|$target|${dimensions.map((d) => d.name).join(',')}';
    if (cache?.containsKey(key) ?? false) {
      final practice = cache![key];
      if (practice == null) return null;
      if (practice.supports(proves)) {
        return practice.draw(rng: rng, id: id, proves: proves,
          recentSurfaces: recentSurfaces, recentLemmas: recentLemmas, recentQuestions: recentQuestions, seenLemmas: seenLemmas);
      }
    }
    final entries = _practiceEntries(pool(trial, componentIds), target, canPresent);
    final dims = trial.dimensions.contains(Dimension.productio) ? {Dimension.productio} : <Dimension>{
      if (target.startsWith('n.thema.') && target != 'n.thema.proprium') Dimension.thema,
      ...dimensions,
      for (final d in trial.dimensions)
        if ((Diagnostician.kDimensionFamilies[d] ?? const <String>[]).any(target.startsWith)) d,
      for (final e in Diagnostician.kDimensionFamilies.entries)
        if (e.value.any(target.startsWith) && !trial.dimensions.contains(e.key)) e.key,
      ...trial.dimensions.where((d) => d != Dimension.analysis || dimensions.contains(d)),
    };
    for (final dim in dims) {
      if (dim == Dimension.productio && !trial.dimensions.contains(dim)) continue;
      var candidates = entries;
      // Reconnaître une classe suppose de comparer les classes déjà découvertes.
      // Les contrastes de base sont disponibles dès leur découverte, sans
      // attendre les cartes Mixta tardives ni changer l'identité de la carte.
      if (target.startsWith('n.') && const {Dimension.declinatio, Dimension.thema, Dimension.genus}.contains(dim)) {
        final contrasts = _nominalContrasts ??= [
          for (final l in analyzer.lexemes.whereType<NounEntry>())
            if (!l.isProper && const {'d1', 'd2.us', 'd2.n', 'd3.cons'}.contains(nounStemType(l)))
              for (final f in analyzer.formsOf(l.id))
                if (f.isPrimary && f.analysis.casus != Casus.locativus) ForumItem(l, f),
        ];
        candidates = _practiceEntries([...entries, ...contrasts], target, canPresent);
      }
      final practice = _practice(trial, candidates, dim, proves, constrain);
      if (practice != null) {
        TargetQuestionCache.remember(cache, key, practice);
        return practice.draw(rng: rng, id: id, proves: proves,
          recentSurfaces: recentSurfaces, recentLemmas: recentLemmas, recentQuestions: recentQuestions, seenLemmas: seenLemmas);
      }
    }
    TargetQuestionCache.remember(cache, key, null);
    return null;
  }

  List<ForumItem> _practiceEntries(List<ForumItem> items, String target, bool Function(Iterable<String>)? canPresent) {
    final focused = <ForumItem>[], others = <ForumItem>[];
    for (final e in items.toList()..shuffle(Random(0))) {
      final parts = nominalComponents(e.form, e.lexeme);
      if (canPresent != null && (!canPresent(parts) || !_canPresentContext(e, canPresent))) continue;
      final s = e.syntagma;
      if (s?.functio != null) parts.add(Diagnostician.functioNode(s!.functio!.key, s));
      if (s?.constructio != null) parts.addAll(Diagnostician.constructioNodes(s!.constructio!.key));
      (parts.contains(target) ? focused : others).add(e);
    }
    return [...focused, ...others];
  }

  TargetPractice? _practice(Trial trial, List<ForumItem> entries, Dimension dim, bool Function(Question) proves, Question? Function(Question)? constrain) {
    final values = _computeValues(entries);
    final scale = dim == Dimension.analysis || dim == Dimension.productio ? null : _offered(trial, dim, values);
    if (scale != null && (values[dim]?.length ?? 0) < 2) return null;
    final builder = TargetPracticeBuilder();
    final rng = Random(0);
    for (final e in entries) {
      if (valueOf(dim, e) == null) continue;
      final correct = correctValues(trial, dim, e);
      if (correct.isEmpty || builder.full(correct)) continue;
      final offered = scale ?? _offeredFor(dim, e, correct);
      if (offered.intersection(correct).isEmpty || offered.difference(correct).isEmpty) continue;
      final q = _build(trial, dim, e, correct, scale, rng, 'practice');
      if (q != null) {
        final ready = constrain == null ? q : constrain(q);
        if (ready != null) {
          builder.add(ready, correct);
        }
      }
    }
    return builder.finish(proves);
  }

  /// Le nom en surbrillance ne suffit pas : « pater {fīliō} » contient aussi
  /// un nom de troisième déclinaison. Pour un mot ambigu, une lecture nominale
  /// déjà découverte suffit ; on ne cumule pas ses analyses possibles.
  bool _canPresentContext(ForumItem e, bool Function(Iterable<String>) canPresent) {
    final s = e.syntagma;
    if (s == null) return true;
    final words = _contextDeclensions.putIfAbsent(s.id, () {
      final out = <Set<String>>[];
      for (final token in s.words) {
        final word = token.replaceAll(RegExp(r'[.,;:!?«»"()]'), '');
        var readings = analyzer.analyze(word);
        if (readings.isEmpty) readings = analyzer.analyze(word.toLowerCase());
        if (readings.isEmpty || readings.any((f) => f.analysis.wordClass != WordClass.nomen)) continue;
        out.add({for (final f in readings) if (f.analysis.declension != null) 'not.declinatio.${f.analysis.declension!.ordinal}'});
      }
      return out;
    });
    return words.every((declensions) => declensions.isEmpty || declensions.any((d) => canPresent({d})));
  }

  /// Follow-up questions on the same item, in chain order.
  Question? _chained(Trial trial, ForumItem e, List<Dimension> rest, Random rng, String id, Map<Dimension, Set<String>> values) {
    if (rest.isEmpty) return null;
    final dim = rest.first;
    final correct = correctValues(trial, dim, e);
    if (correct.isEmpty) return null;
    final offered = dim == Dimension.analysis ? null : _offered(trial, dim, values);
    final off = offered ?? _offeredFor(dim, e, correct);
    if (off.difference(correct).isEmpty || correct.intersection(off).isEmpty) return null;
    final q = _build(trial, dim, e, correct, offered, rng, '$id-${dim.name}');
    if (q == null) return null;
    final next = _chained(trial, e, rest.skip(1).toList(), rng, id, values);
    return next == null ? q : _withFollowUp(q, next);
  }

  Question _withFollowUp(Question q, Question next) => Question(
        id: q.id,
        trialId: q.trialId,
        dimension: q.dimension,
        prompt: q.prompt,
        surface: q.surface,
        lemmaId: q.lemmaId,
        choices: q.choices,
        correctValues: q.correctValues,
        skillIds: q.skillIds,
        payload: q.payload,
        componentId: q.componentId,
        ambiguous: q.ambiguous,
        context: q.context,
        errata: q.errata,
        syntagma: q.syntagma,
        followUp: next,
      );

  Question? _build(Trial trial, Dimension dim, ForumItem e, Set<String> correct, Set<String>? offered, Random rng, String id, {Map<String, SkillRecord> skills = const {}, MasteryConfig cfg = const MasteryConfig()}) {
    final choices = _buildChoices(trial, dim, e, correct, offered, rng);
    if (choices.length < 2) return null;
    final ambiguous = choices.where((c) => correct.contains(c.value)).length > 1;
    return Question(
      id: id,
      trialId: trial.id,
      dimension: dim,
      // Préciser le rôle évite qu'un génitif rattaché au sujet soit aussi une
      // complétion possible (« servus dominī servit »).
      prompt: dim == Dimension.productio ? 'Complēmentum verbī ēlige.' : dim.prompt,
      surface: e.surface,
      lemmaId: e.lexeme.id,
      payload: ForumQuestionPayload(target: e.form, analyses: analyzer.analyze(e.surface), lexeme: e.lexeme, syntagma: e.syntagma),
      choices: choices,
      correctValues: correct,
      skillIds: _skillIds(trial, dim, e),
      componentId: e.componentId,
      ambiguous: ambiguous,
      context: _context(trial, dim, e),
      syntagma: dim == Dimension.productio ? e.syntagma!.display.replaceFirst('{${e.syntagma!.target}}', '{…}') : e.syntagma?.display,
      errata: ErrataNote(formKey: e.formKey, cellKey: e.cellKey, analysis: _describe(e)),
    );
  }

  /// Offered values of [d]: the fixed case scale on a fixed grid, otherwise
  /// the values present in the pool.
  Set<String> _offered(Trial trial, Dimension d, Map<Dimension, Set<String>> values) {
    final pool = values[d] ?? const <String>{};
    if (trial.fixedChoices && d == Dimension.casus) {
      return {
        Casus.nominativus.key,
        if (pool.contains(Casus.vocativus.key)) Casus.vocativus.key,
        Casus.accusativus.key,
        Casus.genetivus.key,
        Casus.dativus.key,
        Casus.ablativus.key,
        if (pool.contains(Casus.locativus.key)) Casus.locativus.key,
      };
    }
    if (d == Dimension.quodNomen) {
      // Candidates differ per item; eligibility only needs some item with
      // at least two candidate nouns.
      return pool.isNotEmpty ? {...pool, '*'} : pool;
    }
    return pool;
  }

  /// Item-specific offered set for dimensions without a pool-wide scale.
  Set<String> _offeredFor(Dimension d, ForumItem e, Set<String> correct) {
    switch (d) {
      case Dimension.analysis:
        return analyzer.formsOf(e.lexeme.id).map((f) => f.analysis.selector).toSet();
      case Dimension.productio:
        return _productionForms(e).map((f) => f.surface).toSet();
      case Dimension.quodNomen:
        final s = e.syntagma;
        if (s == null) return correct;
        return {...s.candidates, if (s.head != null) s.head!};
      default:
        return correct;
    }
  }

  /// Every value of [dim] accepted for [e].
  Set<String> correctValues(Trial trial, Dimension dim, ForumItem e) {
    final s = e.syntagma;
    if (s != null) {
      if (dim == Dimension.productio) {
        return {e.surface, for (final f in _productionForms(e)) if (f.analysis.casus == e.analysis.casus) f.surface};
      }
      // The context imposes one reading. Vocative and nominative share their
      // form; a declared nominative also accepts the vocative only when the
      // phrase is an address (authored as vocative), so nothing is added.
      final v = valueOf(dim, e);
      return v == null ? const {} : {v};
    }
    if (dim == Dimension.quodNomen) return const {};
    final sameLemmaOnly = dim == Dimension.analysis || dim == Dimension.thema || trial.showDictionaryEntry || dim == Dimension.valor || dim == Dimension.correlativum;
    final out = <String>{};
    for (final f in analyzer.analyze(e.surface)) {
      final a = f.analysis;
      if (sameLemmaOnly && a.lemmaId != e.lexeme.id) continue;
      if (a.wordClass != e.analysis.wordClass) continue;
      final lex = analyzer.lexeme(a.lemmaId);
      final v = valueOf(dim, ForumItem(lex, f));
      if (v != null) out.add(v);
    }
    if (dim == Dimension.lemma) {
      // Only lemmas of the trial's own pool are legitimate alternatives.
      final poolIds = _poolLemmaIds(trial);
      out.retainWhere((v) => v == e.lexeme.id || poolIds.contains(v));
    }
    return out;
  }

  final Map<String, Set<String>> _poolLemmaCache = {};
  Set<String> _poolLemmaIds(Trial t) => _poolLemmaCache[t.id] ??= {
        for (final e in pool(t, t.components.map((c) => c.id).toList())) e.lexeme.id,
      };

  List<Choice> _buildChoices(Trial trial, Dimension dim, ForumItem e, Set<String> correct, Set<String>? offered, Random rng) {
    List<String> values;
    switch (dim) {
      case Dimension.productio:
        final forms = _productionForms(e);
        final others = forms.map((f) => f.surface).where((s) => !correct.contains(s)).toSet().toList()..shuffle(rng);
        // Garder le contraste de régime avant les autres distracteurs.
        final contrast = e.analysis.casus == Casus.accusativus ? Casus.dativus : Casus.accusativus;
        final contrasting = {for (final f in forms) if (f.analysis.casus == contrast) f.surface};
        others.sort((a, b) => (contrasting.contains(a) ? 0 : 1).compareTo(contrasting.contains(b) ? 0 : 1));
        values = [...correct, ...others.take(max(1, 4 - correct.length))]..shuffle(rng);
        return [for (final v in values) Choice(v, v)];
      case Dimension.analysis:
        final a = e.analysis;
        final others = analyzer.formsOf(e.lexeme.id).map((f) => f.analysis.selector).where((s) => !correct.contains(s)).toSet().toList()..shuffle(rng);
        others.sort((x, y) {
          int score(String s) {
            final p = parseSelector(s);
            var sc = 0;
            if (p.number == a.number) sc -= 2;
            if (p.gender == a.gender) sc -= 1;
            if (p.degree == a.degree) sc -= 4;
            return sc;
          }
          return score(x).compareTo(score(y));
        });
        values = [...correct.take(2), ...others.take(max(1, 4 - min(2, correct.length)))];
      case Dimension.quodNomen:
        final s = e.syntagma!;
        values = [...s.candidates, if (s.head != null && !s.candidates.contains(s.head)) s.head!];
        // Keep the text order of the candidates.
        final order = <String, int>{};
        final surfaces = s.candidateSurfaces;
        for (var i = 0; i < s.candidates.length; i++) {
          order[s.candidates[i]] = s.text.indexOf('<${i < surfaces.length ? surfaces[i] : ''}>');
        }
        if (s.head != null) order[s.head!] = s.text.indexOf('[');
        values.sort((x, y) => (order[x] ?? 0).compareTo(order[y] ?? 0));
        return [for (final v in values) Choice(v, labelOf(dim, v, item: e))];
      case Dimension.lemma:
        final off = offered!;
        final others = off.where((v) => !correct.contains(v)).toList()..shuffle(rng);
        others.sort((x, y) {
          int score(String id) {
            final l = analyzer.maybeLexeme(id);
            if (l == null) return 0;
            var sc = l.wordClass == e.lexeme.wordClass ? -2 : 0;
            if (l is PronounEntry && e.lexeme is PronounEntry && l.kind == (e.lexeme as PronounEntry).kind) sc -= 1;
            if (l is AdjectiveEntry && e.lexeme is AdjectiveEntry && l.cls == (e.lexeme as AdjectiveEntry).cls) sc -= 1;
            return sc;
          }
          return score(x).compareTo(score(y));
        });
        values = [...correct.take(2), ...others.take(4 - min(2, correct.length))];
        values.shuffle(rng);
        return [for (final v in values) Choice(v, labelOf(dim, v))];
      case Dimension.correlativum:
        final off = offered!;
        final others = off.where((v) => !correct.contains(v)).toList()..shuffle(rng);
        values = [...correct.take(1), ...others.take(3)];
        values.shuffle(rng);
        return [for (final v in values) Choice(v, labelOf(dim, v))];
      case Dimension.valor:
        final off = offered!;
        final target = int.parse(correct.first);
        final others = off.where((v) => !correct.contains(v)).toList()..sort((x, y) => (int.parse(x) - target).abs().compareTo((int.parse(y) - target).abs()));
        // Two nearest values and one random, so the scale is not always adjacent.
        final picked = <String>[...others.take(2)];
        final rest = others.skip(2).toList()..shuffle(rng);
        if (rest.isNotEmpty) picked.add(rest.first);
        values = [...correct.take(1), ...picked];
      case Dimension.genusNumerus:
        final off = offered!;
        final a = e.analysis;
        final others = off.where((v) => !correct.contains(v)).toList()..shuffle(rng);
        others.sort((x, y) {
          int score(String v) {
            final p = v.split('.');
            return (p[1] == a.number?.key ? -2 : 0) + (p[0] == a.gender?.key ? -1 : 0);
          }
          return score(x).compareTo(score(y));
        });
        values = [...correct, ...others.take(max(1, 4 - correct.length))];
      default:
        final off = offered!;
        final correctOffered = correct.intersection(off).toList();
        final others = off.difference(correct).toList()..shuffle(rng);
        if (trial.fixedChoices && dim == Dimension.casus) {
          values = off.toList();
        } else {
          final maxChoices = switch (dim) {
            Dimension.numerus => 2,
            Dimension.relatio => 2,
            Dimension.genus => 3,
            Dimension.gradus => 3,
            Dimension.persona => 3,
            Dimension.classis => 3,
            Dimension.declinatio => 5,
            _ => 4,
          };
          final need = maxChoices - correctOffered.length;
          values = [...correctOffered, ...others.take(need < 1 ? 1 : need)];
        }
    }
    values.sort((x, y) => _canonicalIndex(dim, x).compareTo(_canonicalIndex(dim, y)));
    return [for (final v in values) Choice(v, labelOf(dim, v, item: e))];
  }

  /// Même nom et même nombre : seule la flexion selon le rôle dans la phrase
  /// change. Les surfaces syncrétiques ne créent pas de boutons en double.
  List<NominalForm> _productionForms(ForumItem e) => analyzer.matching(e.lexeme.id,
    number: e.analysis.number, gender: e.analysis.gender, degree: e.analysis.degree)
    .where((f) => f.isPrimary).toList();

  /// Skills credited: the card's skill, then the component's skill in Mixta
  /// cards, then the noun cell (`d.1.acc.sg`) for noun forms.
  List<String> _skillIds(Trial trial, Dimension dim, ForumItem e) {
    final out = <String>[trial.primarySkill];
    if (e.componentId != null) {
      final c = trial.components.where((c) => c.id == e.componentId).firstOrNull;
      if (c?.skillId != null && Skills.maybe(c!.skillId!) != null) out.add(c.skillId!);
    }
    final cell = _cellSkill(e);
    if (cell != null && dim != Dimension.declinatio && dim != Dimension.thema && dim != Dimension.lemma) out.add(cell);
    return out;
  }

  String? _cellSkill(ForumItem e) {
    final id = e.analysis.nounSkillId;
    return id != null && Skills.maybe(id) != null ? id : null;
  }

  /// Dictionary entry under an isolated form when the card shows it and it
  /// does not give the answer away; in declension questions only when the
  /// ending alone is shared by several declensions.
  List<String> _context(Trial trial, Dimension dim, ForumItem e) {
    if (dim == Dimension.productio) return ['${e.lexeme.lemma} (${e.lexeme.glossFr}) · ${e.analysis.number!.latin}'];
    if (dim == Dimension.thema) {
      final genitivePlural = analyzer.primary(e.lexeme.id, 'gen.pl');
      return [e.lexeme.dictionaryEntry, if (genitivePlural != null) 'Genetīvus plūrālis: ${genitivePlural.surface}'];
    }
    if (e.isContextual) return const [];
    if (dim == Dimension.declinatio) {
      return _endingIsShared(e) ? ['${e.lexeme.lemma}, ${(e.lexeme as NounEntry).genitive}'] : const [];
    }
    const revealing = {Dimension.genus, Dimension.lemma, Dimension.classis, Dimension.valor, Dimension.correlativum, Dimension.forma, Dimension.persona};
    if (trial.showDictionaryEntry && !revealing.contains(dim)) return [e.lexeme.dictionaryEntry];
    return const [];
  }

  bool _endingIsShared(ForumItem e) {
    if (e.lexeme is! NounEntry) return true;
    final decls = _endingDeclensions ??= _computeEndingDeclensions();
    final ending = _nounEnding(e);
    if (ending == null) return true;
    return (decls[ending]?.length ?? 0) > 1;
  }

  Map<String, Set<Declension>> _computeEndingDeclensions() {
    final m = <String, Set<Declension>>{};
    for (final p in analyzer.nouns.paradigms) {
      final help = DeclensionHelp(p);
      for (final f in p.forms) {
        if (!f.isPrimary) continue;
        final seg = help.segment(f);
        if (seg != null) (m[seg.ending] ??= {}).add(p.noun.declension);
      }
    }
    return m;
  }

  String? _nounEnding(ForumItem e) {
    final n = e.lexeme;
    if (n is! NounEntry) return null;
    final p = analyzer.nouns.paradigmOf(n.id);
    final nf = p.forms.where((f) => f.surface == e.surface && f.analysis.nominal == e.analysis).firstOrNull;
    if (nf == null) return null;
    return DeclensionHelp(p).segment(nf)?.ending;
  }

  String _describe(ForumItem e) {
    final a = e.analysis;
    if (a.wordClass == WordClass.nomen && a.declension != null) return '${a.describe()} · ${a.declension!.latin.toLowerCase()} dēclīnātiō';
    return '${a.describe()} · ${e.lexeme.lemma}';
  }

  // ----- mastery helpers ------------------------------------------------------------

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

  /// Form of the same lexeme matching the chosen (wrong) value, when it exists.
  NominalForm? contrastForm(Question q, String chosenValue) {
    final a = q.forum.target.analysis;
    final id = q.lemmaId;
    switch (q.dimension) {
      case Dimension.casus:
        return _primaryMatching(id, casus: Casus.fromKey(chosenValue), number: a.number, gender: a.gender, degree: a.degree);
      case Dimension.numerus:
        return _primaryMatching(id, casus: a.casus, number: Numerus.fromKey(chosenValue), gender: a.gender, degree: a.degree);
      case Dimension.genus:
        return _primaryMatching(id, casus: a.casus, number: a.number, gender: Gender.fromKey(chosenValue), degree: a.degree);
      case Dimension.genusNumerus:
        final p = chosenValue.split('.');
        return _primaryMatching(id, casus: a.casus, number: Numerus.fromKey(p[1]), gender: Gender.fromKey(p[0]), degree: a.degree);
      case Dimension.gradus:
        return _primaryMatching(id, casus: a.casus, number: a.number, gender: a.gender, degree: Degree.fromKey(chosenValue));
      case Dimension.analysis:
        return analyzer.primary(id, chosenValue);
      case Dimension.productio:
        final forms = analyzer.analyzeAs(chosenValue, id).where((f) =>
          f.analysis.number == a.number && f.analysis.gender == a.gender && f.analysis.degree == a.degree).toList();
        return forms.where((f) => f.analysis.casus == a.casus).firstOrNull ?? forms.firstOrNull;
      default:
        return null;
    }
  }

  NominalForm? _primaryMatching(String id, {Casus? casus, Numerus? number, Gender? gender, Degree? degree}) {
    final m = analyzer.matching(id, casus: casus, number: number, gender: gender, degree: degree);
    return m.where((f) => f.isPrimary).firstOrNull ?? m.firstOrNull;
  }

  @override
  Explanation explain({required Question q, required String chosenValue, required bool correct}) {
    final p = q.forum;
    final a = p.target.analysis;
    final lex = p.lexeme;
    final headline = '${q.surface} — ${a.describe()} (${lex.dictionaryEntry})';
    final others = p.analyses
        .where((f) => f.analysis != a)
        .map((f) => '${f.analysis.describe()} (${analyzer.lexeme(f.analysis.lemmaId).lemma})')
        .toSet()
        .toList();
    final why = _why(q);
    if (correct) {
      return Explanation(headline: headline, detail: q.ambiguous ? 'Rēctē: plūrēs analysēs lēgitimae sunt.${why.isEmpty ? '' : ' $why'}' : why, also: p.syntagma == null ? others : const []);
    }
    // The chosen value is normally one of the offered choices; when a caller
    // asks about a value that was not offered, its own label is still shown
    // in Latin rather than a raw key.
    final chosenLabel = q.choices.where((c) => c.value == chosenValue).map((c) => c.label).firstOrNull ?? labelOf(q.dimension, chosenValue, item: ForumItem(p.lexeme, p.target, syntagma: p.syntagma));
    final correctLabels = q.choices.where((c) => q.correctValues.contains(c.value)).map((c) => c.label).join(' aut ');
    final contrast = contrastForm(q, chosenValue);
    var detail = 'Rēctum: $correctLabels. Tū dīxistī: $chosenLabel.';
    if (contrast != null && contrast.surface != q.surface) {
      detail += q.dimension == Dimension.productio
        ? ' ${contrast.surface}: ${contrast.analysis.describe()}.'
        : ' Fōrma "$chosenLabel" esset: ${contrast.surface}.';
    }
    if (why.isNotEmpty) detail += ' $why';
    return Explanation(headline: headline, detail: detail, contrastSurface: contrast?.surface, also: p.syntagma == null ? others : const []);
  }

  static const _declGen = ['prīmae', 'secundae', 'tertiae', 'quārtae', 'quīntae'];

  /// One sentence: the rule that decides. For a contextual item the authored
  /// note; for an isolated form the ending when the surface is stem + ending.
  String _why(Question q) {
    final p = q.forum;
    final s = p.syntagma;
    if (s != null) {
      final ctx = 'In "${s.plain}": ';
      switch (q.dimension) {
        case Dimension.quodNomen:
          return '$ctx${q.surface} cum ${s.headSurface ?? ''} congruit (${p.target.analysis.describe()}).${s.note.isEmpty ? '' : ' ${s.note}'}';
        default:
          return s.note.isEmpty ? '$ctx${q.surface} est ${p.target.analysis.describe()}.' : '$ctx${s.note}';
      }
    }
    final a = p.target.analysis;
    final lex = p.lexeme;
    final ending = NominalHelp(analyzer, lex).ending(p.target);
    switch (q.dimension) {
      case Dimension.casus:
      case Dimension.numerus:
      case Dimension.genusNumerus:
      case Dimension.analysis:
        if (lex is NounEntry) {
          final decl = _declGen[lex.declension.index];
          final bare = a.number == Numerus.singularis && (a.casus == Casus.nominativus || a.casus == Casus.vocativus);
          if (ending == null) return bare ? 'Nōminātīvus singulāris sine dēsinentiā; thema ${lex.stem}- ē genetīvō ${lex.genitive} cognōscitur.' : 'Fōrma irregulāris: thema ${lex.stem}- ē genetīvō ${lex.genitive} cognōscitur.';
          return 'Dēsinentia $ending: ${a.describe()} $decl dēclīnātiōnis.';
        }
        if (lex is PronounEntry) return 'Prōnōmen ${lex.lemma}: fōrma memoriā tenenda (${lex.entry}).';
        if (ending == null) return 'Fōrma propria vocābulī ${lex.lemma}: ${a.describe()}.';
        return 'Dēsinentia $ending: ${a.describe()}.';
      case Dimension.genus:
        if (lex is NounEntry) return 'Genus nōminis ē vocābulō discitur: ${lex.dictionaryEntry}.';
        if (ending == null) return 'Fōrma ${q.surface}: ${a.describe()}.';
        return 'Dēsinentia $ending genus ostendit: ${a.gender?.latin.toLowerCase() ?? ''}.';
      case Dimension.declinatio:
        if (lex is NounEntry) return 'Genetīvus ${lex.genitive} ${lex.declension.latin.toLowerCase()}m dēclīnātiōnem ostendit.';
        return '';
      case Dimension.thema:
        if (lex is NounEntry) return '${lex.dictionaryEntry}: ${_themeLabels[nounStemType(lex)]}. Thema ē genetīvō cognōscitur.';
        return '';
      case Dimension.classis:
        if (lex is AdjectiveEntry) {
          if (lex.pronominal) return 'Adiectīvum prōnōmināle: genetīvus -īus, datīvus -ī (${lex.entry}).';
          return lex.isFirstClass ? 'Ut bonus, -a, -um: prīma et secunda classis (${lex.entry}).' : 'Ut fortis, -e / fēlīx, -īcis: tertia classis (${lex.entry}).';
        }
        return '';
      case Dimension.gradus:
        return switch (a.degree) {
          Degree.positivus => 'Gradus positīvus: fōrma simplex vocābulī ${lex.lemma}.',
          Degree.comparativus => a.wordClass == WordClass.adverbium ? 'Comparātīvus adverbiī = neutrum comparātīvī in -ius.' : 'Signum -ior (m. f.), -ius (n.): comparātīvus, thema cōnsonāns (-e, -um, -a).',
          Degree.superlativus => 'Signum -issim- (-errim-, -illim-): superlātīvus, ut bonus dēclīnātus.',
        };
      case Dimension.lemma:
        return 'Vocābulum: ${lex.dictionaryEntry}.';
      case Dimension.persona:
        return a.person == null ? '' : '${a.person!.latin} persōna: ${lex.entry_}';
      case Dimension.correlativum:
        final partner = kCorrelativa[lex.id];
        return partner == null ? '' : 'Correlātīva bīna: ${lex.lemma} … ${analyzer.lexeme(partner).lemma}.';
      case Dimension.valor:
        return 'Valor: ${labelOf(Dimension.valor, valueOf(Dimension.valor, ForumItem(lex, p.target)) ?? '0')}.';
      case Dimension.forma:
        if (lex is NumeralEntry) return lex.isIndeclinable ? 'Cardinālia ā quattuor ad centum indēclīnābilia sunt.' : 'Hoc numerāle dēclīnātur (${lex.entry}).';
        if (lex is PronounEntry) return '${lex.kind.latin}: ${lex.entry}.';
        return '';
      default:
        return '';
    }
  }
}

extension on Lexeme {
  /// Dictionary entry followed by a full stop, for sentences.
  String get entry_ => '$dictionaryEntry.';
}
