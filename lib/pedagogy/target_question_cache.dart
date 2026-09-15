import 'question.dart';

/// Témoins déjà validés pour une cible. Le contrôle de jouabilité et le
/// générateur de combat partagent les mêmes sources et donc ces témoins.
/// Un nouveau tirage peut varier les exemples, sans échouer alors qu'un
/// exemple admissible vient d'être trouvé par l'Iter.
class TargetQuestionCache {
  final Map<String, Question> _structural = {};
  final Map<String, Question> _exposed = {};
  String? _exposureKey;

  Map<String, Question> forExposure(String? key) {
    if (key == null) return _structural;
    if (key != _exposureKey) {
      _exposureKey = key;
      _exposed.clear();
    }
    return _exposed;
  }
}
