// The Forum catalogue was rebuilt around the whole nominal system (schema 4).
// A save made under schema 3 must keep every gem spent: each old declension
// card is carried to the card that now covers the same ground, the paradigm
// cells (d.1.acc.sg…) survive untouched because they are still the cells
// credited by noun forms, and the mixed-drill skills that have no successor
// are dropped rather than left dangling.
import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/pedagogy/skills.dart';
import 'package:grammaticon/pedagogy/trials.dart';
import 'package:grammaticon/persistence/save_data.dart';

void main() {
  const codec = SaveCodec();

  test('every old Forum id maps to a card that exists in the same activity', () {
    for (final e in kForumV3TrialIds.entries) {
      final t = Trials.maybe(e.value);
      expect(t, isNotNull, reason: '${e.key} -> ${e.value}');
      expect(t!.activity, Activity.forum, reason: '${e.key} -> ${e.value} must stay in the Forum');
    }
  });

  test('purchases and introductions are carried over; noun cells survive; d.mx.* is dropped', () {
    const v3 = '{"schema":3,"gems":22,'
        '"purchased":["d1-omnes","d2-us-um","d2-omnes","d3-consonantia","deponentia","dmx-omnia"],'
        '"introSeen":["d1-recti","d2-us-um","ind-praes-act"],'
        '"skills":{'
        '"d.1.acc.sg":{"ac":5,"aw":1,"aidc":0,"aidw":0,"corc":0,"est":0.8,"hw":0.8,"recent":[],"lemmas":["rosa","via"],"days":["20260102"],"last":1767312000000},'
        '"d.mx.declinatio":{"ac":3,"aw":0,"aidc":0,"aidw":0,"corc":0,"est":0.7,"hw":0.7,"recent":[],"lemmas":["rex"],"days":["20260102"],"last":1767312000000},'
        '"v.ind.praes.act":{"ac":9,"aw":1,"aidc":0,"aidw":0,"corc":0,"est":0.9,"hw":0.9,"recent":[],"lemmas":["amo"],"days":["20260102"],"last":1767312000000}},'
        '"settings":{"vol":0.5,"snd":true,"rm":false,"cd":350,"wd":2800,"mus":true,"mvol":0.5},'
        '"won":4,"lost":2,"tx":21,"lemmaDaily":{},'
        '"activities":{"amphitheatrum":{"w":3,"l":2},"forum":{"w":1,"l":0}}}';
    final d = codec.decode(v3);
    expect(d.schemaVersion, kSchemaVersion);
    expect(d.gems, 22, reason: 'no gem is refunded or taken');
    // Old declension cards become the cards that cover the same ground.
    expect(d.purchased, containsAll(['dec-2-mf', 'dec-2-n', 'dec-2-er', 'dec-3-cons', 'mx-nominalia']));
    expect(d.purchased, contains('deponentia'), reason: 'Amphitheatrum purchases are untouched');
    expect(d.purchased.where((p) => p.startsWith('d1-') || p.startsWith('d2-') || p.startsWith('dmx-')), isEmpty);
    for (final p in d.purchased) {
      expect(Trials.maybe(p), isNotNull, reason: 'purchased trial $p must exist');
    }
    expect(d.introSeen, containsAll(['dec-1', 'dec-2-n', 'ind-praes-act']));
    // Paradigm cells are still the cells credited by noun forms: kept as they are.
    expect(d.skills['d.1.acc.sg']!.autonomousCorrect, 5);
    expect(d.skills['d.1.acc.sg']!.lemmas, {'rosa', 'via'});
    expect(d.skills['v.ind.praes.act']!.autonomousCorrect, 9);
    // The old mixed-drill skills have no successor in the new tree.
    expect(d.skills.keys.where((k) => k.startsWith('d.mx')), isEmpty);
    for (final k in d.skills.keys) {
      expect(Skills.maybe(k), isNotNull, reason: 'skill $k must exist in the tree');
    }
    expect(d.activityStats['forum']!.won, 1);
  });

  test('a debate interrupted on an old card resumes on its successor, without a stale component selection', () {
    const v3 = '{"schema":3,"gems":10,"purchased":["d1-omnes"],"introSeen":[],"skills":{},'
        '"settings":{"vol":0.5,"snd":true,"rm":false,"cd":350,"wd":2800,"mus":true,"mvol":0.5},'
        '"won":0,"lost":0,"tx":3,"lemmaDaily":{},'
        '"battle":{"t":"dmx-casus","h":2,"e":6,"a":5,"g":12,"s":77,"q":5,"c":["d1","d3"],"ok":4}}';
    final d = codec.decode(v3);
    expect(d.activeBattle!.trialId, 'syn-omnia');
    expect(Trials.maybe(d.activeBattle!.trialId), isNotNull);
    expect(d.activeBattle!.componentIds, isEmpty, reason: 'the old drill mixed declensions, the new card mixes endings');
    expect(d.activeBattle!.hearts, 2);
    expect(d.activeBattle!.seed, 77);
  });

  test('a fight in another activity is left exactly as it was', () {
    const v3 = '{"schema":3,"gems":10,"purchased":[],"introSeen":[],"skills":{},'
        '"settings":{"vol":0.5,"snd":true,"rm":false,"cd":350,"wd":2800,"mus":true,"mvol":0.5},'
        '"won":0,"lost":0,"tx":3,"lemmaDaily":{},'
        '"battle":{"t":"tm-tempora-ind-act","h":3,"e":9,"a":1,"g":8,"s":42,"q":1,"c":["ind.praes.act"],"ok":1}}';
    final d = codec.decode(v3);
    expect(d.activeBattle!.trialId, 'tm-tempora-ind-act');
    expect(d.activeBattle!.componentIds, ['ind.praes.act']);
  });
}
