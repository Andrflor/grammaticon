"""Comparison: interpreting rankings versus forming degrees and endings."""
FRAMES = []
LEXICON = '''
longus|longus|long
brevis|brevis|court
gravis|gravis|lourd
levis|levis|léger
omnis|omnis|tout
bonus|bonus|bon
malus|malus|mauvais
magnus|magnus|grand
parvus|parvus|petit
multus|multus|nombreux
quam|quam|que
celeriter|celeriter|rapidement
tarde|tardē|lentement
clare|clārē|clairement
bene|bene|bien
lego|legō|lire
scribo|scrībō|écrire
loquor|loquor|parler
laboro|labōrō|travailler
'''
# All four regular degrees denote measurable physical properties of the objects.
REGULAR = [
 ('longus', 'longior', 'longius', 'longissim', 'long', 'longue'),
 ('brevis', 'brevior', 'brevius', 'brevissim', 'court', 'courte'),
 ('gravis', 'gravior', 'gravius', 'gravissim', 'lourd', 'lourde'),
 ('levis', 'levior', 'levius', 'levissim', 'léger', 'légère'),
]
IRREGULAR = [
 ('bonus', 'melior', 'melius', 'meilleur', 'meilleure'),
 ('malus', 'peior', 'peius', 'pire', 'pire'),
 ('magnus', 'maior', 'maius', 'plus grand', 'plus grande'),
 ('parvus', 'minor', 'minus', 'plus petit', 'plus petite'),
]
ADVERBS = [
 ('celeriter','celerius','celerrimē','rapidement','legit','lego'),
 ('tardē','tardius','tardissimē','lentement','scrībit','scribo'),
 ('clārē','clārius','clārissimē','clairement','loquitur','loquor'),
 ('bene','melius','optimē','bien','labōrat','laboro'),
]

def add(mode, topic, suffix, latin, correct, wrong, vocab, explanation, french=None):
    place = 'theatrum' if mode == 'lectio' else 'templum'
    section = 'res-comparatae' if mode == 'lectio' else 'gradus-adiectivorum'
    name = {'1':'Comparātīvus','2':'Superlātīvus','3':'Comparātiō irrēgulāris','4':'Adverbia comparāta'}[topic]
    f = dict(id=f'{mode}-comparatio-{topic}-{suffix}', place=place, section=section,
        sectionName='Rēs et actiōnēs comparāre' if mode=='lectio' else 'Gradūs compōnere',
        card=topic, name=name, skill=f'{mode}.curriculum.comparison.{topic}',
        latin=latin, correct=correct, wrong=wrong, vocabulary=vocab.split(),
        explanation=explanation, task='interpretatio-comparationis' if mode=='lectio' else 'compositio-graduum',
        actorPool='artifices')
    if french: f['french']=french
    FRAMES.append(f)

for key, comp, neuter, sup, masculine, feminine in REGULAR:
    # Object-specific properties are supplied by the authored gender tables.
    add('lectio','1',key,
        '{o.nom} {a.gen} {o.'+key+'_comp} est quam {o.nom} {b.gen}.',
        '{o.fr} appartenant {a.to} est plus {o.'+key+'_fr} que {o.fr} appartenant {b.to}.',
        ['{o.fr} appartenant {a.to} est moins {o.'+key+'_fr} que {o.fr} appartenant {b.to}.',
         '{o.fr} appartenant {a.to} est aussi {o.'+key+'_fr} que {o.fr} appartenant {b.to}.'],
        key+' sum quam', 'Comparātīvus gradum maiōrem, nōn aequālem aut minōrem, exprimit.')
    add('compositio','1',key,
        '{o.nom} {a.gen} ___ est quam {o.nom} {b.gen}.', '{o.'+key+'_comp}',
        ['{o.'+key+'_positive}','{o.'+key+'_super}'], key+' sum quam',
        'Comparātīvus cum quam comparātiōnem inter duās rēs exprimit. Fōrma cum genere nōminis congruit.',
        '{o.fr} appartenant {a.to} est plus {o.'+key+'_fr} que {o.fr} appartenant {b.to}.')
    add('lectio','2',key,
        '{o.nom} {a.gen} omnium {o.'+key+'_super} est.',
        '{o.fr} appartenant {a.to} est {o.article} plus {o.'+key+'_fr} de tous les objets comparés.',
        ['{o.fr} appartenant {a.to} est {o.article} moins {o.'+key+'_fr} de tous les objets comparés.',
         '{o.fr} appartenant {a.to} est aussi {o.'+key+'_fr} que tous les autres objets comparés.'],
        key+' omnis sum', 'Superlātīvus cum omnium summum gradum inter rēs comparātās dēsignat.')
    add('compositio','2',key,
        '{o.nom} {a.gen} omnium ___ est.', '{o.'+key+'_super}',
        ['{o.'+key+'_positive}','{o.'+key+'_comp}'], key+' omnis sum',
        'Superlātīvus summum gradum cum omnium exprimit; cum nōmine suō genere congruit.',
        '{o.fr} appartenant {a.to} est {o.article} plus {o.'+key+'_fr} de tous les objets comparés.')
for key, comp, neuter, masculine, feminine in IRREGULAR:
    add('lectio','3',key,
        '{o.nom} {a.gen} {o.'+key+'_comp} est quam {o.nom} {b.gen}.',
        '{o.fr} appartenant {a.to} est {o.'+key+'_fr} que {o.fr} appartenant {b.to}.',
        ['{o.fr} appartenant {a.to} est {o.'+key+'_reverse_fr} que {o.fr} appartenant {b.to}.',
         'Les deux objets comparés ont exactement la même qualité ou dimension.'],
        key+' sum quam', 'Comparātīvus irrēgulāris ad gradum positīvum pertinet quamquam fōrma mutātur.')
    add('compositio','3',key,
        '{o.nom} {a.gen} ___ est quam {o.nom} {b.gen}.', '{o.'+key+'_comp}',
        ['{o.'+key+'_positive}','{o.'+key+'_reverse_comp}'], key+' '+dict(bonus='malus',malus='bonus',magnus='parvus',parvus='magnus')[key]+' sum quam',
        'Comparātīvus irrēgulāris sēnsum postulātum et genus nōminis servat.',
        '{o.fr} appartenant {a.to} est {o.'+key+'_fr} que {o.fr} appartenant {b.to}.')
for i,(positive,comp,sup,french,verb,lemma) in enumerate(ADVERBS):
    key={'tardē':'tarde','clārē':'clare'}.get(positive,positive)
    french_comp = 'mieux' if key=='bene' else 'plus '+french
    french_sup = 'le mieux' if key=='bene' else 'le plus '+french
    frverb={'lego':'lit','scribo':'écrit','loquor':'parle','laboro':'travaille'}[lemma]
    add('lectio','4',key,
        '{a.nom} '+comp+' '+verb+' quam {b.nom}.',
        '{a.fr} '+frverb+' '+french_comp+' que {b.fr}.',
        ['{b.fr} '+frverb+' '+french_comp+' que {a.fr}.',
         '{a.fr} '+frverb+' exactement aussi bien ou de la même manière que {b.fr}.'],
        key+' '+lemma+' quam', 'Adverbium comparātīvum modum actiōnis comparat, nōn nōmen describit.')
    add('compositio','4',key,
        '{a.nom} ___ '+verb+' quam {b.nom}.', comp,[positive,sup],
        key+' '+lemma+' quam', 'Adverbium comparātīvum cum quam ēligendum est; positīvum et superlātīvum alium gradum exprimunt.',
        '{a.fr} '+frverb+' '+french_comp+' que {b.fr}.')
# Irregular maxima and adverbial maxima are separate stimuli from comparatives.
for key, stem, masculine, feminine in [
    ('bonus','optim','meilleur','meilleure'),
    ('malus','pessim','pire','pire'),
    ('magnus','maxim','plus grand','plus grande'),
    ('parvus','minim','plus petit','plus petite'),
]:
    add('lectio','3',key+'-super',
        '{o.nom} {a.gen} omnium {o.'+key+'_super} est.',
        '{o.fr} appartenant {a.to} est {o.article} {o.'+key+'_fr} de tous les objets comparés.',
        ['{o.fr} appartenant {a.to} est {o.article} {o.'+key+'_reverse_fr} de tous les objets comparés.',
         'Tous les objets comparés ont exactement la même qualité ou dimension.'],
        key+' omnis sum', 'Optimus, pessimus, maximus et minimus sunt superlātīvī irrēgulārēs.')
    add('compositio','3',key+'-super',
        '{o.nom} {a.gen} omnium ___ est.', '{o.'+key+'_super}',
        ['{o.'+key+'_positive}','{o.'+key+'_comp}'], key+' omnis sum',
        'Superlātīvus irrēgulāris summum gradum inter omnēs exprimit.',
        '{o.fr} appartenant {a.to} est {o.article} {o.'+key+'_fr} de tous les objets comparés.')
for positive, comp, sup, french, verb, lemma in ADVERBS:
    key={'tardē':'tarde','clārē':'clare'}.get(positive,positive)
    frverb={'lego':'lit','scribo':'écrit','loquor':'parle','laboro':'travaille'}[lemma]
    french_sup='le mieux' if key=='bene' else 'le plus '+french
    add('lectio','4',key+'-super',
        '{a.nom} omnium '+sup+' '+verb+'.',
        '{a.fr} '+frverb+' '+french_sup+' de tous.',
        ['Tous '+{'lego':'lisent','scribo':'écrivent','loquor':'parlent','laboro':'travaillent'}[lemma]+' exactement de la même manière.',
         '{a.fr} '+('n’écrit' if lemma=='scribo' else 'ne '+frverb)+' pas.'],
        key+' '+lemma+' omnis', 'Superlātīvus adverbiī gradum actiōnis, nōn qualitatem nōminis, exprimit.')
    add('compositio','4',key+'-super',
        '{a.nom} omnium ___ '+verb+'.', sup, [positive,comp],
        key+' '+lemma+' omnis', 'Omnium cum superlātīvō adverbiī summum gradum actiōnis indicat.',
        '{a.fr} '+frverb+' '+french_sup+' de tous.')
for key, positive, comp, sup, french, subject in [
    ('pulcher','pulcher','pulchrior','pulcherrimus','beau','{a.nom}'),
    ('miser','miser','miserior','miserrimus','malheureux','{a.nom}'),
    ('facilis','facile','facilius','facillimum','facile','opus {a.gen}'),
    ('difficilis','difficile','difficilius','difficillimum','difficile','opus {a.gen}'),
]:
    frsubject='{a.fr}' if key in ['pulcher','miser'] else 'le travail appartenant {a.to}'
    vocab=key+' omnis sum'+(' opus' if key in ['facilis','difficilis'] else '')
    add('lectio','2',key+'-special',subject+' omnium '+sup+' est.',
        frsubject+' est le plus '+french+' de tous.',
        [frsubject+' est le moins '+french+' de tous.',frsubject+' est aussi '+french+' que tous les autres.'],
        vocab, 'Hic superlātīvus litteram r aut l geminat: pulcherrimus, miserrimus, facillimus, difficillimus.')
    add('compositio','2',key+'-special',subject+' omnium ___ est.',sup,[positive,comp],vocab,
        'Superlātīvus huius adiectīvī r aut l geminat et cum nōmine congruit.',
        frsubject+' est le plus '+french+' de tous.')
LEXICON += '\npulcher|pulcher|beau\nmiser|miser|malheureux\nfacilis|facilis|facile\ndifficilis|difficilis|difficile\nopus|opus|travail\n'

# A reviewed cap per frame avoids letting the object cross-product dominate the
# curriculum. Every authored object remains represented in every relevant unit.
for frame in FRAMES:
    frame['maxVariants'] = 2400
