#!/usr/bin/env python3
"""Read-only release gate for the authored learning design; never generates content."""
import argparse
from collections import Counter
import gzip
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--catalog-only', action='store_true')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
design = root / 'assets/designs/grammaticon'
read = lambda p: json.loads(p.read_text())
report = read(design / 'learning-content-report.json')
with gzip.open(design / 'knowledge.json.gz', 'rt', encoding='utf-8') as stream:
    knowledge = {node['id']: node for node in json.load(stream)['nodes']}
errors = []
question_ids = {}
generic_sentence_diagnostics = Counter()
counts = {'groups': len(report['groups']), 'cards': 0, 'questions': 0}
for place, mode in [('theatrum', 'version'), ('templum', 'theme')]:
    manifest = read(design / 'places' / place / 'place.json')
    free = []
    for group in manifest['children']:
        folder = design / 'places' / place / 'sections' / group['id']
        section = read(folder / 'section.json')
        if len(section['children']) < 4:
            errors.append(f'{place}/{group["id"]}: too few distinct subject cards')
        if section['children'][-1]['id'] != 'vocabula':
            errors.append(f'{place}/{group["id"]}: vocabulary is not last')
        declared = next(g for g in report['groups'] if g['id'] == group['id'])
        lexical_ids = {v['id'] for v in declared['vocabulary']}
        for child in section['children']:
            address = f'{place}/{group["id"]}/{child["id"]}'
            directory = folder / 'cards' / child['id']
            card = read(directory / 'card.json')
            bank = read(directory / card['questions'])
            question_ids[address] = {q['id'] for q in bank}
            # Choice order is authored: grammatical categories may have stable keys.
            # Runtime shuffle is optional and defaults to false.
            if 'shuffleChoices' in card and not isinstance(card['shuffleChoices'], bool):
                errors.append(f'{address}: invalid activity choice-order setting')
            for question in bank:
                if 'shuffleChoices' in question and not isinstance(question['shuffleChoices'], bool):
                    errors.append(f'{address}: invalid question choice-order setting')
            counts['cards'] += 1
            counts['questions'] += len(bank)
            if len(card['skills']) != 1:
                errors.append(f'{address}: expected one progression')
            if card['name'] in ['Thema', 'Versiō', 'Lexique de la section']:
                errors.append(f'{address}: generic or non-Latin label')
            if card['access']['price'] == 0:
                free.append(address)
            elif not card['access']['requires']['all']:
                errors.append(f'{address}: missing prerequisites')
            if child['id'] == 'vocabula':
                ids = [q['id'] for q in bank]
                if len(ids) != len(set(ids)) or set(ids) != lexical_ids:
                    errors.append(f'{address}: incomplete or duplicate lexical bank')
                required = knowledge[card['skills'][0]].get('masteryRequirements', {}).get('successfulItems', [])
                if set(required) != {q['item'] for q in bank}:
                    errors.append(f'{address}: mastery can omit encountered lexical items')
            for q in bank:
                if child['id'] != 'vocabula':
                    for choice, outcome in q['outcomes'].items():
                        if choice not in q['accepted'] and not (
                            set(outcome.get('observed', [])) - {'study.error'}
                            or outcome.get('hypotheses')
                        ):
                            generic_sentence_diagnostics[address] += 1
                if q.get('editorial', {}).get('language') != 'la':
                    errors.append(f'{address}#{q["id"]}: missing Latin editorial declaration')
                if any(o.get('practice') for o in q['outcomes'].values()):
                    errors.append(f'{address}#{q["id"]}: added review route')
    if free != [f'{place}/loca/a-ablative']:
        errors.append(f'{place}: free cards are not limited to the starting card')
if not args.catalog_only:
    for address, count in generic_sentence_diagnostics.items():
        errors.append(f'{address}: {count} incorrect sentence outcomes lack specific diagnostics')
    from audit_lexical_traceability import REPORT, audit
    from audit_existing_content import existing_cards, existing_question_digest

    if not REPORT.exists() or read(REPORT) != audit():
        errors.append('Lexical traceability evidence is stale')
    contract = read(root / 'doc/pedagogy/contracts/completion.json')
    for gate in contract['gates']:
        if not gate['passed']:
            errors.append('Open completion gate: ' + gate['id'])
    coverage = read(root / 'doc/pedagogy/coverage.json')
    for book in coverage['books']:
        pending = sum(unit['status'] != 'verified-covered' for unit in book['units'])
        if pending:
            errors.append(f'{book["id"]}: {pending} source units lack verified coverage')
        for unit in book['units']:
            requirements = {
                f'{kind}:{item}'
                for kind in ['lexemes', 'senses', 'constructions', 'readingObjectives']
                for item in unit[kind]
            }
            mapped = set()
            for evidence in unit['gameQuestions']:
                address = evidence['card']
                if address not in question_ids:
                    if address not in existing_cards():
                        errors.append(f'{unit["id"]}: unaudited evidence bank {address}')
                        continue
                    ids = evidence.get('questions', [])
                    if not ids:
                        errors.append(f'{unit["id"]}: empty evidence in {address}')
                        continue
                    try:
                        for qid in ids:
                            digest = existing_question_digest(address, qid)
                            if evidence.get('questionDigests', {}).get(qid) != digest:
                                raise ValueError(f'Missing or stale review fingerprint: {qid}')
                    except (KeyError, StopIteration, ValueError) as error:
                        errors.append(f'{unit["id"]}: unresolved original-bank evidence {address}: {error}')
                        continue
                    # This verifies references only. Pedagogical scope and review
                    # remain explicit editorial requirements below.
                    resolved = True
                else:
                    resolved = bool(evidence.get('questions')) and set(evidence['questions']) <= question_ids[address]
                ids = evidence.get('questions', [])
                if not resolved:
                    errors.append(f'{unit["id"]}: unresolved questions in {address}')
                    continue
                covers = set(evidence.get('covers', []))
                if not covers <= requirements:
                    errors.append(f'{unit["id"]}: evidence names undeclared requirements')
                mapped.update(covers)
            if unit['status'] == 'verified-covered':
                if any(not unit[kind] for kind in ['lexemes', 'senses', 'constructions', 'readingObjectives']):
                    errors.append(f'{unit["id"]}: verified unit has an empty requirement inventory')
                if requirements - mapped:
                    errors.append(f'{unit["id"]}: verified unit has unmapped requirements')
                if unit['linguisticReview'] != 'verified':
                    errors.append(f'{unit["id"]}: linguistic review is not verified')
print(json.dumps({'mode': 'catalog-only' if args.catalog_only else 'full-objective', 'catalog': counts, 'validationPassed': not errors, 'objectiveComplete': None if args.catalog_only else not errors, 'errors': errors}, indent=2))
raise SystemExit(1 if errors else 0)
