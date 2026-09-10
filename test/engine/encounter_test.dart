import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/engine/design.dart';
import 'package:grammaticon/engine/session.dart';

import 'design_test.dart' show demo, readFile;

void main() {
  test(
    'victory updates the configured reward and completion exactly once',
    () async {
      final d = await demo();
      final s = GameSession(d, {}, (_) async {});
      final card = d.cards['observatory/discovery/durations']!;
      await s.start(card);
      await s.begin();
      for (var i = 0; i < 3; i++) {
        await s.answer(s.question!.accepted.first);
        await s.advance();
      }
      expect(s.encounter!['phase'], 'victory');
      expect(s.balance, 29);
      expect(s.state['completed'][card.address], 1);
      final tx = s.state['transaction'];
      await s.advance();
      expect(s.state['transaction'], tx);
      expect(s.balance, 29);
      await s.finish();
      await s.finish();
      expect(s.balance, 29);
    },
  );
  test(
    'Grammaticon keeps the existing upward-rounded defeat tribute',
    () async {
      final d = await GameDesign.load(
        'assets/designs/grammaticon/game.json',
        readFile,
      );
      final s = GameSession(d, {}, (_) async {});
      s.state['balance'] = 83;
      final card = d.cards.values.firstWhere((c) => c.id == 'ind-praes-act');
      await s.start(card);
      await s.begin();
      for (var i = 0; i < 3; i++) {
        final q = s.question!;
        await s.answer(
          q.choices.firstWhere((c) => !q.accepted.contains(c['id']))['id'],
        );
        await s.advance();
      }
      expect(s.encounter!['phase'], 'defeat');
      expect(s.balance, 58);
      final tx = s.state['transaction'];
      await s.advance();
      expect(s.state['transaction'], tx);
    },
  );
  test('different wrong options retain different explicitly authored diagnoses and destinations', () async {
    final d = await demo();
    final c = d.cards['observatory/discovery/durations']!;
    final q = (await d.questions(c)).firstWhere((q) => q.id == 'hours');
    expect(q.outcome('1')['observed'], ['unit-factor']);
    expect(q.outcome('2')['observed'], ['unit-count-omitted']);
    final s = GameSession(d, {}, (_) async {});
    expect(
      s
          .practiceTargets(q.outcome('1'))
          .any((t) => t['card'] == 'map-room/discovery/scale'),
      false,
    );
    expect(
      s
          .practiceTargets(q.outcome('2'))
          .any((t) => t['card'] == 'map-room/discovery/scale'),
      true,
    );
  });
}
