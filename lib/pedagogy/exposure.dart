/// Vocabulary exposure ledger of the Theatrum.
///
/// Records what the player has *met*, never what they have *mastered*: how
/// many times a lemma appeared in a played passage, in how many distinct
/// passages, and how often it was the word a question actually turned on.
/// Mastery of grammar lives in [SkillRecord]; the two are never merged.
library;

class LemmaExposure {
  const LemmaExposure({this.seen = 0, this.passages = const [], this.tested = 0, this.testedCorrect = 0});

  /// Occurrences in played passages (every answer counts once per passage).
  final int seen;

  /// Distinct passage ids the lemma was met in (bounded).
  final List<String> passages;

  /// Times the lemma was the target of the asked distinction.
  final int tested;

  /// …of which answered correctly without help.
  final int testedCorrect;

  /// Met in more than one context.
  bool get revisited => passages.length >= 2;

  static const int maxPassages = 12;

  LemmaExposure met(String passageId, {required bool asTarget, required bool autonomousCorrect}) {
    final p = passages.contains(passageId) ? passages : [...passages, passageId];
    return LemmaExposure(
      seen: seen + 1,
      passages: p.length > maxPassages ? p.sublist(p.length - maxPassages) : p,
      tested: tested + (asTarget ? 1 : 0),
      testedCorrect: testedCorrect + (asTarget && autonomousCorrect ? 1 : 0),
    );
  }

  Map<String, Object?> toJson() => {'n': seen, 'p': passages, 't': tested, 'tc': testedCorrect};
  factory LemmaExposure.fromJson(Map<String, Object?> j) => LemmaExposure(
        seen: (j['n'] as num?)?.toInt() ?? 0,
        passages: ((j['p'] as List?) ?? const []).cast<String>(),
        tested: (j['t'] as num?)?.toInt() ?? 0,
        testedCorrect: (j['tc'] as num?)?.toInt() ?? 0,
      );
}

/// What a resolved question exposes: the item played, its passage and the
/// lemmas met, with the one the distinction turned on.
class ExposureNote {
  const ExposureNote({required this.itemId, required this.passageId, required this.lemmas, required this.targetLemma});
  final String itemId;
  final String passageId;
  final List<String> lemmas;
  final String targetLemma;
}

class ExposureLedger {
  const ExposureLedger({this.lemmas = const {}, this.items = const {}});

  final Map<String, LemmaExposure> lemmas;

  /// Times each content item was answered.
  final Map<String, int> items;

  int get encountered => lemmas.values.where((e) => e.seen > 0).length;
  int get revisited => lemmas.values.where((e) => e.revisited).length;
  int get tested => lemmas.values.where((e) => e.tested > 0).length;

  LemmaExposure of(String lemmaId) => lemmas[lemmaId] ?? const LemmaExposure();
  int seenCount(String itemId) => items[itemId] ?? 0;

  ExposureLedger record(ExposureNote note, {required bool autonomousCorrect}) {
    final l = Map<String, LemmaExposure>.from(lemmas);
    for (final id in note.lemmas.toSet()) {
      l[id] = (l[id] ?? const LemmaExposure()).met(note.passageId, asTarget: id == note.targetLemma, autonomousCorrect: autonomousCorrect);
    }
    final i = Map<String, int>.from(items);
    i[note.itemId] = (i[note.itemId] ?? 0) + 1;
    return ExposureLedger(lemmas: l, items: i);
  }

  Map<String, Object?> toJson() => {
        'l': {for (final e in lemmas.entries) e.key: e.value.toJson()},
        'i': items,
      };

  factory ExposureLedger.fromJson(Map<String, Object?> j) => ExposureLedger(
        lemmas: {for (final e in ((j['l'] as Map?) ?? const {}).entries) e.key as String: LemmaExposure.fromJson((e.value as Map).cast<String, Object?>())},
        items: {for (final e in ((j['i'] as Map?) ?? const {}).entries) e.key as String: (e.value as num).toInt()},
      );
}
