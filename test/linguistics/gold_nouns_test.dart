// Gold-table tests for nouns: forms typed independently from Allen &
// Greenough, *New Latin Grammar* (1903), DCC edition (§40–§98, §427). They do
// not reuse the declinator's rules, so they check linguistic correctness
// rather than internal consistency.
import 'package:flutter_test/flutter_test.dart';
import 'package:latin_game/linguistics/engine/declinator.dart';
import 'package:latin_game/linguistics/engine/noun_analyzer.dart';
import 'package:latin_game/linguistics/lexicon/nouns.dart';
import 'package:latin_game/linguistics/model/grammar.dart';

const _d = Declinator();
NounParadigm _p(String id) => _d.decline(kNouns.firstWhere((n) => n.id == id));

const _order = ['nom', 'voc', 'acc', 'gen', 'dat', 'abl'];

/// Asserts the six primary forms of one number, in the order
/// nom, voc, acc, gen, dat, abl ('—' for an absent cell).
void _six(String id, String number, List<String> expected) {
  final p = _p(id);
  final got = [for (final c in _order) p.primary('$c.$number')?.surface ?? '—'];
  expect(got, expected, reason: '$id $number');
}

/// Asserts the exact set of surfaces of one cell (primary and alternatives).
void _cell(String id, String selector, List<String> expected) {
  expect(_p(id).cell(selector).map((f) => f.surface).toList(), expected, reason: '$id $selector');
}

void _none(String id, String selector) {
  expect(_p(id).has(selector), isFalse, reason: '$id should have no $selector');
}

void main() {
  group('A&G §41–43 first declension', () {
    test('rosa', () {
      _six('rosa', 'sg', ['rosa', 'rosa', 'rosam', 'rosae', 'rosae', 'rosā']);
      _six('rosa', 'pl', ['rosae', 'rosae', 'rosās', 'rosārum', 'rosīs', 'rosīs']);
    });
    test('masculines poēta, nauta keep the feminine endings', () {
      _six('poeta', 'sg', ['poēta', 'poēta', 'poētam', 'poētae', 'poētae', 'poētā']);
      expect(_p('nauta').noun.gender, Gender.masculinum);
    });
    test('dea and fīlia: dative/ablative plural -ābus (§43e)', () {
      _cell('dea', 'dat.pl', ['deābus']);
      _cell('dea', 'abl.pl', ['deābus']);
      _cell('filia', 'dat.pl', ['fīliābus', 'fīliīs']);
    });
    test('Rōma: singular only, locative Rōmae; Athēnae: plural only, locative Athēnīs', () {
      _cell('roma', 'loc.sg', ['Rōmae']);
      _none('roma', 'nom.pl');
      _cell('athenae', 'loc.pl', ['Athēnīs']);
      _six('athenae', 'pl', ['Athēnae', 'Athēnae', 'Athēnās', 'Athēnārum', 'Athēnīs', 'Athēnīs']);
      _none('athenae', 'nom.sg');
    });
  });

  group('A&G §45–52 second declension', () {
    test('servus', () {
      _six('servus', 'sg', ['servus', 'serve', 'servum', 'servī', 'servō', 'servō']);
      _six('servus', 'pl', ['servī', 'servī', 'servōs', 'servōrum', 'servīs', 'servīs']);
    });
    test('bellum (neuter): nominative = accusative = vocative, plural -a', () {
      _six('bellum', 'sg', ['bellum', 'bellum', 'bellum', 'bellī', 'bellō', 'bellō']);
      _six('bellum', 'pl', ['bella', 'bella', 'bella', 'bellōrum', 'bellīs', 'bellīs']);
    });
    test('puer keeps e, ager drops it, vir (§47)', () {
      _six('puer', 'sg', ['puer', 'puer', 'puerum', 'puerī', 'puerō', 'puerō']);
      _six('ager', 'sg', ['ager', 'ager', 'agrum', 'agrī', 'agrō', 'agrō']);
      _six('vir', 'pl', ['virī', 'virī', 'virōs', 'virōrum', 'virīs', 'virīs']);
    });
    test('fīlius: vocative fīlī, genitive fīliī / fīlī (§49b)', () {
      _cell('filius', 'voc.sg', ['fīlī']);
      _cell('filius', 'gen.sg', ['fīliī', 'fīlī']);
      _cell('consilium', 'gen.sg', ['cōnsiliī', 'cōnsilī']);
      _cell('consilium', 'voc.sg', ['cōnsilium']);
    });
    test('deus (§49c)', () {
      _six('deus', 'sg', ['deus', 'deus', 'deum', 'deī', 'deō', 'deō']);
      _cell('deus', 'nom.pl', ['dī', 'deī', 'diī']);
      _cell('deus', 'gen.pl', ['deōrum', 'deum']);
      _cell('deus', 'dat.pl', ['dīs', 'deīs', 'diīs']);
      _cell('deus', 'acc.pl', ['deōs']);
    });
    test('castra, arma: plural only', () {
      _six('castra', 'pl', ['castra', 'castra', 'castra', 'castrōrum', 'castrīs', 'castrīs']);
      _none('castra', 'nom.sg');
    });
    test('humus, Corinthus: feminine, locative -ī (§427)', () {
      _cell('humus', 'loc.sg', ['humī']);
      _cell('corinthus', 'loc.sg', ['Corinthī']);
      expect(_p('humus').noun.gender, Gender.femininum);
    });
  });

  group('A&G §56–71 third declension', () {
    test('rēx (consonant stem)', () {
      _six('rex', 'sg', ['rēx', 'rēx', 'rēgem', 'rēgis', 'rēgī', 'rēge']);
      _six('rex', 'pl', ['rēgēs', 'rēgēs', 'rēgēs', 'rēgum', 'rēgibus', 'rēgibus']);
      _cell('rex', 'acc.pl', ['rēgēs']);
    });
    test('corpus, nōmen, caput, iter (neuter consonant stems)', () {
      _six('corpus', 'sg', ['corpus', 'corpus', 'corpus', 'corporis', 'corporī', 'corpore']);
      _six('corpus', 'pl', ['corpora', 'corpora', 'corpora', 'corporum', 'corporibus', 'corporibus']);
      _six('nomen', 'pl', ['nōmina', 'nōmina', 'nōmina', 'nōminum', 'nōminibus', 'nōminibus']);
      _six('caput', 'sg', ['caput', 'caput', 'caput', 'capitis', 'capitī', 'capite']);
      _six('iter', 'sg', ['iter', 'iter', 'iter', 'itineris', 'itinerī', 'itinere']);
    });
    test('pater, canis, iuvenis: consonant stems despite the parisyllabic form (§71)', () {
      _cell('pater', 'gen.pl', ['patrum']);
      _cell('canis', 'gen.pl', ['canum']);
      _cell('iuvenis', 'gen.pl', ['iuvenum']);
    });
    test('cīvis, hostis (i-stems): -ium, acc. pl. -ēs / -īs (§66–67)', () {
      _six('civis', 'sg', ['cīvis', 'cīvis', 'cīvem', 'cīvis', 'cīvī', 'cīve']);
      _cell('civis', 'gen.pl', ['cīvium']);
      _cell('civis', 'acc.pl', ['cīvēs', 'cīvīs']);
      _cell('hostis', 'gen.pl', ['hostium']);
    });
    test('monosyllables urbs, nox, pars, mōns: -ium', () {
      _cell('urbs', 'gen.pl', ['urbium']);
      _cell('nox', 'gen.pl', ['noctium']);
      _cell('pars', 'gen.pl', ['partium']);
      _six('mons', 'sg', ['mōns', 'mōns', 'montem', 'montis', 'montī', 'monte']);
    });
    test('turris, nāvis, ignis: -im / -ī alternatives (§75–76)', () {
      _cell('turris', 'acc.sg', ['turrim', 'turrem']);
      _cell('turris', 'abl.sg', ['turrī', 'turre']);
      _cell('navis', 'acc.sg', ['nāvem', 'nāvim']);
      _cell('navis', 'abl.sg', ['nāve', 'nāvī']);
      _cell('ignis', 'abl.sg', ['ignī', 'igne']);
    });
    test('mare, animal (neuter i-stems): abl. -ī, plural -ia, -ium (§68)', () {
      _six('mare', 'sg', ['mare', 'mare', 'mare', 'maris', 'marī', 'marī']);
      _six('mare', 'pl', ['maria', 'maria', 'maria', 'marium', 'maribus', 'maribus']);
      _six('animal', 'sg', ['animal', 'animal', 'animal', 'animālis', 'animālī', 'animālī']);
      _six('animal', 'pl', ['animālia', 'animālia', 'animālia', 'animālium', 'animālibus', 'animālibus']);
      _six('moenia', 'pl', ['moenia', 'moenia', 'moenia', 'moenium', 'moenibus', 'moenibus']);
    });
    test('cīvitās, aetās: -um / -ium; os: ossium (§71)', () {
      _cell('civitas', 'gen.pl', ['cīvitātum', 'cīvitātium']);
      _cell('os', 'gen.pl', ['ossium']);
      _six('os', 'pl', ['ossa', 'ossa', 'ossa', 'ossium', 'ossibus', 'ossibus']);
    });
    test('irregular vīs, bōs, senex, Iuppiter (§79)', () {
      _six('vis', 'sg', ['vīs', 'vīs', 'vim', 'vīs', 'vī', 'vī']);
      _six('vis', 'pl', ['vīrēs', 'vīrēs', 'vīrēs', 'vīrium', 'vīribus', 'vīribus']);
      _cell('vis', 'acc.pl', ['vīrēs', 'vīrīs']);
      _six('bos', 'sg', ['bōs', 'bōs', 'bovem', 'bovis', 'bovī', 'bove']);
      _cell('bos', 'gen.pl', ['boum']);
      _cell('bos', 'dat.pl', ['bōbus', 'būbus']);
      _six('senex', 'sg', ['senex', 'senex', 'senem', 'senis', 'senī', 'sene']);
      _cell('senex', 'gen.pl', ['senum']);
      _six('iuppiter', 'sg', ['Iuppiter', 'Iuppiter', 'Iovem', 'Iovis', 'Iovī', 'Iove']);
      _none('iuppiter', 'nom.pl');
    });
    test('locatives Carthāginī / Carthāgine, rūrī / rūre (§427)', () {
      _cell('carthago', 'loc.sg', ['Carthāginī', 'Carthāgine']);
      _cell('rus', 'loc.sg', ['rūrī', 'rūre']);
      _none('rus', 'nom.pl');
    });
  });

  group('A&G §89–94 fourth declension', () {
    test('manus', () {
      _six('manus', 'sg', ['manus', 'manus', 'manum', 'manūs', 'manuī', 'manū']);
      _six('manus', 'pl', ['manūs', 'manūs', 'manūs', 'manuum', 'manibus', 'manibus']);
    });
    test('cornū (neuter)', () {
      _six('cornu', 'sg', ['cornū', 'cornū', 'cornū', 'cornūs', 'cornū', 'cornū']);
      _six('cornu', 'pl', ['cornua', 'cornua', 'cornua', 'cornuum', 'cornibus', 'cornibus']);
    });
    test('tribus, lacus, portus: -ubus (§92c); senātus: senātī (§92a)', () {
      _cell('tribus', 'dat.pl', ['tribubus']);
      _cell('lacus', 'abl.pl', ['lacubus']);
      _cell('portus', 'dat.pl', ['portibus', 'portubus']);
      _cell('senatus', 'gen.sg', ['senātūs', 'senātī']);
    });
    test('domus (§93) mixes second and fourth declension forms; locative domī', () {
      _six('domus', 'sg', ['domus', 'domus', 'domum', 'domūs', 'domuī', 'domō']);
      _cell('domus', 'dat.sg', ['domuī', 'domō']);
      _cell('domus', 'abl.sg', ['domō', 'domū']);
      _cell('domus', 'gen.pl', ['domuum', 'domōrum']);
      _cell('domus', 'acc.pl', ['domōs', 'domūs']);
      _cell('domus', 'loc.sg', ['domī']);
      _cell('domus', 'dat.pl', ['domibus']);
    });
  });

  group('A&G §96–98 fifth declension', () {
    test('rēs and diēs are complete; ē short after a consonant (reī), long after a vowel (diēī)', () {
      _six('res', 'sg', ['rēs', 'rēs', 'rem', 'reī', 'reī', 'rē']);
      _six('res', 'pl', ['rēs', 'rēs', 'rēs', 'rērum', 'rēbus', 'rēbus']);
      _six('dies', 'sg', ['diēs', 'diēs', 'diem', 'diēī', 'diēī', 'diē']);
      _six('dies', 'pl', ['diēs', 'diēs', 'diēs', 'diērum', 'diēbus', 'diēbus']);
      expect(_p('dies').noun.gender, Gender.masculinum);
    });
    test('spēs, aciēs: plural nominative/accusative only; fidēs singular only (§98b)', () {
      _six('spes', 'sg', ['spēs', 'spēs', 'spem', 'speī', 'speī', 'spē']);
      _six('spes', 'pl', ['spēs', 'spēs', 'spēs', '—', '—', '—']);
      expect(_p('spes').absenceFor('gen.pl'), AbsenceStatus.nonUsitatur);
      _none('fides', 'nom.pl');
      _six('fides', 'sg', ['fidēs', 'fidēs', 'fidem', 'fideī', 'fideī', 'fidē']);
    });
  });

  group('no invented forms', () {
    test('the locative exists only where declared', () {
      for (final n in kNouns) {
        final p = _d.decline(n);
        final loc = p.forms.where((f) => f.analysis.casus == Casus.locativus);
        expect(loc.isNotEmpty, n.locative, reason: n.id);
      }
    });
    test('singular-only and plural-only nouns have no forms of the other number', () {
      for (final n in kNouns) {
        final p = _d.decline(n);
        if (n.singularOnly) expect(p.forms.any((f) => f.analysis.number == Numerus.pluralis), isFalse, reason: n.id);
        if (n.pluralOnly) expect(p.forms.any((f) => f.analysis.number == Numerus.singularis), isFalse, reason: n.id);
      }
    });
    test('the dictionary entry appears in its own paradigm', () {
      for (final n in kNouns) {
        final p = _d.decline(n);
        final surfaces = p.forms.map((f) => f.surface).toSet();
        expect(surfaces, contains(n.lemma), reason: '${n.id} lemma');
        expect(surfaces, contains(n.genitive), reason: '${n.id} genitive');
      }
    });
    test('every neuter has nominative = accusative = vocative in both numbers', () {
      for (final n in kNouns.where((n) => n.isNeuter)) {
        final p = _d.decline(n);
        for (final num in ['sg', 'pl']) {
          final nom = p.primary('nom.$num')?.surface;
          if (nom == null) continue;
          expect(p.primary('acc.$num')?.surface, nom, reason: '${n.id} acc.$num');
          expect(p.primary('voc.$num')?.surface, nom, reason: '${n.id} voc.$num');
        }
      }
    });
  });

  group('analyzer: all valid analyses are kept', () {
    final analyzer = NounAnalyzer(kNouns, const Declinator());
    test('rosae is genitive, dative singular and nominative, vocative plural', () {
      final a = analyzer.analyze('rosae').map((f) => f.analysis.selector).toSet();
      expect(a, {'gen.sg', 'dat.sg', 'nom.pl', 'voc.pl'});
    });
    test('rosā (ablative) differs from rosa by quantity; the loose index merges them', () {
      expect(analyzer.analyze('rosā').map((f) => f.analysis.selector).toSet(), {'abl.sg'});
      expect(analyzer.analyze('rosa').map((f) => f.analysis.selector).toSet(), {'nom.sg', 'voc.sg'});
      expect(analyzer.analyzeLoose('rosa').map((f) => f.analysis.selector).toSet(), {'nom.sg', 'voc.sg', 'abl.sg'});
    });
    test('manus is nominative/vocative singular; manūs adds genitive singular and the plural', () {
      expect(analyzer.analyze('manus').map((f) => f.analysis.selector).toSet(), {'nom.sg', 'voc.sg'});
      expect(analyzer.analyze('manūs').map((f) => f.analysis.selector).toSet(), {'gen.sg', 'nom.pl', 'voc.pl', 'acc.pl'});
    });
    test('vīs is nominative, vocative and genitive singular', () {
      expect(analyzer.analyze('vīs').map((f) => f.analysis.selector).toSet(), {'nom.sg', 'voc.sg', 'gen.sg'});
    });
    test('the locative is a separate analysis (Rōmae)', () {
      expect(analyzer.analyze('Rōmae').map((f) => f.analysis.selector).toSet(), {'gen.sg', 'dat.sg', 'loc.sg'});
    });
    test('corpus size', () {
      expect(analyzer.nouns.length, greaterThanOrEqualTo(120));
      expect(analyzer.formCount, greaterThan(1500));
      for (final d in Declension.values) {
        expect(kNouns.where((n) => n.declension == d).length, greaterThanOrEqualTo(5), reason: d.key);
      }
    });
  });
}
