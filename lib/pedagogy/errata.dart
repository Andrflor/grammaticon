/// Error ledger (errāta): what the player actually missed, kept apart from
/// mastery.
///
/// Mastery ([SkillRecord]) estimates a skill; this ledger remembers the
/// *forms* that were missed, the paradigm cell they belong to and what they
/// were confused with. It serves two purposes: the recall of missed material
/// in *later* fights (never in the fight where the error was made) and the
/// error analysis shown in the Tabula. An erratum is retired after
/// [ErrorLedger.retireAfter] autonomous correct answers on the same form.
library;

/// Key of one form: `v|amo|ind.imperf.act.2.pl`, `d|rosa|abl.pl`.
String verbFormKey(String lemmaId, String selector) => 'v|$lemmaId|$selector';
String nounFormKey(String lemmaId, String selector) => 'd|$lemmaId|$selector';

/// Key of one paradigm cell across lemmas: `v|ind.imperf.act.2.pl`, `d|1|abl.pl`.
String verbCellKey(String selector) => 'v|$selector';
String nounCellKey(int declensionOrdinal, String selector) => 'd|$declensionOrdinal|$selector';

/// What a question exposes to the ledger: the keys of its form and cell and
/// the Latin description of the analysis.
class ErrataNote {
  const ErrataNote({required this.formKey, required this.cellKey, required this.analysis});
  final String formKey;
  final String cellKey;

  /// Latin analysis, e.g. `secunda plūrālis · indicātīvus imperfectum · āctīvum`.
  final String analysis;
}

class Erratum {
  const Erratum({
    required this.formKey,
    required this.cellKey,
    required this.lemmaId,
    required this.surface,
    required this.analysis,
    required this.trialId,
    required this.lastMiss,
    required this.lastBattle,
    this.misses = 1,
    this.fixes = 0,
    this.confusions = const {},
  });

  final String formKey;
  final String cellKey;
  final String lemmaId;
  final String surface;
  final String analysis;

  /// Trial of the last miss.
  final String trialId;
  final DateTime lastMiss;

  /// Seed of the fight of the last miss: recall waits for a later fight.
  final int lastBattle;
  final int misses;

  /// Autonomous correct answers on this form since the last miss.
  final int fixes;

  /// Wrong labels chosen, with counts (`Secunda singulāris: 2`).
  final Map<String, int> confusions;

  /// Most frequent confusion, or null.
  String? get topConfusion {
    String? best;
    var n = 0;
    for (final e in confusions.entries) {
      if (e.value > n) {
        best = e.key;
        n = e.value;
      }
    }
    return best;
  }

  Erratum copyWith({String? surface, String? trialId, DateTime? lastMiss, int? lastBattle, int? misses, int? fixes, Map<String, int>? confusions}) => Erratum(
        formKey: formKey,
        cellKey: cellKey,
        lemmaId: lemmaId,
        surface: surface ?? this.surface,
        analysis: analysis,
        trialId: trialId ?? this.trialId,
        lastMiss: lastMiss ?? this.lastMiss,
        lastBattle: lastBattle ?? this.lastBattle,
        misses: misses ?? this.misses,
        fixes: fixes ?? this.fixes,
        confusions: confusions ?? this.confusions,
      );

  Map<String, Object?> toJson() => {
        'f': formKey,
        'c': cellKey,
        'l': lemmaId,
        's': surface,
        'a': analysis,
        'tr': trialId,
        't': lastMiss.millisecondsSinceEpoch,
        'b': lastBattle,
        'n': misses,
        'ok': fixes,
        'x': confusions,
      };

  factory Erratum.fromJson(Map<String, Object?> j) => Erratum(
        formKey: j['f'] as String,
        cellKey: j['c'] as String,
        lemmaId: j['l'] as String,
        surface: j['s'] as String,
        analysis: j['a'] as String? ?? '',
        trialId: j['tr'] as String? ?? '',
        lastMiss: DateTime.fromMillisecondsSinceEpoch((j['t'] as num).toInt()),
        lastBattle: (j['b'] as num?)?.toInt() ?? 0,
        misses: (j['n'] as num?)?.toInt() ?? 1,
        fixes: (j['ok'] as num?)?.toInt() ?? 0,
        confusions: {for (final e in ((j['x'] as Map?) ?? const {}).entries) e.key as String: (e.value as num).toInt()},
      );
}

/// Forms and cells to recall in a fight, with their selection boosts.
class Recall {
  const Recall({this.forms = const {}, this.cells = const {}});
  static const Recall none = Recall();

  final Set<String> forms;
  final Set<String> cells;

  /// A missed form is drawn four times as often, another form of a missed
  /// cell two and a half times.
  static const double formBoost = 4.0;
  static const double cellBoost = 2.5;

  bool get isEmpty => forms.isEmpty && cells.isEmpty;

  double boost(String formKey, String cellKey) {
    if (forms.contains(formKey)) return formBoost;
    if (cells.contains(cellKey)) return cellBoost;
    return 1.0;
  }
}

/// One line of the error analysis: a cell, its missed forms and the usual
/// confusion.
class ErrataGroup {
  const ErrataGroup({required this.cellKey, required this.analysis, required this.items});
  final String cellKey;
  final String analysis;
  final List<Erratum> items;

  int get misses => items.fold(0, (a, e) => a + e.misses);
  List<String> get surfaces => items.map((e) => e.surface).toList();

  String? get topConfusion {
    final counts = <String, int>{};
    for (final e in items) {
      for (final c in e.confusions.entries) {
        counts[c.key] = (counts[c.key] ?? 0) + c.value;
      }
    }
    String? best;
    var n = 0;
    for (final e in counts.entries) {
      if (e.value > n) {
        best = e.key;
        n = e.value;
      }
    }
    return best;
  }

  /// Activity prefix of the cell (`v` verbs, `d` nouns).
  String get activity => cellKey.split('|').first;
}

class ErrorLedger {
  const ErrorLedger({this.items = const {}, this.retired = 0});

  /// Open errata by form key.
  final Map<String, Erratum> items;

  /// Errata retired so far (forms answered correctly enough after a miss).
  final int retired;

  /// Autonomous correct answers on a missed form before it is retired.
  static const int retireAfter = 2;

  /// Oldest errata are dropped beyond this size.
  static const int maxItems = 150;

  bool get isEmpty => items.isEmpty;
  int get openCount => items.length;
  List<Erratum> get open => items.values.toList()..sort((a, b) => b.lastMiss.compareTo(a.lastMiss));

  /// Records a wrong answer on [note].
  ErrorLedger miss(ErrataNote note, {required String lemmaId, required String surface, required String chosenLabel, required String trialId, required DateTime now, required int battleSeed}) {
    final m = Map<String, Erratum>.from(items);
    final prev = m[note.formKey];
    if (prev == null) {
      m[note.formKey] = Erratum(
        formKey: note.formKey,
        cellKey: note.cellKey,
        lemmaId: lemmaId,
        surface: surface,
        analysis: note.analysis,
        trialId: trialId,
        lastMiss: now,
        lastBattle: battleSeed,
        confusions: {chosenLabel: 1},
      );
    } else {
      final conf = Map<String, int>.from(prev.confusions);
      conf[chosenLabel] = (conf[chosenLabel] ?? 0) + 1;
      m[note.formKey] = prev.copyWith(surface: surface, trialId: trialId, lastMiss: now, lastBattle: battleSeed, misses: prev.misses + 1, fixes: 0, confusions: conf);
    }
    if (m.length > maxItems) {
      final oldest = m.values.toList()..sort((a, b) => a.lastMiss.compareTo(b.lastMiss));
      for (final e in oldest.take(m.length - maxItems)) {
        m.remove(e.formKey);
      }
    }
    return ErrorLedger(items: m, retired: retired);
  }

  /// Records an autonomous correct answer on [formKey]; retires the erratum
  /// after [retireAfter] of them.
  ErrorLedger fix(String formKey) {
    final prev = items[formKey];
    if (prev == null) return this;
    final m = Map<String, Erratum>.from(items);
    if (prev.fixes + 1 >= retireAfter) {
      m.remove(formKey);
      return ErrorLedger(items: m, retired: retired + 1);
    }
    m[formKey] = prev.copyWith(fixes: prev.fixes + 1);
    return ErrorLedger(items: m, retired: retired);
  }

  /// What to recall in the fight [battleSeed]: every erratum from an earlier
  /// fight. Errors of the current fight are left alone.
  Recall recall(int battleSeed) {
    final forms = <String>{};
    final cells = <String>{};
    for (final e in items.values) {
      if (e.lastBattle == battleSeed) continue;
      forms.add(e.formKey);
      cells.add(e.cellKey);
    }
    return Recall(forms: forms, cells: cells);
  }

  /// Open errata made in [trialId].
  List<Erratum> forTrial(String trialId) => open.where((e) => e.trialId == trialId).toList();

  /// Error analysis: open errata grouped by cell, most missed first.
  List<ErrataGroup> groups() {
    final by = <String, List<Erratum>>{};
    for (final e in items.values) {
      (by[e.cellKey] ??= []).add(e);
    }
    final out = [
      for (final e in by.entries) ErrataGroup(cellKey: e.key, analysis: e.value.first.analysis, items: e.value..sort((a, b) => b.misses.compareTo(a.misses))),
    ];
    out.sort((a, b) {
      final c = b.misses.compareTo(a.misses);
      return c != 0 ? c : a.analysis.compareTo(b.analysis);
    });
    return out;
  }

  Map<String, Object?> toJson() => {'i': items.values.map((e) => e.toJson()).toList(), 'r': retired};

  factory ErrorLedger.fromJson(Map<String, Object?> j) {
    final list = ((j['i'] as List?) ?? const []).map((e) => Erratum.fromJson((e as Map).cast<String, Object?>()));
    return ErrorLedger(items: {for (final e in list) e.formKey: e}, retired: (j['r'] as num?)?.toInt() ?? 0);
  }
}
