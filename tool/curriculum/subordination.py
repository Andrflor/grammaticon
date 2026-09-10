"""Independent reading and production tasks for subordinate clauses."""
LEXICON = '''
nescio|nesciō|ignorer
cur|cūr|pourquoi
ubi|ubi|où
habito|habitō|habiter
ex|ex|hors de
exeo|exeō|sortir
tam|tam|si
fortiter|fortiter|courageusement
pugno|pugnō|combattre
ut|ut|pour que
laudo|laudō|louer
quamvis|quamvīs|bien que
tamen|tamen|cependant
dum|dum|pendant que
lego|legō|lire
scribo|scrībō|écrire
cum|cum|quand
discedo|discēdō|s’en aller
quod|quod|parce que
qui|quī|qui
peto|petō|chercher
desero|dēserō|abandonner
ne|nē|que ne
impedio|impediō|empêcher
quominus|quōminus|que
quin|quīn|que
venio|veniō|venir
dubito|dubitō|douter
facio|faciō|faire
ambulo|ambulō|marcher
possum|possum|pouvoir
gratia|grātia|reconnaissance
ago|agō|faire
postquam|postquam|après que
priusquam|priusquam|avant que
advenio|adveniō|arriver
fero|ferō|porter
iuvo|iuvō|aider
auxilium|auxilium|aide
''' 
FRAMES = []
def R(id, n, name, latin, correct, wrong, vocab, explanation):
    FRAMES.append(dict(id=id, place='theatrum', section='nexus-sententiarum',
        sectionName='Sententiārum nexus', card=str(n), name=name,
        skill=f'lectio.curriculum.subordination.{n}', latin=latin,
        correct=correct, wrong=wrong, vocabulary=vocab.split(),
        explanation=explanation, task='interpretatio-subordinationis'))
def P(id, n, name, french, latin, correct, wrong, vocab, explanation):
    FRAMES.append(dict(id=id, place='templum', section='sententiae-subordinatae',
        sectionName='Sententiās subiungere', card=str(n), name=name,
        skill=f'compositio.curriculum.subordination.{n}', french=french,
        latin=latin, correct=correct, wrong=wrong, vocabulary=vocab.split(),
        explanation=explanation, task='compositio-subordinationis'))

R('sequence-past-question', 1, 'Tempus relātum',
  '{a.nom} rogāvit ubi {b.nom} habitāret.',
  '{a.fr} a demandé où {b.fr} habitait alors.',
  ['{a.fr} a demandé où {b.fr} habiterait plus tard.',
   '{a.fr} a demandé où {b.fr} avait habité auparavant.'],
  'rogo ubi habito', 'Habitāret eōdem tempore ac rogāvit habitātiōnem pōnit. Habitāvisset antērioritātem indicāret.')
R('indirect-why', 2, 'Quid quaeritur?',
  '{a.nom} nescit cūr {b.nom} ex {l.abl} exeat.',
  '{a.fr} ignore pourquoi {b.fr} sort de {l.fr}.',
  ['{a.fr} ignore par où {b.fr} sort de {l.fr}.',
   '{a.fr} ignore quand {b.fr} sort de {l.fr}.'],
  'nescio cur ex exeo', 'Cūr causam quaerit; interrogātiō post nescit oblīqua est, ideo exeat coniūnctīvus est.')
R('result-praise', 3, 'Effectus, nōn cōnsilium',
  '{a.nom} tam fortiter pugnat ut {b.nom} eum laudet.',
  '{a.fr} combat si courageusement que {b.fr} le loue.',
  ['{a.fr} combat courageusement afin que {b.fr} le loue.',
   '{a.fr} combat courageusement parce que {b.fr} le loue.'],
  'tam fortiter pugno ut is laudo', 'Tam … ut effectum exprimit. Laus ex fortitūdine sequitur; cōnsilium pugnantis nōn affirmātur.')
R('concession-fear', 4, 'Quamvīs et tamen',
  'Quamvīs {a.nom} timeat, tamen {b.acc} nōn dēserit.',
  'Bien que {a.fr} ait peur, il n’abandonne pourtant pas {b.fr}.',
  ['Parce que {a.fr} a peur, il n’abandonne pas {b.fr}.',
   'Afin que {a.fr} ait peur, il n’abandonne pas {b.fr}.'],
  'quamvis timeo tamen non desero', 'Quamvīs rem admissam, tamen contrārium exspectātiōnī indicat. Causa vel cōnsilium nōn exprimitur.')
R('while-writing', 5, 'Dum et simul',
  'Dum {a.nom} in {l.abl} scrībit, {b.nom} legit.',
  'Pendant que {a.fr} écrit dans {l.fr}, {b.fr} lit.',
  ['Après que {a.fr} a écrit dans {l.fr}, {b.fr} lit.',
   'Avant que {a.fr} écrive dans {l.fr}, {b.fr} lit.'],
  'dum in scribo lego', 'Dum cum praesente hīc duās actiōnēs simul factās coniungit.')
R('historical-cum-arrival', 6, 'Cum in nārrātiōne',
  'Cum {a.nom} in {l.abl} manēret, {b.nom} vēnit.',
  'Alors que {a.fr} restait dans {l.fr}, {b.fr} est arrivé.',
  ['Après que {a.fr} eut quitté {l.fr}, {b.fr} est arrivé.',
   'Avant que {a.fr} reste dans {l.fr}, {b.fr} est arrivé.'],
  'cum in maneo venio', 'Cum manēret statum dūrantem praebet in quō adventus accidit. Perfectum vēnit adventum, imperfectum manēret statum exprimit.')
R('cause-prior-call', 7, 'Causa nārrāta',
  '{a.nom} discessit quod {b.nom} eum vocāverat.',
  '{a.fr} est parti parce que {b.fr} l’avait appelé.',
  ['{a.fr} est parti afin que {b.fr} l’appelle.',
   '{a.fr} est parti bien que {b.fr} ne l’ait pas appelé.'],
  'discedo quod is voco', 'Quod causam discessūs exprimit; vocāverat vocātiōnem priōrem discessū facit.')
R('relative-purpose-envoy', 8, 'Quī cōnsilium indicat',
  '{a.nom} {b.acc} mittit quī auxilium petat.',
  '{a.fr} envoie {b.fr} pour que celui-ci cherche de l’aide.',
  ['{a.fr} envoie {b.fr} parce que celui-ci a déjà cherché de l’aide.',
   '{a.fr} envoie {b.fr} bien que celui-ci refuse de chercher de l’aide.'],
  'mitto qui auxilium peto', 'Quī petat relātīva cōnsiliī est: quō cōnsiliō mittātur ostendit, nōn rem iam factam nārrat.')
R('relative-character', 9, 'Quālis sit',
  '{a.nom} nōn is est quī {b.acc} dēserat.',
  '{a.fr} n’est pas homme à abandonner {b.fr}.',
  ['{a.fr} est précisément celui qui vient d’abandonner {b.fr}.',
   '{a.fr} donne à {b.fr} l’ordre de l’abandonner.'],
  'non is sum qui desero', 'Nōn is est quī … proprietātem persōnae negat. Dēserat coniūnctīvus quālis sit exprimit.')
R('fear-leaving', 10, 'Quid timētur?',
  '{a.nom} timet nē {b.nom} ex {l.abl} discēdat.',
  '{a.fr} craint que {b.fr} quitte {l.fr}.',
  ['{a.fr} craint que {b.fr} ne quitte pas {l.fr}.',
   '{a.fr} souhaite que {b.fr} quitte {l.fr}.'],
  'timeo ne ex discedo', 'Post timet nē rem timendam affirmātam intrōdūcit. Nē nōn discessum nōn futūrum timēret.')
R('prevent-departure', 11, 'Quid impeditur?',
  '{a.nom} impedit {b.acc} quōminus ex {l.abl} exeat.',
  '{a.fr} empêche {b.fr} de sortir de {l.fr}.',
  ['{a.fr} ordonne à {b.fr} de sortir de {l.fr}.',
   '{a.fr} empêche {b.fr} de rester dans {l.fr}.'],
  'impedio quominus ex exeo', 'Quōminus actiōnem impeditam intrōdūcit: exitus, nōn mora impeditur.')
R('certainty-quin', 12, 'Quīn post dubitātiōnem negātam',
  '{a.nom} nōn dubitat quīn {b.nom} veniat in {l.acc}.',
  '{a.fr} ne doute pas que {b.fr} vienne dans {l.fr}.',
  ['{a.fr} doute que {b.fr} vienne dans {l.fr}.',
   '{a.fr} empêche {b.fr} de venir dans {l.fr}.'],
  'non dubito quin venio in', 'Nōn dubitat quīn certitūdinem adventūs exprimit. Quīn hīc nōn negātiōnem adventūs addit.')

# Production order starts from causal/temporal linking before mood-dependent
# relative clauses and restrictions. These prompts are not reversed readings.
P('produce-because', 7, 'Causam subiungere',
  '{a.fr} reste parce que {b.fr} a besoin d’aide.',
  '{a.nom} manet ___ {b.dat} auxiliō opus est.', 'quod', ['ut', 'quamvīs'],
  'maneo quod auxilium opus sum ut quamvis', 'Quod causam indicat. Ut cōnsilium vel effectum, quamvīs concessiōnem introduceret.')
P('produce-after', 5, 'Ordinem factōrum compōnere',
  'Après que {a.fr} est arrivé, {b.fr} a quitté {l.fr}.',
  '___ {a.nom} advēnit, {b.nom} ex {l.abl} discessit.', 'Postquam', ['Priusquam', 'Dum'],
  'postquam advenio ex discedo priusquam dum', 'Postquam adventum priōrem discessū facit. Priusquam ordinem inverteret; dum simultāneitātem exprimeret.')
P('produce-indirect-present', 2, 'Interrogātiōnem subiungere',
  'Dis-moi pourquoi {a.fr} reste dans {l.fr}.',
  'Dīc mihi cūr {a.nom} in {l.abl} ___.', 'maneat', ['manēret', 'mānserit'],
  'dico ego cur in maneo', 'Post dīc interrogātiō oblīqua de rē praesente coniūnctīvum praesentem habet: maneat. Mānserit rem priōrem indicāret.')
P('produce-sequence-past', 1, 'Tempora inter sē accommodāre',
  '{a.fr} a demandé ce que {b.fr} faisait alors dans {l.fr}.',
  '{a.nom} rogāvit quid {b.nom} in {l.abl} ___.', 'faceret', ['faciat', 'fēcisset'],
  'rogo quis in facio', 'Post rogāvit actiō eōdem tempore facta imperfectō coniūnctīvī exprimitur: faceret. Fēcisset antērioritātem indicāret.')
P('produce-historical-background', 6, 'Statum nārrātiōnis compōnere',
  'Alors que {a.fr} écrivait dans {l.fr}, {b.fr} lisait.',
  'Cum {a.nom} in {l.abl} ___, {b.nom} legēbat.', 'scrīberet', ['scrīpsisset', 'scrībat'],
  'cum in scribo lego', 'In nārrātiōne cum scrīberet actiōnem legēbat simul comitātam exprimit. Scrīpsisset scrīptūram iam perfectam pōneret.')
P('produce-result-inability', 3, 'Effectum subiungere',
  '{a.fr} est si fatigué qu’il ne peut pas marcher jusqu’{l.to}.',
  '{a.nom} tam fessus est ut ad {l.acc} ambulāre nōn ___.', 'possit', ['potuerit', 'posset'],
  'tam fessus sum ut ad ambulo non possum', 'Effectus praesēns post tam fessus est coniūnctīvō praesente exprimitur: possit.')
P('produce-concession', 4, 'Concessiōnem subiungere',
  'Bien que {a.fr} soit fatigué, il remercie pourtant {b.fr}.',
  'Quamvīs {a.nom} fessus ___, tamen {b.dat} grātiās agit.', 'sit', ['fuisset', 'esse'],
  'quamvis fessus sum tamen gratia ago', 'Quamvīs concessīvum cum coniūnctīvō hīc ponitur. Sit statum praesentem exprimit, nōn praeteritum ante aliud praeteritum.')
P('produce-relative-purpose', 8, 'Relātīvā cōnsilium exprimere',
  'Envoyez {a.fr} pour qu’il porte de l’aide à {b.fr}.',
  '{a.acc} mittite quī {b.dat} auxilium ___.', 'ferat', ['tulerit', 'tulisset'],
  'mitto qui auxilium fero', 'Quī ferat cōnsilium futūrum post iussum mittite exprimit. Tulerit vel tulisset rem iam factam indicāret.')
P('produce-relative-character', 9, 'Proprietātem relātīvā exprimere',
  'Il n’y a aucun membre du groupe des {a.frpl} qui ne soit prêt à aider {b.fr}.',
  'Nēmō {a.genpl} est quī {b.acc} iuvāre nōn ___ parātus.', 'sit', ['esse', 'fuisset'],
  'nemo sum qui iuvo non paratus', 'Nēmō est quī … proprietātem generālem exprimit. Sit cum parātus statum praesentem dēsignat.')
P('produce-fear-negated-event', 10, 'Rem timendam negāre',
  '{a.fr} craint que {b.fr} ne vienne pas dans {l.fr}.',
  '{a.nom} timet ___ {b.nom} veniat in {l.acc}.', 'nē nōn', ['nē', 'quod'],
  'timeo ne non venio in quod', 'Nē nōn rem nōn futūram timendam facit. Sōlum nē adventum ipsum timendum faceret.')
P('produce-prevention', 11, 'Actiōnem impeditam subiungere',
  '{a.fr} empêche {b.fr} de venir dans {l.fr}.',
  '{a.nom} impedit ___ {b.nom} veniat in {l.acc}.', 'quōminus', ['postquam', 'quamvīs'],
  'impedio quominus venio in postquam quamvis', 'Quōminus actiōnem impeditam intrōdūcit. Postquam tempus, quamvīs concessiōnem exprimeret.')
P('produce-certainty', 12, 'Dubitātiōnem negāre',
  '{a.fr} ne doute pas que {b.fr} sache où se trouve {l.fr}.',
  '{a.nom} nōn dubitat ___ {b.nom} sciat ubi {l.nom} sit.', 'quīn', ['nē', 'quōminus'],
  'non dubito quin scio ubi sum ne quominus', 'Post nōn dubitat quīn sententiam cui fīdēs habētur intrōdūcit. Nē cum timōre, quōminus cum impedīmentō coniungitur.')
LEXICON += '''
paratus|parātus|prêt
scio|sciō|savoir
'''
for f in FRAMES:
    for key in ['correct', 'french']:
        if key in f: f[key] = f[key].replace('à {a.fr}', '{a.to}').replace('à {b.fr}', '{b.to}')
    f['wrong'] = [t.replace('à {a.fr}', '{a.to}').replace('à {b.fr}', '{b.to}') for t in f['wrong']]

for frame in FRAMES:
    frame['actorPool'] = 'artifices'
