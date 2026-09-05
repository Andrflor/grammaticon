# Grammaticon

Lūdus Latīnus — un jeu d'apprentissage de la conjugaison latine dans une ville romaine.
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
dart run tool/dump_paradigm.dart amo 'ind.*.act'     # affiche un paradigme
dart run tool/export_forms.dart                      # exporte toutes les formes (JSON)
python3 tool/corpus/verify_collatinus.py             # contrôle croisé avec Collatinus
python3 tool/assets/generate_art.py                  # régénère les visuels provisoires
```

## Boucle de jeu

Ville → **Amphitheātrum** → choix d'une épreuve (certāmen) → combat → résultats → achat d'un palier avec les gemmes → sauvegarde.

* Réponse par souris, toucher ou touches **1–9** ; Échap met en pause ; Espace/Entrée passe la correction.
* Bonne réponse : attaque, impact, *Recte!*, gemmes qui volent vers le compteur, question suivante après ~350 ms (réglable).
* Erreur : riposte, perte d'un cœur, pénalité, explication contrastive, délai de lecture réglable ; *Explicā plūs* ouvre l'aide (tableaux, décomposition, forme voisine) et suspend la reprise.
* **Exercitātiō** : même contenu sans gemmes ni cœurs ; les réponses aidées ou corrigées sont comptées à part.
* **Tabula** : maîtrise estimée par compétence, alimentée par les réponses réelles (nombre, diversité des verbes, réussite récente au premier essai, dernière pratique, révision due, fiabilité).
* Sauvegarde après chaque réponse et chaque achat (`shared_preferences`, schéma versionné, migrations, export/import par le presse-papiers). Un combat interrompu se reprend depuis la ville.

## Architecture

```
lib/linguistics   moteur : grammaire (enums), analyses, lexique vérifié, conjugueur, index d'analyse, aide
lib/pedagogy      compétences, catalogue des épreuves, générateur de questions, maîtrise, progression, explications
lib/economy       barème gemmes (centralisé), transaction unique par réponse
lib/battle        résolution déterministe d'une réponse + contrôleur de combat (Riverpod Notifier)
lib/persistence   schéma de sauvegarde versionné, migrations, dépôt
lib/app           providers Riverpod, thème, bootstrap
lib/game          scène Flame (héros, adversaire, impacts, particules) — ne décide rien, représente
lib/ui            ville, Amphitheātrum, arène, Tabula, réglages, aide
tool/             outils de développement (export, vérification Collatinus, génération des visuels)
doc/              matrice de couverture, vérifications, manifeste des assets
```

Une réponse est résolue une seule fois par `AnswerResolver` (pur), persistée immédiatement par `ProfileController`, puis seulement animée. Les animations ne conditionnent jamais l'enregistrement.

## Documentation

* `doc/coverage_matrix.md` — catégorie → données → génération/analyse → épreuve → test.
* `doc/verification.md` — vérifications effectuées, plateformes testées, limites connues.
* `doc/assets_manifest.md` — assets provisoires, dimensions, pivots, spécifications de remplacement.
* `THIRD_PARTY_NOTICES.md` — sources et licences.
