import 'dart:math';

import 'question.dart';

/// Une séance ciblée contient des preuves de la cible ET des contrastes.
/// Elle est admissible seulement si aucune réponse ne réussit toute la série.
/// Le contrôle de jouabilité et le combat partagent exactement cette séance.
class TargetPractice {
  TargetPractice(this.questions);
  final List<Question> questions;
  late final _byKey = {for (final q in questions) q.repetitionKey: q};

  static Set<String> answers(Question q) => {
    for (final c in q.choices) if (q.isCorrect(c.value)) c.value,
  };

  static String answerKey(Iterable<String> values) => (values.toList()..sort()).join('|');

  bool supports(bool Function(Question) proves) => questions.any(proves);

  Question draw({required Random rng, required String id, required bool Function(Question) proves,
    List<String> recentSurfaces = const [], List<String> recentLemmas = const [], List<String> recentQuestions = const [], Set<String> seenLemmas = const {}}) {
    final previous = recentQuestions.isNotEmpty ? [
      for (final key in recentQuestions.reversed.take(2)) _byKey[key],
    ] : [
      for (final surface in recentSurfaces.reversed.take(2))
        questions.where((q) => q.surface == surface).firstOrNull,
    ];
    var candidates = questions;
    // Deux réponses ayant un choix commun : sortir de ce choix, plutôt que
    // laisser gagner en pressant toujours le même bouton. Pas d'alternance fixe.
    if (previous.length == 2 && previous.every((q) => q != null)) {
      final common = answers(previous[0]!).intersection(answers(previous[1]!));
      final contrast = questions.where((q) => !answers(q).containsAll(common)).toList();
      if (common.isNotEmpty && contrast.isNotEmpty) candidates = contrast;
    }
    if (identical(candidates, questions)) {
      final focus = questions.where(proves).toList();
      final review = questions.where((q) => !proves(q)).toList();
      // La cible reste majoritaire ; les questions de contraste créditent
      // leur propre compétence, jamais artificiellement la cible de séance.
      if (previous.length == 2 && previous.every((q) => q != null && proves(q)) && review.isNotEmpty) {
        candidates = review;
      } else if (recentSurfaces.isEmpty || previous.every((q) => q != null && !proves(q)) || rng.nextDouble() < 0.65 || review.isEmpty) {
        candidates = focus;
      } else {
        candidates = review;
      }
    }
    var fresh = candidates.where((q) => !recentSurfaces.contains(q.surface)).toList();
    if (fresh.isEmpty) {
      final oldest = candidates.map((q) => recentSurfaces.lastIndexOf(q.surface)).reduce(min);
      fresh = candidates.where((q) => recentSurfaces.lastIndexOf(q.surface) == oldest).toList();
    }
    // Équilibrer les réponses avant les lexèmes : une catégorie qui contient
    // cent noms ne doit pas effacer celle qui n'en contient que dix.
    final groups = <String, List<Question>>{};
    for (final q in fresh) {
      (groups[answerKey(answers(q))] ??= []).add(q);
    }
    final group = groups.values.elementAt(rng.nextInt(groups.length));
    final q = weightedPick(group, [
      for (final q in group) (seenLemmas.contains(q.lemmaId) ? 1.0 : 2.0) * (recentLemmas.contains(q.lemmaId) ? 0.5 : 1.0),
    ], rng);
    return q.withChoices(q.choices, id: id);
  }
}

/// Échantillon borné, dédoublonné, d'une dimension. Les générateurs parcourent
/// d'abord les formes de la cible, puis les autres formes admissibles.
class TargetPracticeBuilder {
  final _questions = <Question>[];
  final _counts = <String, int>{};
  final _seen = <String>{};

  bool full(Set<String> rawAnswers) => (_counts[TargetPractice.answerKey(rawAnswers)] ?? 0) >= 24;

  void add(Question q, Set<String> rawAnswers) {
    final answers = TargetPractice.answers(q);
    if (answers.isEmpty || !q.choices.any((c) => !q.isCorrect(c.value))) return;
    final key = q.repetitionKey;
    if (!_seen.add(key)) return;
    _questions.add(q);
    final rawKey = TargetPractice.answerKey(rawAnswers);
    _counts[rawKey] = (_counts[rawKey] ?? 0) + 1;
  }

  TargetPractice? finish(bool Function(Question) proves) {
    if (!_questions.any(proves)) return null;
    var common = TargetPractice.answers(_questions.first);
    for (final q in _questions.skip(1)) {
      common = common.intersection(TargetPractice.answers(q));
    }
    if (common.isNotEmpty) return null;
    return TargetPractice(List.unmodifiable(_questions));
  }
}

class TargetQuestionCache {
  final Map<String, TargetPractice?> _structural = {};
  final Map<String, TargetPractice?> _exposed = {};
  String? _exposureKey;

  Map<String, TargetPractice?> forExposure(String? key) {
    if (key == null) return _structural;
    if (key != _exposureKey) {
      _exposureKey = key;
      _exposed.clear();
    }
    return _exposed;
  }

  static void remember(Map<String, TargetPractice?>? cache, String key, TargetPractice? practice) {
    if (cache == null) return;
    if (cache.length >= 128 && !cache.containsKey(key)) cache.remove(cache.keys.first);
    cache[key] = practice;
  }
}
