"""Verb constructions: voice, experiencers, impersonal clauses and government."""
FRAMES=[]
SKILLS=[]
LEXICON='''
sequor|sequor|suivre
hortor|hortor|encourager
conor|cōnor|essayer
proficiscor|proficīscor|partir
loquor|loquor|parler
moror|moror|s’attarder
revertor|revertor|revenir
patior|patior|supporter
vereor|vereor|craindre
polliceor|polliceor|promettre
gaudeo|gaudeō|se réjouir
audeo|audeō|oser
soleo|soleō|avoir l’habitude
confido|cōnfīdō|avoir confiance
licet|licet|il est permis
oportet|oportet|il faut
paenitet|paenitet|regretter
pudet|pudet|avoir honte
taedet|taedet|être las
miseret|miseret|avoir pitié
piget|piget|éprouver du déplaisir
odi|ōdī|haïr
memini|meminī|se souvenir
coepi|coepī|commencer
inquam|inquam|dire
utor|ūtor|utiliser
fruor|fruor|jouir de
fungor|fungor|s’acquitter de
vescor|vēscor|se nourrir de
potior|potior|s’emparer de
faveo|faveō|être favorable à
parco|parcō|épargner
servio|serviō|servir
obtempero|obtemperō|obéir à
credo|crēdō|croire, faire confiance
persuadeo|persuādeō|persuader
civis|cīvis|citoyen
error|error|erreur
mendacium|mendācium|mensonge
mora|mora|retard
labor|labor|travail
puer|puer|enfant
miles|mīles|soldat
dominus|dominus|maître de maison
servus|servus|esclave
discipulus|discipulus|élève
magister|magister|maître
amicus|amīcus|ami
hostis|hostis|ennemi
victoria|victōria|victoire
periculum|perīculum|danger
munus|mūnus|charge, cadeau
consilium|cōnsilium|conseil, projet
pax|pāx|paix
cibus|cibus|nourriture
urbs|urbs|ville
gladius|gladius|épée
auxilium|auxilium|aide
natura|nātūra|nature
lex|lēx|loi
civitas|cīvitās|cité
beneficium|beneficium|bienfait
iniuria|iniūria|injustice
bellum|bellum|guerre
fraus|fraus|tromperie
nomen|nōmen|nom
iter|iter|trajet
locus|locus|lieu
mos|mōs|coutume
ianua|iānua|porte de maison
tabula|tabula|tablette
litterae|litterae|lettre, lettres
verbum|verbum|mot
metus|metus|crainte
fames|famēs|faim
sitis|sitis|soif
frigus|frīgus|froid
dolor|dolor|douleur
sum|sum|être
et|et|et
in|in|dans
ad|ad|vers
a|ā|par, loin de
non|nōn|ne pas
iam|iam|déjà
nunc|nunc|maintenant
heri|herī|hier
olim|ōlim|autrefois
hodie|hodiē|aujourd’hui
saepe|saepe|souvent
semper|semper|toujours
hic|hic|celui-ci
is|is|celui-ci
ego|ego|moi
meus|meus|mon
suus|suus|son propre
cum|cum|avec, lorsque
sine|sine|sans
quis|quis|qui
venio|veniō|venir
redeo|redeō|revenir
ambulo|ambulō|marcher
curro|currō|courir
pugno|pugnō|combattre
vivo|vīvō|vivre
eo|eō|aller
laboro|labōrō|travailler
rideo|rīdeō|rire
cano|canō|chanter
taceo|taceō|se taire
maneo|maneō|rester
aperio|aperiō|ouvrir
claudo|claudō|fermer
porto|portō|porter
do|dō|donner
scribo|scrībō|écrire
lego|legō|lire
exspecto|exspectō|attendre
audio|audiō|entendre
dico|dīcō|dire
habeo|habeō|avoir
'''
DEFINITIONS={
 'praeteritum-praesens':('Praesēns ā praeteritō distinguere',['trait.tempus']),
 'deponens-agens':('Sēnsum actīvum fōrmae dēpōnentis intellegere',['agent-patient','voice']),
 'deponens-forma':('Fōrmam dēpōnentem ad sēnsum actīvum ēligere',['voice']),
 'semideponens-perfectum':('Perfectum sēmidēpōnentis compōnere',['imperfect-perfect']),
 'impersonale-persona':('Persōnam in cōnstrūctiōne impersonālī reperīre',['agent-patient']),
 'licentia-dativus':('Datīvum persōnae cum licet pōnere',['recipient']),
 'necessitas-accusativus':('Accūsātīvum persōnae cum oportet pōnere',['agent-patient']),
 'affectus-persona':('Persōnam affectam accūsātīvō expressam agnōscere',['agent-patient']),
 'affectus-accusativus':('Persōnam affectam in accūsātīvō pōnere',['agent-patient']),
 'affectus-genitivus':('Causam affectūs in genitīvō pōnere',['possessor-case']),
 'perfectum-praesens':('Perfectum fōrmā praesēns sēnsū intellegere',['imperfect-perfect']),
 'oratio-persona':('Persōnam in verbīs rēctīs servāre',['curriculum.reported-speech.5']),
 'passivum-impersonale':('Passīvum sine subiectō nōminātīvō intellegere',['voice']),
 'impersonale-numerus':('Passīvum impersonāle singulāre compōnere',['subject-number','voice']),
 'regimen-ablativi':('Ablātīvum ā verbō postulātum ēligere',['instrument-case']),
 'regimen-dativi':('Datīvum ā verbō postulātum ēligere',['recipient']),
 'regimen-partes':('Partēs nōminum ex verbī rēgimine intellegere',['agent-patient']),
}
for mode in ['lectio','compositio']:
 for key,(name,requires) in DEFINITIONS.items():
  SKILLS.append(dict(id=f'{mode}.verba.{key}',name=name,visible=False,parent=mode+'.curriculum.verb-meaning',requires=[s if s.startswith('trait.') else mode+'.'+s for s in requires]))
EXPL={
 'verba.praeteritum-praesens':'Praeteritum rem ante tempus praesēns sitam indicat; actiō praesēns et actiō praeterita nōn idem tempus habent.',
 'past-anteriority':'Plusquamperfectum actiōnem ante aliud tempus praeteritum sitam exprimit; perfectum simplex hanc relātiōnem nōn per sē exprimit.',
 'verba.deponens-agens':'Fōrma dēpōnēns hīc sēnsum actīvum habet. Terminātiō passīva nōn per sē significat subiectum actiōnem aliēnam patī.',
 'verba.deponens-forma':'Hoc verbum dēpōnēns est. Fōrma in -tur subiectī actiōnem exprimit; fōrma actīva ficta nōn substituenda est.',
 'verba.semideponens-perfectum':'Sēmidēpōnēns in perfectō participium cum esse adhibet, sed sēnsum actīvum servat.',
 'verba.impersonale-persona':'Persōna cui aliquid licet datīvō exprimitur; persōna quam aliquid facere oportet accūsātīvō exprimitur. Fōrma impersonālis alteram persōnam nōn fingit.',
 'verba.licentia-dativus':'Licet persōnam cui licentia datur in datīvō postulat.',
 'verba.necessitas-accusativus':'Oportet cum īnfīnītīvō persōnam agentem in accūsātīvō postulat.',
 'verba.affectus-persona':'Cum paenitet, pudet, taedet, miseret et piget, persōna affecta accūsātīvō, causa affectūs genitīvō exprimitur.',
 'verba.affectus-accusativus':'Persōna quae hunc affectum sentit accūsātīvum, nōn nōminātīvum vel datīvum, postulat.',
 'verba.affectus-genitivus':'Causa affectūs cum hōc verbō in genitīvō ponitur; accūsātīvus persōnae affectae servātur.',
 'verba.perfectum-praesens':'Ōdī et meminī fōrmam perfectī habent sed hīc affectum vel memoriam praesentem significant. Nōn omne perfectum rem tantum praeteritam exprimit.',
 'verba.oratio-persona':'Ego in verbīs rēctīs ad loquentem refertur et prīmam persōnam verbī postulat; inquit hanc persōnam nōn mūtat.',
 'verba.passivum-impersonale':'Passīvum impersonāle actiōnem sine subiectō nōminātīvō exprimit. Aliquī agunt, sed nōn dīcitur aliquōs hanc actiōnem patī.',
 'verba.impersonale-numerus':'Passīvum impersonāle tertiam persōnam singulārem habet, etiam sī multī hominēs agunt.',
 'verba.regimen-ablativi':'Ūtor, fruor, fungor et vēscor hīc ablātīvum regunt; nōmen nōn in accūsātīvō obiectī ordināriī ponitur.',
 'verba.regimen-dativi':'Hoc verbum datīvum regit; cāsus ex rēgimine verbī, nōn ex trānslātiōne Gallicā, ēligendus est.',
 'verba.regimen-partes':'Nōminātīvus subiectum indicat. Nōmen oblīquum ex rēgimine verbī pendet; subiectum et complementum nōn permūtantur.',
 'imperfect-perfect':'Hīc tempus actiōnis vel initium eius ex fōrmā verbī et contextū reperitur; praeteritum et praesēns nōn confundenda sunt.',
}

def add(mode,topic,key,latin,correct,wrong,words,skills,failures=None,french=None):
 if failures is None:failures=[skills]*len(wrong)
 FRAMES.append(dict(id=f'{mode}-verba-{topic}-{key}',place='theatrum' if mode=='lectio' else 'templum',
  section='verbis-intellegendis' if mode=='lectio' else 'verbis-utendis',
  sectionName='Verbōrum proprietātēs intellegere' if mode=='lectio' else 'Verbīs rēctē ūtī',
  card=str(topic),name={1:'Verba dēpōnentia',2:'Verba sēmidēpōnentia',3:'Verba impersonālia',4:'Verba dēfectīva',5:'Passīvum impersonāle',6:'Verbōrum rēgimen'}[topic],
  skill=f'{mode}.curriculum.verb-meaning.{topic}',assessedSkills=[mode+'.'+s for s in skills],wrongSkills=[[mode+'.'+s for s in f] for f in failures],
  latin=latin,correct=correct,wrong=wrong,vocabulary=words.split(),explanation=' '.join(EXPL[s] for s in skills),
  actorPool='artifices',task='interpretatio-verborum' if mode=='lectio' else 'compositio-verborum',
  **({'french':french} if french is not None else {})))

# Morphological voice must not reverse the roles of a deponent clause.
for key,verb,active,obj,fr,wrong,words in [
 ('sequor','sequitur','sequit','amīcum','suit l’ami','est suivi par l’ami','amicus'),
 ('hortor','hortātur','hortat','magistrum','encourage le maître','est encouragé par le maître','magister'),
 ('vereor','verētur','veret','hostem','craint l’ennemi','est craint par l’ennemi','hostis'),
 ('polliceor','pollicētur','pollicet','amīcō auxilium','promet de l’aide à l’ami','reçoit une promesse d’aide de l’ami','amicus auxilium'),
]:
 add('lectio',1,key,'{a.nom} '+obj+' '+verb+'.','{a.fr} '+fr+'.',['{a.fr} '+wrong+'.'],key+' '+words,['verba.deponens-agens'])
 add('compositio',1,key,'{a.nom} '+obj+' ___.',verb,[active],key+' '+words,['verba.deponens-forma'],french='{a.fr} '+fr+'.')

# Semideponents: real perfects, not invented passive meanings. Four verbs supply
# independent diagnostic stimuli; neither the complement nor its lexicon is scored.
for key,form,wrong,present,latin,fr,frnow,words in [
 ('gaudeo','gāvīsus est','gauduit','gaudet','victōriā','s’est réjoui de la victoire','se réjouit de la victoire','victoria'),
 ('audeo','ausus est','auduit','audet','loquī','a osé parler','ose parler','loquor'),
 ('soleo','solitus est','soluit','solet','hīc manēre','avait l’habitude de rester ici','a l’habitude de rester ici','hic maneo'),
 ('confido','cōnfīsus est','cōnfīdit','cōnfīdit','amīcō','a fait confiance à l’ami','fait confiance à l’ami','amicus'),
]:
 add('lectio',2,key,'Ōlim {a.nom} '+latin+' '+form+'.','Autrefois, {a.fr} '+fr+'.',
   ['{a.fr} '+frnow+' maintenant.','Le sujet nommé subit l’action d’un agent extérieur ; la forme décrit un passif.'],key+' '+words+' sum olim',['verba.praeteritum-praesens','verba.deponens-agens'],[['verba.praeteritum-praesens'],['verba.deponens-agens']])
 add('compositio',2,key,'Ōlim {a.nom} '+latin+' ___.',form,[wrong],key+' '+words+' sum olim',
   ['verba.semideponens-perfectum'],french='Autrefois, {a.fr} '+fr+'.')

# Case government is assessed here; lexical recall stays in Vocābula.
for key,nom,dat,acc,inf,fr,words in [
 ('citizen','cīvis','cīvī','cīvem','loquī','le citoyen parle','civis loquor'),
 ('child','puer','puerō','puerum','redīre','l’enfant revienne','puer redeo'),
 ('soldier','mīles','mīlitī','mīlitem','manēre','le soldat reste','miles maneo'),
 ('student','discipulus','discipulō','discipulum','proficīscī','l’élève parte','discipulus proficiscor'),
]:
 for necessary in [False,True]:
  modal='oportet' if necessary else 'licet';case=acc if necessary else dat
  correct=('Il faut que '+fr+'.') if necessary else {
   'citizen':'Le citoyen a la permission de parler.',
   'child':'L’enfant a la permission de revenir.',
   'soldier':'Le soldat a la permission de rester.',
   'student':'L’élève a la permission de partir.',
  }[key]
  skill='verba.necessitas-accusativus' if necessary else 'verba.licentia-dativus'
  add('lectio',3,key+str(necessary),case+' '+inf+' '+modal+'.',correct,
    ['La personne nommée donne elle-même cet ordre ou cette permission à quelqu’un d’autre.'],
    words+' '+modal,['verba.impersonale-persona'])
  add('compositio',3,key+str(necessary),'___ '+inf+' '+modal+'.',case,[nom,dat if necessary else acc],
    words+' '+modal,[skill],french=correct)

for key,acc,nom,dat,gen,accobj,ablobj,fr,wrong,words in [
 ('paenitet','cīvem','cīvis','cīvī','errōris','errōrem','errōre','Le citoyen regrette l’erreur.','Quelqu’un regrette le citoyen.','civis error'),
 ('pudet','puerum','puer','puerō','mendāciī','mendācium','mendāciō','L’enfant a honte du mensonge.','Quelqu’un a honte de l’enfant.','puer mendacium'),
 ('taedet','mīlitem','mīles','mīlitī','morae','moram','morā','Le soldat est las du retard.','Quelqu’un est las du soldat.','miles mora'),
 ('miseret','dominum','dominus','dominō','servī','servum','servō','Le maître de maison a pitié de l’esclave.','L’esclave a pitié du maître de maison.','dominus servus'),
 ('piget','discipulum','discipulus','discipulō','labōris','labōrem','labōre','L’élève éprouve du déplaisir à cause du travail.','Quelqu’un éprouve du déplaisir à cause de l’élève.','discipulus labor'),
]:
 add('lectio',3,key,acc+' '+gen+' '+key+'.',fr,[wrong],key+' '+words,['verba.affectus-persona'])
 add('compositio',3,key+'-person','___ '+gen+' '+key+'.',acc,[nom,dat],key+' '+words,['verba.affectus-accusativus'],french=fr)
 add('compositio',3,key+'-cause',acc+' ___ '+key+'.',gen,[accobj,ablobj],key+' '+words,['verba.affectus-genitivus'],french=fr)

# Defective perfects with present meaning, contrasted with coepi's past inception.
for key,obj,fr,words in [('war','bellum','la guerre','bellum'),('fraud','fraudem','la tromperie','fraus'),('injustice','iniūriam','l’injustice','iniuria'),('lie','mendācium','le mensonge','mendacium')]:
 add('lectio',4,'odi-'+key,'{a.nom} '+obj+' ōdit.','{a.fr} déteste '+fr+' actuellement.',
   ['{a.fr} avait détesté '+fr+'.'],words+' odi',['verba.perfectum-praesens'])
 add('compositio',4,'odi-'+key,'{a.nom} '+obj+' ___.','ōdit',['ōderat'],words+' odi',['verba.perfectum-praesens'],french='{a.fr} déteste '+fr+' actuellement.')
for key,obj,fr,words in [('name','nōmen','du nom','nomen'),('journey','iter','du trajet','iter'),('place','locum','du lieu','locus'),('benefit','beneficium','du bienfait','beneficium')]:
 add('lectio',4,'memini-'+key,'{a.nom} '+obj+' meminit.','{a.fr} se souvient actuellement '+fr+'.',
   ['{a.fr} s’était souvenu '+fr+'.'],words+' memini',['verba.perfectum-praesens'])
 add('compositio',4,'memini-'+key,'{a.nom} '+obj+' ___.','meminit',['meminerat'],words+' memini',['verba.perfectum-praesens'],french='{a.fr} se souvient actuellement '+fr+'.')
for key,inf,fr in [('scribo','scrībere','écrire'),('lego','legere','lire'),('cano','canere','chanter'),('laboro','labōrāre','travailler')]:
 add('lectio',4,'coepi-'+key,'{a.nom} '+inf+' coepit.','{a.fr} a commencé à '+fr+'.',
   ['{a.fr} commence seulement maintenant ; aucun début antérieur n’est exprimé.'],key+' coepi',['verba.praeteritum-praesens'])
 add('compositio',4,'coepi-'+key,'{a.nom} '+inf+' ___.','coepit',['coeperat'],key+' coepi',['past-anteriority'],french='{a.fr} a commencé à '+fr+'.')
# Parenthetic inquit does not turn the quoted first person into reported third person.
for key,direct,indirect,fr,words in [('come','veniō','venit','viens','venio'),('stay','maneō','manet','reste','maneo'),('hear','audiō','audit','entends','audio'),('wait','exspectō','exspectat','attends','exspecto')]:
 quoted=('J’' if fr[0] in 'aeiou' else 'Je ')+fr
 add('lectio',4,'inquit-'+key,'«Ego», inquit {a.nom}, «'+direct+'.»','{a.fr} dit : « '+quoted+'. »',
   ['{a.fr} dit qu’une autre personne accomplit cette action.'],words+' ego inquam',['verba.oratio-persona'])
 add('compositio',4,'inquit-'+key,'«Ego», inquit {a.nom}, «___.»',direct,[indirect],words+' ego inquam',['verba.oratio-persona'],french='{a.fr} dit : « '+quoted+'. »')

# Impersonal passive with both zero and plural human context: plural actors do
# not license a plural impersonal verb.
for key,form,plural,fr in [('eo','ītur','euntur','on va'),('curro','curritur','curruntur','on court'),('pugno','pugnātur','pugnantur','on combat'),('vivo','vīvitur','vīvuntur','on vit')]:
 add('lectio',5,key,'Hīc '+form+'.','Ici, '+fr+'.',['Le texte désigne des personnes qui subissent cette action comme sujets du verbe.'],key+' hic',['verba.passivum-impersonale'])
 add('compositio',5,key,'Hīc ___.',form,[plural],key+' hic',['verba.impersonale-numerus'],french='Ici, '+fr+'.')

for key,verb,abl,acc,dat,fr,words in [('utor','ūtitur','gladiō','gladium','gladiō','utilise l’épée','gladius'),('fruor','fruitur','pāce','pācem','pācī','jouit de la paix','pax'),('fungor','fungitur','mūnere','mūnus','mūnerī','s’acquitte de sa charge','munus'),('vescor','vēscitur','cibō','cibum','cibō','consomme de la nourriture','cibus')]:
 # Dative and ablative coincide for two nouns: never offer the same surface as
 # a wrong case. The accusative contrasts with all four genuine ablatives.
 add('lectio',6,key,'{a.nom} '+verb+' '+abl+'.','{a.fr} '+fr+'.',
   ['La forme verbale a un sens passif : le sujet nommé subit l’action d’un autre agent.'],
   key+' '+words,['verba.deponens-agens'])
 add('compositio',6,key,'{a.nom} '+verb+' ___.',abl,[acc],key+' '+words,['verba.regimen-ablativi'],french='{a.fr} '+fr+'.')
for key,verb,dat,acc,nom,fr,reverse,words in [
 ('faveo','favet','amīcō','amīcum','amīcus','est favorable à l’ami','L’ami est favorable {a.to}.','amicus'),
 ('parco','parcit','hostī','hostem','hostis','épargne l’ennemi','L’ennemi épargne {a.fr}.','hostis'),
 ('servio','servit','dominō','dominum','dominus','sert le maître de maison','Le maître de maison sert {a.fr}.','dominus'),
 ('obtempero','obtemperat','magistrō','magistrum','magister','obéit au maître','Le maître obéit {a.to}.','magister'),
 ('credo','crēdit','amīcō','amīcum','amīcus','fait confiance à l’ami','L’ami fait confiance {a.to}.','amicus'),
 ('persuadeo','persuādet','cīvī','cīvem','cīvis','persuade le citoyen','Le citoyen persuade {a.fr}.','civis'),
]:
 add('lectio',6,key,'{a.nom} '+dat+' '+verb+'.','{a.fr} '+fr+'.',[reverse],key+' '+words,['verba.regimen-partes'])
 add('compositio',6,key,'{a.nom} '+verb+' ___.',dat,[acc,nom],key+' '+words,['verba.regimen-dativi'],french='{a.fr} '+fr+'.')

FRAMES.sort(key=lambda f:(f['place'],int(f['card'])))
used={s for f in FRAMES for s in f['assessedSkills']}
SKILLS=[s for s in SKILLS if s['id'] in used]
