#!/usr/bin/env python3
"""Builds and validates the Theatrum content from the authored sources.

    python3 tool/theatrum/build_content.py                 # validate everything, write assets, coverage report + acceptance check
    python3 tool/theatrum/build_content.py --only FILE.py  # validate one batch file only (no assets written)

Inputs
    tool/theatrum/items_fr.py          hand-written items (v1 format: I/T/D, LEX, GLOSS)
    tool/theatrum/items_fr/*.py        batch items (v2 format: Q, see items_fr/README.md)
    assets/corpus/*.txt                the two source texts (tool/corpus/bible/corpus.py)
    tool/corpus/out/vulgate_lemmatized.json   lemma/analysis/gloss of every corpus form
                                       (tool/corpus/bible/lemmatize.py, Collatinus lexica, GPL)
Outputs
    assets/theatrum/passages_la.json   Latin side (passages, items, Latin annotations, vocabulary bands)
    assets/theatrum/renderings_fr.json French side (renderings, distractors, glosses)
    doc/theatrum_coverage.md, tool/corpus/out/theatrum_coverage.json (via vocab.py)

Every check fails the build. Nothing linguistic is generated at run time and
nothing is invented at build time: a target analysis is accepted only when the
lexicon produces that analysis for that form; a distractor's misreading is a
feature the lexicon can also produce for the lemma (the contrast form comes
from the lexicon); Latin explanations are rendered from those validated
features by fixed templates; the French text of every choice is authored.
"""
from __future__ import annotations

import importlib.util
import json
import os
import re
import sys
from collections import Counter, defaultdict
from datetime import datetime, timezone

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'tool', 'corpus', 'bible'))
sys.path.insert(0, HERE)

import corpus  # noqa: E402
import vocab  # noqa: E402
from items_fr import GLOSS, ITEMS, LEX  # noqa: E402

VERSION = '2.0.0'
ASSETS = os.path.join(ROOT, 'assets', 'theatrum')
BATCH_DIR = os.path.join(HERE, 'items_fr')
MAX_PASSAGE = 240
MAX_DIFF_TOKENS = 12

DISTINCTIONS = {'numerus', 'persona', 'casus', 'tempus', 'vox', 'modus', 'congruentia', 'nonfinita'}

# Mirror of ReadingTrials (lib/pedagogy/reading/reading_trials.dart).
TRIALS = {
    'th-numerus': ({'numerus'}, [], 'l.numerus'),
    'th-persona': ({'persona', 'numerus'}, ['th-numerus'], 'l.persona'),
    'th-casus-recti': ({'casus'}, ['th-numerus'], 'l.casus'),
    'th-tempus-praeteritum': ({'tempus'}, ['th-persona'], 'l.tempus'),
    'th-tempus-futurum': ({'tempus'}, ['th-tempus-praeteritum'], 'l.tempus'),
    'th-casus-obliqui': ({'casus'}, ['th-casus-recti'], 'l.casus'),
    'th-congruentia': ({'congruentia'}, ['th-casus-obliqui'], 'l.congruentia'),
    'th-modus-imperativus': ({'modus'}, ['th-persona'], 'l.modus'),
    'th-vox': ({'vox'}, ['th-tempus-praeteritum'], 'l.vox'),
    'th-modus-subiunctivus': ({'modus'}, ['th-modus-imperativus', 'th-tempus-futurum'], 'l.modus'),
    'th-nonfinita': ({'nonfinita'}, ['th-vox', 'th-congruentia'], 'l.nonfinita'),
}

BOOKS = {
    'GEN': 'Genesis', 'EXO': 'Exodus', 'LEV': 'Leviticus', 'NUM': 'Numeri', 'DEU': 'Deuteronomium', 'JOS': 'Josue', 'JDG': 'Judices',
    'RUT': 'Ruth', '1SA': 'Regum I', '2SA': 'Regum II', '1KI': 'Regum III', '2KI': 'Regum IV', '1CH': 'Paralipomenon I', '2CH': 'Paralipomenon II',
    'EZR': 'Esdras', 'NEH': 'Nehemias', 'EST': 'Esther', 'JOB': 'Job', 'PSA': 'Psalmi',
    'PRO': 'Proverbia', 'ECC': 'Ecclesiastes', 'SOL': 'Canticum Canticorum', 'ISA': 'Isaias', 'JER': 'Jeremias', 'LAM': 'Lamentationes', 'EZE': 'Ezechiel',
    'DAN': 'Daniel', 'HOS': 'Osee', 'JOE': 'Joel', 'AMO': 'Amos', 'OBA': 'Abdias', 'JON': 'Jonas', 'MIC': 'Michaeas', 'NAH': 'Nahum', 'HAB': 'Habacuc',
    'ZEP': 'Sophonias', 'HAG': 'Aggaeus', 'ZEC': 'Zacharias', 'MAL': 'Malachias', 'TOB': 'Tobias', 'JDT': 'Judith', 'WIS': 'Sapientia', 'SIR': 'Ecclesiasticus',
    'BAR': 'Baruch', '1MA': 'Machabaeorum I', '2MA': 'Machabaeorum II',
    'MAT': 'Matthaeus', 'MAR': 'Marcus', 'LUK': 'Lucas', 'JOH': 'Joannes', 'ACT': 'Actus Apostolorum', 'ROM': 'Ad Romanos',
    '1CO': 'Ad Corinthios I', '2CO': 'Ad Corinthios II', 'GAL': 'Ad Galatas', 'EPH': 'Ad Ephesios', 'PHI': 'Ad Philippenses',
    'COL': 'Ad Colossenses', '1TH': 'Ad Thessalonicenses I', '2TH': 'Ad Thessalonicenses II', '1TI': 'Ad Timotheum I', '2TI': 'Ad Timotheum II',
    'TIT': 'Ad Titum', 'PHM': 'Ad Philemonem', 'HEB': 'Ad Hebraeos', 'JAM': 'Jacobi', '1PE': 'Petri I', '2PE': 'Petri II', '1JO': 'Joannis I',
    '2JO': 'Joannis II', '3JO': 'Joannis III', 'JUD': 'Judae', 'REV': 'Apocalypsis',
}

BAND_LIMITS = [300, 1000, 2500, 5000]  # frequency ranks of common lemmas -> bands 1..5

# Collatinus noun models -> declension of the existing Forum skills.
DECL_MODELS = {'roma': 1, 'anima': 1, 'lupus': 2, 'templum': 2, 'puer': 2, 'ager': 2, 'uir': 2, 'deus': 2, 'filius': 2, 'liberi': 2, 'samus': 2,
               'miles': 3, 'corpus': 3, 'ciuis': 3, 'mare': 3, 'urbs': 3, 'animal': 3, 'pater': 3, 'nomen': 3, 'iter': 3, 'rex': 3, 'homo': 3,
               'manus': 4, 'cornu': 4, 'res': 5, 'dies': 5}


# ------------------------------------------------------------------ lexicon access

class Lexicon:
    """Corpus-form analyses from the lemmatiser + on-demand form generation
    for contrast forms (both from the Collatinus data, development time)."""

    def __init__(self):
        self.inv = vocab.Inventory()
        import lemmatize as L
        import verify_collatinus as vc
        self.L, self.vc = L, vc
        self.lemmas = L.parse_lemma_file(os.path.join(vc.DATA, 'lemmes.la'), 'lemmes')
        for k, e in L.parse_lemma_file(os.path.join(vc.DATA, 'lem_ext.la'), 'lem_ext').items():
            self.lemmas.setdefault(k, e)
        self.models, _ = vc.parse_models()
        self.morphos = vc.parse_morphos()
        self._gen: dict[str, dict[str, set[str]]] = {}
        self._rank: dict[str, int] | None = None

    def analyses(self, tok: str) -> dict[str, set[str]]:
        """lemma -> features for a corpus token."""
        out: dict[str, set[str]] = {}
        for lemma, feats in self.inv.features_of(tok):
            out.setdefault(lemma, set()).update(feats)
        return out

    def entry(self, tok: str) -> str | None:
        return self.inv.entry_of_token(tok)

    def forms_of(self, lemma: str) -> dict[str, set[str]]:
        """feature -> plain forms, generated from the lexicon."""
        if lemma in self._gen:
            return self._gen[lemma]
        e = self.lemmas.get(lemma)
        out: dict[str, set[str]] = defaultdict(set)
        if e and e['model'] in self.models:
            R, des, abs_ = self.vc.resolve(self.models, e['model'])
            forms = self.L.generate_all(e, R, des, abs_, self.vc.parse_contractions())
            for f, ms in forms.items():
                for m in ms:
                    out[vocab.label_to_feature(self.morphos.get(m, ''))].add(f)
        self._gen[lemma] = out
        return out

    def gloss(self, lemma: str) -> str | None:
        return self.inv.gloss(lemma)

    def is_proper(self, lemma: str) -> bool:
        e = self.inv.entries.get(lemma)
        return bool(e and e['kind'] == 'proper')

    def rank(self, lemma: str) -> int:
        if self._rank is None:
            common = sorted((e for e in self.inv.entries.values() if e['kind'] == 'common'), key=lambda e: -e['freq'])
            self._rank = {e['id']: i + 1 for i, e in enumerate(common)}
        return self._rank.get(lemma, 10 ** 6)

    def band(self, lemmas) -> int:
        b = 1
        for l in lemmas:
            r = self.rank(l)
            if r >= 10 ** 6:
                continue
            for i, lim in enumerate(BAND_LIMITS):
                if r <= lim:
                    b = max(b, i + 1)
                    break
            else:
                b = max(b, len(BAND_LIMITS) + 1)
        return b

    def form_skill(self, lemma: str, feature: str) -> str:
        e = self.lemmas.get(lemma)
        kind, _, rest = feature.partition(':')
        p = rest.split('.')
        if kind == 'v':
            base = lemma.rstrip('0123456789')
            model = e['model'] if e else ''
            if base in ('sum', 'possum', 'adsum', 'absum', 'prosum', 'praesum', 'desum', 'intersum', 'supersum', 'obsum', 'insum'):
                return 'v.fam.sum'
            if model == 'eo' or base in ('eo', 'abeo', 'adeo', 'redeo', 'exeo', 'transeo', 'pereo', 'ineo', 'intereo', 'praetereo', 'subeo', 'circumeo', 'introeo', 'obeo'):
                return 'v.fam.eo'
            if model == 'fero' or base.endswith('fero'):
                return 'v.fam.fero'
            if base in ('uolo', 'nolo', 'malo'):
                return 'v.fam.volo'
            if base in ('fio',) or model == 'fio':
                return 'v.fam.fio'
            if base in ('do', 'edo', 'circumdo'):
                return 'v.fam.minora'
            if e and ('dép' in e['indic'] or 'dep' in e['indic']) and p[0] in ('ind', 'subj', 'imp', 'inf'):
                return 'v.dep'
            if p[0] in ('ind', 'subj'):
                return f'v.{p[0]}.{p[1]}.{p[2]}'
            if p[0] == 'imp':
                return 'v.imp.praes' if p[1] == 'praes' else 'v.imp.fut'
            if p[0] == 'inf':
                return 'v.inf'
            if p[0] == 'part':
                return 'v.part'
            if p[0] in ('ger', 'gdv'):
                return 'v.ger'
            if p[0] == 'sup':
                return 'v.sup'
        if kind == 'n' and e:
            m = e['model']
            seen = set()
            while m and m not in DECL_MODELS and m in self.models and self.models[m].pere and m not in seen:
                seen.add(m)
                m = self.models[m].pere
            d = DECL_MODELS.get(m)
            if d and len(p) == 2:
                return f'd.{d}.{p[0]}.{p[1]}'
            if p == ['loc']:
                return 'd.loc'
        return ''


# ------------------------------------------------------------------ helpers

def allowed(trial: str) -> set[str]:
    out: set[str] = set()
    seen: set[str] = set()

    def visit(t: str) -> None:
        if t in seen:
            return
        seen.add(t)
        own, pre, _ = TRIALS[t]
        out.update(own)
        for p in pre:
            visit(p)

    visit(trial)
    return out


def typo(s: str) -> str:
    return re.sub(r'\s+', ' ', s.replace("'", '’')).strip()


def norm(s: str) -> str:
    return corpus.clean(s).replace('’', "'").replace(' ', ' ').replace(' ', ' ')


def fr_tokens(s: str) -> list[str]:
    return re.findall(r"[\wÀ-ÿœŒ]+", norm(s).lower())


def diff_size(a: str, b: str) -> int:
    """Number of differing word tokens between two French texts (symmetric difference of aligned tokens)."""
    import difflib
    ta, tb = fr_tokens(a), fr_tokens(b)
    sm = difflib.SequenceMatcher(a=ta, b=tb, autojunk=False)
    n = 0
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag != 'equal':
            n += max(i2 - i1, j2 - j1)
    if len(ta) == len(tb):  # swaps (mon/ton) confuse difflib; positional count is fairer
        n = min(n, sum(1 for x, y in zip(ta, tb) if x != y))
    return n


def feature_parts(f: str) -> tuple[str, list[str]]:
    kind, _, rest = f.partition(':')
    return kind, rest.split('.')


def check_distinction(dist: str, ok: str, wrong: str) -> str | None:
    """None when the wrong feature differs from the ok feature exactly in the
    named dimension; else an error message."""
    ko, po = feature_parts(ok)
    kw, pw = feature_parts(wrong)
    if dist in ('congruentia', 'nonfinita'):
        return None if ok != wrong else 'wrong feature equals the correct one'
    if ko != kw:
        if dist == 'casus' and ko in ('n', 'a') and kw in ('n', 'a'):
            pass
        else:
            return f'{dist}: feature kinds differ ({ok} vs {wrong})'
    if ko == 'v':
        finite = po[0] in ('ind', 'subj', 'imp')
        if dist == 'numerus':
            idx = 4 if finite else (4 if po[0] == 'part' else None)
            if idx is None or len(po) <= idx or len(pw) <= idx:
                return f'numerus: no number in {ok}'
            same = po[:idx] + po[idx + 1:] == pw[:idx] + pw[idx + 1:]
            return None if same and po[idx] != pw[idx] else f'numerus: {ok} → {wrong} changes more than the number'
        if dist == 'persona':
            if not finite or len(pw) < 5:
                return 'persona: not a finite form'
            same = po[:3] + po[4:] == pw[:3] + pw[4:]
            return None if same and po[3] != pw[3] else f'persona: {ok} → {wrong} changes more than the person'
        if dist == 'tempus':
            if po[0] != pw[0] or po[2:] != pw[2:] or po[1] == pw[1]:
                return f'tempus: {ok} → {wrong} must change the tense only'
            return None
        if dist == 'vox':
            if po[0] != pw[0] or po[1] != pw[1] or po[3:] != pw[3:] or po[2] == pw[2]:
                return f'vox: {ok} → {wrong} must change the voice only'
            return None
        if dist == 'modus':
            if po[0] == pw[0]:
                return f'modus: {ok} → {wrong} must change the mood'
            if finite and pw[0] in ('ind', 'subj', 'imp') and po[3:] != pw[3:]:
                return f'modus: {ok} → {wrong} must keep person and number'
            return None
        if dist == 'casus':
            if po[0] != 'part':
                return f'casus: {ok} is not a declined form'
            return None if po[3] != pw[3] and po[:3] + po[4:] == pw[:3] + pw[4:] else f'casus: {ok} → {wrong} must change the case only'
    if ko in ('n', 'a'):
        if dist == 'numerus':
            if len(po) < 2 or len(pw) < 2 or po[1] == pw[1] or po[0] != pw[0]:
                return f'numerus: {ok} → {wrong} must change the number only'
            return None
        if dist == 'casus':
            if po[0] == pw[0] or po[1:2] != pw[1:2]:
                return f'casus: {ok} → {wrong} must change the case only'
            return None
        return f'{dist} does not apply to a nominal form'
    return f'{dist}: unsupported feature {ok}'


def latin_expl(dist: str, span: str, ok_lat: str, wrong_lat: str, contrast: str | None) -> str:
    head = f'«{span}» est {ok_lat}.'
    if contrast:
        return f'{head} Sī {wrong_lat} esset, fōrma «{contrast}» legerētur.'
    return f'{head} Nōn est {wrong_lat}.'


# ------------------------------------------------------------------ v2 item loading

def Q(trial, ref, target, dist, la='VERSE', fr='LSG', paed=False, fr_ref=None, gloss=None, lemma=None, note='', hint=''):
    """Batch item (see items_fr/README.md)."""
    return {'trial': trial, 'ref': ref, 'la': la, 'fr': fr, 'paed': paed, 'fr_ref': fr_ref, 'target': target, 'dist': dist, 'gloss': gloss or {}, 'lemma': lemma or {}, 'note': note, 'hint': hint}


def load_batches(only: str | None = None) -> list[dict]:
    files = []
    if only:
        files = [only]
    elif os.path.isdir(BATCH_DIR):
        files = sorted(os.path.join(BATCH_DIR, f) for f in os.listdir(BATCH_DIR) if f.endswith('.py') and not f.startswith('_'))
    items = []
    for path in files:
        spec = importlib.util.spec_from_file_location(os.path.basename(path)[:-3], path)
        mod = importlib.util.module_from_spec(spec)
        mod.__dict__['Q'] = Q
        spec.loader.exec_module(mod)
        for q in getattr(mod, 'ITEMS', []):
            q = dict(q)
            q['_file'] = os.path.basename(path)
            items.append(q)
    return items


# ------------------------------------------------------------------ build

class Builder:
    def __init__(self, lex: Lexicon, la, fr):
        self.lex, self.la, self.fr = lex, la, fr
        self.errors: list[str] = []
        self.passages: dict[tuple[str, str], dict] = {}
        self.items_la: list[dict] = []
        self.items_fr: dict[str, dict] = {}
        self.ids: set[str] = set()
        self.per_trial: Counter[str] = Counter()
        self.sources: Counter[str] = Counter()
        self.distinction_use: Counter[str] = Counter()
        self.glosses: dict[str, str] = {}
        self.gloss_src: Counter[str] = Counter()

    # ----- shared pieces

    def passage(self, ref, text, verse_c, words, tag) -> str:
        pkey = (str(ref), text)
        if pkey not in self.passages:
            base = f'{ref.book}.{ref.chapter}.{ref.verse}'
            n = sum(1 for k in self.passages if k[0] == str(ref))
            self.passages[pkey] = {'id': base if n == 0 else f'{base}#{n + 1}', 'ref': str(ref), 'text': text, 'verse': verse_c, 'words': words}
        return self.passages[pkey]['id']

    def french(self, it, tag, ref, text, verse_len):
        fr_ref = corpus.Ref.parse(it['fr_ref']) if it.get('fr_ref') else corpus.to_lsg(ref)
        fr_verse = self.fr.get(fr_ref) if fr_ref else None
        fr_verse_c = corpus.clean(fr_verse) if fr_verse else ''
        correct_text = it['fr']
        if it.get('paed'):
            return 'paed', typo(correct_text), fr_ref, fr_verse_c
        if correct_text == 'LSG':
            if not fr_verse:
                self.errors.append(f'{tag}: fr=LSG but no Segond verse at {fr_ref}')
                return None
            if text != corpus.clean(self.la[ref]):
                self.errors.append(f'{tag}: fr=LSG (whole verse) requires the whole Latin verse as passage')
                return None
            return 'LSG', typo(fr_verse_c), fr_ref, fr_verse_c
        if not fr_verse:
            self.errors.append(f'{tag}: no Segond verse at {fr_ref}; mark the rendering as pedagogical')
            return None
        hay, needle = norm(fr_verse_c), norm(correct_text)
        idx = hay.find(needle)
        if idx < 0:
            self.errors.append(f'{tag}: French rendering is not a span of Segond {fr_ref} (paed=True if deliberate):\n    {needle}\n    {hay}')
            return None
        return 'LSG', typo(fr_verse_c[idx:idx + len(needle)]), fr_ref, fr_verse_c

    def check_choices(self, tag, correct_out, dist_texts):
        texts = {norm(correct_out).lower()}
        for t in dist_texts:
            n = norm(typo(t)).lower()
            if n in texts:
                self.errors.append(f'{tag}: duplicate or correct-identical distractor: {t}')
            texts.add(n)
            d = diff_size(correct_out, t)
            # One misreading may legitimately propagate through French agreement
            # (ils verront → il verra); a wholesale rewrite may not.
            limit = max(MAX_DIFF_TOKENS, round(0.6 * len(fr_tokens(correct_out))))
            if d == 0:
                self.errors.append(f'{tag}: distractor identical to the rendering: {t}')
            elif d > limit:
                self.errors.append(f'{tag}: distractor rewrites the rendering ({d} words differ, max {limit}): {t}')

    def emit(self, it, trial, ref, text, verse_c, words, fr_res, target, distractors, note, hint, band, item_glosses):
        source, correct_out, fr_ref, fr_verse_c = fr_res
        self.sources[source] += 1
        pid = self.passage(ref, text, verse_c, words, '')
        iid = f"{trial}|{ref}|{target['span']}"
        tag = f'{trial} {ref}'
        if iid in self.ids:
            self.errors.append(f'{tag}: duplicate item id {iid}')
        self.ids.add(iid)
        self.per_trial[trial] += 1
        for d in distractors:
            self.distinction_use[d['distinction']] += 1
        self.items_la.append({
            'id': iid, 'passage': pid, 'trial': trial, 'skill': TRIALS[trial][2],
            'distinctions': sorted({d['distinction'] for d in distractors}),
            'target': target, 'hint': hint, 'note': note, 'band': band, 'status': 'validated', 'version': VERSION,
        })
        self.items_fr[iid] = {
            'correct': [{'id': 'c1', 'text': correct_out, 'source': source, 'ref': str(fr_ref) if fr_ref else ''}],
            'distractors': [{'id': f'd{i + 1}', **d} for i, d in enumerate(distractors)],
            'verse': typo(fr_verse_c) if fr_verse_c else '', 'verseRef': str(fr_ref) if fr_ref else '',
            'glosses': item_glosses,
        }

    # ----- v1 (hand-written items_fr.py)

    def add_v1(self, it):
        trial = it['trial']
        ref = corpus.Ref.parse(it['ref'])
        tag = f'{trial} {ref}'
        verse = self.la.get(ref)
        if verse is None:
            self.errors.append(f'{tag}: Latin verse absent')
            return
        verse_c = corpus.clean(verse)
        text = corpus.clean(it['la'])
        if text not in verse_c:
            self.errors.append(f'{tag}: Latin span is not an exact substring of the verse')
            return
        fr_res = self.french(it, tag, ref, text, len(verse_c))
        if fr_res is None:
            return
        dist = it['dist']
        if len(dist) != 3:
            self.errors.append(f'{tag}: {len(dist)} distractors')
        allow = allowed(trial)
        out_d = []
        for d in dist:
            for k in ('span', 'ok', 'wrong', 'shift', 'distinction', 'expl'):
                if not d.get(k):
                    self.errors.append(f'{tag}: distractor lacks {k}')
            if d['distinction'] not in allow:
                self.errors.append(f'{tag}: distinction {d["distinction"]} not allowed (allowed: {sorted(allow)})')
            if corpus.clean(d['span']) not in text:
                self.errors.append(f'{tag}: distractor span "{d["span"]}" not in passage')
            out_d.append({'text': typo(d['text']), 'span': d['span'], 'ok': d['ok'], 'wrong': d['wrong'], 'shift': typo(d['shift']),
                          'skill': 'l.' + d['distinction'], 'formSkill': d.get('formSkill', ''), 'distinction': d['distinction'], 'expl': d['expl']})
        self.check_choices(tag, fr_res[1], [d['text'] for d in out_d])
        tgt = it['target']
        if corpus.clean(tgt['span']) not in text:
            self.errors.append(f'{tag}: target span not in passage')
        words, glosses, lemmas = [], {}, []
        for tok in corpus.latin_tokens(text):
            key = corpus.latin_key(tok)
            lemma = LEX.get(key)
            if lemma is None:
                self.errors.append(f'{tag}: token {key} without lemma in LEX')
                continue
            # words are keyed by the corpus lexicon's entry so that vocabulary
            # counts agree between hand-written and batch items
            ce = self.lex.entry(tok)
            wl = ce or lemma
            words.append({'f': tok, 'l': wl})
            if lemma in GLOSS:
                glosses[wl] = GLOSS[lemma]
            else:
                self.errors.append(f'{tag}: lemma {lemma} without gloss')
            if ce:
                lemmas.append(ce)
        target = {'span': tgt['span'], 'lemma': tgt['lemma'], 'formSkill': tgt.get('formSkill', ''), 'analysis': tgt['analysis']}
        self.emit(it, trial, ref, text, verse_c, words, fr_res, target, out_d, it.get('note', ''), it.get('hint', ''), self.lex.band(lemmas), glosses)

    # ----- v2 (batch items)

    def add_v2(self, it):
        trial = it['trial']
        tag = f"{it.get('_file', '')} {trial} {it['ref']}"
        if trial not in TRIALS:
            self.errors.append(f'{tag}: unknown trial')
            return
        try:
            ref = corpus.Ref.parse(it['ref'])
        except ValueError as e:
            self.errors.append(f'{tag}: {e}')
            return
        verse = self.la.get(ref)
        if verse is None:
            self.errors.append(f'{tag}: Latin verse absent')
            return
        verse_c = corpus.clean(verse)
        text = verse_c if it.get('la') in (None, '', 'VERSE') else corpus.clean(it['la'])
        if text not in verse_c:
            self.errors.append(f'{tag}: Latin span is not an exact substring of the verse:\n    {text}\n    {verse_c}')
            return
        if len(text) > MAX_PASSAGE:
            self.errors.append(f'{tag}: passage too long ({len(text)} > {MAX_PASSAGE}); choose a clause')
            return
        fr_res = self.french(it, tag, ref, text, len(verse_c))
        if fr_res is None:
            return
        # words, lemmas, glosses
        lemma_over = {corpus.latin_key(k): v for k, v in (it.get('lemma') or {}).items()}
        gloss_over = {k: v for k, v in (it.get('gloss') or {}).items()}
        gloss_over_keys = {corpus.latin_key(k): v for k, v in gloss_over.items()}
        words, lemmas, item_glosses = [], [], {}
        for tok in corpus.latin_tokens(text):
            key = corpus.latin_key(tok)
            an = self.lex.analyses(tok)
            lemma = lemma_over.get(key)
            if lemma and an and lemma not in an:
                self.errors.append(f'{tag}: lemma override {lemma} for {tok} is not an analysis the lexicon gives ({sorted(an)})')
            if lemma is None:
                lemma = self.lex.entry(tok) or ('?' + vocab.fkey(tok))
            words.append({'f': tok, 'l': lemma})
            lemmas.append(lemma)
            g = gloss_over.get(lemma) or gloss_over_keys.get(key) or gloss_over.get(tok)
            if g:
                item_glosses[lemma] = typo(g)
                self.gloss_src['authored'] += 1
            elif lemma.startswith('?') or not self.lex.gloss(lemma):
                self.errors.append(f'{tag}: no French meaning for «{tok}» (lemma {lemma}); add gloss={{"{tok}": "…"}}')
            else:
                self.glosses[lemma] = self.lex.gloss(lemma)
                self.gloss_src['collatinus'] += 1
        # target
        t = it['target']
        span, ok = t[0], t[1]
        forced_lemma = t[2] if len(t) > 2 else None
        if corpus.clean(span) not in text:
            self.errors.append(f'{tag}: target span "{span}" not in passage')
            return
        span_tok = corpus.latin_tokens(span)
        an = self.lex.analyses(span_tok[-1]) if span_tok else {}
        cands = [l for l, fs in an.items() if ok in fs and (forced_lemma is None or l == forced_lemma)]
        if not cands:
            self.errors.append(f'{tag}: the lexicon does not analyse «{span}» as {ok}; it offers: ' + '; '.join(f'{l}: {", ".join(sorted(fs))}' for l, fs in an.items())[:400])
            return
        cands.sort(key=lambda l: -self.lex.inv.entries.get(l, {}).get('freq', 0))
        lemma = cands[0]
        ok_lat = vocab.feature_to_latin(ok)
        target = {'span': span, 'lemma': lemma, 'formSkill': self.lex.form_skill(lemma, ok), 'analysis': ok_lat, 'feature': ok}
        # distractors
        dist = it['dist']
        if len(dist) != 3:
            self.errors.append(f'{tag}: {len(dist)} distractors (3 required)')
        allow = allowed(trial)
        out_d = []
        for d in dist:
            if len(d) != 5:
                self.errors.append(f'{tag}: distractor needs (text, span, distinction, wrong, shift): {d}')
                continue
            d_text, d_span, distinction, wrong, shift = d
            if distinction not in DISTINCTIONS:
                self.errors.append(f'{tag}: unknown distinction {distinction}')
                continue
            if distinction not in allow:
                self.errors.append(f'{tag}: distinction {distinction} not allowed in {trial} (allowed: {sorted(allow)})')
            if corpus.clean(d_span) not in text:
                self.errors.append(f'{tag}: distractor span "{d_span}" not in passage')
                continue
            if not shift or not shift.strip():
                self.errors.append(f'{tag}: distractor lacks the French shift: {d_text}')
            d_tok = corpus.latin_tokens(d_span)
            d_an = self.lex.analyses(d_tok[-1]) if d_tok else {}
            # the correct analysis of the distractor span: the target's when same span, else the most frequent lemma's first feature matching an authored hint
            if wrong.startswith('!'):
                # free-text misreading (congruentia / nonfinita), no contrast form
                d_ok_feat = ok if d_span == span else (next(iter(next(iter(d_an.values())))) if d_an else '')
                d_ok_lat = vocab.feature_to_latin(d_ok_feat) if d_ok_feat else 'fōrma'
                d_lemma = lemma if d_span == span else (self.lex.entry(d_tok[-1]) or '')
                wrong_lat = wrong[1:].strip()
                contrast = None
                if distinction not in ('congruentia', 'nonfinita', 'casus'):
                    self.errors.append(f'{tag}: free-text misreading only allowed for congruentia/nonfinita/casus ({distinction})')
            else:
                # wrong may be "okfeature>wrongfeature" when the span is not the target
                if '>' in wrong:
                    d_ok_feat, wrong = wrong.split('>', 1)
                else:
                    d_ok_feat = ok if d_span == span else None
                if d_ok_feat is None:
                    # infer: the unique feature of the span whose change in `distinction` gives `wrong`
                    opts = [(l, f) for l, fs in d_an.items() for f in fs if check_distinction(distinction, f, wrong) is None]
                    if len({f for _, f in opts}) != 1:
                        self.errors.append(f'{tag}: give the correct feature of «{d_span}» as "ok>wrong" (candidates: ' + '; '.join(f'{l}: {", ".join(sorted(fs))}' for l, fs in d_an.items())[:300] + ')')
                        continue
                    d_lemma, d_ok_feat = opts[0]
                else:
                    ls = [l for l, fs in d_an.items() if d_ok_feat in fs]
                    if not ls:
                        self.errors.append(f'{tag}: the lexicon does not analyse «{d_span}» as {d_ok_feat}; it offers: ' + '; '.join(f'{l}: {", ".join(sorted(fs))}' for l, fs in d_an.items())[:300])
                        continue
                    ls.sort(key=lambda l: -self.lex.inv.entries.get(l, {}).get('freq', 0))
                    d_lemma = lemma if (d_span == span and lemma in ls) else ls[0]
                err = check_distinction(distinction, d_ok_feat, wrong)
                if err:
                    self.errors.append(f'{tag}: {err}')
                    continue
                d_ok_lat = vocab.feature_to_latin(d_ok_feat)
                wrong_lat = vocab.feature_to_latin(wrong)
                forms = self.lex.forms_of(d_lemma).get(wrong, set())
                contrast = sorted(forms, key=len)[0] if forms else None
                if contrast is None and distinction not in ('congruentia', 'nonfinita'):
                    self.errors.append(f'{tag}: the lexicon has no form {wrong} for {d_lemma} (contrast form); is the misreading real?')
                    continue
            out_d.append({
                'text': typo(d_text), 'span': d_span, 'ok': f'{d_ok_lat} ({d_span})', 'wrong': wrong_lat + (f' ({contrast})' if contrast else ''),
                'shift': typo(shift), 'skill': 'l.' + distinction, 'formSkill': self.lex.form_skill(d_lemma, d_ok_feat) if d_ok_feat else '',
                'distinction': distinction, 'expl': latin_expl(distinction, d_span, d_ok_lat, wrong_lat, contrast), 'wrongFeature': wrong if not wrong.startswith('!') else '',
            })
        if len(out_d) != 3:
            return
        self.check_choices(tag, fr_res[1], [d['text'] for d in out_d])
        self.emit(it, trial, ref, text, verse_c, words, fr_res, target, out_d, it.get('note', ''), it.get('hint', ''), self.lex.band(lemmas), item_glosses)


def write_assets(b: Builder) -> None:
    os.makedirs(ASSETS, exist_ok=True)
    now = datetime.now(timezone.utc).isoformat(timespec='seconds')
    la_out = {
        'dataset': {'id': 'theatrum-la', 'version': VERSION, 'generatedAt': now, 'edition': corpus.EDITIONS['la'], 'items': len(b.items_la), 'passages': len(b.passages),
                    'bands': BAND_LIMITS, 'bandNote': 'vocabulary band of an item = highest frequency band among its common lemmas (ranks by corpus frequency)'},
        'books': {k: v for k, v in BOOKS.items() if any(p['ref'].startswith(k + ' ') for p in b.passages.values())},
        'passages': list(b.passages.values()),
        'items': b.items_la,
        # vocabulary band of every common lemma used in the content (progression + Tabula)
        'lemmaBands': {l: b.lex.band([l]) for p in b.passages.values() for l in {w['l'] for w in p['words']} if b.lex.rank(l) < 10 ** 6},
    }
    fr_out = {
        'dataset': {'id': 'theatrum-fr', 'version': VERSION, 'language': 'fr', 'generatedAt': now, 'edition': corpus.EDITIONS['fr'], 'items': len(b.items_fr), 'sources': dict(b.sources),
                    'glossSources': dict(b.gloss_src),
                    'note': 'Renderings marked "LSG" are exact spans of Louis Segond 1910; renderings marked "paed" are pedagogical renderings written for this game and never attributed to Segond. '
                            'Glosses come from the Collatinus lexica (GPL, see THIRD_PARTY_NOTICES.md) or were authored for this game.'},
        'glosses': dict(sorted(b.glosses.items())),
        'items': b.items_fr,
    }
    with open(os.path.join(ASSETS, 'passages_la.json'), 'w', encoding='utf-8') as f:
        json.dump(la_out, f, ensure_ascii=False, separators=(',', ':'))
    with open(os.path.join(ASSETS, 'renderings_fr.json'), 'w', encoding='utf-8') as f:
        json.dump(fr_out, f, ensure_ascii=False, separators=(',', ':'))


def main(argv: list[str]) -> int:
    only = argv[argv.index('--only') + 1] if '--only' in argv else None
    la, fr = corpus.load_latin(), corpus.load_french()
    lex = Lexicon()
    b = Builder(lex, la, fr)
    if not only:
        for it in ITEMS:
            b.add_v1(it)
    for it in load_batches(only):
        b.add_v2(it)
    if b.errors:
        print(f'CONTENT BUILD FAILED ({len(b.errors)} errors)')
        for e in b.errors[:200]:
            print(' -', e)
        return 1
    if only:
        print(f'ok: {len(b.items_la)} items in {os.path.basename(only)} validated; trials: {dict(b.per_trial)}; sources {dict(b.sources)}')
        return 0
    write_assets(b)
    print(f'ok: {len(b.items_la)} items, {len(b.passages)} passages, sources {dict(b.sources)}, glosses {dict(b.gloss_src)}')
    for t in TRIALS:
        print(f'  {t:24s} {b.per_trial[t]}')
    # coverage report + acceptance
    inv = lex.inv
    m = vocab.measure(inv)
    with open(vocab.COVERAGE_JSON, 'w', encoding='utf-8') as f:
        json.dump(m, f, ensure_ascii=False, indent=1)
    vocab.write_report(inv, m)
    print(f'coverage: taught {m["taught"]}/{m["entries"]} = {m["taught_pct"]} % (min {m["min_coverage_pct"]} %), tested {m["tested_pct"]} %, weighted {m["weighted_taught_pct"]} %, with meaning {m["with_meaning_pct"]} %')
    print('ACCEPTANCE:', 'ok' if m['passes'] else f'NOT REACHED (task unfinished)')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
