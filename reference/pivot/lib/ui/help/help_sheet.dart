import '../widgets/roman_widgets.dart';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../engine/design.dart';
import '../../engine/session.dart';

/// Rich authored content uses the original highlighted-word treatment.
///
/// Authored content is a flat run of parts whose text may carry line breaks.
/// Splitting on those breaks gives the real structure: an optional gloss line
/// (the vernacular sentence) above the Latin line that carries the gap.
class QuestionContent extends StatelessWidget {
  const QuestionContent({
    super.key,
    required this.session,
    required this.parts,
    required this.size,
  });
  final GameSession session;
  final List<Json> parts;
  final double size;

  /// Groups the parts into lines, cutting text parts on their line breaks.
  List<List<Json>> get _lines {
    final lines = <List<Json>>[[]];
    for (final part in parts) {
      if (part['type'] != 'text') {
        lines.last.add(part);
        continue;
      }
      final segments = session.text(part['text']).split('\n');
      for (var i = 0; i < segments.length; i++) {
        if (i > 0) lines.add([]);
        if (segments[i].trim().isEmpty) continue;
        lines.last.add({'type': 'text', 'text': segments[i]});
      }
    }
    return lines.where((line) => line.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final skin = G(object(session.design.root['theme']));
    final lines = _lines;
    // With two lines the first one is the vernacular gloss: it supports the
    // Latin line instead of competing with it.
    final glossed = lines.length > 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < lines.length; i++) ...[
          if (i > 0) SizedBox(height: 10),
          if (glossed && i == 0)
            Text(
              lines[i].map((p) => session.text(p['text'])).join(),
              textAlign: TextAlign.center,
              style: skin.body(
                15,
                color: skin.inkSoft,
                weight: 600,
                style: FontStyle.italic,
              ),
            )
          else
            _Line(skin: skin, session: session, parts: lines[i], size: size),
        ],
      ],
    );
  }
}

/// One rendered line: words flow and wrap, gaps and highlights keep their box.
class _Line extends StatelessWidget {
  const _Line({
    required this.skin,
    required this.session,
    required this.parts,
    required this.size,
  });
  final G skin;
  final GameSession session;
  final List<Json> parts;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = skin.display(size, color: skin.purpleDark, letterSpacing: .3);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 0,
      runSpacing: 6,
      children: [
        for (final part in parts)
          if (part['type'] == 'image')
            Image.asset(session.design.asset(part['asset']), height: 160)
          else if (part['type'] == 'gap')
            // The gap reads as a slot waiting for the answer, not as text.
            // Its width is fixed so it never stretches the line it sits in.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 96,
                height: size * 1.15,
                decoration: BoxDecoration(
                  color: skin.goldWash,
                  borderRadius: BorderRadius.circular(6),
                  border: Border(
                    bottom: BorderSide(color: skin.goldDark, width: 3),
                  ),
                ),
              ),
            )
          else if (part['type'] == 'highlight')
            Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: skin.goldWash,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                session.text(part['text']),
                style: style.copyWith(fontWeight: FontWeight.bold),
              ),
            )
          else
            Text(session.text(part['text']), style: style),
      ],
    );
  }
}

/// The original draggable help sheet, bound to authored display blocks.
Future<void> showHelpSheet(
  BuildContext context,
  GameSession session,
  G skin,
  List<Json> blocks, {
  String? highlight,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (ctx) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: .85,
    minChildSize: .4,
    builder: (ctx, scroll) => ListView(
      controller: scroll,
      padding: const EdgeInsets.all(18),
      children: [
        for (final b in [
          if (!blocks.any((block) => block['role'] == 'heading'))
            <String, dynamic>{
              'role': 'heading',
              'text': session.label('actions.help'),
            },
          ...blocks,
        ])
          if (b['role'] == 'heading')
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.text(b['text']),
                    style: skin.display(26, color: skin.purple),
                  ),
                ),
                RomanButton(
                  skin: skin,
                  label: session.label('actions.close'),
                  style: RomanButtonStyle.neutral,
                  dense: true,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            )
          else if (b['type'] == 'table') ...[
            const SizedBox(height: 14),
            Text(
              session.text(b['title']),
              style: skin.display(16, color: skin.goldDark),
            ),
            const SizedBox(height: 6),
            HelpTableView(
              HelpTableData(session, b),
              skin: skin,
              highlight: highlight,
            ),
            if (session.text(b['note']).isNotEmpty)
              Text(
                session.text(b['note']),
                style: skin.body(
                  12,
                  color: skin.inkSoft,
                  style: FontStyle.italic,
                ),
              ),
          ] else if (b['role'] == 'lead')
            Text(
              session.text(b['text']),
              style: skin.body(18, weight: 800, color: skin.purpleDark),
            )
          else if (b['role'] == 'section') ...[
            const SizedBox(height: 14),
            Text(
              session.text(b['text']),
              style: skin.display(16, color: skin.goldDark),
            ),
          ] else if (b['role'] == 'note')
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                session.text(b['text']),
                style: skin.body(
                  13,
                  color: skin.inkSoft,
                  style: FontStyle.italic,
                ),
              ),
            )
          else if (b['role'] == 'source') ...[
            const SizedBox(height: 20),
            Text(
              session.text(b['text']),
              style: skin.body(11, color: skin.inkSoft),
            ),
          ] else
            Text(
              session.text(b['text']),
              style: skin.body(14, color: skin.inkSoft),
            ),
      ],
    ),
  ),
);

class HelpTableData {
  HelpTableData(this.session, this.data);
  final GameSession session;
  final Json data;
  List<String> get columns =>
      (data['columns'] as List).skip(1).map(session.text).toList();
  List<HelpRowData> get rows => [
    for (final r in data['rows'] as List)
      HelpRowData(
        session.text(r[0]),
        (r as List).skip(1).map(session.text).toList(),
      ),
  ];
}

class HelpRowData {
  const HelpRowData(this.label, this.cells);
  final String label;
  final List<String> cells;
}

class HelpTableView extends StatelessWidget {
  final G skin;
  const HelpTableView(this.t, {required this.skin, super.key, this.highlight});
  final HelpTableData t;
  final String? highlight;

  bool _matches(String cell) =>
      highlight != null &&
      (cell == highlight || cell.split(' / ').contains(highlight));
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder.all(
        color: skin.marbleDark,
        width: 1,
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(color: skin.purple),
          children: [
            const Padding(padding: EdgeInsets.all(6), child: SizedBox()),
            for (final c in t.columns)
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  c,
                  style: skin.body(13, color: Colors.white, weight: 800),
                ),
              ),
          ],
        ),
        for (final r in t.rows)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  r.label,
                  style: skin.body(13, color: skin.inkSoft, weight: 800),
                ),
              ),
              for (final c in r.cells)
                Container(
                  padding: const EdgeInsets.all(6),
                  color: _matches(c) ? skin.goldLight : null,
                  child: Text(
                    c,
                    style: skin.body(
                      14,
                      weight: _matches(c) ? 800 : 600,
                      color: c.startsWith('—') || c.startsWith('(')
                          ? skin.inkSoft
                          : skin.ink,
                    ),
                  ),
                ),
            ],
          ),
      ],
    ),
  );
}
