"""Read/materialize authored banks offline, using the same index contract as Dart."""
import gzip
import json
from pathlib import Path


def read(path):
    path = Path(path)
    return json.load(gzip.open(path, 'rt')) if path.suffix == '.gz' else json.loads(path.read_text())


def write(path, value):
    path = Path(path)
    data = (json.dumps(value, ensure_ascii=False, separators=(',', ':')) + '\n').encode()
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(gzip.compress(data, mtime=0) if path.suffix == '.gz' else data)


def expand(value, texts):
    if isinstance(value, dict):
        if set(value) == {'ref'}:
            return texts[value['ref']]
        return {k: expand(v, texts) for k, v in value.items()}
    if isinstance(value, list):
        return [expand(v, texts) for v in value]
    return value


def questions(path):
    path = Path(path)
    bank = read(path)
    if isinstance(bank, list):
        yield from bank
    elif 'index' in bank:
        # Parts must remain contiguous in an authored index; avoid retaining a
        # million materialized questions just to audit one section.
        previous = None
        for entry in bank['index']:
            if previous != entry['part']:
                part = read(path.parent / entry['part'])
                current = {q['id']: q for q in part['questions']}
                texts = part.get('texts', {})
                previous = entry['part']
            yield expand(current[entry['id']], texts)
    else:
        for q in bank['questions']:
            yield expand(q, bank.get('texts', {}))


def write_indexed(directory, bank, chunk_size=256):
    """Persist complete questions, never templates or executable generation rules."""
    directory = Path(directory)
    index, chunk, part_number = [], [], 0
    keys = ['id', 'dimension', 'item', 'assessment', 'skills', 'evidenceItem',
            'eligible', 'next', 'followUpOnly', 'legacyKeys', 'selectionGroup']
    def flush():
        nonlocal part_number, chunk
        if not chunk:
            return
        name = f'curriculum-part-{part_number:04d}.json.gz'
        write(directory / name, {'texts': {}, 'questions': chunk})
        index.extend({**{k: q[k] for k in keys if k in q}, 'part': name} for q in chunk)
        chunk, part_number = [], part_number + 1
    for q in bank:
        chunk.append(q)
        if len(chunk) >= chunk_size:
            flush()
    flush()
    write(directory / 'questions.json.gz', {'index': index})
    # Remove only stale parts owned by this materializer.
    used = {e['part'] for e in index}
    for path in directory.glob('curriculum-part-*.json.gz'):
        if path.name not in used:
            path.unlink()
    return len(index)
