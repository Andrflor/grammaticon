import '../model/analysis.dart';
import '../model/grammar.dart';
import '../model/verb.dart';
import 'declension.dart';
import 'irregular_paradigms.dart';

/// The complete set of forms of one verb, with the reasons for absences.
class Paradigm {
  Paradigm(this.verb, List<FormEntry> forms, this.absent) : forms = List.unmodifiable(forms) {
    for (final f in forms) {
      (_bySelector[f.analysis.selector] ??= []).add(f);
    }
  }

  final VerbEntry verb;
  final List<FormEntry> forms;
  final List<AbsentForm> absent;
  final Map<String, List<FormEntry>> _bySelector = {};

  /// All forms (primary and variants) of one exact selector.
  List<FormEntry> cell(String selector) => _bySelector[selector] ?? const [];

  /// Primary form of one selector, or null.
  FormEntry? primary(String selector) {
    for (final f in cell(selector)) {
      if (f.isPrimary) return f;
    }
    return null;
  }

  /// All forms whose selector matches [pattern] (see [AbsentForm.matches]).
  List<FormEntry> select(String pattern) {
    final p = AbsentForm(pattern, AbsenceStatus.datumDeest);
    return forms.where((f) => p.matches(f.analysis.selector)).toList();
  }

  /// Reason why [selector] has no form, or null when the form exists or was
  /// simply never derivable.
  AbsenceStatus? absenceFor(String selector) {
    for (final a in absent) {
      if (a.matches(selector)) return a.status;
    }
    return null;
  }

  /// True when the selector exists in the paradigm.
  bool has(String selector) => _bySelector.containsKey(selector);
  Iterable<String> get selectors => _bySelector.keys;
}

/// Person/number order used for six-cell tables.
const List<(Person, Numerus)> kPersons = [
  (Person.prima, Numerus.singularis),
  (Person.secunda, Numerus.singularis),
  (Person.tertia, Numerus.singularis),
  (Person.prima, Numerus.pluralis),
  (Person.secunda, Numerus.pluralis),
  (Person.tertia, Numerus.pluralis),
];

const _vowels = 'aeiouāēīōūAEIOUĀĒĪŌŪ';

/// Rule-based conjugator. Regular classes follow A&G §184–189, deponents
/// §190, periphrastics §193–196, irregulars come from [irregularTemplates].
class Conjugator {
  Conjugator({Map<String, Map<String, List<String>>>? templates})
      : _templates = templates ?? irregularTemplates;

  final Map<String, Map<String, List<String>>> _templates;
  final Map<String, Paradigm> _cache = {};

  Paradigm conjugate(VerbEntry v) => _cache[v.id] ??= _Build(v, _templates).run();
}

// ---------------------------------------------------------------------------
// Ending tables (A&G §184–189)
// ---------------------------------------------------------------------------

const _presIndAct = {
  Conjugation.prima: ['ō', 'ās', 'at', 'āmus', 'ātis', 'ant'],
  Conjugation.secunda: ['eō', 'ēs', 'et', 'ēmus', 'ētis', 'ent'],
  Conjugation.tertia: ['ō', 'is', 'it', 'imus', 'itis', 'unt'],
  Conjugation.tertiaIo: ['iō', 'is', 'it', 'imus', 'itis', 'iunt'],
  Conjugation.quarta: ['iō', 'īs', 'it', 'īmus', 'ītis', 'iunt'],
};
const _presIndPass = {
  Conjugation.prima: ['or', 'āris', 'ātur', 'āmur', 'āminī', 'antur'],
  Conjugation.secunda: ['eor', 'ēris', 'ētur', 'ēmur', 'ēminī', 'entur'],
  Conjugation.tertia: ['or', 'eris', 'itur', 'imur', 'iminī', 'untur'],
  Conjugation.tertiaIo: ['ior', 'eris', 'itur', 'imur', 'iminī', 'iuntur'],
  Conjugation.quarta: ['ior', 'īris', 'ītur', 'īmur', 'īminī', 'iuntur'],
};
const _imperfVowel = {
  Conjugation.prima: 'ā',
  Conjugation.secunda: 'ē',
  Conjugation.tertia: 'ē',
  Conjugation.tertiaIo: 'iē',
  Conjugation.quarta: 'iē',
};
const _baEndingsAct = ['bam', 'bās', 'bat', 'bāmus', 'bātis', 'bant'];
const _baEndingsPass = ['bar', 'bāris', 'bātur', 'bāmur', 'bāminī', 'bantur'];
const _futIndAct = {
  Conjugation.prima: ['ābō', 'ābis', 'ābit', 'ābimus', 'ābitis', 'ābunt'],
  Conjugation.secunda: ['ēbō', 'ēbis', 'ēbit', 'ēbimus', 'ēbitis', 'ēbunt'],
  Conjugation.tertia: ['am', 'ēs', 'et', 'ēmus', 'ētis', 'ent'],
  Conjugation.tertiaIo: ['iam', 'iēs', 'iet', 'iēmus', 'iētis', 'ient'],
  Conjugation.quarta: ['iam', 'iēs', 'iet', 'iēmus', 'iētis', 'ient'],
};
const _futIndPass = {
  Conjugation.prima: ['ābor', 'āberis', 'ābitur', 'ābimur', 'ābiminī', 'ābuntur'],
  Conjugation.secunda: ['ēbor', 'ēberis', 'ēbitur', 'ēbimur', 'ēbiminī', 'ēbuntur'],
  Conjugation.tertia: ['ar', 'ēris', 'ētur', 'ēmur', 'ēminī', 'entur'],
  Conjugation.tertiaIo: ['iar', 'iēris', 'iētur', 'iēmur', 'iēminī', 'ientur'],
  Conjugation.quarta: ['iar', 'iēris', 'iētur', 'iēmur', 'iēminī', 'ientur'],
};
const _presSubjAct = {
  Conjugation.prima: ['em', 'ēs', 'et', 'ēmus', 'ētis', 'ent'],
  Conjugation.secunda: ['eam', 'eās', 'eat', 'eāmus', 'eātis', 'eant'],
  Conjugation.tertia: ['am', 'ās', 'at', 'āmus', 'ātis', 'ant'],
  Conjugation.tertiaIo: ['iam', 'iās', 'iat', 'iāmus', 'iātis', 'iant'],
  Conjugation.quarta: ['iam', 'iās', 'iat', 'iāmus', 'iātis', 'iant'],
};
const _presSubjPass = {
  Conjugation.prima: ['er', 'ēris', 'ētur', 'ēmur', 'ēminī', 'entur'],
  Conjugation.secunda: ['ear', 'eāris', 'eātur', 'eāmur', 'eāminī', 'eantur'],
  Conjugation.tertia: ['ar', 'āris', 'ātur', 'āmur', 'āminī', 'antur'],
  Conjugation.tertiaIo: ['iar', 'iāris', 'iātur', 'iāmur', 'iāminī', 'iantur'],
  Conjugation.quarta: ['iar', 'iāris', 'iātur', 'iāmur', 'iāminī', 'iantur'],
};
// Imperfect subjunctive: infinitive stem (amār-) + these.
const _imperfSubjAct = ['em', 'ēs', 'et', 'ēmus', 'ētis', 'ent'];
const _imperfSubjPass = ['er', 'ēris', 'ētur', 'ēmur', 'ēminī', 'entur'];
// Stem vowel before the r of the imperfect subjunctive / infinitive.
const _infVowel = {
  Conjugation.prima: 'ā',
  Conjugation.secunda: 'ē',
  Conjugation.tertia: 'e',
  Conjugation.tertiaIo: 'e',
  Conjugation.quarta: 'ī',
};
// Perfect system (A&G §184): long ī in 2 sg / 1 pl / 2 pl of the perfect
// subjunctive following A&G's paradigm; short in the future perfect.
const _perfInd = ['ī', 'istī', 'it', 'imus', 'istis', 'ērunt'];
const _plusqInd = ['eram', 'erās', 'erat', 'erāmus', 'erātis', 'erant'];
const _futexInd = ['erō', 'eris', 'erit', 'erimus', 'eritis', 'erint'];
const _perfSubj = ['erim', 'erīs', 'erit', 'erīmus', 'erītis', 'erint'];
const _plusqSubj = ['issem', 'issēs', 'isset', 'issēmus', 'issētis', 'issent'];

// Auxiliary sum for composite forms.
const _auxInd = {
  Tense.praesens: ['sum', 'es', 'est', 'sumus', 'estis', 'sunt'],
  Tense.imperfectum: ['eram', 'erās', 'erat', 'erāmus', 'erātis', 'erant'],
  Tense.futurum: ['erō', 'eris', 'erit', 'erimus', 'eritis', 'erunt'],
  Tense.perfectum: ['fuī', 'fuistī', 'fuit', 'fuimus', 'fuistis', 'fuērunt'],
  Tense.plusquamperfectum: ['fueram', 'fuerās', 'fuerat', 'fuerāmus', 'fuerātis', 'fuerant'],
  Tense.futurumExactum: ['fuerō', 'fueris', 'fuerit', 'fuerimus', 'fueritis', 'fuerint'],
};
const _auxSubj = {
  Tense.praesens: ['sim', 'sīs', 'sit', 'sīmus', 'sītis', 'sint'],
  Tense.imperfectum: ['essem', 'essēs', 'esset', 'essēmus', 'essētis', 'essent'],
  Tense.perfectum: ['fuerim', 'fuerīs', 'fuerit', 'fuerīmus', 'fuerītis', 'fuerint'],
  Tense.plusquamperfectum: ['fuissem', 'fuissēs', 'fuisset', 'fuissēmus', 'fuissētis', 'fuissent'],
};
const _forem = ['forem', 'forēs', 'foret', 'forēmus', 'forētis', 'forent'];

/// Nominative participle endings for composite forms.
String _nomEnding(Numerus n, Gender g) {
  switch ((n, g)) {
    case (Numerus.singularis, Gender.masculinum):
      return 'us';
    case (Numerus.singularis, Gender.femininum):
      return 'a';
    case (Numerus.singularis, Gender.neutrum):
      return 'um';
    case (Numerus.pluralis, Gender.masculinum):
      return 'ī';
    case (Numerus.pluralis, Gender.femininum):
      return 'ae';
    case (Numerus.pluralis, Gender.neutrum):
      return 'a';
  }
}

String _accEnding(Numerus n, Gender g) {
  switch ((n, g)) {
    case (Numerus.singularis, Gender.masculinum):
      return 'um';
    case (Numerus.singularis, Gender.femininum):
      return 'am';
    case (Numerus.singularis, Gender.neutrum):
      return 'um';
    case (Numerus.pluralis, Gender.masculinum):
      return 'ōs';
    case (Numerus.pluralis, Gender.femininum):
      return 'ās';
    case (Numerus.pluralis, Gender.neutrum):
      return 'a';
  }
}

/// Removes macrons and breves for macron-insensitive comparison.
String stripMacrons(String s) {
  const map = {
    'ā': 'a', 'ē': 'e', 'ī': 'i', 'ō': 'o', 'ū': 'u', 'ȳ': 'y',
    'Ā': 'A', 'Ē': 'E', 'Ī': 'I', 'Ō': 'O', 'Ū': 'U', 'Ȳ': 'Y',
    'ă': 'a', 'ĕ': 'e', 'ĭ': 'i', 'ŏ': 'o', 'ŭ': 'u',
  };
  final b = StringBuffer();
  for (final r in s.runes) {
    final ch = String.fromCharCode(r);
    b.write(map[ch] ?? ch);
  }
  return b.toString();
}

// ---------------------------------------------------------------------------

class _Build {
  _Build(this.v, this.templates);

  final VerbEntry v;
  final Map<String, Map<String, List<String>>> templates;
  final List<FormEntry> out = [];
  final List<AbsentForm> absent = [];

  /// Cell overrides: exact selector -> surfaces ("form", "form#variantKey").
  final Map<String, List<String>> cellOverrides = {};

  /// Stem directives for nominal forms: `part.praes.act` -> `nom/stem`,
  /// `part.perf.pass`, `part.fut.act`, `gdv`, `ger`, `sup` -> stem.
  final Map<String, String> stemDirectives = {};

  late final Conjugation conj = v.conjugation;
  late final bool deponent = v.isDeponent;
  late final Voice? depSemantic = deponent || v.isSemiDeponent ? Voice.activum : null;

  // ----- stems -----------------------------------------------------------

  /// Root without thematic vowel (am-, mon-, reg-, cap-, aud-).
  String get base {
    final inf = v.infinitive;
    String cut(String s, String suffix) => s.endsWith(suffix) ? s.substring(0, s.length - suffix.length) : s;
    if (deponent) {
      switch (conj) {
        case Conjugation.prima:
          return cut(inf, 'ārī');
        case Conjugation.secunda:
          return cut(inf, 'ērī');
        case Conjugation.tertia:
        case Conjugation.tertiaIo:
          return cut(inf, 'ī');
        case Conjugation.quarta:
          return cut(inf, 'īrī');
        case Conjugation.anomala:
          return inf;
      }
    }
    switch (conj) {
      case Conjugation.prima:
        // dō, dare (short a): the infinitive is stored as written.
        return inf.endsWith('are') ? cut(inf, 'are') : cut(inf, 'āre');
      case Conjugation.secunda:
        return cut(inf, 'ēre');
      case Conjugation.tertia:
      case Conjugation.tertiaIo:
        return cut(inf, 'ere');
      case Conjugation.quarta:
        return cut(inf, 'īre');
      case Conjugation.anomala:
        return inf;
    }
  }

  String? get perfectStem => v.perfectStem;
  String? get pppStem {
    final d = stemDirectives['part.perf.pass'];
    if (d != null) return d == '-' ? null : d;
    if (!v.hasSupine) return null;
    return v.supineStem ?? v.deponentParticipleStem;
  }

  String? get futPartStem {
    final d = stemDirectives['part.fut.act'];
    if (d != null) return d == '-' ? null : d;
    if (!v.hasSupine) return null;
    final s = v.supineStem ?? v.deponentParticipleStem;
    return s == null ? null : '${s}ūr';
  }

  String? get gerundiveStem {
    final d = stemDirectives['gdv'];
    if (d != null) return d == '-' ? null : d;
    if (!v.hasPresentSystem || v.isIrregular) return null;
    switch (conj) {
      case Conjugation.prima:
        return '${base}and';
      case Conjugation.secunda:
      case Conjugation.tertia:
        return '${base}end';
      case Conjugation.tertiaIo:
      case Conjugation.quarta:
        return '${base}iend';
      case Conjugation.anomala:
        return null;
    }
  }

  String? get gerundStem {
    final d = stemDirectives['ger'];
    if (d != null) return d == '-' ? null : d;
    return gerundiveStem;
  }

  String? get supineStemForms {
    final d = stemDirectives['sup'];
    if (d != null) return d == '-' ? null : d;
    if (!v.hasSupine) return null;
    return v.supineStem ?? v.deponentParticipleStem;
  }

  /// (nominative, stem) of the present participle.
  (String, String)? get presentParticiple {
    final d = stemDirectives['part.praes.act'];
    if (d != null) {
      if (d == '-') return null;
      final parts = d.split('/');
      return (parts[0], parts[1]);
    }
    if (!v.hasPresentSystem || v.isIrregular) return null;
    switch (conj) {
      case Conjugation.prima:
        return ('${base}āns', '${base}ant');
      case Conjugation.secunda:
      case Conjugation.tertia:
        return ('${base}ēns', '${base}ent');
      case Conjugation.tertiaIo:
      case Conjugation.quarta:
        return ('${base}iēns', '${base}ient');
      case Conjugation.anomala:
        return null;
    }
  }

  // ----- helpers ---------------------------------------------------------

  void add(String surface, Analysis a) => out.add(FormEntry(surface, a));

  /// Adds a cell from a list of surfaces: the first is primary, later ones are
  /// variants ("forma#kind", default [VariantKind.altera]). "-" means absent.
  void addCell(Analysis a, List<String> surfaces, {AbsenceStatus absence = AbsenceStatus.nonExstat}) {
    var first = true;
    for (final raw in surfaces) {
      if (raw == '-' || raw.isEmpty) {
        if (first) absent.add(AbsentForm(a.selector, absence));
        first = false;
        continue;
      }
      final hash = raw.indexOf('#');
      final surface = hash < 0 ? raw : raw.substring(0, hash);
      VariantKind kind;
      if (hash >= 0) {
        kind = VariantKind.fromKey(raw.substring(hash + 1));
      } else {
        kind = first ? VariantKind.norma : VariantKind.altera;
      }
      add(surface, a.copyWith(variant: kind));
      first = false;
    }
  }

  Analysis fin(Mood m, Tense t, Voice vo, Person p, Numerus n, {Gender? g, bool composite = false, Periphrasis per = Periphrasis.nulla}) {
    return Analysis(
      lemmaId: v.id,
      mood: m,
      tense: t,
      voice: vo,
      person: p,
      number: n,
      gender: g,
      composite: composite,
      periphrasis: per,
      semanticVoice: (vo == Voice.passivum && per == Periphrasis.nulla) ? depSemantic : null,
    );
  }

  void sixCells(Mood m, Tense t, Voice vo, String stem, List<String> endings) {
    for (var i = 0; i < 6; i++) {
      final (p, n) = kPersons[i];
      add('$stem${endings[i]}', fin(m, t, vo, p, n));
    }
  }

  /// Applies a prefix to a template surface (compounds of irregular verbs).
  String prefixed(String s) {
    final pre = v.prefix;
    if (pre == null) return s;
    // Composite / multi-word surfaces prefix each verbal word.
    final parts = s.split('/');
    return parts.map((p) {
      if (p == '-' || p.isEmpty) return p;
      final hash = p.indexOf('#');
      final body = hash < 0 ? p : p.substring(0, hash);
      final tail = hash < 0 ? '' : p.substring(hash);
      final startsVowel = _vowels.contains(body[0]);
      final usePre = (startsVowel && v.prefixBeforeVowel != null) ? v.prefixBeforeVowel! : pre;
      return '$usePre$body$tail';
    }).join('/');
  }

  void collectOverrides() {
    final merged = <String, List<String>>{};
    final family = v.compoundOf ?? (v.isIrregular ? v.family : null);
    if (family != null && templates.containsKey(family)) {
      for (final e in templates[family]!.entries) {
        merged[e.key] = e.value.map(prefixed).toList();
      }
    }
    merged.addAll(v.overrides);

    for (final e in merged.entries) {
      final key = e.key;
      final vals = e.value;
      if (const {'part.praes.act', 'part.perf.pass', 'part.fut.act', 'gdv', 'ger', 'sup'}.contains(key)) {
        stemDirectives[key] = vals.first;
        continue;
      }
      final segs = key.split('.');
      final isBlock = (segs[0] == 'ind' || segs[0] == 'subj') && segs.length == 3 ||
          (segs[0] == 'imp' && segs.length == 3);
      if (isBlock && vals.length == 6 && segs[0] != 'imp') {
        for (var i = 0; i < 6; i++) {
          final (p, n) = kPersons[i];
          cellOverrides['$key.${p.key}.${n.key}'] = vals[i].split('/');
        }
      } else if (isBlock && segs[0] == 'imp') {
        // Imperative block: praes -> [2sg, 2pl]; fut -> [2sg, 3sg, 2pl, 3pl].
        final cells = segs[1] == 'praes'
            ? ['2.sg', '2.pl']
            : segs[2] == 'pass'
                ? ['2.sg', '3.sg', '3.pl']
                : ['2.sg', '3.sg', '2.pl', '3.pl'];
        for (var i = 0; i < cells.length && i < vals.length; i++) {
          cellOverrides['$key.${cells[i]}'] = vals[i].split('/');
        }
      } else {
        cellOverrides[key] = vals.length == 1 ? vals.first.split('/') : vals;
      }
    }
  }

  // ----- regular present system -------------------------------------------

  void presentSystemRegular() {
    final b = base;
    final iv = _infVowel[conj]!;
    final infStem = '$b${iv}r'; // amār-, regēr- etc. for imperfect subjunctive
    final imperfV = _imperfVowel[conj]!;
    final vowelEndings3 = conj == Conjugation.tertia;

    if (!deponent) {
      sixCells(Mood.indicativus, Tense.praesens, Voice.activum, b, _presIndAct[conj]!);
      sixCells(Mood.indicativus, Tense.imperfectum, Voice.activum, '$b$imperfV', _baEndingsAct);
      sixCells(Mood.indicativus, Tense.futurum, Voice.activum, b, _futIndAct[conj]!);
      sixCells(Mood.subiunctivus, Tense.praesens, Voice.activum, b, _presSubjAct[conj]!);
      sixCells(Mood.subiunctivus, Tense.imperfectum, Voice.activum, infStem, _imperfSubjAct);
      // Imperatives (A&G §163, §184)
      final imp2sg = vowelEndings3 || conj == Conjugation.tertiaIo ? '${b}e' : '$b$iv';
      final imp2pl = vowelEndings3 || conj == Conjugation.tertiaIo ? '${b}ite' : '$b${iv}te';
      final impFutStem = vowelEndings3 || conj == Conjugation.tertiaIo ? '${b}it' : '$b${iv}t';
      final thirdPl = _presIndAct[conj]![5]; // ant / ent / unt / iunt
      final thirdPlStem = '$b${thirdPl.substring(0, thirdPl.length - 1)}'; // aman-t -> aman
      add(imp2sg, fin(Mood.imperativus, Tense.praesens, Voice.activum, Person.secunda, Numerus.singularis));
      add(imp2pl, fin(Mood.imperativus, Tense.praesens, Voice.activum, Person.secunda, Numerus.pluralis));
      add('${impFutStem}ō', fin(Mood.imperativus, Tense.futurum, Voice.activum, Person.secunda, Numerus.singularis));
      add('${impFutStem}ō', fin(Mood.imperativus, Tense.futurum, Voice.activum, Person.tertia, Numerus.singularis));
      add('${impFutStem}ōte', fin(Mood.imperativus, Tense.futurum, Voice.activum, Person.secunda, Numerus.pluralis));
      add('${thirdPlStem}tō', fin(Mood.imperativus, Tense.futurum, Voice.activum, Person.tertia, Numerus.pluralis));
      // Infinitive present active
      add(v.infinitive, Analysis(lemmaId: v.id, mood: Mood.infinitivus, tense: Tense.praesens, voice: Voice.activum));
    }

    // Passive morphology (also deponents).
    sixCells(Mood.indicativus, Tense.praesens, Voice.passivum, b, _presIndPass[conj]!);
    sixCells(Mood.indicativus, Tense.imperfectum, Voice.passivum, '$b$imperfV', _baEndingsPass);
    sixCells(Mood.indicativus, Tense.futurum, Voice.passivum, b, _futIndPass[conj]!);
    sixCells(Mood.subiunctivus, Tense.praesens, Voice.passivum, b, _presSubjPass[conj]!);
    sixCells(Mood.subiunctivus, Tense.imperfectum, Voice.passivum, infStem, _imperfSubjPass);
    // Passive imperatives
    final impPass2sg = vowelEndings3 || conj == Conjugation.tertiaIo ? '${b}ere' : '$b${iv}re';
    final impPass2pl = '$b${_presIndPass[conj]![4]}';
    final impFutPassStem = vowelEndings3 || conj == Conjugation.tertiaIo ? '${b}it' : '$b${iv}t';
    final thirdPlPass = _presIndPass[conj]![5]; // antur
    final thirdPlPassStem = '$b${thirdPlPass.substring(0, thirdPlPass.length - 3)}'; // an
    add(impPass2sg, fin(Mood.imperativus, Tense.praesens, Voice.passivum, Person.secunda, Numerus.singularis));
    add(impPass2pl, fin(Mood.imperativus, Tense.praesens, Voice.passivum, Person.secunda, Numerus.pluralis));
    add('${impFutPassStem}or', fin(Mood.imperativus, Tense.futurum, Voice.passivum, Person.secunda, Numerus.singularis));
    add('${impFutPassStem}or', fin(Mood.imperativus, Tense.futurum, Voice.passivum, Person.tertia, Numerus.singularis));
    add('${thirdPlPassStem}tor', fin(Mood.imperativus, Tense.futurum, Voice.passivum, Person.tertia, Numerus.pluralis));
    // Infinitive present passive
    final infPass = switch (conj) {
      Conjugation.prima => '${b}ārī',
      Conjugation.secunda => '${b}ērī',
      Conjugation.tertia || Conjugation.tertiaIo => '${b}ī',
      Conjugation.quarta => '${b}īrī',
      Conjugation.anomala => '${b}ī',
    };
    add(infPass, Analysis(lemmaId: v.id, mood: Mood.infinitivus, tense: Tense.praesens, voice: Voice.passivum, semanticVoice: depSemantic));
  }

  // ----- perfect system active ----------------------------------------------

  void perfectSystemActive(String p) {
    void six(Mood m, Tense t, List<String> endings) {
      for (var i = 0; i < 6; i++) {
        final (per, n) = kPersons[i];
        add(_join(p, endings[i]), fin(m, t, Voice.activum, per, n));
      }
    }

    six(Mood.indicativus, Tense.perfectum, _perfInd);
    six(Mood.indicativus, Tense.plusquamperfectum, _plusqInd);
    six(Mood.indicativus, Tense.futurumExactum, _futexInd);
    six(Mood.subiunctivus, Tense.perfectum, _perfSubj);
    six(Mood.subiunctivus, Tense.plusquamperfectum, _plusqSubj);
    add(_join(p, 'isse'), Analysis(lemmaId: v.id, mood: Mood.infinitivus, tense: Tense.perfectum, voice: Voice.activum));
  }

  /// Joins perfect stem and ending, contracting i+is -> īs (iī, īstī; audiit, audīstī).
  static String _join(String stem, String ending) {
    if (stem.endsWith('i') && ending.startsWith('is')) {
      return '${stem.substring(0, stem.length - 1)}ī${ending.substring(1)}';
    }
    return '$stem$ending';
  }

  // ----- composite forms ---------------------------------------------------

  /// Person/number/gender cells of composite forms. [impersonalOnly]
  /// restricts to 3 sg neuter (impersonal passive of intransitives).
  Iterable<(Person, Numerus, Gender)> compositeCells({required bool impersonalOnly}) sync* {
    for (final (p, n) in kPersons) {
      for (final g in Gender.values) {
        if (impersonalOnly) {
          if (p != Person.tertia || n != Numerus.singularis || g != Gender.neutrum) continue;
        } else if (g == Gender.neutrum && p != Person.tertia) {
          continue;
        }
        yield (p, n, g);
      }
    }
  }

  void perfectPassiveComposite(String ppp) {
    // Deponents are personal even when intransitive (mortuus est).
    final impersonalOnly = v.isImpersonal || (v.intransitive && !deponent && !v.isSemiDeponent);
    for (final (p, n, g) in compositeCells(impersonalOnly: impersonalOnly)) {
      final i = kPersons.indexOf((p, n));
      final part = '$ppp${_nomEnding(n, g)}';
      for (final t in [Tense.perfectum, Tense.plusquamperfectum, Tense.futurumExactum]) {
        final auxTense = switch (t) {
          Tense.perfectum => Tense.praesens,
          Tense.plusquamperfectum => Tense.imperfectum,
          _ => Tense.futurum,
        };
        final a = fin(Mood.indicativus, t, Voice.passivum, p, n, g: g, composite: true);
        add('$part ${_auxInd[auxTense]![i]}', a);
        add('$part ${_auxInd[t]![i]}', a.copyWith(variant: VariantKind.fuiAuxiliare));
      }
      for (final t in [Tense.perfectum, Tense.plusquamperfectum]) {
        final auxTense = t == Tense.perfectum ? Tense.praesens : Tense.imperfectum;
        final a = fin(Mood.subiunctivus, t, Voice.passivum, p, n, g: g, composite: true);
        add('$part ${_auxSubj[auxTense]![i]}', a);
        add('$part ${_auxSubj[t]![i]}', a.copyWith(variant: VariantKind.fuiAuxiliare));
        if (t == Tense.plusquamperfectum) {
          add('$part ${_forem[i]}', a.copyWith(variant: VariantKind.forem));
        }
      }
    }
  }

  void periphrastic(Periphrasis per, String partStem) {
    // The passive periphrastic of an intransitive verb is impersonal
    // (pugnandum est); the active one is personal (pugnātūrus sum).
    final impersonalOnly = v.isImpersonal || (per == Periphrasis.passiva && v.intransitive);
    for (final (p, n, g) in compositeCells(impersonalOnly: impersonalOnly)) {
      final i = kPersons.indexOf((p, n));
      final part = '$partStem${_nomEnding(n, g)}';
      for (final t in Tense.values) {
        add('$part ${_auxInd[t]![i]}', fin(Mood.indicativus, t, per == Periphrasis.activa ? Voice.activum : Voice.passivum, p, n, g: g, composite: true, per: per));
      }
      for (final t in _auxSubj.keys) {
        add('$part ${_auxSubj[t]![i]}', fin(Mood.subiunctivus, t, per == Periphrasis.activa ? Voice.activum : Voice.passivum, p, n, g: g, composite: true, per: per));
      }
    }
    // Infinitives of the periphrastic conjugation (amātūrus esse / fuisse).
    for (final n in Numerus.values) {
      for (final g in Gender.values) {
        if (impersonalOnly && (n != Numerus.singularis || g != Gender.neutrum)) continue;
        for (final (casus, ending) in [(Casus.nominativus, _nomEnding(n, g)), (Casus.accusativus, _accEnding(n, g))]) {
          final part = '$partStem$ending';
          final vo = per == Periphrasis.activa ? Voice.activum : Voice.passivum;
          add('$part esse', Analysis(lemmaId: v.id, mood: Mood.infinitivus, tense: Tense.praesens, voice: vo, number: n, gender: g, casus: casus, composite: true, periphrasis: per));
          add('$part fuisse', Analysis(lemmaId: v.id, mood: Mood.infinitivus, tense: Tense.perfectum, voice: vo, number: n, gender: g, casus: casus, composite: true, periphrasis: per));
        }
      }
    }
  }

  void compositeInfinitives(String? ppp, String? futPart, String? sup) {
    final passiveImpersonal = v.isImpersonal || (v.intransitive && !deponent && !v.isSemiDeponent);
    for (final n in Numerus.values) {
      for (final g in Gender.values) {
        final neuterSg = n == Numerus.singularis && g == Gender.neutrum;
        for (final (casus, ending) in [(Casus.nominativus, _nomEnding(n, g)), (Casus.accusativus, _accEnding(n, g))]) {
          if (ppp != null && (!passiveImpersonal || neuterSg)) {
            final a = Analysis(lemmaId: v.id, mood: Mood.infinitivus, tense: Tense.perfectum, voice: Voice.passivum, number: n, gender: g, casus: casus, composite: true, semanticVoice: depSemantic);
            add('$ppp$ending esse', a);
            add('$ppp$ending fuisse', a.copyWith(variant: VariantKind.fuiAuxiliare));
          }
          if (futPart != null && (!v.isImpersonal || neuterSg)) {
            add('$futPart$ending esse', Analysis(lemmaId: v.id, mood: Mood.infinitivus, tense: Tense.futurum, voice: Voice.activum, number: n, gender: g, casus: casus, composite: true));
          }
        }
      }
    }
    if (sup != null && !deponent && !v.isSemiDeponent) {
      add('${sup}um īrī', Analysis(lemmaId: v.id, mood: Mood.infinitivus, tense: Tense.futurum, voice: Voice.passivum, composite: true));
    }
  }

  // ----- nominal forms -----------------------------------------------------

  void nominal(Mood mood, Tense? tense, Voice? voice, List<DeclinedCell> cells, {Voice? semantic}) {
    final impersonalOnly = v.isImpersonal || (v.intransitive && !deponent);
    for (final c in cells) {
      if (mood == Mood.gerundivum && impersonalOnly && (c.gender != Gender.neutrum || c.number != Numerus.singularis)) {
        continue;
      }
      addCell(
        Analysis(lemmaId: v.id, mood: mood, tense: tense, voice: voice, casus: c.casus, number: c.number, gender: c.gender, semanticVoice: semantic),
        c.surfaces,
      );
    }
  }

  // ----- variants ------------------------------------------------------------

  void ruleVariants() {
    final extra = <FormEntry>[];
    for (final f in out) {
      final a = f.analysis;
      if (!a.isPrimary || a.composite) continue;
      // 3 pl perfect -ēre
      if (a.mood == Mood.indicativus && a.tense == Tense.perfectum && a.person == Person.tertia && a.number == Numerus.pluralis && f.surface.endsWith('ērunt')) {
        extra.add(FormEntry('${f.surface.substring(0, f.surface.length - 5)}ēre', a.copyWith(variant: VariantKind.perfectumEre)));
      }
      // 2 sg passive -re
      if (a.voice == Voice.passivum && a.person == Person.secunda && a.number == Numerus.singularis && (a.mood == Mood.indicativus || a.mood == Mood.subiunctivus) && a.tense != null && !a.tense!.isPerfectSystem && f.surface.endsWith('ris')) {
        final kind = (a.mood == Mood.indicativus && a.tense == Tense.praesens) ? VariantKind.rara : VariantKind.passivumRe;
        extra.add(FormEntry('${f.surface.substring(0, f.surface.length - 3)}re', a.copyWith(variant: kind)));
      }
    }
    out.addAll(extra);
  }

  /// Syncopated perfects (A&G §181): amāstī, amāsse, amārunt, audiit, audīsse.
  void syncopatedPerfects(String p) {
    final extra = <FormEntry>[];
    final endsAv = p.endsWith('āv') || p.endsWith('ēv') || p.endsWith('ōv');
    final endsIv = p.endsWith('īv');
    if (!endsAv && !endsIv) return;
    for (final f in out) {
      final a = f.analysis;
      if (!a.isPrimary || a.composite || a.voice != Voice.activum) continue;
      if (!(a.tense?.isPerfectSystem ?? false)) continue;
      if (!f.surface.startsWith(p)) continue;
      final ending = f.surface.substring(p.length);
      String? s;
      if (endsAv) {
        if (ending.startsWith('is')) {
          s = '${p.substring(0, p.length - 1)}${ending.substring(1)}';
        } else if (ending.startsWith('er') || ending.startsWith('ēr')) {
          s = '${p.substring(0, p.length - 1)}${ending.substring(1)}';
        }
      } else {
        final short = '${p.substring(0, p.length - 2)}i';
        s = _join(short, ending);
        if (s == f.surface) s = null;
      }
      if (s != null) extra.add(FormEntry(s, a.copyWith(variant: VariantKind.syncopa)));
    }
    out.addAll(extra);
  }

  void undusVariants() {
    if (conj != Conjugation.tertia && conj != Conjugation.tertiaIo && conj != Conjugation.quarta) return;
    final stem = gerundiveStem;
    if (stem == null || !stem.endsWith('end')) return;
    final und = '${stem.substring(0, stem.length - 3)}und';
    final extra = <FormEntry>[];
    for (final f in out) {
      final a = f.analysis;
      if (!a.isPrimary || a.composite) continue;
      if ((a.mood == Mood.gerundivum || a.mood == Mood.gerundium) && f.surface.startsWith(stem)) {
        extra.add(FormEntry('$und${f.surface.substring(stem.length)}', a.copyWith(variant: VariantKind.undus)));
      }
    }
    out.addAll(extra);
  }

  void applyShortA() {
    if (!v.shortA) return;
    const protect = {'ind.praes.act.2.sg', 'imp.praes.act.2.sg'};
    for (var i = 0; i < out.length; i++) {
      final f = out[i];
      final sel = f.analysis.selector;
      if (protect.contains(sel)) continue;
      if (f.analysis.mood == Mood.participium && f.analysis.tense == Tense.praesens && f.analysis.number == Numerus.singularis && (f.analysis.casus == Casus.nominativus || f.analysis.casus == Casus.vocativus || (f.analysis.casus == Casus.accusativus && f.analysis.gender == Gender.neutrum))) {
        continue;
      }
      if (f.surface.contains('ā')) {
        // Only the stem vowel of the present system is short: dăbam, dătus. The
        // syllable of a perfect stem (dedī) never contains ā anyway.
        out[i] = FormEntry(f.surface.replaceAll('ā', 'a'), f.analysis);
      }
    }
  }

  void applyPerfectAsPresent() {
    if (!v.perfectHasPresentSense) return;
    for (var i = 0; i < out.length; i++) {
      final f = out[i];
      final t = f.analysis.tense;
      Tense? sem;
      switch (t) {
        case Tense.perfectum:
          sem = Tense.praesens;
        case Tense.plusquamperfectum:
          sem = Tense.imperfectum;
        case Tense.futurumExactum:
          sem = Tense.futurum;
        default:
          sem = null;
      }
      if (sem != null && f.analysis.mood != Mood.participium) {
        out[i] = FormEntry(f.surface, f.analysis.copyWith(semanticTense: sem));
      }
    }
  }

  // ----- overrides & absences ------------------------------------------------

  void applyCellOverrides() {
    for (final e in cellOverrides.entries) {
      final sel = e.key;
      out.removeWhere((f) => f.analysis.selector == sel);
      final a = _analysisFromSelector(sel);
      if (a == null) continue;
      addCell(a, e.value, absence: AbsenceStatus.nonExstat);
    }
  }

  Analysis? _analysisFromSelector(String sel) {
    final s = sel.split('.');
    var i = 0;
    var per = Periphrasis.nulla;
    if (s[i] == 'pa' || s[i] == 'pp') {
      per = Periphrasis.fromKey(s[i]);
      i++;
    }
    final mood = Mood.fromKey(s[i++]);
    Tense? tense;
    Voice? voice;
    Person? person;
    Casus? casus;
    Numerus? number;
    Gender? gender;
    for (; i < s.length; i++) {
      final k = s[i];
      if (Tense.values.any((t) => t.key == k)) {
        tense = Tense.fromKey(k);
      } else if (k == 'act' || k == 'pass') {
        voice = Voice.fromKey(k);
      } else if (k == '1' || k == '2' || k == '3') {
        person = Person.fromKey(k);
      } else if (Casus.values.any((c) => c.key == k)) {
        casus = Casus.fromKey(k);
      } else if (k == 'sg' || k == 'pl') {
        number = Numerus.fromKey(k);
      } else if (k == 'm' || k == 'f' || k == 'n') {
        gender = Gender.fromKey(k);
      } else {
        return null;
      }
    }
    final composite = per != Periphrasis.nulla || (tense?.isPerfectSystem == true && voice == Voice.passivum && mood != Mood.participium);
    return Analysis(
      lemmaId: v.id,
      mood: mood,
      tense: tense,
      voice: voice,
      person: person,
      number: number,
      gender: gender,
      casus: casus,
      periphrasis: per,
      composite: composite,
      semanticVoice: (voice == Voice.passivum && mood != Mood.gerundivum && per == Periphrasis.nulla) ? depSemantic : null,
    );
  }

  void applyAbsences() {
    for (final a in v.absent) {
      out.removeWhere((f) => a.matches(f.analysis.selector));
      absent.add(a);
    }
  }

  void impersonalFilter() {
    if (!v.isImpersonal) return;
    out.removeWhere((f) {
      final a = f.analysis;
      if (a.mood == Mood.imperativus) return true;
      if (a.isFinite) return a.person != Person.tertia || a.number != Numerus.singularis;
      return false;
    });
    absent.add(const AbsentForm('imp', AbsenceStatus.nonExstat, note: 'verbum impersōnāle'));
    for (final m in ['ind', 'subj']) {
      for (final p in ['1', '2']) {
        absent.add(AbsentForm('$m.*.*.$p', AbsenceStatus.nonExstat, note: 'verbum impersōnāle: sōla tertia persōna singulāris'));
      }
      absent.add(AbsentForm('$m.*.*.3.pl', AbsenceStatus.nonExstat, note: 'verbum impersōnāle'));
    }
  }

  /// Semi-deponents have no present-system passive: their passive morphology
  /// is confined to the perfect system, where it carries the active meaning.
  void semiDeponentAbsences() {
    if (!v.isSemiDeponent) return;
    out.removeWhere((f) {
      final a = f.analysis;
      if (a.voice != Voice.passivum || a.composite || a.periphrasis != Periphrasis.nulla) return false;
      if (a.mood == Mood.participium || a.mood == Mood.gerundivum) return false;
      return true;
    });
    for (final t in ['praes', 'imperf', 'fut']) {
      absent.add(AbsentForm('ind.$t.pass', AbsenceStatus.nonExstat, note: 'sēmidēpōnēns: passīvum sōlum in systēmate perfectī'));
    }
    absent.add(const AbsentForm('subj.praes.pass', AbsenceStatus.nonExstat, note: 'sēmidēpōnēns'));
    absent.add(const AbsentForm('subj.imperf.pass', AbsenceStatus.nonExstat, note: 'sēmidēpōnēns'));
    absent.add(const AbsentForm('imp.*.pass', AbsenceStatus.nonExstat, note: 'sēmidēpōnēns'));
    absent.add(const AbsentForm('inf.praes.pass', AbsenceStatus.nonExstat, note: 'sēmidēpōnēns'));
    absent.add(const AbsentForm('inf.fut.pass', AbsenceStatus.nonExstat, note: 'sēmidēpōnēns'));
  }

  void intransitiveAbsences() {
    if (!v.intransitive || deponent || v.isSemiDeponent) return;
    for (final m in ['ind', 'subj']) {
      for (final p in ['1', '2']) {
        absent.add(AbsentForm('$m.*.pass.$p', AbsenceStatus.nonExstat, note: 'verbum intrānsitīvum: passīvum impersōnāle tantum'));
      }
      absent.add(AbsentForm('$m.*.pass.3.pl', AbsenceStatus.nonExstat, note: 'verbum intrānsitīvum: passīvum impersōnāle tantum'));
    }
    absent.add(const AbsentForm('imp.*.pass', AbsenceStatus.nonExstat, note: 'verbum intrānsitīvum'));
    out.removeWhere((f) {
      final a = f.analysis;
      if (a.voice != Voice.passivum || a.periphrasis != Periphrasis.nulla) return false;
      if (a.mood == Mood.imperativus) return true;
      if (a.isFinite) return a.person != Person.tertia || a.number != Numerus.singularis;
      return false;
    });
  }

  // ----- main -----------------------------------------------------------------

  Paradigm run() {
    collectOverrides();
    final usesTemplate = (v.compoundOf ?? (v.isIrregular ? v.family : null)) != null &&
        templates.containsKey(v.compoundOf ?? v.family);

    if (!v.explicitOnly && v.hasPresentSystem && !usesTemplate && conj != Conjugation.anomala) {
      presentSystemRegular();
    }

    final p = perfectStem;
    if (!v.explicitOnly && v.hasPerfect && p != null && (!deponent || v.kind == VerbKind.semideponensInversum)) {
      perfectSystemActive(p);
    }

    final ppp = pppStem;
    final fut = futPartStem;
    final gdv = gerundiveStem;
    final ger = gerundStem;
    final sup = supineStemForms;
    final pp = presentParticiple;

    if (!v.explicitOnly) {
      if (ppp != null && v.kind != VerbKind.semideponensInversum) {
        perfectPassiveComposite(ppp);
      }
      compositeInfinitives(v.kind == VerbKind.semideponensInversum ? null : ppp, fut, sup);
      if (pp != null) {
        nominal(Mood.participium, Tense.praesens, Voice.activum, declineParticiple(pp.$1, pp.$2));
      }
      if (ppp != null) {
        nominal(Mood.participium, Tense.perfectum, Voice.passivum, declineBonus(ppp), semantic: depSemantic);
      }
      if (fut != null) {
        nominal(Mood.participium, Tense.futurum, Voice.activum, declineBonus(fut));
      }
      if (gdv != null) {
        nominal(Mood.gerundivum, null, null, declineBonus(gdv));
      }
      if (ger != null) {
        for (final (c, e) in [(Casus.genetivus, 'ī'), (Casus.dativus, 'ō'), (Casus.accusativus, 'um'), (Casus.ablativus, 'ō')]) {
          add('$ger$e', Analysis(lemmaId: v.id, mood: Mood.gerundium, casus: c));
        }
      }
      if (sup != null) {
        add('${sup}um', Analysis(lemmaId: v.id, mood: Mood.supinum, casus: Casus.accusativus));
        add('${sup}ū', Analysis(lemmaId: v.id, mood: Mood.supinum, casus: Casus.ablativus));
      }
      if (fut != null) periphrastic(Periphrasis.activa, fut);
      if (gdv != null && v.kind != VerbKind.impersonale) periphrastic(Periphrasis.passiva, gdv);
    }

    // Cell-level overrides replace generated cells (irregular templates and
    // attested exceptions) and may introduce cells no rule produced.
    applyCellOverrides();
    if (v.explicitOnly) {
      // Explicit-only verbs may still list nominal stem directives.
      if (pp != null) nominal(Mood.participium, Tense.praesens, Voice.activum, declineParticiple(pp.$1, pp.$2));
      if (ppp != null) nominal(Mood.participium, Tense.perfectum, Voice.passivum, declineBonus(ppp), semantic: depSemantic);
      if (gdv != null) nominal(Mood.gerundivum, null, null, declineBonus(gdv));
    }

    if (!v.explicitOnly) {
      ruleVariants();
      if (p != null && v.hasPerfect && !deponent) syncopatedPerfects(p);
      undusVariants();
    }
    applyShortA();
    semiDeponentAbsences();
    intransitiveAbsences();
    impersonalFilter();
    applyAbsences();
    applyPerfectAsPresent();

    // Deduplicate identical (surface, analysis) pairs.
    final seen = <String>{};
    final unique = <FormEntry>[];
    for (final f in out) {
      final k = '${f.surface}|${f.analysis}';
      if (seen.add(k)) unique.add(f);
    }
    final seenAbsent = <String>{};
    final absentUnique = [for (final a in absent) if (seenAbsent.add('${a.selectorPrefix}|${a.status.key}')) a];
    return Paradigm(v, unique, absentUnique);
  }
}
