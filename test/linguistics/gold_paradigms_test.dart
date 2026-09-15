// Gold-table tests: forms typed independently from Allen & Greenough,
// *New Latin Grammar* (1903), DCC edition. They do not reuse the generator's
// rules, so they check linguistic correctness rather than internal consistency.
import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/linguistics/engine/analyzer.dart';
import 'package:grammaticon/linguistics/engine/conjugator.dart';
import 'package:grammaticon/linguistics/lexicon/verbs.dart';
import 'package:grammaticon/linguistics/model/grammar.dart';

final _conj = Conjugator();
Paradigm _p(String id) => _conj.conjugate(kVerbs.firstWhere((v) => v.id == id));

/// Asserts that the six primary forms of a block equal [expected].
void _six(String id, String block, List<String> expected) {
  final p = _p(id);
  final got = <String>[];
  for (final (per, n) in kPersons) {
    got.add(p.primary('$block.${per.key}.${n.key}')?.surface ?? '—');
  }
  expect(got, expected, reason: '$id $block');
}

void _one(String id, String selector, String expected) {
  expect(_p(id).primary(selector)?.surface, expected, reason: '$id $selector');
}

/// Asserts the selector has the given surface among primary or variant forms.
void _has(String id, String selector, String surface) {
  final forms = _p(id).cell(selector).map((f) => f.surface).toList();
  expect(forms, contains(surface), reason: '$id $selector');
}

void _none(String id, String pattern) {
  final forms = _p(id).select(pattern);
  expect(forms, isEmpty, reason: '$id should have no $pattern but has ${forms.take(5)}');
}

void main() {
  group('A&G §184 amō, first conjugation', () {
    test('indicative active', () {
      _six('amo', 'ind.praes.act', ['amō', 'amās', 'amat', 'amāmus', 'amātis', 'amant']);
      _six('amo', 'ind.imperf.act', ['amābam', 'amābās', 'amābat', 'amābāmus', 'amābātis', 'amābant']);
      _six('amo', 'ind.fut.act', ['amābō', 'amābis', 'amābit', 'amābimus', 'amābitis', 'amābunt']);
      _six('amo', 'ind.perf.act', ['amāvī', 'amāvistī', 'amāvit', 'amāvimus', 'amāvistis', 'amāvērunt']);
      _six('amo', 'ind.plusq.act', ['amāveram', 'amāverās', 'amāverat', 'amāverāmus', 'amāverātis', 'amāverant']);
      _six('amo', 'ind.futex.act', ['amāverō', 'amāveris', 'amāverit', 'amāverimus', 'amāveritis', 'amāverint']);
    });
    test('subjunctive active', () {
      _six('amo', 'subj.praes.act', ['amem', 'amēs', 'amet', 'amēmus', 'amētis', 'ament']);
      _six('amo', 'subj.imperf.act', ['amārem', 'amārēs', 'amāret', 'amārēmus', 'amārētis', 'amārent']);
      _six('amo', 'subj.perf.act', ['amāverim', 'amāverīs', 'amāverit', 'amāverīmus', 'amāverītis', 'amāverint']);
      _six('amo', 'subj.plusq.act', ['amāvissem', 'amāvissēs', 'amāvisset', 'amāvissēmus', 'amāvissētis', 'amāvissent']);
    });
    test('indicative passive', () {
      _six('amo', 'ind.praes.pass', ['amor', 'amāris', 'amātur', 'amāmur', 'amāminī', 'amantur']);
      _six('amo', 'ind.imperf.pass', ['amābar', 'amābāris', 'amābātur', 'amābāmur', 'amābāminī', 'amābantur']);
      _six('amo', 'ind.fut.pass', ['amābor', 'amāberis', 'amābitur', 'amābimur', 'amābiminī', 'amābuntur']);
      _six('amo', 'subj.praes.pass', ['amer', 'amēris', 'amētur', 'amēmur', 'amēminī', 'amentur']);
      _six('amo', 'subj.imperf.pass', ['amārer', 'amārēris', 'amārētur', 'amārēmur', 'amārēminī', 'amārentur']);
    });
    test('composite passive with agreement', () {
      _one('amo', 'ind.perf.pass.1.sg.m', 'amātus sum');
      _one('amo', 'ind.perf.pass.1.sg.f', 'amāta sum');
      _one('amo', 'ind.perf.pass.3.sg.n', 'amātum est');
      _one('amo', 'ind.perf.pass.3.pl.m', 'amātī sunt');
      _one('amo', 'ind.perf.pass.3.pl.f', 'amātae sunt');
      _one('amo', 'ind.perf.pass.3.pl.n', 'amāta sunt');
      _one('amo', 'ind.plusq.pass.2.pl.f', 'amātae erātis');
      _one('amo', 'ind.futex.pass.3.sg.m', 'amātus erit');
      _one('amo', 'subj.perf.pass.1.pl.m', 'amātī sīmus');
      _one('amo', 'subj.plusq.pass.3.sg.f', 'amāta esset');
      _has('amo', 'ind.perf.pass.3.sg.m', 'amātus fuit');
      _has('amo', 'subj.plusq.pass.3.sg.m', 'amātus foret');
      // No neuter first or second person.
      expect(_p('amo').cell('ind.perf.pass.1.sg.n'), isEmpty);
    });
    test('imperatives', () {
      _one('amo', 'imp.praes.act.2.sg', 'amā');
      _one('amo', 'imp.praes.act.2.pl', 'amāte');
      _one('amo', 'imp.fut.act.2.sg', 'amātō');
      _one('amo', 'imp.fut.act.3.sg', 'amātō');
      _one('amo', 'imp.fut.act.2.pl', 'amātōte');
      _one('amo', 'imp.fut.act.3.pl', 'amantō');
      _one('amo', 'imp.praes.pass.2.sg', 'amāre');
      _one('amo', 'imp.praes.pass.2.pl', 'amāminī');
      _one('amo', 'imp.fut.pass.2.sg', 'amātor');
      _one('amo', 'imp.fut.pass.3.sg', 'amātor');
      _one('amo', 'imp.fut.pass.3.pl', 'amantor');
      // No 2 pl future passive imperative in A&G.
      _none('amo', 'imp.fut.pass.2.pl');
    });
    test('infinitives, participles, gerund, supine', () {
      _one('amo', 'inf.praes.act', 'amāre');
      _one('amo', 'inf.praes.pass', 'amārī');
      _one('amo', 'inf.perf.act', 'amāvisse');
      _one('amo', 'inf.perf.pass.nom.sg.m', 'amātus esse');
      _one('amo', 'inf.fut.act.nom.sg.m', 'amātūrus esse');
      _one('amo', 'inf.fut.pass', 'amātum īrī');
      _one('amo', 'part.praes.act.nom.sg.m', 'amāns');
      _one('amo', 'part.praes.act.gen.sg.m', 'amantis');
      _one('amo', 'part.praes.act.nom.pl.n', 'amantia');
      _one('amo', 'part.praes.act.gen.pl.f', 'amantium');
      _one('amo', 'part.perf.pass.nom.sg.m', 'amātus');
      _one('amo', 'part.perf.pass.dat.pl.f', 'amātīs');
      _one('amo', 'part.fut.act.nom.sg.f', 'amātūra');
      _one('amo', 'gdv.acc.sg.m', 'amandum');
      _one('amo', 'gdv.gen.pl.f', 'amandārum');
      _one('amo', 'ger.gen', 'amandī');
      _one('amo', 'ger.abl', 'amandō');
      _one('amo', 'sup.acc', 'amātum');
      _one('amo', 'sup.abl', 'amātū');
    });
    test('periphrastic conjugations (§195)', () {
      _one('amo', 'pa.ind.praes.act.1.sg.m', 'amātūrus sum');
      _one('amo', 'pa.ind.imperf.act.3.sg.f', 'amātūra erat');
      _one('amo', 'pa.ind.perf.act.3.pl.m', 'amātūrī fuērunt');
      _one('amo', 'pa.subj.plusq.act.1.sg.m', 'amātūrus fuissem');
      _one('amo', 'pp.ind.praes.pass.1.sg.m', 'amandus sum');
      _one('amo', 'pp.ind.fut.pass.3.sg.n', 'amandum erit');
      _one('amo', 'pp.subj.imperf.pass.3.pl.f', 'amandae essent');
      _one('amo', 'pa.inf.praes.act.nom.sg.m', 'amātūrus esse');
      _one('amo', 'pp.inf.perf.pass.nom.sg.m', 'amandus fuisse');
    });
    test('variants (§163, §181)', () {
      _has('amo', 'ind.perf.act.3.pl', 'amāvēre');
      _has('amo', 'ind.imperf.pass.2.sg', 'amābāre');
      _has('amo', 'ind.perf.act.2.sg', 'amāstī');
      _has('amo', 'inf.perf.act', 'amāsse');
      _has('amo', 'ind.plusq.act.1.sg', 'amāram');
      _has('amo', 'subj.plusq.act.1.sg', 'amāssem');
    });
  });

  group('A&G §185–189 other conjugations', () {
    test('moneō', () {
      _six('moneo', 'ind.praes.act', ['moneō', 'monēs', 'monet', 'monēmus', 'monētis', 'monent']);
      _six('moneo', 'ind.fut.act', ['monēbō', 'monēbis', 'monēbit', 'monēbimus', 'monēbitis', 'monēbunt']);
      _six('moneo', 'subj.praes.act', ['moneam', 'moneās', 'moneat', 'moneāmus', 'moneātis', 'moneant']);
      _six('moneo', 'subj.praes.pass', ['monear', 'moneāris', 'moneātur', 'moneāmur', 'moneāminī', 'moneantur']);
      _six('moneo', 'ind.praes.pass', ['moneor', 'monēris', 'monētur', 'monēmur', 'monēminī', 'monentur']);
      _one('moneo', 'inf.praes.pass', 'monērī');
      _one('moneo', 'part.praes.act.nom.sg.m', 'monēns');
      _one('moneo', 'gdv.nom.sg.m', 'monendus');
      _one('moneo', 'imp.praes.act.2.sg', 'monē');
      _one('moneo', 'imp.fut.act.3.pl', 'monentō');
    });
    test('regō', () {
      _six('rego', 'ind.praes.act', ['regō', 'regis', 'regit', 'regimus', 'regitis', 'regunt']);
      _six('rego', 'ind.imperf.act', ['regēbam', 'regēbās', 'regēbat', 'regēbāmus', 'regēbātis', 'regēbant']);
      _six('rego', 'ind.fut.act', ['regam', 'regēs', 'reget', 'regēmus', 'regētis', 'regent']);
      _six('rego', 'subj.praes.act', ['regam', 'regās', 'regat', 'regāmus', 'regātis', 'regant']);
      _six('rego', 'subj.imperf.act', ['regerem', 'regerēs', 'regeret', 'regerēmus', 'regerētis', 'regerent']);
      _six('rego', 'ind.praes.pass', ['regor', 'regeris', 'regitur', 'regimur', 'regiminī', 'reguntur']);
      _six('rego', 'ind.fut.pass', ['regar', 'regēris', 'regētur', 'regēmur', 'regēminī', 'regentur']);
      _six('rego', 'subj.imperf.pass', ['regerer', 'regerēris', 'regerētur', 'regerēmur', 'regerēminī', 'regerentur']);
      _six('rego', 'ind.perf.act', ['rēxī', 'rēxistī', 'rēxit', 'rēximus', 'rēxistis', 'rēxērunt']);
      _one('rego', 'imp.praes.act.2.sg', 'rege');
      _one('rego', 'imp.praes.act.2.pl', 'regite');
      _one('rego', 'imp.fut.act.2.sg', 'regitō');
      _one('rego', 'imp.fut.act.3.pl', 'reguntō');
      _one('rego', 'imp.praes.pass.2.sg', 'regere');
      _one('rego', 'imp.fut.pass.3.pl', 'reguntor');
      _one('rego', 'inf.praes.pass', 'regī');
      _one('rego', 'part.praes.act.nom.sg.m', 'regēns');
      _one('rego', 'part.perf.pass.nom.sg.m', 'rēctus');
      _one('rego', 'gdv.nom.sg.m', 'regendus');
      _has('rego', 'gdv.nom.sg.m', 'regundus');
      _one('rego', 'sup.abl', 'rēctū');
    });
    test('capiō (§188)', () {
      _six('capio', 'ind.praes.act', ['capiō', 'capis', 'capit', 'capimus', 'capitis', 'capiunt']);
      _six('capio', 'ind.imperf.act', ['capiēbam', 'capiēbās', 'capiēbat', 'capiēbāmus', 'capiēbātis', 'capiēbant']);
      _six('capio', 'ind.fut.act', ['capiam', 'capiēs', 'capiet', 'capiēmus', 'capiētis', 'capient']);
      _six('capio', 'subj.praes.act', ['capiam', 'capiās', 'capiat', 'capiāmus', 'capiātis', 'capiant']);
      _six('capio', 'subj.imperf.act', ['caperem', 'caperēs', 'caperet', 'caperēmus', 'caperētis', 'caperent']);
      _six('capio', 'ind.praes.pass', ['capior', 'caperis', 'capitur', 'capimur', 'capiminī', 'capiuntur']);
      _six('capio', 'ind.fut.pass', ['capiar', 'capiēris', 'capiētur', 'capiēmur', 'capiēminī', 'capientur']);
      _one('capio', 'imp.praes.act.2.sg', 'cape');
      _one('capio', 'imp.fut.act.3.pl', 'capiuntō');
      _one('capio', 'inf.praes.pass', 'capī');
      _one('capio', 'part.praes.act.nom.sg.m', 'capiēns');
      _one('capio', 'part.praes.act.gen.sg.m', 'capientis');
      _one('capio', 'gdv.nom.sg.m', 'capiendus');
      _has('capio', 'gdv.nom.sg.m', 'capiundus');
      _six('capio', 'ind.perf.act', ['cēpī', 'cēpistī', 'cēpit', 'cēpimus', 'cēpistis', 'cēpērunt']);
    });
    test('audiō (§187)', () {
      _six('audio', 'ind.praes.act', ['audiō', 'audīs', 'audit', 'audīmus', 'audītis', 'audiunt']);
      _six('audio', 'ind.imperf.act', ['audiēbam', 'audiēbās', 'audiēbat', 'audiēbāmus', 'audiēbātis', 'audiēbant']);
      _six('audio', 'ind.fut.act', ['audiam', 'audiēs', 'audiet', 'audiēmus', 'audiētis', 'audient']);
      _six('audio', 'ind.praes.pass', ['audior', 'audīris', 'audītur', 'audīmur', 'audīminī', 'audiuntur']);
      _six('audio', 'subj.imperf.pass', ['audīrer', 'audīrēris', 'audīrētur', 'audīrēmur', 'audīrēminī', 'audīrentur']);
      _one('audio', 'imp.praes.act.2.sg', 'audī');
      _one('audio', 'imp.fut.act.2.pl', 'audītōte');
      _one('audio', 'inf.praes.pass', 'audīrī');
      _one('audio', 'part.praes.act.nom.sg.m', 'audiēns');
      _one('audio', 'gdv.nom.sg.m', 'audiendus');
      // Syncopated perfect (§181 b).
      _has('audio', 'ind.perf.act.1.sg', 'audiī');
      _has('audio', 'ind.perf.act.2.sg', 'audīstī');
      _has('audio', 'ind.perf.act.3.sg', 'audiit');
      _has('audio', 'ind.perf.act.3.pl', 'audiērunt');
      _has('audio', 'inf.perf.act', 'audīsse');
    });
    test('dō (§202) short a', () {
      _six('do', 'ind.praes.act', ['dō', 'dās', 'dat', 'damus', 'datis', 'dant']);
      _six('do', 'subj.praes.act', ['dem', 'dēs', 'det', 'dēmus', 'dētis', 'dent']);
      _one('do', 'ind.imperf.act.1.sg', 'dabam');
      _one('do', 'ind.fut.act.1.sg', 'dabō');
      _one('do', 'subj.imperf.act.1.sg', 'darem');
      _one('do', 'imp.praes.act.2.sg', 'dā');
      _one('do', 'imp.praes.act.2.pl', 'date');
      _one('do', 'inf.praes.act', 'dare');
      _one('do', 'inf.praes.pass', 'darī');
      _one('do', 'part.praes.act.nom.sg.m', 'dāns');
      _one('do', 'part.praes.act.gen.sg.m', 'dantis');
      _one('do', 'part.perf.pass.nom.sg.m', 'datus');
      _one('do', 'gdv.nom.sg.m', 'dandus');
      _six('do', 'ind.perf.act', ['dedī', 'dedistī', 'dedit', 'dedimus', 'dedistis', 'dedērunt']);
    });
    test('imperatives dīc, dūc, fac (§182)', () {
      _one('dico', 'imp.praes.act.2.sg', 'dīc');
      _one('duco', 'imp.praes.act.2.sg', 'dūc');
      _one('facio', 'imp.praes.act.2.sg', 'fac');
      _one('dico', 'imp.praes.act.2.pl', 'dīcite');
    });
  });

  group('A&G §190–192 deponents and semi-deponents', () {
    test('sequor', () {
      _six('sequor', 'ind.praes.pass', ['sequor', 'sequeris', 'sequitur', 'sequimur', 'sequiminī', 'sequuntur']);
      _six('sequor', 'ind.imperf.pass', ['sequēbar', 'sequēbāris', 'sequēbātur', 'sequēbāmur', 'sequēbāminī', 'sequēbantur']);
      _six('sequor', 'ind.fut.pass', ['sequar', 'sequēris', 'sequētur', 'sequēmur', 'sequēminī', 'sequentur']);
      _six('sequor', 'subj.praes.pass', ['sequar', 'sequāris', 'sequātur', 'sequāmur', 'sequāminī', 'sequantur']);
      _six('sequor', 'subj.imperf.pass', ['sequerer', 'sequerēris', 'sequerētur', 'sequerēmur', 'sequerēminī', 'sequerentur']);
      _one('sequor', 'ind.perf.pass.1.sg.m', 'secūtus sum');
      _one('sequor', 'ind.plusq.pass.3.pl.f', 'secūtae erant');
      _one('sequor', 'subj.perf.pass.3.sg.m', 'secūtus sit');
      _one('sequor', 'imp.praes.pass.2.sg', 'sequere');
      _one('sequor', 'imp.praes.pass.2.pl', 'sequiminī');
      _one('sequor', 'imp.fut.pass.2.sg', 'sequitor');
      _one('sequor', 'imp.fut.pass.3.pl', 'sequuntor');
      _one('sequor', 'inf.praes.pass', 'sequī');
      _one('sequor', 'inf.perf.pass.nom.sg.m', 'secūtus esse');
      _one('sequor', 'inf.fut.act.nom.sg.m', 'secūtūrus esse');
      _one('sequor', 'part.praes.act.nom.sg.m', 'sequēns');
      _one('sequor', 'part.perf.pass.nom.sg.m', 'secūtus');
      _one('sequor', 'part.fut.act.nom.sg.m', 'secūtūrus');
      _one('sequor', 'gdv.nom.sg.m', 'sequendus');
      _one('sequor', 'ger.gen', 'sequendī');
      _one('sequor', 'sup.acc', 'secūtum');
      // Deponents have no active finite forms and no future passive infinitive.
      _none('sequor', 'ind.*.act');
      _none('sequor', 'subj.*.act');
      _none('sequor', 'imp.*.act');
      _none('sequor', 'inf.praes.act');
      _none('sequor', 'inf.fut.pass');
      // Semantic voice is active.
      final f = _p('sequor').primary('ind.praes.pass.3.sg')!;
      expect(f.analysis.voice, Voice.passivum);
      expect(f.analysis.effectiveSemanticVoice, Voice.activum);
    });
    test('hortor, vereor, patior, potior', () {
      _six('hortor', 'ind.praes.pass', ['hortor', 'hortāris', 'hortātur', 'hortāmur', 'hortāminī', 'hortantur']);
      _one('hortor', 'inf.praes.pass', 'hortārī');
      _six('vereor', 'ind.praes.pass', ['vereor', 'verēris', 'verētur', 'verēmur', 'verēminī', 'verentur']);
      _one('vereor', 'subj.imperf.pass.1.sg', 'verērer');
      _six('patior', 'ind.praes.pass', ['patior', 'pateris', 'patitur', 'patimur', 'patiminī', 'patiuntur']);
      _one('patior', 'subj.imperf.pass.1.sg', 'paterer');
      _one('patior', 'part.praes.act.nom.sg.m', 'patiēns');
      _one('patior', 'part.perf.pass.nom.sg.m', 'passus');
      _six('potior', 'ind.praes.pass', ['potior', 'potīris', 'potītur', 'potīmur', 'potīminī', 'potiuntur']);
      _has('potior', 'ind.praes.pass.3.sg', 'potitur');
      _has('potior', 'subj.imperf.pass.3.sg', 'poterētur');
      _one('morior', 'part.fut.act.nom.sg.m', 'moritūrus');
      _one('orior', 'part.fut.act.nom.sg.m', 'oritūrus');
      _one('orior', 'ind.praes.pass.3.sg', 'oritur');
    });
    test('semi-deponents (§192)', () {
      _one('audeo', 'ind.praes.act.1.sg', 'audeō');
      _one('audeo', 'ind.imperf.act.1.sg', 'audēbam');
      _one('audeo', 'ind.perf.pass.1.sg.m', 'ausus sum');
      _one('audeo', 'subj.plusq.pass.3.sg.m', 'ausus esset');
      _one('audeo', 'inf.perf.pass.nom.sg.m', 'ausus esse');
      _none('audeo', 'ind.perf.act');
      _none('audeo', 'inf.perf.act');
      _none('audeo', 'ind.praes.pass');
      _none('audeo', 'inf.praes.pass');
      _one('audeo', 'gdv.nom.sg.m', 'audendus');
      _has('audeo', 'subj.praes.act.1.sg', 'ausim');
      _one('gaudeo', 'ind.perf.pass.3.sg.m', 'gāvīsus est');
      _one('soleo', 'ind.perf.pass.3.pl.m', 'solitī sunt');
      _one('fido', 'ind.perf.pass.1.sg.m', 'fīsus sum');
      // revertor: deponent present, active perfect (§191).
      _one('revertor', 'ind.praes.pass.1.sg', 'revertor');
      _one('revertor', 'ind.perf.act.1.sg', 'revertī');
      _one('revertor', 'ind.perf.act.3.sg', 'revertit');
      _none('revertor', 'ind.praes.act');
      _none('revertor', 'ind.perf.pass');
    });
  });

  group('A&G §170, §198–205 irregular verbs', () {
    test('sum', () {
      _six('sum', 'ind.praes.act', ['sum', 'es', 'est', 'sumus', 'estis', 'sunt']);
      _six('sum', 'ind.imperf.act', ['eram', 'erās', 'erat', 'erāmus', 'erātis', 'erant']);
      _six('sum', 'ind.fut.act', ['erō', 'eris', 'erit', 'erimus', 'eritis', 'erunt']);
      _six('sum', 'ind.perf.act', ['fuī', 'fuistī', 'fuit', 'fuimus', 'fuistis', 'fuērunt']);
      _six('sum', 'ind.plusq.act', ['fueram', 'fuerās', 'fuerat', 'fuerāmus', 'fuerātis', 'fuerant']);
      _six('sum', 'ind.futex.act', ['fuerō', 'fueris', 'fuerit', 'fuerimus', 'fueritis', 'fuerint']);
      _six('sum', 'subj.praes.act', ['sim', 'sīs', 'sit', 'sīmus', 'sītis', 'sint']);
      _six('sum', 'subj.imperf.act', ['essem', 'essēs', 'esset', 'essēmus', 'essētis', 'essent']);
      _six('sum', 'subj.perf.act', ['fuerim', 'fuerīs', 'fuerit', 'fuerīmus', 'fuerītis', 'fuerint']);
      _six('sum', 'subj.plusq.act', ['fuissem', 'fuissēs', 'fuisset', 'fuissēmus', 'fuissētis', 'fuissent']);
      _has('sum', 'subj.imperf.act.1.sg', 'forem');
      _one('sum', 'imp.praes.act.2.sg', 'es');
      _one('sum', 'imp.praes.act.2.pl', 'este');
      _one('sum', 'imp.fut.act.2.sg', 'estō');
      _one('sum', 'imp.fut.act.2.pl', 'estōte');
      _one('sum', 'imp.fut.act.3.pl', 'suntō');
      _one('sum', 'inf.praes.act', 'esse');
      _one('sum', 'inf.perf.act', 'fuisse');
      _one('sum', 'inf.fut.act.nom.sg.m', 'futūrus esse');
      _has('sum', 'inf.fut.act', 'fore');
      _one('sum', 'part.fut.act.nom.sg.m', 'futūrus');
      _none('sum', 'ind.*.pass');
      _none('sum', 'part.praes');
      _none('sum', 'part.perf');
      _none('sum', 'gdv');
      _none('sum', 'ger');
      _none('sum', 'sup');
      expect(_p('sum').absenceFor('part.praes.act.nom.sg.m'), AbsenceStatus.nonUsitatur);
      expect(_p('sum').absenceFor('ind.praes.pass.1.sg'), AbsenceStatus.nonExstat);
    });
    test('compounds of sum', () {
      _six('absum', 'ind.praes.act', ['absum', 'abes', 'abest', 'absumus', 'abestis', 'absunt']);
      _one('absum', 'ind.perf.act.1.sg', 'āfuī');
      _one('absum', 'part.praes.act.nom.sg.m', 'absēns');
      _one('absum', 'part.praes.act.gen.sg.m', 'absentis');
      _one('absum', 'part.fut.act.nom.sg.m', 'āfutūrus');
      _six('prosum', 'ind.praes.act', ['prōsum', 'prōdes', 'prōdest', 'prōsumus', 'prōdestis', 'prōsunt']);
      _one('prosum', 'ind.imperf.act.1.sg', 'prōderam');
      _one('prosum', 'ind.fut.act.3.sg', 'prōderit');
      _one('prosum', 'subj.praes.act.1.sg', 'prōsim');
      _one('prosum', 'inf.praes.act', 'prōdesse');
      _one('prosum', 'ind.perf.act.1.sg', 'prōfuī');
      _one('praesum', 'part.praes.act.nom.sg.m', 'praesēns');
    });
    test('possum (§198)', () {
      _six('possum', 'ind.praes.act', ['possum', 'potes', 'potest', 'possumus', 'potestis', 'possunt']);
      _six('possum', 'ind.imperf.act', ['poteram', 'poterās', 'poterat', 'poterāmus', 'poterātis', 'poterant']);
      _six('possum', 'ind.fut.act', ['poterō', 'poteris', 'poterit', 'poterimus', 'poteritis', 'poterunt']);
      _six('possum', 'ind.perf.act', ['potuī', 'potuistī', 'potuit', 'potuimus', 'potuistis', 'potuērunt']);
      _six('possum', 'subj.praes.act', ['possim', 'possīs', 'possit', 'possīmus', 'possītis', 'possint']);
      _six('possum', 'subj.imperf.act', ['possem', 'possēs', 'posset', 'possēmus', 'possētis', 'possent']);
      _one('possum', 'inf.praes.act', 'posse');
      _one('possum', 'inf.perf.act', 'potuisse');
      _one('possum', 'part.praes.act.nom.sg.m', 'potēns');
      _none('possum', 'imp');
      _none('possum', 'part.fut');
      _none('possum', 'ind.*.pass');
    });
    test('eō (§203)', () {
      _six('eo', 'ind.praes.act', ['eō', 'īs', 'it', 'īmus', 'ītis', 'eunt']);
      _six('eo', 'ind.imperf.act', ['ībam', 'ībās', 'ībat', 'ībāmus', 'ībātis', 'ībant']);
      _six('eo', 'ind.fut.act', ['ībō', 'ības', 'ībit', 'ībimus', 'ībitis', 'ībunt'].map((s) => s == 'ības' ? 'ībis' : s).toList());
      _six('eo', 'ind.perf.act', ['iī', 'īstī', 'iit', 'iimus', 'īstis', 'iērunt']);
      _six('eo', 'ind.plusq.act', ['ieram', 'ierās', 'ierat', 'ierāmus', 'ierātis', 'ierant']);
      _six('eo', 'subj.praes.act', ['eam', 'eās', 'eat', 'eāmus', 'eātis', 'eant']);
      _six('eo', 'subj.imperf.act', ['īrem', 'īrēs', 'īret', 'īrēmus', 'īrētis', 'īrent']);
      _six('eo', 'subj.plusq.act', ['īssem', 'īssēs', 'īsset', 'īssēmus', 'īssētis', 'īssent']);
      _one('eo', 'imp.praes.act.2.sg', 'ī');
      _one('eo', 'imp.praes.act.2.pl', 'īte');
      _one('eo', 'imp.fut.act.2.sg', 'ītō');
      _one('eo', 'imp.fut.act.3.pl', 'euntō');
      _one('eo', 'inf.praes.act', 'īre');
      _one('eo', 'inf.perf.act', 'īsse');
      _one('eo', 'inf.fut.act.nom.sg.m', 'itūrus esse');
      _one('eo', 'part.praes.act.nom.sg.m', 'iēns');
      _one('eo', 'part.praes.act.gen.sg.m', 'euntis');
      _one('eo', 'part.fut.act.nom.sg.m', 'itūrus');
      _one('eo', 'ger.gen', 'eundī');
      _one('eo', 'gdv.nom.sg.n', 'eundum');
      _one('eo', 'sup.acc', 'itum');
      // Impersonal passive only.
      _one('eo', 'ind.praes.pass.3.sg', 'ītur');
      _one('eo', 'ind.perf.pass.3.sg.n', 'itum est');
      _none('eo', 'ind.praes.pass.1');
      _none('eo', 'ind.praes.pass.3.pl');
      // Transitive compound: personal passive.
      _six('adeo', 'ind.praes.pass', ['adeor', 'adīris', 'adītur', 'adīmur', 'adīminī', 'adeuntur']);
      _one('adeo', 'ind.perf.pass.1.sg.m', 'aditus sum');
      _six('redeo', 'ind.praes.act', ['redeō', 'redīs', 'redit', 'redīmus', 'redītis', 'redeunt']);
      _one('redeo', 'ind.perf.act.1.sg', 'rediī');
      _one('redeo', 'part.praes.act.nom.sg.m', 'rediēns');
      _one('redeo', 'part.praes.act.gen.sg.m', 'redeuntis');
    });
    test('ferō (§200)', () {
      _six('fero', 'ind.praes.act', ['ferō', 'fers', 'fert', 'ferimus', 'fertis', 'ferunt']);
      _six('fero', 'ind.praes.pass', ['feror', 'ferris', 'fertur', 'ferimur', 'feriminī', 'feruntur']);
      _six('fero', 'ind.imperf.act', ['ferēbam', 'ferēbās', 'ferēbat', 'ferēbāmus', 'ferēbātis', 'ferēbant']);
      _six('fero', 'ind.fut.act', ['feram', 'ferēs', 'feret', 'ferēmus', 'ferētis', 'ferent']);
      _six('fero', 'ind.perf.act', ['tulī', 'tulistī', 'tulit', 'tulimus', 'tulistis', 'tulērunt']);
      _six('fero', 'subj.praes.act', ['feram', 'ferās', 'ferat', 'ferāmus', 'ferātis', 'ferant']);
      _six('fero', 'subj.imperf.act', ['ferrem', 'ferrēs', 'ferret', 'ferrēmus', 'ferrētis', 'ferrent']);
      _six('fero', 'subj.imperf.pass', ['ferrer', 'ferrēris', 'ferrētur', 'ferrēmur', 'ferrēminī', 'ferrentur']);
      _one('fero', 'imp.praes.act.2.sg', 'fer');
      _one('fero', 'imp.praes.act.2.pl', 'ferte');
      _one('fero', 'imp.fut.act.2.sg', 'fertō');
      _one('fero', 'imp.praes.pass.2.sg', 'ferre');
      _one('fero', 'imp.fut.pass.2.sg', 'fertor');
      _one('fero', 'inf.praes.act', 'ferre');
      _one('fero', 'inf.praes.pass', 'ferrī');
      _one('fero', 'inf.perf.act', 'tulisse');
      _one('fero', 'part.praes.act.nom.sg.m', 'ferēns');
      _one('fero', 'part.perf.pass.nom.sg.m', 'lātus');
      _one('fero', 'part.fut.act.nom.sg.m', 'lātūrus');
      _one('fero', 'gdv.nom.sg.m', 'ferendus');
      _one('fero', 'ind.perf.pass.3.sg.f', 'lāta est');
      _six('aufero', 'ind.praes.act', ['auferō', 'aufers', 'aufert', 'auferimus', 'aufertis', 'auferunt']);
      _one('aufero', 'ind.perf.act.1.sg', 'abstulī');
      _one('aufero', 'part.perf.pass.nom.sg.m', 'ablātus');
      _one('refero', 'ind.perf.act.1.sg', 'rettulī');
      _one('confero', 'part.perf.pass.nom.sg.m', 'collātus');
    });
    test('volō, nōlō, mālō (§199)', () {
      _six('volo', 'ind.praes.act', ['volō', 'vīs', 'vult', 'volumus', 'vultis', 'volunt']);
      _six('volo', 'subj.praes.act', ['velim', 'velīs', 'velit', 'velīmus', 'velītis', 'velint']);
      _six('volo', 'subj.imperf.act', ['vellem', 'vellēs', 'vellet', 'vellēmus', 'vellētis', 'vellent']);
      _six('volo', 'ind.fut.act', ['volam', 'volēs', 'volet', 'volēmus', 'volētis', 'volent']);
      _six('volo', 'ind.perf.act', ['voluī', 'voluistī', 'voluit', 'voluimus', 'voluistis', 'voluērunt']);
      _one('volo', 'inf.praes.act', 'velle');
      _one('volo', 'part.praes.act.nom.sg.m', 'volēns');
      _none('volo', 'imp');
      _none('volo', 'ind.*.pass');
      _none('volo', 'gdv');
      _six('nolo', 'ind.praes.act', ['nōlō', 'nōn vīs', 'nōn vult', 'nōlumus', 'nōn vultis', 'nōlunt']);
      _six('nolo', 'subj.praes.act', ['nōlim', 'nōlīs', 'nōlit', 'nōlīmus', 'nōlītis', 'nōlint']);
      _one('nolo', 'imp.praes.act.2.sg', 'nōlī');
      _one('nolo', 'imp.praes.act.2.pl', 'nōlīte');
      _one('nolo', 'imp.fut.act.2.sg', 'nōlītō');
      _one('nolo', 'inf.praes.act', 'nōlle');
      _six('malo', 'ind.praes.act', ['mālō', 'māvīs', 'māvult', 'mālumus', 'māvultis', 'mālunt']);
      _six('malo', 'subj.imperf.act', ['māllem', 'māllēs', 'māllet', 'māllēmus', 'māllētis', 'māllent']);
      _one('malo', 'inf.praes.act', 'mālle');
      _none('malo', 'imp');
      _none('malo', 'part.praes');
    });
    test('fīō and faciō (§204)', () {
      _six('fio', 'ind.praes.act', ['fīō', 'fīs', 'fit', 'fīmus', 'fītis', 'fīunt']);
      _six('fio', 'ind.imperf.act', ['fīēbam', 'fīēbās', 'fīēbat', 'fīēbāmus', 'fīēbātis', 'fīēbant']);
      _six('fio', 'ind.fut.act', ['fīam', 'fīēs', 'fīet', 'fīēmus', 'fīētis', 'fīent']);
      _six('fio', 'subj.praes.act', ['fīam', 'fīās', 'fīat', 'fīāmus', 'fīātis', 'fīant']);
      _six('fio', 'subj.imperf.act', ['fierem', 'fierēs', 'fieret', 'fierēmus', 'fierētis', 'fierent']);
      _one('fio', 'imp.praes.act.2.sg', 'fī');
      _one('fio', 'inf.praes.act', 'fierī');
      _one('fio', 'ind.perf.pass.1.sg.m', 'factus sum');
      _one('fio', 'part.perf.pass.nom.sg.m', 'factus');
      _one('fio', 'gdv.nom.sg.m', 'faciendus');
      _none('fio', 'part.praes');
      _six('facio', 'ind.praes.pass', ['fīō', 'fīs', 'fit', 'fīmus', 'fītis', 'fīunt']);
      _one('facio', 'inf.praes.pass', 'fierī');
      _one('facio', 'subj.imperf.pass.3.sg', 'fieret');
      _six('facio', 'ind.praes.act', ['faciō', 'facis', 'facit', 'facimus', 'facitis', 'faciunt']);
      _one('facio', 'part.fut.act.nom.sg.m', 'factūrus');
      _one('facio', 'inf.fut.pass', 'factum īrī');
      // Regular compound keeps regular passive.
      _one('conficio', 'ind.praes.pass.1.sg', 'cōnficior');
    });
    test('edō (§201)', () {
      _six('edo', 'ind.praes.act', ['edō', 'edis', 'edit', 'edimus', 'editis', 'edunt']);
      _has('edo', 'ind.praes.act.2.sg', 'ēs');
      _has('edo', 'ind.praes.act.3.sg', 'ēst');
      _has('edo', 'ind.praes.act.2.pl', 'ēstis');
      _has('edo', 'subj.imperf.act.1.sg', 'ēssem');
      _has('edo', 'inf.praes.act', 'ēsse');
      _has('edo', 'imp.praes.act.2.sg', 'ēs');
      _has('edo', 'subj.praes.act.1.sg', 'edim');
      _has('edo', 'ind.praes.pass.3.sg', 'ēstur');
      _one('edo', 'ind.perf.act.1.sg', 'ēdī');
      _one('edo', 'part.perf.pass.nom.sg.m', 'ēsus');
    });
    test('defectives (§205–206)', () {
      _six('odi', 'ind.perf.act', ['ōdī', 'ōdistī', 'ōdit', 'ōdimus', 'ōdistis', 'ōdērunt']);
      _six('odi', 'ind.plusq.act', ['ōderam', 'ōderās', 'ōderat', 'ōderāmus', 'ōderātis', 'ōderant']);
      _six('odi', 'ind.futex.act', ['ōderō', 'ōderis', 'ōderit', 'ōderimus', 'ōderitis', 'ōderint']);
      _one('odi', 'inf.perf.act', 'ōdisse');
      _one('odi', 'part.fut.act.nom.sg.m', 'ōsūrus');
      _none('odi', 'ind.praes');
      _none('odi', 'ind.imperf');
      _none('odi', 'imp');
      expect(_p('odi').primary('ind.perf.act.1.sg')!.analysis.effectiveSemanticTense, Tense.praesens);
      expect(_p('odi').primary('ind.plusq.act.1.sg')!.analysis.effectiveSemanticTense, Tense.imperfectum);
      _six('memini', 'ind.perf.act', ['meminī', 'meministī', 'meminit', 'meminimus', 'meministis', 'meminērunt']);
      _one('memini', 'imp.fut.act.2.sg', 'mementō');
      _one('memini', 'imp.fut.act.2.pl', 'mementōte');
      _one('memini', 'inf.perf.act', 'meminisse');
      _none('memini', 'imp.praes');
      _none('memini', 'part');
      _six('coepi', 'ind.perf.act', ['coepī', 'coepistī', 'coepit', 'coepimus', 'coepistis', 'coepērunt']);
      _one('coepi', 'ind.perf.pass.3.sg.f', 'coepta est');
      _one('coepi', 'part.fut.act.nom.sg.m', 'coeptūrus');
      _none('coepi', 'ind.praes');
      _one('inquam', 'ind.praes.act.1.sg', 'inquam');
      _one('inquam', 'ind.praes.act.3.sg', 'inquit');
      _one('inquam', 'ind.praes.act.3.pl', 'inquiunt');
      _none('inquam', 'ind.praes.act.2.pl');
      _none('inquam', 'subj');
      _one('aio', 'ind.praes.act.3.sg', 'ait');
      _one('aio', 'ind.praes.act.3.pl', 'āiunt');
      _one('aio', 'ind.imperf.act.3.sg', 'āiēbat');
      _none('aio', 'ind.praes.act.1.pl');
      _one('for', 'ind.praes.pass.3.sg', 'fātur');
      _one('for', 'ind.praes.pass.3.pl', 'fantur');
      _one('for', 'ind.fut.pass.1.sg', 'fābor');
      _one('for', 'ind.perf.pass.1.sg.m', 'fātus sum');
      _one('for', 'imp.praes.pass.2.sg', 'fāre');
      _one('for', 'inf.praes.pass', 'fārī');
      _one('for', 'part.praes.act.gen.sg.m', 'fantis');
      _one('for', 'gdv.nom.sg.m', 'fandus');
      _one('for', 'ger.gen', 'fandī');
      _one('for', 'sup.abl', 'fātū');
      _none('for', 'ind.praes.pass.1');
      _none('for', 'sup.acc');
      _one('quaeso', 'ind.praes.act.1.sg', 'quaesō');
      _one('quaeso', 'ind.praes.act.1.pl', 'quaesumus');
      _one('salve', 'imp.praes.act.2.sg', 'salvē');
      _one('ave', 'imp.praes.act.2.pl', 'avēte');
    });
    test('impersonals (§207–208)', () {
      _one('licet', 'ind.praes.act.3.sg', 'licet');
      _one('licet', 'ind.imperf.act.3.sg', 'licēbat');
      _one('licet', 'ind.fut.act.3.sg', 'licēbit');
      _one('licet', 'ind.perf.act.3.sg', 'licuit');
      _has('licet', 'ind.perf.act.3.sg', 'licitum est');
      _one('licet', 'ind.plusq.act.3.sg', 'licuerat');
      _one('licet', 'ind.futex.act.3.sg', 'licuerit');
      _one('licet', 'subj.praes.act.3.sg', 'liceat');
      _one('licet', 'subj.imperf.act.3.sg', 'licēret');
      _one('licet', 'subj.perf.act.3.sg', 'licuerit');
      _one('licet', 'subj.plusq.act.3.sg', 'licuisset');
      _one('licet', 'inf.praes.act', 'licēre');
      _one('licet', 'inf.perf.act', 'licuisse');
      _none('licet', 'ind.praes.act.1');
      _none('licet', 'ind.praes.act.2');
      _none('licet', 'ind.praes.act.3.pl');
      _none('licet', 'imp');
      _none('licet', 'part');
      _none('licet', 'inf.praes.pass');
      _one('oportet', 'ind.perf.act.3.sg', 'oportuit');
      _one('pluit', 'ind.praes.act.3.sg', 'pluit');
      _one('pluit', 'ind.imperf.act.3.sg', 'pluēbat');
      _one('pluit', 'ind.perf.act.3.sg', 'pluit');
      _one('paenitet', 'subj.praes.act.3.sg', 'paeniteat');
      expect(_p('licet').absenceFor('ind.praes.act.1.sg'), AbsenceStatus.nonExstat);
    });
  });

  group('no invented combinations', () {
    test('intransitive verbs have only impersonal passives', () {
      _one('venio', 'ind.praes.pass.3.sg', 'venītur');
      _none('venio', 'ind.praes.pass.1');
      _none('venio', 'ind.praes.pass.2');
      _none('venio', 'ind.praes.pass.3.pl');
      _none('venio', 'imp.*.pass');
      _one('venio', 'ind.perf.pass.3.sg.n', 'ventum est');
      _none('venio', 'ind.perf.pass.3.sg.m');
      _one('venio', 'gdv.nom.sg.n', 'veniendum');
      _none('venio', 'gdv.nom.sg.m');
      _one('venio', 'pp.ind.praes.pass.3.sg.n', 'veniendum est');
      _none('venio', 'pp.ind.praes.pass.1');
      // Active periphrastic stays personal.
      _one('venio', 'pa.ind.praes.act.1.sg.m', 'ventūrus sum');
      _one('venio', 'inf.fut.act.nom.pl.f', 'ventūrae esse');
    });
    test('verbs without supine lack the participial system', () {
      _none('timeo', 'part.perf');
      _none('timeo', 'part.fut');
      _none('timeo', 'ind.perf.pass');
      _none('timeo', 'inf.fut');
      _none('timeo', 'sup');
      _none('timeo', 'pa');
      _one('timeo', 'gdv.nom.sg.m', 'timendus');
      _one('timeo', 'ind.perf.act.1.sg', 'timuī');
    });
    test('scī is flagged as not used, not as nonexistent', () {
      _none('scio', 'imp.praes.act.2.sg');
      expect(_p('scio').absenceFor('imp.praes.act.2.sg'), AbsenceStatus.nonUsitatur);
      _one('scio', 'imp.fut.act.2.sg', 'scītō');
      _one('scio', 'imp.praes.act.2.pl', 'scīte');
    });
    test('no 2 pl future passive imperative anywhere', () {
      for (final v in kVerbs) {
        expect(_p(v.id).cell('imp.fut.pass.2.pl'), isEmpty, reason: v.id);
      }
    });
    test('imperatives never have first person; infinitives never have person', () {
      for (final v in kVerbs) {
        for (final f in _p(v.id).forms) {
          final a = f.analysis;
          if (a.mood == Mood.imperativus) {
            expect(a.person, isNot(Person.prima), reason: '${v.id} ${f.surface}');
          }
          if (a.mood == Mood.infinitivus || a.mood == Mood.gerundium || a.mood == Mood.supinum) {
            expect(a.person, isNull, reason: '${v.id} ${f.surface}');
          }
          if (a.isFinite) {
            expect(a.person, isNotNull, reason: '${v.id} ${f.surface}');
            expect(a.number, isNotNull, reason: '${v.id} ${f.surface}');
          }
        }
      }
    });
    test('every principal part appears in its own paradigm', () {
      for (final v in kVerbs) {
        // for (fārī) has no attested first person (A&G §206).
        if (v.id == 'for') continue;
        final p = _p(v.id);
        final surfaces = p.forms.map((f) => f.surface).toSet();
        expect(surfaces, contains(v.principalParts[0]), reason: '${v.id} first principal part');
        if (v.infinitive != '-') {
          expect(surfaces, contains(v.infinitive), reason: '${v.id} infinitive');
        }
        if (v.perfectFirst != '-' && v.hasPerfect) {
          expect(surfaces, contains(v.perfectFirst), reason: '${v.id} perfect');
        }
      }
    });
  });

  group('analyzer: all valid analyses are kept', () {
    final analyzer = Analyzer(kVerbs, _conj);
    test('amāre is infinitive, passive imperative and rare 2 sg passive', () {
      final a = analyzer.analyze('amāre').map((f) => f.analysis.selector).toSet();
      expect(a, containsAll(['inf.praes.act', 'imp.praes.pass.2.sg', 'ind.praes.pass.2.sg']));
    });
    test('regere is infinitive, passive imperative and 2 sg passive', () {
      final a = analyzer.analyze('regere').map((f) => f.analysis.selector).toSet();
      expect(a, containsAll(['inf.praes.act', 'imp.praes.pass.2.sg', 'ind.praes.pass.2.sg']));
    });
    test('regam is future indicative and present subjunctive', () {
      final a = analyzer.analyze('regam').map((f) => f.analysis.selector).toSet();
      expect(a, containsAll(['ind.fut.act.1.sg', 'subj.praes.act.1.sg']));
    });
    test('fit belongs to fīō and to the passive of faciō', () {
      final a = analyzer.analyze('fit').map((f) => '${f.analysis.lemmaId}:${f.analysis.selector}').toSet();
      expect(a, containsAll(['fio:ind.praes.act.3.sg', 'facio:ind.praes.pass.3.sg']));
    });
    test('es is indicative and imperative of sum; ēs belongs to edō', () {
      final a = analyzer.analyze('es').map((f) => '${f.analysis.lemmaId}:${f.analysis.selector}').toSet();
      expect(a, containsAll(['sum:ind.praes.act.2.sg', 'sum:imp.praes.act.2.sg']));
      expect(a.any((s) => s.startsWith('edo:')), isFalse);
      final loose = analyzer.analyzeLoose('es').map((f) => f.analysis.lemmaId).toSet();
      expect(loose, containsAll(['sum', 'edo']));
    });
    test('amāverīs (subjunctive) and amāveris (future perfect) differ by quantity', () {
      expect(analyzer.analyze('amāverīs').map((f) => f.analysis.selector), contains('subj.perf.act.2.sg'));
      expect(analyzer.analyze('amāveris').map((f) => f.analysis.selector), contains('ind.futex.act.2.sg'));
      final loose = analyzer.analyzeLoose('amaveris').map((f) => f.analysis.selector).toSet();
      expect(loose, containsAll(['subj.perf.act.2.sg', 'ind.futex.act.2.sg']));
    });
    test('amātum esse is nominative neuter or accusative masculine', () {
      final a = analyzer.analyze('amātum esse').map((f) => f.analysis.selector).toSet();
      expect(a, containsAll(['inf.perf.pass.nom.sg.n', 'inf.perf.pass.acc.sg.m']));
    });
    test('lexicon size and index build', () {
      expect(analyzer.verbs.length, greaterThan(90));
      expect(analyzer.formCount, greaterThan(40000));
    });
  });
}
