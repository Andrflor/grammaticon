# Design-driven learning games

Un moteur Flutter commun exécute des jeux entièrement décrits en JSON. Il ne connaît ni le latin, ni les mathématiques, ni les compétences d’un sujet. Il ne génère aucune question, proposition, correction ou relation pédagogique à l’exécution.

Deux designs sont fournis :

- **Grammaticon** : Amphitheātrum et Forum, 171 cartes, 890 554 questions explicites issues des contenus existants.
- **Le Cabinet des repères** : trois lieux, six cartes et douze questions sur les durées, la chronologie et les cartes ; français/anglais, autre thème et autre progression.

## Compiler un design

```bash
flutter pub get
python3 tool/build_game.py --design assets/designs/grammaticon/game.json --target linux
python3 tool/build_game.py --design assets/designs/compass/game.json --target linux
```

Les exécutables se trouvent dans `dist/<id>/linux/`. Le script sélectionne les fichiers du design et les assets de son registre pour la compilation ; il rétablit ensuite `pubspec.yaml`. Il ne fabrique aucun contenu. `--target web`, `--target apk` et `--release` sont aussi acceptés ; les compilations Linux sont celles vérifiées dans cette intervention.

Pour le développement, le `pubspec.yaml` du dépôt embarque les deux designs :

```bash
flutter run -d linux --dart-define=GAME_DESIGN=assets/designs/compass/game.json
flutter run -d linux --dart-define=GAME_DESIGN=assets/designs/grammaticon/game.json
```

## Architecture

```text
lib/main.dart                 choix du design à la compilation, ressources, sauvegarde
lib/engine/design.dart        structure, références, validation, lecture du catalogue
lib/engine/session.dart       transactions, accès, sélection, observations et règles déclarées
lib/engine/application.dart   navigation, interactions, cours, suivi, thème et présentation
lib/engine/assets.dart        lecture des assets JSON et JSON compressés
assets/designs/<id>/           design complet et autonome
```

Les trois interactions disponibles sont `choice`, `highlightChoice` et `gapChoice`. Les propositions conservent leur ordre écrit dans le design. Les enchaînements suivent des identifiants explicites. Les liens proposés après une erreur viennent exclusivement de `practiceSets`, avec les adresses et identifiants des questions cibles déclarés dans le design.

Les anciens générateurs, modèles linguistiques, catalogues Dart, écrans spécifiques et outils de génération ont été supprimés. Les contenus sources bibliques restent conservés dans leurs dossiers d’assets ; ils ne sont pas chargés par ces deux designs.

## Vérifier

```bash
flutter analyze
flutter test
# Valide la structure, tous les index et toutes les références de liens :
dart run tool/validate_design.dart assets/designs/grammaticon/game.json
# Vérifie en plus chaque question et chaque réponse stockées :
dart run tool/validate_design.dart assets/designs/grammaticon/game.json --all-questions
dart run tool/validate_design.dart assets/designs/compass/game.json --all-questions
```

Les grandes banques de Grammaticon sont des **JSON compressés et découpés**, pas des générateurs. Les exemples du second design sont des JSON ordinaires directement éditables. Le format, les règles de migration et les limites sont décrits dans [le contrat de design](doc/topic_agnostic_design.md).

Les sauvegardes sont séparées par identifiant de jeu. Grammaticon reprend l’ancien emplacement et migre les données avec les correspondances déclarées dans son manifeste ; une copie complète de la sauvegarde antérieure est conservée dans le nouveau document.
