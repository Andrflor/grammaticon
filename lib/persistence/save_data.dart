/// Versioned save schema with manual JSON serialisation and migrations.
library;

import 'dart:convert';

import '../pedagogy/exposure.dart';
import '../pedagogy/mastery.dart';

const int kSchemaVersion = 3;

/// Language of the translations shown in the Theatrum. The interface itself
/// stays Latin. A language is *selectable* only when its content is shipped.
enum TranslationLanguage {
  gallice('fr', 'Gallicē'),
  anglice('en', 'Anglicē');

  const TranslationLanguage(this.code, this.latin);
  final String code;
  final String latin;
  static TranslationLanguage fromCode(String c) => values.firstWhere((e) => e.code == c, orElse: () => gallice);
}

class Settings {
  const Settings({
    this.volume = 0.8,
    this.soundOn = true,
    this.reducedMotion = false,
    this.correctDelayMs = 350,
    this.wrongDelayMs = 2800,
    this.musicOn = true,
    this.musicVolume = 0.5,
    this.translationLanguage = TranslationLanguage.gallice,
  });

  final double volume;
  final bool soundOn;
  final bool musicOn;
  final double musicVolume;
  final bool reducedMotion;
  final TranslationLanguage translationLanguage;

  /// Delay before the next question after a correct answer.
  final int correctDelayMs;

  /// Reading delay after an error before the next question.
  final int wrongDelayMs;

  Settings copyWith({double? volume, bool? soundOn, bool? reducedMotion, int? correctDelayMs, int? wrongDelayMs, bool? musicOn, double? musicVolume, TranslationLanguage? translationLanguage}) => Settings(
    volume: volume ?? this.volume,
    soundOn: soundOn ?? this.soundOn,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    correctDelayMs: correctDelayMs ?? this.correctDelayMs,
    wrongDelayMs: wrongDelayMs ?? this.wrongDelayMs,
    musicOn: musicOn ?? this.musicOn,
    musicVolume: musicVolume ?? this.musicVolume,
    translationLanguage: translationLanguage ?? this.translationLanguage,
  );

  Map<String, Object?> toJson() => {'vol': volume, 'snd': soundOn, 'rm': reducedMotion, 'cd': correctDelayMs, 'wd': wrongDelayMs, 'mus': musicOn, 'mvol': musicVolume, 'lang': translationLanguage.code};
  factory Settings.fromJson(Map<String, Object?> j) => Settings(
    volume: (j['vol'] as num?)?.toDouble() ?? 0.8,
    soundOn: j['snd'] as bool? ?? true,
    reducedMotion: j['rm'] as bool? ?? false,
    correctDelayMs: (j['cd'] as num?)?.toInt() ?? 350,
    wrongDelayMs: (j['wd'] as num?)?.toInt() ?? 2800,
    musicOn: j['mus'] as bool? ?? true,
    musicVolume: (j['mvol'] as num?)?.toDouble() ?? 0.5,
    translationLanguage: TranslationLanguage.fromCode(j['lang'] as String? ?? 'fr'),
  );
}

enum BattleMode {
  certamen('certamen', 'Certāmen'),
  exercitatio('exercitatio', 'Exercitātiō');

  const BattleMode(this.key, this.latin);
  final String key;
  final String latin;
  static BattleMode fromKey(String k) => values.firstWhere((e) => e.key == k);
}

/// Encounters won and lost in one activity (the Amphitheatrum's fights, the
/// Forum's debates). The gem balance itself is shared.
class ActivityStats {
  const ActivityStats({this.won = 0, this.lost = 0});
  final int won;
  final int lost;

  Map<String, Object?> toJson() => {'w': won, 'l': lost};
  factory ActivityStats.fromJson(Map<String, Object?> j) => ActivityStats(won: (j['w'] as num?)?.toInt() ?? 0, lost: (j['l'] as num?)?.toInt() ?? 0);
}

/// Snapshot of a fight in progress, so that closing the app mid-fight resumes
/// coherently. Gems and mastery are already applied at answer time; the
/// snapshot only restores the arena.
class ActiveBattle {
  const ActiveBattle({
    required this.trialId,
    required this.mode,
    required this.hearts,
    required this.enemyHp,
    required this.answered,
    required this.gemsDelta,
    required this.seed,
    required this.questionIndex,
    required this.componentIds,
    required this.correctCount,
  });

  final String trialId;
  final BattleMode mode;
  final int hearts;
  final int enemyHp;
  final int answered;
  final int gemsDelta;
  final int seed;
  final int questionIndex;
  final List<String> componentIds;
  final int correctCount;

  Map<String, Object?> toJson() => {'t': trialId, 'm': mode.key, 'h': hearts, 'e': enemyHp, 'a': answered, 'g': gemsDelta, 's': seed, 'q': questionIndex, 'c': componentIds, 'ok': correctCount};
  factory ActiveBattle.fromJson(Map<String, Object?> j) => ActiveBattle(
    trialId: j['t'] as String,
    mode: BattleMode.fromKey(j['m'] as String),
    hearts: (j['h'] as num).toInt(),
    enemyHp: (j['e'] as num).toInt(),
    answered: (j['a'] as num).toInt(),
    gemsDelta: (j['g'] as num).toInt(),
    seed: (j['s'] as num).toInt(),
    questionIndex: (j['q'] as num).toInt(),
    componentIds: ((j['c'] as List?) ?? const []).cast<String>(),
    correctCount: (j['ok'] as num?)?.toInt() ?? 0,
  );
}

class SaveData {
  const SaveData({
    this.schemaVersion = kSchemaVersion,
    this.gems = 0,
    this.purchased = const {},
    this.skills = const {},
    this.settings = const Settings(),
    this.mixtaConfig = const {},
    this.battlesWon = 0,
    this.battlesLost = 0,
    this.lastTransactionId = 0,
    this.activeBattle,
    this.lemmaDaily = const {},
    this.introSeen = const {},
    this.activityStats = const {},
    this.exposure = const ExposureLedger(),
    this.createdAt,
    this.updatedAt,
  });

  final int schemaVersion;
  final int gems;

  /// Trial ids permanently unlocked.
  final Set<String> purchased;
  final Map<String, SkillRecord> skills;
  final Settings settings;

  /// Selected component ids per Mixta trial.
  final Map<String, List<String>> mixtaConfig;
  final int battlesWon;
  final int battlesLost;

  /// Monotonic id of the last applied transaction (idempotency).
  final int lastTransactionId;
  final ActiveBattle? activeBattle;

  /// Correct autonomous answers per `skill|lemma|yyyymmdd` (lemma saturation).
  final Map<String, int> lemmaDaily;

  /// Trial ids whose introduction has been read.
  final Set<String> introSeen;

  /// Per-activity tallies keyed by [Activity.key]; [battlesWon] and
  /// [battlesLost] remain the global totals.
  final Map<String, ActivityStats> activityStats;

  /// Vocabulary met in the Theatrum (exposure, not mastery).
  final ExposureLedger exposure;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SaveData copyWith({
    int? gems,
    Set<String>? purchased,
    Map<String, SkillRecord>? skills,
    Settings? settings,
    Map<String, List<String>>? mixtaConfig,
    int? battlesWon,
    int? battlesLost,
    int? lastTransactionId,
    ActiveBattle? activeBattle,
    bool clearActiveBattle = false,
    Map<String, int>? lemmaDaily,
    Set<String>? introSeen,
    Map<String, ActivityStats>? activityStats,
    ExposureLedger? exposure,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SaveData(
    schemaVersion: schemaVersion,
    gems: gems ?? this.gems,
    purchased: purchased ?? this.purchased,
    skills: skills ?? this.skills,
    settings: settings ?? this.settings,
    mixtaConfig: mixtaConfig ?? this.mixtaConfig,
    battlesWon: battlesWon ?? this.battlesWon,
    battlesLost: battlesLost ?? this.battlesLost,
    lastTransactionId: lastTransactionId ?? this.lastTransactionId,
    activeBattle: clearActiveBattle ? null : (activeBattle ?? this.activeBattle),
    lemmaDaily: lemmaDaily ?? this.lemmaDaily,
    introSeen: introSeen ?? this.introSeen,
    activityStats: activityStats ?? this.activityStats,
    exposure: exposure ?? this.exposure,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, Object?> toJson() => {
    'schema': schemaVersion,
    'gems': gems,
    'purchased': purchased.toList()..sort(),
    'skills': {for (final e in skills.entries) e.key: e.value.toJson()},
    'settings': settings.toJson(),
    'mixta': mixtaConfig,
    'won': battlesWon,
    'lost': battlesLost,
    'tx': lastTransactionId,
    if (activeBattle != null) 'battle': activeBattle!.toJson(),
    'lemmaDaily': lemmaDaily,
    'introSeen': introSeen.toList()..sort(),
    'activities': {for (final e in activityStats.entries) e.key: e.value.toJson()},
    'expo': exposure.toJson(),
    if (createdAt != null) 'created': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated': updatedAt!.toIso8601String(),
  };

  factory SaveData.fromJson(Map<String, Object?> j) => SaveData(
    schemaVersion: (j['schema'] as num?)?.toInt() ?? kSchemaVersion,
    gems: (j['gems'] as num?)?.toInt() ?? 0,
    purchased: ((j['purchased'] as List?) ?? const []).cast<String>().toSet(),
    skills: {for (final e in ((j['skills'] as Map?) ?? const {}).entries) e.key as String: SkillRecord.fromJson((e.value as Map).cast<String, Object?>())},
    settings: j['settings'] == null ? const Settings() : Settings.fromJson((j['settings'] as Map).cast<String, Object?>()),
    mixtaConfig: {for (final e in ((j['mixta'] as Map?) ?? const {}).entries) e.key as String: (e.value as List).cast<String>()},
    battlesWon: (j['won'] as num?)?.toInt() ?? 0,
    battlesLost: (j['lost'] as num?)?.toInt() ?? 0,
    lastTransactionId: (j['tx'] as num?)?.toInt() ?? 0,
    activeBattle: j['battle'] == null ? null : ActiveBattle.fromJson((j['battle'] as Map).cast<String, Object?>()),
    lemmaDaily: {for (final e in ((j['lemmaDaily'] as Map?) ?? const {}).entries) e.key as String: (e.value as num).toInt()},
    introSeen: ((j['introSeen'] as List?) ?? const []).cast<String>().toSet(),
    activityStats: {for (final e in ((j['activities'] as Map?) ?? const {}).entries) e.key as String: ActivityStats.fromJson((e.value as Map).cast<String, Object?>())},
    exposure: j['expo'] == null ? const ExposureLedger() : ExposureLedger.fromJson((j['expo'] as Map).cast<String, Object?>()),
    createdAt: j['created'] == null ? null : DateTime.tryParse(j['created'] as String),
    updatedAt: j['updated'] == null ? null : DateTime.tryParse(j['updated'] as String),
  );
}

/// Encodes/decodes saves, applying migrations from older schema versions.
class SaveCodec {
  const SaveCodec();

  /// Migrations keyed by the version they upgrade *from*.
  static final Map<int, Map<String, Object?> Function(Map<String, Object?>)> migrations = {
    // 0 -> 1: pre-release saves without a schema field.
    0: (j) => {...j, 'schema': 1},
    // 1 -> 2: the Forum arrives. Every earlier encounter was fought in the
    // Amphitheatrum, so the global tallies seed its per-activity record; gems,
    // purchases, skills and the snapshot are untouched.
    1: (j) => {
      ...j,
      'schema': 2,
      'activities': {
        'amphitheatrum': {'w': (j['won'] as num?)?.toInt() ?? 0, 'l': (j['lost'] as num?)?.toInt() ?? 0},
      },
    },
    // 2 -> 3: the Thermae become the Theatrum. No trial, skill or tally ever
    // carried the Thermae identifier, so nothing is reset; any stray
    // per-activity record under the old key is renamed rather than dropped.
    // The exposure ledger and the translation-language setting start with
    // their defaults (French).
    2: (j) {
      final acts = Map<String, Object?>.from((j['activities'] as Map?)?.cast<String, Object?>() ?? const {});
      if (acts.containsKey('thermae') && !acts.containsKey('theatrum')) acts['theatrum'] = acts.remove('thermae');
      acts.remove('thermae');
      return {...j, 'schema': 3, 'activities': acts};
    },
  };

  String encode(SaveData d) => jsonEncode(d.toJson());

  SaveData decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) throw const FormatException('Cōnservātiō corrupta');
    var j = decoded.cast<String, Object?>();
    var v = (j['schema'] as num?)?.toInt() ?? 0;
    while (v < kSchemaVersion) {
      final m = migrations[v];
      if (m == null) throw FormatException('Nūlla migrātiō ā versiōne $v');
      j = m(j);
      v = (j['schema'] as num?)?.toInt() ?? (v + 1);
    }
    if (v > kSchemaVersion) throw FormatException('Versiō $v recentior quam $kSchemaVersion');
    return SaveData.fromJson(j);
  }
}
