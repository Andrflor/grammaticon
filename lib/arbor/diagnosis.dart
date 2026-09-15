/// Diagnostic d'une réponse : quels maillons de l'arbre une erreur met en
/// cause, et quels maillons une bonne réponse a réellement testés.
///
/// Pour la morphologie, le diagnostic est **calculé** : on prend la forme qui
/// correspond à la réponse choisie (`contrastForm`), on décompose les deux
/// formes en maillons (`verbalComponents` / `nominalComponents`) et la
/// différence est le diagnostic. Rien n'est écrit question par question.
library;

import '../linguistics/model/adjective.dart';
import '../linguistics/model/grammar.dart';
import '../linguistics/model/nominal.dart';
import '../linguistics/model/noun.dart';
import '../linguistics/model/numeral.dart';
import '../linguistics/model/pronoun.dart';
import '../linguistics/model/verb.dart';
import '../pedagogy/forum/forum_question_source.dart';
import '../pedagogy/forum/syntagma.dart';
import '../pedagogy/frames/frame_question_source.dart';
import '../pedagogy/question_generator.dart';
import '../pedagogy/reading/reading_question_source.dart';
import '../pedagogy/trial.dart';
import 'arbor.dart';
import 'cellae.dart';

class Diagnosis {
  const Diagnosis({this.observed = const {}, this.confusedWith = const {}});

  /// Maillons de la bonne réponse que le joueur n'a pas reconnus.
  final Set<String> observed;

  /// Maillons sur lesquels repose la réponse choisie.
  final Set<String> confusedWith;

  bool get isEmpty => observed.isEmpty && confusedWith.isEmpty;

  /// Maillons L1 et au-dessus (les notions L0 servent d'agrégat, pas de cible).
  Set<String> get observedElementa => observed.where((id) => !id.startsWith('not.')).toSet();

  Map<String, Object?> toJson() => {'o': observed.toList()..sort(), 'c': confusedWith.toList()..sort()};
  factory Diagnosis.fromJson(Map<String, Object?> j) => Diagnosis(
    observed: ((j['o'] as List?) ?? const []).cast<String>().toSet(),
    confusedWith: ((j['c'] as List?) ?? const []).cast<String>().toSet(),
  );
}

class Diagnostician {
  Diagnostician(this.arbor, this.verbs, this.forum);
  final Arbor arbor;
  final QuestionGenerator verbs;
  final ForumQuestionSource forum;

  // ---------------------------------------------------------------------------
  // Composants d'une réponse
  // ---------------------------------------------------------------------------

  /// Maillons de la forme cible d'une question (bonne réponse), avec sa case
  /// L2 et son lexème.
  Set<String> targetComponents(Question q) {
    final p = q.payload;
    if (p is VerbQuestionPayload) {
      final v = verbs.analyzer.verb(q.lemmaId);
      return _verb(p.target.analysis, v);
    }
    if (p is ForumQuestionPayload) {
      final out = _nominal(p.target, p.lexeme);
      final s = p.syntagma;
      if (s != null) {
        if (s.functio != null) out.add(_functioNode(s.functio!.key, s));
        if (s.constructio != null) out.addAll(_constructioNodes(s.constructio!.key));
        if (s.relatio != null) out.addAll({s.relatio!.key == 'subiectum' ? 'syn.pron.reflexivum' : 'syn.pron.is.anaphora', 'pron.suus_eius'});
        if (s.head != null) out.addAll({'syn.concordia.adiectivum', 'syn.concordia.distans'});
      }
      return out;
    }
    if (p is ReadingQuestionPayload) return {_readingSkill(p.entry.item.skillId, p.entry.item.distinctions)};
    if (p is FrameQuestionPayload) {
      final out = p.nodes.toSet();
      // Choix latins d'un seul mot : la forme correcte apporte ses maillons.
      final accepted = q.choices.where((c) => q.isCorrect(c.value)).map((c) => c.label).firstOrNull;
      if (accepted != null) out.addAll(_wordComponents(accepted));
      return out;
    }
    return {};
  }

  /// Maillons d'un mot latin isolé (une seule analyse acceptée), sinon rien.
  Set<String> _wordComponents(String label) {
    final word = label.trim().replaceAll(RegExp(r'[.,;:!?«»"]'), '');
    if (word.isEmpty || word.contains(' ')) return {};
    final vf = verbs.analyzer.analyzeLoose(word);
    if (vf.length == 1 || (vf.isNotEmpty && vf.every((f) => f.analysis.lemmaId == vf.first.analysis.lemmaId))) {
      final f = vf.first;
      return _verb(f.analysis, verbs.analyzer.verb(f.analysis.lemmaId))..removeWhere((c) => c.startsWith('cella.'));
    }
    final nf = forum.analyzer.analyzeLoose(word);
    if (nf.isNotEmpty && nf.every((f) => f.analysis.lemmaId == nf.first.analysis.lemmaId)) {
      final f = nf.first;
      return _nominal(f, forum.analyzer.lexeme(f.analysis.lemmaId))..removeWhere((c) => c.startsWith('cella.'));
    }
    return {};
  }

  Set<String> _verb(dynamic analysis, VerbEntry v) {
    final out = verbalComponents(analysis, v);
    out.add('lex.v.${v.id}');
    final cell = 'cella.v.${verbClassKey(v)}.${analysis.selector}';
    if (arbor.nodes.containsKey(cell)) out.add(cell);
    return out;
  }

  Set<String> _nominal(NominalForm f, Lexeme lexeme) {
    final out = nominalComponents(f, lexeme);
    final prefix = lexeme is NounEntry
        ? 'lex.n'
        : lexeme is AdjectiveEntry
        ? 'lex.adj'
        : lexeme is PronounEntry
        ? 'lex.pron'
        : lexeme is NumeralEntry
        ? 'lex.num'
        : 'lex.adv';
    out.add('$prefix.${lexeme.id}');
    final cell = switch (lexeme) {
      NounEntry n => 'cella.n.${nounStemType(n)}.${f.analysis.selector}',
      AdjectiveEntry a => f.analysis.degree == Degree.positivus ? 'cella.adj.${adjectiveClassKey(a)}.${f.analysis.selector}' : 'cella.adj.${f.analysis.degree.key}.${f.analysis.selector}',
      PronounEntry p => 'cella.pron.${p.id}.${f.analysis.selector}',
      NumeralEntry n => 'cella.num.${n.id}.${f.analysis.selector}',
      _ => '',
    };
    if (arbor.nodes.containsKey(cell)) out.add(cell);
    return out;
  }

  // ---------------------------------------------------------------------------
  // Diagnostic d'une mauvaise réponse
  // ---------------------------------------------------------------------------

  /// Diagnostic d'une réponse [chosen] à [q]. Vide si la réponse est correcte
  /// ou si aucune différence de maillon n'est identifiable.
  Diagnosis diagnose(Question q, String chosen) {
    if (q.isCorrect(chosen)) return const Diagnosis();
    final a = targetComponents(q);
    final b = chosenComponents(q, chosen);
    if (b == null) return const Diagnosis();
    return Diagnosis(observed: a.difference(b), confusedWith: b.difference(a));
  }

  /// Maillons sur lesquels repose une réponse [chosen] (correcte ou non).
  Set<String>? chosenComponents(Question q, String chosen) {
    final p = q.payload;
    if (p is VerbQuestionPayload) return _verbChosen(q, p, chosen);
    if (p is ForumQuestionPayload) return _nominalChosen(q, p, chosen);
    if (p is ReadingQuestionPayload) return _readingChosen(p, chosen);
    if (p is FrameQuestionPayload) {
      final label = q.choices.where((c) => c.value == chosen).map((c) => c.label).firstOrNull;
      final morph = label == null ? const <String>{} : _wordComponents(label);
      // Le nœud de la carte est ce qui a manqué ; ce que le choix repose sur
      // d'autre (forme fautive, geste de fidélité) est la confusion.
      return {...morph, 'lect.versio.fidelitas'};
    }
    return null;
  }

  Set<String>? _verbChosen(Question q, VerbQuestionPayload p, String chosen) {
    final target = p.target.analysis;
    final v = verbs.analyzer.verb(q.lemmaId);
    final paradigm = verbs.analyzer.paradigmOf(v.id);
    switch (q.dimension) {
      case Dimension.coniugatio:
        final cls = chosen == 'c3io' ? 'c3io' : chosen;
        return {..._verb(target, v)}
          ..remove('v.thema.praes.${verbClassKey(v)}')
          ..remove(_vocalisFor(verbClassKey(v)))
          ..add('v.thema.praes.$cls')
          ..add(_vocalisFor(cls));
      case Dimension.tempusSensus:
        return {..._verb(target, v)}
          ..remove('v.kind.def')
          ..removeWhere((c) => c.startsWith('not.tempus.'))
          ..add('not.tempus.$chosen');
      case Dimension.voxSensus:
        if (!v.isDeponent && !v.isSemiDeponent) {
          final want = chosen == 'act' ? Voice.activum : Voice.passivum;
          final other = paradigm.forms.where((f) => f.isPrimary && f.analysis.mood == target.mood && f.analysis.tense == target.tense && f.analysis.person == target.person && f.analysis.number == target.number && f.analysis.voice == want && f.analysis.periphrasis == target.periphrasis).firstOrNull;
          if (other != null) return _verb(other.analysis, v);
          return _synthetic(target.copyWith(voice: want), v);
        }
        return {..._verb(target, v)}
          ..remove('v.kind.dep')
          ..remove('v.kind.semidep')
          ..removeWhere((c) => c.startsWith('not.vox.'))
          ..add('not.vox.$chosen');
      case Dimension.lemma:
      case Dimension.formaPlena:
      case Dimension.analysis:
      case Dimension.forma:
        final contrast = verbs.contrastForm(q, chosen);
        if (contrast == null) return _genericChosen(q, _verb(target, v), chosen);
        return _verb(contrast.analysis, verbs.analyzer.verb(contrast.analysis.lemmaId));
      default:
        // Une forme de contraste réelle si elle existe ; sinon l'analyse
        // synthétique : les maillons se calculent même pour une case vide.
        final contrast = verbs.contrastForm(q, chosen);
        if (contrast != null && contrast.analysis.lemmaId == v.id) return _verb(contrast.analysis, v);
        final synthetic = _syntheticAnalysis(target, q.dimension, chosen);
        if (synthetic != null) {
          final comps = _synthetic(synthetic, v);
          if (comps != null) return comps;
        }
        if (contrast != null) return _verb(contrast.analysis, verbs.analyzer.verb(contrast.analysis.lemmaId));
        return _genericChosen(q, _verb(target, v), chosen);
    }
  }

  Set<String>? _synthetic(dynamic analysis, VerbEntry v) {
    try {
      final out = verbalComponents(analysis, v);
      out.add('lex.v.${v.id}');
      return out;
    } catch (_) {
      return null;
    }
  }

  /// Analyse « comme si » la réponse choisie était la bonne.
  dynamic _syntheticAnalysis(dynamic t, Dimension d, String chosen) {
    switch (d) {
      case Dimension.persona:
        return t.copyWith(person: Person.fromKey(chosen));
      case Dimension.numerus:
        return t.copyWith(number: Numerus.fromKey(chosen));
      case Dimension.personaNumerus:
        final k = chosen.split('.');
        return t.copyWith(person: Person.fromKey(k[0]), number: Numerus.fromKey(k[1]));
      case Dimension.tempus:
        final tense = Tense.fromKey(chosen);
        if (t.mood == Mood.participium) {
          return t.copyWith(tense: tense, voice: tense == Tense.perfectum ? Voice.passivum : Voice.activum);
        }
        // Un composé (amātus erat) pris pour un temps du système du présent :
        // c'est une forme simple qui a été lue.
        if (t.composite && t.periphrasis == Periphrasis.nulla && !tense.isPerfectSystem) return t.copyWith(tense: tense, composite: false);
        return t.copyWith(tense: tense);
      case Dimension.modus:
        final mood = Mood.fromKey(chosen);
        if (t.composite && (mood.isNominal || mood == Mood.imperativus)) return t.copyWith(mood: mood, composite: false, tense: mood == Mood.imperativus ? Tense.praesens : t.tense);
        return t.copyWith(mood: mood);
      case Dimension.tempusModus:
        final (m, te) = QuestionGenerator.tempusModusOf(chosen);
        if (t.composite && (m.isNominal || m == Mood.imperativus || !te.isPerfectSystem)) return t.copyWith(mood: m, tense: te, composite: false);
        return t.copyWith(mood: m, tense: te);
      case Dimension.vox:
        final voice = Voice.fromKey(chosen);
        if (t.mood == Mood.participium) {
          // Un participe n'a qu'une voix par temps : choisir l'autre voix, c'est
          // le prendre pour le participe qui a cette voix.
          if (voice == Voice.passivum) return t.tense == Tense.futurum ? t.copyWith(mood: Mood.gerundivum, tense: null, voice: Voice.passivum) : t.copyWith(tense: Tense.perfectum, voice: Voice.passivum);
          return t.copyWith(tense: t.tense == Tense.perfectum ? Tense.praesens : t.tense, voice: Voice.activum);
        }
        return t.copyWith(voice: voice);
      case Dimension.genus:
        return t.copyWith(gender: Gender.fromKey(chosen));
      case Dimension.casus:
        return t.copyWith(casus: Casus.fromKey(chosen));
      default:
        return null;
    }
  }

  Set<String>? _nominalChosen(Question q, ForumQuestionPayload p, String chosen) {
    final base = _nominal(p.target, p.lexeme);
    switch (q.dimension) {
      case Dimension.genus when p.lexeme is NounEntry:
        // Le genre d'un nom ne se lit pas sur la désinence : c'est la règle de
        // genre de sa déclinaison qui est en cause.
        return {...base}
          ..removeWhere((c) => c.startsWith('n.genus.') || c.startsWith('not.genus.'))
          ..add('not.genus.$chosen');
      case Dimension.casus:
      case Dimension.numerus:
      case Dimension.genus:
      case Dimension.genusNumerus:
      case Dimension.gradus:
      case Dimension.analysis:
        final contrast = forum.contrastForm(q, chosen);
        if (contrast != null) return _nominal(contrast, p.lexeme);
        final a = p.target.analysis;
        final synthetic = switch (q.dimension) {
          Dimension.casus => a.copyWith(casus: Casus.fromKey(chosen)),
          Dimension.numerus => a.copyWith(number: Numerus.fromKey(chosen)),
          Dimension.genus => a.copyWith(gender: Gender.fromKey(chosen)),
          Dimension.gradus => a.copyWith(degree: Degree.fromKey(chosen)),
          Dimension.genusNumerus => a.copyWith(gender: Gender.fromKey(chosen.split('.')[0]), number: Numerus.fromKey(chosen.split('.')[1])),
          _ => null,
        };
        if (synthetic == null) return _genericChosen(q, base, chosen);
        return _nominal(NominalForm(p.target.surface, synthetic), p.lexeme);
      case Dimension.declinatio:
        return {...base}
          ..removeWhere((c) => c.startsWith('n.thema.') || c.startsWith('not.declinatio.'))
          ..add(_themaOfDeclension(chosen))
          ..add('not.declinatio.${chosen.substring(1)}');
      case Dimension.classis:
        return {...base}
          ..removeWhere((c) => c.startsWith('adj.classis.'))
          ..add(switch (chosen) { '12' => 'adj.classis.12', '3' => 'adj.classis.3.duo', _ => 'adj.classis.pron' });
      case Dimension.lemma:
        final other = forum.analyzer.maybeLexeme(chosen);
        if (other == null) return null;
        final form = forum.analyzer.primary(other.id, p.target.analysis.selector) ?? forum.analyzer.formsOf(other.id).firstOrNull;
        if (form == null) return {...base}..removeWhere((c) => c.startsWith('lex.'));
        return _nominal(form, other);
      case Dimension.functio:
        return _swap(base, _functioNodes(p.syntagma), _functioNode(chosen, p.syntagma));
      case Dimension.constructio:
        return _swap(base, _allConstructioNodes(), _constructioNodes(chosen));
      case Dimension.relatio:
        return _swap(base, {'syn.pron.reflexivum', 'syn.pron.is.anaphora'}, {chosen == 'subiectum' ? 'syn.pron.reflexivum' : 'syn.pron.is.anaphora', 'pron.suus_eius'});
      case Dimension.quodNomen:
        // Choisir un autre nom : l'accord a été fait avec le voisin, pas avec le
        // nom qui porte les mêmes genre, nombre et cas.
        return {...base}..remove('syn.concordia.distans')..remove('syn.concordia.adiectivum');
      case Dimension.correlativum:
        return {...base}..removeWhere((c) => c.startsWith('lex.'))..add('pron.corr');
      case Dimension.valor:
        return {...base}..removeWhere((c) => c.startsWith('num.') || c.startsWith('lex.'))..add('num.card.indecl');
      case Dimension.forma:
        return {...base}..removeWhere((c) => c.startsWith('pron.') || c.startsWith('lex.'))..add(_pronounKindNode(chosen));
      case Dimension.persona:
        return {...base}..removeWhere((c) => c.startsWith('not.persona.') || c.startsWith('pron.'))..add('not.persona.$chosen');
      default:
        return _genericChosen(q, base, chosen);
    }
  }

  Set<String>? _readingChosen(ReadingQuestionPayload p, String chosen) {
    final d = p.entry.renderings.distractors.where((d) => d.id == chosen).firstOrNull;
    if (d == null) return null;
    return {_readingSkill(d.skillId, {d.distinction}), 'lect.versio.fidelitas'};
  }

  /// Sans forme de contraste : on remplace les notions de la dimension par
  /// celle qui a été choisie ; le diagnostic est alors au niveau des notions.
  Set<String> _genericChosen(Question q, Set<String> base, String chosen) {
    final prefix = switch (q.dimension) {
      Dimension.tempus || Dimension.tempusSensus => 'not.tempus.',
      Dimension.modus => 'not.modus.',
      Dimension.vox || Dimension.voxSensus => 'not.vox.',
      Dimension.persona => 'not.persona.',
      Dimension.numerus => 'not.numerus.',
      Dimension.genus => 'not.genus.',
      Dimension.casus => 'not.casus.',
      Dimension.gradus => 'not.gradus.',
      _ => null,
    };
    if (prefix == null) return {...base}..removeWhere((c) => c.startsWith('lex.'));
    return {...base}
      ..removeWhere((c) => c.startsWith(prefix) && !c.contains('systema'))
      ..add('$prefix$chosen');
  }

  // ---------------------------------------------------------------------------
  // Crédit d'une bonne réponse
  // ---------------------------------------------------------------------------

  /// Maillons qu'une bonne réponse à [q] a réellement prouvés : ceux de la
  /// cible qui la distinguent d'au moins un distracteur proposé, plus sa case
  /// et son lexème. Une question sans distracteur diagnostique ne prouve que
  /// la case et le lexème.
  Set<String> credited(Question q) {
    final a = targetComponents(q);
    final out = <String>{};
    for (final c in q.choices) {
      if (q.isCorrect(c.value)) continue;
      final b = chosenComponents(q, c.value);
      if (b == null) continue;
      out.addAll(a.difference(b));
    }
    out.addAll(a.where((id) => id.startsWith('cella.') || id.startsWith('lex.')));
    return out;
  }

  // ---------------------------------------------------------------------------
  // Tables
  // ---------------------------------------------------------------------------

  static String _vocalisFor(String cls) => switch (cls) {
    'c1' => 'v.voc.a',
    'c2' => 'v.voc.e',
    'c3' => 'v.voc.i_u',
    'c3io' => 'v.voc.io',
    'c4' => 'v.voc.i_long',
    _ => 'not.coniugatio.anom',
  };

  static String _themaOfDeclension(String key) => switch (key) {
    'd1' => 'n.thema.d1',
    'd2' => 'n.thema.d2.us',
    'd3' => 'n.thema.d3.cons',
    'd4' => 'n.thema.d4.m',
    _ => 'n.thema.d5',
  };

  static String _pronounKindNode(String kind) => switch (kind) {
    'relativum' => 'pron.qui',
    'interrogativum' => 'pron.quis',
    'indefinitum' => 'pron.indef',
    'personale' => 'pron.ego',
    'reflexivum' => 'pron.se',
    'demonstrativum' => 'pron.is',
    'correlativum' => 'pron.corr',
    _ => 'pron.quis_qui',
  };

  Set<String> _swap(Set<String> base, Set<String> remove, Object add) => {...base}
    ..removeAll(remove)
    ..addAll(add is Set<String> ? add : {add as String});

  Set<String> _functioNodes(Syntagma? s) => {for (final f in Functio.values) _functioNode(f.key, s)};

  static String _functioNode(String key, Syntagma? s) => switch (key) {
    'subiectum' => 'syn.nom.subiectum',
    'obiectum' => 'syn.acc.obiectum',
    'possessor' => 'syn.gen.possessivus',
    'datum' => 'syn.dat.attributio',
    'instrumentum' => 'syn.abl.instrumentum',
    'praedicatum' => 'syn.nom.praedicativum',
    'vocatio' => 'syn.voc.appellatio',
    'locus-ubi' => 'syn.abl.locus',
    'locus-quo' => 'syn.acc.directio',
    'locus-unde' => 'syn.abl.separatio',
    'tempus' => 'syn.abl.tempus',
    'comparatio' => 'syn.abl.comparationis',
    'appositio' => 'syn.concordia.appositio',
    'attributum' => 'syn.concordia.adiectivum',
    'obiectum-dat' => 'syn.dat.verba',
    'obiectum-abl' => 'syn.abl.deponentia',
    'obiectum-gen' => 'syn.gen.memoriae',
    'praepositio' => s?.casus.key == 'acc' ? 'syn.acc.praep' : 'syn.abl.praep',
    'partitivum' => 'syn.gen.partitivus',
    _ => 'syn',
  };

  static Set<String> _allConstructioNodes() => {for (final c in Constructio.values) ..._constructioNodes(c.key)};

  /// Nœuds mis en jeu par une construction : la fonction du cas et, quand la
  /// construction se distingue par un mot (in, sub, nom de ville), ce mot.
  static Set<String> _constructioNodes(String key) => switch (key) {
    'abl-comp' => {'syn.abl.comparationis'},
    'quam' => {'syn.comp.quam'},
    'in-abl' => {'syn.abl.locus', 'syn.praep.in', 'syn.praep.in.duplex'},
    'sub-abl' => {'syn.abl.locus', 'syn.praep.sub', 'syn.praep.in.duplex'},
    'in-acc' => {'syn.acc.directio', 'syn.praep.in', 'syn.praep.in.duplex'},
    'sub-acc' => {'syn.acc.directio', 'syn.praep.sub', 'syn.praep.in.duplex'},
    'mille-adi' => {'syn.numeri.mille'},
    'milia-gen' => {'syn.gen.quantitatis', 'syn.numeri.mille'},
    'loc' => {'syn.locus.locativus', 'n.thema.proprium'},
    'acc-motus' => {'syn.acc.directio', 'n.thema.proprium'},
    'abl-sep' => {'syn.abl.separatio', 'n.thema.proprium'},
    'abl-temp' => {'syn.abl.tempus'},
    'acc-dur' => {'syn.acc.tempus'},
    'gen-part' => {'syn.gen.partitivus'},
    _ => {'syn'},
  };

  /// Les anciens items de lecture portent une « distinction » ; on la projette
  /// sur le nœud de lecture le plus proche.
  static String _readingSkill(String legacySkill, Set<String> distinctions) {
    final d = distinctions.isEmpty ? '' : distinctions.first;
    return switch (d) {
      'numerus' || 'persona' => 'syn.concordia.verbum',
      'casus' => 'lect.versio.casus',
      'tempus' => 'lect.versio.tempora',
      'vox' => 'lect.versio.deponentia',
      'modus' => 'lect.versio.tempora',
      'congruentia' => 'syn.concordia.adiectivum',
      'nonfinita' => 'lect.versio.participia',
      _ => 'lect.versio.fidelitas',
    };
  }
}
