# Compétences fines : contrat exécutable

Les cartes sont des vues sur des compétences. Une victoire est une statistique de
combat et ne prouve pas la maîtrise de la carte. Aucun score propre à une carte ne
peut compenser une compétence composante inconnue ou fragile.

## Périmètre demandé

Refaire Theatrum et Templum pour une couverture large du latin, vocabulaire inclus.
Familia Romana, Fabellae Latinae, Fabulae Syrae et Epitome Historiae Sacrae donnent
un ordre de grandeur du niveau et de l'étendue. Roma Aeterna est exclu. Il n'est
pas demandé de certifier chaque chapitre ni de consulter ces sources. Les anciens
contrats de couverture documentaire ne sont plus les critères de livraison.

La cible de volume est de l'ordre des centaines de milliers de questions par
lieu, comparable au Forum et à l'Amphitheatrum. Les deux parcours dépassent désormais
200 000 questions chacun. La couverture grammaticale et lexicale des deux
parcours reste incomplète. Une modification d'ordre des choix ne constitue pas un nouvel
exercice. Le raccordement des banques actuelles ne constitue pas à lui seul la
reconstruction éditoriale des deux parcours.

## Une seule identité entre entraînement et erreur

`question.skills` contient les feuilles réellement évaluées. Les IDs de
`outcomes[choix].observed` sont un sous-ensemble de ces mêmes feuilles : ce sont
les compétences auxquelles l'erreur apporte une preuve négative. Les autres
compétences restent inchangées. Une réponse correcte apporte une preuve positive
aux compétences déclarées ; une réponse assistée ne certifie pas leur maîtrise.
Les hypothèses ne reçoivent pas de score. Les prérequis ne sont pas pénalisés par
propagation automatique.

Ce contrat est obligatoire pour toutes les cartes et tous les designs. Il
n’existe plus de commutateur de mode d’évaluation. Forum et Amphitheatrum
utilisent eux aussi les feuilles et les compositions du même registre.
Les compétences fines de Grammaticon portent des noms latins. Les lemmes,
formes et traits du registre existant peuvent être référencés comme prérequis.

## Composition et dépendance

`knowledge.aggregation.skills` compose une compétence visible à partir de
compétences évaluables ou d'autres compositions. Avec `level: "minimum"`, une
feuille inconnue vaut zéro ; toutes les feuilles doivent être maîtrisées pour
valider le composite. La progression affichée suit également le minimum, pas la
moyenne des seules feuilles rencontrées. Aucun score enregistré directement sur
le composite n'est lu comme preuve de ses composants.

`knowledge.requires` décrit les prérequis, distincts de la composition.
Les références et les cycles sont vérifiés dans chaque graphe et dans leur union.
Les dépendances ne rendent pas un achat obligatoire et ne transfèrent aucun score.
Le sélecteur pondère les questions selon les prérequis transitifs de leurs
compétences et leur propre champ `requires`. Il développe les compositions,
retient les feuilles évaluables dans le catalogue et exclut les compétences
évaluées par la question elle-même. La moyenne de préparation module uniquement
la fréquence de sélection (facteur de 0,25 à 1), jamais la maîtrise. Le plancher
laisse les phrases accessibles avant le vocabulaire de fin de section.

`mastered: "lieu/section/carte"` demande la maîtrise de toutes les compétences de
la carte. L’ancien opérateur `completed`
emploie aussi cette règle pour toutes les cartes. Les compteurs de victoires sont conservés pour les
statistiques, jamais utilisés pour valider une carte.

La sélection privilégie les feuilles fragiles et les questions déclarant les
mêmes feuilles que les erreurs récentes, même dans une autre carte. La navigation
vers les activités liées utilise la composition explicite des cartes. L'index
éditorial `coverage.json.questionIndex` fournit la correspondance exacte
compétence → carte → question. Il est recalculable, pas un deuxième référentiel.

## Deux types de preuves

`lectio.*` évalue l'interprétation du latin : relations, références, temporalité,
portée de la négation, etc. `compositio.*` évalue des choix de formulation en latin.
Les scores sont séparés. La banque de thème actuelle est guidée : elle ne certifie
pas une rédaction libre. Les exercices à trous demandent des constituants ; les
questions de lecture en contexte ont leurs propres textes et objectifs.

Chaque lemme dispose de `lexicon.lectio.<lemme>` et
`lexicon.compositio.<lemme>`. Ces feuilles sont évaluées exclusivement dans
`Vocābula`, dernière carte de chaque section. Sa banque contient exactement
l'ensemble `vocabulary` déclaré par les exercices de cette section, dans ce lieu.
Une phrase référence éventuellement ces feuilles dans `requires`, mais sa réussite
ne crédite aucun mot. Le même lemme dans plusieurs sections partage son score dans
une direction ; l'autre direction conserve une estimation indépendante.

## Migration et vérification

Les anciens scores globaux `study.*` et ceux des cartes du Forum et de
l’Amphitheatrum sont archivés dans `previousMastery`, sans
être redistribués arbitrairement aux feuilles. Achats, monnaie et statistiques
restent conservés. Les preuves fines déjà compatibles sont conservées.
Les rencontres interrompues qui évaluent les anciens skills sont archivées.

- `python3 tool/audit_unified_model.py --write` : toutes les questions des quatre
  lieux, dépendances, compositions, diagnostics et conservation des textes des
  banques historiques (empreintes dans `unification.json`).
- `python3 tool/audit_skill_graph.py --write` : intégrité, index, vocabulaire exact,
  feuilles sans assez d'items pour atteindre les seuils.
- `python3 tool/check_learning_contract.py --catalog-only` : contrat actuel.
- `python3 tool/check_learning_contract.py` : objectif global, volontairement en
  échec tant que l'étendue et le volume demandés ne sont pas présents.
- `flutter test --no-pub test/engine` : moteur et interface.

`migration-map.json` conserve les décisions de fusion des anciens diagnostics.
Les JSON courants sont la source de vérité. `sync_section_vocabulary.py`
recompose les bilans à partir des traductions déjà écrites et échoue si une
traduction manque. Aucun texte, choix ou diagnostic n'est généré à l'exécution du jeu.

`question.evidenceItem` permet de distinguer les formes ou contextes probants
sans changer l’identité économique `item`. Il vaut `item` quand il est absent.
Une réussite sur un couple personne/nombre ne confond pas les deux compétences ;
un choix erroné ne pénalise que les composantes réellement différentes.

## Construction éditoriale en cours

`tool/curriculum/build_curriculum.py` matérialise les unités originales de cas et
subordination. Les fichiers `cases.py` et `subordination.py` contiennent des tâches
indépendantes de lecture et de formulation. Les participants sont fléchis selon
leurs formes déclarées ; `people.py` introduit un nouveau groupe de métiers dans
la deuxième unité. L'application lit seulement les questions JSON matérialisées.

`curriculum-build.json` distingue le nombre de modèles de phrases et leurs
variantes lexicales : ces dernières ne sont pas autant de concepts nouveaux.
`dependencies.py` fournit leurs prérequis fins. Leur familiarité conditionne
l'accès ; la maîtrise des cartes précédentes reste calculée sur leurs feuilles.
Les mots requis pour lire une phrase ne sont pas crédités par sa réussite.

Le contrôle global reste en échec : il vérifie aussi un plancher de travail de
2 000 mots distincts par direction et la présence des deux évaluations lexicales.
Ce plancher empêche de présenter de nombreuses permutations d'un petit lexique
comme une couverture large ; il ne certifie pas à lui seul l'exhaustivité.

`evidence.py` distingue le stimulus évalué du simple décor. Une substitution de
personnage ne compte pas comme une preuve nouvelle lorsque la construction
évaluée reste entièrement fixe. Ces séries doivent recevoir d'autres stimuli
pertinents avant de satisfaire le minimum de diversité du moteur ; on ne baisse
pas leur seuil pour masquer le manque de contenu.

La diversité nécessaire à la maîtrise se calcule sur `successfulItems`, pas sur
les éléments simplement rencontrés. Une erreur retire la réussite de ce stimulus
pour le seul skill diagnostiqué. La progression est plafonnée par la couverture
de ces réussites et la sélection adaptative favorise les stimuli non encore
réussis. Les récompenses conservent leurs seuils propres.

La révision `unified-skills-3` archive les preuves des seules nouvelles unités
de cas/subordination qui comptaient auparavant leurs changements de décor comme
stimuli distincts. Les autres preuves fines compatibles sont conservées.

Les unités de cas et subordination disposent maintenant de quatre stimuli
pertinents au minimum par compétence grammaticale évaluée. `extra_cases.py`,
`extra_subordination.py` et `stimuli.py` ajoutent ces constructions distinctes.
Cela ne complète pas encore le reste du programme ni son lexique.

Certaines questions évaluent plusieurs feuilles. Dans l’exemple de relative
finale au pluriel, `petunt`, `petat` et `peterent` diagnostiquent respectivement
la construction finale, le nombre et la concordance des temps. La réussite
crédite les trois compétences ; chaque erreur ne touche que la feuille indiquée.
L’extrait est recalculable avec `tool/curriculum/export_example.py`.

`selectionGroup` conserve les familles de stimuli dans l’index et dans les
parties matérialisées. La sélection adaptative utilise leur besoin moyen de
travail, puis choisit une question dans la famille. Multiplier ses variantes de
décor ne multiplie donc pas son poids. Les politiques de groupe restent des
facteurs explicites et les stimuli non encore réussis sont favorisés.

Le lot de comparaison comprend quatre distinctions par direction : comparatif,
superlatif, comparaison irrégulière et degré de l’adverbe. Les objets possèdent
des genres latin et français déclarés séparément. Le plafond déterministe des
variantes conserve chaque objet ; il ne crée pas de preuves grammaticales
supplémentaires. Les identifiants des constructions sont uniques dans tout le
lot éditorial pour éviter qu’une aide en remplace une autre.

Le lot pronominal distingue les indéfinis, les interrogatifs, les relatifs
indéfinis et l’opposition entre insistance (*ipse*) et identité (*īdem*). Les
questions de lecture suivent les référents dans le discours ; le thème demande
le choix d’un pronom adapté au sens et à sa fonction. Dans le contraste entre
agent/patient et personne/chose, chaque mauvais choix possède son attribution
propre. Ces unités restent des exercices guidés et ne suffisent pas à attester
l’exhaustivité du parcours.

Le lot numérique compose ses objectifs à partir de distinctions fines partagées :
quantité/rang, quantité/fréquence, rang/fréquence, quantité collective/répartition,
rang/répartition et interprétation d’une série ordinale. Un mauvais choix ne
pénalise que sa distinction. Les cartes de quantité et de fréquence peuvent donc
progresser depuis une même preuve sans partager de compteur de victoire.
L’audit de couverture développe désormais les composants d’un objectif composé :
toutes ses feuilles doivent avoir des preuves, sans jamais évaluer le composite.

Les situations numériques emploient un lexique animal avec accusatifs et genres
latin/français déclarés. Les choix de thème sont des constituants grammaticaux
complets. Chaque lemme numérique conserve son identifiant canonique (par exemple
`primus`, `bis`, `bini`), partagé entre les sections et évalué lexicalement dans
les cartes finales seulement.

Le lot conditionnel sépare la condition ouverte, la possibilité, l’irréel et les
temps de la condition et de la conséquence. L’irréel du présent et celui du passé
possèdent chacun des constructions correctes à travailler. Les conditions mixtes
composent les deux compétences temporelles partagées. Un thème qui fournit déjà
la condition et ne demande que sa conséquence n’évalue pas le temps de la partie
fournie. La lecture distingue aussi une condition d’une cause affirmée.

Le lot des subjonctifs indépendants comprend exhortations, souhaits réalisables
et irréalisables (présents/passés), possibilités, délibérations présentes et
rétrospectives, ainsi que les interdictions avec *nē* ou *nōlī*. Les distinctions
entre exhortation/souhait et souhait/possibilité sont partagées entre cartes.
Les erreurs de temporalité et de polarité possèdent leurs propres attributions.
Le vocabulaire alimentaire joue le rôle d’objet des actions ; les formes
accusatives et les groupes nominaux français sont déclarés séparément. Une
variation de nourriture ne crée pas de nouvelle preuve grammaticale.

Le lot des formes non finies couvre les participes conjoints présents et parfaits,
les gérondifs adjectivaux, leur attraction à l’accusatif, au génitif et à
l’ablatif, les deux périphrastiques et les deux supins. En production, le genre
et le nombre du gérondif adjectival sont deux feuilles distinctes ; chaque cas
d’attraction possède aussi sa feuille. Les temps de la périphrastique active
et passive partagent une compétence. La lecture et le thème n’évaluent pas
artificiellement les mêmes composants : interpréter un groupe et choisir ses
terminaisons sont des tâches différentes.

Le discours rapporté réutilise les feuilles de temps de l’infinitif, de
référence réflexive et de possession. Le nominatif avec infinitif distingue
l’attribution d’un propos en lecture et le cas du sujet en production. Les
ordres indirects distinguent la polarité de la différence entre ordre et fait
en lecture ; en production, le lien introducteur ut/nē a son propre diagnostic.
Les interrogations narratives travaillent l’antériorité ; le thème évalue
séparément le choix du mode quand le temps est déjà donné. Les reprises
possessives s’appuient sur une parole directe explicite afin d’identifier
le possesseur sans inventer une ambiguïté.

Les emplois particuliers des verbes comprennent les déponents, semi-déponents,
impersonnels, défectifs, le passif impersonnel et les régimes datif/ablatif. Les
phrases avec licet/oportet évaluent le cas de la personne ; celles avec
pudet/paenitet distinguent personne à l’accusatif et cause au génitif. Le
lexique reste évalué dans Vocābula. La lecture des déponents travaille les
rôles ; leur production travaille les formes. Les citations interrompues par
inquit conservent la personne du discours direct.
