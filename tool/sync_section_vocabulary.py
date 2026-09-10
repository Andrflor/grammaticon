#!/usr/bin/env python3
"""Materialize final vocabulary cards from existing authored word translations.

No translation is inferred. A word without a declared translation raises an error.
The two directions have independent skills; only vocabulary questions assess them.
"""
import copy
import gzip
import json
from pathlib import Path
from question_banks import questions

D = Path(__file__).resolve().parents[1] / 'assets/designs/grammaticon'
def read(p): return json.loads(p.read_text())
def write(p, x): p.write_text(json.dumps(x, ensure_ascii=False, indent=2) + '\n')
k = json.load(gzip.open(D / 'knowledge.json.gz', 'rt'))
nodes = {n['id']: n for n in k['nodes']}
for place in ['theatrum', 'templum']:
    authored = {}
    for p in (D / 'places' / place).rglob('cards/vocabula/questions.json'):
        for q in read(p): authored.setdefault(q['item'], q)
    for section in (D / 'places' / place / 'sections').iterdir():
        words = set()
        for card_path in section.glob('cards/*/card.json'):
            if card_path.parent.name != 'vocabula':
                card = read(card_path)
                for q in questions(card_path.parent / card['questions']):
                    words.update(q['vocabulary'])
        p = section / 'cards/vocabula/questions.json'
        current = {q['item']: q for q in read(p)}
        bank = []
        for word in sorted(words):
            q = copy.deepcopy(current.get(word, authored.get(word)))
            if q is None: raise ValueError(f'No authored translation for {place}: {word}')
            bank.append(q)
        write(p, bank)
        card = read(p.parent / 'card.json')
        nodes[card['skills'][0]]['aggregation']['skills'] = sorted({s for q in bank for s in q['skills']})
(D / 'knowledge.json.gz').write_bytes(gzip.compress((json.dumps(k, ensure_ascii=False) + '\n').encode(), mtime=0))

# Keep the editorial inventory aligned with the actual per-place banks.
report_path = D / 'learning-content-report.json'
report = read(report_path)
translations = {}
for place in ['theatrum', 'templum']:
    for p in (D / 'places' / place).rglob('cards/vocabula/questions.json'):
        for q in read(p):
            answer = next(c['text'] for c in q['choices'] if c['id'] in q['accepted'])
            translations[q['item']] = {
                'id': q['item'],
                'lemma': q['content'][0]['text'] if place == 'theatrum' else answer,
                'meaning': answer if place == 'theatrum' else q['content'][0]['text'],
            }
for group in report['groups']:
    union = set()
    group['vocabularyByPlace'] = {}
    for place in ['theatrum', 'templum']:
        p = D / 'places' / place / 'sections' / group['id'] / 'cards/vocabula/questions.json'
        words = {q['item'] for q in read(p)}
        group['vocabularyByPlace'][place] = sorted(words)
        union.update(words)
    old = {v['id']: v for v in group['vocabulary']}
    group['vocabulary'] = [old.get(w, translations[w]) for w in sorted(union)]
    for topic in group['topics']:
        union = set()
        topic['vocabularyByPlace'] = {}
        for address in topic['cards'].values():
            place, section, card = address.split('/')
            directory = D / 'places' / place / 'sections' / section / 'cards' / card
            manifest = read(directory / 'card.json')
            words = {w for q in questions(directory / manifest['questions']) for w in q['vocabulary']}
            topic['vocabularyByPlace'][place] = sorted(words)
            union.update(words)
        topic['vocabulary'] = sorted(union)
report['curriculumByPlace'] = {}
for place in ['theatrum', 'templum']:
    manifest = read(D / 'places' / place / 'place.json')
    report['curriculumByPlace'][place] = []
    for child in manifest['children']:
        directory = D / 'places' / place / 'sections' / child['id']
        section = read(directory / 'section.json')
        words = [q['item'] for q in read(directory / 'cards/vocabula/questions.json')]
        report['curriculumByPlace'][place].append({
            'id': section['id'], 'name': section['name'],
            'cards': [c['id'] for c in section['children']], 'vocabulary': words,
        })
write(report_path, report)
