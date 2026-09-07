# Grammaticon

Lūdus Latīnus — un jeu d'apprentissage de la conjugaison, de la déclinaison et de la lecture latines dans une ville romaine.
Flutter · Riverpod (déclarations manuelles) · Flutter Hooks · Flame. **Aucun `build_runner`**, aucun code généré, aucun réseau à l'exécution.

Toute l'interface est en latin. Le français n'apparaît que dans le contenu des exercices de traduction du Theātrum (rendus, distracteurs, gloses de l'Auxilium) et dans ce dépôt (documentation).

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
python3 tool/assets/generate_theatrum_art.py         # régénère les visuels du Theatrum
bash tool/assets/generate_sfx.sh                     # régénère les sons du Forum (SoX)
bash tool/assets/generate_theatrum_sfx.sh            # régénère les sons du Theatrum (SoX)
bash tool/assets/generate_menu_sfx.sh                # régénère les sons des menus et de la navigation (SoX)
python3 tool/corpus/bible/corpus.py align            # alignement Clémentine ↔ Segond (livres, psaumes, versets)
python3 tool/corpus/bible/corpus.py inventory        # inventaire des formes latines du corpus
python3 tool/corpus/bible/corpus.py show MAT 5:8     # affiche un verset dans les deux textes
python3 tool/corpus/bible/lemmatize.py               # lemmatise le corpus (lexiques Collatinus) → inventaire du vocabulaire
python3 tool/theatrum/vocab.py coverage|check|queue  # couverture du vocabulaire, seuil d'acceptation, file de versets à rédiger
python3 tool/theatrum/build_content.py [--only F]    # valide et construit le contenu du Theatrum (items_fr.py + items_fr/*.py) + rapport
```

## Boucle de jeu

Ville → **Amphitheātrum** (conjugaisons), **Forum** (déclinaisons) ou **Theātrum** (lecture latin → français) → choix d'une épreuve (certāmen / contrōversia / fābula) → rencontre → résultats → achat d'un palier avec les gemmes → sauvegarde.

Les trois activités partagent le même moteur de rencontre, le même porte-monnaie de gemmes, les mêmes règles de maîtrise et la même sauvegarde ; seuls changent les données linguistiques, les épreuves, les libellés latins et la mise en scène.

* Réponse par souris, toucher ou touches **1–9** ; Échap met en pause ; Espace/Entrée passe la correction.
* Bonne réponse : attaque, impact, *Recte!*, gemmes qui volent vers le compteur, question suivante après ~350 ms (réglable).
* Erreur : riposte, perte d'un cœur, pénalité, explication contrastive qui reste affichée jusqu'à *Perge* (ou Espace/Entrée) ; *Explicā plūs* ouvre l'aide (tableaux, décomposition, forme voisine).
* Défaite : les gemmes gagnées pendant le combat sont perdues et un tribut d'un quart du solde (plafonné à 40) est payé ; achats et maîtrise sont conservés. Le coût est annoncé avant chaque combat.
* **Exercitātiō** : même contenu sans gemmes ni cœurs ; les réponses aidées ou corrigées sont comptées à part.
* **Progression des questions** : dans les épreuves de conjugaison, la personne et le nombre sont d'abord demandés séparément ; au niveau *Familiāris* la question combinée « Quae persōna et quī numerus ? » (la case du paradigme, quatre choix voisins) s'y ajoute, et au niveau *Perīta* elle remplace les deux questions séparées. Même schéma au Forum avec l'analyse complète (cas et nombre) à partir de *Familiāris*.
* **Tirage pondéré par la maîtrise** : au sein d'une épreuve, les formes dont la compétence est inconnue sont tirées deux fois plus souvent que celles d'une compétence maîtrisée, les compétences faibles jusqu'à trois fois, et une compétence dont la révision est due une fois et demie de plus (`selectionWeight`). Au Forum la compétence est la case (`d.1.abl.pl`) ; à l'Amphitheātrum, dans les épreuves mixtes, le temps de la forme. Rien n'est jamais exclu : le contenu maîtrisé continue d'apparaître.
* **Errāta (analyse des erreurs et rappel)** : chaque mauvaise réponse sur une forme isolée est retenue telle quelle (`ErrorLedger`, `lib/pedagogy/errata.dart`) : la forme (*amātis*), sa case du paradigme (2 pl du présent actif), ce qu'elle a été prise pour (*Secunda singulāris*) et le combat où l'erreur a eu lieu. Le combat où l'erreur est faite ne la rappelle **pas** ; dans les combats suivants, la forme ratée est tirée quatre fois plus souvent et les autres formes de la même case deux fois et demie (`Recall`). Deux réponses justes sans aide sur la forme retirent l'erreur ; une réponse aidée ne compte pas. La Tabula affiche l'analyse (panneau *Errāta* : formes par case, confusion habituelle, nombre d'erreurs, erreurs corrigées) et l'écran de résultat le nombre d'errāta encore ouverts pour l'épreuve. Le registre est borné à 150 formes.
* **Forum** : duel oratoire contre un orateur romain. Une forme déclinée apparaît ; le joueur en donne le cas, le nombre, la déclinaison (épreuves mixtes) ou l'analyse complète. Bonne réponse : geste, rouleau d'argument, adversaire qui recule, applaudissements ; la *cōnstantia* de l'adversaire baisse. Erreur : réfutation, murmure du public, cœur perdu. Toutes les analyses valides d'une forme sont acceptées (*rosae* : gén. sg., dat. sg., nom. pl., voc. pl.) ; aucune question n'est posée si toutes les réponses proposées seraient justes ; l'entrée de dictionnaire (*rosa, rosae, f.*) est affichée dans les épreuves d'introduction, et dans « Quae dēclīnātiō ? » seulement quand la désinence seule est ambiguë.
* **Theātrum** : représentation théâtrale contre un acteur adverse. Un passage exact de la Vulgate Clémentine est affiché avec sa référence ; quatre rendus français sont proposés : un rendu fidèle (extrait exact de Louis Segond 1910, ou rendu pédagogique identifié quand Segond ne rend pas la forme latine) et trois rendus qui commettent chacun **une** erreur d'interprétation morphologique contrôlée (singulier lu pluriel, 3e personne lue 1re, parfait lu présent, actif lu passif, sujet et objet inversés par méprise de cas, accord ou participe mal rattaché…). Les épreuves suivent la progression morphologique de l'Amphitheātrum et du Forum (nombre → personne → cas → temps → modes → voix → accord → formes nominales → mélanges), jamais des thèmes bibliques. Bonne réponse : réplique déclamée, masque qui vole, l'adversaire recule, la cavea applaudit ; erreur : réplique adverse, sifflets, cœur perdu, correction qui nomme la forme mal lue, les deux analyses et le changement de sens. Victoire : révérence sous les lauriers ; défaite : l'acteur adverse salue. L'Auxilium donne le vocabulaire (lemme et sens) et un conseil grammatical avant la réponse, l'analyse complète et le verset entier après. **Acquisition du vocabulaire de la Vulgate** : chaque mot des passages est lemmatisé et glosé (lexiques Collatinus, voir `THIRD_PARTY_NOTICES.md`) ; les lemmes sont rangés en bandes de fréquence (gradūs I–V) et chaque question porte la bande de son mot le plus rare. Le joueur ne reçoit que les questions de son *gradus vocābulōrum* ; le gradus suivant s'ouvre quand 60 % des mots du gradus courant sont *nōta* (vus dans deux passages ou interrogés avec succès). La Tabula affiche par gradus les mots *obvia / nōta / firma* et le gradus atteint, à part de la maîtrise grammaticale. La sélection favorise en outre les passages et les mots jamais ou peu rencontrés. Objectif de contenu : ≥ 90 % des entrées de vocabulaire du corpus enseignées (`python3 tool/theatrum/vocab.py check`, `test/content/vocabulary_acceptance_test.dart`) ; état courant dans `doc/theatrum_coverage.md`. Langue des rendus : **Gallicē** (disponible) ; **Anglicē** préparé mais non sélectionnable tant que son contenu n'existe pas — rien n'est jamais affiché dans une autre langue que celle choisie. Sources, alignement des éditions et couverture : `doc/theatrum_sources.md`, `doc/theatrum_coverage.md`.
* **Tabula** : maîtrise estimée par compétence, alimentée par les réponses réelles (nombre, diversité des verbes, réussite récente au premier essai, dernière pratique, révision due, fiabilité). Branche **Dēclīnātiōnēs** : déclinaison → cas → nombre, locatif, épreuves mixtes. Branche **Lēctiō · Theātrum** : verbe en phrase (nombre, personne, temps, mode, voix), nom en phrase (cas, accord), formes nominales, mélanges — distincte des arbres de reconnaissance des formes.
* Sauvegarde après chaque réponse et chaque achat (`shared_preferences`, schéma versionné — v3 : registre d'exposition au vocabulaire et langue des rendus —, migrations, export/import par le presse-papiers). Un combat interrompu se reprend depuis la ville.

## Architecture

```
lib/linguistics   moteur : grammaire (enums), analyses, lexiques vérifiés (verbes, noms), conjugueur, déclineur, index d'analyse, aides
lib/pedagogy      compétences, modèle d'épreuve partagé (trial.dart), catalogues (trials.dart verbes, noun_trials.dart noms,
                  reading/reading_trials.dart lecture), contrat de question partagé (question.dart), générateurs (verbes, noms),
                  source de lecture (reading/: contenu curé, sélection orientée couverture), exposition au vocabulaire (exposure.dart),
                  maîtrise, progression, explications
lib/economy       barème gemmes (centralisé), transaction unique par réponse
lib/battle        résolution déterministe d'une réponse + contrôleur de rencontre neutre vis-à-vis de l'activité (Riverpod Notifier)
lib/persistence   schéma de sauvegarde versionné (v2), migrations, dépôt
lib/app           providers Riverpod, thème, bootstrap
lib/game          scènes Flame : contrat EncounterScene, arène (ArenaGame), forum (ForumGame), théâtre (TheatrumGame) — ne décident rien, représentent
lib/ui            ville, sélection d'épreuves partagée (TrialSelectionScreen), écran de rencontre partagé (BattleScreen),
                  configuration par activité (ActivityConfig : libellés latins, adversaires, scène, aide, sons), Tabula, réglages, aides
tool/             outils de développement (export, vérification Collatinus, corpus biblique, construction du contenu du Theatrum, visuels, sons)
assets/corpus     textes sources complets (Vulgate Clémentine, Louis Segond 1910) · assets/theatrum : contenu curé (latin / français)
doc/              matrice de couverture, vérifications, manifeste des assets, sources et couverture du Theatrum
```

Une réponse est résolue une seule fois par `AnswerResolver` (pur), persistée immédiatement par `ProfileController`, puis seulement animée. Les animations ne conditionnent jamais l'enregistrement.

### Partage entre Amphitheātrum, Forum et Theātrum

Partagé : transitions de la rencontre (`BattleController`, `BattleState`), contrat de question (`Question`, `correctValues` multi-valeurs, `QuestionSource`), résolution et transaction unique (`AnswerResolver`), barres de ressource et résultats, gemmes volantes, sélection/prérequis/achats (`Progression`, `TrialSelectionScreen`), maîtrise (`SkillRecord`, `MasterySummary`), persistance et pause. Spécifique à chaque activité : données linguistiques et génération (`QuestionGenerator` / `NounQuestionGenerator` / `ReadingQuestionSource`), taxonomie de compétences et catalogue d'épreuves, libellés latins, scène, gestes et sons (`ActivityConfig`, dont `longText` pour la mise en page des phrases). Le contrôleur ne connaît pas l'activité : il interroge la `QuestionSource` de l'activité de l'épreuve. Le Theatrum n'ajoute ni équipement, ni monnaie, ni système de jeu : un rendu choisi produit exactement une résolution et une transaction (`AnswerResolver`), qui enregistre au passage le vocabulaire rencontré (`ExposureLedger`) sans jamais le compter comme maîtrise.

## Documentation

* `doc/coverage_matrix.md` — catégorie → données → génération/analyse → épreuve → test.
* `doc/theatrum_sources.md` — éditions embarquées, provenance, écart avec l'édition demandée, alignement Clémentine ↔ Segond.
* `doc/theatrum_coverage.md` — couverture du vocabulaire et de la morphologie du corpus par le contenu jouable, lacunes (généré par `build_content.py`).
* `doc/verification.md` — vérifications effectuées, plateformes testées, limites connues.
* `doc/assets_manifest.md` — assets provisoires, dimensions, pivots, spécifications de remplacement.
* `THIRD_PARTY_NOTICES.md` — sources et licences.
