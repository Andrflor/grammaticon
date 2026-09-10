"""Pronoun reference and scope in discourse; independent formulation contrasts."""
FRAMES = []
LEXICON = '''
aliquis|aliquis|quelqu’un
aliquid|aliquid|quelque chose
quidam|quīdam|un certain
quisque|quisque|chacun
nemo|nēmō|personne
quisquam|quisquam|qui que ce soit
quidquam|quidquam|quoi que ce soit
quivis|quīvīs|n’importe qui
quis|quis|qui
quid|quid|quoi
uter|uter|lequel des deux
quicumque|quīcumque|quiconque
quisquis|quisquis|quiconque
quidquid|quidquid|tout ce qui
qualiscumque|quāliscumque|quel qu’il soit
ipse|ipse|lui-même
idem|īdem|le même
alius|alius|autre
omnis|omnis|tout
suus|suus|son propre
is|is|celui-ci
et|et|et
sed|sed|mais
si|sī|si
non|nōn|ne… pas
hodie|hodiē|aujourd’hui
heri|herī|hier
cras|crās|demain
venio|veniō|venir
saluto|salūtō|saluer
iuvo|iuvō|aider
video|videō|voir
quaero|quaerō|chercher
respondeo|respondeō|répondre
interrogo|interrogō|interroger
rogo|rogō|demander
sum|sum|être
adsum|adsum|être présent
absum|absum|être absent
credo|crēdō|croire
amo|amō|aimer
habeo|habeō|avoir
dico|dīcō|dire
dono|dōnō|donner
lego|legō|lire
narro|nārrō|raconter
scribo|scrībō|écrire
audio|audiō|entendre
accipio|accipiō|recevoir
facio|faciō|faire
cognosco|cognōscō|apprendre
ignoro|ignōrō|ignorer
nomen|nōmen|nom
liber|liber|livre
verbum|verbum|mot
homo|homō|être humain
veritas|vēritās|vérité
mandatum|mandātum|ordre confié
promissum|prōmissum|promesse
'''

def add(mode, topic, id, latin, correct, wrong, vocab, explanation, french=None):
    place='theatrum' if mode=='lectio' else 'templum'
    f=dict(id=f'{mode}-pronomen-{id}',place=place,
        section='referentiae-pronominum' if mode=='lectio' else 'pronomina-eligenda',
        sectionName='Prōnōminum sēnsūs' if mode=='lectio' else 'Prōnōmina ēligere',
        card=str(topic),name={1:'Indēfīnīta',2:'Interrogātīva',3:'Relātīva indēfīnīta',4:'Ipse et īdem'}[topic],
        skill=f'{mode}.curriculum.pronouns.{topic}',latin=latin,correct=correct,wrong=wrong,
        vocabulary=vocab.split(),explanation=explanation,actorPool='artifices',
        task='interpretatio-referentiae' if mode=='lectio' else 'compositio-pronominum')
    if french is not None: f['french']=french
    FRAMES.append(f)

add('lectio',1,'aliquis',
    'Aliquis {a.acc} iuvat; {b.nom} nōmen eius ignōrat.',
    'Quelqu’un aide {a.fr} ; {b.fr} ignore son nom.',
    ['Personne n’aide '+ '{a.fr} ; {b.fr} ignore son nom.',
     'Tout le monde aide {a.fr} ; {b.fr} ignore les noms.'],
    'aliquis iuvo nomen is ignoro', 'Aliquis hominem indēfīnītum significat, nōn omnēs neque nēminem.')
add('lectio',1,'quidam',
    'Quīdam {a.nom} {b.acc} salūtat. Nōmen eius nōn dīcō.',
    'Un certain '+ '{a.frbare} salue {b.fr}. Je ne donne pas son nom.',
    ['Chaque '+ '{a.frbare} salue {b.fr}. Je ne donne pas leurs noms.',
     'Aucun '+ '{a.frbare} ne salue {b.fr}. Je ne donne pas son nom.'],
    'quidam saluto nomen is non dico', 'Quīdam hominem certum, sed nōn nōminātum, dēsignat.')
add('lectio',1,'quisque',
    '{a.nom} et {b.nom} adsunt. Quisque suum librum habet.',
    '{a.fr} et {b.fr} sont présents. Chacun a son propre livre.',
    ['{a.fr} et {b.fr} sont présents. Un seul des deux a son propre livre.',
     '{a.fr} et {b.fr} sont présents. Ils n’ont aucun livre.'],
    'et adsum quisque suus liber habeo', 'Quisque ad singulōs pertinet; suum ad quemque possessōrem refertur.')
add('lectio',1,'nemo',
    '{a.nom} rogat, sed nēmō respondet; {b.nom} abest.',
    '{a.fr} pose une question, mais personne ne répond ; {b.fr} est absent.',
    ['{a.fr} pose une question et chacun répond ; {b.fr} est absent.',
     '{a.fr} pose une question et quelqu’un répond ; {b.fr} est absent.'],
    'rogo sed nemo respondeo absum', 'Nēmō negat quemquam respondēre.')
add('compositio',1,'si-quis',
    'Sī ___ venit, {a.nom} eum salūtat.', 'quis',['nēmō','quisque'],
    'si quis nemo quisque venio is saluto', 'Post sī, quis hominem indēfīnītum potest dēsignāre.',
    'Si quelqu’un vient, {a.fr} le salue.')
add('compositio',1,'nemo',
    '___ {a.acc} videt; {b.nom} abest.', 'Nēmō',['Aliquis','Quisque'],
    'nemo aliquis quisque video absum', 'Nēmō negātiōnem continet: nūllus homō videt.',
    'Personne ne voit {a.fr} ; {b.fr} est absent.')
add('compositio',1,'quidquam',
    '{a.nom} nōn ___ dīcit; {b.nom} respondet.', 'quidquam',['omnia','nōmen'],
    'non quidquam omnis nomen dico respondeo', 'Nōn quidquam idem valet ac nihil: nūlla rēs dīcitur.',
    '{a.fr} ne dit absolument rien ; {b.fr} répond.')
add('compositio',1,'quivis',
    '___ {a.acc} interrogāre potest.', 'Quīvīs',['Nēmō','Quīdam'],
    'quivis nemo quidam interrogo possum', 'Quīvīs līberam ēlectiōnem exprimit: quīcumque vult.',
    'N’importe qui peut interroger {a.fr}.')

add('lectio',2,'quis-subject',
    'Quis {a.acc} iuvat? {b.nom} respondet.',
    'Qui aide {a.fr} ? {b.fr} répond.',
    ['Qui '+ '{a.fr} aide-t-il ? {b.fr} répond.',
     'Qu’est-ce qui aide {a.fr} ? {b.fr} répond.'],
    'quis iuvo respondeo', 'Quis hominem agentem interrogat; accusātīvus eum quī adiuvātur dēsignat.')
add('lectio',2,'quem-object',
    'Quem {a.nom} salūtat? {b.nom} respondet.',
    'Qui '+ '{a.fr} salue-t-il ? {b.fr} répond.',
    ['Qui salue {a.fr} ? {b.fr} répond.',
     'À qui '+ '{a.fr} appartient-il ? {b.fr} répond.'],
    'quis saluto respondeo', 'Quem accusātīvus hominem salūtātum interrogat.')
add('lectio',2,'cui-recipient',
    'Cui {a.nom} librum dōnat? {b.nom} respondet.',
    'À qui '+ '{a.fr} donne-t-il un livre ? {b.fr} répond.',
    ['Qui donne un livre '+ '{a.to} ? {b.fr} répond.',
     'Quel livre '+ '{a.fr} donne-t-il ? {b.fr} répond.'],
    'quis liber dono respondeo', 'Cui datīvus accipientem interrogat.')
add('lectio',2,'uter',
    '{a.nom} et {b.nom} adsunt. Uter librum habet?',
    '{a.fr} et {b.fr} sont présents. Lequel des deux a le livre ?',
    ['{a.fr} et {b.fr} sont présents. Quel livre ont-ils tous deux ?',
     '{a.fr} et {b.fr} sont présents. Combien de personnes ont un livre ?'],
    'et adsum uter liber habeo', 'Uter ē duōbus ūnum interrogat.')
add('compositio',2,'quid',
    '___ {a.nom} quaerit? {b.nom} respondet.', 'Quid',['Quis','Cui'],
    'quid quis quaero respondeo', 'Quid rem quaesītam interrogat, nōn hominem nec accipientem.',
    'Que cherche {a.fr} ? {b.fr} répond.')
add('compositio',2,'cuius',
    '___ librum {a.nom} legit? {b.nom} respondet.', 'Cuius',['Cui','Quem'],
    'quis liber lego respondeo', 'Cuius genitīvus possessōrem librī interrogat.',
    'De qui '+ '{a.fr} lit-il le livre ? {b.fr} répond.')
add('compositio',2,'quo-with',
    'Cum ___ {a.nom} venit? {b.nom} respondet.', 'quō',['quis','quem'],
    'cum quis venio respondeo', 'Cum sociātīvum ablātīvum quō postulat.',
    'Avec qui vient {a.fr} ? {b.fr} répond.')
add('compositio',2,'uter-two',
    '{a.nom} et {b.nom} adsunt. ___ librum habet?', 'Uter',['Cui','Quid'],
    'et adsum uter quis quid liber habeo', 'Uter hominem ē duōbus ēligendum interrogat.',
    '{a.fr} et {b.fr} sont présents. Lequel des deux a un livre ?')

add('lectio',3,'quicumque',
    'Quīcumque venit, {a.acc} salūtat; {b.nom} haec audit.',
    'Quiconque vient salue {a.fr} ; {b.fr} entend cela.',
    ['Une seule personne déterminée vient saluer {a.fr} ; {b.fr} entend cela.',
     'Personne ne vient saluer {a.fr} ; {b.fr} entend cela.'],
    'quicumque venio saluto hic audio', 'Quīcumque ad omnēs quī veniunt pertinet, sine hominis ēlectiōne.')
add('lectio',3,'quisquis',
    'Quisquis haec dīcit, vēritātem ignōrat; {a.nom} {b.acc} audit.',
    'Quiconque dit cela ignore la vérité ; {a.fr} écoute {b.fr}.',
    ['Une personne dont on connaît précisément le nom ignore la vérité ; {a.fr} écoute {b.fr}.',
     'Personne ne dit cela et tous connaissent la vérité ; {a.fr} écoute {b.fr}.'],
    'quisquis hic dico veritas ignoro audio', 'Quisquis omnem hominem huius condiciōnis complectitur.')
add('lectio',3,'quidquid',
    'Quidquid {a.nom} dīcit, {b.nom} audit.',
    '{b.fr} entend tout ce que dit {a.fr}.',
    ['{b.fr} n’entend rien de ce que dit {a.fr}.',
     '{b.fr} entend seulement une partie déterminée de ce que dit {a.fr}.'],
    'quidquid dico audio', 'Quidquid omnēs rēs dictās complectitur.')
add('lectio',3,'qualiscumque',
    'Quāliscumque {a.nom} est, {b.nom} eum amat.',
    'Quel que soit le caractère de '+ '{a.fr}, {b.fr} l’aime.',
    ['{b.fr} aime {a.fr} uniquement s’il possède une qualité précise.',
     '{b.fr} n’aime jamais {a.fr}, quelles que soient ses qualités.'],
    'qualiscumque sum is amo', 'Quāliscumque qualitatem nōn restringit.')
add('compositio',3,'whoever',
    '___ venit, {a.acc} videt.', 'Quīcumque',['Nēmō','Quīdam'],
    'quicumque nemo quidam venio video', 'Quīcumque omnem venientem sine exceptiōne significat.',
    'Quiconque vient voit {a.fr}.')
add('compositio',3,'whatever',
    '___ {a.nom} scrībit, {b.nom} legit.', 'Quidquid',['Nihil','Aliquid'],
    'quidquid nihil aliquid scribo lego', 'Quidquid rēs scrīptās ūniversās complectitur.',
    '{b.fr} lit tout ce que '+ '{a.fr} écrit.')
add('compositio',3,'whatever-character',
    '___ {a.nom} est, {b.nom} eum iuvat.', 'Quāliscumque',['Quīdam','Nēmō'],
    'qualiscumque quidam nemo sum is iuvo', 'Quāliscumque qualitatem hominis apertam relinquit.',
    'Quel que soit le caractère de '+ '{a.fr}, {b.fr} l’aide.')
add('compositio',3,'quisquis',
    '___ haec audit, {a.acc} interrogat; {b.nom} adest.', 'Quisquis',['Nēmō','Quīdam'],
    'quisquis nemo quidam hic audio interrogo adsum', 'Quisquis omnēs audientēs comprehendit.',
    'Quiconque entend cela interroge {a.fr} ; {b.fr} est présent.')

add('lectio',4,'ipse-subject',
    '{a.nom} ipse {b.acc} salūtat.',
    'C’est '+ '{a.fr} en personne qui salue {b.fr}.',
    ['{a.fr} salue {b.fr} lui-même, et non quelqu’un d’autre.',
     'Le même '+ '{a.frbare} salue {b.fr}.'],
    'ipse saluto', 'Ipse nōminātīvus agentem ipsum auget, nōn obiectum.')
add('lectio',4,'ipsum-object',
    '{a.nom} {b.acc} ipsum videt.',
    '{a.fr} voit {b.fr} en personne.',
    ['C’est '+ '{a.fr} en personne qui voit {b.fr}.',
     '{a.fr} voit le même individu qu’auparavant.'],
    'ipse video', 'Ipsum accusātīvus ad obiectum spectat.')
add('lectio',4,'idem-return',
    '{a.nom} herī vēnit. Īdem hodiē {b.acc} salūtat.',
    '{a.fr} est venu hier. Le même homme salue {b.fr} aujourd’hui.',
    ['{a.fr} est venu hier. Un autre homme salue {b.fr} aujourd’hui.',
     '{a.fr} est venu hier. Personne ne salue {b.fr} aujourd’hui.'],
    'heri venio idem hodie saluto', 'Īdem identitātem hominis per duo tempora servat.')
add('lectio',4,'eundem-book',
    '{a.nom} librum legit. {b.nom} eundem librum legit.',
    '{a.fr} lit un livre. {b.fr} lit le même livre.',
    ['{a.fr} lit un livre. {b.fr} lit un autre livre.',
     '{a.fr} lit un livre. {b.fr} ne lit aucun livre.'],
    'liber lego idem', 'Eundem identitātem librī, nōn tantum similitudinem, exprimit.')
add('compositio',4,'ipse',
    '{a.nom} ___ {b.acc} iuvat.', 'ipse',['īdem','alius'],
    'ipse idem alius iuvo', 'Ipse praesentiam agentis auget; īdem identitātem repetītam significat.',
    'C’est '+ '{a.fr} en personne qui aide {b.fr}.')
add('compositio',4,'eundem',
    '{a.nom} librum habet. {b.nom} ___ librum legit.', 'eundem',['ipsum','alium'],
    'liber habeo lego idem ipse alius', 'Eundem ad librum iam dictum refertur.',
    '{a.fr} a un livre. {b.fr} lit le même livre.')
add('compositio',4,'ipsi-recipient',
    '{a.nom} {b.dat} ___ librum dōnat.', 'ipsī',['eīdem','aliī'],
    'ipse idem alius liber dono', 'Ipsī datīvus accipientem in persōnā auget.',
    'C’est '+ '{b.to} en personne que {a.fr} donne un livre.')
add('compositio',4,'idem',
    '{a.nom} herī vēnit. ___ crās veniet.', 'Īdem',['Ipse','Alius'],
    'heri venio idem ipse alius cras', 'Īdem eundem hominem inter tempora coniungit.',
    '{a.fr} est venu hier. Le même homme viendra demain.')

# A reversal of agent and patient diagnoses that relation specifically, while
# confusing a human interrogative with a thing diagnoses the pronoun contrast.
for frame in FRAMES:
    if frame['id'] == 'lectio-pronomen-quis-subject':
        frame['additionalSkills'] = ['lectio.agent-patient']
        frame['wrongSkills'] = [['lectio.agent-patient'], [frame['skill']]]
