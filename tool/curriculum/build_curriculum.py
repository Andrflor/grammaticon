#!/usr/bin/env python3
"""Materialize independent authored curriculum batches; safe to rerun deterministically.

This is one editorial batch, not a claim of a completed Latin curriculum.
All learner-facing questions, choices and attributions are persisted as JSON.
"""
import copy
from collections import defaultdict, Counter
import hashlib
import itertools
import json
from pathlib import Path
import re
import sys
from types import SimpleNamespace
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from question_banks import read, write, write_indexed
from cases import ACTORS, PLACES
import cases
import subordination
import stimuli
import extra_cases
import extra_subordination
import comparison
import pronouns
import numerals
import conditions
import subjunctive
import nonfinite
import reported_speech
import verb_meaning
from foods import FOODS, FRENCH as FOOD_FRENCH
from animals import ANIMALS
from objects import OBJECTS
from dependencies import prerequisites
from evidence import evidence_item
from people import PEOPLE, forms as human_forms
LEXICON = cases.LEXICON + subordination.LEXICON + stimuli.LEXICON + extra_cases.LEXICON + extra_subordination.LEXICON + comparison.LEXICON + pronouns.LEXICON + numerals.LEXICON + conditions.LEXICON + subjunctive.LEXICON + nonfinite.LEXICON + reported_speech.LEXICON + verb_meaning.LEXICON
FRAMES = stimuli.expand(cases.FRAMES + subordination.FRAMES) + extra_cases.FRAMES + extra_subordination.FRAMES + comparison.FRAMES + pronouns.FRAMES + numerals.FRAMES + conditions.FRAMES + subjunctive.FRAMES + nonfinite.FRAMES + reported_speech.FRAMES + verb_meaning.FRAMES

ROOT = Path(__file__).resolve().parents[2]
D = ROOT / 'assets/designs/grammaticon'
NOUNS = {n['id']: n for n in read(ROOT / 'tool/corpus/out/nouns_export.json')['nouns']}
for key, nom, gen, decl, french in PEOPLE:
    NOUNS[key] = {'id': key, 'lemma': nom, 'forms': human_forms(nom, gen, decl)}
LEX = {}
for place in ['theatrum', 'templum']:
    for path in (D / 'places' / place).glob('sections/*/cards/vocabula/questions.json'):
        for q in read(path):
            correct = next(c['text'] for c in q['choices'] if c['id'] in q['accepted'])
            latin, french = (q['content'][0]['text'], correct) if place == 'theatrum' else (correct, q['content'][0]['text'])
            LEX.setdefault(q['item'], (latin, french))
for line in LEXICON.strip().splitlines():
    if not line.strip(): continue
    key, latin, french = line.split('|')
    LEX[key] = (latin, french)


def french_plural(phrase):
    overrides = {'l’homme': 'hommes', 'le jeune homme': 'jeunes hommes',
                 'le fils': 'fils', 'le vieillard': 'vieillards'}
    if phrase in overrides: return overrides[phrase]
    base = re.sub(r'^(le |la |l’)', '', phrase)
    return base if base.endswith('s') else base + 's'


def noun(key, french):
    record = NOUNS[key]
    forms = {}
    for form in record['forms']:
        forms.setdefault(form['sel'], form['s'])
    result = {'id': key, 'fr': french, 'frbare': re.sub(r'^(le |la |l’)', '', french), 'frpl': french_plural(french),
              'to': ('au ' + french[3:]) if french.startswith('le ') else 'à ' + french}
    for case in ['nom', 'acc', 'gen', 'dat', 'abl']:
        result[case] = forms[case + '.sg']
        result[case + 'pl'] = forms[case + '.pl']
    LEX[key] = (record['lemma'], re.sub(r'^(le |la |l’)', '', french))
    return SimpleNamespace(**result)

ACTOR_POOL = [noun(k, v) for k, v in ACTORS.items()]
PLACE_POOL = [noun(k, v) for k, v in PLACES.items()]
PROFESSION_POOL = [noun(key, french) for key, _, _, _, french in PEOPLE]



def comparison_object(line):
    key, nom, gender, french, french_gender = line.split('|')
    result = dict(id=key, nom=nom, fr=french,
                  article='la' if french_gender == 'f' else 'le')
    ending = {'m': 'us', 'f': 'a', 'n': 'um'}[gender]
    for adjective, common, neuter, stem, masculine, feminine in comparison.REGULAR:
        result[adjective + '_comp'] = neuter if gender == 'n' else common
        result[adjective + '_super'] = stem + ending
        result[adjective + '_positive'] = (adjective[:-2] + ending if adjective == 'longus'
            else adjective[:-2] + 'e' if gender == 'n' else adjective)
        result[adjective + '_fr'] = feminine if french_gender == 'f' else masculine
    reverse = dict(bonus='malus', malus='bonus', magnus='parvus', parvus='magnus')
    for adjective, common, neuter, masculine, feminine in comparison.IRREGULAR:
        result[adjective + '_comp'] = neuter if gender == 'n' else common
        result[adjective + '_positive'] = adjective[:-2] + ending
        result[adjective + '_super'] = dict(bonus='optim', malus='pessim', magnus='maxim', parvus='minim')[adjective] + ending
        result[adjective + '_fr'] = feminine if french_gender == 'f' else masculine
    for adjective, opposite in reverse.items():
        result[adjective + '_reverse_comp'] = result[opposite + '_comp']
        result[adjective + '_reverse_fr'] = result[opposite + '_fr']
    LEX[key] = (nom, re.sub(r'^(le |la |l’)', '', french))
    return SimpleNamespace(**result)


OBJECT_POOL = [comparison_object(line) for line in OBJECTS.strip().splitlines()]



def counted_animal(line):
    key, nom, gender, acc, accpl, frgender, french, french_plural = line.split('|')
    if gender not in ['m', 'f'] or frgender not in ['m', 'f']:
        raise ValueError('Animal gender must be authored: ' + key)
    ending = 'am' if gender == 'f' else 'um'
    plural_ending = 'ās' if gender == 'f' else 'ōs'
    article = 'la' if frgender == 'f' else 'le'
    result = dict(id=key, nom=nom, acc=acc, accpl=accpl, fr=french,
                  frpl=french_plural, frarticle=article,
                  same='eandem' if gender == 'f' else 'eundem')
    for number, cardinal, ordinal, distributive, adverb, frnumber, rank in numerals.NUMBERS:
        singular = number == 'unus'
        latin_count = cardinal + ending if singular else cardinal + plural_ending if number == 'duo' else cardinal
        fr_count = ('une' if frgender == 'f' else 'un') if singular else frnumber
        fr_noun = french if singular else french_plural
        result[number + '_counted'] = latin_count + ' ' + (acc if singular else accpl)
        result[number + '_ranked'] = ordinal + ending + ' ' + acc
        result[number + '_distributed'] = distributive + plural_ending + ' ' + accpl
        result[number + '_frcount'] = fr_count + ' ' + fr_noun
        french_rank = 'première' if singular and frgender == 'f' else rank
        result[number + '_frrank'] = article + ' ' + french_rank + ' ' + french
        distinct = 'distinct' + ('e' if frgender == 'f' else '') + ('' if singular else 's')
        result[number + '_frdistinct'] = fr_count + ' ' + fr_noun + ' ' + distinct
    LEX[key] = (nom, french)
    return SimpleNamespace(**result)


ANIMAL_POOL = [counted_animal(line) for line in ANIMALS.strip().splitlines()]



def food(line):
    key, nom, acc, gloss = line.split('|')
    LEX[key] = (nom, gloss)
    return SimpleNamespace(id=key, nom=nom, acc=acc, fr=FOOD_FRENCH[key])


FOOD_POOL = [food(line) for line in FOODS.strip().splitlines()]


def sentence_case(text):
    return re.sub(r'(^|[.!?] )([a-zà-ÿāēīōū])', lambda m: m[1] + m[2].upper(), text)


def instantiate(frame):
    raw = json.dumps(frame, ensure_ascii=False)
    slots = [s for s in ['a', 'b', 'l', 'o', 'n', 'f'] if '{' + s + '.' in raw]
    actors = PROFESSION_POOL if frame.get('actorPool') == 'artifices' else ACTOR_POOL
    pools = [PLACE_POOL if s == 'l' else OBJECT_POOL if s == 'o' else ANIMAL_POOL if s == 'n' else FOOD_POOL if s == 'f' else actors for s in slots]
    combinations = []
    for combination in itertools.product(*pools):
        env = dict(zip(slots, combination))
        if 'a' in env and 'b' in env and env['a'].id == env['b'].id: continue
        # Do not claim a boy is older than an old man or a father younger than
        # his son. Those roles add factual constraints unrelated to the case.
        if '.case-uses.' in frame['skill'] and frame['card'] in ['10', '13'] and any(v.id in {'puer', 'iuvenis', 'senex', 'filius', 'pater'} for v in combination): continue
        combinations.append(combination)
    if frame.get('maxVariants'):
        combinations.sort(key=lambda values: hashlib.sha256(
            ('|'.join([frame['id']] + [v.id for v in values])).encode()).digest())
        combinations = combinations[:frame['maxVariants']]
        for slot, pool in [('o', OBJECT_POOL), ('n', ANIMAL_POOL), ('f', FOOD_POOL)]:
            if slot in slots:
                represented = {values[slots.index(slot)].id for values in combinations}
                if represented != {obj.id for obj in pool}:
                    raise ValueError('Variant cap omitted authored vocabulary: ' + frame['id'])
    for combination in combinations:
        env = dict(zip(slots, combination))
        render = lambda s: s.format(**env)
        latin = sentence_case(render(frame['latin']))
        correct = render(frame['correct'])
        wrong = list(dict.fromkeys(render(w) for w in frame['wrong']))
        wrong = [w for w in wrong if w != correct]
        if not wrong: raise ValueError('No contrasting answer: ' + frame['id'])
        words = set(frame['vocabulary']) | {v.id for v in combination}
        if frame['id'] == 'duration-accusative': words.add('secundus')
        missing = words - LEX.keys()
        if missing: raise ValueError(f'Missing authored gloss: {missing}')
        identity = '|'.join([frame['id']] + [env[s].id for s in slots])
        qid = 'casus-' + hashlib.sha256(identity.encode()).hexdigest()[:20]
        content = [{'type': 'text', 'text': latin}]
        if frame['place'] == 'templum':
            before, after = latin.split('___')
            content = [
                {'type': 'text', 'text': sentence_case(render(frame['french']))},
                {'type': 'text', 'text': '\n' + before},
                {'type': 'gap', 'text': '…'}, {'type': 'text', 'text': after},
            ]
        else:
            correct, wrong = sentence_case(correct), [sentence_case(w) for w in wrong]
        explanation = render(frame['explanation'])
        assessed = frame.get('assessedSkills', [frame['skill']] + frame.get('additionalSkills', []))
        failures = frame.get('wrongSkills', [[frame['skill']] for _ in frame['wrong']])
        failure_by_text = {render(text): failed for text, failed in zip(frame['wrong'], failures)}
        if frame['place'] == 'theatrum':
            failure_by_text = {sentence_case(text): failed for text, failed in failure_by_text.items()}
        if any(not failed or not set(failed) <= set(assessed) for failed in failures):
            raise ValueError('Invalid authored fine-skill attribution: ' + frame['id'])
        mode = 'lectio' if frame['place'] == 'theatrum' else 'compositio'
        yield {
            'id': qid, 'interaction': 'choice' if mode == 'lectio' else 'gapChoice',
            'dimension': 'course.reading' if mode == 'lectio' else 'course.production',
            'prompt': 'Sententiārum sēnsum Gallicē redde.' if mode == 'lectio' else 'Sententiam Latīnē complē.',
            'content': content,
            'choices': [{'id': str(i), 'text': t} for i, t in enumerate([correct] + wrong)],
            'accepted': ['0'], 'skills': assessed,
            'item': identity, 'evidenceItem': evidence_item(frame, env),
            'selectionGroup': frame['id'],
            'assessment': frame['skill'] + ':' + identity,
            'requires': sorted(set(prerequisites(frame['skill'])) | set(frame.get('supportingSkills', [])) | {'lexicon.' + mode + '.' + w for w in words}),
            'vocabulary': sorted(words), 'help': 'curriculum.' + frame['id'],
            'outcomes': {str(i): {
                'feedback': ('Rēctē. ' if i == 0 else 'Nōn rēctē. ') + explanation,
                'observed': [] if i == 0 else failure_by_text[wrong[i - 1]], 'hypotheses': [], 'practice': [],
            } for i in range(len(wrong) + 1)},
            'editorial': {'task': frame['task'], 'frame': frame['id'],
                'authorship': 'original-controlled-composition',
                'translationDirection': 'la-fr' if mode == 'lectio' else 'fr-la',
                'bindings': {s: env[s].id for s in slots}},
        }


def main():
    if len({frame['id'] for frame in FRAMES}) != len(FRAMES):
        raise ValueError('Authored frame identifiers must be globally unique')
    knowledge = read(D / 'knowledge.json.gz')
    nodes = {n['id']: n for n in knowledge['nodes']}
    for definition in numerals.SKILLS + conditions.SKILLS + subjunctive.SKILLS + nonfinite.SKILLS + reported_speech.SKILLS + verb_meaning.SKILLS:
        nodes[definition['id']] = definition
    composed_objectives = defaultdict(set)
    for frame in FRAMES:
        if 'assessedSkills' in frame:
            composed_objectives[frame['skill']].update(frame['assessedSkills'])
    for objective, components in composed_objectives.items():
        nodes[objective]['aggregation'] = {'skills': sorted(components), 'level': 'minimum'}
    help_entries = read(D / 'help.json.gz')
    for frame in FRAMES:
        required = prerequisites(frame['skill'])
        for ref in required + frame.get('supportingSkills', []):
            if ref not in nodes: raise ValueError('Missing fine prerequisite: ' + ref)
        nodes[frame['skill']]['requires'] = required
    sections = defaultdict(list)
    for f in FRAMES: sections[(f['place'], f['section'])].append(f)
    summary = {}
    asset_dirs = set()
    for (place, sid), frames in sections.items():
        mode = 'lectio' if place == 'theatrum' else 'compositio'
        path = D / 'places' / place / 'sections' / sid
        all_words, total, frame_counts = set(), 0, {}
        order = ([4, 1, 3, 11, 10, 13, 2, 5, 6, 8, 7, 9, 12] if mode == 'lectio'
                 else [4, 5, 6, 8, 7, 9, 1, 3, 11, 12, 2, 10, 13])
        groups = defaultdict(list)
        for frame in frames: groups[frame['card']].append(frame)
        children = []
        previous = None
        if sid not in ['casuum-sensus', 'casuum-electio']:
            order = list(groups)
        for number in order:
            cid = str(number)
            card_frames = groups[cid]
            directory = path / 'cards' / cid
            card = copy.deepcopy(read(D / 'places' / place / 'sections/loca/cards/a-ablative/card.json'))
            aggregate = f'curriculum.{mode}.{sid}.{cid}'
            card.update(id=cid, name=card_frames[0]['name'], subtitle=frames[0]['sectionName'],
                        skills=[aggregate], questions='questions.json.gz')
            card['access'] = {'price': 20, 'requires': {'all': [
                *([] if previous is None else [{'mastered': previous}]),
                *[{'skill': {'id': ref, 'minLevel': 2}} for ref in sorted({
                    ref for frame in card_frames for ref in prerequisites(frame['skill']) + frame.get('supportingSkills', [])
                })],
            ]}}
            card['encounter']['target'] = 8
            card['questionSelection'] = 'adaptive'
            card['shuffleChoices'] = True
            card['presentation']['longText'] = True
            bank = []
            for frame in card_frames:
                new = list(instantiate(frame)); bank.extend(new)
                frame_counts[frame['id']] = len(new)
                if not new: raise ValueError('Empty authored frame: ' + frame['id'])
                help_entries['curriculum.' + frame['id']] = [{'type': 'text', 'text': new[0]['outcomes']['0']['feedback']}]
            if len({q['id'] for q in bank}) != len(bank): raise ValueError('Duplicate question ID')
            for q in bank: all_words.update(q['vocabulary'])
            write_indexed(directory, bank)
            write(directory / 'card.json', card)
            write(directory / 'lesson.json', [
                {'type': 'text', 'text': help_entries['curriculum.' + f['id']][0]['text']} for f in card_frames
            ] + [{'type': 'text', 'text': 'Vocābula in extrēmā parte sectiōnis probantur.'}])
            nodes[aggregate] = {'id': aggregate, 'name': card['name'], 'visible': True,
                'parent': 'study.versio' if mode == 'lectio' else 'study.thema',
                'aggregation': {'skills': sorted({skill for q in bank for skill in q['skills']}), 'level': 'minimum'}}
            children.append({'kind': 'card', 'id': cid})
            previous = f'{place}/{sid}/{cid}'
            asset_dirs.add(str(directory.relative_to(ROOT)) + '/')
            total += len(bank)
        # Word translations are shared evidence across sections; directions are
        # independent, and both leaves exist even if first encountered in one.
        for word in all_words:
            for direction in ['lectio', 'compositio']:
                key = f'lexicon.{direction}.{word}'
                nodes.setdefault(key, {'id': key, 'name': ('Intellegere: ' if direction == 'lectio' else 'Latīnē reddere: ') + LEX[word][0],
                    'visible': False, 'masteryRequirements': {'minItems': 1, 'successfulItems': [word]}})
        directory = path / 'cards/vocabula'
        card = copy.deepcopy(read(D / 'places' / place / 'sections/loca/cards/vocabula/card.json'))
        aggregate = f'curriculum.{mode}.{sid}.vocabula'
        card['skills'] = [aggregate]
        card['access'] = {'price': 25, 'requires': {'all': [{'mastered': f'{place}/{sid}/{c["id"]}'} for c in children]}}
        card['questions'] = 'questions.json'
        bank = []
        sorted_words = sorted(all_words)
        for index, word in enumerate(sorted_words):
            source, answer = LEX[word] if mode == 'lectio' else LEX[word][::-1]
            wrong = []
            for other in sorted_words[index + 1:] + sorted_words[:index]:
                # An equivalent French gloss must never become a supposedly
                # wrong Latin answer (for example is/hic or quin/quominus).
                if LEX[other][1] == LEX[word][1]: continue
                candidate = LEX[other][1 if mode == 'lectio' else 0]
                if candidate != answer and candidate not in wrong: wrong.append(candidate)
                if len(wrong) == 2: break
            skill = f'lexicon.{mode}.{word}'
            bank.append({'id': 'verbum-' + word, 'interaction': 'choice',
                'dimension': 'course.reading' if mode == 'lectio' else 'course.production',
                'prompt': 'Vocābulum Gallicē redde.' if mode == 'lectio' else 'Vocābulum Latīnē redde.',
                'content': [{'type': 'text', 'text': source}],
                'choices': [{'id': str(i), 'text': t} for i, t in enumerate([answer] + wrong)],
                'accepted': ['0'], 'skills': [skill], 'item': word, 'assessment': skill,
                'help': 'curriculum.vocabula', 'vocabulary': [word],
                'outcomes': {str(i): {'feedback': LEX[word][0] + ' — ' + LEX[word][1],
                    'observed': [] if i == 0 else [skill], 'hypotheses': [], 'practice': []} for i in range(3)}})
        nodes[aggregate] = {'id': aggregate, 'name': 'Vocābula: ' + frames[0]['sectionName'], 'visible': True,
            'parent': 'study.lexicon', 'aggregation': {'skills': [q['skills'][0] for q in bank], 'level': 'minimum'}}
        nodes['study.lexicon']['aggregation']['skills'] = sorted(set(nodes['study.lexicon']['aggregation']['skills']) | {aggregate})
        write(directory / 'card.json', card); write(directory / 'questions.json', bank)
        write(directory / 'lesson.json', [{'type': 'text', 'text': 'Vocābula huius sectiōnis singillātim redde. Utraque via suam perītiam habet.'}])
        children.append({'kind': 'card', 'id': 'vocabula'})
        write(path / 'section.json', {'id': sid, 'name': frames[0]['sectionName'], 'children': children})
        manifest_path = D / 'places' / place / 'place.json'
        manifest = read(manifest_path)
        if not any(c['id'] == sid for c in manifest['children']): manifest['children'].append({'kind': 'section', 'id': sid})
        write(manifest_path, manifest)
        asset_dirs.update([str(path.relative_to(ROOT)) + '/', str(directory.relative_to(ROOT)) + '/'])
        summary[place + '/' + sid] = {'section': sid, 'sentenceQuestions': total, 'vocabularyQuestions': len(bank),
                          'frames': frame_counts, 'words': sorted_words}
    help_entries['curriculum.vocabula'] = [{'type': 'text', 'text': 'Vocābulum singulum redde. Perītia huius vocābulī ex hīs responsīs aestimātur.'}]
    knowledge['nodes'] = list(nodes.values())
    write(D / 'knowledge.json.gz', knowledge); write(D / 'help.json.gz', help_entries)
    write(ROOT / 'doc/pedagogy/skills/curriculum-build.json', {'status': 'partial-editorial-batch', 'places': summary})
    pubspec = ROOT / 'pubspec.yaml'; content = pubspec.read_text()
    missing = [p for p in sorted(asset_dirs) if '    - ' + p + '\n' not in content]
    content = content.replace('  assets:\n', '  assets:\n' + ''.join('    - ' + p + '\n' for p in missing))
    pubspec.write_text(content)
    print(json.dumps({p: {k: v for k, v in s.items() if k != 'words'} for p, s in summary.items()}, ensure_ascii=False, indent=2))

if __name__ == '__main__': main()
