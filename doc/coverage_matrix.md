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

## Tempora et modī (reconnaissance du temps et du mode)

Groupe de l'Amphithéâtre placé avant les Mixta et exigé par elles. Une seule dimension interrogée par épreuve, grille de réponses fixe (toute l'échelle du mode dans l'ordre canonique, même si deux temps seulement sont mélangés), composants déverrouillés à mesure que l'épreuve du temps correspondant est achetée (`TrialComponent.requires`, `Progression.unlockedComponents`). Les compétences `tm.*` (branche « Tempora et modī » de la Tabula) sont distinctes des compétences de conjugaison `v.*`, qui mesurent les désinences de personne et de nombre : une question de temps ou de mode ne crédite jamais `v.*`, une question de personne ne crédite jamais `tm.*`, y compris dans les Mixta.

| Épreuve | Question | Composants | Compétence | Test |
|---|---|---|---|---|
| `tm-tempora-ind-act` / `-pass` | quod tempus ? (indicatif, une voix) | 6 temps, chacun exige `ind-<t>-<voix>` | `tm.tempus.ind.act` / `.pass` | `tempora_modi_test` « tense trials ask the tense only », « fixed grid », « components unlock » |
| `tm-tempora-subj-act` / `-pass` | quod tempus ? (subjonctif, une voix) | 4 temps, chacun exige `subj-<t>-<voix>` | `tm.tempus.subj.act` / `.pass` | idem |
| `tm-tempora-inf` | quod tempus ? (infinitif actif) | présent, parfait, futur | `tm.tempus.inf` | idem |
| `tm-modi-praes` | quī modus ? (présent actif seulement) | ind., subj., impér., inf., chacun exige son épreuve | `tm.modus.praes` | « mood trials ask the mood only » |
| `tm-modi-omnia` | quī modus ? (tous temps, actif) | 4 modes | `tm.modus.omnia` | idem |
| `tm-ambo` | quod tempus, quī modus ? réponse combinée (`Dimension.tempusModus`, distracteurs voisins : même mode autre temps, même temps autre mode, les deux changés) | 4 modes | `tm.ambo` | « combined tense and mood », regam accepté comme futur ind. et présent subj. |

## Mélanges (Mixta)

| Épreuve | Composants sélectionnables | Compétence évaluée | Test |
|---|---|---|---|
| `mx-tempora-ind-act` / `-pass` | 6 temps de l'indicatif (exigent `tm-tempora-ind-*`) | `mx.tempus.ind` + `tm.tempus.ind.*` quand le temps est demandé, `v.ind.<t>.<voix>` quand la personne ou le nombre l'est | « mixta questions credit the observed tense skill », « mixta with a component subset only draws from those components » |
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

## Système nominal (Forum)

Chaîne : **données** (`lib/linguistics/lexicon/` — `nouns.dart` 340 noms, `adjectives.dart`, `pronouns.dart`, `numerals.dart`, `adverbs.dart` ; A&G §40–§152, §214–§218, §427) → **génération** (`declinator.dart` pour les noms, `adjective_declinator.dart` pour les trois degrés, paradigmes explicites pour les pronoms ; index unique `nominal_analyzer.dart`, 612 lexèmes) → **contenu contextuel rédigé** (`lib/pedagogy/forum/syntagmata/`, 763 syntagmes) → **épreuves** (`lib/pedagogy/forum/forum_trials.dart`, 78 cartes en 11 sections) → **source de questions** (`forum_question_source.dart`) → **tests** (`test/linguistics/gold_nouns_test.dart`, `gold_nominals_test.dart`, `test/pedagogy/forum_question_source_test.dart`, `forum_syntagmata_test.dart`, `test/battle/forum_encounter_test.dart`). Outils : `dart run tool/dump_nominal.dart --ids`, `dart run tool/check_syntagmata.dart`, `dart run tool/sample_forum_questions.dart`.

**Principe du catalogue : une carte par confusion, pas par catégorie.** Les prérequis suivent les ambiguïtés réelles du système, non l'ordre du manuel (`dec-3-cons` exige `dec-2-n` parce que la logique du neutre doit être en place ; `adi-3-duo` exige `dec-3-i` parce que les adjectifs de 3e suivent le thème en -i- alors que la plupart des noms de 3e suivent le thème consonantique). Deux portes gratuites : `dec-1` et `pron-ego-tu`.

### L'item contextuel
Les cartes de flexion (sections 1–7) travaillent sur un mot isolé. Les sections 8–11 ne le peuvent pas : le système nominal est massivement syncrétique et « quel cas est *rosae* ? » n'a pas de réponse — trois sont correctes. D'où un second type d'item, le **syntagme** (`lib/pedagogy/forum/syntagma.dart`) : deux à cinq mots, la cible entre accolades, l'antécédent entre crochets, les nominaux candidats entre chevrons.

```
{ text: 'rosae {spīnae} pungunt',  → nom. pl.
  text: '{rosae} aqua nocet',      → dat. sg.
  text: 'spīnae {rosae} pungunt' } → gén. sg.
```

Un item isolé accepte **toutes** les lectures de sa surface (*rosae* = gén. sg., dat. sg., nom. pl., voc. pl.) ; un item contextuel n'accepte **que** celle que le contexte impose — c'est tout l'intérêt. Chaque item déclare une note latine d'une phrase, affichée en correction. `tool/check_syntagmata.dart` et `forum_syntagmata_test.dart` vérifient que la surface porte réellement la lecture déclarée sous le lemme déclaré, que les candidats sont de vraies formes de leur lemme, et qu'exactement un nominal s'accorde avec la cible sur les items `quodNomen`.

| Section | Cartes | Contenu | Questions |
|---|---|---|---|
| 1. Dēclīnātiōnēs | 9 : `dec-1`, `dec-2-mf`, `dec-2-n`, `dec-2-er`, `dec-3-cons`, `dec-3-n`, `dec-3-i`, `dec-4`, `dec-5` | 340 noms, A&G §40–§98 | `casus`, `numerus`, `genus`, `declinatio`, `lemma`, `analysis` |
| 2. Adiectīva | 6 : `adi-1-2`, `adi-1-2-er`, `adi-3-duo`, `adi-3-una`, `adi-3-tria`, `adi-pron` | bonus, pulcher/miser, fortis, fēlīx/vetus (thème consonantique), ācer, les neuf prōnōminālia (-īus, -ī) | + `classis` |
| 3. Comparātiō | 5 : `comp-forma`, `comp-flexio`, `comp-irreg`, `comp-adv`, `comp-abl` | -ior/-issimus, -errimus, -illimus ; melior/optimus, plūs ; prior sans positif ; adverbes | + `gradus`, `constructio` |
| 4. Prōnōmina persōnālia | 6 : `pron-ego-tu`, `pron-nos-vos`, `pron-se`, `pron-me-mihi`, `pron-poss`, `pron-suus-eius` | mē/tē (acc. = abl.), nōs/vōs (nom. = acc.), nōbīs/vōbīs (dat. = abl.) | + `persona`, `functio`, `relatio` |
| 5. Dēmōnstrātīva | 7 : `pron-is`, `pron-hic`, `pron-ille`, `pron-iste`, `pron-ipse`, `pron-idem`, `pron-dem-omnia` | paradigmes explicites, A&G §146 | `casus`, `numerus`, `genus`, `lemma` |
| 6. Relātīva et interrogātīva | 6 : `pron-quis`, `pron-qui`, `rel-consensus`, `pron-quis-qui`, `pron-indef`, `pron-corr` | quī/quis, aliquis…nēmō/nihil (défectifs), correlātīva | + `genusNumerus`, `forma`, `correlativum` |
| 7. Numerālia | 4 : `num-1-3`, `num-card`, `num-ord`, `num-mille` | ūnus/duo/trēs (trois systèmes), indéclinables, centēna, mīlle vs mīlia | + `valor` |
| 8. Syncretismī | 13 : `syn-ae`, `-a`, `-i`, `-o`, `-um`, `-us`, `-e`, `-es`, `-is`, `-ibus`, `-neutra`, `-quantitas`, `-omnia` | 279 syntagmes ; grille de cas fixe | `casus` (+ `numerus` là où il varie) |
| 9. Cōnsēnsus | 6 : `con-1-2`, `con-3-1`, `con-distans`, `con-plura`, `con-appositio`, `con-omnia` | 140 syntagmes ; accord distant, appositions | + `quodNomen` |
| 10. Cāsūs in sententiā | 8 : `cas-verba-{dat,abl,gen}`, `cas-prep-{duplex,abl,acc}`, `cas-loci`, `cas-temporis` | 166 syntagmes ; propriétés lexicales et mécaniques | `casus`, `functio`, `constructio` |
| 11. Mixta | 8 : `mx-declinationes`, `mx-adiectiva`, `mx-pronomina`, `mx-syncretismi`, `mx-consensus`, `mx-casus`, `mx-instrumenta`, `mx-nominalia` | composants déverrouillés un à un | `analysis` + toutes |

### Cartes à noter
* `dec-4` : le filtre est **volontairement élargi** aux noms de 2e (*exercitus* ressemble à *servus*) pour forcer la discrimination ; c'est le génitif *exercitūs* qui tranche.
* `comp-flexio` : le comparatif en `-ior` se décline sur le thème **consonantique** (abl. `-e`, gén. pl. `-um`, neutre pl. `-a`) — l'inverse des adjectifs de 3e ordinaires. *Fortī* mais *fortiōre*.
* `syn-us` : quatre origines (nom. sg. 2e, nom./gén. sg. 4e, nom./acc. pl. 4e, neutres de 3e *corpus, tempus, genus, opus*) dont la terminaison « crie » 2e masculin.
* `syn-neutra` : nominatif = accusatif partout, donc **seule la syntaxe tranche** ; prépare directement la lecture réelle.
* `rel-consensus` : la règle a deux sources, donc **deux questions enchaînées** sur le même item (`Trial.chain`) — d'abord `genusNumerus` (d'où viennent-ils : l'antécédent), puis `casus` (pourquoi celui-là : la fonction dans la subordonnée). Les poser d'un coup masquerait qu'il y a deux opérations. Trois paliers : antécédent adjacent, éloigné, relatif en tête.
* `con-distans` : *magnam in silvā vīdit umbram*. Question `quodNomen`, trois ou quatre candidats, un seul compatible. Le drill le plus proche de la lecture véritable.
* `cas-verba-dat` : propriété du lemme, non règle générale ; l'aide signale que ce n'est pas irrégulier mais régulier vu du latin (*pāreō* = « être obéissant à »).

### Ambiguïtés et compétences
* Toutes les analyses d'une surface sont conservées dans `NominalAnalyzer` (macron-sensible ; index insensible pour l'outillage) : *rosae* (4 lectures), *rosā* ≠ *rosa*, *manus* ≠ *manūs*, *fortius* = neutre comparatif **et** adverbe, *quem* = relatif **et** interrogatif.
* Une question n'est posée que si la dimension a ≥ 2 valeurs dans le palier ; les formes à réponse unique sont préférées ; une forme dont toutes les réponses proposées seraient justes n'est jamais posée. Sur grille fixe (`fixedChoices`), l'échelle complète des cas est toujours offerte : reconnaître n'est pas éliminer.
* Une cible en tête de phrase porte la majuscule latine (*Quis clāmat ?*) : le lexique est consulté sur la forme minuscule, l'écran affiche la graphie de la phrase. Les noms propres gardent leur majuscule (`lexiconTarget`).
* Compétences : une feuille par carte sous sa section (`f.dec.1`, `f.syn.us`, `f.rel.consensus`…), plus la cellule de paradigme du nom (`d.1.acc.sg`, locatif `d.loc`) conservée à part, pour que l'historique d'une cellule survive à toute refonte du catalogue. Dans les cartes mixtes, la compétence du composant est créditée entre les deux.
* Ids uniques entre activités (`Trials` lève une erreur en cas de collision) : la sauvegarde clé les achats par id seul.
* Migration schéma 3 → 4 : les achats et introductions des anciennes cartes de déclinaison sont reportés sur la carte qui couvre le même terrain (`kForumV3TrialIds`), aucune gemme dépensée n'est perdue ; les anciennes compétences `d.mx.*` sans successeur sont supprimées.

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

Les distracteurs portent chacun **une** erreur d'interprétation morphologique contrôlée (nombre, personne, cas, temps, voix, mode, accord, forme nominale) ; la donnée conserve la portion latine, l'analyse correcte, l'analyse simulée, le changement de sens en français, la compétence testée et la compétence de forme (`formSkill`) correspondante des arbres Amphitheātrum/Forum, et l'explication latine servant à la correction et à l'Auxilium. Une réponse ne crédite que la compétence de lecture (`l.*`) : la reconnaissance d'une forme isolée (`v.*`, `d.*`) et sa compréhension en contexte ne sont jamais confondues ; le vocabulaire rencontré est enregistré à part (`ExposureLedger`).

**Vocabulaire** (`tool/corpus/bible/lemmatize.py`, `tool/theatrum/vocab.py`, `lib/pedagogy/reading/vocab_progress.dart`) : chaque forme du corpus est lemmatisée avec les lexiques Collatinus ; les entrées (lemmes communs, noms propres, formes non résolues) forment le dénominateur de la couverture ; une entrée est *enseignée* quand une question validée la contient dans son passage avec sa glose, *interrogée* quand elle est la forme décisive ou la portion d'un distracteur. Les lemmes communs sont rangés en bandes de fréquence (gradūs I–V, `lemmaBands`) ; la question porte la bande de son mot le plus rare ; `ReadingQuestionSource` n'offre que les bandes ouvertes (`VocabProgress.level`, 60 % de mots *nōta* pour ouvrir la suivante) ; la Tabula affiche l'acquisition par gradus (*obvia / nōta / firma*). Seuil d'acceptation : 90 % des entrées enseignées (`vocab.py check`, `test/content/vocabulary_acceptance_test.dart`). Couverture et lacunes : `doc/theatrum_coverage.md`.

## Structure préparée (non jouable, indiquée comme à venir)
Templum visible dans la ville, désactivé (sens Gallicē → Latīnē réservé). Anglicē : option visible, non sélectionnable tant que `renderings_en.json` n'existe pas.
