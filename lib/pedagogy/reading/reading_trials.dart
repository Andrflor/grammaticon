/// Trial (fābula) catalogue of the Theatrum: Latin → French comprehension
/// organised by the morphological progression of the Amphitheatrum and the
/// Forum. Uses the shared [Trial] model; the content is selected by
/// [ReadingFilter] over the curated items of `reading_content.dart`.
library;

import '../trial.dart';

/// Selects curated items by the base trial they were written for.
class ReadingFilter extends ContentFilter {
  const ReadingFilter({this.trialIds});

  /// Base trial ids whose items are drawn; null = the trial's own items.
  final Set<String>? trialIds;

  bool matches(String ownTrialId, String itemTrialId) => trialIds == null ? itemTrialId == ownTrialId : trialIds!.contains(itemTrialId);
}

/// Distinction keys used by the distractor annotations.
class Distinctions {
  Distinctions._();
  static const numerus = 'numerus';
  static const persona = 'persona';
  static const casus = 'casus';
  static const tempus = 'tempus';
  static const vox = 'vox';
  static const modus = 'modus';
  static const congruentia = 'congruentia';
  static const nonfinita = 'nonfinita';
  static const all = {numerus, persona, casus, tempus, vox, modus, congruentia, nonfinita};
}

class ReadingTrials {
  ReadingTrials._();

  static const groups = ['Verbum: persōna et numerus', 'Verbum: tempora', 'Nōmen: cāsūs et congruentia', 'Verbum: modī et vōcēs', 'Fōrmae nōminālēs', 'Mixta'];

  /// Distinctions a trial's distractors may rely on. Prerequisites' keys are
  /// allowed too (checked transitively by [allowedDistinctions]).
  static const Map<String, Set<String>> ownDistinctions = {
    'th-numerus': {Distinctions.numerus},
    'th-persona': {Distinctions.persona, Distinctions.numerus},
    'th-casus-recti': {Distinctions.casus},
    'th-tempus-praeteritum': {Distinctions.tempus},
    'th-tempus-futurum': {Distinctions.tempus},
    'th-casus-obliqui': {Distinctions.casus},
    'th-modus-imperativus': {Distinctions.modus},
    'th-vox': {Distinctions.vox},
    'th-modus-subiunctivus': {Distinctions.modus},
    'th-congruentia': {Distinctions.congruentia},
    'th-nonfinita': {Distinctions.nonfinita},
    'th-mx-verbum': {Distinctions.numerus, Distinctions.persona, Distinctions.tempus, Distinctions.modus, Distinctions.vox},
    'th-mx-nomen': {Distinctions.casus, Distinctions.congruentia},
    'th-mx-omnia': Distinctions.all,
  };

  /// Non-revealing Auxilium hint per trial (Latin).
  static const Map<String, String> hints = {
    'th-numerus': 'Attende dēsinentiam verbī: -t (ūnus) an -nt (plūrēs)? Nōmen quoque numerum ostendit.',
    'th-persona': 'Quis loquitur, quis agit? Dēsinentiae -ō/-m, -s, -t, -mus, -tis, -nt persōnam dīcunt.',
    'th-casus-recti': 'Quis agit (nōminātīvus), quid patitur (accūsātīvus), quō īnstrūmentō (ablātīvus)? Ōrdō verbōrum nihil probat.',
    'th-tempus-praeteritum': 'Nunc, tunc, an iam factum? Quaere signum -ba- (imperfectum) et thema perfectī (-v-, -s-, -x-).',
    'th-tempus-futurum': 'Quod fīet: -b- (I–II) aut -ē-/-a- (III–IV). Quod factum erat ante: -era-.',
    'th-casus-obliqui': 'Cuius (genetīvus)? Cui (datīvus)? Ā quō, quō modō (ablātīvus)? Dēsinentia relātiōnem dīcit.',
    'th-modus-imperativus': 'Iubetne (imperātīvus) an nārrat (indicātīvus)? Nōlī + īnfīnītīvus vetat.',
    'th-vox': 'Agitne subiectum (āctīvum) an patitur (passīvum)? -tur, -ntur, -rī, participium + est.',
    'th-modus-subiunctivus': 'Optat, iubet, fīnem dīcit (subiūnctīvus) an rem ut factum affirmat (indicātīvus)?',
    'th-congruentia': 'Adiectīvum et participium cum quō nōmine congruunt (genere, numerō, cāsū)?',
    'th-nonfinita': 'Participium tempus et vōcem habet; īnfīnītīvus āctīvus (-re) an passīvus (-rī)?',
    'th-mx-verbum': 'Omnia signa verbī: persōna, numerus, tempus, modus, vōx.',
    'th-mx-nomen': 'Omnia signa nōminis: cāsus, numerus, congruentia.',
    'th-mx-omnia': 'Omnia quae didicistī: verbum et nōmen in sententiā.',
  };

  static Set<String> allowedDistinctions(String trialId, Trial Function(String) byId) {
    final out = <String>{};
    final seen = <String>{};
    void visit(String id) {
      if (!seen.add(id)) return;
      out.addAll(ownDistinctions[id] ?? const {});
      for (final p in byId(id).prerequisites) {
        visit(p);
      }
    }

    visit(trialId);
    return out;
  }

  static List<Trial> build() => [
        // ----------------------------------------------------- Verbum: persōna et numerus
        const Trial(
          id: 'th-numerus',
          activity: Activity.theatrum,
          name: 'Numerus in sententiā',
          subtitle: 'ūnus an plūrēs?',
          skillIds: ['l.numerus'],
          price: 0,
          prerequisites: [],
          filter: ReadingFilter(),
          dimensions: [Dimension.sensus],
          intro: 'In Theātrō sententia Latīna legitur et quattuor interpretātiōnēs Gallicae offeruntur: ūna vēra, trēs fōrmam Latīnam male intellegunt. Prīmum discrīmen: numerus. Dēsinentia -t ūnum agentem, -nt plūrēs dīcit; nōmen quoque singulāre aut plūrāle est (Deus / diī, homō / hominēs).',
          examples: ['videbit (ūnus) ≠ videbunt (plūrēs)', 'Beati mundo corde: quoniam ipsi Deum videbunt.', 'ovis · oves — gens · gentes'],
          opponentId: 'comoedus',
          group: 'Verbum: persōna et numerus',
        ),
        const Trial(
          id: 'th-persona',
          activity: Activity.theatrum,
          name: 'Persōna in sententiā',
          subtitle: 'ego · tū · ille',
          skillIds: ['l.persona'],
          price: 15,
          prerequisites: ['th-numerus'],
          filter: ReadingFilter(),
          dimensions: [Dimension.sensus],
          intro: 'Quis loquitur, quis agit? Latīna persōnam in dēsinentiā verbī gerit, etiam sine prōnōmine: peccāvī (ego), peccāstī (tū), peccāvit (ille). Interpretātiō falsa persōnam mūtat: «j\'ai péché» fit «tu as péché».',
          examples: ['amō · amās · amat', 'Tibi soli peccavi (ego).', 'tu scis quia amo te'],
          opponentId: 'comoedus',
          group: 'Verbum: persōna et numerus',
        ),
        // ----------------------------------------------------- Verbum: tempora
        const Trial(
          id: 'th-tempus-praeteritum',
          activity: Activity.theatrum,
          name: 'Tempora: praesēns, imperfectum, perfectum',
          subtitle: 'nunc · tunc · iam factum',
          skillIds: ['l.tempus'],
          price: 25,
          prerequisites: ['th-persona'],
          filter: ReadingFilter(),
          dimensions: [Dimension.sensus],
          intro: 'Idem verbum aliud tempus, alius sēnsus: erat (imperfectum: «était»), est (praesēns: «est»), fuit (perfectum: «fut»). Imperfectum āctiōnem dūrantem, perfectum factum absolūtum dīcit. Gallicē: imparfait, présent, passé composé / passé simple.',
          examples: ['In principio erat Verbum.', 'creavit Deus — Dieu créa', 'lucet ≠ lucebat ≠ luxit'],
          opponentId: 'tragoedus',
          group: 'Verbum: tempora',
        ),
        const Trial(
          id: 'th-tempus-futurum',
          activity: Activity.theatrum,
          name: 'Tempora: futūrum et plūsquamperfectum',
          subtitle: 'quod fīet · quod factum erat',
          skillIds: ['l.tempus'],
          price: 30,
          prerequisites: ['th-tempus-praeteritum'],
          filter: ReadingFilter(),
          dimensions: [Dimension.sensus],
          intro: 'Futūrum prōmissa et praecepta gerit (Non occides: «tu ne tueras point»); plūsquamperfectum rem ante aliud praeteritum factam (fecerat: «il avait fait»). Cavē futūrum exāctum (ambulavero) quod Gallicē saepe praesente redditur.',
          examples: ['videbunt — ils verront', 'mortuus erat, et revixit', 'quæ fecerat — qu\'il avait fait'],
          opponentId: 'tragoedus',
          group: 'Verbum: tempora',
        ),
        // ----------------------------------------------------- Nōmen: cāsūs
        const Trial(
          id: 'th-casus-recti',
          activity: Activity.theatrum,
          name: 'Cāsūs: subiectum et obiectum',
          subtitle: 'nōminātīvus · accūsātīvus · ablātīvus',
          skillIds: ['l.casus'],
          price: 20,
          prerequisites: ['th-numerus'],
          filter: ReadingFilter(),
          dimensions: [Dimension.sensus],
          intro: 'Ōrdō verbōrum Latīnus līber est: cāsus, nōn locus, dīcit quis agat. «Deum diligit homo» et «hominem diligit Deus» contrāria significant. Ablātīvus īnstrūmentum, modum, locum ostendit.',
          examples: ['creavit Deus hominem — Dieu créa l\'homme', 'Dominus regit me — c\'est le Seigneur qui me conduit', 'in principio · voce magna'],
          opponentId: 'mimus',
          group: 'Nōmen: cāsūs et congruentia',
        ),
        const Trial(
          id: 'th-casus-obliqui',
          activity: Activity.theatrum,
          name: 'Cāsūs: genetīvus, datīvus, ablātīvus',
          subtitle: 'cuius · cui · ā quō',
          skillIds: ['l.casus'],
          price: 30,
          prerequisites: ['th-casus-recti'],
          filter: ReadingFilter(),
          dimensions: [Dimension.sensus],
          intro: 'Genetīvus possessiōnem et partem («de»), datīvus eum cui datur («à»), ablātīvus īnstrūmentum et sēparātiōnem («par, avec, de») dīcit. Interpretātiō falsa relātiōnem invertit: «le fils de l\'homme» fit «l\'homme du fils».',
          examples: ['Filius hominis — le Fils de l\'homme', 'Reddite Cæsari — Rendez à César', 'in sudore vultus tui'],
          opponentId: 'mimus',
          group: 'Nōmen: cāsūs et congruentia',
        ),
        const Trial(
          id: 'th-congruentia',
          activity: Activity.theatrum,
          name: 'Congruentia',
          subtitle: 'adiectīvum et participium cum nōmine',
          skillIds: ['l.congruentia'],
          price: 40,
          prerequisites: ['th-casus-obliqui'],
          filter: ReadingFilter(),
          dimensions: [Dimension.sensus],
          intro: 'Adiectīvum et participium genere, numerō, cāsū cum suō nōmine congruunt, etiam procul positum. Quod nōmen «bonus» dēscrībit? Congruentia, nōn vīcīnitās, respondet.',
          examples: ['pastor bonus — le bon berger', 'hominibus bonæ voluntatis', 'Ego sum vitis vera'],
          opponentId: 'pantomimus',
          group: 'Nōmen: cāsūs et congruentia',
        ),
        // ----------------------------------------------------- Verbum: modī et vōcēs
        const Trial(
          id: 'th-modus-imperativus',
          activity: Activity.theatrum,
          name: 'Modī: imperātīvus et indicātīvus',
          subtitle: 'iubet an nārrat?',
          skillIds: ['l.modus'],
          price: 30,
          prerequisites: ['th-persona'],
          filter: ReadingFilter(),
          dimensions: [Dimension.sensus],
          intro: 'Imperātīvus iubet: veni, venite («viens, venez»); indicātīvus nārrat: venit («il vient / il vint»). Nōlī, nōlīte + īnfīnītīvus vetat («ne … pas»). Futūrum quoque praecipere potest.',
          examples: ['Venite ad me omnes', 'Nolite timere — Ne craignez point', 'venit ≠ veni'],
          opponentId: 'chorus',
          group: 'Verbum: modī et vōcēs',
        ),
        const Trial(
          id: 'th-vox',
          activity: Activity.theatrum,
          name: 'Vōx: āctīvum et passīvum',
          subtitle: 'agit an patitur?',
          skillIds: ['l.vox'],
          price: 35,
          prerequisites: ['th-tempus-praeteritum'],
          filter: ReadingFilter(),
          dimensions: [Dimension.sensus],
          intro: 'Passīvum subiectum patientem facit: vocabitur («il sera appelé») ≠ vocabit («il appellera»). Signa: -tur, -ntur, -mur, -minī; īnfīnītīvus -rī; participium perfectī + est/erat. Dēpōnentia fōrmā passīva sēnsum āctīvum habent (sequitur: «il suit»).',
          examples: ['non venit ministrari, sed ministrare', 'facta est lux — la lumière fut', 'exaltabitur ≠ exaltabit'],
          opponentId: 'chorus',
          group: 'Verbum: modī et vōcēs',
        ),
        const Trial(
          id: 'th-modus-subiunctivus',
          activity: Activity.theatrum,
          name: 'Modī: subiūnctīvus',
          subtitle: 'optat · iubet · fīnem dīcit',
          skillIds: ['l.modus'],
          price: 40,
          prerequisites: ['th-modus-imperativus', 'th-tempus-futurum'],
          filter: ReadingFilter(),
          dimensions: [Dimension.sensus],
          intro: 'Subiūnctīvus optātum, iussum, fīnem, condiciōnem dīcit: fiat lux («que la lumière soit»), ut videant («afin qu\'ils voient»). Indicātīvus rem affirmat: fit («elle se fait»). Gallicē: subjonctif, «que…», «afin que…».',
          examples: ['Fiat lux. Et facta est lux.', 'sanctificetur nomen tuum', 'faciamus hominem — faisons l\'homme'],
          opponentId: 'tragoedus',
          group: 'Verbum: modī et vōcēs',
        ),
        // ----------------------------------------------------- Fōrmae nōminālēs
        const Trial(
          id: 'th-nonfinita',
          activity: Activity.theatrum,
          name: 'Participia et īnfīnītīvī',
          subtitle: 'videns · venturus · ministrari',
          skillIds: ['l.nonfinita'],
          price: 45,
          prerequisites: ['th-vox', 'th-congruentia'],
          filter: ReadingFilter(),
          dimensions: [Dimension.sensus],
          intro: 'Participium praesentis āctiōnem simul factam dīcit (videns: «voyant»), perfectī rem iam passam (natus: «né»), futūrī rem ventūram (venturus: «qui va venir»). Īnfīnītīvus āctīvus (-re) an passīvus (-rī)? Ablātīvus absolūtus (vespere facto) circumstantiam dat.',
          examples: ['Videns autem Jesus turbas, ascendit', 'qui venturus est', 'Vespere autem facto'],
          opponentId: 'pantomimus',
          group: 'Fōrmae nōminālēs',
        ),
        // ----------------------------------------------------- Mixta
        const Trial(
          id: 'th-mx-verbum',
          activity: Activity.theatrum,
          name: 'Mixta: verbum in sententiā',
          subtitle: 'persōna · numerus · tempus · modus · vōx',
          skillIds: ['l.mx.verbum'],
          price: 60,
          prerequisites: ['th-modus-subiunctivus', 'th-vox'],
          filter: ReadingFilter(trialIds: {'th-numerus', 'th-persona', 'th-tempus-praeteritum', 'th-tempus-futurum', 'th-modus-imperativus', 'th-vox', 'th-modus-subiunctivus'}),
          dimensions: [Dimension.sensus],
          components: [
            TrialComponent('numerus', 'Numerus', ReadingFilter(trialIds: {'th-numerus'}), skillId: 'l.numerus'),
            TrialComponent('persona', 'Persōna', ReadingFilter(trialIds: {'th-persona'}), skillId: 'l.persona'),
            TrialComponent('tempus', 'Tempora', ReadingFilter(trialIds: {'th-tempus-praeteritum', 'th-tempus-futurum'}), skillId: 'l.tempus'),
            TrialComponent('modus', 'Modī', ReadingFilter(trialIds: {'th-modus-imperativus', 'th-modus-subiunctivus'}), skillId: 'l.modus'),
            TrialComponent('vox', 'Vōcēs', ReadingFilter(trialIds: {'th-vox'}), skillId: 'l.vox'),
          ],
          intro: 'Nunc nōn dīcitur quod discrīmen quaerātur: persōna, numerus, tempus, modus an vōx. Omnia signa verbī simul legenda sunt.',
          examples: ['videbunt · videbit · vidit · videat', 'ministrari ≠ ministrare', 'omnia quae didicistī dē verbō'],
          opponentId: 'dominus',
          group: 'Mixta',
        ),
        const Trial(
          id: 'th-mx-nomen',
          activity: Activity.theatrum,
          name: 'Mixta: nōmen in sententiā',
          subtitle: 'cāsūs · congruentia',
          skillIds: ['l.mx.nomen'],
          price: 60,
          prerequisites: ['th-congruentia'],
          filter: ReadingFilter(trialIds: {'th-casus-recti', 'th-casus-obliqui', 'th-congruentia'}),
          dimensions: [Dimension.sensus],
          components: [
            TrialComponent('casus', 'Cāsūs', ReadingFilter(trialIds: {'th-casus-recti', 'th-casus-obliqui'}), skillId: 'l.casus'),
            TrialComponent('congruentia', 'Congruentia', ReadingFilter(trialIds: {'th-congruentia'}), skillId: 'l.congruentia'),
          ],
          intro: 'Cāsūs et congruentia mixta: quis agit, quid patitur, cui datur, quod nōmen adiectīvum dēscrībit.',
          examples: ['Deus hominem · hominem Deus', 'Reddite Cæsari', 'pastor bonus'],
          opponentId: 'dominus',
          group: 'Mixta',
        ),
        const Trial(
          id: 'th-mx-omnia',
          activity: Activity.theatrum,
          name: 'Omnia mixta',
          subtitle: 'summa fābula',
          skillIds: ['l.mx.omnia'],
          price: 100,
          prerequisites: ['th-mx-verbum', 'th-mx-nomen', 'th-nonfinita'],
          filter: ReadingFilter(trialIds: {'th-numerus', 'th-persona', 'th-tempus-praeteritum', 'th-tempus-futurum', 'th-casus-recti', 'th-casus-obliqui', 'th-congruentia', 'th-modus-imperativus', 'th-vox', 'th-modus-subiunctivus', 'th-nonfinita'}),
          dimensions: [Dimension.sensus],
          components: [
            TrialComponent('verbum', 'Verbum', ReadingFilter(trialIds: {'th-numerus', 'th-persona', 'th-tempus-praeteritum', 'th-tempus-futurum', 'th-modus-imperativus', 'th-vox', 'th-modus-subiunctivus'})),
            TrialComponent('nomen', 'Nōmen', ReadingFilter(trialIds: {'th-casus-recti', 'th-casus-obliqui', 'th-congruentia'})),
            TrialComponent('nonfinita', 'Fōrmae nōminālēs', ReadingFilter(trialIds: {'th-nonfinita'}), skillId: 'l.nonfinita'),
          ],
          intro: 'Omnia mixta: quaelibet sententia, quodlibet discrīmen. Summa fābula Theātrī.',
          examples: ['verbum et nōmen', 'participia et īnfīnītīvī', 'omnia quae didicistī'],
          opponentId: 'dominus',
          group: 'Mixta',
        ),
      ];
}
