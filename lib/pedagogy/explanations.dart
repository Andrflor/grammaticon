/// Latin feedback texts built from a resolved verb answer (Amphitheatrum).
library;

import '../linguistics/model/analysis.dart';
import '../linguistics/model/grammar.dart';
import 'question_generator.dart';
import 'trials.dart';

class Explanations {
  const Explanations._();

  static Explanation build({required Question q, required String chosenValue, required bool correct, required QuestionGenerator gen}) {
    final a = q.verb.target.analysis;
    final lemma = gen.analyzer.verb(q.lemmaId);
    final headline = '${q.surface} — ${QuestionGenerator.analysisLabel(a)} (${lemma.lemma})';

    final others = q.verb.analyses
        .where((f) => f.analysis != a && (f.analysis.lemmaId != a.lemmaId || QuestionGenerator.analysisKey(f.analysis) != QuestionGenerator.analysisKey(a)))
        .map((f) => '${QuestionGenerator.analysisLabel(f.analysis)} (${gen.analyzer.verb(f.analysis.lemmaId).lemma})${f.analysis.isPrimary ? '' : ' · ${f.analysis.variant.latin}'}')
        .toSet()
        .toList();

    if (correct) {
      final detail = q.ambiguous ? 'Rēctē: plūrēs analysēs lēgitimae sunt.' : _why(q);
      return Explanation(headline: headline, detail: detail, also: others);
    }

    final chosenLabel = q.choices.firstWhere((c) => c.value == chosenValue, orElse: () => Choice(chosenValue, chosenValue)).label;
    final correctLabels = q.choices.where((c) => q.correctValues.contains(c.value)).map((c) => c.label).join(' aut ');
    final contrast = gen.contrastForm(q, chosenValue);
    var detail = 'Rēctum: $correctLabels. Tū dīxistī: $chosenLabel.';
    if (contrast != null && contrast.surface != q.surface) {
      detail += ' Fōrma "$chosenLabel" esset: ${contrast.surface}.';
    }
    final why = _why(q);
    if (why.isNotEmpty) detail += ' $why';
    return Explanation(headline: headline, detail: detail, contrastSurface: contrast?.surface, also: others);
  }

  /// One-sentence rule of thumb for the target analysis.
  static String _why(Question q) {
    final a = q.verb.target.analysis;
    switch (q.dimension) {
      case Dimension.tempus:
      case Dimension.tempusSensus:
        return _tenseHint(a);
      case Dimension.persona:
      case Dimension.numerus:
        return _personHint(a);
      case Dimension.vox:
        if (a.effectiveSemanticVoice != a.voice) return 'Fōrma passīva, sēnsus āctīvus: verbum dēpōnēns.';
        return a.voice == Voice.passivum ? 'Dēsinentiae -r, -ris, -tur, -mur, -minī, -ntur passīvum ostendunt.' : 'Dēsinentiae -ō/-m, -s, -t, -mus, -tis, -nt āctīvum ostendunt.';
      case Dimension.modus:
        return _moodHint(a);
      case Dimension.declinatio:
        return '';
      case Dimension.coniugatio:
        return 'Vōcālis thematica coniugātiōnem ostendit: -ā- (I), -ē- (II), -e/-i/-u- (III), -i- (III -iō), -ī- (IV).';
      case Dimension.genus:
        return 'Participium cum subiectō congruit: -us (m.), -a (f.), -um (n.).';
      case Dimension.casus:
        return 'Cāsus ē dēsinentiā participiī vel gerundiī cognōscitur.';
      case Dimension.forma:
        return 'Discerne fōrmās nōminālēs: īnfīnītīvus (-re, -rī, -isse), participium (dēclīnātur), gerundium (-ndī, -ndō, -ndum), gerundīvum (-ndus, -a, -um), supīnum (-um, -ū).';
      case Dimension.lemma:
        return 'Quaere thema et partēs prīncipālēs verbī.';
      case Dimension.formaPlena:
        return 'Fōrma contracta vel varia: ${a.variant.latin}.';
      case Dimension.analysis:
        return '';
    }
  }

  static String _tenseHint(Analysis a) {
    if (a.composite) {
      return 'Fōrma composita: tempus ex auxiliārī sūmitur (sum/es/est → perfectum; eram → plūsquamperfectum; erō → futūrum exāctum; sim → subiūnctīvus perfectī; essem → subiūnctīvus plūsquamperfectī).';
    }
    if (a.semanticTense != null) {
      return 'Fōrma ${a.tense!.latin.toLowerCase()}, sed sēnsus ${a.semanticTense!.latin.toLowerCase()}: verbum dēfectīvum.';
    }
    switch (a.tense) {
      case Tense.praesens:
        return 'Thema praesentis sine signō temporis.';
      case Tense.imperfectum:
        return a.mood == Mood.subiunctivus ? 'Īnfīnītīvus + dēsinentia: signum subiūnctīvī imperfectī.' : 'Signum -ba- imperfectum ostendit.';
      case Tense.futurum:
        return 'Signum -b- (I, II) aut vōcālis -a-/-ē- (III, IV) futūrum ostendit.';
      case Tense.perfectum:
        return a.mood == Mood.subiunctivus ? 'Thema perfectī + -eri-: subiūnctīvus perfectī.' : 'Thema perfectī + -ī, -istī, -it, -imus, -istis, -ērunt.';
      case Tense.plusquamperfectum:
        return a.mood == Mood.subiunctivus ? 'Thema perfectī + -isse-: subiūnctīvus plūsquamperfectī.' : 'Thema perfectī + -era-: plūsquamperfectum.';
      case Tense.futurumExactum:
        return 'Thema perfectī + -erō, -eris, -erit … -erint: futūrum exāctum.';
      case null:
        return '';
    }
  }

  static String _personHint(Analysis a) {
    if (!a.isFinite) return '';
    final p = a.person!;
    final n = a.number!;
    final pass = a.voice == Voice.passivum && !a.composite;
    const act = {1: ['-ō / -m', '-mus'], 2: ['-s', '-tis'], 3: ['-t', '-nt']};
    const pas = {1: ['-or / -r', '-mur'], 2: ['-ris / -re', '-minī'], 3: ['-tur', '-ntur']};
    final table = pass ? pas : act;
    final e = table[p.index1]![n == Numerus.singularis ? 0 : 1];
    if (a.composite) return 'Persōna et numerus ex auxiliārī sūmuntur; participium numerum ostendit (-us/-a/-um singulāris, -ī/-ae/-a plūrālis).';
    return 'Dēsinentia $e: ${p.latin.toLowerCase()} persōna ${n.latin.toLowerCase()}.';
  }

  static String _moodHint(Analysis a) {
    switch (a.mood) {
      case Mood.subiunctivus:
        return 'Subiūnctīvus vōcālem mūtat (-e- in prīmā, -a- in cēterīs) aut thema īnfīnītīvī/perfectī cum -re-, -eri-, -isse- adhibet.';
      case Mood.imperativus:
        return 'Imperātīvus iubet: thema nūdum (amā, rege) aut -te, -tō, -tōte, -ntō.';
      case Mood.infinitivus:
        return 'Īnfīnītīvus persōnam nōn habet: -re, -rī, -isse, -ūrus esse.';
      case Mood.indicativus:
        return 'Indicātīvus rem ut factum dīcit.';
      default:
        return '';
    }
  }
}
