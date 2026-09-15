"""Regroupe les questions Theatrum/Templum en cadres et infère les emplacements variables.

Un cadre = même carte, même interaction, mêmes explications pour chaque issue, même
squelette de phrase (même nombre de mots par segment et par proposition). À l'intérieur
d'un cadre, les positions dont le mot change d'une instanciation à l'autre sont des
emplacements ; l'ensemble des valeurs observées à chaque emplacement est conservé.

Sortie : reference/frames/<lieu>.json — liste de cadres, jamais de questions générées.
"""
import collections
import json
import re
import sys

import glob
import os

from common import REPO, ROOT, cards, flatten, questions

TOKEN = re.compile(r"[^\s]+")


def tokens(s):
    return TOKEN.findall(s)


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


def main(place):
    groups = collections.defaultdict(list)
    for address, directory, card in cards(place):
        for q, texts in questions(directory, card):
            flat = flatten(q, texts)
            feedback = tuple(sorted(o['feedback'] for o in flat['outcomes'].values()))
            accepted = tuple(sorted(
                i for i, c in enumerate(flat['choices']) if c['id'] in flat['accepted']))
            key = (address, flat['interaction'], flat['dimension'], feedback, skeleton(flat), accepted, tuple(flat['skills']))
            groups[key].append(flat)
    frames = []
    for n, (key, members) in enumerate(sorted(groups.items(), key=lambda kv: (kv[0][0], -len(kv[1])))):
        address, interaction, dimension, feedback, _, accepted, skills = key
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
            })
        # Instanciations alignées : pour chaque instance, la valeur de chaque
        # emplacement dans l'ordre des emplacements (24 au plus, régulièrement
        # espacées), pour régénérer des phrases cohérentes.
        def values_of(member):
            vals = []
            for seg_i, seg in enumerate(first['content']):
                if seg['type'] == 'image':
                    continue
                tpl_slots = [sl for sl in slots if sl['in'] == f'content[{seg_i}]']
                vals.extend(_fill(member['content'][seg_i]['text'], first['content'][seg_i]['text'], tpl_slots, members))
            for j in range(len(first['choices'])):
                tpl_slots = [sl for sl in slots if sl['in'] == f'choices[{j}]']
                vals.extend(_fill(member['choices'][j]['text'], first['choices'][j]['text'], tpl_slots, members))
            return vals
        step = max(1, len(members) // 24)
        instances = [values_of(m) for m in members[::step][:24]]
        frames.append({
            'id': f'{address}#{n}',
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
            'aligned': instances,
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
        json.dump(frames, f, ensure_ascii=False, indent=1)
    # Métadonnées des cartes (nom, sous-titre, prix, prérequis, ordre).
    cards_meta = []
    for address, directory, card in cards(place):
        section = address.split('/')[1]
        cards_meta.append({
            'id': address, 'section': section, 'card': address.split('/')[2],
            'name': card.get('name'), 'subtitle': card.get('subtitle'),
            'price': (card.get('access') or {}).get('price', 0),
            'requires': (card.get('access') or {}).get('requires'),
            'skills': card.get('skills', []),
            'encounter': card.get('encounter'),
            'questionSelection': card.get('questionSelection'),
        })
    sections = {}
    for sec_file in sorted(glob.glob(os.path.join(ROOT, place, 'sections', '*', 'section.json'))):
        sec = json.load(open(sec_file, encoding='utf-8'))
        sections[sec['id']] = {'name': sec.get('name'), 'subtitle': sec.get('subtitle'), 'children': [c['id'] for c in sec.get('children', [])]}
    place_file = os.path.join(ROOT, place, 'place.json')
    place_meta = json.load(open(place_file, encoding='utf-8')) if os.path.exists(place_file) else {}
    with open(os.path.join(REPO, f'reference/frames/{place}.cards.json'), 'w', encoding='utf-8') as f:
        json.dump({'place': {k: place_meta.get(k) for k in ('id', 'name', 'subtitle', 'children')}, 'sections': sections, 'cards': cards_meta}, f, ensure_ascii=False, indent=1)
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
