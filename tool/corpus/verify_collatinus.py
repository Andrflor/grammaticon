#!/usr/bin/env python3
"""Cross-checks Grammaticon's generated forms against Collatinus data.

Collatinus (GPL-3.0, Yves Ouvrard / Biblissima) is used here only as an
independent development-time oracle: its model files are re-implemented in a
small Python flexion engine, the forms it predicts for our lexicon are compared
with the forms exported by `dart run tool/export_forms.dart`, and a report is
written. Nothing from Collatinus is embedded in the application.

Usage: python3 tool/corpus/verify_collatinus.py [forms_export.json]
"""
import json, os, re, sys, unicodedata
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, 'collatinus_data')
OUT = os.path.join(HERE, 'out')

def plain(s):
    s = unicodedata.normalize('NFD', s)
    s = ''.join(c for c in s if unicodedata.category(c) != 'Mn')
    return s.replace('j', 'i').replace('v', 'u').replace('J', 'I').replace('V', 'U').lower()

# ---------------------------------------------------------------- morphos -> selector
def parse_morphos():
    m = {}
    for line in open(os.path.join(DATA, 'morphos.fr'), encoding='utf-8'):
        line = line.strip()
        if not line or line.startswith('!') or ':' not in line:
            continue
        n, label = line.split(':', 1)
        if not n.strip().isdigit():
            continue
        m[int(n)] = label
    return m

PERS = {'1ère': '1', '2ème': '2', '3ème': '3'}
NUM = {'singulier': 'sg', 'pluriel': 'pl'}
MOOD = {'indicatif': 'ind', 'subjonctif': 'subj', 'impératif': 'imp', 'infinitif': 'inf', 'participe': 'part', 'gérondif': 'ger', 'supin': 'sup', 'adjectif verbal': 'gdv'}
TENSE = {'présent': 'praes', 'imparfait': 'imperf', 'futur antérieur': 'futex', 'futur': 'fut', 'parfait': 'perf', 'PQP': 'plusq'}
VOICE = {'actif': 'act', 'passif': 'pass'}
CASE = {'nominatif': 'nom', 'vocatif': 'voc', 'accusatif': 'acc', 'génitif': 'gen', 'datif': 'dat', 'ablatif': 'abl'}
GEND = {'masculin': 'm', 'féminin': 'f', 'neutre': 'n'}

def label_to_selector(label):
    """Returns our selector for a Collatinus verbal label, or None."""
    l = label
    mood = None
    for k, v in MOOD.items():
        if k in l:
            mood = v
            break
    if mood is None:
        return None
    tense = None
    for k, v in TENSE.items():
        if k in l:
            tense = v
            break
    voice = None
    for k, v in VOICE.items():
        if re.search(r'\b' + k + r'\b', l):
            voice = v
            break
    pers = next((v for k, v in PERS.items() if k in l), None)
    num = next((v for k, v in NUM.items() if re.search(r'\b' + k + r'\b', l)), None)
    case = next((v for k, v in CASE.items() if k in l), None)
    gend = next((v for k, v in GEND.items() if k in l), None)
    if mood in ('ind', 'subj', 'imp'):
        if not (tense and voice and pers and num):
            return None
        return f'{mood}.{tense}.{voice}.{pers}.{num}'
    if mood == 'inf':
        if not (tense and voice):
            return None
        return f'inf.{tense}.{voice}'
    if mood == 'part':
        if not (tense and voice and case and gend and num):
            return None
        return f'part.{tense}.{voice}.{case}.{num}.{gend}'
    if mood == 'gdv':
        if not (case and gend and num):
            return None
        return f'gdv.{case}.{num}.{gend}'
    if mood == 'ger':
        return f'ger.{case}' if case else None
    if mood == 'sup':
        return 'sup.acc' if '-um' in l else 'sup.abl'
    return None

# ---------------------------------------------------------------- modeles.la
class Model:
    def __init__(self, name):
        self.name = name
        self.pere = None
        self.pos = None
        self.R = {}          # n -> ('cut', k, add) | ('K',) | ('-',)
        self.des = {}        # morpho -> list of (radnum, [endings])  (own definitions)
        self.desplus = {}    # morpho -> list of (radnum, [endings])
        self.abs = set()

def expand_range(spec):
    out = []
    for part in spec.split(','):
        part = part.strip()
        if '-' in part:
            a, b = part.split('-')
            out.extend(range(int(a), int(b) + 1))
        elif part:
            out.append(int(part))
    return out

def parse_models():
    consts = {}
    models = {}
    cur = None
    for raw in open(os.path.join(DATA, 'modeles.la'), encoding='utf-8'):
        line = raw.strip()
        if not line or line.startswith('!'):
            continue
        if line.startswith('$'):
            k, v = line[1:].split('=', 1)
            consts[k] = v.split(';')
            continue
        if line.startswith('modele:'):
            cur = Model(line.split(':', 1)[1].strip())
            models[cur.name] = cur
            continue
        if cur is None:
            continue
        if line.startswith('pere:'):
            cur.pere = line.split(':', 1)[1].strip()
        elif line.startswith('pos:'):
            cur.pos = line.split(':', 1)[1].strip()
        elif line.startswith('R:'):
            _, n, rule = line.split(':', 2)
            n = int(n)
            if rule == 'K':
                cur.R[n] = ('K',)
            elif rule == '-':
                cur.R[n] = ('-',)
            else:
                k, add = (rule.split(',', 1) + [''])[:2] if ',' in rule else (rule, '')
                cur.R[n] = ('cut', int(k), add if add != '0' else '')
        elif line.startswith('des+:') or line.startswith('des:'):
            plus = line.startswith('des+:')
            _, rng, rad, lst = line.split(':', 3)
            morphos = expand_range(rng)
            rad = int(rad)
            cells = expand_constants(lst, consts)
            target = cur.desplus if plus else cur.des
            for i, m in enumerate(morphos):
                cell = cells[i] if i < len(cells) else cells[-1]
                target.setdefault(m, []).append((rad, [e for e in cell.split(',')]))
        elif line.startswith('abs:'):
            cur.abs.update(expand_range(line.split(':', 1)[1]))
        elif line.startswith('suf:') or line.startswith('sufd:'):
            pass
    return models, consts

def expand_constants(lst, consts):
    # "ūr$lupus" -> prefix repeated before each element of the constant;
    # several such items may be chained with ';'.
    out = []
    for item in lst.split(';'):
        m = re.match(r'^([^$]*)\$(\w+)$', item.strip())
        if m:
            pre, name = m.group(1), m.group(2)
            out.extend(pre + e for e in consts[name])
        else:
            out.append(item)
    return out

def resolve(models, name, _seen=None):
    """Effective (R, des, abs) with inheritance."""
    m = models[name]
    if m.pere and m.pere in models:
        R, des, abs_ = resolve(models, m.pere)
        R = dict(R); des = {k: list(v) for k, v in des.items()}; abs_ = set(abs_)
    else:
        R, des, abs_ = {}, {}, set()
    R.update(m.R)
    for k, v in m.des.items():
        des[k] = list(v)          # child overrides
    for k, v in m.desplus.items():
        des.setdefault(k, []).extend(v)
    abs_ |= m.abs
    # a child's own definition re-enables a morpho its parent marked absent
    for k in m.des:
        abs_.discard(k)
    return R, des, abs_

# ---------------------------------------------------------------- lemmes.la
def parse_lemmes():
    lem = {}
    for raw in open(os.path.join(DATA, 'lemmes.la'), encoding='utf-8'):
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
            key, canon = plain(keyfield), keyfield
        key = plain(key)
        lem.setdefault(key, []).append({'canon': canon, 'model': parts[1], 'R1': parts[2], 'R2': parts[3], 'indic': parts[4]})
    return lem

def radical(entry, R, n):
    """Plain radical number n for a lemma entry (list of alternatives)."""
    canon = plain(entry['canon'])
    if n == 1 and entry['R1']:
        return [plain(x) for x in entry['R1'].split(',')]
    if n == 2 and entry['R2']:
        return [plain(x) for x in entry['R2'].split(',')]
    rule = R.get(n)
    if rule is None:
        return []
    if rule[0] == 'K':
        return [canon]
    if rule[0] == '-':
        return []
    _, k, add = rule
    base = canon[:len(canon) - k] if k else canon
    return [base + plain(add)]

def parse_contractions():
    out = []
    for raw in open(os.path.join(DATA, 'contractions.la'), encoding='utf-8'):
        line = raw.strip()
        if not line or line.startswith('!') or ':' not in line:
            continue
        short, long = line.split(':', 1)
        out.append((plain(short), plain(long)))
    return out

CONTRACTIONS = None

def parse_assimilations():
    out = []
    for raw in open(os.path.join(DATA, 'assimilations.la'), encoding='utf-8'):
        line = raw.strip()
        if not line or line.startswith('!') or ':' not in line:
            continue
        a, b = line.split(':', 1)
        out.append((plain(a), plain(b)))
    return out

ASSIMILATIONS = parse_assimilations()

def assimilate(form):
    """adfero -> affero (assimilations.la), applied to the word start."""
    for a, b in ASSIMILATIONS:
        if form.startswith(a):
            return b + form[len(a):]
    return form

def generate(entry, models, morphos):
    """-> dict selector -> set(plain surfaces)"""
    global CONTRACTIONS
    if CONTRACTIONS is None:
        CONTRACTIONS = parse_contractions()
    R, des, abs_ = resolve(models, entry['model'])
    out = defaultdict(set)
    for m, cells in des.items():
        if m in abs_:
            continue
        label = morphos.get(m, '')
        sel = label_to_selector(label)
        if sel is None:
            continue
        for rad, endings in cells:
            for r in radical(entry, R, rad):
                for e in endings:
                    e = e.strip()
                    if e == '-' or e == '':
                        continue
                    raw_form = r + plain(e)
                    form = assimilate(raw_form)
                    out[sel].add(form)
                    out[sel].add(raw_form)
                    # Collatinus recognises syncopated perfects through
                    # contractions.la; add the contracted variants it accepts.
                    for short, long in CONTRACTIONS:
                        if form.endswith(long) and len(form) > len(long):
                            out[sel].add(form[:-len(long)] + short)
    return out

# ---------------------------------------------------------------- comparison
DEPONENT_KINDS = {'dep', 'semidepinv'}

def our_sel_to_collatinus(sel, kind):
    """Deponents: Collatinus labels their passive-shaped finite forms and the
    perfect participle as 'actif', but keeps the future imperative under the
    passive numbers."""
    if kind in DEPONENT_KINDS:
        parts = sel.split('.')
        if sel.startswith('imp.fut.pass'):
            return sel
        if sel.startswith('part.perf.pass'):
            parts[2] = 'act'
            return '.'.join(parts)
        if len(parts) >= 3 and parts[0] in ('ind', 'subj', 'imp', 'inf') and parts[2] == 'pass':
            parts[2] = 'act'
            return '.'.join(parts)
    return sel

# Our ids -> Collatinus lemma keys when they differ.
ALIASES = {
    'affero': 'adfero', 'coepi': 'coepio', 'oportet': 'oportet', 'pudet': 'pudeo', 'paenitet': 'paeniteo',
    'pluit': 'pluo', 'ningit': 'ningo', 'tonat': 'tono', 'taedet': 'taedeo', 'libet': 'libet', 'piget': 'pigeo',
    'decet': 'decet', 'licet': 'licet', 'quaeso': 'quaeso', 'salve': 'salueo', 'ave': 'aueo',
}
# Collatinus artefacts excluded from the comparison (documented in the report).
SKIP_COLL = {('dep', 'imp.fut.act')}

def main():
    export = sys.argv[1] if len(sys.argv) > 1 else os.path.join(OUT, 'forms_export.json')
    data = json.load(open(export, encoding='utf-8'))
    morphos = parse_morphos()
    models, _ = parse_models()
    lemmes = parse_lemmes()
    report = []
    totals = defaultdict(int)
    per_verb = []
    for v in data['verbs']:
        key = plain(ALIASES.get(v['id'], v['lemmaPlain']))
        candidates = lemmes.get(key) or lemmes.get(key + '2') or lemmes.get(key + '1')
        # some lemmas are stored with a numeric suffix (homonyms); try a few
        if not candidates:
            for k in (key + '2', key + '3'):
                if k in lemmes:
                    candidates = lemmes[k]
                    break
        if not candidates:
            per_verb.append((v['id'], 'absent in Collatinus', 0, 0, 0, [], []))
            totals['missing_lemma'] += 1
            continue
        ours = defaultdict(set)
        for f in v['forms']:
            if f['comp']:
                continue
            sel = our_sel_to_collatinus(f['sel'], v['kind'])
            ours[sel].add(plain(f['plain']))
        # Homonyms: keep the Collatinus entry that agrees best with our forms.
        best = None
        for e in candidates:
            if e['model'] not in models:
                continue
            g = generate(e, models, morphos)
            score = sum(1 for sel, ss in ours.items() for x in ss if x in g.get(sel, set()))
            if best is None or score > best[0]:
                best = (score, e, g)
        if best is None:
            per_verb.append((v['id'], 'no verb model', 0, 0, 0, [], []))
            totals['missing_lemma'] += 1
            continue
        _, entry, coll = best
        matched = 0
        ours_only = []
        coll_only = []
        for sel, surfaces in ours.items():
            c = coll.get(sel, set())
            for s in surfaces:
                if s in c:
                    matched += 1
                else:
                    ours_only.append((sel, s))
        for sel, surfaces in coll.items():
            if v['kind'] in DEPONENT_KINDS and sel.startswith('imp.fut.act'):
                continue  # Collatinus repeats the 2 pl ending over the future cells
            o = ours.get(sel, set())
            for s in surfaces:
                if s not in o:
                    coll_only.append((sel, s))
        totals['matched'] += matched
        totals['ours_only'] += len(ours_only)
        totals['coll_only'] += len(coll_only)
        per_verb.append((v['id'], entry['model'], matched, len(ours_only), len(coll_only), ours_only, coll_only))

    lines = ['# Collatinus cross-check report', '', f"Export: `{os.path.basename(export)}` ({data['generatedAt']})", '',
             f"Matched simple forms: **{totals['matched']}**  ·  in Grammaticon only: **{totals['ours_only']}**  ·  in Collatinus only: **{totals['coll_only']}**  ·  lemmas absent from Collatinus: {totals['missing_lemma']}", '',
             'Composite forms (amātus sum, amātūrus esse…) are not generated by Collatinus and are checked against Allen & Greenough tables in `test/linguistics` instead.', '',
             '| verb | Collatinus model | matched | Grammaticon only | Collatinus only |', '|---|---|---:|---:|---:|']
    for vid, model, m, o, c, _, _ in per_verb:
        lines.append(f'| {vid} | {model} | {m} | {o} | {c} |')
    lines += ['', '## Details', '']
    for vid, model, m, o, c, ours_only, coll_only in per_verb:
        if not ours_only and not coll_only:
            continue
        lines.append(f'### {vid} ({model})')
        if ours_only:
            lines.append('Grammaticon only:')
            for sel, s in sorted(ours_only):
                lines.append(f'- `{sel}` {s}')
        if coll_only:
            lines.append('Collatinus only:')
            for sel, s in sorted(coll_only):
                lines.append(f'- `{sel}` {s}')
        lines.append('')
    os.makedirs(OUT, exist_ok=True)
    rp = os.path.join(OUT, 'collatinus_report.md')
    open(rp, 'w', encoding='utf-8').write('\n'.join(lines))
    print('\n'.join(lines[:6]))
    print(f'report: {rp}')
    for vid, model, m, o, c, _, _ in per_verb:
        print(f'{vid:12s} {model:10s} ok={m:4d} ours_only={o:3d} coll_only={c:3d}')

if __name__ == '__main__':
    main()
