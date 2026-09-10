import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:grammaticon/engine/design.dart';

Future<String> readDesign(String path) async => path.endsWith('.gz')
    ? utf8.decode(
        const GZipDecoder().decodeBytes(await File(path).readAsBytes()),
      )
    : File(path).readAsString();
Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    throw ArgumentError(
      'Usage: dart run tool/validate_design.dart DESIGN [--all-questions]',
    );
  }
  final design = await GameDesign.load(args.first, readDesign);
  for (final r in design.resources.values) {
    if (!File(r['path'] as String).existsSync()) {
      throw FormatException('Missing asset ${r['path']}');
    }
  }
  final ids = <String, Set<String>>{};
  var count = 0;
  for (final card in design.cards.values) {
    final bank = await design.questions(card);
    ids[card.address] = bank.map((q) => q.id).toSet();
    count += bank.length;
    final lesson = await design.lesson(card);
    if (lesson.isEmpty) throw FormatException('Missing lesson ${card.address}');
    if (args.contains('--all-questions')) {
      for (final q in bank) {
        await design.materialize(card, q);
      }
    } else {
      await design.materialize(card, bank.first);
    }
    stdout.writeln('${card.address}: ${bank.length}');
  }
  for (final set in objects(design.pedagogy['practiceSets'])) {
    for (final target in objects(set['targets'])) {
      if (target['allQuestions'] != true &&
          !ids[target['card']]!.containsAll(strings(target['questions']))) {
        throw FormatException('Invalid explicit practice target ${set['id']}');
      }
    }
  }
  stdout.writeln(
    'Valid ${design.identity}: ${design.places.length} places, ${design.cards.length} cards, $count authored questions.',
  );
}
