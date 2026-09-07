# Theatrum — sources, provenance et alignement

## Éditions embarquées

| Langue | Fichier | Édition | Identifiants | Licence | Provenance |
|---|---|---|---|---|---|
| Latin | `assets/corpus/latVUC_vpl.txt` | **Biblia Sacra Vulgata Clementina (texte de 1598), édition Migne 1880** (« Clementine Vulgate of 1598 with Glossa Ordinaria, Migne edition 1880 ») | eBible.org `latVUC` (LATCLV), export « verse per line » du 2026‑08‑08 (fichiers sources du 2025‑12‑12) | domaine public | `tool/corpus/bible/provenance/latVUC_*.htm` (pages *about*, *copyright*, *details* copiées telles quelles) |
| Français | `assets/corpus/fraLSG_vpl.txt` | **La Sainte Bible, Louis Segond 1910** | eBible.org `fraLSG` (FRELSG), export du 2026‑08‑08 | domaine public (https://ebible.org/fraLSG/copyright.htm) | `tool/corpus/bible/provenance/fraLSG_*.htm` |

Empreintes SHA‑256 des fichiers importés :

```
41de172765e2209386d273d352695df54dc2ac85a8ce522fd807f52f6e3fc398  assets/corpus/latVUC_vpl.txt
c9a5ca9c81266fb4353767c619c79732c0530f709447d4903bc05485232de4cf  assets/corpus/fraLSG_vpl.txt
```

Les textes sont stockés **sans modification** (orthographe *æ*, *j*, ponctuation, marqueurs `[`/`]` de l'export). Seule la vue normalisée utilisée pour la comparaison retire les crochets et unifie les espaces ; la clé de comparaison des formes latines met en minuscules, développe *æ/œ* et rend *j* par *i*.

### L'édition demandée n'est pas celle embarquée — dit explicitement

Le cahier des charges demande la **« Vulgate Clémentine 1901 »**, c'est‑à‑dire l'impression Desclée (Tournai, Société de Saint‑Jean l'Évangéliste) de 1901, réimprimée aujourd'hui en fac‑similé. Aucune transcription numérique vérifiée de cette impression n'a été trouvée ; le texte le plus proche disponible avec métadonnées vérifiables est la Clémentine de 1598 dans l'édition Migne (1880), diffusée par eBible.org. C'est **la même recension** (édition vaticane de 1598), mais **pas la même impression** : l'orthographe et la ponctuation peuvent différer. Le jeu **n'étiquette jamais** son texte « 1901 » : le jeu de données (`assets/theatrum/passages_la.json` → `dataset.edition`) porte le titre réel, la source, la licence, le champ `requested` (« 1901 Clementine Vulgate (Desclée printing) ») et une note décrivant l'écart. Le test `reading_content_test` vérifie ces métadonnées.

## Alignement Clémentine ↔ Segond

Rapport machine : `python3 tool/corpus/bible/corpus.py align` → `tool/corpus/out/bible_alignment.json`.

* **Livres** : 73 dans la Clémentine, 66 dans Segond. Absents de Segond : Tobie, Judith, Sagesse, Siracide (Ecclésiastique), Baruch, 1 et 2 Maccabées ; chapitres absents : Esther 11–16, Daniel 13–14 (et Daniel 3 : 100 versets contre 30). Ces textes ne peuvent recevoir qu'un **rendu pédagogique identifié** ; aucun n'a encore été rédigé (voir `doc/theatrum_coverage.md`).
* **Psaumes** : numérotation des Septante dans la Clémentine, hébraïque dans Segond. Correspondance implémentée dans `corpus.psalm_to_lsg` : 1–8 identiques ; 9 → 9 (1–21) + 10 (22–39) ; 10–112 → +1 ; 113 → 114 (1–8) + 115 (9–26) ; 114 → 116:1–9 ; 115 → 116 (versets déjà numérotés 10–19) ; 116–145 → +1 ; 146 → 147:1–11 ; 147 → 147 (versets 12–20) ; 148–150 identiques. Les titres comptent pour verset 1 dans les deux éditions. Trois versets de la Clémentine n'ont pas de correspondant (Ps 2:13, 4:10, 10:8 : Segond compte un verset de moins).
* **Décalages de versets** ailleurs : 69 chapitres ont un nombre de versets différent (liste dans le rapport). Cas rencontrés dans le contenu : Matthieu 5:4–5 (béatitudes inversées), Jean 6 (Vulg. 6:69 = Segond 6:68), Ésaïe 9 (Vulg. 9:6 = Segond 9:5).
* **Règle du contenu** : chaque question porte **ses deux références** (`ref` latine ; `verseRef`/`ref` française). Un numéro identique n'est jamais tenu pour une garantie : le script de construction exige que le rendu « LSG » soit un **extrait exact** du verset Segond visé ; sinon l'auteur doit fournir un rendu **pédagogique** (`source: paed`), affiché comme tel dans l'Auxilium (« interpretātiō paedagōgica (nōn Segond) ») et jamais attribué à Segond. Les cas où Segond ne rend pas la forme latine (temps, nombre, personne, variante textuelle) sont notés dans le champ `note` de la question.

## Fichiers produits

* `assets/theatrum/passages_la.json` — côté latin : passages (référence, texte exact, verset entier, mots → lemmes), questions (épreuve, compétence, forme décisive, analyse latine, indice, note, statut, version), noms latins des livres, métadonnées d'édition.
* `assets/theatrum/renderings_fr.json` — côté français : pour chaque question, rendu(s) accepté(s) avec source (`LSG`/`paed`) et référence, trois distracteurs annotés (portion latine, analyse correcte, analyse simulée, changement de sens, compétence, compétence de forme, explication latine), verset Segond entier, gloses des lemmes. Identifiants de langue et d'édition en tête.
* `assets/theatrum/renderings_en.json` — **n'existe pas** : Anglicē est préparé (option visible, non sélectionnable) mais sans contenu.

Reconstruction : `python3 tool/corpus/bible/corpus.py inventory && python3 tool/theatrum/build_content.py` (les sources sont dans `tool/theatrum/items_fr.py`).

## Lexiques du vocabulaire (Collatinus) et licence

Le vocabulaire du corpus est résolu par `tool/corpus/bible/lemmatize.py` avec les lexiques Collatinus (`lemmes.la`, `lem_ext.la` : 81 928 lemmes ; `lemmes.fr`, `lem_ext.fr` : 81 653 sens français ; modèles de flexion, irréguliers, assimilations, contractions). Résultat sur le corpus : 46 388 formes distinctes, dont 41 5xx résolues, ~4 400 formes de noms propres (dont ~2 600 sans lemme dans les lexiques : elles restent des entrées à part entière, une par forme) et ~350 formes non résolues (mots grecs tardifs : *synagoga, hypocrita, gazophylacium, eleemosyna* ; composés numéraux : *quartadecima* ; lettres hébraïques des acrostiches). Toutes restent au dénominateur du rapport de couverture.

**Licence.** Les fichiers Collatinus sont sous GPL (v2 ou ultérieure ; dépôt sous GPL-3.0). Les données embarquées qui en dérivent (lemme, analyse, glose de chaque mot des passages jouables) sont distribuées sous GPL-3.0 avec attribution ; voir `THIRD_PARTY_NOTICES.md`. **Décision à prendre avant toute publication du jeu** : accepter que les assets du Theatrum soient GPL (et, selon l'interprétation retenue, l'application combinée), ou remplacer les gloses par une source sous licence permissive (aucune source latin→français prête à l'emploi n'a été identifiée ; Whitaker's Words et Lewis & Short sont en anglais).

**Ce qui n'est pas inventé.** Une analyse n'est enregistrée que si le lexique génère la forme avec cette analyse ; une forme de contraste (« *videbit* » pour un *videbunt* lu au singulier) n'est affichée que si le lexique la produit ; les explications latines sont rendues par des gabarits fixes à partir de ces traits validés ; le texte français de chaque choix est écrit par un auteur et vérifié mécaniquement (extrait exact de Segond ou rendu pédagogique déclaré ; modification minimale pour les distracteurs).
