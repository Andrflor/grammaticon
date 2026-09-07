#!/usr/bin/env python3
"""Lemmatises every surface form of the Clementine corpus with the Collatinus
lexica (development time) and writes the vocabulary inventory.

    python3 tool/corpus/bible/lemmatize.py            # -> tool/corpus/out/vulgate_lemmatized.json

Resource and licence
    Collatinus (Yves Ouvrard, Philippe Verkerk, Biblissima) — lexica
    `lemmes.la`, `lem_ext.la` (lemmas, models, radicals), `lemmes.fr`,
    `lem_ext.fr` (French meanings), `modeles.la`, `morphos.fr`, `irregs.la`,
    `assimilations.la`, `contractions.la`, `tags.la`. Every file carries a
    GNU GPL v2-or-later header (repository: GPL v3). The flexion engine below
    re-implements the model files (as `verify_collatinus.py` already did).
    What this script produces — lemma, analysis and French meaning for the
    words of the corpus — is *derived from* those GPL data files; the shipped
    lexicon asset is therefore distributed under the GPL with attribution
    (see THIRD_PARTY_NOTICES.md and doc/theatrum_sources.md). Nothing here is
    invented: an analysis is recorded only when the lexicon generates the form.

Output (JSON)
    forms:   plain form -> {n, candidates:[{lemma, pos, morphos[], src}], lemma (chosen), status}
    lemmas:  lemma key -> {canon, indic, pos, gloss, glossSrc, freq (corpus tokens), forms[], proper}
    status:  resolved | proper | unresolved
"""
from __future__ import annotations

import json
import os
import re
import sys
import unicodedata
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..'))
sys.path.insert(0, HERE)
import corpus  # noqa: E402
import verify_collatinus as vc  # noqa: E402

DATA = vc.DATA
OUT = os.path.join(corpus.OUT_DIR, 'vulgate_lemmatized.json')


def plain(s: str) -> str:
    return vc.plain(s)


# ------------------------------------------------------------------ lexica

def parse_lemma_file(path: str, src: str) -> dict[str, dict]:
    """key -> entry. Keys are the plain canon (homonyms carry a digit)."""
    out: dict[str, dict] = {}
    for raw in open(path, encoding='utf-8'):
        line = raw.strip()
        if not line or line.startswith('!'):
            continue
        parts = line.split('|')
        if len(parts) < 5:
            continue
        keyfield = parts[0]
        if '=' in keyfield:
            key, canon = keyfield.split('=', 1)
        else:
            key, canon = keyfield, keyfield
        key = plain(key)
        freq = 0
        if len(parts) > 5 and parts[5].strip().isdigit():
            freq = int(parts[5])
        indic = parts[4]
        out[key] = {'key': key, 'canon': canon, 'model': parts[1], 'R1': parts[2], 'R2': parts[3], 'indic': indic, 'cfreq': freq, 'src': src,
                    'proper': ('npr' in indic) or (canon[:1].isupper() and not indic.startswith('inv'))}
    return out


def parse_gloss_file(path: str) -> dict[str, str]:
    out: dict[str, str] = {}
    if not os.path.exists(path):
        return out
    for raw in open(path, encoding='utf-8'):
        line = raw.rstrip('\n')
        if not line or line.startswith('!') or ':' not in line:
            continue
        k, g = line.split(':', 1)
        out[plain(k)] = g.strip()
    return out


def parse_irregs() -> dict[str, list[tuple[str, list[int]]]]:
    """plain form -> [(lemma key, morphos)]"""
    out: dict[str, list[tuple[str, list[int]]]] = defaultdict(list)
    for raw in open(os.path.join(DATA, 'irregs.la'), encoding='utf-8'):
        line = raw.strip()
        if not line or line.startswith('!') or ':' not in line:
            continue
        form, lemma, morphos = line.split(':', 2)
        form = plain(form.replace('*', ''))
        out[form].append((plain(lemma), vc.expand_range(morphos)))
    return out


# ------------------------------------------------------------------ generation

def radicals(entry: dict, R, n: int) -> list[str]:
    """Plain radical(s) n of a lemma entry. The canonical field may list
    several forms separated by commas (pŏpŭlus,pō̆plus; ĭn,īndŭ): each yields
    its own radical."""
    if n == 1 and entry['R1']:
        return [plain(x) for x in entry['R1'].split(',')]
    if n == 2 and entry['R2']:
        return [plain(x) for x in entry['R2'].split(',')]
    rule = R.get(n)
    if rule is None or rule[0] == '-':
        return []
    out = []
    for canon in entry['canon'].split(','):
        c = re.sub(r'\d+$', '', plain(canon.strip()))  # homonym index (dīco2) is not part of the stem
        if not c:
            continue
        if rule[0] == 'K':
            out.append(c)
        else:
            _, k, add = rule
            base = c[:len(c) - k] if k else c
            out.append(base + plain(add))
    return out


vc.radical = radicals  # comma-aware replacement used by the generation below


def generate_all(entry: dict, R, des, abs_, contractions) -> dict[str, set[int]]:
    """plain form -> set(morpho ids) for one lemma entry."""
    out: dict[str, set[int]] = defaultdict(set)
    for m, cells in des.items():
        if m in abs_:
            continue
        for rad, endings in cells:
            for r in vc.radical(entry, R, rad):
                for e in endings:
                    e = e.strip()
                    ending = '' if e == '-' else plain(e)
                    raw_form = r + ending
                    if not raw_form:
                        continue
                    form = vc.assimilate(raw_form)
                    out[form].add(m)
                    if form != raw_form:
                        out[raw_form].add(m)
                    for short, long in contractions:
                        if form.endswith(long) and len(form) > len(long):
                            out[form[:-len(long)] + short].add(m)
    return out


def morpho_pos(model_pos: str | None, indic: str) -> str:
    if model_pos:
        return model_pos
    if 'npr' in indic:
        return 'npr'
    return 'inv'


def build_index(lemmas: dict[str, dict], models, prefixes: set[str]):
    """form -> [(lemma key, morphos)] for every lemma whose radicals can start a corpus form."""
    index: dict[str, list[tuple[str, frozenset[int]]]] = defaultdict(list)
    resolved_models = {}
    contractions = vc.parse_contractions()
    skipped = 0
    for key, e in lemmas.items():
        mname = e['model']
        if mname not in models:
            skipped += 1
            continue
        if mname not in resolved_models:
            resolved_models[mname] = vc.resolve(models, mname)
        R, des, abs_ = resolved_models[mname]
        # prefix filter: at least one radical must open a corpus form
        rads = set()
        short = False
        for n in set(R) | {1, 2, 0}:
            for r in vc.radical(e, R, n):
                if len(r) < 3:
                    short = True
                rads.add(r[:3])
        if rads and not short and not (rads & prefixes):
            continue
        forms = generate_all(e, R, des, abs_, contractions)
        for f, ms in forms.items():
            index[f].append((key, frozenset(ms)))
    return index, skipped


ENCLITICS = ['que', 'ne', 'ue']
# Compound pronouns Collatinus builds with suffixes (quidam = qui + dam): the
# base resolves as a pronoun and the compound lemma exists in the lexicon.
SUFFIXES = ['cumque', 'cunque', 'quam', 'piam', 'libet', 'dam', 'uis', 'met', 'nam', 'pte']


def main() -> None:
    la = corpus.load_latin()
    freq: Counter[str] = Counter()
    display: dict[str, Counter] = defaultdict(Counter)
    for text in la.values():
        for tok in corpus.latin_tokens(text):
            k = plain(tok.lower().replace('æ', 'ae').replace('œ', 'oe'))
            freq[k] += 1
            display[k][tok] += 1
    # occurrences at the head of a sentence (after . : ; ! ? or at verse start)
    sentence_head: Counter[str] = Counter()
    for text in la.values():
        t = corpus.clean(text)
        for m in re.finditer(r'(?:^|[.:;!?]\s+)([A-ZÆŒ][\wæœ]*)', t):
            sentence_head[plain(m.group(1).lower().replace('æ', 'ae').replace('œ', 'oe'))] += 1
    prefixes = {k[:3] for k in freq}
    lemmas = parse_lemma_file(os.path.join(DATA, 'lemmes.la'), 'lemmes')
    ext = parse_lemma_file(os.path.join(DATA, 'lem_ext.la'), 'lem_ext')
    for k, e in ext.items():
        lemmas.setdefault(k, e)
    gloss = parse_gloss_file(os.path.join(DATA, 'lemmes.fr'))
    gloss_ext = parse_gloss_file(os.path.join(DATA, 'lem_ext.fr'))
    for k, g in gloss_ext.items():
        gloss.setdefault(k, g)
    morphos = vc.parse_morphos()
    models, _ = vc.parse_models()
    index, skipped = build_index(lemmas, models, prefixes)
    irregs = parse_irregs()
    for f, lst in irregs.items():
        for key, ms in lst:
            index[f].append((key, frozenset(ms)))
    print(f'lexicon: {len(lemmas)} lemmas ({skipped} with unknown model), {len(index)} generated forms, {len(gloss)} glosses')

    def lookup(k: str):
        cands = list(index.get(k, []))
        if cands:
            return cands, ''
        # enclitics -que, -ne, -ue
        for enc in ENCLITICS:
            if k.endswith(enc) and len(k) > len(enc) + 2:
                base = k[:-len(enc)]
                c2 = index.get(base)
                if c2:
                    return list(c2), enc
        # syncopated perfects of -īre/-ēre/-āre verbs (audisset = audiuisset,
        # complesset = compleuisset) and the oe/ae spelling (foenum = faenum)
        for a, b in (('iss', 'iuiss'), ('ist', 'iuist'), ('ess', 'euiss'), ('est', 'euist'), ('ass', 'auiss'), ('ast', 'auist'), ('oe', 'ae'), ('ae', 'oe'), ('y', 'i')):
            if a in k:
                idx = k.find(a, 2) if a not in ('oe', 'ae', 'y') else k.find(a)
                if idx > 0:
                    alt = k[:idx] + b + k[idx + len(a):]
                    c2 = index.get(alt)
                    if c2:
                        return list(c2), ''
        # pronoun suffixes: quidam, quicumque, quisquam, quispiam, egomet…
        for suf in SUFFIXES:
            if k.endswith(suf) and len(k) > len(suf) + 1:
                base = k[:-len(suf)]
                c2 = index.get(base)
                if c2:
                    out = []
                    for lemma, ms in c2:
                        compound = lemma.rstrip('0123456789') + suf
                        target = compound if compound in lemmas else lemma
                        out.append((target, ms))
                    return out, suf
        # sēmetipsum, tēipsum, mēipsum: personal pronoun + (met) + ipse
        m = re.match(r'^(me|te|se|nos|uos)(met)?(ips[a-z]+)$', k)
        if m and m.group(3) in index:
            return list(index[m.group(3)]), m.group(1) + (m.group(2) or '')
        return [], ''

    # first pass: corpus tokens per candidate lemma (all candidates), to tell
    # frequent common words from spurious analyses of unknown names
    lemma_corpus: Counter[str] = Counter()
    for k, n in freq.items():
        for c in index.get(k, []):
            lemma_corpus[c[0]] += n
    forms_out = {}
    lemma_tokens: Counter[str] = Counter()
    lemma_forms: dict[str, set[str]] = defaultdict(set)
    n_res = n_prop = n_unres = 0
    for k, n in freq.items():
        cands, enc = lookup(k)
        disp = display[k].most_common(1)[0][0]
        capitalised = sum(v for t, v in display[k].items() if t[:1].isupper()) >= n * 0.9
        # A form written with a capital in (almost) all its occurrences, never
        # at the head of a sentence, whose only analyses are rare common words
        # (Balanam → balo) is a proper name the lexica do not know: it must not
        # borrow a verb's gloss. Common capitalised words (Deus, Dominus) keep
        # their lemma because that lemma is frequent elsewhere in the corpus.
        if cands and capitalised and not any(lemmas[c[0]]['proper'] for c in cands):
            starts = sum(v for t, v in display[k].items() if t[:1].isupper())  # capitalised occurrences
            head = sentence_head.get(k, 0)
            if head < starts * 0.5 and max(lemma_corpus.get(c[0], 0) for c in cands) < 50:
                cands = []
        if cands:
            # rank: prefer proper lemmas for capitalised forms, main lexicon, Collatinus frequency
            def rank(c):
                e = lemmas[c[0]]
                return (e['proper'] == capitalised, e['src'] == 'lemmes', e['cfreq'])
            cands.sort(key=rank, reverse=True)
            chosen = cands[0][0]
            e = lemmas[chosen]
            status = 'proper' if e['proper'] else 'resolved'
            if status == 'proper':
                n_prop += 1
            else:
                n_res += 1
            lemma_tokens[chosen] += n
            lemma_forms[chosen].add(k)
            forms_out[k] = {
                'n': n,
                'display': disp,
                'lemma': chosen,
                'status': status,
                'enclitic': enc,
                'candidates': [{'lemma': c[0], 'pos': morpho_pos(models[lemmas[c[0]]['model']].pos if lemmas[c[0]]['model'] in models else None, lemmas[c[0]]['indic']), 'morphos': sorted(c[1])} for c in cands[:6]],
            }
        else:
            status = 'proper' if capitalised else 'unresolved'
            if status == 'proper':
                n_prop += 1
            else:
                n_unres += 1
            forms_out[k] = {'n': n, 'display': disp, 'lemma': None, 'status': status, 'enclitic': '', 'candidates': []}
    lemmas_out = {}
    for key, toks in lemma_tokens.items():
        e = lemmas[key]
        g = gloss.get(key)
        lemmas_out[key] = {
            'canon': e['canon'],
            'indic': e['indic'],
            'pos': morpho_pos(models[e['model']].pos if e['model'] in models else None, e['indic']),
            'model': e['model'],
            'gloss': g,
            'glossSrc': ('lemmes.fr' if key in parse_gloss_file.__dict__.get('_main', {}) else ('collatinus' if g else None)),
            'freq': toks,
            'forms': sorted(lemma_forms[key]),
            'proper': e['proper'],
            'src': e['src'],
        }
    tokens = sum(freq.values())
    summary = {
        'tokens': tokens,
        'forms': len(freq),
        'forms_resolved': n_res,
        'forms_proper': n_prop,
        'forms_unresolved': n_unres,
        'tokens_resolved': sum(v['n'] for v in forms_out.values() if v['status'] == 'resolved'),
        'tokens_proper': sum(v['n'] for v in forms_out.values() if v['status'] == 'proper'),
        'lemmas': len(lemmas_out),
        'lemmas_common': sum(1 for l in lemmas_out.values() if not l['proper']),
        'lemmas_proper': sum(1 for l in lemmas_out.values() if l['proper']),
        'lemmas_with_gloss': sum(1 for l in lemmas_out.values() if l['gloss']),
        'morphos_labels': {str(k): v for k, v in morphos.items()},
    }
    os.makedirs(corpus.OUT_DIR, exist_ok=True)
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump({'summary': summary, 'forms': forms_out, 'lemmas': lemmas_out}, f, ensure_ascii=False)
    print(json.dumps({k: v for k, v in summary.items() if k != 'morphos_labels'}, indent=1))
    top = sorted(((v['n'], k) for k, v in forms_out.items() if v['status'] == 'unresolved'), reverse=True)[:40]
    print('most frequent unresolved:', ', '.join(f'{k}({n})' for n, k in top))


if __name__ == '__main__':
    main()
