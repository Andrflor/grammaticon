# Sources et licences

## Grammaire (référence des paradigmes)
Allen & Greenough, *New Latin Grammar for Schools and Colleges* (Ginn, 1903), édition numérique Dickinson College Commentaries, éd. Meagan Ayer — https://dcc.dickinson.edu/grammar/latin/ .
Le contenu DCC est réutilisable sous **Creative Commons Attribution-ShareAlike** (https://dcc.dickinson.edu/grammar/latin/credits-and-reuse). Le texte de 1903 est dans le domaine public.
Les tables de référence utilisées dans `test/linguistics/gold_paradigms_test.dart` et `test/linguistics/gold_nouns_test.dart`, ainsi que les sections citées dans les lexiques (`lib/linguistics/lexicon/verbs.dart`, `lib/linguistics/lexicon/nouns.dart`), proviennent de cette édition.

## Collatinus (outil de développement uniquement)
Collatinus, Yves Ouvrard & Philippe Verkerk, Biblissima — https://github.com/biblissima/collatinus — **GPL-3.0**.
Les fichiers `tool/corpus/collatinus_data/*` (lemmes.la, modeles.la, morphos.fr, irregs.la, assimilations.la, contractions.la) sont des copies des données Collatinus, conservées **hors de l'application** et utilisées seulement par `tool/corpus/verify_collatinus.py` et `tool/corpus/verify_collatinus_nouns.py` pour un contrôle croisé en développement. Aucune donnée Collatinus n'est embarquée dans les assets ni dans le code Dart livré ; l'application n'est donc pas une œuvre dérivée de Collatinus. Le dossier reste sous GPL-3.0 (voir `tool/corpus/collatinus_data/LICENSE`).

## Polices
* Cinzel (Natanael Gama) — SIL Open Font License 1.1 — `assets/fonts/OFL_Cinzel.txt`.
* Nunito (Vernon Adams et al.) — SIL Open Font License 1.1 — `assets/fonts/OFL_Nunito.txt`.

## Musique
`assets/audio/thema.mp3` : thème fourni par l'auteur du projet (génération Replicate, fichier `replicate-prediction-9k3t3d78qdrmr0d0ea29ej41q0.wav`, réencodé en MP3 128 kb/s). Droits et conditions de réutilisation : ceux de l'auteur du projet.

## Images et sons
Tous les visuels (`assets/images/*.png`, générés par `tool/assets/generate_art.py` et `tool/assets/generate_forum_art.py`) et sons (`assets/audio/*.wav`, synthétisés avec SoX, dont `tool/assets/generate_sfx.sh` pour le Forum) ont été produits dans ce dépôt et sont placés sous CC0. Ce sont des ressources provisoires (voir `doc/assets_manifest.md`).

## Paquets Dart
flutter_riverpod / hooks_riverpod / riverpod (MIT), flutter_hooks (MIT), flame (MIT), audioplayers (MIT), shared_preferences (BSD-3). Aucun paquet n'exige `build_runner`.
