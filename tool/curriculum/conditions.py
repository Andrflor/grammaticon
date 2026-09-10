"""Conditional stance and the independent times of condition and consequence."""
FRAMES = []
SKILLS = []
LEXICON = '''
si|sī|si
sed|sed|mais
non|nōn|ne… pas
nunc|nunc|maintenant
heri|herī|hier
dico|dīcō|dire
adsum|adsum|être présent
absum|absum|être absent
iuvo|iuvō|aider
ego|ego|je
habeo|habeō|avoir
pecunia|pecūnia|argent
emo|emō|acheter
cibus|cibus|nourriture
scio|sciō|savoir
via|via|chemin
venio|veniō|venir
audio|audiō|entendre
vox|vōx|voix
respondeo|respondeō|répondre
disco|discō|apprendre
accipio|accipiō|recevoir
litterae|litterae|lettre envoyée
veritas|vēritās|vérité
prudens|prūdēns|prudent
amitto|āmittō|perdre
amicus|amīcus|ami
maneo|maneō|rester
in|in|dans
urbs|urbs|ville
hospes|hospes|hôte
ianua|iānua|porte d’entrée
aperio|aperiō|ouvrir
auxilium|auxilium|aide
peto|petō|demander
liber|liber|livre
lego|legō|lire
sum|sum|être
is|is|celui-ci
'''
DISTINCTIONS = {
    'condicio-causa': 'Condiciōnem ā causā distinguere',
    'aperta': 'Condiciōnem apertam intellegere',
    'potentialis': 'Condiciōnem possibilem fingere',
    'irrealis': 'Condiciōnem contrāriam reī distinguere',
    'tempus-protasis': 'Tempus condiciōnis distinguere',
    'tempus-apodosis': 'Tempus consequentiae distinguere',
}
for mode in ['lectio','compositio']:
    for suffix,name in DISTINCTIONS.items():
        SKILLS.append(dict(id=f'{mode}.condiciones.{suffix}',name=name,visible=False,
            parent=mode+'.curriculum.conditions',
            requires=[mode+'.cause-question'] if suffix=='condicio-causa' else
                     [mode+'.present-future'] if suffix in ['aperta','potentialis'] else
                     [mode+'.imperfect-perfect',mode+'.past-anteriority']))


def add(mode, topic, suffix, latin, correct, wrong, vocab, explanation, french=None, distinctions=None, failures=None):
    if distinctions is None:
        distinctions = {1:['aperta'],2:['potentialis'],3:['irrealis','tempus-protasis','tempus-apodosis'],4:['tempus-protasis','tempus-apodosis']}[topic]
    skills = [f'{mode}.condiciones.{part}' for part in distinctions]
    if failures is None: failures=[distinctions,distinctions]
    f=dict(id=f'{mode}-condicio-{topic}-{suffix}',
        place='theatrum' if mode=='lectio' else 'templum',
        section='condiciones-interpretandae' if mode=='lectio' else 'condiciones-componendae',
        sectionName='Condiciōnēs interpretārī' if mode=='lectio' else 'Condiciōnēs compōnere',
        card=str(topic),name={1:'Condiciō aperta',2:'Condiciō possibilis',3:'Contrā reī vēritātem',4:'Tempora diversa'}[topic],
        skill=f'{mode}.curriculum.conditions.{topic}',assessedSkills=skills,
        supportingSkills=sorted({ref for node in SKILLS if node['id'] in skills for ref in node['requires']}),
        wrongSkills=[[f'{mode}.condiciones.{part}' for part in failed] for failed in failures],
        latin=latin,correct=correct,wrong=wrong,vocabulary=vocab.split(),explanation=explanation,
        actorPool='artifices',task='interpretatio-condicionum' if mode=='lectio' else 'compositio-condicionum')
    if french is not None: f['french']=french
    FRAMES.append(f)

# Reading preserves a speaker's stance. Open conditions do not assert that the
# premise is true; unreal conditions explicitly conflict with the stated facts.
SCENES = [
 ('praesentia','adest','adsit','adesset','adfuisset','mē iuvat','mē iuvet','mē iuvāret','mē iūvisset',
  'est présent','était présent','avait été présent','il m’aide','il m’aiderait','il m’aurait aidé',
  'abest','il est absent','adsum absum ego iuvo'),
 ('pecunia','pecūniam habet','pecūniam habeat','pecūniam habēret','pecūniam habuisset','cibum emit','cibum emat','cibum emeret','cibum ēmisset',
  'a de l’argent','avait de l’argent','avait eu de l’argent','il achète de la nourriture','il achèterait de la nourriture','il aurait acheté de la nourriture',
  'pecūniam nōn habet','il n’a pas d’argent','pecunia habeo cibus emo non'),
 ('via','viam scit','viam sciat','viam scīret','viam scīvisset','venit','veniat','venīret','vēnisset',
  'connaît le chemin','connaissait le chemin','avait connu le chemin','il vient','il viendrait','il serait venu',
  'viam nōn scit','il ne connaît pas le chemin','via scio venio non'),
 ('vox','vocem audit','vocem audiat','vocem audīret','vocem audīvisset','respondet','respondeat','respondēret','respondisset',
  'entend la voix','entendait la voix','avait entendu la voix','il répond','il répondrait','il aurait répondu',
  'vocem nōn audit','il n’entend pas la voix','vox audio respondeo non'),
]
for (key,prot,protpot,protunreal,protpast,apod,apodpot,apodunreal,apodpast,
     frprot,frunreal,frpast,frapod,frapodunreal,frapodpast,fact,frfact,vocab) in SCENES:
    prefix='{a.fr} dit : « '
    add('lectio',1,key,'{a.nom} dīcit: «Sī {b.nom} '+prot+', '+apod+'.»',
        prefix+'Si {b.fr} '+frprot+', '+frapod+'. »',
        [prefix+'Puisque {b.fr} '+frprot+', '+frapod+'. »',
         prefix+'Si {b.fr} '+frunreal+', '+frapodunreal+'. »'],
        'si dico '+vocab,'Sī cum indicātīvō condiciōnem apertam exprimit: condiciō ipsa nōn affirmātur.',
        distinctions=['condicio-causa','aperta'],failures=[['condicio-causa'],['aperta']])
    add('lectio',2,key,'{a.nom} dīcit: «Sī {b.nom} '+protpot+', '+apodpot+'.»',
        prefix+'Si jamais {b.fr} '+frunreal+', '+frapodunreal+'. C’est une éventualité. »',
        [prefix+'Il est certain que {b.fr} '+frprot+' et que '+frapod+'. »',
         prefix+'Si {b.fr} '+frpast+', '+frapodpast+'. Cette occasion est passée. »'],
        'si dico '+vocab,'Coniūnctīvus praesentis rem ut possibilem fingit, nōn ut factum certum aut praeteritum irrēāle.',
        distinctions=['potentialis','tempus-protasis','tempus-apodosis'],
        failures=[['potentialis'],['potentialis','tempus-protasis','tempus-apodosis']])
    add('lectio',3,key,'{a.nom} dīcit: «Sī {b.nom} nunc '+protunreal+', '+apodunreal+'. Sed '+fact+'.»',
        prefix+'Si {b.fr} '+frunreal+' maintenant, '+frapodunreal+'. Mais '+frfact+'. »',
        [prefix+'{b.fr} '+frprot+' maintenant et '+frapod+'. »',
         prefix+'Si {b.fr} '+frpast+' hier, '+frapodpast+'. »'],
        'si dico nunc sed '+vocab,'Imperfectum coniūnctīvī hīc condiciōnem praesentem contrāriam reī exprimit, nōn rem praeteritam.',
        failures=[['irrealis'],['tempus-protasis','tempus-apodosis']])

# Production uses different situations and chooses a consequent while holding
# the premise fixed. It cannot claim to assess a change to that fixed premise.
PRODUCTION = [
 ('hospes','hospes adest','hospes adsit','hospes adesset','iānuam aperit','iānuam aperiat','iānuam aperīret','iānuam aperuisset',
  'un hôte est présent','un hôte était présent','ouvre la porte','ouvrirait la porte','hospes adsum ianua aperio'),
 ('auxilium','{b.nom} auxilium petit','{b.nom} auxilium petat','{b.nom} auxilium peteret','eum iuvat','eum iuvet','eum iuvāret','eum iūvisset',
  '{b.fr} demande de l’aide','{b.fr} demandait de l’aide','l’aide','l’aiderait','auxilium peto is iuvo'),
 ('liber','{b.nom} librum habet','{b.nom} librum habeat','{b.nom} librum habēret','librum legit','librum legat','librum legeret','librum lēgisset',
  '{b.fr} a un livre','{b.fr} avait un livre','lit le livre','lirait le livre','liber habeo lego'),
 ('urbs','{b.nom} in urbe manet','{b.nom} in urbe maneat','{b.nom} in urbe manēret','quoque manet','quoque maneat','quoque manēret','quoque mānsisset',
  '{b.fr} reste dans la ville','{b.fr} restait dans la ville','reste aussi','resterait aussi','in urbs maneo quoque'),
]
LEXICON += '\nquoque|quoque|aussi\n'
for key,prot,pot,unreal,answer,potanswer,unrealanswer,pastanswer,frprot,frunreal,franswer,frunrealanswer,vocab in PRODUCTION:
    add('compositio',1,key,'Sī '+prot+', {a.nom} ___.',answer,[potanswer,unrealanswer],
        'si '+vocab,'Indicātīvus consequentiam sub condiciōne apertā exprimit.',
        'Si '+frprot+', {a.fr} '+franswer+'. Formule cette condition ouverte, sans la présenter comme imaginaire.')
    add('compositio',2,key,'Sī '+pot+', {a.nom} ___.',potanswer,[answer,pastanswer],
        'si '+vocab,'Coniūnctīvus praesentis consequentiam possibilem exprimit.',
        'Si jamais '+frunreal+', {a.fr} '+frunrealanswer+'. Présente cela comme une éventualité à venir.',
        distinctions=['potentialis','tempus-apodosis'],failures=[['potentialis'],['tempus-apodosis']])
    add('compositio',3,key,'Sī '+unreal+', {a.nom} nunc ___.',unrealanswer,[answer,pastanswer],
        'si nunc '+vocab,'Imperfectum coniūnctīvī consequentiam praesentem irrēālem exprimit.',
        'Si '+frunreal+', {a.fr} '+frunrealanswer+' maintenant. Présente la situation comme contraire aux faits actuels.',
        distinctions=['irrealis','tempus-apodosis'],failures=[['irrealis'],['tempus-apodosis']])

# Past counterfactuals are accepted constructions too, not merely distractors.
for (key,prot,protpot,protunreal,protpast,apod,apodpot,apodunreal,apodpast,
     frprot,frunreal,frpast,frapod,frapodunreal,frapodpast,fact,frfact,vocab) in SCENES:
    past_statement = frapodpast.replace('aurait','avait').replace('serait','était')
    add('lectio',3,key+'-praeteritum',
        '{a.nom} dīcit: «Sī {b.nom} herī '+protpast+', '+apodpast+'.»',
        '{a.fr} dit : « Si {b.fr} '+frpast+' hier, '+frapodpast+'. »',
        ['{a.fr} dit : « Il est certain que {b.fr} '+frpast+' hier et que '+past_statement+'. »',
         '{a.fr} dit : « Si {b.fr} '+frunreal+' maintenant, '+frapodunreal+'. »'],
        'si heri dico '+vocab,'Plusquamperfectum coniūnctīvī condiciōnem et consequentiam praeteritās contrāriās reī exprimit.',
        failures=[['irrealis'],['tempus-protasis','tempus-apodosis']])
PAST_PREMISES = {
    'hospes': ('hospes adfuisset','iānuam aperuerat','un hôte avait été présent','aurait ouvert la porte'),
    'auxilium': ('{b.nom} auxilium petīvisset','eum iūverat','{b.fr} avait demandé de l’aide','l’aurait aidé'),
    'liber': ('{b.nom} librum habuisset','librum lēgerat','{b.fr} avait eu un livre','aurait lu le livre'),
    'urbs': ('{b.nom} in urbe mānsisset','quoque mānserat','{b.fr} était resté dans la ville','serait resté aussi'),
}
for key,prot,pot,unreal,answer,potanswer,unrealanswer,pastanswer,frprot,frunreal,franswer,frunrealanswer,vocab in PRODUCTION:
    premise,statement,frpremise,frconsequence=PAST_PREMISES[key]
    add('compositio',3,key+'-praeteritum',
        'Sī '+premise+', {a.nom} herī ___.',pastanswer,[statement,unrealanswer],
        'si heri '+vocab,'Plusquamperfectum coniūnctīvī consequentiam praeteritam irrēālem exprimit.',
        'Si '+frpremise+', {a.fr} '+frconsequence+' hier. Formule cet irréel du passé.',
        distinctions=['irrealis','tempus-apodosis'],failures=[['irrealis'],['tempus-apodosis']])

# Mixed time: the premise and consequence must be located independently.
MIXED = [
 ('doctrina',
  'Sī {b.nom} herī viam didicisset, nunc viam scīret.',
  'Sī {b.nom} nunc viam disceret, nunc viam scīret.',
  'Sī {b.nom} herī viam didicisset, herī viam scīvisset.',
  'Si {b.fr} avait appris le chemin hier, il le connaîtrait maintenant.',
  'Si {b.fr} apprenait le chemin maintenant, il le connaîtrait maintenant.',
  'Si {b.fr} avait appris le chemin hier, il l’aurait connu hier.',
  'via disco scio'),
 ('epistula',
  'Sī {b.nom} herī litterās accēpisset, nunc vēritātem scīret.',
  'Sī {b.nom} nunc litterās acciperet, nunc vēritātem scīret.',
  'Sī {b.nom} herī litterās accēpisset, herī vēritātem scīvisset.',
  'Si {b.fr} avait reçu la lettre hier, il connaîtrait la vérité maintenant.',
  'Si {b.fr} recevait la lettre maintenant, il connaîtrait la vérité maintenant.',
  'Si {b.fr} avait reçu la lettre hier, il aurait connu la vérité hier.',
  'litterae accipio veritas scio'),
 ('prudentia',
  'Sī {b.nom} prūdēns esset, herī viam nōn āmīsisset.',
  'Sī {b.nom} herī prūdēns fuisset, herī viam nōn āmīsisset.',
  'Sī {b.nom} prūdēns esset, nunc viam nōn āmitteret.',
  'Si {b.fr} était prudent, il n’aurait pas perdu le chemin hier.',
  'Si {b.fr} avait été prudent hier, il n’aurait pas perdu le chemin hier.',
  'Si {b.fr} était prudent, il ne perdrait pas le chemin maintenant.',
  'prudens sum via non amitto'),
 ('amicitia',
  'Sī {b.nom} amīcus esset, herī auxilium nōn negāvisset.',
  'Sī {b.nom} herī amīcus fuisset, herī auxilium nōn negāvisset.',
  'Sī {b.nom} amīcus esset, nunc auxilium nōn negāret.',
  'Si {b.fr} était un ami, il n’aurait pas refusé son aide hier.',
  'Si {b.fr} avait été un ami hier, il n’aurait pas refusé son aide hier.',
  'Si {b.fr} était un ami, il ne refuserait pas son aide maintenant.',
  'amicus sum auxilium non nego'),
]
LEXICON += '\nnego|negō|refuser\n'
for key,latin,wrongprot,wrongapod,french,frwrongprot,frwrongapod,vocab in MIXED:
    add('lectio',4,key,'{a.nom} dīcit: «'+latin+'»',
        '{a.fr} dit : « '+french+' »',
        ['{a.fr} dit : « '+frwrongprot+' »','{a.fr} dit : « '+frwrongapod+' »'],
        'si heri nunc dico '+vocab,'Tempus condiciōnis et tempus consequentiae sēparātim distinguenda sunt.',
        failures=[['tempus-protasis'],['tempus-apodosis']])
    # In production the learner formulates the whole conditional sentence.
    add('compositio',4,key,'{a.nom} dīcit: «___»',latin,[wrongprot,wrongapod],
        'si heri nunc dico '+vocab,'Plusquamperfectum ad praeteritum, imperfectum hīc ad praesēns irrēāle pertinet.',
        '{a.fr} dit : « '+french+' »',failures=[['tempus-protasis'],['tempus-apodosis']])
FRAMES.sort(key=lambda f:(f['place'],int(f['card'])))
