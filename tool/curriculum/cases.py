"""Authored case-use exercises. Books are breadth guidelines, not text sources.

R: interpret a Latin situation. P: formulate a specified French meaning.
Substitution pools are constrained to human agents and physical places; they
change participants, referents and locations, never merely choice order.
"""
ACTORS = {
    'poeta': 'le poète', 'nauta': 'le marin', 'agricola': 'le paysan',
    'servus': 'l’esclave', 'dominus': 'le maître', 'amicus': 'l’ami',
    'filius': 'le fils', 'puer': 'le garçon', 'magister': 'le professeur',
    'vir': 'l’homme', 'rex': 'le roi', 'dux': 'le chef',
    'iudex': 'le juge', 'consul': 'le consul', 'miles': 'le soldat',
    'eques': 'le cavalier', 'princeps': 'le prince', 'orator': 'l’orateur',
    'senator': 'le sénateur', 'pater': 'le père', 'frater': 'le frère',
    'sacerdos': 'le prêtre', 'iuvenis': 'le jeune homme', 'senex': 'le vieillard',
}
PLACES = {
    'hortus': 'le jardin', 'ager': 'le champ', 'templum': 'le temple',
    'oppidum': 'la ville fortifiée', 'silva': 'la forêt', 'insula': 'l’île',
    'portus': 'le port', 'urbs': 'la ville', 'arx': 'la citadelle',
    'domus': 'la maison', 'navis': 'le navire', 'turris': 'la tour',
}
# Additional fixed words, independent of variable noun inflection.
LEXICON = '''
pars|pars|partie
unus|ūnus|un
habeo|habeō|avoir
sum|sum|être
venio|veniō|venir
in|in|dans
ad|ad|vers
multus|multus|nombreux
nemo|nēmō|personne
alius|alius|autre
solus|sōlus|seul
consilium|cōnsilium|conseil
auxilium|auxilium|aide
donum|dōnum|cadeau
do|dō|donner
liber|liber|livre
emo|emō|acheter
vendo|vēndō|vendre
denarius|dēnārius|denier
quinque|quīnque|cinq
decem|decem|dix
pretium|pretium|prix
magnus|magnus|grand
parvus|parvus|petit
tantus|tantus|si grand
quantus|quantus|de quel prix
virtus|virtūs|courage
animus|animus|esprit
fortis|fortis|courageux
bonus|bonus|bon
spes|spēs|espoir
metus|metus|crainte
gaudium|gaudium|joie
fames|famēs|faim
ira|īra|colère
amor|amor|amour
morbus|morbus|maladie
fessus|fessus|fatigué
labor|labor|travail
pereo|pereō|périr
tremo|tremō|trembler
lacrimo|lacrimō|pleurer
mors|mors|mort
fleo|fleō|pleurer
maneo|maneō|rester
proficiscor|proficīscor|partir
curro|currō|courir
dies|diēs|jour
tres|trēs|trois
duo|duo|deux
hora|hōra|heure
mille|mīlle|mille
passus|passus|pas
absum|absum|être absent
pedes|pedēs|à pied
iter|iter|voyage
longus|longus|long
altus|altus|haut
pes|pēs|pied
murus|mūrus|mur
meus|meus|mon
tuus|tuus|ton
nomen|nōmen|nom
marcus|Mārcus|Marcus
cui|cui|à qui
quis|quis|qui
rogatio|rogātiō|demande
rogo|rogō|demander
sententia|sententia|avis
doceo|doceō|enseigner
lingua|lingua|langue
latinus|Latīnus|latin
appello|appellō|appeler
creo|creō|élire
puto|putō|penser
sapientia|sapientia|sagesse
maior|maior|plus grand
minor|minor|plus petit
melior|melior|meilleur
peior|peior|pire
quam|quam|que
paulo|paulō|un peu
multo|multō|beaucoup
ante|ante|avant
post|post|après
celer|celer|rapide
celeriter|celeriter|rapidement
celerius|celerius|plus rapidement
senior|senior|plus âgé
iunior|iūnior|plus jeune
annus|annus|année
sed|sed|mais
non|nōn|ne pas
et|et|et
nam|nam|car
itaque|itaque|donc
ille|ille|celui-là
hic|hic|celui-ci
hic_adv|hīc|ici
neque|neque|et ne pas
pecunia|pecūnia|argent
opus|opus|besoin
usus|ūsus|usage
res|rēs|chose
carus|cārus|cher
auxilio|auxiliō|pour aider
'''

FRAMES = []
def R(id, topic, name, latin, correct, wrong, vocabulary, explanation):
    FRAMES.append(dict(id=id, place='theatrum', section='casuum-sensus',
        sectionName='Cāsūs in nārrātiōne', card=topic, name=name,
        skill=f'lectio.curriculum.case-uses.{topic}', latin=latin,
        correct=correct, wrong=wrong, vocabulary=vocabulary.split(),
        explanation=explanation, task='interpretatio-casuum'))

def P(id, topic, name, french, latin, correct, wrong, vocabulary, explanation):
    FRAMES.append(dict(id=id, place='templum', section='casuum-electio',
        sectionName='Cāsibus sententiam compōnere', card=topic, name=name,
        skill=f'compositio.curriculum.case-uses.{topic}', french=french,
        latin=latin, correct=correct, wrong=wrong, vocabulary=vocabulary.split(),
        explanation=explanation, task='compositio-casuum'))

R('partitive-council', '1', 'Pars et tōtum',
  '{a.nom} ūnus multōrum est. In {l.abl} cōnsilium dat.',
  '{a.fr} est un homme parmi beaucoup d’autres. Dans {l.fr}, il donne un conseil.',
  ['{a.fr} est le seul homme. Dans {l.fr}, il donne un conseil.',
   '{a.fr} possède beaucoup d’hommes. Dans {l.fr}, il donne un conseil.'],
  'unus multus sum in consilium do',
  'Multōrum genetīvus tōtum indicat; ūnus pars huius tōtī est. Ūnus multōrum nōn idem est atque sōlus.')
R('partitive-group', '1', 'Pars et tōtum',
  'Ūnus {a.genpl} in {l.abl} manet; aliī proficīscuntur.',
  'Un membre du groupe des {a.frpl} reste dans {l.fr} ; les autres partent.',
  ['Tous les {a.frpl} restent dans {l.fr} ; les autres partent.',
   'Un homme reste dans {l.fr} pour les {a.frpl} ; les autres partent.'],
  'unus in maneo alius proficiscor',
  'Ūnus cum genetīvō plūrālī unum ē plūribus dēsignat. Genetīvus nōn accipientem indicat.')
R('price-book', '2', 'Pretium et aestimātiō',
  '{a.nom} librum {b.gen} magnī emit.',
  '{a.fr} achète cher le livre appartenant à {b.fr}.',
  ['{a.fr} achète le grand livre appartenant à {b.fr}.',
   '{a.fr} achète à bas prix le livre appartenant à {b.fr}.'],
  'liber magnus emo',
  'Magnī cum emere pretium magnum significat; nōn cum librum congruit.')
R('price-low', '2', 'Pretium et aestimātiō',
  '{a.nom} librum {b.gen} parvī vēndit.',
  '{a.fr} vend à bas prix le livre appartenant à {b.fr}.',
  ['{a.fr} vend le petit livre appartenant à {b.fr}.',
   '{a.fr} vend cher le livre appartenant à {b.fr}.'],
  'liber parvus vendo',
  'Parvī genetīvus pretiī est: parvō pretiō. Librum parvum aliam rem dīceret.')
R('quality-courage', '3', 'Quālitās genetīvō expressa',
  '{a.nom} magnae virtūtis est; {b.nom} eum nōn timet.',
  '{a.fr} est d’un grand courage ; {b.fr} ne le craint pas.',
  ['{a.fr} possède un grand homme ; {b.fr} ne le craint pas.',
   '{a.fr} est sans courage ; {b.fr} ne le craint pas.'],
  'magnus virtus sum is non timeo',
  'Magnae virtūtis quālitātem persōnae exprimit. Genetīvus cum adiectīvō nōn rem possidēndam hīc indicat.')
R('possession-gift', '4', 'Possessiō datīvō expressa',
  '{a.dat} dōnum est. {b.nom} in {l.abl} manet.',
  '{a.fr} a un cadeau. {b.fr} reste dans {l.fr}.',
  ['{a.fr} est un cadeau. {b.fr} reste dans {l.fr}.',
   '{b.fr} a un cadeau. {a.fr} reste dans {l.fr}.'],
  'donum sum in maneo',
  'Datīvus cum esse possessōrem indicat: dōnum {a.dat} est idem valet atque {a.nom} dōnum habet.')
R('purpose-aid', '5', 'Datīvus fīnis',
  '{a.nom} auxiliō venit; {b.nom} in {l.abl} manet.',
  '{a.fr} vient pour apporter de l’aide ; {b.fr} reste dans {l.fr}.',
  ['{a.fr} vient grâce à l’aide reçue ; {b.fr} reste dans {l.fr}.',
   '{a.fr} vient sans aide ; {b.fr} reste dans {l.fr}.'],
  'auxilium venio in maneo',
  'Auxiliō datīvus fīnis est: cūr veniat ostendit. Auxiliō hīc nōn causam iam effectam indicat.')
R('double-dative', '6', 'Cui et cuī reī?',
  '{a.nom} {b.dat} auxiliō venit in {l.acc}.',
  '{a.fr} vient dans {l.fr} pour aider {b.fr}.',
  ['{a.fr} vient dans {l.fr} grâce à l’aide de {b.fr}.',
   '{b.fr} vient dans {l.fr} pour aider {a.fr}.'],
  'auxilium venio in',
  'Duo datīvī diversa mūnera habent: {b.dat} persōnam adiūtam, auxiliō fīnem adventūs indicat.')
R('distance-travel', '7', 'Spatium itineris',
  '{a.nom} tria mīlia passuum pedēs prōcēdit; {b.nom} manet.',
  '{a.fr} avance à pied sur trois milles ; {b.fr} reste.',
  ['{a.fr} avance à pied pendant trois jours ; {b.fr} reste.',
   '{a.fr} avance à pied jusqu’à trois voyageurs ; {b.fr} reste.'],
  'tres mille passus pedes procedo maneo',
  'Tria mīlia passuum spatium percursum accūsātīvō exprimit. Passuum genetīvus ad mīlia pertinet.')
R('duration-stay', '8', 'Quam diū?',
  '{a.nom} trēs diēs in {l.abl} manet; {b.nom} venit.',
  '{a.fr} reste trois jours dans {l.fr} ; {b.fr} arrive.',
  ['{a.fr} reste dans {l.fr} le troisième jour ; {b.fr} arrive.',
   '{a.fr} reste dans {l.fr} après trois jours ; {b.fr} arrive.'],
  'tres dies in maneo venio',
  'Trēs diēs quam diū maneat exprimit. Tertiō diē tempus, nōn spatium temporis, indicāret.')
R('double-accusative-teach', '9', 'Persōna et rēs docta',
  '{a.nom} {b.acc} linguam Latīnam docet in {l.abl}.',
  '{a.fr} enseigne le latin à {b.fr} dans {l.fr}.',
  ['{b.fr} enseigne le latin à {a.fr} dans {l.fr}.',
   '{a.fr} apprend le latin auprès de {b.fr} dans {l.fr}.'],
  'lingua latinus doceo in',
  'Docēre duōs accūsātīvōs admittit: persōnam quae discit et rem quam discit.')
R('ablative-comparison', '10', 'Quō maior?',
  '{a.nom} {b.abl} senior est. In {l.abl} manent.',
  '{a.fr} est plus âgé que {b.fr}. Ils restent dans {l.fr}.',
  ['{b.fr} est plus âgé que {a.fr}. Ils restent dans {l.fr}.',
   '{a.fr} vieillit avec {b.fr}. Ils restent dans {l.fr}.'],
  'senior sum in maneo',
  'Ablātīvus {b.abl} terminum comparātiōnis post senior indicat: senior quam {b.nom}.')
R('ablative-quality', '11', 'Quālitās ablātīvō expressa',
  '{a.nom} bonō animō est; {b.nom} in {l.abl} manet.',
  '{a.fr} est dans de bonnes dispositions ; {b.fr} reste dans {l.fr}.',
  ['{a.fr} a quitté ses bonnes dispositions ; {b.fr} reste dans {l.fr}.',
   '{a.fr} est avec un homme bon ; {b.fr} reste dans {l.fr}.'],
  'bonus animus sum in maneo',
  'Bonō animō quālitātem vel habitum animī exprimit. Nōn comitem nec locum unde quis exeat indicat.')
R('ablative-cause', '12', 'Cūr tremit?',
  '{a.nom} metū tremit; {b.nom} in {l.abl} manet.',
  '{a.fr} tremble de peur ; {b.fr} reste dans {l.fr}.',
  ['{a.fr} tremble pour faire peur ; {b.fr} reste dans {l.fr}.',
   '{a.fr} tremble malgré son absence de peur ; {b.fr} reste dans {l.fr}.'],
  'metus tremo in maneo',
  'Metū ablātīvus causae est: metus tremōrem efficit, nōn fīnis tremōris est.')
R('measure-comparison', '13', 'Quantō differt?',
  '{a.nom} multō senior est quam {b.nom}. In {l.abl} manent.',
  '{a.fr} est beaucoup plus âgé que {b.fr}. Ils restent dans {l.fr}.',
  ['{a.fr} est un peu plus âgé que {b.fr}. Ils restent dans {l.fr}.',
   '{a.fr} est beaucoup plus jeune que {b.fr}. Ils restent dans {l.fr}.'],
  'multo senior sum quam in maneo',
  'Multō ablātīvus mēnsūrae differentiae est. Quantum aetātēs differant indicat; senior comparātiōnem tenet.')

P('partitive-selection', '1', 'Tōtum genetīvō addere',
  'Un membre du groupe des {a.frpl} donne un conseil à {b.fr}.',
  'Ūnus ___ {b.dat} cōnsilium dat.', '{a.genpl}', ['{a.datpl}', '{a.accpl}'],
  'unus consilium do', 'Post ūnus tōtum ē quō pars sūmitur genetīvō exprimitur.')
P('price-genitive', '2', 'Pretium aestimāre',
  '{a.fr} vend cher le livre appartenant à {b.fr}.',
  '{a.nom} librum {b.gen} ___ vēndit.', 'magnī', ['magnum', 'magna'],
  'liber magnus vendo', 'Pretium indefīnītum magnī exprimitur. Magnum cum librum congrueret et magnitūdinem librī dīceret.')
P('quality-genitive', '3', 'Quālitātem genetīvō compōnere',
  '{a.fr} est d’un grand courage ; {b.fr} reste.',
  '{a.nom} ___ est; {b.nom} manet.', 'magnae virtūtis', ['magnam virtūtem', 'magna virtūs'],
  'magnus virtus sum maneo', 'Quālitās persōnae genetīvō cum adiectīvō exprimitur: magnae virtūtis.')
P('dative-owner', '4', 'Possessōrem datīvō pōnere',
  '{a.fr} a un livre. {b.fr} reste dans {l.fr}. Exprime la possession avec esse.',
  '___ liber est. {b.nom} in {l.abl} manet.', '{a.dat}', ['{a.acc}', '{a.abl}'],
  'liber sum in maneo', 'Possessōrem datīvō pōne; liber est subiectum verbī est.')
P('purpose-dative', '5', 'Fīnem datīvō indicāre',
  '{a.fr} vient pour aider. {b.fr} reste dans {l.fr}.',
  '{a.nom} ___ venit. {b.nom} in {l.abl} manet.', 'auxiliō', ['auxilium', 'auxiliī'],
  'auxilium venio in maneo', 'Auxiliō datīvus fīnis cum venit est. Auxilium accūsātīvus obiectum nōn potest esse verbī venīre.')
P('two-datives-recipient', '6', 'Duōs datīvōs coniungere',
  '{a.fr} vient au secours de {b.fr} dans {l.fr}.',
  '{a.nom} ___ auxiliō venit in {l.acc}.', '{b.dat}', ['{b.gen}', '{b.acc}'],
  'auxilium venio in', 'Cum auxiliō alter datīvus persōnam adiūtam indicat. Hīc {b.dat} scribendum est.')
P('distance-accusative', '7', 'Spatium accūsātīvō pōnere',
  '{a.fr} avance à pied sur trois milles ; {b.fr} reste.',
  '{a.nom} ___ pedēs prōcēdit; {b.nom} manet.', 'tria mīlia passuum', ['tribus mīlibus passuum', 'trium mīlium passuum'],
  'tres mille passus pedes procedo maneo', 'Spatium percursum accūsātīvō exprime: tria mīlia. Passuum ad mīlia pertinet.')
P('duration-accusative', '8', 'Spatium temporis compōnere',
  '{a.fr} reste trois jours dans {l.fr}, puis {b.fr} arrive.',
  '{a.nom} ___ in {l.abl} manet; deinde {b.nom} venit.', 'trēs diēs', ['tribus diēbus', 'tertiō diē'],
  'tres dies in maneo deinde venio', 'Quam diū? accūsātīvum poscit. Tertiō diē diem certum, nōn trīduī spatium, indicat.')
P('teach-person', '9', 'Persōnam et rem accūsātīvō pōnere',
  '{a.fr} enseigne le latin à {b.fr} dans {l.fr}.',
  '{a.nom} ___ linguam Latīnam docet in {l.abl}.', '{b.acc}', ['{b.dat}', '{b.gen}'],
  'lingua latinus doceo in', 'Docēre persōnam et rem accūsātīvō admittit; Gallicum « à » hīc datīvum nōn efficit.')
P('comparison-ablative', '10', 'Comparātiōnem sine quam compōnere',
  '{a.fr} est plus âgé que {b.fr}. Ils restent dans {l.fr}. Complète sans quam.',
  '{a.nom} ___ senior est. In {l.abl} manent.', '{b.abl}', ['{b.acc}', '{b.gen}'],
  'senior sum in maneo', 'Post comparātīvum sine quam terminus comparātiōnis ablātīvō exprimitur.')
P('quality-ablative', '11', 'Quālitātem ablātīvō compōnere',
  '{a.fr} est dans de bonnes dispositions. {b.fr} reste dans {l.fr}.',
  '{a.nom} ___ est. {b.nom} in {l.abl} manet.', 'bonō animō', ['bonum animum', 'bonus animus'],
  'bonus animus sum in maneo', 'Bonō animō ablātīvus quālitātis est; bonus animus subiectum aliud faceret.')
P('cause-ablative', '12', 'Causam ablātīvō compōnere',
  '{a.fr} tremble de peur. {b.fr} reste dans {l.fr}.',
  '{a.nom} ___ tremit. {b.nom} in {l.abl} manet.', 'metū', ['metum', 'metūs'],
  'metus tremo in maneo', 'Metū ablātīvus causae est. Tremere hīc causam tremōris, nōn obiectum timōris, habet.')
P('difference-ablative', '13', 'Differentiam mēnsūrāre',
  '{a.fr} est beaucoup plus âgé que {b.fr}. Ils restent dans {l.fr}.',
  '{a.nom} ___ senior est quam {b.nom}. In {l.abl} manent.', 'multō', ['multus', 'multum'],
  'multus senior sum quam in maneo', 'Ante comparātīvum multō mēnsūram differentiae exprimit: multō senior.')
# Production asks for new formulations with different clause structures and
# grammatical subjects from the reading activities. Do not invert R entries.
PRODUCTION = {
 'partitive-selection': ('{a.fr} appelle un membre du groupe des {b.frpl}.', '{a.nom} ūnum ___ vocat.', '{b.genpl}', ['{b.datpl}', '{b.accpl}'], 'unus voco'),
 'price-genitive': ('{a.fr} achète cher le livre, mais {b.fr} le vend à bas prix.', '{a.nom} librum magnī emit, sed {b.nom} eum ___ vēndit.', 'parvī', ['parvum', 'parva'], 'liber magnus emo sed is parvus vendo'),
 'quality-genitive': ('Nous appelons {a.fr} un homme d’un grand courage.', '{a.acc} virum ___ appellāmus.', 'magnae virtūtis', ['magnam virtūtem', 'magna virtūs'], 'vir magnus virtus appello'),
 'dative-owner': ('Dans {l.fr}, {a.fr} dit : « J’ai un livre. »', 'In {l.abl} {a.nom} dīcit: « ___ liber est. »', 'mihi', ['mē', 'ego'], 'in dico ego liber sum'),
 'purpose-dative': ('{a.fr} envoie {b.fr} pour apporter de l’aide.', '{a.nom} {b.acc} ___ mittit.', 'auxiliō', ['auxiliī', 'auxilium'], 'auxilium mitto'),
 'two-datives-recipient': ('Les {a.frpl} serviront de protection à {b.fr}.', '{a.nompl} ___ praesidiō erunt.', '{b.dat}', ['{b.gen}', '{b.acc}'], 'praesidium sum'),
 'distance-accusative': ('La tour appartenant à {a.fr} a une hauteur de trente pieds.', 'Turris {a.gen} ___ alta est.', 'trīgintā pedēs', ['trīgintā pedibus', 'trīgintā pedum'], 'turris triginta pes altus sum'),
 'duration-accusative': ('Les {a.frpl} attendent {b.fr} pendant deux heures.', '{a.nompl} {b.acc} ___ exspectant.', 'duās hōrās', ['duābus hōrīs', 'secundā hōrā'], 'duo hora exspecto'),
 'teach-person': ('{a.fr} demande son avis à {b.fr}.', '{a.nom} ___ sententiam rogat.', '{b.acc}', ['{b.dat}', '{b.gen}'], 'sententia rogo'),
 'comparison-ablative': ('{a.fr} court plus vite que {b.fr}.', '{a.nom} ___ celerius currit.', '{b.abl}', ['{b.acc}', '{b.gen}'], 'celerius curro'),
 'quality-ablative': ('Les {a.frpl} recherchent un chef d’un grand courage.', '{a.nompl} ducem ___ quaerunt.', 'magnā virtūte', ['magnam virtūtem', 'magna virtūs'], 'dux magnus virtus quaero'),
 'cause-ablative': ('{a.fr} périt de faim ; {b.fr} reste dans {l.fr}.', '{a.nom} ___ perit; {b.nom} in {l.abl} manet.', 'famē', ['famem', 'famis'], 'fames pereo in maneo'),
 'difference-ablative': ('{a.fr} est plus jeune de trois ans que {b.fr}.', '{a.nom} ___ iūnior est quam {b.nom}.', 'tribus annīs', ['trēs annōs', 'trium annōrum'], 'tres annus iunior sum quam'),
}
for f in FRAMES:
    if f['place'] == 'templum':
        f['french'], f['latin'], f['correct'], f['wrong'], vocab = PRODUCTION[f['id']]
        f['vocabulary'] = vocab.split()
        # Explanations describe the actual construction, independent of the
        # particular noun or wording of an earlier draft.
        f['explanation'] = {
          '1': 'Genetīvus plūrālis tōtum exprimit; ūnum accūsātīvus obiectum verbī vocat est.',
          '2': 'Parvī pretium parvum significat; magnī in priōre parte pretium magnum indicat.',
          '3': 'Magnae virtūtis genetīvus quālitātis ad virum pertinet.',
          '4': 'Mihi datīvus possessōris est. In ōrātiōne rēctā loquēns sē prīmā persōnā dēsignat.',
          '5': 'Auxiliō datīvus fīnis est: cūr mittātur indicat.',
          '6': 'Datīvus persōnae cum praesidiō datīvō fīnis coniungitur.',
          '7': 'Mēnsūra altitūdinis accūsātīvō exprimitur: trīgintā pedēs alta.',
          '8': 'Duās hōrās accūsātīvus spatium temporis indicat. Secundā hōrā aliud significat.',
          '9': 'Rogāre persōnam et rem accūsātīvō admittit: aliquem sententiam rogāre.',
          '10': 'Post celerius terminus comparātiōnis sine quam ablātīvō exprimitur.',
          '11': 'Magnā virtūte ablātīvus quālitātis ad ducem pertinet; nōn alterum obiectum est.',
          '12': 'Famē ablātīvus causae est: famēs mortem efficit.',
          '13': 'Tribus annīs ablātīvus mēnsūrae indicat quantum aetātēs differant.',
        }[f['card']]
LEXICON += '''
is|is|celui-ci
timeo|timeō|craindre
procedo|prōcēdō|avancer
deinde|deinde|ensuite
voco|vocō|appeler
dico|dīcō|dire
ego|ego|moi
mitto|mittō|envoyer
praesidium|praesidium|protection
triginta|trīgintā|trente
exspecto|exspectō|attendre
quaero|quaerō|chercher
secundus|secundus|deuxième
tertius|tertius|troisième
'''
# Prepositional contractions belong to French wording, never Latin morphology.
for f in FRAMES:
    for key in ['correct', 'french']:
        if key in f:
            f[key] = f[key].replace('à {a.fr}', '{a.to}').replace('à {b.fr}', '{b.to}')
    f['wrong'] = [t.replace('à {a.fr}', '{a.to}').replace('à {b.fr}', '{b.to}') for t in f['wrong']]
