#!/usr/bin/env python3
"""Development library and CLI for the Theatrum corpora.

Sources (verse-per-line exports of eBible.org, public domain, copied verbatim
into assets/corpus/ with their provenance pages in tool/corpus/bible/provenance/):

* Latin  — ``latVUC``: "Bibbia Vulgata Clementina na 1598 / Clementine Vulgate
  of 1598 with Glossa Ordinaria, Migne edition 1880" (eBible.org id latVUC).
  The brief asked for the "1901 Clementine Vulgate" (the Desclée / Society of
  St John the Evangelist printing of 1901, itself an edition of the 1598
  Vatican text); no verified digital transcription of that printing exists,
  so the Clementine text is used through the Migne 1880 edition and every
  metadata record says so. Nothing is labelled "1901".
* French — ``fraLSG``: "Louis Segond 1910", eBible.org id fraLSG, public domain
  (https://ebible.org/fraLSG/copyright.htm).

Sub-commands::

    python3 tool/corpus/bible/corpus.py align       # alignment tables (books, chapters, psalms)
    python3 tool/corpus/bible/corpus.py inventory   # Latin surface-form inventory + resolution
    python3 tool/corpus/bible/corpus.py show JOH 3:16 PSA 22:1 ...   # verses side by side

The text files are never modified: ``[`` / ``]`` (poetry markers of the
eBible export) are stripped only in the *normalised* view used for matching.
"""
from __future__ import annotations

import json
import os
import re
import sys
import unicodedata
from collections import Counter, defaultdict
from dataclasses import dataclass

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
LAT_FILE = os.path.join(ROOT, 'assets', 'corpus', 'latVUC_vpl.txt')
FRA_FILE = os.path.join(ROOT, 'assets', 'corpus', 'fraLSG_vpl.txt')
OUT_DIR = os.path.join(ROOT, 'tool', 'corpus', 'out')

EDITIONS = {
    'la': {
        'id': 'latVUC',
        'language': 'la',
        'title': 'Biblia Sacra Vulgata Clementina (textus 1598), editio Migne 1880',
        'source': 'eBible.org, id latVUC, verse-per-line export dated 2026-08-08 (source files 2025-12-12)',
        'license': 'Public Domain',
        'url': 'https://ebible.org/find/details.php?id=latVUC',
        'requested': '1901 Clementine Vulgate (Desclée printing)',
        'note': 'The 1901 Desclée printing was requested; no verified digital transcription of it is available. '
                'This is the same Clementine recension (Vatican 1598) in the Migne 1880 edition; orthography (æ, j) is kept as in the source.',
    },
    'fr': {
        'id': 'fraLSG',
        'language': 'fr',
        'title': 'La Sainte Bible, Louis Segond 1910',
        'source': 'eBible.org, id fraLSG, verse-per-line export dated 2026-08-08',
        'license': 'Public Domain (https://ebible.org/fraLSG/copyright.htm)',
        'url': 'https://ebible.org/find/details.php?id=fraLSG',
    },
}

# ---------------------------------------------------------------------------
# loading

@dataclass(frozen=True)
class Ref:
    book: str
    chapter: int
    verse: int

    def __str__(self) -> str:
        return f'{self.book} {self.chapter}:{self.verse}'

    @staticmethod
    def parse(s: str) -> 'Ref':
        m = re.fullmatch(r'\s*([1-3]?[A-Z]{2,3})\s+(\d+):(\d+)\s*', s)
        if not m:
            raise ValueError(f'bad reference {s!r}')
        return Ref(m.group(1), int(m.group(2)), int(m.group(3)))


def load(path: str) -> dict[Ref, str]:
    out: dict[Ref, str] = {}
    with open(path, encoding='utf-8') as f:
        for line in f:
            line = line.rstrip('\n')
            if not line:
                continue
            code, cv, text = line.split(' ', 2)
            ch, vs = cv.split(':')
            out[Ref(code, int(ch), int(vs))] = text
    return out


def load_latin() -> dict[Ref, str]:
    return load(LAT_FILE)


def load_french() -> dict[Ref, str]:
    return load(FRA_FILE)


# ---------------------------------------------------------------------------
# normalisation

_WS = re.compile(r'\s+')


def clean(text: str) -> str:
    """Display form: poetry markers removed, whitespace collapsed, wording untouched."""
    return _WS.sub(' ', text.replace('[', '').replace(']', '')).strip()


def latin_key(token: str) -> str:
    """Matching key of a Latin token: lower case, æ/œ expanded, j → i, no macrons."""
    t = token.lower().replace('æ', 'ae').replace('œ', 'oe').replace('j', 'i')
    t = unicodedata.normalize('NFD', t)
    t = ''.join(c for c in t if unicodedata.category(c) != 'Mn')
    return t


_TOKEN = re.compile(r"[A-Za-zÆŒæœÀ-ÿ]+")


def latin_tokens(text: str) -> list[str]:
    return _TOKEN.findall(clean(text))


def french_norm(text: str) -> str:
    """Comparison form for French: typographic apostrophes and spaces unified."""
    t = clean(text).replace('’', "'").replace(' ', ' ').replace(' ', ' ')
    t = re.sub(r'\s+([;:!?])', r'\1', t)
    return t


# ---------------------------------------------------------------------------
# alignment: books and psalm numbering

LSG_MISSING_BOOKS = ['TOB', 'JDT', 'WIS', 'SIR', 'BAR', '1MA', '2MA']


def psalm_to_lsg(ch: int, vs: int) -> tuple[int, int] | None:
    """Vulgate (Septuagint) psalm numbering → Louis Segond (Hebrew) numbering.

    Both editions count the title as verse 1, so verses map one-to-one except
    where the Vulgate joins two Hebrew psalms (9, 113, 114+115, 146+147).
    """
    if ch <= 8 or ch >= 148:
        return ch, vs
    if ch == 9:
        return (9, vs) if vs <= 21 else (10, vs - 21)
    if 10 <= ch <= 112:
        return ch + 1, vs
    if ch == 113:
        return (114, vs) if vs <= 8 else (115, vs - 8)
    if ch == 114:
        return 116, vs
    if ch == 115:  # Vulgate numbers its verses 10–19 already
        return 116, vs
    if 116 <= ch <= 145:
        return ch + 1, vs
    if ch == 146:
        return 147, vs
    if ch == 147:  # verses 12–20 in the Vulgate, same numbers in Segond
        return 147, vs
    return None


def to_lsg(ref: Ref) -> Ref | None:
    """Default alignment of a Vulgate reference (books absent from Segond → None)."""
    if ref.book in LSG_MISSING_BOOKS:
        return None
    if ref.book == 'PSA':
        m = psalm_to_lsg(ref.chapter, ref.verse)
        return None if m is None else Ref('PSA', *m)
    return ref


def alignment_report(la: dict[Ref, str], fr: dict[Ref, str]) -> dict:
    books_la = []
    for r in la:
        if r.book not in books_la:
            books_la.append(r.book)
    books_fr = []
    for r in fr:
        if r.book not in books_fr:
            books_fr.append(r.book)
    by_book_ch_la: dict[str, dict[int, int]] = defaultdict(lambda: defaultdict(int))
    by_book_ch_fr: dict[str, dict[int, int]] = defaultdict(lambda: defaultdict(int))
    for r in la:
        by_book_ch_la[r.book][r.chapter] += 1
    for r in fr:
        by_book_ch_fr[r.book][r.chapter] += 1
    chapters_missing_in_fr = []  # chapters of the Vulgate with no Segond counterpart
    verse_count_differs = []  # same chapter, different verse counts (numbering differences)
    for b in books_la:
        if b in LSG_MISSING_BOOKS or b == 'PSA':
            continue
        for ch, n in sorted(by_book_ch_la[b].items()):
            m = by_book_ch_fr[b].get(ch)
            if m is None:
                chapters_missing_in_fr.append(f'{b} {ch}')
            elif m != n:
                verse_count_differs.append({'ref': f'{b} {ch}', 'la': n, 'fr': m})
    # Psalms: mapped verse must exist
    psalm_unmapped = []
    for r in la:
        if r.book != 'PSA':
            continue
        t = to_lsg(r)
        if t is None or t not in fr:
            psalm_unmapped.append(str(r))
    mapped = sum(1 for r in la if (t := to_lsg(r)) is not None and t in fr)
    return {
        'books_la': books_la,
        'books_fr': books_fr,
        'books_only_la': [b for b in books_la if b not in books_fr],
        'books_only_fr': [b for b in books_fr if b not in books_la],
        'verses_la': len(la),
        'verses_fr': len(fr),
        'verses_la_with_default_fr_counterpart': mapped,
        'chapters_missing_in_fr': chapters_missing_in_fr,
        'verse_count_differs': verse_count_differs,
        'psalm_unmapped': psalm_unmapped,
    }


# ---------------------------------------------------------------------------
# inventory

FUNCTION_WORDS = set('''et in non est ad ut qui quae quod cum de a ab ex per super sed autem enim
quia si ne nec neque aut vel atque ac sicut tamquam propter ante post inter sub pro sine
ego tu nos vos me te se sui sibi is ea id hic haec hoc ille illa illud iste ipse idem meus
tuus suus noster vester omnis omne omnia tota totus multi multa unus una unum duo tres
ergo itaque igitur tamen nunc tunc iam semper numquam ubi unde ibi hinc inde etiam quoque
quidem vero verum quam quanto tam ita sic ecce o'''.split())


def resolve_tables() -> tuple[dict[str, list[dict]], dict[str, list[dict]]]:
    """Forms of the game's own verified lexicons (macron-stripped keys)."""
    verbs: dict[str, list[dict]] = defaultdict(list)
    nouns: dict[str, list[dict]] = defaultdict(list)
    vp = os.path.join(OUT_DIR, 'forms_export.json')
    npth = os.path.join(OUT_DIR, 'nouns_export.json')
    if os.path.exists(vp):
        for v in json.load(open(vp, encoding='utf-8'))['verbs']:
            for f in v['forms']:
                if ' ' in f['plain']:
                    continue  # composite forms are matched per token elsewhere
                verbs[latin_key(f['plain'])].append({'lemma': v['lemma'], 'id': v['id'], 'sel': f['sel'], 'var': f['var']})
    if os.path.exists(npth):
        data = json.load(open(npth, encoding='utf-8'))
        for n in data.get('nouns', []):
            for f in n['forms']:
                nouns[latin_key(f['plain'])].append({'lemma': n['lemma'], 'id': n['id'], 'sel': f['sel'], 'var': f.get('var', 'norma')})
    return verbs, nouns


def inventory(la: dict[Ref, str]) -> dict:
    freq: Counter[str] = Counter()
    cap: Counter[str] = Counter()
    first: Counter[str] = Counter()  # occurrences at the start of a sentence
    example: dict[str, str] = {}
    for ref, text in la.items():
        toks = latin_tokens(text)
        prev_end = True
        for tok in toks:
            k = latin_key(tok)
            freq[k] += 1
            if tok[0].isupper():
                cap[k] += 1
                if prev_end:
                    first[k] += 1
            example.setdefault(k, str(ref))
            prev_end = False
        # a crude sentence-start detector for the capitalisation heuristic
        for m in re.finditer(r'[.:;!?]\s+([A-ZÆŒ][a-zæœ]*)', clean(text)):
            first[latin_key(m.group(1))] += 1
    verbs, nouns = resolve_tables()
    forms = []
    proper = 0
    resolved = 0
    for k, n in freq.most_common():
        is_proper = k not in FUNCTION_WORDS and cap[k] >= n * 0.9 and cap[k] > first[k] * 1.1 and n >= 2
        v = verbs.get(k, [])
        nn = nouns.get(k, [])
        status = 'proper' if is_proper else ('verb' if v else ('noun' if nn else 'unresolved'))
        if is_proper:
            proper += 1
        elif v or nn:
            resolved += 1
        entry = {'form': k, 'n': n, 'status': status, 'example': example[k]}
        if v:
            entry['verb'] = sorted({f"{a['id']}:{a['sel']}" for a in v})
        if nn:
            entry['noun'] = sorted({f"{a['id']}:{a['sel']}" for a in nn})
        forms.append(entry)
    tokens = sum(freq.values())
    return {
        'edition': EDITIONS['la'],
        'tokens': tokens,
        'surface_forms': len(freq),
        'resolved_forms_by_engine': resolved,
        'proper_name_forms': proper,
        'unresolved_forms': len(freq) - resolved - proper,
        'resolved_tokens_by_engine': sum(e['n'] for e in forms if e['status'] in ('verb', 'noun')),
        'proper_tokens': sum(e['n'] for e in forms if e['status'] == 'proper'),
        'forms': forms,
    }


# ---------------------------------------------------------------------------
# CLI

def _show(args: list[str]) -> None:
    la, fr = load_latin(), load_french()
    refs: list[Ref] = []
    i = 0
    while i < len(args):
        if ':' in args[i]:
            refs.append(Ref.parse(f'{args[i - 1]} {args[i]}'))
        i += 1
    for r in refs:
        t = to_lsg(r)
        print(f'== {r}')
        print('LA:', clean(la.get(r, '(absent)')))
        print(f'FR ({t}):', clean(fr.get(t, '(absent)')) if t else '(book absent from Segond)')


def main(argv: list[str]) -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    if not argv:
        print(__doc__)
        return
    cmd, rest = argv[0], argv[1:]
    if cmd == 'show':
        _show(rest)
    elif cmd == 'align':
        rep = alignment_report(load_latin(), load_french())
        with open(os.path.join(OUT_DIR, 'bible_alignment.json'), 'w', encoding='utf-8') as f:
            json.dump(rep, f, ensure_ascii=False, indent=1)
        summary = {k: (v if not isinstance(v, list) or len(v) < 12 else f'{len(v)} entries') for k, v in rep.items()}
        print(json.dumps(summary, ensure_ascii=False, indent=1))
    elif cmd == 'inventory':
        inv = inventory(load_latin())
        with open(os.path.join(OUT_DIR, 'vulgate_inventory.json'), 'w', encoding='utf-8') as f:
            json.dump(inv, f, ensure_ascii=False, indent=0)
        print({k: v for k, v in inv.items() if k != 'forms'})
    else:
        print(__doc__)
        sys.exit(2)


if __name__ == '__main__':
    main(sys.argv[1:])
