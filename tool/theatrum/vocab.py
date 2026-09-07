#!/usr/bin/env python3
"""Vocabulary inventory, coverage measurement, acceptance check and work queue
of the Theatrum.

    python3 tool/theatrum/vocab.py coverage        # measure shipped content -> doc/theatrum_coverage.md, out/theatrum_coverage.json
    python3 tool/theatrum/vocab.py check           # exit 1 when taught coverage < MIN_COVERAGE
    python3 tool/theatrum/vocab.py queue [N] [--out DIR] [--start K]   # greedy set cover: next N unused verses, worksheets numbered from K

Definitions (enforced here and reported with the numbers)
    vocabulary entry   a lemma of the Collementine corpus as resolved by the
                       Collatinus lexica (tool/corpus/bible/lemmatize.py) — or,
                       for a form no lexicon resolves, the form itself. Every
                       entry stays in the denominator; proper names and
                       unresolved forms are reported separately, never dropped.
    with meaning       the entry has a French gloss (Collatinus lemmes.fr /
                       lem_ext.fr, or an authored gloss in the content).
    taught             at least one *validated, shipped* question whose Latin
                       passage (not merely the surrounding verse) contains a
                       form of the entry, whose faithful French rendering
                       renders that passage, and whose Auxilium shows the
                       entry's lemma and French meaning. Incidental presence in
                       the verse outside the passage does not count; a passage
                       word without a gloss does not count.
    tested             the entry is the form the question turns on (target) or
                       a form a distractor misreads (distractor span).
    weighted           the same, weighted by the entry's number of occurrences.

The acceptance threshold applies to *taught* entries over *all* entries.
"""
from __future__ import annotations

import heapq
import json
import math
import os
import re
import sys
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'tool', 'corpus', 'bible'))
import corpus  # noqa: E402

LEMMATIZED = os.path.join(corpus.OUT_DIR, 'vulgate_lemmatized.json')
PASSAGES = os.path.join(ROOT, 'assets', 'theatrum', 'passages_la.json')
RENDERINGS = os.path.join(ROOT, 'assets', 'theatrum', 'renderings_fr.json')
COVERAGE_JSON = os.path.join(corpus.OUT_DIR, 'theatrum_coverage.json')
COVERAGE_DOC = os.path.join(ROOT, 'doc', 'theatrum_coverage.md')
WORK = os.path.join(HERE, 'work')

MIN_COVERAGE = 0.90


def fkey(tok: str) -> str:
    """Form key used by the lemmatiser (lower, æ→ae, j→i, v→u, no macrons)."""
    import unicodedata
    t = tok.lower().replace('æ', 'ae').replace('œ', 'oe')
    t = unicodedata.normalize('NFD', t)
    t = ''.join(c for c in t if unicodedata.category(c) != 'Mn')
    return t.replace('j', 'i').replace('v', 'u')


# ------------------------------------------------------------------ morpho labels → features

_CASE = {'nominatif': 'nom', 'vocatif': 'voc', 'accusatif': 'acc', 'génitif': 'gen', 'datif': 'dat', 'ablatif': 'abl', 'locatif': 'loc'}
_NUM = {'singulier': 'sg', 'pluriel': 'pl'}
_GEN = {'masculin': 'm', 'féminin': 'f', 'neutre': 'n'}
_MOOD = {'indicatif': 'ind', 'subjonctif': 'subj', 'impératif': 'imp', 'infinitif': 'inf', 'participe': 'part', 'gérondif': 'ger', 'supin': 'sup', 'adjectif verbal': 'gdv'}
_TENSE = {'présent': 'praes', 'imparfait': 'imperf', 'futur antérieur': 'futex', 'futur': 'fut', 'parfait': 'perf', 'PQP': 'plusq'}
_VOICE = {'actif': 'act', 'passif': 'pass'}
_PERS = {'1ère': '1', '2ème': '2', '3ème': '3'}


def label_to_feature(label: str) -> str:
    """Collatinus French label -> compact feature string.

    verbs:  v:ind.praes.act.3.sg · v:inf.praes.act · v:part.perf.pass.nom.sg.m ·
            v:ger.acc · v:gdv.nom.sg.m · v:sup.acc
    nouns:  n:acc.sg · n:loc        adjectives/pronouns: a:nom.sg.m[.comp|.sup]
    invariables: inv
    """
    l = label.strip()
    if l.startswith('inv'):
        return 'inv'
    mood = next((v for k, v in _MOOD.items() if k in l), None)
    case = next((v for k, v in _CASE.items() if k in l), None)
    num = next((v for k, v in _NUM.items() if re.search(r'\b' + k + r'\b', l)), None)
    gen = next((v for k, v in _GEN.items() if k in l), None)
    degree = '.comp' if 'comparatif' in l else ('.sup' if 'superlatif' in l else '')
    if mood:
        tense = next((v for k, v in _TENSE.items() if k in l), None)
        voice = next((v for k, v in _VOICE.items() if re.search(r'\b' + k + r'\b', l)), None)
        pers = next((v for k, v in _PERS.items() if k in l), None)
        if mood in ('ind', 'subj', 'imp'):
            return f'v:{mood}.{tense}.{voice}.{pers}.{num}'
        if mood == 'inf':
            return f'v:inf.{tense}.{voice}'
        if mood == 'part':
            return f'v:part.{tense}.{voice}.{case}.{num}.{gen}'
        if mood == 'gdv':
            return f'v:gdv.{case}.{num}.{gen}'
        if mood == 'ger':
            return f'v:ger.{case}'
        if mood == 'sup':
            return 'v:sup.acc' if 'um' in l else 'v:sup.abl'
    if case and gen:
        return f'a:{case}.{num}.{gen}{degree}'
    if case == 'loc':
        return 'n:loc'
    if case:
        return f'n:{case}.{num}'
    if l == 'comparatif' or l == 'superlatif' or l.startswith('positif'):
        return 'a:' + l[:4]
    return 'x:' + l


LAT = {
    'nom': 'nōminātīvus', 'voc': 'vocātīvus', 'acc': 'accūsātīvus', 'gen': 'genetīvus', 'dat': 'datīvus', 'abl': 'ablātīvus', 'loc': 'locātīvus',
    'sg': 'singulāris', 'pl': 'plūrālis', 'm': 'masculīnum', 'f': 'fēminīnum', 'n': 'neutrum',
    'ind': 'indicātīvus', 'subj': 'subiūnctīvus', 'imp': 'imperātīvus', 'inf': 'īnfīnītīvus', 'part': 'participium', 'ger': 'gerundium', 'gdv': 'gerundīvum', 'sup': 'supīnum',
    'praes': 'praesentis', 'imperf': 'imperfectī', 'fut': 'futūrī', 'perf': 'perfectī', 'plusq': 'plūsquamperfectī', 'futex': 'futūrī exāctī',
    'act': 'āctīvī', 'pass': 'passīvī', '1': 'prīma persōna', '2': 'secunda persōna', '3': 'tertia persōna', 'comp': 'comparātīvus', 'inv': 'indēclīnābile',
}


def feature_to_latin(f: str) -> str:
    """Latin description of a feature string (deterministic, for corrections and the Auxilium)."""
    if f == 'inv':
        return 'vocābulum indēclīnābile'
    kind, _, rest = f.partition(':')
    p = rest.split('.')
    if kind == 'v':
        if p[0] in ('ind', 'subj', 'imp'):
            return f'{LAT[p[0]]} {LAT[p[1]]} {LAT[p[2]]}, {LAT[p[3]]} {LAT[p[4]]}'
        if p[0] == 'inf':
            return f'īnfīnītīvus {LAT[p[1]]} {LAT[p[2]]}'
        if p[0] == 'part':
            return f'participium {LAT[p[1]]} {LAT[p[2]]}, {LAT[p[3]]} {LAT[p[4]]} {LAT[p[5]]}'
        if p[0] == 'gdv':
            return f'gerundīvum, {LAT[p[1]]} {LAT[p[2]]} {LAT[p[3]]}'
        if p[0] == 'ger':
            return f'gerundium, {LAT[p[1]]}'
        if p[0] == 'sup':
            return f'supīnum, {LAT[p[1]]}'
    if kind == 'n':
        return ' '.join(LAT.get(x, x) for x in p)
    if kind == 'a':
        return ' '.join(LAT.get(x, x) for x in p)
    return f


# ------------------------------------------------------------------ inventory

class Inventory:
    def __init__(self):
        data = json.load(open(LEMMATIZED, encoding='utf-8'))
        self.forms: dict[str, dict] = data['forms']
        self.lemmas: dict[str, dict] = data['lemmas']
        self.summary = data['summary']
        self.morpho_labels = {int(k): v for k, v in self.summary['morphos_labels'].items()}
        # entries
        self.entries: dict[str, dict] = {}
        for key, l in self.lemmas.items():
            self.entries[key] = {'id': key, 'kind': 'proper' if l['proper'] else 'common', 'freq': l['freq'], 'forms': set(l['forms']), 'gloss': l['gloss'], 'canon': l['canon'], 'indic': l['indic'], 'pos': l['pos']}
        for form, f in self.forms.items():
            if f['lemma'] is None:
                eid = '?' + form
                self.entries[eid] = {'id': eid, 'kind': 'unresolved' if f['status'] == 'unresolved' else 'proper', 'freq': f['n'], 'forms': {form}, 'gloss': None, 'canon': f['display'], 'indic': '', 'pos': '?'}
        self.form_entry = {}
        for eid, e in self.entries.items():
            for fm in e['forms']:
                self.form_entry.setdefault(fm, eid)

    def entry_of_token(self, tok: str) -> str | None:
        k = fkey(tok)
        f = self.forms.get(k)
        if f is None:
            return None
        return f['lemma'] if f['lemma'] else '?' + k

    def features_of(self, tok: str) -> list[tuple[str, list[str]]]:
        """[(lemma, [feature strings])] for a corpus token."""
        f = self.forms.get(fkey(tok))
        if not f:
            return []
        out = []
        for c in f['candidates']:
            feats = sorted({label_to_feature(self.morpho_labels.get(m, '')) for m in c['morphos']})
            out.append((c['lemma'], feats))
        return out

    def gloss(self, eid: str) -> str | None:
        e = self.entries.get(eid)
        return e['gloss'] if e else None


# ------------------------------------------------------------------ coverage

def measure(inv: Inventory, passages_path=PASSAGES, renderings_path=RENDERINGS) -> dict:
    taught: set[str] = set()
    tested: set[str] = set()
    glossed_in_content: set[str] = set()
    items_n = 0
    passages_n = 0
    if os.path.exists(passages_path) and os.path.exists(renderings_path):
        la = json.load(open(passages_path, encoding='utf-8'))
        fr = json.load(open(renderings_path, encoding='utf-8'))
        glosses_global = fr.get('glosses', {})
        passages = {p['id']: p for p in la['passages']}
        passages_n = len(passages)
        for it in la['items']:
            if it.get('status') != 'validated' or it['id'] not in fr['items']:
                continue
            r = fr['items'][it['id']]
            if not r.get('correct'):
                continue
            items_n += 1
            p = passages[it['passage']]
            item_gloss = r.get('glosses', {})
            for w in p['words']:
                eid = inv.entry_of_token(w['f'])
                if eid is None:
                    continue
                has_gloss = bool(item_gloss.get(w['l']) or glosses_global.get(w['l']) or glosses_global.get(eid) or inv.gloss(eid))
                if has_gloss:
                    taught.add(eid)
                    glossed_in_content.add(eid)
            spans = [it['target']['span']] + [d['span'] for d in r['distractors']]
            for sp in spans:
                for tok in corpus.latin_tokens(sp):
                    eid = inv.entry_of_token(tok)
                    if eid:
                        tested.add(eid)
    total_tokens = inv.summary['tokens']
    by_kind = Counter(e['kind'] for e in inv.entries.values())
    taught_kind = Counter(inv.entries[e]['kind'] for e in taught if e in inv.entries)
    tested_kind = Counter(inv.entries[e]['kind'] for e in tested if e in inv.entries)
    with_meaning = sum(1 for e in inv.entries.values() if e['gloss']) + sum(1 for e in glossed_in_content if e in inv.entries and not inv.entries[e]['gloss'])
    weighted_taught = sum(inv.entries[e]['freq'] for e in taught if e in inv.entries)
    n = len(inv.entries)
    return {
        'items': items_n,
        'passages': passages_n,
        'entries': n,
        'entries_by_kind': dict(by_kind),
        'with_meaning': with_meaning,
        'with_meaning_pct': round(100 * with_meaning / n, 2),
        'taught': len(taught),
        'taught_pct': round(100 * len(taught) / n, 2),
        'taught_by_kind': dict(taught_kind),
        'tested': len(tested),
        'tested_pct': round(100 * len(tested) / n, 2),
        'tested_by_kind': dict(tested_kind),
        'forms_total': inv.summary['forms'],
        'forms_covered': len({fm for e in taught for fm in inv.entries[e]['forms']} & {fkey(w) for w in _content_forms(passages_path)}),
        'weighted_taught_pct': round(100 * weighted_taught / total_tokens, 2),
        'min_coverage_pct': MIN_COVERAGE * 100,
        'passes': len(taught) / n >= MIN_COVERAGE,
        'taught_ids': sorted(taught),
        'tested_ids': sorted(tested),
    }


def _content_forms(passages_path) -> set[str]:
    if not os.path.exists(passages_path):
        return set()
    la = json.load(open(passages_path, encoding='utf-8'))
    return {w['f'] for p in la['passages'] for w in p['words']}


def write_report(inv: Inventory, m: dict) -> None:
    lines = []
    w = lines.append
    w('# Theatrum — couverture du vocabulaire')
    w('')
    w('Généré par `python3 tool/theatrum/vocab.py coverage`. Définitions appliquées :')
    w('')
    w('* **Entrée de vocabulaire** : un lemme du corpus clémentin tel que résolu par les lexiques Collatinus (`tool/corpus/bible/lemmatize.py`), ou, pour une forme qu\'aucun lexique ne résout, la forme elle-même. Toutes les entrées restent au dénominateur ; noms propres et formes non résolues sont comptés à part, jamais retirés.')
    w('* **Avec sens vérifié** : l\'entrée possède une glose française (Collatinus `lemmes.fr` / `lem_ext.fr`, ou glose rédigée dans le contenu).')
    w('* **Enseignée** : au moins une question validée et livrée dont le **passage latin** (pas seulement le verset) contient une forme de l\'entrée, dont le rendu français fidèle traduit ce passage, et dont l\'Auxilium affiche le lemme et le sens français de l\'entrée. Une présence dans le verset hors du passage ne compte pas ; un mot sans glose ne compte pas.')
    w('* **Interrogée** : l\'entrée est la forme décisive d\'une question ou une forme qu\'un distracteur lit de travers.')
    w('* **Pondérée** : idem, pondéré par le nombre d\'occurrences dans le corpus.')
    w('')
    w(f'**Seuil d\'acceptation : {MIN_COVERAGE:.0%} des entrées enseignées** (`python3 tool/theatrum/vocab.py check` échoue en dessous). État : **{"ATTEINT" if m["passes"] else "NON ATTEINT"}**.')
    w('')
    w('## Chiffres')
    w('')
    w('| Mesure | Valeur |')
    w('|---|---|')
    w(f'| Questions validées livrées | {m["items"]} sur {m["passages"]} passages |')
    w(f'| Entrées de vocabulaire (dénominateur) | **{m["entries"]:,}** = {m["entries_by_kind"].get("common", 0):,} communes + {m["entries_by_kind"].get("proper", 0):,} noms propres + {m["entries_by_kind"].get("unresolved", 0):,} formes non résolues |')
    w(f'| Entrées avec sens français vérifié | {m["with_meaning"]:,} ({m["with_meaning_pct"]} %) |')
    w(f'| Entrées **enseignées** dans le contenu jouable | **{m["taught"]:,} ({m["taught_pct"]} %)** — communes {m["taught_by_kind"].get("common", 0):,}, noms propres {m["taught_by_kind"].get("proper", 0):,}, non résolues {m["taught_by_kind"].get("unresolved", 0):,} |')
    w(f'| Entrées **interrogées** (cible ou portion d\'un distracteur) | {m["tested"]:,} ({m["tested_pct"]} %) |')
    w(f'| Formes écrites distinctes couvertes | {m["forms_covered"]:,} / {m["forms_total"]:,} |')
    w(f'| Couverture pondérée par la fréquence | {m["weighted_taught_pct"]} % des occurrences |')
    w('')
    w('## Corpus et résolution')
    w('')
    s = inv.summary
    w(f'* {s["tokens"]:,} occurrences, {s["forms"]:,} formes distinctes ; résolues par les lexiques : {s["forms_resolved"]:,} formes ({s["tokens_resolved"]:,} occurrences), noms propres {s["forms_proper"]:,} formes ({s["tokens_proper"]:,} occ.), non résolues {s["forms_unresolved"]:,} formes.')
    w(f'* {s["lemmas"]:,} lemmes ({s["lemmas_common"]:,} communs, {s["lemmas_proper"]:,} noms propres), {s["lemmas_with_gloss"]:,} avec glose Collatinus.')
    w('')
    uncovered = [e for e in inv.entries.values() if e['id'] not in set(m['taught_ids'])]
    uncovered.sort(key=lambda e: -e['freq'])
    w(f'## Entrées non enseignées ({len(uncovered):,})')
    w('')
    w('Les plus fréquentes :')
    w('')
    w('| Entrée | Type | Occurrences | Sens |')
    w('|---|---|---|---|')
    for e in uncovered[:80]:
        w(f'| {e["canon"]} | {e["kind"]} | {e["freq"]} | {(e["gloss"] or "—")[:60]} |')
    w('')
    nog = [e for e in inv.entries.values() if not e['gloss'] and e['id'] not in m['taught_ids']]
    w(f'Entrées sans sens français ({len(nog):,}) : ' + ', '.join(e['canon'] for e in sorted(nog, key=lambda e: -e['freq'])[:60]) + (' …' if len(nog) > 60 else ''))
    w('')
    w('## Exclusions')
    w('')
    w('Aucune. Les noms propres et les formes non résolues figurent au dénominateur et dans les listes ci-dessus. Les livres absents de Segond (Tobie, Judith, Sagesse, Siracide, Baruch, 1–2 Maccabées, Esther 11–16, Daniel 13–14) sont dans le corpus et leurs mots comptent ; leurs passages exigent un rendu pédagogique identifié.')
    with open(COVERAGE_DOC, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')


# ------------------------------------------------------------------ work queue (greedy set cover)

def used_refs() -> set[str]:
    """Verses already used by a shipped passage (never re-queued)."""
    if not os.path.exists(PASSAGES):
        return set()
    la = json.load(open(PASSAGES, encoding='utf-8'))
    return {p['ref'] for p in la['passages']}


def build_queue(inv: Inventory, covered: set[str], n: int, out_dir: str, max_len: int = 220, start: int = 1, skip: set[str] | None = None) -> list[dict]:
    la = corpus.load_latin()
    fr = corpus.load_french()
    skip = skip or set()
    verse_entries: dict[str, set[str]] = {}
    verse_len: dict[str, int] = {}
    entry_verses: dict[str, list[str]] = defaultdict(list)
    for ref, text in la.items():
        t = corpus.clean(text)
        ents = set()
        for tok in corpus.latin_tokens(t):
            eid = inv.entry_of_token(tok)
            if eid:
                ents.add(eid)
        verse_entries[str(ref)] = ents
        verse_len[str(ref)] = len(t)
        for e in ents:
            entry_verses[e].append(str(ref))

    def weight(eid: str) -> float:
        e = inv.entries[eid]
        base = 1 + math.log10(1 + e['freq'])
        return base * (0.6 if e['kind'] == 'proper' else 1.0)

    def gain(ref: str) -> float:
        g = sum(weight(e) for e in verse_entries[ref] if e not in covered)
        L = verse_len[ref]
        cost = 1 + (L / 120) + (2.0 if L > max_len else 0) + (0.5 if corpus.to_lsg(corpus.Ref.parse(ref)) is None else 0)
        return g / cost

    heap = [(-gain(r), r) for r in verse_entries if r not in skip and verse_entries[r] - covered]
    heapq.heapify(heap)
    chosen = []
    while heap and len(chosen) < n:
        neg, ref = heapq.heappop(heap)
        g = gain(ref)
        if g <= 0:
            continue
        if abs(-neg - g) > 1e-9:
            heapq.heappush(heap, (-g, ref))
            continue
        new = [e for e in verse_entries[ref] if e not in covered]
        covered.update(new)
        chosen.append({'ref': ref, 'new': new, 'len': verse_len[ref]})
    os.makedirs(out_dir, exist_ok=True)
    sheets = []
    for c in chosen:
        ref = corpus.Ref.parse(c['ref'])
        t = corpus.clean(la[ref])
        lsg_ref = corpus.to_lsg(ref)
        lsg = corpus.clean(fr[lsg_ref]) if lsg_ref and lsg_ref in fr else None
        toks = []
        for tok in corpus.latin_tokens(t):
            eid = inv.entry_of_token(tok)
            feats = inv.features_of(tok)
            toks.append({'form': tok, 'entry': eid, 'new': eid in c['new'], 'gloss': inv.gloss(eid) if eid else None,
                         'analyses': [{'lemma': l, 'features': f} for l, f in feats[:3]]})
        sheets.append({'ref': c['ref'], 'latin': t, 'lsg_ref': str(lsg_ref) if lsg_ref else None, 'lsg': lsg, 'len': c['len'], 'new_entries': c['new'], 'tokens': toks})
    with open(os.path.join(out_dir, 'queue.json'), 'w', encoding='utf-8') as f:
        json.dump(sheets, f, ensure_ascii=False, indent=1)
    write_worksheets(sheets, out_dir, start=start)
    return sheets


def write_worksheets(sheets: list[dict], out_dir: str, per_file: int = 40, start: int = 1) -> None:
    """Compact worksheets for authors: one file per `per_file` verses, numbered from `start`."""
    for i in range(0, len(sheets), per_file):
        chunk = sheets[i:i + per_file]
        lines = []
        for s in chunk:
            lines.append(f"### {s['ref']} | {s['len']} chars | LSG {s['lsg_ref'] or 'ABSENT (paed=True required)'}")
            lines.append(f"LA: {s['latin']}")
            lines.append(f"FR: {s['lsg'] or '—'}")
            new = [t for t in s['tokens'] if t['new']]
            lines.append('NEW: ' + ', '.join(f"{t['form']}={t['entry']}" + ('' if t['gloss'] else ' [NO GLOSS: add gloss]') for t in new))
            toks = []
            for t in s['tokens']:
                if not t['analyses']:
                    toks.append(f"{t['form']}=?")
                    continue
                a = t['analyses'][0]
                feats = '|'.join(a['features'][:4])
                more = '' if len(t['analyses']) == 1 else f" (+{len(t['analyses']) - 1} lemma)"
                toks.append(f"{t['form']}={a['lemma']}{{{feats}}}{more}")
            lines.append('TOK: ' + '  '.join(toks))
            lines.append('')
        n = i // per_file + start
        with open(os.path.join(out_dir, f'sheet_{n:03d}.md'), 'w', encoding='utf-8') as f:
            f.write('\n'.join(lines))


def main(argv: list[str]) -> int:
    if not argv:
        print(__doc__)
        return 2
    inv = Inventory()
    cmd = argv[0]
    if cmd in ('coverage', 'check'):
        m = measure(inv)
        os.makedirs(corpus.OUT_DIR, exist_ok=True)
        with open(COVERAGE_JSON, 'w', encoding='utf-8') as f:
            json.dump(m, f, ensure_ascii=False, indent=1)
        write_report(inv, m)
        print(json.dumps({k: v for k, v in m.items() if not k.endswith('_ids')}, ensure_ascii=False, indent=1))
        if cmd == 'check':
            if not m['passes']:
                print(f'ACCEPTANCE FAILED: taught coverage {m["taught_pct"]} % < {MIN_COVERAGE:.0%}')
                return 1
            print('acceptance ok')
        return 0
    if cmd == 'queue':
        n = int(argv[1]) if len(argv) > 1 and argv[1].isdigit() else 200
        out_dir = WORK
        if '--out' in argv:
            out_dir = argv[argv.index('--out') + 1]
        start = int(argv[argv.index('--start') + 1]) if '--start' in argv else 1
        m = measure(inv)
        sheets = build_queue(inv, set(m['taught_ids']), n, out_dir, start=start, skip=used_refs())
        new_total = sum(len(s['new_entries']) for s in sheets)
        print(f'{len(sheets)} verses queued, {new_total} new entries, avg len {sum(s["len"] for s in sheets) / max(1, len(sheets)):.0f} chars -> {out_dir}/queue.json')
        return 0
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
