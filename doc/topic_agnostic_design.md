# Contrat du design et migration

## Frontière du moteur

Le moteur connaît des documents, des interactions, des transactions et des opérations de suivi. Tous les identifiants de lieu, de carte, de compétence, de dimension, d’attribut et de confusion sont opaques. Aucun conjugueur, analyseur linguistique, générateur de questions ou recherche de similarité pédagogique n’est présent dans `lib`.

Le design contient les questions et leurs propositions complètes, l’ordre des propositions, les réponses acceptées, les corrections, les connaissances concernées, les hypothèses et les destinations précises associées à une réponse. Les cours, aides, relations, prérequis, prix, récompenses, langues, assets et thème appartiennent aussi au design. Le moteur choisit des entrées existantes et applique ces déclarations. Il ne crée pas de nouvelles variantes ou de nouveaux liens.

## Hiérarchie

```text
assets/designs/<game-id>/
  game.json
  assets.json
  rules.json
  knowledge.json[.gz]
  help.json[.gz]
  locales/<locale>.json
  places/<place-id>/
    place.json
    sections/<section-id>/
      section.json
      cards/<card-id>/
        card.json
        lesson.json
        questions.json[.gz]
        part-0000.json.gz ...       # grandes banques seulement
```

Le manifeste déclare `places` dans leur ordre. Chaque lieu ou section déclare ses `children`, avec `kind` (`section` ou `card`) et `id`. Des sections peuvent contenir d’autres sections ; le chemin suit alors cette imbrication. Les identifiants des documents doivent correspondre aux dossiers. Les références globales emploient l’adresse complète, par exemple `observatory/discovery/durations`. Les noms et sous-titres sont indépendants de ces identifiants.

Les fichiers ordinaires du design `compass` constituent un exemple complet directement éditable. Les modèles et validations effectives sont définis dans `lib/engine/design.dart`.

## Manifeste et présentation

`game.json` déclare `schemaVersion: 1`, `id`, `revision`, `name`, `subtitle`, `defaultLocale`, `locales`, les chemins des registres `assets`, `rules`, `knowledge`, `help`, la liste des lieux, le `theme`, la `presentation` globale et les `settings` initiaux. Le chemin du manifeste est sélectionné à la compilation avec `GAME_DESIGN`.

Un texte peut être une chaîne, un objet de traductions (`{"fr":"Aide","en":"Help"}`), ou une référence à une clé du registre de langues (`{"key":"actions.help"}`). La langue par défaut sert de repli. Changer une langue ne traduit pas les contenus. Les actions communes — aide, retour, pause, abandon, achat, import/export, suivi, etc. — ont des clés sémantiques dans les fichiers de langue.

`assets.json` associe des identifiants à un type (`image`, `audio`, `font`) et un chemin. Une police déclare aussi sa famille. Le thème choisit les familles, les couleurs sémantiques, tailles de texte, espacements, rayons, largeur du contenu, dimensions et paramètres de mouvement de la scène. Les cartes choisissent leurs fonds, acteurs, poses, effets et séquences sonores dans ce registre. Aucun nom d’asset romain n’est imposé par le moteur.

Le script `tool/build_game.py` n’embarque que le dossier du design sélectionné et les ressources de son registre. Il rétablit le fichier de déclaration d’assets après compilation. Le registre fourni reprend les ressources existantes ; le jeu de démonstration réutilise donc des illustrations romaines malgré ses autres sujets.

## Cartes et conditions

Une carte déclare son nom, son sous-titre, ses compétences, son cours, sa banque de questions, son coût et les paramètres de rencontre (`lives`, `target`). Sa présentation reste indépendante du type d’interaction des questions.

Les conditions sont des arbres fermés : `all`, `any`, `not`, `unlocked`, `completed`, `count` et `skill` avec niveau minimal ou nombre minimal d’observations. Elles ne peuvent pas exécuter de script. Les conditions d’un parent s’appliquent à ses descendants. Les achats restent permanents. Une question peut avoir une condition `eligible` : cela conserve notamment les composants accessibles des mélanges et l’apparition progressive des questions combinées.

Les conditions d’accès sont distinctes des dépendances pédagogiques. Un lien de connaissance ou une hypothèse ne ferme jamais une carte implicitement.

## Questions et réponses

Les interactions sont définies par ce qu’elles affichent et recueillent :

- `choice` : contenu et choix de réponse ;
- `highlightChoice` : contenu comprenant un élément mis en évidence ;
- `gapChoice` : contenu comprenant un trou rempli par le choix.

Extrait simplifié d’une question du second design :

```json
{
  "id": "hours",
  "interaction": "gapChoice",
  "dimension": "completion",
  "item": "hours",
  "assessment": "hours",
  "prompt": {"fr": "Compléter la conversion.", "en": "Complete the conversion."},
  "content": [
    {"type": "text", "text": "Deux heures = "},
    {"type": "gap", "text": "…"},
    {"type": "text", "text": " minutes"}
  ],
  "choices": [
    {"id": "0", "text": "120"},
    {"id": "1", "text": "200"},
    {"id": "2", "text": "60"}
  ],
  "accepted": ["0"],
  "skills": ["time-units"],
  "requires": ["time-units"],
  "help": "durations",
  "outcomes": {
    "0": {"feedback": "2 × 60 = 120.", "observed": [], "hypotheses": [], "practice": []},
    "1": {"feedback": "Une heure contient 60 minutes, pas 100.", "observed": ["unit-factor"], "hypotheses": ["time-units"], "practice": ["practice-durations"]},
    "2": {"feedback": "60 minutes représentent une seule heure.", "observed": ["unit-factor"], "hypotheses": ["time-units"], "practice": ["practice-durations"]}
  }
}
```

Chaque choix possède son propre résultat. Plusieurs réponses peuvent être acceptées. `assessment` déclare l’identité utilisée pour suivre une difficulté, indépendamment d’une variante de présentation. `item` est un identifiant de diversité ; il peut désigner n’importe quel objet du design. `attributes` contient les données descriptives pré-écrites, dont les noms et types sont décrits par le design. Le moteur ne les interprète pas comme des notions d’un sujet.

`next` référence une autre question du même catalogue. `followUpOnly` permet de réserver cette question à l’enchaînement. Aucun ordre de réponse n’est mélangé à l’exécution. Pour un autre ordre, le design doit fournir une autre variante identifiée.

## Liens entièrement déclarés

`knowledge` définit dimensions, attributs, nœuds, hiérarchie d’affichage et éventuelles agrégations. Le suivi affiche cette hiérarchie ; il ne crée aucune branche consacrée à une discipline. Les niveaux et leurs seuils se trouvent dans les règles.

Chaque résultat de réponse référence zéro ou plusieurs `practiceSets`. Un ensemble contient les **adresses des cartes et les identifiants des questions cibles**, ou une déclaration explicite `allQuestions: true`. Par exemple, le design du Cabinet relie volontairement les erreurs sur les siècles à des questions de conversion de durée dans un autre lieu. Ce lien n’est pas recherché ou déduit par le moteur.

Les constats et hypothèses restent séparés. Une hypothèse affichée n’est pas une nouvelle erreur établie. Les liens proposés restent ceux du design même lorsque le moteur ne connaît rien des sujets concernés.

## Règles et observations

`rules.json` configure niveaux de maîtrise, seuils, minima d’observations et de diversité, lissage, évolution en l’absence de pratique, barèmes par niveau, assistance, saturation par objet, victoire, défaite et limites de conservation. Les groupes de sélection et leurs poids peuvent être déclarés par carte, avec des conditions de niveau.

Le rappel utilise uniquement l’identité d’évaluation et les destinations déclarées. Le combat courant reste exclu. Deux réussites autonomes retirent une erreur avec le réglage Grammaticon ; le nombre requis est configurable. Une réponse aidée ne la retire pas. Il n’y a ni calendrier de rappel ni planificateur pédagogique nouveau.

Une observation conserve la transaction, la date, le design et sa révision, la carte et la rencontre, la question complète présentée, les choix dans leur ordre, le choix du joueur, la correction et les liens déclarés, l’assistance et le temps de réponse. Le temps exclut les pauses et n’est pas interprété comme une erreur. Le journal actif est borné par le design ; une archive de la sauvegarde antérieure est conservée lors de la migration.

## Grammaticon et conservation

Le design reproduit les deux catalogues actuels : 93 cartes de l’Amphitheatrum et 78 du Forum. Les 890 554 entrées couvrent l’énumération des pools existants et des dimensions applicables, y compris les questions combinées et les enchaînements. Les propositions et corrigés ont été fixés en amont, puis les générateurs ont été supprimés. `export-report.json` conserve les comptes par carte et les correspondances d’identifiants.

Le test de parité conserve les prix, compétences, prérequis, cœurs et objectifs des 171 cartes. Les cours et exemples sont exportés dans les cartes ; les aides sont des données. Le changement intentionnel est le remplacement du tirage de formes et de distracteurs à la volée par la sélection d’entrées entièrement écrites. La mise en page et les scènes ont été adaptées aux composants génériques ; elles ne constituent pas une reproduction graphique pixel pour pixel des anciens écrans.

Les grandes banques sont stockées en JSON gzip, avec index et portions de 400 questions. Des dictionnaires de chaînes évitent de répéter les mêmes textes dans une portion. Lire ces références et décompresser les fichiers ne produit aucun contenu nouveau. Une banque ordinaire, comme celles du Cabinet, reste un simple tableau JSON.

La migration est décrite par `migration` dans le manifeste de Grammaticon : correspondances de champs et d’identifiants, compétences, observations, réglages et erreurs. La sauvegarde d’origine est conservée intégralement sous `legacy`. Un combat interrompu retrouve ses cœurs, son objectif restant, ses réponses et ses gains ; l’ancienne sauvegarde ne contenant pas la question complète en cours, sa reprise choisit une entrée pré-écrite. Les instantanés nouveaux conservent exactement la question présentée.

Le contenu biblique et les anciens assets restent des fichiers conservés, mais ne sont pas une activité des deux designs livrés. Aucun travail pédagogique sur le Theatrum ou le Templum n’a été ajouté.

## Vérifications

Les tests couvrent un design à trois lieux et trois niveaux, français/anglais, les trois interactions, les ordres fixes, les snapshots, les liens explicites entre lieux, les règles d’accès composées, le retrait précis des erreurs, la parité des cartes et la migration. Les tests d’interface passent par la même application pour les deux designs, sur téléphone et grand écran.

Le validateur complet a vérifié les 890 554 questions de Grammaticon, leurs propositions et toutes les références des liens. Les compilations Linux des deux designs utilisent le même point d’entrée et n’embarquent que le dossier du design choisi. Les commandes exactes sont dans le README.

Le futur parcours automatique n’est pas implémenté. Ses choix devront eux aussi reposer sur des conditions et destinations déclarées dans le design ; la richesse des données ne garantit pas, à elle seule, la qualité pédagogique d’un parcours.
