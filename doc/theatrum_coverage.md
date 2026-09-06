# Theatrum — couverture du vocabulaire et de la morphologie

Généré par `python3 tool/theatrum/build_content.py` le 2026-09-06. Ce rapport distingue explicitement ce qui est **présent dans le corpus importé**, ce qui est **présent dans le contenu jouable validé**, et ce que le joueur a **rencontré** (suivi à l'exécution dans la sauvegarde, `ExposureLedger`, affiché dans la Tabula). L'import du corpus ne vaut pas couverture.

## 1. Corpus importé (latin)

* Édition : Biblia Sacra Vulgata Clementina (textus 1598), editio Migne 1880 — eBible.org, id latVUC, verse-per-line export dated 2026-08-08 (source files 2025-12-12). **Demandé : 1901 Clementine Vulgate (Desclée printing).** The 1901 Desclée printing was requested; no verified digital transcription of it is available. This is the same Clementine recension (Vatican 1598) in the Migne 1880 edition; orthography (æ, j) is kept as in the source.
* 612,221 occurrences, **46,392 formes de surface distinctes** (clé de comparaison : minuscules, æ→ae, j→i).
* Résolues par les moteurs du jeu (verbes + noms vérifiés A&G) : 4,452 formes (127,941 occurrences, 20.9 %).
* Noms propres (heuristique de capitalisation) : 2,333 formes (44,981 occurrences).
* Non résolues (hors lexiques du jeu, sans analyse automatique) : 39,607 formes. Elles sont **inventoriées, pas analysées** ; aucune analyse Collatinus n'est embarquée.

## 2. Contenu jouable validé (Gallicē)

* **132 questions** sur **128 passages**, toutes validées par le script (texte latin exact, rendu français exact de Segond ou rendu pédagogique identifié, trois distracteurs annotés, niveau des distinctions conforme à la progression).
* Rendus fidèles : 105 extraits exacts de Louis Segond 1910, 27 rendus pédagogiques (quand Segond ne rend pas la forme latine visée : temps, nombre, personne ou texte différent).
* Vocabulaire des passages : **330 lemmes**, **542 formes de surface** distinctes, toutes glosées en français dans l'Auxilium.

| Épreuve | Questions |
|---|---|
| `th-numerus` | 12 |
| `th-persona` | 12 |
| `th-casus-recti` | 12 |
| `th-tempus-praeteritum` | 13 |
| `th-tempus-futurum` | 11 |
| `th-casus-obliqui` | 12 |
| `th-congruentia` | 12 |
| `th-modus-imperativus` | 12 |
| `th-vox` | 12 |
| `th-modus-subiunctivus` | 12 |
| `th-nonfinita` | 12 |

Distinctions testées par les distracteurs : casus 40, congruentia 16, modus 33, nonfinita 10, numerus 137, persona 42, tempus 97, vox 21.

## 3. Couverture du corpus par le contenu jouable

* Formes de surface du corpus présentes dans un passage jouable : **542 / 46,392** (1.17 %) ; occurrences couvertes : 282,630 / 612,221 (46.2 %).
* Par statut : verb 110/3686, noun 53/766, proper 18/2333, unresolved 361/39607.

### Catégories morphologiques des moteurs du jeu (formes du corpus couvertes / résolues)

| Catégorie | Couvertes | Résolues dans le corpus |
|---|---|---|
| nomen nom.sg | 22 | 125 |
| nomen voc.sg | 21 | 119 |
| verbum ind.praes.act | 21 | 308 |
| nomen acc.sg | 17 | 129 |
| verbum ind.perf.act | 17 | 347 |
| verbum imp.praes.act | 16 | 119 |
| nomen abl.sg | 13 | 125 |
| nomen nom.pl | 13 | 124 |
| nomen voc.pl | 13 | 124 |
| verbum part.perf.pass | 13 | 365 |
| verbum ind.fut.act | 11 | 310 |
| verbum subj.praes.act | 11 | 309 |
| nomen gen.sg | 10 | 123 |
| nomen acc.pl | 9 | 142 |
| verbum part.praes.act | 8 | 393 |
| nomen dat.sg | 6 | 110 |
| nomen abl.pl | 5 | 114 |
| nomen dat.pl | 5 | 114 |
| verbum inf.praes.act | 5 | 75 |
| verbum ind.fut.pass | 4 | 126 |
| nomen gen.pl | 3 | 98 |
| verbum ind.praes.pass | 3 | 161 |
| verbum sup.acc | 3 | 46 |
| verbum imp.praes.pass | 2 | 65 |
| verbum ind.imperf.act | 2 | 193 |
| verbum ind.plusq.act | 2 | 107 |
| verbum inf.praes.pass | 2 | 43 |
| verbum subj.imperf.act | 2 | 201 |
| verbum subj.praes.pass | 2 | 111 |
| verbum part.fut.act | 1 | 86 |
| verbum subj.imperf.pass | 1 | 63 |
| nomen loc.pl | 0 | 2 |
| nomen loc.sg | 0 | 3 |
| verbum gdv.abl.pl | 0 | 2 |
| verbum gdv.abl.sg | 0 | 26 |
| verbum gdv.acc.pl | 0 | 17 |
| verbum gdv.acc.sg | 0 | 44 |
| verbum gdv.dat.pl | 0 | 2 |
| verbum gdv.dat.sg | 0 | 21 |
| verbum gdv.gen.sg | 0 | 13 |

Catégories résolues dans le corpus mais **sans aucune forme couverte** (26) : nomen loc.pl, nomen loc.sg, verbum gdv.abl.pl, verbum gdv.abl.sg, verbum gdv.acc.pl, verbum gdv.acc.sg, verbum gdv.dat.pl, verbum gdv.dat.sg, verbum gdv.gen.sg, verbum gdv.nom.pl, verbum gdv.nom.sg, verbum gdv.voc.pl, verbum gdv.voc.sg, verbum ger.abl, verbum ger.acc, verbum ger.dat, verbum ger.gen, verbum imp.fut.act, verbum imp.fut.pass, verbum ind.futex.act, verbum ind.imperf.pass, verbum inf.fut.act, verbum inf.perf.act, verbum subj.perf.act, verbum subj.plusq.act, verbum sup.abl.

## 4. Lacunes

### Formes les plus fréquentes du corpus sans couverture jouable (noms propres exclus)

| Forme | Occurrences | Statut | Exemple |
|---|---|---|---|
| per | 1930 | unresolved | GEN 4:1 |
| eis | 1466 | unresolved | GEN 1:22 |
| eo | 1343 | verb | GEN 2:17 |
| ait | 1237 | verb | GEN 1:11 |
| rex | 1153 | noun | GEN 14:1 |
| terram | 1130 | noun | GEN 1:1 |
| eam | 1052 | verb | GEN 1:28 |
| ne | 1051 | unresolved | GEN 2:17 |
| quasi | 991 | unresolved | GEN 3:22 |
| dicit | 983 | verb | GEN 22:16 |
| nec | 954 | unresolved | GEN 11:6 |
| dicens | 906 | verb | GEN 1:22 |
| contra | 895 | unresolved | GEN 2:14 |
| suo | 797 | unresolved | GEN 1:24 |
| quoque | 796 | unresolved | GEN 1:6 |
| sua | 792 | unresolved | GEN 8:21 |
| neque | 741 | unresolved | GEN 9:11 |
| illi | 736 | unresolved | GEN 6:22 |
| illis | 712 | unresolved | GEN 1:28 |
| domum | 690 | noun | GEN 12:15 |
| regis | 688 | verb | GEN 14:17 |
| terrae | 677 | noun | GEN 1:24 |
| manu | 661 | noun | GEN 4:11 |
| quem | 659 | unresolved | GEN 2:8 |
| illius | 642 | unresolved | GEN 2:12 |
| es | 636 | verb | GEN 3:9 |
| domus | 633 | noun | GEN 7:1 |
| iuxta | 619 | unresolved | GEN 1:11 |
| filiis | 603 | noun | GEN 9:1 |
| ante | 597 | unresolved | GEN 3:24 |
| nunc | 589 | unresolved | GEN 2:23 |
| tuo | 582 | unresolved | GEN 3:17 |
| cumque | 575 | unresolved | GEN 2:21 |
| locutus | 560 | verb | GEN 8:15 |
| diebus | 552 | noun | GEN 3:14 |
| illum | 539 | unresolved | GEN 1:27 |
| regem | 537 | noun | GEN 14:2 |
| aut | 534 | unresolved | GEN 19:12 |
| viri | 522 | noun | GEN 3:16 |
| ibi | 509 | unresolved | GEN 2:12 |
| atque | 502 | unresolved | GEN 1:21 |
| sui | 490 | unresolved | GEN 1:29 |
| quibus | 480 | unresolved | GEN 1:30 |
| esset | 477 | verb | GEN 1:4 |
| ille | 463 | unresolved | GEN 15:8 |
| domo | 461 | noun | GEN 12:1 |
| illa | 459 | unresolved | GEN 8:11 |
| misit | 451 | verb | GEN 19:13 |
| ita | 449 | verb | GEN 1:7 |
| filiorum | 445 | noun | GEN 6:18 |
| vir | 439 | noun | GEN 6:9 |
| millia | 437 | unresolved | GEN 24:60 |
| faciem | 433 | unresolved | GEN 1:2 |
| ac | 426 | unresolved | GEN 1:14 |
| fratres | 424 | noun | GEN 13:8 |
| numquid | 417 | unresolved | GEN 18:14 |
| fuit | 414 | verb | GEN 4:2 |
| tuae | 412 | unresolved | GEN 3:14 |
| conspectu | 411 | unresolved | GEN 24:33 |
| tunc | 408 | unresolved | GEN 12:6 |

### Formes résolues par les moteurs (verbes/noms du jeu) sans couverture jouable, les plus fréquentes

| Forme | Occurrences | Analyses |
|---|---|---|
| eo | 1343 | eo:ind.praes.act.1.sg |
| ait | 1237 | aio:ind.perf.act.3.sg, aio:ind.praes.act.3.sg |
| rex | 1153 | rex:nom.sg, rex:voc.sg |
| terram | 1130 | terra:acc.sg |
| eam | 1052 | eo:subj.praes.act.1.sg |
| dicit | 983 | dico:ind.praes.act.3.sg |
| dicens | 906 | dico:part.praes.act.acc.sg.n, dico:part.praes.act.nom.sg.f, dico:part.praes.act. |
| domum | 690 | domus:acc.sg |
| regis | 688 | rego:ind.praes.act.2.sg, rex:gen.sg |
| terrae | 677 | terra:dat.sg, terra:gen.sg, terra:nom.pl, terra:voc.pl |
| manu | 661 | manus:abl.sg |
| es | 636 | edo:imp.praes.act.2.sg, edo:ind.praes.act.2.sg, sum:imp.praes.act.2.sg, sum:ind. |
| domus | 633 | domus:acc.pl, domus:gen.sg, domus:nom.pl, domus:nom.sg, domus:voc.pl, domus:voc. |
| filiis | 603 | filia:abl.pl, filia:dat.pl, filius:abl.pl, filius:dat.pl |
| locutus | 560 | loquor:part.perf.pass.nom.sg.m |
| diebus | 552 | dies:abl.pl, dies:dat.pl |
| regem | 537 | rex:acc.sg |
| viri | 522 | vir:gen.sg, vir:nom.pl, vir:voc.pl |
| esset | 477 | edo:subj.imperf.act.3.sg, sum:subj.imperf.act.3.sg |
| domo | 461 | domus:abl.sg, domus:dat.sg |
| misit | 451 | mitto:ind.perf.act.3.sg |
| ita | 449 | eo:part.perf.pass.abl.sg.f, eo:part.perf.pass.acc.pl.n, eo:part.perf.pass.nom.pl |
| filiorum | 445 | filius:gen.pl |
| vir | 439 | vir:nom.sg, vir:voc.sg |
| fratres | 424 | frater:acc.pl, frater:nom.pl, frater:voc.pl |
| fuit | 414 | sum:ind.perf.act.3.sg |
| principes | 406 | princeps:acc.pl, princeps:nom.pl, princeps:voc.pl |
| dedit | 400 | do:ind.perf.act.3.sg |
| dixerunt | 387 | dico:ind.perf.act.3.pl |
| fuerit | 385 | sum:ind.futex.act.3.sg, sum:subj.perf.act.3.sg |
| viam | 330 | via:acc.sg |
| dicentes | 327 | dico:part.praes.act.acc.pl.f, dico:part.praes.act.acc.pl.m, dico:part.praes.act. |
| diem | 317 | dies:acc.sg |
| erunt | 313 | sum:ind.fut.act.3.pl |
| civitatem | 310 | civitas:acc.sg |
| nomine | 294 | nomen:abl.sg |
| caput | 283 | caput:acc.sg, caput:nom.sg, caput:voc.sg |
| venerunt | 282 | venio:ind.perf.act.3.pl |
| exercituum | 281 | exercitus:gen.pl |
| sacerdotes | 257 | sacerdos:acc.pl, sacerdos:nom.pl, sacerdos:voc.pl |

### Ce qui manque, explicitement

* 45,850 formes de surface du corpus (98.8 %) n'apparaissent dans aucune question. L'objectif « tout le vocabulaire du corpus » n'est **pas** atteint : le parcours actuel couvre le noyau grammatical avec 132 questions validées ; l'extension se fait dans `tool/theatrum/items_fr.py` (même format, même validation).
* Les livres absents de Segond (Tobie, Judith, Sagesse, Siracide, Baruch, 1–2 Maccabées, Esther 11–16, Daniel 13–14) ne peuvent recevoir que des rendus pédagogiques identifiés ; aucun n'est encore rédigé.
* Anglicē : aucun contenu (le fichier `renderings_en.json` n'existe pas) ; la langue est visible mais non sélectionnable.

## 5. Suivi côté joueur

La sauvegarde (`expo`) compte, par lemme du contenu jouable : occurrences rencontrées, passages distincts (≥ 2 = « rencontré à nouveau dans un autre contexte »), fois où le lemme était la forme interrogée, et par question le nombre de parties jouées. La sélection (`ReadingQuestionSource.weight`) favorise les questions jamais jouées et le vocabulaire jamais ou peu rencontré, et les questions familières quand une révision est due. Ces compteurs sont affichés dans la Tabula à part de la maîtrise et n'y contribuent jamais.
