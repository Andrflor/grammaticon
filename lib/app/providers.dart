import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_service.dart';
import '../linguistics/engine/analyzer.dart';
import '../linguistics/engine/nominal_analyzer.dart';
import '../linguistics/engine/noun_analyzer.dart';
import '../linguistics/lexicon/forum_lexicon.dart';
import '../pedagogy/mastery.dart';
import '../pedagogy/forum/forum_question_source.dart';
import '../pedagogy/forum/syntagmata/syntagmata.dart';
import '../pedagogy/progression.dart';
import '../pedagogy/question_generator.dart';
import '../pedagogy/reading/reading_content.dart';
import '../pedagogy/reading/reading_question_source.dart';
import '../pedagogy/trials.dart';
import '../persistence/save_data.dart';
import '../persistence/save_repository.dart';
import '../battle/answer_resolver.dart';

/// Whole-lexicon analyzer, built before the app starts (overridden in main).
final analyzerProvider = Provider<Analyzer>((ref) => throw UnimplementedError('analyzerProvider must be overridden'));

final questionGeneratorProvider = Provider<QuestionGenerator>((ref) => QuestionGenerator(ref.watch(analyzerProvider)));

/// Whole-noun-lexicon analyzer (overridden in main and tests).
final nounAnalyzerProvider = Provider<NounAnalyzer>((ref) => throw UnimplementedError('nounAnalyzerProvider must be overridden'));

/// Whole nominal lexicon (nouns, adjectives, pronouns, numerals, adverbs),
/// built on the noun analyzer.
final nominalAnalyzerProvider = Provider<NominalAnalyzer>((ref) => buildNominalAnalyzer(nouns: ref.watch(nounAnalyzerProvider)));

final forumQuestionSourceProvider = Provider<ForumQuestionSource>((ref) => ForumQuestionSource(ref.watch(nominalAnalyzerProvider), kSyntagmata));

/// Curated reading content of the Theatrum (overridden in main and tests).
final readingLibraryProvider = Provider<ReadingLibrary>((ref) => throw UnimplementedError('readingLibraryProvider must be overridden'));

/// Reading source for the selected translation language. Rebuilt when the
/// language changes; unavailable languages yield no questions.
final readingQuestionSourceProvider = Provider<ReadingQuestionSource>(
  (ref) => ReadingQuestionSource(ref.watch(readingLibraryProvider), language: ref.watch(settingsProvider.select((s) => s.translationLanguage.code))),
);

/// One question source per activity, dispatched by the trial's activity.
final questionSourcesProvider = Provider<QuestionSources>(
  (ref) => QuestionSources((a) => switch (a) {
        Activity.amphitheatrum => ref.read(questionGeneratorProvider),
        Activity.forum => ref.read(forumQuestionSourceProvider),
        Activity.theatrum => ref.read(readingQuestionSourceProvider),
      }),
);

final saveRepositoryProvider = Provider<SaveRepository>((ref) => throw UnimplementedError('saveRepositoryProvider must be overridden'));

/// Save loaded at startup (overridden in main).
final initialSaveProvider = Provider<SaveData>((ref) => throw UnimplementedError('initialSaveProvider must be overridden'));

final audioProvider = Provider<AudioService>((ref) => throw UnimplementedError('audioProvider must be overridden'));

final masteryConfigProvider = Provider<MasteryConfig>((ref) => const MasteryConfig());
final answerResolverProvider = Provider<AnswerResolver>((ref) => AnswerResolver(mastery: ref.watch(masteryConfigProvider)));

final profileProvider = NotifierProvider<ProfileController, SaveData>(ProfileController.new);
final settingsProvider = Provider<Settings>((ref) => ref.watch(profileProvider).settings);

/// Single owner of the persisted game state. Every mutation saves at once.
class ProfileController extends Notifier<SaveData> {
  @override
  SaveData build() => ref.read(initialSaveProvider);

  SaveRepository get _repo => ref.read(saveRepositoryProvider);

  Future<void> _commit(SaveData next) {
    state = next;
    final audio = ref.read(audioProvider);
    audio.volume = next.settings.volume;
    audio.soundOn = next.settings.soundOn;
    audio.setMusic(on: next.settings.musicOn, volume: next.settings.musicVolume);
    return _repo.save(next);
  }

  /// Applies a resolved answer: one transaction, mastery updates and the
  /// arena snapshot, persisted together so that closing the app during the
  /// animation can neither lose nor duplicate the transaction.
  Future<void> applyResolution(Resolution r, ActiveBattle? snapshot) {
    if (r.transaction.id <= state.lastTransactionId) return Future.value(); // already applied
    return _commit(
      state.copyWith(gems: r.gemsAfter, skills: r.skillsAfter, lemmaDaily: r.lemmaDailyAfter, lastTransactionId: r.transaction.id, activeBattle: snapshot, clearActiveBattle: snapshot == null, exposure: r.exposureAfter, errata: r.errataAfter),
    );
  }

  /// Buys permanent access. Returns false when not purchasable.
  Future<bool> purchase(Trial t) async {
    if (!Progression.canPurchase(state, t)) return false;
    if (state.purchased.contains(t.id)) return false;
    await _commit(state.copyWith(gems: state.gems - t.price, purchased: {...state.purchased, t.id}));
    return true;
  }

  Future<void> updateSettings(Settings s) => _commit(state.copyWith(settings: s));

  Future<void> markIntroSeen(String trialId) => _commit(state.copyWith(introSeen: {...state.introSeen, trialId}));

  Future<void> setActiveBattle(ActiveBattle? b) => _commit(state.copyWith(activeBattle: b, clearActiveBattle: b == null));

  /// Records the end of an encounter: global and per-activity tallies, bonus
  /// or penalty applied once, snapshot cleared.
  Future<void> recordBattleEnd({required Activity activity, required bool won, required int bonus, int penalty = 0}) {
    final stats = Map<String, ActivityStats>.from(state.activityStats);
    final cur = stats[activity.key] ?? const ActivityStats();
    stats[activity.key] = ActivityStats(won: cur.won + (won ? 1 : 0), lost: cur.lost + (won ? 0 : 1));
    return _commit(
      state.copyWith(
        gems: (state.gems + bonus - penalty).clamp(0, 1 << 30),
        battlesWon: state.battlesWon + (won ? 1 : 0),
        battlesLost: state.battlesLost + (won ? 0 : 1),
        activityStats: stats,
        clearActiveBattle: true,
      ),
    );
  }

  String exportJson() => _repo.export(state);

  /// Replaces the profile with an imported save. Throws FormatException.
  Future<void> importJson(String raw) => _commit(_repo.import(raw));

  Future<void> resetAll() async {
    await _repo.reset();
    await _commit(SaveData(createdAt: DateTime.now()));
  }
}
