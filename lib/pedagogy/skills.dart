/// Skill taxonomy shown in the Tabula and tracked by the mastery model.
///
/// Leaf skills receive observations; parents aggregate their children. Ids are
/// stable and used as keys in the save file.
library;

import 'forum/forum_trials.dart';
import 'tm_steps.dart';

enum SkillBranch { coniugationes, temporaModi, mixta, declinationes, forum, lectio }

class Skill {
  const Skill(this.id, this.name, {this.parent, required this.branch, this.hint = '', this.future = false});
  final String id;
  final String name;
  final String? parent;
  final SkillBranch branch;
  final String hint;

  /// Structure prepared for a later release (Declinationes).
  final bool future;

  bool get isRoot => parent == null;
}

class Skills {
  Skills._();

  static const List<Skill> _base = [
    // ----- Coniugationes -----
    Skill('v', 'Coniugātiōnēs', branch: SkillBranch.coniugationes),
    Skill('v.ind', 'Indicātīvus', parent: 'v', branch: SkillBranch.coniugationes),
    Skill('v.ind.praes.act', 'Praesēns āctīvum', parent: 'v.ind', branch: SkillBranch.coniugationes, hint: 'amō, amās, amat'),
    Skill('v.ind.imperf.act', 'Imperfectum āctīvum', parent: 'v.ind', branch: SkillBranch.coniugationes, hint: 'amābam, regēbam'),
    Skill('v.ind.fut.act', 'Futūrum āctīvum', parent: 'v.ind', branch: SkillBranch.coniugationes, hint: 'amābō, regam'),
    Skill('v.ind.perf.act', 'Perfectum āctīvum', parent: 'v.ind', branch: SkillBranch.coniugationes, hint: 'amāvī, rēxī'),
    Skill('v.ind.plusq.act', 'Plūsquamperfectum āctīvum', parent: 'v.ind', branch: SkillBranch.coniugationes, hint: 'amāveram'),
    Skill('v.ind.futex.act', 'Futūrum exāctum āctīvum', parent: 'v.ind', branch: SkillBranch.coniugationes, hint: 'amāverō'),
    Skill('v.ind.praes.pass', 'Praesēns passīvum', parent: 'v.ind', branch: SkillBranch.coniugationes, hint: 'amor, amāris'),
    Skill('v.ind.imperf.pass', 'Imperfectum passīvum', parent: 'v.ind', branch: SkillBranch.coniugationes, hint: 'amābar'),
    Skill('v.ind.fut.pass', 'Futūrum passīvum', parent: 'v.ind', branch: SkillBranch.coniugationes, hint: 'amābor, regar'),
    Skill('v.ind.perf.pass', 'Perfectum passīvum', parent: 'v.ind', branch: SkillBranch.coniugationes, hint: 'amātus sum'),
    Skill('v.ind.plusq.pass', 'Plūsquamperfectum passīvum', parent: 'v.ind', branch: SkillBranch.coniugationes, hint: 'amātus eram'),
    Skill('v.ind.futex.pass', 'Futūrum exāctum passīvum', parent: 'v.ind', branch: SkillBranch.coniugationes, hint: 'amātus erō'),
    Skill('v.subj', 'Subiūnctīvus', parent: 'v', branch: SkillBranch.coniugationes),
    Skill('v.subj.praes.act', 'Praesēns āctīvum', parent: 'v.subj', branch: SkillBranch.coniugationes, hint: 'amem, regam'),
    Skill('v.subj.imperf.act', 'Imperfectum āctīvum', parent: 'v.subj', branch: SkillBranch.coniugationes, hint: 'amārem'),
    Skill('v.subj.perf.act', 'Perfectum āctīvum', parent: 'v.subj', branch: SkillBranch.coniugationes, hint: 'amāverim'),
    Skill('v.subj.plusq.act', 'Plūsquamperfectum āctīvum', parent: 'v.subj', branch: SkillBranch.coniugationes, hint: 'amāvissem'),
    Skill('v.subj.praes.pass', 'Praesēns passīvum', parent: 'v.subj', branch: SkillBranch.coniugationes, hint: 'amer'),
    Skill('v.subj.imperf.pass', 'Imperfectum passīvum', parent: 'v.subj', branch: SkillBranch.coniugationes, hint: 'amārer'),
    Skill('v.subj.perf.pass', 'Perfectum passīvum', parent: 'v.subj', branch: SkillBranch.coniugationes, hint: 'amātus sim'),
    Skill('v.subj.plusq.pass', 'Plūsquamperfectum passīvum', parent: 'v.subj', branch: SkillBranch.coniugationes, hint: 'amātus essem'),
    Skill('v.imp', 'Imperātīvus', parent: 'v', branch: SkillBranch.coniugationes),
    Skill('v.imp.praes', 'Imperātīvus praesēns', parent: 'v.imp', branch: SkillBranch.coniugationes, hint: 'amā, amāte, amāre'),
    Skill('v.imp.fut', 'Imperātīvus futūrus', parent: 'v.imp', branch: SkillBranch.coniugationes, hint: 'amātō, amantō'),
    Skill('v.nonfinita', 'Fōrmae nōminālēs', parent: 'v', branch: SkillBranch.coniugationes),
    Skill('v.inf', 'Īnfīnītīvī', parent: 'v.nonfinita', branch: SkillBranch.coniugationes, hint: 'amāre, amāvisse, amātūrus esse'),
    Skill('v.part', 'Participia', parent: 'v.nonfinita', branch: SkillBranch.coniugationes, hint: 'amāns, amātus, amātūrus'),
    Skill('v.ger', 'Gerundium et gerundīvum', parent: 'v.nonfinita', branch: SkillBranch.coniugationes, hint: 'amandī, amandus'),
    Skill('v.sup', 'Supīnum', parent: 'v.nonfinita', branch: SkillBranch.coniugationes, hint: 'amātum, amātū'),
    Skill('v.periph', 'Coniugātiō periphrastica', parent: 'v', branch: SkillBranch.coniugationes),
    Skill('v.periph.act', 'Periphrastica āctīva', parent: 'v.periph', branch: SkillBranch.coniugationes, hint: 'amātūrus sum'),
    Skill('v.periph.pass', 'Periphrastica passīva', parent: 'v.periph', branch: SkillBranch.coniugationes, hint: 'amandus sum'),
    Skill('v.fam', 'Verba anōmala', parent: 'v', branch: SkillBranch.coniugationes),
    Skill('v.fam.sum', 'sum et composita', parent: 'v.fam', branch: SkillBranch.coniugationes, hint: 'sum, possum, absum, prōsum'),
    Skill('v.fam.eo', 'eō et composita', parent: 'v.fam', branch: SkillBranch.coniugationes, hint: 'eō, redeō, trānseō'),
    Skill('v.fam.fero', 'ferō et composita', parent: 'v.fam', branch: SkillBranch.coniugationes, hint: 'ferō, auferō, referō'),
    Skill('v.fam.volo', 'volō, nōlō, mālō', parent: 'v.fam', branch: SkillBranch.coniugationes),
    Skill('v.fam.fio', 'fīō et faciō', parent: 'v.fam', branch: SkillBranch.coniugationes),
    Skill('v.fam.minora', 'dō et edō', parent: 'v.fam', branch: SkillBranch.coniugationes),
    Skill('v.specialia', 'Verba speciālia', parent: 'v', branch: SkillBranch.coniugationes),
    Skill('v.dep', 'Dēpōnentia', parent: 'v.specialia', branch: SkillBranch.coniugationes, hint: 'sequor, hortor, patior'),
    Skill('v.semidep', 'Sēmidēpōnentia', parent: 'v.specialia', branch: SkillBranch.coniugationes, hint: 'audeō, ausus sum'),
    Skill('v.def', 'Dēfectīva', parent: 'v.specialia', branch: SkillBranch.coniugationes, hint: 'ōdī, meminī, coepī, inquam'),
    Skill('v.impers', 'Impersōnālia', parent: 'v.specialia', branch: SkillBranch.coniugationes, hint: 'licet, oportet, pluit'),
    Skill('v.variantes', 'Variantēs fōrmārum', parent: 'v.specialia', branch: SkillBranch.coniugationes, hint: 'amāstī, amāvēre, amābāre'),
    // ----- Tempora et modī: recognising tense and mood, apart from the
    // endings of person and number trained in the conjugation tree -----
    Skill('tm', 'Tempora et modī', branch: SkillBranch.temporaModi),
    Skill('tm.tempus', 'Agnitiō temporum', parent: 'tm', branch: SkillBranch.temporaModi),
    // Each mood/voice is a ladder of steps, one leaf per step (generated
    // from TmLadders): recognising praesēns against imperfectum is not
    // recognising every tense.
    Skill('tm.tempus.ind.act', 'Tempora indicātīvī āctīvī', parent: 'tm.tempus', branch: SkillBranch.temporaModi, hint: 'amat · amābat · amābit · amāvit'),
    Skill('tm.tempus.ind.pass', 'Tempora indicātīvī passīvī', parent: 'tm.tempus', branch: SkillBranch.temporaModi, hint: 'amātur · amābātur · amātus est'),
    Skill('tm.tempus.subj.act', 'Tempora subiūnctīvī āctīvī', parent: 'tm.tempus', branch: SkillBranch.temporaModi, hint: 'amet · amāret · amāverit · amāvisset'),
    Skill('tm.tempus.subj.pass', 'Tempora subiūnctīvī passīvī', parent: 'tm.tempus', branch: SkillBranch.temporaModi, hint: 'amētur · amārētur · amātus sit'),
    Skill('tm.tempus.inf', 'Tempora īnfīnītīvī', parent: 'tm.tempus', branch: SkillBranch.temporaModi, hint: 'amāre · amāvisse · amātūrus esse'),
    // Leaves of the mood ladder and of the combined ladder are generated
    // from ModiLadder and AmboLadder.
    Skill('tm.modus', 'Agnitiō modōrum', parent: 'tm', branch: SkillBranch.temporaModi),
    Skill('tm.ambo', 'Tempus et modus simul', parent: 'tm', branch: SkillBranch.temporaModi, hint: 'amāret: subiūnctīvus imperfectum'),
    // ----- Mixta -----
    Skill('mx', 'Mixta', branch: SkillBranch.mixta),
    Skill('mx.tempus.ind', 'Discrīmen temporum indicātīvī', parent: 'mx', branch: SkillBranch.mixta),
    Skill('mx.tempus.subj', 'Discrīmen temporum subiūnctīvī', parent: 'mx', branch: SkillBranch.mixta),
    Skill('mx.modus', 'Discrīmen modōrum', parent: 'mx', branch: SkillBranch.mixta),
    Skill('mx.vox', 'Discrīmen vōcum', parent: 'mx', branch: SkillBranch.mixta),
    Skill('mx.familia', 'Discrīmen verbōrum anōmalōrum', parent: 'mx', branch: SkillBranch.mixta),
    Skill('mx.omnia', 'Omnia mixta', parent: 'mx', branch: SkillBranch.mixta),
    // ----- Declinationes: the paradigm cells credited by every noun form of
    // the Forum (kept apart from the cards so that a cell's history survives
    // any change of the catalogue) -----
    Skill('d', 'Dēclīnātiōnēs · cellae', branch: SkillBranch.declinationes),
  ];

  /// Contextual comprehension (Theatrum): the same grammatical distinctions
  /// as the two form-recognition trees, read in a sentence and rendered in
  /// French. Kept apart so that recognising an isolated form and
  /// understanding it in context are never conflated.
  static const List<Skill> _lectio = [
    Skill('l', 'Lēctiō · Theātrum', branch: SkillBranch.lectio),
    Skill('l.verbum', 'Verbum in sententiā', parent: 'l', branch: SkillBranch.lectio),
    Skill('l.numerus', 'Numerus', parent: 'l.verbum', branch: SkillBranch.lectio, hint: 'videbit · videbunt'),
    Skill('l.persona', 'Persōna', parent: 'l.verbum', branch: SkillBranch.lectio, hint: 'peccāvī · peccāstī · peccāvit'),
    Skill('l.tempus', 'Tempus', parent: 'l.verbum', branch: SkillBranch.lectio, hint: 'erat · est · fuit · erit'),
    Skill('l.modus', 'Modus', parent: 'l.verbum', branch: SkillBranch.lectio, hint: 'fiat · fit · fac'),
    Skill('l.vox', 'Vōx', parent: 'l.verbum', branch: SkillBranch.lectio, hint: 'ministrāre · ministrārī'),
    Skill('l.nomen', 'Nōmen in sententiā', parent: 'l', branch: SkillBranch.lectio),
    Skill('l.casus', 'Cāsūs et relātiōnēs', parent: 'l.nomen', branch: SkillBranch.lectio, hint: 'Deus hominem · hominem Deus'),
    Skill('l.congruentia', 'Congruentia', parent: 'l.nomen', branch: SkillBranch.lectio, hint: 'pastor bonus · vitis vēra'),
    Skill('l.nonfinita', 'Participia et īnfīnītīvī', parent: 'l', branch: SkillBranch.lectio, hint: 'vidēns · nātus · ventūrus · ministrārī'),
    Skill('l.mx', 'Mixta lēctiōnis', parent: 'l', branch: SkillBranch.lectio),
    Skill('l.mx.verbum', 'Verbum mixtum', parent: 'l.mx', branch: SkillBranch.lectio),
    Skill('l.mx.nomen', 'Nōmen mixtum', parent: 'l.mx', branch: SkillBranch.lectio),
    Skill('l.mx.omnia', 'Omnia mixta', parent: 'l.mx', branch: SkillBranch.lectio),
  ];

  /// The locative cell, appended after the declension tree.
  static const List<Skill> _declTail = [
    Skill('d.loc', 'Locātīvus', parent: 'd', branch: SkillBranch.declinationes, hint: 'Rōmae, domī, Carthāginī, rūrī'),
  ];

  /// Forum: one node per section, one leaf per card (generated from the
  /// catalogue), so that every card has its own mastery.
  static List<Skill> _forum() {
    final list = <Skill>[const Skill('f', 'Forum · Nōminālia', branch: SkillBranch.forum)];
    for (final section in ForumSections.all) {
      list.add(Skill(ForumSections.skillOf(section), section, parent: 'f', branch: SkillBranch.forum));
    }
    for (final t in ForumTrials.build()) {
      list.add(Skill(t.primarySkill, t.name, parent: ForumSections.skillOf(t.group), branch: SkillBranch.forum, hint: t.examples.first));
    }
    return list;
  }

  static final List<Skill> all = _buildAll();

  static List<Skill> _buildAll() {
    final list = List<Skill>.from(_base);
    const decl = ['Prīma', 'Secunda', 'Tertia', 'Quārta', 'Quīnta'];
    const hints = ['rosa, rosae', 'servus, puer, bellum', 'rēx, cīvis, corpus, mare', 'manus, cornū', 'rēs, diēs'];
    const cases = [('nom', 'Nōminātīvus'), ('voc', 'Vocātīvus'), ('acc', 'Accūsātīvus'), ('gen', 'Genetīvus'), ('dat', 'Datīvus'), ('abl', 'Ablātīvus')];
    for (var i = 0; i < 5; i++) {
      final d = 'd.${i + 1}';
      list.add(Skill(d, '${decl[i]} dēclīnātiō', parent: 'd', branch: SkillBranch.declinationes, hint: hints[i]));
      for (final (ck, cn) in cases) {
        list.add(Skill('$d.$ck', cn, parent: d, branch: SkillBranch.declinationes));
        list.add(Skill('$d.$ck.sg', 'Singulāris', parent: '$d.$ck', branch: SkillBranch.declinationes));
        list.add(Skill('$d.$ck.pl', 'Plūrālis', parent: '$d.$ck', branch: SkillBranch.declinationes));
      }
    }
    list.addAll(_declTail);
    list.addAll(_forum());
    for (final (mood, voice) in TmLadders.ladders) {
      for (final step in TmLadders.of(mood, voice)) {
        list.add(Skill(TmLadders.skillId(mood, voice, step), step.name, parent: TmLadders.parentSkill(mood, voice), branch: SkillBranch.temporaModi, hint: step.hint));
      }
    }
    for (final step in ModiLadder.steps) {
      final sub = step.subtitle.contains(' · ') ? '' : ' · ${step.subtitle}';
      list.add(Skill(ModiLadder.skillId(step), '${step.name}$sub', parent: ModiLadder.parentSkill, branch: SkillBranch.temporaModi, hint: step.hint));
    }
    for (final step in AmboLadder.steps) {
      list.add(Skill(AmboLadder.skillId(step), step.name, parent: AmboLadder.parentSkill, branch: SkillBranch.temporaModi, hint: step.hint));
    }
    list.addAll(_lectio);
    return List.unmodifiable(list);
  }

  static final Map<String, Skill> _byId = {for (final s in all) s.id: s};
  static Skill byId(String id) => _byId[id]!;
  static Skill? maybe(String id) => _byId[id];
  static List<Skill> children(String? parentId) => all.where((s) => s.parent == parentId).toList();
  static List<Skill> roots() => all.where((s) => s.isRoot).toList();
  static bool isLeaf(String id) => !all.any((s) => s.parent == id);

  /// All leaf descendants of [id] (or [id] itself when it is a leaf).
  static List<String> leaves(String id) {
    if (isLeaf(id)) return [id];
    return [for (final c in children(id)) ...leaves(c.id)];
  }

  /// Skill id for a finite tense/voice combination, e.g. `v.ind.praes.act`.
  static String finite(String moodKey, String tenseKey, String voiceKey) => 'v.$moodKey.$tenseKey.$voiceKey';

  /// Tense-recognition skill for a mood/voice among every tense (the last
  /// step of the ladder), e.g. `tm.tempus.ind.act.omnia`, or null when no
  /// such skill exists (imperative, participles…).
  static String? tenseRecognition(String moodKey, String? voiceKey) {
    final id = moodKey == 'inf' ? 'tm.tempus.inf' : 'tm.tempus.$moodKey.$voiceKey.omnia';
    return _byId.containsKey(id) ? id : null;
  }

  /// Skill id of a noun cell, e.g. `d.1.acc.sg` (declension ordinal 1–5).
  static String nounCell(int declension, String caseKey, String numberKey) => 'd.$declension.$caseKey.$numberKey';

  /// True when [ancestorId] is [id] or one of its ancestors.
  static bool isWithin(String id, String ancestorId) {
    String? cur = id;
    while (cur != null) {
      if (cur == ancestorId) return true;
      cur = _byId[cur]?.parent;
    }
    return false;
  }
}
