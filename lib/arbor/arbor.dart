/// L'arbre complet : nœuds authored (L0, L1, L3, L5), cases dérivées (L2),
/// lexique (L4), arêtes indexées et validation structurelle.
library;

import 'contextus.dart';
import '../linguistics/engine/analyzer.dart';
import '../linguistics/engine/conjugator.dart';
import '../linguistics/engine/nominal_analyzer.dart';
import '../linguistics/lexicon/forum_lexicon.dart';
import '../linguistics/lexicon/verbs.dart';
import '../linguistics/model/noun.dart';
import '../linguistics/model/adjective.dart';
import '../linguistics/model/pronoun.dart';
import '../linguistics/model/numeral.dart';
import '../linguistics/model/grammar.dart';
import 'cellae.dart';
import 'lectio.dart';
import 'nominal_elementa.dart';
import 'notiones.dart';
import 'skill.dart';
import 'syntaxis.dart';
import 'verbal_elementa.dart';

class Arbor {
  Arbor._(this.nodes);

  final Map<String, Skill> nodes;

  /// composé → composants.
  final Map<String, Set<String>> partes = {};

  /// composant → composés.
  final Map<String, Set<String>> compositaEx = {};

  /// nœud → confusions (symétriques).
  final Map<String, List<Confusio>> confusiones = {};

  /// nœud → nœuds qui le requièrent.
  final Map<String, Set<String>> requiritur = {};

  /// parent d'affichage → enfants.
  final Map<String, List<Skill>> liberi = {};

  /// nœud → lexèmes qui l'illustrent.
  final Map<String, Set<String>> exempla = {};

  Skill? operator [](String id) => nodes[id];
  Iterable<Skill> get omnes => nodes.values;
  Iterable<Skill> stratum(Stratum s) => nodes.values.where((n) => n.stratum == s);

  /// Construit l'arbre standard à partir des lexiques embarqués.
  factory Arbor.standard({Analyzer? analyzer, NominalAnalyzer? nominal, List<String>? problems}) {
    final an = analyzer ?? Analyzer(kVerbs, Conjugator());
    final nom = nominal ?? buildNominalAnalyzer();
    final all = <Skill>[
      ...kNotiones,
      ...kVerbalGroups,
      ...kVerbalElementa,
      ...kNominalGroups,
      ...kNominalElementa,
      ...kSyntaxisGroups,
      ...kSyntaxis,
      ...kLectioGroups,
      ...kLectio,
      ...kContextusGroups,
      ...contextusNodes(),
      ...deriveVerbalCellae(an),
      ...deriveNominalCellae(nom, problems: problems),
      ...lexiconNodes(an, nom),
    ];
    final arbor = Arbor.of(all);
    arbor._syncretisms(an, nom);
    return arbor;
  }

  /// Construit et indexe un ensemble de nœuds (sans dérivation).
  factory Arbor.of(Iterable<Skill> skills) {
    final map = <String, Skill>{};
    for (final s in skills) {
      if (map.containsKey(s.id)) throw StateError('Nœud en double : ${s.id}');
      map[s.id] = s;
    }
    final a = Arbor._(map);
    a._index();
    return a;
  }

  void _index() {
    for (final s in nodes.values) {
      for (final p in s.pars) {
        (partes[s.id] ??= {}).add(p);
        (compositaEx[p] ??= {}).add(s.id);
      }
      for (final c in s.confunditur) {
        (confusiones[s.id] ??= []).add(c);
        (confusiones[c.cum] ??= []).add(Confusio(s.id, c.modus, nota: c.nota));
      }
      for (final r in s.requirit) {
        (requiritur[r] ??= {}).add(s.id);
      }
      if (s.parens != null) (liberi[s.parens!] ??= []).add(s);
      for (final e in s.exempla) {
        (exempla[e] ??= {}).add(s.id);
      }
    }
  }

  void _addConfusio(String a, String b, Modus m, String nota) {
    if (a == b) return;
    final la = confusiones[a] ??= [];
    if (la.any((c) => c.cum == b)) return;
    la.add(Confusio(b, m, nota: nota));
    (confusiones[b] ??= []).add(Confusio(a, m, nota: nota));
  }

  /// Deux cases d'un même paradigme qui partagent une surface sont en
  /// syncrétisme. Dérivé, jamais écrit.
  void _syncretisms(Analyzer an, NominalAnalyzer nom) {
    for (final e in {...kVerbalClassReps, ...kAnomalousReps}.entries) {
      final p = an.paradigmOf(e.value);
      final bySurface = <String, Set<String>>{};
      for (final f in p.forms) {
        if (!f.analysis.isPrimary) continue;
        final id = 'cella.v.${e.key}.${f.analysis.selector}';
        if (nodes.containsKey(id)) (bySurface[stripMacrons(f.surface)] ??= {}).add(id);
      }
      _link(bySurface);
    }
    void nominalGroup(String prefix, String lexId) {
      final bySurface = <String, Set<String>>{};
      for (final f in nom.formsOf(lexId)) {
        if (!f.isPrimary) continue;
        final id = '$prefix.${f.analysis.selector}';
        if (nodes.containsKey(id)) (bySurface[stripMacrons(f.surface)] ??= {}).add(id);
      }
      _link(bySurface);
    }
    kNounTypeReps.forEach((type, lex) => nominalGroup('cella.n.$type', lex));
    for (final p in nom.pronouns) {
      nominalGroup('cella.pron.${p.id}', p.id);
    }
  }

  void _link(Map<String, Set<String>> bySurface) {
    for (final e in bySurface.entries) {
      final ids = e.value.toList();
      for (var i = 0; i < ids.length; i++) {
        for (var j = i + 1; j < ids.length; j++) {
          _addConfusio(ids[i], ids[j], Modus.syncretismus, 'même surface : ${e.key}');
        }
      }
    }
  }

  /// Composants transitifs d'un nœud (lui-même exclu).
  Set<String> componentsOf(String id) {
    final out = <String>{};
    void visit(String x) {
      for (final p in partes[x] ?? const <String>{}) {
        if (out.add(p)) visit(p);
      }
    }
    visit(id);
    return out;
  }

  /// Prérequis transitifs d'un nœud.
  Set<String> prerequisitesOf(String id) {
    final out = <String>{};
    void visit(String x) {
      for (final r in nodes[x]?.requirit ?? const <String>[]) {
        if (out.add(r)) visit(r);
      }
    }
    visit(id);
    return out;
  }

  /// Vérifie la structure ; renvoie la liste des problèmes (vide si sain).
  List<String> validate() {
    final problems = <String>[];
    for (final s in nodes.values) {
      for (final ref in [...s.pars, ...s.requirit, ...s.notiones, ...s.exempla, ...s.confunditur.map((c) => c.cum), if (s.parens != null) s.parens!]) {
        if (!nodes.containsKey(ref)) problems.add('${s.id} → référence inconnue $ref');
      }
      if (s.stratum == Stratum.elementum && s.probatur.isNotEmpty && s.fontes.isEmpty) problems.add('${s.id} sans source');
      if (s.stratum == Stratum.cella && s.pars.isEmpty) problems.add('${s.id} case sans composant');
    }
    // Prérequis acycliques.
    final state = <String, int>{};
    void visit(String id, List<String> path) {
      final st = state[id] ?? 0;
      if (st == 2) return;
      if (st == 1) {
        problems.add('cycle de prérequis : ${[...path, id].join(' → ')}');
        return;
      }
      state[id] = 1;
      for (final r in nodes[id]?.requirit ?? const <String>[]) {
        visit(r, [...path, id]);
      }
      state[id] = 2;
    }
    for (final id in nodes.keys) {
      visit(id, []);
    }
    // Maillons reliés : au moins une arête.
    for (final s in nodes.values.where((s) => s.stratum == Stratum.elementum && s.probatur.isNotEmpty)) {
      final linked = s.requirit.isNotEmpty || s.confunditur.isNotEmpty || (confusiones[s.id]?.isNotEmpty ?? false) || (compositaEx[s.id]?.isNotEmpty ?? false) || (requiritur[s.id]?.isNotEmpty ?? false) || (exempla[s.id]?.isNotEmpty ?? false);
      if (!linked) problems.add('${s.id} isolé (aucune arête)');
    }
    return problems;
  }

  Map<Stratum, int> get census {
    final out = <Stratum, int>{};
    for (final s in nodes.values) {
      out[s.stratum] = (out[s.stratum] ?? 0) + 1;
    }
    return out;
  }
}

/// L4 — un nœud par lexème, avec sa classe et ses particularités comme `exempla`.
List<Skill> lexiconNodes(Analyzer an, NominalAnalyzer nom) {
  final out = <Skill>[
    const Skill('lex', nomen: 'Lexicon', quid: 'Le vocabulaire.', stratum: Stratum.lexicon),
    const Skill('lex.v', nomen: 'Verba', quid: 'Les verbes du lexique.', stratum: Stratum.lexicon, parens: 'lex'),
    const Skill('lex.n', nomen: 'Nōmina', quid: 'Les noms du lexique.', stratum: Stratum.lexicon, parens: 'lex'),
    const Skill('lex.adj', nomen: 'Adiectīva', quid: 'Les adjectifs du lexique.', stratum: Stratum.lexicon, parens: 'lex'),
    const Skill('lex.pron', nomen: 'Prōnōmina', quid: 'Les pronoms du lexique.', stratum: Stratum.lexicon, parens: 'lex'),
    const Skill('lex.num', nomen: 'Numerālia', quid: 'Les numéraux du lexique.', stratum: Stratum.lexicon, parens: 'lex'),
    const Skill('lex.adv', nomen: 'Adverbia', quid: 'Les adverbes du lexique.', stratum: Stratum.lexicon, parens: 'lex'),
  ];
  for (final v in an.verbs) {
    final cls = verbClassKey(v);
    final ex = <String>{
      kVerbalClassReps.containsKey(cls) ? 'v.thema.praes.$cls' : anomalousNode(cls),
      if (v.isDeponent) 'v.kind.dep',
      if (v.isSemiDeponent) 'v.kind.semidep',
      if (v.kind == VerbKind.defectivum) 'v.kind.def',
      if (v.kind == VerbKind.impersonale) 'v.kind.impers',
      if (v.compoundOf != null) 'v.kind.comp',
    };
    out.add(Skill('lex.v.${v.id}', nomen: v.lemma, quid: v.glossFr, stratum: Stratum.lexicon, exempla: ex.where((e) => e != 'not.coniugatio.anom').toList(), probatur: const [Dimensio.lemma, Dimensio.vocabulum], visibilis: false, parens: 'lex.v'));
  }
  for (final l in nom.lexemes) {
    final ex = <String>{};
    String parens;
    if (l is NounEntry) {
      ex.add('n.thema.${nounStemType(l)}');
      parens = 'lex.n';
    } else if (l is AdjectiveEntry) {
      ex.add('adj.classis.${adjectiveClassKey(l)}');
      if (l.pronominal) ex.add('adj.classis.pron');
      if (l.comparison == ComparisonKind.irregularis) ex.add('adj.gradus.irr');
      if (l.comparison == ComparisonKind.periphrastica) ex.add('adj.gradus.periph');
      parens = 'lex.adj';
    } else if (l is PronounEntry) {
      ex.add(pronounNode(l));
      parens = 'lex.pron';
    } else if (l is NumeralEntry) {
      ex.add(numeralNode(l));
      parens = 'lex.num';
    } else {
      parens = 'lex.adv';
    }
    out.add(Skill('${parens}.${l.id}', nomen: l.lemma, quid: l.glossFr, stratum: Stratum.lexicon, exempla: ex.toList(), probatur: const [Dimensio.lemma, Dimensio.vocabulum], visibilis: false, parens: parens));
  }
  return out;
}
