"""Distinct temporal and logical stimuli for subordinate-clause assessment."""
import copy
from subordination import FRAMES as BASE
FRAMES = []
LEXICON = '''
finio|fīniō|finir
laboro|labōrō|travailler
intellego|intellegō|comprendre
cognosco|cognōscō|apprendre
quando|quandō|quand
redeo|redeō|revenir
redeundum|redeundum|le fait de devoir revenir
noster|noster|notre
antequam|antequam|avant que
exspecto|exspectō|attendre
mox|mox|bientôt
adeo|adeō|à tel point
ita|ita|ainsi
nemo|nēmō|personne
invenio|inveniō|trouver
valde|valdē|beaucoup
sic|sīc|ainsi
ut|ut|que
etsi|etsī|même si
tametsi|tametsī|bien que
quamquam|quamquam|bien que
pauper|pauper|pauvre
pecunia|pecūnia|argent
fidelis|fidēlis|fidèle
absum|absum|être absent
taceo|taceō|se taire
rideo|rīdeō|rire
cedo|cēdō|céder
donec|dōnec|jusqu’à ce que
ubi|ubi|quand
simul|simul|en même temps
audio|audiō|entendre
respondeo|respondeō|répondre
aperio|aperiō|ouvrir
porta|porta|porte
clamo|clāmō|crier
quaero|quaerō|chercher
morior|morior|mourir
nox|nox|nuit
fio|fīō|devenir
dormio|dormiō|dormir
sol|sōl|soleil
orior|orior|se lever
''' 

def add(base, id, latin, correct, wrong, vocab, explanation, french=None):
    f = copy.deepcopy(next(f for f in BASE if f['id'] == base))
    f.update(id=id, latin=latin, correct=correct, wrong=wrong,
             vocabulary=vocab.split(), explanation=explanation)
    if french is not None: f['french'] = french
    for key in ['correct','french']:
        if key in f: f[key] = f[key].replace('à {a.fr}','{a.to}').replace('à {b.fr}','{b.to}')
    f['wrong'] = [s.replace('à {a.fr}','{a.to}').replace('à {b.fr}','{b.to}') for s in f['wrong']]
    FRAMES.append(f)

# Sequence of tenses: primary/historic main verbs, simultaneity/anteriority.
add('sequence-past-question','sequence-primary-simultaneous',
    '{a.nom} rogat quid {b.nom} faciat.',
    '{a.fr} demande ce que {b.fr} fait actuellement.',
    ['{a.fr} demande ce que {b.fr} a fait auparavant.',
     '{a.fr} demande ce que {b.fr} fera plus tard.'],
    'rogo quis facio', 'Rogat praesēns cum faciat praesente coniungitur: actiōnēs eōdem tempore pōnuntur.')
add('sequence-past-question','sequence-historic-anterior',
    '{a.nom} rogāvit quid {b.nom} fēcisset.',
    '{a.fr} a demandé ce que {b.fr} avait fait auparavant.',
    ['{a.fr} a demandé ce que {b.fr} faisait alors.',
     '{a.fr} a demandé ce que {b.fr} ferait ensuite.'],
    'rogo quis facio', 'Fēcisset plusquamperfectum rem priōrem interrogātiōne praeteritā exprimit.')
add('sequence-past-question','sequence-primary-anterior',
    '{a.nom} rogat quid {b.nom} fēcerit.',
    '{a.fr} demande ce que {b.fr} a fait auparavant.',
    ['{a.fr} demande ce que {b.fr} fait actuellement.',
     '{a.fr} demande ce que {b.fr} fera ensuite.'],
    'rogo quis facio', 'Fēcerit perfectum coniūnctīvī rem priōrem interrogātiōne praesente exprimit.')
add('produce-sequence-past','produce-sequence-primary',
    '{a.nom} quaerit quid {b.nom} ___.', 'scrībat',['scrīpserit','scrīpsisset'],
    'quaero quis scribo', 'Post quaerit scrībat actiōnem praesentem eōdem tempore exprimit.',
    '{a.fr} demande ce que {b.fr} écrit actuellement.')
add('produce-sequence-past','produce-sequence-prior-primary',
    '{a.nom} quaerit quid {b.nom} iam ___.','scrīpserit',['scrībat','scrīberet'],
    'quaero quis iam scribo', 'Scrīpserit actiōnem ante quaerit iam perfectam exprimit.',
    '{a.fr} demande ce que {b.fr} a déjà écrit.')
add('produce-sequence-past','produce-sequence-prior-historic',
    '{a.nom} quaesīvit quid {b.nom} iam ___.','scrīpsisset',['scrīberet','scrībat'],
    'quaero quis iam scribo', 'Scrīpsisset actiōnem ante interrogātiōnem praeteritam iam perfectam exprimit.',
    '{a.fr} a demandé ce que {b.fr} avait déjà écrit.')

# Indirect questions: the question word determines what information is missing.
add('indirect-why','indirect-when', '{a.nom} nescit quandō {b.nom} redeat.',
    '{a.fr} ignore quand {b.fr} revient.',
    ['{a.fr} ignore pourquoi {b.fr} revient.', '{a.fr} ignore par où {b.fr} revient.'],
    'nescio quando redeo', 'Quandō tempus reditūs quaerit, nōn causam nec viam.')
add('indirect-why','indirect-who', '{a.nom} nescit quis {b.acc} vocet.',
    '{a.fr} ignore qui appelle {b.fr}.',
    ['{a.fr} ignore qui est appelé par {b.fr}.', '{a.fr} ignore pourquoi {b.fr} appelle.'],
    'nescio quis voco', 'Quis nōminātīvus persōnam vocantem quaerit; {b.acc} obiectum est.')
add('indirect-why','indirect-where', '{a.nom} nescit ubi {b.nom} labōret.',
    '{a.fr} ignore où {b.fr} travaille.',
    ['{a.fr} ignore pourquoi {b.fr} travaille.', '{a.fr} ignore quand {b.fr} travaille.'],
    'nescio ubi laboro', 'Ubi locum labōris quaerit. Interrogātiō post nescit oblīqua est.')
add('produce-indirect-present','produce-indirect-when',
    'Dīc mihi ___ {a.nom} redeat.', 'quandō',['cūr','quis'],
    'dico ego quando cur quis redeo', 'Quandō tempus quaerit; cūr causam, quis persōnam quaereret.',
    'Dis-moi quand {a.fr} revient.')
add('produce-indirect-present','produce-indirect-where',
    'Dīc mihi ___ {a.nom} labōret.', 'ubi',['cūr','quis'],
    'dico ego ubi cur quis laboro', 'Ubi locum quaerit. Labōret in interrogātiōne oblīquā coniūnctīvus est.',
    'Dis-moi où {a.fr} travaille.')
add('produce-indirect-present','produce-indirect-agent',
    'Dīc mihi ___ {a.acc} vocet.', 'quis',['quem','cui'],
    'dico ego quis voco', 'Quis subiectum vocet est. Quem obiectum alterum faceret, cui accipientem indicāret.',
    'Dis-moi qui appelle {a.fr}.')

# Result clauses use different correlatives and predicates.
add('result-praise','result-no-understanding',
    '{a.nom} ita loquitur ut {b.nom} nihil intellegat.',
    '{a.fr} parle de telle façon que {b.fr} ne comprend rien.',
    ['{a.fr} parle dans le but que {b.fr} ne comprenne rien.',
     '{a.fr} parle parce que {b.fr} ne comprend rien.'],
    'ita loquor ut nihil intellego', 'Ita … ut effectum sermōnis indicat; nōn cōnsilium fraudandī affirmat.')
add('result-praise','result-voice',
    '{a.nom} tantā vōce clāmat ut {b.nom} eum audiat.',
    '{a.fr} crie si fort que {b.fr} l’entend.',
    ['{a.fr} crie fort afin que {b.fr} l’entende.',
     '{a.fr} crie fort parce que {b.fr} l’entend.'],
    'tantus vox clamo ut is audio', 'Tantā vōce … ut effectum magnitūdinis vōcis exprimit.')
add('result-praise','result-hidden',
    '{a.nom} adeō sē occultat ut {b.nom} eum nōn inveniat.',
    '{a.fr} se cache si bien que {b.fr} ne le trouve pas.',
    ['{a.fr} se cache afin que {b.fr} ne le trouve pas.',
     '{a.fr} se cache parce que {b.fr} ne le trouve pas.'],
    'adeo se occulto ut is non invenio', 'Adeō … ut nōn effectum negātum exprimit. Sententia fīnālis negāta nē haberet.')
add('produce-result-inability','produce-result-negative',
    '{a.nom} ita loquitur ___ {b.nom} nihil intellegat.', 'ut',['quia','quamvīs'],
    'ita loquor ut quia quamvis nihil intellego', 'Ita … ut effectum exprimit. Nihil negātiōnem effectūs continet.',
    '{a.fr} parle de telle façon que {b.fr} ne comprend rien.')
add('produce-result-inability','produce-result-historic',
    '{a.nom} tam fessus erat ut ambulāre nōn ___.','posset',['possit','potuisset'],
    'tam fessus sum ut ambulo non possum', 'Posset effectum eōdem tempore ac erat exprimit; potuisset antērioritātem dīceret.',
    '{a.fr} était si fatigué qu’il ne pouvait pas marcher.')
add('produce-result-inability','produce-result-no-find',
    '{a.nom} adeō sē occultat ut {b.nom} eum ___ inveniat.', 'nōn',['nē','nihil'],
    'adeo se occulto ut is non ne nihil invenio', 'In consecutīvā ut nōn ponitur. Nē fīnem negātum intrōdūceret; nihil cum eum obiectum mutāret.',
    '{a.fr} se cache si bien que {b.fr} ne le trouve pas.')

# Concession: finite facts, hypothetical admission, and correlative tamen.
add('concession-fear','concession-poverty',
    'Quamquam {a.nom} pauper est, tamen {b.dat} pecūniam dat.',
    'Bien que {a.fr} soit pauvre, il donne pourtant de l’argent à {b.fr}.',
    ['Parce que {a.fr} est pauvre, il donne de l’argent à {b.fr}.',
     'Afin que {a.fr} soit pauvre, il donne de l’argent à {b.fr}.'],
    'quamquam pauper sum tamen pecunia do', 'Quamquam paupertātem ut rem certam admittit; tamen dōnum contrā exspectātiōnem addit.')
add('concession-fear','concession-admission',
    'Etsī {a.nom} taceat, tamen {b.nom} respondet.',
    'Même si {a.fr} se tait, {b.fr} répond pourtant.',
    ['Parce que {a.fr} se tait, {b.fr} répond.',
     'Pour que {a.fr} se taise, {b.fr} répond.'],
    'etsi taceo tamen respondeo', 'Etsī rem etiam admissam cōnsiliō vel causae nōn aequat; tamen concessiōnem confirmat.')
add('concession-fear','concession-absence',
    'Tametsī {a.nom} abest, tamen {b.nom} eum laudat.',
    'Bien que {a.fr} soit absent, {b.fr} le loue pourtant.',
    ['Parce que {a.fr} est absent, {b.fr} le loue.',
     'Afin que {a.fr} soit absent, {b.fr} le loue.'],
    'tametsi absum tamen is laudo', 'Tametsī absentiam admittit, sed laudem nōn impeditam esse ostendit.')
add('produce-concession','produce-concession-correlative',
    'Quamquam {a.nom} pauper est, ___ {b.dat} pecūniam dat.', 'tamen',['itaque','quia'],
    'quamquam pauper sum tamen itaque quia pecunia do', 'Tamen contrārium exspectātiōnī post concessiōnem signat; itaque effectum causae significāret.',
    'Bien que {a.fr} soit pauvre, il donne pourtant de l’argent à {b.fr}.')
add('produce-concession','produce-concession-past',
    'Quamvīs {a.nom} fessus ___, tamen {b.dat} grātiās agēbat.', 'esset',['sit','fuerit'],
    'quamvis fessus sum tamen gratia ago', 'Esset statum praeteritum eōdem tempore ac agēbat exprimit.',
    'Bien que {a.fr} fût fatigué, il remerciait pourtant {b.fr}.')
add('produce-concession','produce-concession-link',
    '___ {a.nom} abest, tamen {b.nom} eum laudat.', 'Tametsī',['Quia','Ut'],
    'tametsi quia ut absum tamen is laudo', 'Tametsī cum tamen concessiōnem facit. Quia causam, ut aliud genus subōrdinātiōnis faceret.',
    'Bien que {a.fr} soit absent, {b.fr} le loue pourtant.')

# Temporal conjunctions: simultaneity, prior event, later event, endpoint.
add('while-writing','temporal-after-arrival',
    'Postquam {a.nom} advēnit, {b.nom} portam aperuit.',
    'Après que {a.fr} est arrivé, {b.fr} a ouvert la porte.',
    ['Avant que {a.fr} arrive, {b.fr} a ouvert la porte.',
     'Pendant que {a.fr} arrivait, {b.fr} a ouvert la porte.'],
    'postquam advenio porta aperio', 'Postquam adventum priōrem apertūrā portae facit.')
add('while-writing','temporal-before-reply',
    '{a.nom} discessit antequam {b.nom} responderet.',
    '{a.fr} est parti avant que {b.fr} réponde.',
    ['{a.fr} est parti après que {b.fr} a répondu.',
     '{a.fr} est parti parce que {b.fr} avait répondu.'],
    'discedo antequam respondeo', 'Antequam responsum post discessum pōnit; nōn responsum iam datum nārrat.')
add('while-writing','temporal-until-arrival',
    '{a.nom} manēbat dōnec {b.nom} vēnit.',
    '{a.fr} restait jusqu’à ce que {b.fr} arrive.',
    ['{a.fr} restait avant que {b.fr} commence à venir, puis partait nécessairement avant son arrivée.',
     '{a.fr} restait seulement après que {b.fr} était arrivé.'],
    'maneo donec venio', 'Dōnec adventum terminum morae facit; mora adventum antecedit et ad eum pertinet.')
add('produce-after','produce-temporal-while',
    '___ {a.nom} scrībit, {b.nom} legit.', 'Dum',['Postquam','Priusquam'],
    'dum scribo lego postquam priusquam', 'Dum simultāneitātem, nōn actiōnem priōrem aut posteriōrem exprimit.',
    'Pendant que {a.fr} écrit, {b.fr} lit.')
add('produce-after','produce-temporal-before',
    '{a.nom} discessit ___ {b.nom} responderet.', 'antequam',['postquam','quia'],
    'discedo antequam postquam quia respondeo', 'Antequam responsum post discessum pōnit.',
    '{a.fr} est parti avant que {b.fr} réponde.')
add('produce-after','produce-temporal-until',
    '{a.nom} manēbat ___ {b.nom} vēnit.', 'dōnec',['postquam','quamquam'],
    'maneo donec postquam quamquam venio', 'Dōnec terminum morae indicat. Postquam ordinem inverteret; quamquam concessiōnem adderet.',
    '{a.fr} restait jusqu’à ce que {b.fr} arrive.')

# Cum historicum: simultaneous background and anterior circumstances.
add('historical-cum-arrival','cum-prior-writing',
    'Cum {a.nom} epistulam scrīpsisset, {b.acc} vocāvit.',
    'Après avoir écrit la lettre, {a.fr} a appelé {b.fr}.',
    ['Pendant qu’il écrivait la lettre, {a.fr} a appelé {b.fr}.',
     'Avant d’écrire la lettre, {a.fr} a appelé {b.fr}.'],
    'cum epistula scribo voco', 'Scrīpsisset rem ante vocāvit perfectam exprimit; scrīberet rem simul factam indicāret.')
add('historical-cum-arrival','cum-simultaneous-sleep',
    'Cum {a.nom} dormīret, {b.nom} portam aperuit.',
    'Alors que {a.fr} dormait, {b.fr} a ouvert la porte.',
    ['Après que {a.fr} eut fini de dormir, {b.fr} a ouvert la porte.',
     'Avant que {a.fr} commence à dormir, {b.fr} a ouvert la porte.'],
    'cum dormio porta aperio', 'Dormīret somnum apertūrā portae dūrantem exprimit.')
add('historical-cum-arrival','cum-prior-arrival',
    'Cum {a.nom} advēnisset, {b.nom} labōrāre coepit.',
    'Après que {a.fr} fut arrivé, {b.fr} a commencé à travailler.',
    ['Avant que {a.fr} arrive, {b.fr} a commencé à travailler.',
     'Pendant que {a.fr} était encore en chemin, {b.fr} a commencé à travailler.'],
    'cum advenio laboro coepi', 'Advēnisset adventum ante initium labōris iam perfectum pōnit.')
add('produce-historical-background','produce-cum-prior-letter',
    'Cum {a.nom} epistulam ___, {b.nom} eam lēgit.', 'scrīpsisset',['scrīberet','scrībat'],
    'cum epistula scribo is lego', 'Scrīpsisset scrīptūram priōrem lēctiōne exprimit.',
    'Après que {a.fr} eut écrit la lettre, {b.fr} l’a lue.')
add('produce-historical-background','produce-cum-sleep',
    'Cum {a.nom} ___, {b.nom} portam aperuit.', 'dormīret',['dormīvisset','dormiat'],
    'cum dormio porta aperio', 'Dormīret statum dūrantem eōdem tempore ac aperuit exprimit.',
    'Alors que {a.fr} dormait, {b.fr} a ouvert la porte.')
add('produce-historical-background','produce-cum-prior-arrival',
    'Cum {a.nom} ___, {b.nom} labōrāre coepit.', 'advēnisset',['advenīret','adveniat'],
    'cum advenio laboro coepi', 'Advēnisset adventum iam perfectum ante initium labōris exprimit.',
    'Après que {a.fr} fut arrivé, {b.fr} a commencé à travailler.')
LEXICON += '''
iam|iam|déjà
loquor|loquor|parler
nihil|nihil|rien
occulto|occultō|cacher
se|sē|soi
vox|vōx|voix
quia|quia|parce que
epistula|epistula|lettre
coepi|coepī|j’ai commencé
'''
# Canonical lexical entries cover the senses actually used in these units.
LEXICON += '''
ubi|ubi|où, lorsque
ut|ut|que, pour que
ne|nē|ne… pas, de peur que
coepi|coepī|commencer
'''
LEXICON += '''
quoniam|quoniam|puisque
idcirco|idcircō|pour cette raison
gaudeo|gaudeō|se réjouir
adsum|adsum|être présent
munus|mūnus|cadeau
negotium|negōtium|affaire
nuntio|nūntiō|annoncer
porto|portō|porter
'''
add('cause-prior-call','cause-present-reason',
    '{a.nom} gaudet quia {b.nom} adest.',
    '{a.fr} se réjouit parce que {b.fr} est présent.',
    ['{a.fr} se réjouit pour que {b.fr} soit présent.',
     '{a.fr} se réjouit bien que {b.fr} soit absent.'],
    'gaudeo quia adsum', 'Quia praesentiam causam gaudiī facit, nōn cōnsilium futūrum.')
add('cause-prior-call','cause-known-reason',
    'Quoniam {a.nom} abest, {b.nom} sōlus labōrat.',
    'Puisque {a.fr} est absent, {b.fr} travaille seul.',
    ['Afin que {a.fr} soit absent, {b.fr} travaille seul.',
     'Bien que {a.fr} soit présent, {b.fr} travaille seul.'],
    'quoniam absum solus laboro', 'Quoniam causam ut rem nōtam intrōdūcit.')
add('cause-prior-call','cause-cum-explicit-consequence',
    'Cum {a.nom} absit, idcircō {b.nom} sōlus labōrat.',
    'Comme {a.fr} est absent, {b.fr} travaille seul pour cette raison.',
    ['Bien que {a.fr} soit absent, {b.fr} travaille seul malgré cette absence.',
     'Afin que {a.fr} soit absent, {b.fr} travaille seul.'],
    'cum absum idcirco solus laboro', 'Idcircō nexum causae confirmat. Cum absit hīc causāle est, nōn sōlum tempus indicat.')
add('produce-because','produce-cause-known',
    '___ {a.nom} abest, {b.nom} sōlus labōrat.', 'Quoniam',['Quamvīs','Ut'],
    'quoniam quamvis ut absum solus laboro', 'Quoniam causam intrōdūcit, nōn concessiōnem vel fīnem.',
    'Puisque {a.fr} est absent, {b.fr} travaille seul.')
add('produce-because','produce-subordinate-cause-joy',
    '{a.nom} gaudet ___ {b.nom} adest.', 'quia',['ut','quamvīs'],
    'gaudeo quia ut quamvis adsum', 'Quia causam gaudiī exprimit. Indicātīvus adest praesentiam affirmat.',
    '{a.fr} se réjouit parce que {b.fr} est présent.')
add('produce-because','produce-cause-cum',
    'Cum {a.nom} ___, idcircō {b.nom} sōlus labōrat.', 'absit',['abesset','āfuisset'],
    'cum absum idcirco solus laboro', 'Cum causāle coniūnctīvum habet. Absit causam praesentem, nōn priōrem statum praeteritum exprimit.',
    'Comme {a.fr} est absent, {b.fr} travaille seul pour cette raison.')

add('relative-purpose-envoy','relative-purpose-letter',
    '{a.nom} {b.acc} mittit quī epistulam portet.',
    '{a.fr} envoie {b.fr} pour qu’il porte la lettre.',
    ['{a.fr} envoie {b.fr} parce qu’il a déjà porté la lettre.',
     '{a.fr} envoie {b.fr} bien qu’il ait refusé de porter la lettre.'],
    'mitto qui epistula porto', 'Quī portet cōnsilium missiōnis exprimit, nōn factum iam perfectum.')
add('relative-purpose-envoy','relative-purpose-plural',
    '{a.nom} {b.accpl} mittit quī portam aperiant.',
    '{a.fr} envoie les {b.frpl} pour qu’ils ouvrent la porte.',
    ['{a.fr} envoie les {b.frpl} parce qu’ils ont déjà ouvert la porte.',
     '{a.fr} envoie un seul membre du groupe des {b.frpl} pour qu’il ouvre la porte.'],
    'mitto qui porta aperio', 'Quī aperiant cōnsilium exprimit; aperiant plūrāle cum antecēdente plūrālī congruit.')
FRAMES[-1]['additionalSkills'] = ['lectio.relative-number']
FRAMES[-1]['wrongSkills'] = [[FRAMES[-1]['skill']], ['lectio.relative-number']]
add('relative-purpose-envoy','relative-purpose-search',
    '{a.nom} {b.acc} mīsit quī {l.acc} quaereret.',
    '{a.fr} a envoyé {b.fr} pour qu’il cherche {l.fr}.',
    ['{a.fr} a envoyé {b.fr} parce qu’il avait déjà trouvé {l.fr}.',
     '{a.fr} a envoyé {b.fr} bien qu’il ait refusé de chercher {l.fr}.'],
    'mitto qui quaero', 'Quī quaereret fīnem missiōnis praeteritae exprimit.')
add('produce-relative-purpose','produce-purpose-secondary',
    '{a.nom} {b.acc} mīsit quī auxilium ___.', 'peteret',['petēbat','petat'],
    'mitto qui auxilium peto', 'Peteret coniūnctīvus imperfectus cōnsilium post mīsit exprimit. Petēbat factum nārrāret; petat cōnsecūtiōnem primāriam haberet.',
    '{a.fr} a envoyé {b.fr} pour qu’il cherche de l’aide.')
FRAMES[-1]['additionalSkills'] = ['compositio.curriculum.subordination.1']
FRAMES[-1]['wrongSkills'] = [[FRAMES[-1]['skill']], ['compositio.curriculum.subordination.1']]
add('produce-relative-purpose','produce-purpose-plural',
    '{a.nom} {b.accpl} mittit quī auxilium ___.', 'petant',['petunt','petat','peterent'],
    'mitto qui auxilium peto', 'Petant coniūnctīvus praesēns plūrālis est: cōnsilium, tempus prīmārium et numerum antecēdentis servat.',
    '{a.fr} envoie les {b.frpl} pour qu’ils cherchent de l’aide.')
FRAMES[-1]['additionalSkills'] = ['compositio.relative-number', 'compositio.curriculum.subordination.1']
FRAMES[-1]['wrongSkills'] = [[FRAMES[-1]['skill']], ['compositio.relative-number'], ['compositio.curriculum.subordination.1']]
add('produce-relative-purpose','produce-purpose-letter',
    '{a.nom} {b.acc} mittit quī epistulam ___.', 'portet',['portat','portābat'],
    'mitto qui epistula porto', 'Portet coniūnctīvus cōnsilium exprimit; portat vel portābat factum indicātīvō nārrārent.',
    '{a.fr} envoie {b.fr} pour qu’il porte la lettre.')
LEXICON += '''
prodo|prōdō|trahir
fallo|fallō|tromper
fugio|fugiō|fuir
metuo|metuō|craindre
redeo|redeō|revenir
prohibeo|prohibeō|empêcher
obsto|obstō|faire obstacle
dubius|dubius|douteux
dubitatio|dubitātiō|doute
nullus|nūllus|aucun
'''

# Characteristic relative: disposition, not an assertion about one past act.
for suffix, subjunctive, infinitive, french, past, vocab in [
    ('betray','prōdat','prōdere','trahir','a trahi','prodo'),
    ('deceive','fallat','fallere','tromper','a trompé','fallo'),
    ('flee','fugiat','fugere','fuir','a fui','fugio'),
]:
    add('relative-character','relative-character-'+suffix,
        '{a.nom} nōn is est quī {b.acc} '+subjunctive+'.',
        '{a.fr} n’est pas homme à '+french+' {b.fr}.',
        ['{a.fr} est précisément celui qui '+past+' {b.fr}.',
         '{a.fr} ordonne à {b.fr} de le '+french+'.'],
        'non is sum qui '+vocab,
        'Nōn is est quī … indolem negat; nōn actiōnem singulam praeteritam nec iussum nārrat.')
for suffix, correct, wrong, french, vocab in [
    ('betray','prōdat',['prōdit','prōdiderit'],'trahir','prodo'),
    ('deceive','fallat',['fallit','fefellerit'],'tromper','fallo'),
    ('flee','fugiat',['fugit','fūgerit'],'fuir','fugio'),
]:
    add('produce-relative-character','produce-character-'+suffix,
        '{a.nom} nōn is est quī {b.acc} ___.', correct, wrong,
        'non is sum qui '+vocab,
        'Coniūnctīvus praesēns indolem persōnae exprimit. Indicātīvus factum certum, perfectum rem priōrem dīceret.',
        '{a.fr} n’est pas homme à '+french+' {b.fr}.')

# Fear complements: ne + event, ne non / ut + absence of an event.
add('fear-leaving','fear-no-return',
    '{a.nom} timet nē {b.nom} nōn redeat.',
    '{a.fr} craint que {b.fr} ne revienne pas.',
    ['{a.fr} craint que {b.fr} revienne.',
     '{a.fr} a peur dans le but que {b.fr} ne revienne pas.'],
    'timeo ne non redeo', 'Nē nōn reditum nōn futūrum timendum facit. Hic nē sententiam fīnālem nōn introducit.')
add('fear-leaving','fear-ut-arrival',
    '{a.nom} timet ut {b.nom} veniat.',
    '{a.fr} craint que {b.fr} ne vienne pas.',
    ['{a.fr} craint que {b.fr} vienne.',
     '{a.fr} a peur dans le but que {b.fr} vienne.'],
    'timeo ut venio', 'Post verbum timendī ut idem valet atque nē nōn: absentia adventūs timētur.')
add('fear-leaving','fear-prior-reading',
    '{a.nom} metuit nē {b.nom} epistulam lēgerit.',
    '{a.fr} craint que {b.fr} ait lu la lettre.',
    ['{a.fr} craint que {b.fr} n’ait pas lu la lettre.',
     '{a.fr} a peur dans le but que {b.fr} ait lu la lettre.'],
    'metuo ne epistula lego', 'Nē lēgerit lēctiōnem iam factam timendam pōnit. Nē hīc lēctiōnem nōn negat.')
add('produce-fear-negated-event','produce-fear-arrival',
    '{a.nom} timet ___ {b.nom} veniat.', 'nē',['nē nōn','quia'],
    'timeo ne non quia venio', 'Nē adventum ipsum timendum facit; nē nōn adventum nōn futūrum timēret.',
    '{a.fr} craint que {b.fr} vienne.')
add('produce-fear-negated-event','produce-fear-ut',
    '{a.nom} timet ___ {b.nom} redeat.', 'ut',['nē','postquam'],
    'timeo ut ne postquam redeo', 'Ut post timet idem valet atque nē nōn; postquam aliud tempus, nōn hunc timōrem, exprimeret.',
    '{a.fr} craint que {b.fr} ne revienne pas.')
add('produce-fear-negated-event','produce-fear-read',
    '{a.nom} metuit ___ {b.nom} epistulam lēgerit.', 'nē',['nē nōn','quia'],
    'metuo ne non quia epistula lego', 'Nē lēctiōnem iam factam timendam facit. Negātiō nōn ad lēctionem transfertur.',
    '{a.fr} craint que {b.fr} ait lu la lettre.')

# Prevention: different governing constructions and explicit negation.
add('prevent-departure','prevent-ne',
    '{a.nom} prohibet nē {b.nom} exeat.',
    '{a.fr} empêche {b.fr} de sortir.',
    ['{a.fr} empêche {b.fr} de rester à l’intérieur.',
     '{a.fr} donne à {b.fr} l’ordre de sortir.'],
    'prohibeo ne exeo', 'Post prohibet nē actiōnem impeditam exprimit. Exitus, nōn mora, impeditur.')
add('prevent-departure','prevent-obstacle',
    '{a.nom} {b.dat} obstat quōminus epistulam legat.',
    '{a.fr} fait obstacle à la lecture de la lettre par {b.fr}.',
    ['{a.fr} fait obstacle au refus de {b.fr} de lire la lettre.',
     '{a.fr} ordonne à {b.fr} de lire la lettre.'],
    'obsto quominus epistula lego', 'Quōminus lēctiōnem impeditam exprimit. Datīvus persōnam cui obstat indicat.')
add('prevent-departure','prevent-not',
    '{a.nom} nōn impedit quōminus {b.nom} veniat.',
    '{a.fr} n’empêche pas {b.fr} de venir.',
    ['{a.fr} empêche {b.fr} de venir.',
     '{a.fr} empêche {b.fr} de ne pas venir.'],
    'non impedio quominus venio', 'Nōn impedīmentum negat; quōminus actiōnem nōn impeditam intrōdūcit.')
add('produce-prevention','produce-prevention-ne',
    '{a.nom} prohibet ___ {b.nom} exeat.', 'nē',['ut','quia'],
    'prohibeo ne ut quia exeo', 'Nē post prohibet actiōnem vetitam intrōdūcit.',
    '{a.fr} empêche {b.fr} de sortir.')
add('produce-prevention','produce-prevention-obstacle',
    '{a.nom} {b.dat} obstat ___ epistulam legat.', 'quōminus',['postquam','quamvīs'],
    'obsto quominus postquam quamvis epistula lego', 'Quōminus lēctiōnem cui obstat intrōdūcit.',
    '{a.fr} fait obstacle à la lecture de la lettre par {b.fr}.')
add('produce-prevention','produce-prevention-negative',
    '{a.nom} nōn impedit ___ {b.nom} veniat.', 'quīn',['ut','quia'],
    'non impedio quin ut quia venio', 'Post nōn impedit quīn licet: actiōnem nōn impeditam intrōdūcit.',
    '{a.fr} n’empêche pas {b.fr} de venir.')

# Quin after denied doubt: verbal and nominal antecedents, present and past.
add('certainty-quin','certainty-nominal',
    'Nōn est dubium quīn {a.nom} {b.acc} iuvet.',
    'Il ne fait aucun doute que {a.fr} aide {b.fr}.',
    ['Il est douteux que {a.fr} aide {b.fr}.',
     'Il ne fait aucun doute que {a.fr} n’aide pas {b.fr}.'],
    'non sum dubius quin iuvo', 'Nōn est dubium quīn certitūdinem auxiliī exprimit. Quīn nōn novam negātiōnem actiōnī addit.')
add('certainty-quin','certainty-historic',
    '{a.nom} nōn dubitāvit quīn {b.nom} adesset.',
    '{a.fr} n’a pas douté que {b.fr} fût présent.',
    ['{a.fr} a douté que {b.fr} fût présent.',
     '{a.fr} n’a pas douté que {b.fr} fût absent.'],
    'non dubito quin adsum', 'Nōn dubitāvit dubitātiōnem negat. Adesset praesentiam eō tempore exprimit.')
add('certainty-quin','certainty-no-doubt',
    'Nūlla dubitātiō est quīn {a.nom} {b.acc} audiat.',
    'Il n’y a aucun doute que {a.fr} entende {b.fr}.',
    ['Il y a un doute que {a.fr} entende {b.fr}.',
     'Il n’y a aucun doute que {a.fr} n’entende pas {b.fr}.'],
    'nullus dubitatio sum quin audio', 'Nūlla dubitātiō negātiōnem dubitātiōnis continet; quīn actiōnem nōn negat.')
add('produce-certainty','produce-certainty-nominal',
    'Nōn est dubium ___ {a.nom} {b.acc} iuvet.', 'quīn',['nē','postquam'],
    'non sum dubius quin ne postquam iuvo', 'Quīn post dubium negātum sententiam certam intrōdūcit.',
    'Il ne fait aucun doute que {a.fr} aide {b.fr}.')
add('produce-certainty','produce-certainty-historic',
    '{a.nom} nōn dubitāvit ___ {b.nom} adesset.', 'quīn',['nē','quōminus'],
    'non dubito quin ne quominus adsum', 'Quīn post nōn dubitāvit ponitur; adesset cōnsecūtiōnem historicam servat.',
    '{a.fr} n’a pas douté que {b.fr} fût présent.')
add('produce-certainty','produce-certainty-null',
    'Nūlla dubitātiō est ___ {a.nom} {b.acc} audiat.', 'quīn',['nē','postquam'],
    'nullus dubitatio sum quin ne postquam audio', 'Nūlla dubitātiō negātiōnem praebet quae quīn admittit.',
    'Il n’y a aucun doute que {a.fr} entende {b.fr}.')
