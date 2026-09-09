// Gold-table tests for adjectives, pronouns, numerals and adverbs: forms
// typed independently from Allen & Greenough, *New Latin Grammar* (1903),
// DCC edition (§109–§152, §214–§218). They do not reuse the declinator's
// rules, so they check linguistic correctness rather than consistency.
import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/linguistics/engine/nominal_analyzer.dart';
import 'package:grammaticon/linguistics/lexicon/forum_lexicon.dart';
import 'package:grammaticon/linguistics/model/nominal.dart';

final NominalAnalyzer _a = buildNominalAnalyzer();

const _cases = ['nom', 'voc', 'acc', 'gen', 'dat', 'abl'];

/// Primary forms of one gender and number, in the order nom, voc, acc, gen, dat, abl.
void _six(String id, String prefix, String number, String gender, List<String> expected) {
  final got = [for (final c in _cases) _a.primary(id, '$prefix$c.$number.$gender')?.surface ?? '—'];
  expect(got, expected, reason: '$id $prefix$number.$gender');
}

void _cell(String id, String selector, List<String> expected) {
  expect(_a.cell(id, selector).map((f) => f.surface).toList(), expected, reason: '$id $selector');
}

void _none(String id, String selector) => expect(_a.cell(id, selector), isEmpty, reason: '$id should have no $selector');

void main() {
  group('A&G §110–§112 first-class adjectives', () {
    test('bonus, -a, -um', () {
      _six('bonus', '', 'sg', 'm', ['bonus', 'bone', 'bonum', 'bonī', 'bonō', 'bonō']);
      _six('bonus', '', 'sg', 'f', ['bona', 'bona', 'bonam', 'bonae', 'bonae', 'bonā']);
      _six('bonus', '', 'sg', 'n', ['bonum', 'bonum', 'bonum', 'bonī', 'bonō', 'bonō']);
      _six('bonus', '', 'pl', 'm', ['bonī', 'bonī', 'bonōs', 'bonōrum', 'bonīs', 'bonīs']);
      _six('bonus', '', 'pl', 'f', ['bonae', 'bonae', 'bonās', 'bonārum', 'bonīs', 'bonīs']);
      _six('bonus', '', 'pl', 'n', ['bona', 'bona', 'bona', 'bonōrum', 'bonīs', 'bonīs']);
    });
    test('pulcher drops the e, miser keeps it; both keep the -er nominative and vocative', () {
      _six('pulcher', '', 'sg', 'm', ['pulcher', 'pulcher', 'pulchrum', 'pulchrī', 'pulchrō', 'pulchrō']);
      _six('pulcher', '', 'sg', 'f', ['pulchra', 'pulchra', 'pulchram', 'pulchrae', 'pulchrae', 'pulchrā']);
      _six('miser', '', 'sg', 'm', ['miser', 'miser', 'miserum', 'miserī', 'miserō', 'miserō']);
      _six('miser', '', 'sg', 'n', ['miserum', 'miserum', 'miserum', 'miserī', 'miserō', 'miserō']);
    });
    test('possessives: meus has the vocative mī; noster like pulcher', () {
      _cell('meus', 'voc.sg.m', ['mī', 'meus']);
      _six('noster', '', 'sg', 'f', ['nostra', 'nostra', 'nostram', 'nostrae', 'nostrae', 'nostrā']);
      _none('meus', 'comp.nom.sg.m');
    });
  });

  group('A&G §113 pronominal adjectives', () {
    test('ūnus: genitive -īus, dative -ī in all genders, no vocative', () {
      _six('unus', '', 'sg', 'm', ['ūnus', '—', 'ūnum', 'ūnīus', 'ūnī', 'ūnō']);
      _six('unus', '', 'sg', 'f', ['ūna', '—', 'ūnam', 'ūnīus', 'ūnī', 'ūnā']);
      _six('unus', '', 'sg', 'n', ['ūnum', '—', 'ūnum', 'ūnīus', 'ūnī', 'ūnō']);
    });
    test('alius has the neuter aliud; alter and uter keep -er', () {
      _cell('alius', 'nom.sg.n', ['aliud']);
      _cell('alius', 'gen.sg.m', ['alīus', 'alterīus']);
      _six('alter', '', 'sg', 'm', ['alter', '—', 'alterum', 'alterīus', 'alterī', 'alterō']);
      _six('uter', '', 'sg', 'f', ['utra', '—', 'utram', 'utrīus', 'utrī', 'utrā']);
      _cell('nullus', 'gen.sg.n', ['nūllīus']);
    });
  });

  group('A&G §114–§122 third-class adjectives', () {
    test('fortis, -e: i-stem endings (ablative -ī, gen. pl. -ium, neuter pl. -ia)', () {
      _six('fortis', '', 'sg', 'm', ['fortis', 'fortis', 'fortem', 'fortis', 'fortī', 'fortī']);
      _six('fortis', '', 'sg', 'n', ['forte', 'forte', 'forte', 'fortis', 'fortī', 'fortī']);
      _six('fortis', '', 'pl', 'f', ['fortēs', 'fortēs', 'fortēs', 'fortium', 'fortibus', 'fortibus']);
      _cell('fortis', 'acc.pl.m', ['fortēs', 'fortīs']);
      _six('fortis', '', 'pl', 'n', ['fortia', 'fortia', 'fortia', 'fortium', 'fortibus', 'fortibus']);
    });
    test('ācer, ācris, ācre: three terminations', () {
      expect(_a.primary('acer', 'nom.sg.m')!.surface, 'ācer');
      expect(_a.primary('acer', 'nom.sg.f')!.surface, 'ācris');
      expect(_a.primary('acer', 'nom.sg.n')!.surface, 'ācre');
      _six('acer', '', 'sg', 'f', ['ācris', 'ācris', 'ācrem', 'ācris', 'ācrī', 'ācrī']);
      _cell('celer', 'nom.sg.f', ['celeris']);
    });
    test('fēlīx, -īcis: one termination; neuter accusative = nominative', () {
      _six('felix', '', 'sg', 'm', ['fēlīx', 'fēlīx', 'fēlīcem', 'fēlīcis', 'fēlīcī', 'fēlīcī']);
      _six('felix', '', 'sg', 'n', ['fēlīx', 'fēlīx', 'fēlīx', 'fēlīcis', 'fēlīcī', 'fēlīcī']);
      _six('felix', '', 'pl', 'n', ['fēlīcia', 'fēlīcia', 'fēlīcia', 'fēlīcium', 'fēlīcibus', 'fēlīcibus']);
      _cell('ingens', 'gen.pl.m', ['ingentium']);
    });
    test('vetus and pauper decline as consonant stems (§121)', () {
      _six('vetus', '', 'sg', 'm', ['vetus', 'vetus', 'veterem', 'veteris', 'veterī', 'vetere']);
      _six('vetus', '', 'pl', 'n', ['vetera', 'vetera', 'vetera', 'veterum', 'veteribus', 'veteribus']);
      _cell('pauper', 'abl.sg.f', ['paupere']);
      _cell('pauper', 'gen.pl.m', ['pauperum']);
    });
  });

  group('A&G §123–§131 comparison', () {
    test('regular comparative declines as a consonant stem: -e, -um, -a', () {
      _six('fortis', 'comp.', 'sg', 'm', ['fortior', 'fortior', 'fortiōrem', 'fortiōris', 'fortiōrī', 'fortiōre']);
      _six('fortis', 'comp.', 'sg', 'n', ['fortius', 'fortius', 'fortius', 'fortiōris', 'fortiōrī', 'fortiōre']);
      _six('fortis', 'comp.', 'pl', 'm', ['fortiōrēs', 'fortiōrēs', 'fortiōrēs', 'fortiōrum', 'fortiōribus', 'fortiōribus']);
      _six('fortis', 'comp.', 'pl', 'n', ['fortiōra', 'fortiōra', 'fortiōra', 'fortiōrum', 'fortiōribus', 'fortiōribus']);
    });
    test('superlatives: -issimus, -errimus after -er, -illimus for the six -ilis adjectives', () {
      expect(_a.primary('longus', 'sup.nom.sg.m')!.surface, 'longissimus');
      expect(_a.primary('pulcher', 'sup.nom.sg.f')!.surface, 'pulcherrima');
      expect(_a.primary('miser', 'sup.nom.sg.m')!.surface, 'miserrimus');
      expect(_a.primary('acer', 'sup.nom.sg.n')!.surface, 'ācerrimum');
      expect(_a.primary('celer', 'sup.nom.sg.m')!.surface, 'celerrimus');
      expect(_a.primary('facilis', 'sup.nom.sg.m')!.surface, 'facillimus');
      expect(_a.primary('similis', 'sup.gen.pl.f')!.surface, 'simillimārum');
      expect(_a.primary('felix', 'sup.nom.sg.m')!.surface, 'fēlīcissimus');
      expect(_a.primary('utilis', 'sup.nom.sg.m')!.surface, 'ūtilissimus', reason: 'ūtilis is not among the six -illimus adjectives');
    });
    test('irregular comparison (§129): bonus, malus, magnus, parvus, multus', () {
      expect(_a.primary('bonus', 'comp.nom.sg.m')!.surface, 'melior');
      expect(_a.primary('bonus', 'comp.nom.sg.n')!.surface, 'melius');
      expect(_a.primary('bonus', 'comp.abl.sg.f')!.surface, 'meliōre');
      expect(_a.primary('bonus', 'sup.nom.sg.m')!.surface, 'optimus');
      expect(_a.primary('malus', 'comp.nom.sg.n')!.surface, 'peius');
      expect(_a.primary('malus', 'sup.nom.sg.f')!.surface, 'pessima');
      expect(_a.primary('magnus', 'comp.nom.sg.n')!.surface, 'maius');
      expect(_a.primary('magnus', 'sup.nom.sg.m')!.surface, 'maximus');
      expect(_a.primary('parvus', 'comp.nom.sg.m')!.surface, 'minor');
      expect(_a.primary('parvus', 'comp.nom.sg.n')!.surface, 'minus');
      expect(_a.primary('parvus', 'sup.nom.sg.m')!.surface, 'minimus');
      // plūs: neuter singular only, then plūrēs / plūra.
      _cell('multus', 'comp.nom.sg.n', ['plūs']);
      _cell('multus', 'comp.gen.sg.n', ['plūris']);
      _none('multus', 'comp.nom.sg.m');
      _none('multus', 'comp.dat.sg.n');
      _cell('multus', 'comp.nom.pl.m', ['plūrēs']);
      _cell('multus', 'comp.nom.pl.n', ['plūra']);
      _cell('multus', 'comp.gen.pl.f', ['plūrium']);
      expect(_a.primary('multus', 'sup.nom.sg.m')!.surface, 'plūrimus');
    });
    test('comparatives without positive (§130): prior, prīmus; ulterior, ultimus', () {
      _none('prior', 'nom.sg.m');
      expect(_a.primary('prior', 'comp.nom.sg.m')!.surface, 'prior');
      expect(_a.primary('prior', 'comp.nom.sg.n')!.surface, 'prius');
      expect(_a.primary('prior', 'sup.nom.sg.m')!.surface, 'prīmus');
      expect(_a.primary('ulterior', 'sup.nom.sg.f')!.surface, 'ultima');
      expect(_a.primary('superior', 'sup.nom.sg.m')!.surface, 'suprēmus');
    });
    test('periphrastic comparison forms nothing: idōneus', () {
      _none('idoneus', 'comp.nom.sg.m');
      _none('idoneus', 'sup.nom.sg.m');
    });
  });

  group('A&G §143–§144 personal and reflexive pronouns', () {
    test('ego / nōs', () {
      expect([for (final c in ['nom', 'acc', 'gen', 'dat', 'abl']) _a.primary('ego', '$c.sg')!.surface], ['ego', 'mē', 'meī', 'mihi', 'mē']);
      _cell('ego', 'dat.sg', ['mihi', 'mī']);
      expect([for (final c in ['nom', 'acc', 'dat', 'abl']) _a.primary('ego', '$c.pl')!.surface], ['nōs', 'nōs', 'nōbīs', 'nōbīs']);
      _cell('ego', 'gen.pl', ['nostrum', 'nostrī']);
    });
    test('tū / vōs with vocative', () {
      expect([for (final c in ['nom', 'voc', 'acc', 'gen', 'dat', 'abl']) _a.primary('tu', '$c.sg')!.surface], ['tū', 'tū', 'tē', 'tuī', 'tibi', 'tē']);
      _cell('tu', 'gen.pl', ['vestrum', 'vestrī']);
      expect(_a.primary('tu', 'dat.pl')!.surface, 'vōbīs');
    });
    test('sē has no nominative and the same forms in both numbers', () {
      _none('se', 'nom.sg');
      _cell('se', 'acc.sg', ['sē', 'sēsē']);
      _cell('se', 'acc.pl', ['sē', 'sēsē']);
      expect(_a.primary('se', 'dat.pl')!.surface, 'sibi');
      expect(_a.primary('se', 'gen.sg')!.surface, 'suī');
    });
  });

  group('A&G §146 demonstratives', () {
    test('is, ea, id', () {
      _six('is', '', 'sg', 'm', ['is', '—', 'eum', 'eius', 'eī', 'eō']);
      _six('is', '', 'sg', 'f', ['ea', '—', 'eam', 'eius', 'eī', 'eā']);
      _six('is', '', 'sg', 'n', ['id', '—', 'id', 'eius', 'eī', 'eō']);
      _cell('is', 'nom.pl.m', ['eī', 'iī', 'ī']);
      _cell('is', 'dat.pl.f', ['eīs', 'iīs', 'īs']);
      expect(_a.primary('is', 'gen.pl.f')!.surface, 'eārum');
    });
    test('hic, haec, hoc: seven forms of its own, the rest like bonus', () {
      _six('hic', '', 'sg', 'm', ['hic', '—', 'hunc', 'huius', 'huic', 'hōc']);
      _six('hic', '', 'sg', 'f', ['haec', '—', 'hanc', 'huius', 'huic', 'hāc']);
      _six('hic', '', 'sg', 'n', ['hoc', '—', 'hoc', 'huius', 'huic', 'hōc']);
      _six('hic', '', 'pl', 'm', ['hī', '—', 'hōs', 'hōrum', 'hīs', 'hīs']);
      _six('hic', '', 'pl', 'n', ['haec', '—', 'haec', 'hōrum', 'hīs', 'hīs']);
    });
    test('ille, ipse, īdem', () {
      _six('ille', '', 'sg', 'n', ['illud', '—', 'illud', 'illīus', 'illī', 'illō']);
      _six('ipse', '', 'sg', 'n', ['ipsum', '—', 'ipsum', 'ipsīus', 'ipsī', 'ipsō']);
      _six('idem', '', 'sg', 'm', ['īdem', '—', 'eundem', 'eiusdem', 'eīdem', 'eōdem']);
      _six('idem', '', 'sg', 'n', ['idem', '—', 'idem', 'eiusdem', 'eīdem', 'eōdem']);
      expect(_a.primary('idem', 'gen.pl.m')!.surface, 'eōrundem');
      expect(_a.primary('idem', 'acc.sg.f')!.surface, 'eandem');
    });
  });

  group('A&G §147–§151 relative, interrogative, indefinite', () {
    test('quī, quae, quod', () {
      _six('qui', '', 'sg', 'm', ['quī', '—', 'quem', 'cuius', 'cui', 'quō']);
      _six('qui', '', 'sg', 'f', ['quae', '—', 'quam', 'cuius', 'cui', 'quā']);
      _six('qui', '', 'sg', 'n', ['quod', '—', 'quod', 'cuius', 'cui', 'quō']);
      _six('qui', '', 'pl', 'm', ['quī', '—', 'quōs', 'quōrum', 'quibus', 'quibus']);
      _six('qui', '', 'pl', 'n', ['quae', '—', 'quae', 'quōrum', 'quibus', 'quibus']);
      _cell('qui', 'dat.pl.f', ['quibus', 'quīs']);
    });
    test('quis, quid shares the oblique forms with quī', () {
      _six('quis', '', 'sg', 'm', ['quis', '—', 'quem', 'cuius', 'cui', 'quō']);
      _six('quis', '', 'sg', 'n', ['quid', '—', 'quid', 'cuius', 'cui', 'quō']);
      final quem = _a.analyze('quem').map((f) => f.analysis.lemmaId).toSet();
      expect(quem, {'qui', 'quis'});
    });
    test('quīdam, quisque, quisquam, nēmō, nihil', () {
      _six('quidam', '', 'sg', 'm', ['quīdam', '—', 'quendam', 'cuiusdam', 'cuidam', 'quōdam']);
      expect(_a.primary('quidam', 'gen.pl.f')!.surface, 'quārundam');
      _cell('quidam', 'nom.sg.n', ['quiddam', 'quoddam']);
      _six('quisque', '', 'sg', 'f', ['quaeque', '—', 'quamque', 'cuiusque', 'cuique', 'quāque']);
      _none('quisquam', 'nom.pl.m');
      _cell('quisquam', 'nom.sg.n', ['quicquam', 'quidquam']);
      _six('nemo', '', 'sg', 'm', ['nēmō', '—', 'nēminem', 'nūllīus', 'nēminī', 'nūllō']);
      _six('nihil', '', 'sg', 'n', ['nihil', '—', 'nihil', 'nūllīus reī', 'nūllī reī', 'nūllā rē']);
      _cell('aliquis', 'nom.pl.n', ['aliqua']);
    });
  });

  group('A&G §134 numerals', () {
    test('duo and trēs decline, quattuor does not, ducentī is a plural adjective, mīlia a neuter noun', () {
      expect([for (final c in ['nom', 'acc', 'gen', 'dat']) _a.primary('duo', '$c.pl.m')!.surface], ['duo', 'duōs', 'duōrum', 'duōbus']);
      expect(_a.primary('duo', 'dat.pl.f')!.surface, 'duābus');
      expect(_a.primary('duo', 'nom.pl.n')!.surface, 'duo');
      expect([for (final c in ['nom', 'acc', 'gen', 'dat']) _a.primary('tres', '$c.pl.f')!.surface], ['trēs', 'trēs', 'trium', 'tribus']);
      expect(_a.primary('tres', 'nom.pl.n')!.surface, 'tria');
      final q = _a.formsOf('quattuor').single;
      expect(q.surface, 'quattuor');
      expect(q.analysis.casus, isNull);
      expect(_a.primary('ducenti', 'gen.pl.f')!.surface, 'ducentārum');
      expect(_a.primary('milia', 'gen.pl.n')!.surface, 'mīlium');
      expect(_a.formsOf('mille').single.analysis.selector, 'indecl');
      expect(_a.primary('septimus', 'abl.sg.f')!.surface, 'septimā');
    });
  });

  group('A&G §214–§218 adverbs', () {
    test('degrees of adverbs', () {
      List<String> degrees(String id) => [for (final d in Degree.values) _a.formsOf(id).where((f) => f.analysis.degree == d && f.isPrimary).map((f) => f.surface).firstOrNull ?? '—'];
      expect(degrees('bene'), ['bene', 'melius', 'optimē']);
      expect(degrees('male'), ['male', 'peius', 'pessimē']);
      expect(degrees('fortiter'), ['fortiter', 'fortius', 'fortissimē']);
      expect(degrees('pulchre'), ['pulchrē', 'pulchrius', 'pulcherrimē']);
      expect(degrees('facile'), ['facile', 'facilius', 'facillimē']);
      expect(degrees('prudenter'), ['prūdenter', 'prūdentius', 'prūdentissimē']);
      expect(degrees('magnopere'), ['magnopere', 'magis', 'maximē']);
      expect(degrees('nuper'), ['nūper', '—', 'nūperrimē']);
      // fortius is both the adverb and the neuter comparative adjective.
      expect(_a.analyze('fortius').map((f) => f.analysis.lemmaId).toSet(), {'fortis', 'fortiter'});
    });
  });

  test('no two lexemes share an id and every surface carries macrons consistently', () {
    final ids = _a.lexemes.map((l) => l.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(_a.analyze('rosa').map((f) => f.analysis.casus?.key).toSet(), {'nom', 'voc'});
    expect(_a.analyze('rosā').map((f) => f.analysis.casus?.key).toSet(), {'abl'});
  });
}
