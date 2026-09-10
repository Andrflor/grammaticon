# Theatrum et Templum — document de conception initial

Statut : historique de conception, amendé par la structure thématique de `pedagogy/README.md`. Les groupes numérotés et le suivi strict des chapitres ne font pas partie du design retenu. Les lieux sont désormais intégrés ; voir [la livraison et ses limites](pedagogy/README.md). La couverture exhaustive décrite ci-dessous reste un objectif éditorial. Périmètre confirmé : Familia Romana, Fabellae Latinae, Fabulae Syrae et Epitome Historiae Sacrae. Roma Aeterna est hors périmètre.

## Résultat recherché

Préparer la lecture autonome des quatre ouvrages par un parcours original couvrant leur vocabulaire, leurs constructions et leurs exigences de compréhension. Une victoire ou une jauge pleine ne suffit pas à prouver cette autonomie : elle doit être vérifiée sur des textes nouveaux, sans aide, puis à distance de l’entraînement. L’objectif est une couverture contrôlable, sans promettre qu’un score de jeu garantit une lecture sans difficulté pour chaque personne.

Les contenus seront entièrement rédigés pour Grammaticon : récits, phrases, traductions, définitions, distracteurs, cours et corrections. Pas de reprise des phrases, personnages récurrents, exercices, annotations ou traductions des éditions modernes ; pas de simple remplacement de noms dans leurs récits. Les ouvrages servent de références de couverture et de progression. Les sources et éditions consultées seront consignées dans le dossier éditorial.

## Repères documentaires vérifiés

Familia Romana comporte 35 chapitres, avec une progression jusqu’à des lectures poétiques et grammaticales ; son éditeur annonce presque 1 800 mots. Cela impose de préparer aussi ces dernières lectures, et pas uniquement le récit courant. [Présentation de l’éditeur](https://hackettpublishing.com/lingua-latina-per-se-illustrata-series/familia-romana-part-i/lingua-latina-pars-i-familia-romana-full-color-edition).

Fabellae Latinae, dans la version officielle consultée, accompagne les chapitres I–XXV. [Document de l’éditeur, identification et sommaire](https://hackettpublishing.com/pdfs/FabellaeLatinae_2022File.pdf).

Fabulae Syrae est associé aux chapitres XXVI–XXXIV, apporte des lectures mythologiques et se termine par des vers d’Ovide. L’éditeur annonce environ 500 mots nouveaux. [Présentation de l’éditeur](https://hackettpublishing.com/lingua-latina-per-se-illustrata-series/lingua-latina-fabulae-syrae).

Epitome Historiae Sacrae est présenté comme une lecture après Familia Romana, avec plus de 1 300 mots supplémentaires. L’édition décrite comporte 209 lectures de l’Ancien Testament et 37 sections supplémentaires sur la vie de Jésus : la couverture visée inclura ces deux ensembles. [Présentation de l’éditeur](https://hackettpublishing.com/lingua-latina-per-se-illustrata-series/lingua-latina-epitome-historiae-sacrae).

Ces chiffres éditoriaux ne constituent pas un inventaire dédoublonné. Le nombre exact de lemmes, de sens et de locutions à traiter reste à établir. Aucun comptage « tout le vocabulaire est couvert » n’est encore justifié.

## Rôle des quatre lieux

| Lieu | Ce qui y est entraîné | Ce qui constitue une réussite |
|---|---|---|
| Amphitheatrum | Morphologie verbale existante | Reconnaître et distinguer les formes |
| Forum | Morphologie nominale et constructions déjà présentes | Identifier et distinguer les fonctions/formes |
| Theatrum | Latin → sens : lexique en contexte, compréhension, version, lecture suivie | Comprendre qui fait quoi, les références, le temps et les intentions |
| Templum | Sens → latin : rappel lexical, thème guidé, choix d’une formulation et de ses constructions | Exprimer un sens donné en latin et distinguer les changements de sens |

Theatrum et Templum partagent des objectifs et des paliers, mais gardent des évaluations distinctes. Reconnaître un mot ne valide pas automatiquement sa mobilisation en thème. Le décor religieux du Templum n’oblige pas chaque exercice à porter sur la religion : sa fonction pédagogique reste le thème. Les récits sacrés et leur lexique arrivent aux paliers appropriés et peuvent être lus au Theatrum comme reformulés au Templum.

Ne pas recopier une nouvelle série de déclinaisons/conjugaisons : les formes déjà travaillées deviennent des moyens de comprendre ou d’exprimer un message. Quand une mauvaise réponse justifie un retour au Forum ou à l’Amphitheatrum, la destination exacte est écrite dans son résultat JSON.

## Progression propre au jeu

Les paliers suivants sont une proposition d’organisation, pas une table chapitre par chapitre vérifiée. Leurs limites et prérequis seront arrêtés après l’inventaire des quatre livres.

| Palier | Compétence de lecture et de thème | Lexique et situations originales |
|---|---|---|
| 1 | Identifier, compter, affirmer et nier | Personnes, objets, lieux, nombres, relations simples |
| 2 | Comprendre agent, patient, possession et destinataire | Maison, échanges, actions quotidiennes |
| 3 | Suivre un déplacement et ses participants | Ville, chemins, positions, origines et destinations |
| 4 | Décrire, comparer et suivre les reprises pronominales | Corps, animaux, qualités, activités humaines |
| 5 | Relier les faits par le temps, la cause et le but simple | Calendrier, voyages, apprentissage, échanges |
| 6 | Raconter : événements, arrière-plan et antériorité | Récits courts, événements et conséquences |
| 7 | Comprendre une phrase à plusieurs propositions | Parole rapportée, relatives, participes et relations logiques |
| 8 | Interpréter intentions, modalités et subordination complexe | Choix, conseils, ordres, arguments, récits développés |
| 9 | Lire des récits mythologiques et les passages de registre poétique | Lexique des mythes, noms propres, ordre des mots, élisions et lecture du vers |
| 10 | Étendre la lecture aux récits sacrés | Parentés, promesses, lois, voyages, conflits, lexique religieux et usages particuliers |
| 11 | Lire et reformuler sans guidage local | Textes originaux mêlant les acquis, registres et références culturelles |

Chaque palier contient plusieurs petites sections, organisées par objectifs précis. Chaque section propose des cartes de vocabulaire, de compréhension ciblée, de version/thème et un bilan de transfert. Les mots et constructions anciens reviennent dans des contextes nouveaux. Un prérequis porte sur une capacité réellement nécessaire, pas sur l’obligation d’avoir acheté ou terminé toutes les cartes précédentes.

## Inventaire de couverture avant production massive

Créer un registre éditorial JSON distinct des fichiers exécutés. Il associe chaque unité de chaque ouvrage aux objectifs du jeu, sans embarquer le texte du livre. Pour chaque entrée : référence bibliographique/unité, lemmes, sens, locutions, constructions, particularités de registre, notions culturelles nécessaires, palier du jeu, cartes et questions associées, état de rédaction et de relecture.

Pour un mot, distinguer le lemme, ses sens en contexte et les expressions où il intervient. Suivre séparément reconnaissance en lecture et mobilisation en thème ; distinguer formes irrégulières utiles, régime et collocations. Les noms propres ont une catégorie spécifique. Une apparition dans un cours ou un distracteur ne compte pas comme une évaluation.

Le bilan éditorial doit révéler : objectifs sans cours, sens sans question, unités sans lecture de transfert, vocabulaire utilisé avant son introduction sans glose, réponses erronées sans correction précise, liens cassés. La couverture de chaque livre doit être vérifiable jusqu’à sa dernière unité. L’inventaire, encore à faire, déterminera les volumes ; ne pas annoncer arbitrairement un nombre de cartes ou de questions.

## Questions originales et diagnostic explicite

Exemple de travail, à relire linguistiquement avant intégration : « Nauta puellae panem dat. »

Au Theatrum : choisir le sens de la phrase. La réponse « La jeune fille donne du pain au marin » signale une inversion des rôles dans cette réponse ; une hypothèse distincte peut viser l’interprétation du datif. Le JSON pointe précisément vers des exercices déjà identifiés de destinataire. La réponse « Le marin reçoit du pain de la jeune fille » vise une autre inversion, celle de la direction du don. Ne pas attribuer automatiquement toutes ces erreurs à une même compétence.

Au Templum : partir de « Le marin donne du pain à la jeune fille » et choisir la formulation latine correspondante, ou compléter le constituant qui manque. Ce sont de nouvelles questions avec leurs propres réponses, pas une inversion automatique du questionnaire de version.

Les variantes de contexte, d’ordre des mots et d’ordre des choix sont toutes écrites avant le jeu. Une variante cosmétique partage son identité d’évaluation avec ses équivalents afin de ne pas faire passer une répétition pour un transfert. Les bonnes réponses, les aides, les erreurs et chaque destination de révision sont déclarées. Une réponse ambiguë ou plusieurs formulations valides nécessitent des choix acceptés et des explications explicites.

## Correspondance avec le JSON actuel

Les dossiers `places/theatrum` et `places/templum` suivent exactement la hiérarchie existante `place.json → sections/<id>/section.json → cards/<id>/{card,lesson,questions}.json`. Retirer les deux bâtiments des décorations et les inscrire comme lieux actifs dans le manifeste. Conserver leurs assets de carte existants.

Chaque carte déclare : identifiant, noms et sous-titres, `skills`, `access.price`, arbre `access.requires`, `encounter`, fichiers du cours et de questions, et `presentation`. Les sections peuvent imbriquer les sous-objectifs. Les textes de reprise/abandon et les titres appartiennent aux JSON.

Les dimensions de compréhension, lexique réceptif, lexique mobilisé, version et thème sont des identifiants ajoutés à `knowledge`, avec leurs propres nœuds et agrégations. Les métadonnées de corpus restent éditoriales ou sont déclarées comme attributs ; elles ne donnent aucune connaissance du latin au moteur. Les états issus du vocabulaire biblique historique du dépôt ne seront pas assimilés à une maîtrise de ce nouveau parcours.

Le contrat exécutable reste celui de `doc/topic_agnostic_design.md`. Le registre éditorial de couverture n’est pas un nouveau format déjà reconnu par le chargeur : un contrôle hors application devra relier ses références aux adresses réelles des cartes et questions. Ce contrôle ne génère aucune question.

## Capacités actuelles et limites à traiter

Déjà possible par contenu JSON : `choice` pour le sens et les traductions, `highlightChoice` pour une référence ou une expression, `gapChoice` pour un choix de mot/construction ; plusieurs réponses acceptées ; enchaînements prédéfinis avec `next` et `followUpOnly` ; aides et liens de révision ; prix et prérequis indépendants.

Un thème par choix reste un thème guidé. Le moteur n’évalue pas aujourd’hui une rédaction libre. Ne pas prétendre valider une production autonome avec ce seul mode. Si une phase de rappel sans propositions devient nécessaire, prévoir une interaction générique de saisie limitée avec variantes acceptées entièrement déclarées, ou de reconstruction de segments ; aucune analyse linguistique ni correction par inférence ne sera introduite. Ces interactions ne sont pas implémentées par ce plan.

Deux points techniques identifiés :

- La scène actuelle doit être vérifiée pour les paragraphes longs sur téléphone. `longText` existe, mais la carte de question n’est pas un lecteur de plusieurs pages. Les lectures longues pourront nécessiter une surface de lecture défilante commune, dans le style original.
- `next` existe, mais la victoire peut interrompre une séquence après le nombre de bonnes réponses cible. On ne doit pas s’en servir comme preuve que chaque question d’un bilan a été traitée. Une règle générique déclarée de fin de séquence serait nécessaire pour les bilans exhaustifs.

Les seuils « plusieurs textes jamais vus, plusieurs jours, sans aide » ne sont pas tous exprimables par les conditions actuelles. Les seuils de niveau et d’observations existants serviront à l’entraînement ; les exigences de transfert seront suivies éditorialement jusqu’à l’ajout explicite des compteurs et règles génériques nécessaires. L’algorithme ne choisira jamais seul quels objectifs correspondent à un passage.

## Présentation et assets

Le Theatrum dispose déjà d’un fond et de plusieurs acteurs. Le Templum dispose d’un bâtiment de carte, mais pas d’un ensemble dédié de scène et d’adversaires. Prévoir un intérieur de temple et des prêtres/adversaires dans le style existant, avec poses nécessaires, effets et sons éventuels. Réutiliser la scène de projectiles du Forum par configuration de `background`, `hero`, `heroCorrect`, `heroWrong`, `heroVictory`, `heroDefeat`, `opponent`, `projectile`, `rewardEffect` et des sons.

Le moteur continue de connaître une scène de projectiles et des ressources, pas des prêtres ni un rituel. Les contrôles, HUD, boutons, cartes et animations actuels sont conservés. La création des assets vient après la définition du pilote pédagogique.

## Déploiement pédagogique proposé

1. Établir l’inventaire complet et les correspondances avec les compétences déjà présentes. Fixer les paliers et les manques avant de rédiger des milliers de questions.
2. Réaliser trois sections pilotes originales : un niveau débutant, un niveau de récit/subordination, un niveau de lecture sacrée avancée. Chacune inclut vocabulaire, compréhension, version, thème guidé, aides, erreurs et transferts. Cela teste les extrémités du parcours dès le départ.
3. Faire relire le latin, les macrons, les traductions, les distracteurs et les diagnostics ; vérifier sur mobile et ordinateur, notamment textes longs et séquences.
4. Étendre progressivement aux quatre ouvrages suivant le registre. Les exigences importantes doivent être évaluées dans plusieurs contextes indépendants ; une banque gonflée par permutation des choix n’est pas une couverture supplémentaire.
5. Faire passer des bilans sur des lectures originales nouvelles de difficulté comparable, sans aide puis à distance. Calibrer les seuils sur les résultats réels. Les prix et les gains ne permettent pas de contourner ces exigences pédagogiques.

Livrable suivant : inventaire de couverture et première section complète de chaque lieu, avec une chaîne question → mauvaise réponse → constat/hypothèse → questions de révision vérifiable de bout en bout. Ce document ne constitue pas encore cet inventaire ni le contenu final.
