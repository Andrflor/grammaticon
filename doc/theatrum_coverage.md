# Theatrum — couverture du vocabulaire

Généré par `python3 tool/theatrum/vocab.py coverage`. Définitions appliquées :

* **Entrée de vocabulaire** : un lemme du corpus clémentin tel que résolu par les lexiques Collatinus (`tool/corpus/bible/lemmatize.py`), ou, pour une forme qu'aucun lexique ne résout, la forme elle-même. Toutes les entrées restent au dénominateur ; noms propres et formes non résolues sont comptés à part, jamais retirés.
* **Avec sens vérifié** : l'entrée possède une glose française (Collatinus `lemmes.fr` / `lem_ext.fr`, ou glose rédigée dans le contenu).
* **Enseignée** : au moins une question validée et livrée dont le **passage latin** (pas seulement le verset) contient une forme de l'entrée, dont le rendu français fidèle traduit ce passage, et dont l'Auxilium affiche le lemme et le sens français de l'entrée. Une présence dans le verset hors du passage ne compte pas ; un mot sans glose ne compte pas.
* **Interrogée** : l'entrée est la forme décisive d'une question ou une forme qu'un distracteur lit de travers.
* **Pondérée** : idem, pondéré par le nombre d'occurrences dans le corpus.

**Seuil d'acceptation : 90% des entrées enseignées** (`python3 tool/theatrum/vocab.py check` échoue en dessous). État : **NON ATTEINT**.

## Chiffres

| Mesure | Valeur |
|---|---|
| Questions validées livrées | 172 sur 168 passages |
| Entrées de vocabulaire (dénominateur) | **11,785** = 7,773 communes + 3,653 noms propres + 359 formes non résolues |
| Entrées avec sens français vérifié | 8,788 (74.57 %) |
| Entrées **enseignées** dans le contenu jouable | **626 (5.31 %)** — communes 545, noms propres 75, non résolues 6 |
| Entrées **interrogées** (cible ou portion d'un distracteur) | 223 (1.89 %) |
| Formes écrites distinctes couvertes | 903 / 46,388 |
| Couverture pondérée par la fréquence | 67.89 % des occurrences |

## Corpus et résolution

* 612,221 occurrences, 46,388 formes distinctes ; résolues par les lexiques : 41,604 formes (578,025 occurrences), noms propres 4,425 formes (33,280 occ.), non résolues 359 formes.
* 8,838 lemmes (7,773 communs, 1,065 noms propres), 8,745 avec glose Collatinus.

## Entrées non enseignées (11,159)

Les plus fréquentes :

| Entrée | Type | Occurrences | Sens |
|---|---|---|---|
| ājo | common | 1255 | affirmer; (ait :) dit-il, dit-elle |
| Dāvīd | proper | 1106 | David, roi des Hébreux |
| nē2 | common | 1051 | que (verbes de crainte et d'empêchement), de ne pas (verbes  |
| Jūda | proper | 1005 | Juda (chef d'une tribu d'Israël) |
| rēspōndĕo | common | 888 | répondre |
| sērvŏs | common | 872 | — |
| ānnus | common | 852 | année |
| Jerusălem | proper | 830 | — |
| săcērdōs | common | 812 | prêtre |
| Mōȳsēs | proper | 751 | Moïse (législateur des Juifs). |
| nĕquĕ | common | 741 | (et ne ...) pas |
| ăqua | common | 707 | eau |
| sērmō | common | 652 | entretien, conversation ; le dialogue, discussion ; le disco |
| ēxērcĭtus | common | 637 | armée |
| jūxtā | common | 619 | à côté ; à côté de (prép. acc.) |
| rĕvērtŏr,rĕvōrtŏr | common | 604 | revenir |
| āntĕ | common | 597 | devant, avant ; (adv.) avant |
| nūnc | common | 589 | maintenant |
| ălĭus | common | 584 | autre, un autre, (alius... alius) l'un, l'autre |
| cūmquĕ | common | 575 | en toutes circonstances |
| ōs2 | common | 574 | visage, bouche, entrée, ouverture |
| scrībo | common | 566 | tracer, écrire ; mettre par écrit ; rédiger ; inscrire, enrô |
| cŏmĕdo | common | 550 | manger |
| prāecĭpĭo | common | 549 | prendre avant, premier ; recommander, conseiller, ordonner ; |
| fōrtĭs | common | 538 | fort, vigoureux, courageux |
| trādo | common | 531 | transmettre, remettre ; livrer ; enseigner |
| tăbērnācŭlŭm | common | 473 | tente |
| ēgrĕdĭŏr | common | 469 | sortir |
| glădĭus | common | 469 | glaive |
| jūstus | common | 462 | juste, équitable, raisonnable |
| fĕro | common | 452 | porter, supporter, rapporter |
| ĭtā | common | 449 | ainsi, de cette manière (ita... ut, ainsi que) |
| cōnspēctus | common | 433 | vue, regard |
| īntērfĭcĭo | common | 424 | tuer |
| tēmplŭm | common | 423 | temple |
| pōrta | common | 420 | porte (d'une ville) |
| nūmquid,nūnquĭd | common | 417 | est-ce que |
| tūnc | common | 410 | alors |
| cōngrĕgo | common | 405 | (tr.) rassembler (en troupeau), réunir, joindre, associer |
| căpŭt | common | 403 | tête ; l'extrémité ; personne ; vie, existence ; capitale |
| dēscēndo | common | 403 | descendre (- in certamen : en venir au combat) |
| ăbĕo | common | 402 | s'éloigner, partir |
| ĭnĭmīcus2 | common | 401 | ennemi |
| āltăr | common | 400 | — |
| jūstĭtĭa | common | 400 | justice, esprit de justice |
| mūltĭtūdō | common | 394 | foule, grand nombre |
| sēptĕm | common | 393 | sept |
| pānĭs | common | 390 | pain |
| ăgo | common | 390 | (en parlant des êtres animés ou personnifiés) faire, pousser |
| crēdo | common | 383 | confier en prêt ; tenir pour vrai ; croire ; avoir confiance |
| mĭsĕrĭcōrdĭa | common | 380 | pitié |
| ĭtăquĕ | common | 378 | c'est pourquoi, aussi, par conséquent |
| ūrbs | common | 377 | ville |
| dēsĕro | common | 374 | abandonner |
| Săūl | proper | 374 | Saül [premier roi des Hébreux] |
| prīmus | common | 365 | premier (comparatif : prior) |
| cōnvērto | common | 363 | tourner complètement |
| vīrtūs | common | 363 | courage, honnêteté |
| ĭgĭtŭr | common | 362 | donc |
| sīngŭlus | common | 357 | isolé (- numerus : le singulier) |
| fŭgĭo | common | 356 | s'enfuir, fuir |
| Jūdāei | proper | 355 | les Juifs |
| săpĭēntĭa | common | 353 | sagesse |
| cărō̆ | common | 348 | chair, viande |
| fīnĭs | common | 346 | limite, fin ; (pl.), frontière, territoire |
| āurŭm | common | 344 | or |
| āufĕro | common | 340 | emporter |
| mēnsĭs | common | 337 | mois |
| lăpĭs | common | 334 | pierre |
| āltĕr | common | 333 | autre (de deux) [subst. m.] ; [alteri ... alteri] les uns, l |
| sāecŭlŭm | common | 329 | époque, âge |
| bĭbo | common | 329 | boire |
| rēgno | common | 329 | régner |
| dōnĕc | common | 328 | jusqu'à ce que |
| Jācōb | proper | 328 | Jacob [troisième patriarche] |
| mātĕr | common | 323 | mère |
| pŭĕr | common | 322 | enfant, jeune esclave |
| Ăărōn | proper | 322 | Aaron [grand prêtre des Hébreux] |
| līgnŭm | common | 321 | bois |
| ēxĕo | common | 321 | sortir de, aller hors de ; partir |

Entrées sans sens français (2,997) : sērvŏs, Jerusălem, āltăr, Joab, Assyriorum, Gad, Babylonem, Bethel, quādrīngēntus, Basan, Sadoc, Jehu, Joram, frūx, Jerosolymis, Asaph, Jerosolymam, tēsto, dŭcēntus, Seir, Nun, Emath, dēlĭcĭa, Sehon, Balac, synagoga, Ramoth, Hai, Jojada, Babylone, Saphan, Jabes, hyacintho, Sarviæ, Jojadæ, prēsbўtĕr,prēsbĭtĕr, Ælam, attende, Hananīas, Babylon, Lachis, Mosollam, Machir, Og, Maspha, Achis, Amos, Attendite, cōnvāllĭs, Masphath, Nabal, Adarezer, Naboth, ōctīngēntus, Euphrātes2, jūsjūrāndŭm, Nadab, Ahicam, synagogis, Hazăĕl …

## Exclusions

Aucune. Les noms propres et les formes non résolues figurent au dénominateur et dans les listes ci-dessus. Les livres absents de Segond (Tobie, Judith, Sagesse, Siracide, Baruch, 1–2 Maccabées, Esther 11–16, Daniel 13–14) sont dans le corpus et leurs mots comptent ; leurs passages exigent un rendu pédagogique identifié.
