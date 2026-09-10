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
      return object(jsonDecode(jsonEncode(saved)));
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
    return next;
  }

  Json skill(String id) => object(state['skills']?[id] ?? {});
  int level(String id, {bool rewards = false}) {
    final aggregate = design.knowledge[id]?['aggregation'];
    if (aggregate != null) {
      final records = strings(aggregate['skills'])
          .map(skill)
          .where(
            (r) => (r['correct'] as num? ?? 0) + (r['wrong'] as num? ?? 0) > 0,
          )
          .toList();
      if (records.isEmpty) return 0;
      return records.map((r) => _level(r, rewards: rewards)).reduce(min);
    }
    return _level(skill(id), rewards: rewards);
  }

  double? estimate(Json record) {
    if (record['estimate'] == null) return null;
    var value = (record['estimate'] as num).toDouble();
    final last = record['last'];
    final levels = objects(mastery['levels']);
    final index = _level(record, applyDecay: false);
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

  int _level(Json record, {bool rewards = false, bool applyDecay = true}) {
    final count =
        (record['correct'] as num? ?? 0) + (record['wrong'] as num? ?? 0);
    final est = rewards
        ? max(
            (record['highWater'] as num? ?? 0),
            (record['estimate'] as num? ?? 0),
          )
        : (applyDecay ? estimate(record) : record['estimate'] as num?);
    if (count == 0 || est == null) return 0;
    final levels = objects(mastery['levels']);
    var result = 0;
    for (var i = 0; i < levels.length; i++) {
      final l = levels[i];
      final recent = objects(record['recent'])
          .where((r) => r['assisted'] != true)
          .toList();
      final rate = recent.isEmpty
          ? 0.0
          : recent.where((r) => r['correct'] == true).length / recent.length;
      if (est >= (l['threshold'] as num? ?? 0) &&
          count >= (l['minObservations'] as num? ?? 0) &&
          strings(record['items']).length >= (l['minItems'] as num? ?? 0) &&
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
      'completed' => (state['completed']?[e.value] as num? ?? 0) > 0,
      'count' =>
        (state['completed']?[e.value['card']] as num? ?? 0) >=
            e.value['atLeast'],
      'skill' =>
        level(e.value['id']) >= (e.value['minLevel'] as int? ?? 0) &&
            ((skill(e.value['id'])['correct'] as num? ?? 0) +
                    (skill(e.value['id'])['wrong'] as num? ?? 0)) >=
                (e.value['minObservations'] as num? ?? 0),
      _ => throw FormatException('Unsupported requirement ${e.key}'),
    };
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

  /// Expands only declared addresses. No concept similarity or inferred edge.
  final Map<String, List<Json>> _practiceCache = {};
  final Map<String, Map<String, Set<String>?>> _practiceMembership = {};
  List<Json> practiceTargets(Json error) {
    final declared = objects(design.pedagogy['practiceSets']);
    return [
      for (final id in strings(error['practice']))
        ...(_practiceCache[id] ??= objects(
          declared.firstWhere((s) => s['id'] == id)['targets'],
        )),
    ];
  }

  double weight(ContentNode card, QuestionEntry q, {String? encounterId}) {
    final record = skill(q.skills.first);
    final est = estimate(record);
    var result = est == null
        ? (selection['unknownWeight'] as num).toDouble()
        : 1.0 + (selection['weakScale'] as num) * (1 - est);
    for (final e in object(state['errors']).values) {
      final error = object(e);
      if (error['encounterId'] == encounterId) continue;
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
    return result;
  }

  QuestionEntry _select(
    ContentNode card,
    List<QuestionEntry> bank,
    Json battle,
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
    final recent = strings(battle['recent']);
    var candidates = allowed.where((q) => !recent.contains(q.item)).toList();
    if (candidates.isEmpty) candidates = allowed;
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
    final groupNames = groups.keys.toList();
    final policies = object(card.data['selectionGroups'] ?? {});
    final group = _pick(
      groupNames,
      groupNames.map((id) {
        final policy = object(policies[id] ?? {});
        for (final r in objects(policy['rules'])) {
          if (meets(object(r['when']))) return (r['weight'] as num).toDouble();
        }
        return (policy['weight'] as num? ?? 1).toDouble();
      }).toList(),
    );
    candidates = groups[group]!;
    return _pick(
      candidates,
      candidates
          .map((q) => weight(card, q, encounterId: battle['id'] as String))
          .toList(),
    );
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
    battle['question'] = (await design.materialize(
      card,
      _select(card, bank, battle),
    )).data;
    next['encounter'] = battle;
    await _commit(next);
    _timer.reset();
    if (battle['phase'] == 'question') _timer.start();
  }

  Future<void> recover() async {
    if (encounter != null) {
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
    b['question'] = (await design.materialize(
      card,
      _select(card, bank, b),
    )).data;
    next['encounter'] = b;
    next.remove('legacyEncounter');
    await _commit(next);
  }

  Future<void> begin() async {
    if (encounter?['phase'] != 'introduction') return;
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
    final next = _copy();
    next['encounter']['phase'] = 'question';
    await _commit(next);
    _timer.start();
  }

  Future<void> answer(String choice) async {
    if (busy || encounter?['phase'] != 'question') return;
    final q = question!;
    if (!q.choices.any((c) => c['id'] == choice)) {
      throw ArgumentError('Answer is not an authored choice');
    }
    _timer.stop();
    final next = _copy(), battle = object(next['encounter']);
    final correct = q.accepted.contains(choice),
        assisted = battle['assisted'] == true;
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
    for (final id in q.skills.toSet()) {
      final r = object(next['skills'][id] ?? {});
      var est = estimate(r);
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
      r['items'] = {...strings(r['items']), q.item}.toList();
      r['days'] = {...strings(r['days']), day}.toList();
      final recent = [
        ...objects(r['recent']),
        {
          'at': timestamp,
          'correct': correct,
          'assisted': assisted,
          'item': q.item,
          'card': battle['card'],
        },
      ];
      r['recent'] = recent
          .skip(max(0, recent.length - (mastery['recentWindow'] as int)))
          .toList();
      next['skills'][id] = r;
    }
    final outcome = q.outcome(choice);
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
      battle['remaining'] = (battle['remaining'] as int) - 1;
      battle['correct'] = (battle['correct'] as int) + 1;
    } else if (!assisted) {
      battle['lives'] = (battle['lives'] as int) - 1;
    }
    battle['elapsedMs'] = 0;
    next['transaction'] = observation['transaction'];
    next['encounter'] = battle;
    await _commit(next);
  }

  Future<void> advance() async {
    if (busy || encounter?['phase'] != 'feedback') return;
    final next = _copy(), battle = object(next['encounter']);
    if (battle['remaining'] <= 0 || battle['lives'] <= 0) {
      final won = battle['remaining'] <= 0;
      final card = design.cards[battle['card']]!;
      var adjustment = won ? economy['victoryBonus'] as int : 0;
      if (won &&
          level(strings(card.data['skills']).first) ==
              objects(mastery['levels']).length - 1) {
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
      final q = old.data['next'] == null
          ? _select(card, bank, battle)
          : bank.firstWhere((q) => q.id == old.data['next']);
      battle['question'] = (await design.materialize(card, q)).data;
      battle['phase'] = 'question';
      battle['assisted'] = false;
      battle.remove('chosen');
    }
    next['encounter'] = battle;
    await _commit(next);
    _timer.reset();
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
