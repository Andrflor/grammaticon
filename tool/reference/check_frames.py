"""Fast executable-bank contract check and per-card census (read-only).

The exhaustive rendered-surface and runtime/graph checks are in
test/arbor/frame_bank_contract_test.dart. This checks the artifacts independently
of Flutter and refuses truncation or repeated lexical finals.
"""
import base64
import collections
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]


def read(path):
    return json.loads((ROOT / path).read_text())


def check():
    report = {'places': {}}
    for place in ['theatrum', 'templum']:
        frames = read(f'assets/arbor/frames/{place}.json')['frames']
        meta = read(f'reference/frames/{place}.cards.json')
        by_card = collections.defaultdict(list)
        for f in frames:
            by_card[f['card']].append(f)
            assert any(c['accepted'] for c in f['choices']) and any(not c['accepted'] for c in f['choices']), f['id']
            assert all(c['outcome']['feedback'] for c in f['choices']), f['id']
            rows = f['alignedPacked']
            assert rows['length'] == f['instances'], f['id']
            assert len(rows['columns']) == len(rows['widths']) == len(f['slots']) + 2, f['id']
            assert len(base64.b64decode(rows['data'])) == rows['length'] * sum(rows['widths']), f['id']
        cards = {c['id']: c for c in meta['cards']}
        assert set(by_card) == set(cards)
        seen, assessed = set(), set()
        sections = []
        for child in meta['place']['children']:
            sid = child['id']
            section = meta['sections'][sid]
            entries, words = [], set()
            for cid in section['children']:
                if cid == 'vocabula': continue
                address = f'{place}/{sid}/{cid}'
                c = cards[address]
                new = set(c['vocabulary']) - seen
                assert new == set(c['newVocabulary']) and len(new) >= 5, address
                seen.update(c['vocabulary'])
                words.update(new)
                available = sum(f['alignedPacked']['length'] for f in by_card[address])
                assert available == c['sentenceQuestions'] and available >= 200, address
                entries.append({'card': cid, 'questions': available, 'newVocabulary': len(new)})
            finals = by_card[f'{place}/{sid}/vocabula']
            tested = {next(c['lexeme'] for c in f['choices'] if c['accepted']) for f in finals}
            assert len(tested) == len(finals) and tested == words, (place, sid)
            assert not assessed & tested, (place, sid)
            assessed.update(tested)
            sections.append({'section': sid, 'cards': entries, 'newVocabulary': len(tested)})
        size = (ROOT / f'assets/arbor/frames/{place}.json').stat().st_size
        report['places'][place] = {'sentenceQuestions': sum(c['questions'] for s in sections for c in s['cards']),
                                   'vocabularyQuestions': len(assessed), 'assetBytes': size, 'sections': sections}
    return report


if __name__ == '__main__':
    report = check()
    if '--json' in sys.argv:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        for place, summary in report['places'].items():
            print(f"{place}: {summary['sentenceQuestions']:,} phrases, {summary['vocabularyQuestions']} mots, {summary['assetBytes'] / 1048576:.1f} MiB")
            for s in summary['sections']:
                print(s['section'] + ': ' + ', '.join(f"{c['card']}={c['questions']} (+{c['newVocabulary']} mots)" for c in s['cards']))
