import 'package:flutter_test/flutter_test.dart';
import 'package:grammaticon/arbor/arbor.dart';
import 'package:grammaticon/arbor/needs.dart';
import 'package:grammaticon/arbor/skill.dart';
import 'package:grammaticon/pedagogy/trial.dart';

void main() {
  final arbor = Arbor.of(const [
    Skill(
      'test.tempus',
      nomen: 'Tempus',
      quid: 'Reconnaître le temps et le mode.',
      stratum: Stratum.elementum,
      probatur: [Dimensio.tempus, Dimensio.tempusModus],
    ),
    Skill(
      'test.group',
      nomen: 'Verba',
      quid: 'Groupe sans question propre.',
      stratum: Stratum.elementum,
    ),
  ]);

  test('les dimensions du graphe se convertissent sans appel dynamique à name', () {
    expect(
      ArborNeeds.dimensionsFor(arbor, 'test.tempus'),
      [Dimension.tempus, Dimension.tempusModus],
    );
  });

  test('un nœud absent ou sans dimension ne produit aucune dimension', () {
    expect(ArborNeeds.dimensionsFor(arbor, 'absent'), isEmpty);
    expect(ArborNeeds.dimensionsFor(arbor, 'test.group'), isEmpty);
  });
}
