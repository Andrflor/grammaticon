/// Oracle d'équivalence entre les patrons de référence (banques pré-générées)
/// et le générateur actuel. Voir doc/arbor/02_corpus.md §2-3.
library;

import '../linguistics/model/adjective.dart';
import '../linguistics/model/grammar.dart';
import '../linguistics/model/nominal.dart';
import '../linguistics/model/noun.dart';
import '../linguistics/model/numeral.dart';
import '../linguistics/model/pronoun.dart';
import '../pedagogy/forum/forum_question_source.dart';
import '../pedagogy/forum/syntagma.dart';
import '../pedagogy/question_generator.dart';
import '../pedagogy/trials.dart';
import 'arbor.dart';
import 'diagnosis.dart';

/// Pourquoi un distracteur de référence n'est pas reproduit.
enum Rejection {
  /// La valeur est une lecture également correcte de la surface : la banque
  /// la comptait fausse à tort.
  lectioRecta,

  /// Aucun maillon ne distingue ce distracteur de la bonne réponse.
  diagnosisVacua,

  /// La valeur n'est pas offerte par le générateur pour cette carte.
  nonOblata,
}

class PatternResult {
  PatternResult(this.card, this.dimension, this.surface, {this.equivalent = false, this.reason = '', this.produced = 0, this.rejected = const {}});
  final String card, dimension, surface;
  final bool equivalent;
  final String reason;
  final int produced;
  final Map<String, Rejection> rejected;
}

class OracleReport {
  final List<PatternResult> results = [];
  int get patterns => results.length;
  int get equivalent => results.where((r) => r.equivalent).length;
  int get distractorsProduced => results.fold(0, (a, r) => a + r.produced);
  int get distractorsRejected => results.fold(0, (a, r) => a + r.rejected.length);
  Map<Rejection, int> get rejections {
    final out = <Rejection, int>{};
    for (final r in results) {
      for (final v in r.rejected.values) {
        out[v] = (out[v] ?? 0) + 1;
      }
    }
    return out;
  }

  String summary(String place) =>
      '$place: patrons=$patterns équivalents=$equivalent (${(100 * equivalent / (patterns == 0 ? 1 : patterns)).toStringAsFixed(1)} %) distracteurs produits=$distractorsProduced rejetés=$distractorsRejected ${rejections.map((k, v) => MapEntry(k.name, v))}';

  String markdown(String place, {bool sampled = false}) {
    final byCard = <String, List<PatternResult>>{};
    for (final r in results) {
      (byCard[r.card] ??= []).add(r);
    }
    final b = StringBuffer()
      ..writeln('# Couverture de la référence — $place${sampled ? ' (échantillon)' : ''}')
      ..writeln()
      ..writeln(summary(place))
      ..writeln()
      ..writeln('| Carte | Patrons | Équivalents | Distracteurs produits | Rejetés (lecture correcte / diagnostic vide / non offert) |')
      ..writeln('|---|---|---|---|---|');
    for (final e in byCard.entries) {
      final rs = e.value;
      final rej = <Rejection, int>{};
      for (final r in rs) {
        for (final v in r.rejected.values) {
          rej[v] = (rej[v] ?? 0) + 1;
        }
      }
      b.writeln('| ${e.key} | ${rs.length} | ${rs.where((r) => r.equivalent).length} | ${rs.fold(0, (a, r) => a + r.produced)} | ${rej[Rejection.lectioRecta] ?? 0} / ${rej[Rejection.diagnosisVacua] ?? 0} / ${rej[Rejection.nonOblata] ?? 0} |');
    }
    final failures = results.where((r) => !r.equivalent).take(40);
    if (failures.isNotEmpty) {
      b..writeln()..writeln('## Patrons non équivalents (extrait)')..writeln();
      for (final r in failures) {
        b.writeln('- ${r.card} · ${r.dimension} · «${r.surface}» — ${r.reason}');
      }
    }
    return b.toString();
  }
}

class Oracle {
  Oracle(this.arbor, this.dx, this.verbs, this.forum);
  final Arbor arbor;
  final Diagnostician dx;
  final QuestionGenerator verbs;
  final ForumQuestionSource forum;

  OracleReport run(Iterable<Map<String, Object?>> patterns) {
    final report = OracleReport();
    for (final p in patterns) {
      report.results.add(check(p));
    }
    return report;
  }

  PatternResult check(Map<String, Object?> p) {
    final cards = (p['cards'] as List).cast<String>();
    final cardId = cards.first.split('/').last;
    final dimName = p['dimension'] as String;
    final content = (p['content'] as List).cast<Map>();
    final surface = content.map((s) => s['text'] ?? '').join();
    final trial = Trials.maybe(cardId);
    final dim = Dimension.values.where((d) => d.name == dimName).firstOrNull;
    if (trial == null) return PatternResult(cardId, dimName, surface, reason: 'carte inconnue');
    if (dim == null) return PatternResult(cardId, dimName, surface, reason: 'dimension inconnue');
    final accepted = (p['accepted'] as List).cast<String>().toSet();
    final distractors = ((p['distractors'] as Map?) ?? const {}).keys.cast<String>().toList();
    if (trial.activity == Activity.amphitheatrum) return _verb(trial, dim, p, surface, accepted, distractors);
    return _nominal(trial, dim, p, content, surface, accepted, distractors);
  }

  // ---------------------------------------------------------------------------

  PatternResult _verb(Trial trial, Dimension dim, Map<String, Object?> p, String surface, Set<String> accepted, List<String> distractors) {
    final item = (p['item'] as String? ?? '').split('.').first;
    final comps = trial.components.map((c) => c.id).toList();
    final pool = verbs.pool(trial, comps);
    final entries = pool.where((e) => e.form.surface == surface && (item.isEmpty || e.verb.id == item)).toList();
    if (entries.isEmpty) return PatternResult(trial.id, dim.name, surface, reason: 'surface absente du pool de la carte');
    final e = entries.first;
    final values = verbs.poolValues(trial, comps)[dim] ?? const <String>{};
    // Valeurs correctes selon le générateur, avec leurs étiquettes.
    final correctValues = _verbCorrect(dim, e);
    if (correctValues.isEmpty) return PatternResult(trial.id, dim.name, surface, reason: 'dimension inapplicable');
    String label(String v) => dim == Dimension.analysis ? QuestionGenerator.analysisLabel(_analysisFromKey(e.verb.id, v)) : verbs.labelOf(dim, v);
    final correctLabels = correctValues.map(label).toSet();
    if (!correctLabels.containsAll(accepted)) {
      return PatternResult(trial.id, dim.name, surface, reason: 'réponses acceptées différentes : référence $accepted, générateur $correctLabels');
    }
    // Chaque distracteur : offert ? lecture correcte ? diagnostic ?
    // L'échelle offerte : toute la dimension (tous les temps, tous les modes…),
    // tout le lexique pour « quel verbe ? », tout le paradigme pour l'analyse.
    final scale = switch (dim) {
      Dimension.formaPlena || Dimension.analysis => _verbAllValues(dim, e),
      Dimension.lemma => {for (final v in verbs.analyzer.verbs) v.id},
      _ => {..._verbScale(dim), ...values},
    };
    final offered = <String, String>{for (final v in scale) label(v): v};
    final rejected = <String, Rejection>{};
    var produced = 0;
    for (final d in distractors) {
      final v = offered[d];
      if (v == null) {
        rejected[d] = Rejection.nonOblata;
        continue;
      }
      if (correctValues.contains(v)) {
        rejected[d] = Rejection.lectioRecta;
        continue;
      }
      final q = Question(
        id: 'oracle',
        trialId: trial.id,
        dimension: dim,
        prompt: dim.prompt,
        surface: surface,
        lemmaId: e.verb.id,
        choices: [for (final c in correctValues) Choice(c, label(c)), Choice(v, d)],
        correctValues: correctValues,
        skillIds: [trial.primarySkill],
        payload: VerbQuestionPayload(target: e.form, analyses: verbs.analyzer.analyze(surface)),
      );
      final diag = dx.diagnose(q, v);
      if (diag.observedElementa.isEmpty) {
        rejected[d] = Rejection.diagnosisVacua;
      } else {
        produced++;
      }
    }
    final ok = produced + rejected.values.where((r) => r == Rejection.lectioRecta).length == distractors.length;
    return PatternResult(trial.id, dim.name, surface, equivalent: ok, produced: produced, rejected: rejected, reason: ok ? '' : 'distracteurs non reproduits : ${rejected.entries.where((e) => e.value != Rejection.lectioRecta).map((e) => '${e.key} (${e.value.name})').join(', ')}');
  }

  Set<String> _verbCorrect(Dimension dim, PoolEntry e) {
    if (dim == Dimension.formaPlena) {
      final prim = verbs.analyzer.paradigmOf(e.verb.id).primary(e.form.analysis.selector);
      return prim == null ? {} : {prim.surface};
    }
    if (dim == Dimension.analysis) {
      return verbs.analyzer.analyze(e.form.surface).where((f) => f.analysis.lemmaId == e.verb.id).map((f) => QuestionGenerator.analysisKey(f.analysis)).toSet();
    }
    final out = <String>{};
    for (final f in verbs.analyzer.analyze(e.form.surface)) {
      final v = verbs.valueOf(dim, verbs.analyzer.verb(f.analysis.lemmaId), f.analysis);
      if (v != null) out.add(v);
    }
    return out;
  }

  static Set<String> _verbScale(Dimension dim) => switch (dim) {
    Dimension.persona => {for (final x in Person.values) x.key},
    Dimension.numerus => {for (final x in Numerus.values) x.key},
    Dimension.personaNumerus => {for (final p in Person.values) for (final n in Numerus.values) '${p.key}.${n.key}'},
    Dimension.tempus || Dimension.tempusSensus => {for (final x in Tense.values) x.key},
    Dimension.modus => {for (final x in Mood.values) x.key},
    Dimension.tempusModus => {for (final m in Mood.values) for (final t in Tense.values) QuestionGenerator.tempusModusKey(m, t)},
    Dimension.vox || Dimension.voxSensus => {for (final x in Voice.values) x.key},
    Dimension.coniugatio => {for (final x in Conjugation.values) x.key},
    Dimension.genus => {for (final x in Gender.values) x.key},
    Dimension.casus => {for (final x in Casus.values) x.key},
    Dimension.forma => {for (final x in FormKind.values) x.name},
    _ => const <String>{},
  };

  Set<String> _verbAllValues(Dimension dim, PoolEntry e) {
    final p = verbs.analyzer.paradigmOf(e.verb.id);
    if (dim == Dimension.formaPlena) return {for (final f in p.forms) if (f.isPrimary) f.surface};
    return {for (final f in p.forms) if (f.isPrimary) QuestionGenerator.analysisKey(f.analysis)};
  }

  dynamic _analysisFromKey(String lemmaId, String key) => verbs.analyzer.paradigmOf(lemmaId).forms.firstWhere((f) => QuestionGenerator.analysisKey(f.analysis) == key).analysis;

  // ---------------------------------------------------------------------------

  PatternResult _nominal(Trial trial, Dimension dim, Map<String, Object?> p, List<Map> content, String surface, Set<String> accepted, List<String> distractors) {
    final item = p['item'] as String? ?? '';
    final comps = trial.components.map((c) => c.id).toList();
    final pool = forum.pool(trial, comps);
    final highlight = content.where((s) => s['type'] == 'highlight').map((s) => s['text'] as String).firstOrNull;
    final shown = highlight ?? surface;
    final entries = pool.where((e) => e.surface == shown && (item.isEmpty || e.lexeme.id == item) && (highlight == null ? e.syntagma == null : e.syntagma != null && _syntagmaText(e.syntagma!) == surface.trim())).toList();
    if (entries.isEmpty) {
      final loose = pool.where((e) => e.surface == shown && (item.isEmpty || e.lexeme.id == item)).toList();
      if (loose.isEmpty) return PatternResult(trial.id, dim.name, surface, reason: 'surface absente du pool de la carte');
      entries.addAll(loose);
    }
    final e = entries.first;
    final correctValues = forum.correctValues(trial, dim, e);
    if (correctValues.isEmpty) return PatternResult(trial.id, dim.name, surface, reason: 'dimension inapplicable');
    String label(String v) => forum.labelOf(dim, v, item: e);
    final correctLabels = correctValues.map(label).toSet();
    if (!correctLabels.containsAll(accepted)) {
      return PatternResult(trial.id, dim.name, surface, reason: 'réponses acceptées différentes : référence $accepted, générateur $correctLabels');
    }
    final values = dim == Dimension.analysis ? {for (final f in forum.analyzer.formsOf(e.lexeme.id)) if (f.isPrimary) f.analysis.selector} : (forum.poolValues(trial, comps)[dim] ?? const <String>{});
    final scale = switch (dim) {
      Dimension.casus => {for (final x in Casus.values) x.key},
      Dimension.numerus => {for (final x in Numerus.values) x.key},
      Dimension.genus => {for (final x in Gender.values) x.key},
      Dimension.genusNumerus => {for (final g in Gender.values) for (final n in Numerus.values) '${g.key}.${n.key}'},
      Dimension.declinatio => {for (final x in Declension.values) x.key},
      Dimension.classis => const {'12', '3', 'pron'},
      Dimension.gradus => {for (final x in Degree.values) x.key},
      Dimension.persona => {for (final x in Person.values) x.key},
      Dimension.functio => {for (final x in Functio.values) x.key},
      Dimension.constructio => {for (final x in Constructio.values) x.key},
      Dimension.relatio => {for (final x in Relatio.values) x.key},
      Dimension.lemma || Dimension.correlativum => {for (final l in forum.analyzer.lexemes) l.id},
      Dimension.quodNomen => {...?e.syntagma?.candidates, if (e.syntagma?.head != null) e.syntagma!.head!},
      Dimension.valor => {for (var i = 1; i <= 2000; i++) '$i'},
      Dimension.forma => const {'declinabile', 'indeclinabile', 'relativum', 'interrogativum', 'indefinitum', 'personale', 'reflexivum', 'demonstrativum', 'correlativum', 'adverbium', 'adiectivum', 'nomen'},
      _ => const <String>{},
    };
    final offered = <String, String>{for (final v in {...scale, ...values, ...correctValues}) label(v): v};
    final rejected = <String, Rejection>{};
    var produced = 0;
    for (final d in distractors) {
      final v = offered[d];
      if (v == null) {
        rejected[d] = Rejection.nonOblata;
        continue;
      }
      if (correctValues.contains(v)) {
        rejected[d] = Rejection.lectioRecta;
        continue;
      }
      final q = Question(
        id: 'oracle',
        trialId: trial.id,
        dimension: dim,
        prompt: dim.prompt,
        surface: shown,
        lemmaId: e.lexeme.id,
        choices: [for (final c in correctValues) Choice(c, label(c)), Choice(v, d)],
        correctValues: correctValues,
        skillIds: [trial.primarySkill],
        payload: ForumQuestionPayload(target: e.form, analyses: forum.analyzer.analyze(shown), lexeme: e.lexeme, syntagma: e.syntagma),
      );
      final diag = dx.diagnose(q, v);
      if (diag.observedElementa.isEmpty) {
        rejected[d] = Rejection.diagnosisVacua;
      } else {
        produced++;
      }
    }
    final ok = produced + rejected.values.where((r) => r == Rejection.lectioRecta).length == distractors.length;
    return PatternResult(trial.id, dim.name, surface, equivalent: ok, produced: produced, rejected: rejected, reason: ok ? '' : 'distracteurs non reproduits : ${rejected.entries.where((e) => e.value != Rejection.lectioRecta).map((e) => '${e.key} (${e.value.name})').join(', ')}');
  }

  static String _syntagmaText(Syntagma s) => s.text.replaceAll(RegExp(r'[{}\[\]<>]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
}

// Les imports de modèles servent aux types des payloads ; gardés explicites.
// ignore: unused_element
final _keep = [NounEntry, AdjectiveEntry, PronounEntry, NumeralEntry, NominalForm];
