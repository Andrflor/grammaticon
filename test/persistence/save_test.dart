import 'package:flutter_test/flutter_test.dart';
import 'package:latin_game/pedagogy/errata.dart';
import 'package:latin_game/pedagogy/mastery.dart';
import 'package:latin_game/persistence/save_data.dart';
import 'package:latin_game/persistence/save_repository.dart';

void main() {
  test('save round trip keeps every field', () async {
    final store = MemorySaveStore();
    final repo = SaveRepository(store);
    var d = SaveData(createdAt: DateTime(2026, 1, 1));
    d = d.copyWith(
      gems: 42,
      purchased: {'ind-imperf-act'},
      skills: {
        'v.ind.praes.act': const SkillRecord().apply(Observation(at: DateTime(2026, 1, 2), correct: true, lemmaId: 'amo', quality: AnswerQuality.autonoma, trialId: 'ind-praes-act'), const MasteryConfig()),
      },
      settings: const Settings(volume: 0.3, soundOn: false, reducedMotion: true),
      mixtaConfig: {'mx-tempora-ind-act': ['ind.praes.act', 'ind.perf.act']},
      battlesWon: 3,
      battlesLost: 1,
      lastTransactionId: 17,
      activeBattle: const ActiveBattle(trialId: 'ind-praes-act', mode: BattleMode.certamen, hearts: 2, enemyHp: 5, answered: 6, gemsDelta: 20, seed: 99, questionIndex: 6, componentIds: [], correctCount: 5),
      lemmaDaily: {'v.ind.praes.act|amo|20260102': 2},
      introSeen: {'ind-praes-act'},
      errata: const ErrorLedger().miss(
        const ErrataNote(formKey: 'v|amo|ind.praes.act.2.pl', cellKey: 'v|ind.praes.act.2.pl', analysis: 'secunda plūrālis · indicātīvus praesēns · āctīvum'),
        lemmaId: 'amo',
        surface: 'amātis',
        chosenLabel: 'Secunda singulāris',
        trialId: 'ind-praes-act',
        now: DateTime(2026, 1, 3),
        battleSeed: 99,
      ),
    );
    await repo.save(d);
    final back = await repo.load();
    expect(back.gems, 42);
    expect(back.purchased, {'ind-imperf-act'});
    expect(back.skills['v.ind.praes.act']!.autonomousCorrect, 1);
    expect(back.settings.volume, 0.3);
    expect(back.settings.soundOn, isFalse);
    expect(back.settings.reducedMotion, isTrue);
    expect(back.mixtaConfig['mx-tempora-ind-act'], ['ind.praes.act', 'ind.perf.act']);
    expect(back.battlesWon, 3);
    expect(back.lastTransactionId, 17);
    expect(back.activeBattle!.hearts, 2);
    expect(back.activeBattle!.seed, 99);
    expect(back.lemmaDaily['v.ind.praes.act|amo|20260102'], 2);
    expect(back.introSeen, {'ind-praes-act'});
    expect(back.errata.items['v|amo|ind.praes.act.2.pl']!.confusions, {'Secunda singulāris': 1});
    expect(back.errata.items['v|amo|ind.praes.act.2.pl']!.lastBattle, 99);
    expect(back.schemaVersion, kSchemaVersion);
  });

  test('legacy save without schema is migrated', () {
    const codec = SaveCodec();
    final d = codec.decode('{"gems": 5, "purchased": ["ind-imperf-act"]}');
    expect(d.gems, 5);
    expect(d.schemaVersion, kSchemaVersion);
    expect(d.activityStats['amphitheatrum']?.won, 0);
  });

  test('schema 1 (Amphitheatrum only) migrates to 2: gems, purchases, skills, snapshot kept; tallies seeded', () {
    const codec = SaveCodec();
    const v1 = '{"schema":1,"gems":37,"purchased":["ind-imperf-act","ind-fut-act"],'
        '"skills":{"v.ind.praes.act":{"ac":3,"aw":1,"aidc":0,"aidw":0,"corc":0,"est":0.7,"hw":0.7,"recent":[],"lemmas":["amo","rego"],"days":["20260102"],"last":1767312000000}},'
        '"settings":{"vol":0.5,"snd":true,"rm":false,"cd":350,"wd":2800,"mus":true,"mvol":0.5},'
        '"mixta":{"mx-tempora-ind-act":["ind.praes.act","ind.perf.act"]},"won":4,"lost":2,"tx":21,'
        '"battle":{"t":"ind-imperf-act","m":"certamen","h":2,"e":6,"a":5,"g":12,"s":77,"q":5,"c":[],"ok":4},'
        '"lemmaDaily":{"v.ind.praes.act|amo|20260102":2},"introSeen":["ind-praes-act"]}';
    final d = codec.decode(v1);
    expect(d.schemaVersion, kSchemaVersion); // 1 → 2 → 3
    expect(d.gems, 37);
    expect(d.purchased, {'ind-imperf-act', 'ind-fut-act'});
    expect(d.skills['v.ind.praes.act']!.autonomousCorrect, 3);
    expect(d.skills['v.ind.praes.act']!.lemmas, {'amo', 'rego'});
    expect(d.mixtaConfig['mx-tempora-ind-act'], ['ind.praes.act', 'ind.perf.act']);
    expect(d.battlesWon, 4);
    expect(d.battlesLost, 2);
    expect(d.lastTransactionId, 21);
    expect(d.activeBattle!.trialId, 'ind-imperf-act');
    expect(d.activeBattle!.enemyHp, 6);
    expect(d.introSeen, {'ind-praes-act'});
    // Every earlier encounter was an Amphitheatrum fight; the Forum starts at zero.
    expect(d.activityStats['amphitheatrum']!.won, 4);
    expect(d.activityStats['amphitheatrum']!.lost, 2);
    expect(d.activityStats['forum'], isNull);
    expect(d.activityStats['theatrum']?.won ?? 0, 0);
    // Round trip keeps the per-activity field.
    final back = codec.decode(codec.encode(d.copyWith(activityStats: {...d.activityStats, 'forum': const ActivityStats(won: 1)})));
    expect(back.activityStats['forum']!.won, 1);
    expect(back.activityStats['amphitheatrum']!.won, 4);
  });

  test('Forum purchases, noun skills and a Forum snapshot survive a round trip', () async {
    final repo = SaveRepository(MemorySaveStore());
    final d = SaveData(
      gems: 9,
      purchased: const {'ind-imperf-act', 'd1-omnes'},
      skills: {'d.1.acc.sg': const SkillRecord().apply(Observation(at: DateTime(2026, 2, 1), correct: true, lemmaId: 'rosa', quality: AnswerQuality.autonoma, trialId: 'd1-recti'), const MasteryConfig())},
      activeBattle: const ActiveBattle(trialId: 'd1-recti', mode: BattleMode.certamen, hearts: 3, enemyHp: 8, answered: 2, gemsDelta: 16, seed: 5, questionIndex: 2, componentIds: [], correctCount: 2),
    );
    await repo.save(d);
    final back = await repo.load();
    expect(back.purchased, {'ind-imperf-act', 'd1-omnes'});
    expect(back.skills['d.1.acc.sg']!.lemmas, {'rosa'});
    expect(back.activeBattle!.trialId, 'd1-recti');
  });

  test('corrupt save falls back to a fresh profile', () async {
    final store = MemorySaveStore()..raw = '{not json';
    final repo = SaveRepository(store);
    final d = await repo.load();
    expect(d.gems, 0);
    expect(d.purchased, isEmpty);
  });

  test('newer schema is rejected on import', () {
    const codec = SaveCodec();
    expect(() => codec.decode('{"schema": 99}'), throwsFormatException);
  });

  test('writes are serialised in order', () async {
    final store = MemorySaveStore();
    final repo = SaveRepository(store);
    final f1 = repo.save(const SaveData(gems: 1));
    final f2 = repo.save(const SaveData(gems: 2));
    await Future.wait([f1, f2]);
    expect((await repo.load()).gems, 2);
    expect(store.writes, 2);
  });
}
