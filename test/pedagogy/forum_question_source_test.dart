import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/linguistics/model/grammar.dart';
import 'package:grammaticon/linguistics/model/nominal.dart';
import 'package:grammaticon/pedagogy/forum/forum_filters.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/forum_trials.dart';
import 'package:grammaticon/pedagogy/forum/syntagma.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/mastery.dart';
import 'package:grammaticon/pedagogy/question.dart';
import 'package:grammaticon/pedagogy/skills.dart';
import 'package:grammaticon/pedagogy/trials.dart';

import '../support/test_env.dart';

void main() {
  final gen = ForumQuestionSource(testNominalAnalyzer, kSyntagmata);
  final forum = Trials.ofActivity(Activity.forum);
  List<String> comps(Trial t) => t.components.map((c) => c.id).toList();

  /// A record at tier familiāris so that analysis questions are eligible.
  final familiar = List.generate(8, (i) => i).fold(
    const SkillRecord(),
    (r, i) => r.apply(Observation(at: DateTime(2026, 1, 1 + i), correct: true, lemmaId: 'l$i', quality: AnswerQuality.autonoma, trialId: 't'), const MasteryConfig()),
  );
  Map<String, SkillRecord> familiarFor(Trial t) => {for (final s in t.skillIds) for (final l in Skills.leaves(s)) l: familiar};

  Question? find(Trial t, bool Function(Question) pred, {int seed = 1, int tries = 400, Map<String, SkillRecord> skills = const {}}) {
    final rng = Random(seed);
    for (var i = 0; i < tries; i++) {
      final q = gen.generate(trial: t, componentIds: comps(t), rng: rng, id: '$i', skills: skills);
      if (q != null && pred(q)) return q;
    }
    return null;
  }

  group('catalogue', () {
    test('78 cards in the 11 sections of the catalogue, in order; two free doors', () {
      expect(forum.length, 78);
      expect(Trials.groupsOf(Activity.forum), ForumSections.all);
      expect(forum.where((t) => t.isFree).map((t) => t.id).toSet(), {'dec-1', 'pron-ego-tu'});
      for (final id in ['dec-1', 'dec-2-mf', 'dec-2-n', 'dec-2-er', 'dec-3-cons', 'dec-3-n', 'dec-3-i', 'dec-4', 'dec-5', 'adi-1-2', 'adi-1-2-er', 'adi-3-duo', 'adi-3-una', 'adi-3-tria', 'adi-pron', 'comp-forma', 'comp-flexio', 'comp-irreg', 'comp-adv', 'comp-abl', 'pron-ego-tu', 'pron-nos-vos', 'pron-se', 'pron-me-mihi', 'pron-poss', 'pron-suus-eius', 'pron-is', 'pron-hic', 'pron-ille', 'pron-iste', 'pron-ipse', 'pron-idem', 'pron-dem-omnia', 'pron-quis', 'pron-qui', 'rel-consensus', 'pron-quis-qui', 'pron-indef', 'pron-corr', 'num-1-3', 'num-card', 'num-ord', 'num-mille', 'syn-ae', 'syn-a', 'syn-i', 'syn-o', 'syn-um', 'syn-us', 'syn-e', 'syn-es', 'syn-is', 'syn-ibus', 'syn-neutra', 'syn-quantitas', 'syn-omnia', 'con-1-2', 'con-3-1', 'con-distans', 'con-plura', 'con-appositio', 'con-omnia', 'cas-verba-dat', 'cas-verba-abl', 'cas-verba-gen', 'cas-prep-duplex', 'cas-prep-abl', 'cas-prep-acc', 'cas-loci', 'cas-temporis', 'mx-declinationes', 'mx-adiectiva', 'mx-pronomina', 'mx-syncretismi', 'mx-consensus', 'mx-casus', 'mx-instrumenta', 'mx-nominalia']) {
        expect(Trials.maybe(id), isNotNull, reason: id);
      }
    });

    test('prices follow the catalogue', () {
      const prices = {'dec-1': 0, 'dec-2-mf': 15, 'dec-2-n': 20, 'dec-3-i': 40, 'adi-pron': 45, 'comp-flexio': 40, 'pron-ego-tu': 0, 'pron-suus-eius': 45, 'pron-dem-omnia': 55, 'rel-consensus': 55, 'num-mille': 30, 'syn-us': 50, 'syn-omnia': 60, 'con-distans': 55, 'cas-verba-dat': 45, 'mx-nominalia': 80};
      for (final e in prices.entries) {
        expect(Trials.byId(e.key).price, e.value, reason: e.key);
      }
    });

    test('trial graph: prerequisites inside the Forum, every card reachable, skills exist, one skill leaf per card', () {
      for (final t in forum) {
        expect(t.activity, Activity.forum);
        for (final s in t.skillIds) {
          expect(Skills.maybe(s), isNotNull, reason: '${t.id} skill $s');
        }
        expect(Skills.byId(t.primarySkill).parent, ForumSections.skillOf(t.group), reason: t.id);
        for (final p in t.prerequisites) {
          expect(Trials.byId(p).activity, Activity.forum, reason: '${t.id} prereq $p');
        }
        for (final c in t.components) {
          if (c.requires != null) expect(Trials.byId(c.requires!).activity, Activity.forum, reason: '${t.id} component ${c.id}');
          if (c.skillId != null) expect(Skills.maybe(c.skillId!), isNotNull, reason: '${t.id} component ${c.id}');
        }
      }
      final reached = <String>{};
      var changed = true;
      while (changed) {
        changed = false;
        for (final t in forum) {
          if (!reached.contains(t.id) && t.prerequisites.every(reached.contains)) {
            reached.add(t.id);
            changed = true;
          }
        }
      }
      expect(reached.length, forum.length);
      // The catalogue's dependencies that carry the pedagogy.
      expect(Trials.byId('dec-3-cons').prerequisites, ['dec-2-n']);
      expect(Trials.byId('adi-3-duo').prerequisites, containsAll(['adi-1-2', 'dec-3-i']));
      expect(Trials.byId('comp-flexio').prerequisites, containsAll(['comp-forma', 'dec-3-cons']));
      expect(Trials.byId('pron-suus-eius').prerequisites, containsAll(['pron-poss', 'pron-se', 'pron-is']));
      expect(Trials.byId('syn-us').prerequisites, containsAll(['syn-um', 'dec-4', 'dec-3-n']));
    });
  });

  group('isolated forms', () {
    test('every card has a pool and produces well-formed questions', () {
      for (final t in forum) {
        expect(gen.pool(t, comps(t)), isNotEmpty, reason: t.id);
        final rng = Random(7);
        var produced = 0;
        for (var i = 0; i < 40; i++) {
          final q = gen.generate(trial: t, componentIds: comps(t), rng: rng, id: '$i', skills: familiarFor(t));
          if (q == null) continue;
          produced++;
          for (final x in [q, if (q.followUp != null) q.followUp!]) {
            expect(x.choices.length, greaterThanOrEqualTo(2), reason: '${t.id} ${x.surface}');
            expect(x.choices.length, lessThanOrEqualTo(7), reason: t.id);
            expect(x.correctValues.any((v) => x.choices.any((c) => c.value == v)), isTrue, reason: '${t.id} ${x.surface}: no correct choice offered');
            expect(x.choices.any((c) => !x.correctValues.contains(c.value)), isTrue, reason: '${t.id} ${x.surface}: every offered choice is correct');
            expect(x.choices.map((c) => c.value).toSet().length, x.choices.length, reason: '${t.id}: duplicate choices');
            expect(t.dimensions, contains(x.dimension), reason: t.id);
            for (final s in x.skillIds) {
              expect(Skills.maybe(s), isNotNull, reason: '${t.id} skill $s');
            }
            expect(x.skillIds.first, t.primarySkill);
            expect(x.ambiguous, x.choices.where((c) => x.correctValues.contains(c.value)).length > 1, reason: '${t.id} ${x.surface}');
            expect(x.errata, isNotNull);
          }
        }
        expect(produced, greaterThan(30), reason: t.id);
      }
    });

    test('a first-declension card never asks the declension; rosae accepts gen., dat., nom. and voc.', () {
      final t = Trials.byId('dec-1');
      final rng = Random(3);
      for (var i = 0; i < 60; i++) {
        final q = gen.generate(trial: t, componentIds: const [], rng: rng, id: '$i')!;
        expect(q.dimension, isNot(Dimension.declinatio));
        expect(q.forum.target.analysis.declension, Declension.prima);
        // The dictionary entry is shown except where it would give the answer away.
        if (q.dimension == Dimension.casus || q.dimension == Dimension.numerus) {
          expect(q.context, [q.forum.lexeme.dictionaryEntry], reason: 'dictionary entry shown in the introductory card');
        }
      }
      // rosae carries four readings at once; the generator prefers forms with a
      // single correct answer, so it is drawn rarely — but whenever it is, all
      // four are accepted.
      final rosae = gen.pool(t, const []).firstWhere((e) => e.surface == 'rosae');
      expect(gen.correctValues(t, Dimension.casus, rosae), {'gen', 'dat', 'nom', 'voc'});
    });

    test('dec-4 mixes second-declension nouns on purpose and asks the declension; the entry appears only for shared endings', () {
      final t = Trials.byId('dec-4');
      final pool = gen.pool(t, const []);
      expect(pool.map((e) => e.analysis.declension).toSet(), {Declension.quarta, Declension.secunda});
      final q = find(t, (q) => q.dimension == Dimension.declinatio && q.surface.endsWith('us') && q.forum.target.analysis.declension == Declension.quarta);
      expect(q, isNotNull);
      expect(q!.correctValues, {'d4'});
      expect(q.skillIds, [t.primarySkill], reason: 'a declension question tests no cell');
      final arum = find(t, (q) => q.dimension == Dimension.declinatio && q.surface.endsWith('ōrum'));
      expect(arum, isNotNull);
      expect(arum!.context, isEmpty, reason: '-ōrum is second-declension only: no hint');
      final ibus = find(t, (q) => q.dimension == Dimension.declinatio && q.surface.endsWith('ibus'));
      expect(ibus?.context, isNotEmpty, reason: '-ibus is shared by the third and fourth declensions');
    });

    test('noun forms credit the card and the paradigm cell; adjective forms credit the card only', () {
      final q = find(Trials.byId('dec-3-cons'), (q) => q.dimension == Dimension.casus);
      expect(q, isNotNull);
      expect(q!.skillIds, ['f.dec.3cons', q.forum.target.analysis.nounSkillId]);
      final a = find(Trials.byId('adi-1-2'), (q) => q.dimension == Dimension.casus);
      expect(a, isNotNull);
      expect(a!.skillIds, ['f.adi.12']);
      expect(a.forum.lexeme.wordClass, WordClass.adiectivum);
    });

    test('adjective cards ask the gender from the form: longae is feminine, longī masculine or neuter', () {
      // bonus, malus, magnus, parvus and multus belong to the irregular-comparison
      // card, so the plain first-class card draws longus and its like.
      final t = Trials.byId('adi-1-2');
      expect(gen.pool(t, const []).map((e) => e.lexeme.id), isNot(contains('bonus')));
      final fem = gen.pool(t, const []).firstWhere((e) => e.surface == 'longae');
      expect(gen.correctValues(t, Dimension.genus, fem), {'f'});
      final mn = gen.pool(t, const []).firstWhere((e) => e.surface == 'longī');
      expect(gen.correctValues(t, Dimension.genus, mn), {'m', 'n'}, reason: 'longī is genitive m./n. and nominative plural m.');
      // The gender question is really asked on this card, whatever the form.
      expect(find(t, (q) => q.dimension == Dimension.genus), isNotNull);
    });

    test('the comparative card mixes third-class positives so fortī and fortiōre meet; the grid asks the degree too', () {
      final t = Trials.byId('comp-flexio');
      final pool = gen.pool(t, const []);
      expect(pool.map((e) => e.analysis.degree).toSet(), {Degree.positivus, Degree.comparativus});
      final abl = gen.pool(t, const []).where((e) => e.surface == 'fortiōre').toList();
      expect(abl, isNotEmpty, reason: 'fortiōre is in the pool beside fortī');
      expect(gen.correctValues(t, Dimension.casus, abl.first), {'abl'});
      expect(gen.pool(t, const []).any((e) => e.surface == 'fortī'), isTrue);
      final g = find(t, (q) => q.dimension == Dimension.gradus);
      expect(g, isNotNull);
    });

    test('irregular comparison: melius asks the lemma (bonus) and the degree', () {
      final t = Trials.byId('comp-irreg');
      final q = find(t, (q) => q.surface == 'melius' && q.dimension == Dimension.lemma, tries: 1500);
      expect(q, isNotNull);
      expect(q!.correctValues, {'bonus'});
      expect(q.choices.map((c) => c.label), contains('bonus'));
      final g = find(t, (q) => q.surface == 'plūs' && q.dimension == Dimension.gradus, tries: 1500);
      expect(g, isNotNull);
      expect(g!.correctValues, {'comp'});
    });

    test('adverbs: fortius is comparative and belongs to fortiter', () {
      final t = Trials.byId('comp-adv');
      final q = find(t, (q) => q.surface == 'fortius' && q.dimension == Dimension.gradus, tries: 1500);
      expect(q, isNotNull);
      expect(q!.correctValues, {'comp'});
      final l = find(t, (q) => q.surface == 'optimē' && q.dimension == Dimension.lemma, tries: 1500);
      expect(l, isNotNull);
      expect(l!.correctValues, {'bene'});
    });

    test('ego et tū: mē is accusative and ablative at once, mihi dative only; the person is asked', () {
      final t = Trials.byId('pron-ego-tu');
      // mē is accusative and ablative at once: both are accepted whenever the
      // form is drawn (the generator prefers unambiguous forms, so it is rare).
      final me = gen.pool(t, const []).firstWhere((e) => e.surface == 'mē');
      expect(gen.correctValues(t, Dimension.casus, me), {'acc', 'abl'});
      final mihi = find(t, (q) => q.surface == 'mihi' && q.dimension == Dimension.casus);
      expect(mihi, isNotNull);
      expect(mihi!.correctValues, {'dat'});
      final p = find(t, (q) => q.surface == 'tibi' && q.dimension == Dimension.persona);
      expect(p, isNotNull);
      expect(p!.correctValues, {'2'});
      expect(gen.pool(t, const []).every((e) => e.analysis.number == Numerus.singularis), isTrue);
    });

    test('the reflexive card mixes sibi with mihi and tibi: person discrimination', () {
      final t = Trials.byId('pron-se');
      final q = find(t, (q) => q.surface == 'sibi' && q.dimension == Dimension.persona);
      expect(q, isNotNull);
      expect(q!.correctValues, {'3'});
      expect(q.choices.length, 3);
    });

    test('hic: huius accepts every gender; hōc the masculine and neuter ablative', () {
      final t = Trials.byId('pron-hic');
      final hoc = gen.pool(t, const []).firstWhere((e) => e.surface == 'hōc');
      expect(gen.correctValues(t, Dimension.genus, hoc), {'m', 'n'}, reason: 'hōc is the masculine and neuter ablative');
      final c = find(t, (q) => q.surface == 'hunc' && q.dimension == Dimension.casus, tries: 1200);
      expect(c, isNotNull);
      expect(c!.correctValues, {'acc'});
      final h = gen.pool(t, const []).firstWhere((e) => e.surface == 'huius');
      expect(gen.correctValues(t, Dimension.genus, h), {'m', 'f', 'n'}, reason: 'huius is the genitive of all three genders');
      expect(Trials.byId('pron-hic').helpNote, contains('Septem fōrmae'));
    });

    test('demonstrativa omnia asks which pronoun; eundem belongs to īdem', () {
      final q = find(Trials.byId('pron-dem-omnia'), (q) => q.surface == 'eundem' && q.dimension == Dimension.lemma, tries: 1500);
      expect(q, isNotNull);
      expect(q!.correctValues, {'idem'});
      expect(q.choices.length, 4);
    });

    test('correlatives: tantus answers quantus; tot answers quot', () {
      final t = Trials.byId('pron-corr');
      final q = find(t, (q) => q.lemmaId == 'tantus' && q.dimension == Dimension.correlativum, tries: 1200);
      expect(q, isNotNull);
      expect(q!.correctValues, {'quantus'});
      final tot = gen.pool(t, const []).firstWhere((e) => e.surface == 'tot');
      expect(gen.correctValues(t, Dimension.correlativum, tot), {'quot'});
    });

    test('numerals: septem is VII and indeclinable; ducentīs is declinable; tertius is III', () {
      final t = Trials.byId('num-card');
      final q = find(t, (q) => q.surface == 'septem' && q.dimension == Dimension.valor, tries: 1200);
      expect(q, isNotNull);
      expect(q!.correctValues, {'7'});
      expect(q.choices.where((c) => c.value == '7').single.label, 'VII');
      final f = find(t, (q) => q.surface == 'septem' && q.dimension == Dimension.forma, tries: 1200);
      expect(f, isNotNull);
      expect(f!.correctValues, {'indeclinabile'});
      final d = find(t, (q) => q.dimension == Dimension.forma && q.lemmaId == 'ducenti', tries: 1200);
      expect(d, isNotNull);
      expect(d!.correctValues, {'declinabile'});
      final o = find(Trials.byId('num-ord'), (q) => q.lemmaId == 'tertius' && q.dimension == Dimension.valor, tries: 1200);
      expect(o, isNotNull);
      expect(o!.correctValues, {'3'});
    });

    test('full analysis appears once the skill is familiar and accepts every reading of the lemma', () {
      final t = Trials.byId('dec-5');
      final q = find(t, (q) => q.dimension == Dimension.analysis, skills: familiarFor(t));
      expect(q, isNotNull);
      final own = testNominalAnalyzer.analyzeAs(q!.surface, q.lemmaId).map((f) => f.analysis.selector).toSet();
      expect(q.correctValues, own);
      expect(find(t, (q) => q.dimension == Dimension.analysis, tries: 60), isNull, reason: 'nova skill: no analysis question yet');
    });

    test('mixed cards credit the card, the component and the cell; a component subset restricts the pool', () {
      final t = Trials.byId('mx-declinationes');
      final rng = Random(9);
      for (var i = 0; i < 30; i++) {
        final q = gen.generate(trial: t, componentIds: const ['d1', 'd3'], rng: rng, id: '$i')!;
        expect(q.skillIds.first, 'f.mx.declinationes');
        expect(q.skillIds[1], isIn(['f.dec.1', 'f.dec.3i']));
        if (q.dimension != Dimension.declinatio) expect(q.skillIds.last, startsWith('d.'));
        expect(q.forum.target.analysis.declension, isIn([Declension.prima, Declension.tertia]));
      }
    });

    test('a weak cell is drawn more often than strong ones', () {
      final t = Trials.byId('dec-1');
      final weak = List.generate(10, (i) => i).fold(const SkillRecord(), (r, i) => r.apply(Observation(at: DateTime(2026, 1, 1 + i), correct: false, lemmaId: 'l$i', quality: AnswerQuality.autonoma, trialId: 't'), const MasteryConfig()));
      final strong = List.generate(15, (i) => i).fold(const SkillRecord(), (r, i) => r.apply(Observation(at: DateTime(2026, 1, 1 + i), correct: true, lemmaId: 'l$i', quality: AnswerQuality.autonoma, trialId: 't'), const MasteryConfig()));
      final skills = {for (final l in Skills.leaves('d.1')) l: strong}..['d.1.abl.pl'] = weak;
      int count(Map<String, SkillRecord> s) {
        final rng = Random(11);
        var n = 0;
        for (var i = 0; i < 400; i++) {
          final q = gen.generate(trial: t, componentIds: const [], rng: rng, id: '$i', skills: s);
          if (q != null && q.forum.target.analysis.selector == 'abl.pl') n++;
        }
        return n;
      }
      expect(count(skills), greaterThan(count({for (final l in Skills.leaves('d.1')) l: strong}) * 3 ~/ 2));
    });

    test('corrections name the right case, the chosen one, the contrasting form and the ending', () {
      final q = find(Trials.byId('dec-1'), (q) => q.surface == 'rosam' && q.dimension == Dimension.casus, tries: 1500);
      expect(q, isNotNull);
      final ex = gen.explain(q: q!, chosenValue: 'abl', correct: false);
      expect(ex.headline, 'rosam — accūsātīvus singulāris (rosa, rosae, f.)');
      expect(ex.detail, contains('Rēctum: Accūsātīvus'));
      expect(ex.detail, contains('Tū dīxistī: Ablātīvus'), reason: 'a value that was not offered is still named in Latin');
      expect(ex.detail, contains('esset: rosā'));
      expect(ex.detail, contains('Dēsinentia -am'));
      expect(ex.contrastSurface, 'rosā');
      final adj = find(Trials.byId('adi-1-2'), (q) => q.surface == 'longam' && q.dimension == Dimension.casus, tries: 1500);
      expect(adj, isNotNull);
      final ex2 = gen.explain(q: adj!, chosenValue: 'nom', correct: false);
      expect(ex2.detail, contains('esset: longa'));
      expect(ex2.detail, contains('Dēsinentia -am'));
    });
  });

  group('contextual items', () {
    test('a contextual item accepts exactly the reading its context imposes, on the fixed case grid', () {
      final t = Trials.byId('syn-ae');
      final q = find(t, (q) => q.dimension == Dimension.casus && q.surface == 'rosae');
      expect(q, isNotNull);
      expect(q!.correctValues.length, 1);
      expect(q.syntagma, contains('{rosae}'));
      expect(q.choices.map((c) => c.value).toList(), containsAll(['nom', 'acc', 'gen', 'dat', 'abl']));
      expect(q.context, isEmpty);
      final ex = gen.explain(q: q, chosenValue: q.correctValues.first, correct: true);
      expect(ex.detail, contains(q.forum.syntagma!.note));
    });

    test('the relative card asks gender and number first, then the case, on the same item', () {
      final t = Trials.byId('rel-consensus');
      final q = find(t, (q) => true);
      expect(q, isNotNull);
      expect(q!.dimension, Dimension.genusNumerus);
      expect(q.followUp, isNotNull);
      expect(q.followUp!.dimension, Dimension.casus);
      expect(q.followUp!.surface, q.surface);
      expect(q.followUp!.syntagma, q.syntagma);
      expect(q.followUp!.id, isNot(q.id));
      expect(q.correctValues.single, '${q.forum.target.analysis.gender!.key}.${q.forum.target.analysis.number!.key}');
      expect(q.forum.syntagma!.head, isNotNull, reason: 'the antecedent is marked');
    });

    test('mē an mihi: case then function; both dimensions have several values', () {
      final t = Trials.byId('pron-me-mihi');
      final values = gen.poolValues(t, const []);
      expect(values[Dimension.casus]!.length, greaterThanOrEqualTo(3));
      expect(values[Dimension.functio]!.length, greaterThanOrEqualTo(3));
      final q = find(t, (q) => q.surface == 'mihi');
      expect(q!.dimension, Dimension.casus);
      expect(q.correctValues, {'dat'});
      expect(q.followUp!.dimension, Dimension.functio);
    });

    test('suus an eius: both relations appear and are decided by context alone', () {
      final t = Trials.byId('pron-suus-eius');
      final suus = find(t, (q) => q.lemmaId == 'suus');
      final eius = find(t, (q) => q.lemmaId == 'is');
      expect(suus!.correctValues, {Relatio.subiectum.key});
      expect(eius!.correctValues, {Relatio.alius.key});
      expect(suus.choices.length, 2);
    });

    test('quis an quī: the kind of pronoun is read from the context', () {
      final t = Trials.byId('pron-quis-qui');
      final rel = find(t, (q) => q.dimension == Dimension.forma && q.lemmaId == 'qui');
      final int_ = find(t, (q) => q.dimension == Dimension.forma && q.lemmaId == 'quis');
      expect(rel!.correctValues, {'relativum'});
      expect(int_!.correctValues, {'interrogativum'});
    });

    test('distant agreement: the choices are the nouns of the phrase in text order and only the head is right', () {
      final t = Trials.byId('con-distans');
      final q = find(t, (q) => q.dimension == Dimension.quodNomen);
      expect(q, isNotNull);
      final s = q!.forum.syntagma!;
      expect(q.correctValues, {s.head});
      expect(q.choices.length, s.candidates.length + 1);
      for (final c in q.choices) {
        expect(s.plain, contains(c.label));
      }
    });

    test('case functions: datives after pāreō-type verbs, contrasted with objects; town names carry the locative', () {
      final dat = Trials.byId('cas-verba-dat');
      expect(gen.poolValues(dat, const [])[Dimension.functio]!.length, greaterThanOrEqualTo(2));
      final q = find(dat, (q) => q.dimension == Dimension.functio && q.forum.target.analysis.casus == Casus.dativus);
      expect(q!.correctValues.single, isIn([Functio.obiectumDativum.key, Functio.datum.key]));
      final loci = Trials.byId('cas-loci');
      final loc = find(loci, (q) => q.dimension == Dimension.casus && q.forum.target.analysis.casus == Casus.locativus);
      expect(loc, isNotNull);
      expect(loc!.choices.map((c) => c.value), contains('loc'));
      final ctor = find(loci, (q) => q.dimension == Dimension.constructio);
      expect(ctor!.choices.length, greaterThanOrEqualTo(2));
    });

    test('mīlle et mīlia: both constructions are drawn', () {
      final t = Trials.byId('num-mille');
      expect(gen.poolValues(t, const [])[Dimension.constructio], {Constructio.milleAdiectivum.key, Constructio.miliaGenetivus.key});
    });

    test('a contextual form remembers the miss under its own form key and recalls it later', () {
      final t = Trials.byId('syn-o');
      final q = find(t, (q) => q.dimension == Dimension.casus);
      expect(q!.errata!.formKey, 'd|${q.lemmaId}|${q.forum.target.analysis.selector}');
      final recall = Recall(forms: {q.errata!.formKey}, cells: {q.errata!.cellKey});
      int count(Recall r) {
        final rng = Random(5);
        var n = 0;
        for (var i = 0; i < 300; i++) {
          final x = gen.generate(trial: t, componentIds: const [], rng: rng, id: '$i', recall: r);
          if (x != null && x.surface == q.surface && x.lemmaId == q.lemmaId) n++;
        }
        return n;
      }
      expect(count(recall), greaterThan(count(Recall.none)));
    });

    test('filters: a syntagma filter matches by tag and tier', () {
      const f = SyntagmaFilter({'syn-ae'}, tiers: {0});
      const s0 = Syntagma(id: 'x', text: 'a {b}', lemmaId: 'rosa', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-ae'});
      const s1 = Syntagma(id: 'y', text: 'a {b}', lemmaId: 'rosa', casus: Casus.nominativus, number: Numerus.singularis, tags: {'syn-ae'}, tier: 1);
      expect(f.matches(s0), isTrue);
      expect(f.matches(s1), isFalse);
      expect(SyntagmaRun.parse('rosae {spīnae} pungunt').map((r) => '${r.target ? '*' : ''}${r.text}').toList(), ['rosae ', '*spīnae', ' pungunt']);
    });
  });
}
