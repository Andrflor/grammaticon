/// Rule-based declension of adjectives in their three degrees (A&G §109–§131).
///
/// First class: bonus / pulcher / miser endings; pronominal adjectives take
/// -īus / -ī. Third class: i-stem endings (ablative -ī, genitive plural -ium,
/// neuter plural -ia) for one, two and three terminations; consonant stems
/// (vetus, pauper) and every comparative take -e, -um, -a. Superlatives are
/// declined like bonus. Explicit cells replace the rule output.
library;

import '../model/adjective.dart';
import '../model/grammar.dart';
import '../model/nominal.dart';

/// Declined paradigm of one adjective.
class AdjectiveParadigm {
  AdjectiveParadigm(this.adjective, List<NominalForm> forms) : forms = List.unmodifiable(forms) {
    for (final f in forms) {
      (_bySelector[f.analysis.selector] ??= []).add(f);
    }
  }
  final AdjectiveEntry adjective;
  final List<NominalForm> forms;
  final Map<String, List<NominalForm>> _bySelector = {};

  List<NominalForm> cell(String selector) => _bySelector[selector] ?? const [];
  NominalForm? primary(String selector) => cell(selector).where((f) => f.isPrimary).firstOrNull;
  bool has(String selector) => _bySelector.containsKey(selector);
  Iterable<String> get selectors => _bySelector.keys;
  bool hasDegree(Degree d) => forms.any((f) => f.analysis.degree == d);
}

class AdjectiveDeclinator {
  const AdjectiveDeclinator();

  AdjectiveParadigm decline(AdjectiveEntry a) {
    final cells = <String, List<String>>{};
    if (a.hasPositive) {
      if (a.isFirstClass) {
        _firstClass(a, cells);
      } else {
        _thirdClass(a, cells);
      }
    }
    if (a.hasComparison) {
      final comp = a.comparative ?? '${a.stem}ior';
      _comparative(comp, cells);
      final sup = a.superlativeStem ?? _regularSuperlativeStem(a);
      _bonus(sup, cells, prefix: 'sup.');
    }
    for (final e in a.overrides.entries) {
      cells[e.key] = List.of(e.value);
    }
    for (final pre in a.absent) {
      cells.removeWhere((k, _) => k == pre || k.startsWith('$pre.') || _matchesPattern(pre, k));
    }
    final out = <NominalForm>[];
    for (final e in cells.entries) {
      final p = parseSelector(e.key);
      final seen = <String>{};
      for (var i = 0; i < e.value.length; i++) {
        final s = e.value[i];
        if (!seen.add(s)) continue;
        out.add(NominalForm(s, NominalAnalysis(lemmaId: a.id, wordClass: WordClass.adiectivum, casus: p.casus, number: p.number, gender: p.gender, degree: p.degree, variant: i == 0 ? VariantKind.norma : VariantKind.altera)));
      }
    }
    return AdjectiveParadigm(a, out);
  }

  /// `*.sg.n` style patterns: segment-wise, `*` matches one segment.
  static bool _matchesPattern(String pat, String sel) {
    if (!pat.contains('*')) return false;
    final ps = pat.split('.');
    final ss = sel.split('.');
    if (ps.length != ss.length) return false;
    for (var i = 0; i < ps.length; i++) {
      if (ps[i] != '*' && ps[i] != ss[i]) return false;
    }
    return true;
  }

  static String _regularSuperlativeStem(AdjectiveEntry a) {
    if (a.tags.contains('ilis')) return '${a.stem}lim';
    if (a.isErType || (a.isThirdClass && a.nominativeM.endsWith('er'))) return '${a.nominativeM}rim';
    return '${a.stem}issim';
  }

  // ----- first class -------------------------------------------------------------

  void _firstClass(AdjectiveEntry a, Map<String, List<String>> cells) {
    final s = a.stem;
    final nomM = a.nominativeM;
    final pron = a.pronominal;
    // masculine
    cells['nom.sg.m'] = [nomM];
    cells['voc.sg.m'] = [nomM.endsWith('us') ? (nomM.endsWith('ius') ? nomM.substring(0, nomM.length - 2) : '${s}e') : nomM];
    cells['acc.sg.m'] = ['${s}um'];
    cells['gen.sg.m'] = pron ? ['${s}īus'] : ['${s}ī'];
    cells['dat.sg.m'] = pron ? ['${s}ī'] : ['${s}ō'];
    cells['abl.sg.m'] = ['${s}ō'];
    // feminine
    cells['nom.sg.f'] = [a.nominativeF];
    cells['voc.sg.f'] = [a.nominativeF];
    cells['acc.sg.f'] = ['${s}am'];
    cells['gen.sg.f'] = pron ? ['${s}īus'] : ['${s}ae'];
    cells['dat.sg.f'] = pron ? ['${s}ī'] : ['${s}ae'];
    cells['abl.sg.f'] = ['${s}ā'];
    // neuter
    cells['nom.sg.n'] = [a.nominativeN];
    cells['voc.sg.n'] = [a.nominativeN];
    cells['acc.sg.n'] = [a.nominativeN];
    cells['gen.sg.n'] = pron ? ['${s}īus'] : ['${s}ī'];
    cells['dat.sg.n'] = pron ? ['${s}ī'] : ['${s}ō'];
    cells['abl.sg.n'] = ['${s}ō'];
    _bonusPlural(s, cells, '');
  }

  /// Superlative (or any bonus-type paradigm) under [prefix].
  void _bonus(String s, Map<String, List<String>> cells, {required String prefix}) {
    cells['${prefix}nom.sg.m'] = ['${s}us'];
    cells['${prefix}voc.sg.m'] = ['${s}e'];
    cells['${prefix}acc.sg.m'] = ['${s}um'];
    cells['${prefix}gen.sg.m'] = ['${s}ī'];
    cells['${prefix}dat.sg.m'] = ['${s}ō'];
    cells['${prefix}abl.sg.m'] = ['${s}ō'];
    cells['${prefix}nom.sg.f'] = ['${s}a'];
    cells['${prefix}voc.sg.f'] = ['${s}a'];
    cells['${prefix}acc.sg.f'] = ['${s}am'];
    cells['${prefix}gen.sg.f'] = ['${s}ae'];
    cells['${prefix}dat.sg.f'] = ['${s}ae'];
    cells['${prefix}abl.sg.f'] = ['${s}ā'];
    cells['${prefix}nom.sg.n'] = ['${s}um'];
    cells['${prefix}voc.sg.n'] = ['${s}um'];
    cells['${prefix}acc.sg.n'] = ['${s}um'];
    cells['${prefix}gen.sg.n'] = ['${s}ī'];
    cells['${prefix}dat.sg.n'] = ['${s}ō'];
    cells['${prefix}abl.sg.n'] = ['${s}ō'];
    _bonusPlural(s, cells, prefix);
  }

  void _bonusPlural(String s, Map<String, List<String>> cells, String prefix) {
    cells['${prefix}nom.pl.m'] = ['${s}ī'];
    cells['${prefix}voc.pl.m'] = ['${s}ī'];
    cells['${prefix}acc.pl.m'] = ['${s}ōs'];
    cells['${prefix}gen.pl.m'] = ['${s}ōrum'];
    cells['${prefix}dat.pl.m'] = ['${s}īs'];
    cells['${prefix}abl.pl.m'] = ['${s}īs'];
    cells['${prefix}nom.pl.f'] = ['${s}ae'];
    cells['${prefix}voc.pl.f'] = ['${s}ae'];
    cells['${prefix}acc.pl.f'] = ['${s}ās'];
    cells['${prefix}gen.pl.f'] = ['${s}ārum'];
    cells['${prefix}dat.pl.f'] = ['${s}īs'];
    cells['${prefix}abl.pl.f'] = ['${s}īs'];
    cells['${prefix}nom.pl.n'] = ['${s}a'];
    cells['${prefix}voc.pl.n'] = ['${s}a'];
    cells['${prefix}acc.pl.n'] = ['${s}a'];
    cells['${prefix}gen.pl.n'] = ['${s}ōrum'];
    cells['${prefix}dat.pl.n'] = ['${s}īs'];
    cells['${prefix}abl.pl.n'] = ['${s}īs'];
  }

  // ----- third class ---------------------------------------------------------------

  void _thirdClass(AdjectiveEntry a, Map<String, List<String>> cells) {
    _third(
      stem: a.stem,
      nomM: a.nominativeM,
      nomF: a.nominativeF,
      nomN: a.nominativeN,
      iStem: !a.consonantStem,
      cells: cells,
      prefix: '',
    );
  }

  /// Comparative: -ior (m/f), -ius (n), oblique stem -iōr-, consonant-stem
  /// endings (A&G §120).
  void _comparative(String nom, Map<String, List<String>> cells) {
    // melior → melius / meliōr-; plūs and other oddities come from overrides.
    final base = nom.endsWith('or') ? nom.substring(0, nom.length - 2) : nom;
    _third(stem: '${base}ōr', nomM: nom, nomF: nom, nomN: '${base}us', iStem: false, cells: cells, prefix: 'comp.');
  }

  void _third({
    required String stem,
    required String nomM,
    required String nomF,
    required String nomN,
    required bool iStem,
    required Map<String, List<String>> cells,
    required String prefix,
  }) {
    final abl = iStem ? '${stem}ī' : '${stem}e';
    final genPl = iStem ? '${stem}ium' : '${stem}um';
    final nPl = iStem ? '${stem}ia' : '${stem}a';
    for (final (g, nom) in [('m', nomM), ('f', nomF)]) {
      cells['${prefix}nom.sg.$g'] = [nom];
      cells['${prefix}voc.sg.$g'] = [nom];
      cells['${prefix}acc.sg.$g'] = ['${stem}em'];
      cells['${prefix}gen.sg.$g'] = ['${stem}is'];
      cells['${prefix}dat.sg.$g'] = ['${stem}ī'];
      cells['${prefix}abl.sg.$g'] = [abl];
      cells['${prefix}nom.pl.$g'] = ['${stem}ēs'];
      cells['${prefix}voc.pl.$g'] = ['${stem}ēs'];
      cells['${prefix}acc.pl.$g'] = iStem ? ['${stem}ēs', '${stem}īs'] : ['${stem}ēs'];
      cells['${prefix}gen.pl.$g'] = [genPl];
      cells['${prefix}dat.pl.$g'] = ['${stem}ibus'];
      cells['${prefix}abl.pl.$g'] = ['${stem}ibus'];
    }
    cells['${prefix}nom.sg.n'] = [nomN];
    cells['${prefix}voc.sg.n'] = [nomN];
    cells['${prefix}acc.sg.n'] = [nomN];
    cells['${prefix}gen.sg.n'] = ['${stem}is'];
    cells['${prefix}dat.sg.n'] = ['${stem}ī'];
    cells['${prefix}abl.sg.n'] = [abl];
    cells['${prefix}nom.pl.n'] = [nPl];
    cells['${prefix}voc.pl.n'] = [nPl];
    cells['${prefix}acc.pl.n'] = [nPl];
    cells['${prefix}gen.pl.n'] = [genPl];
    cells['${prefix}dat.pl.n'] = ['${stem}ibus'];
    cells['${prefix}abl.pl.n'] = ['${stem}ibus'];
  }
}
