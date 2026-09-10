"""Reported statements, commands, questions and reflexive reference in context."""
FRAMES=[]
SKILLS=[]
LEXICON='''
nauta|nauta|marin
portus|portus|port
navis|nāvis|navire
navigo|nāvigō|naviguer
redeo|redeō|revenir
maneo|maneō|rester
proficiscor|proficīscor|partir
ancora|ancora|ancre
solvo|solvō|détacher
reparo|reparō|réparer
exspecto|exspectō|attendre
paro|parō|préparer
curo|cūrō|soigner
custos|custōs|gardien
porta|porta|porte
claudo|claudō|fermer
puer|puer|enfant
aeger|aeger|malade
medicus|medicus|médecin
remedium|remedium|remède
magister|magister|maître
discipulus|discipulus|élève
liber|liber|livre
lego|legō|lire
scribo|scrībō|écrire
epistula|epistula|lettre
mitto|mittō|envoyer
servus|servus|esclave
dominus|dominus|maître de maison
domus|domus|maison
dico|dīcō|dire
sum|sum|être
in|in|dans
ad|ad|vers
et|et|et
sed|sed|mais
non|nōn|ne pas
iam|iam|déjà
iubeo|iubeō|ordonner
impero|imperō|commander
rogo|rogō|demander
quaero|quaerō|chercher, demander
quis|quis|qui
ubi|ubi|où, quand
cur|cūr|pourquoi
quando|quandō|quand
ut|ut|que
ne|nē|que ne pas
quod|quod|parce que
se|sē|soi
suus|suus|son propre
is|is|celui-ci
ego|ego|moi
meus|meus|mon
hic|hic|celui-ci
venio|veniō|venir
video|videō|voir
voco|vocō|appeler
habeo|habeō|avoir
auxilium|auxilium|aide
peto|petō|demander, chercher à obtenir
nuntius|nūntius|messager
credo|crēdō|croire
puto|putō|penser
nunc|nunc|maintenant
heri|herī|hier
'''
DEFS={
 'nci-relatio':('Rem trāditam ā locūtiōne subiectī distinguere',['infinitive-speaker']),
 'nci-casus':('Subiectum nōminātīvō cum īnfīnītīvō pōnere',['infinitive-case']),
 'iussum-factum':('Iussum ā rē affirmātā distinguere',['command-mood']),
 'iussum-nexus':('Iussum oblīquum ut vel nē intrōdūcere',['command-mood']),
 'quaestio-modus':('Coniūnctīvum in interrogātiōne oblīquā pōnere',['question-statement']),
}
# Existing shared leaves retain their identifiers; no duplicate time/reflexive model.
for mode in ['lectio','compositio']:
 for key,(name,req) in DEFS.items():
  if key in ['nci-relatio','iussum-factum'] and mode=='compositio':continue
  if key in ['nci-casus','quaestio-modus','iussum-nexus'] and mode=='lectio':continue
  SKILLS.append(dict(id=f'{mode}.oratio.{key}',name=name,visible=False,
    parent=mode+'.curriculum.reported-speech',requires=[mode+'.'+r for r in req]))

EXPL={
 'infinitive-before':'Īnfīnītīvus perfectī rem ante verbum dīcendī factam exprimit; praesēns rem eōdem tempore, futūrus rem posteriōrem exprimeret.',
 'infinitive-after':'Īnfīnītīvus futūrī rem post verbum dīcendī futūram exprimit; is nōn rem iam factam affirmat.',
 'infinitive-case':'Subiectum accūsātīvī cum īnfīnītīvō in accūsātīvō ponitur, quamquam subiectum sententiae rēctae nōminātīvum habet.',
 'infinitive-speaker':'Subiectum verbī dīcendī loquitur; subiectum īnfīnītīvī rem relātam agit. Haec subiecta distinguenda sunt.',
 'reported-after':'Post verbum praeteritum īnfīnītīvus futūrī rem posteā futūram, nōn rem iam anteā factam indicat.',
 'oratio.nci-relatio':'In cōnstrūctiōne dīcitur cum īnfīnītīvō aliī rem dē subiectō referunt; subiectum nōn ipsum loquī affirmātur.',
 'oratio.nci-casus':'Post dīcitur persōnāle subiectum nōminātīvō ponitur. Accūsātīvus ad accūsātīvum cum īnfīnītīvō pertinet.',
 'oratio.iussum-factum':'Imperat ut vel nē iussum exprimit; rem factam affirmāre et aliquid imperāre nōn idem sunt.',
 'oratio.iussum-nexus':'Post imperat iussum oblīquum ut vel nē intrōdūcitur; quod hunc nexum iussīvum nōn exprimit.',
 'oratio.quaestio-modus':'Interrogātiō oblīqua coniūnctīvum postulat; indicātīvus interrogātiōnis rēctae hīc nōn servātur.',
 'negation':'Nē in iussō oblīquō rem prohibet; ut sine negātiōne rem agendam iubet.',
 'reflexive-reference':'Sē in hāc ōrātiōne oblīquā ad eum quī loquitur refertur; eum alium virum indicat.',
 'possessive-reflexive':'Suus in hīs verbīs ad loquentem refertur; eius alterīus possessiōnem indicat. Possessor ē contextū reperiendus est.',
 'past-anteriority':'Plusquamperfectum coniūnctīvī rem ante interrogātiōnem praeteritam factam exprimit; imperfectum rem eōdem tempore indicāret.',
 'imperfect-perfect':'Tempus actiōnis cum tempore interrogātiōnis comparandum est; actiō simul gesta ā priōre distinguitur.',
}

def add(mode,topic,key,latin,correct,wrong,words,skills,failures=None,french=None):
 if failures is None:failures=[skills]*len(wrong)
 FRAMES.append(dict(id=f'{mode}-oratio-{topic}-{key}',place='theatrum' if mode=='lectio' else 'templum',
  section='oratio-obliqua' if mode=='lectio' else 'orationem-referre',
  sectionName='Ōrātiōnem oblīquam intellegere' if mode=='lectio' else 'Ōrātiōnem referre',
  card=str(topic),name={1:'Accūsātīvus cum īnfīnītīvō',2:'Nōminātīvus cum īnfīnītīvō',3:'Iussa oblīqua',4:'Interrogātiōnēs in nārrātiōne',5:'Prōnōmina et loquēns'}[topic],
  skill=f'{mode}.curriculum.reported-speech.{topic}',assessedSkills=[mode+'.'+s for s in skills],
  wrongSkills=[[mode+'.'+s for s in f] for f in failures],
  latin=latin,correct=correct,wrong=wrong,vocabulary=words.split(),
  explanation=' '.join(EXPL[s] for s in skills),actorPool='artifices',maxVariants=96,
  task='interpretatio-orationis-obliquae' if mode=='lectio' else 'compositio-orationis-obliquae',
  **({'french':french} if french is not None else {})))

# Four independently authored actions, each with relative anteriority and posteriority.
for key,inf,perfect,future,frpast,frfuture in [
 ('navigo','nāvigāre','nāvigāvisse','nāvigātūrum esse','avait navigué','naviguerait'),
 ('redeo','redīre','rediisse','reditūrum esse','était revenu','reviendrait'),
 ('maneo','manēre','mānsisse','mānsūrum esse','était resté','resterait'),
 ('proficiscor','proficīscī','profectum esse','profectūrum esse','était parti','partirait'),
]:
 for time,form,skill,fr,alts in [
  ('prior',perfect,'infinitive-before',frpast,[frfuture,'agissait exactement au moment où ces paroles étaient prononcées']),
  ('posterior',future,'reported-after',frfuture,[frpast,'agissait exactement au moment où ces paroles étaient prononcées']),
 ]:
  add('lectio',1,key+'-'+time,'Nauta in portū erat. {a.nom} dīxit nautam '+form+'.',
    '{a.fr} a dit que le marin '+fr+'.',
    ['{a.fr} a dit que le marin '+t+'.' for t in alts],
    'nauta in portus sum dico '+key,[skill])
  add('compositio',1,key+'-'+time,'Nauta in portū erat. {a.nom} dīxit nautam ___.',form,
    [inf,future if time=='prior' else perfect], 'nauta in portus sum dico '+key,[skill],
    french='Le marin était au port. {a.fr} a dit que le marin '+fr+'.')
 for mode in ['lectio','compositio']:
  if mode=='lectio':
   add(mode,1,key+'-speaker','{a.nom} dīcit nautam '+inf+'.',
     'C’est {a.fr} qui rapporte l’action du marin.',
     ['C’est le marin qui rapporte l’action {a.to}.','Le marin et {a.fr} parlent tous les deux.'],
     'dico nauta '+key,['infinitive-speaker'])
  else:
   add(mode,1,key+'-case','{a.nom} dīcit ___ '+inf+'.','nautam',['nauta','nautā'],
     'dico nauta '+key,['infinitive-case'],french='{a.fr} dit que le marin '+{'navigo':'navigue','redeo':'revient','maneo':'reste','proficiscor':'part'}[key]+'.')

# Personal passive reporting: the named subject does not become the speaker.
for key,nom,acc,oblique,action,fr,words in [
 ('nauta','nauta','nautam','nautae','ancoram solvere','le marin détache l’ancre','nauta ancora solvo'),
 ('medicus','medicus','medicum','medicō','puerum cūrāre','le médecin soigne l’enfant','medicus puer curo'),
 ('magister','magister','magistrum','magistrō','librum legere','le maître lit le livre','magister liber lego'),
 ('servus','servus','servum','servō','epistulam mittere','l’esclave envoie la lettre','servus epistula mitto'),
]:
 add('lectio',2,key,nom+' dīcitur '+action+'.','On rapporte que '+fr+'.',
   ['La personne nommée déclare elle-même ce qu’elle fait.','La personne nommée reçoit l’ordre d’accomplir cette action.'],
   words+' dico',['oratio.nci-relatio'])
 add('compositio',2,key,'___ dīcitur '+action+'.',nom,[acc,oblique],words+' dico',['oratio.nci-casus'],
   french='On rapporte que '+fr+'.')

# Commands are interpreted as requests, not as proof of execution; production
# chooses polarity and clause type independently within the requested completion.
for key,dat,action,fr,words in [
 ('anchor','nautae','ancoram solvat','le marin détache l’ancre','nauta ancora solvo'),
 ('gate','custōdī','portam claudat','le gardien ferme la porte','custos porta claudo'),
 ('remedy','medicō','remedium paret','le médecin prépare le remède','medicus remedium paro'),
 ('letter','servō','epistulam mittat','l’esclave envoie la lettre','servus epistula mitto'),
]:
 for negative in [False,True]:
  conj='nē' if negative else 'ut'; other='ut' if negative else 'nē'
  instruction=('interdit que ' if negative else 'ordonne que ')+fr
  opposite=('ordonne que ' if negative else 'interdit que ')+fr
  add('lectio',3,key+str(negative),'{a.nom} '+dat+' imperat '+conj+' '+action+'.',
    '{a.fr} '+instruction+'.', ['{a.fr} '+opposite+'.','Le texte affirme que cette action a déjà été exécutée.'],
    words+' impero '+('ne' if negative else 'ut'),['negation','oratio.iussum-factum'],[['negation'],['oratio.iussum-factum']])
  add('compositio',3,key+str(negative),'{a.nom} '+dat+' imperat ___ '+action+'.',conj,[other,'quod'],
    words+' impero ut ne quod',['negation','oratio.iussum-nexus'],[['negation'],['oratio.iussum-nexus']],
    french='{a.fr} '+instruction+'.')

# A short situation provides the question's reference time. The reading task
# reconstructs chronology; the production gap supplies mood or anterior tense.
for key,question,imperfect,pluperfect,indicative,frsim,frprior,words in [
 ('repair','quid nauta','reparāret','reparāvisset','reparābat','ce que le marin réparait','ce que le marin avait réparé','quis nauta reparo'),
 ('read','quid discipulus','legeret','lēgisset','legēbat','ce que l’élève lisait','ce que l’élève avait lu','quis discipulus lego'),
 ('wait','quem custōs','exspectāret','exspectāvisset','exspectābat','qui le gardien attendait','qui le gardien avait attendu','quis custos exspecto'),
 ('write','quid magister','scrīberet','scrīpsisset','scrībēbat','ce que le maître écrivait','ce que le maître avait écrit','quis magister scribo'),
]:
 add('lectio',4,key,'{a.nom} in portū erat. Rogāvit '+question+' '+pluperfect+'.',
   '{a.fr} a demandé '+frprior+', donc ce qui précédait sa question.',
   ['{a.fr} a demandé '+frsim+', exactement au moment de sa question.','La question portait uniquement sur une action encore à venir.'],
   words+' in portus sum rogo',['past-anteriority'])
 add('compositio',4,key+'-tense','{a.nom} in portū erat. Rogāvit '+question+' ___.',pluperfect,[imperfect],
   words+' in portus sum rogo',['past-anteriority'],french='{a.fr} était au port et a demandé '+frprior+'.')
 add('compositio',4,key+'-mood','{a.nom} rogāvit '+question+' ___.',imperfect,[indicative],
   words+' rogo',['oratio.quaestio-modus'],french='{a.fr} a demandé '+frsim+' à ce moment-là.')

# Speakers and possessors are explicitly named in context. These lexical
# persons are not interchangeable scene substitutions.
for key,speaker,other,dat,acc,verb,frspeaker,frother,words in [
 ('doctor','Medicus','nauta','nautae','nautam','venīre','le médecin','le marin','medicus nauta venio'),
 ('master','Magister','discipulus','discipulō','discipulum','redīre','le maître','l’élève','magister discipulus redeo'),
 ('guard','Custōs','servus','servō','servum','manēre','le gardien','l’esclave','custos servus maneo'),
 ('messenger','Nūntius','dominus','dominō','dominum','proficīscī','le messager','le maître de maison','nuntius dominus proficiscor'),
]:
 add('lectio',5,key+'-self',speaker+' '+acc+' vocat. Dīcit sē '+verb+'.',
   'La personne désignée par sē est '+frspeaker+'.',
   ['La personne désignée par sē est '+frother+'.','Sē désigne nécessairement les deux personnes ensemble.'],
   words+' voco dico se',['reflexive-reference'])
 add('compositio',5,key+'-self',speaker+' '+acc+' vocat. Dīcit ___ '+verb+'.','sē',['eum'],
   words+' voco dico se is',['reflexive-reference'],
   french=frspeaker+' appelle '+frother+' et rapporte ensuite sa propre action, à lui qui parle.')
 add('lectio',5,key+'-possession',speaker+' '+dat+' dīcit: «Epistulam meam habeō.» Dīcit sē epistulam suam habēre.',
   'Le propriétaire de la lettre est '+frspeaker+'.',['Le propriétaire de la lettre est '+frother+'.','Le texte dit que la lettre appartient aux deux personnes.'],
   words.split()[0]+' '+words.split()[1]+' dico epistula meus habeo se suus',['possessive-reflexive'])
 add('compositio',5,key+'-possession',speaker+' '+dat+' dīcit: «Epistulam meam habeō.» Dīcit sē epistulam ___ habēre.',
   'suam',['eius'],words.split()[0]+' '+words.split()[1]+' dico epistula meus habeo se suus is',['possessive-reflexive'],
   french='Rapporte les paroles données : '+frspeaker+' dit avoir sa propre lettre.')

FRAMES.sort(key=lambda f:(f['place'],int(f['card'])))
used={s for f in FRAMES for s in f['assessedSkills']}
SKILLS=[s for s in SKILLS if s['id'] in used]
