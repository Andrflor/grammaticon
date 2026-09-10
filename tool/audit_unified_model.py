#!/usr/bin/env python3
"""Exhaustive structural validation of the one skill-evidence contract.

Does not certify linguistic exhaustiveness. Reads every stored question and its
index, checks compositions, prerequisites, attribution and source-text hashes.
"""
import argparse
from collections import Counter
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def read(path):
    return json.load(gzip.open(path, 'rt')) if path.suffix == '.gz' else json.loads(path.read_text())

def fingerprint(q, texts):
    def expand(v):
        if isinstance(v, dict):
            if set(v) == {'ref'}: return texts[v['ref']]
            return {k: expand(x) for k, x in v.items()}
        return [expand(x) for x in v] if isinstance(v, list) else v
    payload = {key: q.get(key) for key in ['id', 'interaction', 'dimension', 'item', 'assessment', 'prompt', 'content', 'context', 'choices', 'accepted', 'next', 'help']}
    payload['feedback'] = {c: o['feedback'] for c, o in q['outcomes'].items()}
    return json.dumps(expand(payload), ensure_ascii=False, sort_keys=True, separators=(',', ':')).encode()

def audit(design_id):
    base = ROOT / 'assets/designs' / design_id
    root = read(base / 'game.json')
    registry = read(base / root['knowledge'])
    knowledge = {n['id']: n for n in registry['nodes']}
    errors = []
    if len(knowledge) != len(registry['nodes']): errors.append('Duplicate knowledge ID')
    if 'evidence' in read(base / root['rules'])['mastery']: errors.append('Obsolete evaluation mode switch')
    cache = {}
    def leaves(sid, active=()):
        if sid in cache: return cache[sid]
        if sid in active: raise ValueError('Composition cycle: ' + sid)
        if sid not in knowledge: raise ValueError('Missing skill: ' + sid)
        node = knowledge[sid]
        if 'aggregation' not in node: result = {sid}
        else:
            children = node['aggregation']['skills']
            if not children or len(children) != len(set(children)): raise ValueError('Invalid composition: ' + sid)
            result = set().union(*(leaves(c, active + (sid,)) for c in children))
        cache[sid] = result
        return result
    visited = set()
    def dependencies(sid, active=()):
        if sid in active: raise ValueError('Dependency cycle: ' + sid)
        if sid in visited: return
        if sid not in knowledge: raise ValueError('Missing prerequisite: ' + sid)
        n = knowledge[sid]
        for ref in n.get('requires', []) + n.get('aggregation', {}).get('skills', []): dependencies(ref, active + (sid,))
        visited.add(sid)
    for sid in knowledge:
        leaves(sid); dependencies(sid)
    counts = {}
    for place in root['places']:
        totals = Counter(); evidence = set(); digest = hashlib.sha256()
        for cp in sorted((base / 'places' / place).rglob('card.json')):
            c = read(cp); totals['cards'] += 1
            if 'evidence' in c: errors.append(f'Obsolete per-card evaluation mode: {cp}')
            allowed = set().union(*(leaves(s) for s in c['skills']))
            bank = read(cp.parent / c['questions']); seen = set()
            index = {q['id']: q for q in bank['index']} if isinstance(bank, dict) else None
            documents = ((part, read(cp.parent / part)) for part in sorted({q['part'] for q in bank['index']})) if index is not None else [(None, {'texts': {}, 'questions': bank})]
            for part, document in documents:
                for q in document['questions']:
                    totals['questions'] += 1; evidence.update(q['skills'])
                    if q['id'] in seen: errors.append(f'Duplicate question: {cp} {q["id"]}')
                    seen.add(q['id'])
                    if index is not None:
                        entry = index.get(q['id'])
                        if not entry or entry['part'] != part or any(entry.get(f) != q.get(f) for f in ['skills', 'evidenceItem', 'dimension', 'item', 'assessment', 'eligible', 'next', 'followUpOnly', 'legacyKeys', 'selectionGroup']):
                            errors.append(f'Index mismatch: {cp} {q["id"]}')
                    if not q['skills'] or not set(q['skills']) <= allowed or any(knowledge[s].get('aggregation') for s in q['skills']):
                        errors.append(f'Invalid assessed leaves: {cp} {q["id"]}')
                    if any(ref not in knowledge for ref in q.get('requires', [])): errors.append(f'Missing prerequisite: {cp} {q["id"]}')
                    totals['questionsWithPrerequisites'] += bool(q.get('requires'))
                    choices = {choice['id'] for choice in q['choices']}
                    if not set(q['accepted']) < choices or choices != set(q['outcomes']): errors.append(f'Invalid choices: {cp} {q["id"]}')
                    for choice, outcome in q['outcomes'].items():
                        failed = set(outcome['observed'])
                        if choice in q['accepted']:
                            if failed: errors.append(f'Accepted failure: {q["id"]}')
                        else:
                            totals['wrongChoices'] += 1
                            if not failed or not failed <= set(q['skills']): errors.append(f'Invalid failure attribution: {cp} {q["id"]}')
                            totals['partialFailures'] += len(failed) < len(q['skills'])
                    digest.update(fingerprint(q, document['texts']))
            if index is not None and set(index) != seen: errors.append(f'Incomplete index: {cp}')
        counts[place] = {**totals, 'fineSkills': len(evidence), 'contentSha256': digest.hexdigest()}
    proof_path = ROOT / 'doc/pedagogy/skills/unification.json'
    if design_id == 'grammaticon' and proof_path.exists():
        proof = read(proof_path)
        for place in ['forum', 'amphitheatrum']:
            if counts[place]['contentSha256'] != proof[place]['before']:
                errors.append('Original content fingerprint changed: ' + place)
    return {'design': design_id, 'passed': not errors, 'places': counts, 'errors': errors}

if __name__ == '__main__':
    parser = argparse.ArgumentParser(); parser.add_argument('--design', default='grammaticon'); parser.add_argument('--write', action='store_true'); args = parser.parse_args()
    result = audit(args.design)
    if args.write: (ROOT / f'doc/pedagogy/skills/{args.design}-model-audit.json').write_text(json.dumps(result, ensure_ascii=False, indent=2)+'\n')
    print(json.dumps(result, ensure_ascii=False, indent=2))
    raise SystemExit(not result['passed'])
