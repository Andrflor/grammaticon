"""Additional diagnostic constructions for case functions.

Each entry changes the assessed phrase, not just its background participants.
Reading interprets a Latin relation; production chooses its required formulation.
"""
import copy
from cases import FRAMES as BASE
FRAMES = []
LEXICON = '''
pluris|plūris|plus cher
minoris|minōris|moins cher
salus|salūs|salut
cura|cūra|souci
mensis|mēnsis|mois
sex|sex|six
quinque|quīnque|cinq
centum|centum|cent
quingenti|quīngentī|cinq cents
stadium|stadium|stade
viginti|vīgintī|vingt
cubitus|cubitus|coudée
latus|lātus|large
lacus|lacus|lac
navis|nāvis|navire
barba|barba|barbe
prudentia|prūdentia|prudence
humanitas|hūmānitās|humanité
capillus|capillus|cheveu
niger|niger|noir
dolor|dolor|douleur
sitis|sitis|soif
aegrotus|aegrōtus|malade
laus|laus|éloge
exsulto|exsultō|exulter
fugio|fugiō|fuir
periculum|perīculum|danger
odium|odium|haine
tristis|trīstis|triste
paulum|paulum|un peu
paulo|paulō|un peu
celer|celer|rapide
altior|altior|plus haut
longior|longior|plus long
brevis|brevis|court
brevius|brevius|plus court
nos|nōs|nous
vos|vōs|vous
tu|tū|toi
iste|iste|celui-là
opus|opus|besoin
''' 

def add(base, id, latin, correct, wrong, vocab, explanation, french=None):
    frame = copy.deepcopy(next(f for f in BASE if f['id'] == base))
    frame.update(id=id, latin=latin, correct=correct, wrong=wrong,
                 vocabulary=vocab.split(), explanation=explanation)
    if french is not None: frame['french'] = french
    for key in ['correct', 'french']:
        if key in frame:
            frame[key] = frame[key].replace('à {a.fr}', '{a.to}').replace('à {b.fr}', '{b.to}')
    frame['wrong'] = [t.replace('à {a.fr}', '{a.to}').replace('à {b.fr}', '{b.to}') for t in frame['wrong']]
    FRAMES.append(frame)

# Comparative valuation is another genitive of indefinite price.
add('price-book','price-higher', '{a.nom} librum {b.gen} plūris emit.',
    '{a.fr} achète plus cher le livre appartenant à {b.fr}.',
    ['{a.fr} achète davantage de livres appartenant à {b.fr}.',
     '{a.fr} achète moins cher le livre appartenant à {b.fr}.'],
    'liber pluris emo', 'Plūris pretium maius, nōn numerum librōrum maiōrem indicat.')
add('price-low','price-lower', '{a.nom} librum {b.gen} minōris vēndit.',
    '{a.fr} vend moins cher le livre appartenant à {b.fr}.',
    ['{a.fr} vend un plus petit livre appartenant à {b.fr}.',
     '{a.fr} vend plus cher le livre appartenant à {b.fr}.'],
    'liber minoris vendo', 'Minōris pretium minus, nōn magnitūdinem librī minōrem indicat.')
for suffix, form, wrong, gloss, vocab in [
    ('high','magnī',['magnum','magna'],'cher','magnus'),
    ('higher','plūris',['plūrēs','plūra'],'plus cher','pluris'),
    ('lower','minōris',['minōrem','minōra'],'moins cher','minoris'),
]:
    add('price-genitive','produce-price-'+suffix,
        '{a.nom} librum {b.gen} ___ emit.',form,wrong,'liber emo '+vocab,
        f'{form.capitalize()} genetīvus pretiī est. Quō pretiō emat, nōn quālis liber sit, exprimit.',
        '{a.fr} achète '+gloss+' le livre appartenant à {b.fr}.')

# Final dative: the function served by a person/action, distinct from its cause.
add('purpose-aid','purpose-protection', '{a.nom} {b.dat} praesidiō est.',
    '{a.fr} sert de protection à {b.fr}.',
    ['{a.fr} est sous la protection de {b.fr}.', '{b.fr} sert de protection à {a.fr}.'],
    'praesidium sum', 'Praesidiō munus protectiōnis indicat; {b.dat} persōnam cui prōdest exprimit.')
add('purpose-aid','purpose-safety', '{a.nom} {b.dat} salūtī fuit.',
    '{a.fr} a été une source de salut pour {b.fr}.',
    ['{a.fr} a été sauvé par {b.fr}.', '{a.fr} a été une source de danger pour {b.fr}.'],
    'salus sum', 'Salūtī datīvus fīnis est: {a.nom} causam salūtis praebuit, nōn ipse hīc salvātus esse dīcitur.')
add('purpose-aid','purpose-concern', '{a.nom} {b.dat} cūrae est.',
    '{a.fr} est un sujet de souci pour {b.fr}.',
    ['{a.fr} se fait du souci pour {b.fr}.', '{b.fr} ne se soucie pas de {a.fr}.'],
    'cura sum', 'Cūrae est rem cūrā dignam indicat. {b.dat} persōnam cūrantem, nōn rem cūrātam, dēsignat.')
add('purpose-dative','produce-protection-function', '{a.nompl} {b.dat} ___ erunt.',
    'praesidiō',['praesidium','praesidiī'], 'praesidium sum',
    'Praesidiō datīvus fīnis est: quō mūnere fungantur exprimit.',
    'Les {a.frpl} serviront de protection à {b.fr}.')
add('purpose-dative','produce-safety-function', '{a.nom} {b.dat} ___ fuit.',
    'salūtī',['salūtem','salūtis'], 'salus sum',
    'Salūtī datīvus fīnis cum fuit coniungitur. Persōna cui prōfuit alterō datīvō exprimitur.',
    '{a.fr} a été une source de salut pour {b.fr}.')
add('purpose-dative','produce-concern-function', '{a.nom} {b.dat} ___ est.',
    'cūrae',['cūram','cūrā'], 'cura sum',
    'Cūrae est significat cūram movet. Cūrā ablātīvus causam, nōn hoc munus, exprimeret.',
    '{a.fr} est un sujet de souci pour {b.fr}.')

# Duration: different time units, with different accusative forms.
for suffix, latin, french, wrong_time, vocab in [
    ('hours','duās hōrās','deux heures','la deuxième heure','duo hora'),
    ('months','sex mēnsēs','six mois','le sixième mois','sex mensis'),
    ('years','duōs annōs','deux ans','la deuxième année','duo annus'),
]:
    add('duration-stay','duration-'+suffix,
        '{a.nom} '+latin+' in {l.abl} manet; {b.nom} venit.',
        '{a.fr} reste '+french+' dans {l.fr} ; {b.fr} arrive.',
        ['{a.fr} reste dans {l.fr} pendant '+wrong_time+' ; {b.fr} arrive.',
         '{a.fr} reste dans {l.fr} après '+french+' ; {b.fr} arrive.'],
        vocab+' in maneo venio', latin.capitalize()+' spatium temporis accūsātīvō exprimit, nōn tempus certum adventūs.')
for suffix, latin, wrong, french, vocab in [
    ('days','trēs diēs',['tribus diēbus','trium diērum'],'trois jours','tres dies'),
    ('months','sex mēnsēs',['sex mēnsibus','sex mēnsium'],'six mois','sex mensis'),
    ('year','ūnum annum',['ūnō annō','ūnīus annī'],'un an','unus annus'),
]:
    add('duration-accusative','produce-duration-'+suffix,
        '{a.nompl} {b.acc} ___ exspectant.', latin, wrong,
        vocab+' exspecto', latin.capitalize()+' accūsātīvus dūrātiōnem exspectātiōnis exprimit.',
        'Les {a.frpl} attendent {b.fr} pendant '+french+'.')

# Distance: units vary, not merely the numeral before the same fixed phrase.
for suffix, latin, french, false_time, vocab in [
    ('paces','quīngentōs passūs','cinq cents pas','cinq cents jours','quingenti passus'),
    ('feet','centum pedēs','cent pieds','cent jours','centum pes'),
    ('stadium','ūnum stadium','un stade','un jour','unus stadium'),
]:
    add('distance-travel','distance-'+suffix,
        '{a.nom} '+latin+' pedēs prōcēdit; {b.nom} manet.',
        '{a.fr} avance à pied sur '+french+' ; {b.fr} reste.',
        ['{a.fr} avance à pied pendant '+false_time+' ; {b.fr} reste.',
         '{a.fr} s’arrête avant d’avoir parcouru '+french+' ; {b.fr} reste.'],
        vocab+' pedes procedo maneo', latin.capitalize()+' accūsātīvus spatium percursum exprimit, nōn dūrātiōnem.')
add('distance-accusative','produce-wall-height', 'Mūrus {a.gen} ___ altus est.',
    'vīgintī cubitōs',['vīgintī cubitīs','vīgintī cubitōrum'], 'murus viginti cubitus altus sum',
    'Mēnsūra altitūdinis accūsātīvō exprimitur: vīgintī cubitōs altus.',
    'Le mur appartenant à {a.fr} a une hauteur de vingt coudées.')
add('distance-accusative','produce-ship-length', 'Nāvis {a.gen} ___ longa est.',
    'centum pedēs',['centum pedibus','centum pedum'], 'navis centum pes longus sum',
    'Centum pedēs accūsātīvus longitudinem nāvis exprimit; longa cum nāvis congruit.',
    'Le navire appartenant à {a.fr} mesure cent pieds de long.')
add('distance-accusative','produce-lake-width', 'Lacus ___ lātus est; {a.nom} in {l.abl} manet.',
    'duo mīlia passuum',['duōbus mīlibus passuum','duōrum mīlium passuum'],
    'lacus duo mille passus latus sum in maneo',
    'Duo mīlia accūsātīvus lātitūdinem exprimit; passuum genetīvus ūnitātem mēnsūrae addit.',
    'Le lac a une largeur de deux milles ; {a.fr} reste dans {l.fr}.')

# First-person possessive dative requires more than repeated mihi.
add('dative-owner','produce-owner-tibi', '___ liber est; {a.nom} in {l.abl} manet.',
    'tibi',['tē','tū'],'tu liber sum in maneo',
    'Tibi datīvus possessōrem secundā persōnā singulārī exprimit.',
    'Tu as un livre ; {a.fr} reste dans {l.fr}.')
add('dative-owner','produce-owner-nobis', '___ liber est; {a.nom} in {l.abl} manet.',
    'nōbīs',['nōs','nostrum'],'nos liber sum in maneo',
    'Nōbīs datīvus possessōrem prīmā persōnā plūrālī exprimit. Liber manet subiectum singulāre.',
    'Nous avons un livre ; {a.fr} reste dans {l.fr}.')
add('dative-owner','produce-owner-vobis', '___ liber est; {a.nom} in {l.abl} manet.',
    'vōbīs',['vōs','vestrum'],'vos liber sum in maneo',
    'Vōbīs datīvus possessōrem secundā persōnā plūrālī exprimit.',
    'Vous avez un livre ; {a.fr} reste dans {l.fr}.')

# Ablative quality is not the same memorized bono animo each time.
for suffix, latin, french, wrong_quality, vocab in [
    ('prudence','magnā prūdentiā','d’une grande prudence','dépourvu de prudence','magnus prudentia'),
    ('humanity','summā hūmānitāte','d’une très grande humanité','dépourvu d’humanité','summus humanitas'),
    ('beard','longā barbā','pourvu d’une longue barbe','dépourvu de barbe','longus barba'),
]:
    add('ablative-quality','quality-ablative-'+suffix,
        '{a.nom} '+latin+' est; {b.nom} in {l.abl} manet.',
        '{a.fr} est '+french+' ; {b.fr} reste dans {l.fr}.',
        ['{a.fr} est '+wrong_quality+' ; {b.fr} reste dans {l.fr}.',
         '{b.fr} est '+french+' ; {a.fr} reste dans {l.fr}.'],
        vocab+' sum in maneo', latin.capitalize()+' ablātīvus quālitātem {a.gen} exprimit.')
for suffix, latin, wrong, french, vocab in [
    ('prudence','magnā prūdentiā',['magnam prūdentiam','magna prūdentia'],'d’une grande prudence','magnus prudentia'),
    ('humanity','summā hūmānitāte',['summam hūmānitātem','summa hūmānitās'],'d’une très grande humanité','summus humanitas'),
    ('beard','longā barbā',['longam barbam','longa barba'],'pourvu d’une longue barbe','longus barba'),
]:
    add('quality-ablative','produce-quality-ablative-'+suffix,
        '{a.nompl} virum ___ quaerunt.', latin, wrong,
        'vir '+vocab+' quaero', latin.capitalize()+' ablātīvus quālitātis ad virum pertinet.',
        'Les {a.frpl} recherchent un homme '+french+'.')

# Cause: different psychological and physical causes; no purpose credited.
for suffix, latin, french, incorrect, vocab in [
    ('joy','gaudiō exsultat','exulte de joie','exulte pour obtenir de la joie','gaudium exsulto'),
    ('hunger','famē perit','périt de faim','périt afin d’avoir faim','fames pereo'),
    ('pain','dolōre lacrimat','pleure de douleur','pleure afin de provoquer de la douleur','dolor lacrimo'),
]:
    add('ablative-cause','cause-'+suffix,
        '{a.nom} '+latin+'; {b.nom} in {l.abl} manet.',
        '{a.fr} '+french+' ; {b.fr} reste dans {l.fr}.',
        ['{a.fr} '+incorrect+' ; {b.fr} reste dans {l.fr}.',
         '{b.fr} '+french+' ; {a.fr} reste dans {l.fr}.'],
        vocab+' in maneo', 'Ablātīvus causam status vel actiōnis exprimit. Causa nōn cōnsilium est.')
for suffix, form, wrong, verb, french, vocab in [
    ('fear','metū',['metum','metūs'],'tremit','tremble de peur','metus tremo'),
    ('joy','gaudiō',['gaudium','gaudiī'],'exsultat','exulte de joie','gaudium exsulto'),
    ('pain','dolōre',['dolōrem','dolōris'],'lacrimat','pleure de douleur','dolor lacrimo'),
]:
    add('cause-ablative','produce-cause-'+suffix,
        '{a.nom} ___ '+verb+'; {b.nom} in {l.abl} manet.',form,wrong,
        vocab+' in maneo', form.capitalize()+' ablātīvus causam exprimit, nōn obiectum nec fīnem.',
        '{a.fr} '+french+' ; {b.fr} reste dans {l.fr}.')

# Measure of difference: scalar and measured comparisons both occur.
add('measure-comparison','difference-small', '{a.nom} paulō senior est quam {b.nom}.',
    '{a.fr} est un peu plus âgé que {b.fr}.',
    ['{a.fr} est beaucoup plus âgé que {b.fr}.','{a.fr} est un peu plus jeune que {b.fr}.'],
    'paulo senior sum quam', 'Paulō mēnsūram parvam differentiae indicat; senior aetātem maiōrem exprimit.')
add('measure-comparison','difference-three-years', '{a.nom} tribus annīs senior est quam {b.nom}.',
    '{a.fr} est plus âgé de trois ans que {b.fr}.',
    ['{a.fr} était plus âgé que {b.fr} il y a trois ans.','{a.fr} est plus jeune de trois ans que {b.fr}.'],
    'tres annus senior sum quam', 'Tribus annīs differentiam aetātum mēnsūrat, nōn tempus ante praesēns indicat.')
add('measure-comparison','difference-two-feet', 'Mūrus duōbus pedibus altior est quam turris; {a.nom} manet.',
    'Le mur dépasse la tour de deux pieds en hauteur ; {a.fr} reste.',
    ['Le mur mesure deux pieds de haut, comme la tour ; {a.fr} reste.',
     'La tour dépasse le mur de deux pieds en hauteur ; {a.fr} reste.'],
    'murus duo pes altior sum quam turris maneo', 'Duōbus pedibus excessum altitūdinis mūrī suprā turrim indicat, nōn tōtam altitūdinem.')
add('difference-ablative','produce-difference-small', '{a.nom} ___ senior est quam {b.nom}.',
    'paulō',['paulus','paulum'], 'paulo senior sum quam',
    'Paulō ante comparātīvum parvam differentiam exprimit.',
    '{a.fr} est un peu plus âgé que {b.fr}.')
add('difference-ablative','produce-difference-large', '{a.nom} ___ senior est quam {b.nom}.',
    'multō',['multus','multum'], 'multus senior sum quam',
    'Multō ante comparātīvum magnam differentiam exprimit.',
    '{a.fr} est beaucoup plus âgé que {b.fr}.')
add('difference-ablative','produce-difference-height', 'Mūrus ___ altior est quam turris; {a.nom} manet.',
    'duōbus pedibus',['duōs pedēs','duōrum pedum'], 'murus duo pes altior sum quam turris maneo',
    'Duōbus pedibus ablātīvus mēnsūrae differentiam altitūdinum exprimit.',
    'Le mur dépasse la tour de deux pieds en hauteur ; {a.fr} reste.')
# Avoid the stylistically awkward homographs pedes (on foot) / pedes (feet).
for frame in FRAMES:
    if frame['id'] == 'distance-feet':
        frame['latin'] = frame['latin'].replace('centum pedēs pedēs', 'centum pedēs')
        frame['correct'] = frame['correct'].replace(' à pied', '')
        frame['wrong'] = [s.replace(' à pied', '') for s in frame['wrong']]
        frame['vocabulary'].remove('pedes')
