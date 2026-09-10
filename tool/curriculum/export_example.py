#!/usr/bin/env python3
"""Extract reviewable examples from the currently materialized runtime JSON."""
import json
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from question_banks import read, questions
ROOT = Path(__file__).resolve().parents[2]
D = ROOT / 'assets/designs/grammaticon'
registry = {n['id']: n for n in read(D / 'knowledge.json.gz')['nodes']}
examples = []
for place, section, word, card_id, prefix in [
    ('theatrum', 'verbis-intellegendis', 'servus', '3', 'lectio-verba-3-miseret'),
    ('templum', 'verbis-utendis', 'mendacium', '3', 'compositio-verba-3-pudet-cause'),
    ('theatrum', 'oratio-obliqua', 'meus', '5', 'lectio-oratio-5-doctor-possession'),
    ('templum', 'orationem-referre', 'ne', '3', 'compositio-oratio-3-gateTrue|'),
    ('theatrum', 'formae-non-finitae', 'liber', '3', 'lectio-nonfinitum-3-libri-genitivus|'),
    ('templum', 'formis-non-finitis', 'donum', '2', 'compositio-nonfinitum-2-donum-plural|'),
    ('theatrum', 'voluntas-et-consilium', None, '2', 'lectio-voluntas-2-servo-praeterita|'),
    ('templum', 'voluntatem-exprimere', None, '5', 'compositio-voluntas-5-servo|'),
    ('theatrum', 'condiciones-interpretandae', 'si', '4', 'lectio-condicio-4-doctrina|'),
    ('templum', 'condiciones-componendae', 'si', '3', 'compositio-condicio-3-auxilium|'),
    ('theatrum', 'numerorum-sensus', 'bini', '3', 'lectio-numerus-3-duo|'),
    ('templum', 'numeris-exprimere', 'bis', '4', 'compositio-numerus-4-duo|'),
    ('theatrum', 'referentiae-pronominum', 'quis', '2', 'lectio-pronomen-quis-subject|'),
    ('templum', 'pronomina-eligenda', 'idem', '4', 'compositio-pronomen-eundem|'),
    ('theatrum', 'res-comparatae', 'calceus', '1', 'lectio-comparatio-1-longus|'),
    ('templum', 'gradus-adiectivorum', 'calceus', '1', 'compositio-comparatio-1-longus|'),
    ('theatrum', 'casuum-sensus', 'donum', '4', ''),
    ('templum', 'casuum-electio', 'liber', '4', ''),
    ('templum', 'sententiae-subordinatae', 'auxilium', '8', 'produce-purpose-plural|'),
]:
    directory = D / 'places' / place / 'sections' / section / 'cards' / card_id
    card = read(directory / 'card.json')
    q = next(q for q in questions(directory / card['questions']) if q['item'].startswith(prefix))
    if word is None: word = q['editorial']['bindings']['f']
    vocabulary = next(q for q in read(directory.parent / 'vocabula/questions.json') if q['item'] == word)
    examples.append({'cardPath': str(directory / 'card.json'), 'card': card,
        'composition': registry[card['skills'][0]], 'question': q,
        'assessedSkills': [registry[skill] for skill in q['skills']], 'vocabularyQuestion': vocabulary,
        'vocabularySkill': registry[vocabulary['skills'][0]]})
(ROOT / 'doc/pedagogy/skills/example-unified.json').write_text(json.dumps({
    'source': 'Extracted from the actual runtime JSON, not a proposed schema',
    'revision': read(D / 'game.json')['revision'], 'examples': examples,
}, ensure_ascii=False, indent=2) + '\n')
