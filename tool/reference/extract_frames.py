"""Regroupe les questions Theatrum/Templum en cadres et infère les emplacements variables.

Un cadre = même carte, même interaction, mêmes explications pour chaque issue, même
squelette de phrase (même nombre de mots par segment et par proposition). À l'intérieur
d'un cadre, les positions dont le mot change d'une instanciation à l'autre sont des
emplacements ; l'ensemble des valeurs observées à chaque emplacement est conservé.

Sortie : reference/frames/<lieu>.json — liste de cadres, jamais de questions générées.
"""
import collections
import base64
import hashlib
import json
import re
import sys

import glob
import os

from common import REPO, ROOT, cards, flatten, load, questions

TOKEN = re.compile(r"\n|[^\s]+")


def tokens(s):
    return TOKEN.findall(s)


def pack_rows(rows):
    """Lossless column dictionaries + little-endian indices, never a sample.

    Dart decodes one row on demand rather than allocating hundreds of thousands
    of lists and repeated strings at startup. Column widths are explicit.
    """
    columns, indices, widths = [], [], []
    for values in zip(*rows):
        dictionary = dict.fromkeys(values)
        lookup = {value: i for i, value in enumerate(dictionary)}
        columns.append(list(dictionary))
        indices.append([lookup[value] for value in values])
        widths.append(1 if len(dictionary) <= 256 else 2 if len(dictionary) <= 65536 else 4)
    packed = bytearray()
    for row in zip(*indices):
        for value, width in zip(row, widths):
            packed.extend(value.to_bytes(width, 'little'))
    return {'columns': columns, 'widths': widths, 'length': len(rows),
            'data': base64.b64encode(packed).decode('ascii')}


def skeleton(flat):
    """Signature structurelle : types des segments et nombre de propositions. Les longueurs en
    mots ne comptent pas : « L'ami » et « Le cavalier » sont le même emplacement."""
    return tuple(seg['type'] for seg in flat['content']), len(flat['choices'])


def template(strings):
    """Patron commun à des chaînes alignées mot à mot sur la première (difflib).

    Les positions de la référence égales dans toutes les instanciations sont les ancres ;
    entre deux ancres, ce qui varie est un emplacement dont la valeur peut compter plusieurs
    mots. Renvoie (patron, emplacements) ; chaque emplacement liste ses valeurs distinctes.
    """
    import difflib
    strings = list(dict.fromkeys(strings))
    ref = tokens(strings[0])
    rows = [tokens(s) for s in strings]
    if len(rows) == 1:
        return ' '.join(ref), []
    stable = set(range(len(ref)))
    maps = []
    for row in rows:
        m = {}
        for i, j, n in difflib.SequenceMatcher(a=ref, b=row, autojunk=False).get_matching_blocks():
            for k in range(n):
                m[i + k] = j + k
        stable &= set(m)
        maps.append((row, m))
    anchors = sorted(stable)
    # Segments entre ancres consécutives (plus avant la première / après la dernière).
    bounds = [(-1, anchors[0] if anchors else len(ref))]
    bounds += [(anchors[i], anchors[i + 1]) for i in range(len(anchors) - 1)]
    if anchors:
        bounds.append((anchors[-1], len(ref)))
    out, slots = [], []
    for a, b in bounds:
        if a >= 0:
            out.append(ref[a])
        values = set()
        for row, m in maps:
            lo = m[a] + 1 if a >= 0 else 0
            hi = m[b] if b < len(ref) else len(row)
            values.add(' '.join(row[lo:hi]))
        if len(values) > 1 or (values and next(iter(values)) and b - a > 1):
            out.append('{%d}' % len(slots))
            slots.append({'after': a, '_next': b, 'values': sorted(values), 'count': len(values)})
        elif values and next(iter(values)):
            out.append(next(iter(values)))
    return ' '.join(out), slots


def _fill(member_text, ref_text, tpl_slots, members):
    """Valeurs des emplacements d'une chaîne d'instance, par le même alignement
    que `template` (ancres stables entre toutes les instances)."""
    if not tpl_slots:
        return []
    import difflib
    ref = tokens(ref_text)
    row = tokens(member_text)
    m = {}
    for i, j, n in difflib.SequenceMatcher(a=ref, b=row, autojunk=False).get_matching_blocks():
        for k in range(n):
            m[i + k] = j + k
    out = []
    for sl in tpl_slots:
        a = sl['after']
        # borne haute : prochaine ancre stable après a
        anchors = sl.get('_anchors')
        lo = m[a] + 1 if a >= 0 and a in m else 0
        b = sl.get('_next', len(ref))
        hi = m[b] if b < len(ref) and b in m else len(row)
        out.append(' '.join(row[lo:hi]))
    return out


BOILER = 'Vocābula in extrēmā parte sectiōnis probantur.'


def _strip_echo(text):
    for prefix in ('Rēctē. ', 'Nōn rēctē. ', 'Rēctē: ', 'Nōn rēctē: '):
        if text.startswith(prefix):
            return text[len(prefix):]
    return text


def _clean_lesson(blocks):
    """Paragraphes de leçon (sans les échos « Rēctē. » ni la phrase passe-partout,
    dédoublonnés) et entrées de vocabulaire « mot — sens »."""
    texts, examples, seen = [], [], set()
    for b in blocks:
        t = (b.get('text') or '').strip()
        if not t:
            continue
        if b.get('type') == 'example':
            if t not in seen:
                seen.add(t)
                examples.append(t)
            continue
        t = _strip_echo(t)
        if t == BOILER or t in seen:
            continue
        seen.add(t)
        texts.append(t)
    return texts, examples


def main(place):
    from context_banks import prepared
    compiled = prepared()
    print(f'{place}: compiling complete banks (no variant cap)', flush=True)
    groups = collections.defaultdict(list)
    for address, directory, card in cards(place):
        for q, texts in questions(directory, card):
            flat = flatten(q, texts)
            feedback = tuple(sorted(o['feedback'] for o in flat['outcomes'].values()))
            accepted = tuple(sorted(
                i for i, c in enumerate(flat['choices']) if c['id'] in flat['accepted']))
            # Keep each choice's diagnosis attached to that choice, and never
            # merge distinct authored assessment families, prompts or help.
            outcomes = tuple(json.dumps(flat['outcomes'][c['id']], sort_keys=True, ensure_ascii=False) for c in flat['choices'])
            key = (address, flat['interaction'], flat['dimension'], outcomes, skeleton(flat), accepted, tuple(flat['skills']), flat['prompt'], flat['help'], flat['selectionGroup'])
            groups[key].append(flat)
    frames = []
    for n, (key, members) in enumerate(sorted(groups.items(), key=lambda kv: (kv[0][0], -len(kv[1])))):
        address, interaction, dimension, feedback, _, accepted, skills, _, _, _ = key
        first = members[0]
        content = []
        slots = []
        for i, seg in enumerate(first['content']):
            if seg['type'] == 'image':
                content.append(seg)
                continue
            tpl, seg_slots = template([m['content'][i]['text'] for m in members])
            for s in seg_slots:
                s['in'] = f'content[{i}]'
            offset = len(slots)
            tpl = re.sub(r'\{(\d+)\}', lambda m: '{%d}' % (int(m.group(1)) + offset), tpl)
            slots.extend(seg_slots)
            content.append({'type': seg['type'], 'template': tpl})
        choices = []
        for j, ch in enumerate(first['choices']):
            tpl, ch_slots = template([m['choices'][j]['text'] for m in members])
            for s in ch_slots:
                s['in'] = f'choices[{j}]'
            offset = len(slots)
            tpl = re.sub(r'\{(\d+)\}', lambda m: '{%d}' % (int(m.group(1)) + offset), tpl)
            slots.extend(ch_slots)
            choices.append({
                'template': tpl,
                'accepted': j in accepted,
                'outcome': first['outcomes'][ch['id']],
                'lexeme': ch.get('lexeme'),
            })
        # Keep ALL observed aligned tuples, including their lexical exposure and
        # authored evidence identity. Background substitutions are not new evidence.
        value_cache = {}
        def values_of(member):
            vals = []
            for seg_i, seg in enumerate(first['content']):
                if seg['type'] == 'image':
                    continue
                tpl_slots = [sl for sl in slots if sl['in'] == f'content[{seg_i}]']
                text = member['content'][seg_i]['text']
                cache_key = ('content', seg_i, text)
                if cache_key not in value_cache:
                    value_cache[cache_key] = _fill(text, first['content'][seg_i]['text'], tpl_slots, members)
                vals.extend(value_cache[cache_key])
            for j in range(len(first['choices'])):
                tpl_slots = [sl for sl in slots if sl['in'] == f'choices[{j}]']
                text = member['choices'][j]['text']
                cache_key = ('choice', j, text)
                if cache_key not in value_cache:
                    value_cache[cache_key] = _fill(text, first['choices'][j]['text'], tpl_slots, members)
                vals.extend(value_cache[cache_key])
            # Verify every text, not just the first reference sample.
            def fill(tpl):
                return re.sub(r'\{(\d+)\}', lambda m: vals[int(m[1])], tpl)
            for seg, original in zip(content, member['content']):
                if seg['type'] != 'image':
                    assert tokens(fill(seg['template'])) == tokens(original['text']), (address, member['id'], 'content')
            for choice, original in zip(choices, member['choices']):
                assert tokens(fill(choice['template'])) == tokens(original['text']), (address, member['id'], 'choice')
            return vals + [json.dumps(sorted(member['vocabulary']), ensure_ascii=False, separators=(',', ':')), member['evidenceItem']]
        instances = [values_of(m) for m in members]
        frames.append({
            'id': address + '#' + hashlib.sha256(json.dumps(key, ensure_ascii=False).encode()).hexdigest()[:16],
            'card': address,
            'interaction': interaction,
            'dimension': dimension,
            'skills': list(skills),
            'prompt': first['prompt'],
            'help': first['help'],
            'content': content,
            'choices': choices,
            'slots': slots,
            'instances': len(members),
            'alignedPacked': pack_rows(instances),
            'variantMetadata': True,
            'samples': [
                {'content': ' '.join(s.get('text', '') for s in m['content']), 'choices': [c['text'] for c in m['choices']]}
                for m in members[:3]
            ],
            'ids': [m['id'] for m in members] if len(members) <= 3 else None,
        })
    os.makedirs(os.path.join(REPO, 'reference/frames'), exist_ok=True)
    for fr in frames:
        for sl in fr['slots']:
            sl.pop('_next', None)
    with open(os.path.join(REPO, f'reference/frames/{place}.json'), 'w', encoding='utf-8') as f:
        # Reference samples remain small; the complete lossless tuples live in
        # the executable asset, not twice in the repository.
        references = [{**{k: v for k, v in fr.items() if k not in ('alignedPacked', 'slots')},
                       'slots': [{'in': sl['in'], 'count': sl['count']} for sl in fr['slots']]} for fr in frames]
        json.dump(references, f, ensure_ascii=False, indent=1)
    # Métadonnées des cartes (nom, sous-titre, prix, prérequis, ordre).
    cards_meta = []
    for address, directory, card in cards(place):
        section = address.split('/')[1]
        lesson_path = os.path.join(directory, card.get('lesson', 'lesson.json'))
        lesson, examples = _clean_lesson(load(lesson_path)) if os.path.exists(lesson_path) else ([], [])
        cm = compiled['metadata'][address]
        lexical_order = cm['newVocabulary'] + [w for w in cm['vocabulary'] if w not in cm['newVocabulary']]
        examples = [compiled['lexicon'][w]['latin'] + ' — ' + compiled['lexicon'][w]['french'] for w in lexical_order]
        encounter = dict(card.get('encounter') or {})
        if address.endswith('/vocabula'):
            lesson = ['Vocābula nova huius sectiōnis tantum probantur. Vocābula sectiōnum priōrum hīc nōn repetuntur.']
            encounter['target'] = min(encounter.get('target', 10), len(cm['vocabulary']))
        cards_meta.append({
            'lesson': lesson,
            'examples': examples,
            'id': address, 'section': section, 'card': address.split('/')[2],
            'name': card.get('name'), 'subtitle': card.get('subtitle'),
            'price': (card.get('access') or {}).get('price', 0),
            'requires': (card.get('access') or {}).get('requires'),
            'skills': card.get('skills', []),
            'encounter': encounter,
            'questionSelection': card.get('questionSelection'),
            **cm,
        })
    sections = {}
    for sec_file in sorted(glob.glob(os.path.join(ROOT, place, 'sections', '*', 'section.json'))):
        sec = json.load(open(sec_file, encoding='utf-8'))
        sections[sec['id']] = {'name': sec.get('name'), 'subtitle': sec.get('subtitle'), 'children': [c['id'] for c in sec.get('children', [])]}
    place_file = os.path.join(ROOT, place, 'place.json')
    place_meta = json.load(open(place_file, encoding='utf-8')) if os.path.exists(place_file) else {}
    # Fiches d'aide référencées par les cadres (texte et exemples seulement).
    help_all = load(os.path.join(ROOT, '..', 'help.json.gz'))
    used = sorted({fr['help'] for fr in frames if fr.get('help')})
    help_path = os.path.join(REPO, 'assets/arbor/frames/help.json')
    existing = json.load(open(help_path, encoding='utf-8')) if os.path.exists(help_path) else {}
    for hid in used:
        blocks = help_all.get(hid)
        if blocks is not None:
            existing[hid] = [{'type': b['type'], 'text': _strip_echo(b['text'])} for b in blocks if b.get('type') in ('text', 'example')]
    for fr in frames:
        if fr['help'] and fr['help'].startswith('context.vocabula.'):
            existing[fr['help']] = [{'type': 'text', 'text': 'Vocābula nova huius sectiōnis redde. Verbum quaesītum et significātiō eius infra explicantur.'}]
        elif fr['help'] and fr['help'].startswith('expansion.'):
            existing[fr['help']] = [{'type': 'text', 'text': fr['choices'][0]['outcome']['feedback']}]
    os.makedirs(os.path.dirname(help_path), exist_ok=True)
    with open(help_path, 'w', encoding='utf-8') as f:
        json.dump(existing, f, ensure_ascii=False, separators=(',', ':'), sort_keys=True)
    with open(os.path.join(REPO, f'reference/frames/{place}.cards.json'), 'w', encoding='utf-8') as f:
        json.dump({'place': {k: place_meta.get(k) for k in ('id', 'name', 'subtitle', 'children')}, 'sections': sections, 'cards': cards_meta}, f, ensure_ascii=False, indent=1)
    with open(os.path.join(REPO, 'reference/frames/lexicon.json'), 'w', encoding='utf-8') as f:
        json.dump(compiled['lexicon'], f, ensure_ascii=False, indent=1)
    with open(os.path.join(REPO, 'reference/frames/coverage.json'), 'w', encoding='utf-8') as f:
        json.dump(compiled['summary'], f, ensure_ascii=False, indent=1)
    # Asset embarqué : les cadres sans échantillons ni identifiants bruts.
    os.makedirs(os.path.join(REPO, 'assets/arbor/frames'), exist_ok=True)
    asset = []
    for fr in frames:
        a = {k: v for k, v in fr.items() if k not in ('samples', 'ids')}
        a['slots'] = [{'in': sl['in'], 'count': sl['count']} for sl in fr['slots']]
        asset.append(a)
    with open(os.path.join(REPO, f'assets/arbor/frames/{place}.json'), 'w', encoding='utf-8') as f:
        json.dump({'place': place, 'frames': asset}, f, ensure_ascii=False, separators=(',', ':'))
    vocab = [f for f in frames if f['card'].endswith('/vocabula')]
    sentences = [f for f in frames if not f['card'].endswith('/vocabula')]
    print(f'{place}: {len(frames)} cadres ({len(sentences)} phrases, {len(vocab)} vocabulaire), '
          f'{sum(f["instances"] for f in frames)} questions; emplacements par cadre de phrase: '
          f'{collections.Counter(len(f["slots"]) for f in sentences).most_common(8)}')


if __name__ == '__main__':
    for place in sys.argv[1:] or ['theatrum', 'templum']:
        main(place)
