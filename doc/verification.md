# Vérifications effectuées

## Automatisées (`flutter test`, 83 tests, tous verts)
* `test/linguistics/gold_paradigms_test.dart` (41) — tables A&G saisies indépendamment des règles : amō complet (6 tests), moneō, regō, capiō, audiō, dō, impératifs irréguliers, déponents (sequor, hortor, vereor, patior, potior, morior, orior), semi-déponents, sum et composés, possum, eō et composés, ferō et composés, volō/nōlō/mālō, fīō/faciō, edō, défectifs, impersonnels ; « no invented combinations » (intransitifs, sans supin, scī, 2 pl impératif futur passif, infinitifs sans personne, parties principales) ; analyseur (ambiguïtés, macrons, taille de l'index).
* `test/pedagogy/question_generator_test.dart` (12) — pools non vides pour les 42 épreuves, ≥ 2 choix, réponse correcte présente, distracteur présent, pas de doublon ; dimensions exclues quand fixées ; Mixta ; variantes ; forme de contraste ; graphe des prérequis acyclique et atteignable.
* `test/pedagogy/mastery_test.dart` (7), `test/economy/economy_test.dart` (5), `test/persistence/save_test.dart` (5), `test/battle/battle_controller_test.dart` (9), `test/widget_test.dart` (4 : parcours ville → Amphitheātrum → combat au clavier ; portrait téléphone ; fiche d'aide pendant une question ; écran des réglages).
* `flutter analyze` : aucune remarque.

## Contrôle croisé Collatinus (développement)
`python3 tool/corpus/verify_collatinus.py` réimplémente la flexion des modèles Collatinus (héritage `pere:`, radicaux `R:`, désinences, `abs:`, constantes, contractions, assimilations) et compare aux formes exportées. Dernier rapport : **19 688 formes simples concordantes**, 3 434 présentes seulement chez Grammaticon, 5 969 seulement chez Collatinus, 3 lemmes absents de Collatinus (avē, oportet, taedet). Les écarts ont été examinés et relèvent de :
* variantes que Collatinus ne liste pas (abl. -ī du participe présent, gérondif -undus, 2 sg passif -re au présent, *forem/fore*, *ausim*) ;
* restrictions volontaires de Grammaticon que Collatinus n'applique pas (passif impersonnel des intransitifs, semi-déponents sans passif présent ni parfait régulier, absences des impersonnels) ;
* choix de Collatinus divergents d'A&G (feritō/fereris pour ferō, fiendus pour fīō, iisti/iuisti pour eō, *amantum* gén. pl.) — la version A&G est conservée ;
* artefacts de données Collatinus (répétition de -minī sur l'impératif futur des déponents, exclus).
Les formes composées ne sont pas produites par Collatinus et sont contrôlées par les tables A&G.

## Manuelles
* Bureau **Linux (X11, 1280×720 et 1920×1080)** : build debug lancé ; ville, Amphitheātrum, combat (question, choix numérotés, *Recte!*, riposte, dialogue de sortie) rendus correctement ; sauvegarde écrite dans `~/.local/share/com.example.latin_game/shared_preferences.json` après les réponses.
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
* Forum, Thermae, Templum : structure prête, contenu à venir.
