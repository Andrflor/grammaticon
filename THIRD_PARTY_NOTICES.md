# Sources et licences

## Grammaire (référence des paradigmes)
Allen & Greenough, *New Latin Grammar for Schools and Colleges* (Ginn, 1903), édition numérique Dickinson College Commentaries, éd. Meagan Ayer — https://dcc.dickinson.edu/grammar/latin/ .
Le contenu DCC est réutilisable sous **Creative Commons Attribution-ShareAlike** (https://dcc.dickinson.edu/grammar/latin/credits-and-reuse). Le texte de 1903 est dans le domaine public.
Les tables de référence utilisées dans `test/linguistics/gold_paradigms_test.dart` et `test/linguistics/gold_nouns_test.dart`, ainsi que les sections citées dans les lexiques (`lib/linguistics/lexicon/verbs.dart`, `lib/linguistics/lexicon/nouns.dart`), proviennent de cette édition.

## Textes bibliques (Theatrum)
* **Biblia Sacra Vulgata Clementina** (texte de 1598), édition Migne 1880 — eBible.org, identifiant `latVUC`, domaine public. Fichier `assets/corpus/latVUC_vpl.txt`, pages de provenance dans `tool/corpus/bible/provenance/`. L'édition Desclée de 1901 demandée n'est pas disponible sous forme numérique vérifiée ; le jeu de données indique l'édition réellement utilisée (voir `doc/theatrum_sources.md`).
* **La Sainte Bible, Louis Segond 1910** — eBible.org, identifiant `fraLSG`, domaine public (https://ebible.org/fraLSG/copyright.htm). Fichier `assets/corpus/fraLSG_vpl.txt`.
* Les rendus français marqués `paed` dans `assets/theatrum/renderings_fr.json` ont été rédigés pour ce jeu (CC0, comme le reste du contenu produit ici) et ne sont jamais attribués à Louis Segond.

## Collatinus (lexiques : contrôle croisé et vocabulaire du Theatrum)
Collatinus, Yves Ouvrard & Philippe Verkerk, Biblissima — https://github.com/biblissima/collatinus — logiciel sous **GPL-3.0** ; chaque fichier de données porte un en-tête **GPL v2 ou ultérieure** (« This file is part of COLLATINUS … under the terms of the GNU General Public License … either version 2 of the License, or (at your option) any later version »).

Deux usages, distingués :

1. **Contrôle croisé en développement** (inchangé) : `tool/corpus/verify_collatinus.py`, `verify_collatinus_nouns.py` comparent les formes générées par les moteurs du jeu aux modèles Collatinus. Rien n'en est embarqué.
2. **Vocabulaire du Theatrum** : `tool/corpus/bible/lemmatize.py` réimplémente la flexion des modèles Collatinus (`modeles.la`, `morphos.fr`, `irregs.la`, `assimilations.la`, `contractions.la`) et applique les lexiques `lemmes.la`, `lem_ext.la` (lemmes, radicaux) et `lemmes.fr`, `lem_ext.fr` (sens français) à chaque forme du corpus clémentin. Le produit embarqué — pour chaque mot des passages jouables : lemme, analyse morphologique (rendue en latin par des gabarits) et glose française, dans `assets/theatrum/passages_la.json` et `assets/theatrum/renderings_fr.json` — est **dérivé de ces données GPL**. Ces deux fichiers de données sont donc distribués **sous GPL-3.0** avec la présente attribution ; leur « source » au sens de la licence est constituée des fichiers d'auteur `tool/theatrum/items_fr*.py`, du script `tool/theatrum/build_content.py` et des données Collatinus copiées dans `tool/corpus/collatinus_data/` (LICENSE inclus). Les gloses rédigées par les auteurs du jeu (marquées `authored`) et les rendus pédagogiques sont CC0 mais figurent dans le même fichier GPL. **Conséquence pour une distribution du jeu** : les assets du Theatrum sont sous GPL-3.0 ; le code Dart de l'application n'incorpore pas de code Collatinus. La question de savoir si l'application entière doit alors être distribuée sous GPL (œuvre combinée) ou s'il s'agit d'une simple agrégation n'est pas tranchée par ce dépôt : elle est signalée dans `doc/theatrum_sources.md` et doit être décidée avant toute publication. Alternatives examinées : Whitaker's Words (domaine public, anglais seulement), Lewis & Short via Perseus (CC BY-SA, anglais), Wiktionnaire (CC BY-SA, français, extraction lourde) — aucune ne fournit à la fois la flexion latine et le sens français prêts à l'emploi.

## Polices
* Cinzel (Natanael Gama) — SIL Open Font License 1.1 — `assets/fonts/OFL_Cinzel.txt`.
* Nunito (Vernon Adams et al.) — SIL Open Font License 1.1 — `assets/fonts/OFL_Nunito.txt`.

## Musique
`assets/audio/thema.mp3` : thème fourni par l'auteur du projet (génération Replicate, fichier `replicate-prediction-9k3t3d78qdrmr0d0ea29ej41q0.wav`, réencodé en MP3 128 kb/s). Droits et conditions de réutilisation : ceux de l'auteur du projet.

## Images et sons
Tous les visuels (`assets/images/*.png`, générés par `tool/assets/generate_art.py`, `tool/assets/generate_forum_art.py` et `tool/assets/generate_theatrum_art.py`) et sons (`assets/audio/*.wav`, synthétisés avec SoX, dont `tool/assets/generate_sfx.sh` pour le Forum et `tool/assets/generate_theatrum_sfx.sh` pour le Theatrum) ont été produits dans ce dépôt et sont placés sous CC0. Ce sont des ressources provisoires (voir `doc/assets_manifest.md`).

## Paquets Dart
flutter_riverpod / hooks_riverpod / riverpod (MIT), flutter_hooks (MIT), flame (MIT), audioplayers (MIT), shared_preferences (BSD-3). Aucun paquet n'exige `build_runner`.
