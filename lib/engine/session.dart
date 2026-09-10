import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'design.dart';

/// Applies declared policies to opaque IDs. No content is generated here.
class GameSession extends ChangeNotifier {
  GameSession(
    this.design,
    Json saved,
    this.persist, {
    Random? random,
    DateTime Function()? clock,
  }) : random = random ?? Random(),
       clock = clock ?? DateTime.now,
       state = _restore(design, saved);
  final GameDesign design;
  final Future<void> Function(String) persist;
  final Random random;
  final DateTime Function() clock;
  Json state;
  bool busy = false;
  final Stopwatch _timer = Stopwatch();
  Json get rules => design.rules;
  Json get selection => object(rules['selection']);
  Json get mastery => object(rules['mastery']);
  Json get economy => object(rules['economy']);
  Json? get encounter =>
      state['encounter'] == null ? null : object(state['encounter']);
  QuestionEntry? get question => encounter?['question'] == null
      ? null
      : QuestionEntry(object(encounter!['question']));
  String get locale =>
      state['settings']?['locale'] as String? ?? design.defaultLocale;
  int get balance => (state['balance'] as num).toInt();
  String label(String key) => design.label(key, locale);
  String text(Object? value) => design.text(value, locale);
  String get exportJson => jsonEncode(state);

  static Json _restore(GameDesign d, Json saved) {
    if (saved.isEmpty) {
      return {
        'schemaVersion': 1,
        'designId': d.id,
        'masteryRevision': d.root['masteryRevision'],
        'balance': d.rules['economy']['startingBalance'],
        'purchased': <String>[],
        'skills': <String, dynamic>{},
        'errors': <String, dynamic>{},
        'observations': <dynamic>[],
        'completed': <String, dynamic>{},
        'transaction': 0,
        'settings': {
          ...object(d.root['settings'] ?? {}),
          'locale': d.defaultLocale,
        },
        'seenLessons': <String>[],
        'daily': <String, dynamic>{},
        'statistics': <String, dynamic>{},
      };
    }
    if (saved['schemaVersion'] == 1) {
      if (saved['designId'] != d.id) {
        throw const FormatException('Save belongs to another design');
      }
      final restored = object(jsonDecode(jsonEncode(saved)));
      if (d.root['masteryRevision'] != null &&
          restored['masteryRevision'] != d.root['masteryRevision']) {
        _retireCoarseEvidence(d, restored);
        restored['masteryRevision'] = d.root['masteryRevision'];
      }
      final purchaseAliases = object(
        d.root['migration']?['purchaseAliases'] ?? {},
      );
      restored['purchased'] = {
        ...strings(restored['purchased']),
        for (final address in strings(restored['purchased']))
          if (purchaseAliases.containsKey(address))
            purchaseAliases[address] as String,
      }.toList();
      final battle = restored['encounter'];
      if (battle != null &&
          (!d.cards.containsKey(battle['card']) ||
              strings(battle['question']?['skills']).any(
                (id) =>
                    !d.knowledge.containsKey(id) ||
                    d.knowledge[id]?['aggregation'] != null,
              ))) {
        restored['retiredEncounters'] = [
          ...objects(restored['retiredEncounters']),
          object(battle),
        ];
        restored.remove('encounter');
      }
      final practiceIds = objects(d.pedagogy['practiceSets'])
          .map((set) => set['id'])
          .toSet();
      final errors = object(restored['errors']);
      final retired = object(restored['retiredErrors'] ?? {});
      for (final key in errors.keys.toList()) {
        if (!d.cards.containsKey(errors[key]['card']) ||
            strings(errors[key]['practice'])
                .any((id) => !practiceIds.contains(id))) {
          retired[key] = errors.remove(key);
        }
      }
      restored['errors'] = errors;
      if (retired.isNotEmpty) restored['retiredErrors'] = retired;
      return restored;
    }
    if (saved.containsKey('schemaVersion')) {
      throw const FormatException('Unsupported save schema');
    }
    final m = object(d.root['migration'] ?? {});
    if (m.isEmpty) {
      throw const FormatException('No legacy save migration declared');
    }
    final fields = object(m['fields']);
    final sourceId = saved[m['identityField']];
    if (sourceId != null && sourceId != d.id) {
      throw const FormatException('Save belongs to another design');
    }
    final next = _restore(d, {});
    // The complete original remains available, including fields not used by this design.
    next['legacy'] = saved;
    for (final e in fields.entries) {
      if (saved[e.value] != null) next[e.key] = saved[e.value];
    }
    final recordFields = object(m['skillFields'] ?? {});
    next['skills'] = <String, dynamic>{};
    for (final e in object(saved[m['skillsField']] ?? {}).entries) {
      final old = object(e.value), record = <String, dynamic>{};
      for (final f in recordFields.entries) {
        if (old[f.value] != null) record[f.key] = old[f.value];
      }
      record['recent'] = [
        for (final r in objects(old['recent']))
          {
            for (final f in object(m['recentFields'] ?? {}).entries)
              if (r[f.value] != null) f.key: r[f.value],
            'assisted': strings(m['recentAssistedValues'])
                .contains(r[m['recentAssistanceField']]),
          },
      ];
      record['legacy'] = old;
      next['skills'][e.key] = record;
    }
    final aliases = object(m['nodeAliases'] ?? {});
    next['purchased'] = strings(next['purchased'])
        .map((id) => aliases[id] ?? id)
        .toList();
    next['seenLessons'] = strings(next['seenLessons'])
        .map((id) => aliases[id] ?? id)
        .toList();
    final settingFields = object(m['settingFields'] ?? {});
    final oldSettings = object(saved[m['settingsField']] ?? {});
    for (final f in settingFields.entries) {
      if (oldSettings[f.value] != null) {
        next['settings'][f.key] = oldSettings[f.value];
      }
    }
    final oldErrors = object(saved[m['errorsField']] ?? {});
    final sourceErrors = oldErrors[m['errorEntriesField']];
    final entries = sourceErrors is List
        ? <String, dynamic>{
            for (final e in sourceErrors)
              (strings(m['errorKeyParts']).length > 1 &&
                          e[strings(m['errorKeyParts'])[1]] != null
                      ? strings(m['errorKeyParts'])
                            .map((f) => e[f] ?? '')
                            .join('|')
                      : e[m['errorKeyField']] as String):
                  e,
          }
        : object(sourceErrors ?? {});
    final errorFields = object(m['errorFields'] ?? {});
    for (final e in entries.entries) {
      final record = <String, dynamic>{
        'legacyKey': e.key,
        'legacy': e.value,
        'practice': <String>[],
      };
      for (final f in errorFields.entries) {
        if (e.value[f.value] != null) record[f.key] = e.value[f.value];
      }
      next['errors'][e.key] = record;
    }
    next['legacyEncounter'] = saved[m['encounterField']];
    if (d.root['masteryRevision'] != null) _retireCoarseEvidence(d, next);
    return next;
  }

  static void _retireCoarseEvidence(GameDesign d, Json saved) {
    final retired = strings(d.root['migration']?['retiredSkillIds']).toSet();
    bool affected(String id) => retired.isEmpty || retired.contains(id);
    final records = object(saved['skills']);
    final archive = <String, dynamic>{};
    for (final id in records.keys.toList()) {
      if (affected(id)) archive[id] = records.remove(id);
    }
    saved['skills'] = records;
    final errors = object(saved['errors']);
    final oldErrors = <String, dynamic>{};
    for (final key in errors.keys.toList()) {
      if (strings(errors[key]['question']?['skills']).any(affected)) {
        oldErrors[key] = errors.remove(key);
      }
    }
    saved['errors'] = errors;
    final battle = saved['encounter'];
    final oldBattle =
        battle != null && strings(battle['question']?['skills']).any(affected);
    saved['previousMastery'] = {
      'revision': saved['masteryRevision'],
      if (saved['previousMastery'] != null)
        'previous': saved['previousMastery'],
      'skills': archive,
      'errors': oldErrors,
      if (oldBattle) 'encounter': battle,
    };
    if (oldBattle) saved.remove('encounter');
  }

  Json skill(String id) => object(state['skills']?[id] ?? {});
  double? progress(String id) {
    if (design.knowledge[id]?['aggregation'] != null) {
      final values = design.skillLeaves(id).map(progress).toList();
      if (values.every((value) => value == null)) return null;
      return values.map((value) => value ?? 0.0).reduce(min);
    }
    final record = skill(id);
    var value = estimate(record, skillId: id);
    if (value == null) return null;
    final minimumItems =
        (design.knowledge[id]?['masteryRequirements']?['minItems'] ??
                objects(mastery['levels']).last['minItems'] ??
                0)
            as num;
    if (minimumItems > 0) {
      value = min(value, _successfulItems(record).length / minimumItems);
    }
    final required = strings(
      design.knowledge[id]?['masteryRequirements']?['successfulItems'],
    );
    if (required.isEmpty) return value;
    final successful = _successfulItems(record);
    final coverage =
        required.where(successful.contains).length / required.length;
    return min(value, coverage);
  }

  int level(String id, {bool rewards = false}) {
    final aggregate = design.knowledge[id]?['aggregation'];
    if (aggregate != null) {
      return design
          .skillLeaves(id)
          .map((leaf) => _level(skill(leaf), skillId: leaf, rewards: rewards))
          .reduce(min);
    }
    return _level(skill(id), skillId: id, rewards: rewards);
  }

  double? estimate(Json record, {String? skillId}) {
    if (record['estimate'] == null) return null;
    var value = (record['estimate'] as num).toDouble();
    final last = record['last'];
    final levels = objects(mastery['levels']);
    final index = _level(record, skillId: skillId, applyDecay: false);
    final grace = (levels[index]['graceDays'] as num? ?? 0).toInt();
    if (last is num && grace > 0) {
      final days = clock()
          .difference(DateTime.fromMillisecondsSinceEpoch(last.toInt()))
          .inDays;
      final daysPracticed = strings(record['days']).length;
      final multiplier = pow(
        2,
        min(max(0, daysPracticed - 1), mastery['graceDoublings'] as int? ?? 0),
      );
      value -=
          max(0, days - grace * multiplier) *
          (mastery['decayPerDay'] as num? ?? 0);
    }
    return value.clamp(0, 1);
  }

  Set<String> _successfulItems(Json record) {
    if (record['successfulItems'] != null) {
      return strings(record['successfulItems']).toSet();
    }
    // Older saves retain only a bounded recent history. Unrecorded success is
    // not evidence; preserve the successful items that can still be verified.
    final result = <String>{};
    for (final r in objects(record['recent'])) {
      if (r['assisted'] == true || r['item'] is! String) continue;
      if (r['correct'] == true) {
        result.add(r['item']);
      } else {
        result.remove(r['item']);
      }
    }
    return result;
  }

  int _level(
    Json record, {
    String? skillId,
    bool rewards = false,
    bool applyDecay = true,
  }) {
    final count =
        (record['correct'] as num? ?? 0) + (record['wrong'] as num? ?? 0);
    final est = rewards
        ? max(
            (record['highWater'] as num? ?? 0),
            (record['estimate'] as num? ?? 0),
          )
        : (applyDecay
              ? estimate(record, skillId: skillId)
              : record['estimate'] as num?);
    if (count == 0 || est == null) return 0;
    final levels = objects(mastery['levels']);
    var result = 0;
    for (var i = 0; i < levels.length; i++) {
      // Coverage is authored per skill. Reward saturation keeps using the
      // existing observation-based levels, independently of this mastery requirement.
      if (!rewards && i == levels.length - 1 && skillId != null) {
        final required = strings(
          design.knowledge[skillId]?['masteryRequirements']?['successfulItems'],
        );
        if (required.isNotEmpty &&
            !_successfulItems(record).containsAll(required)) {
          continue;
        }
      }
      final l = levels[i];
      var minimumItems = l['minItems'] as num? ?? 0;
      if (!rewards && i == levels.length - 1) {
        minimumItems =
            design.knowledge[skillId]?['masteryRequirements']?['minItems']
                as num? ??
            minimumItems;
      }
      final recent = objects(record['recent'])
          .where((r) => r['assisted'] != true)
          .toList();
      final rate = recent.isEmpty
          ? 0.0
          : recent.where((r) => r['correct'] == true).length / recent.length;
      if (est >= (l['threshold'] as num? ?? 0) &&
          count >= (l['minObservations'] as num? ?? 0) &&
          (rewards
                  ? strings(record['items']).length
                  : _successfulItems(record).length) >=
              minimumItems &&
          (rewards || rate >= (l['minRecentSuccess'] as num? ?? 0))) {
        result = i;
      }
    }
    return result;
  }

  bool meets(Json rule, [Set<String>? evaluating]) {
    final active = evaluating ?? <String>{};
    final e = rule.entries.single;
    return switch (e.key) {
      'all' => objects(e.value).every((r) => meets(r, active)),
      'any' => objects(e.value).any((r) => meets(r, active)),
      'not' => !meets(object(e.value), active),
      'unlocked' => unlocked(design.nodes[e.value]!, active),
      'completed' => cardMastered(design.cards[e.value]!),
      'mastered' => cardMastered(design.cards[e.value]!),
      'count' =>
        (state['completed']?[e.value['card']] as num? ?? 0) >=
            e.value['atLeast'],
      'skill' =>
        level(e.value['id']) >= (e.value['minLevel'] as int? ?? 0) &&
            observations(e.value['id']) >=
                (e.value['minObservations'] as num? ?? 0),
      _ => throw FormatException('Unsupported requirement ${e.key}'),
    };
  }

  bool cardMastered(ContentNode card) =>
      strings(card.data['skills']).isNotEmpty &&
      strings(card.data['skills'])
          .every((id) => level(id) == objects(mastery['levels']).length - 1);

  num observations(String id) {
    if (design.knowledge[id]?['aggregation'] != null) {
      return design.skillLeaves(id).map(observations).reduce(min);
    }
    return (skill(id)['correct'] as num? ?? 0) +
        (skill(id)['wrong'] as num? ?? 0);
  }

  bool unlocked(ContentNode node, [Set<String>? evaluating]) {
    final active = {...?evaluating};
    if (!active.add(node.address)) return false;
    if (node.parent != null && !unlocked(node.parent!, active)) return false;
    if (strings(state['purchased']).contains(node.address)) return true;
    return node.price == 0 && meets(node.requirements, active);
  }

  bool purchasable(ContentNode node) =>
      !unlocked(node) &&
      (node.parent == null || unlocked(node.parent!)) &&
      meets(node.requirements) &&
      balance >= node.price;
  Future<void> buy(ContentNode node) async {
    if (busy || !purchasable(node)) return;
    final next = _copy();
    next['balance'] = balance - node.price;
    next['purchased'] = [...strings(next['purchased']), node.address];
    next['transaction'] = (next['transaction'] as int) + 1;
    await _commit(next);
  }

  /// Resolves explicit routes and cards assessing the same failed leaves.
  final Map<String, List<Json>> _practiceCache = {};
  final Map<String, Map<String, Set<String>?>> _practiceMembership = {};
  List<Json> practiceTargets(Json error) {
    final failed = strings(error['outcome']?['observed']).toSet();
    final declared = objects(design.pedagogy['practiceSets']);
    final result = <String, Json>{};
    for (final id in strings(error['practice'])) {
      for (final target in (_practiceCache[id] ??= objects(
        declared.firstWhere((set) => set['id'] == id)['targets'],
      ))) {
        result[target['card']] = target;
      }
    }
    for (final card in design.cards.values) {
      final matching = strings(card.data['skills'])
          .expand(design.skillLeaves)
          .where(failed.contains)
          .toSet();
      if (matching.isNotEmpty) {
        result.putIfAbsent(
          card.address,
          () => {'card': card.address, 'skills': matching.toList()},
        );
      }
    }
    return result.values.toList();
  }

  late final Set<String> _assessableSkills = {
    for (final card in design.cards.values) ...design.cardSkills(card),
  };
  final Map<String, Set<String>> _dependencyLeaves = {};

  Set<String> _requiredLeaves(String id) => _dependencyLeaves.putIfAbsent(
    id,
    () => {
      ...design.skillLeaves(id),
      for (final prerequisite in design.skillPrerequisites(id))
        ...design.skillLeaves(prerequisite),
    }.intersection(_assessableSkills),
  );

  double _readiness(QuestionEntry q) {
    final required = {
      for (final id in strings(q.data['requires'])) ..._requiredLeaves(id),
      for (final skill in q.skills)
        for (final id in strings(design.knowledge[skill]?['requires']))
          ..._requiredLeaves(id),
    }..removeAll(q.skills);
    if (required.isEmpty) return 1;
    // This is a selection preference, not mastery: a known grammatical
    // prerequisite should help even while a word has not yet been practiced.
    return required.fold<double>(0, (sum, id) => sum + (progress(id) ?? 0)) /
        required.length;
  }

  double weight(ContentNode card, QuestionEntry q, {String? encounterId}) {
    final estimates = q.skills.map(progress).toList();
    final est = estimates.any((v) => v == null)
        ? null
        : estimates.cast<double>().reduce(min);
    var result = est == null
        ? (selection['unknownWeight'] as num).toDouble()
        : 1.0 + (selection['weakScale'] as num) * (1 - est);
    for (final e in object(state['errors']).values) {
      final error = object(e);
      if (error['encounterId'] == encounterId) continue;
      if (strings(error['outcome']?['observed']).any(q.skills.contains)) {
        result *= (selection['linkedQuestionBoost'] as num).toDouble();
        break;
      }
      if (error['assessment'] == q.assessment ||
          strings(q.data['legacyKeys']).contains(error['legacyKey'])) {
        result *= (selection['sameQuestionBoost'] as num).toDouble();
        break;
      }
      if (strings(error['practice']).any((id) {
        final members = _practiceMembership.putIfAbsent(
          id,
          () => {
            for (final t in practiceTargets({
              'practice': [id],
            }))
              t['card'] as String: t['allQuestions'] == true
                  ? null
                  : strings(t['questions']).toSet(),
          },
        );
        return members.containsKey(card.address) &&
            (members[card.address] == null ||
                members[card.address]!.contains(q.id));
      })) {
        result *= (selection['linkedQuestionBoost'] as num).toDouble();
        break;
      }
    }
    if (card.data['questionSelection'] == 'adaptive') {
      if (q.skills.any(
        (id) => !_successfulItems(skill(id)).contains(q.evidenceItem),
      )) {
        result *= (selection['unprovenItemBoost'] as num? ?? 2);
      }
      final history = object(
        state['questionResults']?[card.address]?[q.id] ?? {},
      );

      final correct = history['correct'] as num? ?? 0;
      final wrong = history['wrong'] as num? ?? 0;
      if (correct + wrong == 0) {
        result *= (selection['unseenQuestionBoost'] as num? ?? 2);
      } else {
        result /= 1 + correct / (1 + wrong);
      }
    }
    // Prerequisites guide selection without claiming evidence for them. Keep
    // questions available even before vocabulary practice at section end.
    return result * (0.25 + 0.75 * _readiness(q));
  }

  QuestionEntry _select(
    ContentNode card,
    List<QuestionEntry> bank,
    Json battle,
    Json next,
  ) {
    final allowed = bank
        .where(
          (q) =>
              q.data['followUpOnly'] != true &&
              meets(object(q.data['eligible'] ?? {'all': []})),
        )
        .toList();
    if (allowed.isEmpty) {
      throw StateError('No eligible authored questions for ${card.address}');
    }
    final adaptive = card.data['questionSelection'] == 'adaptive';
    final recent = adaptive
        ? strings(next['recentQuestions']?[card.address])
        : strings(battle['recent']);
    var candidates = allowed
        .where((q) => !recent.contains(adaptive ? q.id : q.item))
        .toList();
    if (candidates.isEmpty) {
      final last = recent.isEmpty ? null : recent.last;
      candidates = allowed
          .where((q) => (adaptive ? q.id : q.item) != last)
          .toList();
      if (candidates.isEmpty) candidates = allowed;
    }
    // First select a declared group, then a question. Large banks cannot drown a dimension.
    final groups = <String, List<QuestionEntry>>{};
    for (final q in candidates) {
      groups
          .putIfAbsent(
            q.data['selectionGroup'] as String? ?? q.dimension,
            () => [],
          )
          .add(q);
    }
    final adaptiveWeights = adaptive
        ? {
            for (final q in candidates)
              q.id: weight(card, q, encounterId: battle['id'] as String),
          }
        : <String, double>{};
    final groupNames = groups.keys.toList();
    final policies = object(card.data['selectionGroups'] ?? {});
    final group = _pick(
      groupNames,
      groupNames.map((id) {
        final policy = object(policies[id] ?? {});
        var policyWeight = (policy['weight'] as num? ?? 1).toDouble();
        for (final r in objects(policy['rules'])) {
          if (meets(object(r['when']))) {
            policyWeight = (r['weight'] as num).toDouble();
            break;
          }
        }
        if (!adaptive) return policyWeight;
        // Average evidence need, so extra scenery cannot inflate a group's weight.
        final members = groups[id]!;
        return policyWeight *
            members.map((q) => adaptiveWeights[q.id]!).reduce((a, b) => a + b) /
            members.length;
      }).toList(),
    );
    candidates = groups[group]!;
    final chosen = _pick(
      candidates,
      candidates
          .map(
            (q) =>
                adaptiveWeights[q.id] ??
                weight(card, q, encounterId: battle['id'] as String),
          )
          .toList(),
    );
    if (adaptive) {
      next['recentQuestions'] ??= <String, dynamic>{};
      final history = [...recent, chosen.id];
      final window = selection['recentItems'] as int? ?? 4;
      next['recentQuestions'][card.address] = history
          .skip(max(0, history.length - window))
          .toList();
    }
    return chosen;
  }

  Future<QuestionEntry> _prepareQuestion(
    ContentNode card,
    QuestionEntry entry,
  ) async {
    final materialized = await design.materialize(card, entry);
    if ((materialized.data['shuffleChoices'] ??
            card.data['shuffleChoices'] ??
            false) !=
        true) {
      return materialized;
    }
    final data = object(jsonDecode(jsonEncode(materialized.data)));
    (data['choices'] as List).shuffle(random);
    return QuestionEntry(data);
  }

  T _pick<T>(List<T> values, List<double> weights) {
    var threshold = random.nextDouble() * weights.fold(0.0, (a, b) => a + b);
    for (var i = 0; i < values.length; i++) {
      threshold -= weights[i];
      if (threshold <= 0) return values[i];
    }
    return values.last;
  }

  Future<void> start(ContentNode card) async {
    if (busy || !unlocked(card)) return;
    final bank = await design.questions(card);
    final next = _copy();
    final battle = <String, dynamic>{
      'id': '${clock().microsecondsSinceEpoch}-${next['transaction']}',
      'card': card.address,
      'lives': card.data['encounter']['lives'],
      'remaining': card.data['encounter']['target'],
      'correct': 0,
      'answered': 0,
      'gain': 0,
      'phase': strings(next['seenLessons']).contains(card.address)
          ? 'question'
          : 'introduction',
      'recent': <String>[],
      'assisted': false,
    };
    battle['question'] = (await _prepareQuestion(
      card,
      _select(card, bank, battle, next),
    )).data;
    next['encounter'] = battle;
    await _commit(next);
    _timer.reset();
    if (battle['phase'] == 'question') _timer.start();
  }

  Future<void> recover() async {
    if (encounter != null) {
      if (encounterExhausted) {
        await advance();
        return;
      }
      if (encounter!['phase'] == 'question') {
        final next = _copy();
        next['encounter']['phase'] = 'paused';
        await _commit(next);
      }
      return;
    }
    final old = state['legacyEncounter'];
    if (old is! Map) return;
    final migration = object(design.root['migration'] ?? {});
    final legacyId = old[migration['encounterCardField']];
    final address = migration['nodeAliases']?[legacyId] ?? legacyId;
    final card = design.cards[address];
    if (card == null) {
      return; // Keep excluded or retired content's snapshot intact.
    }
    final bank = await design.questions(card);
    final next = _copy();
    final b = <String, dynamic>{
      'id': 'restored-${state['transaction']}',
      'card': card.address,
      'phase': 'paused',
      'recent': <String>[],
      'assisted': false,
    };
    for (final f in object(migration['encounterFields']).entries) {
      b[f.key] = old[f.value];
    }
    b['question'] = (await _prepareQuestion(
      card,
      _select(card, bank, b, next),
    )).data;
    next['encounter'] = b;
    next.remove('legacyEncounter');
    await _commit(next);
  }

  Future<void> begin() async {
    if (encounter?['phase'] != 'introduction') return;
    if (encounterExhausted) return advance();
    final next = _copy();
    next['encounter']['phase'] = 'question';
    next['seenLessons'] = {
      ...strings(next['seenLessons']),
      encounter!['card'] as String,
    }.toList();
    await _commit(next);
    _timer
      ..reset()
      ..start();
  }

  Future<void> help() async {
    if (encounter?['phase'] != 'question') return;
    final next = _copy();
    next['encounter']['assisted'] = true;
    await _commit(next);
  }

  Future<void> pause() async {
    if (encounter?['phase'] != 'question') return;
    _timer.stop();
    final next = _copy();
    next['encounter']['elapsedMs'] =
        (encounter!['elapsedMs'] as int? ?? 0) + _timer.elapsedMilliseconds;
    next['encounter']['phase'] = 'paused';
    await _commit(next);
    _timer.reset();
  }

  Future<void> resume() async {
    if (encounter?['phase'] != 'paused') return;
    if (encounterExhausted) return advance();
    final next = _copy();
    next['encounter']['phase'] = 'question';
    await _commit(next);
    _timer.start();
  }

  Future<void> answer(String choice) async {
    if (busy || encounter?['phase'] != 'question') return;
    if (encounterExhausted) return advance();
    final q = question!;
    if (!q.choices.any((c) => c['id'] == choice)) {
      throw ArgumentError('Answer is not an authored choice');
    }
    final outcome = q.outcome(choice);
    final failed = strings(outcome['observed']);
    if (q.skills.isEmpty ||
        q.skills.any(
          (id) =>
              !design.knowledge.containsKey(id) ||
              design.knowledge[id]?['aggregation'] != null,
        ) ||
        (q.accepted.contains(choice) ? failed.isNotEmpty : failed.isEmpty) ||
        failed.any((id) => !q.skills.contains(id))) {
      throw const FormatException(
        'Snapshot violates fine-skill evidence contract',
      );
    }
    _timer.stop();
    final next = _copy(), battle = object(next['encounter']);
    final correct = q.accepted.contains(choice),
        assisted = battle['assisted'] == true;
    next['questionResults'] ??= <String, dynamic>{};
    next['questionResults'][battle['card']] ??= <String, dynamic>{};
    final results = object(next['questionResults'][battle['card']][q.id] ?? {});
    final field = assisted
        ? 'assisted'
        : correct
        ? 'correct'
        : 'wrong';
    results[field] = (results[field] as int? ?? 0) + 1;
    next['questionResults'][battle['card']][q.id] = results;
    final primary = skill(q.skills.first);
    final rewardLevel = _level(primary, rewards: true);
    final reward = objects(economy['levels'])[rewardLevel];
    final day = clock().toIso8601String().substring(0, 10);
    final saturationKey = '${q.skills.first}|${q.item}|$day';
    final saturated =
        (next['daily'][saturationKey] as int? ?? 0) >=
        (economy['itemSaturation'] as int);
    int delta = assisted
        ? (correct ? economy['assistedGain'] : -economy['assistedLoss']) as int
        : (correct ? (saturated ? 0 : reward['gain']) : -reward['loss']) as int;
    if (correct && !assisted) {
      next['daily'][saturationKey] =
          (next['daily'][saturationKey] as int? ?? 0) + 1;
    }
    next['daily'] = object(next['daily'])
      ..removeWhere((key, _) => !key.endsWith(day));
    final after = max(economy['minBalance'] as int, balance + delta);
    delta = after - balance;
    next['balance'] = after;
    final timestamp = clock().millisecondsSinceEpoch;
    final assessed = !correct
        ? strings(outcome['observed']).toSet()
        : q.skills.toSet();
    for (final id in assessed) {
      final r = object(next['skills'][id] ?? {});
      var est = estimate(r, skillId: id);
      if (!assisted) {
        r[correct ? 'correct' : 'wrong'] =
            (r[correct ? 'correct' : 'wrong'] as int? ?? 0) + 1;
        est = est == null
            ? ((correct ? mastery['initialCorrect'] : mastery['initialWrong'])
                      as num)
                  .toDouble()
            : est + (mastery['alpha'] as num) * ((correct ? 1 : 0) - est);
        r['highWater'] = max(
          est,
          (r['highWater'] as num? ?? 0) - (mastery['highWaterDecay'] as num),
        );
      } else {
        r[correct ? 'assistedCorrect' : 'assistedWrong'] =
            (r[correct ? 'assistedCorrect' : 'assistedWrong'] as int? ?? 0) + 1;
        if (est != null && !correct) {
          est += (mastery['alpha'] as num) * 0.5 * -est;
        }
      }
      r['estimate'] = est;
      r['last'] = timestamp;
      r['items'] = {...strings(r['items']), q.evidenceItem}.toList();
      if (!assisted && design.knowledge[id]?['masteryRequirements'] != null) {
        final successful = _successfulItems(r);
        if (correct) {
          successful.add(q.evidenceItem);
        } else {
          successful.remove(q.evidenceItem);
        }
        r['successfulItems'] = successful.toList();
      }
      r['days'] = {...strings(r['days']), day}.toList();
      final recent = [
        ...objects(r['recent']),
        {
          'at': timestamp,
          'correct': correct,
          'assisted': assisted,
          'item': q.evidenceItem,
          'card': battle['card'],
        },
      ];
      r['recent'] = recent
          .skip(max(0, recent.length - (mastery['recentWindow'] as int)))
          .toList();
      next['skills'][id] = r;
    }
    final observation = <String, dynamic>{
      'transaction': (next['transaction'] as int) + 1,
      'balanceDelta': delta,
      'at': timestamp,
      'design': design.identity,
      'card': battle['card'],
      'encounterId': battle['id'],
      'question': q.data,
      'chosen': choice,
      'correct': correct,
      'assisted': assisted,
      'responseTimeMs':
          (battle['elapsedMs'] as int? ?? 0) + _timer.elapsedMilliseconds,
      'outcome': outcome,
    };
    final observations = [...objects(next['observations']), observation];
    next['observations'] = observations
        .skip(
          max(0, observations.length - (selection['maxObservations'] as int)),
        )
        .toList();
    final errors = object(next['errors']);
    if (!correct) {
      final previous = object(errors[q.assessment] ?? {});
      errors[q.assessment] = {
        ...observation,
        'assessment': q.assessment,
        'count': (previous['count'] as int? ?? 0) + 1,
        'successes': 0,
        'practice': strings(outcome['practice']),
      };
    } else if (!assisted) {
      for (final key in errors.keys.toList()) {
        final e = object(errors[key]);
        final failed = strings(e['outcome']?['observed']);
        if (failed.isNotEmpty) {
          final successes = object(e['skillSuccesses'] ?? {});
          for (final id in failed.where(q.skills.contains)) {
            successes[id] = (successes[id] as int? ?? 0) + 1;
          }
          e['skillSuccesses'] = successes;
          if (failed.every(
            (id) => (successes[id] as int? ?? 0) >= selection['retireAfter'],
          )) {
            errors.remove(key);
          } else {
            errors[key] = e;
          }
          continue;
        }
        if (e['assessment'] == q.assessment ||
            strings(q.data['legacyKeys']).contains(e['legacyKey'])) {
          e['successes'] = (e['successes'] as int? ?? 0) + 1;
          if (e['successes'] >= selection['retireAfter']) {
            errors.remove(key);
          } else {
            errors[key] = e;
          }
        }
      }
    }
    while (errors.length > selection['maxErrors']) {
      errors.remove(errors.keys.first);
    }
    next['errors'] = errors;
    battle['phase'] = 'feedback';
    battle['chosen'] = choice;
    battle['lastCorrect'] = correct;
    battle['gain'] = (battle['gain'] as int) + delta;
    battle['answered'] = (battle['answered'] as int) + 1;
    if (correct) {
      battle['remaining'] = max(0, (battle['remaining'] as int) - 1);
      battle['correct'] = (battle['correct'] as int) + 1;
    } else if (!assisted) {
      battle['lives'] = (battle['lives'] as int) - 1;
    }
    battle['elapsedMs'] = 0;
    next['transaction'] = observation['transaction'];
    next['encounter'] = battle;
    await _commit(next);
  }

  bool get encounterExhausted =>
      encounter != null &&
      ((encounter!['remaining'] as num? ?? 1) <= 0 ||
          (encounter!['lives'] as num? ?? 1) <= 0);

  Future<void> advance() async {
    if (busy || encounter == null) return;
    final phase = encounter!['phase'];
    if (phase != 'feedback' &&
        !(encounterExhausted &&
            ['question', 'paused', 'introduction'].contains(phase))) {
      return;
    }
    final next = _copy(), battle = object(next['encounter']);
    final currentCard = design.cards[battle['card']]!;
    final ordered = currentCard.data['encounter']['completion'] == 'sequence';
    final completed =
        battle['remaining'] <= 0 || (ordered && question!.data['next'] == null);
    if (completed || battle['lives'] <= 0) {
      final won = battle['remaining'] <= 0 && battle['lives'] > 0;
      final card = design.cards[battle['card']]!;
      var adjustment = won ? economy['victoryBonus'] as int : 0;
      if (won && cardMastered(card)) {
        final prices = design.cards.values
            .where(
              (c) =>
                  !unlocked(c) &&
                  (c.parent == null || unlocked(c.parent!)) &&
                  meets(c.requirements),
            )
            .map((c) => c.price)
            .toList();
        if (prices.isNotEmpty && balance < prices.reduce(min)) {
          adjustment *= economy['catchUpMultiplier'] as int? ?? 1;
        }
      }
      if (!won) {
        if (economy['loseEncounterGains'] == true) {
          adjustment -= max(0, battle['gain'] as int);
        }
        final base = max(0, balance + adjustment);
        adjustment -= min(
          economy['defeatTributeMax'] as int,
          switch (economy['defeatRounding']) {
            'up' => (base * (economy['defeatTributeRatio'] as num)).ceil(),
            'down' => (base * (economy['defeatTributeRatio'] as num)).floor(),
            _ => throw const FormatException('Unsupported rounding policy'),
          },
        );
      }
      next['balance'] = max(economy['minBalance'] as int, balance + adjustment);
      if (won) {
        next['completed'][card.address] =
            (next['completed'][card.address] as int? ?? 0) + 1;
      }
      final place = card.address.split('/').first;
      final stats = object(next['statistics'][place] ?? {});
      stats[won ? 'won' : 'lost'] =
          (stats[won ? 'won' : 'lost'] as int? ?? 0) + 1;
      next['statistics'][place] = stats;
      battle['phase'] = won ? 'victory' : 'defeat';
      battle['adjustment'] = adjustment;
      next['transaction'] = (next['transaction'] as int) + 1;
    } else {
      final old = question!;
      final card = design.cards[battle['card']]!;
      final bank = await design.questions(card);
      final recent = [...strings(battle['recent']), old.item];
      battle['recent'] = recent
          .skip(max(0, recent.length - (selection['recentItems'] as int? ?? 4)))
          .toList();
      final q =
          old.data['next'] == null ||
              card.data['questionSelection'] == 'adaptive'
          ? _select(card, bank, battle, next)
          : bank.firstWhere((q) => q.id == old.data['next']);
      battle['question'] = (await _prepareQuestion(card, q)).data;
      battle['phase'] = 'question';
      battle['assisted'] = false;
      battle.remove('chosen');
    }
    next['encounter'] = battle;
    await _commit(next);
    _timer
      ..stop()
      ..reset();
    if (battle['phase'] == 'question') _timer.start();
  }

  /// Dismiss only the resumable encounter; recorded learning and rewards remain.
  Future<void> discardEncounter() async {
    if (busy || encounter == null) return;
    final next = _copy()..remove('encounter');
    await _commit(next);
    _timer.stop();
    _timer.reset();
  }

  Future<void> finish() async {
    if (!{'victory', 'defeat'}.contains(encounter?['phase'])) return;
    final next = _copy();
    next.remove('encounter');
    await _commit(next);
  }

  Future<void> setting(String key, Object value) async {
    final next = _copy();
    next['settings'][key] = value;
    await _commit(next);
  }

  Future<void> importSave(String raw) async {
    final next = _restore(design, object(jsonDecode(raw)));
    await _commit(next);
    _timer.reset();
  }

  Json _copy() => object(jsonDecode(jsonEncode(state)));
  Future<void> _commit(Json next) async {
    busy = true;
    try {
      await persist(jsonEncode(next));
      state = next;
      notifyListeners();
    } finally {
      busy = false;
    }
  }
}
