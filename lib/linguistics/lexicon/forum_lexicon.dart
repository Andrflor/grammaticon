/// Assembles the nominal analyzer of the Forum from the shipped lexicons.
library;

import '../engine/declinator.dart';
import '../engine/nominal_analyzer.dart';
import '../engine/noun_analyzer.dart';
import 'adjectives.dart';
import 'adverbs.dart';
import 'nouns.dart';
import 'numerals.dart';
import 'pronouns.dart';

NominalAnalyzer buildNominalAnalyzer({NounAnalyzer? nouns}) => NominalAnalyzer(
      nouns: nouns ?? NounAnalyzer(kNouns, const Declinator()),
      adjectives: kAdjectives,
      pronouns: kPronouns,
      numerals: kNumerals,
      adverbs: kAdverbs,
    );
