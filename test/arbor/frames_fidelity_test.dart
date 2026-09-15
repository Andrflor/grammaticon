/// Les cadres reproduisent-ils exactement les questions de référence ? Pour
/// chaque cadre, la première question observée dans la banque (échantillon)
/// doit être reproduite mot pour mot par l'instanciation du premier tuple.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/pedagogy/frames/frame_content.dart';

String norm(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

void main() {
  for (final place in ['theatrum', 'templum']) {
    test('$place : chaque cadre reproduit sa question de référence', () {
      final ref = (jsonDecode(File('reference/frames/$place.json').readAsStringSync()) as List).cast<Map>();
      final lib = FrameLibrary.parse(File('assets/arbor/frames/$place.json').readAsStringSync());
      final byId = {for (final f in lib.frames) f.id: f};
      var checked = 0, mismatches = 0;
      final samples = <String>[];
      for (final r in ref) {
        final f = byId[r['id']];
        expect(f, isNotNull, reason: 'cadre absent de l\'asset : ${r['id']}');
        final sample = ((r['samples'] as List).first as Map);
        final expectedContent = norm(sample['content'] as String);
        final expectedChoices = (sample['choices'] as List).cast<String>().map(norm).toList();
        // Le premier tuple aligné est la première instance observée.
        final row = f!.aligned.isEmpty ? const <String>[] : f.aligned.first;
        String fill(String tpl) => tpl.replaceAllMapped(RegExp(r'\{(\d+)\}'), (m) => row[int.parse(m.group(1)!)]);
        final content = norm(f.content.map((s) => fill(s.template)).join(' '));
        final choices = f.choices.map((c) => norm(fill(c.template))).toList();
        checked++;
        if (content != expectedContent || choices.join('|') != expectedChoices.join('|')) {
          mismatches++;
          if (samples.length < 5) samples.add('${f.id}\n    attendu: $expectedContent | ${expectedChoices.join(' / ')}\n    obtenu : $content | ${choices.join(' / ')}');
        }
      }
      // ignore: avoid_print
      print('$place : $checked cadres vérifiés, $mismatches écarts');
      for (final s in samples) {
        // ignore: avoid_print
        print('  $s');
      }
      expect(mismatches, 0);
    });
  }
}
