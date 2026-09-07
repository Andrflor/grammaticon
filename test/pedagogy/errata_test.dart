import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:latin_game/battle/answer_resolver.dart';
import 'package:latin_game/linguistics/model/grammar.dart';
import 'package:latin_game/pedagogy/mastery.dart';
import 'package:latin_game/pedagogy/noun_question_generator.dart';
import 'package:latin_game/pedagogy/question_generator.dart';
import 'package:latin_game/pedagogy/trials.dart';
import 'package:latin_game/persistence/save_data.dart';

import '../support/test_env.dart';

void main() {
  const note = ErrataNote(formKey: 'd|rosa|abl.pl', cellKey: 'd|1|abl.pl', analysis: 'ablātīvus plūrālis');
  final t0 = DateTime(2026, 3, 1);

  group('ErrorLedger', () {
    test('a miss opens an erratum with its confusion; a second miss counts and resets fixes', () {
      var led = const ErrorLedger().miss(note, lemmaId: 'rosa', surface: 'rosīs', chosenLabel: 'Datīvus', trialId: 'd1-omnes', now: t0, battleSeed: 1);
      expect(led.openCount, 1);
      expect(led.items['d|rosa|abl.pl']!.confusions, {'Datīvus': 1});
      led = led.fix('d|rosa|abl.pl');
      expect(led.items['d|rosa|abl.pl']!.fixes, 1);
      led = led.miss(note, lemmaId: 'rosa', surface: 'rosīs', chosenLabel: 'Datīvus', trialId: 'd1-omnes', now: t0.add(const Duration(days: 1)), battleSeed: 2);
      final e = led.items['d|rosa|abl.pl']!;
      expect(e.misses, 2);
      expect(e.fixes, 0);
      expect(e.topConfusion, 'Datīvus');
      expect(e.lastBattle, 2);
    });

    test('two autonomous fixes retire the erratum and count it as corrected', () {
      var led = const ErrorLedger().miss(note, lemmaId: 'rosa', surface: 'rosīs', chosenLabel: 'Datīvus', trialId: 'd1-omnes', now: t0, battleSeed: 1);
      led = led.fix('d|rosa|abl.pl');
      expect(led.openCount, 1);
      led = led.fix('d|rosa|abl.pl');
      expect(led.isEmpty, isTrue);
      expect(led.retired, 1);
      // Fixing an unknown form is a no-op.
      expect(identical(led.fix('d|rosa|abl.pl'), led), isTrue);
    });

    test('recall covers earlier fights only, never the fight where the error was made', () {
      final led = const ErrorLedger()
          .miss(note, lemmaId: 'rosa', surface: 'rosīs', chosenLabel: 'Datīvus', trialId: 'd1-omnes', now: t0, battleSeed: 7)
          .miss(const ErrataNote(formKey: 'v|amo|ind.praes.act.2.pl', cellKey: 'v|ind.praes.act.2.pl', analysis: 'secunda plūrālis'), lemmaId: 'amo', surface: 'amātis', chosenLabel: 'Secunda singulāris', trialId: 'ind-praes-act', now: t0, battleSeed: 8);
      final inFight7 = led.recall(7);
      expect(inFight7.forms, {'v|amo|ind.praes.act.2.pl'});
      expect(inFight7.cells, {'v|ind.praes.act.2.pl'});
      final later = led.recall(99);
      expect(later.forms, {'d|rosa|abl.pl', 'v|amo|ind.praes.act.2.pl'});
      expect(later.boost('d|rosa|abl.pl', 'd|1|abl.pl'), Recall.formBoost);
      expect(later.boost('d|puella|abl.pl', 'd|1|abl.pl'), Recall.cellBoost);
      expect(later.boost('d|puella|gen.sg', 'd|1|gen.sg'), 1.0);
    });

    test('groups by cell, most missed first, with the usual confusion; json round trip', () {
      var led = const ErrorLedger();
      for (var i = 0; i < 3; i++) {
        led = led.miss(note, lemmaId: 'rosa', surface: 'rosīs', chosenLabel: i == 0 ? 'Genetīvus' : 'Datīvus', trialId: 'd1-omnes', now: t0.add(Duration(hours: i)), battleSeed: i);
      }
      led = led.miss(const ErrataNote(formKey: 'd|puella|abl.pl', cellKey: 'd|1|abl.pl', analysis: 'ablātīvus plūrālis'), lemmaId: 'puella', surface: 'puellīs', chosenLabel: 'Datīvus', trialId: 'd1-omnes', now: t0, battleSeed: 5);
      led = led.miss(const ErrataNote(formKey: 'd|rosa|gen.sg', cellKey: 'd|1|gen.sg', analysis: 'genetīvus singulāris'), lemmaId: 'rosa', surface: 'rosae', chosenLabel: 'Datīvus', trialId: 'd1-omnes', now: t0, battleSeed: 5);
      final groups = led.groups();
      expect(groups.map((g) => g.cellKey), ['d|1|abl.pl', 'd|1|gen.sg']);
      expect(groups.first.misses, 4);
      expect(groups.first.surfaces, ['rosīs', 'puellīs']);
      expect(groups.first.topConfusion, 'Datīvus');
      final back = ErrorLedger.fromJson(led.toJson());
      expect(back.openCount, 3);
      expect(back.items['d|rosa|abl.pl']!.misses, 3);
      expect(back.items['d|rosa|abl.pl']!.confusions['Datīvus'], 2);
      expect(back.retired, 0);
    });
  });

  group('resolution', () {
    final gen = NounQuestionGenerator(testNounAnalyzer);
    const resolver = AnswerResolver();
    final t = Trials.byId('d1-recti');

    Question unambiguous() {
      final rng = Random(3);
      for (var i = 0; i < 50; i++) {
        final q = gen.generate(trial: t, componentIds: const [], rng: rng, id: '$i')!;
        if (!q.ambiguous && q.correctValues.length == 1) return q;
      }
      fail('no unambiguous question');
    }

    test('a wrong answer records the form, its cell and the chosen label; the fight seed is kept', () {
      final q = unambiguous();
      final wrong = q.choices.firstWhere((c) => !q.correctValues.contains(c.value));
      final save = SaveData(createdAt: t0);
      final r = resolver.resolve(save: save, q: q, chosenValue: wrong.value, quality: AnswerQuality.autonoma, mode: BattleMode.certamen, now: t0, battleSeed: 42);
      expect(r.correct, isFalse);
      final e = r.errataAfter.items[q.errata!.formKey]!;
      expect(e.formKey, 'd|${q.lemmaId}|${q.noun.target.analysis.selector}');
      expect(e.cellKey, 'd|1|${q.noun.target.analysis.selector}');
      expect(e.surface, q.surface);
      expect(e.confusions, {wrong.label: 1});
      expect(e.lastBattle, 42);
      expect(e.trialId, 'd1-recti');
      // The error made in fight 42 is not recalled in fight 42, but is later.
      expect(r.errataAfter.recall(42).isEmpty, isTrue);
      expect(r.errataAfter.recall(43).forms, {e.formKey});
    });

    test('autonomous correct answers retire a missed form after two; an aided one does not count', () {
      final q = unambiguous();
      final wrong = q.choices.firstWhere((c) => !q.correctValues.contains(c.value));
      final right = q.correctValues.first;
      var save = SaveData(createdAt: t0);
      var r = resolver.resolve(save: save, q: q, chosenValue: wrong.value, quality: AnswerQuality.autonoma, mode: BattleMode.certamen, now: t0, battleSeed: 1);
      save = save.copyWith(errata: r.errataAfter, lastTransactionId: 1);
      r = resolver.resolve(save: save, q: q, chosenValue: right, quality: AnswerQuality.adiuta, mode: BattleMode.certamen, now: t0, battleSeed: 2);
      expect(r.errataAfter.items[q.errata!.formKey]!.fixes, 0, reason: 'aided answers do not fix');
      save = save.copyWith(errata: r.errataAfter);
      r = resolver.resolve(save: save, q: q, chosenValue: right, quality: AnswerQuality.autonoma, mode: BattleMode.certamen, now: t0, battleSeed: 2);
      expect(r.errataAfter.items[q.errata!.formKey]!.fixes, 1);
      save = save.copyWith(errata: r.errataAfter);
      r = resolver.resolve(save: save, q: q, chosenValue: right, quality: AnswerQuality.autonoma, mode: BattleMode.certamen, now: t0, battleSeed: 3);
      expect(r.errataAfter.isEmpty, isTrue);
      expect(r.errataAfter.retired, 1);
    });

    test('Theatrum questions carry no errata note', () {
      expect(Trials.ofActivity(Activity.theatrum), isNotEmpty);
      // Reading questions describe a passage, not one form: nothing to remember by form.
      final q = Question(id: 'x', trialId: 't', dimension: Dimension.sensus, prompt: '', surface: '', lemmaId: '', choices: const [Choice('a', 'a'), Choice('b', 'b')], correctValues: const {'a'}, skillIds: const ['l.numerus'], payload: const _NoPayload());
      final r = resolver.resolve(save: SaveData(createdAt: t0), q: q, chosenValue: 'b', quality: AnswerQuality.autonoma, mode: BattleMode.certamen, now: t0);
      expect(r.errataAfter.isEmpty, isTrue);
    });
  });

  group('recall in generation', () {
    test('a missed noun form is drawn far more often in a later fight', () {
      final gen = NounQuestionGenerator(testNounAnalyzer);
      final t = Trials.byId('d1-omnes');
      const recall = Recall(forms: {'d|rosa|abl.pl'}, cells: {'d|1|abl.pl'});
      int count(Recall r, int seed) {
        final rng = Random(seed);
        var n = 0;
        for (var i = 0; i < 300; i++) {
          final q = gen.generate(trial: t, componentIds: const [], rng: rng, id: '$i', recall: r);
          if (q != null && q.lemmaId == 'rosa' && q.noun.target.analysis.selector == 'abl.pl') n++;
        }
        return n;
      }

      final plain = count(Recall.none, 1);
      final boosted = count(recall, 1);
      expect(boosted, greaterThan(plain * 2), reason: 'plain $plain, boosted $boosted');
    });

    test('a missed verb cell brings back the same cell of other verbs', () {
      final gen = QuestionGenerator(testAnalyzer);
      final t = Trials.byId('ind-praes-act');
      const recall = Recall(forms: {'v|amo|ind.praes.act.2.pl'}, cells: {'v|ind.praes.act.2.pl'});
      int count(Recall r, int seed) {
        final rng = Random(seed);
        var n = 0;
        for (var i = 0; i < 300; i++) {
          final q = gen.generate(trial: t, componentIds: const [], rng: rng, id: '$i', recall: r)!;
          final a = q.verb.target.analysis;
          if (a.person == Person.secunda && a.number == Numerus.pluralis) n++;
        }
        return n;
      }

      final plain = count(Recall.none, 2);
      final boosted = count(recall, 2);
      expect(boosted, greaterThan((plain * 1.5).round()), reason: 'plain $plain, boosted $boosted');
      // Every verb question carries its keys.
      final q = gen.generate(trial: t, componentIds: const [], rng: Random(4), id: 'k')!;
      expect(q.errata!.formKey, 'v|${q.lemmaId}|${q.verb.target.analysis.selector}');
      expect(q.errata!.cellKey, 'v|${q.verb.target.analysis.selector}');
    });
  });
}

class _NoPayload extends QuestionPayload {
  const _NoPayload();
}
