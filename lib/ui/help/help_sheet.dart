import '../widgets/roman_widgets.dart';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../engine/design.dart';
import '../../engine/session.dart';

/// Rich authored content uses the original highlighted-word treatment.
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
  @override
  Widget build(BuildContext context) {
    final skin = G(object(session.design.root['theme']));
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final part in parts)
          if (part['type'] == 'image')
            Image.asset(session.design.asset(part['asset']), height: 160)
          else
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: part['type'] == 'highlight' ? 6 : 0,
                vertical: part['type'] == 'highlight' ? 2 : 0,
              ),
              decoration: BoxDecoration(
                color: part['type'] == 'highlight' ? skin.goldWash : null,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                session.text(part['text']),
                style: skin
                    .display(size, color: skin.purpleDark, letterSpacing: .3)
                    .copyWith(
                      fontWeight: part['type'] == 'highlight'
                          ? FontWeight.bold
                          : null,
                      decoration: part['type'] == 'gap'
                          ? TextDecoration.underline
                          : null,
                    ),
              ),
            ),
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
        for (final b in blocks)
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
