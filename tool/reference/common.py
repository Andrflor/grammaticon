"""Lecture des banques pré-générées (corpus de référence). Aucune génération."""
import glob
import gzip
import json
import os

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ROOT = os.path.join(REPO, 'assets/designs/grammaticon/places')


def load(path):
    with (gzip.open(path, 'rt', encoding='utf-8') if path.endswith('.gz') else open(path, encoding='utf-8')) as f:
        return json.load(f)


def text(value, texts):
    """Résout une référence de texte stocké et une éventuelle carte de langues."""
    if isinstance(value, dict) and 'ref' in value:
        value = texts.get(value['ref'], '')
    if isinstance(value, dict):
        value = value.get('la') or value.get('fr') or next(iter(value.values()), '')
    return '' if value is None else str(value)


def cards(place):
    """Itère (adresse de carte, dossier, card.json) d'un lieu, dans l'ordre des fichiers."""
    for card_file in sorted(glob.glob(f'{ROOT}/{place}/sections/*/cards/*/card.json')):
        directory = os.path.dirname(card_file)
        section, card = directory.split('/sections/')[1].split('/cards/')
        yield f'{place}/{section}/{card}', directory, json.load(open(card_file, encoding='utf-8'))


def raw_questions(directory, card):
    """Itère (question matérialisée, dictionnaire de textes) de toutes les parties d'une carte."""
    bank = load(os.path.join(directory, card['questions']))
    index = bank if isinstance(bank, list) else (bank.get('index') or bank.get('questions'))
    parts = sorted({q['part'] for q in index if 'part' in q})
    chunks = (load(os.path.join(directory, p)) for p in parts) if parts else [
        bank if isinstance(bank, dict) else {'texts': {}, 'questions': index}]
    for chunk in chunks:
        texts = chunk.get('texts', {})
        for q in chunk['questions']:
            yield q, texts


def questions(directory, card):
    from context_banks import prepared
    place, suffix = directory.split('/places/')[1].split('/sections/')
    section, cid = suffix.split('/cards/')
    address = f'{place}/{section}/{cid}'
    content = prepared()
    if cid == 'vocabula':
        for q in content['vocabulary'][address]:
            yield q, {}
        return
    from context_banks import canonical_question
    for q, texts in raw_questions(directory, card):
        yield canonical_question(q, section, texts), texts
    for q in content['expansions'].get(address, []):
        yield q, {}


def flatten(q, texts):
    """Question à plat : chaînes résolues, structure conservée."""
    return {
        'id': q['id'],
        'dimension': q['dimension'],
        'interaction': q['interaction'],
        'item': q.get('item'),
        'skills': q['skills'],
        'prompt': text(q.get('prompt'), texts),
        'content': [
            {'type': s['type'], 'text': text(s.get('text'), texts)} if s['type'] != 'image' else {'type': 'image', 'asset': s.get('asset')}
            for s in q.get('content', [])
        ],
        'choices': [{'id': c['id'], 'text': text(c['text'], texts), 'lexeme': c.get('lexeme')} for c in q['choices']],
        'accepted': q['accepted'],
        'outcomes': {
            k: {
                'feedback': text(o.get('feedback'), texts),
                'observed': o.get('observed', []),
                'hypotheses': o.get('hypotheses', []),
                'practice': o.get('practice', []),
                'suspecta': o.get('suspecta', []),
            }
            for k, o in q['outcomes'].items()
        },
        'help': q.get('help'),
        'vocabulary': q.get('vocabulary', []),
        'evidenceItem': q.get('evidenceItem') or q.get('assessment') or q.get('item') or q['id'],
        'selectionGroup': q.get('selectionGroup'),
    }
