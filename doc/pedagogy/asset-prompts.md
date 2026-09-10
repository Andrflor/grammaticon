# Nouveaux assets du Templum

Outil utilisé : ImageGen intégré, avec les assets du jeu comme références visuelles. Aucun ancien visuel n’a été remplacé.

- `assets/images/temple_bg.png` : intérieur de temple romain en dessin de jeu cartoon, colonnes ivoire, pourpre et or, deux emplacements de combat aux positions de la scène du Forum, sans personnages ni interface. Référence : `assets/images/forum_bg.png`.
- `assets/images/priest.png` : prêtre romain souriant, tête couverte par sa toge ivoire et pourpre, parchemin et geste de la main, personnage entier sur fond transparent, proportions cartoon du jeu. Référence : le rhéteur existant.

Les deux images ont été inspectées avant intégration et sont référencées par le registre `assets.json`. Le temple utilise le même gameplay à projectiles que le Forum ; son décor et son adversaire sont sélectionnés par le design.

## Tenue et adversaires du parcours thématique

ImageGen intégré, références : `orator_idle.png`, `priest.png`, puis `temple_hero_idle.png` pour ses poses.

- `temple_hero_idle.png` : conserver le jeune héros, sa tête et ses proportions ; tenue d’assistant du temple romain, tunique ivoire à larges bordures bleu-vert et or, laurier, sandales et petit rouleau, fond transparent.
- `temple_hero_gesture.png` : même personnage et tenue, geste assuré vers l’adversaire.
- `temple_hero_hurt.png` : même personnage et tenue, recul défensif après une erreur, aucune blessure.
- `temple_hero_victory.png` : même personnage et tenue, rouleau levé et pose de victoire joyeuse.
- `temple_hero_defeat.png` : même personnage et tenue, épaules et rouleau abaissés, déception sans blessure.
- `temple_priest_augur.png` : rival romain âgé, cheveux et barbe blancs, toge ivoire bordée de bleu-vert et d’or, bâton augural courbe ; personnage entier, fond transparent.
- `temple_priest_flamen.png` : rival romain sans barbe, bonnet apex rouge, tenue ivoire bordée de rouge et d’or, rouleau et main gestuelle ; personnage entier, fond transparent.

Tous les sprites sont copiés dans `assets/images/` et enregistrés dans le registre du design. Aucun visuel d’origine n’est remplacé.
