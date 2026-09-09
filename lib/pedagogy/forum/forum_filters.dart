/// Content filters of the Forum: which isolated forms and which contextual
/// items (syntagmata) a trial draws.
library;

import '../../linguistics/model/adjective.dart';
import '../../linguistics/model/grammar.dart';
import '../../linguistics/model/nominal.dart';
import '../../linguistics/model/noun.dart';
import '../../linguistics/model/numeral.dart';
import '../../linguistics/model/pronoun.dart';
import '../trial.dart';
import 'syntagma.dart';

/// Predicate over (lexeme, form) pairs. Null fields do not filter.
class NominalFilter {
  const NominalFilter({
    this.classes,
    this.lemmaIds,
    this.excludeLemmaIds = const {},
    this.declensions,
    this.cases,
    this.numbers,
    this.genders,
    this.thirdStems,
    this.degrees = const {Degree.positivus},
    this.adjClasses,
    this.terminations,
    this.tags,
    this.excludeTags = const {},
    this.pronominal,
    this.consonantStem,
    this.erStem,
    this.hasComparison,
    this.pronounKinds,
    this.persons,
    this.indeclinable,
    this.variantKinds = const {VariantKind.norma},
    this.includeProper = false,
    this.onlyLocativeNouns = false,
  });

  final Set<WordClass>? classes;
  final Set<String>? lemmaIds;
  final Set<String> excludeLemmaIds;

  /// Nouns only.
  final Set<Declension>? declensions;

  /// Cases drawn as question surfaces. The locative is drawn only when listed.
  final Set<Casus>? cases;
  final Set<Numerus>? numbers;

  /// Gender of the reading (adjectives, pronouns) or of the noun.
  final Set<Gender>? genders;
  final Set<ThirdStem>? thirdStems;

  /// Degrees drawn (adjectives, adverbs); null: every degree.
  final Set<Degree>? degrees;
  final Set<AdjClass>? adjClasses;

  /// Terminations of third-class adjectives (1, 2, 3).
  final Set<int>? terminations;

  /// Adjective tags, any of which must be present (`possessivum`, `ordinale`).
  final Set<String>? tags;
  final Set<String> excludeTags;
  final bool? pronominal;
  final bool? consonantStem;

  /// Nouns puer/ager/vir and adjectives pulcher/miser: nominative in -er.
  final bool? erStem;
  final bool? hasComparison;
  final Set<PronounKind>? pronounKinds;
  final Set<Person>? persons;
  final bool? indeclinable;
  final Set<VariantKind>? variantKinds;
  final bool includeProper;
  final bool onlyLocativeNouns;

  bool matchesLexeme(Lexeme l) {
    if (lemmaIds != null && !lemmaIds!.contains(l.id)) return false;
    if (excludeLemmaIds.contains(l.id)) return false;
    if (classes != null && !classes!.contains(l.wordClass)) return false;
    if (!includeProper && lemmaIds == null && l.isProper) return false;
    if (l is NounEntry) {
      if (declensions != null && !declensions!.contains(l.declension)) return false;
      if (genders != null && !genders!.contains(l.gender)) return false;
      if (thirdStems != null && !thirdStems!.contains(l.thirdStem)) return false;
      if (erStem != null && l.isErStem != erStem) return false;
      if (onlyLocativeNouns && !l.locative) return false;
      if (tags != null || adjClasses != null || terminations != null || pronominal != null || consonantStem != null || hasComparison != null || pronounKinds != null || persons != null || indeclinable != null) return false;
      return true;
    }
    if (declensions != null || thirdStems != null || onlyLocativeNouns) return false;
    if (l is AdjectiveEntry) {
      if (adjClasses != null && !adjClasses!.contains(l.cls)) return false;
      if (terminations != null && (!l.isThirdClass || !terminations!.contains(l.terminations))) return false;
      if (tags != null && !tags!.any(l.tags.contains)) return false;
      if (excludeTags.any(l.tags.contains)) return false;
      if (pronominal != null && l.pronominal != pronominal) return false;
      if (consonantStem != null && l.consonantStem != consonantStem) return false;
      if (erStem != null && l.isErType != erStem) return false;
      if (hasComparison != null && l.hasComparison != hasComparison) return false;
      if (pronounKinds != null || persons != null || indeclinable != null) return false;
      return true;
    }
    if (l is PronounEntry) {
      if (pronounKinds != null && !pronounKinds!.contains(l.kind)) return false;
      if (persons != null && (l.person == null || !persons!.contains(l.person))) return false;
      if (tags != null || adjClasses != null || terminations != null || pronominal != null || consonantStem != null || erStem != null || hasComparison != null) return false;
      if (indeclinable != null && (l.cells.containsKey('indecl')) != indeclinable) return false;
      return true;
    }
    if (l is NumeralEntry) {
      if (indeclinable != null && l.isIndeclinable != indeclinable) return false;
      if (tags != null || adjClasses != null || terminations != null || pronominal != null || consonantStem != null || erStem != null || hasComparison != null || pronounKinds != null || persons != null) return false;
      return true;
    }
    // adverbs
    if (tags != null || adjClasses != null || terminations != null || pronominal != null || consonantStem != null || erStem != null || hasComparison != null || pronounKinds != null || persons != null || indeclinable != null) return false;
    return true;
  }

  bool matchesForm(Lexeme l, NominalForm f) {
    final a = f.analysis;
    if (a.casus == Casus.locativus && (cases == null || !cases!.contains(Casus.locativus))) return false;
    if (cases != null && (a.casus == null || !cases!.contains(a.casus))) return false;
    if (numbers != null && (a.number == null || !numbers!.contains(a.number))) return false;
    if (genders != null && l is! NounEntry && a.gender != null && !genders!.contains(a.gender)) return false;
    if (degrees != null && !degrees!.contains(a.degree)) return false;
    if (variantKinds != null && !variantKinds!.contains(a.variant)) return false;
    return true;
  }

  bool matches(Lexeme l, NominalForm f) => matchesLexeme(l) && matchesForm(l, f);
}

/// Selects contextual items by tag (trial ids) and difficulty tier.
class SyntagmaFilter {
  const SyntagmaFilter(this.tags, {this.tiers});
  final Set<String> tags;
  final Set<int>? tiers;

  bool matches(Syntagma s) => tags.any(s.tags.contains) && (tiers == null || tiers!.contains(s.tier));
}

/// A Forum trial draws isolated forms (union of [forms]) and/or contextual
/// items ([syntagmata]).
class ForumFilter extends ContentFilter {
  const ForumFilter({this.forms = const [], this.syntagmata});
  final List<NominalFilter> forms;
  final SyntagmaFilter? syntagmata;

  bool get hasForms => forms.isNotEmpty;
  bool get hasSyntagmata => syntagmata != null;

  bool matchesLexeme(Lexeme l) => forms.any((f) => f.matchesLexeme(l));
  bool matchesForm(Lexeme l, NominalForm f) => forms.any((x) => x.matches(l, f));
}
