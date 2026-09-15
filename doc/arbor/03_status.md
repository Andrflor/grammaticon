# État du chantier (15 septembre 2026)

## Ce qui est en place

- **Code typé restauré** depuis le commit `9bc4ad13` (linguistique, pédagogie, combat, sauvegarde, UI Riverpod). Le moteur « design JSON » du 10 septembre est déplacé dans `reference/pivot/`, non compilé, non embarqué.
- **Arbre des compétences** `lib/arbor/` : 64 notions, 265 maillons authored (verbal, nominal, adjectifs, pronoms, numéraux), 223 nœuds de syntaxe, 41 de lecture, 732 lexèmes, 4 072 cases dérivées ; validation structurelle (références, prérequis acycliques, maillons reliés, sources A&G) dans `test/arbor/arbor_test.dart`.
- **Diagnostic calculé** (`diagnosis.dart`) : différence de maillons entre la forme correcte et la forme choisie ; analyse synthétique quand la case n'existe pas. Sur 6 827 questions générées, 0,5 % des distracteurs restent sans diagnostic (`diagnosis_test.dart`).
- **Évidence et remédiation** (`evidence.dart`, `needs.dart`) : enregistrements par maillon, hypothèses sur les prérequis directs d'un maillon raté, poids de sélection ; l'apprenant simulé qui rate dix fois -bā- voit sa part de questions sur -bā- passer de 23 % à 43 % (`evidence_test.dart`).
- **Oracle d'équivalence** (`oracle.dart`) sur un échantillon des patrons de référence : Amphitheatrum 97,8 %, Forum 99,9 %.
- **Theatrum et Templum** : 274 cartes, 996 cadres de phrases et 3 044 entrées de vocabulaire extraits des banques (`tool/reference/extract_frames.py`), embarqués dans `assets/arbor/frames/` (5 Mo), instanciés avec des tuples alignés ; une compétence par carte ; prérequis et prix de la référence ; diagnostic de niveau carte plus différence morphologique pour les choix latins d'un mot.
- **Sauvegarde** : l'ancienne sauvegarde du moteur JSON est convertie au premier lancement (solde, achats, leçons vues, statistiques, réglages, ancienne sauvegarde typée reprise), l'original gardé sous `grammaticon.save.pivot`.
- **Tabula** sur l'arbre (`lib/ui/tabula/arbor_panel.dart`).

## Ce qui reste

- Annoter les confusions précises des distracteurs de lecture (`confusedWith`) ; aujourd'hui le diagnostic des cadres est celui de la carte.
- Parcours complet de l'oracle (`dart run` sur 344 794 patrons) et rapport `doc/arbor/coverage/` ; puis retrait des banques `.gz` de la référence.
- Retirer l'ancienne taxonomie `lib/pedagogy/skills.dart` là où elle ne sert plus qu'à l'affichage.
- Revue de performance de l'UI restaurée (rapport du 14 septembre : rebuilds, Flame sous les overlays, PNG sans `cacheWidth`).
- README et `doc/topic_agnostic_design.md` à réécrire ; ce dernier décrit le moteur retiré.
