import 'dart:convert';

/// The runtime knows document structure and capabilities, never subject matter.
typedef Json = Map<String, dynamic>;
Json object(Object? value) {
  if (value is! Map) throw const FormatException('Expected an object');
  return Map<String, dynamic>.from(value);
}

List<String> strings(Object? value) => (value as List? ?? []).cast<String>();
List<Json> objects(Object? value) =>
    (value as List? ?? []).map(object).toList();
Object? freeze(Object? value) => value is Map
    ? Map<String, dynamic>.unmodifiable(
        value.map((k, v) => MapEntry(k as String, freeze(v))),
      )
    : value is List
    ? List<dynamic>.unmodifiable(value.map(freeze))
    : value;

class ContentNode {
  ContentNode(this.id, this.kind, this.data, this.parent, this.directory);
  final String id, kind, directory;
  final Json data;
  final ContentNode? parent;
  final List<ContentNode> children = [];
  String get address => parent == null ? id : '${parent!.address}/$id';
  int get price => (data['access']?['price'] as num? ?? 0).toInt();
  Json get requirements => object(data['access']?['requires'] ?? {'all': []});
}

class QuestionEntry {
  QuestionEntry(Json value) : data = freeze(value) as Json;
  final Json data;
  String get id => data['id'] as String;
  String get interaction => data['interaction'] as String;
  String get dimension => data['dimension'] as String;
  String get item => data['item'] as String? ?? id;
  String get assessment => data['assessment'] as String? ?? id;
  String get evidenceItem => data['evidenceItem'] as String? ?? item;
  List<Json> get choices => objects(data['choices']);
  List<String> get accepted => strings(data['accepted']);
  List<String> get skills => strings(data['skills']);
  Json outcome(String choice) => object(data['outcomes'][choice]);
}

class GameDesign {
  GameDesign._(this.root, this.path, this.read);
  final Json root;
  final String path;
  final Future<String> Function(String) read;
  final List<ContentNode> places = [];
  final Map<String, ContentNode> nodes = {};
  final Map<String, ContentNode> cards = {};
  final Map<String, Json> knowledge = {};
  final Map<String, Json> dimensions = {};
  final Map<String, Json> resources = {};
  final Map<String, Json> locales = {};
  final Map<String, List<QuestionEntry>> _questions = {};
  final Map<String, Set<String>> _questionIds = {};
  final Map<String, Object?> _documents = {};
  late Json rules;
  late Json pedagogy;

  /// Composition and prerequisites are different edges. Only components are
  /// evaluated; a prerequisite is never marked wrong by implication.
  Set<String> skillLeaves(String id) {
    final components = knowledge[id]?['aggregation'];
    if (components == null) return {id};
    return {
      for (final child in strings(components['skills'])) ...skillLeaves(child),
    };
  }

  Set<String> skillPrerequisites(String id) => {
    for (final prerequisite in strings(knowledge[id]?['requires'])) ...{
      prerequisite,
      ...skillPrerequisites(prerequisite),
    },
    for (final component in strings(knowledge[id]?['aggregation']?['skills']))
      ...skillPrerequisites(component),
  };

  Set<String> cardSkills(ContentNode card) => {
    for (final id in strings(card.data['skills'])) ...skillLeaves(id),
  };

  void _validateAssessedSkills(QuestionEntry question, Set<String> components) {
    if (question.skills.isEmpty ||
        question.skills.toSet().length != question.skills.length ||
        !components.containsAll(question.skills) ||
        question.skills.any((id) => knowledge[id]?['aggregation'] != null)) {
      throw FormatException(
        'Question must assess declared leaf skills ${question.id}',
      );
    }
    final group = question.data['selectionGroup'];
    if (group != null && (group is! String || group.isEmpty)) {
      throw FormatException('Invalid selection group ${question.id}');
    }
    if (question.data['evidenceItem'] != null &&
        (question.data['evidenceItem'] is! String ||
            question.evidenceItem.isEmpty)) {
      throw FormatException('Invalid evidence item ${question.id}');
    }
  }

  String get id => root['id'] as String;
  String get revision => root['revision'] as String;
  String get identity => '$id@$revision';
  String get base => path.substring(0, path.lastIndexOf('/') + 1);
  String get defaultLocale => root['defaultLocale'] as String;
  static const interactions = {'choice', 'highlightChoice', 'gapChoice'};

  static Future<GameDesign> load(
    String path,
    Future<String> Function(String) read,
  ) async {
    final root = object(jsonDecode(await read(path)));
    if (root['schemaVersion'] != 1) {
      throw const FormatException('Unsupported design schema');
    }
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(root['id'] as String? ?? '')) {
      throw const FormatException('Invalid design ID');
    }
    final d = GameDesign._(freeze(root) as Json, path, read);
    for (final key in ['id', 'revision', 'defaultLocale']) {
      if (root[key] is! String || (root[key] as String).isEmpty) {
        throw FormatException('Missing $key');
      }
    }
    for (final entry in object(root['locales']).entries) {
      d.locales[entry.key] = object(await d.document(entry.value as String));
    }
    if (!d.locales.containsKey(d.defaultLocale)) {
      throw const FormatException('Missing default locale');
    }
    final assets = object(await d.document(root['assets'] as String));
    for (final e in assets.entries) {
      final a = object(e.value);
      if (!{'image', 'audio', 'font'}.contains(a['type']) ||
          a['path'] is! String ||
          (a['path'] as String).contains('..')) {
        throw FormatException('Invalid asset ${e.key}');
      }
      d.resources[e.key] = a;
    }
    d.rules = object(await d.document(root['rules'] as String));
    d.pedagogy = object(await d.document(root['knowledge'] as String));
    for (final n in objects(d.pedagogy['nodes'])) {
      d._unique(d.knowledge, n, 'knowledge');
    }
    for (final n in objects(d.pedagogy['dimensions'])) {
      d._unique(d.dimensions, n, 'dimension');
    }
    for (final placeId in strings(root['places'])) {
      d.places.add(await d._node(placeId, 'place', null, 'places/$placeId'));
    }
    d.validate();
    return d;
  }

  void _unique(Map<String, Json> target, Json value, String kind) {
    final key = value['id'];
    if (key is! String || key.isEmpty || target.containsKey(key)) {
      throw FormatException('Invalid/duplicate $kind: $key');
    }
    target[key] = value;
  }

  Future<Object?> document(String relative) async {
    if (relative.startsWith('/') ||
        relative.contains('..') ||
        relative.contains('\\') ||
        !(relative.endsWith('.json') || relative.endsWith('.json.gz'))) {
      throw FormatException('Invalid design path $relative');
    }
    if (!_documents.containsKey(relative)) {
      _documents[relative] = freeze(jsonDecode(await read('$base$relative')));
    }
    return _documents[relative];
  }

  Future<ContentNode> _node(
    String id,
    String kind,
    ContentNode? parent,
    String directory,
  ) async {
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(id)) {
      throw FormatException('Invalid folder ID $id');
    }
    final data = object(await document('$directory/$kind.json'));
    if (data['id'] != id) {
      throw FormatException('Folder/document ID mismatch: $directory');
    }
    final node = ContentNode(id, kind, data, parent, directory);
    if (nodes.containsKey(node.address)) {
      throw FormatException('Duplicate node ${node.address}');
    }
    nodes[node.address] = node;
    if (kind == 'card') {
      cards[node.address] = node;
      if (data['questions'] is! String || data['lesson'] is! String) {
        throw FormatException('Missing card content: ${node.address}');
      }
    } else {
      for (final child in objects(data['children'])) {
        final type = child['kind'];
        if (!{'section', 'card'}.contains(type)) {
          throw FormatException('Unsupported child $type');
        }
        node.children.add(
          await _node(
            child['id'] as String,
            type,
            node,
            '$directory/${type}s/${child['id']}',
          ),
        );
      }
    }
    return node;
  }

  String text(Object? value, [String? locale]) {
    if (value == null) return '';
    if (value is String) return value;
    final v = object(value);
    if (v.containsKey('key')) {
      final key = v['key'] as String;
      final result =
          locales[locale ?? defaultLocale]?[key] ??
          locales[defaultLocale]?[key];
      if (result is! String) throw FormatException('Missing text $key');
      return result;
    }
    final result = v[locale ?? defaultLocale] ?? v[defaultLocale];
    if (result is! String) {
      throw const FormatException('Missing localized text');
    }
    return result;
  }

  String label(String key, [String? locale]) => text({'key': key}, locale);
  String asset(String id) {
    final path = resources[id]?['path'];
    if (path is! String) throw FormatException('Unknown asset $id');
    return path;
  }

  Future<List<dynamic>> lesson(ContentNode card) async =>
      (await document('${card.directory}/${card.data['lesson']}') as List);

  Future<List<QuestionEntry>> questions(ContentNode card) async {
    if (_questions.containsKey(card.address)) return _questions[card.address]!;
    final relative = '${card.directory}/${card.data['questions']}';
    // Question banks are lazy and evictable; navigation never constructs them.
    final raw = jsonDecode(await read('$base$relative'));
    final bank = raw is Map
        ? object(raw)
        : <String, dynamic>{'texts': {}, 'questions': raw};
    if (bank['index'] != null) {
      final index = objects(bank['index']).map(QuestionEntry.new).toList();
      final ids = index.map((q) => q.id).toSet();
      _questionIds[card.address] = ids;
      if (ids.length != index.length || index.isEmpty) {
        throw const FormatException('Invalid question index');
      }
      final components = cardSkills(card);
      for (final q in index) {
        _validateAssessedSkills(q, components);
        _reference(dimensions, q.dimension, 'dimension');
        for (final id in q.skills) {
          _reference(knowledge, id, 'skill');
        }
        validateRequirement(object(q.data['eligible'] ?? {'all': []}));
        if (q.data['next'] != null && !ids.contains(q.data['next'])) {
          throw const FormatException('Unknown sequence target');
        }
      }
      _acyclic({
        for (final q in index)
          q.id: [if (q.data['next'] != null) q.data['next'] as String],
      }, 'question sequences');
      _validateCompletionSequence(card, index);
      if (_questions.length >= 3) _questions.remove(_questions.keys.first);
      return _questions[card.address] = index;
    }
    final texts = object(bank['texts'] ?? {});
    Object? expand(Object? value) {
      if (value is Map && value.length == 1 && value.containsKey('ref')) {
        if (!texts.containsKey(value['ref'])) {
          throw FormatException('Missing stored text ${value['ref']}');
        }
        return texts[value['ref']];
      }
      if (value is Map) {
        return value.map((k, v) => MapEntry(k as String, expand(v)));
      }
      if (value is List) return value.map(expand).toList();
      return value;
    }

    final result = (bank['questions'] as List)
        .map((q) => QuestionEntry(object(expand(q))))
        .toList();
    validateQuestions(card, result);
    if (_questions.length >= 3) _questions.remove(_questions.keys.first);
    return _questions[card.address] = result;
  }

  final Map<String, Map<String, QuestionEntry>> _parts = {};
  Future<QuestionEntry> materialize(
    ContentNode card,
    QuestionEntry entry,
  ) async {
    if (entry.data['part'] == null) return entry;
    final part = entry.data['part'] as String;
    if (part.contains('/') ||
        part.contains('..') ||
        !part.endsWith('.json.gz')) {
      throw FormatException('Invalid question part $part');
    }
    final relative = '${card.directory}/$part';
    if (!_parts.containsKey(relative)) {
      final bank = object(jsonDecode(await read('$base$relative')));
      final texts = object(bank['texts']);
      Object? expand(Object? value) {
        if (value is Map && value.length == 1 && value.containsKey('ref')) {
          if (!texts.containsKey(value['ref'])) {
            throw FormatException('Missing stored text ${value['ref']}');
          }
          return texts[value['ref']];
        }
        if (value is Map) {
          return value.map((k, v) => MapEntry(k as String, expand(v)));
        }
        if (value is List) return value.map(expand).toList();
        return value;
      }

      final entries = objects(bank['questions'])
          .map((q) => QuestionEntry(object(expand(q))))
          .toList();
      validateQuestions(card, entries, sequenceIds: _questionIds[card.address]);
      if (_parts.length >= 3) _parts.remove(_parts.keys.first);
      _parts[relative] = {for (final q in entries) q.id: q};
    }
    final q = _parts[relative]![entry.id];
    if (q == null) throw FormatException('Index/part mismatch ${entry.id}');
    for (final key in [
      'id',
      'dimension',
      'item',
      'assessment',
      'skills',
      'evidenceItem',
      'selectionGroup',
      'eligible',
      'legacyKeys',
      'followUpOnly',
      'next',
    ]) {
      if (jsonEncode(q.data[key]) != jsonEncode(entry.data[key])) {
        throw FormatException('Index/part mismatch: ${entry.id}.$key');
      }
    }
    return q;
  }

  Future<List<dynamic>> help(String id) async {
    final data = object(await document(root['help'] as String));
    if (data[id] is! List) throw FormatException('Missing help $id');
    return data[id] as List;
  }

  void validate() {
    final theme = object(root['theme']);
    for (final key in [
      'primary',
      'accent',
      'surface',
      'background',
      'onBackground',
      'text',
      'error',
    ]) {
      if (!RegExp(r'^[a-fA-F0-9]{8}$')
          .hasMatch(theme['colors']?[key] as String? ?? '')) {
        throw FormatException('Invalid theme color $key');
      }
    }
    for (final key in [
      'spacing',
      'bodySize',
      'headingSize',
      'questionSize',
      'maxWidth',
    ]) {
      if (theme[key] is! num ||
          !(theme[key] as num).isFinite ||
          theme[key] < 0) {
        throw FormatException('Invalid theme metric $key');
      }
    }
    for (final key in ['bodyFont', 'headingFont']) {
      if (!resources.values.any(
        (r) => r['type'] == 'font' && r['family'] == theme[key],
      )) {
        throw FormatException('Unknown theme font ${theme[key]}');
      }
    }
    final levels = objects(rules['mastery']?['levels']);
    if (objects(rules['economy']?['levels']).length != levels.length) {
      throw const FormatException('Reward/mastery levels mismatch');
    }
    if (!{'up', 'down'}.contains(rules['economy']?['defeatRounding'])) {
      throw const FormatException('Invalid rounding policy');
    }
    final alpha = rules['mastery']?['alpha'];
    if (alpha is! num || alpha <= 0 || alpha > 1) {
      throw const FormatException('Invalid mastery smoothing');
    }
    for (final key in [
      'startingBalance',
      'assistedGain',
      'assistedLoss',
      'itemSaturation',
      'victoryBonus',
      'minBalance',
      'defeatTributeRatio',
      'defeatTributeMax',
    ]) {
      final value = rules['economy']?[key];
      if (value is! num || !value.isFinite || value < 0) {
        throw FormatException('Invalid reward rule $key');
      }
    }
    if (rules['economy']['itemSaturation'] < 1 ||
        rules['economy']['defeatTributeRatio'] > 1) {
      throw const FormatException('Invalid economy range');
    }
    for (final view in [
      object(root['presentation'] ?? {}),
      for (final n in nodes.values) object(n.data['presentation'] ?? {}),
    ]) {
      for (final key in [
        'background',
        'image',
        'hero',
        'opponent',
        'heroCorrect',
        'heroWrong',
        'heroVictory',
        'heroDefeat',
        'projectile',
        'correctSound',
        'wrongSound',
        'music',
      ]) {
        if (view[key] != null) asset(view[key] as String);
      }
      for (final cues in object(view['cues'] ?? {}).values) {
        for (final cue in objects(cues)) {
          asset(cue['sound'] as String);
          if (cue['delayMs'] is! int || cue['delayMs'] < 0) {
            throw const FormatException('Invalid sound cue delay');
          }
        }
      }
    }

    for (final target in object(
      root['migration']?['purchaseAliases'] ?? {},
    ).values) {
      if (target is! String || !nodes.containsKey(target)) {
        throw const FormatException('Invalid purchase migration target');
      }
    }
    for (final n in nodes.values) {
      if (n.price < 0) throw FormatException('Negative price ${n.address}');
      text(n.data['name']);
      text(n.data['subtitle']);
      validateRequirement(n.requirements);
      final view = object(n.data['presentation'] ?? {});
      for (final key in ['image', 'background', 'hero', 'opponent']) {
        if (view[key] != null) asset(view[key] as String);
      }
      if (n.kind == 'card') {
        if (n.data.containsKey('shuffleChoices') &&
            n.data['shuffleChoices'] is! bool) {
          throw FormatException('Invalid choice shuffle setting ${n.address}');
        }
        if (!{
          'weighted',
          'adaptive',
        }.contains(n.data['questionSelection'] ?? 'weighted')) {
          throw FormatException('Unsupported question selection ${n.address}');
        }
        if (n.data['questionSelection'] == 'adaptive' &&
            n.data['encounter']?['completion'] == 'sequence') {
          throw FormatException(
            'Adaptive selection cannot require a sequence ${n.address}',
          );
        }
        if (!{
          'target',
          'sequence',
        }.contains(n.data['encounter']?['completion'] ?? 'target')) {
          throw FormatException('Unsupported completion rule ${n.address}');
        }
        if ((n.data['encounter']?['target'] as num? ?? 0) <= 0 ||
            (n.data['encounter']?['lives'] as num? ?? 0) <= 0) {
          throw FormatException('Invalid encounter ${n.address}');
        }
        for (final s in strings(n.data['skills'])) {
          _reference(knowledge, s, 'skill');
          if (knowledge[s]?['aggregation'] != null &&
              knowledge[s]?['aggregation']?['level'] != 'minimum') {
            throw FormatException(
              'Evidence card needs complete skill composition ${n.address}',
            );
          }
        }
      }
    }
    for (final n in knowledge.values) {
      text(n['name']);
      if (n['masteryRequirements'] != null) {
        final requirements = object(n['masteryRequirements']);
        final items = requirements['successfulItems'];
        if (requirements.keys.any(
              (key) => !{'successfulItems', 'minItems'}.contains(key),
            ) ||
            (items != null &&
                (items is! List ||
                    items.isEmpty ||
                    items.any((item) => item is! String || item.isEmpty) ||
                    items.toSet().length != items.length)) ||
            (requirements['minItems'] != null &&
                (requirements['minItems'] is! int ||
                    requirements['minItems'] < 1))) {
          throw FormatException('Invalid mastery requirements ${n['id']}');
        }
      }
      if (n['parent'] != null) {
        _reference(knowledge, n['parent'] as String, 'parent');
      }
      for (final ref in strings(n['requires'])) {
        _reference(knowledge, ref, 'knowledge');
      }
      if (n['aggregation'] != null) {
        final children = strings(n['aggregation']['skills']);
        if (n['aggregation']['level'] != null &&
            n['aggregation']['level'] != 'minimum') {
          throw FormatException('Unsupported skill aggregation ${n['id']}');
        }
        if (children.isEmpty || children.toSet().length != children.length) {
          throw FormatException('Invalid skill composition ${n['id']}');
        }
        for (final ref in children) {
          _reference(knowledge, ref, 'skill component');
        }
      }
    }
    _acyclic({
      for (final n in knowledge.values)
        n['id'] as String: strings(n['aggregation']?['skills']),
    }, 'skill composition');
    _acyclic({
      for (final n in knowledge.values)
        n['id'] as String: strings(n['requires']),
    }, 'skill prerequisites');
    _acyclic({
      for (final n in knowledge.values)
        n['id'] as String: [
          ...strings(n['requires']),
          ...strings(n['aggregation']?['skills']),
        ],
    }, 'combined skill dependencies');
    _acyclic({
      for (final n in knowledge.values)
        n['id'] as String: [if (n['parent'] != null) n['parent'] as String],
    }, 'progress hierarchy');
    _acyclic({
      for (final n in nodes.values)
        n.address: [
          if (n.parent != null) n.parent!.address,
          ..._accessReferences(n.requirements),
        ],
    }, 'access');
    for (final target in objects(pedagogy['practiceSets'])) {
      for (final ref in objects(target['targets'])) {
        _reference(cards, ref['card'] as String, 'practice card');
        if (ref['questions'] == null && ref['allQuestions'] != true) {
          throw const FormatException(
            'Practice link needs explicit question IDs or allQuestions',
          );
        }
      }
    }
    final selection = object(rules['selection']);
    if (selection.containsKey('unseenQuestionBoost')) {
      final value = selection['unseenQuestionBoost'];
      if (value is! num || !value.isFinite || value <= 0) {
        throw const FormatException('Invalid unseen-question weight');
      }
    }
    for (final key in [
      'unknownWeight',
      'weakScale',
      'sameQuestionBoost',
      'linkedQuestionBoost',
      'retireAfter',
      'maxErrors',
      'maxObservations',
    ]) {
      final value = selection[key];
      if (value is! num || !value.isFinite || value < 0) {
        throw FormatException('Invalid selection rule $key');
      }
    }
    for (final key in ['retireAfter', 'maxErrors', 'maxObservations']) {
      if (selection[key] is! int || selection[key] <= 0) {
        throw FormatException('Invalid positive count $key');
      }
    }
    if (levels.isEmpty) throw const FormatException('Missing mastery levels');
    for (final l in levels) {
      text(l['name']);
    }
    for (final key in requiredLabels) {
      label(key);
    }
  }

  static const requiredLabels = [
    'actions.back',
    'actions.start',
    'actions.continue',
    'actions.help',
    'actions.close',
    'actions.pause',
    'actions.resume',
    'actions.leave',
    'actions.buy',
    'actions.settings',
    'actions.progress',
    'actions.errors',
    'actions.export',
    'actions.import',
    'actions.save',
    'actions.cancel',
    'state.locked',
    'state.empty',
    'state.correct',
    'state.incorrect',
    'state.victory',
    'state.defeat',
    'state.loading',
    'labels.currency',
    'labels.lives',
    'labels.target',
    'labels.price',
    'labels.requirements',
    'labels.observed',
    'labels.hypotheses',
    'labels.related',
    'labels.responseTime',
    'labels.correctAnswers',
    'labels.yourAnswer',
    'labels.lesson',
    'labels.language',
    'labels.sound',
    'labels.music',
    'labels.volume',
    'labels.reducedMotion',
    'labels.balance',
    'labels.successes',
    'labels.failures',
    'labels.completed',
    'labels.notMeasured',
    'labels.history',
    'labels.importData',
  ];
  void validateRequirement(Json rule, [int depth = 0]) {
    if (depth > 32) throw const FormatException('Requirement nesting too deep');
    if (rule.length != 1) {
      throw const FormatException('One requirement operator expected');
    }
    final key = rule.keys.single, value = rule.values.single;
    if (key == 'all' || key == 'any') {
      for (final child in objects(value)) {
        validateRequirement(child, depth + 1);
      }
    } else if (key == 'not') {
      validateRequirement(object(value), depth + 1);
    } else if (key == 'mastered') {
      _reference(cards, value as String, key);
    } else if (key == 'completed') {
      _reference(cards, value as String, key);
    } else if (key == 'unlocked') {
      _reference(nodes, value as String, key);
    } else if (key == 'skill') {
      final v = object(value);
      _reference(knowledge, v['id'] as String, 'skill');
      if ((v['minLevel'] as int? ?? 0) < 0 ||
          (v['minLevel'] as int? ?? 0) >=
              objects(rules['mastery']?['levels']).length) {
        throw const FormatException('Invalid level');
      }
    } else if (key == 'count') {
      final v = object(value);
      _reference(nodes, v['card'] as String, 'completion');
      if (v['atLeast'] is! int || v['atLeast'] < 0) {
        throw const FormatException('Invalid completion count');
      }
    } else {
      throw FormatException('Unsupported requirement $key');
    }
  }

  Iterable<String> _accessReferences(Json rule) sync* {
    for (final e in rule.entries) {
      if (e.key == 'unlocked' || e.key == 'completed' || e.key == 'mastered') {
        yield e.value as String;
      }
      if (e.key == 'all' || e.key == 'any') {
        for (final c in objects(e.value)) {
          yield* _accessReferences(c);
        }
      }
      if (e.key == 'not') yield* _accessReferences(object(e.value));
    }
  }

  void validateQuestions(
    ContentNode card,
    List<QuestionEntry> questions, {
    Set<String>? sequenceIds,
  }) {
    if (questions.isEmpty) {
      throw FormatException('Empty question bank ${card.address}');
    }
    final components = cardSkills(card);
    final ids = <String>{};
    for (final q in questions) {
      if (q.id.isEmpty || !ids.add(q.id)) {
        throw FormatException('Invalid or duplicate question ${q.id}');
      }
      if (!interactions.contains(q.interaction)) {
        throw FormatException('Unsupported interaction ${q.interaction}');
      }
      _reference(dimensions, q.dimension, 'dimension');
      final choices = q.choices.map((c) => c['id'] as String).toSet();
      if (q.data.containsKey('shuffleChoices') &&
          q.data['shuffleChoices'] is! bool) {
        throw FormatException(
          'Invalid choice shuffle setting ${card.address}/${q.id}',
        );
      }
      if (choices.length < 2 ||
          choices.length != q.choices.length ||
          q.accepted.isEmpty ||
          !choices.containsAll(q.accepted) ||
          q.accepted.length == choices.length) {
        throw FormatException('Invalid answers ${q.id}');
      }
      if (q.skills.isEmpty || q.skills.toSet().length != q.skills.length) {
        throw FormatException('Invalid evaluated skills ${q.id}');
      }
      for (final ref in [...q.skills, ...strings(q.data['requires'])]) {
        _reference(knowledge, ref, 'knowledge');
      }
      _validateAssessedSkills(q, components);
      validateRequirement(object(q.data['eligible'] ?? {'all': []}));
      if (q.data['prompt'] == null || text(q.data['prompt']).trim().isEmpty) {
        throw FormatException('Missing question prompt ${q.id}');
      }
      for (final c in q.choices) {
        text(c['text']);
        final o = q.outcome(c['id'] as String);
        text(o['feedback']);
        for (final ref in [
          ...strings(o['observed']),
          ...strings(o['hypotheses']),
        ]) {
          _reference(knowledge, ref, 'diagnosis');
        }
        final failed = strings(o['observed']);
        final accepted = q.accepted.contains(c['id']);
        if ((accepted && failed.isNotEmpty) ||
            (!accepted && failed.isEmpty) ||
            !q.skills.toSet().containsAll(failed)) {
          throw FormatException(
            'Outcome must identify assessed failed skills ${q.id}',
          );
        }
        for (final set in strings(o['practice'])) {
          if (!objects(pedagogy['practiceSets']).any((s) => s['id'] == set)) {
            throw FormatException('Missing explicit practice link $set');
          }
        }
      }
      for (final segment in objects(q.data['content'])) {
        if (!{'text', 'highlight', 'gap', 'image'}.contains(segment['type'])) {
          throw const FormatException('Unsupported content segment');
        }
        if (segment['type'] == 'image') {
          asset(segment['asset'] as String);
        } else {
          text(segment['text']);
        }
      }
      if (q.interaction == 'gapChoice' &&
          !objects(q.data['content']).any((s) => s['type'] == 'gap')) {
        throw const FormatException('Missing gap');
      }
      if (q.interaction == 'highlightChoice' &&
          !objects(q.data['content']).any((s) => s['type'] == 'highlight')) {
        throw const FormatException('Missing highlight');
      }
    }
    for (final q in questions) {
      if (q.data['next'] != null &&
          !(sequenceIds ?? ids).contains(q.data['next'])) {
        throw FormatException('Unknown next question ${q.data['next']}');
      }
    }
    if (sequenceIds == null) _validateCompletionSequence(card, questions);
    _acyclic({
      for (final q in questions)
        q.id: [if (q.data['next'] != null) q.data['next'] as String],
    }, 'question sequence');
  }

  void _validateCompletionSequence(
    ContentNode card,
    List<QuestionEntry> questions,
  ) {
    if (card.data['questionSelection'] == 'adaptive' &&
        questions.any(
          (q) => q.data['next'] != null || q.data['followUpOnly'] == true,
        )) {
      throw FormatException(
        'Adaptive selection needs independent entries: ${card.address}',
      );
    }
    if (card.data['encounter']['completion'] == 'sequence') {
      final starts = questions
          .where((q) => q.data['followUpOnly'] != true)
          .toList();
      if (starts.length != 1) {
        throw FormatException('Sequence needs one start: ${card.address}');
      }
      final indexed = {for (final q in questions) q.id: q};
      final seen = <String>{};
      String? id = starts.single.id;
      while (id != null && seen.add(id)) {
        id = indexed[id]!.data['next'] as String?;
      }
      if (id != null || seen.length != questions.length) {
        throw FormatException('Incomplete or cyclic sequence: ${card.address}');
      }
      if (card.data['encounter']['target'] > questions.length) {
        throw FormatException('Impossible sequence target: ${card.address}');
      }
    }
  }

  void _reference(Map target, String id, String label) {
    if (!target.containsKey(id)) throw FormatException('Unknown $label: $id');
  }

  void _acyclic(Map<String, List<String>> graph, String name) {
    final done = <String>{}, active = <String>{};
    void visit(String id) {
      if (done.contains(id)) return;
      if (!active.add(id)) throw FormatException('Cycle in $name: $id');
      for (final ref in graph[id] ?? <String>[]) {
        visit(ref);
      }
      active.remove(id);
      done.add(id);
    }

    for (final id in graph.keys) {
      visit(id);
    }
  }
}
