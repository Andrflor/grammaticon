import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/engine/design.dart';
import 'package:grammaticon/engine/session.dart';

import 'design_test.dart' show readFile;

void main() {
  test('large adaptive bank timing probe', () async {
    final d = await GameDesign.load(
      'assets/designs/grammaticon/game.json',
      readFile,
    );
    final card = d.cards['theatrum/numerorum-sensus/3']!;
    final s = GameSession(d, {}, (_) async {});
    addTearDown(s.dispose);
    s.state['purchased'].add(card.address);
    final watch = Stopwatch()..start();
    await s.start(card);
    print('start: ${watch.elapsedMilliseconds} ms');
    await s.begin();
    for (var i = 0; i < 3; i++) {
      watch.reset();
      await s.answer(s.question!.accepted.first);
      print('answer: ${watch.elapsedMilliseconds} ms');
      watch.reset();
      await s.advance();
      print('advance: ${watch.elapsedMilliseconds} ms');
    }
  });
}
