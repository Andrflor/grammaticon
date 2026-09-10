#!/usr/bin/env python3
"""Audit existing lexical headwords and question references; never create questions."""
import argparse
import json
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DESIGN = ROOT / 'assets/designs/grammaticon'
REPORT = ROOT / 'doc/pedagogy/contracts/familia-romana-lexical-traceability.json'


def normalized(text):
    text = ''.join(c for c in unicodedata.normalize('NFD', text.lower())
                   if not unicodedata.combining(c))
    return text.replace('-', '').replace('j', 'i').replace('v', 'u')


def audit():
    catalog = json.loads((DESIGN / 'learning-content-report.json').read_text())
    source = json.loads((ROOT / 'doc/pedagogy/contracts/familia-romana-lexical-candidates.json').read_text())
    index, evidence = {}, {}
    for group in catalog['groups']:
        for word in group['vocabulary']:
            head = normalized(word['lemma'].split(',')[0].strip())
            index.setdefault(head, set()).add(word['id'])
    for place in ['theatrum', 'templum']:
        for path in sorted((DESIGN / 'places' / place).rglob('questions.json')):
            parts = path.relative_to(DESIGN / 'places').parts
            card = '/'.join([parts[0], parts[2], parts[4]])
            for question in json.loads(path.read_text()):
                for word in question['vocabulary']:
                    evidence.setdefault(word, {}).setdefault(card, []).append(question['id'])
    entries = []
    for entry in source['entries']:
        matches = set()
        for head in entry['headword'].split('/'):
            matches.update(index.get(normalized(head), []))
        entries.append({
            'sourceEntry': entry['id'], 'headword': entry['headword'],
            'sourcePage': entry['sourcePage'],
            'status': 'surface-match-requires-sense-review' if matches else 'no-surface-match',
            'candidateDesignLexemes': sorted(matches),
            'questionEvidence': [
                {'lexeme': word, 'card': card, 'questions': ids}
                for word in sorted(matches)
                for card, ids in sorted(evidence[word].items())
            ],
        })
    matched = sum(bool(e['candidateDesignLexemes']) for e in entries)
    return {
        'source': source['source'],
        'scope': 'Theatrum and Templum only; Amphitheatrum and Forum are excluded.',
        'method': 'Normalized headword surfaces only: remove compound separators and quantities; normalize i/j and u/v. Matches do not certify senses, homographs, finite/infinitive aliases or pedagogical coverage.',
        'completionStatus': 'not-certified',
        'summary': {'sourceCandidates': len(entries), 'surfaceMatched': matched,
                    'withoutSurfaceMatch': len(entries) - matched},
        'entries': entries,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Fail if the saved evidence is stale.')
    args = parser.parse_args()
    result = audit()
    if args.check:
        if not REPORT.exists() or json.loads(REPORT.read_text()) != result:
            raise SystemExit('Lexical evidence is stale; rerun this audit without --check.')
    else:
        REPORT.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps(result['summary']))


if __name__ == '__main__':
    main()
