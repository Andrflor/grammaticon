# Audit de variété — Theatrum et Templum

État du dépôt au 19 septembre 2026. Audit de contenu et de sélection, avant correctif.

## Synthèse

Les deux lieux comptent chacun **22 sections, 115 cartes de phrases et 22 cartes de vocabulaire**, soit 274 cartes auditées.

| Mesure | Theatrum, version | Templum, thème |
|---|---:|---:|
| Questions de phrases dans les banques source | 397 733 | 302 684 |
| Questions de phrases distinctes réellement instanciables | 9 253 | 4 192 |
| Modèles techniques de phrases embarqués | 603 | 393 |
| Cartes de phrases avec seulement 4 à 6 questions | **42 / 115** | **42 / 115** |
| Cartes de phrases avec au plus 10 questions | **44 / 115** | **44 / 115** |
| Questions des cartes finales de vocabulaire, cumulées | 1 508 | 1 536 |
| Identifiants lexicaux distincts dans ces cartes | 717 | 732 |
| Entrées de vocabulaire déjà interrogées dans une section précédente | **791, soit 52,5 %** | **804, soit 52,3 %** |

Les très gros totaux source masquent deux problèmes : des cartes véritablement minuscules, et des banques gonflées par substitutions de personnes, objets ou nombres. L'extraction réduit ensuite fortement ces dernières.

De `nomina` à `gerundium`, **40 des 42 cartes de phrases de chaque lieu n'ont que 4 à 6 questions**. Les deux exceptions sont `cur-quia` (12) et `absolute-perfect` (9).

Deux autres cartes par lieu n'ont que quatre questions alors que la victoire exige huit bonnes réponses :

- `oratio-obliqua/2` et `orationem-referre/2` : nominatif avec infinitif ;
- `verbis-intellegendis/5` et `verbis-utendis/5` : passif impersonnel.

La répétition est donc obligatoire pour gagner ces quatre cartes.

## Méthode et périmètre

- **Banque** : questions matérialisées des fichiers désignés par les `card.json` sous `assets/designs/grammaticon/places/{theatrum,templum}` ; les index et fichiers compressés sont développés.
- **Jouables** : toutes les instanciations possibles des tuples `aligned` des modèles de `assets/arbor/frames/{theatrum,templum}.json`, filtrés comme `FrameQuestionSource.pool`. Décompte par carte des couples distincts « énoncé affiché + réponse(s) acceptée(s) », sans compter les permutations de choix. Un trou est rendu par `[…]`.
- Les espaces sont normalisés pour rapprocher les instanciations des questions source. Chaque instanciation a été retrouvée dans la banque source ; chaque carte du catalogue possède des modèles jouables.
- Les 22 sections et leur ordre viennent du catalogue actif, dérivé de `reference/frames/<lieu>.cards.json` et déclaré dans `lib/pedagogy/frames/frame_catalogue.dart`.
- **Vocabulaire nouveau** dans les tableaux : identifiant lexical interrogé pour la première fois dans une carte finale, dans l'ordre des sections de ce lieu. **Ancien** : déjà interrogé dans une section antérieure du même lieu. Les deux directions sont comptées séparément.
- Les listes finales coïncident avec l'union des annotations `vocabulary` des questions source de leur section. Elles ne coïncident pas toujours avec le sous-ensemble de questions conservé pour le jeu.
- Un identifiant lexical n'est pas une validation linguistique de lemme ou de sens. Les comptages lexicaux s'appuient sur les annotations existantes, sans lemmatisation indépendante de tout le texte, des aides ou des distracteurs. L'ordre éditorial ne décrit pas l'historique réel d'un joueur qui change de parcours.
- Les modèles sont des regroupements techniques, notamment par corrections et structure des segments : leur nombre n'est pas un nombre certifié de situations pédagogiques indépendantes. Deux énoncés différents peuvent ne changer que le personnage.

L'application distribue les questions des deux lieux via `FrameQuestionSource` (`lib/app/providers.dart:49-54`). L'ancien bilan biblique `doc/theatrum_coverage.md` n'est donc pas le décompte du parcours actif.

## 1. Inventaire exhaustif des cartes de phrases

TH = Theatrum ; TP = Templum. Le nom affiché ci-dessous est celui de la carte TH ; les cartes correspondantes partagent leur identifiant final. Lorsque les sections portent des noms différents, l'en-tête indique **section TH / section TP**. L'ordre des lignes suit TH ; certaines sections TP ordonnent leurs cartes autrement.

### loca

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `a-ablative` — In Italiā | 36 | 36 | 36 | 36 |
| `numerus` — Ūnus et plūrēs | 32 | 32 | 32 | 32 |
| `concordia` — Magnus, magna, magnum | 32 | 32 | 32 | 32 |
| `negatio` — Affirmātiō et negātiō | 32 | 32 | 32 | 32 |

### personae

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `agents` — Quis quem videt? | 32 | 32 | 32 | 32 |
| `possession` — Cuius est? | 40 | 40 | 40 | 40 |
| `reference` — Meus, suus et sē | 32 | 32 | 32 | 32 |
| `giving` — Cui? | 32 | 30 | 32 | 30 |
| `relative-case-role` — Quī et quem | 32 | 30 | 32 | 30 |

### nomina

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `third-subject-object` — Māter et mātrem | 6 | 6 | 6 | 6 |
| `third-genitive` — Mātris, patris, sorōris | 6 | 6 | 6 | 6 |
| `third-dative` — Mātrī, patrī, frātrī | 6 | 6 | 6 | 6 |
| `third-ablative` — Cum mātre, cum patre | 6 | 6 | 6 | 6 |

### demonstratives

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `demonstrative-gender` — Hic, haec, hoc | 6 | 6 | 6 | 6 |
| `demonstrative-accusative` — Hunc, hanc, hoc | 6 | 6 | 6 | 6 |
| `demonstrative-genitive` — Huius et illīus | 6 | 6 | 6 | 6 |
| `demonstrative-dative` — Huic et illī | 6 | 6 | 6 | 6 |

### interrogationes

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `neutral-question` — -ne | 4 | 4 | 4 | 4 |
| `num-question` — Num? | 4 | 4 | 4 | 4 |
| `nonne-question` — Nōnne? | 4 | 4 | 4 | 4 |
| `cur-quia` — Cūr? Quia… | 12 | 12 | 12 | 12 |

### sermo

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `singular-command` — Imperā! | 4 | 4 | 4 | 4 |
| `plural-command` — Imperāte! | 4 | 4 | 4 | 4 |
| `vocative` — Ō amīce! | 4 | 4 | 4 | 4 |
| `eum-eam` — Eum et eam | 6 | 6 | 4 | 4 |
| `eos-eas` — Eōs et eās | 4 | 4 | 4 | 4 |

### actiones

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `passive-patient` — Quis patitur? | 6 | 6 | 6 | 6 |
| `passive-number` — -tur et -ntur | 6 | 6 | 6 | 6 |
| `passive-agent` — Ā quō? | 6 | 6 | 6 | 6 |
| `instrument-agent` — Quō īnstrūmentō? | 6 | 6 | 6 | 6 |

### itinera

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `in-place-motion` — In: ubi an quō? | 6 | 6 | 6 | 6 |
| `town-location` — Rōmae et Tūsculī | 6 | 6 | 6 | 6 |
| `town-destination` — Quō? Rōmam! | 6 | 6 | 6 | 6 |
| `town-origin` — Unde? Rōmā! | 6 | 6 | 6 | 6 |

### tempora

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `04-time` — -at et -ābit; -et et -ēbit | 6 | 6 | 6 | 6 |
| `future-third-fourth` — Legit et leget; audit et audiet | 6 | 6 | 6 | 6 |
| `05-narrative` — Cantābat et cantāvit | 6 | 6 | 6 | 6 |
| `pluperfect-anteriority` — Iam fēcerat | 6 | 6 | 6 | 6 |

### orationes

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `infinitive-subject` — Dīcit puerum cantāre | 6 | 6 | 6 | 6 |
| `infinitive-anteriority` — Cantāre et cantāvisse | 6 | 6 | 6 | 6 |
| `infinitive-posteriority` — Cantātūrum esse | 6 | 6 | 6 | 6 |
| `past-posteriority` — Vīsūrum esse putābat | 6 | 6 | 6 | 6 |

### sententiae

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `07-purpose` — Ut et nē | 6 | 6 | 6 | 6 |
| `purpose-past` — Ut monēret | 6 | 6 | 6 | 6 |
| `08-circumstances` — Puerō cantante | 6 | 6 | 6 | 6 |
| `absolute-perfect` — Epistulā lēctā | 9 | 9 | 9 | 9 |
| `10-sacred` — Causae et cōnsilia | 4 | 4 | 4 | 4 |

### gerundium

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `gerund-ad` — Ad discendum | 6 | 6 | 6 | 6 |
| `gerund-desire` — Cupidus discendī | 6 | 6 | 6 | 6 |
| `gerund-means` — Legendō discere | 6 | 6 | 6 | 6 |
| `gerund-causa` — Discendī causā | 6 | 6 | 6 | 6 |

### casuum-sensus / casuum-electio

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `4` — Possessiō datīvō expressa | 6624 | 576 | 1152 | 96 |
| `1` — Pars et tōtum | 576 | 48 | 552 | 24 |
| `3` — Quālitās genetīvō expressa | 2208 | 96 | 96 | 96 |
| `11` — Quālitās ablātīvō expressa | 26496 | 1752 | 96 | 96 |
| `10` — Quō maior? | 4104 | 456 | 342 | 24 |
| `13` — Quantō differt? | 4807 | 91 | 1045 | 91 |
| `2` — Pretium et aestimātiō | 2208 | 96 | 2208 | 96 |
| `5` — Datīvus fīnis | 8280 | 1680 | 2208 | 96 |
| `6` — Cui et cuī reī? | 6624 | 576 | 552 | 48 |
| `8` — Quam diū? | 26496 | 96 | 2208 | 96 |
| `7` — Spatium itineris | 2208 | 96 | 360 | 96 |
| `9` — Persōna et rēs docta | 6624 | 24 | 552 | 48 |
| `12` — Cūr tremit? | 26496 | 48 | 26496 | 96 |

### nexus-sententiarum / sententiae-subordinatae

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `1` — Tempus relātum | 2208 | 96 | 8280 | 96 |
| `2` — Quid quaeritur? | 8280 | 624 | 360 | 96 |
| `3` — Effectus, nōn cōnsilium | 2208 | 96 | 1416 | 96 |
| `4` — Quamvīs et tamen | 2208 | 96 | 2208 | 96 |
| `5` — Dum et simul | 8280 | 96 | 8280 | 96 |
| `6` — Cum in nārrātiōne | 8280 | 96 | 8280 | 96 |
| `7` — Causa nārrāta | 2208 | 96 | 2208 | 96 |
| `8` — Quī cōnsilium indicat | 8280 | 96 | 2208 | 96 |
| `9` — Quālis sit | 2208 | 48 | 2208 | 48 |
| `10` — Quid timētur? | 8280 | 96 | 8280 | 96 |
| `11` — Quid impeditur? | 8280 | 96 | 8280 | 96 |
| `12` — Quīn post dubitātiōnem negātam | 8280 | 96 | 8280 | 96 |

### res-comparatae / gradus-adiectivorum

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `1` — Comparātīvus | 9600 | 24 | 9600 | 24 |
| `2` — Superlātīvus | 6624 | 48 | 6624 | 48 |
| `3` — Comparātiō irrēgulāris | 16128 | 48 | 16128 | 48 |
| `4` — Adverbia comparāta | 2304 | 48 | 2304 | 48 |

### referentiae-pronominum / pronomina-eligenda

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `1` — Indēfīnīta | 2208 | 96 | 1152 | 96 |
| `2` — Interrogātīva | 2208 | 96 | 2208 | 96 |
| `3` — Relātīva indēfīnīta | 2208 | 96 | 1680 | 96 |
| `4` — Ipse et īdem | 2208 | 96 | 1680 | 96 |

### numerorum-sensus / numeris-exprimere

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `1` — Quot? | 21600 | 24 | 21600 | 24 |
| `2` — Quō ordine? | 18000 | 24 | 21600 | 24 |
| `3` — Quot singulī? | 28800 | 24 | 28800 | 24 |
| `4` — Quotiēns? | 21600 | 24 | 21600 | 24 |

### condiciones-interpretandae / condiciones-componendae

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `1` — Condiciō aperta | 2208 | 24 | 1680 | 24 |
| `2` — Condiciō possibilis | 2208 | 24 | 1680 | 24 |
| `3` — Contrā reī vēritātem | 4416 | 48 | 3360 | 48 |
| `4` — Tempora diversa | 2208 | 24 | 2208 | 24 |

### voluntas-et-consilium / voluntatem-exprimere

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `1` — Hortātiō | 4800 | 24 | 4800 | 24 |
| `2` — Optātiō | 14400 | 48 | 14400 | 48 |
| `3` — Possibilitās | 4800 | 24 | 4800 | 24 |
| `4` — Dēlīberātiō | 9600 | 24 | 9600 | 24 |
| `5` — Prohibitiō | 4800 | 24 | 4800 | 24 |

### formae-non-finitae / formis-non-finitis

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `1` — Participium coniūnctum | 4416 | 48 | 4416 | 48 |
| `2` — Gerundīvum | 120 | 24 | 192 | 72 |
| `3` — Gerundīvī attractiō | 6624 | 48 | 6624 | 72 |
| `4` — Periphrastica actīva | 4416 | 24 | 4416 | 24 |
| `5` — Periphrastica passīva | 2208 | 24 | 2208 | 24 |
| `6` — Supīnum in -um | 2208 | 24 | 2208 | 24 |
| `7` — Supīnum in -ū | 96 | 24 | 96 | 24 |

### oratio-obliqua / orationem-referre

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `1` — Accūsātīvus cum īnfīnītīvō | 288 | 72 | 288 | 72 |
| `2` — Nōminātīvus cum īnfīnītīvō | 4 | 4 | 4 | 4 |
| `3` — Iussa oblīqua | 192 | 24 | 192 | 24 |
| `4` — Interrogātiōnēs in nārrātiōne | 96 | 24 | 192 | 48 |
| `5` — Prōnōmina et loquēns | 8 | 8 | 8 | 8 |

### verbis-intellegendis / verbis-utendis

| Carte | Banque TH | Jouables TH | Banque TP | Jouables TP |
|---|---:|---:|---:|---:|
| `1` — Verba dēpōnentia | 96 | 24 | 96 | 24 |
| `2` — Verba sēmidēpōnentia | 96 | 24 | 96 | 24 |
| `3` — Verba impersonālia | 13 | 13 | 18 | 18 |
| `4` — Verba dēfectīva | 384 | 72 | 384 | 72 |
| `5` — Passīvum impersonāle | 4 | 4 | 4 | 4 |
| `6` — Verbōrum rēgimen | 240 | 48 | 240 | 48 |

## 2. Vocabulaire : inventaire des 44 cartes finales

Chaque ligne décrit la carte `vocabula` de la section. Le total est aussi son nombre de questions jouables. « Nouveau » et « ancien » suivent la définition éditoriale donnée plus haut.

| Section TH / TP | Total TH | Nouveaux TH | Anciens TH | Total TP | Nouveaux TP | Anciens TP |
|---|---:|---:|---:|---:|---:|---:|
| loca | 27 | 27 | 0 | 31 | 31 | 0 |
| personae | 65 | 48 | 17 | 66 | 45 | 21 |
| nomina | 29 | 8 | 21 | 30 | 10 | 20 |
| demonstratives | 34 | 10 | 24 | 34 | 9 | 25 |
| interrogationes | 52 | 17 | 35 | 41 | 10 | 31 |
| sermo | 32 | 3 | 29 | 26 | 3 | 23 |
| actiones | 36 | 20 | 16 | 37 | 20 | 17 |
| itinera | 21 | 4 | 17 | 22 | 6 | 16 |
| tempora | 31 | 3 | 28 | 31 | 3 | 28 |
| orationes | 43 | 5 | 38 | 43 | 5 | 38 |
| sententiae | 90 | 40 | 50 | 103 | 51 | 52 |
| gerundium | 48 | 11 | 37 | 48 | 13 | 35 |
| casuum-sensus / casuum-electio | 104 | 69 | 35 | 110 | 74 | 36 |
| nexus-sententiarum / sententiae-subordinatae | 127 | 69 | 58 | 133 | 67 | 66 |
| res-comparatae / gradus-adiectivorum | 116 | 68 | 48 | 116 | 67 | 49 |
| referentiae-pronominum / pronomina-eligenda | 63 | 19 | 44 | 70 | 21 | 49 |
| numerorum-sensus / numeris-exprimere | 151 | 115 | 36 | 152 | 113 | 39 |
| condiciones-interpretandae / condiciones-componendae | 54 | 10 | 44 | 55 | 9 | 46 |
| voluntas-et-consilium / voluntatem-exprimere | 151 | 115 | 36 | 152 | 115 | 37 |
| formae-non-finitae / formis-non-finitis | 75 | 9 | 66 | 75 | 11 | 64 |
| oratio-obliqua / orationem-referre | 62 | 5 | 57 | 64 | 5 | 59 |
| verbis-intellegendis / verbis-utendis | 97 | 42 | 55 | 97 | 44 | 53 |

### Sections au renouvellement particulièrement faible

- **Sermō** : seulement `ad`, `mēnsa`, `pōnere` sont nouveaux dans les deux lieux. Les anciens représentent 29/32 questions TH et 23/26 TP.
- **Tempora** : seulement `discipulus`, `moneō`, `scrībō` sont nouveaux. Les anciens représentent 28/31 questions dans chaque lieu, soit 90,3 %.
- **Orationes** : seulement `arāre`, `cēnāre`, `crēdō`, `dīcō`, `putāre` sont nouveaux. Les anciens représentent 38/43 questions dans chaque lieu, soit 88,4 %.
- **Itinera TH** : `cubiculum`, `eō`, `Rōma`, `Tūsculum`, soit seulement deux mots communs et deux noms de ville nouveaux selon les annotations.
- **Discours indirect avancé** : seulement `ancora`, `imperō`, `remedium`, `reparō`, `solvō` apparaissent pour la première fois dans les cartes finales. Les anciens représentent 57/62 questions TH et 59/64 TP.

À l'inverse, les sections des nombres introduisent 115/113 entrées nouvelles, largement des animaux et des numéraux ; celles de volonté/conseil, 115 nouvelles dans chaque lieu, largement des aliments et ingrédients. La progression lexicale est donc très irrégulière : quelques nouveautés sur des sections entières, puis des blocs massifs thématiquement concentrés.

Sur les douze premières sections, les cartes finales totalisent 508 questions TH pour 196 identifiants lexicaux distincts, et 512 questions TP pour 206 identifiants distincts.

Exemples de réinterrogation du même identifiant entre sections : `mercator` apparaît dans 18 cartes finales TH et 17 TP ; `sum` dans 17 de chaque côté ; `puer` dans 16 de chaque côté.

### Vocabulaire conservé après disparition des phrases correspondantes

L'extraction conserve toutes les questions lexicales mais seulement un échantillon des phrases. Des mots restent donc dans le bilan d'une section alors qu'ils ne figurent plus dans les annotations d'aucune de ses questions de phrases jouables.

| Section TH / TP | Entrées finales absentes des annotations des phrases jouables TH | TP |
|---|---:|---:|
| casuum-sensus / casuum-electio | 0 | 9 |
| nexus-sententiarum / sententiae-subordinatae | 11 | 11 |
| res-comparatae / gradus-adiectivorum | 15 | 16 |
| numerorum-sensus / numeris-exprimere | 24 | 24 |
| condiciones-interpretandae / condiciones-componendae | 17 | 0 |
| voluntas-et-consilium / voluntatem-exprimere | 23 | 29 |
| verbis-intellegendis / verbis-utendis | 15 | 15 |

Les quinze autres sections ont zéro écart selon cette mesure.

Sur l'ensemble du parcours, seuls 659 des 717 identifiants interrogés au TH, et 664 des 732 au TP, sont déclarés par au moins une question de phrases jouable. **58 identifiants TH et 68 TP sont donc interrogés au vocabulaire sans ce rattachement à une phrase jouable**, même en considérant toutes les sections. Cela ne prouve pas leur absence des aides ou des distracteurs : cette mesure porte sur les annotations des questions.

## 3. Causes de la répétition

### A. Banques réellement petites

Les cartes à quatre ou six questions possèdent déjà ce faible volume dans les banques source. Pour elles, l'échantillonnage n'explique pas la pénurie. Beaucoup des cartes à six questions sont regroupées en trois modèles techniques de deux variantes.

### B. Échantillonnage limité à 24 variantes par modèle

Dans `tool/reference/extract_frames.py:172-200`, l'extraction prend au plus 24 membres par modèle avec un pas régulier. Le champ `instances` garde le nombre original, mais le moteur n'instancie que les tuples `aligned` (`lib/pedagogy/frames/frame_content.dart:104-115`).

Exemples :

- `numerorum-sensus/3` : 28 800 questions source, **24 jouables** ; même bilan au Templum.
- `res-comparatae/1` : 9 600 questions source, **24 jouables** ; même bilan au Templum.
- `casuum-sensus/8` : 26 496 questions source, **96 jouables**.

Sur les deux lieux réunis, 700 417 questions de phrases source deviennent 13 445 questions jouables, soit environ 1,9 % conservées. Ce ratio mesure la réduction de banque, pas la qualité ni le nombre de situations originales perdues.

### C. Variantes de texte souvent superficielles

Exemples directement observés au Templum :

- Les 24 variantes de `formis-non-finitis/6` n'offrent que quatre bonnes réponses distinctes : `audītum`, `rogātum`, `salūtātum`, `vīsum`. Plusieurs variantes conservent le même exercice en remplaçant le médecin par le boulanger, l'arbitre ou le chasseur.
- Les 24 variantes de `formis-non-finitis/7` n'offrent que `audītū`, `dictū`, `factū`, `vīsū`, avec notamment des variantes de « Le médecin / boulanger / arbitre dit : ceci est facile à dire ».
- Les 96 variantes de `sententiae-subordinatae/12` ont toutes **`quīn` comme bonne réponse**. Le nombre de phrases différentes ne garantit pas un choix réellement discriminant.

Une seule réponse possible peut correspondre à un objectif grammatical étroit ; le problème de variété doit donc être jugé aussi sur les contextes, les contrastes et les opérations demandées, au-delà du seul compteur de textes.

### D. Antirépétition au niveau du modèle, sans exclusion de phrase

`lib/pedagogy/frames/frame_question_source.dart:50-60` :

- pondère les modèles par leur nombre d'expositions ;
- réduit à 15 % le poids de ceux joués récemment, sans les exclure ;
- tire ensuite une variante aléatoire du modèle ;
- reçoit `recentSurfaces` mais ne l'utilise pas.

Le contrôleur mémorise seulement les trois derniers identifiants de modèle et douze dernières surfaces (`lib/battle/battle_controller.dart:312-319`). Avec trois modèles pour une carte, après avoir vu les trois, la pénalisation peut s'appliquer à tous : elle ne garantit aucune phrase nouvelle. Avec un seul modèle, elle ne change pas le choix de modèle.

### E. Fin de section définie par tous les mots, sans notion de nouveauté

`tool/sync_section_vocabulary.py:22-36` construit la liste finale par union des `vocabulary` des cartes de la section, puis copie les questions correspondantes. Il n'effectue aucune soustraction des mots des sections précédentes. Les banques observées suivent cette règle.

Le moteur charge ensuite la carte demandée sans filtrage de nouveauté lexicale. L'exposition est enregistrée par identifiant de modèle propre à la carte, avec une liste de lemmes vide (`lib/pedagogy/frames/frame_question_source.dart:76-82`). Un même mot dans deux cartes finales ne partage donc pas un identifiant d'exposition lexicale dans ce tirage.

## 4. Priorités issues de l'audit

1. **Sous-alimentation des cartes** : les 42 cartes à 4–6 questions par lieu, particulièrement le bloc `nomina` → `gerundium`, puis les deux cartes avancées qui exigent huit réponses sur quatre questions.
2. **Ciblage du vocabulaire final** : plus de la moitié des entrées, cumulées sur les sections, portent sur des identifiants déjà interrogés ; plusieurs sections n'apportent que trois à cinq nouveautés.
3. **Cohérence phrases / vocabulaire** : les listes finales reposent sur les banques complètes alors que le jeu ne conserve qu'un sous-ensemble des phrases.
4. **Variété réelle et tirage** : les permutations de personnages et le plafond de 24 variantes par modèle limitent l'intérêt des grosses banques ; l'absence d'exclusion des phrases récentes accentue la répétition.

Le présent document fournit le diagnostic et les comptages pour décider du correctif.
