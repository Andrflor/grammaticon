/// Le diagnostic désigne-t-il le bon maillon ? Deux contrôles :
/// 1. des cas vérifiés à la main : pour une forme, une dimension et un mauvais
///    choix donnés, le maillon observé et la confusion attendus ;
/// 2. une règle de pertinence par dimension sur des milliers de questions
///    générées : une erreur de temps doit toucher un marqueur de temps, une
///    erreur de personne une désinence, une erreur de cas une désinence
///    nominale, etc.
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/arbor/arbor.dart';
import 'package:grammaticon/arbor/diagnosis.dart';
import 'package:grammaticon/linguistics/engine/analyzer.dart';
import 'package:grammaticon/linguistics/engine/conjugator.dart';
import 'package:grammaticon/linguistics/lexicon/forum_lexicon.dart';
import 'package:grammaticon/linguistics/lexicon/verbs.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/question_generator.dart';
import 'package:grammaticon/pedagogy/trials.dart';

void main() {
  final analyzer = Analyzer(kVerbs, Conjugator());
  final nominal = buildNominalAnalyzer();
  final arbor = Arbor.standard(analyzer: analyzer, nominal: nominal);
  final verbs = QuestionGenerator(analyzer);
  final forum = ForumQuestionSource(nominal, kSyntagmata);
  final dx = Diagnostician(arbor, verbs, forum);

  Question verbQ(String surface, String lemma, Dimension dim, String chosen, {Set<String>? correct}) {
    final target = analyzer.analyze(surface).firstWhere((f) => f.analysis.lemmaId == lemma && f.isPrimary);
    final ok = correct ?? {for (final f in analyzer.analyze(surface)) if (f.analysis.lemmaId == lemma) verbs.valueOf(dim, analyzer.verb(lemma), f.analysis) ?? ''}..remove('');
    return Question(
      id: 'g', trialId: 'ind-praes-act', dimension: dim, prompt: dim.prompt, surface: surface, lemmaId: lemma,
      choices: [for (final v in ok) Choice(v, v), Choice(chosen, chosen)], correctValues: ok, skillIds: const ['v'],
      payload: VerbQuestionPayload(target: target, analyses: analyzer.analyze(surface)),
    );
  }

  Question nomQ(String surface, String lemma, Dimension dim, String chosen) {
    final target = nominal.analyze(surface).firstWhere((f) => f.analysis.lemmaId == lemma && f.isPrimary);
    final lex = nominal.lexeme(lemma);
    final item = ForumItem(lex, target);
    final ok = {for (final f in nominal.analyze(surface)) if (f.analysis.lemmaId == lemma) forum.valueOf(dim, ForumItem(lex, f)) ?? ''}..remove('');
    return Question(
      id: 'g', trialId: 'dec-1', dimension: dim, prompt: dim.prompt, surface: surface, lemmaId: lemma,
      choices: [for (final v in ok) Choice(v, v), Choice(chosen, chosen)], correctValues: ok, skillIds: const ['n'],
      payload: ForumQuestionPayload(target: target, analyses: nominal.analyze(surface), lexeme: lex, syntagma: item.syntagma),
    );
  }

  void expectDiag(Question q, String chosen, {required List<String> observed, List<String> confused = const []}) {
    final d = dx.diagnose(q, chosen);
    for (final o in observed) {
      expect(d.observed, contains(o), reason: '«${q.surface}» ${q.dimension.name}→$chosen : observé attendu $o, obtenu ${d.observed}');
    }
    for (final c in confused) {
      expect(d.confusedWith, contains(c), reason: '«${q.surface}» ${q.dimension.name}→$chosen : confusion attendue $c, obtenu ${d.confusedWith}');
    }
  }

  test('cas vérifiés à la main : système verbal', () {
    expectDiag(verbQ('amābat', 'amo', Dimension.tempus, 'praes'), 'praes', observed: ['v.sig.imperf.ba'], confused: ['v.sig.praes']);
    expectDiag(verbQ('amābit', 'amo', Dimension.tempus, 'imperf'), 'imperf', observed: ['v.sig.fut.b'], confused: ['v.sig.imperf.ba']);
    expectDiag(verbQ('reget', 'rego', Dimension.tempus, 'praes'), 'praes', observed: ['v.sig.fut.a_e'], confused: ['v.sig.praes']);
    expectDiag(verbQ('amāverit', 'amo', Dimension.tempus, 'plusq'), 'plusq', observed: ['v.sig.futex.eri'], confused: ['v.sig.plusq.era']);
    expectDiag(verbQ('amāverat', 'amo', Dimension.tempus, 'imperf'), 'imperf', observed: ['v.sig.plusq.era'], confused: ['v.sig.imperf.ba']);
    expectDiag(verbQ('amem', 'amo', Dimension.modus, 'ind'), 'ind', observed: ['v.sig.subj.praes.e'], confused: ['v.sig.praes']);
    expectDiag(verbQ('amārem', 'amo', Dimension.modus, 'ind'), 'ind', observed: ['v.sig.subj.imperf.re'], confused: ['v.sig.imperf.ba']);
    expectDiag(verbQ('amātur', 'amo', Dimension.vox, 'act'), 'act', observed: ['v.des.pass.3.sg.tur'], confused: ['v.des.act.3.sg.t']);
    expectDiag(verbQ('amāmus', 'amo', Dimension.persona, '2'), '2', observed: ['v.des.act.1.pl.mus'], confused: ['v.des.act.2.pl.tis']);
    expectDiag(verbQ('amat', 'amo', Dimension.numerus, 'pl'), 'pl', observed: ['v.des.act.3.sg.t'], confused: ['v.des.act.3.pl.nt']);
    expectDiag(verbQ('amātus est', 'amo', Dimension.tempus, 'praes'), 'praes', observed: ['v.comp.perf.pass', 'v.comp.aux.perf'], confused: ['v.sig.praes']);
    expectDiag(verbQ('amātus erat', 'amo', Dimension.tempus, 'perf'), 'perf', observed: ['v.comp.aux.plusq'], confused: ['v.comp.aux.perf']);
    expectDiag(verbQ('amātus erat', 'amo', Dimension.tempus, 'imperf'), 'imperf', observed: ['v.comp.aux.plusq', 'v.comp.perf.pass'], confused: ['v.sig.imperf.ba']);
    expectDiag(verbQ('sequitur', 'sequor', Dimension.voxSensus, 'pass'), 'pass', observed: ['v.kind.dep']);
    expectDiag(verbQ('ōdī', 'odi', Dimension.tempusSensus, 'perf'), 'perf', observed: ['v.kind.def']);
    expectDiag(verbQ('amāre', 'amo', Dimension.modus, 'imp', correct: {'inf'}), 'imp', observed: ['v.sig.inf.praes.act.re']);
    expectDiag(verbQ('amandus', 'amo', Dimension.forma, 'participium'), 'participium', observed: ['v.nom.gdv.ndus']);
    expectDiag(verbQ('amābō', 'amo', Dimension.lemma, 'oro'), 'oro', observed: ['lex.v.amo'], confused: ['lex.v.oro']);
    expectDiag(verbQ('monet', 'moneo', Dimension.coniugatio, 'c1'), 'c1', observed: ['v.thema.praes.c2', 'v.voc.e'], confused: ['v.thema.praes.c1', 'v.voc.a']);
    expectDiag(verbQ('erō', 'sum', Dimension.tempus, 'imperf'), 'imperf', observed: ['v.anom.sum.fut'], confused: ['v.anom.sum.imperf']);
    expectDiag(verbQ('ferēbat', 'fero', Dimension.tempus, 'praes'), 'praes', observed: ['v.sig.imperf.ba'], confused: ['v.sig.praes']);
    expectDiag(verbQ('ībit', 'eo', Dimension.tempus, 'imperf'), 'imperf', observed: ['v.anom.eo.fut'], confused: ['v.anom.eo.imperf']);
    expectDiag(verbQ('amāminī', 'amo', Dimension.persona, '3'), '3', observed: ['v.des.pass.2.pl.mini'], confused: ['v.des.pass.3.pl.ntur']);
    expectDiag(verbQ('amāvistī', 'amo', Dimension.persona, '3'), '3', observed: ['v.des.perf.2.sg.isti'], confused: ['v.des.perf.3.sg.it']);
    expectDiag(verbQ('amāvisse', 'amo', Dimension.tempus, 'praes'), 'praes', observed: ['v.sig.inf.perf.act.isse'], confused: ['v.sig.inf.praes.act.re']);
  });

  test('cas vérifiés à la main : système nominal', () {
    expectDiag(nomQ('rosae', 'rosa', Dimension.casus, 'abl'), 'abl', observed: ['n.des.ae'], confused: ['n.des.a_long']);
    expectDiag(nomQ('rosam', 'rosa', Dimension.casus, 'nom'), 'nom', observed: ['n.des.am'], confused: ['n.des.a']);
    expectDiag(nomQ('servō', 'servus', Dimension.casus, 'gen'), 'gen', observed: ['n.des.o_long'], confused: ['n.des.i_long']);
    expectDiag(nomQ('rēgum', 'rex', Dimension.casus, 'acc'), 'acc', observed: ['n.des.um'], confused: ['n.des.es_long']);
    expectDiag(nomQ('puella', 'puella', Dimension.numerus, 'pl'), 'pl', observed: ['n.des.a'], confused: ['n.des.ae']);
    expectDiag(nomQ('cīvium', 'civis', Dimension.declinatio, 'd1'), 'd1', observed: ['n.thema.d3.i'], confused: ['n.thema.d1']);
    expectDiag(nomQ('manus', 'manus', Dimension.genus, 'm'), 'm', observed: ['n.genus.d4']);
    expectDiag(nomQ('fortior', 'fortis', Dimension.gradus, 'pos'), 'pos', observed: ['adj.gradus.comp.ior']);
    expectDiag(nomQ('huius', 'hic', Dimension.casus, 'dat'), 'dat', observed: ['pron.des.ius'], confused: ['pron.des.i']);
    expectDiag(nomQ('manum', 'manus', Dimension.numerus, 'pl'), 'pl', observed: ['n.des.um'], confused: ['n.des.us_long']);
    expectDiag(nomQ('speī', 'spes', Dimension.numerus, 'pl'), 'pl', observed: ['n.des.ei'], confused: ['n.des.erum']);
    expectDiag(nomQ('fortiōribus', 'fortis', Dimension.casus, 'gen'), 'gen', observed: ['n.des.ibus'], confused: ['n.des.um']);
  });

  test('cas vérifiés à la main : syntagme (construction et fonction)', () {
    final trial = Trials.byId('cas-loci');
    final items = forum.pool(trial, const []);
    final romam = items.firstWhere((e) => e.surface == 'Rōmam' && e.syntagma != null);
    final q = Question(
      id: 'g', trialId: trial.id, dimension: Dimension.constructio, prompt: '', surface: 'Rōmam', lemmaId: romam.lexeme.id,
      choices: const [Choice('acc-motus', 'acc-motus'), Choice('loc', 'loc'), Choice('in-acc', 'in-acc')], correctValues: const {'acc-motus'}, skillIds: const ['f'],
      payload: ForumQuestionPayload(target: romam.form, analyses: nominal.analyze('Rōmam'), lexeme: romam.lexeme, syntagma: romam.syntagma),
    );
    expectDiag(q, 'loc', observed: ['syn.acc.directio'], confused: ['syn.locus.locativus']);
    // Choisir « in + accusatif » pour un nom de ville : ce qui manque, c'est le
    // nom de ville sans préposition ; la direction, elle, est comprise.
    final d = dx.diagnose(q, 'in-acc');
    expect(d.observed, contains('n.thema.proprium'));
    expect(d.observed, isNot(contains('syn.acc.directio')));
    expect(d.confusedWith, contains('syn.praep.in'));
  });

  test('règle de pertinence par dimension sur les questions générées', () {
    // Pour chaque dimension, les familles de nœuds qu'une erreur DOIT toucher.
    const rule = <Dimension, List<String>>{
      Dimension.tempus: ['v.sig.', 'v.comp.aux.', 'v.anom.', 'v.nom.', 'v.thema.perf', 'v.kind.def'],
      Dimension.tempusModus: ['v.sig.', 'v.comp.aux.', 'v.anom.', 'v.nom.', 'v.comp.'],
      Dimension.modus: ['v.sig.', 'v.anom.', 'v.nom.', 'v.comp.', 'v.des.'],
      Dimension.persona: ['v.des.', 'v.anom.', 'pron.'],
      Dimension.numerus: ['v.des.', 'n.des.', 'pron.', 'v.anom.', 'num.', 'syn.', 'cella.pron.', 'cella.num.', 'lect.'],
      Dimension.personaNumerus: ['v.des.', 'v.anom.'],
      Dimension.vox: ['v.des.', 'v.sig.', 'v.nom.', 'v.comp.', 'v.kind.', 'v.anom.', 'v.thema.perf'],
      Dimension.voxSensus: ['v.kind.', 'v.des.', 'v.anom.', 'v.comp.', 'v.sig.'],
      Dimension.tempusSensus: ['v.kind.def'],
      Dimension.coniugatio: ['v.thema.praes.', 'v.voc.', 'v.anom.'],
      Dimension.lemma: ['lex.'],
      Dimension.forma: ['v.nom.', 'v.comp.', 'v.sig.', 'v.des.', 'pron.', 'num.'],
      Dimension.casus: ['n.des.', 'pron.', 'num.', 'adj.', 'v.nom.', 'n.thema.proprium', 'syn.', 'cella.pron.', 'cella.num.', 'lect.'],
      Dimension.genus: ['n.des.', 'n.genus.', 'pron.', 'adj.', 'num.', 'syn.', 'cella.pron.', 'cella.num.', 'lect.'],
      Dimension.declinatio: ['n.thema.'],
      Dimension.classis: ['adj.classis.'],
      Dimension.gradus: ['adj.gradus.', 'adj.adv.'],
      Dimension.genusNumerus: ['pron.', 'n.des.', 'syn.', 'cella.pron.', 'lect.'],
      Dimension.functio: ['syn.'],
      Dimension.constructio: ['syn.', 'n.thema.proprium'],
      Dimension.relatio: ['syn.pron.', 'pron.'],
      Dimension.quodNomen: ['syn.concordia.'],
      Dimension.correlativum: ['pron.corr', 'lex.'],
      Dimension.valor: ['num.', 'lex.'],
      Dimension.analysis: ['v.', 'n.', 'pron.', 'adj.', 'num.'],
      Dimension.formaPlena: ['v.', 'n.'],
    };
    final rng = Random(21);
    final total = <Dimension, int>{}, bad = <Dimension, int>{};
    final samples = <String>[];
    final perDim = <Dimension, int>{};
    for (final trial in Trials.all.where((t) => t.activity == Activity.amphitheatrum || t.activity == Activity.forum)) {
      final source = trial.activity == Activity.amphitheatrum ? verbs : forum;
      final comps = trial.components.map((c) => c.id).toList();
      for (var i = 0; i < 30; i++) {
        final q = source.generate(trial: trial, componentIds: comps, rng: rng, id: '${trial.id}-$i');
        if (q == null) continue;
        final families = rule[q.dimension];
        if (families == null) continue;
        // Les lectures également correctes de la forme isolée (que la carte
        // écarte par son sujet) ne sont pas des distracteurs à diagnostiquer.
        final readings = trial.activity == Activity.amphitheatrum
            ? {for (final f in analyzer.analyze(q.surface)) if (f.analysis.lemmaId == q.lemmaId) verbs.valueOf(q.dimension, analyzer.verb(q.lemmaId), f.analysis)}
            : {for (final f in nominal.analyze(q.surface)) if (f.analysis.lemmaId == q.lemmaId) forum.valueOf(q.dimension, ForumItem(nominal.lexeme(q.lemmaId), f))};
        for (final c in q.choices) {
          if (q.isCorrect(c.value)) continue;
          if (readings.contains(c.value) && (q.payload is! ForumQuestionPayload || (q.payload as ForumQuestionPayload).syntagma == null)) continue;
          final d = dx.diagnose(q, c.value);
          total[q.dimension] = (total[q.dimension] ?? 0) + 1;
          // Observé (ce qui a manqué) ou confusion (ce qui a été cru vu) : les
          // deux sont enregistrés par l'évidence.
          final touched = {...d.observedElementa, ...d.confusedWith.where((id) => !id.startsWith('not.'))};
          final ok = touched.any((id) => families.any(id.startsWith));
          if (!ok) {
            bad[q.dimension] = (bad[q.dimension] ?? 0) + 1;
            if ((perDim[q.dimension] = (perDim[q.dimension] ?? 0) + 1) <= 4) samples.add('${trial.id} ${q.dimension.name} «${q.surface}» → ${c.label} : ${d.observedElementa.join(',')}');
          }
        }
      }
    }
    final t = total.values.fold(0, (a, b) => a + b), b = bad.values.fold(0, (a, b) => a + b);
    // ignore: avoid_print
    print('pertinence : $b / $t distracteurs hors famille (${(100 * b / max(1, t)).toStringAsFixed(2)} %) ; par dimension : ${bad.entries.map((e) => '${e.key.name}=${e.value}/${total[e.key]}').join(' ')}');
    for (final s in samples) {
      // ignore: avoid_print
      print('  $s');
    }
    expect(b / max(1, t), lessThan(0.02));
  });
}
