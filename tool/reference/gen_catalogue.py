"""Génère lib/pedagogy/frames/frame_catalogue.dart depuis reference/frames/<lieu>.cards.json.

Les conditions d'accès `unlocked` et `mastered` deviennent des prérequis de carte
(la carte requise doit être accessible) ; les conditions `skill` du moteur JSON
(niveaux de ses 67 021 nœuds) n'ont pas d'équivalent et sont ignorées.
"""
import json
import os

from common import REPO

def esc(x):
    return (x or '').replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')


def main():
    out = [
        '/// Catalogue des cartes du Theatrum et du Templum, dérivé des banques de référence',
        '/// (`reference/frames/<lieu>.cards.json`). Généré par tool/reference/gen_catalogue.py ;',
        '/// ne pas éditer à la main : les nœuds visés sont dans frame_cards.dart.',
        'library;', '',
        'class FrameSectionMeta {', '  const FrameSectionMeta(this.id, this.name, this.cards);', '  final String id;', '  final String name;', '  final List<String> cards;', '}', '',
        'class FrameCardMeta {',
        '  const FrameCardMeta({required this.place, required this.section, required this.card, required this.name, required this.subtitle, required this.price, required this.requires, required this.target, required this.lives, this.lesson = const [], this.examples = const [], this.vocabulary = const [], this.newVocabulary = const []});',
        '  final String place, section, card, name, subtitle;', '  final int price, target, lives;',
        '  /// Paragraphes de la leçon (latin) et entrées de vocabulaire « mot — sens ».', '  final List<String> lesson;', '  final List<String> examples;',
        '  final List<String> vocabulary, newVocabulary;',
        '  /// Adresses des cartes requises (accessibles avant celle-ci).', '  final List<String> requires;',
        "  String get id => '$place/$section/$card';", '}', '',
    ]
    for place in ['theatrum', 'templum']:
        m = json.load(open(os.path.join(REPO, f'reference/frames/{place}.cards.json'), encoding='utf-8'))
        order = [c['id'] for c in m['place']['children']]
        out.append(f'const List<FrameSectionMeta> k{place.capitalize()}Sections = [')
        for sid in order:
            sec = m['sections'][sid]
            out.append(f"  FrameSectionMeta('{sid}', '{esc(sec['name'])}', [{', '.join(repr(c) for c in sec['children'])}]),")
        out.append('];')
        out.append(f'const List<FrameCardMeta> k{place.capitalize()}Cards = [')
        for c in m['cards']:
            req = []
            for cond in ((c.get('requires') or {}).get('all') or []):
                for key in ('unlocked', 'mastered', 'completed'):
                    if key in cond and cond[key] not in req:
                        req.append(cond[key])
            enc = c.get('encounter') or {}
            lesson = ', '.join("'" + esc(t) + "'" for t in c.get('lesson', []))
            examples = ', '.join("'" + esc(t) + "'" for t in c.get('examples', []))
            vocabulary = ', '.join("'" + esc(t) + "'" for t in c.get('vocabulary', []))
            new_vocabulary = ', '.join("'" + esc(t) + "'" for t in c.get('newVocabulary', []))
            out.append(f"  FrameCardMeta(place: '{place}', section: '{c['section']}', card: '{c['card']}', name: '{esc(c['name'])}', subtitle: '{esc(c['subtitle'])}', price: {c['price']}, requires: [{', '.join(repr(x) for x in req)}], target: {enc.get('target', 5)}, lives: {enc.get('lives', 3)}, lesson: [{lesson}], examples: [{examples}], vocabulary: [{vocabulary}], newVocabulary: [{new_vocabulary}]),")
        out.append('];')
    path = os.path.join(REPO, 'lib/pedagogy/frames/frame_catalogue.dart')
    open(path, 'w', encoding='utf-8').write('\n'.join(out) + '\n')
    print('écrit', path)
    lexicon = json.load(open(os.path.join(REPO, 'reference/frames/lexicon.json'), encoding='utf-8'))
    out = [
        '/// Lexique des phrases et premières introductions. Généré par tool/reference/gen_catalogue.py.',
        'library;', '',
        'class FrameLexemeMeta {',
        '  const FrameLexemeMeta(this.latin, this.french, this.readingCard, this.productionCard);',
        '  final String latin, french;',
        '  final String? readingCard, productionCard;',
        '}', '',
        'const Map<String, FrameLexemeMeta> kFrameLexemes = {',
    ]
    for word, entry in lexicon.items():
        refs = ["'" + esc(entry['introduced'][p]) + "'" if p in entry['introduced'] else 'null' for p in ['theatrum', 'templum']]
        out.append(f"  '{esc(word)}': FrameLexemeMeta('{esc(entry['latin'])}', '{esc(entry['french'])}', {', '.join(refs)}),")
    out.append('};')
    path = os.path.join(REPO, 'lib/pedagogy/frames/frame_lexicon.dart')
    open(path, 'w', encoding='utf-8').write('\n'.join(out) + '\n')
    print('écrit', path)


if __name__ == '__main__':
    main()
