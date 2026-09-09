/// Contextual items of the Forum (syntagmata): a short phrase with one
/// marked word, and the analysis the context imposes on it.
///
/// Isolated forms cannot carry the nominal system past its syncretisms:
/// `rosae` has three cases. A syntagma gives the two to five words that
/// decide. The marked word is written between braces (`rosae {spīnae}`); the
/// declared analysis is validated against the lexicon by tests (the surface
/// must really have that reading under that lemma) and by the agreement
/// checks of the head word when one is marked between brackets.
library;

import '../../linguistics/model/grammar.dart';
import '../../linguistics/model/nominal.dart';

/// Syntactic function of the marked word (question `functio`).
enum Functio {
  subiectum('subiectum', 'Subiectum'),
  obiectum('obiectum', 'Obiectum (accūsātīvus)'),
  possessor('possessor', 'Possessor / complēmentum (genetīvus)'),
  datum('datum', 'Cui datur (datīvus)'),
  instrumentum('instrumentum', 'Īnstrūmentum / comitātus (ablātīvus)'),
  praedicatum('praedicatum', 'Praedicātīvum (nōminātīvus)'),
  vocatio('vocatio', 'Vocātiō (vocātīvus)'),
  locusUbi('locus-ubi', 'Locus ubi'),
  locusQuo('locus-quo', 'Locus quō'),
  locusUnde('locus-unde', 'Locus unde'),
  tempus('tempus', 'Tempus quandō / quam diū'),
  comparatio('comparatio', 'Comparātiō (ablātīvus)'),
  appositio('appositio', 'Appositiō'),
  attributum('attributum', 'Attribūtum (cum nōmine congruit)'),
  obiectumDativum('obiectum-dat', 'Obiectum verbī cum datīvō'),
  obiectumAblativum('obiectum-abl', 'Obiectum verbī cum ablātīvō'),
  obiectumGenetivum('obiectum-gen', 'Obiectum verbī cum genetīvō'),
  praepositio('praepositio', 'Cum praepositiōne'),
  partitivum('partitivum', 'Genetīvus partītīvus');

  const Functio(this.key, this.latin);
  final String key;
  final String latin;
  static Functio fromKey(String k) => values.firstWhere((e) => e.key == k);
}

/// Construction of the phrase (question `constructio`).
enum Constructio {
  ablativusComparationis('abl-comp', 'Ablātīvus comparātiōnis'),
  quamCasus('quam', 'Quam + cāsus comparātī'),
  inAblativus('in-abl', 'In + ablātīvus (locus ubi)'),
  inAccusativus('in-acc', 'In + accūsātīvus (locus quō)'),
  subAblativus('sub-abl', 'Sub + ablātīvus (locus ubi)'),
  subAccusativus('sub-acc', 'Sub + accūsātīvus (locus quō)'),
  milleAdiectivum('mille-adi', 'Mīlle: adiectīvum indēclīnābile'),
  miliaGenetivus('milia-gen', 'Mīlia: nōmen cum genetīvō'),
  locativus('loc', 'Locātīvus (ubi)'),
  accusativusMotus('acc-motus', 'Accūsātīvus (quō)'),
  ablativusSeparationis('abl-sep', 'Ablātīvus (unde)'),
  ablativusTemporis('abl-temp', 'Ablātīvus temporis (quandō)'),
  accusativusDurationis('acc-dur', 'Accūsātīvus (quam diū)'),
  genetivusPartitivus('gen-part', 'Genetīvus partītīvus');

  const Constructio(this.key, this.latin);
  final String key;
  final String latin;
  static Constructio fromKey(String k) => values.firstWhere((e) => e.key == k);
}

/// To whom a possessive or pronoun refers (question `relatio`).
enum Relatio {
  subiectum('subiectum', 'Ad subiectum (suus, sē)'),
  alius('alius', 'Ad alium (eius, eum)');

  const Relatio(this.key, this.latin);
  final String key;
  final String latin;
  static Relatio fromKey(String k) => values.firstWhere((e) => e.key == k);
}

/// One contextual item.
class Syntagma {
  const Syntagma({
    required this.id,
    required this.text,
    required this.lemmaId,
    required this.casus,
    required this.number,
    required this.tags,
    this.gender,
    this.degree = Degree.positivus,
    this.head,
    this.candidates = const [],
    this.functio,
    this.constructio,
    this.relatio,
    this.tier = 0,
    this.note = '',
  });

  /// Stable id (`syn-ae-01`).
  final String id;

  /// The phrase, the target between braces; the head word (antecedent, noun
  /// the adjective agrees with) may be marked between brackets: `[puer]
  /// {quī} currit`. Candidate distractor nouns of the `quodNomen` question are
  /// written between angle brackets: `{magnam} in <silvā> vīdit [umbram]`.
  final String text;
  final String lemmaId;
  final Casus casus;
  final Numerus number;

  /// Gender of the target reading when the lexeme varies in gender; null for
  /// nouns and personal pronouns.
  final Gender? gender;
  final Degree degree;

  /// Lemma id of the head word marked with brackets, when any.
  final String? head;

  /// Lemma ids of the candidate nouns marked with angle brackets, in text order.
  final List<String> candidates;
  final Functio? functio;
  final Constructio? constructio;
  final Relatio? relatio;

  /// Trial ids this item belongs to (`syn-ae`, `con-1-2`).
  final Set<String> tags;

  /// Difficulty step within a trial (0 adjacent, 1 distant, 2 hard).
  final int tier;

  /// One Latin sentence explaining why the context imposes the reading.
  final String note;

  /// The marked target surface.
  String get target => _between(text, '{', '}');

  /// The head surface, or null.
  String? get headSurface => text.contains('[') ? _between(text, '[', ']') : null;

  /// Candidate surfaces in text order.
  List<String> get candidateSurfaces {
    final out = <String>[];
    final re = RegExp(r'<([^>]+)>');
    for (final m in re.allMatches(text)) {
      out.add(m.group(1)!);
    }
    return out;
  }

  /// The phrase without markers.
  String get plain => text.replaceAll(RegExp(r'[{}\[\]<>]'), '');

  /// The phrase with only the target braces kept (for display).
  String get display => text.replaceAll(RegExp(r'[\[\]<>]'), '');

  /// Words of the phrase (markers removed, punctuation kept on the word).
  List<String> get words => plain.split(' ').where((w) => w.isNotEmpty).toList();

  /// Cell selector `acc.sg` of the target reading.
  String get cellSelector => '${casus.key}.${number.key}';

  static String _between(String s, String open, String close) {
    final i = s.indexOf(open);
    final j = s.indexOf(close, i + 1);
    if (i < 0 || j < 0) throw FormatException('missing $open$close in "$s"');
    return s.substring(i + 1, j);
  }

  @override
  String toString() => '$id: $text';
}

/// Words of a display text split into runs, the target marked.
class SyntagmaRun {
  const SyntagmaRun(this.text, {this.target = false});
  final String text;
  final bool target;

  /// Splits `rosae {spīnae} flōrent` into runs.
  static List<SyntagmaRun> parse(String display) {
    final out = <SyntagmaRun>[];
    final re = RegExp(r'\{([^}]*)\}');
    var last = 0;
    for (final m in re.allMatches(display)) {
      if (m.start > last) out.add(SyntagmaRun(display.substring(last, m.start)));
      out.add(SyntagmaRun(m.group(1)!, target: true));
      last = m.end;
    }
    if (last < display.length) out.add(SyntagmaRun(display.substring(last)));
    return out;
  }
}
