#!/usr/bin/env python3
"""Inventory existing indexed banks and sample their actual tasks. Never author questions."""
import argparse
from collections import Counter
from functools import lru_cache
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DESIGN = ROOT / 'assets/designs/grammaticon'
REPORT = ROOT / 'doc/pedagogy/contracts/existing-activities-inventory.json'


def read(path):
    if path.suffix == '.gz':
        with gzip.open(path, 'rt', encoding='utf-8') as stream:
            return json.load(stream)
    return json.loads(path.read_text())


@lru_cache(maxsize=1)
def existing_cards():
    result = {}
    for place in ['amphitheatrum', 'forum']:
        for path in (DESIGN / 'places' / place).rglob('card.json'):
            parts = path.relative_to(DESIGN / 'places').parts
            result['/'.join([parts[0], parts[2], parts[4]])] = path
    return result


@lru_cache(maxsize=16)
def existing_index(address):
    path = existing_cards()[address]
    card = read(path)
    return path.parent, {q['id']: q for q in read(path.parent / card['questions'])['index']}


def resolve_existing_question(address, question_id):
    """Resolve an explicit editorial reference against the current authored bank."""
    directory, index = existing_index(address)
    entry = index[question_id]
    data = read(directory / entry['part'])
    question = next(q for q in data['questions'] if q['id'] == question_id)
    # Both the index and payload must agree; merely having an index ID is not proof.
    if question['dimension'] != entry['dimension'] or question['item'] != entry['item']:
        raise ValueError(f'Index/payload disagreement: {address}#{question_id}')
    def resolve(value):
        if isinstance(value, dict):
            if set(value) == {'ref'}:
                return data['texts'][value['ref']]
            return {key: resolve(item) for key, item in value.items()}
        if isinstance(value, list):
            return [resolve(item) for item in value]
        return value

    return resolve(question)


def existing_question_digest(address, question_id):
    question = resolve_existing_question(address, question_id)
    canonical = json.dumps(question, ensure_ascii=False, sort_keys=True, separators=(',', ':'))
    return hashlib.sha256(canonical.encode()).hexdigest()


def audit():
    cards, totals = [], Counter()
    for place in ['amphitheatrum', 'forum']:
        for path in sorted((DESIGN / 'places' / place).rglob('card.json')):
            card = read(path)
            parts = path.relative_to(DESIGN / 'places').parts
            address = '/'.join([parts[0], parts[2], parts[4]])
            document = read(path.parent / card['questions'])
            index = document['index']
            dimensions = Counter(q['dimension'] for q in index)
            items = sorted({q['item'] for q in index})
            selected = {}
            for q in index:
                selected.setdefault(q['dimension'], q)
            loaded, samples = {}, []
            for dimension, entry in sorted(selected.items()):
                part = entry['part']
                if part not in loaded:
                    data = read(path.parent / part)
                    loaded[part] = (data['texts'], {q['id']: q for q in data['questions']})
                texts, questions = loaded[part]
                q = questions[entry['id']]

                def text(value):
                    return texts[value['ref']] if isinstance(value, dict) else value

                samples.append({
                    'question': q['id'], 'dimension': dimension,
                    'prompt': text(q['prompt']),
                    'content': [{'type': block['type'], 'text': text(block['text'])}
                                for block in q['content']],
                    'acceptedAnswers': [text(choice['text']) for choice in q['choices']
                                        if choice['id'] in q['accepted']],
                    'attributes': q.get('attributes', {}),
                    'reviewStatus': 'sample-retrieved-not-certified',
                })
            cards.append({
                'card': address, 'name': card['name'], 'skills': card['skills'],
                'questionCount': len(index), 'dimensions': dict(sorted(dimensions.items())),
                'itemIds': items, 'samples': samples,
                'scope': 'Complete index inventory; one materialized sample per dimension, not a review of every question.',
            })
            totals.update(dimensions)
    return {
        'status': 'inventory-not-reading-coverage-certification',
        'method': 'Read the existing question indices and retrieve one authored question per dimension per card. Item identifiers are opaque; they are not automatically equated with source lexemes or senses. Sampling does not certify unsampled content.',
        'summary': {'cards': len(cards), 'questions': sum(totals.values()),
                    'dimensions': dict(sorted(totals.items())),
                    'distinctItemIds': len({item for c in cards for item in c['itemIds']}),
                    'materializedSamples': sum(len(c['samples']) for c in cards)},
        'cards': cards,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    result = audit()
    if args.check:
        if not REPORT.exists() or read(REPORT) != result:
            raise SystemExit('Existing-activity inventory is stale')
    else:
        REPORT.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps(result['summary'], ensure_ascii=False))


if __name__ == '__main__':
    main()
