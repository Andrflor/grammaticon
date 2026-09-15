# Arbre des compétences du latin — schéma et inventaire

Ce document fixe **ce qu'est un nœud**, **quelles arêtes existent**, **comment le graphe est construit** et **combien de nœuds chaque couche contient**. Les feuilles elles-mêmes sont écrites dans les fichiers suivants du dossier (`10_…` à `60_…`), un par domaine.

Il remplace `doc/pedagogy/skills/` (67 021 nœuds générés, une étiquette par forme, aucune arête entre compétences) et l'ancienne taxonomie Dart (`v.ind.imperf.act`, une case de paradigme par nœud, sans décomposition).

## 1. Règle du grain

Un nœud est **un maillon isolable** : un savoir ou une opération que l'on peut faire échouer seul, par un distracteur qui ne casse que lui, et qui **se retrouve dans plusieurs formes ou plusieurs phrases**.

Trois tests, un nœud doit passer les trois :

1. **Isolable** — il existe un distracteur qui met en cause ce maillon et aucun autre. `amat` face à `amābat` isole le marqueur d'imparfait ; `monēbat` face à `amābat` isole le lexème (ou la classe) sans toucher au marqueur.
2. **Récurrent** — le maillon intervient dans au moins deux contextes distincts (autre lexème, autre case, autre phrase). Sinon il n'y a rien où « revenir ».
3. **Relié** — il a au moins un prérequis, ou une confusion, ou il compose un nœud d'une couche supérieure. Un nœud isolé n'est pas une compétence, c'est une étiquette.

Ce que n'est **pas** un nœud : une forme (`amābat`), une question, un chapitre de manuel, un item de vocabulaire *dans une phrase donnée*.

## 2. Couches

Le graphe est construit en couches. Les couches 0, 1, 3, 5 et le cœur de la couche 4 sont **rédigées à la main et relues**. La couche 2 et les arêtes de portée de la couche 4 sont **dérivées par des règles déterministes** à partir des couches inférieures : elles ne sont ni écrites une à une, ni produites par un modèle de langage.

| Couche | Contenu | Origine | Ordre de grandeur |
|---|---|---|---|
| **L0 Notiones** | Catégories grammaticales : cas, nombre, genre, personne, temps, mode, voix, degré, classe de déclinaison, classe de conjugaison, type de thème | main | ≈ 45 |
| **L1 Elementa** | Maillons morphologiques : thèmes et radicaux par classe, marqueurs de temps et de mode, désinences personnelles, désinences casuelles par type de thème, morphèmes de degré, formation des adverbes, alternances (rhotacisme, apophonie, allongement) | main | ≈ 350 |
| **L2 Cellae** | Cases de paradigme : *type de thème × cas × nombre* pour le nominal, *classe × mode × temps × voix × personne × nombre* pour le verbal, plus formes nominales du verbe. Chaque case est **composée** de maillons L1 et porte les **syncrétismes** dérivés (deux cases de même surface) | dérivée | ≈ 1 700 |
| **L3 Syntaxis** | Fonctions des cas, accord, ordre, propositions (relatives, complétives, circonstancielles), infinitives, interrogatives indirectes, discours indirect, concordance des temps, participes et ablatif absolu, gérondif et adjectif verbal, périodes conditionnelles, impersonnels, négations, questions, coordination | main | ≈ 330 |
| **L4 Lexicon** | Un nœud par lexème du programme (Familia Romana en premier, puis Fabellae, Fabulae Syrae, Epitome), avec sa classe, ses irrégularités, ses confusions sémantiques et formelles ; plus les procédés de formation (préfixes, suffixes, composition) | cœur main, portée dérivée | ≈ 2 000 + 60 |
| **L5 Lectio** | Opérations de lecture et de traduction : repérer le verbe, délimiter les propositions, résoudre les anaphores, ordonner en français, traiter les ellipses ; prosodie et écriture (quantités, accent, élision, *i/j*, *u/v*) | main | ≈ 55 |
| | **Total** | | **≈ 4 500** |

Le total est cohérent avec la taille attendue d'un graphe complet (4 000 à 5 000 nœuds). Il est **dix fois plus petit** que les 67 021 nœuds actuels parce que les formes ne sont plus des nœuds, et **dix fois plus grand** que l'ancienne taxonomie parce que les maillons, les syncrétismes et le lexique le sont.

## 3. Arêtes

| Arête | Sens | Exemple |
|---|---|---|
| `pars` | *A est un composant de B* (composition). Une case L2 est composée de ses maillons L1 ; une construction L3 est composée de fonctions de cas et de formes. | `v.sig.imperf.ba` pars `cella.v.c1.ind.imperf.act.3.sg` |
| `requirit` | *A doit être en place pour apprendre B* (prérequis pédagogique, jamais déduit de la composition). | `n.thema.d3.cons` requirit `n.des.d3.gen.sg.is` ; `syn.acc.obiectum` requirit `syn.aci` |
| `confunditur` | *A se confond avec B*, typée par un `modus` : `syncretismus` (même surface, ex. -ae), `similitudo` (surfaces proches, -bā-/-bi-), `analogia` (transfert d'une classe à l'autre, *audiēbat* → \**audībat*), `sensus` (sens voisins, *petere/quaerere*), `functio` (même cas, fonctions voisines : abl. de moyen / de cause). | `v.sig.imperf.ba` confunditur `v.sig.fut.b` (similitudo) |
| `exemplum` | *le lexème A réalise le nœud B*, et en particulier *A est irrégulier en B*. Donne la portée : quels mots servent à re-tester un maillon dans un autre contexte. | `lex.fero` exemplum `cella.v.anom.fero.ind.praes.act.3.sg` (fert, sans voyelle thématique) |
| `probatur` | *le nœud A se teste par la dimension D* (persōna, cāsus, tempus, fūnctiō, sēnsus…). Sert au générateur à savoir quel type de question et de distracteur isole ce maillon. | `n.des.d1.ae` probatur `casus` |

Les confusions sont **symétriques** ; elles sont écrites une fois. Les prérequis forment un graphe **acyclique**, vérifié par test.

## 4. Diagnostic d'un distracteur

Un distracteur n'est pas une chaîne : c'est *(forme, diagnostic)*, où le diagnostic est l'ensemble des nœuds mis en cause si le joueur le choisit.

- **Morphologie** (Amphitheatrum, Forum) : le diagnostic est **calculé** par différence entre l'analyse de la forme correcte et celle du distracteur. Le générateur produit un voisin en changeant *une* dimension ; les maillons L1 qui diffèrent entre les deux cases L2 sont le diagnostic. `amābat` → `amat` : diffèrent `v.sig.imperf.ba` et la notion `not.tempus.imperf`. `amābat` → `amābātur` : diffère `v.des.pass.3.sg.tur` et `not.vox.pass`. Un distracteur dont la différence est vide ou touche plus de deux maillons est rejeté par le générateur.
- **Syntaxe et lecture** (Theatrum, Templum) : reconnaître une forme sur demande morphologique et la comprendre ou la produire dans une phrase sont des compétences distinctes. Une erreur débite le nœud de contexte de la carte (`lect.intellectus.*` ou `lect.thema.*`) et rend **suspects** ses prérequis directs (syntaxe, morphologie) sans les débiter ; au Templum, quand le distracteur est une autre forme du même mot, les maillons de la forme attendue absents de la forme choisie s'ajoutent aux suspects. C'est le Forum ou l'Amphitheātrum qui tranche ensuite. À terme le diagnostic peut être **écrit** avec le distracteur, comme une arête vers un nœud L3 ou L5. Une traduction fautive qui prend un ablatif de moyen pour un ablatif de lieu porte `syn.abl.instrumentum ↔ syn.abl.locus`. Pas de distracteur sans diagnostic : la validation refuse la question.
- **Lexique** : un distracteur lexical porte le nœud L4 du mot choisi et le `modus` de la confusion (`sensus`, `similitudo`).

Une erreur **observe** les nœuds du diagnostic (ils baissent) et **suspecte** leurs prérequis non encore validés (ils passent en hypothèses). La sélection suivante puise dans ces hypothèses avant de revenir à la frontière. C'est ce qui permet de redescendre d'un maillon vers celui qui manque réellement.

## 5. Format d'un nœud

```json
{
  "id": "v.sig.imperf.ba",
  "nomen": "Signum imperfectī -bā-",
  "quid": "Reconnaître -bā- (-ba-) comme marque de l'imparfait de l'indicatif, toutes conjugaisons, actif et passif.",
  "stratum": 1,
  "notiones": ["not.tempus.imperf", "not.modus.ind"],
  "requirit": ["v.thema.praes"],
  "confunditur": [
    {"cum": "v.sig.fut.b", "modus": "similitudo", "nota": "-bō/-bi-/-bu- du futur des 1re et 2e conj."},
    {"cum": "v.sig.subj.imperf.re", "modus": "analogia", "nota": "amāret lu comme un imparfait"}
  ],
  "probatur": ["tempus", "tempusModus", "forma"],
  "fontes": ["A&G §179", "A&G §184"]
}
```

`nomen` est en latin (c'est ce que voit le joueur dans la Tabula), `quid` en français (c'est ce que relit l'auteur). `fontes` renvoie à Allen & Greenough par paragraphe ; un nœud sans source est refusé à la relecture.

## 6. Conventions d'identifiants

| Préfixe | Domaine | Exemples |
|---|---|---|
| `not.` | L0 notions | `not.casus.abl`, `not.tempus.plusq`, `not.vox.pass`, `not.gradus.comp` |
| `n.` | nominal : thèmes, désinences, cases | `n.thema.d3.i`, `n.des.d1.ae`, `n.des.d3.gen.sg.is`, `cella.n.d2.n.nom.pl` |
| `adj.` | adjectifs, degrés, adverbes | `adj.classis.2`, `adj.comp.ior`, `adj.sup.issimus`, `adj.adv.e`, `adj.irr.bonus` |
| `pron.` | pronoms | `pron.is.thema`, `pron.qui.cella.dat.abl.pl`, `pron.refl.sui` |
| `num.` | numéraux | `num.card.unus.decl`, `num.ord.des`, `num.distr` |
| `v.` | verbal : radicaux, marqueurs, désinences, cases | `v.thema.praes.c3`, `v.sig.perf.v`, `v.des.act.2.pl.tis`, `cella.v.c2.subj.imperf.pass.1.sg` |
| `syn.` | syntaxe | `syn.abl.instrumentum`, `syn.aci.tempus`, `syn.cum.hist`, `syn.cond.irrealis.praes` |
| `lex.` | lexique | `lex.fero`, `lex.petere`, `lex.form.prae`, `lex.form.tor` |
| `lect.` | lecture, prosodie | `lect.verbum.invenire`, `lect.anaphora.is`, `lect.quantitas.a` |

Les identifiants sont stables : ce sont les clés de la sauvegarde.

## 7. Ce que le moteur en fait

- **Sélection** : trois files pondérées, *rappels* (nœuds appris dont l'échéance est passée), *remédiation* (hypothèses ouvertes, en descendant vers le prérequis le plus profond non validé), *frontière* (nœuds dont tous les prérequis sont maîtrisés). Le nœud tiré, le générateur produit une question qui l'isole, sur un lexème choisi par les arêtes `exemplum` pour changer de contexte.
- **Maîtrise** : une estimation par nœud ; les cases L2 et les constructions L3 agrègent leurs composants (`pars`), la Tabula montre les agrégats. La sauvegarde ne contient que des compteurs par nœud.
- **Cartes** : une carte est un ensemble de nœuds cibles. L'ordre des cartes se déduit de `requirit` ; il n'est plus écrit à la main.

## 8. Où vit l'arbre

L'arbre est écrit **en Dart**, pas en Markdown : les nœuds sont des constantes typées, la validation tourne dans les tests, et le moteur le charge sans étape de génération.

| Fichier | Couche | Contenu |
|---|---|---|
| `lib/arbor/skill.dart` | — | modèle : `Skill`, `Confusio`, `Modus`, `Dimensio`, `Stratum` |
| `lib/arbor/notiones.dart` | L0 | catégories grammaticales |
| `lib/arbor/verbal_elementa.dart` | L1 | thèmes, voyelles, marqueurs, désinences, composés, alternances, genres de verbes, anomaux |
| `lib/arbor/nominal_elementa.dart` | L1 | thèmes, désinences par surface, genre, adjectifs et degrés, adverbes, pronoms, numéraux |
| `lib/arbor/cellae.dart` | L2 | dérivation des cases et fonctions de composition `verbalComponents` / `nominalComponents` |
| `lib/arbor/syntaxis.dart` | L3 | fonctions des cas, accord, ordre, propositions, constructions |
| `lib/arbor/lectio.dart` | L5 | lecture, traduction, écriture, vocabulaire |
| `lib/arbor/contextus.dart` | L5 | compétences en contexte : `lect.intellectus.<section>.<carte>` (comprendre dans une phrase, Theātrum) et `lect.thema.<section>.<carte>` (rendre en latin, Templum), une par carte, chaînées par le catalogue ; le thema exige l'intellectus ; la grammaire qu'une carte introduit exige son thema (exposition avant morphologie) |
| `lib/arbor/arbor.dart` | L4 + graphe | nœuds lexicaux, index des arêtes, syncrétismes dérivés, `validate()` |
| `lib/arbor/diagnosis.dart` | — | diagnostic d'un distracteur par différence de maillons |
| `lib/arbor/evidence.dart`, `needs.dart` | — | évidence par nœud, hypothèses, poids de sélection |
| `lib/arbor/oracle.dart` | — | équivalence avec les banques de référence |

`test/arbor/arbor_test.dart` refuse tout nœud sans source, toute référence inconnue, tout cycle de prérequis et tout maillon isolé.
