# Le corpus de référence : les 1,6 M de questions comme oracle

Les banques pré-générées ne sont pas jetées. Elles deviennent le **corpus de référence** contre lequel le nouveau moteur est mesuré, et la **source des cadres** authored de la lecture et de la production. Rien n'est supprimé avant que le moteur ait prouvé qu'il reproduit le corpus.

## 1. Ce que le corpus contient réellement

Mesuré le 14 septembre 2026 sur les 445 cartes par `tool/reference/extract_frames.py` et `extract_patterns.py` (voir §4) :

| Lieu | Questions | Contenu distinct | Ce que c'est |
|---|---|---|---|
| Amphitheatrum | 682 207 | 113 verbes ; 34 533 surfaces distinctes ; 307 602 patrons (surface × dimension × réponse) ; 16 consignes | produit du conjugueur : **reproductible par génération** |
| Forum | 208 347 | 579 lexèmes nominaux ; 6 999 surfaces et syntagmes distincts ; 37 192 patrons ; 17 consignes ; syntagmes contextuels (`highlightChoice`) | produit du déclinateur + syntagmes authored : **reproductible**, syntagmes à **récupérer** |
| Theatrum | 399 241 | **603 cadres de phrases** (instanciés jusqu'à 28 800 fois) + 1 508 entrées de vocabulaire | cadres authored : **à récupérer et annoter** |
| Templum | 304 220 | **393 cadres de phrases** + 1 536 entrées de vocabulaire | idem |

Un *cadre* est un groupe de questions de même carte, même interaction, même réponse acceptée et même explication pédagogique pour chaque issue ; les emplacements variables sont inférés par alignement mot à mot des instanciations (`difflib`) : même structure latine, mêmes distracteurs, seuls les remplisseurs changent (*poēta / nauta / mercātor*, *hortō / agrō / templō*). Exemple, carte `casuum-sensus/8`, un cadre de 6 624 questions :

> Poēta sex mēnsēs in {hortō | agrō | templō} manet; nauta venit. → « reste six mois » / « pendant le sixième mois » / « après six mois »
> Feedback : *Sex mēnsēs spatium temporis accūsātīvō exprimit, nōn tempus certum adventūs.*

Le travail à préserver, c'est ces **996 cadres** avec leurs distracteurs et leurs explications, plus les syntagmes du Forum et la liste des lexèmes. Les 703 000 instanciations, elles, se régénèrent.

## 2. Ce que le nouveau moteur doit prouver

Le corpus sert d'**oracle d'équivalence**. Pour chaque question de référence, le moteur doit pouvoir produire une question *équivalente* :

| Lieu | Équivalence exigée |
|---|---|
| Amphitheatrum, Forum (forme isolée) | même lexème, même case de paradigme, même dimension ; même réponse acceptée ; **chaque distracteur de référence est soit produit par le générateur avec un diagnostic, soit rejeté avec une raison enregistrée** (voir §3) |
| Forum (syntagme) | le syntagme est présent dans les cadres du Forum avec le même mot marqué, la même lecture imposée et les mêmes distracteurs |
| Theatrum, Templum | le cadre est présent dans les cadres authored : même phrase latine à remplisseurs près, mêmes traductions ou mêmes formes proposées, même explication ; chaque distracteur porte un diagnostic |
| Vocābula | chaque lemme de référence est un nœud L4 avec sa glose, dans les deux sens |

Le test `test/arbor/corpus_test.dart` parcourt le corpus et produit un **rapport de couverture par carte** (`doc/arbor/coverage/<lieu>.md`) : questions équivalentes / total, distracteurs reproduits / rejetés / manquants. **Critère de suppression des banques : 100 % des cadres et des patrons couverts, tout rejet documenté.** Tant que ce n'est pas atteint, les banques restent dans le dépôt et le rapport dit où on en est.

## 3. Ce que l'oracle révèle en retour

L'équivalence n'est pas à sens unique. Quand le générateur **refuse** un distracteur de référence, c'est l'un de ces cas, chacun enregistré dans le rapport :

- **Lecture également correcte** : le distracteur est une analyse valide de la surface (syncrétisme réel). La banque actuelle le comptait faux ; c'est une erreur de la banque, corrigée par le nouveau moteur qui l'accepte comme réponse.
- **Diagnostic vide** : le distracteur ne diffère de la réponse par aucun maillon de l'arbre. Soit l'arbre manque un maillon (on l'ajoute), soit le distracteur ne teste rien (on le remplace).
- **Trop de maillons** : le distracteur casse trois maillons ou plus ; il ne diagnostique rien de précis. Remplacé par un voisin à un maillon.

Chaque rejet est donc soit une correction de la banque, soit une correction de l'arbre. C'est aussi ce qui garantit que l'arbre couvre le corpus : **un maillon manquant apparaît comme un diagnostic vide sur une question de référence.**

## 4. Outillage

| Outil | Rôle |
|---|---|
| `tool/reference/extract_frames.py` | regroupe les questions Theatrum/Templum par carte, explication et réponse, infère les emplacements variables par alignement des instanciations, exporte `reference/frames/theatrum.json`, `templum.json` (603 + 393 cadres de phrases, 3 044 entrées de vocabulaire, 16 Mo) — **écrit et exécuté** |
| `tool/reference/extract_patterns.py` | exporte pour Amphitheatrum et Forum les patrons (surface, item, dimension, réponses acceptées, distracteurs observés avec fréquence et feedback témoin, cartes) et la liste des lexèmes : `reference/patterns/<lieu>.jsonl.gz` (28 Mo + 4 Mo), `<lieu>.lexemes.json` — **écrit et exécuté** ; les syntagmes du Forum y figurent avec leur mot marqué |
| `reference/` | dossier du dépôt, **hors `assets/`, non embarqué** : cadres, patrons, lexèmes, et les banques `.gz` déplacées telles quelles tant que le critère du §2 n'est pas atteint |
| `test/arbor/corpus_test.dart` | l'oracle d'équivalence et le rapport de couverture |

## 5. Des cadres extraits aux cadres authored

Les cadres extraits sont **la matière première, pas le produit fini**. Chacun passe par une relecture avant d'entrer dans `40_syntaxis.md` / `50_lexicon.md` :

1. l'explication devient le nœud L3 visé (ou plusieurs), avec sa source A&G ;
2. chaque distracteur reçoit son diagnostic (nœud + `modus`) ; un cadre dont un distracteur n'a pas de diagnostic défendable est corrigé ou écarté, et l'écart est noté dans le rapport ;
3. les emplacements variables déclarent leur lexique admissible (personnes, lieux, objets) pour que la régénération conserve la variété actuelle ;
4. les cadres redondants (même nœud, mêmes distracteurs, phrase quasi identique) sont fusionnés : la section `casuum-sensus` compte 238 cadres pour 13 emplois des cas, il en restera moins, mais aucune structure distincte ne disparaît.

La relecture est faite cadre par cadre, avec la grammaire ouverte. Elle **n'est pas** confiée à une boucle d'agents sans relecture : c'est cette boucle qui a produit 67 021 nœuds sans arêtes.
