/// Curated reading content of the Theatrum: Latin passages of the Clementine
/// Vulgate and, per translation language, one faithful rendering and three
/// morphologically controlled distractors for each item.
///
/// The Latin side (`assets/theatrum/passages_la.json`) and each language side
/// (`assets/theatrum/renderings_<lang>.json`) are separate files with explicit
/// edition identifiers; they are joined by item id at load time. A language
/// without a file is *unavailable* — its content is never substituted by
/// another language's. Everything is parsed by hand (no code generation).
library;

import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle;

/// Edition metadata carried by every dataset (provenance is part of the data).
class TextEdition {
  const TextEdition({required this.id, required this.language, required this.title, required this.source, required this.license, this.url = '', this.note = '', this.requested = ''});
  final String id;
  final String language;
  final String title;
  final String source;
  final String license;
  final String url;

  /// Discrepancies between what was asked for and what is shipped.
  final String note;
  final String requested;

  factory TextEdition.fromJson(Map<String, Object?> j) => TextEdition(
        id: j['id'] as String,
        language: j['language'] as String,
        title: j['title'] as String,
        source: j['source'] as String? ?? '',
        license: j['license'] as String? ?? '',
        url: j['url'] as String? ?? '',
        note: j['note'] as String? ?? '',
        requested: j['requested'] as String? ?? '',
      );
}

class PassageWord {
  const PassageWord({required this.form, required this.lemma});

  /// Surface form as it stands in the passage (original orthography).
  final String form;

  /// Lemma id (dictionary head word, no macrons).
  final String lemma;
}

class ReadingPassage {
  const ReadingPassage({required this.id, required this.ref, required this.text, required this.verse, required this.words});
  final String id;

  /// Book code and chapter:verse of the Clementine text (`MAT 5:8`).
  final String ref;

  /// Exact passage (a whole verse or a contiguous span of it).
  final String text;

  /// The whole verse the passage is taken from.
  final String verse;
  final List<PassageWord> words;

  List<String> get lemmas => [for (final w in words) w.lemma];

  factory ReadingPassage.fromJson(Map<String, Object?> j) => ReadingPassage(
        id: j['id'] as String,
        ref: j['ref'] as String,
        text: j['text'] as String,
        verse: j['verse'] as String? ?? j['text'] as String,
        words: [for (final w in (j['words'] as List)) PassageWord(form: (w as Map)['f'] as String, lemma: w['l'] as String)],
      );
}

class ReadingTarget {
  const ReadingTarget({required this.span, required this.lemmaId, required this.formSkillId, required this.analysis});

  /// The Latin form or span the item turns on.
  final String span;
  final String lemmaId;

  /// Existing Amphitheatrum / Forum skill of the isolated form (alignment with
  /// the form-recognition progression; never credited by a reading answer).
  final String formSkillId;

  /// Latin description of the contextual analysis.
  final String analysis;

  factory ReadingTarget.fromJson(Map<String, Object?> j) => ReadingTarget(
        span: j['span'] as String,
        lemmaId: j['lemma'] as String,
        formSkillId: j['formSkill'] as String? ?? '',
        analysis: j['analysis'] as String,
      );
}

/// Language-neutral part of a question: which passage, which distinction.
class ReadingItem {
  const ReadingItem({
    required this.id,
    required this.passageId,
    required this.trialId,
    required this.skillId,
    required this.distinctions,
    required this.target,
    required this.hint,
    required this.note,
    required this.status,
    required this.version,
  });

  final String id;
  final String passageId;

  /// Base trial the item was written for (mixed trials reuse base pools).
  final String trialId;

  /// Reading skill credited (`l.numerus`…).
  final String skillId;

  /// Distinction keys the distractors rely on (subset of the trial's allowed keys).
  final Set<String> distinctions;
  final ReadingTarget target;

  /// Non-revealing Latin hint shown by the Auxilium before the answer.
  final String hint;

  /// Latin grammatical note shown after the answer.
  final String note;
  final String status;
  final String version;

  factory ReadingItem.fromJson(Map<String, Object?> j) => ReadingItem(
        id: j['id'] as String,
        passageId: j['passage'] as String,
        trialId: j['trial'] as String,
        skillId: j['skill'] as String,
        distinctions: ((j['distinctions'] as List?) ?? const []).cast<String>().toSet(),
        target: ReadingTarget.fromJson((j['target'] as Map).cast<String, Object?>()),
        hint: j['hint'] as String? ?? '',
        note: j['note'] as String? ?? '',
        status: j['status'] as String? ?? 'draft',
        version: j['version'] as String? ?? '',
      );
}

/// A French (or other) rendering offered as a choice.
class Rendering {
  const Rendering({required this.id, required this.text, required this.source, this.ref = ''});
  final String id;
  final String text;

  /// `LSG` when the wording is Louis Segond's; `paed` for a separately
  /// identified pedagogical rendering (never attributed to Segond).
  final String source;

  /// Verse the wording is taken from, in the translation's numbering.
  final String ref;

  factory Rendering.fromJson(Map<String, Object?> j) => Rendering(id: j['id'] as String, text: j['text'] as String, source: j['source'] as String? ?? 'paed', ref: j['ref'] as String? ?? '');
}

/// A plausible rendering carrying one controlled morphological misreading.
class Distractor {
  const Distractor({
    required this.id,
    required this.text,
    required this.span,
    required this.correctAnalysis,
    required this.wrongAnalysis,
    required this.shift,
    required this.skillId,
    required this.formSkillId,
    required this.distinction,
    required this.explanation,
  });
  final String id;
  final String text;

  /// Latin span misread.
  final String span;

  /// Correct contextual analysis (Latin).
  final String correctAnalysis;

  /// The misreading simulated (Latin).
  final String wrongAnalysis;

  /// Resulting change of meaning, in the translation language.
  final String shift;

  /// Reading skill the misreading tests.
  final String skillId;

  /// Existing form skill of the span (alignment data).
  final String formSkillId;
  final String distinction;

  /// Latin explanation used by the correction and the Auxilium.
  final String explanation;

  factory Distractor.fromJson(Map<String, Object?> j) => Distractor(
        id: j['id'] as String,
        text: j['text'] as String,
        span: j['span'] as String,
        correctAnalysis: j['ok'] as String,
        wrongAnalysis: j['wrong'] as String,
        shift: j['shift'] as String,
        skillId: j['skill'] as String,
        formSkillId: j['formSkill'] as String? ?? '',
        distinction: j['distinction'] as String,
        explanation: j['expl'] as String,
      );
}

/// Everything one language says about one item.
class ItemRenderings {
  const ItemRenderings({required this.itemId, required this.correct, required this.distractors, required this.verse, required this.verseRef, required this.glosses});
  final String itemId;

  /// Accepted renderings (one faithful rendering; equivalent paraphrases may be added).
  final List<Rendering> correct;
  final List<Distractor> distractors;

  /// Whole verse in the translation (Auxilium after the answer) — empty when
  /// the translation has no counterpart.
  final String verse;
  final String verseRef;

  /// Lemma → gloss in the translation language.
  final Map<String, String> glosses;

  factory ItemRenderings.fromJson(String itemId, Map<String, Object?> j) => ItemRenderings(
        itemId: itemId,
        correct: [for (final r in (j['correct'] as List)) Rendering.fromJson((r as Map).cast<String, Object?>())],
        distractors: [for (final d in (j['distractors'] as List)) Distractor.fromJson((d as Map).cast<String, Object?>())],
        verse: j['verse'] as String? ?? '',
        verseRef: j['verseRef'] as String? ?? '',
        glosses: {for (final e in ((j['glosses'] as Map?) ?? const {}).entries) e.key as String: e.value as String},
      );
}

class ReadingCorpus {
  const ReadingCorpus({required this.datasetId, required this.version, required this.edition, required this.passages, required this.items, required this.bookNames});
  final String datasetId;
  final String version;
  final TextEdition edition;
  final Map<String, ReadingPassage> passages;
  final Map<String, ReadingItem> items;

  /// Book code → Latin book name.
  final Map<String, String> bookNames;

  factory ReadingCorpus.parse(String json) {
    final j = (jsonDecode(json) as Map).cast<String, Object?>();
    final ds = (j['dataset'] as Map).cast<String, Object?>();
    return ReadingCorpus(
      datasetId: ds['id'] as String,
      version: ds['version'] as String,
      edition: TextEdition.fromJson((ds['edition'] as Map).cast<String, Object?>()),
      passages: {for (final p in (j['passages'] as List)) (p as Map)['id'] as String: ReadingPassage.fromJson(p.cast<String, Object?>())},
      items: {for (final i in (j['items'] as List)) (i as Map)['id'] as String: ReadingItem.fromJson(i.cast<String, Object?>())},
      bookNames: {for (final e in ((j['books'] as Map?) ?? const {}).entries) e.key as String: e.value as String},
    );
  }

  /// `Matthaeus 5, 8` for `MAT 5:8`.
  String latinRef(String ref) {
    final parts = ref.split(' ');
    final name = bookNames[parts[0]] ?? parts[0];
    return '$name ${parts.length > 1 ? parts[1].replaceAll(':', ', ') : ''}'.trim();
  }
}

class ReadingRenderings {
  const ReadingRenderings({required this.datasetId, required this.version, required this.language, required this.edition, required this.items});
  final String datasetId;
  final String version;
  final String language;
  final TextEdition edition;
  final Map<String, ItemRenderings> items;

  factory ReadingRenderings.parse(String json) {
    final j = (jsonDecode(json) as Map).cast<String, Object?>();
    final ds = (j['dataset'] as Map).cast<String, Object?>();
    return ReadingRenderings(
      datasetId: ds['id'] as String,
      version: ds['version'] as String,
      language: ds['language'] as String,
      edition: TextEdition.fromJson((ds['edition'] as Map).cast<String, Object?>()),
      items: {for (final e in (j['items'] as Map).entries) e.key as String: ItemRenderings.fromJson(e.key as String, (e.value as Map).cast<String, Object?>())},
    );
  }
}

/// One playable item joined across the Latin corpus and a language.
class ReadingEntry {
  const ReadingEntry({required this.item, required this.passage, required this.renderings});
  final ReadingItem item;
  final ReadingPassage passage;
  final ItemRenderings renderings;
}

/// Content of one translation language, ready to play.
class ReadingSet {
  ReadingSet({required this.language, required this.corpus, required this.renderings})
      : entries = List.unmodifiable([
          for (final it in corpus.items.values)
            if (renderings.items[it.id] != null && corpus.passages[it.passageId] != null && it.status == 'validated')
              ReadingEntry(item: it, passage: corpus.passages[it.passageId]!, renderings: renderings.items[it.id]!),
        ]);

  final String language;
  final ReadingCorpus corpus;
  final ReadingRenderings renderings;
  final List<ReadingEntry> entries;

  ReadingEntry? byId(String itemId) {
    for (final e in entries) {
      if (e.item.id == itemId) return e;
    }
    return null;
  }

  List<ReadingEntry> ofTrial(String trialId) => entries.where((e) => e.item.trialId == trialId).toList();

  /// Every lemma present in validated playable content.
  Set<String> get playableLemmas => {for (final e in entries) ...e.passage.lemmas};
}

/// All reading content shipped with the app.
class ReadingLibrary {
  ReadingLibrary({required this.corpus, required Map<String, ReadingRenderings> renderings}) : _renderings = renderings; // ignore: prefer_initializing_formals

  final ReadingCorpus corpus;
  final Map<String, ReadingRenderings> _renderings;
  final Map<String, ReadingSet> _sets = {};

  static const String latinAsset = 'assets/theatrum/passages_la.json';
  static String renderingsAsset(String lang) => 'assets/theatrum/renderings_$lang.json';

  /// Languages the option screen may offer (in order).
  static const languages = ['fr', 'en'];

  bool supports(String language) => _renderings.containsKey(language);
  Iterable<String> get availableLanguages => _renderings.keys;

  /// Null when the language has no content: the caller must not fall back.
  ReadingSet? forLanguage(String language) {
    final r = _renderings[language];
    if (r == null) return null;
    return _sets[language] ??= ReadingSet(language: language, corpus: corpus, renderings: r);
  }

  static ReadingLibrary parse({required String latinJson, Map<String, String> renderingsJson = const {}}) => ReadingLibrary(
        corpus: ReadingCorpus.parse(latinJson),
        renderings: {for (final e in renderingsJson.entries) e.key: ReadingRenderings.parse(e.value)},
      );

  /// Loads the shipped files; a missing language file simply leaves that
  /// language unavailable.
  static Future<ReadingLibrary> load(AssetBundle bundle) async {
    final la = await bundle.loadString(latinAsset);
    final r = <String, String>{};
    for (final lang in languages) {
      try {
        r[lang] = await bundle.loadString(renderingsAsset(lang));
      } catch (_) {
        // not shipped for this language
      }
    }
    return parse(latinJson: la, renderingsJson: r);
  }

  /// An empty library (tests, or a build without content).
  static ReadingLibrary empty() => ReadingLibrary(
        corpus: const ReadingCorpus(
          datasetId: 'none',
          version: '0',
          edition: TextEdition(id: 'none', language: 'la', title: '', source: '', license: ''),
          passages: {},
          items: {},
          bookNames: {},
        ),
        renderings: const {},
      );
}
