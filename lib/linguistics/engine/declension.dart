import '../model/grammar.dart';

/// Case order used throughout the engine.
const List<Casus> kCases = [
  Casus.nominativus,
  Casus.vocativus,
  Casus.accusativus,
  Casus.genetivus,
  Casus.dativus,
  Casus.ablativus,
];

/// One declined cell: surface forms (first primary, others [VariantKind.altera]).
class DeclinedCell {
  const DeclinedCell(this.casus, this.number, this.gender, this.surfaces);
  final Casus casus;
  final Numerus number;
  final Gender gender;
  final List<String> surfaces;
}

/// First/second declension adjective (amātus, -a, -um). A&G §110.
List<DeclinedCell> declineBonus(String stem) {
  const m = {
    Numerus.singularis: ['us', 'e', 'um', 'ī', 'ō', 'ō'],
    Numerus.pluralis: ['ī', 'ī', 'ōs', 'ōrum', 'īs', 'īs'],
  };
  const f = {
    Numerus.singularis: ['a', 'a', 'am', 'ae', 'ae', 'ā'],
    Numerus.pluralis: ['ae', 'ae', 'ās', 'ārum', 'īs', 'īs'],
  };
  const n = {
    Numerus.singularis: ['um', 'um', 'um', 'ī', 'ō', 'ō'],
    Numerus.pluralis: ['a', 'a', 'a', 'ōrum', 'īs', 'īs'],
  };
  final out = <DeclinedCell>[];
  for (final (g, table) in [(Gender.masculinum, m), (Gender.femininum, f), (Gender.neutrum, n)]) {
    for (final num in Numerus.values) {
      for (var i = 0; i < 6; i++) {
        out.add(DeclinedCell(kCases[i], num, g, ['$stem${table[num]![i]}']));
      }
    }
  }
  return out;
}

/// Third declension present participle (amāns, amantis). A&G §118.
/// [nom] is the nominative singular, [stem] the oblique stem.
/// Ablative singular: -e (participial use) with -ī as free alternative.
List<DeclinedCell> declineParticiple(String nom, String stem) {
  final out = <DeclinedCell>[];
  for (final g in Gender.values) {
    final neuter = g == Gender.neutrum;
    // singular
    out.add(DeclinedCell(Casus.nominativus, Numerus.singularis, g, [nom]));
    out.add(DeclinedCell(Casus.vocativus, Numerus.singularis, g, [nom]));
    out.add(DeclinedCell(Casus.accusativus, Numerus.singularis, g, [neuter ? nom : '${stem}em']));
    out.add(DeclinedCell(Casus.genetivus, Numerus.singularis, g, ['${stem}is']));
    out.add(DeclinedCell(Casus.dativus, Numerus.singularis, g, ['${stem}ī']));
    out.add(DeclinedCell(Casus.ablativus, Numerus.singularis, g, ['${stem}e', '${stem}ī']));
    // plural
    final nomPl = neuter ? '${stem}ia' : '${stem}ēs';
    out.add(DeclinedCell(Casus.nominativus, Numerus.pluralis, g, [nomPl]));
    out.add(DeclinedCell(Casus.vocativus, Numerus.pluralis, g, [nomPl]));
    out.add(DeclinedCell(Casus.accusativus, Numerus.pluralis, g, [nomPl]));
    out.add(DeclinedCell(Casus.genetivus, Numerus.pluralis, g, ['${stem}ium']));
    out.add(DeclinedCell(Casus.dativus, Numerus.pluralis, g, ['${stem}ibus']));
    out.add(DeclinedCell(Casus.ablativus, Numerus.pluralis, g, ['${stem}ibus']));
  }
  return out;
}
