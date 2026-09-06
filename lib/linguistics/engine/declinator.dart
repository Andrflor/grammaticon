/// Rule-based declension of nouns (Allen & Greenough §40–§98, §427).
///
/// The declinator adds regular endings to the stem of a [NounEntry]; the
/// irregular nominative singular is taken from the entry itself and any cell
/// no rule produces comes from the entry's overrides. Every legitimate surface
/// of a cell is kept (first = primary, the rest = free alternatives), so the
/// analyzer can report every analysis of a form.
library;

import '../model/grammar.dart';
import '../model/noun.dart';

/// Declined paradigm of one noun.
class NounParadigm {
  NounParadigm(this.noun, List<NounForm> forms) : forms = List.unmodifiable(forms) {
    for (final f in forms) {
      (_bySelector[f.analysis.selector] ??= []).add(f);
    }
  }

  final NounEntry noun;
  final List<NounForm> forms;
  final Map<String, List<NounForm>> _bySelector = {};

  /// All forms (primary and variants) of one cell (`acc.sg`).
  List<NounForm> cell(String selector) => _bySelector[selector] ?? const [];

  /// Primary form of one cell, or null.
  NounForm? primary(String selector) {
    for (final f in cell(selector)) {
      if (f.isPrimary) return f;
    }
    return null;
  }

  bool has(String selector) => _bySelector.containsKey(selector);
  Iterable<String> get selectors => _bySelector.keys;

  /// Reason why [selector] is absent, or null.
  AbsenceStatus? absenceFor(String selector) {
    for (final a in noun.absent) {
      if (a.matches(selector)) return a.status;
    }
    return null;
  }
}

class Declinator {
  const Declinator();

  NounParadigm decline(NounEntry n) {
    final cells = <String, List<String>>{};
    final numbers = switch (n.number) {
      NounNumber.ambo => Numerus.values,
      NounNumber.singulareTantum => [Numerus.singularis],
      NounNumber.pluraleTantum => [Numerus.pluralis],
    };
    for (final num in numbers) {
      for (final c in Casus.ordinary) {
        final surfaces = _regular(n, c, num);
        if (surfaces.isNotEmpty) cells['${c.key}.${num.key}'] = surfaces;
      }
      if (n.locative) {
        final loc = _locative(n, num);
        if (loc.isNotEmpty) cells['loc.${num.key}'] = loc;
      }
    }
    // Explicit cells replace the rule output for that cell.
    for (final e in n.overrides.entries) {
      cells[e.key] = List.of(e.value);
    }
    // Absent cells are removed (the reason stays on the entry).
    for (final a in n.absent) {
      cells.removeWhere((sel, _) => a.matches(sel));
    }
    final out = <NounForm>[];
    for (final e in cells.entries) {
      final parts = e.key.split('.');
      final casus = Casus.fromKey(parts[0]);
      final num = Numerus.fromKey(parts[1]);
      final seen = <String>{};
      for (var i = 0; i < e.value.length; i++) {
        final s = e.value[i];
        if (!seen.add(s)) continue;
        out.add(NounForm(s, NounAnalysis(lemmaId: n.id, casus: casus, number: num, gender: n.gender, declension: n.declension, variant: i == 0 ? VariantKind.norma : VariantKind.altera)));
      }
    }
    return NounParadigm(n, out);
  }

  // ----- endings -------------------------------------------------------------------

  List<String> _regular(NounEntry n, Casus c, Numerus num) {
    final s = n.stem;
    final sg = num == Numerus.singularis;
    switch (n.declension) {
      case Declension.prima: // A&G §41
        if (sg) {
          return switch (c) {
            Casus.nominativus || Casus.vocativus => [n.lemma],
            Casus.genetivus || Casus.dativus => ['${s}ae'],
            Casus.accusativus => ['${s}am'],
            Casus.ablativus => ['${s}ā'],
            Casus.locativus => const [],
          };
        }
        return switch (c) {
          Casus.nominativus || Casus.vocativus => ['${s}ae'],
          Casus.genetivus => ['${s}ārum'],
          Casus.dativus || Casus.ablativus => ['${s}īs'],
          Casus.accusativus => ['${s}ās'],
          Casus.locativus => const [],
        };
      case Declension.secunda: // A&G §45–§49
        if (n.isNeuter) {
          if (sg) {
            return switch (c) {
              Casus.nominativus || Casus.vocativus || Casus.accusativus => [n.lemma],
              Casus.genetivus => n.isIusStem ? ['${s}ī', '${s.substring(0, s.length - 1)}ī'] : ['${s}ī'],
              Casus.dativus || Casus.ablativus => ['${s}ō'],
              Casus.locativus => const [],
            };
          }
          return switch (c) {
            Casus.nominativus || Casus.vocativus || Casus.accusativus => ['${s}a'],
            Casus.genetivus => ['${s}ōrum'],
            Casus.dativus || Casus.ablativus => ['${s}īs'],
            Casus.locativus => const [],
          };
        }
        if (sg) {
          return switch (c) {
            Casus.nominativus => [n.lemma],
            // -us → -e; -ius → -ī (fīlī, Vergilī); puer, ager, vir keep the nominative.
            Casus.vocativus => n.isErStem ? [n.lemma] : (n.isIusStem ? ['${s.substring(0, s.length - 1)}ī'] : ['${s}e']),
            // -ius / -ium: gen. -iī, older -ī (A&G §49b).
            Casus.genetivus => n.isIusStem ? ['${s}ī', '${s.substring(0, s.length - 1)}ī'] : ['${s}ī'],
            Casus.dativus || Casus.ablativus => ['${s}ō'],
            Casus.accusativus => ['${s}um'],
            Casus.locativus => const [],
          };
        }
        return switch (c) {
          Casus.nominativus || Casus.vocativus => ['${s}ī'],
          Casus.genetivus => ['${s}ōrum'],
          Casus.dativus || Casus.ablativus => ['${s}īs'],
          Casus.accusativus => ['${s}ōs'],
          Casus.locativus => const [],
        };
      case Declension.tertia: // A&G §56–§71
        final iStem = n.thirdStem != ThirdStem.consonans;
        if (n.isNeuter) {
          final neuterI = n.thirdStem == ThirdStem.neutrumI;
          if (sg) {
            return switch (c) {
              Casus.nominativus || Casus.vocativus || Casus.accusativus => [n.lemma],
              Casus.genetivus => ['${s}is'],
              Casus.dativus => ['${s}ī'],
              Casus.ablativus => neuterI ? ['${s}ī'] : ['${s}e'],
              Casus.locativus => const [],
            };
          }
          return switch (c) {
            Casus.nominativus || Casus.vocativus || Casus.accusativus => neuterI ? ['${s}ia'] : ['${s}a'],
            Casus.genetivus => neuterI ? ['${s}ium'] : ['${s}um'],
            Casus.dativus || Casus.ablativus => ['${s}ibus'],
            Casus.locativus => const [],
          };
        }
        final pure = n.thirdStem == ThirdStem.vocalisIPura;
        if (sg) {
          return switch (c) {
            Casus.nominativus || Casus.vocativus => [n.lemma],
            Casus.genetivus => ['${s}is'],
            Casus.dativus => ['${s}ī'],
            Casus.accusativus => pure ? ['${s}im'] : ['${s}em'],
            Casus.ablativus => pure ? ['${s}ī'] : ['${s}e'],
            Casus.locativus => const [],
          };
        }
        return switch (c) {
          Casus.nominativus || Casus.vocativus => ['${s}ēs'],
          Casus.genetivus => iStem ? ['${s}ium'] : ['${s}um'],
          Casus.dativus || Casus.ablativus => ['${s}ibus'],
          // i-stems: acc. pl. -ēs or -īs (A&G §67b).
          Casus.accusativus => iStem ? ['${s}ēs', '${s}īs'] : ['${s}ēs'],
          Casus.locativus => const [],
        };
      case Declension.quarta: // A&G §89–§94
        if (n.isNeuter) {
          if (sg) {
            return switch (c) {
              Casus.nominativus || Casus.vocativus || Casus.accusativus || Casus.dativus || Casus.ablativus => [n.lemma],
              Casus.genetivus => ['${s}ūs'],
              Casus.locativus => const [],
            };
          }
          return switch (c) {
            Casus.nominativus || Casus.vocativus || Casus.accusativus => ['${s}ua'],
            Casus.genetivus => ['${s}uum'],
            Casus.dativus || Casus.ablativus => ['${s}ibus'],
            Casus.locativus => const [],
          };
        }
        if (sg) {
          return switch (c) {
            Casus.nominativus || Casus.vocativus => [n.lemma],
            Casus.genetivus => ['${s}ūs'],
            Casus.dativus => ['${s}uī'],
            Casus.accusativus => ['${s}um'],
            Casus.ablativus => ['${s}ū'],
            Casus.locativus => const [],
          };
        }
        return switch (c) {
          Casus.nominativus || Casus.vocativus || Casus.accusativus => ['${s}ūs'],
          Casus.genetivus => ['${s}uum'],
          Casus.dativus || Casus.ablativus => ['${s}ibus'],
          Casus.locativus => const [],
        };
      case Declension.quinta: // A&G §96–§98
        // ē of gen./dat. sg. is long after a vowel (diēī), short after a consonant (reī, fideī).
        final longE = s.endsWith('i');
        final genDat = longE ? '${s}ēī' : '${s}eī';
        if (sg) {
          return switch (c) {
            Casus.nominativus || Casus.vocativus => [n.lemma],
            Casus.genetivus || Casus.dativus => [genDat],
            Casus.accusativus => ['${s}em'],
            Casus.ablativus => ['${s}ē'],
            Casus.locativus => const [],
          };
        }
        return switch (c) {
          Casus.nominativus || Casus.vocativus || Casus.accusativus => ['${s}ēs'],
          Casus.genetivus => ['${s}ērum'],
          Casus.dativus || Casus.ablativus => ['${s}ēbus'],
          Casus.locativus => const [],
        };
    }
  }

  /// Locative (A&G §427): 1st sg. -ae, 2nd sg. -ī, 3rd sg. -ī (or -e),
  /// 4th/5th as ablative; plural = ablative plural.
  List<String> _locative(NounEntry n, Numerus num) {
    if (num == Numerus.pluralis) return _regular(n, Casus.ablativus, Numerus.pluralis);
    switch (n.declension) {
      case Declension.prima:
        return ['${n.stem}ae'];
      case Declension.secunda:
        return ['${n.stem}ī'];
      case Declension.tertia:
        return ['${n.stem}ī', '${n.stem}e'];
      case Declension.quarta:
      case Declension.quinta:
        return _regular(n, Casus.ablativus, Numerus.singularis);
    }
  }
}
