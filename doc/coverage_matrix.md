# Matrice de couverture — conjugaison et déclinaison latines

Chaîne vérifiée pour chaque catégorie : **données** (lexique, `lib/linguistics/lexicon/verbs.dart`) → **génération/analyse** (`lib/linguistics/engine/`) → **épreuve** (`lib/pedagogy/trials.dart`) → **test** (`test/`). Les formes composées sont générées avec accord (genre, nombre) et toutes les analyses d'une même forme sont conservées dans l'index (`Analyzer`).

Sources : A&G = Allen & Greenough, *New Latin Grammar* (1903, éd. DCC). Collatinus = contrôle croisé de développement (`tool/corpus/verify_collatinus.py`, rapport `tool/corpus/out/collatinus_report.md`).

## Conjugaisons régulières

| Catégorie | Verbes représentatifs | Génération | Épreuves | Tests |
|---|---|---|---|---|
| 1re conjugaison | amō, laudō, vocō, portō, ōrō, pugnō, ambulō, stō, iuvō, lavō | règles A&G §184 (`presentSystemRegular`, `perfectSystemActive`) | tous les paliers `ind-*`, `subj-*`, `imp-*`, non personnels, `mx-*` | `gold_paradigms_test` « amō » (6 tests), Collatinus |
| 2e conjugaison | moneō, habeō, videō, teneō, doceō, dēleō, iubeō, maneō, sedeō, timeō, moveō | A&G §185 | idem | « moneō », Collatinus |
| 3e conjugaison | regō, dūcō, dīcō, mittō, legō, scrībō, vincō, pōnō, agō, petō, crēdō, cadō, currō, vīvō, reddō, gerō, vertō | A&G §186 | idem | « regō », Collatinus |
| 3e en -iō | capiō, faciō, cōnficiō, iaciō, rapiō, fugiō, cupiō | A&G §188 | idem | « capiō », Collatinus |
| 4e conjugaison | audiō, veniō, dormiō, sentiō, sciō, aperiō | A&G §187 | idem | « audiō », Collatinus |
| Particularités de thème | perfaits redoublés (stetī, cecidī, dedī), en -sī (rēxī, mānsī), à voyelle longue (vīdī, lēgī), en -uī, -īvī | parties principales explicites ; thèmes dérivés | tous | « every principal part appears », Collatinus |
| Impératifs dīc, dūc, fac ; dō à *a* bref | dīcō, dūcō, faciō, dō, circumdō | `overrides`, drapeau `shortA` | `imp-praes`, `fam-minora` | « imperatives dīc, dūc, fac », « dō (§202) » |
| Verbes sans supin | timeō | `hasSupine: false` → pas de participe parfait/futur, ni composés | tous | « verbs without supine lack the participial system » |
| Intransitifs | veniō, pugnō, ambulō, maneō, sedeō, cadō, currō, vīvō, stō, dormiō | passif impersonnel (3 sg, neutre) seulement ; périphrastique passive impersonnelle | tous (`excludeIntransitivePassive` dans les paliers passifs) | « intransitive verbs have only impersonal passives » |

## Formes personnelles (toutes conjugaisons)

| Mode / temps | Voix | Génération | Épreuve | Test |
|---|---|---|---|---|
| Indicatif présent, imparfait, futur | act./pass. | tables A&G | `ind-praes-act`… `ind-fut-pass` | gold amō/moneō/regō/capiō/audiō |
| Indicatif parfait, plus-que-parfait, futur antérieur | act. | thème du parfait + désinences | `ind-perf-act`, `ind-plusq-act`, `ind-futex-act` | gold |
| Indicatif parfait, PQP, futur antérieur | pass. (composé) | PPP + sum/eram/erō, accord m/f/n, sg/pl ; variantes *fuī* | `ind-perf-pass`, `ind-plusq-pass`, `ind-futex-pass` | « composite passive with agreement » |
| Subjonctif présent, imparfait | act./pass. | tables A&G ; imparfait = infinitif + désinence | `subj-praes-act`… `subj-imperf-pass` | gold |
| Subjonctif parfait, PQP | act. / pass. composé | thème du parfait ; PPP + sim/essem (variantes *fuerim*, *forem*) | `subj-perf-*`, `subj-plusq-*` | gold |
| Impératif présent 2 sg/pl | act./pass. | A&G §163 | `imp-praes` | « imperatives » |
| Impératif futur 2 sg, 3 sg, 2 pl (act.), 3 pl ; passif 2 sg, 3 sg, 3 pl | act./pass. | A&G §163 ; aucun 2 pl passif futur inventé | `imp-fut` | « no 2 pl future passive imperative anywhere » |

## Formes non personnelles et périphrases

| Catégorie | Génération | Épreuve | Test |
|---|---|---|---|
| Infinitifs présent (act./pass.), parfait (act. ; pass. composé avec accord nom./acc.), futur (act. composé ; pass. supin + īrī) | `compositeInfinitives` | `infinitivi` | gold « infinitives… », « amātum esse is nominative neuter or accusative masculine » |
| Participes présent (3e décl. complète, abl. -e/-ī), parfait passif, futur actif (1re/2e décl. complètes) | `declineParticiple`, `declineBonus` | `participia` | gold |
| Gérondif (gén., dat., acc., abl.) et gérondif/adjectif verbal (déclinaison complète, variante -undus III/IV) | `gerundStem`, `undusVariants` | `gerundium` | gold |
| Supin (-um, -ū) | `supineStemForms` | `supinum` | gold |
| Conjugaison périphrastique active (participe futur + sum : 6 temps ind., 4 subj., infinitifs) | `periphrastic(activa)` | `periph-act` | « periphrastic conjugations (§195) » |
| Conjugaison périphrastique passive (gérondif + sum) | `periphrastic(passiva)` | `periph-pass` | idem |
| Aucune personne demandée aux infinitifs/participes | `Dimension` filtrées par le générateur | tous | `question_generator_test` « non-finite trials never ask person or number » |

## Familles irrégulières, déponents, défectifs, impersonnels

| Catégorie | Verbes | Génération | Épreuve | Test |
|---|---|---|---|---|
| sum et composés | sum, absum, adsum, prōsum (prōd- devant voyelle), praesum | gabarit `irregularTemplates['sum']` + préfixes ; forem/fore ; futūrus ; participe *absēns/praesēns* | `fam-sum` | « sum », « compounds of sum » |
| possum | possum | gabarit ; potēns ; aucun impératif | `fam-sum` | « possum (§198) » |
| eō et composés | eō, abeō, adeō, redeō, exeō, trānseō, pereō | gabarit ; iī/īstī/īsse ; iēns, euntis ; eundum ; passif impersonnel ītur, personnel pour les composés transitifs | `fam-eo` | « eō (§203) » |
| ferō et composés | ferō, afferō, auferō, referō, offerō, cōnferō | gabarit (fers, fert, ferris, fer, ferre, ferrī) ; tulī / lātus, abstulī / ablātus… | `fam-fero` | « ferō (§200) » |
| volō, nōlō, mālō | volō, nōlō, mālō | gabarits (vīs, vult, nōn vīs, māvult ; velim ; vellem ; nōlī) ; absences (impératif, passif, participes) | `fam-volo` | « volō, nōlō, mālō (§199) » |
| fīō / faciō | fīō, faciō, cōnficiō (régulier) | gabarit fīō ; passif présent de faciō = fīō ; factus sum ; faciendus | `fam-fio` | « fīō and faciō (§204) », « fit belongs to fīō and to the passive of faciō » |
| edō, dō | edō (ēs, ēst, ēsse, ēssem, ēstur ; edim archaïque), dō | gabarit edō ; `shortA` | `fam-minora` | « edō (§201) », « dō (§202) » |
| Déponents | hortor, vereor, sequor, loquor, ūtor, patior, morior, gradior, potior, orior, for | morphologie passive, sens actif (`semanticVoice`) ; aucune forme active ; participes présent/futur actifs ; gérondif passif ; moritūrus, oritūrus ; potitur/poterētur ; orior mixte III/IV | `deponentia`, `mx-voces` | « sequor », « hortor, vereor, patior, potior » |
| Semi-déponents | audeō (ausim), gaudeō, soleō, fīdō, cōnfīdō ; revertor (inverse) | présent actif, parfait composé ; pas de passif présent ; revertī actif | `semideponentia` | « semi-deponents (§192) » |
| Défectifs | ōdī, meminī (mementō), coepī (coeptus sum), inquam, āiō, quaesō, salvē, avē, for | parfait à sens présent (`semanticTense`) ; formes explicites ; absences documentées | `defectiva` | « defectives (§205–206) » |
| Impersonnels | licet (licitum est), oportet, decet, pudet, paenitet, taedet, piget, libet, pluit, ningit, tonat | 3 sg seulement ; infinitifs ; participes non générés (documenté) | `impersonalia` | « impersonals (§207–208) » |

## Variantes attestées

| Variante | Génération | Épreuve | Test |
|---|---|---|---|
| Parfait 3 pl -ēre | `ruleVariants` | `variantes` | « variants (§163, §181) » |
| 2 sg passif -re (rare au présent de l'indicatif) | `ruleVariants` (`rara` / `passivumRe`) | `variantes` | idem |
| Parfaits syncopés (amāstī, amāsse, amārunt, amāram ; audiit, audīsse ; nōsse) | `syncopatedPerfects` (A&G §181) | `variantes` | idem ; Collatinus (`contractions.la`) |
| Composés avec *fuī* (amātus fuit), *forem* | générateur de composés | `variantes`, tous paliers composés (acceptés à l'analyse) | « composite passive with agreement » |
| Gérondif -undus | `undusVariants` | `variantes` | « regō », « capiō » |
| forem / fore ; edim ; ausim ; dīce/dūce archaïques | gabarits / `overrides` marqués `forem`, `archaica` | familles | « sum », « edō », « semi-deponents » |

## Ambiguïtés et politique des macrons

* Les formes sont stockées et affichées avec macrons ; l'index est macron-sensible, un index insensible existe pour l'outillage (`analyzeLoose`). A&G distingue *amāverīs* (subj. parf.) et *amāveris* (fut. ant.) ; les deux analyses sont retenues en lecture insensible (« amāverīs (subjunctive) and amāveris (future perfect) differ by quantity »).
* Toutes les analyses valides sont conservées : *amāre* (infinitif, impératif passif, 2 sg passif rare), *regere*, *regam* (fut. ind. / prés. subj.), *fit* (fīō / faciō), *es* (sum ind. / impér.), *amātum esse* (nom. n. / acc. m.). Une question n'est posée que si la dimension demandée a ≥ 2 valeurs dans le palier ; si la forme est ambiguë sur cette dimension, toutes les valeurs légitimes sont acceptées et signalées (« ambiguous forms accept every legitimate value », « lemma question on fit accepts both fīō and faciō »).
* Distinction forme inexistante / non attestée / non usitée / donnée manquante : `AbsenceStatus` (ex. *scī* = nōn ūsitātur, *ēns* = nōn ūsitātur, passif de sum = nōn exstat, gérondif de licet = nōn attestātur) — test « scī is flagged as not used, not as nonexistent ».

## Mélanges (Mixta)

| Épreuve | Composants sélectionnables | Compétence évaluée | Test |
|---|---|---|---|
| `mx-tempora-ind-act` / `-pass` | 6 temps de l'indicatif | `mx.tempus.ind` + compétence du temps observé | « mixta questions credit the observed tense skill », « mixta with a component subset only draws from those components » |
| `mx-tempora-subj` | 4 temps × 2 voix | `mx.tempus.subj` | idem |
| `mx-modi` | ind., subj., impér., inf. | `mx.modus` | « every trial has a non-empty pool » |
| `mx-voces` | actif, passif, déponents | `mx.vox` | idem |
| `mx-familiae` | sum, eō, ferō, volō, fīō, dō/edō | `mx.familia` | idem |
| `mx-omnia` | personnelles, nominales, périphrastiques, anomales, spéciales | `mx.omnia` (analyse complète) | idem |

## Économie, maîtrise, sauvegarde

| Exigence | Implémentation | Test |
|---|---|---|
| Barème configurable, transaction unique par réponse, maîtrise avant réponse | `EconomyConfig`, `AnswerResolver` | `economy_test`, `battle_controller_test` « pays gems once » |
| Erreur volontaire non rentable | `SkillRecord.rewardTier` (marque haute à décroissance lente) | `mastery_test` « deliberate errors… » |
| Répétition d'un même mot | saturation `lemmaDaily` | `economy_test` « repeating one lemma stops paying » |
| Réponses aidées / corrigées | `AnswerQuality`, `aidedGain` | « help before answering marks the answer as aided », « aided answers never raise the tier » |
| Solde ≥ 0, achats permanents, pas d'achat automatique, déduction unique | `Economy.applyToBalance`, `ProfileController.purchase` | « purchase deducts once… » |
| Pas d'impasse | prime de victoire bornée, doublée en rattrapage | « victory pays a bounded bonus », « no economic dead end » |
| Enjeu de la défaite | gains du combat perdus + tribut d'un quart du solde plafonné à 40, annoncé avant le combat ; achats et maîtrise conservés | `economy_test` « defeat forfeits… », « defeat after losing all hearts » |
| Sauvegarde après chaque réponse/achat, schéma versionné, migrations, reprise, export/import | `SaveCodec`, `SaveRepository`, `ActiveBattle` | `save_test`, « snapshot is saved mid-fight and can be resumed » |
| Entrée unique par question (touches maintenues, doubles clics, événements tardifs) | latch `questionId` + `KeyDownEvent` seulement | `widget_test` « held key / repeat must not answer twice » |

## Déclinaisons (Forum)

Chaîne : **données** (`lib/linguistics/lexicon/nouns.dart`, 145 noms, A&G §40–§98, §427, §101) → **génération** (`lib/linguistics/engine/declinator.dart`, index `noun_analyzer.dart`) → **épreuve** (`lib/pedagogy/noun_trials.dart`) → **test** (`test/linguistics/gold_nouns_test.dart`, `test/pedagogy/noun_question_generator_test.dart`, `test/battle/forum_encounter_test.dart`). Contrôle croisé : `python3 tool/corpus/verify_collatinus_nouns.py` (rapport `tool/corpus/out/collatinus_nouns_report.md`).

| Catégorie | Noms représentatifs | Génération | Épreuves | Tests |
|---|---|---|---|---|
| 1re déclinaison | rosa, puella, via, terra, aqua, īnsula, fēmina… ; masculins poēta, nauta, agricola ; dea, fīlia (-ābus) ; Rōma, Athēnae (pl.), dīvitiae (pl.) | A&G §41–43 | `d1-recti` (gratuite : nom., acc., abl.), `d1-omnes` | « rosa », « dea and fīlia », « Rōma… Athēnae » |
| 2e déclinaison | servus, dominus, amīcus… ; puer, ager, magister, liber, vir ; fīlius (voc. fīlī, gén. fīliī/fīlī), cōnsilium, imperium ; deus (dī, deōrum/deum, dīs) ; humus, Corinthus (f.) ; castra, arma (pl.) | A&G §45–49 | `d2-us-um`, `d2-omnes` | « servus », « bellum », « puer… vir », « fīlius », « deus » |
| 3e thèmes consonantiques | rēx, dux, lēx, vōx, pāx, lūx, iūdex, cōnsul, mīles, eques, prīnceps, homō, ōrātor, senātor, honor, amor, labor, arbor (f.), soror, pater/māter/frāter (patrum), lēgiō, ōrātiō, cīvitās (-um/-ium), virtūs, aetās, pēs, lapis, sacerdōs, canis, iuvenis ; neutres corpus, tempus, genus, opus, nōmen, flūmen, carmen, caput, iter, lītus, vulnus, pectus, os (ossium) | A&G §56–64, §71 | `d3-consonantia`, `d3-omnia` | « rēx », « corpus, nōmen, caput, iter », « pater, canis, iuvenis », « cīvitās… os » |
| 3e thèmes en -i | cīvis, hostis, nāvis (-em/-im, -e/-ī), turris (-im/-em, -ī/-e), ignis (-ī/-e), collis, fīnis, avis, nūbēs, caedēs ; monosyllabes urbs, arx, mōns, pōns, gēns, mēns, mors, ars, pars, dēns, nox ; neutres mare, animal, exemplar, moenia (pl.) | A&G §65–71, §75–76 | `d3-i`, `d3-omnia` | « cīvis, hostis », « monosyllables », « turris, nāvis, ignis », « mare, animal » |
| 3e irréguliers | vīs (vim, vī ; vīrēs, vīrium), bōs (boum, bōbus/būbus), senex (senis), Iuppiter (Iovis), iter (itineris) | `overrides` par cellule, A&G §79 | `d3-omnia` | « irregular vīs, bōs, senex, Iuppiter » |
| 4e déclinaison | manus (f.), exercitus, senātus (-ūs/-ī), frūctus, cāsus, portus (-ibus/-ubus), tribus (-ubus), lacus (-ubus), domus (§93 : domō, domōrum, domī), cornū, genū | A&G §89–94 | `d4` | « manus », « cornū », « tribus, lacus, portus… senātus », « domus » |
| 5e déclinaison | rēs, diēs (m.), spēs, fidēs (sg.), aciēs, merīdiēs (sg.) ; ē brève/longue (reī, diēī) ; pluriel complet pour rēs et diēs seulement | A&G §96–98 | `d5` | « rēs and diēs », « spēs, aciēs… fidēs » |
| Locatif | Rōmae, Athēnīs, Corinthī, humī, Carthāginī/Carthāgine, rūrī/rūre, domī | généré uniquement pour les noms marqués `locative` (A&G §427) | `d-locativus`, `dmx-omnia` | « locatives », « the locative exists only where declared » |
| Nombre | singulāria tantum (Rōma, fidēs, Iuppiter…), plūrālia tantum (Athēnae, castra, arma, moenia, dīvitiae) | `NounNumber`, `AbsentForm` (spēs : gén./dat./abl. pl. nōn ūsitātur) | toutes | « singular-only and plural-only… », « spēs, aciēs » |
| Mélanges | quae dēclīnātiō ? (composants = 5 déclinaisons), cas mixtes, omnia mixta (analyse complète) | `Dimension.declinatio`, entrée de dictionnaire affichée seulement si la désinence est partagée par plusieurs déclinaisons | `dmx-declinatio`, `dmx-casus`, `dmx-omnia` | « declension questions show the dictionary entry only when the ending is shared », « mixed trials credit… » |

### Ambiguïtés des noms
* Toutes les analyses d'une forme sont conservées dans `NounAnalyzer` (macron-sensible ; index insensible pour l'outillage) : *rosae* = gén. sg., dat. sg., nom. pl., voc. pl. ; *rosā* ≠ *rosa* ; *manus* (nom./voc. sg.) ≠ *manūs* ; *Rōmae* ajoute le locatif.
* Une question n'est posée que si la dimension a ≥ 2 valeurs dans le palier (jamais « quelle déclinaison ? » dans une épreuve à une déclinaison). Les formes à réponse unique parmi les choix proposés sont préférées ; une forme dont toutes les réponses proposées seraient justes n'est jamais posée ; sinon toutes les valeurs légitimes sont acceptées et signalées. Une analyse hors du palier (vocatif dans `d1-recti`) n'est jamais refusée, elle n'est simplement pas proposée.
* Compétences créditées : la cellule de la forme (`d.1.acc.sg`, locatif `d.loc`) ; dans les épreuves mixtes, en plus, la compétence de discrimination ; « quae dēclīnātiō ? » ne crédite que `d.mx.declinatio` (aucune inférence sur le cas).

## Lecture et interprétation (Theatrum)

Chaîne : **corpus** (`assets/corpus/latVUC_vpl.txt`, `fraLSG_vpl.txt`, provenance dans `doc/theatrum_sources.md`) → **contenu rédigé et validé** (`tool/theatrum/items_fr.py` → `python3 tool/theatrum/build_content.py` → `assets/theatrum/passages_la.json` + `renderings_fr.json`) → **source de questions** (`lib/pedagogy/reading/reading_question_source.dart`, sélection orientée couverture) → **épreuves** (`lib/pedagogy/reading/reading_trials.dart`) → **tests** (`test/pedagogy/reading_content_test.dart`, `test/battle/theatrum_encounter_test.dart`, `test/widget_test.dart`). Rien n'est généré à l'exécution : passages, rendus et distracteurs sont des données rédigées, chacune validée (extrait latin exact, rendu Segond exact ou rendu pédagogique identifié, trois distracteurs annotés, distinctions conformes au niveau).

| Épreuve (fābula) | Distinction | Compétence Tabula | Alignement forme isolée | Questions |
|---|---|---|---|---|
| `th-numerus` (gratuite) | nombre du verbe et du nom | `l.numerus` | `ind-praes-act` / `d1-recti` (dēsinentiae -t/-nt, -a/-æ) | 12 |
| `th-persona` | personne (verbe, possessifs) | `l.persona` | `ind-praes-act`, `ind-perf-act` | 12 |
| `th-casus-recti` | sujet / objet / ablatif | `l.casus` | `d1-recti`, `d2-us-um` | 12 |
| `th-tempus-praeteritum` | présent · imparfait · parfait | `l.tempus` | `ind-imperf-act`, `ind-perf-act` | 13 |
| `th-tempus-futurum` | futur · plus-que-parfait · futur antérieur | `l.tempus` | `ind-fut-act`, `ind-plusq-act`, `ind-futex-act` | 11 |
| `th-casus-obliqui` | génitif · datif · ablatif (-ae, -o, -is/-ibus) | `l.casus` | `d1-omnes`, `d2-omnes`, `d3-consonantia` | 12 |
| `th-congruentia` | accord adjectif/participe ↔ nom | `l.congruentia` | `d1-omnes`…`d3-i`, `participia` | 12 |
| `th-modus-imperativus` | impératif ↔ indicatif, nōlī(te) | `l.modus` | `imp-praes`, `fam-volo` | 12 |
| `th-vox` | actif ↔ passif (-tur, -rī, participe + est) | `l.vox` | `ind-praes-pass`…`ind-perf-pass`, `infinitivi` | 12 |
| `th-modus-subiunctivus` | subjonctif (souhait, ordre, but) ↔ indicatif | `l.modus` | `subj-praes-act`, `fam-fio` | 12 |
| `th-nonfinita` | participes (temps, voix, accord), infinitifs, gérondif, ablatif absolu, périphrastique | `l.nonfinita` | `participia`, `infinitivi`, `gerundium`, `periph-act` | 12 |
| `th-mx-verbum`, `th-mx-nomen`, `th-mx-omnia` | mélanges (composants = épreuves de base) | `l.mx.*` + compétence de la distinction | — | pools des composants |

Les distracteurs portent chacun **une** erreur d'interprétation morphologique contrôlée (nombre, personne, cas, temps, voix, mode, accord, forme nominale) ; la donnée conserve la portion latine, l'analyse correcte, l'analyse simulée, le changement de sens en français, la compétence testée et la compétence de forme (`formSkill`) correspondante des arbres Amphitheātrum/Forum, et l'explication latine servant à la correction et à l'Auxilium. Une réponse ne crédite que la compétence de lecture (`l.*`) : la reconnaissance d'une forme isolée (`v.*`, `d.*`) et sa compréhension en contexte ne sont jamais confondues ; le vocabulaire rencontré est enregistré à part (`ExposureLedger`, panneau *Vocābula Theātrī* de la Tabula). Couverture et lacunes : `doc/theatrum_coverage.md`.

## Structure préparée (non jouable, indiquée comme à venir)
Templum visible dans la ville, désactivé (sens Gallicē → Latīnē réservé). Anglicē : option visible, non sélectionnable tant que `renderings_en.json` n'existe pas. Adjectifs et pronoms : non traités ; le modèle `NounEntry`/`Declinator` (cellules cas × nombre, `overrides`, `absent`) et le contrat `QuestionPayload` sont le point d'extension prévu.
