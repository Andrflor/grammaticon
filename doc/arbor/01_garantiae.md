# Garanties de couverture du nouveau moteur

Le moteur génère les questions et leurs distracteurs à la volée, à partir de l'arbre des compétences (`00_schema.md`) et des générateurs de formes. Il ne précharge aucune banque. **En échange, il doit garantir tout ce que les 1 594 015 questions pré-générées couvraient.** Ce document liste ces garanties, établies par inventaire des banques actuelles (445 cartes, 14 septembre 2026), et le test qui vérifie chacune. Une garantie sans test n'en est pas une.

Principe de vérification : pour chaque ligne, un test `test/arbor/garantiae_test.dart` demande au générateur de produire *N* questions pour le nœud ou la dimension visée et vérifie (a) qu'il y parvient, (b) que chaque distracteur porte un diagnostic non vide et différent de la réponse, (c) que les formes produites correspondent au conjugueur et au déclinateur (oracle Collatinus au moment du développement, comme avant).

## A. Amphitheatrum — système verbal (93 cartes, 682 207 questions)

### A.1 Dimensions de question à produire

| Dimension | Question | Distracteurs | Existant |
|---|---|---|---|
| `persona` | Quae persōna ? | les deux autres personnes, même case sinon | oui |
| `numerus` | Quī numerus ? | l'autre nombre | oui |
| `personaNumerus` | Quae persōna et quī numerus ? | voisins à une dimension | oui |
| `tempus` | Quod tempus ? | temps voisins du même mode et de la même voix, en priorité les confusions déclarées (`confunditur`) | oui |
| `modus` | Quī modus ? | modes possibles pour la surface | oui |
| `tempusModus` | Quod tempus, quī modus ? | couples voisins | oui |
| `vox` | Quae vōx ? | l'autre voix ; pour un déponent, la voix morphologique et la voix sémantique | oui |
| `voxSensus` | Quae vōx sēnsū ? (déponents, semi-déponents) | idem | oui |
| `tempusSensus` | Quod tempus sēnsū ? (défectifs : ōdī, meminī) | temps morphologique vs temps de sens | oui |
| `coniugatio` | Quae coniugātiō ? | les autres classes | oui |
| `lemma` | Quod verbum ? | lemmes de même famille ou même classe (composés de eō, ferō…) | oui |
| `forma` | Quae fōrma ? (gerundium / gerundīvum / participium / supīnum / īnfīnītīvus) | formes nominales voisines | oui |
| `formaPlena` | Quae fōrma plēna ? (surface → surface) | formes du même paradigme, une dimension changée | oui |
| `analysis` | Quae analysis ? (analyse complète) | voisins à une dimension, triés par proximité | oui |
| `casus`, `genus`, `numerus` sur formes nominales du verbe (participes, gérondif, adjectif verbal, supin) | | | oui |

Toute question réalise la même interaction qu'aujourd'hui : `choice`, forme isolée sans contexte. **Nouveau, exigé par le schéma** : chaque distracteur porte le diagnostic calculé par différence de maillons ; un distracteur qui diffère sur plus de deux maillons est rejeté, un distracteur de différence vide (syncrétisme réel : *amāvēre* = 3 pl. perf. et inf.) est traité comme réponse acceptée, pas comme distracteur.

### A.2 Étendue morphologique

Le générateur doit produire, pour chaque verbe du lexique, l'ensemble des cases existantes :

- **Indicatif** : praesēns, imperfectum, futūrum, perfectum, plūsquamperfectum, futūrum exāctum — actif et passif (cartes `section-1`, 12 cartes).
- **Subjonctif** : praesēns, imperfectum, perfectum, plūsquamperfectum — actif et passif (`section-2`, 8 cartes).
- **Impératif** : praesēns et futūrum, actif et passif (`section-3`).
- **Formes nominales** : infinitifs (praes., perf., fut., act. et pass.), participes (praes. act., perf. pass., fut. act.), gérondif, adjectif verbal, supin en -um et en -ū (`section-4`).
- **Périphrastiques** : active (*amātūrus sum*, tous temps) et passive (*amandus sum*, tous temps) (`section-5`).
- **Verbes anomaux** : *sum* et composés (*possum, absum, prōsum*…), *eō* et composés (*redeō, exeō, trānseō*…), *ferō* et composés (*auferō, referō, offerō*…), *fīō* / *faciō*, *dō*, *edō*, *volō, nōlō, mālō* (`section-6`).
- **Verbes spéciaux** : déponents (*sequor, hortor, patior*…), semi-déponents (*audeō, gaudeō, soleō, fīdō*), défectifs (*ōdī, meminī, coepī, inquam, āiō*), impersonnels (*licet, oportet, pluit*…), passif impersonnel (*pugnātur, ītur*) (`section-7`, `verbis-utendis`).
- **Variantes** : formes contractées (*amāsse, amārunt*), *forem / fore*, *-undus*, formes archaïques et tardives, avec le statut de variante conservé par le conjugueur (`VariantKind`).
- **Lexique verbal** : les 113 lemmes verbaux actuels (liste dans `assets/designs/grammaticon/…/mx-omnia`, à exporter dans `50_lexicon.md`) sont le minimum ; le nouveau lexique les contient tous.

### A.3 Paires de confusion travaillées comme cartes

Les cartes `section-8` à `section-11` isolaient des **paires ou triplets de temps ou de modes** : praesēns / imperfectum, praesēns / futūrum, praesēns / perfectum, imperfectum / plūsquamperfectum, perfectum / plūsquamperfectum, plūsquamperfectum / futūrum exāctum, futūrum / futūrum exāctum, système du présent, système du parfait, tous les temps de l'indicatif, tous ceux du subjonctif, les temps de l'infinitif ; indicatif / subjonctif à chaque temps, indicatif / impératif, infinitif / impératif, infinitif / subjonctif imperfectum, futūrum / subjonctif praesēns ; les modes du présent, tous les modes.

**Garantie** : chacune de ces paires est une arête `confunditur` de `30_verbal.md` (marqueur contre marqueur), et le générateur sait produire une question dont les distracteurs se limitent à la paire. Test : pour chaque arête `confunditur` de type `similitudo` ou `syncretismus` entre marqueurs verbaux, le générateur produit une question à deux choix qui isole la paire.

### A.4 Mixtes

Les sept cartes `mx-*` (temps de l'indicatif actif, passif, du subjonctif, modes, voix, familles anomales, tout) ne sont plus des banques de 58 000 à 258 000 entrées : ce sont des ensembles de nœuds cibles ; la sélection à trois files fait le mélange. Garantie : une carte peut déclarer un ensemble de nœuds et une pondération par groupe (`selectionGroups` : analysis, forma, modus, tempus, vox, lemma, personaNumerus), et le tirage respecte la pondération à ±5 % sur 10 000 tirages simulés.

## B. Forum — système nominal (78 cartes, 208 347 questions)

### B.1 Dimensions

`casus`, `numerus`, `genus`, `declinatio`, `lemma`, `analysis`, `forma`, `classis` (classe d'adjectif), `gradus`, `genusNumerus` (relatif : depuis l'antécédent), `functio` (fonction dans la phrase), `constructio` (ablatif de comparaison / *quam*, *in* + abl. / acc.…), `relatio` (à qui renvoie *suus / eius*), `quodNomen` (avec quel nom s'accorde l'adjectif), `correlativum`, `valor` (valeur d'un numéral), `persona` (pronoms personnels).

Deux interactions : `choice` (forme isolée, **toute lecture de la surface est acceptée**) et `highlightChoice` (mot marqué dans un syntagme de 2 à 5 mots, **seule la lecture imposée par le contexte est acceptée**). La seconde exige des **syntagmes authored** : les 763 syntagmes de l'ancien code (`lib/pedagogy/forum/syntagmata/`, commit `9bc4ad13`) sont récupérés, chacun avec ses diagnostics écrits.

### B.2 Étendue

- **Déclinaisons** : 1re ; 2e en -us, -er, neutres ; 3e consonantique, à thème en -i-, neutres, mixte ; 4e (m. et n.) ; 5e ; locatif ; noms de villes. Lexique : 340 noms minimum (LLPSI ch. 1-19), 579 lexèmes nominaux au total dans les banques actuelles.
- **Adjectifs** : 1re/2e classe (dont -er), 3e classe à une, deux, trois terminaisons ; pronominaux (*ūnus, sōlus, tōtus, alius, alter, uter, neuter, nūllus, ūllus*).
- **Comparaison** : formation régulière, flexion du comparatif, irrégulière (*bonus / melior / optimus*…), adverbes et leurs degrés, ablatif de comparaison / *quam*.
- **Pronoms** (paradigmes explicites, pas de règle) : *ego, tū, nōs, vōs, sē* ; possessifs ; *is, hic, ille, iste, ipse, īdem* ; *quī, quis* ; indéfinis (*aliquis, quīdam, quisque, quisquam, nēmō, nihil, nūllus*) ; corrélatifs (*tantus … quantus, tālis … quālis, tot … quot*) ; oppositions *mē / mihi*, *suus / eius*, *quis / quī*.
- **Numéraux** : *ūnus, duo, trēs* ; cardinaux ; *mīlle / mīlia* ; ordinaux ; distributifs et adverbes numéraux (via Theatrum).
- **Syncrétismes** (13 cartes) : -a / -ā, -ae, -e / -ē, -ēs, -ī, -ibus, -is / -īs, neutres nom. = acc., -ō, -um, -us / -ūs, quantité vocalique. **Garantie** : chaque syncrétisme est dérivé automatiquement par la règle L2 (deux cases de même surface dans un même paradigme ou entre paradigmes) et le générateur sait poser la question « quelles lectures ? » avec, en distracteurs, les lectures impossibles pour cette surface.
- **Accord** : simple, adjectif et nom de déclinaisons différentes, apposition, adjectif éloigné du nom, plusieurs noms pour un adjectif.
- **Cas dans la phrase** : prépositions avec abl., avec acc., à double cas ; ablatif de temps ; verbes à l'ablatif (*ūtor, fruor*…), au datif (*pāreō, placeō*…), au génitif (*meminī, oblīvīscor*, adjectifs *plēnus, cupidus*).

## C. Theatrum — latin → français (137 cartes, 399 000 questions) et D. Templum — français → latin (137 cartes, 304 000 questions)

Les deux lieux sont **symétriques** : mêmes 22 sections, mêmes concepts, le Theatrum lit (`course.reading`, interaction `choice` sur des traductions françaises), le Templum produit (`course.production`, interaction `gapChoice` à trou dans une phrase latine, ou `choice` entre phrases latines). Chaque section se termine par une carte **Vocābula** (latin → français au Theatrum, français → latin au Templum) couvrant l'union des lemmes de la section.

### C.1 Concepts couverts, par section (identiques dans les deux lieux)

| Section | Cartes (concepts) |
|---|---|
| Locī et rēs | *in Italiā* (-a / -ā) ; accord *magnus, -a, -um* ; affirmation et négation ; singulier / pluriel |
| Locī et nōmina (3e décl.) | sujet / objet ; génitif ; datif ; ablatif avec *cum* |
| Persōnae | qui voit qui ; *cui* ; *cuius est* ; *meus / suus / sē* ; *quī / quem* |
| Sermō et imperia | *eum / eam* ; *eōs / eās* ; impératif sg. ; impératif pl. ; vocatif |
| Tempora et nārrātiō | -at / -ābit, -et / -ēbit ; imparfait / parfait ; futur 3e et 4e conj. ; plus-que-parfait d'antériorité |
| Agentēs et patientēs | instrument ; agent *ā / ab* ; -tur / -ntur ; qui subit |
| Itinera | *in* + abl. / acc. ; *Rōmam* ; *Rōmae, Tūsculī* ; *Rōmā* |
| Dēmōnstrātīva | *hunc, hanc, hoc* ; *huic, illī* ; *hic, haec, hoc* ; *huius, illīus* |
| Interrogātiōnēs | *cūr / quia* ; *-ne* ; *nōnne* ; *num* |
| Ōrātiōnēs (infinitives) | antériorité *cantāvisse* ; postériorité *cantātūrum esse* ; sujet à l'acc. ; futur après verbe au passé |
| Sententiae coniūnctae | *ut / nē* ; ablatif absolu au participe présent ; ablatif absolu au participe parfait ; *ut* après un passé ; causes et buts |
| Gerundium | *ad* + gér. ; *causā* + gér. ; *cupidus* + gér. ; gérondif de moyen |
| Cāsūs (13 cartes) | partitif ; prix et estimation ; génitif de qualité ; datif de possession ; datif de but ; double datif ; accusatif d'étendue ; durée ; double accusatif (*doceō*) ; ablatif de comparaison sans *quam* ; ablatif de qualité ; ablatif de cause ; ablatif de mesure de la différence |
| Verba (6 cartes) | déponents ; semi-déponents ; impersonnels ; défectifs ; passif impersonnel ; régime des verbes |
| Gradūs / Rēs comparātae | comparatif ; superlatif ; comparaison irrégulière ; adverbes comparés |
| Numerī (4 cartes) | *quot* (cardinaux) ; *quō ōrdine* (ordinaux) ; *quot singulī* (distributifs) ; *quotiēns* (adverbes numéraux) |
| Prōnōmina ēligenda / referentiae | indéfinis ; interrogatifs ; relatifs indéfinis ; *ipse / īdem* |
| Voluntās (5 cartes) | hortatif ; optatif ; potentiel ; délibératif ; prohibition |
| Condiciōnēs (4 cartes) | condition ouverte ; potentielle ; irréelle ; temps mixtes |
| Ōrātiō oblīqua (5 cartes) | acc. + inf. ; nom. + inf. ; ordres indirects ; interrogatives indirectes ; pronoms et locuteur |
| Fōrmae nōn fīnītae (7 cartes) | participe conjoint ; adjectif verbal ; attraction de l'adjectif verbal ; périphrastique active ; passive ; supin en -um ; supin en -ū |
| Sententiae subordinātae / nexus (12 cartes) | concordance des temps ; interrogative indirecte ; consécutive ; concessive (*quamvīs … tamen*) ; *dum* ; *cum* narratif ; causale ; relative finale ; relative de caractéristique ; verbes de crainte ; verbes d'empêchement ; *quīn* après doute nié |

### C.2 Ce que le moteur doit garantir ici

Ces sections ne se génèrent pas par un conjugueur : elles reposent sur des **phrases authored** avec des **distracteurs à diagnostic écrit**. Les banques actuelles ont 703 000 questions pour ~1 070 lemmes et 48 personnages, obtenues par produit cartésien de cadres (*personne × animal × objet*) : la même phrase avec *mercātor / pistor / nauta*. Le contenu réel est le **nombre de cadres**, pas le nombre de questions.

Garanties :

1. **Chaque concept du tableau C.1 est un nœud L3** de `40_syntaxis.md` (ou un groupe de nœuds), avec ses confusions déclarées (ex. `syn.abl.instrumentum` ↔ `syn.abl.locus` ; `syn.cond.irrealis` ↔ `syn.cond.potentialis`).
2. **Chaque nœud L3 dispose d'au moins 8 cadres authored par sens** (lecture, production), chaque cadre déclare ses emplacements variables (personne, objet…) et le lexique admissible ; le moteur instancie les cadres avec le lexique, ce qui reproduit la variété actuelle sans la stocker. Un cadre porte pour chaque distracteur son diagnostic (nœud + `modus`). Test : validation refuse un cadre sans diagnostic ou dont un distracteur est une traduction également correcte.
3. **Lecture** : distracteur = traduction française qui incarne une mauvaise lecture d'un maillon précis (cas, temps, mode, référent, nombre) ; **production** : distracteur = forme latine qui incarne le maillon fautif (`nautīs` pour `nautārum` = confusion datif / génitif partitif). Les deux sens partagent les mêmes cadres.
4. **Vocābula** : le générateur produit la carte lexicale d'une section à partir des lemmes de ses cadres, dans les deux sens ; un lemme, une entrée, distracteurs = lemmes sémantiquement voisins déclarés dans L4 (`confunditur … sensus`).
5. **Mandat lexical** : le lexique cible couvre ≥ 90 % du vocabulaire du corpus visé (Familia Romana d'abord : 1 899 candidats dans `doc/pedagogy/contracts/familia-romana-lexical-candidates.json`) ; le test de couverture existant (`vocabulary_acceptance`) est rétabli sur le nouveau lexique.
6. **Français uniquement dans le matériel à traduire** : aucune chaîne française dans un feedback de l'Amphitheatrum ou du Forum (la banque actuelle en a dans 100 % des feedbacks : « Sens de cette analyse : … » — cette fuite disparaît).

## E. Garanties transverses

| # | Garantie | Test |
|---|---|---|
| E.1 | Chaque nœud de l'arbre est atteignable par au moins une question générée (aucun nœud orphelin) | parcours de tous les nœuds, génération d'une question, 0 échec |
| E.2 | Chaque distracteur porte un diagnostic ⊆ nœuds de la question, non vide, ≠ réponse | propriété sur 100 000 questions aléatoires |
| E.3 | Toute forme produite est validée par le conjugueur / déclinateur, eux-mêmes validés contre Collatinus au développement | tests d'or existants du commit `9bc4ad13` (`gold_paradigms_test`, 41 cas) rétablis et étendus |
| E.4 | Une erreur répétée sur un nœud fait revenir le moteur sur ce nœud et ses prérequis dans les 5 questions suivantes ; une réussite répétée espace les rappels | apprenant simulé |
| E.5 | Les prérequis sont acycliques ; les confusions sont symétriques ; tout nœud a une source A&G | test structurel sur l'arbre |
| E.6 | Génération d'une question < 5 ms, sélection < 20 ms sur l'arbre complet, sauvegarde < 100 Ko après 10 000 réponses | test de temps |
| E.7 | Interface latine, contenu français uniquement dans le matériel à traduire, hors ligne, sans build_runner | tests de chaînes + contrainte de dépendances |
| E.8 | Migration de la sauvegarde actuelle : solde, cartes achetées, compétences agrégées (les 67 021 nœuds actuels se projettent sur les nouveaux par table de correspondance ; ce qui ne se projette pas est archivé, jamais perdu) | test de migration sur la sauvegarde réelle |

## F. Ce qui n'est **pas** repris

- Les 1 594 015 questions elles-mêmes, les 5 421 fichiers `.gz`, les 239 Mo : remplacés par les générateurs et les cadres.
- Les 67 021 nœuds de `knowledge.json.gz` : remplacés par l'arbre ; correspondance de migration seulement.
- Les champs toujours nuls des questions (`itemId`, `antecedent`, `function`, `construction`, `person`).
- Le moteur « agnostique du sujet » : un seul jeu est servi.
