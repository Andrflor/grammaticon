"""Independent mood in requests, wishes, possibilities and deliberation.

Food is the actual object of preparation, purchase, preservation or exchange.
It supplies context and vocabulary; sentence success never scores the word.
"""
FRAMES=[]
SKILLS=[]
# id, infinitive, hortative, indicative plural, subjunctive singular 1/3,
# imperfect subjunctive singular/plural, pluperfect subjunctive plural,
# indicative singular 1/2/3, indicative pluperfect plural, perfect subjunctive 2,
# imperative; French infinitive, hortative, plural indicative/subjunctive,
# participle, third-person indicative.
VERBS=[]
for line in '''
paro|parāre|parēmus|parāmus|parem|paret|parārem|parārēmus|parāvissemus|parō|parās|parat|parāverāmus|parāverīs|parā|préparer|préparons|préparons|préparions|préparé|prépare
emo|emere|emāmus|emimus|emam|emat|emerem|emerēmus|ēmissemus|emō|emis|emit|ēmerāmus|ēmerīs|eme|acheter|achetons|achetons|achetions|acheté|achète
porto|portāre|portēmus|portāmus|portem|portet|portārem|portārēmus|portāvissemus|portō|portās|portat|portāverāmus|portāverīs|portā|porter|portons|portons|portions|porté|porte
quaero|quaerere|quaerāmus|quaerimus|quaeram|quaerat|quaererem|quaererēmus|quaesīvissemus|quaerō|quaeris|quaerit|quaesīverāmus|quaesīverīs|quaere|chercher|cherchons|cherchons|cherchions|cherché|cherche
servo|servāre|servēmus|servāmus|servem|servet|servārem|servārēmus|servāvissemus|servō|servās|servat|servāverāmus|servāverīs|servā|conserver|conservons|conservons|conservions|conservé|conserve
divido|dīvidere|dīvidāmus|dīvidimus|dīvidam|dīvidat|dīviderem|dīviderēmus|dīvīsissemus|dīvidō|dīvidis|dīvidit|dīvīserāmus|dīvīserīs|dīvide|partager|partageons|partageons|partagions|partagé|partage
sumo|sūmere|sūmāmus|sūmimus|sūmam|sūmat|sūmerem|sūmerēmus|sūmpsissemus|sūmō|sūmis|sūmit|sūmpserāmus|sūmpserīs|sūme|prendre|prenons|prenons|prenions|pris|prend
mitto|mittere|mittāmus|mittimus|mittam|mittat|mitterem|mitterēmus|mīsissemus|mittō|mittis|mittit|mīserāmus|mīserīs|mitte|envoyer|envoyons|envoyons|envoyions|envoyé|envoie
'''.strip().splitlines():
    fields='id inf hort indpl sub1 sub3 imp1 imppl pluppl ind1 ind2 ind3 indpastpl perfect2 imperative frinf frhort frindpl frsubpl frpp fr3'.split()
    values=line.split('|')
    assert len(fields)==len(values)
    VERBS.append(dict(zip(fields,values)))
LEXICON='''
dico|dīcō|dire
utinam|utinam|pourvu que
forsitan|forsitan|peut-être
quomodo|quōmodō|comment
quando|quandō|quand
unde|unde|d’où
quis|quis|qui
heri|herī|hier
nunc|nunc|maintenant
ne|nē|ne… pas, de peur que
non|nōn|ne… pas
nolo|nōlō|ne pas vouloir
'''
for v in VERBS: LEXICON+=f"\n{v['id']}|{v['ind1']}|{v['frinf']}\n"
DISTINCTIONS={
 'hortatio-assertio':'Hortātiōnem ab affirmātiōne distinguere',
 'hortatio-optatio':'Hortātiōnem ab optātiōne distinguere',
 'optatio-possibilitas':'Optātiōnem ā possibilitāte distinguere',
 'optatio-assertio':'Optātiōnem ab affirmātiōne distinguere',
 'tempus-optationis':'Tempus optātiōnis distinguere',
 'possibilitas-assertio':'Possibilitātem ab affirmātiōne distinguere',
 'deliberatio-indagatio':'Dēlīberātiōnem ab indāgātiōne factī distinguere',
 'tempus-deliberationis':'Tempus dēlīberātiōnis distinguere',
 'prohibitio-assertio':'Prohibitiōnem ab affirmātiōne distinguere',
 'prohibitio-polaritas':'Prohibitiōnem ab iussū affirmātīvō distinguere',
}
for mode in ['lectio','compositio']:
    for suffix,name in DISTINCTIONS.items():
        required=['subject-number']
        if suffix.startswith('prohibitio'): required=['negation-scope']
        elif 'deliberatio' in suffix: required=['question-thing','imperfect-perfect']
        elif suffix=='tempus-optationis': required=['condiciones.irrealis','past-anteriority']
        elif 'possibilitas' in suffix: required=['condiciones.potentialis']
        SKILLS.append(dict(id=f'{mode}.voluntas.{suffix}',name=name,visible=False,
            parent=mode+'.curriculum.subjunctive',requires=[mode+'.'+r for r in required]))

def add(mode,topic,id,latin,correct,wrong,vocab,explanation,distinctions,french=None):
    skills=[f'{mode}.voluntas.{d}' for d in distinctions]
    f=dict(id=f'{mode}-voluntas-{topic}-{id}',place='theatrum' if mode=='lectio' else 'templum',
        section='voluntas-et-consilium' if mode=='lectio' else 'voluntatem-exprimere',
        sectionName='Voluntātem et cōnsilium intellegere' if mode=='lectio' else 'Voluntātem exprimere',
        card=str(topic),name={1:'Hortātiō',2:'Optātiō',3:'Possibilitās',4:'Dēlīberātiō',5:'Prohibitiō'}[topic],
        skill=f'{mode}.curriculum.subjunctive.{topic}',assessedSkills=skills,
        supportingSkills=sorted({r for n in SKILLS if n['id'] in skills for r in n['requires']}),
        wrongSkills=[[s] for s in skills],latin=latin,correct=correct,wrong=wrong,
        vocabulary=vocab.split(),explanation=explanation,actorPool='artifices',maxVariants=1200,
        task='interpretatio-voluntatis' if mode=='lectio' else 'compositio-voluntatis')
    if french is not None: f['french']=french
    FRAMES.append(f)

for mode in ['lectio','compositio']:
    # Each direction uses all eight verbs over the unit, but the formulation
    # tasks are not copies of the corresponding reading situations.
    active=VERBS[:4] if mode=='lectio' else VERBS[4:]
    wishing=VERBS[4:] if mode=='lectio' else VERBS[:4]
    for v in active:
        if mode=='lectio':
            add(mode,1,v['id'],'{a.nom} dīcit: «'+v['hort']+' {f.acc}!»',
                '{a.fr} propose : « '+v['frhort'].capitalize()+' {f.fr} ! »',
                ['{a.fr} constate : « Nous '+v['frindpl']+' {f.fr}. »',
                 '{a.fr} exprime un souhait : « Pourvu que nous '+v['frsubpl']+' {f.fr} ! »'],
                v['id']+' dico','Coniūnctīvus hortātīvus ad actiōnem commūnem invītat.',
                ['hortatio-assertio','hortatio-optatio'])
        else:
            add(mode,1,v['id'],'{a.nom} dīcit: «___ {f.acc}!»',v['hort'],[v['indpl'],'utinam '+v['hort']],
                v['id']+' dico utinam','Hortātiō actiōnem commūnem prōpōnit; neque factum affirmat neque optātiōnem tantum exprimit.',
                ['hortatio-assertio','hortatio-optatio'],
                '{a.fr} propose au groupe : « '+v['frhort'].capitalize()+' {f.fr} ! »')
        if mode=='lectio':
            add(mode,3,v['id'],'{a.nom} dīcit: «Forsitan {b.nom} {f.acc} '+v['sub3']+'.»',
                '{a.fr} envisage une possibilité : « Il se peut que {b.fr} '+({'prépare':'prépare','achète':'achète','porte':'porte','cherche':'cherche'}[v['fr3']])+' {f.fr}. »',
                ['{a.fr} affirme avec certitude que {b.fr} '+v['fr3']+' {f.fr}.',
                 '{a.fr} souhaite que {b.fr} '+v['fr3']+' {f.fr}.'],
                v['id']+' dico forsitan','Forsitan cum coniūnctīvō possibilitātem exprimit, nōn certitūdinem aut optātiōnem.',
                ['possibilitas-assertio','optatio-possibilitas'])
        else:
            add(mode,3,v['id'],'{a.nom} dīcit: «___ {f.acc}.»',
                'forsitan {b.nom} '+v['sub3'],['{b.nom} '+v['ind3'],'utinam {b.nom} '+v['sub3']],
                v['id']+' dico forsitan utinam','Possibilitās cum forsitan et coniūnctīvō exprimitur.',
                ['possibilitas-assertio','optatio-possibilitas'],
                '{a.fr} considère possible que {b.fr} '+{'conserve':'conserve','partage':'partage','prend':'prenne','envoie':'envoie'}[v['fr3']]+' {f.fr}, sans affirmer le fait ni formuler un souhait.')
        # Present and retrospective deliberation use the same fine time axis.
        for past in [False,True]:
            tense='praeteritum' if past else 'praesens'
            form=v['imp1'] if past else v['sub1']
            other=v['sub1'] if past else v['imp1']
            cue='herī ' if past else 'nunc '
            frtime='hier' if past else 'maintenant'
            frmodal='devais' if past else 'dois'
            if mode=='lectio':
                add(mode,4,v['id']+'-'+tense,'{a.nom} dīcit: «Quōmodō '+cue+'{f.acc} '+form+'?»',
                    '{a.fr} délibère : « Comment '+frmodal+'-je '+v['frinf']+' {f.fr} '+frtime+' ? »',
                    ['{a.fr} demande un renseignement sur sa façon habituelle de '+v['frinf']+' {f.fr}, sans délibérer sur ce qu’il doit faire.',
                     '{a.fr} délibère : « Comment '+('dois' if past else 'devais')+'-je '+v['frinf']+' {f.fr} '+('maintenant' if past else 'hier')+' ? »'],
                    v['id']+' dico quomodo '+('heri' if past else 'nunc'),
                    'Coniūnctīvus dēlīberātīvus quaerit quid agendum sit aut fuerit.',
                    ['deliberatio-indagatio','tempus-deliberationis'])
            else:
                # For past deliberation the indicative past question is a
                # factual inquiry, not a different-time error.
                factual={'servo':'servābam','divido':'dīvidēbam','sumo':'sūmēbam','mitto':'mittēbam'}[v['id']] if past else v['ind1']
                add(mode,4,v['id']+'-'+tense,'{a.nom} dīcit: «Quōmodō '+cue+'{f.acc} ___?»',form,[factual,other],
                    v['id']+' dico quomodo '+('heri' if past else 'nunc'),
                    'Dēlīberātiō coniūnctīvum postulat; tempus ad rem dēlīberandam pertinet.',
                    ['deliberatio-indagatio','tempus-deliberationis'],
                    '{a.fr} délibère : « Comment '+frmodal+'-je '+v['frinf']+' {f.fr} '+frtime+' ? »')
        # Negative command and negative assertion are independent distinctions
        # from the polarity of the command itself.
        use_ne=active.index(v)%2==0
        command='nē '+v['perfect2'] if use_ne else 'nōlī '+v['inf']
        if mode=='lectio':
            add(mode,5,v['id'],'{a.nom} dīcit: «'+command+' {f.acc}!»',
                '{a.fr} interdit à son interlocuteur de '+v['frinf']+' {f.fr}.',
                ['{a.fr} décrit une situation où son interlocuteur ne fait pas cette action, sans lui donner d’ordre.',
                 '{a.fr} ordonne au contraire de '+v['frinf']+' {f.fr}.'],
                v['id']+' dico '+('ne' if use_ne else 'nolo'),
                'Nē cum perfectō coniūnctīvī aut nōlī cum īnfīnītīvō prohibitiōnem exprimit.',
                ['prohibitio-assertio','prohibitio-polaritas'])
        else:
            add(mode,5,v['id'],'{a.nom} dīcit: «___ {f.acc}!»',command,['nōn '+v['ind2'],v['imperative']],
                v['id']+' dico non '+('ne' if use_ne else 'nolo'),
                'Prohibitiō nōn est simplex affirmātiō negātīva nec iussum affirmātīvum.',
                ['prohibitio-assertio','prohibitio-polaritas'],
                '{a.fr} interdit à son interlocuteur de '+v['frinf']+' {f.fr}.')
    for v in wishing:
        if mode=='lectio':
            # Subjunctive French after pourvu que: take/prendre is irregular.
            add(mode,2,v['id']+'-possibilis','{a.nom} dīcit: «Utinam '+v['hort']+' {f.acc}!»',
                '{a.fr} souhaite : « Pourvu que nous '+v['frsubpl']+' {f.fr} ! »',
                ['{a.fr} propose au groupe : « '+v['frhort'].capitalize()+' {f.fr} ! »',
                 '{a.fr} envisage simplement la possibilité de '+v['frinf']+' {f.fr}, sans le souhaiter.'],
                v['id']+' dico utinam','Utinam cum praesentī coniūnctīvō optātiōnem possibilem exprimit.',
                ['hortatio-optatio','optatio-possibilitas'])
        else:
            add(mode,2,v['id']+'-possibilis','{a.nom} dīcit: «___ {f.acc}!»','utinam '+v['hort'],[v['hort'],'forsitan '+v['hort']],
                v['id']+' dico utinam forsitan','Utinam optātiōnem, nōn hortātiōnem aut possibilitātem tantum, exprimit.',
                ['hortatio-optatio','optatio-possibilitas'],
                '{a.fr} exprime un souhait réalisable : « Pourvu que nous '+v['frsubpl']+' {f.fr} ! »')
        for past in [False,True]:
            form=v['pluppl'] if past else v['imppl']
            other=v['imppl'] if past else v['pluppl']
            factual=v['indpastpl'] if past else v['indpl']
            frwish='avions '+v['frpp'] if past else v['frsubpl']
            frwrong=v['frsubpl'] if past else 'avions '+v['frpp']
            suffix='praeterita' if past else 'praesens'
            if mode=='lectio':
                add(mode,2,v['id']+'-'+suffix,'{a.nom} dīcit: «Utinam '+('herī ' if past else 'nunc ')+form+' {f.acc}!»',
                    '{a.fr} regrette : « Si seulement nous '+frwish+' {f.fr} '+('hier' if past else 'maintenant')+' ! »',
                    ['{a.fr} regrette : « Si seulement nous '+frwrong+' {f.fr} '+('maintenant' if past else 'hier')+' ! »',
                     '{a.fr} affirme que nous '+('avions '+v['frpp'] if past else v['frindpl'])+' {f.fr}.'],
                    v['id']+' dico utinam '+('heri' if past else 'nunc'),'Imperfectum optātiōnem praesentem irrēālem, plusquamperfectum praeteritam exprimit.',
                    ['tempus-optationis','optatio-assertio'])
            else:
                add(mode,2,v['id']+'-'+suffix,'{a.nom} dīcit: «___ '+('herī' if past else 'nunc')+' {f.acc}!»','utinam '+form,['utinam '+other,factual],
                    v['id']+' dico utinam '+('heri' if past else 'nunc'),'Tempus optātiōnis irrēālis ā tempore praeteritō vel praesentī pendet.',
                    ['tempus-optationis','optatio-assertio'],
                    '{a.fr} exprime un souhait contraire aux faits : « Si seulement nous '+frwish+' {f.fr} '+('hier' if past else 'maintenant')+' ! »')
FRAMES.sort(key=lambda f:(f['place'],int(f['card'])))
