# Sources et licences

## Grammaire (référence des paradigmes)
Allen & Greenough, *New Latin Grammar for Schools and Colleges* (Ginn, 1903), édition numérique Dickinson College Commentaries, éd. Meagan Ayer — https://dcc.dickinson.edu/grammar/latin/ .
Le contenu DCC est réutilisable sous **Creative Commons Attribution-ShareAlike** (https://dcc.dickinson.edu/grammar/latin/credits-and-reuse). Le texte de 1903 est dans le domaine public.
Les tables de référence utilisées dans `test/linguistics/gold_paradigms_test.dart` et `test/linguistics/gold_nouns_test.dart`, ainsi que les sections citées dans les lexiques (`lib/linguistics/lexicon/verbs.dart`, `lib/linguistics/lexicon/nouns.dart`), proviennent de cette édition.

## Textes bibliques (Theatrum)
* **Biblia Sacra Vulgata Clementina** (texte de 1598), édition Migne 1880 — eBible.org, identifiant `latVUC`, domaine public. Fichier `assets/corpus/latVUC_vpl.txt`, pages de provenance dans `tool/corpus/bible/provenance/`. L'édition Desclée de 1901 demandée n'est pas disponible sous forme numérique vérifiée ; le jeu de données indique l'édition réellement utilisée (voir `doc/theatrum_sources.md`).
* **La Sainte Bible, Louis Segond 1910** — eBible.org, identifiant `fraLSG`, domaine public (https://ebible.org/fraLSG/copyright.htm). Fichier `assets/corpus/fraLSG_vpl.txt`.
* Les rendus français marqués `paed` dans `assets/theatrum/renderings_fr.json` ont été rédigés pour ce jeu (CC0, comme le reste du contenu produit ici) et ne sont jamais attribués à Louis Segond.

## Collatinus (outil de développement uniquement)
Collatinus, Yves Ouvrard & Philippe Verkerk, Biblissima — https://github.com/biblissima/collatinus — **GPL-3.0**.
Les fichiers `tool/corpus/collatinus_data/*` (lemmes.la, modeles.la, morphos.fr, irregs.la, assimilations.la, contractions.la) sont des copies des données Collatinus, conservées **hors de l'application** et utilisées seulement par `tool/corpus/verify_collatinus.py` et `tool/corpus/verify_collatinus_nouns.py` pour un contrôle croisé en développement. Aucune donnée Collatinus n'est embarquée dans les assets ni dans le code Dart livré ; l'application n'est donc pas une œuvre dérivée de Collatinus. Le dossier reste sous GPL-3.0 (voir `tool/corpus/collatinus_data/LICENSE`).

## Polices
* Cinzel (Natanael Gama) — SIL Open Font License 1.1 — `assets/fonts/OFL_Cinzel.txt`.
* Nunito (Vernon Adams et al.) — SIL Open Font License 1.1 — `assets/fonts/OFL_Nunito.txt`.

## Musique
`assets/audio/thema.mp3` : thème fourni par l'auteur du projet (génération Replicate, fichier `replicate-prediction-9k3t3d78qdrmr0d0ea29ej41q0.wav`, réencodé en MP3 128 kb/s). Droits et conditions de réutilisation : ceux de l'auteur du projet.

## Images et sons
Tous les visuels (`assets/images/*.png`, générés par `tool/assets/generate_art.py`, `tool/assets/generate_forum_art.py` et `tool/assets/generate_theatrum_art.py`) et sons (`assets/audio/*.wav`, synthétisés avec SoX, dont `tool/assets/generate_sfx.sh` pour le Forum et `tool/assets/generate_theatrum_sfx.sh` pour le Theatrum) ont été produits dans ce dépôt et sont placés sous CC0. Ce sont des ressources provisoires (voir `doc/assets_manifest.md`).

## Paquets Dart
flutter_riverpod / hooks_riverpod / riverpod (MIT), flutter_hooks (MIT), flame (MIT), audioplayers (MIT), shared_preferences (BSD-3). Aucun paquet n'exige `build_runner`.
