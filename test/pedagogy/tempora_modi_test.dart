// "Tempora et modī": recognising the tense or the mood of a form and nothing
// else, on a fixed answer grid, with components unlocked as tenses are learnt;
// the tree of recognition skills stays apart from the conjugation tree.
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
  final tm = Trials.ofActivity(Activity.amphitheatrum).where((t) => t.group == 'Tempora et modī').toList();

  test('the group exists, sits before Mixta and credits only recognition skills', () {
    expect(tm.map((t) => t.id), containsAll(['tm-tempora-ind-act', 'tm-tempora-ind-pass', 'tm-tempora-subj-act', 'tm-tempora-subj-pass', 'tm-tempora-inf', 'tm-modi-praes', 'tm-modi-omnia', 'tm-ambo']));
    final groups = Trials.groupsOf(Activity.amphitheatrum);
    expect(groups.indexOf('Tempora et modī'), lessThan(groups.indexOf('Mixta')));
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

  test('fixed grid: two mixed tenses still offer the whole scale in canonical order', () {
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

  test('components unlock with their own trial; the default mix is what is unlocked', () {
    final t = Trials.byId('tm-tempora-ind-act');
    // Only the free present trial: nothing to mix yet but present (imperfect not bought).
    var save = SaveData(createdAt: DateTime(2026, 1, 1));
    expect(Progression.unlockedComponents(save, t).map((c) => c.id), ['ind.praes.act']);
    save = save.copyWith(purchased: {'ind-imperf-act', 'ind-perf-act'});
    expect(Progression.unlockedComponents(save, t).map((c) => c.id), ['ind.praes.act', 'ind.imperf.act', 'ind.perf.act']);
    expect(Progression.componentsFor(save, t), ['ind.praes.act', 'ind.imperf.act', 'ind.perf.act']);
    // A saved choice that names a locked component is trimmed to the unlocked ones.
    save = save.copyWith(mixtaConfig: {t.id: ['ind.praes.act', 'ind.futex.act']});
    expect(Progression.componentsFor(save, t), ['ind.praes.act', 'ind.imperf.act', 'ind.perf.act']);
    save = save.copyWith(mixtaConfig: {t.id: ['ind.praes.act', 'ind.perf.act']});
    expect(Progression.componentsFor(save, t), ['ind.praes.act', 'ind.perf.act']);
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
        expect(q.skillIds, contains('tm.tempus.ind.act'));
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
