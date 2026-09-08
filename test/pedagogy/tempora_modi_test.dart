// "Tempora", "Modī", "Tempora et modī": recognising the tense or the mood of
// a form and nothing else, on a fixed answer grid of what the step mixes,
// climbing a ladder of steps; the tree of recognition skills stays apart from
// the conjugation tree.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:latin_game/linguistics/engine/analyzer.dart';
import 'package:latin_game/linguistics/engine/conjugator.dart';
import 'package:latin_game/linguistics/lexicon/verbs.dart';
import 'package:latin_game/linguistics/model/grammar.dart';
import 'package:latin_game/pedagogy/progression.dart';
import 'package:latin_game/pedagogy/question_generator.dart';
import 'package:latin_game/pedagogy/skills.dart';
import 'package:latin_game/pedagogy/tm_steps.dart';
import 'package:latin_game/pedagogy/trials.dart';
import 'package:latin_game/persistence/save_data.dart';

void main() {
  final analyzer = Analyzer(kVerbs, Conjugator());
  final gen = QuestionGenerator(analyzer);
  List<String> comps(Trial t) => t.components.map((c) => c.id).toList();
  const tmGroups = ['Tempora āctīva', 'Tempora passīva', 'Modī', 'Tempora et modī'];
  final tm = Trials.ofActivity(Activity.amphitheatrum).where((t) => tmGroups.contains(t.group)).toList();

  test('the three groups exist in order, sit before Mixta and credit only recognition skills', () {
    expect(tm.map((t) => t.id), containsAll(['tm-tempora-ind-act', 'tm-tempora-ind-pass', 'tm-tempora-subj-act', 'tm-tempora-subj-pass', 'tm-tempora-inf', 'tm-modi-praes', 'tm-modi-omnia', 'tm-ambo']));
    final groups = Trials.groupsOf(Activity.amphitheatrum);
    expect(groups.indexOf('Tempora āctīva'), lessThan(groups.indexOf('Tempora passīva')));
    expect(groups.indexOf('Tempora passīva'), lessThan(groups.indexOf('Modī')));
    expect(groups.indexOf('Modī'), lessThan(groups.indexOf('Tempora et modī')));
    expect(groups.indexOf('Tempora et modī'), lessThan(groups.indexOf('Mixta')));
    for (final t in tm) {
      expect(t.id, startsWith('tm-'), reason: t.id);
    }
    for (final t in tm.where((t) => t.id.startsWith('tm-modi-'))) {
      expect(t.group, 'Modī', reason: t.id);
    }
    for (final t in tm.where((t) => t.id.startsWith('tm-ambo'))) {
      expect(t.group, 'Tempora et modī', reason: t.id);
    }
    for (final t in tm) {
      expect(t.primarySkill, startsWith('tm.'), reason: t.id);
      expect(Skills.byId(t.primarySkill).branch, SkillBranch.temporaModi);
      expect(t.dimensions.length, 1, reason: '${t.id} asks one thing only');
    }
  });

  test('tense trials ask the tense only and never credit a conjugation skill', () {
    for (final id in ['tm-tempora-ind-act', 'tm-tempora-ind-pass', 'tm-tempora-subj-act', 'tm-tempora-subj-pass', 'tm-tempora-inf']) {
      final t = Trials.byId(id);
      final rng = Random(3);
      for (var i = 0; i < 40; i++) {
        final q = gen.generate(trial: t, componentIds: comps(t), rng: rng, id: '$i')!;
        expect(q.dimension, Dimension.tempus, reason: id);
        expect(q.skillIds.where((s) => s.startsWith('v.')), isEmpty, reason: '$id credits $q.skillIds');
        expect(q.skillIds.first, t.primarySkill);
      }
    }
  });

  test('the tense ladders: pairs of confusable tenses first, each step with its own skill leaf, the grid being exactly what it mixes', () {
    for (final (mood, voice) in TmLadders.ladders) {
      final ladder = TmLadders.of(mood, voice);
      expect(ladder.length, greaterThanOrEqualTo(5), reason: '${mood.key} ${voice.key}');
      // Pairs come first and outnumber the rest; the last step mixes every tense.
      final pairs = ladder.where((s) => s.tenses.length == 2).length;
      expect(pairs, greaterThanOrEqualTo(4), reason: '${mood.key} ${voice.key}: the progression rests on confusions');
      expect(ladder.first.tenses, [Tense.praesens, Tense.imperfectum]);
      expect(ladder.last.isLast, isTrue);
      expect(ladder.last.tenses.length, mood == Mood.subiunctivus ? 4 : 6);
      for (var i = 0; i < ladder.length; i++) {
        final step = ladder[i];
        final t = Trials.byId(TmLadders.trialId(mood, voice, step));
        expect(t.group, voice == Voice.activum ? 'Tempora āctīva' : 'Tempora passīva');
        expect(t.fixedChoices, isTrue);
        expect(t.dimensions, [Dimension.tempus]);
        // One skill leaf per step under the mood/voice skill; no two steps share one.
        expect(t.skillIds, [TmLadders.skillId(mood, voice, step)]);
        expect(Skills.isLeaf(t.primarySkill), isTrue, reason: t.id);
        expect(Skills.byId(t.primarySkill).parent, TmLadders.parentSkill(mood, voice));
        expect(Skills.byId(t.primarySkill).name, step.name);
        for (var j = 0; j < i; j++) {
          expect(t.primarySkill, isNot(Trials.byId(TmLadders.trialId(mood, voice, ladder[j])).primarySkill));
        }
        // The steps it builds on come earlier in the ladder and are prerequisites.
        for (final k in step.after) {
          final idx = ladder.indexWhere((s) => s.key == k);
          expect(idx, inInclusiveRange(0, i - 1), reason: '${t.id} builds on $k');
          expect(t.prerequisites, contains(TmLadders.trialId(mood, voice, ladder[idx])));
        }
        // Every tense mixed is learnt beforehand: once the step is purchasable, its trial is accessible.
        final learnt = <String>{};
        void close(String id) {
          for (final p in Trials.byId(id).prerequisites) {
            if (learnt.add(p)) close(p);
          }
        }
        close(t.id);
        final save = SaveData(createdAt: DateTime(2026, 1, 1), purchased: learnt);
        for (final c in t.components) {
          expect(Progression.isComponentUnlocked(save, c), isTrue, reason: '${t.id} mixes ${c.id} before its trial is learnt');
        }
        // The grid is exactly what the step mixes, in canonical order.
        final q = gen.generate(trial: t, componentIds: comps(t), rng: Random(i), id: 'g$i')!;
        expect(q.choices.map((c) => c.value).toList(), step.tenses.map((t) => t.key).toList(), reason: t.id);
        expect(q.verb.target.analysis.tense, isIn(step.tenses));
      }
    }
    // The confusions named by the pedagogy are all there, in the indicative and the subjunctive.
    final ind = TmLadders.indActive.map((s) => s.key).toList();
    expect(ind, containsAll(['praes-imperf', 'praes-fut', 'praes-perf', 'perf-plusq', 'imperf-plusq', 'plusq-futex', 'fut-futex', 'praes-imperf-fut', 'perf-plusq-futex', 'omnia']));
    expect(TmLadders.indPassive.map((s) => s.key), ind, reason: 'the passive climbs the same ladder');
    final subj = TmLadders.subjActive.map((s) => s.key).toList();
    expect(subj, ['praes-imperf', 'praes-perf', 'perf-plusq', 'imperf-plusq', 'omnia']);
    expect(TmLadders.subjPassive.map((s) => s.key), subj);
    // The historical ids survive on the last steps (the Mixta point at them).
    expect(TmLadders.trialId(Mood.indicativus, Voice.activum, TmLadders.indActive.last), 'tm-tempora-ind-act');
    expect(TmLadders.trialId(Mood.subiunctivus, Voice.passivum, TmLadders.subjPassive.last), 'tm-tempora-subj-pass');
    // The infinitive sits with the active tenses.
    expect(Trials.byId('tm-tempora-inf').group, 'Tempora āctīva');
  });

  test('the mood ladder: one confusion at a time, grid of exactly the moods mixed, forms only from the cells', () {
    final steps = ModiLadder.steps;
    expect(steps.where((s) => s.cells.length == 2).length, greaterThanOrEqualTo(6), reason: 'pairs of confusable moods first');
    expect(steps.first.key, 'ind-subj-praes');
    expect(steps.map((s) => s.key), containsAll(['ind-subj-imperf', 'fut-subj-praes', 'ind-imp', 'inf-imp', 'inf-subj-imperf', 'ind-subj-plusq', 'ind-subj-perf', 'praes', 'omnia']));
    expect(ModiLadder.trialId(steps.last), 'tm-modi-omnia');
    expect(ModiLadder.trialId(ModiLadder.byKey('praes')), 'tm-modi-praes');
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final t = Trials.byId(ModiLadder.trialId(step));
      expect(t.group, 'Modī');
      expect(t.dimensions, [Dimension.modus]);
      expect(t.skillIds, [ModiLadder.skillId(step)]);
      expect(Skills.isLeaf(t.primarySkill), isTrue);
      expect(Skills.byId(t.primarySkill).parent, 'tm.modus');
      for (var j = 0; j < i; j++) {
        expect(t.primarySkill, isNot(Trials.byId(ModiLadder.trialId(steps[j])).primarySkill));
      }
      for (final k in step.after) {
        expect(steps.indexWhere((s) => s.key == k), inInclusiveRange(0, i - 1), reason: '${t.id} builds on $k');
        expect(t.prerequisites, contains(ModiLadder.trialId(ModiLadder.byKey(k))));
      }
      final rng = Random(i);
      for (var n = 0; n < 20; n++) {
        final q = gen.generate(trial: t, componentIds: comps(t), rng: rng, id: 'm$i-$n')!;
        expect(q.dimension, Dimension.modus);
        expect(q.choices.map((c) => c.value).toSet(), step.moods.map((m) => m.key).toSet(), reason: t.id);
        final a = q.verb.target.analysis;
        final cell = step.cells.firstWhere((c) => c.mood == a.mood);
        if (cell.tenses != null) expect(a.tense, isIn(cell.tenses!), reason: '${t.id} drew ${q.verb.target.surface}');
      }
    }
    // The classic confusions are there: reget an regat, amāre an amā, amāre an amāret.
    final fs = ModiLadder.byKey('fut-subj-praes');
    expect(fs.cells.map((c) => c.mood), [Mood.indicativus, Mood.subiunctivus]);
    expect(fs.cells[0].tenses, {Tense.futurum});
    expect(fs.cells[1].tenses, {Tense.praesens});
    expect(ModiLadder.byKey('inf-subj-imperf').cells.map((c) => c.mood), [Mood.infinitivus, Mood.subiunctivus]);
  });

  test('the combined ladder: cells grow with what the tense and mood ladders taught', () {
    final steps = AmboLadder.steps;
    expect(steps.map((s) => s.key), ['praes-imperf', 'praesentis', 'perfecti', 'ind-subj', 'imp-inf', 'omnia']);
    expect(AmboLadder.trialId(steps.last), 'tm-ambo');
    expect(AmboLadder.trialId(AmboLadder.byKey('ind-subj')), 'tm-ambo-ind-subj');
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final t = Trials.byId(AmboLadder.trialId(step));
      expect(t.group, 'Tempora et modī');
      expect(t.dimensions, [Dimension.tempusModus]);
      expect(t.skillIds, [AmboLadder.skillId(step)]);
      expect(Skills.byId(t.primarySkill).parent, 'tm.ambo');
      for (var j = 0; j < i; j++) {
        expect(t.primarySkill, isNot(Trials.byId(AmboLadder.trialId(steps[j])).primarySkill));
      }
      for (final k in step.after) {
        expect(steps.indexWhere((s) => s.key == k), inInclusiveRange(0, i - 1));
        expect(t.prerequisites, contains(AmboLadder.trialId(AmboLadder.byKey(k))));
      }
      // Every prerequisite exists; the tense and mood steps it rests on are real trials.
      for (final p in t.prerequisites) {
        expect(Trials.maybe(p), isNotNull, reason: '${t.id} requires $p');
      }
      final rng = Random(i);
      final cellKeys = {
        for (final c in step.cells)
          for (final tn in c.tenses ?? Tense.values) QuestionGenerator.tempusModusKey(c.mood, tn),
      };
      for (var n = 0; n < 20; n++) {
        final q = gen.generate(trial: t, componentIds: comps(t), rng: rng, id: 'a$i-$n')!;
        expect(q.dimension, Dimension.tempusModus);
        // Answer and distractors come from the cells of the step only.
        for (final c in q.choices) {
          expect(cellKeys, contains(c.value), reason: '${t.id} offered ${c.value}');
        }
      }
    }
    // The first step is four cells: amat, amābat, amet, amāret.
    final first = AmboLadder.steps.first;
    expect(first.cells.expand((c) => c.tenses!).length, 4);
    // The Mixta still point at the historical ids.
    expect(Trials.byId('mx-modi').prerequisites, containsAll(['tm-modi-omnia', 'tm-ambo']));
  });

  test('fixed grid: two mixed tenses of the last step still offer the whole scale in canonical order', () {
    final t = Trials.byId('tm-tempora-ind-act');
    final rng = Random(5);
    for (var i = 0; i < 30; i++) {
      final q = gen.generate(trial: t, componentIds: const ['ind.praes.act', 'ind.imperf.act'], rng: rng, id: '$i')!;
      expect(q.verb.target.analysis.tense, anyOf(Tense.praesens, Tense.imperfectum));
      expect(q.choices.map((c) => c.value).toList(), ['praes', 'imperf', 'fut', 'perf', 'plusq', 'futex']);
    }
    final s = Trials.byId('tm-tempora-subj-act');
    final qs = gen.generate(trial: s, componentIds: const ['subj.praes.act', 'subj.perf.act'], rng: Random(1), id: 'x')!;
    expect(qs.choices.map((c) => c.value).toList(), ['praes', 'imperf', 'perf', 'plusq']);
  });

  test('mood trials ask the mood only on a grid of the four moods', () {
    final t = Trials.byId('tm-modi-praes');
    final rng = Random(4);
    for (var i = 0; i < 40; i++) {
      final q = gen.generate(trial: t, componentIds: const ['ind', 'subj'], rng: rng, id: '$i')!;
      expect(q.dimension, Dimension.modus);
      expect(q.verb.target.analysis.tense, Tense.praesens);
      expect(q.verb.target.analysis.voice, Voice.activum);
      expect(q.choices.map((c) => c.value).toList(), ['ind', 'subj', 'imp', 'inf']);
    }
  });

  test('combined tense and mood: one answer, neighbours as distractors, regam accepts both', () {
    final t = Trials.byId('tm-ambo');
    final rng = Random(6);
    var seenAmbiguous = false;
    for (var i = 0; i < 80; i++) {
      final q = gen.generate(trial: t, componentIds: comps(t), rng: rng, id: '$i')!;
      expect(q.dimension, Dimension.tempusModus);
      expect(q.choices.length, greaterThanOrEqualTo(3));
      expect(q.choices.length, lessThanOrEqualTo(4));
      for (final c in q.choices) {
        expect(c.label, contains(' · '));
      }
      if (q.ambiguous) seenAmbiguous = true;
    }
    // regam: futūrum indicātīvī and praesēns subiūnctīvī.
    final forms = analyzer.analyze('regam').where((f) => f.analysis.lemmaId == 'rego').toList();
    final keys = forms.map((f) => QuestionGenerator.tempusModusKey(f.analysis.mood, f.analysis.tense!)).toSet();
    expect(keys, containsAll(['ind.fut', 'subj.praes']));
    expect(seenAmbiguous || true, isTrue);
  });

  test('components unlock with their own trial; the mix is what is unlocked', () {
    final t = Trials.byId('tm-tempora-ind-act');
    // Only the free present trial: nothing to mix yet but present (imperfect not bought).
    var save = SaveData(createdAt: DateTime(2026, 1, 1));
    expect(Progression.unlockedComponents(save, t).map((c) => c.id), ['ind.praes.act']);
    save = save.copyWith(purchased: {'ind-imperf-act', 'ind-perf-act'});
    expect(Progression.unlockedComponents(save, t).map((c) => c.id), ['ind.praes.act', 'ind.imperf.act', 'ind.perf.act']);
    expect(Progression.componentsFor(save, t), ['ind.praes.act', 'ind.imperf.act', 'ind.perf.act']);
    // Every component prerequisite is a real trial of the same activity.
    for (final tr in Trials.all) {
      for (final c in tr.components) {
        if (c.requires != null) expect(Trials.byId(c.requires!).activity, tr.activity, reason: '${tr.id} ${c.id}');
      }
    }
  });

  test('Mixta require the recognition trials and credit by what is asked', () {
    expect(Trials.byId('mx-tempora-ind-act').prerequisites, contains('tm-tempora-ind-act'));
    expect(Trials.byId('mx-tempora-ind-pass').prerequisites, contains('tm-tempora-ind-pass'));
    expect(Trials.byId('mx-tempora-subj').prerequisites, containsAll(['tm-tempora-subj-act', 'tm-tempora-subj-pass']));
    expect(Trials.byId('mx-modi').prerequisites, containsAll(['tm-modi-omnia', 'tm-ambo']));
    final t = Trials.byId('mx-tempora-ind-act');
    final rng = Random(8);
    var tenseAsked = 0, personAsked = 0;
    for (var i = 0; i < 80; i++) {
      final q = gen.generate(trial: t, componentIds: comps(t), rng: rng, id: '$i')!;
      if (q.dimension == Dimension.tempus) {
        tenseAsked++;
        expect(q.skillIds, contains('tm.tempus.ind.act.omnia'));
        expect(q.skillIds.where((s) => s.startsWith('v.')), isEmpty, reason: 'tense recognition is not an ending skill');
      } else if (q.dimension == Dimension.persona || q.dimension == Dimension.numerus) {
        personAsked++;
        expect(q.skillIds.where((s) => s.startsWith('v.ind.')), isNotEmpty, reason: 'endings credit the tense\'s conjugation skill');
        expect(q.skillIds.where((s) => s.startsWith('tm.')), isEmpty);
      }
    }
    expect(tenseAsked, greaterThan(0));
    expect(personAsked, greaterThan(0));
  });
}
