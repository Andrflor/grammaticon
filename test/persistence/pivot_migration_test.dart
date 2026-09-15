import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/persistence/save_data.dart';
import 'package:grammaticon/persistence/save_repository.dart';

void main() {
  const codec = SaveCodec();

  test('une sauvegarde du moteur JSON est convertie : solde, achats, leçons vues, statistiques, réglages, ancienne sauvegarde reprise', () {
    final legacy = const SaveData(gems: 5, purchased: {'ind-imperf-act'}, introSeen: {'ind-praes-act'}, lastTransactionId: 40).toJson();
    final pivot = {
      'schemaVersion': 1,
      'designId': 'grammaticon',
      'balance': 731,
      'purchased': ['forum/section-1/dec-2-er', 'amphitheatrum/section-7/deponentia', 'theatrum/loca/a-ablative', 'templum/casuum-electio/3', 'theatrum/loca/o-ablative'],
      'seenLessons': ['forum/section-1/dec-1', 'templum/loca/a-ablative'],
      'statistics': {'amphitheatrum': {'w': 154, 'l': 80, 'won': 1, 'lost': 3}, 'theatrum': {'won': 34, 'lost': 2}},
      'settings': {'sound': true, 'music': false, 'volume': 0.7, 'reducedMotion': true, 'correctDelayMs': 350, 'locale': 'la', 'musicVolume': 0.2},
      'transaction': 12,
      'skills': {'form:v|amo|ind.praes.act.1.sg': {'estimate': 0.9}},
      'legacy': legacy,
    };
    final s = codec.decode(jsonEncode(pivot));
    expect(s.gems, 731);
    expect(s.purchased, containsAll(['ind-imperf-act', 'dec-2-er', 'deponentia', 'th-loca-a-ablative', 'tp-casuum-electio-3']));
    expect(s.introSeen, containsAll(['ind-praes-act', 'dec-1', 'tp-loca-a-ablative']));
    expect(s.activityStats['theatrum']!.won, 34);
    expect(s.activityStats['amphitheatrum']!.won, 1);
    expect(s.battlesWon, 35);
    expect(s.settings.musicOn, isFalse);
    expect(s.settings.volume, 0.7);
    expect(s.settings.reducedMotion, isTrue);
    expect(s.lastTransactionId, 40);
    expect(s.activeBattle, isNull);
    // Ré-encodée, elle est au schéma courant et se relit sans conversion.
    final again = codec.decode(codec.encode(s));
    expect(again.gems, 731);
  });

  test('le dépôt conserve une copie de la sauvegarde JSON avant de la remplacer', () async {
    final store = MemorySaveStore()..raw = jsonEncode({'schemaVersion': 1, 'designId': 'grammaticon', 'balance': 3, 'purchased': <String>[]});
    final repo = SaveRepository(store);
    final s = await repo.load();
    expect(s.gems, 3);
    expect(store.backedUp, isNotNull);
  });

  test('la sauvegarde réelle du joueur, si elle est présente, se convertit sans perte de solde ni d\'achats', () {
    final home = Platform.environment['HOME'];
    final f = File('$home/.local/share/com.example.grammaticon/shared_preferences.json');
    if (!f.existsSync()) {
      markTestSkipped('pas de sauvegarde locale');
      return;
    }
    final prefs = jsonDecode(f.readAsStringSync()) as Map;
    final raw = prefs['flutter.grammaticon.save'] as String?;
    if (raw == null || !raw.contains('"designId"')) {
      markTestSkipped('sauvegarde déjà au format courant');
      return;
    }
    final pivot = jsonDecode(raw) as Map;
    final s = codec.decode(raw);
    expect(s.gems, pivot['balance']);
    final addresses = (pivot['purchased'] as List).cast<String>();
    final expected = addresses.where((a) => a.startsWith('amphitheatrum') || a.startsWith('forum')).map((a) => a.split('/').last);
    expect(s.purchased, containsAll(expected));
    // ignore: avoid_print
    print('sauvegarde réelle : ${s.gems} gemmes, ${s.purchased.length} achats, ${s.skills.length} compétences reprises de l\'ancienne sauvegarde, ${s.battlesWon} victoires');
  });
}
