#!/usr/bin/env python3
"""Validate actual question-to-skill evidence and report coverage without inventing it."""
import argparse
from collections import Counter, defaultdict
import gzip
import json
from pathlib import Path
from question_banks import questions
ROOT = Path(__file__).resolve().parents[1]
D = ROOT / 'assets/designs/grammaticon'

def read(path):
    return json.load(gzip.open(path, 'rt')) if path.suffix == '.gz' else json.loads(path.read_text())

def audit():
    knowledge = {n['id']: n for n in read(D / 'knowledge.json.gz')['nodes']}
    errors = []
    def leaves(sid, stack=()):
        if sid not in knowledge:
            errors.append('Unknown skill: ' + sid); return set()
        if sid in stack:
            errors.append('Composition cycle: ' + sid); return set()
        n = knowledge[sid]
        if 'aggregation' not in n: return {sid}
        children = n['aggregation']['skills']
        if not children: errors.append('Empty composition: ' + sid)
        return set().union(*(leaves(c, stack + (sid,)) for c in children))
    report = {}
    vocabulary_by_mode = {}
    by_skill = defaultdict(list)
    for place, mode in [('theatrum', 'lectio'), ('templum', 'compositio')]:
        counts = Counter(); vocabulary = set(); assessed = set(); task_types = Counter()
        for section in sorted((D / 'places' / place / 'sections').iterdir()):
            manifest = read(section / 'section.json')
            if manifest['children'][-1]['id'] != 'vocabula': errors.append(f'{section}: vocabulary must be last')
            encountered = set(); tested_words = set()
            for child in manifest['children']:
                directory = section / 'cards' / child['id']; card = read(directory / 'card.json')
                address = f'{place}/{section.name}/{child["id"]}'
                bank = questions(directory / card['questions']); counts['cards'] += 1
                declared = set().union(*(leaves(s) for s in card['skills']))
                evaluated = set()
                for q in bank:
                    counts['questions'] += 1
                    task_types[q.get('editorial', {}).get('task', q['interaction'])] += 1
                    skills = set(q['skills']); evaluated.update(skills); assessed.update(skills)
                    if not skills or not skills <= declared: errors.append(f'{address}#{q["id"]}: invalid evaluated skills')
                    for sid in skills:
                        if sid not in knowledge or 'aggregation' in knowledge[sid]: errors.append(f'{address}: non-leaf assessment {sid}')
                        by_skill[sid].append({'card': address, 'question': q['id'], 'item': q.get('evidenceItem', q['item'])})
                    for ref in q.get('requires', []):
                        if ref not in knowledge: errors.append(f'{address}: unknown prerequisite {ref}')
                    if child['id'] == 'vocabula':
                        tested_words.add(q['item']); vocabulary.add(q['item'])
                        if skills != {f'lexicon.{mode}.{q["item"]}'}: errors.append(f'{address}: lexical evidence must be per word and direction')
                    else:
                        encountered.update(q.get('vocabulary', []))
                        if any(s.startswith('lexicon.') for s in skills): errors.append(f'{address}: vocabulary assessed outside vocabulary card')
                        if any(not s.startswith(mode + '.') for s in skills): errors.append(f'{address}: direction conflated')
                    for choice, outcome in q['outcomes'].items():
                        failed = set(outcome['observed'])
                        if choice not in q['accepted']:
                            counts['wrongChoices'] += 1
                            if not failed or not failed <= skills: errors.append(f'{address}#{q["id"]}: failure not attributed to evaluated leaves')
                        elif failed: errors.append(f'{address}: accepted choice marks failure')
                if declared != evaluated: errors.append(f'{address}: card contains unevaluated skills {sorted(declared-evaluated)}')
            if tested_words != encountered: errors.append(f'{place}/{section.name}: vocabulary mismatch {sorted(tested_words ^ encountered)}')
        vocabulary_by_mode[mode] = vocabulary
        report[place] = {**counts, 'assessedSkills': len(assessed), 'vocabulary': len(vocabulary), 'taskTypes': dict(task_types)}
    thin = {}
    for sid, references in by_skill.items():
        available = {r['item'] for r in references}
        minimum = knowledge[sid].get('masteryRequirements', {}).get('minItems', 4)
        if len(available) < minimum:
            thin[sid] = {'items': len(available), 'required': minimum}
    if thin: errors.append(f'{len(thin)} skills lack enough distinct items for mastery')
    curriculum = read(ROOT / 'doc/pedagogy/skills/curriculum.json')
    objectives = {sid for family in curriculum['families'] for objective in family['objectives']
                  for sid in objective['skills'].values()}
    # An objective may compose shared fine distinctions. Evidence is required
    # for every component, never for the aggregate itself.
    objective_leaves = {objective: leaves(objective) for objective in objectives}
    missing = sorted(objective for objective, components in objective_leaves.items()
                     if not components or not components <= set(by_skill))
    all_words = set().union(*vocabulary_by_mode.values())
    missing_directions = {mode: sorted(all_words - words) for mode, words in vocabulary_by_mode.items()}
    vocabulary_floor = curriculum['targetDistinctVocabularyPerPlace']
    lexical_complete = all(len(words) >= vocabulary_floor for words in vocabulary_by_mode.values()) and not any(missing_directions.values())
    return {'validationPassed': not errors, 'places': report, 'errors': errors, 'insufficientEvidence': thin,
            'questionIndex': dict(sorted(by_skill.items())),
            'scope': ['Familia Romana', 'Fabellae Latinae', 'Fabulae Syrae', 'Epitome Historiae Sacrae'],
            'coverageComplete': not errors and not missing and not thin and lexical_complete,
            'lexicalCoverage': {'workingFloorPerPlace': vocabulary_floor,
                'missingDirectionalEvidence': missing_directions, 'complete': lexical_complete},
            'unassessedCurriculumSkills': missing,
            'coverageNote': 'Conceptual and lexical breadth are evaluated separately from question count. Structural validity does not certify breadth; source books are scope guidelines.'}

if __name__ == '__main__':
    parser = argparse.ArgumentParser(); parser.add_argument('--write', action='store_true'); args = parser.parse_args()
    result = audit()
    if args.write:
        (ROOT / 'doc/pedagogy/skills/coverage.json').write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({k:v for k,v in result.items() if k != 'questionIndex'}, ensure_ascii=False, indent=2))
    raise SystemExit(not result['validationPassed'])
