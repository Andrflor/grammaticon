/// Pedagogical helpers for any nominal lexeme: classification line, help
/// tables (declension by gender and degree, pronoun paradigm, degrees of an
/// adverb) and the stem/ending segmentation where it is sound.
library;

import '../engine/nominal_analyzer.dart';
import '../model/adjective.dart';
import '../model/adverb.dart';
import '../model/grammar.dart';
import '../model/nominal.dart';
import '../model/noun.dart';
import '../model/numeral.dart';
import '../model/pronoun.dart';
import 'declension_help.dart';
import 'paradigm_help.dart' show HelpRow, HelpTable;

class NominalHelp {
  const NominalHelp(this.analyzer, this.lexeme);
  final NominalAnalyzer analyzer;
  final Lexeme lexeme;

  /// One line: class and pattern of the word.
  String classification() {
    final l = lexeme;
    if (l is NounEntry) return DeclensionHelp(analyzer.nouns.paradigmOf(l.id)).classification();
    if (l is AdjectiveEntry) {
      final b = <String>['Adiectīvum', l.cls == AdjClass.primaSecunda ? 'prīmae et secundae classis' : 'tertiae classis'];
      if (l.isThirdClass) b.add(switch (l.terminations) { 1 => 'ūna termīnātiō', 2 => 'duae termīnātiōnēs', _ => 'trēs termīnātiōnēs' });
      if (l.isErType) b.add('in -er');
      if (l.pronominal) b.add('prōnōmināle (-īus, -ī)');
      if (l.consonantStem) b.add('thema cōnsonāns');
      if (l.tags.contains('possessivum')) b.add('possessīvum');
      if (l.tags.contains('ordinale')) b.add('ōrdināle');
      if (l.tags.contains('correlativum')) b.add('correlātīvum');
      b.add(switch (l.comparison) {
        ComparisonKind.regularis => 'comparātiō regulāris',
        ComparisonKind.irregularis => 'comparātiō irregulāris',
        ComparisonKind.periphrastica => 'comparātiō perīphrastica (magis, maximē)',
        ComparisonKind.nulla => 'sine comparātiōne',
      });
      return b.join(' · ');
    }
    if (l is PronounEntry) {
      final b = <String>['Prōnōmen', l.kind.latin.toLowerCase()];
      if (l.person != null) b.add('${l.person!.latin.toLowerCase()} persōna');
      if (!l.hasGender) b.add('sine genere');
      return b.join(' · ');
    }
    if (l is NumeralEntry) return 'Numerāle ${l.kind.latin.toLowerCase()} · ${l.roman} · ${l.isIndeclinable ? 'indēclīnābile' : 'dēclīnābile'}';
    if (l is AdverbEntry) return 'Adverbium${l.adjectiveId == null ? '' : ' ab adiectīvō ${analyzer.maybeLexeme(l.adjectiveId!)?.lemma ?? l.adjectiveId}'}';
    return l.wordClass.latin;
  }

  /// Tables to show: nouns one table; adjectives one table per degree
  /// (positive first, or the target's degree first); pronouns one table;
  /// numerals one when declinable; adverbs a degree list.
  List<HelpTable> tables({NominalForm? highlight}) {
    final l = lexeme;
    if (l is NounEntry) return [DeclensionHelp(analyzer.nouns.paradigmOf(l.id)).table()];
    if (l is AdjectiveEntry) {
      final degrees = <Degree>[
        if (highlight != null) highlight.analysis.degree,
        for (final d in Degree.values)
          if (highlight == null || d != highlight.analysis.degree) d,
      ];
      return [
        for (final d in degrees)
          if (analyzer.formsOf(l.id).any((f) => f.analysis.degree == d)) _genderTable(l.id, d, '${l.entry} · ${d.latin.toLowerCase()}'),
      ];
    }
    if (l is PronounEntry) {
      if (l.cells.containsKey('indecl')) return [HelpTable(l.entry, const ['fōrma'], [HelpRow('indēclīnābile', [l.cells['indecl']!.join(' / ')])], note: l.notes)];
      return [l.hasGender ? _genderTable(l.id, Degree.positivus, l.entry) : _plainTable(l.id, l.entry)];
    }
    if (l is NumeralEntry) {
      if (l.isIndeclinable) return [HelpTable(l.entry, const ['fōrma'], [HelpRow('indēclīnābile', [l.lemma])], note: l.notes)];
      return [_genderTable(l.id, Degree.positivus, l.entry)];
    }
    if (l is AdverbEntry) {
      return [
        HelpTable(l.dictionaryEntry, const ['fōrma'], [
          HelpRow('positīvus', [l.lemma]),
          HelpRow('comparātīvus', [l.comparative.isEmpty ? '—' : l.comparative.join(' / ')]),
          HelpRow('superlātīvus', [l.superlative.isEmpty ? '—' : l.superlative.join(' / ')]),
        ], note: l.notes),
      ];
    }
    return const [];
  }

  /// Rows: cases × (sg / pl), columns: singular and plural (no gender).
  HelpTable _plainTable(String id, String title) {
    final rows = <HelpRow>[];
    for (final c in Casus.ordinary) {
      final cells = <String>[];
      for (final n in Numerus.values) {
        final fs = analyzer.cell(id, '${c.key}.${n.key}');
        cells.add(fs.isEmpty ? '—' : fs.map((f) => f.surface).join(' / '));
      }
      if (cells.every((x) => x == '—')) continue;
      rows.add(HelpRow(c.latin, cells));
    }
    return HelpTable(title, const ['singulāris', 'plūrālis'], rows, note: lexeme.notes);
  }

  /// Rows: cases; columns: m / f / n for one number, singular then plural
  /// stacked (six columns: sg m f n · pl m f n).
  HelpTable _genderTable(String id, Degree degree, String title) {
    final prefix = degree == Degree.positivus ? '' : '${degree.key}.';
    final rows = <HelpRow>[];
    final numbers = Numerus.values.where((n) => analyzer.formsOf(id).any((f) => f.analysis.number == n && f.analysis.degree == degree)).toList();
    for (final c in Casus.ordinary) {
      final cells = <String>[];
      var any = false;
      for (final n in numbers) {
        for (final g in Gender.values) {
          final fs = analyzer.cell(id, '$prefix${c.key}.${n.key}.${g.key}');
          if (fs.isNotEmpty) any = true;
          cells.add(fs.isEmpty ? '—' : fs.map((f) => f.surface).join(' / '));
        }
      }
      if (any) rows.add(HelpRow(c.latin, cells));
    }
    final columns = [for (final n in numbers) for (final g in ['m.', 'f.', 'n.']) '${n == Numerus.singularis ? 'sg.' : 'pl.'} $g'];
    return HelpTable(title, columns, rows, note: lexeme.notes);
  }

  /// Stem + ending when the surface really is stem + ending; null for bare
  /// nominatives, suppletive cells and pronouns.
  ({String stem, String ending})? segment(NominalForm f) {
    final l = lexeme;
    String? stem;
    if (l is NounEntry) {
      stem = l.stem;
    } else if (l is AdjectiveEntry) {
      stem = switch (f.analysis.degree) {
        Degree.positivus => l.stem,
        Degree.comparativus => _comparativeStem(l),
        Degree.superlativus => l.superlativeStem ?? _regularSuperlative(l),
      };
    } else if (l is NumeralEntry && !l.isIndeclinable) {
      stem = _commonPrefix(analyzer.formsOf(l.id).map((x) => x.surface).toList());
    }
    if (stem == null || stem.isEmpty || !f.surface.startsWith(stem) || f.surface.length == stem.length) return null;
    return (stem: stem, ending: f.surface.substring(stem.length));
  }

  String? _comparativeStem(AdjectiveEntry a) {
    final nom = a.comparative ?? '${a.stem}ior';
    return nom.endsWith('or') ? '${nom.substring(0, nom.length - 2)}ōr' : null;
  }

  String _regularSuperlative(AdjectiveEntry a) {
    if (a.tags.contains('ilis')) return '${a.stem}lim';
    if (a.isErType || (a.isThirdClass && a.nominativeM.endsWith('er'))) return '${a.nominativeM}rim';
    return '${a.stem}issim';
  }

  static String _commonPrefix(List<String> xs) {
    if (xs.isEmpty) return '';
    var p = xs.first;
    for (final x in xs) {
      var i = 0;
      while (i < p.length && i < x.length && p[i] == x[i]) {
        i++;
      }
      p = p.substring(0, i);
    }
    return p;
  }

  /// The ending as displayed in corrections (`-am`), or null.
  String? ending(NominalForm f) {
    final seg = segment(f);
    return seg == null ? null : '-${seg.ending}';
  }
}
