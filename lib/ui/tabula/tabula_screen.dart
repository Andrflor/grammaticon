import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../engine/design.dart';
import '../../engine/session.dart';
import '../widgets/roman_widgets.dart';

class TabulaScreen extends StatelessWidget {
  const TabulaScreen({
    super.key,
    required this.session,
    required this.skin,
    required this.onBack,
    required this.onSettings,
    required this.onCard,
    required this.onErrors,
  });
  final GameSession session;
  final G skin;
  final VoidCallback onBack, onSettings, onErrors;
  final void Function(ContentNode) onCard;
  @override
  Widget build(BuildContext context) {
    final light = skin.body(16, color: Colors.white);
    return Scaffold(
      body: ScreenBackground(
        asset: session.design.asset(
          session.design.root['presentation']['progressBackground'],
        ),
        child: Column(
          children: [
            TopBar(
              skin: skin,
              title: session.label('progress.title'),
              backLabel: session.label('actions.back'),
              currencyAsset: session.design.asset(
                session.design.root['presentation']['currency'],
              ),
              gems: session.balance,
              onBack: onBack,
              onSettings: onSettings,
            ),
            Expanded(
              child: ContentColumn(
                maxWidth: 960,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  children: [
                    RomanPanel(
                      skin: skin,
                      color: skin.purpleDeep,
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            session.label('progress.levels'),
                            style: skin.body(
                              16,
                              color: skin.paint('FFF3E9D2'),
                              weight: 800,
                            ),
                          ),
                          for (
                            var i = 0;
                            i < objects(session.mastery['levels']).length;
                            i++
                          )
                            LevelBadge(
                              session: session,
                              skin: skin,
                              level: i,
                              dense: true,
                            ),
                          for (final stat in objects(
                            session
                                .design
                                .root['presentation']['progressStatistics'],
                          ))
                            Text(
                              '· ${session.text(stat['won'])}: ${(readPath(session.state, strings(stat['path'])) as Map?)?['won'] ?? 0} · ${session.text(stat['lost'])}: ${(readPath(session.state, strings(stat['path'])) as Map?)?['lost'] ?? 0}',
                              style: light,
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: RomanPanel(
                        skin: skin,
                        color: skin.purpleDeep,
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                        child: InkWell(
                          onTap: onErrors,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      session.label('actions.errors'),
                                      style: skin.display(
                                        18,
                                        color: skin.goldLight,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                  StatChip(
                                    '${object(session.state['errors']).length} ${session.label('progress.open')}',
                                    skin: skin,
                                    icon: Icons.error_outline,
                                    color:
                                        object(session.state['errors']).isEmpty
                                        ? skin.green
                                        : skin.red,
                                    textColor: Colors.white,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (object(session.state['errors']).isEmpty)
                                Text(
                                  session.label('progress.noErrors'),
                                  style: light,
                                )
                              else
                                for (final raw in object(
                                  session.state['errors'],
                                ).values.take(10))
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3,
                                    ),
                                    child: Text(
                                      session.text(raw['outcome']?['feedback']),
                                      style: light,
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    for (final collection in objects(
                      session.design.root['presentation']['collections'],
                    ))
                      CollectionPanel(
                        session: session,
                        skin: skin,
                        config: collection,
                      ),
                    for (final root in session.design.knowledge.values.where(
                      (n) => n['parent'] == null && n['visible'] != false,
                    ))
                      _SkillNode(
                        session: session,
                        skin: skin,
                        onCard: onCard,
                        skill: root,
                        depth: 0,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkillSummary {
  SkillSummary(this.session, this.node);
  final GameSession session;
  final Json node;
  List<String> get ids => node['aggregation'] == null
      ? [node['id'] as String]
      : strings(node['aggregation']['skills']);
  int get totalLeaves => ids.length;
  int get evaluatedLeaves =>
      ids.where((id) => session.progress(id) != null).length;
  bool get evaluated => evaluatedLeaves > 0;
  int get tier => session.level(node['id']);
  Color get color => Color(
    int.parse(objects(session.mastery['levels'])[tier]['color'], radix: 16),
  );
  String get estimateText {
    double weighted = 0, total = 0;
    for (final id in ids) {
      final record = session.skill(id);
      final est = session.progress(id);
      if (est != null) {
        final weight =
            ((record['correct'] as num? ?? 0) + (record['wrong'] as num? ?? 0))
                .clamp(1, double.infinity);
        weighted += est * weight;
        total += weight;
      }
    }
    return total == 0 ? '—' : '${(weighted / total * 100).round()} %';
  }
}

class _SkillNode extends StatefulWidget {
  final GameSession session;
  final G skin;
  final void Function(ContentNode) onCard;
  const _SkillNode({
    required this.session,
    required this.skin,
    required this.onCard,
    required this.skill,
    required this.depth,
  });
  final Json skill;
  final int depth;
  @override
  State<_SkillNode> createState() => _SkillNodeState();
}

class _SkillNodeState extends State<_SkillNode> {
  late bool _open = widget.depth == 0;

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final skin = widget.skin;

    final s = widget.skill;
    final children = session.design.knowledge.values
        .where((n) => n['parent'] == s['id'] && n['visible'] != false)
        .toList();
    final leaf = children.isEmpty;
    final sum = SkillSummary(session, s);
    final root = widget.depth == 0;
    // Nested rows sit 24 px inside their parent on both sides (relative to the
    // parent row, which is itself already inset).
    final inset = root ? 0.0 : 24.0;
    final chevronColor = root ? skin.purpleTitle : skin.purpleRoyal;
    // On phones the figures go under the name instead of crowding the row.
    final compact = MediaQuery.sizeOf(context).width < 720;

    final stats = <Widget>[
      if (s['future'] != true) ...[
        if (!leaf && sum.totalLeaves > 1)
          Text(
            '${sum.evaluatedLeaves}/${sum.totalLeaves}',
            style: skin.body(root ? 16 : 14, color: skin.inkSoft, weight: 700),
          ),
        if (sum.evaluated)
          Text(
            sum.estimateText,
            style: skin.body(root ? 19 : 17, weight: 800, color: sum.color),
          ),
        LevelBadge(
          session: session,
          skin: skin,
          level: sum.tier,
          dense: !root || compact,
        ),
      ],
    ];

    return Padding(
      padding: EdgeInsets.only(left: inset, right: inset, top: root ? 10 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RomanPanel(
            skin: skin,
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: root ? 9 : 7,
            ),
            color: s['future'] == true ? skin.paint('FFEFE6D4') : skin.marble,
            borderColor: root ? skin.gold : skin.goldPale,
            borderWidth: root ? 3 : 2,
            radius: root ? 16 : 12,
            shadow: root,
            child: InkWell(
              onTap: () {
                if (leaf) {
                  _showSkill(context, s, sum);
                } else {
                  setState(() => _open = !_open);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      leaf
                          ? Icons.chevron_right
                          : (_open ? Icons.expand_more : Icons.chevron_right),
                      color: leaf ? skin.goldDark : chevronColor,
                      size: root ? 28 : 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.text(s['name']),
                            style: root
                                ? skin.display(
                                    22,
                                    color: skin.purpleTitle,
                                    letterSpacing: 1.0,
                                  )
                                : skin.body(14, weight: 800),
                          ),
                          if (session.text(s['hint']).isNotEmpty)
                            Text(
                              session.text(s['hint']),
                              style: skin.body(13, color: skin.inkSoft),
                            ),
                          if (s['future'] == true)
                            Text(
                              session.label('progress.future'),
                              style: skin.body(
                                12,
                                color: skin.inkSoft,
                                style: FontStyle.italic,
                              ),
                            ),
                          if (compact && stats.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: stats,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!compact)
                      for (final w in stats) ...[const SizedBox(width: 10), w],
                  ],
                ),
              ),
            ),
          ),
          if (_open)
            for (final c in children)
              _SkillNode(
                session: session,
                skin: skin,
                onCard: widget.onCard,
                skill: c,
                depth: widget.depth + 1,
              ),
        ],
      ),
    );
  }

  void _showSkill(BuildContext context, Json skill, SkillSummary summary) {
    final session = widget.session, skin = widget.skin;
    final cards = session.design.cards.values.where(
      (c) => strings(c.data['skills']).contains(skill['id']),
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.text(skill['name']),
                      style: skin.display(22, color: skin.purpleTitle),
                    ),
                  ),
                  LevelBadge(session: session, skin: skin, level: summary.tier),
                ],
              ),
              if (session.text(skill['hint']).isNotEmpty)
                Text(
                  session.text(skill['hint']),
                  style: skin.body(14, color: skin.inkSoft),
                ),
              const SizedBox(height: 12),
              Text(
                summary.evaluated
                    ? summary.estimateText
                    : session.label('labels.unassessed'),
                style: skin.body(15, weight: 700),
              ),
              const SizedBox(height: 14),
              Text(
                session.label('labels.related'),
                style: skin.display(16, color: skin.goldDark),
              ),
              const SizedBox(height: 6),
              for (final card in cards)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: RomanPanel(
                    skin: skin,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: Colors.white,
                    borderColor: skin.goldPale,
                    borderWidth: 2,
                    radius: 12,
                    shadow: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${session.text(card.data['name'])} · ${session.text(card.data['subtitle'])}',
                            style: skin.body(15, weight: 800),
                          ),
                        ),
                        const SizedBox(width: 8),
                        RomanButton(
                          skin: skin,
                          label: session.label('actions.open'),
                          style: RomanButtonStyle.gold,
                          dense: true,
                          onPressed: () {
                            Navigator.pop(ctx);
                            widget.onCard(card);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

Object? readPath(Object? value, List<String> path) {
  for (final key in path) {
    value = value is Map ? value[key] : null;
  }
  return value;
}

class CollectionPanel extends StatelessWidget {
  const CollectionPanel({
    super.key,
    required this.session,
    required this.skin,
    required this.config,
  });
  final GameSession session;
  final G skin;
  final Json config;
  bool matches(Json record, Json rule) {
    if (rule['any'] != null) {
      return objects(rule['any']).any((r) => matches(record, r));
    }
    if (rule['all'] != null) {
      return objects(rule['all']).every((r) => matches(record, r));
    }
    final value = record[rule['field']];
    return rule['count'] != null
        ? (value is List ? value.length : 0) >= rule['count']
        : (value is num ? value : 0) >= rule['min'];
  }

  @override
  Widget build(BuildContext context) {
    final records = object(
      readPath(session.state, strings(config['path'])) ?? {},
    );
    final groups = objects(config['groups']);
    final counters = object(config['counters']);
    int count(List<String> ids, String key) => ids
        .where(
          (id) => matches(object(records[id] ?? {}), object(counters[key])),
        )
        .length;
    final all = groups.expand((g) => strings(g['members'])).toList();
    final gated = groups.where((g) => g['gated'] == true).toList();
    var level = 1;
    for (final group in gated) {
      final ids = strings(group['members']);
      if (ids.isNotEmpty &&
          count(ids, 'known') / ids.length >= config['unlockShare'] &&
          level < gated.length) {
        level++;
      } else {
        break;
      }
    }
    String format(Object? text) {
      var result = session.text(text);
      for (final e in {
        'level': level,
        'count': gated.length,
        'total': all.length,
        'seen': count(all, 'seen'),
        'repeated': count(all, 'repeated'),
        'tested': count(all, 'tested'),
      }.entries) {
        result = result.replaceAll('{${e.key}}', '${e.value}');
      }
      return result;
    }

    final light = skin.body(16, color: Colors.white),
        strong = skin.body(16, color: Colors.white, weight: 800);
    final summary = format(config['summary']);
    final split = summary.indexOf('  ·');
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: RomanPanel(
        skin: skin,
        color: skin.purpleDeep,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.text(config['title']),
                    style: skin.display(
                      18,
                      color: skin.goldLight,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                StatChip(
                  format(config['badge']),
                  skin: skin,
                  icon: Icons.stairs,
                  color: skin.gold,
                  textColor: skin.purpleDark,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: split < 0 ? summary : summary.substring(0, split),
                    style: strong,
                  ),
                  if (split >= 0)
                    TextSpan(text: summary.substring(split), style: light),
                ],
              ),
            ),
            const SizedBox(height: 8),
            for (final group in groups)
              CollectionRow(
                skin: skin,
                title: session.text(group['title']),
                total: strings(group['members']).length,
                seen: count(strings(group['members']), 'seen'),
                known: count(strings(group['members']), 'known'),
                open: group['gated'] != true || gated.indexOf(group) < level,
                lockedSuffix: session.text(config['lockedSuffix']),
              ),
            const SizedBox(height: 6),
            Text(
              session.text(config['note']),
              style: skin.body(
                14,
                color: skin.goldLight,
                style: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CollectionRow extends StatelessWidget {
  const CollectionRow({
    super.key,
    required this.skin,
    required this.title,
    required this.total,
    required this.seen,
    required this.known,
    required this.open,
    required this.lockedSuffix,
  });
  final G skin;
  final String title, lockedSuffix;
  final int total, seen, known;
  final bool open;
  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: compact ? 92 : 136,
            child: Text(
              title,
              style: skin.body(
                13,
                color: open ? Colors.white : skin.goldLight,
                weight: 700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 12,
                  decoration: ShapeDecoration(
                    shape: StadiumBorder(),
                    color: skin.paint('66200A40'),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: total == 0 ? 0 : (seen / total).clamp(0, 1),
                  child: Container(
                    height: 12,
                    decoration: ShapeDecoration(
                      shape: const StadiumBorder(),
                      color: skin.purpleLight,
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: total == 0 ? 0 : (known / total).clamp(0, 1),
                  child: Container(
                    height: 12,
                    decoration: ShapeDecoration(
                      shape: const StadiumBorder(),
                      color: skin.gold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$known/$total${open || compact ? '' : lockedSuffix}',
            style: skin.body(13, color: Colors.white, weight: 700),
          ),
          if (!open && compact) ...[
            const SizedBox(width: 4),
            Icon(Icons.lock, size: 14, color: skin.goldLight),
          ],
        ],
      ),
    );
  }
}
