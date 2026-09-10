# Theatrum et Templum : objectif en cours

L’objectif actif est la couverture vérifiable de Familia Romana, Fabellae Latinae, Fabulae Syrae et Epitome Historiae Sacrae. Le catalogue actuel ne constitue pas encore cette couverture complète.

## Structure retenue

Les sections sont des groupes d’apprentissage. Plusieurs cartes nommées en latin y travaillent des distinctions précises, une par une, dans des phrases originales. Le premier groupe commence par **-a et -ā** : le Templum distingue explicitement « Puella in Italiā est. » de « Puella in Italia est. ». Les cartes suivantes travaillent d’autres distinctions et portent leurs noms propres, pas un titre générique « Thema » ou « Versiō ».

Titres, consignes, cours et corrections sont en latin. Le français reste uniquement dans le matériel à traduire ou les équivalents lexicaux. Les activités du Theatrum et du Templum restent respectivement Fābula et Rītus, avec leurs icônes, tenues, adversaires et présentation existants.

Chaque groupe se termine par une carte Vocābula dans chaque lieu : latin → français au Theatrum et français → latin au Templum. Chaque banque couvre l’union des lemmes rencontrés dans les cartes du groupe, une seule entrée par lemme et par direction. Il n’y a pas de parcours de révision ajouté ; la maîtrise décroît selon la mécanique existante.

Seule la première carte de chaque lieu est gratuite. Les autres, y compris les bilans lexicaux, ont un prix positif. Les cartes suivent des prérequis explicites et l’ordre écrit dans le JSON. Les bilans viennent en dernier et requièrent la complétion des cartes du groupe dans le lieu concerné.

## Conditions d’achèvement

Le contrat `contracts/completion.json` définit les critères stricts. L’objectif n’est atteint que lorsque tous les critères sont satisfaits, y compris l’inventaire complet, les correspondances et la vérification pédagogique. Aucun nombre de cartes ou de questions ne remplace ces conditions.

- `python3 tool/check_learning_contract.py --catalog-only` contrôle les invariants du catalogue actuel.
- `python3 tool/check_learning_contract.py` contrôle l’objectif complet et **doit échouer tant que les lacunes subsistent**.

Le registre de 356 unités dans `coverage.json` reste incomplet : les 30 lectures de Fabellae Latinae ont maintenant un relevé initial de leurs exigences, mais aucune unité n’a encore une couverture certifiée. Le lexique public de Familia Romana a pu être consulté : `contracts/familia-romana-lexical-candidates.json` contient 1 899 entrées candidates avec leurs pages source, sans les définitions anglaises. Les normalisations, les sens et leur couverture restent à vérifier. Les autres ouvrages nécessitent leurs propres inventaires.

## État technique actuel

Douze groupes, 66 sujets dans les deux sens, dont certaines anciennes cartes encore à découper, vingt-quatre cartes lexicales finales : 156 cartes et 1 670 questions pour Theatrum/Templum. Le rapport du design déclare les adresses des cartes et leurs inventaires lexicaux. La validation technique et les tests de macrons, d’économie, de progression et de rendu passent ; cela ne certifie pas une couverture exhaustive ni une relecture indépendante de tous les contenus.

Le rapport de rapprochement lexical est recalculé par `python3 tool/audit_lexical_traceability.py`. L’option `--check` détecte un rapport périmé. Ce contrôle examine les références aux questions existantes ; il ne produit aucune question et ne certifie pas les sens lexicaux.

`python3 tool/audit_existing_content.py` inventorie les 171 cartes du Forum et de l’Amphitheatrum : index complet et un exemple matérialisé par dimension et par carte (516 exemples). Son option `--check` détecte un relevé périmé. Les 691 identifiants d’items distincts ne sont pas assimilés automatiquement à 691 mots appris. Reconnaître un lemme latin ou nommer un cas ne prouve pas sa traduction ni la compréhension de toute une phrase.

Les premières correspondances avec ces lieux sont enregistrées dans `coverage.json` avec leur portée explicite. Le contrôle complet résout leurs identifiants dans les banques compressées réelles et vérifie une empreinte incluant les textes, choix et corrections. Une modification invalide la preuve jusqu’à sa relecture ; l’existence d’une question ne suffit pas à certifier la couverture pédagogique.

Les formes des 30 lectures de Fabellae Latinae sont inventoriées dans `contracts/fabellae-surface-inventory.json`. Les exigences de lecture sont relevées dans `coverage.json` et leurs libellés regroupés dans `contracts/fabellae-construction-index.json`. La désambiguïsation des lemmes, la consolidation des libellés et les correspondances pédagogiques restent en cours.

Les références de Fabulae Syrae et d’Epitome sont accessibles pour l’audit. Leurs sommaires et paragraphes sont reliés aux pages dans `contracts/fabulae-syrae-source-map.json` et `contracts/epitome-source-map.json`. Les fichiers de référence restent hors du dépôt et aucun de leurs textes n’est intégré au jeu. Le comptage de Fabulae Syrae distingue les 45 lectures numérotées de l’édition consultée des 50 mythes annoncés par l’éditeur.

Les cinq premières lectures de *Fabulae Syrae* ont désormais un inventaire provisoire, indexé dans [fabulae-syrae-construction-index.json](contracts/fabulae-syrae-construction-index.json). Les fins de trois plages de pages ont été corrigées après lecture du corps du texte. Les quarante lectures suivantes et l’exhaustivité lexicale restent à examiner.

Les dix premiers paragraphes de l’*Epitome* ont un relevé provisoire de 82 constructions dans [epitome-construction-index.json](contracts/epitome-construction-index.json), avec leurs limites de pages vérifiées. Les 236 paragraphes suivants et l’exhaustivité lexicale restent à examiner. La carte **Ut monēret**, placée après **Ut et nē**, apporte une première correspondance partielle pour le but après une action passée.
