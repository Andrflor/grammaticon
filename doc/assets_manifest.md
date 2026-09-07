# Manifeste des assets (provisoires)

Direction artistique : Rome stylisée 2,5D, couleurs franches (pourpre `#5A2A9C`, or `#E0B24A`, marbre `#F6EED9`, ciel `#6FC3FF`), personnages « chibi » aux grands volumes, contours bruns épais, gemmes brillantes. Textes et boutons restent dans Flutter.

Tous les fichiers ci-dessous sont **provisoires**, générés procéduralement par `tool/assets/generate_art.py`, `generate_forum_art.py` et `generate_theatrum_art.py` (SVG → PNG via rsvg-convert). Ils sont explicitement destinés à être remplacés par des illustrations finales respectant les mêmes dimensions, pivots et transparence. Licence : CC0 (produits dans ce dépôt). Aucun outil de génération d'images par IA n'était disponible pendant le développement.

| Fichier | Taille (px) | Transparence | Pivot / origine | Usage | Spécification de remplacement |
|---|---|---|---|---|---|
| `city_bg.png` | 1920×1080 | non | ancré bas-centre (`BoxFit.cover`) | fond de la ville | Vue 2,5D d'une ville romaine (mer/rivière à gauche, collines, place au centre, route). Laisser libres les zones d'ancrage des 4 bâtiments (voir `city_screen.dart`). |
| `bld_amphitheatrum.png` | 640×440 | oui | bas-centre | bâtiment cliquable | Colisée elliptique, arcades sur 3 niveaux, bannières. |
| `bld_forum.png` | 560×420 | oui | bas-centre | bâtiment (à venir) | Basilique à colonnes, statues, étal à auvent. |
| `bld_theatrum.png` | 560×420 | oui | bas-centre | bâtiment cliquable (remplace les thermes) | Théâtre romain : cavea semi-circulaire à gradins, scaenae frons à colonnes et fronton, bannière aux deux masques. |
| `bld_templum.png` | 520×440 | oui | bas-centre | bâtiment (à venir) | Temple à fronton, colonnes, braseros, aigle. |
| `arena_bg.png` | 1920×1080 | non | centre (`cover`) | fond de l'arène | Gradins avec foule, mur d'arcades, sable ; ligne de sol vers 83 % de la hauteur. |
| `hero_idle.png` `hero_attack.png` `hero_hurt.png` `hero_victory.png` `hero_defeat.png` | 420×540 | oui | bas-centre (pieds) | protagoniste | Garçon romain : couronne de laurier, tunique blanche à liseré pourpre, cape pourpre, glaive, bouclier rouge. Même cadrage et même ligne de pieds pour les 5 poses. |
| `enemy_statua.png` | 480×540 | oui | bas-centre | adversaire palier 1 | Statue de marbre animée aux yeux cyan. |
| `enemy_gladiator.png` | 480×540 | oui | bas-centre | adversaire | Gladiateur thrace (casque à grille, trident, bouclier). |
| `enemy_leo.png` | 520×520 | oui | bas-centre | adversaire | Lion stylisé. |
| `enemy_sphinx.png` | 500×540 | oui | bas-centre | adversaire | Sphinx à némès. |
| `enemy_cyclops.png` | 500×560 | oui | bas-centre | adversaire | Cyclope à massue. |
| `enemy_hydra.png` | 560×560 | oui | bas-centre | adversaire final | Hydre à quatre têtes. |
| `forum_bg.png` | 1920×1080 | non | centre (`cover`) | fond du Forum | Colonnade de basilique, public sur les marches, deux rostres ; ligne de sol vers 86 % de la hauteur ; la zone sous la carte de question (≈ 40–45 % de la hauteur) reste sobre car la ligne *RECTE!/ERRAT…* s'y affiche. Généré par `tool/assets/generate_forum_art.py`. |
| `orator_idle.png` `orator_gesture.png` `orator_hurt.png` `orator_victory.png` `orator_defeat.png` | 420×540 | oui | bas-centre (pieds) | protagoniste du Forum | Même garçon romain en toge à bande pourpre, rouleau en main, laurier ; pose `gesture` = bras tendu, bouche ouverte. Même cadrage que `hero_*`. |
| `rhetor_rhetor.png` `rhetor_senator.png` `rhetor_causidicus.png` `rhetor_philosophus.png` `rhetor_censor.png` | 480×540 | oui | bas-centre | orateurs adverses | Rhéteur grec (chiton bleu, rouleau), sénateur âgé (toge, bâton), avocat rusé (manteau vert, tablette), philosophe stoïcien (chauve, barbe, bâton), censeur (toge pourpre, faisceaux). |
| `argumentum.png` | 128×128 | oui | centre | projectile d'argument | Rouleau de parchemin doré, animé en arc vers l'adversaire. |
| `theatrum_bg.png` | 1920×1080 | non | centre (`cover`) | fond du Theatrum | Scène de théâtre romain vue de l'orchestra : scaenae frons à deux étages, trois portes à rideaux, plancher de scène (ligne de sol vers 86 % de la hauteur), cavea avec public de part et d'autre (applaudissements vers 62 %), bande calme vers 40–45 % pour la ligne *RECTE!/ERRAT…*. Généré par `tool/assets/generate_theatrum_art.py`. |
| `histrio_idle.png` `histrio_gesture.png` `histrio_hurt.png` `histrio_victory.png` `histrio_defeat.png` | 420×540 | oui | bas-centre (pieds) | protagoniste du Theatrum | Même garçon romain en tunique safran à bandes pourpres, masque comique à la main ; `gesture` = déclamation, `victory` = révérence masque levé, `defeat` = assis, masque au sol. Même cadrage que `hero_*` / `orator_*`. |
| `actor_comoedus.png` `actor_tragoedus.png` `actor_mimus.png` `actor_pantomimus.png` `actor_chorus.png` `actor_dominus.png` | 480×540 | oui | bas-centre | acteurs adverses | Comédien masqué, tragédien à cothurnes et onkos, mime en centon, pantomime voilé, chef de chœur à la lyre, dominus gregis (maître de troupe). Regard tourné vers la gauche. |
| `persona.png` | 128×128 | oui | centre | projectile de réplique | Masque de théâtre doré, animé en arc vers l'adversaire. |
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
Synthétisés par SoX (`recte`, `errat`, `impetus`, `ictus`, `gemma`, `numerus`, `victoria`, `clades`, `tactus`, `emptio`, `vulnus`), 44,1 kHz mono, 30 ms–1 s. Forum (`tool/assets/generate_sfx.sh`) : `oratio` (envol de l'argument), `plausus` (applaudissements), `refutatio` (réfutation), `murmur` (murmure du public). Theatrum (`tool/assets/generate_theatrum_sfx.sh`) : `tibia` (trait de flûte, la réplique part), `sibilus` (sifflets de la cavea) ; `plausus` et `refutatio` sont réutilisés. Menus et navigation (`tool/assets/generate_menu_sfx.sh`) : `tactus` joué par défaut par tout `RomanButton` (menus, entrée dans un bâtiment, retour), `tuba` (fanfare au début d'une épreuve, bouton ou clavier), `folium` (ouverture d'une feuille d'aide ou d'une fiche), `vetitum` (action refusée : bâtiment à venir, bouton verrouillé). À remplacer par des sons produits, en conservant les noms.

## Chorégraphie du Theatrum
Même chaîne (`lib/game/theatrum_game.dart`) : bonne réponse = pas en avant + pose `gesture`, masque `persona` en arc, flash et recul de l'acteur adverse, étincelles, applaudissements montant des deux côtés de la cavea ; erreur = anneau pourpre de réplique vers l'acteur, flash rouge, pose `hurt`, sifflets (particules descendantes) ; victoire = révérence (double inclinaison) sous une pluie de lauriers, l'adversaire s'efface ; défaite = l'acteur adverse s'avance, salue et reçoit les applaudissements.

## Chorégraphie du Forum
Même chaîne que l'arène (sprites fixes + effets Flame, `lib/game/forum_game.dart`) : bonne réponse = pas en avant + pose `gesture`, rouleau `argumentum` en arc (Bézier), flash et recul de l'adversaire, étincelles dorées, applaudissements (particules montantes depuis les marches) ; erreur = anneau rouge de réfutation vers l'orateur, flash rouge, pose `hurt`, murmure (particules grises descendantes) ; victoire = pluie de lauriers ; défaite = murmure lourd. Effets brefs (< 0,7 s) pour préserver la lisibilité de la question.
