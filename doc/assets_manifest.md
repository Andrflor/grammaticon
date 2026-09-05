# Manifeste des assets (provisoires)

Direction artistique : Rome stylisée 2,5D, couleurs franches (pourpre `#5A2A9C`, or `#E0B24A`, marbre `#F6EED9`, ciel `#6FC3FF`), personnages « chibi » aux grands volumes, contours bruns épais, gemmes brillantes. Textes et boutons restent dans Flutter.

Tous les fichiers ci-dessous sont **provisoires**, générés procéduralement par `tool/assets/generate_art.py` (SVG → PNG via rsvg-convert). Ils sont explicitement destinés à être remplacés par des illustrations finales respectant les mêmes dimensions, pivots et transparence. Licence : CC0 (produits dans ce dépôt). Aucun outil de génération d'images par IA n'était disponible pendant le développement.

| Fichier | Taille (px) | Transparence | Pivot / origine | Usage | Spécification de remplacement |
|---|---|---|---|---|---|
| `city_bg.png` | 1920×1080 | non | ancré bas-centre (`BoxFit.cover`) | fond de la ville | Vue 2,5D d'une ville romaine (mer/rivière à gauche, collines, place au centre, route). Laisser libres les zones d'ancrage des 4 bâtiments (voir `city_screen.dart`). |
| `bld_amphitheatrum.png` | 640×440 | oui | bas-centre | bâtiment cliquable | Colisée elliptique, arcades sur 3 niveaux, bannières. |
| `bld_forum.png` | 560×420 | oui | bas-centre | bâtiment (à venir) | Basilique à colonnes, statues, étal à auvent. |
| `bld_thermae.png` | 560×400 | oui | bas-centre | bâtiment (à venir) | Thermes à dôme, arches, vapeur, eau. |
| `bld_templum.png` | 520×440 | oui | bas-centre | bâtiment (à venir) | Temple à fronton, colonnes, braseros, aigle. |
| `arena_bg.png` | 1920×1080 | non | centre (`cover`) | fond de l'arène | Gradins avec foule, mur d'arcades, sable ; ligne de sol vers 83 % de la hauteur. |
| `hero_idle.png` `hero_attack.png` `hero_hurt.png` `hero_victory.png` `hero_defeat.png` | 420×540 | oui | bas-centre (pieds) | protagoniste | Garçon romain : couronne de laurier, tunique blanche à liseré pourpre, cape pourpre, glaive, bouclier rouge. Même cadrage et même ligne de pieds pour les 5 poses. |
| `enemy_statua.png` | 480×540 | oui | bas-centre | adversaire palier 1 | Statue de marbre animée aux yeux cyan. |
| `enemy_gladiator.png` | 480×540 | oui | bas-centre | adversaire | Gladiateur thrace (casque à grille, trident, bouclier). |
| `enemy_leo.png` | 520×520 | oui | bas-centre | adversaire | Lion stylisé. |
| `enemy_sphinx.png` | 500×540 | oui | bas-centre | adversaire | Sphinx à némès. |
| `enemy_cyclops.png` | 500×560 | oui | bas-centre | adversaire | Cyclope à massue. |
| `enemy_hydra.png` | 560×560 | oui | bas-centre | adversaire final | Hydre à quatre têtes. |
| `gem.png` `gem_green.png` | 128×128 | oui | centre | monnaie, effets | Gemme facettée magenta / verte. |
| `heart.png` `heart_empty.png` | 96×96 | oui | centre | points de vie | Cœur plein / vide. |
| `impact.png` | 256×256 | oui | centre | impact d'attaque | Étoile d'impact jaune/blanche. |
| `laurel.png` | 128×128 | oui | centre | ornement de titres | Couronne de laurier or. |
| `tabula_icon.png` | 128×128 | oui | centre | icône | Tablette de cire. |

## Animation
Chaîne retenue : **sprites fixes + animation procédurale** (Flame) : respiration (échelle sinusoïdale), anticipation/attaque (`MoveByEffect` aller-retour), recul, flash de teinte, impact (`ScaleEffect` + fondu), particules (étincelles, confettis), gemmes en vol (Flutter, courbe de Bézier vers le compteur). Rive et Blender n'ont pas été utilisés (aucun fichier .riv ni modèle disponible) ; les poses supplémentaires (victoire, défaite, blessure) sont des sprites distincts.

Pour remplacer un personnage par une séquence ou un fichier Rive : conserver le pivot bas-centre et la hauteur relative (≈ 42 % de la hauteur de l'écran, bornée 140–520 px), exposer les états `idle`, `attack`, `hurt`, `victory`, `defeat`.

## Musique
`thema.mp3` (2 min 17, stéréo, 128 kb/s, 2,2 Mo) : thème du jeu fourni par l'auteur, joué en boucle dès le lancement, coupé quand l'application passe en arrière-plan ; interrupteur et volume dédiés dans les Optiōnēs.

## Sons (`assets/audio/`)
Synthétisés par SoX (`recte`, `errat`, `impetus`, `ictus`, `gemma`, `numerus`, `victoria`, `clades`, `tactus`, `emptio`, `vulnus`), 44,1 kHz mono, 30 ms–1 s. À remplacer par des sons produits, en conservant les noms.
