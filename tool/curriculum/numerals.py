"""Quantity, sequence, distribution and frequency are distinct Latin meanings.

Reading includes ordered and repeated observations; production chooses a whole
constituent so distractors remain grammatical and differ in intended meaning.
"""
import unicodedata
FRAMES = []
# Cardinal, ordinal stem, distributive stem, adverb, French cardinal/ordinal.
NUMBERS = [
    ('unus','ūn','prīm','singul','semel','un','premier'),
    ('duo','du','secund','bīn','bis','deux','deuxième'),
    ('tres','trēs','terti','tern','ter','trois','troisième'),
    ('quattuor','quattuor','quārt','quatern','quater','quatre','quatrième'),
    ('quinque','quīnque','quīnt','quīn','quīnquiēs','cinq','cinquième'),
    ('sex','sex','sext','sēn','sexiēs','six','sixième'),
    ('septem','septem','septim','septēn','septiēs','sept','septième'),
    ('octo','octō','octāv','octōn','octiēs','huit','huitième'),
    ('novem','novem','nōn','novēn','noviēs','neuf','neuvième'),
    ('decem','decem','decim','dēn','deciēs','dix','dixième'),
    ('viginti','vīgintī','vīcēsim','vīcēn','vīciēs','vingt','vingtième'),
    ('centum','centum','centēsim','centēn','centiēs','cent','centième'),
]
def plain(text):
    return ''.join(c for c in unicodedata.normalize('NFD', text) if not unicodedata.combining(c))


def ordinal_key(key):
    return plain(next(row[2] for row in NUMBERS if row[0] == key) + 'us')


def distributive_key(key):
    return plain(next(row[3] for row in NUMBERS if row[0] == key) + 'i')


def frequency_key(key):
    return plain(next(row[4] for row in NUMBERS if row[0] == key))


LEXICON = '''
video|videō|voir
numero|numerō|compter
specto|spectō|observer
et|et|et
deinde|deinde|ensuite
idem|īdem|le même
quisque|quisque|chacun
'''
for key, cardinal, ordinal, distributive, adverb, french, rank in NUMBERS:
    LEXICON += f'\n{key}|'+('ūnus' if key=='unus' else 'duo' if key=='duo' else cardinal)+f'|{french}\n'
    LEXICON += f'{ordinal_key(key)}|{ordinal}us|{rank}\n'
    # singuli/bini/terni are lexical plurals; their stored headword reflects it.
    LEXICON += f'{distributive_key(key)}|{distributive}ī|{french} chacun\n'
    LEXICON += f'{frequency_key(key)}|{adverb}|'+('une fois' if key=='unus' else french+' fois')+'\n'


def add(mode, topic, suffix, latin, correct, wrong, vocab, explanation, french=None):
    place='theatrum' if mode=='lectio' else 'templum'
    f=dict(id=f'{mode}-numerus-{topic}-{suffix}',place=place,
        section='numerorum-sensus' if mode=='lectio' else 'numeris-exprimere',
        sectionName='Numerōrum sēnsūs' if mode=='lectio' else 'Numerīs exprimere',
        card=str(topic),name={1:'Quot?',2:'Quō ordine?',3:'Quot singulī?',4:'Quotiēns?'}[topic],
        skill=f'{mode}.curriculum.numerals.{topic}',latin=latin,correct=correct,wrong=wrong,
        vocabulary=vocab.split(),explanation=explanation,actorPool='artifices',maxVariants=2400,
        task='interpretatio-numerorum' if mode=='lectio' else 'compositio-numerorum')
    if french is not None: f['french']=french
    FRAMES.append(f)

for key, cardinal, ordinal, distributive, adverb, french, rank in NUMBERS:
    counted='{n.'+key+'_counted}'
    ranked='{n.'+key+'_ranked}'
    repeated=adverb+' {n.same} {n.acc}'
    frcount='{n.'+key+'_frcount}'
    frrank='{n.'+key+'_frrank}'
    frfreq='une fois' if key=='unus' else french+' fois'
    add('lectio',1,key,'{a.nom} '+counted+' videt.',
        '{a.fr} voit '+frcount+'.',
        ['{a.fr} voit '+frrank+'.',
         '{a.fr} voit '+frfreq+' {n.frarticle} même {n.fr}.'],
        key+' video', 'Numerus cardinālis quot animālia videantur dīcit, nōn ordinem aut frequentiam.')
    add('compositio',1,key,'{a.nom} ___ videt.',counted,[ranked,repeated],
        key+' '+ordinal_key(key)+' '+frequency_key(key)+' idem video',
        'Numerus cardinālis quantitatem exprimit et, sī variātur, cum nōmine congruit.',
        '{a.fr} voit '+frcount+'. Il s’agit du nombre d’animaux distincts.')
    # Reading distributes observations over two named people. A collective
    # cardinal is not evidence that each person sees that many animals.
    add('lectio',3,key,
        '{a.nom} et {b.nom} {n.'+key+'_distributed} vident.',
        '{a.fr} et {b.fr} voient chacun '+frcount+'.',
        ['{a.fr} et {b.fr} voient '+frcount+' au total, sans préciser combien chacun en voit.',
         '{a.fr} et {b.fr} voient chacun '+frrank+'.'],
        distributive_key(key)+' et video', 'Numerus distribūtīvus ad singulōs pertinet: nōn summa commūnis datur.')
    # Formulation explicitly requests per-person distribution.
    add('compositio',3,key,
        '{a.nom} et {b.nom} ___ vident.', '{n.'+key+'_distributed}',
        [counted,ranked],
        distributive_key(key)+' '+key+' '+ordinal_key(key)+' et video',
        'Cum subiectīs plūribus distribūtīvus ostendit quot animālia quisque videat.',
        '{a.fr} et {b.fr} voient chacun '+frcount+'. La répartition par personne doit être exprimée.')
    add('lectio',4,key,'{a.nom} '+repeated+' videt.',
        '{a.fr} voit '+frfreq+' {n.frarticle} même {n.fr}.',
        ['{a.fr} voit {n.'+key+'_frdistinct}.',
         '{a.fr} voit '+frrank+'.'],
        frequency_key(key)+' idem video', 'Adverbium numerāle quotiēns actiō fiat indicat; idem animal iterum vidērī potest.')
    add('compositio',4,key,'{a.nom} ___ spectat.',repeated,[counted,ranked],
        frequency_key(key)+' '+key+' '+ordinal_key(key)+' idem specto',
        'Frequentia actiōnis adverbiō numerālī exprimitur, nōn numerō animālium.',
        '{a.fr} observe '+frfreq+' {n.frarticle} même {n.fr}.')
    add('compositio',2,key,
        '{a.nom} {n.accpl} numerat; ___ spectat.',ranked,[counted,repeated],
        ordinal_key(key)+' '+key+' '+frequency_key(key)+' idem numero specto',
        'Ordō ūnīus animālis numerō ōrdinālī exprimitur; cāsus et genus cum nōmine congruunt.',
        '{a.fr} compte les {n.frpl} ; il observe '+frrank+'.')
# Interpretation of ordinal order uses connected observations, rather than
# simply reversing the French cue from the formulation bank.
for left,right in [('unus','duo'),('duo','tres'),('tres','quattuor'),('quattuor','quinque'),('quinque','sex'),('sex','septem'),('septem','octo'),('novem','decem'),('decem','viginti'),('viginti','centum')]:
    add('lectio',2,left+'-'+right,
        '{a.nom} {n.'+left+'_ranked} videt, deinde {n.'+right+'_ranked}.',
        '{a.fr} voit {n.'+left+'_frrank}, puis {n.'+right+'_frrank}.',
        ['{a.fr} voit {n.'+right+'_frrank}, puis {n.'+left+'_frrank}.',
         '{a.fr} voit {n.'+left+'_frcount}, puis {n.'+right+'_frcount}.'],
        ordinal_key(left)+' '+ordinal_key(right)+' video deinde',
        'Numerī ōrdinālēs locum in seriē dēsignant; deinde ordinem actiōnum servat.')

# Teach quantity, then rank, per-person distribution, and frequency.
FRAMES.sort(key=lambda frame: (frame['place'], int(frame['card'])))

# The four curriculum objectives compose reusable distinctions. They are never
# assessed directly; the same fine skill is reused by multiple cards.
SKILLS = []
DISTINCTIONS = {
    'quantitas-ordo': 'Quantitātem ab ordine distinguere',
    'quantitas-frequentia': 'Quantitātem ā frequentiā distinguere',
    'ordo-frequentia': 'Ordinem ā frequentiā distinguere',
    'quantitas-distributio': 'Quantitātem commūnem ā distribūtiōne distinguere',
    'ordo-distributio': 'Ordinem ā distribūtiōne distinguere',
    'series-ordinalis': 'Seriem ōrdinālem interpretārī',
}
for mode in ['lectio', 'compositio']:
    for suffix, name in DISTINCTIONS.items():
        # Only reading asks learners to interpret the order of two successive
        # ordinal observations. Production does not claim that evidence.
        if mode == 'compositio' and suffix == 'series-ordinalis': continue
        SKILLS.append(dict(id=f'{mode}.numeri.{suffix}',name=name,visible=False,
            parent=mode+'.curriculum.numerals',
            requires=[mode+'.subject-number',mode+'.agent-patient']+
                ([mode+'.curriculum.pronouns.4'] if 'frequentia' in suffix else [])))
for frame in FRAMES:
    mode = 'lectio' if frame['place']=='theatrum' else 'compositio'
    distinctions = {
        '1': ['quantitas-ordo','quantitas-frequentia'],
        '2': ['series-ordinalis','quantitas-ordo'] if mode=='lectio' else ['quantitas-ordo','ordo-frequentia'],
        '3': ['quantitas-distributio','ordo-distributio'],
        '4': ['quantitas-frequentia','ordo-frequentia'],
    }[frame['card']]
    frame['assessedSkills'] = [f'{mode}.numeri.{suffix}' for suffix in distinctions]
    frame['wrongSkills'] = [[skill] for skill in frame['assessedSkills']]

for frame in FRAMES:
    frame['supportingSkills'] = sorted({ref for node in SKILLS if node['id'] in frame['assessedSkills'] for ref in node['requires']})
