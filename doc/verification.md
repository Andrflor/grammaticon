# Parcours de phrases et bilan lexical commun — 10 septembre 2026

- 29 tests réussis : phrases complètes dans les activités principales, un bilan unique couvrant tous les lemmes de la section, déblocage après version et thème, absence de liens de révision ajoutés, une progression par carte et sauvegardes compatibles.
- Comparaisons graphiques d’origine et parcours Compass conservés.
- Catalogue validé : 4 lieux, 219 cartes et 890 981 questions ; les 427 questions de Theatrum/Templum sont intégralement vérifiées par les tests.
- Les comptes rendus ci-dessous concernent les versions antérieures.

---

# Correction du parcours thématique — 10 septembre 2026

- Suite complète : **31 tests réussis**, y compris une progression par carte, relations concept/lecture/version/thème/lexique, sauvegarde d’une carte retirée, icônes et sélection à 420 et 1500 pixels.
- Comparaisons graphiques d’origine conservées. Captures de sélection inspectées : cartes compactes et portraits présents.
- Catalogue courant : **238 cartes et 891 078 questions**, dont 67 cartes et 524 questions pour Theatrum/Templum. Les séries alphabétiques ont été retirées ; leur taille n’est pas une mesure de couverture pédagogique.
- Les rapports ci-dessous décrivent les états précédents.

---

# Vérification de l’intégration déclarative — 10 septembre 2026

- `flutter test --no-pub` : **29 tests réussis**, dont les comparaisons graphiques d’origine, les parcours Compass, les nouvelles scènes à 420 et 1500 pixels, les banques intégrées et les séquences avec sauvegarde. Après extraction de la validation des séquences pour les banques indexées, les cinq tests concernés ont été rejoués avec succès.
- `dart analyze lib test` : aucune anomalie.
- Validation Grammaticon : **4 lieux, 288 cartes et 892 268 questions** ; cours, ressources et destinations de révision résolus. Les 1 714 nouvelles questions sont chargées et validées intégralement par les tests. Les anciennes banques indexées utilisent la validation de leurs index et d’un échantillon matérialisé par carte.
- Temple et théâtre : captures des widgets inspectées aux deux tailles ; décor du temple et prêtre intégrés. Ce contrôle hors écran ne constitue pas une session utilisateur sur appareil.
- La validation technique ne certifie pas la couverture complète des livres ni la justesse de tous les distracteurs. Voir `pedagogy/README.md` pour les limites éditoriales.

---

# Historique de vérification avant le moteur déclaratif

Les commandes de génération et les classes citées ci-dessous décrivent des outils historiques supprimés ; elles ne sont plus des instructions valides pour le moteur actuel.

# Vérifications effectuées

## Automatisées (`flutter test`, 176 tests, tous verts)
* `test/pedagogy/reading_content_test.dart` (11) — contenu du Theatrum : métadonnées d'édition explicites (latVUC / Migne 1880, jamais « 1901 » ; fraLSG), 132 questions validées (extrait latin exact du verset, cible et portions des distracteurs présentes, trois distracteurs distincts et complets, typographie uniforme, rendu Segond exact ou pédagogique identifié, gloses pour tous les mots), alignement des distinctions avec le niveau de l'épreuve (transitif par prérequis), ≥ 10 questions par épreuve dont les mixtes, graphe acyclique et atteignable, questions bien formées (quatre rendus, référence latine, crédit des seules compétences `l.*`), ordre des choix déterministe par graine et position de la bonne réponse variable, acceptation de toute paraphrase listée comme correcte par l'`AnswerResolver`, correction nommant la portion mal lue, les deux analyses et le changement de sens, sélection orientée couverture (question négligée tirée > 1/3 du temps ; « rencontré », « rencontré ailleurs », « interrogé » distingués), langue indisponible → aucune question, chargement hors ligne des assets par `rootBundle` (contenu et textes sources complets).
* `test/battle/theatrum_encounter_test.dart` (9) — moteur partagé sur une fābula : favor populī qui baisse, transaction unique, crédit de `l.numerus` seul (jamais `v.*`/`d.*`), registre d'exposition (chaque lemme rencontré, cible interrogée, doublons ignorés), réplique adverse (cœur, pénalité, correction), Auxilium avant réponse = réponse aidée, porte-monnaie commun aux trois activités et compteurs distincts, achats permanents gatés par les seuls prérequis du Theatrum, reprise d'une fābula interrompue sur le même passage, épreuves mixtes limitées aux composants choisis, Anglicē sélectionné → aucune question ni repli sur le français, aller-retour de sauvegarde (exposition, langue) et migration schéma 2 → 3 (rien perdu, identifiant `thermae` migré).
* `test/widget_test.dart` (+4) — ville → Theātrum → fābula au clavier puis à la souris (passage, référence, quatre rendus longs, barre « favor populī », Auxilium sans le français du passage, réponse aidée +1, doublon ignoré, correction *Rēctum:*, *Explicā plūs* avec source du rendu) ; téléphone portrait avec correction affichée sans débordement ; Anglicē non sélectionnable et Theātrum sans contenu français quand l'anglais est choisi ; Tabula avec branche Lēctiō et panneau *Vocābula Theātrī*.
* `test/screens/screenshot_test.dart` (+3) — rendus hors écran : sélection du Theātrum, fābula sur bureau et sur téléphone.
* `test/linguistics/gold_nouns_test.dart` (30) — tables A&G des noms saisies indépendamment des règles : rosa, dea/fīlia, Rōma/Athēnae, servus, bellum, puer/ager/vir, fīlius, deus, castra, humus/Corinthus, rēx, corpus/nōmen/caput/iter, pater/canis/iuvenis, cīvis/hostis, monosyllabes en -ium, turris/nāvis/ignis, mare/animal/moenia, cīvitās/os, vīs/bōs/senex/Iuppiter, locatifs, manus, cornū, tribus/lacus/portus/senātus, domus, rēs/diēs, spēs/fidēs ; « no invented forms » (locatif seulement où déclaré, nombres, entrée de dictionnaire présente, neutres nom. = acc. = voc.) ; analyseur (rosae ×4, rosā/rosa, manus/manūs, vīs, Rōmae, taille du corpus ≥ 120 noms, ≥ 5 par déclinaison).
* `test/pedagogy/noun_question_generator_test.dart` (10) — pools non vides et questions bien formées pour les 13 épreuves du Forum (toujours un choix faux, drapeau d'ambiguïté cohérent) ; épreuve à une déclinaison sans question de déclinaison et limitée à ses cas ; toutes les analyses valides acceptées ; jamais de question de nombre où les deux nombres seraient justes ; locatif limité à son épreuve ; entrée de dictionnaire seulement si la désinence est partagée ; crédit des compétences en épreuve mixte ; questions d'analyse dès le niveau familiāris ; corrections (cas juste, cas choisi, forme de contraste, désinence) ; graphe des épreuves.
* `test/battle/forum_encounter_test.dart` (6) — moteur partagé sur un débat : baisse de la cōnstantia, transaction unique, crédit de la cellule, sauvegarde ; réfutation ; acceptation de toutes les analyses de *rosae* par l'`AnswerResolver` ; porte-monnaie commun aux deux activités et compteurs distincts ; achats du Forum ; reprise d'un débat interrompu.
* `test/persistence/save_test.dart` (+2) — migration schéma 1 → 2 (gemmes, achats, compétences, configuration Mixta, instantané, compteurs conservés ; compteurs par activité amorcés depuis les totaux), aller-retour des achats et compétences du Forum.
* `test/widget_test.dart` (+3) — ville → Forum → débat au clavier puis à la souris (entrée de dictionnaire, barre « cōnstantia », adversaire, RECTE!/ERRAT…, correction, porte-monnaie partagé) ; téléphone portrait (sélection et débat sans débordement) ; Tabula (branche Dēclīnātiōnēs, compétences non évaluées).
* `test/screens/screenshot_test.dart` (+4) — rendus hors écran : sélection du Forum, débat sur bureau et sur téléphone, combat de l'arène (graine fixée).
* `test/linguistics/gold_paradigms_test.dart` (41) — tables A&G saisies indépendamment des règles : amō complet (6 tests), moneō, regō, capiō, audiō, dō, impératifs irréguliers, déponents (sequor, hortor, vereor, patior, potior, morior, orior), semi-déponents, sum et composés, possum, eō et composés, ferō et composés, volō/nōlō/mālō, fīō/faciō, edō, défectifs, impersonnels ; « no invented combinations » (intransitifs, sans supin, scī, 2 pl impératif futur passif, infinitifs sans personne, parties principales) ; analyseur (ambiguïtés, macrons, taille de l'index).
* `test/pedagogy/question_generator_test.dart` (12) — pools non vides pour les 42 épreuves, ≥ 2 choix, réponse correcte présente, distracteur présent, pas de doublon ; dimensions exclues quand fixées ; Mixta ; variantes ; forme de contraste ; graphe des prérequis acyclique et atteignable.
* `test/pedagogy/mastery_test.dart` (7), `test/economy/economy_test.dart` (5), `test/persistence/save_test.dart` (5), `test/battle/battle_controller_test.dart` (9), `test/widget_test.dart` (4 : parcours ville → Amphitheātrum → combat au clavier ; portrait téléphone ; fiche d'aide pendant une question ; écran des réglages).
* `flutter analyze` : aucune remarque. `flutter build linux --debug` : construit (2026-09-06, après l'ajout du Theatrum).

## Theatrum — validation du contenu (développement)
`python3 tool/theatrum/build_content.py` refuse tout item dont le latin n'est pas un extrait exact du verset de la Clémentine, dont le rendu « LSG » n'est pas un extrait exact du verset Segond visé (sinon `paed=True` obligatoire, affiché comme tel), qui n'a pas exactement trois distracteurs distincts et entièrement annotés, dont un distracteur emploie une distinction non permise au niveau de l'épreuve, ou dont un mot latin n'a pas de lemme et de glose. État : 132 questions / 128 passages / 330 lemmes, 105 rendus Segond exacts, 27 rendus pédagogiques (Segond rend un autre temps, nombre, personne ou texte). La validité linguistique des distracteurs (une seule erreur morphologique défendable, sens changé, jamais une simple paraphrase) a été vérifiée à la rédaction, item par item, et documentée dans les champs `ok` / `wrong` / `shift` / `expl` ; elle n'est pas prouvable mécaniquement. Alignement des éditions : `python3 tool/corpus/bible/corpus.py align` (73 vs 66 livres, psaumes renumérotés, 69 chapitres à décalage, 3 versets de psaumes sans correspondant). Couverture : `doc/theatrum_coverage.md` (542 / 46 392 formes du corpus dans un passage jouable, 46 % des occurrences ; 39 607 formes non résolues inventoriées).

## Contrôle croisé Collatinus — noms (développement)
`python3 tool/corpus/verify_collatinus_nouns.py` réutilise les analyseurs de `verify_collatinus.py` pour les modèles nominaux (morphos 1–12) et compare aux formes exportées par `dart run tool/export_nouns.dart`. Dernier rapport : **1 593 formes concordantes**, 115 présentes seulement chez Grammaticon, 135 seulement chez Collatinus, aucun lemme absent. Écarts examinés : variantes A&G que Collatinus ne liste pas (fīlī/cōnsilī, deum, aetātium, turrem/turre, ignī, senātī, domū/domuum/domōs, arcium, vīs gén.) ; choix d'A&G divergents (deābus seul, boum/bōbus, ossium, lacubus, cornū dat.) ; restrictions volontaires (singulāria tantum : Rōma, humus, Carthāgō, rūs, fidēs, merīdiēs ; spēs/aciēs sans gén./dat./abl. pl.) ; artefacts Collatinus (homonymes *populus/pōplus*, *līber* adj., *labor* verbe, *prīnceps* adj., *cāsus* part., graphie *littus*, radical *itiner*). Le locatif n'est pas produit par Collatinus et est contrôlé par A&G §427.

## Contrôle croisé Collatinus — verbes (développement)
`python3 tool/corpus/verify_collatinus.py` réimplémente la flexion des modèles Collatinus (héritage `pere:`, radicaux `R:`, désinences, `abs:`, constantes, contractions, assimilations) et compare aux formes exportées. Dernier rapport : **19 688 formes simples concordantes**, 3 434 présentes seulement chez Grammaticon, 5 969 seulement chez Collatinus, 3 lemmes absents de Collatinus (avē, oportet, taedet). Les écarts ont été examinés et relèvent de :
* variantes que Collatinus ne liste pas (abl. -ī du participe présent, gérondif -undus, 2 sg passif -re au présent, *forem/fore*, *ausim*) ;
* restrictions volontaires de Grammaticon que Collatinus n'applique pas (passif impersonnel des intransitifs, semi-déponents sans passif présent ni parfait régulier, absences des impersonnels) ;
* choix de Collatinus divergents d'A&G (feritō/fereris pour ferō, fiendus pour fīō, iisti/iuisti pour eō, *amantum* gén. pl.) — la version A&G est conservée ;
* artefacts de données Collatinus (répétition de -minī sur l'impératif futur des déponents, exclus).
Les formes composées ne sont pas produites par Collatinus et sont contrôlées par les tables A&G.

## Manuelles
* Bureau **Linux (X11, 1280×720 et 1920×1080)** : build debug lancé ; ville, Amphitheātrum, combat (question, choix numérotés, *Recte!*, riposte, dialogue de sortie) rendus correctement ; sauvegarde écrite dans `~/.local/share/com.example.grammaticon/shared_preferences.json` après les réponses.
* **Theatrum** : non lancé sur le bureau réel dans cette session (build Linux construit ; parcours vérifiés en tests de widgets et rendus hors écran, voir les goldens `theatrum*.png`). Les sons `tibia`/`sibilus` n'ont pas été évalués à l'oreille.
* **Forum** (Linux, 1280×720, build debug, sauvegarde réelle de schéma 1 chargée) : ville avec le Forum ouvert et 20 gemmes conservées ; sélection (épreuve gratuite ouverte, *Emenda* à 20 gemmes, *Clausa* avec prérequis) ; introduction ; démarrage par Entrée ; question *viīs* (via, viae, f.) « Quī numerus ? » ; réponse fausse par la touche 1 : onde de réfutation, posture blessée, cœur perdu, −1 gemme, correction « Rēctum : Plūrālis… Dēsinentia -īs : plūrālis. Etiam : datīvus plūrālis » ; sauvegarde migrée en schéma 2 avec instantané `d1-recti` et compétence `d.1.abl.pl`. La sauvegarde d'origine a été restaurée à l'identique après l'essai. La réponse juste (geste, rouleau, applaudissements) n'a été vérifiée qu'en test de widget et en rendu hors écran, pas à l'écran réel.
* Sons : synthétisés et joués via audioplayers/GStreamer (non évalués à l'oreille en session).

## Plateformes
| Plateforme | État |
|---|---|
| Linux desktop | construit et exécuté |
| Android | APK debug compilé (`flutter build apk --debug`) ; non exécuté sur appareil/émulateur |
| Web (Chrome) | non testé |
| Windows, macOS, iOS | non testés |

## Limites connues et travail restant
* Assets visuels et sonores provisoires (voir `doc/assets_manifest.md`).
* Lexique de 113 lemmes : représentatif des familles, pas exhaustif ; l'ajout d'un verbe régulier se fait en une ligne dans `verbs.dart`.
* Gérondif des intransitifs limité au neutre singulier (emploi impersonnel) ; gén. pl. -um des participes présents non généré ; infinitif passif archaïque -ier exclu ; *coepiō* archaïque exclu — choix documentés dans le lexique.
* Le mode « analyse complète » (cartes à descripteur entier) n'apparaît qu'à partir du niveau *Familiāris* de la compétence principale.
* Forum : 145 noms ; adjectifs et pronoms non traités (extension prévue via `NounEntry`/`Declinator` et `QuestionPayload`) ; pas de phrases de contexte (seule l'entrée de dictionnaire est affichée) ; formes archaïques (honōs, arbōs) et graphies alternatives (littus) omises ; genre commun (cīvis, sacerdōs, bōs) noté sans être interrogé.
* Theatrum : 132 questions validées couvrent le noyau morphologique ; « tout le vocabulaire du corpus » n'est pas atteint (1,17 % des formes de surface, voir `doc/theatrum_coverage.md`) ; livres absents de Segond sans rendu pédagogique ; Anglicē sans contenu ; la mise en page à quatre phrases sur une ligne apparaît quand tous les rendus font ≤ 32 caractères.
* Templum : structure prête (Gallicē → Latīnē), contenu à venir.

## Active exhaustive-curriculum work — current checkpoint

Theatrum/Templum currently contain 4 learning groups, 25 sentence topics in both directions and 8 final lexical cards: 58 cards, 646 explicit questions. The complete design has 229 cards and 891,200 questions, mostly from the unchanged Amphitheatrum/Forum banks. These totals do **not** demonstrate exhaustive reading coverage.

The first topic tests `Italia / Italiā / Italiam` and has separately authored feedback for the case/quantity errors. Number and adjective agreement are split into six cards. Incorrect vocabulary choices no longer display `Rēctē`.

Validation of the current design passed. The 29-test Flutter suite passed after the card split, including the original visual comparisons and the macron acceptance test. The full pedagogical completion gate remains failed because inventories, coverage mappings and content review are unfinished. See `doc/pedagogy/contracts/completion.json`.

### Possession and question distinctions

Added paired sentence cards `Quis? Quid?`, `-ārum et -ōrum`, `Meus et tuus`, and `Suus et eius` to the personae learning group. The last uses explicit antecedent context and distinguishes French `son propre` from an explicitly named other owner. Vocabulary inventories and both terminal banks include the added words. Existing scene assets and runtime rendering are unchanged.

Current totals: 66 Theatrum/Templum cards, 706 questions; 237 cards and 891,260 explicit questions across Grammaticon. The existing eight targeted content/progression tests passed and the design validator resolved every new question, lesson and skill. Source-to-question mappings for the possessive constructions in Fabellae readings 2 and 4 are partial evidence only; the exhaustive completion gate remains open.

### Sermō et imperia

Added a fifth learning group with paired cards `Imperā!`, `Imperāte!`, `Ō amīce!`, `Eum et eam`, and `Eōs et eās`. Each direction ends with one lexical card containing all 26 encountered lemmas. Instructions and error feedback are authored in Latin. French plural commands explicitly address several people; pronoun questions give an antecedent in the preceding sentence. Error outcomes distinguish mood, number, case, gender and referent/role mistakes in JSON.

Current totals: 78 Theatrum/Templum cards and 798 explicit questions; 249 cards and 891,352 questions across Grammaticon. All 29 Flutter tests and the full design validator passed. No runtime or scene assets were changed for this group.

The lexical traceability report compares only Theatrum/Templum with the 1,899 publisher headword candidates. It found 180 surface matches and 1,719 candidates without a surface match. This is a gap-finding aid, not semantic coverage certification; neither homographs nor unmatched finite/infinitive aliases are resolved automatically. The exhaustive objective remains incomplete.

### Quaestiōnēs et responsa

Added paired sentence cards `-ne`, `Num?`, `Nōnne?`, and `Cūr? Quia…`, followed by lexical cards covering the group's 26 declared lexemes. Explicit question annotations are Latin; they distinguish speaker expectation from the truth of the answer. The lexical inventory includes the interrogative enclitic separately from the verb carrying it.

Current totals: 88 Theatrum/Templum cards, 882 questions; 259 cards and 891,436 questions across Grammaticon. The full 29-test suite and design validator passed. The expanded UI test additionally exercised both directions of the expectation questions at 420 and 1500 pixels, including answer selection. Rendered narrow-screen captures were inspected; question annotations and all choices are readable without changing the existing rendering code.

`python3 tool/audit_lexical_traceability.py` refreshes the source-to-question lexical evidence. `--check` rejects stale evidence; the full learning completion checker includes that check. Current surface comparison: 184 matches among 1,899 source candidates. These are provisional matches, not certified semantic coverage. Full completion still fails, as required while the source inventory and coverage remain incomplete.

### Agentēs et patientēs

Added paired cards `Quis patitur?`, `-tur et -ntur`, `Ā quō?`, and `Quō īnstrūmentō?`, each with six authored sentence questions. Incorrect answers distinguish voice, number, agent/patient roles, negation and instrumental case. Equivalent active paraphrases are not treated as incorrect answers to passive translations. Both final lexical banks contain the group's 37 encountered lemmas.

Current totals: 98 Theatrum/Templum cards and 1,004 questions; 269 cards and 891,558 questions across Grammaticon. All 29 Flutter tests and the full design validation passed. The scene assets and runtime rendering remain unchanged. The lexical traceability audit was refreshed, and new explicit partial mappings were added for Fabellae readings 7 and 12. Full coverage is still unverified.

Lexical checks consulted the Lewis and Short entries for [malleus](https://www.alatius.com/ls/index.php?l=malleum) and [forfex](https://www.alatius.com/ls/index.php?l=forfex). Closed-syllable quantity markers in morphological source tables are not copied automatically as vowel-length marks into the authored questions.

### Answer positions, purchases and Locī et itinera

Correct-answer positions previously repeated the same four-answer pattern across 56 sentence banks. Authored choice order is now balanced within each bank and varied between banks. Choice IDs, accepted IDs, texts and outcomes were preserved; a canonical comparison verified that only array order changed. The catalog checker now rejects unbalanced positions and excessive reuse of a common four-answer prefix. There is no runtime shuffling or generation.

A new test buys and completes each Theatrum/Templum card using actual session rewards, starting with the configured zero balance. Before the price correction it failed at `loca/masculine-agreement`: 29 gems available against a price of 50. Prices had grown by global card ordinal up to 220. Each group now has explicit JSON prices: sentence cards cost 15, 20 or 25 gems; final lexical cards cost 20, 25 or 30. Only each place's starting card is free. Existing prerequisites and the shared reward rules are preserved. Both complete current routes pass without replaying a card after all-correct answers. This tests a successful route, not the balance of every possible error history or future content.

Added paired cards `In: ubi an quō?`, `Rōmae et Tūsculī`, `Quō? Rōmam!` and `Unde? Rōmā!`, each with six original sentence questions. Directional errors have explicit Latin feedback and confusion IDs. Both final lexical banks contain all 22 encountered lemmas. Partial source mappings were added for Fabellae readings 7 and 8.

Current totals: eight groups, 46 sentence topics in both directions, 16 final lexical cards; 108 Theatrum/Templum cards and 1,096 explicit questions. The complete Grammaticon design has 279 cards and 891,650 questions. All 31 Flutter tests passed, including the existing visual reference comparisons. The full pedagogical completion gate remains failed: neither these technical checks nor the 202 provisional lexical surface matches certify exhaustive reading coverage.

The full design validator passed. The Linux Grammaticon build completed, and all 3,211 bundled design files were compared byte-for-byte with the workspace JSON/data files; no mismatch was found.

### Required lexical evidence for mastery

The shared four-item proficiency threshold could previously mark a 90-word lexical bank as mastered after a small subset of words. All 16 terminal lexical skills now explicitly declare their complete item sets through `masteryRequirements.successfulItems` in the design. The engine treats these as opaque identifiers, tracks the latest unassisted outcome for each, and requires successful evidence for every declared item before allowing the highest mastery level. Assisted responses do not establish success; subsequent unassisted errors remove it. Saved evidence survives beyond the recent-observation window. For old saves, only successes supported by retained recent history can be recovered.

The existing progress bar and acquisition overview use the lower of the normal estimate and successful required-item coverage. No scene, layout, asset or styling changed. Normal reward thresholds and item saturation are retained; the separate highest-mastery catch-up bonus still depends on actually reaching that mastery status. Cards without coverage requirements retain their prior display and mastery behavior.

All 34 Flutter tests passed, including saved-state compatibility, partial coverage, correct/incorrect/assisted outcomes, invalid requirement lists, real purchase routes and original pixel comparisons. Targeted Dart analysis found no issues. The complete design validator passed (279 cards, 891,650 questions), and the catalog audit checks that each terminal lexical requirement list exactly matches its bank. This correction guarantees a condition on recorded evidence, not exhaustive source coverage or linguistic quality; those completion gates remain open.

The Linux build completed after the mastery fix. All 3,211 bundled design files match the workspace; the build engine hash matches the current Dart sources.

### Reflexive reference and relative-clause roles

Added paired sentence cards `Sē, eum, eam` and `Quī agit? Quem vidēs?` to the personae group. Each has six original questions per direction. Reflexive questions provide a preceding context naming the other person and distinguish self-reference, reference to that person and added negation. Relative questions distinguish agent/patient inversion inside the relative clause from exchanging the antecedent/main-clause subject. Incorrect choices have separate authored Latin diagnostic feedback.

Both terminal lexical banks were rebuilt from the expanded section inventory (64 lemmas), and their required successful-item lists were updated. The new cards cost 20 gems, preserve the explicit purchase chain and reuse existing opponents and hero presentation. No runtime or graphical code changed for this content update. Source mappings for Fabellae readings 7 and 8 are partial evidence only.

The current design has 48 sentence topics in both directions plus 16 final lexical cards: 112 Theatrum/Templum cards and 1,152 questions. Whole Grammaticon: 283 cards and 891,706 questions. All 34 Flutter tests and the full design validator passed. The lexical surface comparison finds 207 of the 1,899 publisher headword candidates; those matches are not verified sense coverage.

Remaining content work includes replacing the older broad `Concordantia et relātiō` and other combined-topic banks with precise learning points, as well as the much larger source-inventory, vocabulary and reading-comprehension gaps. Added cards do not close those completion gates.

Linux build completed; all 3,223 bundled design files and the engine source hash match the workspace.

### Replaced the mixed adjective bank

The legacy `Concordantia et relātiō` bank mixed adjective reference, lexical contrasts, numerals and conjunctions, without actually testing relative clauses. It is now `Cui nōminī convenit?`, with six original sentences per direction on adjective attachment and number agreement. Each distractor either attaches the adjective to the subject instead of the object or changes the object to plural. Both errors have explicit Latin feedback.

The card address and purchase remain stable, but the replacement has distinct skill, item and assessment identifiers. Its mastery requires successful evidence for all six new items; old mixed-topic successes do not certify them. Existing save handling archives an interrupted encounter if it refers to the removed skill, without deleting balance or purchase history.

The personae lexical inventory was recalculated from the actual remaining sentences and Latin choices: 58 lemmas per direction. Words found only in removed questions are no longer falsely represented as encountered in this section. They remain uncovered source requirements wherever they have no other evidence; removing an irrelevant quiz does not waive the reading objective. Explicit partial mappings now link the adjective and relative-role cards to Fabellae reading 5.

Current totals: 112 Theatrum/Templum cards, 1,144 questions; complete Grammaticon 283 cards, 891,698 questions. All 34 Flutter tests passed. The full design validator and catalog/lexical-evidence audits passed after the final data edits. Graphical/runtime code was unchanged in this content replacement. Exhaustive source coverage and the remaining combined-topic banks still need work.

Linux build completed; all 3,223 bundled design files and the engine source hash match the workspace after this replacement.

### Separated tense contrasts

Replaced the mixed `Hodiē et herī` bank with a six-sentence bank contrasting present and future in the first two conjugations. A separate six-sentence card covers the third/fourth-conjugation future, including explicit `legit / lēgit / leget` distinctions. Replaced the old imperfect/perfect/pluperfect mixture with a six-sentence imperfect-versus-perfect card and a separate six-sentence pluperfect anteriority card. The latter uses a preceding past event to make the reference time explicit; distractors compare completed, ongoing and anterior events without combining incoherent future/past clauses.

Each direction uses authored complete sentences and Latin diagnostic feedback. The four banks have explicit complete-item mastery requirements. The two replaced subjects have new skill IDs so their former mixed-topic evidence cannot certify the replacements. Prices remain 25 gems and existing purchase-chain semantics are preserved. No runtime or graphical changes were made.

The tempora lexical banks now contain their actual union of 47 encountered lemmas. Words present only in the retired mixed questions are removed from this section's lexical claim, not from the source requirements. This is why the provisional publisher-headword surface match count can decrease during correction; it is not a completion score. The remaining `Ōrātiō oblīqua` card still mixes constructions and remains scheduled for separation.

Partial evidence was added for Fabellae readings 23, 24, 26 and 29. These third-person examples do not certify all persons, passive/deponent forms or all reading demands of those units. The principal parts and floral sense of `carpo` were checked against [Lewis and Short](https://alatius.com/ls/index.php?l=carpere); no source example was copied into the game.

Current totals: 116 Theatrum/Templum cards and 1,172 explicit questions; whole Grammaticon 287 cards and 891,726 questions. All 34 Flutter tests passed, including original visual references and real purchase routes. Exhaustive reading coverage remains unverified.

The complete design validator and Linux build passed. All 3,235 bundled design files and the engine source hash match the workspace.

### Verba relāta

Replaced the mixed reported-speech card with a separate group containing three paired sentence topics: accusative subject of an infinitive, anterior action with the perfect infinitive, and posterior action with the future active infinitive. Each bank contains six original questions. Subject-case errors, speaker/actor confusion, subject number and relative-time errors have distinct authored Latin feedback. The new cards use existing characters and graphical presentation.

Both terminal lexical banks contain the group's 27 encountered lemmas and explicitly require successful evidence for all of them. The remaining time section has its own recalculated 31-lemma bank. The old `tempora/06-reported` card, lesson and question files were removed; its mixed skill IDs and help entry were retired. Indirect questions, passive infinitives and other missing constructions remain open requirements, not implicitly covered by these three cards.

The forms `lēctūram esse` and `dormītūrum esse` were checked against the publisher's Familia Romana vocabulary, [Dickinson's Latin core vocabulary](https://dcc.dickinson.edu/latin-core-list1?order=field_frequency_rank&sort=desc), and [Lewis's entry for dormiō](https://www.perseus.tufts.edu/hopper/text?doc=Perseus%3Atext%3A1999.04.0060%3Aentry%3Ddormio). No source sentences were copied. Partial evidence maps the cards to Fabellae readings 13, 26 and 28; the examples do not certify all demands of those readings.

Current totals: nine groups, 52 topics in both directions and 18 terminal lexical cards; 122 Theatrum/Templum cards and 1,222 authored questions. Whole Grammaticon: 293 cards and 891,776 questions. The source-coverage completion gates remain open.

All 34 Flutter tests and the complete design validator passed. The Linux build completed; all 3,255 bundled design files and the engine source hash match the workspace, and the retired reported-speech card is absent from the bundle.

### Existing Forum/Amphitheatrum evidence

Added a read-only inventory of all 171 existing card indices (890,554 questions, 691 distinct opaque item IDs). It materializes one actual question per dimension per card: 516 samples. This is a complete index inventory and a bounded sample, not a semantic review of all questions. The audit does not generate or alter gameplay content.

Five inspected Forum questions now provide explicitly scoped partial evidence for possessive reference, distant adjective attachment, relative antecedents, town-name destination and static location with in. These analyses complement sentence translation; they do not replace it. For example, the dedicated future-tense Amphitheatrum card samples ask for conjugation, lemma and person rather than translating the future meaning. Its title alone is not proof that temporal interpretation has been tested.

The full completion checker now resolves cited original-bank questions against both index and payload. A SHA-256 fingerprint of the materialized question (including resolved text references, choices and outcomes) protects the editorial review against silent content changes. Known references passed. Missing banks, missing questions and deliberately mismatched fingerprints were rejected in isolated process checks. The existing-content report passed its freshness check, and the catalog gate passed. The exhaustive gate still fails on the open completion conditions and all 356 uncertified source units, as intended.

Only audit tooling and pedagogical evidence changed in this step; no app rebuild was needed.

### Third-declension roles in sentences

Added the group `Nōmina tertiae dēclīnātiōnis` with four paired six-question cards: nominative/accusative roles, genitive relationships, dative recipients, and ablative accompaniment/absence. Half of the subject/object sentences put the accusative first, preventing a simple first-noun-is-subject shortcut. Incorrect options distinguish role inversion, number, recipient case and accompaniment/destination errors. Rules about endings are scoped to the nouns actually taught; they do not claim that every third-declension noun has the same endings.

Each direction ends with a complete 30-lemma lexical bank. `Amīcus/amīca` is one lexical entry, not separate duplicate cards. The four sentence cards and lexical bank have explicit complete-item mastery requirements. Sentence cards cost 20 gems, the lexical card 25; the existing successful purchase routes remain viable. Existing actors, priests, hero outfits and scene layouts are reused.

Partial source mappings were added for third-declension roles in Fabellae reading 10, accompaniment in reading 5 and absence with sine in reading 6. The publisher vocabulary was consulted for the quantities of māter, frāter, soror, pāstor and pānis. No source sentences were copied, and the source units remain uncertified.

Current totals: ten groups, 56 topics in both directions and 20 terminal lexical cards; 132 Theatrum/Templum cards and 1,330 questions. Whole Grammaticon: 303 cards and 891,884 questions. All 34 Flutter tests passed, including real purchase routes and original visual references. The complete design validator and catalog/lexical-evidence checks passed. No runtime or graphical code changed for this content addition.

Linux build completed; all 3,287 bundled design files and the engine source hash match the workspace.

### Hic et ille

Added four paired sentence cards covering singular demonstrative gender/proximity, accusative objects, genitive reference and dative recipients. French translation material explicitly uses -ci/-là to distinguish the intended deictic reference. Each six-question bank has separately authored diagnostics for proximity, gender, number, case and attachment. The genitive feedback allows for grammatically valid alternatives that point to a different noun; it does not falsely label every distractor ungrammatical.

The section ends with 34-lemma banks in both directions, including the contextual price senses of magnus/parvus. All cards require successful evidence for their complete authored item sets. Existing scene assets and characters are reused. The publisher vocabulary confirms ōrnāmentum, ōrnāre and vēndere; the earlier reflexive examples were corrected consistently to ōrnat. This fixes vowel quantity rather than changing the assessed construction.

Partial mappings were added for demonstratives in Fabellae reading 9. They explicitly cover only the singular cases in these cards, not every plural/ablative form or the reading's other constructions. Current totals: eleven groups, 60 topics in both directions and 22 terminal lexical cards; 142 Theatrum/Templum cards and 1,446 questions. Whole Grammaticon: 313 cards and 892,000 questions.

All 34 Flutter tests passed, including purchase routes and original visual references. The catalog and lexical-evidence checks passed. No runtime or graphical code changed in this content addition; exhaustive reading coverage remains unfinished.

The complete design validator and Linux build passed. All 3,319 bundled design files and the engine source hash match the workspace.

### Familia Romana chapter II source audit

Inspected all six printed pages (13–18) of the public [chapter II excerpt](https://culturaclasica.com/lingualatina/textos/FamiliaRomanaCap2.pdf), including its grammar and exercises. Added a scoped draft inventory and eight partial translation-bank mappings. Newly explicit gaps include interrogative possessor/quantity contrasts, numeral agreement, coordinated genitives and possessives in dependent cases. The distinction between the lexical items for book and children also needs explicit treatment. No source sentences or illustrations were copied into the game. The chapter remains uncertified; proper names, metalanguage and cumulative lexical senses still need reconciliation.

This audit changes documentation only. The verified Linux bundle remains current.

### Cuius: interrogative genitive

Added six original sentence questions in each direction after the genitive cards in Persōnae et necessitūdinēs. The choices distinguish a possessor or kinship relation from a person, place, definition, number or reversed grammatical roles. Each incorrect choice has an explicit Latin diagnostic. The cards cost 20 gems and require the preceding card to be unlocked; both are required before the final vocabulary card. Existing presentation and characters are reused.

Merged the section's separate quis/quid lexical entries into one interrogative pronoun entry with the contextual genitive meaning. The final lexical bank now has 57 lemmas per direction, preserving one assessment per lemma. Question vocabulary references, lessons, help and mastery requirements were updated consistently. Chapter II has partial references for the new questions; this is not a certification of full reading coverage. Current Theatrum/Templum totals: eleven groups, 61 paired topics, 22 lexical cards, 144 cards and 1,456 questions.

All 34 Flutter tests, complete design validation and Linux compilation passed. Whole Grammaticon contains 315 cards and 892,010 questions. Both updated lexical banks were checked for exact inventory, distinct choices and correct accepted meanings. All 3,325 bundled design files and the engine hash match the workspace. The full objective checker still reports the open completion gates and 356 uncertified source units, with no unresolved question-reference errors.

### Genitive interpretation diagnostics

Reviewed all twelve sentence questions in the original possession pair. Each wrong answer now identifies a specific change: agent versus genitive referent, head noun versus dependent genitive, agent/object inversion, number of referents or number of possessors. Correct-answer feedback describes the actual sentence rather than repeating one generic ownership rule. The course explicitly distinguishes possession from kinship.

Replaced the fifth question's punctuation-only distractor with a singular/plural possessor contrast (magistrī/magistrōrum), using vocabulary already present in the section. Renamed this declarative card Liber puerī to distinguish it from the newly added interrogative Cuius? card. Both cards now require evidence for all six authored items for mastery. No new artwork or runtime logic was introduced.

The full completion gate now reports incorrect sentence outcomes that declare neither a specific observed confusion nor a hypothesis. Lexical cards are excluded from this sentence-diagnostic rule. The current audit identifies 26 remaining banks; the repaired possession pair is clear. A diagnostic identifier alone is still not proof of linguistic or pedagogical correctness, so the editorial review gate remains open. All 34 Flutter tests and full design validation passed.

Linux compilation passed; all 3,325 bundled design files and the engine hash match the workspace. No runtime or graphical code changed in this correction.

### Introductory ablative and number contrasts

Reviewed both directions of o-ablative and est-sunt (16 questions). Replaced implausible French distractors equating people with gardens or schools with meaningful contrasts: inside/outside, static position/entry, number of people and number of locations. Latin production choices retain explicit case or agreement contrasts. Each incorrect outcome has a dedicated diagnostic and an explanation tied to the displayed distinction.

Scoped the -ō rule to the actual second-declension nouns rather than claiming every masculine noun in -us follows it. Number explanations distinguish the subject from the location and apply est/sunt to the given third-person subjects. Both paired skills now require successful evidence for every authored item. Original graphics, question IDs, accepted choices, prices and prerequisites are preserved.

All 34 Flutter tests, complete design validation and Linux compilation passed. All 3,325 bundled design files and the engine hash match the workspace. The four repaired banks are clear in the specific-diagnostic audit; 22 older banks remain flagged. The exhaustive reading objective remains unfinished.

### Location questions and negation

Reviewed 20 questions across both directions of Ubi? and negation. Authored diagnostics now separate location/person/definition/polar questions, omitted negation, shifted negation scope, and subject-number changes. The course identifies the usual negative expectation of num and replaces an unsuitable negative imperative with nōlī plus infinitive. All four skills require successful evidence for their complete authored item sets.

The interrogative quī in Quī sunt puerī? was incorrectly classified as a relative pronoun in the first section. Merged it with quis/quid into one interrogative lexical entry and corrected num's contextual meaning. Relative pronouns in other sections remain separate. Updated question references, vocabulary choices, lessons, help and mastery lists; the two terminal banks each contain the same 38-lemma inventory. Exact accepted meanings and choice uniqueness were checked.

Theatrum/Templum now have 144 cards and 1,452 questions; four redundant inflection-based lexical questions were removed. The source vocabulary surface matcher reports 187 matches, not 189: merging lemma labels changes this limited comparison, which does not certify lexical-sense coverage. Eighteen older sentence banks still lack specific diagnostics. The exhaustive completion gates remain open.

All 34 Flutter tests, complete design validation and Linux compilation passed. Whole Grammaticon contains 315 cards and 892,006 questions. All 3,325 bundled design files and the unchanged engine hash match the workspace.

### Active roles and dative recipients

Replaced the mixed Cui? banks with six paired original sentence translations focused on the recipient. The old banks mixed carrying, possession, negation, a short-story identification and French instructions in Templum. New questions distinguish giver/recipient reversal and recipient number, including object-first order. They use Latin instructions, one skill and explicit per-choice diagnostics. The card address, presentation, prices and prerequisites are retained. New dative-recipient skill/item identifiers retire the mixed giving assessments rather than crediting them as evidence of the new skill.

Reviewed the 20 subject/object questions. Twelve distractors now change only the intended number instead of changing subject and object numbers together. Explicit diagnostics distinguish role reversal, subject number and object number. All six reviewed skills require evidence for every authored item. The complete 57-lemma section inventory was retained and its encountered-form lists reconciled against the actual sentence banks; this also restored previously omitted relative forms to that inventory. No runtime or graphical code changed. Twelve older sentence banks still lack specific diagnostics, and full source coverage remains unfinished.

All 34 Flutter tests, complete design validation and Linux compilation passed. All 3,325 bundled design files and the unchanged engine hash match the workspace. The six repaired banks pass the specific-diagnostic check; the full reading objective remains open.

### Present-purpose clauses

Replaced the mixed Ut et nē banks with six original paired sentence translations focused on purpose after present main verbs. Their distractors distinguish a causal clause with quia from a purpose clause and reverse affirmative/negative purpose. The previous bank also tested a gerundive obligation and an unrelated return home; those do not count as acquired purpose knowledge. Past-tense purpose and gerundive obligation remain separate uncovered requirements. New purpose-present skill identifiers retire the mixed assessment identities.

The sentences introduce contextual vocabulary for sails, a ship, cold, waking, silence and holding. The publisher vocabulary was consulted for vowel quantities including vēlum, frīgus, excitāre, tacēre, tenēre and iānua. No source sentences were copied. The complete section union is now 97 lexical entries, tested in both directions; obsolete words that occurred only in the removed questions were removed from this section's bank. Correct accepted meanings and distinct choices were checked.

Current Theatrum/Templum totals: 144 cards, 1,470 questions. Ten older sentence banks still lack specific diagnostics. The other mixed advanced cards and full source-coverage gates remain unfinished. No runtime or graphical code changed.

All 34 Flutter tests, complete design validation and Linux compilation passed. Whole Grammaticon contains 315 cards and 892,024 questions. All 3,325 bundled design files and the unchanged engine hash match the workspace.

### Present participles in absolute clauses

Replaced the mixed ablative-absolute bank with six original paired sentences using present participles. Puerō cantante identifies a simultaneous action with its own subject; the other choices either assign both actions to one actor or express a before-relation. Singular and plural absolute phrases are included. The concise Latin card title and subtitle identify the example and construction. New absolute-present skills retire the mixed assessment IDs and require every authored item for mastery.

The section's complete vocabulary was recalculated at 103 lemmas in each direction. Quantities and meanings for working, telling, crying out, dinner, friendship, arrival and picking were checked against the publisher vocabulary. Exact lexical inventory, accepted meanings and distinct choices were verified. Theatrum/Templum total 144 cards and 1,486 questions.

Rechecked Fabellae reading 25: its absolute phrase uses a perfect participle describing a resulting state of fear. Refined that explicit source requirement and left it unmapped; the present-participle bank does not certify it. Perfect-participle absolutes and the other advanced constructions remain open work. Eight older sentence banks still lack specific diagnostics. No runtime or graphical code changed.

All 34 Flutter tests, complete design validation and Linux compilation passed. Whole Grammaticon contains 315 cards and 892,040 questions. All 3,325 bundled design files and the unchanged engine hash match the workspace.

### Perfect participles in absolute clauses

Added Epistulā lēctā after the present-participle card, with six original paired sentence questions. Most contrast completed action with action still occurring or not yet occurring; one explicitly distinguishes the resulting state of being terrified from actively frightening someone else. The course does not invent an agent for an absolute passive phrase. The new card costs 25 gems, requires the preceding card to be unlocked and is included in the section's final lexical prerequisite list. Existing scene and hero assets are retained, with an existing opponent selected from the same place.

The full section vocabulary now contains 114 lemmas per direction. Quantities were checked against the publisher vocabulary, including lēctum, dēlētum and perterritus. The old synthesis sentence was corrected consistently from lectā to lēctā. Exact lexical inventory, accepted meanings and choice uniqueness passed. One authored question in each direction supplies partial evidence for the resulting-state absolute in Fabellae reading 25; the unit remains uncertified.

Current Theatrum/Templum totals: eleven groups, 62 paired topics, 22 lexical cards; 146 cards and 1,520 questions. Existing source requirements and mixed advanced cards still require work. No runtime or graphical code changed.

All 34 Flutter tests, complete design validation and Linux compilation passed. Whole Grammaticon contains 317 cards and 892,074 questions. All 3,331 bundled design files and the unchanged engine hash match the workspace.

### First Fabulae Syrae reading requirements

Inspected the bodies of the first five readings in the referenced 2010 edition, including their transitions on shared pages. The original start-page-based ranges incorrectly cut off the final portions of readings 1–3. Their inclusive printed ranges are now 7–8, 8–9 and 9–11; readings 4–5 occupy 11 and 12 respectively. First-five boundaries are marked as body-verified. The remaining forty end-page estimates are explicitly provisional.

Drafted salient lexical senses, constructions and reading objectives for all five. The resulting index contains 63 distinct provisional construction requirements. It distinguishes gerund uses, deponent and semideponent forms, passive reporting and commands, nominal versus absolute participles, ordinary versus figurative referents, and intentionally ambiguous references. Proper names are recorded separately. These are requirement drafts, not exhaustive lemma inventories or verified reading coverage. No source sentences, stories or illustrations were added to gameplay.

Eight scoped mappings reference existing original questions for perfect absolutes, resulting states and nonne. The completion checker resolves these references and reports no undeclared requirements; the full objective remains incomplete. Catalog validation and whitespace checks pass. Only source-audit documentation changed, so the already verified Linux bundle remains current and no app rebuild was needed.

### Gerund constructions

Added the Gerundium group with four separate paired topics: purpose with ad and the accusative gerund, genitive after cupidus/studiosus, ablative of means, and the genitive before causā. Each bank has six original full-sentence questions. Production diagnostics distinguish incorrect cases or an infinitive after ad; translation diagnostics distinguish purpose, time, cause, means, desire and actual action. No runtime question generation was introduced.

Each sentence card costs 25 gems, followed by a 30-gem lexical card requiring completion of all four. All main and lexical skills require successful evidence for every declared item for mastery. Existing actors and temple opponents rotate across the new cards; scenes and hero graphics are reused. The complete 48-lemma inventory is tested in both directions, including the contextual purpose meaning of ad. Accepted lexical meanings and choice uniqueness were checked.

Explicit partial mappings connect these basic gerund constructions to the first five Fabulae Syrae readings. They do not claim to cover gerunds with direct objects, deponent gerunds or causal gerunds with adjectives. The previously omitted ad-gerund requirement in the third reading was added from the inspected source body. All new question references resolve; full reading coverage remains unfinished.

Current Theatrum/Templum totals: twelve groups, 66 paired sentence topics and 24 terminal lexical cards; 156 cards and 1,664 questions.

All 34 Flutter tests, complete design validation and Linux compilation passed. Whole Grammaticon contains 327 cards and 892,218 questions. All 3,363 bundled design files and the unchanged engine hash match the workspace.

### Epitome opening requirements and purpose after past actions

Visually inspected the first ten numbered paragraphs on PDF pages 11, 12 and 14 of the referenced 2009 Epitome. Paragraph 3 continues onto page 12; paragraph 7 continues on page 14 after an illustration. The source map now records inclusive end pages for these ten paragraphs. Their provisional inventory distinguishes 82 construction requirements, including deponent meanings, future perfect conditions, predicative complements, secondary-sequence purposes, the supine after motion and figurative references. Salient lexical candidates and reading objectives are recorded separately; the other 236 paragraph bodies and exhaustive lexical disambiguation remain pending.

Replaced the old mixed Concessiō et antecēdentia card with Ut monēret in both places and moved it directly after Ut et nē. Six original sentences per direction contrast purpose after a past action with cause or reversed polarity. The new card has a new skill/item identity, costs 25 gems, and is connected to the explicit unlock chain and terminal vocabulary prerequisite list. Removed the retired card directories, help and skill IDs. The gerund group now depends on the actual last sentence card of the preceding group. The course, titles and corrections remain Latin; all graphics and runtime code are unchanged.

The section's final vocabulary was rebuilt from the actual remaining and new sentences: 115 lemmas in each direction, including all new contextual words. Words present only in the removed mixed bank are no longer claimed by that section. Partial source mappings for Epitome paragraphs 5 and 7 refer to the new purposes; they explicitly exclude certification of the irregular edere forms and complete reading comprehension.

Current Theatrum/Templum totals: twelve groups, 66 paired topics and 24 terminal lexical cards; 156 cards and 1,670 questions. Whole Grammaticon validates with 327 cards and 892,224 authored questions. The full completion gate remains false; six legacy sentence banks still lack specific diagnostics, alongside the wider source-coverage work.

The 32 unaffected Flutter tests passed. The two scene tests initially referenced the retired card; after updating their addresses, both passed at 420 and 1,500 pixels. Their new temple screenshots were visually inspected. Catalog validation, full design validation, lexical-report freshness and whitespace checks passed. These checks do not certify exhaustive pedagogical coverage.

Linux compilation passed. All 3,363 bundled design files match the workspace byte-for-byte; the retired card is absent from both. The engine hash remains `e5ef4c6f090ac375f188755225cf997686927af132ace85e32b269e0992a83ae`.
