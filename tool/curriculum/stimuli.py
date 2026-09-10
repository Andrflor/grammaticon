"""Independently chosen diagnostic phrases, not cosmetic scenario permutations."""
import copy
import re

LEXICON = '''
ingenium|ingenium|naturel
summus|summus|suprême
constantia|cōnstantia|constance
'''

QUALITY_VARIANTS = [
    ('ingenium', {
        'magnae virtūtis': 'bonī ingeniī', 'magnam virtūtem': 'bonum ingenium',
        'magna virtūs': 'bonum ingenium',
        'd’un grand courage': 'd’un bon naturel', 'sans courage': 'd’un mauvais naturel',
    }, {'magnus': 'bonus', 'virtus': 'ingenium'}),
    ('sapientia', {
        'magnae virtūtis': 'summae sapientiae', 'magnam virtūtem': 'summam sapientiam',
        'magna virtūs': 'summa sapientia',
        'd’un grand courage': 'd’une très grande sagesse', 'sans courage': 'sans sagesse',
    }, {'magnus': 'summus', 'virtus': 'sapientia'}),
    ('constantia', {
        'magnae virtūtis': 'magnae cōnstantiae', 'magnam virtūtem': 'magnam cōnstantiam',
        'magna virtūs': 'magna cōnstantia',
        'd’un grand courage': 'd’une grande constance', 'sans courage': 'sans constance',
    }, {'virtus': 'constantia'}),
]


def expand(frames):
    result = []
    for source in frames:
        result.append(source)
        if source['id'] not in ['quality-courage', 'quality-genitive']: continue
        for suffix, replacements, vocabulary in QUALITY_VARIANTS:
            frame = copy.deepcopy(source)
            def rewrite(text):
                for before, after in replacements.items():
                    text = re.sub(re.escape(before), lambda match: after[0].upper() + after[1:] if match[0][0].isupper() else after,
                                  text, flags=re.IGNORECASE)
                return text
            for key in ['latin', 'french', 'correct', 'explanation']:
                if key in frame: frame[key] = rewrite(frame[key])
            frame['wrong'] = [rewrite(w) for w in frame['wrong']]
            frame['vocabulary'] = [vocabulary.get(w, w) for w in frame['vocabulary']]
            frame['id'] += '-' + suffix
            result.append(frame)
    return result
