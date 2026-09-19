"""Assemble the complete legacy banks, new situations and first-introduction lexicon.

The original question banks are immutable inputs. This stage never samples a
bank. Vocabulary finals are derived from first occurrence in curriculum order,
independently for reading and production, with explicit translations only.
"""
from collections import defaultdict
from functools import lru_cache
import json
from pathlib import Path
import re
import sys

from common import REPO, ROOT, cards, load, raw_questions, text

sys.path.insert(0, str(Path(REPO) / 'tool/curriculum'))
import context_expansion
from context_vocabulary import INTRODUCTIONS, DISPLAY

# Orthographic/allomorphic identity, not inferred synonymy.
ALIASES = {'a': 'ab', 'ne-question': 'ne-question'}

# Without a disambiguating sentence these broad/overlapping glosses must not
# be set against one another as supposedly exclusive lexical answers.
OVERLAPPING = [
    {'is', 'hic', 'ille', 'iste'}, {'qui', 'quis', 'quid'},
    {'amicus', 'amica'}, {'puer', 'infans', 'liberi'}, {'femina', 'mulier'},
    {'video', 'specto', 'intueor', 'observo'}, {'audio', 'ausculto'},
    {'dico', 'aio', 'loquor'}, {'narro', 'memoro'}, {'sum', 'adsum'},
    {'sonus', 'strepitus', 'vox', 'clamor'}, {'lux', 'lumen'},
    {'stella', 'astrum', 'sidus'}, {'cibus', 'esca'}, {'donum', 'munus'},
    {'via', 'iter', 'semita'}, {'navis', 'ratis'}, {'ignis', 'flamma'},
    {'creta', 'calx-lapis'}, {'saxum', 'lapis', 'rupes'},
]


def gloss_words(gloss):
    return set(re.findall(r'[a-zà-ÿ]+', gloss.lower())) - {
        'un', 'une', 'le', 'la', 'les', 'du', 'des', 'de', 'en', 'à', 'au', 'aux',
        'se', 's', 'l', 'd', 'par', 'pour', 'avec', 'dans', 'et', 'ou', 'ne', 'pas',
    }


def canonical(word, section):
    word = word.lower()
    if word == 'ne' and section == 'interrogationes': return 'ne-question'
    return ALIASES.get(word, word)


def canonical_question(q, section, texts=None):
    words = {canonical(w, section) for w in q.get('vocabulary', [])}
    if 'hic' in words:
        texts = texts or {}
        surface = ' '.join(text(s.get('text'), texts) for s in q.get('content', []))
        surface += ' ' + ' '.join(text(c['text'], texts) for c in q['choices'] if c['id'] in q['accepted'])
        if re.search(r'\bhīc\b', surface, re.IGNORECASE):
            words.add('hic-adv')
            if not re.search(r'\b(hic|haec|hoc|huius|huic|hunc|hanc|hōc|hāc|hōs|hās|hīs)\b', surface, re.IGNORECASE):
                words.remove('hic')
    return {**q, 'vocabulary': sorted(words)}


def pos(latin, french):
    if latin.endswith(('āre', 'ēre', 'ere', 'īre', 'ārī', 'ērī')) or french.startswith(('se ', 's’', 'être ', 'il ')):
        return 'verb'
    if ', -' in latin or latin.endswith(('us, -a, -um', 'is, -e')): return 'adjective'
    return 'word'


@lru_cache(maxsize=1)
def prepared():
    lexicon = {}
    for place in ['theatrum', 'templum']:
        for address, directory, card in cards(place):
            if not address.endswith('/vocabula'): continue
            for q, texts in raw_questions(directory, card):
                accepted = next(text(c['text'], texts) for c in q['choices'] if c['id'] in q['accepted'])
                surface = text(q['content'][0]['text'], texts)
                latin, french = (surface, accepted) if place == 'theatrum' else (accepted, surface)
                word = canonical(q['item'], address.split('/')[1])
                lexicon.setdefault(word, (latin, french))
    expansions = context_expansion.banks()
    lexicon.update(context_expansion.LEXICON)
    # Preserve polysemy of an existing lemma instead of inventing a second
    # "new word" when a later situation introduces a related sense.
    lexicon['sententia'] = ('sententia', 'phrase ; avis, décision')
    lexicon['ne-question'] = ('-ne', 'particule de question neutre')
    lexicon['hic-adv'] = ('hīc', 'ici')
    result = assemble(lexicon, expansions)
    for _ in range(3):
        if all(len(m['newVocabulary']) >= 5 for a, m in result['metadata'].items() if not a.endswith('/vocabula')):
            break
        add_introductions(lexicon, expansions, result['metadata'])
        result = assemble(lexicon, expansions)
    assert all(len(m['newVocabulary']) >= 5 for a, m in result['metadata'].items() if not a.endswith('/vocabula'))
    return result


def assemble(lexicon, expansions):
    vocabulary, metadata, first = {}, {}, defaultdict(dict)
    summary = {'places': {}}
    for place in ['theatrum', 'templum']:
        by_id = {address: (directory, card) for address, directory, card in cards(place)}
        manifest = load(f'{ROOT}/{place}/place.json')
        seen = set()
        sections = []
        for child in manifest['children']:
            sid = child['id']
            section = load(f'{ROOT}/{place}/sections/{sid}/section.json')
            section_words = set()
            sentence_cards = []
            for child_card in section['children']:
                cid = child_card['id']
                if cid == 'vocabula': continue
                address = f'{place}/{sid}/{cid}'
                directory, card = by_id[address]
                words = set()
                count = 0
                for q, texts in raw_questions(directory, card):
                    words.update(canonical_question(q, sid, texts)['vocabulary'])
                    count += 1
                for q in expansions.get(address, []):
                    words.update(q['vocabulary'])
                    count += 1
                if count < 200: raise ValueError(f'Fewer than 200 questions: {address}: {count}')
                missing = words - lexicon.keys()
                if missing: raise ValueError(f'No authored translation for {address}: {sorted(missing)}')
                new = sorted(words - seen)
                for w in new: first[w][place] = address
                seen.update(words)
                section_words.update(words)
                metadata[address] = {'vocabulary': sorted(words), 'newVocabulary': new,
                                     'sentenceQuestions': count}
                sentence_cards.append({'card': cid, 'questions': count, 'newVocabulary': new, 'vocabulary': sorted(words)})
            new_words = sorted(w for w in section_words if first[w][place].split('/')[1] == sid)
            if not new_words: raise ValueError(f'No new vocabulary in section {place}/{sid}')
            address = f'{place}/{sid}/vocabula'
            bank = []
            for word in new_words:
                latin, french = lexicon[word]
                category = pos(latin, french)
                # Plausible choices from this section, preferring the same kind
                # of word; equal translations are never marked incorrect.
                candidates = sorted(section_words - {word}, key=lambda w: (
                    pos(*lexicon[w]) != category, w not in new_words,
                    abs(len(lexicon[w][0]) - len(latin)), w))
                wrong = []
                for w in candidates:
                    la, fr = lexicon[w]
                    if any(word in group and w in group for group in OVERLAPPING): continue
                    if la == latin or fr == french or la in [lexicon[x][0] for x in wrong] or fr in [lexicon[x][1] for x in wrong]: continue
                    if set(fr.split(' ; ')) & set(french.split(' ; ')): continue
                    if gloss_words(fr) & gloss_words(french): continue
                    wrong.append(w)
                    if len(wrong) == 3: break
                if len(wrong) < 2: raise ValueError(f'Insufficient distinct lexical distractors: {address}/{word}')
                chosen = [word] + wrong
                source, answer = (latin, french) if place == 'theatrum' else (french, latin)
                skill = f'lexicon.{"lectio" if place == "theatrum" else "compositio"}.{word}'
                bank.append({'id': word, 'interaction': 'choice', 'dimension': 'lemma',
                    'item': word, 'assessment': skill, 'evidenceItem': word, 'skills': [skill],
                    'prompt': 'Vocābulum novum Gallicē redde.' if place == 'theatrum' else 'Vocābulum novum Latīnē redde.',
                    'content': [{'type': 'text', 'text': source}],
                    'choices': [{'id': str(i), 'text': lexicon[w][1 if place == 'theatrum' else 0], 'lexeme': w} for i, w in enumerate(chosen)],
                    'accepted': ['0'], 'vocabulary': [word], 'help': 'context.vocabula.' + place + '.' + sid,
                    'outcomes': {str(i): {'feedback': f'{latin} — {french}.' + ('' if i == 0 else f' Le choix proposé correspond à {lexicon[w][0]} — {lexicon[w][1]}.'),
                        'observed': [] if i == 0 else [skill], 'hypotheses': [], 'practice': []} for i, w in enumerate(chosen)}})
            vocabulary[address] = bank
            metadata[address] = {'vocabulary': new_words, 'newVocabulary': new_words}
            sections.append({'section': sid, 'cards': sentence_cards, 'vocabulary': new_words})
        summary['places'][place] = sections
    used = {w for entry in metadata.values() for w in entry['vocabulary']}
    records = {w: {'latin': lexicon[w][0], 'french': lexicon[w][1], 'introduced': first[w]} for w in sorted(used)}
    return {'lexicon': records, 'vocabulary': vocabulary, 'metadata': metadata,
            'expansions': expansions, 'summary': summary}


def add_introductions(lexicon, expansions, metadata):
    """Five genuinely new lexical IDs per sentence card, in both directions.

    A small number of explicit introductions accompanies existing diagnostic
    questions. It never supplies the 200-question floor, already checked by the
    first assembly, nor extra grammar-evidence identities.
    """
    aliases = dict(zip(
        'casuum-sensus nexus-sententiarum res-comparatae referentiae-pronominum numerorum-sensus condiciones-interpretandae voluntas-et-consilium formae-non-finitae oratio-obliqua verbis-intellegendis'.split(),
        'casuum-electio sententiae-subordinatae gradus-adiectivorum pronomina-eligenda numeris-exprimere condiciones-componendae voluntatem-exprimere formis-non-finitis orationem-referre verbis-utendis'.split()))
    used = set(lexicon)
    # Avoid reintroducing an inflected/headword spelling of an existing item.
    used_surfaces = {context_expansion.identifier(la.split(',')[0]) for la, _ in lexicon.values()}
    candidates = []
    for line in INTRODUCTIONS.strip().splitlines():
        lemma, presentation = line.split('|')
        key = context_expansion.identifier(lemma)
        shown = DISPLAY.get(key, lemma)
        normalized = context_expansion.identifier(shown)
        if key in used or normalized in used_surfaces: continue
        used.add(key)
        used_surfaces.add(normalized)
        candidates.append((key, shown, presentation))
    iterator = iter(candidates)
    manifests = {address: (directory, card) for p in ['theatrum', 'templum'] for address, directory, card in cards(p)}
    for address, m in metadata.items():
        if not address.startswith('theatrum/') or address.endswith('/vocabula'): continue
        _, section, cid = address.split('/')
        counterpart = f'templum/{aliases.get(section, section)}/{cid}'
        needed = max(0, 5 - min(len(m['newVocabulary']), len(metadata[counterpart]['newVocabulary'])))
        for _ in range(needed):
            try: word, latin, presentation = next(iterator)
            except StopIteration: raise ValueError(f'Authored lexical introductions exhausted at {address}') from None
            gloss = re.sub(r'^(un |une |des |du |de la |de l’)', '', presentation)
            lexicon[word] = (latin, gloss)
            la_intro = f'Hīc {"sunt" if presentation.startswith("des ") else "est"} {latin}.'
            fr_intro = f'Voici {presentation}.'
            for destination in [address, counterpart]:
                reading = destination.startswith('theatrum/')
                directory, card = manifests[destination]
                # The original authored question remains intact after the
                # clearly separate introduction; no noun substitution or guessed
                # agreement changes its diagnostics.
                raw, texts = next(raw_questions(directory, card))
                from common import flatten
                q = flatten(canonical_question(raw, section, texts), texts)
                original_evidence = q['evidenceItem']
                q['id'] = 'intro-' + word + '-' + q['id']
                q['item'] = word
                q['evidenceItem'] = original_evidence
                q['selectionGroup'] = 'intro-' + word
                q['vocabulary'] = sorted(set(q['vocabulary']) | {word, 'hic-adv', 'sum'})
                q['content'].insert(0, {'type': 'text', 'text': (la_intro if reading else fr_intro) + '\n'})
                if reading:
                    for c in q['choices']: c['text'] = fr_intro + ' ' + c['text']
                elif q['interaction'] == 'gapChoice':
                    # Show the Latin introduction as part of the fixed text;
                    # choices still fill the original gap only.
                    q['content'].insert(1, {'type': 'text', 'text': la_intro + '\n'})
                else:
                    for c in q['choices']: c['text'] = la_intro + ' ' + c['text']
                expansions.setdefault(destination, []).append(q)


if __name__ == '__main__':
    result = prepared()
    for place, sections in result['summary']['places'].items():
        print(place, sum(c['questions'] for s in sections for c in s['cards']), 'sentence questions')
        for s in sections:
            print(s['section'], 'new vocabulary:', len(s['vocabulary']), 'per card:', [len(c['newVocabulary']) for c in s['cards']])
