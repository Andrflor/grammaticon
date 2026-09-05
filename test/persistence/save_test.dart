import 'package:flutter_test/flutter_test.dart';
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
    expect(back.schemaVersion, kSchemaVersion);
  });

  test('legacy save without schema is migrated', () {
    const codec = SaveCodec();
    final d = codec.decode('{"gems": 5, "purchased": ["ind-imperf-act"]}');
    expect(d.gems, 5);
    expect(d.schemaVersion, kSchemaVersion);
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
