"""Exporte les patrons de l'Amphitheatrum et du Forum : ce que le générateur doit reproduire.

Un patron = (carte, dimension, interaction, contenu affiché, choix, acceptés, item, skills).
Les questions identiques à ces champs près sont comptées, pas répétées. Les feedbacks sont
conservés une fois par patron (ils sont eux-mêmes des gabarits).

Sortie : reference/patterns/<lieu>.jsonl.gz (un patron par ligne) et <lieu>.lexemes.json.
"""
import collections
import gzip
import json
import os
import sys

from common import REPO, cards, flatten, questions


def main(place):
    """Un patron = (dimension, interaction, contenu affiché, item, réponses acceptées), toutes cartes confondues.
    Les distracteurs varient d'une question à l'autre (tirage) : ils sont agrégés avec leur
    fréquence et un feedback témoin chacun, au lieu d'être répétés."""
    patterns = {}
    lexemes = collections.Counter()
    dims = collections.Counter()
    for address, directory, card in cards(place):
        for q, texts in questions(directory, card):
            f = flatten(q, texts)
            content = tuple((s['type'], s.get('text', s.get('asset', ''))) for s in f['content'])
            accepted = tuple(sorted(c['text'] for c in f['choices'] if c['id'] in f['accepted']))
            key = (f['dimension'], f['interaction'], content, f['item'], accepted)
            if key not in patterns:
                patterns[key] = {
                    'cards': [], 'dimension': f['dimension'], 'interaction': f['interaction'],
                    'prompt': f['prompt'], 'content': [dict(s) for s in f['content']],
                    'item': f['item'], 'skills': sorted(set(f['skills'])), 'help': f['help'],
                    'accepted': list(accepted), 'acceptedFeedback': None,
                    'distractors': {}, 'count': 0, 'ids': [],
                }
            p = patterns[key]
            p['count'] += 1
            if address not in p['cards']:
                p['cards'].append(address)
            for sk in f['skills']:
                if sk not in p['skills']:
                    p['skills'].append(sk)
            if len(p['ids']) < 2:
                p['ids'].append(f['id'])
            for c in f['choices']:
                o = f['outcomes'][c['id']]
                if c['id'] in f['accepted']:
                    p['acceptedFeedback'] = p['acceptedFeedback'] or o['feedback']
                else:
                    d = p['distractors'].setdefault(c['text'], {'count': 0, 'feedback': o['feedback'], 'observed': o['observed']})
                    d['count'] += 1
            lemma = (f['item'] or '').split('.')[0].split('|')[0]
            if lemma:
                lexemes[lemma] += 1
            dims[f['dimension']] += 1
    os.makedirs(os.path.join(REPO, 'reference/patterns'), exist_ok=True)
    with gzip.open(os.path.join(REPO, f'reference/patterns/{place}.jsonl.gz'), 'wt', encoding='utf-8') as out:
        for p in patterns.values():
            out.write(json.dumps(p, ensure_ascii=False) + '\n')
    with open(os.path.join(REPO, f'reference/patterns/{place}.lexemes.json'), 'w', encoding='utf-8') as out:
        json.dump(dict(sorted(lexemes.items())), out, ensure_ascii=False, indent=1)
    total = sum(p['count'] for p in patterns.values())
    surfaces = len({tuple(s['text'] for s in p['content'] if 'text' in s) for p in patterns.values()})
    distractors = sum(len(p['distractors']) for p in patterns.values())
    print(f'{place}: {total} questions -> {len(patterns)} patrons, {surfaces} surfaces distinctes, '
          f'{distractors} distracteurs distincts, {len(lexemes)} lexèmes')


if __name__ == '__main__':
    for place in sys.argv[1:] or ['amphitheatrum', 'forum']:
        main(place)
