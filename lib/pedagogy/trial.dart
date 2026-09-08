/// Activity-neutral trial model shared by the Amphitheatrum (verbs) and the
/// Forum (nouns): what is asked, at what price, after which prerequisites.
/// The content selected by a trial is described by an activity-specific
/// [ContentFilter]; the catalogues live in `trials.dart` and `noun_trials.dart`.
library;

/// Playable activities of the city. The key is stable and used in save data.
enum Activity {
  amphitheatrum('amphitheatrum', 'Amphitheātrum'),
  forum('forum', 'Forum'),
  theatrum('theatrum', 'Theātrum');

  const Activity(this.key, this.latin);
  final String key;
  final String latin;
  static Activity fromKey(String k) => values.firstWhere((a) => a.key == k);
}

/// A dimension of analysis the player may be asked about.
enum Dimension {
  persona('Quae persōna?'),
  numerus('Quī numerus?'),
  /// Person and number together (asked once the skill is familiar).
  personaNumerus('Quae persōna et quī numerus?'),
  tempus('Quod tempus?'),
  tempusSensus('Quod tempus sēnsū?'),
  modus('Quī modus?'),
  /// Tense and mood answered together ("Subiūnctīvus · imperfectum").
  tempusModus('Quod tempus, quī modus?'),
  vox('Quae vōx?'),
  coniugatio('Quae coniugātiō?'),
  declinatio('Quae dēclīnātiō?'),
  genus('Quod genus?'),
  casus('Quī cāsus?'),
  forma('Quae fōrma?'),
  lemma('Quod verbum?'),
  formaPlena('Quae fōrma plēna?'),
  analysis('Quae analysis?'),
  /// Theatrum: which translation renders the passage faithfully.
  sensus('Quae interpretātiō rēcta est?');

  const Dimension(this.prompt);
  final String prompt;
}

/// Marker for the predicate that selects the forms of a trial. Each activity
/// defines its own (verbs: `FormFilter`, nouns: `NounFilter`, reading:
/// `ReadingFilter`); the generator
/// of that activity is the only code that reads it.
abstract class ContentFilter {
  const ContentFilter();
}

/// Selectable component of a Mixta trial.
class TrialComponent {
  const TrialComponent(this.id, this.name, this.filter, {this.skillId, this.requires});
  final String id;
  final String name;
  final ContentFilter filter;

  /// Skill credited when the answer concerns this component (in addition to the
  /// discrimination skill of the trial).
  final String? skillId;

  /// Trial that must be accessible before this component may be mixed in
  /// (the tense one has learnt before one is asked to recognise it).
  final String? requires;
}

class Trial {
  const Trial({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.skillIds,
    required this.price,
    required this.prerequisites,
    required this.filter,
    required this.dimensions,
    required this.intro,
    required this.examples,
    required this.opponentId,
    this.activity = Activity.amphitheatrum,
    this.components = const [],
    this.questionsToWin = 10,
    this.hearts = 3,
    this.group = 'Indicātīvus',
    this.showDictionaryEntry = false,
    this.fixedChoices = false,
  });

  final String id;
  final String name;
  final String subtitle;

  /// First id is the primary skill shown on cards and used for the victory
  /// bonus; questions may credit finer skills.
  final List<String> skillIds;
  final int price;
  final List<String> prerequisites;
  final ContentFilter filter;
  final List<Dimension> dimensions;

  /// Short introduction in simple Latin.
  final String intro;

  /// Contrasting examples shown in the introduction.
  final List<String> examples;

  /// Opponent sprite / name id within the activity.
  final String opponentId;
  final Activity activity;
  final List<TrialComponent> components;
  final int questionsToWin;
  final int hearts;

  /// Display group in the selection screen.
  final String group;

  /// Introductory trials show the dictionary entry under the form.
  final bool showDictionaryEntry;

  /// Tense and mood questions always offer the whole scale (every tense of
  /// the mood, every mood of the trial) in canonical order, whatever subset
  /// is mixed: recognising is not eliminating, and key 1 stays "Praesēns".
  final bool fixedChoices;

  bool get isMixta => components.isNotEmpty;
  bool get isFree => price == 0;
  String get primarySkill => skillIds.first;
}
