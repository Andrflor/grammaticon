/// L'oracle d'équivalence : les banques pré-générées (reference/patterns)
/// doivent être reproductibles par le générateur, chaque distracteur de
/// référence étant soit produit avec un diagnostic, soit rejeté avec une raison.
///
/// Ce test échantillonne les patrons ; `dart run tool/arbor/oracle.dart` fait
/// le parcours complet et écrit doc/arbor/coverage/.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
  final analyzer = Analyzer(kVerbs, Conjugator());
  final nominal = buildNominalAnalyzer();
  final arbor = Arbor.standard(analyzer: analyzer, nominal: nominal);
  final verbs = QuestionGenerator(analyzer);
  final forum = ForumQuestionSource(nominal, kSyntagmata);
  final oracle = Oracle(arbor, Diagnostician(arbor, verbs, forum), verbs, forum);

  for (final place in ['amphitheatrum', 'forum']) {
    test('$place : un échantillon des patrons de référence est reproduit', () {
      final file = File('reference/patterns/$place.jsonl.gz');
      if (!file.existsSync()) {
        markTestSkipped('pas de référence extraite');
        return;
      }
      final lines = utf8.decode(gzip.decode(file.readAsBytesSync())).split('\n').where((l) => l.isNotEmpty).toList();
      final rng = Random(1);
      final sample = <String>[];
      final step = max(1, lines.length ~/ 3000);
      for (var i = rng.nextInt(step); i < lines.length; i += step) {
        sample.add(lines[i]);
      }
      final report = oracle.run(sample.map((l) => (jsonDecode(l) as Map).cast<String, Object?>()));
      File('doc/arbor/coverage/$place-sample.md').writeAsStringSync(report.markdown(place, sampled: true));
      // ignore: avoid_print
      print(report.summary(place));
      expect(report.patterns, greaterThan(1000));
      expect(report.equivalent / report.patterns, greaterThan(0.9), reason: 'patrons équivalents');
    });
  }
}
