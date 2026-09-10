import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/engine/design.dart';
import 'package:grammaticon/engine/session.dart';

import 'design_test.dart' show readFile;

void main() {
  late GameDesign design;
  setUpAll(() async {
    design = await GameDesign.load(
      'assets/designs/grammaticon/game.json',
      readFile,
    );
  });
  test('171 cards retain original prices, prerequisites, hearts, targets and skill IDs', () async {
    final baseline = objects(
      jsonDecode(
        await File('test/fixtures/extracted_trial_rules.json').readAsString(),
      ),
    );
    final aliases = object(design.root['migration']['nodeAliases']);
    expect(design.cards.length, baseline.length);
    for (final original in baseline) {
      final card = design.cards[aliases[original['id']]]!;
      expect(card.price, original['price'], reason: card.id);
      expect(
        card.data['encounter']['lives'],
        original['hearts'],
        reason: card.id,
      );
      expect(
        card.data['encounter']['target'],
        original['questionsToWin'],
        reason: card.id,
      );
      expect(card.data['skills'], original['skillIds'], reason: card.id);
      expect(
        objects(card.requirements['all']).map((r) => r['unlocked']).toList(),
        card.price == 0
            ? []
            : strings(original['prerequisites'])
                  .map((p) => aliases[p])
                  .toList(),
        reason: card.id,
      );
    }
  });
  test('legacy profile keeps balance, purchases, observations, mastery and excluded data', () async {
    final original = object(
      jsonDecode(
        await File('test/fixtures/legacy-profile.json').readAsString(),
      ),
    );
    String? saved;
    final s = GameSession(design, original, (raw) async {
      saved = raw;
    });
    expect(s.balance, 83);
    expect(s.state['transaction'], 42);
    expect(
      s.state['purchased'],
      contains(design.root['migration']['nodeAliases']['deponentia']),
    );
    expect(s.skill('v.ind.praes.act')['correct'], 7);
    expect(s.skill('v.ind.praes.act')['recent'].single['assisted'], false);
    expect(s.state['observations'], original['answers']);
    expect(s.state['legacy'], original);
    expect(
      s.state['errors'].keys.single,
      'v|sequor|ind.praes.pass.3.sg|voxSensus|',
    );
    await s.recover();
    expect(s.encounter!['lives'], 2);
    expect(s.encounter!['remaining'], 7);
    expect(s.encounter!['gain'], 11);
    expect(s.encounter!['answered'], 4);
    expect(s.encounter!['phase'], 'paused');
    final again = GameSession(design, object(jsonDecode(saved!)), (_) async {});
    expect(again.state['legacy']['expo'], original['expo']);
    expect(again.state['transaction'], 42);
  });
  test('another design cannot import this profile', () async {
    final d = await GameDesign.load(
      'assets/designs/compass/game.json',
      readFile,
    );
    final old = object(
      jsonDecode(
        await File('test/fixtures/legacy-profile.json').readAsString(),
      ),
    );
    expect(() => GameSession(d, old, (_) async {}), throwsFormatException);
  });
}
