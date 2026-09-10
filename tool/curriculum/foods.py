"""Authored accusatives for the next food/preparation contexts.

Materialized in independent-subjunctive contexts. Rows contain a lemma
ID, Latin headword, accusative used in a sentence and its French food gloss.
No quantity or noun gender is inferred from these strings.
"""
FOODS = '''
panis|pānis|pānem|pain
far|far|far|épeautre
frumentum|frūmentum|frūmentum|blé
triticum|trīticum|trīticum|froment
hordeum|hordeum|hordeum|orge
avena|avēna|avēnam|avoine
secale|secāle|secāle|seigle
milium|milium|milium|millet
panicum|pānicum|pānicum|millet des oiseaux
oryza|orȳza|orȳzam|riz
siligo|silīgō|silīginem|blé tendre
amylum|amylum|amylum|amidon
farina|farīna|farīnam|farine
furfur|furfur|furfurem|son de céréale
placenta|placenta|placentam|gâteau plat
libum|lībum|lībum|gâteau d’offrande
crustum|crustum|crustum|croûte de pain
buccella|buccella|buccellam|bouchée
caseus|cāseus|cāseum|fromage
lac|lac|lac|lait
butyrum|būtyrum|būtyrum|beurre
mel|mel|mel|miel
oleum|oleum|oleum|huile
vinum|vīnum|vīnum|vin
acetum|acētum|acētum|vinaigre
vappa|vappa|vappam|vin éventé
mustum|mustum|mustum|moût
mulsum|mulsum|mulsum|vin miellé
passum|passum|passum|vin de raisins secs
defrutum|dēfrūtum|dēfrūtum|moût réduit
garum|garum|garum|sauce de poisson
muria|muria|muriam|saumure
sal|sāl|sālem|sel
piper|piper|piper|poivre
sinapi|sināpi|sināpi|moutarde
lactuca|lactūca|lactūcam|laitue
brassica|brassica|brassicam|chou
caulis|caulis|caulem|tige de chou
porrum|porrum|porrum|poireau
cepa|cēpa|cēpam|oignon
allium|allium|allium|ail
asparagus|asparagus|asparagum|asperge
apium|apium|apium|céleri
olus|olus|olus|légume
rapum|rāpum|rāpum|rave
napus|nāpus|nāpum|navet
pastinaca|pastināca|pastinācam|panais
beta|bēta|bētam|bette
cucumis|cucumis|cucumerem|concombre
cucurbita|cucurbita|cucurbitam|courge
pepo|pepō|pepōnem|melon
malum|mālum|mālum|pomme
pirum|pirum|pirum|poire
prunum|prūnum|prūnum|prune
persicum|persicum|persicum|pêche
armeniacum|armeniacum|armeniacum|abricot
cerasum|cerasum|cerasum|cerise
ficus|fīcus|fīcum|figue
uva|ūva|ūvam|raisin
acinus|acinus|acinum|grain de raisin
racemus|racēmus|racēmum|grappe
nux|nux|nucem|noix
amygdalum|amygdalum|amygdalum|amande
castanea|castanea|castaneam|châtaigne
glans|glāns|glandem|gland
oliva|olīva|olīvam|olive
dactylus|dactylus|dactylum|datte
pomum|pōmum|pōmum|fruit
caro|carō|carnem|chair
viscera|viscera|viscera|abats
adeps|adeps|adipem|graisse
laridum|lāridum|lāridum|lard
perna|perna|pernam|jambon
iecur|iecur|iecur|foie
cor|cor|cor|cœur
pulmo|pulmō|pulmōnem|poumon
ren|rēn|rēnem|rein
lingua|lingua|linguam|langue
botulus|botulus|botulum|boudin
tomaculum|tomāculum|tomāculum|saucisse
isicium|īsicium|īsicium|hachis
ostrea|ostrea|ostream|huître
concha|concha|concham|coquillage
mitulus|mītulus|mītulum|moule
echinus|echīnus|echīnum|oursin
lupinus|lupīnus|lupīnum|lupin
faba|faba|fabam|fève
lens|lēns|lentem|lentille
pisum|pīsum|pīsum|pois
cicer|cicer|cicer|pois chiche
ervum|ervum|ervum|ers
phaseolus|phaseolus|phaseolum|haricot
sesamum|sēsamum|sēsamum|sésame
papaver|papāver|papāver|pavot
cuminum|cumīnum|cumīnum|cumin
coriandrum|coriandrum|coriandrum|coriandre
anethum|anēthum|anēthum|aneth
anisum|anīsum|anīsum|anis
menta|menta|mentam|menthe
thymum|thymum|thymum|thym
origanum|orīganum|orīganum|origan
cunila|cunīla|cunīlam|sarriette
rosmarinum|rōsmarīnum|rōsmarīnum|romarin
laurus|laurus|laurum|laurier
ocimum|ōcimum|ōcimum|basilic
crocus|crocus|crocum|safran
cinnamomum|cinnamōmum|cinnamōmum|cannelle
casia|casia|casiam|casse aromatique
fungus|fungus|fungum|champignon
boletus|bōlētus|bōlētum|cèpe
tuber|tūber|tūber|truffe
'''

# French noun phrases are authored independently of Latin morphology.
PHRASES = '''
panis|du pain
far|de l’épeautre
frumentum|du blé
triticum|du froment
hordeum|de l’orge
avena|de l’avoine
secale|du seigle
milium|du millet
panicum|du millet des oiseaux
oryza|du riz
siligo|du blé tendre
amylum|de l’amidon
farina|de la farine
furfur|du son de céréale
placenta|un gâteau plat
libum|un gâteau d’offrande
crustum|une croûte de pain
buccella|une bouchée
caseus|du fromage
lac|du lait
butyrum|du beurre
mel|du miel
oleum|de l’huile
vinum|du vin
acetum|du vinaigre
vappa|du vin éventé
mustum|du moût
mulsum|du vin miellé
passum|du vin de raisins secs
defrutum|du moût réduit
garum|de la sauce de poisson
muria|de la saumure
sal|du sel
piper|du poivre
sinapi|de la moutarde
lactuca|une laitue
brassica|un chou
caulis|une tige de chou
porrum|un poireau
cepa|un oignon
allium|de l’ail
asparagus|une asperge
apium|du céleri
olus|un légume
rapum|une rave
napus|un navet
pastinaca|un panais
beta|une bette
cucumis|un concombre
cucurbita|une courge
pepo|un melon
malum|une pomme
pirum|une poire
prunum|une prune
persicum|une pêche
armeniacum|un abricot
cerasum|une cerise
ficus|une figue
uva|du raisin
acinus|un grain de raisin
racemus|une grappe
nux|une noix
amygdalum|une amande
castanea|une châtaigne
glans|un gland
oliva|une olive
dactylus|une datte
pomum|un fruit
caro|de la chair
viscera|des abats
adeps|de la graisse
laridum|du lard
perna|un jambon
iecur|du foie
cor|un cœur
pulmo|un poumon
ren|un rein
lingua|une langue
botulus|un boudin
tomaculum|une saucisse
isicium|du hachis
ostrea|une huître
concha|un coquillage
mitulus|une moule
echinus|un oursin
lupinus|du lupin
faba|une fève
lens|une lentille
pisum|un pois
cicer|un pois chiche
ervum|de l’ers
phaseolus|un haricot
sesamum|du sésame
papaver|du pavot
cuminum|du cumin
coriandrum|de la coriandre
anethum|de l’aneth
anisum|de l’anis
menta|de la menthe
thymum|du thym
origanum|de l’origan
cunila|de la sarriette
rosmarinum|du romarin
laurus|du laurier
ocimum|du basilic
crocus|du safran
cinnamomum|de la cannelle
casia|de la casse aromatique
fungus|un champignon
boletus|un cèpe
tuber|une truffe
'''
FRENCH = dict(line.split('|') for line in PHRASES.strip().splitlines())
assert FRENCH.keys() == {line.split('|')[0] for line in FOODS.strip().splitlines()}
