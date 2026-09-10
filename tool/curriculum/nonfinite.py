"""Participial relations, gerundives, periphrases and the two supines."""
def de(text):
    return ('d’' if text[0].lower() in 'aeiouyàâéèêëîïôùûü' else 'de ') + text


FRAMES=[]
SKILLS=[]
LEXICON='''
saluto|salūtō|saluer
audio|audiō|entendre
video|videō|voir
duco|dūcō|conduire
laudo|laudō|louer
voco|vocō|appeler
moneo|moneō|avertir
invenio|inveniō|trouver
intro|intrō|entrer
urbs|urbs|ville
dico|dīcō|dire
liber|liber|livre
epistula|epistula|lettre
carmen|carmen|chant
mandatum|mandātum|ordre confié
porta|porta|porte
consilium|cōnsilium|conseil, projet
lego|legō|lire
scribo|scrībō|écrire
canto|cantō|chanter
exsequor|exsequor|exécuter
porto|portō|porter
curo|cūrō|soigner
paro|parō|préparer
puer|puer|enfant
donum|dōnum|cadeau
venio|veniō|venir
ad|ad|vers
ab|ab|de, par
in|in|dans
sum|sum|être
proficiscor|proficīscor|partir
redeo|redeō|revenir
navigo|nāvigō|naviguer
laboro|labōrō|travailler
nunc|nunc|maintenant
heri|herī|hier
rogo|rogō|demander
facio|faciō|faire
hic|hic|celui-ci
facilis|facilis|facile
difficilis|difficilis|difficile
mirabilis|mīrābilis|étonnant
iucundus|iūcundus|agréable
'''
DEFINITIONS={
 'tempus-participii':'Tempus participiī distinguere',
 'vox-participii':'Vōcem participiī distinguere',
 'casus-participii':'Participiī cāsum ad nōmen referre',
 'gerundivum-sensus':'Gerundīvī sēnsum intellegere',
 'genus-gerundivi':'Genus gerundīvī cum nōmine congruere',
 'numerus-gerundivi':'Numerum gerundīvī cum nōmine congruere',
 'attractio-accusativi':'Attractiōnem in accūsātīvō compōnere',
 'attractio-genitivi':'Attractiōnem in genitīvō compōnere',
 'attractio-ablativi':'Attractiōnem in ablātīvō compōnere',
 'attractio-sensus':'Actiōnem in gerundīvī attractiōne intellegere',
 'finis-actionis':'Fīnem actiōnis ā tempore distinguere',
 'intentio-actus':'Cōnsilium agendī ab actiōne distinguere',
 'tempus-periphrasticae':'Tempus periphrasticae distinguere',
 'necessitas-factum':'Necessitātem ā factō distinguere',
 'dativus-auctoris':'Auctōrem datīvō expressum intellegere',
 'supinum-regimen':'Supīnī cāsum secundum cōnstrūctiōnem ēligere',
 'supinum-respectus':'Supīnum ad aestimātiōnem referre',
}
for mode in ['lectio','compositio']:
    for suffix,name in DEFINITIONS.items():
        required=['agent-patient']
        if suffix in ['casus-participii','genus-gerundivi','numerus-gerundivi','attractio-accusativi','attractio-genitivi','attractio-ablativi']:required=['adjective-reference']
        if 'tempus' in suffix:required=['imperfect-perfect','past-anteriority']
        if suffix=='finis-actionis':required=['purpose-cause']
        if suffix=='dativus-auctoris':required=['recipient','agent-patient']
        SKILLS.append(dict(id=f'{mode}.nonfinitum.{suffix}',name=name,visible=False,
            parent=mode+'.curriculum.nonfinite',requires=[mode+'.'+r for r in required]))

EXPLANATIONS={
 'tempus-participii':'Participium praesentis actiōnem eōdem tempore gestam, perfectī actiōnem priōrem, futūrī actiōnem posteram exprimit.',
 'vox-participii':'Participia perfectī horum verbōrum passīva sunt: subiectum laudātur, vocātur, monētur aut invenītur; nōn ipsum hanc actiōnem agit.',
 'casus-participii':'Participium ad subiectum huius sententiae pertinet et nōminātīvum postulat. Cāsus oblīquus aliud nōmen indicāret.',
 'genus-gerundivi':'Gerundīvum eōdem genere ac nōmen suum ponitur: liber legendus, epistula scrībenda, carmen cantandum.',
 'numerus-gerundivi':'Nōmen plūrāle gerundīvum plūrāle postulat: librī legendī, epistulae scrībendae, dōna portanda.',
 'gerundivum-sensus':'Gerundīvum attributīvum rem agendam indicat, nōn actiōnem iam perfectam neque agentem futūrum.',
 'attractio-accusativi':'Post ad nōmen et gerundīvum in accūsātīvō ponuntur; gerundīvum etiam genere et numerō congruit.',
 'attractio-genitivi':'Causā postpositum genitīvum postulat: librōrum legendōrum causā. Utraque fōrma eundem cāsum servat.',
 'attractio-ablativi':'In hāc cōnstrūctiōne in cum ablātīvō actiōnem significat: in librīs legendīs. Nōmen et gerundīvum in ablātīvō sunt.',
 'attractio-sensus':'Nōmen cum gerundīvō hīc actiōnem verbālem exprimit; nōn dē rē iam perfectā tantum agitur.',
 'finis-actionis':'Fīnis respondet cūr veniat: ad actiōnem agendam venit, nōn post actiōnem perfectam nec eō tempore tantum quō eam agit.',
 'intentio-actus':'Participium futūrī actīvī cum esse cōnsilium vel propinquitātem actiōnis exprimit; actiō nōn iam facta affirmātur.',
 'tempus-periphrasticae':'Est tempus praesēns, erat tempus praeteritum cōnsiliī vel necessitātis indicat; nōn tempus actiōnis futurae per sē dēfīnit.',
 'necessitas-factum':'Gerundīvum cum esse necessitātem exprimit; participium perfectī cum esse rem factam exprimit.',
 'dativus-auctoris':'Datīvus in hāc periphrasticā passīvā eum indicat cui actiō agenda est. Is nōn necesse est idem ac loquēns esse.',
 'supinum-regimen':'Post verbum veniendī supīnum in -um fīnem exprimit. Supīnum in -ū cum adiectīvīs ut facile vel difficile iungitur.',
 'supinum-respectus':'Facile dictū vel difficile factū rem quoad actiōnem aestimat; neque rem factam neque necessitātem agendī affirmat.',
 '=agent-patient':'Nōminātīvus agentem, accūsātīvus eum ad quem actiō spectat indicat; nōmina nōn permūtanda sunt.',
}

def add(mode,topic,id,latin,correct,wrong,vocab,distinctions,failures=None,french=None):
    # A leading '=' references an existing shared skill outside this unit.
    ref=lambda d: mode+'.'+d[1:] if d.startswith('=') else f'{mode}.nonfinitum.{d}'
    skills=[ref(d) for d in distinctions]
    if failures is None: failures=[[d] for d in distinctions] if len(distinctions)==len(wrong) else [distinctions]*len(wrong)
    frame=dict(id=f'{mode}-nonfinitum-{topic}-{id}',place='theatrum' if mode=='lectio' else 'templum',
        section='formae-non-finitae' if mode=='lectio' else 'formis-non-finitis',
        sectionName='Fōrmās nōn fīnītās intellegere' if mode=='lectio' else 'Fōrmīs nōn fīnītīs ūtī',
        card=str(topic),name={1:'Participium coniūnctum',2:'Gerundīvum',3:'Gerundīvī attractiō',4:'Periphrastica actīva',5:'Periphrastica passīva',6:'Supīnum in -um',7:'Supīnum in -ū'}[topic],
        skill=f'{mode}.curriculum.nonfinite.{topic}',assessedSkills=skills,
        supportingSkills=sorted({r for n in SKILLS if n['id'] in skills for r in n['requires']}),
        wrongSkills=[[ref(d) for d in failed] for failed in failures],
        latin=latin,correct=correct,wrong=wrong,vocabulary=vocab.split(),
        explanation=' '.join(EXPLANATIONS[d] for d in distinctions),
        actorPool='artifices',task='interpretatio-formarum-non-finitarum' if mode=='lectio' else 'compositio-formarum-non-finitarum')
    if french is not None:frame['french']=french
    FRAMES.append(frame)

for key,present,acc,future,fr in [
 ('saluto','salūtāns','salūtantem','salūtātūrus','saluant'),
 ('audio','audiēns','audientem','audītūrus','écoutant'),
 ('video','vidēns','videntem','vīsūrus','voyant'),
 ('duco','dūcēns','dūcentem','ductūrus','conduisant'),
]:
    add('lectio',1,key,'{a.nom} {b.acc} '+present+' urbem intrat.',
        '{a.fr} entre dans la ville en '+fr+' {b.fr}.',
        ['{b.fr} entre dans la ville en '+fr+' {a.fr}.',
         '{a.fr} entre dans la ville avant de commencer à '+{'saluto':'saluer','audio':'écouter','video':'voir','duco':'conduire'}[key]+' {b.fr}.'],
        key+' urbs intro',['=agent-patient','tempus-participii'])
    add('compositio',1,key,'{a.nom} {b.acc} ___ urbem intrat.',present,[acc,future],
        key+' urbs intro',['casus-participii','tempus-participii'],
        french='{a.fr} entre dans la ville en '+fr+' {b.fr} au même moment.')
for key,part,wrongcase,future,fr,active in [
 ('laudo','laudātus','laudātō','laudātūrus','loué','loué'),
 ('voco','vocātus','vocātō','vocātūrus','appelé','appelé'),
 ('moneo','monitus','monitō','monitūrus','averti','averti'),
 ('invenio','inventus','inventō','inventūrus','trouvé','trouvé'),
]:
    add('lectio',1,key+'-perfectum','{a.nom} ab {b.abl} '+part+' urbem intrat.',
        '{a.fr} entre dans la ville après avoir été '+fr+' par {b.fr}.',
        ['{a.fr} entre dans la ville après avoir '+active+' {b.fr}.',
         '{a.fr} entre dans la ville avant d’être '+fr+' par {b.fr}.'],
        key+' ab urbs intro',['vox-participii','tempus-participii'])
    add('compositio',1,key+'-perfectum','{a.nom} ab {b.abl} ___ urbem intrat.',part,[wrongcase,future],
        key+' ab urbs intro',['casus-participii','vox-participii','tempus-participii'],
        failures=[['casus-participii'],['vox-participii','tempus-participii']],
        french='{a.fr}, après avoir été '+fr+' par {b.fr}, entre dans la ville.')

# Avoid syncretic wrong forms that could instead be a number/case error.
# These two gender contrasts therefore use one unambiguous distractor.
OBJECTS=[
 ('liber','liber','legendus',['legenda'],'le livre','à lire','lego'),
 ('epistula','epistula','scrībenda',['scrībendus','scrībendum'],'la lettre','à écrire','scribo'),
 ('carmen','carmen','cantandum',['cantandus'],'le chant','à chanter','canto'),
 ('mandatum','mandāta','exsequenda',['exsequendae','exsequendum'],'les ordres','à exécuter','exsequor'),
 ('labor','labōrēs','faciendī',['facienda','faciendus'],'les travaux','à faire','facio'),
]
for key,noun,gerund,wrong,fr,task,verb in OBJECTS:
    copula='sunt' if key in ['mandatum','labor'] else 'est'
    add('lectio',2,key,'{a.nom} dīcit: «'+noun+' '+gerund+' in urbe '+copula+'.»',
        '{a.fr} dit que '+fr+' '+task+' '+('sont' if copula=='sunt' else 'est')+' dans la ville.',
        ['{a.fr} décrit une action déjà accomplie sur '+fr+' dans la ville.',
         '{a.fr} annonce qu’il va lui-même '+task[2:]+' '+fr+' dans la ville.'],
        key+' '+verb+' dico in urbs sum',['gerundivum-sensus'])
    add('compositio',2,key,noun+' ___ in urbe '+copula+'. '+ '{a.nom} adest.',gerund,wrong,
        key+' '+verb+' in urbs sum adsum',['genus-gerundivi','numerus-gerundivi'] if key in ['mandatum','labor'] else ['genus-gerundivi'],
        french=fr.capitalize()+' '+task+' '+('sont' if copula=='sunt' else 'est')+' dans la ville. {a.fr} est présent.')
LEXICON+='\nadsum|adsum|être présent\nlabor|labor|travail\n'

# Plural formation has its own evidence: gender and number errors are isolated.
for key,noun,answer,wronggender,wrongsingular,fr,verb in [
 ('epistula','epistulae','scrībendae','scrībendī','scrībenda','Les lettres à écrire','scribo'),
 ('liber','librī','legendī','legendae','legendus','Les livres à lire','lego'),
 ('donum','dōna','portanda','portandae','portandum','Les cadeaux à porter','porto'),
]:
    add('compositio',2,key+'-plural',noun+' ___ in urbe sunt. {a.nom} adest.',
        answer,[wronggender] if key=='epistula' else [wronggender,wrongsingular],key+' '+verb+' in urbs sum adsum',
        ['genus-gerundivi'] if key=='epistula' else ['genus-gerundivi','numerus-gerundivi'],
        french=fr+' sont dans la ville. {a.fr} est présent.')

for key,group,wrongcase,wrongagree,fr,vocab in [
 ('epistulae','epistulās scrībendās','epistulārum scrībendārum','epistulās scrībendōs','écrire les lettres','epistula scribo'),
 ('libri','librōs legendōs','librōrum legendōrum','librōs legendās','lire les livres','liber lego'),
 ('pueri','puerōs cūrandōs','puerōrum cūrandōrum','puerōs cūrandās','soigner les enfants','puer curo'),
 ('dona','dōna portanda','dōnōrum portandōrum','dōna portandās','porter les cadeaux','donum porto'),
]:
    add('lectio',3,key,'{a.nom} ad '+group+' venit. {b.nom} adest.',
        '{a.fr} vient pour '+fr+'. {b.fr} est présent.',
        ['{a.fr} vient après avoir fini '+de(fr)+'. {b.fr} est présent.',
         '{a.fr} vient pour '+{'epistulae':'les lettres déjà écrites','libri':'les livres déjà lus','pueri':'les enfants déjà soignés','dona':'les cadeaux déjà transportés'}[key]+'. {b.fr} est présent.'],
        vocab+' ad venio adsum',['finis-actionis','attractio-sensus'])
    add('compositio',3,key,'{a.nom} ad ___ venit. {b.nom} adest.',group,[wrongcase,wrongagree],
        vocab+' ad venio adsum',['attractio-accusativi','genus-gerundivi'],
        french='{a.fr} vient pour '+fr+'. {b.fr} est présent. Emploie ad avec le nom et le adjectif verbal accordés.')

# The same verbal-noun relation also occurs in the genitive and ablative.
for key,acc,gen,abl,fr,completed,vocab in [
 ('epistulae','epistulās scrībendās','epistulārum scrībendārum','epistulīs scrībendīs','écrire les lettres','les lettres déjà écrites','epistula scribo'),
 ('libri','librōs legendōs','librōrum legendōrum','librīs legendīs','lire les livres','les livres déjà lus','liber lego'),
 ('pueri','puerōs cūrandōs','puerōrum cūrandōrum','puerīs cūrandīs','soigner les enfants','les enfants déjà soignés','puer curo'),
 ('dona','dōna portanda','dōnōrum portandōrum','dōnīs portandīs','porter les cadeaux','les cadeaux déjà transportés','donum porto'),
]:
    add('lectio',3,key+'-genitivus','{a.nom} '+gen+' causā venit. {b.nom} adest.',
        '{a.fr} vient pour '+fr+'. {b.fr} est présent.',
        ['{a.fr} vient après avoir fini '+de(fr)+'. {b.fr} est présent.',
         '{a.fr} vient pour '+completed+'. {b.fr} est présent.'],
        vocab+' causa venio adsum',['finis-actionis','attractio-sensus'])
    add('compositio',3,key+'-genitivus','{a.nom} ___ causā venit. {b.nom} adest.',gen,[acc,abl],
        vocab+' causa venio adsum',['attractio-genitivi'],
        french='{a.fr} vient pour '+fr+'. {b.fr} est présent. Emploie le groupe nominal avec causā.')
    add('lectio',3,key+'-ablativus','{a.nom} in '+abl+' multum temporis cōnsūmit. {b.nom} adest.',
        '{a.fr} consacre beaucoup de temps à '+fr+'. {b.fr} est présent.',
        ['{a.fr} passe beaucoup de temps après avoir fini '+de(fr)+'. {b.fr} est présent.',
         '{a.fr} parle seulement de '+completed.replace('les ','ces ',1)+'. {b.fr} est présent.'],
        vocab+' in multus tempus consumo adsum',['attractio-sensus'])
    add('compositio',3,key+'-ablativus','{a.nom} in ___ multum temporis cōnsūmit. {b.nom} adest.',abl,[acc,gen],
        vocab+' in multus tempus consumo adsum',['attractio-ablativi'],
        french='{a.fr} consacre beaucoup de temps à '+fr+'. {b.fr} est présent.')
LEXICON+='\ncausa|causa|cause\nmultus|multus|nombreux\ntempus|tempus|temps\nconsumo|cōnsūmō|consommer\n'

for key,future,actual,pastactual,fr,frnow,frpast in [
 ('proficiscor','profectūrus','proficīscitur','profectus erat','partir','part','était parti'),
 ('redeo','reditūrus','redit','redierat','revenir','revient','était revenu'),
 ('navigo','nāvigātūrus','nāvigat','nāvigāverat','naviguer','navigue','avait navigué'),
 ('laboro','labōrātūrus','labōrat','labōrāverat','travailler','travaille','avait travaillé'),
]:
    for past in [False,True]:
        time='herī' if past else 'nunc';copula='erat' if past else 'est';other='est' if past else 'erat'
        frtime='hier' if past else 'maintenant';frverb='avait' if past else 'a'
        add('lectio',4,key+('-past' if past else '-present'),'{a.nom} '+time+' '+future+' '+copula+'. {b.nom} adest.',
            '{a.fr} '+frverb+' '+frtime+' l’intention '+de(fr)+'. {b.fr} est présent.',
            ['{a.fr} '+(frpast if past else frnow)+' effectivement '+frtime+'. {b.fr} est présent.',
             '{a.fr} '+('a maintenant' if past else 'avait hier')+' l’intention '+de(fr)+'. {b.fr} est présent.'],
            key+' '+('heri' if past else 'nunc')+' sum adsum',['intentio-actus','tempus-periphrasticae'])
        add('compositio',4,key+('-past' if past else '-present'),'{a.nom} '+time+' ___. {b.nom} adest.',
            future+' '+copula,[pastactual if past else actual,future+' '+other],
            key+' '+('heri' if past else 'nunc')+' sum adsum',['intentio-actus','tempus-periphrasticae'],
            french='{a.fr} '+frverb+' '+frtime+' l’intention '+de(fr)+'. {b.fr} est présent.')

for key,noun,gerund,perfect,fr,action in [
 ('liber','liber','legendus','lēctus','le livre','lire'),
 ('epistula','epistula','scrībenda','scrīpta','la lettre','écrire'),
 ('porta','porta','aperienda','aperta','la porte','ouvrir'),
 ('consilium','cōnsilium','parandum','parātum','le projet','préparer'),
]:
    vocab=key+' '+{'liber':'lego','epistula':'scribo','porta':'aperio','consilium':'paro'}[key]+' dico sum'
    distinctions=['dativus-auctoris','necessitas-factum','tempus-periphrasticae']
    add('lectio',5,key,'{a.nom} dīcit: «'+noun+' {b.dat} '+gerund+' est.»',
        '{a.fr} dit que {b.fr} doit '+action+' '+fr+'.',
        ['{a.fr} dit qu’il doit lui-même '+action+' '+fr+', et non {b.fr}.',
         '{a.fr} affirme que {b.fr} a déjà accompli l’action sur '+fr+'.',
         '{a.fr} dit que {b.fr} devait '+action+' '+fr+' autrefois.'],
        vocab,distinctions)
    add('compositio',5,key,'{a.nom} dīcit: «___.»',noun+' {b.dat} '+gerund+' est',
        [noun+' {a.dat} '+gerund+' est',noun+' {b.dat} '+perfect+' est',noun+' {b.dat} '+gerund+' erat'],
        vocab,distinctions,french='{a.fr} dit : « {b.fr} a actuellement l’obligation de '+action+' '+fr+'. »')
LEXICON+='\naperio|aperiō|ouvrir\n'
for key,supine,abl,part,fr in [
 ('rogo','rogātum','rogātū','rogāns','interroger'),
 ('saluto','salūtātum','salūtātū','salūtāns','saluer'),
 ('video','vīsum','vīsū','vidēns','voir'),
 ('audio','audītum','audītū','audiēns','écouter'),
]:
    add('lectio',6,key,'{a.nom} {b.acc} '+supine+' venit.',
        '{a.fr} vient pour '+fr+' {b.fr}.',
        ['{a.fr} vient après avoir fini '+de(fr)+' {b.fr}.',
         '{b.fr} vient pour '+fr+' {a.fr}.'],
        key+' venio',['finis-actionis','=agent-patient'])
    add('compositio',6,key,'{a.nom} {b.acc} ___ venit.',supine,[abl,part],
        key+' venio',['supinum-regimen','finis-actionis'],
        french='{a.fr} vient dans le but de '+fr+' {b.fr}. Emploie le supin de but.')
for key,supine,acc,gerund,adjective,fradj,frverb in [
 ('dico','dictū','dictum','dīcendum','facile','facile','dire'),
 ('facio','factū','factum','faciendum','difficile','difficile','faire'),
 ('video','vīsū','vīsum','videndum','mīrābile','étonnant','voir'),
 ('audio','audītū','audītum','audiendum','iūcundum','agréable','entendre'),
]:
    vocab=key+' hic sum '+{'facile':'facilis','difficile':'difficilis','mīrābile':'mirabilis','iūcundum':'iucundus'}[adjective]
    add('lectio',7,key,'{a.nom} dīcit: «Hoc '+adjective+' '+supine+' est.»',
        '{a.fr} dit que ceci est '+fradj+' à '+frverb+'.',
        ['{a.fr} dit que cette action a effectivement déjà été accomplie.',
         '{a.fr} dit que cette action doit obligatoirement être accomplie.'],
        vocab+' dico',['supinum-respectus'])
    add('compositio',7,key,'{a.nom} dīcit: «Hoc '+adjective+' ___ est.»',supine,[acc,gerund],
        vocab+' dico',['supinum-respectus'],french='{a.fr} dit : « Ceci est '+fradj+' à '+frverb+'. »')
FRAMES.sort(key=lambda f:(f['place'],int(f['card'])))

# Register only fine distinctions actually exercised in this batch.
used={skill for frame in FRAMES for skill in frame['assessedSkills']}
SKILLS=[node for node in SKILLS if node['id'] in used]
