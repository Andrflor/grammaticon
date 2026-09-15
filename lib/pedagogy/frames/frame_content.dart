/// Cadres authored du Theatrum (lecture) et du Templum (production) : une
/// structure de phrase avec emplacements variables, des choix alignés sur les
/// mêmes emplacements, une réponse acceptée et une explication par choix.
///
/// Les cadres sont extraits des banques de référence
/// (`tool/reference/extract_frames.py`) et embarqués dans
/// `assets/arbor/frames/<lieu>.json`. Rien n'est généré à la volée en dehors
/// de l'instanciation des emplacements avec des tuples alignés observés.
library;

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart' show AssetBundle;

class FrameSegment {
  const FrameSegment({required this.type, required this.template});

  /// `text`, `gap` ou `highlight`.
  final String type;
  final String template;
}

class FrameChoice {
  const FrameChoice({required this.template, required this.accepted, required this.feedback, required this.observed});
  final String template;
  final bool accepted;
  final String feedback;

  /// Anciens identifiants de compétence observés par la banque de référence.
  final List<String> observed;
}

class Frame {
  const Frame({
    required this.id,
    required this.card,
    required this.interaction,
    required this.dimension,
    required this.prompt,
    required this.content,
    required this.choices,
    required this.slotCount,
    required this.aligned,
    required this.instances,
    required this.legacySkills,
    this.help,
  });

  final String id;

  /// Adresse de carte : `theatrum/casuum-sensus/8`.
  final String card;
  final String interaction;
  final String dimension;
  final String prompt;
  final List<FrameSegment> content;
  final List<FrameChoice> choices;
  final int slotCount;

  /// Tuples de valeurs alignées (une valeur par emplacement), observés dans la
  /// référence ; l'instanciation en tire un au hasard.
  final List<List<String>> aligned;
  final int instances;
  final List<String> legacySkills;

  /// Identifiant de la fiche d'aide (clé de `help.json`).
  final String? help;

  String get place => card.split('/')[0];
  String get section => card.split('/')[1];
  String get cardId => card.split('/')[2];
  bool get isVocabulary => cardId == 'vocabula';

  factory Frame.fromJson(Map<String, Object?> j) => Frame(
    id: j['id'] as String,
    card: j['card'] as String,
    interaction: j['interaction'] as String,
    dimension: j['dimension'] as String,
    prompt: j['prompt'] as String? ?? '',
    content: [
      for (final s in (j['content'] as List).cast<Map>())
        if (s['type'] != 'image') FrameSegment(type: s['type'] as String, template: s['template'] as String? ?? ''),
    ],
    choices: [
      for (final c in (j['choices'] as List).cast<Map>())
        FrameChoice(
          template: c['template'] as String,
          accepted: c['accepted'] == true,
          feedback: ((c['outcome'] as Map?)?['feedback'] as String?) ?? '',
          observed: (((c['outcome'] as Map?)?['observed'] as List?) ?? const []).cast<String>(),
        ),
    ],
    slotCount: (j['slots'] as List).length,
    aligned: [for (final row in ((j['aligned'] as List?) ?? const [])) (row as List).cast<String>()],
    instances: (j['instances'] as num?)?.toInt() ?? 1,
    legacySkills: ((j['skills'] as List?) ?? const []).cast<String>(),
    help: j['help'] as String?,
  );

  static final _slot = RegExp(r'\{(\d+)\}');

  /// Une instanciation cohérente : contenu et choix remplis avec le même tuple.
  FrameInstance instantiate(Random rng) {
    final row = aligned.isEmpty ? const <String>[] : aligned[rng.nextInt(aligned.length)];
    String fill(String tpl) => tpl.replaceAllMapped(_slot, (m) {
      final i = int.parse(m.group(1)!);
      return i < row.length ? row[i] : '';
    });
    return FrameInstance(
      frame: this,
      content: [for (final s in content) FrameSegment(type: s.type, template: fill(s.template))],
      choices: [for (final c in choices) fill(c.template)],
    );
  }
}

class FrameInstance {
  const FrameInstance({required this.frame, required this.content, required this.choices});
  final Frame frame;
  final List<FrameSegment> content;
  final List<String> choices;

  /// Texte affiché : les segments, le trou marqué […].
  String get surface => content.map((s) => s.type == 'gap' ? '[…]' : s.template).join().replaceAll(RegExp(r' *\n *'), '\n').trim();
}

/// Un bloc d'une fiche d'aide : paragraphe (`text`) ou entrée « mot — sens » (`example`).
class HelpBlock {
  const HelpBlock(this.type, this.text);
  final String type;
  final String text;
}

class FrameLibrary {
  FrameLibrary(this.frames, {this.help = const {}});
  final List<Frame> frames;

  /// Fiches d'aide par identifiant.
  final Map<String, List<HelpBlock>> help;

  static FrameLibrary parse(String json, {Map<String, List<HelpBlock>> help = const {}}) {
    final j = (jsonDecode(json) as Map).cast<String, Object?>();
    return FrameLibrary([for (final f in (j['frames'] as List)) Frame.fromJson((f as Map).cast<String, Object?>())], help: help);
  }

  static Map<String, List<HelpBlock>> parseHelp(String json) {
    final j = (jsonDecode(json) as Map).cast<String, Object?>();
    return {
      for (final e in j.entries) e.key: [for (final b in (e.value as List).cast<Map>()) HelpBlock(b['type'] as String, b['text'] as String)],
    };
  }

  static Future<FrameLibrary> load(AssetBundle bundle, {List<String> places = const ['theatrum', 'templum']}) async {
    final all = <Frame>[];
    var help = const <String, List<HelpBlock>>{};
    try {
      help = parseHelp(await bundle.loadString('assets/arbor/frames/help.json'));
    } on FlutterError {
      // pas de fiches : les questions restent jouables
    }
    for (final p in places) {
      String text;
      try {
        text = await bundle.loadString('assets/arbor/frames/$p.json');
      } on FlutterError {
        continue; // lieu sans cadres embarqués : pas de contenu, pas d'erreur
      }
      all.addAll(parse(text).frames); // une erreur de format doit remonter
    }
    return FrameLibrary(all, help: help);
  }

  List<HelpBlock> helpFor(Frame f) => f.help == null ? const [] : (help[f.help] ?? const []);

  FrameLibrary merge(FrameLibrary other) => FrameLibrary([...frames, ...other.frames], help: {...help, ...other.help});

  late final Map<String, List<Frame>> _byCard = () {
    final m = <String, List<Frame>>{};
    for (final f in frames) {
      (m[f.card] ??= []).add(f);
    }
    return m;
  }();

  List<Frame> forCard(String card) => _byCard[card] ?? const [];
  Iterable<String> get cards => _byCard.keys;
}
