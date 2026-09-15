/// L2 — Cellae : les cases de paradigme, dérivées des maillons L1.
///
/// Rien n'est écrit case par case. Pour chaque type (classe de conjugaison,
/// type de thème nominal, classe d'adjectif, pronom, numéral), on prend un
/// lexème représentatif, on parcourt son paradigme réel (conjugueur,
/// déclinateur) et l'on compose chaque case à partir des maillons que la forme
/// met en jeu. Les fonctions `verbalComponents` / `nominalComponents` sont
/// aussi celles qui servent au diagnostic : la différence entre deux ensembles
/// de composants est le diagnostic d'un distracteur.
library;

import '../linguistics/engine/analyzer.dart';
import '../linguistics/engine/conjugator.dart' show stripMacrons;
import '../linguistics/engine/nominal_analyzer.dart';
import '../linguistics/model/adjective.dart';
import '../linguistics/model/adverb.dart';
import '../linguistics/model/analysis.dart';
import '../linguistics/model/grammar.dart';
import '../linguistics/model/nominal.dart';
import '../linguistics/model/noun.dart';
import '../linguistics/model/numeral.dart';
import '../linguistics/model/pronoun.dart';
import '../linguistics/model/verb.dart';
import 'skill.dart';

// ---------------------------------------------------------------------------
// Verbal
// ---------------------------------------------------------------------------

/// Représentants des classes régulières.
const kVerbalClassReps = {
  'c1': 'amo',
  'c2': 'moneo',
  'c3': 'rego',
  'c3io': 'capio',
  'c4': 'audio',
};

/// Familles anomales : identifiant de famille → verbe représentatif.
const kAnomalousReps = {
  'sum': 'sum',
  'possum': 'possum',
  'eo': 'eo',
  'fero': 'fero',
  'volo': 'volo',
  'nolo': 'nolo',
  'malo': 'malo',
  'fio': 'fio',
  'do': 'do',
  'edo': 'edo',
};

/// Clé de classe d'un verbe : `c1`…`c4`, ou sa famille anomale.
String verbClassKey(VerbEntry v) {
  if (v.conjugation == Conjugation.anomala) {
    final base = v.compoundOf ?? v.id;
    return kAnomalousReps.containsKey(base) ? base : 'anom';
  }
  return v.conjugation.key;
}

/// Nœud L1 qui porte le thème du présent d'une classe (ou la famille anomale).
String anomalousNode(String fam, {String part = 'praes'}) {
  const praes = {
    'sum': 'v.anom.sum.praes', 'possum': 'v.anom.possum', 'eo': 'v.anom.eo.praes', 'fero': 'v.anom.fero.praes',
    'volo': 'v.anom.volo.praes', 'nolo': 'v.anom.nolo', 'malo': 'v.anom.malo', 'fio': 'v.anom.fio', 'do': 'v.anom.do', 'edo': 'v.anom.edo.praes',
  };
  const perf = {'sum': 'v.anom.sum.perf', 'eo': 'v.anom.eo.perf', 'fero': 'v.anom.fero.perf', 'possum': 'v.anom.possum'};
  const inf = {'sum': 'v.anom.sum.inf', 'eo': 'v.anom.eo.inf', 'edo': 'v.anom.edo.inf'};
  return switch (part) {
    'perf' => perf[fam] ?? 'v.thema.perf',
    'inf' => inf[fam] ?? praes[fam] ?? 'not.coniugatio.anom',
    _ => praes[fam] ?? 'not.coniugatio.anom',
  };
}

String _thema(String cls) => kVerbalClassReps.containsKey(cls) ? 'v.thema.praes.$cls' : anomalousNode(cls);

/// Maillons L1 (et notions L0) mis en jeu par une analyse verbale.
Set<String> verbalComponents(Analysis a, VerbEntry v) {
  final cls = verbClassKey(v);
  final anom = !kVerbalClassReps.containsKey(cls);
  final out = <String>{};
  void n(String id) => out.add(id);

  // Notions.
  if (a.mood.isFinite || a.mood == Mood.infinitivus) n('not.modus.${a.mood.key}');
  if (a.tense != null) n('not.tempus.${a.tense!.key}');
  if (a.voice != null) n('not.vox.${a.voice!.key}');
  if (a.person != null) n('not.persona.${a.person!.key}');
  if (a.number != null) n('not.numerus.${a.number!.key}');
  if (a.gender != null) n('not.genus.${a.gender!.key}');
  if (a.casus != null) n('not.casus.${a.casus!.key}');
  if (a.mood.isNominal || a.mood == Mood.infinitivus) n('not.forma.${a.mood.key}');
  if (a.tense != null) n(a.tense!.isPerfectSystem ? 'not.tempus.systema.perf' : 'not.tempus.systema.praes');
  n(anom ? 'not.coniugatio.anom' : 'not.coniugatio.${cls == 'c3io' ? '3io' : cls.substring(1)}');

  // Genre du verbe.
  if (v.isDeponent) n('v.kind.dep');
  if (v.isSemiDeponent) n('v.kind.semidep');
  if (v.kind == VerbKind.semideponensInversum) n('v.kind.semidep.inv');
  if (v.kind == VerbKind.defectivum) n('v.kind.def');
  if (v.kind == VerbKind.impersonale) n('v.kind.impers');
  if (v.compoundOf != null) n('v.kind.comp');
  if (a.periphrasis != Periphrasis.nulla) {
    n(a.periphrasis == Periphrasis.activa ? 'v.comp.peri.act' : 'v.comp.peri.pass');
    n(a.periphrasis == Periphrasis.activa ? 'v.nom.part.fut.urus' : 'v.nom.gdv.ndus');
    if (a.mood == Mood.infinitivus) {
      n('v.anom.sum.inf');
    } else {
      if (a.mood == Mood.subiunctivus) n('v.anom.sum.subj');
      // Le temps du tour périphrastique se lit sur l'auxiliaire.
      n(switch (a.tense!) {
        Tense.praesens => 'v.anom.sum.praes',
        Tense.imperfectum => 'v.anom.sum.imperf',
        Tense.futurum => 'v.anom.sum.fut',
        Tense.perfectum => 'v.comp.aux.perf',
        Tense.plusquamperfectum => 'v.comp.aux.plusq',
        Tense.futurumExactum => 'v.comp.aux.futex',
      });
      n('v.comp.part.concordia');
      n(_activeEnding(a, oInFirst: false));
    }
    _participleEnding(a, n);
    return out;
  }

  final perfectSystem = a.tense?.isPerfectSystem ?? false;
  final passive = a.voice == Voice.passivum;
  // La classe du verbe se lit aussi sur le parfait (amāv-, monu-, rēx-) : la
  // rattacher au lexème fait partie de l'analyse.
  if (!anom) n(_thema(cls));

  // Thème.
  if (a.mood == Mood.infinitivus && a.composite) {
    // amātum esse / amātūrum esse / amātum īrī
    if (a.tense == Tense.perfectum) {
      n('v.comp.inf.perf.pass');
      n('v.nom.part.perf.tus');
      n(_supThema(v));
      n('v.anom.sum.inf');
    } else if (a.tense == Tense.futurum && !passive) {
      n('v.comp.inf.fut.act');
      n('v.nom.part.fut.urus');
      n(_supThema(v));
      n('v.anom.sum.inf');
    } else {
      n('v.comp.inf.fut.pass.iri');
      n('v.nom.sup.um');
      n(_supThema(v));
      n('v.anom.eo.inf');
    }
    return out;
  }
  if (a.composite) {
    // participe parfait + sum
    if (cls == 'fio') n('v.anom.fio');
    n('v.comp.perf.pass');
    n('v.nom.part.perf.tus');
    n(_supThema(v));
    n('v.comp.part.concordia');
    n('v.comp.aux.tempus');
    n(switch (a.tense!) {
      Tense.perfectum => 'v.comp.aux.perf',
      Tense.plusquamperfectum => 'v.comp.aux.plusq',
      Tense.futurumExactum => 'v.comp.aux.futex',
      _ => 'v.comp.aux.perf',
    });
    n(_auxNode(a.mood, a.tense!));
    if (a.mood == Mood.imperativus) n('v.anom.sum.imp');
    n(_activeEnding(a, oInFirst: false));
    _participleEnding(a, n);
    if (a.variant == VariantKind.fuiAuxiliare) n('v.alt.fui');
    if (a.variant == VariantKind.forem) n('v.alt.forem');
    return out;
  }

  if (a.mood.isNominal) {
    switch (a.mood) {
      case Mood.participium:
        if (a.tense == Tense.praesens) {
          n('v.nom.part.praes.nt');
          n(_thema(cls));
          n('adj.classis.3.una');
          _thirdEnding(a, n);
        } else if (a.tense == Tense.perfectum) {
          n('v.nom.part.perf.tus');
          n(_supThema(v));
          n('adj.classis.12');
          _participleEnding(a, n);
          if (v.isDeponent) n('v.kind.dep.part');
        } else {
          n('v.nom.part.fut.urus');
          n(_supThema(v));
          n('adj.classis.12');
          _participleEnding(a, n);
        }
      case Mood.gerundivum:
        n('v.nom.gdv.ndus');
        n(_thema(cls));
        n('adj.classis.12');
        _participleEnding(a, n);
        if (a.variant == VariantKind.undus) n('v.alt.undus');
      case Mood.gerundium:
        n('v.nom.ger.nd');
        n(_thema(cls));
        n(switch (a.casus) { Casus.genetivus => 'n.des.i_long', Casus.accusativus => 'n.des.um', _ => 'n.des.o_long' });
      case Mood.supinum:
        n(a.casus == Casus.ablativus ? 'v.nom.sup.u' : 'v.nom.sup.um');
        n(_supThema(v));
      default:
        break;
    }
    return out;
  }

  if (a.mood == Mood.infinitivus) {
    if (a.tense == Tense.perfectum) {
      n('v.sig.inf.perf.act.isse');
      n(_perfThema(v));
      if (a.variant == VariantKind.syncopa) n('v.alt.syncopa');
    } else if (anom) {
      n(anomalousNode(cls, part: 'inf'));
      if (passive) {
        n(cls == 'fero' ? 'v.sig.inf.praes.pass.i' : 'v.sig.inf.praes.pass.ri');
      } else if (cls == 'fero' || cls == 'do') {
        n('v.sig.inf.praes.act.re');
      }
    } else if (passive) {
      n(cls == 'c3' || cls == 'c3io' ? 'v.sig.inf.praes.pass.i' : 'v.sig.inf.praes.pass.ri');
      n(_thema(cls));
    } else {
      n('v.sig.inf.praes.act.re');
      n(_thema(cls));
    }
    return out;
  }

  // Formes finies.
  if (perfectSystem) {
    n(_perfThema(v));
    switch ((a.mood, a.tense!)) {
      case (Mood.indicativus, Tense.perfectum):
        n('v.sig.perf');
        n('v.des.perf.${a.person!.key}.${a.number!.key}.${_perfEnding(a)}');
        if (a.variant == VariantKind.perfectumEre) n('v.alt.ere');
      case (Mood.indicativus, Tense.plusquamperfectum):
        n('v.sig.plusq.era');
        n(_activeEnding(a, oInFirst: false));
      case (Mood.indicativus, Tense.futurumExactum):
        n('v.sig.futex.eri');
        n(_activeEnding(a, oInFirst: true));
      case (Mood.subiunctivus, Tense.perfectum):
        n('v.sig.subj.perf.eri');
        n(_activeEnding(a, oInFirst: false));
      case (Mood.subiunctivus, Tense.plusquamperfectum):
        n('v.sig.subj.plusq.isse');
        n(_activeEnding(a, oInFirst: false));
      default:
        break;
    }
    if (a.variant == VariantKind.syncopa) n('v.alt.syncopa');
    if (v.perfectHasPresentSense) n('v.kind.def');
    return out;
  }

  // Système du présent, formes finies.
  if (anom) {
    n(_anomalousFinite(cls, a));
    if (cls == 'possum') n('v.anom.possum');
    // Les anomaux gardent les marques régulières là où elles le sont : ferēbat,
    // volēbam, fīēbat, dabam (-bā-) ; feram, volam, fīam, edam (-a-/-ē-) ; dabō
    // (-b-) ; feram, fīam, edam au subjonctif (-ā-), dem (-ē-) ; -rē- partout.
    switch ((a.mood, a.tense)) {
      case (Mood.indicativus, Tense.imperfectum) when cls != 'sum' && cls != 'possum':
        n('v.sig.imperf.ba');
      case (Mood.indicativus, Tense.futurum) when const {'fero', 'volo', 'nolo', 'malo', 'fio', 'edo'}.contains(cls):
        n('v.sig.fut.a_e');
      case (Mood.indicativus, Tense.futurum) when cls == 'do':
        n('v.sig.fut.b');
      case (Mood.indicativus, Tense.praesens):
        n('v.sig.praes');
      case (Mood.subiunctivus, Tense.praesens) when const {'fero', 'fio', 'edo'}.contains(cls):
        n('v.sig.subj.praes.a');
      case (Mood.subiunctivus, Tense.praesens) when cls == 'do':
        n('v.sig.subj.praes.e');
      case (Mood.subiunctivus, Tense.imperfectum):
        n('v.sig.subj.imperf.re');
      default:
        break;
    }
    if (a.mood == Mood.imperativus) n(a.tense == Tense.futurum ? 'v.sig.imp.fut.to' : 'v.sig.imp.praes');
  } else {
    n(_thema(cls));
    n(_vocalis(cls));
    switch ((a.mood, a.tense!)) {
      case (Mood.indicativus, Tense.praesens):
        n('v.sig.praes');
      case (Mood.indicativus, Tense.imperfectum):
        n('v.sig.imperf.ba');
        if (cls == 'c3io' || cls == 'c4') n('v.sig.imperf.ie');
      case (Mood.indicativus, Tense.futurum):
        n(cls == 'c1' || cls == 'c2' ? 'v.sig.fut.b' : 'v.sig.fut.a_e');
      case (Mood.subiunctivus, Tense.praesens):
        n(cls == 'c1' ? 'v.sig.subj.praes.e' : 'v.sig.subj.praes.a');
      case (Mood.subiunctivus, Tense.imperfectum):
        n('v.sig.subj.imperf.re');
      case (Mood.imperativus, Tense.praesens):
        n('v.sig.imp.praes');
      case (Mood.imperativus, Tense.futurum):
        n('v.sig.imp.fut.to');
      default:
        break;
    }
  }
  if (a.mood == Mood.imperativus) {
    if (a.tense == Tense.praesens) {
      n(passive
          ? (a.number == Numerus.singularis ? 'v.des.imp.pass.2.sg.re' : 'v.des.imp.pass.2.pl.mini')
          : (a.number == Numerus.singularis ? 'v.des.imp.2.sg' : 'v.des.imp.2.pl.te'));
    } else {
      final sg = a.number == Numerus.singularis;
      n(passive
          ? (sg ? 'v.des.imp.fut.pass.2.sg.tor' : 'v.des.imp.fut.pass.3.pl.ntor')
          : (sg ? (a.person == Person.tertia ? 'v.des.imp.fut.3.sg.to' : 'v.des.imp.fut.2.sg.to') : (a.person == Person.tertia ? 'v.des.imp.fut.3.pl.nto' : 'v.des.imp.fut.2.pl.tote')));
    }
    if (v.isDeponent) n('v.kind.dep');
    return out;
  }
  if (passive) {
    n(_passiveEnding(a));
    if (a.variant == VariantKind.passivumRe || a.variant == VariantKind.rara) n('v.alt.re');
  } else {
    // -ō à la 1re sg du présent (sauf sum, possum : -m) et des futurs en -b-
    // (amābō, dabō, ībō, erō, poterō) ; -m partout ailleurs.
    final oFirst = a.mood == Mood.indicativus &&
        ((a.tense == Tense.praesens && cls != 'sum' && cls != 'possum') ||
            (a.tense == Tense.futurum && const {'c1', 'c2', 'do', 'eo', 'sum', 'possum'}.contains(cls)));
    n(_activeEnding(a, oInFirst: oFirst));
  }
  if (v.kind == VerbKind.impersonale) n('v.kind.impers');
  return out;
}

/// Désinence d'un participe de 1re/2e classe (ou d'un composé) selon cas,
/// nombre et genre : la même connaissance que pour bonus, -a, -um.
void _participleEnding(Analysis a, void Function(String) n) {
  final g = a.gender, num = a.number, c = a.casus ?? Casus.nominativus;
  if (g == null || num == null) return;
  final sg = num == Numerus.singularis;
  final key = switch ((g, c)) {
    (Gender.masculinum, Casus.nominativus) => sg ? 'us' : 'i_long',
    (Gender.masculinum, Casus.vocativus) => sg ? 'e' : 'i_long',
    (Gender.masculinum, Casus.accusativus) => sg ? 'um' : 'os',
    (Gender.femininum, Casus.nominativus || Casus.vocativus) => sg ? 'a' : 'ae',
    (Gender.femininum, Casus.accusativus) => sg ? 'am' : 'as',
    (Gender.neutrum, Casus.nominativus || Casus.vocativus || Casus.accusativus) => sg ? 'um' : 'a',
    (Gender.femininum, Casus.genetivus) => sg ? 'ae' : 'arum',
    (_, Casus.genetivus) => sg ? 'i_long' : 'orum',
    (Gender.femininum, Casus.dativus) => sg ? 'ae' : 'is_long',
    (Gender.femininum, Casus.ablativus) => sg ? 'a_long' : 'is_long',
    (_, Casus.dativus || Casus.ablativus) => sg ? 'o_long' : 'is_long',
    _ => null,
  };
  if (key != null) n('n.des.$key');
}

/// Désinence d'un participe présent (3e classe, thème en -i).
void _thirdEnding(Analysis a, void Function(String) n) {
  final num = a.number, c = a.casus ?? Casus.nominativus, neuter = a.gender == Gender.neutrum;
  if (num == null) return;
  final sg = num == Numerus.singularis;
  final key = switch (c) {
    Casus.nominativus || Casus.vocativus => sg ? 'nom3' : (neuter ? 'ia' : 'es_long'),
    Casus.accusativus => sg ? (neuter ? 'nom3' : 'em') : (neuter ? 'ia' : 'es_long'),
    Casus.genetivus => sg ? 'is' : 'ium',
    Casus.dativus => sg ? 'i_long' : 'ibus',
    Casus.ablativus => sg ? 'e' : 'ibus',
    _ => null,
  };
  if (key != null) n('n.des.$key');
}

String _supThema(VerbEntry v) {
  final s = v.supineStem ?? v.deponentParticipleStem ?? '';
  return s.endsWith('s') ? 'v.thema.sup.s' : 'v.thema.sup.t';
}

String _perfThema(VerbEntry v) {
  final p = v.perfectStem ?? '';
  final base = stripMacrons(v.presentStem);
  final pp = stripMacrons(p);
  if (v.conjugation == Conjugation.anomala) {
    return anomalousNode(verbClassKey(v), part: 'perf');
  }
  if (p.endsWith('v') || p.endsWith('āv') || p.endsWith('īv') || p.endsWith('ēv')) return 'v.thema.perf.v';
  if (p.endsWith('u') && !p.endsWith('qu')) return 'v.thema.perf.u';
  if (p.endsWith('s') || p.endsWith('x') || p.endsWith('ss')) return 'v.thema.perf.s';
  if (pp.length >= 2 && base.isNotEmpty && pp.length > base.length && pp.substring(0, 1) == base.substring(0, 1) && pp.length >= 3 && pp[2] == pp[0] && pp != base) {
    return 'v.thema.perf.redup';
  }
  if (pp == base) return p == v.presentStem ? 'v.thema.perf.nud' : 'v.thema.perf.long';
  return 'v.thema.perf';
}

String _vocalis(String cls) => switch (cls) {
  'c1' => 'v.voc.a',
  'c2' => 'v.voc.e',
  'c3' => 'v.voc.i_u',
  'c3io' => 'v.voc.io',
  _ => 'v.voc.i_long',
};

String _auxNode(Mood m, Tense t) {
  if (m == Mood.subiunctivus) return 'v.anom.sum.subj';
  return switch (t) {
    Tense.perfectum => 'v.anom.sum.praes',
    Tense.plusquamperfectum => 'v.anom.sum.imperf',
    Tense.futurumExactum => 'v.anom.sum.fut',
    Tense.praesens => 'v.anom.sum.praes',
    Tense.imperfectum => 'v.anom.sum.imperf',
    Tense.futurum => 'v.anom.sum.fut',
  };
}

String _activeEnding(Analysis a, {required bool oInFirst}) {
  final p = a.person!.key, n = a.number!.key;
  const suffix = {'2.sg': 's', '3.sg': 't', '1.pl': 'mus', '2.pl': 'tis', '3.pl': 'nt'};
  if (p == '1' && n == 'sg') return oInFirst ? 'v.des.act.1.sg.o' : 'v.des.act.1.sg.m';
  return 'v.des.act.$p.$n.${suffix['$p.$n']}';
}

String _passiveEnding(Analysis a) {
  const suffix = {'1.sg': 'r', '2.sg': 'ris', '3.sg': 'tur', '1.pl': 'mur', '2.pl': 'mini', '3.pl': 'ntur'};
  final k = '${a.person!.key}.${a.number!.key}';
  return 'v.des.pass.$k.${suffix[k]}';
}

String _perfEnding(Analysis a) {
  const suffix = {'1.sg': 'i', '2.sg': 'isti', '3.sg': 'it', '1.pl': 'imus', '2.pl': 'istis', '3.pl': 'erunt'};
  return suffix['${a.person!.key}.${a.number!.key}']!;
}

String _anomalousFinite(String fam, Analysis a) {
  switch (fam) {
    case 'sum':
      if (a.mood == Mood.subiunctivus) return 'v.anom.sum.subj';
      if (a.mood == Mood.imperativus) return 'v.anom.sum.imp';
      return switch (a.tense!) {
        Tense.praesens => 'v.anom.sum.praes',
        Tense.imperfectum => 'v.anom.sum.imperf',
        _ => 'v.anom.sum.fut',
      };
    case 'possum':
      // pot- + sum : les temps se lisent comme ceux de sum.
      if (a.mood == Mood.subiunctivus) return 'v.anom.sum.subj';
      if (a.tense == Tense.praesens) return 'v.anom.possum.praes';
      return a.tense == Tense.imperfectum ? 'v.anom.sum.imperf' : 'v.anom.sum.fut';
    case 'eo':
      if (a.mood == Mood.subiunctivus) return 'v.anom.eo.subj';
      if (a.tense == Tense.praesens || a.mood == Mood.imperativus) return 'v.anom.eo.praes';
      return a.tense == Tense.imperfectum ? 'v.anom.eo.imperf' : 'v.anom.eo.fut';
    case 'fero':
      return 'v.anom.fero.praes';
    case 'volo':
      return a.mood == Mood.subiunctivus ? 'v.anom.volo.subj' : 'v.anom.volo.praes';
    case 'nolo':
      return a.mood == Mood.subiunctivus ? 'v.anom.volo.subj' : 'v.anom.nolo';
    case 'malo':
      return a.mood == Mood.subiunctivus ? 'v.anom.volo.subj' : 'v.anom.malo';
    case 'fio':
      return 'v.anom.fio';
    case 'do':
      return 'v.anom.do';
    case 'edo':
      return 'v.anom.edo.praes';
  }
  return 'not.coniugatio.anom';
}

/// Cases verbales dérivées : une par (classe, sélecteur) rencontrée dans le
/// paradigme du représentant. Les variantes ne créent pas de case.
List<Skill> deriveVerbalCellae(Analyzer analyzer, {List<String> problems = const []}) {
  final out = <Skill>[];
  final reps = {...kVerbalClassReps, ...kAnomalousReps};
  for (final e in reps.entries) {
    final cls = e.key;
    final v = analyzer.verb(e.value);
    final p = analyzer.paradigmOf(v.id);
    final seen = <String>{};
    for (final f in p.forms) {
      final a = f.analysis;
      if (!a.isPrimary) continue;
      if ((a.mood == Mood.participium || a.mood == Mood.gerundivum) && !(a.casus == Casus.nominativus && a.number == Numerus.singularis && a.gender == Gender.masculinum)) continue;
      if (a.composite && a.gender != null && a.gender != Gender.masculinum) continue;
      final sel = a.selector;
      if (!seen.add(sel)) continue;
      final comps = verbalComponents(a, v);
      out.add(Skill(
        'cella.v.$cls.$sel',
        nomen: '${a.describe()} (${kVerbalClassReps.containsKey(cls) ? 'coniugātiō ${cls.substring(1)}' : v.lemma})',
        quid: 'Reconnaître et produire la case ${a.describe()} d\'un verbe comme ${v.lemma} (${f.surface}).',
        stratum: Stratum.cella,
        pars: comps.toList()..sort(),
        notiones: comps.where((c) => c.startsWith('not.')).toList(),
        probatur: const [Dimensio.analysis, Dimensio.formaPlena],
        visibilis: false,
        parens: 'v',
      ));
    }
  }
  return out;
}

// ---------------------------------------------------------------------------
// Nominal
// ---------------------------------------------------------------------------

/// Type de thème d'un nom, clé des cases et du maillon `n.thema.<type>`.
String nounStemType(NounEntry n) {
  switch (n.declension) {
    case Declension.prima:
      return 'd1';
    case Declension.secunda:
      if (n.isNeuter) return 'd2.n';
      if (n.isIusStem) return 'd2.ius';
      if (n.isErStem) return 'd2.er';
      return 'd2.us';
    case Declension.tertia:
      if (n.isNeuter) return n.thirdStem == ThirdStem.neutrumI ? 'd3.ni' : 'd3.n';
      return switch (n.thirdStem) {
        ThirdStem.consonans => 'd3.cons',
        ThirdStem.vocalisI => 'd3.i',
        ThirdStem.vocalisIPura => 'd3.ipura',
        ThirdStem.neutrumI => 'd3.ni',
      };
    case Declension.quarta:
      return n.isNeuter ? 'd4.n' : 'd4.m';
    case Declension.quinta:
      return 'd5';
  }
}

const kNounTypeReps = {
  'd1': 'rosa',
  'd2.us': 'servus',
  'd2.er': 'puer',
  'd2.ius': 'filius',
  'd2.n': 'bellum',
  'd3.cons': 'rex',
  'd3.i': 'civis',
  'd3.ipura': 'turris',
  'd3.n': 'corpus',
  'd3.ni': 'mare',
  'd4.m': 'manus',
  'd4.n': 'cornu',
  'd5': 'res',
};

const _endingKeys = {
  'a': 'a', 'ā': 'a_long', 'ae': 'ae', 'am': 'am', 'ārum': 'arum', 'ās': 'as', 'īs': 'is_long',
  'us': 'us', 'ūs': 'us_long', 'e': 'e', 'ē': 'e_long', 'um': 'um', 'ī': 'i_long', 'ō': 'o_long',
  'ōrum': 'orum', 'ōs': 'os', 'is': 'is', 'em': 'em', 'im': 'im', 'ēs': 'es_long', 'ium': 'ium',
  'ibus': 'ibus', 'ia': 'ia', 'ū': 'u_long', 'uī': 'ui', 'ua': 'ua', 'uum': 'uum', 'ēī': 'ei', 'eī': 'ei',
  'ērum': 'erum', 'ēbus': 'ebus', 'er': 'er', 'ubus': 'ibus', 'ir': 'er',
};

/// Désinence de surface d'une forme nominale par rapport à son thème, ou null.
String? _ending(String surface, String stem) {
  if (surface.startsWith(stem)) return surface.substring(stem.length);
  // Thème à voyelle finale brève allongée dans la forme : manu- → manūs, fīli- → fīlī.
  const long = {'a': 'ā', 'e': 'ē', 'i': 'ī', 'o': 'ō', 'u': 'ū'};
  final last = stem.isEmpty ? '' : stem[stem.length - 1];
  if (long.containsKey(last) && surface.startsWith('${stem.substring(0, stem.length - 1)}${long[last]}')) return surface.substring(stem.length - 1);
  return null;
}

/// Maillon de désinence d'une forme, à partir de sa surface et de son thème.
String? nominalEndingNode(String surface, String stem, {required bool isLemma, required Declension declension, required bool neuter}) {
  final e = _ending(surface, stem);
  if (e == null || e.isEmpty || !_endingKeys.containsKey(e)) {
    if (isLemma) {
      if (declension == Declension.tertia) return 'n.des.nom3';
      if (surface.endsWith('er') || surface.endsWith('ir')) return 'n.des.er';
    }
    return null;
  }
  return 'n.des.${_endingKeys[e]}';
}

/// Maillons mis en jeu par une analyse nominale (nom, adjectif, pronom, numéral).
Set<String> nominalComponents(NominalForm f, Lexeme lexeme) {
  final a = f.analysis;
  final out = <String>{};
  void n(String id) => out.add(id);
  if (a.casus != null) n('not.casus.${a.casus!.key}');
  if (a.number != null) n('not.numerus.${a.number!.key}');
  if (a.gender != null) n('not.genus.${a.gender!.key}');
  if (a.degree != Degree.positivus) n('not.gradus.${a.degree.key}');
  if (a.person != null) n('not.persona.${a.person!.key}');
  if (a.gender == Gender.neutrum && (a.casus == Casus.nominativus || a.casus == Casus.accusativus || a.casus == Casus.vocativus)) n('n.des.neutrum');

  if (lexeme is NounEntry) {
    final type = nounStemType(lexeme);
    n('n.thema.$type');
    n('not.declinatio.${lexeme.declension.ordinal}');
    n('n.genus.d${lexeme.declension.ordinal}');
    if (a.casus == Casus.locativus) {
      n('n.thema.proprium');
      n('not.casus.loc');
    }
    final d = nominalEndingNode(f.surface, lexeme.stem, isLemma: f.surface == lexeme.lemma, declension: lexeme.declension, neuter: lexeme.isNeuter);
    if (d != null) n(d);
    if (d == 'n.des.nom3') n('n.alt.nom3');
    if (type == 'd2.er' && f.surface != lexeme.lemma && stripMacrons(lexeme.stem) != stripMacrons(lexeme.lemma)) n('n.alt.syncopa');
    return out;
  }
  if (lexeme is AdjectiveEntry) {
    final cls = adjectiveClassKey(lexeme);
    // La classe du lexème se sait à tous les degrés (bonus → melior reste un
    // adjectif de 1re/2e classe par son entrée de dictionnaire).
    n('adj.classis.$cls');
    if (lexeme.pronominal) n('adj.classis.pron');
    if (a.degree == Degree.comparativus) {
      n('adj.gradus.comp.ior');
      if (a.casus != null) {
        n('adj.gradus.comp.decl');
        n('adj.classis.3.cons');
      }
      if (lexeme.comparison == ComparisonKind.irregularis) n('adj.gradus.irr');
    } else if (a.degree == Degree.superlativus) {
      n(f.surface.contains('errim') ? 'adj.gradus.sup.errimus' : f.surface.contains('illim') ? 'adj.gradus.sup.illimus' : 'adj.gradus.sup.issimus');
      if (lexeme.comparison == ComparisonKind.irregularis) n('adj.gradus.irr');
      if (!cls.startsWith('12')) n('adj.classis.12');
    }
    if (a.casus != null) {
      String? d;
      if (a.degree == Degree.positivus) {
        final stem = lexeme.stem;
        d = nominalEndingNode(f.surface, stem, isLemma: f.surface == lexeme.lemma, declension: cls.startsWith('12') ? Declension.secunda : Declension.tertia, neuter: a.gender == Gender.neutrum);
        if (d == null && cls.startsWith('3')) d = _stripEnding(f.surface, const ['ibus', 'ium', 'ēs', 'is', 'em', 'ia', 'ī', 'e', 'a']) ?? 'n.des.nom3';
      } else if (a.degree == Degree.comparativus) {
        d = _stripEnding(f.surface, const ['ibus', 'um', 'ēs', 'is', 'em', 'ī', 'e', 'a']);
        if (f.surface.endsWith('ior')) d = 'n.des.nom3';
      } else {
        d = _stripEnding(f.surface, const ['ōrum', 'ārum', 'ībus', 'īs', 'ōs', 'ās', 'ae', 'am', 'um', 'us', 'ā', 'ī', 'ō', 'a', 'e']);
      }
      if (d != null) n(d);
      if (lexeme.pronominal && (a.casus == Casus.genetivus && a.number == Numerus.singularis)) n('pron.des.ius');
      if (lexeme.pronominal && (a.casus == Casus.dativus && a.number == Numerus.singularis)) n('pron.des.i');
    }
    return out;
  }
  if (lexeme is PronounEntry) {
    n(pronounNode(lexeme));
    final s = f.surface;
    // La désinence du pronom, quand elle est celle des noms (quem, quōs, eā,
    // quibus…) ; les formes propres (huius, huic, id) ont leurs nœuds ci-dessous.
    final bare = lexeme.id == 'hic' && s.endsWith('c') ? s.substring(0, s.length - 1) : s;
    if (!(a.casus == Casus.genetivus && a.number == Numerus.singularis) && !(a.casus == Casus.dativus && a.number == Numerus.singularis)) {
      final d = _stripEnding(bare, const ['ārum', 'ōrum', 'ibus', 'īs', 'ōs', 'ās', 'ae', 'am', 'um', 'em', 'ā', 'ī', 'ō', 'a']);
      if (d != null) n(d);
    }
    if (a.casus == Casus.genetivus && a.number == Numerus.singularis && (s.endsWith('īus') || s.endsWith('ius'))) n('pron.des.ius');
    if (a.casus == Casus.dativus && a.number == Numerus.singularis && (s.endsWith('ī') || s.endsWith('ic') || s.endsWith('uic'))) n('pron.des.i');
    if (a.gender == Gender.neutrum && a.number == Numerus.singularis && (a.casus == Casus.nominativus || a.casus == Casus.accusativus) && s.endsWith('d')) n('pron.des.d');
    if (lexeme.id == 'hic' && s.endsWith('c')) n('pron.des.c');
    if (lexeme.id == 'idem') n('pron.des.dem');
    return out;
  }
  if (lexeme is NumeralEntry) {
    n(numeralNode(lexeme));
    return out;
  }
  if (lexeme is AdverbEntry) {
    final s = f.surface;
    if (a.degree == Degree.comparativus) {
      n('adj.adv.comp.ius');
    } else if (a.degree == Degree.superlativus) {
      n('adj.adv.sup.issime');
    } else if (s.endsWith('iter') || s.endsWith('nter')) {
      n('adj.adv.iter');
    } else if (s.endsWith('ē')) {
      n('adj.adv.e');
    } else {
      n('adj.adv.o');
    }
    return out;
  }
  return out;
}

/// Clé de classe d'un adjectif : `12`, `12.er`, `3.una`, `3.duo`, `3.tria`, `3.cons`.
String adjectiveClassKey(AdjectiveEntry a) {
  if (a.cls == AdjClass.primaSecunda) return a.lemma.endsWith('er') || a.lemma.endsWith('ur') ? '12.er' : '12';
  if (a.consonantStem) return '3.cons';
  return switch (a.terminations) { 1 => '3.una', 2 => '3.duo', _ => '3.tria' };
}

/// Nœud de désinence obtenu en retirant la plus longue terminaison connue.
String? _stripEnding(String surface, List<String> endings) {
  for (final e in endings) {
    if (surface.endsWith(e) && surface.length > e.length && _endingKeys.containsKey(e)) return 'n.des.${_endingKeys[e]}';
  }
  return null;
}

/// Maillon L1 qui porte un pronom du lexique.
String pronounNode(PronounEntry p) {
  const direct = {'ego', 'tu', 'nos', 'vos', 'se', 'is', 'hic', 'ille', 'iste', 'ipse', 'idem', 'qui', 'quis'};
  if (direct.contains(p.id)) return 'pron.${p.id}';
  if (p.kind == PronounKind.correlativum) return 'pron.corr';
  if (p.id.startsWith('qui') && (p.id.endsWith('cumque') || p.id == 'quisquis')) return 'pron.rel.indef';
  if ({'nemo', 'nihil', 'nullus'}.contains(p.id)) return 'pron.indef.nemo';
  if ({'quisque', 'quisquam', 'quidam'}.contains(p.id)) return 'pron.indef.quisque';
  if ({'meus', 'tuus', 'suus', 'noster', 'vester'}.contains(p.id)) return 'pron.poss';
  if (p.kind == PronounKind.indefinitum) return 'pron.indef';
  if (p.kind == PronounKind.personale) return 'pron.ego';
  return 'pron.indef';
}

/// Maillon L1 qui porte un numéral du lexique.
String numeralNode(NumeralEntry n) {
  if (n.id == 'unus') return 'num.unus';
  if (n.id == 'duo' || n.id == 'ambo') return 'num.duo';
  if (n.id == 'tres') return 'num.tres';
  if (n.id.startsWith('mille') || n.id == 'milia') return 'num.mille';
  if (n.kind == NumeralKind.substantivum) return 'num.mille';
  return n.isIndeclinable ? 'num.card.indecl' : 'num.card.centeni';
}

/// Cases nominales dérivées pour les noms (par type de thème), les adjectifs
/// (par classe et degré), les pronoms et les numéraux déclinables.
List<Skill> deriveNominalCellae(NominalAnalyzer nominal, {List<String>? problems}) {
  final out = <Skill>[];
  void cell(String id, String nomen, String quid, Set<String> comps, {required String parens}) {
    out.add(Skill(id, nomen: nomen, quid: quid, stratum: Stratum.cella, pars: comps.toList()..sort(), notiones: comps.where((c) => c.startsWith('not.')).toList(), probatur: const [Dimensio.casus, Dimensio.numerus, Dimensio.genus, Dimensio.analysis], visibilis: false, parens: parens));
  }

  // Noms.
  for (final e in kNounTypeReps.entries) {
    final lex = nominal.maybeLexeme(e.value);
    if (lex is! NounEntry) {
      problems?.add('représentant manquant ${e.value}');
      continue;
    }
    final seen = <String>{};
    for (final f in nominal.formsOf(lex.id)) {
      if (!f.isPrimary) continue;
      final sel = f.analysis.selector;
      if (!seen.add(sel)) continue;
      final comps = nominalComponents(f, lex);
      if (!comps.any((c) => c.startsWith('n.des.'))) problems?.add('désinence inconnue ${lex.id} ${f.surface}');
      cell('cella.n.${e.key}.$sel', '${f.analysis.describe(withGender: false)} — ${lex.lemma}', 'Lire et produire ${f.surface} : ${f.analysis.describe()} d\'un nom comme ${lex.lemma}.', comps, parens: 'n');
    }
  }
  // Adjectifs : un représentant par classe, plus les degrés.
  const adjReps = {'12': 'bonus', '12.er': 'pulcher', '3.una': 'felix', '3.duo': 'fortis', '3.tria': 'acer', '3.cons': 'vetus'};
  for (final e in adjReps.entries) {
    final lex = nominal.maybeLexeme(e.value);
    if (lex is! AdjectiveEntry) {
      problems?.add('représentant manquant ${e.value}');
      continue;
    }
    final seen = <String>{};
    for (final f in nominal.formsOf(lex.id)) {
      if (!f.isPrimary || f.analysis.degree != Degree.positivus || f.analysis.casus == null) continue;
      final sel = f.analysis.selector;
      if (!seen.add(sel)) continue;
      cell('cella.adj.${e.key}.$sel', '${f.analysis.describe(withDegree: false)} — ${lex.lemma}', 'Lire et produire ${f.surface} : ${f.analysis.describe()} d\'un adjectif comme ${lex.lemma}.', nominalComponents(f, lex), parens: 'adj');
    }
  }
  final longus = nominal.maybeLexeme('longus');
  if (longus is AdjectiveEntry) {
    final seen = <String>{};
    for (final f in nominal.formsOf(longus.id)) {
      if (!f.isPrimary || f.analysis.degree == Degree.positivus || f.analysis.casus == null) continue;
      final sel = f.analysis.selector;
      if (!seen.add(sel)) continue;
      cell('cella.adj.${f.analysis.degree.key}.$sel', '${f.analysis.describe()} — ${longus.lemma}', 'Lire et produire ${f.surface} : ${f.analysis.describe()}.', nominalComponents(f, longus), parens: 'adj');
    }
  } else {
    problems?.add('représentant manquant longus');
  }
  // Pronoms : chaque paradigme est explicite.
  for (final p in nominal.pronouns) {
    final seen = <String>{};
    for (final f in nominal.formsOf(p.id)) {
      if (!f.isPrimary || f.analysis.casus == null) continue;
      final sel = f.analysis.selector;
      if (!seen.add(sel)) continue;
      cell('cella.pron.${p.id}.$sel', '${f.analysis.describe()} — ${p.lemma}', 'Lire et produire ${f.surface} : ${f.analysis.describe()} de ${p.lemma}.', nominalComponents(f, p), parens: 'pron');
    }
  }
  // Numéraux déclinables.
  for (final nu in nominal.numerals) {
    final seen = <String>{};
    for (final f in nominal.formsOf(nu.id)) {
      if (!f.isPrimary || f.analysis.casus == null) continue;
      final sel = f.analysis.selector;
      if (!seen.add(sel)) continue;
      cell('cella.num.${nu.id}.$sel', '${f.analysis.describe()} — ${nu.lemma}', 'Lire et produire ${f.surface} : ${f.analysis.describe()} de ${nu.lemma}.', nominalComponents(f, nu), parens: 'num');
    }
  }
  return out;
}
