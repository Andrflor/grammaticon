/// Pedagogical helpers for nouns: dictionary entry, declension table and the
/// stem/ending segmentation where it is linguistically sound.
library;

import '../engine/declinator.dart';
import '../model/grammar.dart';
import '../model/noun.dart';
import 'paradigm_help.dart' show HelpRow, HelpTable;

/// Segmentation of a declined form into stem and ending.
class NounSegmentation {
  const NounSegmentation(this.stem, this.ending);
  final String stem;
  final String ending;
}

class DeclensionHelp {
  const DeclensionHelp(this.paradigm);
  final NounParadigm paradigm;
  NounEntry get noun => paradigm.noun;

  String classification() {
    final b = <String>['Dēclīnātiō ${noun.declension.latin.toLowerCase()}', noun.gender.latin.toLowerCase()];
    switch (noun.thirdStem) {
      case ThirdStem.consonans:
        if (noun.declension == Declension.tertia) b.add('thema cōnsonāns');
      case ThirdStem.vocalisI:
      case ThirdStem.vocalisIPura:
        b.add('thema in -i');
      case ThirdStem.neutrumI:
        b.add('neutrum in -i');
    }
    if (noun.pluralOnly) b.add('plūrāle tantum');
    if (noun.singularOnly) b.add('singulāre tantum');
    if (noun.locative) b.add('cum locātīvō');
    return b.join(' · ');
  }

  /// Six (or seven) rows × singular / plural.
  HelpTable table() {
    final rows = <HelpRow>[];
    final cases = [...Casus.ordinary, if (noun.locative) Casus.locativus];
    for (final c in cases) {
      final cells = <String>[];
      for (final n in Numerus.values) {
        final sel = '${c.key}.${n.key}';
        final forms = paradigm.cell(sel);
        if (forms.isEmpty) {
          cells.add(_absentMark(sel));
        } else {
          cells.add(forms.map((f) => f.surface).join(' / '));
        }
      }
      rows.add(HelpRow(c.latin, cells));
    }
    return HelpTable('${noun.lemma}, ${noun.genitive}, ${noun.gender.abbreviation}', const ['singulāris', 'plūrālis'], rows, note: noun.notes);
  }

  String _absentMark(String selector) {
    final st = paradigm.absenceFor(selector);
    if (st == null) return '—';
    return switch (st) {
      AbsenceStatus.nonExstat => '—',
      AbsenceStatus.nonAttestatur => '(nōn attest.)',
      AbsenceStatus.nonUsitatur => '(nōn ūsit.)',
      AbsenceStatus.datumDeest => '(dēest)',
    };
  }

  /// Stem + ending when the surface really is stem + ending. Irregular
  /// nominatives (rēx, corpus, Iuppiter) and suppletive cells (vīrēs, bōbus)
  /// return null rather than a misleading cut.
  NounSegmentation? segment(NounForm f) {
    final s = f.surface;
    final stem = noun.stem;
    if (stem.isEmpty || !s.startsWith(stem) || s.length == stem.length) return null;
    return NounSegmentation(stem, s.substring(stem.length));
  }

  /// The ending of a form as displayed in corrections (`-am`), or null.
  String? ending(NounForm f) {
    final seg = segment(f);
    return seg == null ? null : '-${seg.ending}';
  }
}
