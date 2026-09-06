# Grammaticon

Lūdus Latīnus — un jeu d'apprentissage de la conjugaison et de la déclinaison latines dans une ville romaine.
Flutter · Riverpod (déclarations manuelles) · Flutter Hooks · Flame. **Aucun `build_runner`**, aucun code généré, aucun réseau à l'exécution.

Toute l'interface est en latin. Le français n'apparaît que dans ce dépôt (documentation, gloses du lexique réservées aux futurs exercices de traduction).

## Lancer

Prérequis : Flutter 3.47 (Dart 3.13) tel que verrouillé par `pubspec.lock`.

```bash
flutter pub get
flutter run -d linux      # bureau Linux (testé)
flutter run -d chrome     # web (non testé visuellement)
flutter run -d <android>  # Android (APK debug compilé, non testé sur appareil)
```

Tests et analyse :

```bash
flutter analyze
flutter test
```

Outils de développement (jamais nécessaires pour construire l'application) :

```bash
dart run tool/dump_paradigm.dart amo 'ind.*.act'     # affiche un paradigme verbal
dart run tool/dump_declension.dart rosa rex          # affiche un paradigme nominal
dart run tool/sample_forum_questions.dart d1-recti   # échantillonne questions et corrections du Forum
dart run tool/export_forms.dart                      # exporte toutes les formes verbales (JSON)
dart run tool/export_nouns.dart                      # exporte toutes les formes nominales (JSON)
python3 tool/corpus/verify_collatinus.py             # contrôle croisé des verbes avec Collatinus
python3 tool/corpus/verify_collatinus_nouns.py       # contrôle croisé des noms avec Collatinus
python3 tool/assets/generate_art.py                  # régénère les visuels provisoires (ville, arène)
python3 tool/assets/generate_forum_art.py            # régénère les visuels du Forum
bash tool/assets/generate_sfx.sh                     # régénère les sons du Forum (SoX)
```

## Boucle de jeu

Ville → **Amphitheātrum** (conjugaisons) ou **Forum** (déclinaisons) → choix d'une épreuve (certāmen / contrōversia) → rencontre → résultats → achat d'un palier avec les gemmes → sauvegarde.

Les deux activités partagent le même moteur de rencontre, le même porte-monnaie de gemmes, les mêmes règles de maîtrise et la même sauvegarde ; seuls changent les données linguistiques, les épreuves, les libellés latins et la mise en scène.

* Réponse par souris, toucher ou touches **1–9** ; Échap met en pause ; Espace/Entrée passe la correction.
* Bonne réponse : attaque, impact, *Recte!*, gemmes qui volent vers le compteur, question suivante après ~350 ms (réglable).
* Erreur : riposte, perte d'un cœur, pénalité, explication contrastive qui reste affichée jusqu'à *Perge* (ou Espace/Entrée) ; *Explicā plūs* ouvre l'aide (tableaux, décomposition, forme voisine).
* Défaite : les gemmes gagnées pendant le combat sont perdues et un tribut d'un quart du solde (plafonné à 40) est payé ; achats et maîtrise sont conservés. Le coût est annoncé avant chaque combat.
* **Exercitātiō** : même contenu sans gemmes ni cœurs ; les réponses aidées ou corrigées sont comptées à part.
* **Forum** : duel oratoire contre un orateur romain. Une forme déclinée apparaît ; le joueur en donne le cas, le nombre, la déclinaison (épreuves mixtes) ou l'analyse complète. Bonne réponse : geste, rouleau d'argument, adversaire qui recule, applaudissements ; la *cōnstantia* de l'adversaire baisse. Erreur : réfutation, murmure du public, cœur perdu. Toutes les analyses valides d'une forme sont acceptées (*rosae* : gén. sg., dat. sg., nom. pl., voc. pl.) ; aucune question n'est posée si toutes les réponses proposées seraient justes ; l'entrée de dictionnaire (*rosa, rosae, f.*) est affichée dans les épreuves d'introduction, et dans « Quae dēclīnātiō ? » seulement quand la désinence seule est ambiguë.
* **Tabula** : maîtrise estimée par compétence, alimentée par les réponses réelles (nombre, diversité des verbes, réussite récente au premier essai, dernière pratique, révision due, fiabilité). Branche **Dēclīnātiōnēs** : déclinaison → cas → nombre, locatif, épreuves mixtes.
* Sauvegarde après chaque réponse et chaque achat (`shared_preferences`, schéma versionné, migrations, export/import par le presse-papiers). Un combat interrompu se reprend depuis la ville.

## Architecture

```
lib/linguistics   moteur : grammaire (enums), analyses, lexiques vérifiés (verbes, noms), conjugueur, déclineur, index d'analyse, aides
lib/pedagogy      compétences, modèle d'épreuve partagé (trial.dart), catalogues (trials.dart verbes, noun_trials.dart noms),
                  contrat de question partagé (question.dart), générateurs (verbes, noms), maîtrise, progression, explications
lib/economy       barème gemmes (centralisé), transaction unique par réponse
lib/battle        résolution déterministe d'une réponse + contrôleur de rencontre neutre vis-à-vis de l'activité (Riverpod Notifier)
lib/persistence   schéma de sauvegarde versionné (v2), migrations, dépôt
lib/app           providers Riverpod, thème, bootstrap
lib/game          scènes Flame : contrat EncounterScene, arène (ArenaGame), forum (ForumGame) — ne décident rien, représentent
lib/ui            ville, sélection d'épreuves partagée (TrialSelectionScreen), écran de rencontre partagé (BattleScreen),
                  configuration par activité (ActivityConfig : libellés latins, adversaires, scène, aide, sons), Tabula, réglages, aides
tool/             outils de développement (export, vérification Collatinus, génération des visuels et des sons)
doc/              matrice de couverture, vérifications, manifeste des assets
```

Une réponse est résolue une seule fois par `AnswerResolver` (pur), persistée immédiatement par `ProfileController`, puis seulement animée. Les animations ne conditionnent jamais l'enregistrement.

### Partage entre Amphitheātrum et Forum

Partagé : transitions de la rencontre (`BattleController`, `BattleState`), contrat de question (`Question`, `correctValues` multi-valeurs, `QuestionSource`), résolution et transaction unique (`AnswerResolver`), barres de ressource et résultats, gemmes volantes, sélection/prérequis/achats (`Progression`, `TrialSelectionScreen`), maîtrise (`SkillRecord`, `MasterySummary`), persistance et pause. Spécifique à chaque activité : données linguistiques et génération (`QuestionGenerator` / `NounQuestionGenerator`), taxonomie de compétences et catalogue d'épreuves, libellés latins, scène, gestes et sons (`ActivityConfig`). Le contrôleur ne connaît pas l'activité : il interroge la `QuestionSource` de l'activité de l'épreuve.

## Documentation

* `doc/coverage_matrix.md` — catégorie → données → génération/analyse → épreuve → test.
* `doc/verification.md` — vérifications effectuées, plateformes testées, limites connues.
* `doc/assets_manifest.md` — assets provisoires, dimensions, pivots, spécifications de remplacement.
* `THIRD_PARTY_NOTICES.md` — sources et licences.
