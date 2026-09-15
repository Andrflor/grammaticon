/// Parcours complet de l'oracle : tous les patrons de référence, rapport écrit
/// dans doc/arbor/coverage/. Long (plusieurs minutes) : lancé à la demande.
///
///   ORACLE_FULL=1 flutter test test/arbor/oracle_full_test.dart
@Tags(['full'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/arbor/arbor.dart';
import 'package:grammaticon/arbor/diagnosis.dart';
import 'package:grammaticon/arbor/oracle.dart';
import 'package:grammaticon/linguistics/engine/analyzer.dart';
import 'package:grammaticon/linguistics/engine/conjugator.dart';
import 'package:grammaticon/linguistics/lexicon/forum_lexicon.dart';
import 'package:grammaticon/linguistics/lexicon/verbs.dart';
import 'package:grammaticon/pedagogy/forum/forum_question_source.dart';
import 'package:grammaticon/pedagogy/forum/syntagmata/syntagmata.dart';
import 'package:grammaticon/pedagogy/question_generator.dart';

void main() {
  final full = Platform.environment['ORACLE_FULL'] == '1';
  final analyzer = Analyzer(kVerbs, Conjugator());
  final nominal = buildNominalAnalyzer();
  final arbor = Arbor.standard(analyzer: analyzer, nominal: nominal);
  final verbs = QuestionGenerator(analyzer);
  final forum = ForumQuestionSource(nominal, kSyntagmata);
  final oracle = Oracle(arbor, Diagnostician(arbor, verbs, forum), verbs, forum);

  for (final place in ['forum', 'amphitheatrum']) {
    test('$place : tous les patrons de référence', () {
      if (!full) {
        markTestSkipped('ORACLE_FULL=1 pour le parcours complet');
        return;
      }
      final file = File('reference/patterns/$place.jsonl.gz');
      final lines = utf8.decode(gzip.decode(file.readAsBytesSync())).split('\n').where((l) => l.isNotEmpty);
      final report = oracle.run(lines.map((l) => (jsonDecode(l) as Map).cast<String, Object?>()));
      File('doc/arbor/coverage/$place.md').writeAsStringSync(report.markdown(place));
      // ignore: avoid_print
      print(report.summary(place));
      expect(report.patterns, greaterThan(10000));
    }, timeout: const Timeout(Duration(hours: 2)));
  }
}
