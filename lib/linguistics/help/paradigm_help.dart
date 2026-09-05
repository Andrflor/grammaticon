/// Pedagogical helpers: principal parts, relevant tables, stem/ending
/// decomposition where it is linguistically sound, and a near-form contrast.
library;

import '../engine/conjugator.dart';
import '../model/analysis.dart';
import '../model/grammar.dart';
import '../model/verb.dart';

class HelpRow {
  const HelpRow(this.label, this.cells);
  final String label;

  /// Surface per column, '—' when absent.
  final List<String> cells;
}

class HelpTable {
  const HelpTable(this.title, this.columns, this.rows, {this.note = ''});
  final String title;
  final List<String> columns;
  final List<HelpRow> rows;
  final String note;
}

/// Decomposition of a form into stem, tense marker and ending.
class Decomposition {
  const Decomposition(this.stem, this.marker, this.ending, {this.note = ''});
  final String stem;
  final String marker;
  final String ending;
  final String note;

  String get display => [stem, if (marker.isNotEmpty) marker, if (ending.isNotEmpty) ending].join(' + ');
}

class ParadigmHelp {
  const ParadigmHelp(this.paradigm);
  final Paradigm paradigm;
  VerbEntry get verb => paradigm.verb;

  String principalParts() => verb.principalParts.where((p) => p != '-').join(', ');

  String classification() {
    final b = <String>[];
    b.add('Coniugātiō ${verb.conjugation.latin.toLowerCase()}');
    b.add(verb.kind.latin.toLowerCase());
    if (verb.intransitive) b.add('intrānsitīvum');
    return b.join(' · ');
  }

  static const _personLabels = ['1 sg', '2 sg', '3 sg', '1 pl', '2 pl', '3 pl'];

  /// Six-row table for a mood/voice across the given tenses.
  HelpTable finiteTable(Mood mood, Voice voice, List<Tense> tenses) {
    final rows = <HelpRow>[];
    for (var i = 0; i < 6; i++) {
      final (p, n) = kPersons[i];
      final cells = <String>[];
      for (final t in tenses) {
        final base = '${mood.key}.${t.key}.${voice.key}.${p.key}.${n.key}';
        final f = paradigm.primary(base) ?? paradigm.primary('$base.m');
        if (f != null) {
          cells.add(f.surface);
        } else {
          cells.add(_absentMark(base));
        }
      }
      rows.add(HelpRow(_personLabels[i], cells));
    }
    return HelpTable('${mood.latin} ${voice.latin.toLowerCase()}', tenses.map((t) => t.latin).toList(), rows);
  }

  HelpTable imperativeTable() {
    final rows = <HelpRow>[];
    for (final (label, sel) in [('2 sg', '2.sg'), ('3 sg', '3.sg'), ('2 pl', '2.pl'), ('3 pl', '3.pl')]) {
      final cells = <String>[];
      for (final t in [Tense.praesens, Tense.futurum]) {
        for (final v in Voice.values) {
          final base = 'imp.${t.key}.${v.key}.$sel';
          cells.add(paradigm.primary(base)?.surface ?? _absentMark(base));
        }
      }
      rows.add(HelpRow(label, cells));
    }
    return HelpTable('Imperātīvus', const ['praes. act.', 'praes. pass.', 'fut. act.', 'fut. pass.'], rows);
  }

  HelpTable nominalTable() {
    String cell(String sel) => paradigm.primary(sel)?.surface ?? _absentMark(sel);
    final rows = <HelpRow>[
      HelpRow('Īnf. praes.', [cell('inf.praes.act'), cell('inf.praes.pass')]),
      HelpRow('Īnf. perf.', [cell('inf.perf.act'), cell('inf.perf.pass.nom.sg.m')]),
      HelpRow('Īnf. fut.', [cell('inf.fut.act.nom.sg.m'), cell('inf.fut.pass')]),
      HelpRow('Part. praes.', [cell('part.praes.act.nom.sg.m'), '—']),
      HelpRow('Part. perf.', ['—', cell('part.perf.pass.nom.sg.m')]),
      HelpRow('Part. fut.', [cell('part.fut.act.nom.sg.m'), cell('gdv.nom.sg.m')]),
      HelpRow('Gerundium', [cell('ger.gen'), '']),
      HelpRow('Supīnum', [cell('sup.acc'), cell('sup.abl')]),
    ];
    return HelpTable('Fōrmae nōminālēs', const ['āctīvum', 'passīvum'], rows, note: 'Participium futūrī passīvī = gerundīvum.');
  }

  String _absentMark(String selector) {
    final st = paradigm.absenceFor(selector);
    if (st == null) return '—';
    switch (st) {
      case AbsenceStatus.nonExstat:
        return '—';
      case AbsenceStatus.nonAttestatur:
        return '(nōn attest.)';
      case AbsenceStatus.nonUsitatur:
        return '(nōn ūsit.)';
      case AbsenceStatus.datumDeest:
        return '(dēest)';
    }
  }

  /// Tables most relevant to a given form.
  List<HelpTable> tablesFor(Analysis a) {
    final out = <HelpTable>[];
    if (a.isFinite && a.mood != Mood.imperativus && a.tense != null && a.voice != null) {
      final tenses = a.mood == Mood.indicativus ? Tense.values : [Tense.praesens, Tense.imperfectum, Tense.perfectum, Tense.plusquamperfectum];
      out.add(finiteTable(a.mood, a.voice!, tenses));
    } else if (a.mood == Mood.imperativus) {
      out.add(imperativeTable());
    } else if (a.periphrasis != Periphrasis.nulla && a.isFinite) {
      out.add(finiteTable(a.mood, a.voice!, a.mood == Mood.indicativus ? Tense.values : [Tense.praesens, Tense.imperfectum, Tense.perfectum, Tense.plusquamperfectum]));
    }
    out.add(nominalTable());
    return out;
  }

  /// Stem/marker/ending analysis for regular, non-composite forms. Returns
  /// null when a segmentation would be misleading (irregular verbs, composite
  /// forms, nominal forms other than participles).
  Decomposition? decompose(FormEntry f) {
    final a = f.analysis;
    if (verb.isIrregular || verb.isDefective || a.composite || !a.isPrimary && a.variant != VariantKind.altera) return null;
    if (a.mood == Mood.participium || a.mood == Mood.gerundium || a.mood == Mood.gerundivum || a.mood == Mood.supinum || a.mood == Mood.infinitivus) {
      return null;
    }
    final s = f.surface;
    if (a.tense != null && a.tense!.isPerfectSystem && a.voice == Voice.activum) {
      final stem = verb.perfectStem;
      if (stem == null || !s.startsWith(stem)) return null;
      final rest = s.substring(stem.length);
      final marker = switch (a.tense) {
        Tense.plusquamperfectum => a.mood == Mood.subiunctivus ? 'isse' : 'era',
        Tense.futurumExactum => 'eri',
        Tense.perfectum => a.mood == Mood.subiunctivus ? 'eri' : '',
        _ => '',
      };
      if (marker.isNotEmpty && rest.startsWith(marker)) {
        return Decomposition(stem, marker, rest.substring(marker.length), note: 'thema perfectī + signum temporis + dēsinentia');
      }
      if (marker.isNotEmpty && a.tense == Tense.plusquamperfectum && rest.startsWith('erā')) {
        return Decomposition(stem, 'erā', rest.substring(3), note: 'thema perfectī + signum temporis + dēsinentia');
      }
      if (marker == 'eri' && rest.startsWith('erī')) return Decomposition(stem, 'erī', rest.substring(3), note: 'thema perfectī + signum temporis + dēsinentia');
      if (a.tense == Tense.plusquamperfectum && a.mood == Mood.subiunctivus && rest.startsWith('issē')) {
        return Decomposition(stem, 'issē', rest.substring(4), note: 'thema perfectī + signum temporis + dēsinentia');
      }
      return Decomposition(stem, '', rest, note: 'thema perfectī + dēsinentia');
    }
    // Present system: stem = infinitive stem without the final vowel handling.
    final base = _presentBase();
    if (base == null || !s.startsWith(base)) return null;
    final rest = s.substring(base.length);
    if (a.tense == Tense.imperfectum && a.mood == Mood.indicativus) {
      final i = rest.indexOf('b');
      if (i > 0) return Decomposition('$base${rest.substring(0, i)}', rest.substring(i, i + 2), rest.substring(i + 2), note: 'thema praesentis + -ba- + dēsinentia');
    }
    if (a.tense == Tense.futurum && a.mood == Mood.indicativus && (verb.conjugation == Conjugation.prima || verb.conjugation == Conjugation.secunda)) {
      final i = rest.indexOf('b');
      if (i > 0) return Decomposition('$base${rest.substring(0, i)}', rest.substring(i, i + 1), rest.substring(i + 1), note: 'thema praesentis + -b- + dēsinentia');
    }
    if (a.tense == Tense.imperfectum && a.mood == Mood.subiunctivus) {
      final i = rest.indexOf('r');
      if (i > 0) return Decomposition('$base${rest.substring(0, i)}', 'r', rest.substring(i + 1), note: 'īnfīnītīvus + dēsinentia');
    }
    return Decomposition(base, '', rest, note: 'thema + vōcālis + dēsinentia');
  }

  String? _presentBase() {
    final inf = verb.infinitive;
    String? cut(String suf) => inf.endsWith(suf) ? inf.substring(0, inf.length - suf.length) : null;
    switch (verb.conjugation) {
      case Conjugation.prima:
        return verb.isDeponent ? cut('ārī') : (cut('āre') ?? cut('are'));
      case Conjugation.secunda:
        return verb.isDeponent ? cut('ērī') : cut('ēre');
      case Conjugation.tertia:
      case Conjugation.tertiaIo:
        return verb.isDeponent ? cut('ī') : cut('ere');
      case Conjugation.quarta:
        return verb.isDeponent ? cut('īrī') : cut('īre');
      case Conjugation.anomala:
        return null;
    }
  }

  /// A neighbouring form to contrast with (same person/number, adjacent tense,
  /// or same tense, other number).
  FormEntry? nearForm(Analysis a) {
    if (!a.isFinite || a.tense == null) return null;
    final tenses = Tense.values;
    final i = tenses.indexOf(a.tense!);
    for (final j in [i - 1, i + 1]) {
      if (j < 0 || j >= tenses.length) continue;
      final f = paradigm.primary(a.copyWith(tense: tenses[j]).selector);
      if (f != null) return f;
    }
    final other = a.copyWith(number: a.number == Numerus.singularis ? Numerus.pluralis : Numerus.singularis);
    return paradigm.primary(other.selector);
  }
}
