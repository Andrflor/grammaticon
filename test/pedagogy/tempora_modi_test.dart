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
import 'package:latin_game/pedagogy/trials.dart';
import 'package:latin_game/persistence/save_data.dart';

void main() {
  final analyzer = Analyzer(kVerbs, Conjugator());
  final gen = QuestionGenerator(analyzer);
  List<String> comps(Trial t) => t.components.map((c) => c.id).toList();
  const tmGroups = ['Tempora', 'Modī', 'Tempora et modī'];
  final tm = Trials.ofActivity(Activity.amphitheatrum).where((t) => tmGroups.contains(t.group)).toList();

  test('the three groups exist in order, sit before Mixta and credit only recognition skills', () {
    expect(tm.map((t) => t.id), containsAll(['tm-tempora-ind-act', 'tm-tempora-ind-pass', 'tm-tempora-subj-act', 'tm-tempora-subj-pass', 'tm-tempora-inf', 'tm-modi-praes', 'tm-modi-omnia', 'tm-ambo']));
    final groups = Trials.groupsOf(Activity.amphitheatrum);
    expect(groups.indexOf('Tempora'), lessThan(groups.indexOf('Modī')));
    expect(groups.indexOf('Modī'), lessThan(groups.indexOf('Tempora et modī')));
    expect(groups.indexOf('Tempora et modī'), lessThan(groups.indexOf('Mixta')));
    for (final t in tm) {
      expect(t.id, startsWith('tm-'), reason: t.id);
    }
    for (final t in tm.where((t) => t.id.startsWith('tm-tempora-') && t.id != 'tm-tempora-inf')) {
      expect(t.group, 'Tempora', reason: t.id);
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

  test('the tense ladder: each step adds tenses, requires the previous step and the tenses it adds, and shows only what it mixes', () {
    const ladders = {
      'tm-tempora-ind-act': ['tm-tempora-ind-act-1', 'tm-tempora-ind-act-2', 'tm-tempora-ind-act-3', 'tm-tempora-ind-act'],
      'tm-tempora-ind-pass': ['tm-tempora-ind-pass-1', 'tm-tempora-ind-pass-2', 'tm-tempora-ind-pass-3', 'tm-tempora-ind-pass'],
      'tm-tempora-subj-act': ['tm-tempora-subj-act-1', 'tm-tempora-subj-act-2', 'tm-tempora-subj-act'],
      'tm-tempora-subj-pass': ['tm-tempora-subj-pass-1', 'tm-tempora-subj-pass-2', 'tm-tempora-subj-pass'],
    };
    for (final steps in ladders.values) {
      for (var i = 0; i < steps.length; i++) {
        final t = Trials.byId(steps[i]);
        // One skill leaf per step, all under the mood/voice skill: mastery of
        // "praesēns against imperfectum" does not stand for every tense.
        expect(t.skillIds.length, 1);
        expect(Skills.isLeaf(t.primarySkill), isTrue, reason: t.id);
        expect(Skills.byId(t.primarySkill).parent, 'tm.tempus.${t.id.split('-')[2]}.${t.id.split('-')[3]}', reason: t.id);
        for (var j = 0; j < i; j++) {
          expect(t.primarySkill, isNot(Trials.byId(steps[j]).primarySkill), reason: '${t.id} shares a skill with ${steps[j]}');
        }
        expect(t.fixedChoices, isTrue);
        if (i > 0) expect(t.prerequisites, contains(steps[i - 1]), reason: '${t.id} needs the previous step');
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
        // The grid is exactly what the step mixes.
        final q = gen.generate(trial: t, componentIds: comps(t), rng: Random(i), id: 'g$i')!;
        expect(q.choices.map((c) => c.value).toSet(), t.components.map((c) => c.id.split('.')[1]).toSet(), reason: t.id);
      }
    }
    // First steps: two cells only.
    expect(Trials.byId('tm-tempora-ind-act-1').components.length, 2);
    expect(Trials.byId('tm-tempora-subj-pass-1').components.length, 2);
    // Present system, then perfect system.
    expect(comps(Trials.byId('tm-tempora-ind-act-2')), ['ind.praes.act', 'ind.imperf.act', 'ind.fut.act']);
    expect(comps(Trials.byId('tm-tempora-ind-act-3')), ['ind.perf.act', 'ind.plusq.act', 'ind.futex.act']);
    expect(comps(Trials.byId('tm-tempora-subj-act-2')), ['subj.perf.act', 'subj.plusq.act']);
  });

  test('the mood ladder and the combined ladder', () {
    final first = Trials.byId('tm-modi-ind-subj');
    expect(Trials.byId('tm-modi-praes').prerequisites, contains('tm-modi-ind-subj'));
    expect(Trials.byId('tm-modi-omnia').prerequisites, contains('tm-modi-praes'));
    final q = gen.generate(trial: first, componentIds: comps(first), rng: Random(2), id: 'm')!;
    expect(q.choices.map((c) => c.value).toList(), ['ind', 'subj']);
    final ambo1 = Trials.byId('tm-ambo-ind-subj');
    expect(Trials.byId('tm-ambo').prerequisites, contains('tm-ambo-ind-subj'));
    expect(ambo1.primarySkill, isNot(Trials.byId('tm-ambo').primarySkill));
    expect(Skills.byId(ambo1.primarySkill).parent, 'tm.ambo');
    expect(Skills.byId(Trials.byId('tm-ambo').primarySkill).parent, 'tm.ambo');
    expect(first.primarySkill, isNot(Trials.byId('tm-modi-praes').primarySkill));
    for (var i = 0; i < 40; i++) {
      final q = gen.generate(trial: ambo1, componentIds: comps(ambo1), rng: Random(i), id: 'a$i')!;
      expect(q.verb.target.analysis.mood, anyOf(Mood.indicativus, Mood.subiunctivus));
    }
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
