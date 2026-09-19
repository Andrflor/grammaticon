"""Controlled, bilingual situations for the context cards with tiny banks.

Forms and French verb principal parts are editorial data. Morphological rules
below only inflect those declared paradigms. Every distractor expresses a named
contrast, with a correction; changing scenery never changes the evidence item.
The existing large authored banks remain the primary corpus.
"""
from dataclasses import dataclass
from collections import defaultdict
from functools import lru_cache
import hashlib
import itertools
import re
import unicodedata

LEXICON = {}


def identifier(s):
    return ''.join(c for c in unicodedata.normalize('NFD', s.lower()) if not unicodedata.combining(c))


def cap(s):
    return s[0].upper() + s[1:]


def de(s):
    if s.startswith('le '): return 'du ' + s[3:]
    if s.startswith('les '): return 'des ' + s[4:]
    return 'de ' + s


def to(s):
    if s.startswith('le '): return 'au ' + s[3:]
    if s.startswith('les '): return 'aux ' + s[4:]
    return 'à ' + s


@dataclass(frozen=True)
class Noun:
    id: str
    nom: str
    gen: str
    gender: str
    fr: str
    frpl: str
    fg: str

    def form(self, case='nom', plural=False):
        if not plural and case == 'nom': return self.nom
        if not plural and case == 'voc' and self.id == 'filius': return 'fīlī'
        if self.gen.endswith('ae'):
            root = self.gen[:-2]
            ends = ['ae', 'ās', 'ārum', 'īs', 'īs', 'ae'] if plural else ['a', 'am', 'ae', 'ae', 'ā', 'a']
        elif self.gen.endswith('ī'):
            root = self.gen[:-1]
            ends = ['ī', 'ōs', 'ōrum', 'īs', 'īs', 'ī'] if plural else ['us', 'um', 'ī', 'ō', 'ō', 'e']
            if self.gender == 'n':
                ends[0] = ends[1] = ends[5] = 'a' if plural else 'um'
            elif not plural and case == 'voc' and not self.nom.endswith('us'):
                return self.nom
        else:
            root = self.gen[:-2]
            ends = ['ēs', 'ēs', 'um', 'ibus', 'ibus', 'ēs'] if plural else ['', 'em', 'is', 'ī', 'e', '']
            if self.gender == 'n':
                if case in ['nom', 'acc', 'voc']:
                    return root + ('ia' if self.nom.endswith(('e', 'al', 'ar')) else 'a') if plural else self.nom
                if self.nom.endswith(('e', 'al', 'ar')):
                    if case == 'abl' and not plural: return root + 'ī'
                    if case == 'gen' and plural: return root + 'ium'
            elif not plural and case == 'voc': return self.nom
            if plural and case == 'gen' and self.id in {'clavis', 'funis', 'vestis'}:
                return root + 'ium'
        return root + ends[['nom', 'acc', 'gen', 'dat', 'abl', 'voc'].index(case)]

    def french(self, plural=False):
        return self.frpl if plural else self.fr


def nouns(text):
    out = []
    for line in text.strip().splitlines():
        nom, gen, gender, fr, frpl, fg = line.split('|')
        n = Noun(identifier(nom), nom, gen, gender, fr, frpl, fg)
        LEXICON[n.id] = (nom, re.sub(r'^(le |la |les |l’)', '', fr))
        out.append(n)
    return out


PEOPLE = nouns('''
discipulus|discipulī|m|l’élève|les élèves|m
magister|magistrī|m|le maître|les maîtres|m
nauta|nautae|m|le marin|les marins|m
agricola|agricolae|m|l’agriculteur|les agriculteurs|m
servus|servī|m|l’esclave|les esclaves|m
medicus|medicī|m|le médecin|les médecins|m
amīcus|amīcī|m|l’ami|les amis|m
vīcīnus|vīcīnī|m|le voisin|les voisins|m
puer|puerī|m|le garçon|les garçons|m
fīlius|fīliī|m|le fils|les fils|m
dominus|dominī|m|le maître de maison|les maîtres de maison|m
hortulānus|hortulānī|m|le jardinier|les jardiniers|m
''')

THIRD_PEOPLE = nouns('''
mercātor|mercātōris|m|le marchand|les marchands|m
pāstor|pāstōris|m|le berger|les bergers|m
vēnātor|vēnātōris|m|le chasseur|les chasseurs|m
piscātor|piscātōris|m|le pêcheur|les pêcheurs|m
viātor|viātōris|m|le voyageur|les voyageurs|m
ōrātor|ōrātōris|m|l’orateur|les orateurs|m
senātor|senātōris|m|le sénateur|les sénateurs|m
imperātor|imperātōris|m|le commandant|les commandants|m
gladiātor|gladiātōris|m|le gladiateur|les gladiateurs|m
cantor|cantōris|m|le chanteur|les chanteurs|m
victor|victōris|m|le vainqueur|les vainqueurs|m
scrīptor|scrīptōris|m|l’écrivain|les écrivains|m
''')

PLACES = nouns('''
ātrium|ātriī|n|l’atrium|les atriums|m
balneum|balneī|n|le bain|les bains|m
trīclīnium|trīclīniī|n|la salle à manger|les salles à manger|f
tabulārium|tabulāriī|n|le dépôt d’archives|les dépôts d’archives|m
praedium|praediī|n|le domaine|les domaines|m
horreum|horreī|n|le grenier|les greniers|m
officīna|officīnae|f|l’atelier|les ateliers|m
culīna|culīnae|f|la cuisine|les cuisines|f
bibliothēca|bibliothēcae|f|la bibliothèque|les bibliothèques|f
taberna|tabernae|f|la boutique|les boutiques|f
fabrica|fabricae|f|la forge|les forges|f
cella|cellae|f|la réserve|les réserves|f
''')

OBJECTS = nouns('''
saccus|saccī|m|le sac|les sacs|m
calamus|calamī|m|le roseau|les roseaux|m
stilus|stilī|m|le stylet|les stylets|m
ānulus|ānulī|m|l’anneau|les anneaux|m
fībula|fībulae|f|la broche|les broches|f
armilla|armillae|f|le bracelet|les bracelets|m
capsa|capsae|f|la boîte|les boîtes|f
charta|chartae|f|la feuille de papyrus|les feuilles de papyrus|f
signum|signī|n|la statue|les statues|f
speculum|speculī|n|le miroir|les miroirs|m
linteum|linteī|n|le linge|les linges|m
strāgulum|strāgulī|n|la couverture|les couvertures|f
''')


@dataclass(frozen=True)
class Verb:
    id: str
    inf: str
    cls: str
    perfect: str
    supine: str
    frinf: str
    present: str
    plural: str
    imperfect: str
    past: str
    future: str
    imperative: str
    imperative_pl: str
    participle: str

    @property
    def root(self): return self.inf[:-3]

    def form(self, tense='present', plural=False, passive=False):
        c, r = self.cls, self.root
        if tense in ['perfect', 'pluperfect']:
            return self.perfect + ({'perfect': ('it', 'ērunt'), 'pluperfect': ('erat', 'erant')}[tense][plural])
        if tense == 'imperative':
            return r + {'1': ('ā', 'āte'), '2': ('ē', 'ēte'), '3': ('e', 'ite'), '4': ('ī', 'īte')}[c][plural]
        endings = {
            'present': {'1': ('at', 'ant'), '2': ('et', 'ent'), '3': ('it', 'unt'), '4': ('t', 'unt')},
            'imperfect': {'1': ('ābat', 'ābant'), '2': ('ēbat', 'ēbant'), '3': ('ēbat', 'ēbant'), '4': ('ēbat', 'ēbant')},
            'future': {'1': ('ābit', 'ābunt'), '2': ('ēbit', 'ēbunt'), '3': ('et', 'ent'), '4': ('et', 'ent')},
            'subjunctive': {'1': ('et', 'ent'), '2': ('eat', 'eant'), '3': ('at', 'ant'), '4': ('at', 'ant')},
        }
        # Fourth-conjugation roots retain -i- (audi-, custodi-), except long ī
        # before the singular present passive ending.
        if c == '4': r += 'i'
        ending = endings[tense][c][plural]
        if passive:
            if not plural:
                ending = {
                    'present': {'1': 'ātur', '2': 'ētur', '3': 'itur', '4': 'ītur'},
                    'imperfect': {'1': 'ābātur', '2': 'ēbātur', '3': 'ēbātur', '4': 'iēbātur'},
                    'future': {'1': 'ābitur', '2': 'ēbitur', '3': 'ētur', '4': 'iētur'},
                    'subjunctive': {'1': 'ētur', '2': 'eātur', '3': 'ātur', '4': 'iātur'},
                }[tense][c]
                return self.root + ending
            return r + ending + 'ur'
        return r + ending

    def french(self, tense='present', plural=False):
        return self.plural if plural and tense == 'present' else getattr(self, {'perfect': 'past', 'pluperfect': 'past'}.get(tense, tense))

    def gerund(self, ending):
        base = self.root + {'1': 'and', '2': 'end', '3': 'end', '4': 'iend'}[self.cls]
        return base + ending


def verbs(text):
    out = []
    for line in text.strip().splitlines():
        fields = line.split('|')
        inf = fields[0]
        canonical = dict(zip(
            'portare aperire claudere legere scribere pingere lavare terere parare quaerere emere vendere servare figere spargere secare mutare iungere purgare condere texere coquere ornare mensurare laborare festinare exsultare cenare dormire tacere sedere vigilare ambulare saltare certare clamare'.split(),
            'porto aperio claudo lego scribo pingo lavo tero paro quaero emo vendo servo figo spargo seco muto iungo purgo condo texo coquo orno mensuro laboro festino exsulto ceno dormio taceo sedeo vigilo ambulo salto certo clamo'.split()))
        v = Verb(canonical[identifier(inf)], *fields)
        LEXICON[v.id] = (inf, v.frinf)
        out.append(v)
    return out


def participle_fr(v, obj, plural=False):
    first, *rest = v.participle.split(' ')
    if obj.fg == 'f': first += 'e'
    if plural and not first.endswith('s'): first += 's'
    return ' '.join([first, *rest])


# Infinitive, conjugation, perfect stem, supine, then authored French forms.
VERBS = verbs('''
portāre|1|portāv|portātum|porter|porte|portent|portait|a porté|portera|porte|portez|porté
aperīre|4|aperu|apertum|ouvrir|ouvre|ouvrent|ouvrait|a ouvert|ouvrira|ouvre|ouvrez|ouvert
claudere|3|claus|clausum|fermer|ferme|ferment|fermait|a fermé|fermera|ferme|fermez|fermé
legere|3|lēg|lēctum|lire|lit|lisent|lisait|a lu|lira|lis|lisez|lu
scrībere|3|scrīps|scrīptum|écrire|écrit|écrivent|écrivait|a écrit|écrira|écris|écrivez|écrit
pingere|3|pīnx|pictum|peindre|peint|peignent|peignait|a peint|peindra|peins|peignez|peint
lavāre|1|lāv|lautum|laver|lave|lavent|lavait|a lavé|lavera|lave|lavez|lavé
terere|3|trīv|trītum|broyer|broie|broient|broyait|a broyé|broiera|broie|broyez|broyé
parāre|1|parāv|parātum|préparer|prépare|préparent|préparait|a préparé|préparera|prépare|préparez|préparé
quaerere|3|quaesīv|quaesītum|chercher|cherche|cherchent|cherchait|a cherché|cherchera|cherche|cherchez|cherché
emere|3|ēm|ēmptum|acheter|achète|achètent|achetait|a acheté|achètera|achète|achetez|acheté
vēndere|3|vēndid|vēnditum|vendre|vend|vendent|vendait|a vendu|vendra|vends|vendez|vendu
servāre|1|servāv|servātum|conserver|conserve|conservent|conservait|a conservé|conservera|conserve|conservez|conservé
fīgere|3|fīx|fīxum|fixer|fixe|fixent|fixait|a fixé|fixera|fixe|fixez|fixé
spargere|3|spars|sparsum|répandre|répand|répandent|répandait|a répandu|répandra|répands|répandez|répandu
secāre|1|secu|sectum|couper|coupe|coupent|coupait|a coupé|coupera|coupe|coupez|coupé
mūtāre|1|mūtāv|mūtātum|changer|change|changent|changeait|a changé|changera|change|changez|changé
iungere|3|iūnx|iūnctum|joindre|joint|joignent|joignait|a joint|joindra|joins|joignez|joint
pūrgāre|1|pūrgāv|pūrgātum|nettoyer|nettoie|nettoient|nettoyait|a nettoyé|nettoiera|nettoie|nettoyez|nettoyé
condere|3|condid|conditum|mettre à l’abri|met à l’abri|mettent à l’abri|mettait à l’abri|a mis à l’abri|mettra à l’abri|mets à l’abri|mettez à l’abri|mis à l’abri
texere|3|texu|textum|tisser|tisse|tissent|tissait|a tissé|tissera|tisse|tissez|tissé
coquere|3|cox|coctum|cuire|cuit|cuisent|cuisait|a cuit|cuira|cuis|cuisez|cuit
ōrnāre|1|ōrnāv|ōrnātum|décorer|décore|décorent|décorait|a décoré|décorera|décore|décorez|décoré
mēnsūrāre|1|mēnsūrāv|mēnsūrātum|mesurer|mesure|mesurent|mesurait|a mesuré|mesurera|mesure|mesurez|mesuré
''')

ACTION_OBJECTS = nouns('''
cophinus|cophinī|m|le panier|les paniers|m
valva|valvae|f|le battant de porte|les battants de porte|m
fenestra|fenestrae|f|la fenêtre|les fenêtres|f
epistula|epistulae|f|la lettre|les lettres|f
sententia|sententiae|f|la phrase|les phrases|f
tabula|tabulae|f|le tableau|les tableaux|m
tunica|tunicae|f|la tunique|les tuniques|f
frūmentum|frūmentī|n|le blé|les blés|m
cēna|cēnae|f|le dîner|les dîners|m
clāvis|clāvis|f|la clé|les clés|f
lūcerna|lūcernae|f|la lampe|les lampes|f
pallium|palliī|n|le manteau|les manteaux|m
pecūnia|pecūniae|f|l’argent|les sommes d’argent|m
clāvus|clāvī|m|le clou|les clous|m
harēna|harēnae|f|le sable|les sables|m
lignum|lignī|n|le bois|les bois|m
vestis|vestis|f|le vêtement|les vêtements|m
fūnis|fūnis|m|la corde|les cordes|f
cisterna|cisternae|f|la citerne|les citernes|f
grānum|grānī|n|le grain|les grains|m
tēla|tēlae|f|la toile|les toiles|f
holus|holeris|n|le légume|les légumes|m
pariēs|parietis|m|le mur intérieur|les murs intérieurs|m
ager|agrī|m|le champ|les champs|m
''')
ACTIONS = list(zip(VERBS, ACTION_OBJECTS))

STATES = verbs('''
labōrāre|1|labōrāv|labōrātum|travailler|travaille|travaillent|travaillait|a travaillé|travaillera|travaille|travaillez|travaillé
festīnāre|1|festīnāv|festīnātum|se hâter|se hâte|se hâtent|se hâtait|s’est hâté|se hâtera|hâte-toi|hâtez-vous|hâté
exsultāre|1|exsultāv|exsultātum|exulter|exulte|exultent|exultait|a exulté|exultera|exulte|exultez|exulté
cēnāre|1|cēnāv|cēnātum|dîner|dîne|dînent|dînait|a dîné|dînera|dîne|dînez|dîné
dormīre|4|dormīv|dormītum|dormir|dort|dorment|dormait|a dormi|dormira|dors|dormez|dormi
tacēre|2|tacu|tacitum|se taire|se tait|se taisent|se taisait|s’est tu|se taira|tais-toi|taisez-vous|tu
sedēre|2|sēd|sessum|être assis|est assis|sont assis|était assis|a été assis|sera assis|sois assis|soyez assis|assis
vigilāre|1|vigilāv|vigilātum|veiller|veille|veillent|veillait|a veillé|veillera|veille|veillez|veillé
ambulāre|1|ambulāv|ambulātum|marcher|marche|marchent|marchait|a marché|marchera|marche|marchez|marché
saltāre|1|saltāv|saltātum|danser|danse|dansent|dansait|a dansé|dansera|danse|dansez|dansé
certāre|1|certāv|certātum|rivaliser|rivalise|rivalisent|rivalisait|a rivalisé|rivalisera|rivalise|rivalisez|rivalisé
clāmāre|1|clāmāv|clāmātum|crier|crie|crient|criait|a crié|criera|crie|criez|crié
''')

for key, la, fr in [
    ('sum', 'esse', 'être'), ('in', 'in', 'dans, sur'), ('non', 'nōn', 'ne… pas'),
    ('et', 'et', 'et'), ('sed', 'sed', 'mais'), ('cum', 'cum', 'avec ; lorsque'),
    ('ad', 'ad', 'vers ; pour'), ('ab', 'ā, ab', 'par ; depuis'), ('ex', 'ex', 'hors de'),
    ('hic', 'hic, haec, hoc', 'ce…-ci, cette…-ci'), ('ille', 'ille, illa, illud', 'ce…-là, cette…-là'),
    ('is', 'is, ea, id', 'celui-ci, celle-ci ; il, elle'), ('suus', 'suus', 'son propre'),
    ('se', 'sē', 'soi'), ('meus', 'meus', 'mon'), ('qui', 'quī, quae, quod', 'qui, lequel'),
    ('dico', 'dīcere', 'dire'), ('do', 'dare', 'donner'), ('habeo', 'habēre', 'avoir'),
    ('venio', 'venīre', 'venir'), ('disco', 'discere', 'apprendre'), ('voco', 'vocāre', 'appeler'),
    ('cur', 'cūr', 'pourquoi'), ('quia', 'quia', 'parce que'), ('ne-question', '-ne', 'particule de question neutre'),
    ('num', 'num', 'est-ce que… ? (réponse négative attendue)'), ('nonne', 'nōnne', 'ne… pas ? (réponse affirmative attendue)'),
    ('ut', 'ut', 'pour que ; que'), ('ne', 'nē', 'pour que ne… pas ; que ne… pas'),
    ('causa', 'causā', 'pour, en vue de (avec le génitif)'), ('cupido', 'cupidō', 'désir'),
    ('antequam', 'antequam', 'avant que'), ('postquam', 'postquam', 'après que'),
    ('sine', 'sine', 'sans'), ('adsum', 'adesse', 'être présent'),
    ('eo', 'īre', 'aller'), ('redeo', 'redīre', 'revenir'), ('habito', 'habitāre', 'habiter'),
    ('magnus', 'magnus', 'grand'), ('parvus', 'parvus', 'petit'),
    ('maneo', 'manēre', 'rester'), ('curro', 'currere', 'courir'),
    ('iam', 'iam', 'déjà'), ('tum', 'tum', 'alors'), ('disciplīna', 'disciplīna', 'apprentissage'),
    ('finio', 'fīnīre', 'achever'), ('incipio', 'incipere', 'commencer'),
    ('advenio', 'advenīre', 'arriver'), ('cupidus', 'cupidus', 'désireux de'),
    ('impero', 'imperāre', 'ordonner'), ('rogo', 'rogāre', 'demander'),
    ('licet', 'licet', 'il est permis'), ('oportet', 'oportet', 'il faut'),
    ('audeo', 'audēre', 'oser'),
]: LEXICON[key] = (la, fr)


def pair(card, key, alternatives, words, explanation, errors, *, evidence=None, suspecta=None):
    """Each alternative is a Latin/French semantic pair, first one accepted.

    Reading distractors change the meaning; production distractors change the
    Latin expression. The explanation identifies the chosen contrast, rather
    than blaming every grammatical prerequisite.
    """
    assert len(alternatives) == len(errors) + 1
    words = sorted(set(words))
    missing = set(words) - LEXICON.keys()
    if missing: raise ValueError((card, missing))
    for place, direction, dimension in [('theatrum', 1, 'course.reading'), ('templum', 0, 'course.production')]:
        sid, cid = card.split('/')
        sid = {'oratio-obliqua': 'orationem-referre', 'verbis-intellegendis': 'verbis-utendis',
               'formae-non-finitae': 'formis-non-finitis', 'casuum-sensus': 'casuum-electio'}.get(sid, sid) if place == 'templum' else sid
        address = f'{place}/{sid}/{cid}'
        source = cap(alternatives[0][1 - direction])
        choices = [cap(a[direction]) for a in alternatives]
        if len(set(choices)) != len(choices): raise ValueError((address, choices))
        qid = 'context-' + hashlib.sha256((card + ':' + key).encode()).hexdigest()[:20]
        skill = f'context.{place}.{card.replace("/", ".")}'
        outcomes = {}
        for i, text in enumerate(choices):
            outcomes[str(i)] = {'feedback': explanation if i == 0 else errors[i - 1] + ' ' + explanation,
                               'observed': [] if i == 0 else [skill], 'hypotheses': [], 'practice': [],
                               'suspecta': [] if i == 0 or place == 'theatrum' or suspecta is None else suspecta[i - 1]}
        yield address, {'id': qid, 'interaction': 'choice', 'dimension': dimension,
                        'prompt': 'Sententiam Gallicē redde.' if place == 'theatrum' else 'Sententiam Latīnē redde.',
                        'content': [{'type': 'text', 'text': source}],
                        'choices': [{'id': str(i), 'text': text} for i, text in enumerate(choices)],
                        'accepted': ['0'], 'skills': [skill], 'item': qid,
                        'evidenceItem': card + ':' + (evidence or key),
                        'assessment': qid, 'selectionGroup': card + ':' + explanation,
                        'help': 'expansion.' + card.replace('/', '.'), 'vocabulary': words,
                        'outcomes': outcomes, 'editorial': {'authorship': 'controlled-bilingual-situations',
                                                          'translationDirection': 'la-fr' if direction else 'fr-la'}}


def clause(person, verb, obj, tense='present', plural=False):
    return (f'{person.form(plural=plural)} {obj.form("acc")} {verb.form(tense, plural)}.',
            f'{person.french(plural)} {verb.french(tense, plural)} {obj.fr}.')


def emit():
    # Location and number: entities and locations both vary, not answer order.
    for i, (entity, place) in enumerate(itertools.product(PEOPLE + OBJECTS, PLACES)):
        la = f'{entity.nom} in {place.form("abl")} est.'
        fr = f'{entity.fr} est dans {place.fr}.'
        alt = (f'{entity.nom} in {place.form("abl")} nōn est.', f'{entity.fr} n’est pas dans {place.fr}.')
        yield from pair('loca/a-ablative', str(i), [(la, fr), alt,
            (f'{place.nom} in {entity.form("abl")} est.', f'{place.fr} est dans {entity.fr}.')],
            [entity.id, place.id, 'sum', 'in', 'non'],
            'In avec l’ablatif indique le lieu où se trouve le sujet.',
            ['La phrase affirme la présence ; elle ne la nie pas.', 'Le lieu et ce qui s’y trouve ont été inversés.'], evidence=entity.id + ':' + place.id)
        plural = i % 2 == 0
        correct = (f'{entity.form(plural=plural)} in {place.form("abl")} {"sunt" if plural else "est"}.',
                   f'{entity.french(plural)} {"sont" if plural else "est"} dans {place.fr}.')
        other = (f'{entity.form(plural=not plural)} in {place.form("abl")} {"sunt" if not plural else "est"}.',
                 f'{entity.french(not plural)} {"sont" if not plural else "est"} dans {place.fr}.')
        yield from pair('loca/numerus', str(i), [correct, other], [entity.id, place.id, 'in', 'sum'],
                        'Le nombre du nom et celui du verbe doivent rendre le même nombre d’êtres ou de choses.',
                        ['Le singulier et le pluriel ont été intervertis.'], evidence=f'{entity.id}:{plural}')

    adjectives = [('altus', 'alt', 'haut', 'haute'), ('angustus', 'angust', 'étroit', 'étroite'),
                  ('latus', 'lāt', 'large', 'large'), ('novus', 'nov', 'neuf', 'neuve'),
                  ('antiquus', 'antīqu', 'ancien', 'ancienne'), ('mundus', 'mund', 'propre', 'propre'),
                  ('obscurus', 'obscūr', 'sombre', 'sombre'), ('clarus', 'clār', 'clair', 'claire'),
                  ('frigidus', 'frīgid', 'froid', 'froide'), ('calidus', 'calid', 'chaud', 'chaude')]
    for key, root, fm, ff in adjectives: LEXICON[key] = (root + 'us, -a, -um', fm + ' / ' + ff)
    for i, (obj, adj) in enumerate(itertools.product(PLACES + OBJECTS, adjectives)):
        key, root, fm, ff = adj
        ending = {'m': 'us', 'f': 'a', 'n': 'um'}[obj.gender]
        wrong = {'m': 'a', 'f': 'um', 'n': 'us'}[obj.gender]
        positive = (f'{obj.nom} {root + ending} est.', f'{obj.fr} est {ff if obj.fg == "f" else fm}.')
        # French distractor contrasts number; Latin one isolates agreement.
        negative = (f'{obj.nom} {root + wrong} est.', f'{obj.frpl} sont {ff + "s" if obj.fg == "f" else fm + ("" if fm.endswith("s") else "s")}.')
        yield from pair('loca/concordia', str(i), [positive, negative], [obj.id, key, 'sum'],
                        'L’adjectif se rapporte au nom et s’accorde avec lui ; le groupe est ici singulier.',
                        ['L’accord ou le nombre du groupe nominal n’est pas respecté.'], evidence=obj.id + ':' + key)

    for i, (person, verb, place) in enumerate(itertools.product(PEOPLE, [STATES[0], STATES[3], STATES[4], STATES[7]], PLACES[:6])):
        la, fr = f'{person.nom} in {place.form("abl")} {verb.form()}.', f'{person.fr} {verb.present} dans {place.fr}.'
        negative = (la.replace(verb.form() + '.', 'nōn ' + verb.form() + '.'), f'{person.fr} ne {verb.present} pas dans {place.fr}.')
        yield from pair('loca/negatio', str(i), [negative, (la, fr)], [person.id, verb.id, place.id, 'non', 'in'],
                        'Nōn nie l’action du verbe ; tous les autres participants restent les mêmes.',
                        ['La négation a été supprimée.'], evidence=verb.id + ':' + place.id)

    yield from people_cards()
    yield from demonstrative_cards()
    yield from question_cards()
    yield from command_cards()
    yield from passive_cards()
    yield from journey_cards()
    yield from time_cards()
    yield from infinitive_cards()
    yield from clause_cards()
    yield from gerund_cards()
    yield from advanced_cards()
    yield from quality_cards()


def people_cards():
    human_verbs = [
        ('saluto', 'salūtat', 'salue'), ('voco', 'vocat', 'appelle'),
        ('laudo', 'laudat', 'félicite'), ('video', 'videt', 'voit'),
        ('audio', 'audit', 'écoute'), ('exspecto', 'exspectat', 'attend'),
        ('adiuvo', 'adiuvat', 'aide'), ('invito', 'invītat', 'invite'),
    ]
    LEXICON.update({
        'saluto': ('salūtāre', 'saluer'), 'voco': ('vocāre', 'appeler'),
        'laudo': ('laudāre', 'louer, féliciter'), 'video': ('vidēre', 'voir'),
        'audio': ('audīre', 'entendre, écouter'), 'exspecto': ('exspectāre', 'attendre'),
        'adiuvo': ('adiuvāre', 'aider'), 'invito': ('invītāre', 'inviter'),
    })
    for card, subjects in [('personae/agents', PEOPLE), ('nomina/third-subject-object', THIRD_PEOPLE)]:
        for i, (a, b, v) in enumerate(itertools.product(subjects, PEOPLE[:6], human_verbs)):
            if a.id == b.id: continue
            key, la, fr = v
            yield from pair(card, str(i), [
                (f'{a.nom} {b.form("acc")} {la}.', f'{a.fr} {fr} {b.fr}.'),
                (f'{b.nom} {a.form("acc")} {la}.', f'{b.fr} {fr} {a.fr}.'),
            ], [a.id, b.id, key], 'Le nominatif désigne celui qui agit ; l’accusatif désigne la personne visée.',
                ['L’agent et la personne visée ont été inversés.'], evidence=f'{a.id}:{b.id}:{key}')
    for section, owners in [('personae', PEOPLE), ('nomina', THIRD_PEOPLE)]:
        for i, (a, obj, other) in enumerate(itertools.product(owners, OBJECTS, [False, True])):
            b = PEOPLE[(i + 3) % len(PEOPLE)]
            if a.id == b.id: b = PEOPLE[(i + 4) % len(PEOPLE)]
            card = 'possession' if section == 'personae' else 'third-genitive'
            yield from pair(f'{section}/{card}', str(i), [
                (f'{obj.nom} {a.form("gen")} in {PLACES[i % 12].form("abl")} est.', f'{obj.fr} {de(a.fr)} est dans {PLACES[i % 12].fr}.'),
                (f'{obj.nom} {b.form("gen")} in {PLACES[i % 12].form("abl")} est.', f'{obj.fr} {de(b.fr)} est dans {PLACES[i % 12].fr}.'),
            ], [a.id, b.id, obj.id, PLACES[i % 12].id, 'in', 'sum'],
                'Le nom au génitif identifie le propriétaire de l’objet.',
                ['Le propriétaire a été remplacé par une autre personne.'], evidence=f'{a.id}:{obj.id}')
            card = 'giving' if section == 'personae' else 'third-dative'
            yield from pair(f'{section}/{card}', str(i), [
                (f'{b.nom} {a.form("dat")} {obj.form("acc")} dat.', f'{b.fr} donne {obj.fr} {to(a.fr)}.'),
                (f'{a.nom} {b.form("dat")} {obj.form("acc")} dat.', f'{a.fr} donne {obj.fr} {to(b.fr)}.'),
            ], [a.id, b.id, obj.id, 'do'], 'Le datif désigne le destinataire ; le nominatif désigne celui qui donne.',
                ['Celui qui donne et celui qui reçoit ont été inversés.'], evidence=f'{a.id}:{b.id}:{obj.id}')
    for i, (a, b, verb) in enumerate(itertools.product(THIRD_PEOPLE, PEOPLE[:4], STATES[:6])):
        yield from pair('nomina/third-ablative', str(i), [
            (f'{b.nom} cum {a.form("abl")} {verb.form()}.', f'{b.fr} {verb.present} avec {a.fr}.'),
            (f'{b.nom} sine {a.form("abl")} {verb.form()}.', f'{b.fr} {verb.present} sans {a.fr}.'),
        ], [a.id, b.id, verb.id, 'cum', 'sine'], 'Cum suivi de l’ablatif exprime l’accompagnement ; sine exprime son absence.',
            ['L’accompagnement a été transformé en absence.'], evidence=f'{a.id}:{verb.id}')
    for i, (a, obj, verb) in enumerate(itertools.product(PEOPLE, OBJECTS, [VERBS[0], VERBS[12]])):
        b = PEOPLE[(PEOPLE.index(a) + (1 if verb.id == 'porto' else 2)) % 12]
        poss = {'m': 'suum', 'f': 'suam', 'n': 'suum'}[obj.gender]
        yield from pair('personae/reference', str(i), [
            (f'{a.nom} {b.form("acc")} vocat. {obj.form("acc")} {poss} {verb.form()}.',
             f'{a.fr} appelle {b.fr}, puis {verb.present} {obj.fr} qui lui appartient à lui, {a.fr}.'),
            (f'{a.nom} {b.form("acc")} vocat. {obj.form("acc")} eius {verb.form()}.',
             f'{a.fr} appelle {b.fr}, puis {verb.present} {obj.fr} qui appartient à l’autre personne.'),
        ], [a.id, b.id, obj.id, verb.id, 'suus', 'is', 'voco'],
            'Suus renvoie au sujet de la proposition ; eius renvoie ici à l’autre personne mentionnée.',
            ['Le possesseur réflexif a été remplacé par un possesseur extérieur.'], evidence=f'{obj.id}:{verb.id}')
        yield from pair('personae/relative-case-role', str(i), [
            (f'{a.nom}, quī {b.form("acc")} vocat, {obj.form("acc")} portat.',
             f'{a.fr}, qui appelle {b.fr}, porte {obj.fr}.'),
            (f'{a.nom}, quem {b.nom} vocat, {obj.form("acc")} portat.',
             f'{a.fr}, que {b.fr} appelle, porte {obj.fr}.'),
        ], [a.id, b.id, obj.id, 'qui', 'voco', 'porto'],
            'Quī est sujet du verbe de la relative ; quem en est l’objet.',
            ['Le sujet et l’objet de la proposition relative ont été intervertis.'], evidence=f'{a.id}:{b.id}')


def demonstrative_cards():
    treasures = nouns('''
gemma|gemmae|f|la pierre précieuse|les pierres précieuses|f
corōna|corōnae|f|la couronne|les couronnes|f
bulla|bullae|f|l’amulette|les amulettes|f
margarīta|margarītae|f|la perle|les perles|f
catēna|catēnae|f|la chaîne|les chaînes|f
spīnula|spīnulae|f|la petite épingle|les petites épingles|f
torques|torquis|m|le collier rigide|les colliers rigides|m
monīle|monīlis|n|le collier|les colliers|m
pendiculum|pendiculī|n|le pendentif|les pendentifs|m
sigillum|sigillī|n|la figurine|les figurines|f
crumēna|crumēnae|f|la bourse|les bourses|f
marsūpium|marsūpiī|n|le porte-monnaie|les porte-monnaie|m
''')
    adjectives = [('pulcher', {'m': 'pulcher', 'f': 'pulchra', 'n': 'pulchrum'}, 'beau', 'belle'),
                  ('pretiosus', {'m': 'pretiōsus', 'f': 'pretiōsa', 'n': 'pretiōsum'}, 'précieux', 'précieuse')]
    for key, forms, fm, ff in adjectives: LEXICON[key] = (forms['m'], fm + ' / ' + ff)
    for i, (obj, person, far) in enumerate(itertools.product(treasures, PEOPLE, [False, True])):
        g = obj.gender
        demonstrative = {'m': 'ille' if far else 'hic', 'f': 'illa' if far else 'haec', 'n': 'illud' if far else 'hoc'}[g]
        acc = {'m': 'illum' if far else 'hunc', 'f': 'illam' if far else 'hanc', 'n': 'illud' if far else 'hoc'}[g]
        other = {'m': 'hic' if far else 'ille', 'f': 'haec' if far else 'illa', 'n': 'hoc' if far else 'illud'}[g]
        otheracc = {'m': 'hunc' if far else 'illum', 'f': 'hanc' if far else 'illam', 'n': 'hoc' if far else 'illud'}[g]
        french = obj.fr + ('-là' if far else '-ci')
        otherfr = obj.fr + ('-ci' if far else '-là')
        key, forms, fm, ff = adjectives[i % 2]
        yield from pair('demonstratives/demonstrative-gender', str(i), [
            (f'{demonstrative} {obj.nom} {forms[g]} est. {person.nom} adest.', f'{french} est {ff if obj.fg == "f" else fm}. {person.fr} est présent.'),
            (f'{other} {obj.nom} {forms[g]} est. {person.nom} adest.', f'{otherfr} est {ff if obj.fg == "f" else fm}. {person.fr} est présent.'),
        ], [obj.id, person.id, key, 'hic', 'ille', 'sum', 'adsum'],
            'Hic, haec, hoc indiquent ici la proximité ; ille, illa, illud l’éloignement. Leur genre suit le nom latin.',
            ['Le démonstratif de proximité et celui d’éloignement ont été échangés.'], evidence=f'{obj.id}:{far}:{key}')
        yield from pair('demonstratives/demonstrative-accusative', str(i), [
            (f'{person.nom} {acc} {obj.form("acc")} portat.', f'{person.fr} porte {french}.'),
            (f'{person.nom} {otheracc} {obj.form("acc")} portat.', f'{person.fr} porte {otherfr}.'),
        ], [obj.id, person.id, 'hic', 'ille', 'porto'], 'Le démonstratif s’accorde avec l’objet à l’accusatif, en conservant la proximité indiquée.',
            ['La distance exprimée par le démonstratif a été changée.'], evidence=f'{obj.id}:{far}')
        yield from pair('demonstratives/demonstrative-genitive', str(i), [
            (f'{obj.nom} {"illīus" if far else "huius"} {person.form("gen")} est.', f'{obj.fr} appartient {to(person.fr)}' + ('-là.' if far else '-ci.')),
            (f'{obj.nom} {"huius" if far else "illīus"} {person.form("gen")} est.', f'{obj.fr} appartient {to(person.fr)}' + ('-ci.' if far else '-là.')),
        ], [obj.id, person.id, 'hic', 'ille', 'sum'], 'Huius et illīus sont des génitifs : ils accompagnent le possesseur au génitif.',
            ['Le possesseur proche et le possesseur éloigné ont été intervertis.'], evidence=f'{person.id}:{far}')
        giver = PEOPLE[(PEOPLE.index(person) + 1) % 12]
        yield from pair('demonstratives/demonstrative-dative', str(i), [
            (f'{giver.nom} {"illī" if far else "huic"} {person.form("dat")} {obj.form("acc")} dat.', f'{giver.fr} donne {obj.fr} {to(person.fr)}' + ('-là.' if far else '-ci.')),
            (f'{giver.nom} {"huic" if far else "illī"} {person.form("dat")} {obj.form("acc")} dat.', f'{giver.fr} donne {obj.fr} {to(person.fr)}' + ('-ci.' if far else '-là.')),
        ], [obj.id, person.id, giver.id, 'hic', 'ille', 'do'], 'Huic et illī sont des datifs : ils accompagnent le destinataire.',
            ['Le destinataire proche et le destinataire éloigné ont été intervertis.'], evidence=f'{person.id}:{far}')


def question_cards():
    for i, (a, verb, place) in enumerate(itertools.product(PEOPLE, STATES, PLACES[:2])):
        base = f'{a.nom} in {place.form("abl")} {verb.form()}'
        fr = f'{a.fr} {verb.present} dans {place.fr}'
        interrogative = f'{verb.form()}ne {a.nom} in {place.form("abl")}?'
        for card, latin, bias in [
            ('neutral-question', interrogative, 'sans réponse présupposée'),
            ('num-question', 'Num ' + base + '?', 'en attendant plutôt une réponse négative'),
            ('nonne-question', 'Nōnne ' + base + '?', 'en attendant plutôt une réponse affirmative'),
        ]:
            other = 'Nōnne ' + base + '?' if card != 'nonne-question' else 'Num ' + base + '?'
            otherbias = 'en attendant plutôt une réponse affirmative' if card != 'nonne-question' else 'en attendant plutôt une réponse négative'
            yield from pair('interrogationes/' + card, str(i), [
                (latin, f'On demande si {fr}, {bias}.'),
                (other, f'On demande si {fr}, {otherbias}.'),
                (base + '.', f'On affirme que {fr}.'),
            ], [a.id, verb.id, place.id, 'in', 'ne-question', 'num', 'nonne'],
                'La particule interrogative indique la question et l’attente du locuteur, sans prouver la réponse.',
                ['L’attente du locuteur a été changée.', 'Une question a été transformée en affirmation.'], evidence=verb.id + ':' + card)
        reasons = [
            ('officium', 'officium habet', 'a une tâche à accomplir', 'officium', 'tâche, devoir'),
            ('tempus', 'tempus habet', 'a du temps', 'tempus', 'temps disponible'),
        ]
        k, reason, freason, lemma, gloss = reasons[i % 2]
        LEXICON[k] = (lemma, gloss)
        yield from pair('interrogationes/cur-quia', str(i), [
            (base + ' quia ' + reason + '.', f'{fr} parce qu’il {freason}.'),
            (base + ' et ' + reason + '.', f'{fr} et il {freason}, sans lien de cause exprimé.'),
        ], [a.id, verb.id, place.id, 'in', k, 'habeo', 'quia', 'et'],
            'Quia introduit la cause ; et juxtapose deux faits sans exprimer ce lien causal.',
            ['Le lien de cause a été supprimé.'], evidence=verb.id + ':' + k)


def command_cards():
    actions = ACTIONS[:8]
    for i, (a, (v, obj), place) in enumerate(itertools.product(PEOPLE, actions, PLACES[:3])):
        for plural, card in [(False, 'singular-command'), (True, 'plural-command')]:
            verb = v.form('imperative', plural)
            other = v.form('imperative', not plural)
            french = v.imperative_pl if plural else v.imperative
            otherfr = v.imperative if plural else v.imperative_pl
            yield from pair('sermo/' + card, str(i), [
                (f'{a.form("voc", plural)}, in {place.form("abl")}, {verb} {obj.form("acc")}!', f'On s’adresse {to(a.french(plural))} : « Dans {place.fr}, {french} {obj.fr} ! » ' + ('Ordre à plusieurs personnes.' if plural else 'Ordre à une personne.')),
                (f'{a.form("voc", not plural)}, in {place.form("abl")}, {other} {obj.form("acc")}!', f'On s’adresse {to(a.french(not plural))} : « Dans {place.fr}, {otherfr} {obj.fr} ! » ' + ('Ordre à une personne.' if plural else 'Ordre à plusieurs personnes.')),
                (f'In {place.form("abl")}, {a.nom} {obj.form("acc")} {v.form()}.', f'Dans {place.fr}, {a.fr} {v.present} {obj.fr}.'),
            ], [a.id, v.id, obj.id, place.id, 'in'],
                'L’impératif donne un ordre ; sa terminaison distingue une personne de plusieurs destinataires.',
                ['Le nombre des destinataires a été changé.', 'L’ordre a été transformé en constat.'], evidence=f'{v.id}:{plural}:{obj.id}')
        yield from pair('sermo/vocative', str(i), [
            (f'{a.form("voc")}, {v.form("imperative")} {obj.form("acc")} in {place.form("abl")}!', f'On s’adresse {to(a.fr)} : « {cap(v.imperative)} {obj.fr} dans {place.fr} ! »'),
            (f'{a.nom} {obj.form("acc")} in {place.form("abl")} {v.form()}.', f'{a.fr} {v.present} {obj.fr} dans {place.fr}.'),
        ], [a.id, v.id, obj.id, place.id, 'in'], 'Le vocatif appelle l’interlocuteur ; il n’est pas le sujet d’un verbe de constat.',
            ['L’interpellation a été interprétée comme une description.'], evidence=f'{a.id}:{v.id}')
    # Human antecedents make singular/plural and masculine/feminine explicit.
    women = nouns('''
ancilla|ancillae|f|la servante|les servantes|f
domina|dominae|f|la maîtresse de maison|les maîtresses de maison|f
amīca|amīcae|f|l’amie|les amies|f
vīcīna|vīcīnae|f|la voisine|les voisines|f
''')
    for plural, card in [(False, 'eum-eam'), (True, 'eos-eas')]:
        for i, (a, woman, place, female) in enumerate(itertools.product(PEOPLE, women, PLACES[:4], [False, True])):
            antecedent = woman if female else a
            observer = PEOPLE[(PEOPLE.index(a) + 1) % 12]
            pronoun = ('eās' if female else 'eōs') if plural else ('eam' if female else 'eum')
            wrong = ('eōs' if female else 'eās') if plural else ('eum' if female else 'eam')
            verb = 'adsunt' if plural else 'adest'
            frenchverb = 'sont présents' if plural else 'est présent'
            if female: frenchverb += 'es' if plural else 'e'
            if plural and female: frenchverb = 'sont présentes'
            yield from pair('sermo/' + card, str(i), [
                (f'{antecedent.form(plural=plural)} in {place.form("abl")} {verb}. {observer.nom} {pronoun} salūtat.', f'{antecedent.french(plural)} {frenchverb} dans {place.fr}. {cap(observer.fr)} salue ' + ('ces femmes.' if female and plural else 'ces hommes.' if plural else 'cette femme.' if female else 'cet homme.')),
                (f'{antecedent.form(plural=plural)} in {place.form("abl")} {verb}. {observer.nom} {wrong} salūtat.', f'{antecedent.french(plural)} {frenchverb} dans {place.fr}. {cap(observer.fr)} salue ' + ('ces hommes.' if female and plural else 'ces femmes.' if plural else 'cet homme.' if female else 'cette femme.')),
            ], [antecedent.id, observer.id, place.id, 'in', 'adsum', 'is', 'saluto'],
                'Le pronom reprend le genre et le nombre de la personne ou du groupe déjà nommé.',
                ['Le genre du pronom ne correspond pas à l’antécédent.'], evidence=f'{antecedent.id}:{plural}')


def passive_cards():
    # Both the active and passive readings remain plausible with human
    # participants. Inanimate objects "buying something" are not distractors.
    patients = []
    for key, inf, fr in [
        ('saluto', 'salūtāre', 'saluer'), ('voco', 'vocāre', 'appeler'),
        ('laudo', 'laudāre', 'féliciter'), ('castigo', 'castīgāre', 'réprimander'),
        ('libero', 'līberāre', 'relâcher'), ('curo', 'cūrāre', 'soigner'),
        ('interrogo', 'interrogāre', 'questionner'), ('invito', 'invītāre', 'inviter'),
        ('exspecto', 'exspectāre', 'attendre'), ('accuso', 'accūsāre', 'accuser'),
        ('adiuvo', 'adiuvāre', 'aider'), ('observo', 'observāre', 'observer'),
    ]:
        f = fr[:-2]
        # Only the displayed present and passive participle are needed here.
        present, plural_fr, part = (('appelle', 'appellent', 'appelé') if key == 'voco'
            else ('attend', 'attendent', 'attendu') if key == 'exspecto'
            else (f + 'e', f + 'ent', f + 'é'))
        perfect, supine = ('adiūv', 'adiūtum') if key == 'adiuvo' else (inf[:-3] + 'āv', inf[:-3] + 'ātum')
        v = Verb(key, inf, '1', perfect, supine, fr, present, plural_fr, '', '', '', '', '', part)
        LEXICON.setdefault(key, (inf, fr))
        patients.append(v)
    for i, (v, obj, place, plural) in enumerate(itertools.product(patients, PEOPLE, PLACES[:2], [False, True])):
        part = participle_fr(v, obj, plural)
        la = f'{obj.form(plural=plural)} in {place.form("abl")} {v.form(plural=plural, passive=True)}.'
        fr = f'{obj.french(plural)} {"sont" if plural else "est"} {part} dans {place.fr}.'
        otherpart = participle_fr(v, obj, not plural)
        number = (f'{obj.form(plural=not plural)} in {place.form("abl")} {v.form(plural=not plural, passive=True)}.',
                  f'{obj.french(not plural)} {"est" if plural else "sont"} {otherpart} dans {place.fr}.')
        active = (f'{obj.form(plural=plural)} in {place.form("abl")} {v.form(plural=plural)}.',
                  f'{obj.french(plural)} {v.french(plural=plural)} quelqu’un dans {place.fr}.')
        words = [v.id, obj.id, place.id, 'in']
        yield from pair('actiones/passive-patient', str(i), [(la, fr), active], words,
            'Dans la phrase passive, le sujet subit l’action ; il n’en est pas l’agent.', ['Le passif a été remplacé par un actif.'], evidence=f'{v.id}:{obj.id}:{plural}')
        yield from pair('actiones/passive-number', str(i), [(la, fr), number], words,
            'Le verbe passif s’accorde avec le sujet qui subit l’action : -tur au singulier, -ntur au pluriel.',
            ['Le nombre du patient a été changé.'], evidence=f'{v.id}:{obj.id}:{plural}')
    for i, (a, (v, obj), plural) in enumerate(itertools.product(PEOPLE, ACTIONS[8:20], [False, True])):
        b = PEOPLE[(PEOPLE.index(a) + 1) % 12]
        part = participle_fr(v, obj, plural)
        yield from pair('actiones/passive-agent', str(i), [
            (f'{obj.form(plural=plural)} ab {a.form("abl")} {v.form(plural=plural, passive=True)}.', f'{obj.french(plural)} {"sont" if plural else "est"} {part} par {a.fr}.'),
            (f'{obj.form(plural=plural)} ab {b.form("abl")} {v.form(plural=plural, passive=True)}.', f'{obj.french(plural)} {"sont" if plural else "est"} {part} par {b.fr}.'),
        ], [a.id, b.id, v.id, obj.id, 'ab'], 'Ā ou ab suivi de l’ablatif désigne l’agent de la phrase passive.',
            ['L’agent introduit par ab n’est pas la personne indiquée dans l’énoncé.'], evidence=f'{a.id}:{v.id}')
    tools = nouns('''
carrus|carrī|m|le chariot|les chariots|m
clāvis|clāvis|f|la clé|les clés|f
pessulus|pessulī|m|le verrou|les verrous|m
pēnicillus|pēnicillī|m|le pinceau|les pinceaux|m
mola|molae|f|la meule|les meules|f
serra|serrae|f|la scie|les scies|f
malleus|malleī|m|le marteau|les marteaux|m
spongia|spongiae|f|l’éponge|les éponges|f
hāmus|hāmī|m|le crochet|les crochets|m
fūniculus|fūniculī|m|la ficelle|les ficelles|f
''')
    tool_actions = [ACTIONS[n] for n in [0, 1, 2, 5, 7, 15, 13, 18, 17, 23]]
    for i, (a, action, plural) in enumerate(itertools.product(PEOPLE, list(zip(tool_actions, tools)), [False, True])):
        (v, obj), tool = action
        if v.id == 'purgo': obj = ACTION_OBJECTS[10]  # a lamp can be cleaned with a sponge
        part = participle_fr(v, obj, plural)
        yield from pair('actiones/instrument-agent', str(i), [
            (f'{obj.form(plural=plural)} ab {a.form("abl")} {tool.form("abl")} {v.form(plural=plural, passive=True)}.', f'{obj.french(plural)} {"sont" if plural else "est"} {part} par {a.fr} avec {tool.fr}.'),
            (f'{obj.form(plural=plural)} ab {a.form("abl")} sine {tool.form("abl")} {v.form(plural=plural, passive=True)}.', f'{obj.french(plural)} {"sont" if plural else "est"} {part} par {a.fr} sans {tool.fr}.'),
        ], [a.id, v.id, obj.id, tool.id, 'ab', 'sine'],
            'L’ablatif sans préposition indique ici l’instrument ; ab indique l’agent, et sine exclurait l’instrument.',
            ['L’emploi de l’instrument a été remplacé par son absence.'], evidence=f'{v.id}:{tool.id}:{obj.id}')


def journey_cards():
    towns = nouns('''
Rōma|Rōmae|f|Rome|Rome|f
Ostia|Ostiae|f|Ostie|Ostie|f
Capua|Capuae|f|Capoue|Capoue|f
Nōla|Nōlae|f|Nole|Nole|f
Arīcia|Arīciae|f|Aricie|Aricie|f
Arīminum|Arīminī|n|Rimini|Rimini|m
Brundisium|Brundisiī|n|Brindisi|Brindisi|m
Tarentum|Tarentī|n|Tarente|Tarente|f
Mediolānum|Mediolānī|n|Milan|Milan|m
Verōna|Verōnae|f|Vérone|Vérone|f
Ravenna|Ravennae|f|Ravenne|Ravenne|f
Tūsculum|Tūsculī|n|Tusculum|Tusculum|m
''')
    for i, (a, town, returning) in enumerate(itertools.product(PEOPLE, towns, [False, True])):
        for card, case, latinverb, frverb in [
            ('town-location', 'gen', 'habitat' if not returning else 'manet', 'habite' if not returning else 'reste'),
            ('town-destination', 'acc', 'venit' if not returning else 'redit', 'vient' if not returning else 'revient'),
            ('town-origin', 'abl', 'venit' if not returning else 'redit', 'vient' if not returning else 'revient'),
        ]:
            frprep = ('de ' if card == 'town-origin' else 'à ')
            if frprep == 'de ' and town.fr[0] in 'AO': frprep = 'd’'
            correct = (f'{a.nom} {town.form(case)} {latinverb}.', f'{a.fr} {frverb} {frprep}{town.fr}.')
            if card == 'town-location':
                wrong = (f'{a.nom} {town.form("acc")} venit.', f'{a.fr} vient à {town.fr}.')
            elif card == 'town-destination':
                wrong = (f'{a.nom} {town.form("abl")} {latinverb}.', f'{a.fr} {frverb} ' + ('d’' if town.fr[0] in 'AO' else 'de ') + town.fr + '.')
            else:
                wrong = (f'{a.nom} {town.form("acc")} {latinverb}.', f'{a.fr} {frverb} à {town.fr}.')
            yield from pair('itinera/' + card, str(i), [correct, wrong], [a.id, town.id, 'venio', 'redeo', 'habito', 'maneo'],
                'Avec ces noms de villes : le locatif indique où l’on est, l’accusatif où l’on va, l’ablatif d’où l’on vient.',
                ['La position, la destination ou le point de départ ont été confondus.'], evidence=f'{town.id}:{card}')
    for i, (a, place, entering) in enumerate(itertools.product(PEOPLE, PLACES, [False, True])):
        correct = (f'{a.nom} in {place.form("acc" if entering else "abl")} currit.', f'{a.fr} court ' + (f'pour entrer dans {place.fr}.' if entering else f'à l’intérieur de {place.fr}, sans franchir son entrée.'))
        wrong = (f'{a.nom} in {place.form("abl" if entering else "acc")} currit.', f'{a.fr} court ' + (f'à l’intérieur de {place.fr}, sans franchir son entrée.' if entering else f'pour entrer dans {place.fr}.'))
        yield from pair('itinera/in-place-motion', str(i), [correct, wrong], [a.id, place.id, 'in', 'curro'],
            'In avec l’accusatif marque l’entrée dans un lieu ; avec l’ablatif, le mouvement reste à l’intérieur du lieu.',
            ['Le mouvement à l’intérieur et l’entrée dans le lieu ont été intervertis.'], evidence=f'{place.id}:{entering}')


def time_cards():
    for card, eligible in [('04-time', [a for a in ACTIONS[16:] if a[0].cls in ['1', '2']]),
                           ('future-third-fourth', [a for a in ACTIONS[16:] if a[0].cls in ['3', '4']])]:
        for i, (a, (v, obj), place) in enumerate(itertools.product(PEOPLE, eligible, PLACES[:6])):
            alternatives = []
            for tense in ['future', 'present', 'perfect']:
                la, fr = clause(a, v, obj, tense)
                alternatives.append((la[:-1] + f' in {place.form("abl")}.', fr[:-1] + f' dans {place.fr}.'))
            yield from pair('tempora/' + card, str(i), alternatives, [a.id, v.id, obj.id, place.id, 'in'],
                'La forme verbale situe l’action dans l’avenir, même sans un adverbe comme crās.',
                ['Le futur a été remplacé par le présent.', 'Le futur a été remplacé par une action accomplie.'], evidence=v.id + ':' + obj.id)
    for i, (a, (v, obj), place) in enumerate(itertools.product(PEOPLE, ACTIONS[16:], PLACES[:3])):
        for tense in ['imperfect', 'perfect']:
            other = 'perfect' if tense == 'imperfect' else 'imperfect'
            alternatives = []
            for t in [tense, other]:
                la, fr = clause(a, v, obj, t)
                alternatives.append((la[:-1] + f' in {place.form("abl")}.', fr[:-1] + f' dans {place.fr}.'))
            yield from pair('tempora/05-narrative', f'{i}:{tense}', alternatives, [a.id, v.id, obj.id, place.id, 'in'],
                'L’imparfait présente l’action en cours ou habituelle ; le parfait la présente comme un événement accompli.',
                ['L’action en cours et l’événement accompli ont été intervertis.'], evidence=f'{v.id}:{tense}')
        prior = v.past.replace('a ', 'avait ', 1)
        yield from pair('tempora/pluperfect-anteriority', str(i), [
            (f'{a.nom} {obj.form("acc")} iam {v.form("pluperfect")}. Tum medicus in {place.form("abl")} advēnit.', f'{a.fr} {prior} {obj.fr} auparavant. Le médecin est alors arrivé dans {place.fr}.'),
            (f'{a.nom} {obj.form("acc")} {v.form("imperfect")}. Tum medicus in {place.form("abl")} advēnit.', f'{a.fr} {v.imperfect} {obj.fr} à ce moment-là. Le médecin est alors arrivé dans {place.fr}.'),
        ], [a.id, v.id, obj.id, place.id, 'in', 'medicus', 'iam', 'tum', 'advenio'],
            'Le plus-que-parfait indique une action accomplie avant le repère déjà passé du récit.',
            ['L’antériorité à un événement passé a été remplacée par la simultanéité.'], evidence=v.id + ':' + obj.id)


def infinitive_cards():
    # The actions here concern preparing and repairing a voyage, rather than
    # another rotation of the six original school sentences.
    voyage = extra_actions()
    for i, (speaker, (v, obj)) in enumerate(itertools.product(PEOPLE, voyage)):
        a = THIRD_PEOPLE[i % len(THIRD_PEOPLE)]
        present, perfect, future = v.inf, v.perfect + 'isse', v.supine[:-2] + 'ūrum esse'
        words = [speaker.id, a.id, v.id, obj.id, 'dico']
        yield from pair('orationes/infinitive-subject', str(i), [
            (f'{speaker.nom} dīcit {a.form("acc")} {obj.form("acc")} {present}.', f'{speaker.fr} dit que {a.fr} {v.present} {obj.fr}.'),
            (f'{a.nom} dīcit {speaker.form("acc")} {obj.form("acc")} {present}.', f'{a.fr} dit que {speaker.fr} {v.present} {obj.fr}.'),
        ], words, 'Dans l’accusatif avec infinitif, le sujet de l’infinitif est à l’accusatif ; il peut différer de celui qui parle.',
            ['La personne qui parle et celle dont l’action est rapportée ont été inversées.'], evidence=a.id + ':' + v.id)
        for card, target, targetfr, other, otherfr in [
            ('infinitive-anteriority', perfect, v.past, present, v.present),
            ('infinitive-posteriority', future, v.future, present, v.present),
        ]:
            yield from pair('orationes/' + card, str(i), [
                (f'{speaker.nom} dīcit {a.form("acc")} {obj.form("acc")} {target}.', f'{speaker.fr} dit que {a.fr} {targetfr} {obj.fr}.'),
                (f'{speaker.nom} dīcit {a.form("acc")} {obj.form("acc")} {other}.', f'{speaker.fr} dit que {a.fr} {otherfr} {obj.fr}.'),
            ], words, 'Le temps de l’infinitif se mesure par rapport au verbe de parole : présent simultané, parfait antérieur, futur postérieur.',
                ['Le rapport temporel avec les paroles rapportées a été changé.'], evidence=v.id + ':' + card)
        conditional = v.future[:-1] + 'ait'
        yield from pair('orationes/past-posteriority', str(i), [
            (f'{speaker.nom} dīxit {a.form("acc")} {obj.form("acc")} {future}.', f'{speaker.fr} a dit que {a.fr} {conditional} {obj.fr} plus tard.'),
            (f'{speaker.nom} dīxit {a.form("acc")} {obj.form("acc")} {perfect}.', f'{speaker.fr} a dit que {a.fr} {v.past.replace("a ", "avait ", 1)} {obj.fr} auparavant.'),
        ], words, 'L’infinitif futur reste postérieur au verbe de parole, même lorsque ce verbe est au passé.',
            ['Une action postérieure aux paroles a été placée avant elles.'], evidence=v.id + ':' + obj.id)


def extra_actions():
    # New lexical situations introduced in the infinitive section. All objects
    # are authored with a compatible action; no arbitrary verb/object products.
    raw = [
        ('reparare', 'réparer', 'répare', 'réparent', 'réparait', 'a réparé', 'réparera', 'répare', 'réparez', 'réparé', 'reparāre', 'reparāv', 'reparātum', 'rēmus|rēmī|m|la rame|les rames|f'),
        ('ligo', 'attacher', 'attache', 'attachent', 'attachait', 'a attaché', 'attachera', 'attache', 'attachez', 'attaché', 'ligāre', 'ligāv', 'ligātum', 'rudēns|rudentis|m|la corde de manœuvre|les cordes de manœuvre|f'),
        ('onerare', 'charger', 'charge', 'chargent', 'chargeait', 'a chargé', 'chargera', 'charge', 'chargez', 'chargé', 'onerāre', 'onerāv', 'onerātum', 'plaustrum|plaustrī|n|le chariot de transport|les chariots de transport|m'),
        ('explorare', 'explorer', 'explore', 'explorent', 'explorait', 'a exploré', 'explorera', 'explore', 'explorez', 'exploré', 'explōrāre', 'explōrāv', 'explōrātum', 'lītus|lītoris|n|le rivage|les rivages|m'),
        ('observare', 'observer', 'observe', 'observent', 'observait', 'a observé', 'observera', 'observe', 'observez', 'observé', 'observāre', 'observāv', 'observātum', 'astrum|astrī|n|l’astre|les astres|m'),
        ('notare', 'noter', 'note', 'notent', 'notait', 'a noté', 'notera', 'note', 'notez', 'noté', 'notāre', 'notāv', 'notātum', 'numerus|numerī|m|le nombre|les nombres|m'),
        ('signare', 'sceller', 'scelle', 'scellent', 'scellait', 'a scellé', 'scellera', 'scelle', 'scellez', 'scellé', 'signāre', 'signāv', 'signātum', 'testāmentum|testāmentī|n|le testament|les testaments|m'),
        ('numerare', 'compter', 'compte', 'comptent', 'comptait', 'a compté', 'comptera', 'compte', 'comptez', 'compté', 'numerāre', 'numerāv', 'numerātum', 'nummus|nummī|m|la pièce de monnaie|les pièces de monnaie|f'),
        ('tractare', 'manier', 'manie', 'manient', 'maniait', 'a manié', 'maniera', 'manie', 'maniez', 'manié', 'tractāre', 'tractāv', 'tractātum', 'gubernāculum|gubernāculī|n|le gouvernail|les gouvernails|m'),
        ('transportare', 'transporter', 'transporte', 'transportent', 'transportait', 'a transporté', 'transportera', 'transporte', 'transportez', 'transporté', 'transportāre', 'transportāv', 'transportātum', 'sarcina|sarcinae|f|le bagage|les bagages|m'),
        ('demonstrare', 'montrer', 'montre', 'montrent', 'montrait', 'a montré', 'montrera', 'montre', 'montrez', 'montré', 'dēmōnstrāre', 'dēmōnstrāv', 'dēmōnstrātum', 'semita|semitae|f|le sentier|les sentiers|m'),
        ('temptare', 'essayer', 'essaie', 'essaient', 'essayait', 'a essayé', 'essaiera', 'essaie', 'essayez', 'essayé', 'temptāre', 'temptāv', 'temptātum', 'ratis|ratis|f|le radeau|les radeaux|m'),
    ]
    out = []
    for key, *f in raw:
        frinf, pres, pl, impf, past, future, imp, imppl, part, inf, perf, sup, obj = f
        if key.endswith('are'): key = key[:-3] + 'o'
        v = Verb(key, inf, '1', perf, sup, frinf, pres, pl, impf, past, future, imp, imppl, part)
        LEXICON[key] = (inf, frinf)
        out.append((v, nouns(obj)[0]))
    # Two meaningful objects per action, rather than duplicated answer orders.
    # The second object is a different number of the same object; the main
    # infinitive task explicitly renders it, with plural case forms.
    return out + [(v, PluralNoun(o)) for v, o in out]


@dataclass(frozen=True)
class PluralNoun:
    """A plural referent, sharing its lemma identity with the singular noun."""
    base: Noun
    @property
    def id(self): return self.base.id
    @property
    def gender(self): return self.base.gender
    @property
    def fg(self): return self.base.fg
    @property
    def nom(self): return self.base.form(plural=True)
    @property
    def fr(self): return self.base.frpl
    def form(self, case='nom', plural=False): return self.base.form(case, True)


def clause_cards():
    for i, (a, (v, obj), place) in enumerate(itertools.product(PEOPLE, ACTIONS, PLACES[:2])):
        b = THIRD_PEOPLE[(i // 2) % 12]
        words = [a.id, b.id, v.id, obj.id, place.id, 'in', 'venio', 'ut', 'ne']
        purpose = (f'{a.nom} in {place.form("acc")} venit ut {obj.form("acc")} {v.form("subjunctive")}.', f'{a.fr} vient dans {place.fr} pour {v.frinf} {obj.fr}.')
        forbidden = (f'{a.nom} in {place.form("acc")} venit nē {obj.form("acc")} {v.form("subjunctive")}.', f'{a.fr} vient dans {place.fr} pour ne pas {v.frinf} {obj.fr}.')
        yield from pair('sententiae/07-purpose', str(i), [purpose, forbidden], words,
            'Ut suivi du subjonctif indique ici le but ; nē exprimerait un but négatif.',
            ['Le but affirmatif a été nié.'], evidence=v.id + ':' + obj.id)
        yield from pair('sententiae/purpose-past', str(i), [
            (f'{a.nom} in {place.form("acc")} vēnit ut {obj.form("acc")} {v.inf + "t"}.', f'{a.fr} est venu dans {place.fr} pour {v.frinf} {obj.fr}.'),
            (f'{a.nom} in {place.form("acc")} vēnit nē {obj.form("acc")} {v.inf + "t"}.', f'{a.fr} est venu dans {place.fr} pour ne pas {v.frinf} {obj.fr}.'),
        ], words, 'Après un verbe principal au passé, le but est exprimé ici par ut et l’imparfait du subjonctif.',
            ['Le but de l’action passée a été nié.'], evidence=v.id + ':' + obj.id)
        part = v.root + {'1': 'ante', '2': 'ente', '3': 'ente', '4': 'iente'}[v.cls]
        yield from pair('sententiae/08-circumstances', str(i), [
            (f'{a.form("abl")} {obj.form("acc")} {part}, {b.nom} in {place.form("acc")} venit.', f'Pendant que {a.fr} {v.present} {obj.fr}, {b.fr} vient dans {place.fr}.'),
            (f'{b.form("abl")} {obj.form("acc")} {part}, {a.nom} in {place.form("acc")} venit.', f'Pendant que {b.fr} {v.present} {obj.fr}, {a.fr} vient dans {place.fr}.'),
        ], words, 'Le nom à l’ablatif est le sujet du participe de l’ablatif absolu ; il se distingue du sujet de la proposition principale.',
            ['Les agents de la circonstance et de l’action principale ont été inversés.'], evidence=f'{v.id}:{a.id}:{b.id}')
        ablpart = v.supine[:-2] + ('ā' if obj.gender == 'f' else 'ō')
        translated = f'{obj.fr} ' + participle_fr(v, obj)
        yield from pair('sententiae/absolute-perfect', str(i), [
            (f'{obj.form("abl")} {ablpart}, {a.nom} in {place.form("acc")} venit.', f'Une fois {translated}, {a.fr} vient dans {place.fr}.'),
            (f'Antequam {obj.nom} {v.form(passive=True)}, {a.nom} in {place.form("acc")} venit.', f'Avant que {obj.fr} soit ' + participle_fr(v, obj) + f', {a.fr} vient dans {place.fr}.'),
        ], words + ['antequam'], 'Le participe parfait de l’ablatif absolu présente ici une action accomplie avant l’action principale.',
            ['L’action déjà accomplie a été reportée après l’action principale.'], evidence=v.id + ':' + obj.id)
        yield from pair('sententiae/10-sacred', str(i), [
            (f'{a.nom} {b.form("dat")} {obj.form("acc")} dat ut {b.nom} {obj.form("acc")} {v.form("subjunctive")}.', f'{a.fr} donne {obj.fr} {to(b.fr)} pour que ce dernier puisse {v.frinf} {obj.fr}.'),
            (f'{a.nom} {b.form("dat")} {obj.form("acc")} dat quia {b.nom} {obj.form("acc")} {v.form()}.', f'{a.fr} donne {obj.fr} {to(b.fr)} parce que ce dernier {v.present} {obj.fr}.'),
        ], words + ['do', 'quia'], 'Un but voulu (ut et subjonctif) se distingue d’une cause présentée comme un fait (quia et indicatif).',
            ['Un but recherché a été transformé en cause déjà donnée.'], evidence=v.id + ':' + obj.id)


def gerund_cards():
    skills = craft_actions()
    for i, (a, (v, obj), place) in enumerate(itertools.product(PEOPLE, skills, PLACES[:2])):
        # No direct object after ad + gerund: the infinitive activity is used
        # absolutely; its concrete context is the authored workshop/location.
        words = [a.id, v.id, place.id, 'in', 'venio', 'ad', 'disco', 'cupido', 'sum', 'causa']
        for card, gerund, correctfr, wronggerund, wrongfr in [
            ('gerund-ad', 'ad ' + v.gerund('um'), 'pour ' + v.frinf, v.gerund('ō'), 'en pratiquant cette activité comme moyen : ' + v.frinf),
            ('gerund-causa', v.gerund('ī') + ' causā', 'pour ' + v.frinf, v.gerund('ō'), 'en pratiquant cette activité comme moyen : ' + v.frinf),
        ]:
            yield from pair('gerundium/' + card, str(i), [
                (f'{a.nom} in {place.form("acc")} {gerund} venit.', f'{a.fr} vient dans {place.fr} {correctfr}.'),
                (f'{a.nom} in {place.form("acc")} {wronggerund} venit.', f'{a.fr} vient dans {place.fr} {wrongfr}.'),
            ], words, 'Ad avec l’accusatif du gérondif ou causā après son génitif indique un but ; l’ablatif seul exprime un moyen.',
                ['Le but a été remplacé par le moyen.'], evidence=v.id + ':' + card)
        yield from pair('gerundium/gerund-desire', str(i), [
            (f'{a.nom} {v.gerund("ī")} cupidus in {place.form("abl")} est.', f'{a.fr} est dans {place.fr} et désire {v.frinf}.'),
            (f'{a.nom} in {place.form("abl")} {v.form()}.', f'{a.fr} est dans {place.fr} et {v.present} effectivement.'),
        ], words + ['cupidus'], 'Cupidus avec le génitif du gérondif exprime le désir d’une activité, sans affirmer sa réalisation.',
            ['Le désir a été transformé en action effective.'], evidence=v.id + ':' + place.id)
        yield from pair('gerundium/gerund-means', str(i), [
            (f'{a.nom} in {place.form("abl")} {v.gerund("ō")} discit.', f'{a.fr} apprend dans {place.fr} par la pratique de l’activité suivante : {v.frinf}.'),
            (f'{a.nom} in {place.form("abl")} ad {v.gerund("um")} discit.', f'{a.fr} apprend dans {place.fr} dans le but de {v.frinf}.'),
        ], words, 'Le gérondif à l’ablatif indique par quelle activité on apprend ; ad indique l’objectif de cet apprentissage.',
            ['Le moyen d’apprendre a été changé en but.'], evidence=v.id + ':' + place.id)


def craft_actions():
    # Dedicated new verbs in this section, with meaningful object pairings for
    # the advanced gerundive/supine cards as well.
    data = [
        ('fingere', '3', 'fīnx', 'fictum', 'façonner', 'façonne', 'façonnent', 'façonnait', 'a façonné', 'façonnera', 'façonne', 'façonnez', 'façonné', 'argilla|argillae|f|l’argile|les argiles|f'),
        ('sculpere', '3', 'sculps', 'sculptum', 'sculpter', 'sculpte', 'sculptent', 'sculptait', 'a sculpté', 'sculptera', 'sculpte', 'sculptez', 'sculpté', 'marmor|marmoris|n|le marbre|les marbres|m'),
        ('polīre', '4', 'polīv', 'polītum', 'polir', 'polit', 'polissent', 'polissait', 'a poli', 'polira', 'polis', 'polissez', 'poli', 'crystallum|crystallī|n|le cristal|les cristaux|m'),
        ('cēlāre', '1', 'cēlāv', 'cēlātum', 'cacher', 'cache', 'cachent', 'cachait', 'a caché', 'cachera', 'cache', 'cachez', 'caché', 'thēsaurus|thēsaurī|m|le trésor|les trésors|m'),
        ('cōnsuere', '3', 'cōnsu', 'cōnsūtum', 'coudre', 'coud', 'cousent', 'cousait', 'a cousu', 'coudra', 'couds', 'cousez', 'cousu', 'pannus|pannī|m|le morceau d’étoffe|les morceaux d’étoffe|m'),
        ('sarcīre', '4', 'sars', 'sartum', 'raccommoder', 'raccommode', 'raccommodent', 'raccommodait', 'a raccommodé', 'raccommodera', 'raccommode', 'raccommodez', 'raccommodé', 'sagum|sagī|n|le manteau de laine|les manteaux de laine|m'),
        ('probāre', '1', 'probāv', 'probātum', 'examiner', 'examine', 'examinent', 'examinait', 'a examiné', 'examinera', 'examine', 'examinez', 'examiné', 'exemplum|exemplī|n|le modèle|les modèles|m'),
        ('dēlīneāre', '1', 'dēlīneāv', 'dēlīneātum', 'dessiner', 'dessine', 'dessinent', 'dessinait', 'a dessiné', 'dessinera', 'dessine', 'dessinez', 'dessiné', 'fōrma|fōrmae|f|la figure|les figures|f'),
        ('līmāre', '1', 'līmāv', 'līmātum', 'limer', 'lime', 'liment', 'limait', 'a limé', 'limera', 'lime', 'limez', 'limé', 'ferrum|ferrī|n|le fer|les fers|m'),
        ('conflāre', '1', 'conflāv', 'conflātum', 'fondre', 'fond', 'fondent', 'fondait', 'a fondu', 'fondra', 'fonds', 'fondez', 'fondu', 'plumbum|plumbī|n|le plomb|les plombs|m'),
        ('dūrāre', '1', 'dūrāv', 'dūrātum', 'durcir', 'durcit', 'durcissent', 'durcissait', 'a durci', 'durcira', 'durcis', 'durcissez', 'durci', 'cēra|cērae|f|la cire|les cires|f'),
        ('mollīre', '4', 'mollīv', 'mollītum', 'assouplir', 'assouplit', 'assouplissent', 'assouplissait', 'a assoupli', 'assouplira', 'assouplis', 'assouplissez', 'assoupli', 'corium|coriī|n|le cuir|les cuirs|m'),
    ]
    canonical = 'fingo sculpo polio celo consuo sarcio probo delineo limo conflo duro mollio'.split()
    out = []
    for key, row in zip(canonical, data):
        v = Verb(key, *row[:-1])
        LEXICON[key] = (v.inf, v.frinf)
        out.append((v, nouns(row[-1])[0]))
    return out


def civic_actions():
    # These French -er verbs are regular, including their written stem.
    data = [
        ('confirmo', 'cōnfirmāre', 'confirmer', 'foedus|foederis|n|le traité|les traités|m'),
        ('recito', 'recitāre', 'réciter', 'ēdictum|ēdictī|n|l’édit|les édits|m'),
        ('accuso', 'accūsāre', 'accuser', 'reus|reī|m|l’accusé|les accusés|m'),
        ('convoco', 'convocāre', 'convoquer', 'concilium|conciliī|n|l’assemblée|les assemblées|f'),
        ('recuso', 'recūsāre', 'refuser', 'condiciō|condiciōnis|f|la condition|les conditions|f'),
        ('nuntio', 'nūntiāre', 'signaler', 'perīculum|perīculī|n|le danger|les dangers|m'),
        ('libero', 'līberāre', 'relâcher', 'obses|obsidis|m|l’otage|les otages|m'),
        ('paco', 'pācāre', 'pacifier', 'prōvincia|prōvinciae|f|la province|les provinces|f'),
        ('violo', 'violāre', 'violer', 'lēx|lēgis|f|la loi|les lois|f'),
        ('honoro', 'honōrāre', 'honorer', 'patrōnus|patrōnī|m|le protecteur|les protecteurs|m'),
        ('saluto', 'salūtāre', 'saluer', 'socius|sociī|m|l’allié|les alliés|m'),
        ('comprobo', 'comprobāre', 'approuver', 'sententia|sententiae|f|la décision|les décisions|f'),
    ]
    out = []
    for key, inf, fr, obj in data:
        r, f = inf[:-3], fr[:-2]
        v = Verb(key, inf, '1', r + 'āv', r + 'ātum', fr, f + 'e', f + 'ent', f + 'ait', 'a ' + f + 'é', fr + 'a', f + 'e', f + 'ez', f + 'é')
        LEXICON[key] = (inf, fr)
        out.append((v, nouns(obj)[0]))
    return out


def advanced_cards():
    craft = craft_actions()
    civic = civic_actions()
    for i, (a, (v, obj), plural) in enumerate(itertools.product(PEOPLE, craft, [False, True])):
        ending = {'m': ('us', 'ī'), 'f': ('a', 'ae'), 'n': ('um', 'a')}[obj.gender][plural]
        copula = 'sunt' if plural else 'est'
        yield from pair('formae-non-finitae/2', str(i), [
            (f'{a.nom} dīcit: «{obj.form(plural=plural)} {v.gerund(ending)} {copula}.»', f'{a.fr} dit : « {cap(obj.french(plural))} ' + ('doivent' if plural else 'doit') + f' être {participle_fr(v, obj, plural)}. »'),
            (f'{a.nom} dīcit: «{obj.form(plural=plural)} {v.supine[:-2] + ending} {copula}.»', f'{a.fr} dit : « {cap(obj.french(plural))} ' + ('ont' if plural else 'a') + f' été {participle_fr(v, obj, plural)}. »'),
        ], [a.id, v.id, obj.id, 'dico', 'sum'],
            'L’adjectif verbal exprime ici ce qui doit être fait ; le participe parfait exprime ce qui a été fait.',
            ['L’obligation a été remplacée par un fait accompli.'], evidence=f'{v.id}:{obj.id}:{plural}')
    supines = [
        ('dico', 'dictū', 'dīcendum', 'dire'), ('audio', 'audītū', 'audiendum', 'entendre'),
        ('video', 'vīsū', 'videndum', 'voir'), ('facio', 'factū', 'faciendum', 'faire'),
        ('cognosco', 'cognitū', 'cognōscendum', 'connaître'), ('invenio', 'inventū', 'inveniendum', 'trouver'),
        ('credo', 'crēditū', 'crēdendum', 'croire'), ('memoro', 'memorātū', 'memorandum', 'rappeler'),
        ('narro', 'nārrātū', 'nārrandum', 'raconter'), ('exprimo', 'expressū', 'exprimendum', 'exprimer'),
        ('intellego', 'intellēctū', 'intellegendum', 'comprendre'), ('iudico', 'iūdicātū', 'iūdicandum', 'juger'),
    ]
    infinitives = dict(zip(
        'dico audio video facio cognosco invenio credo memoro narro exprimo intellego iudico'.split(),
        'dīcere audīre vidēre facere cognōscere invenīre crēdere memorāre nārrāre exprimere intellegere iūdicāre'.split()))
    for key, sup, _, gloss in supines: LEXICON.setdefault(key, (infinitives[key], gloss))
    for key, la, fr in [('facilis', 'facile', 'facile'), ('difficilis', 'difficile', 'difficile'), ('mirabilis', 'mīrābile', 'étonnant')]:
        LEXICON[key] = (key, fr)
        for i, (a, (vid, sup, gerund, gloss)) in enumerate(itertools.product(PEOPLE, supines)):
            yield from pair('formae-non-finitae/7', key + str(i), [
                (f'{a.nom} dīcit: «Hoc {la} {sup} est.»', f'{a.fr} dit : « Ceci est {fr} à {gloss}. »'),
                (f'{a.nom} dīcit: «Hoc {gerund} est.»', f'{a.fr} dit : « Ceci doit être ' + {'dire': 'dit', 'entendre': 'entendu', 'voir': 'vu', 'faire': 'fait', 'connaître': 'connu', 'trouver': 'trouvé', 'croire': 'cru', 'rappeler': 'rappelé', 'raconter': 'raconté', 'exprimer': 'exprimé', 'comprendre': 'compris', 'juger': 'jugé'}[gloss] + '. »'),
            ], [a.id, key, vid, 'hic', 'sum', 'dico'], 'Le supin en -ū complète ici une appréciation : facile à dire, difficile à faire. Il ne formule pas une obligation.',
                ['L’appréciation a été transformée en obligation.'], evidence=vid + ':' + key)
    for i, (a, (v, obj), plural) in enumerate(itertools.product(PEOPLE, civic, [False, True])):
        acc, fr = obj.form('acc', plural), obj.french(plural)
        words = [a.id, v.id, obj.id, 'dico', 'se']
        yield from pair('oratio-obliqua/2', str(i), [
            (f'{a.nom} dīcitur {acc} {v.inf}.', f'On rapporte que {a.fr} {v.present} {fr}.'),
            (f'{a.nom} dīcit sē {acc} {v.inf}.', f'{a.fr} déclare lui-même qu’il {v.present} {fr}.'),
        ], words, 'Dīcitur avec un sujet au nominatif rapporte ce que d’autres disent de ce sujet ; dīcit ferait de lui le locuteur.',
            ['La personne dont on parle a été transformée en locuteur.'], evidence=v.id + ':' + obj.id)
        b = THIRD_PEOPLE[i % 12]
        for card, utterance in [('3', 'command'), ('4', 'question'), ('5', 'reference')]:
            if utterance == 'command':
                alternatives = [
                    (f'{a.nom} {b.form("dat")} imperat ut {acc} {v.form("subjunctive")}.', f'{a.fr} ordonne {to(b.fr)} de {v.frinf} {fr}.'),
                    (f'{a.nom} {b.form("dat")} imperat nē {acc} {v.form("subjunctive")}.', f'{a.fr} interdit {to(b.fr)} de {v.frinf} {fr}.'),
                ]
                explanation = 'Dans un ordre rapporté, ut exprime l’action demandée et nē l’action interdite.'
                error = 'L’ordre a été transformé en interdiction.'
                extras = ['impero', 'ut', 'ne']
            elif utterance == 'question':
                alternatives = [
                    (f'{a.nom} rogāvit cūr {b.nom} {acc} {v.perfect + "isset"}.', f'{a.fr} a demandé pourquoi {b.fr} {v.past.replace("a ", "avait ", 1)} {fr} avant sa question.'),
                    (f'{a.nom} rogāvit cūr {b.nom} {acc} {v.inf + "t"}.', f'{a.fr} a demandé pourquoi {b.fr} {v.imperfect} {fr} au moment de sa question.'),
                ]
                explanation = 'Dans l’interrogation indirecte passée, le plus-que-parfait marque l’antériorité et l’imparfait la simultanéité.'
                error = 'L’action antérieure à la question a été présentée comme simultanée.'
                extras = ['rogo', 'cur']
            else:
                alternatives = [
                    (f'{a.nom} {b.form("acc")} vocat. Dīcit sē {acc} {v.inf}.', f'{a.fr} appelle {b.fr}, puis dit que lui-même, {a.fr}, {v.present} {fr}.'),
                    (f'{a.nom} {b.form("acc")} vocat. Dīcit eum {acc} {v.inf}.', f'{a.fr} appelle {b.fr}, puis dit que l’autre personne, {b.fr}, {v.present} {fr}.'),
                ]
                explanation = 'Dans ces paroles rapportées, sē renvoie au locuteur ; eum désigne l’autre homme déjà nommé.'
                error = 'La reprise réflexive du locuteur a été remplacée par une autre personne.'
                extras = ['voco', 'is']
            yield from pair('oratio-obliqua/' + card, str(i), alternatives, words + extras + [b.id], explanation, [error], evidence=f'{v.id}:{a.id}:{b.id}:{card}')
        for modal in ['licet', 'oportet']:
            allowed = modal == 'licet'
            target = a.form('dat' if allowed else 'acc')
            other = a.form('acc' if allowed else 'dat')
            yield from pair('verbis-intellegendis/3', str(i) + modal, [
                (f'{target} {acc} {v.inf} {modal}.', f'{a.fr} ' + ('a la permission' if allowed else 'a l’obligation') + f' de {v.frinf} {fr}.'),
                (f'{other} {acc} {v.inf} {"oportet" if allowed else "licet"}.', f'{a.fr} ' + ('a l’obligation' if allowed else 'a la permission') + f' de {v.frinf} {fr}.'),
            ], [a.id, v.id, obj.id, 'licet', 'oportet'],
                'Licet exprime la permission et régit le datif de la personne ; oportet exprime la nécessité avec l’accusatif.',
                ['Permission et obligation ont été interverties.'], evidence=f'{v.id}:{modal}')
    deponents = [('consolor', 'cōnsōlātur', 'cōnsōlārī', 'console', 'est consolé'),
                 ('comitor', 'comitātur', 'comitārī', 'accompagne', 'est accompagné'),
                 ('imitor', 'imitātur', 'imitārī', 'imite', 'est imité'),
                 ('admiror', 'admīrātur', 'admīrārī', 'admire', 'est admiré')]
    for key, _, inf, fr, _ in deponents: LEXICON[key] = (inf, fr + 'r')
    for i, (a, b, v) in enumerate(itertools.product(PEOPLE, THIRD_PEOPLE, deponents)):
        key, dep, active_inf, fr, passivefr = v
        yield from pair('verbis-intellegendis/1', str(i), [
            (f'{a.nom} {b.form("acc")} {dep}.', f'{a.fr} {fr} {b.fr}.'),
            (f'{b.nom} {a.form("acc")} {dep}.', f'{a.fr} {passivefr} par {b.fr}.'),
        ], [a.id, b.id, key], 'Le déponent a une forme passive mais un sens actif : son sujet agit.',
            ['Le sens actif du déponent a été inversé comme s’il s’agissait d’un passif.'], evidence=f'{key}:{b.id}')
    for i, (a, (v, obj), place) in enumerate(itertools.product(PEOPLE, civic, PLACES[:2])):
        yield from pair('verbis-intellegendis/2', str(i), [
            (f'{a.nom} in {place.form("abl")} {obj.form("acc")} {v.inf} ausus est.', f'{a.fr} a osé {v.frinf} {obj.fr} dans {place.fr}.'),
            (f'{a.nom} in {place.form("abl")} {obj.form("acc")} {v.inf} audet.', f'{a.fr} ose maintenant {v.frinf} {obj.fr} dans {place.fr}.'),
        ], [a.id, v.id, obj.id, place.id, 'in', 'audeo', 'sum'],
            'Ausus est est le parfait du semi-déponent audēre, de sens actif ; audet est son présent.',
            ['Le parfait du semi-déponent a été ramené au présent.'], evidence=v.id + ':' + obj.id)
    for i, (v, place, past) in enumerate(itertools.product(STATES, PLACES, [False, True])):
        tense = 'imperfect' if past else 'present'
        yield from pair('verbis-intellegendis/5', str(i), [
            (f'In {place.form("abl")} {v.form(tense, passive=True)}.', f'Dans {place.fr}, on {v.imperfect if past else v.present}.'),
            (f'In {place.form("abl")} {v.form(tense, passive=True, plural=True)}.', f'Dans {place.fr}, le texte désigne plusieurs personnes comme sujets patients d’un verbe passif.'),
        ], [v.id, place.id, 'in'], 'Le passif impersonnel reste à la troisième personne du singulier, sans sujet nominatif patient.',
            ['Un sujet patient pluriel a été inventé pour un passif impersonnel.'], evidence=f'{v.id}:{past}')


def quality_cards():
    qualities = [
        ('industria', 'industria', 'activité, application', 'magnae industriae', 'magnā industriā', 'magnam industriam', 'très laborieux'),
        ('probitas', 'probitās', 'honnêteté', 'eximiae probitātis', 'eximiā probitāte', 'eximiam probitātem', 'remarquablement honnête'),
        ('diligentia', 'dīligentia', 'soin, diligence', 'summae dīligentiae', 'summā dīligentiā', 'summam dīligentiam', 'extrêmement soigneux'),
        ('audacia', 'audācia', 'audace', 'magnae audāciae', 'magnā audāciā', 'magnam audāciam', 'très audacieux'),
        ('auctoritas', 'auctōritās', 'autorité', 'parvae auctōritātis', 'parvā auctōritāte', 'parvam auctōritātem', 'doté de peu d’autorité'),
        ('gravitas', 'gravitās', 'dignité, gravité', 'magnae gravitātis', 'magnā gravitāte', 'magnam gravitātem', 'd’une grande dignité'),
        ('patientia', 'patientia', 'patience', 'mīrae patientiae', 'mīrā patientiā', 'mīram patientiam', 'remarquablement patient'),
        ('modestia', 'modestia', 'modestie', 'rārae modestiae', 'rārā modestiā', 'rāram modestiam', 'd’une rare modestie'),
        ('integritas', 'integritās', 'intégrité', 'summae integritātis', 'summā integritāte', 'summam integritātem', 'parfaitement intègre'),
        ('comitas', 'cōmitās', 'amabilité', 'magnae cōmitātis', 'magnā cōmitāte', 'magnam cōmitātem', 'd’une grande amabilité'),
    ]
    for key, la, fr, *_ in qualities: LEXICON[key] = (la, fr)
    for key, la, fr in [('eximius', 'eximius', 'remarquable'), ('summus', 'summus', 'très grand, suprême'),
                         ('mirus', 'mīrus', 'étonnant'), ('rarus', 'rārus', 'rare')]:
        LEXICON[key] = (la, fr)
    for i, (a, q, place) in enumerate(itertools.product(PEOPLE, qualities, PLACES[:2])):
        key, _, _, gen, abl, acc, french = q
        adjective = {'magnae': 'magnus', 'eximiae': 'eximius', 'summae': 'summus', 'parvae': 'parvus', 'mīrae': 'mirus', 'rārae': 'rarus'}[gen.split()[0]]
        for cid, group, case in [('3', gen, 'génitif'), ('11', abl, 'ablatif')]:
            for address, question in pair('casuum-sensus/' + cid, str(i), [
                (f'{a.nom} {group} in {place.form("abl")} est.', f'{a.fr}, qui est {french}, se trouve dans {place.fr}.'),
                (f'{a.nom} {acc} in {place.form("abl")} est.', f'{a.fr}, qui n’est pas {french}, se trouve dans {place.fr}.'),
            ], [a.id, key, adjective, place.id, 'in', 'sum'],
                f'Le groupe au {case} attribue une qualité à la personne ; ce n’est pas un objet à l’accusatif.',
                ['La qualité a été niée en lecture ; en latin, l’accusatif ne remplit pas ici la fonction de qualité.'], evidence=key + ':' + cid):
                if address.startswith('templum/'):
                    question['outcomes']['1']['feedback'] = f'Le groupe de qualité attendu est au {case}, pas à l’accusatif.'
                yield address, question


@lru_cache(maxsize=1)
def banks():
    result, seen = defaultdict(list), defaultdict(set)
    for address, q in emit():
        signature = (q['content'][0]['text'], tuple(c['text'] for c in q['choices'] if c['id'] in q['accepted']))
        if signature in seen[address]: continue
        seen[address].add(signature)
        result[address].append(q)
    return dict(result)


if __name__ == '__main__':
    all_banks = banks()
    for address, qs in all_banks.items():
        print(address, len(qs), 'questions;', len({w for q in qs for w in q['vocabulary']}), 'lexical IDs')
    print('Total:', sum(map(len, all_banks.values())), 'questions;', len(LEXICON), 'lexical entries')
