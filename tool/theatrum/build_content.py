#!/usr/bin/env python3
"""Builds and validates the Theatrum content from the authored source.

    python3 tool/theatrum/build_content.py          # validate, write assets, write coverage report

Input : tool/theatrum/items_fr.py (authored items, lexicon and glosses),
        assets/corpus/*.txt (the two source texts, see tool/corpus/bible/corpus.py).
Output: assets/theatrum/passages_la.json      Latin side (passages, items, Latin annotations)
        assets/theatrum/renderings_fr.json    French side (renderings, distractors, glosses)
        doc/theatrum_coverage.md              vocabulary / morphology coverage report
        tool/corpus/out/theatrum_content.json machine-readable summary

Every check below fails the build: an item is shipped only when its Latin is
an exact contiguous span of the Clementine verse, its faithful rendering is
either an exact span of the Louis Segond verse or explicitly marked as a
pedagogical rendering, its three distractors are distinct, complete and use
only distinctions allowed at the trial's level, and every Latin token has a
lemma with a French gloss. Nothing is generated: the script only checks and
packages what was written.
"""
from __future__ import annotations

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
from items_fr import GLOSS, ITEMS, LEX  # noqa: E402

VERSION = '1.0.0'
ASSETS = os.path.join(ROOT, 'assets', 'theatrum')
DOC = os.path.join(ROOT, 'doc', 'theatrum_coverage.md')
SUMMARY = os.path.join(ROOT, 'tool', 'corpus', 'out', 'theatrum_content.json')

DISTINCTIONS = {'numerus', 'persona', 'casus', 'tempus', 'vox', 'modus', 'congruentia', 'nonfinita'}

# Mirror of ReadingTrials (lib/pedagogy/reading/reading_trials.dart): own
# distinctions and prerequisites, so that level alignment fails at build time
# as well as in the Dart tests.
TRIALS = {
    'th-numerus': ({'numerus'}, []),
    'th-persona': ({'persona', 'numerus'}, ['th-numerus']),
    'th-casus-recti': ({'casus'}, ['th-numerus']),
    'th-tempus-praeteritum': ({'tempus'}, ['th-persona']),
    'th-tempus-futurum': ({'tempus'}, ['th-tempus-praeteritum']),
    'th-casus-obliqui': ({'casus'}, ['th-casus-recti']),
    'th-congruentia': ({'congruentia'}, ['th-casus-obliqui']),
    'th-modus-imperativus': ({'modus'}, ['th-persona']),
    'th-vox': ({'vox'}, ['th-tempus-praeteritum']),
    'th-modus-subiunctivus': ({'modus'}, ['th-modus-imperativus', 'th-tempus-futurum']),
    'th-nonfinita': ({'nonfinita'}, ['th-vox', 'th-congruentia']),
}

BOOKS = {
    'GEN': 'Genesis', 'EXO': 'Exodus', 'LEV': 'Leviticus', 'NUM': 'Numeri', 'DEU': 'Deuteronomium', 'JOS': 'Josue', 'JDG': 'Judices',
    'RUT': 'Ruth', '1SA': 'Regum I', '2SA': 'Regum II', '1KI': 'Regum III', '2KI': 'Regum IV', 'JOB': 'Job', 'PSA': 'Psalmi',
    'PRO': 'Proverbia', 'ECC': 'Ecclesiastes', 'SOL': 'Canticum Canticorum', 'ISA': 'Isaias', 'JER': 'Jeremias', 'EZE': 'Ezechiel',
    'DAN': 'Daniel', 'HOS': 'Osee', 'JOE': 'Joel', 'AMO': 'Amos', 'JON': 'Jonas', 'MIC': 'Michaeas', 'HAB': 'Habacuc', 'ZEC': 'Zacharias',
    'MAL': 'Malachias', 'TOB': 'Tobias', 'JDT': 'Judith', 'WIS': 'Sapientia', 'SIR': 'Ecclesiasticus', 'BAR': 'Baruch',
    '1MA': 'Machabaeorum I', '2MA': 'Machabaeorum II',
    'MAT': 'Matthaeus', 'MAR': 'Marcus', 'LUK': 'Lucas', 'JOH': 'Joannes', 'ACT': 'Actus Apostolorum', 'ROM': 'Ad Romanos',
    '1CO': 'Ad Corinthios I', '2CO': 'Ad Corinthios II', 'GAL': 'Ad Galatas', 'EPH': 'Ad Ephesios', 'PHI': 'Ad Philippenses',
    'COL': 'Ad Colossenses', '1TH': 'Ad Thessalonicenses I', '2TH': 'Ad Thessalonicenses II', '1TI': 'Ad Timotheum I', '2TI': 'Ad Timotheum II',
    'TIT': 'Ad Titum', 'PHM': 'Ad Philemonem', 'HEB': 'Ad Hebraeos', 'JAM': 'Jacobi', '1PE': 'Petri I', '2PE': 'Petri II', '1JO': 'Joannis I',
    '2JO': 'Joannis II', '3JO': 'Joannis III', 'JUD': 'Judae', 'REV': 'Apocalypsis',
}


def allowed(trial: str) -> set[str]:
    out: set[str] = set()
    seen: set[str] = set()

    def visit(t: str) -> None:
        if t in seen:
            return
        seen.add(t)
        own, pre = TRIALS[t]
        out.update(own)
        for p in pre:
            visit(p)

    visit(trial)
    return out


def typo(s: str) -> str:
    """Uniform French typography for every choice: curly apostrophe, no double spaces."""
    return re.sub(r'\s+', ' ', s.replace("'", '’')).strip()


def norm(s: str) -> str:
    return corpus.clean(s).replace('’', "'").replace(' ', ' ').replace(' ', ' ')


def build() -> int:
    la = corpus.load_latin()
    fr = corpus.load_french()
    errors: list[str] = []
    passages: dict[tuple[str, str], dict] = {}
    items_la: list[dict] = []
    items_fr: dict[str, dict] = {}
    seen_ids: set[str] = set()
    missing_lex: Counter[str] = Counter()
    missing_gloss: Counter[str] = Counter()
    used_lemmas: set[str] = set()
    used_forms: set[str] = set()
    per_trial: Counter[str] = Counter()
    sources: Counter[str] = Counter()
    distinction_use: Counter[str] = Counter()

    for it in ITEMS:
        trial = it['trial']
        ref = corpus.Ref.parse(it['ref'])
        tag = f"{trial} {ref}"
        if trial not in TRIALS:
            errors.append(f'{tag}: unknown trial')
            continue
        verse = la.get(ref)
        if verse is None:
            errors.append(f'{tag}: Latin verse absent')
            continue
        verse_c = corpus.clean(verse)
        text = corpus.clean(it['la'])
        if text not in verse_c:
            errors.append(f'{tag}: Latin span is not an exact substring of the verse:\n    {text}\n    {verse_c}')
            continue
        if len(text) > 160:
            errors.append(f'{tag}: passage too long for the question panel ({len(text)} chars)')
        # French side
        fr_ref = corpus.Ref.parse(it['fr_ref']) if it.get('fr_ref') else corpus.to_lsg(ref)
        fr_verse = fr.get(fr_ref) if fr_ref else None
        fr_verse_c = corpus.clean(fr_verse) if fr_verse else ''
        correct_text = it['fr']
        if it.get('paed'):
            source = 'paed'
            correct_out = typo(correct_text)
        else:
            if not fr_verse:
                errors.append(f'{tag}: no Segond verse at {fr_ref}; mark the rendering as pedagogical')
                continue
            hay = norm(fr_verse_c)
            needle = norm(correct_text)
            idx = hay.find(needle)
            if idx < 0:
                errors.append(f'{tag}: French rendering is not a span of Segond {fr_ref} (mark paed=True if deliberate):\n    {needle}\n    {hay}')
                continue
            source = 'LSG'
            correct_out = typo(fr_verse_c[idx:idx + len(needle)])
        sources[source] += 1
        # distractors
        dist = it['dist']
        if len(dist) != 3:
            errors.append(f'{tag}: {len(dist)} distractors (3 required)')
        texts = {norm(correct_out).lower()}
        allow = allowed(trial)
        for d in dist:
            t = norm(typo(d['text'])).lower()
            if t in texts:
                errors.append(f'{tag}: duplicate or correct-identical distractor: {d["text"]}')
            texts.add(t)
            for k in ('span', 'ok', 'wrong', 'shift', 'distinction', 'expl'):
                if not d.get(k):
                    errors.append(f'{tag}: distractor "{d["text"][:40]}" lacks {k}')
            if d['distinction'] not in DISTINCTIONS:
                errors.append(f'{tag}: unknown distinction {d["distinction"]}')
            elif d['distinction'] not in allow:
                errors.append(f'{tag}: distinction {d["distinction"]} not allowed at this level (allowed: {sorted(allow)})')
            if corpus.clean(d['span']) not in text:
                errors.append(f'{tag}: distractor span "{d["span"]}" not in passage')
            distinction_use[d['distinction']] += 1
        tgt = it['target']
        if corpus.clean(tgt['span']) not in text:
            errors.append(f'{tag}: target span "{tgt["span"]}" not in passage')
        # lexicon
        words = []
        for tok in corpus.latin_tokens(text):
            key = corpus.latin_key(tok)
            lemma = LEX.get(key)
            if lemma is None:
                missing_lex[key] += 1
                continue
            words.append({'f': tok, 'l': lemma})
            used_lemmas.add(lemma)
            used_forms.add(key)
            if lemma not in GLOSS:
                missing_gloss[lemma] += 1
        if tgt['lemma'] not in GLOSS:
            missing_gloss[tgt['lemma']] += 1
        # ids
        pkey = (str(ref), text)
        if pkey not in passages:
            base = f'{ref.book}.{ref.chapter}.{ref.verse}'
            n = sum(1 for k in passages if k[0] == str(ref))
            passages[pkey] = {'id': base if n == 0 else f'{base}#{n + 1}', 'ref': str(ref), 'text': text, 'verse': verse_c, 'words': words}
        pid = passages[pkey]['id']
        iid = f"{trial}|{ref}|{tgt['span']}"
        if iid in seen_ids:
            errors.append(f'{tag}: duplicate item id {iid}')
        seen_ids.add(iid)
        per_trial[trial] += 1
        items_la.append({
            'id': iid,
            'passage': pid,
            'trial': trial,
            'skill': it['skill'],
            'distinctions': sorted({d['distinction'] for d in dist}),
            'target': {'span': tgt['span'], 'lemma': tgt['lemma'], 'formSkill': tgt.get('formSkill', ''), 'analysis': tgt['analysis']},
            'hint': it.get('hint', ''),
            'note': it.get('note', ''),
            'status': 'validated' if not errors else 'invalid',
            'version': VERSION,
        })
        glosses = {w['l']: GLOSS[w['l']] for w in words if w['l'] in GLOSS}
        items_fr[iid] = {
            'correct': [{'id': 'c1', 'text': correct_out, 'source': source, 'ref': str(fr_ref) if fr_ref else ''}],
            'distractors': [
                {
                    'id': f'd{i + 1}',
                    'text': typo(d['text']),
                    'span': d['span'],
                    'ok': d['ok'],
                    'wrong': d['wrong'],
                    'shift': typo(d['shift']),
                    'skill': 'l.' + d['distinction'],
                    'formSkill': d.get('formSkill', ''),
                    'distinction': d['distinction'],
                    'expl': d['expl'],
                }
                for i, d in enumerate(dist)
            ],
            'verse': typo(fr_verse_c) if fr_verse else '',
            'verseRef': str(fr_ref) if fr_ref else '',
            'glosses': glosses,
        }

    if missing_lex:
        errors.append('tokens without lemma in LEX: ' + ', '.join(f'{k}({n})' for k, n in sorted(missing_lex.items())))
    if missing_gloss:
        errors.append('lemmas without gloss in GLOSS: ' + ', '.join(sorted(missing_gloss)))
    for t in TRIALS:
        if per_trial[t] < 10:
            errors.append(f'{t}: only {per_trial[t]} items (10 required)')
    if errors:
        print('CONTENT BUILD FAILED')
        for e in errors:
            print(' -', e)
        return 1

    os.makedirs(ASSETS, exist_ok=True)
    now = datetime.now(timezone.utc).isoformat(timespec='seconds')
    la_out = {
        'dataset': {'id': 'theatrum-la', 'version': VERSION, 'generatedAt': now, 'edition': corpus.EDITIONS['la'], 'items': len(items_la), 'passages': len(passages)},
        'books': {k: v for k, v in BOOKS.items() if any(p['ref'].startswith(k + ' ') for p in passages.values())},
        'passages': list(passages.values()),
        'items': items_la,
    }
    fr_out = {
        'dataset': {'id': 'theatrum-fr', 'version': VERSION, 'language': 'fr', 'generatedAt': now, 'edition': corpus.EDITIONS['fr'], 'items': len(items_fr), 'sources': dict(sources),
                    'note': 'Renderings marked "LSG" are exact spans of Louis Segond 1910; renderings marked "paed" are pedagogical renderings written for this game and are never attributed to Segond.'},
        'items': items_fr,
    }
    with open(os.path.join(ASSETS, 'passages_la.json'), 'w', encoding='utf-8') as f:
        json.dump(la_out, f, ensure_ascii=False, indent=1)
    with open(os.path.join(ASSETS, 'renderings_fr.json'), 'w', encoding='utf-8') as f:
        json.dump(fr_out, f, ensure_ascii=False, indent=1)
    summary = report(la, passages, items_la, per_trial, sources, distinction_use, used_lemmas, used_forms)
    os.makedirs(os.path.dirname(SUMMARY), exist_ok=True)
    with open(SUMMARY, 'w', encoding='utf-8') as f:
        json.dump(summary, f, ensure_ascii=False, indent=1)
    print(f'ok: {len(items_la)} items, {len(passages)} passages, {len(used_lemmas)} lemmas, sources {dict(sources)}')
    for t in TRIALS:
        print(f'  {t:24s} {per_trial[t]}')
    return 0


def report(la, passages, items, per_trial, sources, distinction_use, used_lemmas, used_forms) -> dict:
    inv_path = os.path.join(corpus.OUT_DIR, 'vulgate_inventory.json')
    inv = json.load(open(inv_path, encoding='utf-8')) if os.path.exists(inv_path) else corpus.inventory(la)
    forms = inv['forms']
    total_tokens = inv['tokens']
    covered = [f for f in forms if f['form'] in used_forms]
    covered_tokens = sum(f['n'] for f in covered)
    by_status = Counter(f['status'] for f in forms)
    covered_status = Counter(f['status'] for f in covered)
    # engine categories (verb: mood.tense.voice; noun: case.number)
    cat_total: Counter[str] = Counter()
    cat_cov: Counter[str] = Counter()
    for f in forms:
        cats = set()
        for a in f.get('verb', []):
            sel = a.split(':', 1)[1].split('.')
            cats.add('verbum ' + '.'.join(sel[:3]) if len(sel) >= 3 else 'verbum ' + '.'.join(sel))
        for a in f.get('noun', []):
            cats.add('nomen ' + a.split(':', 1)[1])
        for c in cats:
            cat_total[c] += 1
            if f['form'] in used_forms:
                cat_cov[c] += 1
    uncovered_frequent = [f for f in forms if f['form'] not in used_forms and f['status'] != 'proper'][:60]
    uncovered_resolved = [f for f in forms if f['form'] not in used_forms and f['status'] in ('verb', 'noun')][:40]
    lines = []
    w = lines.append
    w('# Theatrum — couverture du vocabulaire et de la morphologie')
    w('')
    w(f'Généré par `python3 tool/theatrum/build_content.py` le {datetime.now(timezone.utc).date()}. Ce rapport distingue explicitement ce qui est **présent dans le corpus importé**, ce qui est **présent dans le contenu jouable validé**, et ce que le joueur a **rencontré** (suivi à l\'exécution dans la sauvegarde, `ExposureLedger`, affiché dans la Tabula). L\'import du corpus ne vaut pas couverture.')
    w('')
    w('## 1. Corpus importé (latin)')
    w('')
    w(f'* Édition : {inv["edition"]["title"]} — {inv["edition"]["source"]}. **Demandé : {inv["edition"]["requested"]}.** {inv["edition"]["note"]}')
    w(f'* {total_tokens:,} occurrences, **{inv["surface_forms"]:,} formes de surface distinctes** (clé de comparaison : minuscules, æ→ae, j→i).')
    w(f'* Résolues par les moteurs du jeu (verbes + noms vérifiés A&G) : {inv["resolved_forms_by_engine"]:,} formes ({inv["resolved_tokens_by_engine"]:,} occurrences, {100 * inv["resolved_tokens_by_engine"] / total_tokens:.1f} %).')
    w(f'* Noms propres (heuristique de capitalisation) : {inv["proper_name_forms"]:,} formes ({inv["proper_tokens"]:,} occurrences).')
    w(f'* Non résolues (hors lexiques du jeu, sans analyse automatique) : {inv["unresolved_forms"]:,} formes. Elles sont **inventoriées, pas analysées** ; aucune analyse Collatinus n\'est embarquée.')
    w('')
    w('## 2. Contenu jouable validé (Gallicē)')
    w('')
    w(f'* **{len(items)} questions** sur **{len(passages)} passages**, toutes validées par le script (texte latin exact, rendu français exact de Segond ou rendu pédagogique identifié, trois distracteurs annotés, niveau des distinctions conforme à la progression).')
    w(f'* Rendus fidèles : {sources.get("LSG", 0)} extraits exacts de Louis Segond 1910, {sources.get("paed", 0)} rendus pédagogiques (quand Segond ne rend pas la forme latine visée : temps, nombre, personne ou texte différent).')
    w(f'* Vocabulaire des passages : **{len(used_lemmas)} lemmes**, **{len(used_forms)} formes de surface** distinctes, toutes glosées en français dans l\'Auxilium.')
    w('')
    w('| Épreuve | Questions |')
    w('|---|---|')
    for t in TRIALS:
        w(f'| `{t}` | {per_trial[t]} |')
    w('')
    w('Distinctions testées par les distracteurs : ' + ', '.join(f'{k} {v}' for k, v in sorted(distinction_use.items())) + '.')
    w('')
    w('## 3. Couverture du corpus par le contenu jouable')
    w('')
    w(f'* Formes de surface du corpus présentes dans un passage jouable : **{len(covered):,} / {inv["surface_forms"]:,}** ({100 * len(covered) / inv["surface_forms"]:.2f} %) ; occurrences couvertes : {covered_tokens:,} / {total_tokens:,} ({100 * covered_tokens / total_tokens:.1f} %).')
    w(f'* Par statut : ' + ', '.join(f'{k} {covered_status.get(k, 0)}/{by_status[k]}' for k in ('verb', 'noun', 'proper', 'unresolved')) + '.')
    w('')
    w('### Catégories morphologiques des moteurs du jeu (formes du corpus couvertes / résolues)')
    w('')
    w('| Catégorie | Couvertes | Résolues dans le corpus |')
    w('|---|---|---|')
    for c, n in sorted(cat_total.items(), key=lambda x: (-cat_cov[x[0]], x[0]))[:40]:
        w(f'| {c} | {cat_cov[c]} | {n} |')
    zero = sorted(c for c in cat_total if cat_cov[c] == 0)
    w('')
    w(f'Catégories résolues dans le corpus mais **sans aucune forme couverte** ({len(zero)}) : ' + ', '.join(zero[:60]) + (' …' if len(zero) > 60 else '') + '.')
    w('')
    w('## 4. Lacunes')
    w('')
    w('### Formes les plus fréquentes du corpus sans couverture jouable (noms propres exclus)')
    w('')
    w('| Forme | Occurrences | Statut | Exemple |')
    w('|---|---|---|---|')
    for f in uncovered_frequent:
        w(f'| {f["form"]} | {f["n"]} | {f["status"]} | {f["example"]} |')
    w('')
    w('### Formes résolues par les moteurs (verbes/noms du jeu) sans couverture jouable, les plus fréquentes')
    w('')
    w('| Forme | Occurrences | Analyses |')
    w('|---|---|---|')
    for f in uncovered_resolved:
        w(f'| {f["form"]} | {f["n"]} | {", ".join((f.get("verb") or []) + (f.get("noun") or []))[:80]} |')
    w('')
    w('### Ce qui manque, explicitement')
    w('')
    w(f'* {inv["surface_forms"] - len(covered):,} formes de surface du corpus ({100 * (inv["surface_forms"] - len(covered)) / inv["surface_forms"]:.1f} %) n\'apparaissent dans aucune question. L\'objectif « tout le vocabulaire du corpus » n\'est **pas** atteint : le parcours actuel couvre le noyau grammatical avec {len(items)} questions validées ; l\'extension se fait dans `tool/theatrum/items_fr.py` (même format, même validation).')
    w('* Les livres absents de Segond (Tobie, Judith, Sagesse, Siracide, Baruch, 1–2 Maccabées, Esther 11–16, Daniel 13–14) ne peuvent recevoir que des rendus pédagogiques identifiés ; aucun n\'est encore rédigé.')
    w('* Anglicē : aucun contenu (le fichier `renderings_en.json` n\'existe pas) ; la langue est visible mais non sélectionnable.')
    w('')
    w('## 5. Suivi côté joueur')
    w('')
    w('La sauvegarde (`expo`) compte, par lemme du contenu jouable : occurrences rencontrées, passages distincts (≥ 2 = « rencontré à nouveau dans un autre contexte »), fois où le lemme était la forme interrogée, et par question le nombre de parties jouées. La sélection (`ReadingQuestionSource.weight`) favorise les questions jamais jouées et le vocabulaire jamais ou peu rencontré, et les questions familières quand une révision est due. Ces compteurs sont affichés dans la Tabula à part de la maîtrise et n\'y contribuent jamais.')
    with open(DOC, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')
    return {
        'items': len(items),
        'passages': len(passages),
        'lemmas': len(used_lemmas),
        'forms': len(used_forms),
        'corpus_forms': inv['surface_forms'],
        'covered_forms': len(covered),
        'covered_tokens': covered_tokens,
        'total_tokens': total_tokens,
        'per_trial': dict(per_trial),
        'sources': dict(sources),
        'distinctions': dict(distinction_use),
        'categories_without_coverage': zero,
    }


if __name__ == '__main__':
    sys.exit(build())
