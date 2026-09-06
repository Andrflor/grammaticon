# Authored Theatrum content (French). Read by build_content.py, which validates
# every item against the two source texts and packages the assets.
#
# Conventions
#   I(trial, ref, la, fr, target, dist, note=, fr_ref=, paed=, hint=)
#     la      exact span of the Clementine verse (æ, j as in the source)
#     fr      exact span of the Louis Segond 1910 verse at fr_ref (default:
#             aligned verse), or — with paed=True — a pedagogical rendering
#             written here, shown to the player as such, never as Segond
#   T(span, lemma, formSkill, analysisLa)         the decisive form
#   D(text, span, ok, wrong, shift, distinction, formSkill, expl)
#     one controlled morphological misreading per distractor; ok/wrong/expl in
#     Latin (correction and Auxilium), shift in French (change of meaning)
#   LEX   normalised token -> lemma (æ→ae, j→i, lower case), GLOSS lemma -> French
from __future__ import annotations


def T(span, lemma, formSkill, analysis):
    return {'span': span, 'lemma': lemma, 'formSkill': formSkill, 'analysis': analysis}


def D(text, span, ok, wrong, shift, distinction, formSkill, expl):
    return {'text': text, 'span': span, 'ok': ok, 'wrong': wrong, 'shift': shift, 'distinction': distinction, 'formSkill': formSkill, 'expl': expl}


def I(trial, ref, la, fr, target, dist, note='', fr_ref=None, paed=False, hint=''):
    skill = {'th-numerus': 'l.numerus', 'th-persona': 'l.persona', 'th-casus-recti': 'l.casus', 'th-casus-obliqui': 'l.casus',
             'th-tempus-praeteritum': 'l.tempus', 'th-tempus-futurum': 'l.tempus', 'th-modus-imperativus': 'l.modus',
             'th-modus-subiunctivus': 'l.modus', 'th-vox': 'l.vox', 'th-congruentia': 'l.congruentia', 'th-nonfinita': 'l.nonfinita'}[trial]
    return {'trial': trial, 'ref': ref, 'la': la, 'fr': fr, 'fr_ref': fr_ref, 'paed': paed, 'target': target, 'dist': dist, 'note': note, 'hint': hint, 'skill': skill}


# Short Latin labels
PL = 'plūrālis'
SG = 'singulāris'
NT = 'Dēsinentia -nt tertiam persōnam plūrālem ostendit; singulāris esset -t.'
NTS = 'Dēsinentia -t tertiam persōnam singulārem ostendit; plūrālis esset -nt.'

ITEMS: list[dict] = []

# ============================================================ th-numerus
ITEMS += [
    I('th-numerus', 'MAT 5:8', 'Beati mundo corde: quoniam ipsi Deum videbunt.', 'Heureux ceux qui ont le cœur pur, car ils verront Dieu!',
      T('videbunt', 'video', 'v.ind.fut.act', 'indicātīvus futūrī, tertia persōna plūrālis'),
      [D('Heureux celui qui a le cœur pur, car il verra Dieu!', 'Beati', 'nōminātīvus plūrālis (beati, ipsi)', 'singulāris (beatus, ipse)', 'Un seul homme est déclaré heureux au lieu de tous ceux qui ont le cœur pur.', 'numerus', 'd.2.nom.pl', 'Beati et ipsi plūrālia sunt: dē multīs dīcitur, nōn dē ūnō.'),
       D('Heureux ceux qui ont le cœur pur, car ils verront les dieux!', 'Deum', 'accūsātīvus singulāris (Deum)', 'plūrālis (deos)', 'Ils verraient plusieurs dieux au lieu du Dieu unique.', 'numerus', 'd.2.acc.sg', 'Deum est accūsātīvus singulāris; plūrālis esset deos.'),
       D('Heureux ceux qui ont le cœur pur, car il verra Dieu!', 'videbunt', 'tertia plūrālis (videbunt)', 'tertia singulāris (videbit)', 'Ce n\'est plus eux qui verront Dieu, mais quelqu\'un d\'autre, au singulier.', 'numerus', 'v.ind.fut.act', NT)],
      note='Ipsi … videbunt: subiectum et verbum plūrālia congruunt.'),
    I('th-numerus', 'JOH 10:27', 'Oves meæ vocem meam audiunt, et ego cognosco eas', 'Mes brebis entendent ma voix; je les connais',
      T('audiunt', 'audio', 'v.ind.praes.act', 'indicātīvus praesentis, tertia persōna plūrālis'),
      [D('Ma brebis entend ma voix; je la connais', 'Oves', 'nōminātīvus plūrālis (oves, audiunt, eas)', 'singulāris (ovis, audit, eam)', 'Une seule brebis au lieu du troupeau.', 'numerus', 'd.3.nom.pl', 'Oves, audiunt et eas plūrālia sunt: ovis, audit, eam essent singulāria.'),
       D('Mes brebis entendent mes voix; je les connais', 'vocem', 'accūsātīvus singulāris (vocem)', 'plūrālis (voces)', 'Plusieurs voix au lieu d\'une seule.', 'numerus', 'd.3.acc.sg', 'Vocem singulāris est; plūrālis esset voces.'),
       D('Mes brebis entendent ma voix; je la connais', 'eas', 'accūsātīvus plūrālis (eas)', 'singulāris (eam)', 'Il ne connaît plus les brebis, mais une seule chose : la voix.', 'numerus', '', 'Eas plūrāle est et ad oves refertur; eam singulāre ad vocem referrētur.')]),
    I('th-numerus', 'PSA 18:2', 'Cæli enarrant gloriam Dei, et opera manuum ejus annuntiat firmamentum.', 'Les cieux racontent la gloire de Dieu, Et l’étendue manifeste l’œuvre de ses mains.',
      T('enarrant', 'enarro', 'v.ind.praes.act', 'indicātīvus praesentis, tertia persōna plūrālis'),
      [D('Le ciel raconte la gloire de Dieu, et l\'étendue manifeste l\'œuvre de ses mains.', 'Cæli', 'nōminātīvus plūrālis (cæli, enarrant)', 'singulāris (cælum, enarrat)', 'Un seul ciel au lieu des cieux.', 'numerus', 'd.2.nom.pl', 'Cæli et enarrant plūrālia sunt.'),
       D('Les cieux racontent la gloire des dieux, et l\'étendue manifeste l\'œuvre de ses mains.', 'Dei', 'genetīvus singulāris (Dei)', 'plūrālis (deorum)', 'La gloire de plusieurs dieux au lieu de celle du Dieu unique.', 'numerus', 'd.2.gen.sg', 'Dei genetīvus singulāris est; plūrālis esset deorum.'),
       D('Les cieux racontent la gloire de Dieu, et l\'étendue manifeste l\'œuvre de sa main.', 'manuum', 'genetīvus plūrālis (manuum)', 'singulāris (manus)', 'Une seule main au lieu des deux.', 'numerus', 'd.4.gen.pl', 'Manuum genetīvus plūrālis est (-uum); singulāris esset manus.')]),
    I('th-numerus', 'MAT 7:7', 'Petite, et dabitur vobis: quærite, et invenietis: pulsate, et aperietur vobis.', 'Demandez,et l’on vous donnera; cherchez, et vous trouverez; frappez, et l’on vous ouvrira.',
      T('Petite', 'peto', 'v.imp.praes', 'imperātīvus praesentis, secunda persōna plūrālis'),
      [D('Demande, et l\'on te donnera; cherche, et tu trouveras; frappe, et l\'on t\'ouvrira.', 'Petite', 'secunda plūrālis (petite, vobis)', 'singulāris (pete, tibi)', 'Un seul auditeur au lieu de plusieurs.', 'numerus', 'v.imp.praes', 'Petite, quærite, pulsate imperātīvī plūrālēs sunt (-te); vobis plūrāle.'),
       D('Demandez, et l\'on vous donnera; cherchez, et vous trouverez; frappez, et l\'on t\'ouvrira.', 'aperietur vobis', 'datīvus plūrālis (vobis)', 'singulāris (tibi)', 'On n\'ouvre plus qu\'à une seule personne.', 'numerus', '', 'Vobis plūrāle est; tibi esset singulāre.'),
       D('Demandez, et l\'on vous donnera; cherche, et tu trouveras; frappez, et l\'on vous ouvrira.', 'invenietis', 'secunda plūrālis (invenietis)', 'singulāris (invenies)', 'Un seul cherche et trouve, au milieu d\'ordres au pluriel.', 'numerus', 'v.ind.fut.act', 'Dēsinentia -tis secundam plūrālem ostendit; -s esset singulāris.')]),
    I('th-numerus', 'LUK 2:14', 'Gloria in altissimis Deo, et in terra pax hominibus bonæ voluntatis.', 'Gloire à Dieu au plus haut des cieux, et paix sur la terre aux hommes de bonne volonté.', paed=True,
      target=T('hominibus', 'homo', 'd.3.dat.pl', 'datīvus plūrālis'),
      dist=[D('Gloire aux dieux au plus haut des cieux, et paix sur la terre aux hommes de bonne volonté.', 'Deo', 'datīvus singulāris (Deo)', 'plūrālis (diis)', 'Plusieurs dieux glorifiés.', 'numerus', 'd.2.dat.sg', 'Deo singulāre est; plūrālis esset diis.'),
            D('Gloire à Dieu au plus haut des cieux, et paix sur la terre à l\'homme de bonne volonté.', 'hominibus', 'datīvus plūrālis (hominibus)', 'singulāris (homini)', 'La paix n\'est promise qu\'à un seul homme.', 'numerus', 'd.3.dat.pl', 'Hominibus (-ibus) plūrāle est; homini esset singulāre.'),
            D('Gloire à Dieu au plus haut des cieux, et paix sur les terres aux hommes de bonne volonté.', 'terra', 'ablātīvus singulāris (terra)', 'plūrālis (terris)', 'Plusieurs terres au lieu de la terre.', 'numerus', 'd.1.abl.sg', 'In terra singulāre est; plūrālis esset in terris.')],
      note='Segond lit « hominibus quos amat » (autre texte grec) ; le rendu pédagogique suit le latin « bonæ voluntatis ».'),
    I('th-numerus', 'PSA 116:1', 'Laudate Dominum, omnes gentes; laudate eum, omnes populi.', 'Louez l’Éternel, vous toutes les nations, Célébrez-le, vous tous les peuples!',
      T('Laudate', 'laudo', 'v.imp.praes', 'imperātīvus praesentis, secunda persōna plūrālis'),
      [D('Louez les seigneurs, vous toutes les nations, célébrez-les, vous tous les peuples!', 'Dominum', 'accūsātīvus singulāris (Dominum, eum)', 'plūrālis (dominos, eos)', 'Plusieurs seigneurs loués au lieu du Seigneur.', 'numerus', 'd.2.acc.sg', 'Dominum et eum singulāria sunt.'),
       D('Louez l\'Éternel, vous toutes les nations, célébrez-le, vous tout le peuple!', 'populi', 'vocātīvus plūrālis (populi)', 'singulāris (popule)', 'Un seul peuple appelé, au lieu de tous.', 'numerus', 'd.2.voc.pl', 'Omnes populi plūrāle est; singulāris esset popule.'),
       D('Loue l\'Éternel, ô nation, célèbre-le, ô peuple!', 'Laudate', 'secunda plūrālis (laudate)', 'singulāris (lauda)', 'Un seul auditeur.', 'numerus', 'v.imp.praes', 'Laudate imperātīvus plūrālis est (-te); lauda singulāris.')]),
    I('th-numerus', 'ISA 40:8', 'exsiccatum est fœnum, et cecidit flos; verbum autem Domini nostri manet in æternum.', 'L\'herbe s\'est desséchée et la fleur est tombée; mais la parole de notre Seigneur demeure éternellement.', paed=True,
      target=T('manet', 'maneo', 'v.ind.praes.act', 'indicātīvus praesentis, tertia persōna singulāris'),
      dist=[D('L\'herbe s\'est desséchée et la fleur est tombée; mais les paroles de notre Seigneur demeurent éternellement.', 'verbum', 'nōminātīvus singulāris (verbum, manet)', 'plūrālis (verba, manent)', 'Plusieurs paroles au lieu de la parole.', 'numerus', 'd.2.nom.sg', 'Verbum et manet singulāria sunt; verba manent esset plūrāle.'),
            D('L\'herbe s\'est desséchée et la fleur est tombée; mais la parole de nos seigneurs demeure éternellement.', 'Domini nostri', 'genetīvus singulāris (Domini nostri)', 'plūrālis (dominorum nostrorum)', 'Plusieurs seigneurs.', 'numerus', 'd.2.gen.sg', 'Domini nostri genetīvus singulāris est.'),
            D('L\'herbe s\'est desséchée et les fleurs sont tombées; mais la parole de notre Seigneur demeure éternellement.', 'flos', 'nōminātīvus singulāris (flos, cecidit)', 'plūrālis (flores, ceciderunt)', 'Plusieurs fleurs.', 'numerus', 'd.3.nom.sg', 'Flos et cecidit singulāria sunt.')],
      note='Segond rend les parfaits par des présents (« L\'herbe sèche, la fleur tombe ») ; le rendu pédagogique garde les temps latins.'),
    I('th-numerus', 'MAT 5:14', 'Vos estis lux mundi.', 'Vous êtes la lumière du monde.',
      T('estis', 'sum', 'v.fam.sum', 'indicātīvus praesentis, secunda persōna plūrālis'),
      [D('Tu es la lumière du monde.', 'Vos estis', 'secunda plūrālis (vos estis)', 'singulāris (tu es)', 'Un seul interlocuteur.', 'numerus', 'v.fam.sum', 'Vos et estis plūrālia sunt; tu es singulāre.'),
       D('Vous êtes les lumières du monde.', 'lux', 'nōminātīvus singulāris (lux)', 'plūrālis (luces)', 'Plusieurs lumières.', 'numerus', 'd.3.nom.sg', 'Lux singulāre est; plūrālis esset luces.'),
       D('Vous êtes la lumière des mondes.', 'mundi', 'genetīvus singulāris (mundi)', 'plūrālis (mundorum)', 'Plusieurs mondes.', 'numerus', 'd.2.gen.sg', 'Mundi hīc genetīvus singulāris est; plūrālis esset mundorum.')]),
    I('th-numerus', 'MAT 24:35', 'Cælum et terra transibunt, verba autem mea non præteribunt.', 'Le ciel et la terre passeront, mais mes paroles ne passeront point.',
      T('verba', 'verbum', 'd.2.nom.pl', 'nōminātīvus plūrālis (neutrum)'),
      [D('Les cieux et la terre passeront, mais mes paroles ne passeront point.', 'Cælum', 'nōminātīvus singulāris (cælum)', 'plūrālis (cæli)', 'Plusieurs cieux.', 'numerus', 'd.2.nom.sg', 'Cælum singulāre est; plūrālis esset cæli.'),
       D('Le ciel et la terre passeront, mais ma parole ne passera point.', 'verba', 'nōminātīvus plūrālis (verba, præteribunt)', 'singulāris (verbum, præteribit)', 'Une seule parole.', 'numerus', 'd.2.nom.pl', 'Verba neutrum plūrāle est (-a); verbum esset singulāre.'),
       D('Le ciel et les terres passeront, mais mes paroles ne passeront point.', 'terra', 'nōminātīvus singulāris (terra)', 'plūrālis (terræ)', 'Plusieurs terres.', 'numerus', 'd.1.nom.sg', 'Terra singulāre est; plūrālis esset terræ.')]),
    I('th-numerus', 'GEN 1:27', 'masculum et feminam creavit eos.', 'il créa l’homme et la femme.',
      T('feminam', 'femina', 'd.1.acc.sg', 'accūsātīvus singulāris'),
      [D('il créa les hommes et les femmes.', 'masculum et feminam', 'accūsātīvus singulāris (masculum, feminam)', 'plūrālis (masculos, feminas)', 'Plusieurs hommes et femmes créés.', 'numerus', 'd.1.acc.sg', 'Masculum et feminam singulāria sunt.'),
       D('il créa l\'homme et les femmes.', 'feminam', 'accūsātīvus singulāris (feminam)', 'plūrālis (feminas)', 'Plusieurs femmes pour un homme.', 'numerus', 'd.1.acc.sg', 'Feminam singulāre est (-am); plūrālis esset feminas.'),
       D('il créa les hommes et la femme.', 'masculum', 'accūsātīvus singulāris (masculum)', 'plūrālis (masculos)', 'Plusieurs hommes pour une femme.', 'numerus', 'd.2.acc.sg', 'Masculum singulāre est (-um); plūrālis esset masculos.')]),
    I('th-numerus', 'JOH 15:5', 'Ego sum vitis, vos palmites', 'Je suis le cep, vous êtes les sarments.',
      T('palmites', 'palmes', 'd.3.nom.pl', 'nōminātīvus plūrālis'),
      [D('Je suis le cep, tu es le sarment.', 'vos palmites', 'plūrālis (vos, palmites)', 'singulāris (tu, palmes)', 'Un seul sarment, un seul interlocuteur.', 'numerus', 'd.3.nom.pl', 'Vos et palmites plūrālia sunt.'),
       D('Nous sommes le cep, vous êtes les sarments.', 'Ego sum', 'prīma singulāris (ego sum)', 'plūrālis (nos sumus)', 'Plusieurs ceps parlent.', 'numerus', 'v.fam.sum', 'Ego sum singulāre est; nos sumus esset plūrāle.'),
       D('Je suis les ceps, vous êtes les sarments.', 'vitis', 'nōminātīvus singulāris (vitis)', 'plūrālis (vites)', 'Plusieurs ceps.', 'numerus', 'd.3.nom.sg', 'Vitis singulāre est; plūrālis esset vites.')]),
    I('th-numerus', 'MAT 5:9', 'Beati pacifici: quoniam filii Dei vocabuntur.', 'Heureux ceux qui procurent la paix, car ils seront appelés fils de Dieu!',
      T('vocabuntur', 'voco', 'v.ind.fut.pass', 'indicātīvus futūrī passīvī, tertia persōna plūrālis'),
      [D('Heureux celui qui procure la paix, car il sera appelé fils de Dieu!', 'pacifici', 'nōminātīvus plūrālis (beati pacifici)', 'singulāris (beatus pacificus)', 'Un seul homme au lieu de tous les pacifiques.', 'numerus', 'd.2.nom.pl', 'Beati pacifici plūrālia sunt (-i).'),
       D('Heureux ceux qui procurent la paix, car ils seront appelés fils des dieux!', 'Dei', 'genetīvus singulāris (Dei)', 'plūrālis (deorum)', 'Plusieurs dieux.', 'numerus', 'd.2.gen.sg', 'Dei genetīvus singulāris est.'),
       D('Heureux ceux qui procurent la paix, car il sera appelé fils de Dieu!', 'vocabuntur', 'tertia plūrālis (vocabuntur)', 'singulāris (vocabitur)', 'Un seul est appelé, non pas eux.', 'numerus', 'v.ind.fut.pass', 'Dēsinentia -ntur plūrālem ostendit; -tur esset singulāris.')]),
]

# ============================================================ th-persona
ITEMS += [
    I('th-persona', 'PSA 50:6', 'Tibi soli peccavi, et malum coram te feci', 'J’ai péché contre toi seul, Et j’ai fait ce qui est mal à tes yeux',
      T('peccavi', 'pecco', 'v.ind.perf.act', 'indicātīvus perfectī, prīma persōna singulāris'),
      [D('Il a péché contre toi seul, et il a fait ce qui est mal à tes yeux', 'peccavi', 'prīma persōna (peccavi, feci)', 'tertia (peccavit, fecit)', 'Ce n\'est plus celui qui prie qui avoue, mais un tiers.', 'persona', 'v.ind.perf.act', 'Dēsinentia -ī perfectī prīmam persōnam ostendit; -it esset tertia.'),
       D('J\'ai péché contre moi seul, et j\'ai fait ce qui est mal à mes yeux', 'Tibi', 'secunda persōna (tibi, te)', 'prīma (mihi, me)', 'La faute n\'est plus commise contre Dieu mais contre soi-même.', 'persona', '', 'Tibi et te secundam persōnam significant; mihi, me essent prīma.'),
       D('J\'ai péché contre toi seul, et tu as fait ce qui est mal à tes yeux', 'feci', 'prīma persōna (feci)', 'secunda (fecisti)', 'C\'est Dieu qui aurait fait le mal.', 'persona', 'v.ind.perf.act', 'Feci prīma persōna est; fecisti esset secunda.')]),
    I('th-persona', 'JOH 21:17', 'Domine, tu omnia nosti, tu scis quia amo te.', 'Seigneur, tu sais toutes choses, tu sais que je t’aime.',
      T('amo', 'amo', 'v.ind.praes.act', 'indicātīvus praesentis, prīma persōna singulāris'),
      [D('Seigneur, je sais toutes choses, je sais que je t\'aime.', 'scis', 'secunda persōna (nosti, scis)', 'prīma (novi, scio)', 'Pierre prétend tout savoir lui-même.', 'persona', 'v.ind.praes.act', 'Tu … scis secunda persōna est (-s); scio esset prīma.'),
       D('Seigneur, tu sais toutes choses, tu sais qu\'il t\'aime.', 'amo', 'prīma persōna (amo)', 'tertia (amat)', 'Un autre aime le Seigneur, non Pierre.', 'persona', 'v.ind.praes.act', 'Amo (-ō) prīma persōna est; amat esset tertia.'),
       D('Seigneur, tu sais toutes choses, tu sais que je l\'aime.', 'te', 'secunda persōna (te)', 'tertia (eum)', 'Pierre aime quelqu\'un d\'autre que le Seigneur.', 'persona', '', 'Te secundam persōnam significat; eum esset tertia.')]),
    I('th-persona', 'MAT 8:8', 'Domine, non sum dignus ut intres sub tectum meum', 'Seigneur, je ne suis pas digne que tu entres sous mon toit',
      T('intres', 'intro', 'v.subj.praes.act', 'subiūnctīvus praesentis, secunda persōna singulāris'),
      [D('Seigneur, il n\'est pas digne que tu entres sous mon toit', 'sum', 'prīma persōna (sum)', 'tertia (est)', 'Le centurion parle d\'un autre indigne.', 'persona', 'v.fam.sum', 'Sum prīma persōna est; est esset tertia.'),
       D('Seigneur, je ne suis pas digne qu\'il entre sous mon toit', 'intres', 'secunda persōna (intres)', 'tertia (intret)', 'Ce n\'est plus le Seigneur qui entrerait.', 'persona', 'v.subj.praes.act', 'Intres (-s) secunda persōna est; intret esset tertia.'),
       D('Seigneur, je ne suis pas digne que tu entres sous ton toit', 'meum', 'prīma persōna (meum)', 'secunda (tuum)', 'Le toit devient celui du Seigneur.', 'persona', '', 'Meum ad loquentem refertur; tuum ad Dominum referrētur.')]),
    I('th-persona', 'LUK 15:18', 'surgam, et ibo ad patrem meum, et dicam ei: Pater, peccavi in cælum, et coram te', 'Je me lèverai, j’irai vers mon père, et je lui dirai: Mon père, j’ai péché contre le ciel et contre toi',
      T('ibo', 'eo', 'v.fam.eo', 'indicātīvus futūrī, prīma persōna singulāris'),
      [D('Il se lèvera, il ira vers son père, et il lui dira: Mon père, j\'ai péché contre le ciel et contre toi', 'ibo', 'prīma persōna (surgam, ibo, dicam)', 'tertia (surget, ibit, dicet)', 'Le récit passe à un autre personnage.', 'persona', 'v.fam.eo', 'Surgam, ibo, dicam prīmam persōnam ostendunt (-m, -ō).'),
       D('Je me lèverai, j\'irai vers mon père, et je lui dirai: Mon père, il a péché contre le ciel et contre toi', 'peccavi', 'prīma persōna (peccavi)', 'tertia (peccavit)', 'Le fils accuse un autre.', 'persona', 'v.ind.perf.act', 'Peccavi (-ī) prīma persōna est; peccavit esset tertia.'),
       D('Je me lèverai, j\'irai vers ton père, et je lui dirai: Mon père, j\'ai péché contre le ciel et contre toi', 'meum', 'prīma persōna (meum)', 'secunda (tuum)', 'Le père devient celui de l\'interlocuteur.', 'persona', '', 'Meum ad loquentem refertur.')]),
    I('th-persona', 'EXO 20:2', 'Ego sum Dominus Deus tuus, qui eduxi te de terra Ægypti', 'Je suis l’Éternel, ton Dieu, qui t’ai fait sortir du pays d’Égypte',
      T('eduxi', 'educo', 'v.ind.perf.act', 'indicātīvus perfectī, prīma persōna singulāris'),
      [D('Il est l\'Éternel, ton Dieu, qui t\'a fait sortir du pays d\'Égypte', 'Ego sum', 'prīma persōna (ego sum, eduxi)', 'tertia (est, eduxit)', 'Dieu ne parle plus de lui-même.', 'persona', 'v.fam.sum', 'Ego sum et eduxi prīmam persōnam ostendunt.'),
       D('Je suis l\'Éternel, ton Dieu, qui vous ai fait sortir du pays d\'Égypte', 'te', 'singulāris (te, tuus)', 'plūrālis (vos, vester)', 'Un peuple entier au lieu d\'un interlocuteur singulier.', 'numerus', '', 'Te et tuus singulāria sunt.'),
       D('Je suis l\'Éternel, mon Dieu, qui t\'ai fait sortir du pays d\'Égypte', 'tuus', 'secunda persōna (tuus)', 'prīma (meus)', 'Dieu serait son propre Dieu.', 'persona', '', 'Tuus ad audientem refertur; meus ad loquentem.')]),
    I('th-persona', 'ISA 6:8', 'Et dixi: Ecce ego, mitte me.', 'Je répondis: Me voici, envoie-moi.',
      T('mitte', 'mitto', 'v.imp.praes', 'imperātīvus praesentis, secunda persōna singulāris'),
      [D('Il répondit: Me voici, envoie-moi.', 'dixi', 'prīma persōna (dixi)', 'tertia (dixit)', 'Un autre répond à la place du prophète.', 'persona', 'v.ind.perf.act', 'Dixi (-ī) prīma persōna perfectī est; dixit esset tertia.'),
       D('Je répondis: Le voici, envoie-le.', 'me', 'prīma persōna (ego, me)', 'tertia (ille, eum)', 'Le prophète propose quelqu\'un d\'autre.', 'persona', '', 'Ego et me prīmam persōnam significant.'),
       D('Je répondis: Me voici, envoyez-moi.', 'mitte', 'secunda singulāris (mitte)', 'plūrālis (mittite)', 'Plusieurs envoyeurs au lieu du Seigneur seul.', 'numerus', 'v.imp.praes', 'Mitte singulāre est; mittite esset plūrāle.')]),
    I('th-persona', 'GEN 3:10', 'Vocem tuam audivi in paradiso, et timui', 'J’ai entendu ta voix dans le jardin, et j’ai eu peur',
      T('audivi', 'audio', 'v.ind.perf.act', 'indicātīvus perfectī, prīma persōna singulāris'),
      [D('Il a entendu ta voix dans le jardin, et il a eu peur', 'audivi', 'prīma persōna (audivi, timui)', 'tertia (audivit, timuit)', 'Adam parle d\'un autre.', 'persona', 'v.ind.perf.act', 'Audivi et timui (-ī) prīmam persōnam ostendunt.'),
       D('J\'ai entendu sa voix dans le jardin, et j\'ai eu peur', 'tuam', 'secunda persōna (tuam)', 'tertia (ejus)', 'La voix n\'est plus celle de Dieu à qui il parle.', 'persona', '', 'Tuam ad audientem refertur; ejus esset tertia.'),
       D('Nous avons entendu ta voix dans le jardin, et nous avons eu peur', 'timui', 'prīma singulāris (audivi, timui)', 'plūrālis (audivimus, timuimus)', 'Adam parle aussi pour Ève.', 'numerus', 'v.ind.perf.act', 'Audivi, timui singulāria sunt; -imus esset plūrāle.')]),
    I('th-persona', 'JOH 14:9', 'Tanto tempore vobiscum sum, et non cognovistis me?', 'Depuis si longtemps je suis avec vous, et vous ne m\'avez pas connu?', paed=True,
      target=T('cognovistis', 'cognosco', 'v.ind.perf.act', 'indicātīvus perfectī, secunda persōna plūrālis'),
      dist=[D('Depuis si longtemps il est avec vous, et vous ne l\'avez pas connu?', 'sum', 'prīma persōna (sum, me)', 'tertia (est, eum)', 'Jésus parlerait d\'un autre.', 'persona', 'v.fam.sum', 'Sum et me prīmam persōnam significant.'),
            D('Depuis si longtemps je suis avec vous, et tu ne m\'as pas connu?', 'cognovistis', 'secunda plūrālis (cognovistis)', 'singulāris (cognovisti)', 'Un seul disciple est repris.', 'numerus', 'v.ind.perf.act', 'Cognovistis (-istis) plūrāle est; cognovisti singulāre.'),
            D('Depuis si longtemps je suis avec toi, et vous ne m\'avez pas connu?', 'vobiscum', 'plūrālis (vobiscum)', 'singulāris (tecum)', 'Jésus n\'aurait été qu\'avec un seul.', 'numerus', '', 'Vobiscum plūrāle est; tecum esset singulāre.')],
      note='Segond suit un texte grec au singulier (« tu ne m\'as pas connu ») ; le latin a cognovistis, deuxième personne du pluriel.'),
    I('th-persona', 'RUT 1:16', 'Populus tuus populus meus, et Deus tuus Deus meus.', 'ton peuple sera mon peuple, et ton Dieu sera mon Dieu',
      T('meus', 'meus', '', 'prōnōmen possessīvum prīmae persōnae'),
      [D('mon peuple sera ton peuple, et mon Dieu sera ton Dieu', 'tuus', 'secunda persōna (tuus)', 'prīma (meus)', 'Les possesseurs sont inversés.', 'persona', '', 'Tuus ad Noemi, meus ad Ruth refertur: ōrdō sententiae hoc dīcit.'),
       D('ton peuple sera son peuple, et ton Dieu sera son Dieu', 'meus', 'prīma persōna (meus)', 'tertia (ejus)', 'Ruth parlerait d\'une tierce personne.', 'persona', '', 'Meus prīmam persōnam significat.'),
       D('son peuple sera mon peuple, et son Dieu sera mon Dieu', 'tuus', 'secunda persōna (tuus)', 'tertia (ejus)', 'Ruth ne s\'adresserait plus à Noémi.', 'persona', '', 'Tuus secundam persōnam significat.')]),
    I('th-persona', 'MAT 3:17', 'Hic est Filius meus dilectus, in quo mihi complacui.', 'Celui-ci est mon Fils bien-aimé, en qui j’ai mis toute mon affection.',
      T('complacui', 'complaceo', 'v.ind.perf.act', 'indicātīvus perfectī, prīma persōna singulāris'),
      [D('Celui-ci est ton Fils bien-aimé, en qui tu as mis toute ton affection.', 'meus', 'prīma persōna (meus, mihi, complacui)', 'secunda (tuus, tibi, complacuisti)', 'La voix du ciel parlerait à un autre père.', 'persona', '', 'Meus, mihi, complacui prīmam persōnam ostendunt.'),
       D('Celui-ci est mon Fils bien-aimé, en qui il a mis toute son affection.', 'complacui', 'prīma persōna (complacui)', 'tertia (complacuit)', 'Un autre se complaît dans le Fils.', 'persona', 'v.ind.perf.act', 'Complacui (-ī) prīma persōna est.'),
       D('Celui-ci est son Fils bien-aimé, en qui j\'ai mis toute mon affection.', 'meus', 'prīma persōna (meus)', 'tertia (ejus)', 'Le Fils appartiendrait à un autre.', 'persona', '', 'Meus ad loquentem refertur.')]),
    I('th-persona', 'LUK 23:46', 'Pater, in manus tuas commendo spiritum meum.', 'Père, je remets mon esprit entre tes mains.',
      T('commendo', 'commendo', 'v.ind.praes.act', 'indicātīvus praesentis, prīma persōna singulāris'),
      [D('Père, il remet mon esprit entre tes mains.', 'commendo', 'prīma persōna (commendo)', 'tertia (commendat)', 'Un autre remet l\'esprit.', 'persona', 'v.ind.praes.act', 'Commendo (-ō) prīma persōna est.'),
       D('Père, je remets ton esprit entre tes mains.', 'meum', 'prīma persōna (meum)', 'secunda (tuum)', 'L\'esprit remis serait celui du Père.', 'persona', '', 'Meum ad loquentem refertur.'),
       D('Père, je remets mon esprit entre ses mains.', 'tuas', 'secunda persōna (tuas)', 'tertia (ejus)', 'Les mains ne sont plus celles du Père.', 'persona', '', 'Tuas ad Patrem, cui loquitur, refertur.')]),
    I('th-persona', 'JOH 9:25', 'unum scio, quia cæcus cum essem, modo video.', 'je sais une chose, c’est que j’étais aveugle et que maintenant je vois.',
      T('video', 'video', 'v.ind.praes.act', 'indicātīvus praesentis, prīma persōna singulāris'),
      [D('il sait une chose, c\'est qu\'il était aveugle et que maintenant il voit.', 'scio', 'prīma persōna (scio, essem, video)', 'tertia (scit, esset, videt)', 'L\'aveugle guéri ne parle plus de lui.', 'persona', 'v.ind.praes.act', 'Scio, essem, video prīmam persōnam ostendunt.'),
       D('je sais une chose, c\'est que tu étais aveugle et que maintenant tu vois.', 'essem', 'prīma persōna (essem, video)', 'secunda (esses, vides)', 'Il parlerait de la cécité de son interlocuteur.', 'persona', 'v.subj.imperf.act', 'Essem et video prīma persōna sunt.'),
       D('je sais une chose, c\'est que j\'étais aveugle et que maintenant il voit.', 'video', 'prīma persōna (video)', 'tertia (videt)', 'Un autre voit à sa place.', 'persona', 'v.ind.praes.act', 'Video (-ō) prīma persōna est; videt esset tertia.')]),
]

# ============================================================ th-casus-recti
ITEMS += [
    I('th-casus-recti', 'JOH 3:16', 'Sic enim Deus dilexit mundum, ut Filium suum unigenitum daret', 'Car Dieu a tant aimé le monde qu’il a donné son Fils unique',
      T('mundum', 'mundus', 'd.2.acc.sg', 'accūsātīvus singulāris, obiectum'),
      [D('Car le monde a tant aimé Dieu qu\'il a donné son Fils unique', 'Deus', 'Deus nōminātīvus (subiectum), mundum accūsātīvus (obiectum)', 'mundus subiectum, Deum obiectum', 'Celui qui aime et celui qui est aimé sont inversés.', 'casus', 'd.2.nom.sg', 'Deus (-us) nōminātīvus est, mundum (-um) accūsātīvus: Deus amat, mundus amātur.'),
       D('Car Dieu a tant aimé le monde que son Fils unique l\'a donné', 'Filium', 'accūsātīvus (Filium, obiectum)', 'nōminātīvus (Filius, subiectum)', 'Le Fils devient celui qui donne au lieu d\'être donné.', 'casus', 'd.2.acc.sg', 'Filium (-um) accūsātīvus est: obiectum verbī daret.'),
       D('Car Dieu a tant aimé les mondes qu\'il a donné son Fils unique', 'mundum', 'accūsātīvus singulāris (mundum)', 'plūrālis (mundos)', 'Plusieurs mondes.', 'numerus', 'd.2.acc.sg', 'Mundum singulāre est.')]),
    I('th-casus-recti', 'MAT 16:18', 'super hanc petram ædificabo Ecclesiam meam', 'sur cette pierre je bâtirai mon Église', paed=True, note='Segond : « surcette pierre » (espace manquante dans l\'export) ; rendu identique, corrigé.',
      target=T('Ecclesiam', 'ecclesia', 'd.1.acc.sg', 'accūsātīvus singulāris, obiectum'),
      dist=[D('sur cette pierre mon Église bâtira', 'Ecclesiam', 'accūsātīvus (Ecclesiam, obiectum)', 'nōminātīvus (Ecclesia, subiectum)', 'L\'Église devient celle qui bâtit.', 'casus', 'd.1.acc.sg', 'Ecclesiam (-am) accūsātīvus est; ædificabo prīma persōna: ego ædificō.'),
       D('avec cette pierre je bâtirai mon Église', 'petram', 'accūsātīvus post super (hanc petram)', 'ablātīvus īnstrūmentī (hac petra)', 'La pierre devient un matériau au lieu du fondement.', 'casus', 'd.1.acc.sg', 'Petram (-am) accūsātīvus est: super + accūsātīvum locum dīcit; ablātīvus esset petra.'),
       D('sur ces pierres je bâtirai mon Église', 'hanc petram', 'singulāris (hanc petram)', 'plūrālis (has petras)', 'Plusieurs pierres.', 'numerus', 'd.1.acc.sg', 'Hanc petram singulāre est.')]),
    I('th-casus-recti', 'LUK 1:46', 'Magnificat anima mea Dominum', 'Mon âme exalte le Seigneur',
      T('Dominum', 'dominus', 'd.2.acc.sg', 'accūsātīvus singulāris, obiectum'),
      [D('Le Seigneur exalte mon âme', 'Dominum', 'Dominum accūsātīvus (obiectum), anima nōminātīvus', 'Dominus subiectum, animam obiectum', 'C\'est Dieu qui exalterait l\'âme.', 'casus', 'd.2.acc.sg', 'Dominum (-um) accūsātīvus est, anima (-a) nōminātīvus.'),
       D('Par mon âme, il exalte le Seigneur', 'anima mea', 'nōminātīvus (anima mea, subiectum)', 'ablātīvus (animā meā, īnstrūmentum)', 'L\'âme n\'est plus le sujet mais le moyen.', 'casus', 'd.1.nom.sg', 'Anima sine macrō nōminātīvus aut ablātīvus vidērī potest; subiectum verbī magnificat requīritur, ergō nōminātīvus.'),
       D('Mon âme exalte les seigneurs', 'Dominum', 'accūsātīvus singulāris (Dominum)', 'plūrālis (dominos)', 'Plusieurs seigneurs.', 'numerus', 'd.2.acc.sg', 'Dominum singulāre est.')]),
    I('th-casus-recti', '1JO 4:19', 'Nos ergo diligamus Deum, quoniam Deus prior dilexit nos.', 'Aimons donc Dieu, puisque Dieu nous a aimés le premier.', paed=True,
      target=T('Deus', 'deus', 'd.2.nom.sg', 'nōminātīvus singulāris, subiectum'),
      dist=[D('Aimons donc Dieu, puisque nous avons aimé Dieu les premiers.', 'Deus prior dilexit nos', 'Deus nōminātīvus (subiectum), nos accūsātīvus', 'nos subiectum, Deum obiectum', 'L\'initiative de l\'amour passe de Dieu aux hommes.', 'casus', 'd.2.nom.sg', 'Deus (-us) nōminātīvus est; dilexit tertia persōna: Deus amāvit.'),
            D('Que Dieu nous aime donc, puisque Dieu nous a aimés le premier.', 'Deum', 'accūsātīvus (Deum, obiectum)', 'nōminātīvus (Deus, subiectum)', 'Ce n\'est plus nous qui aimons Dieu.', 'casus', 'd.2.acc.sg', 'Deum (-um) accūsātīvus est; diligamus prīma persōna plūrālis: nos amāmus.'),
            D('Aimons donc les dieux, puisque Dieu nous a aimés le premier.', 'Deum', 'accūsātīvus singulāris (Deum)', 'plūrālis (deos)', 'Plusieurs dieux aimés.', 'numerus', 'd.2.acc.sg', 'Deum singulāre est.')],
      note='Segond suit un texte grec sans « Deum » (« nous l\'aimons ») ; le rendu pédagogique suit le latin.'),
    I('th-casus-recti', 'LUK 1:52', 'Deposuit potentes de sede, et exaltavit humiles.', 'Il a renversé les puissants de leur trône, et il a élevé les humbles.', paed=True,
      target=T('potentes', 'potens', 'd.3.acc.pl', 'accūsātīvus plūrālis, obiectum'),
      dist=[D('Les puissants l\'ont renversé de son trône, et les humbles l\'ont élevé.', 'potentes', 'accūsātīvus (potentes, humiles: obiecta)', 'nōminātīvus (subiecta)', 'Les puissants et les humbles deviennent les acteurs.', 'casus', 'd.3.acc.pl', 'Potentes et humiles accūsātīvī sunt: deposuit et exaltavit singulāria, subiectum Deus.'),
            D('Il a renversé les puissants de leur trône, et les humbles l\'ont élevé.', 'humiles', 'accūsātīvus (humiles, obiectum)', 'nōminātīvus (subiectum)', 'Les humbles deviennent ceux qui élèvent.', 'casus', 'd.3.acc.pl', 'Humiles obiectum verbī exaltavit est; -es accūsātīvus plūrālis tertiae dēclīnātiōnis.'),
            D('Il a renversé le puissant de son trône, et il a élevé les humbles.', 'potentes', 'accūsātīvus plūrālis (potentes)', 'singulāris (potentem)', 'Un seul puissant.', 'numerus', 'd.3.acc.pl', 'Potentes plūrāle est.')],
      note='Segond a « de leurs trônes » (pluriel) pour « de sede » (singulier) ; rendu pédagogique.'),
    I('th-casus-recti', 'JOH 8:32', 'et cognoscetis veritatem, et veritas liberabit vos.', 'vous connaîtrez la vérité, etla vérité vous affranchira.',
      T('veritas', 'veritas', 'd.3.nom.sg', 'nōminātīvus singulāris, subiectum'),
      [D('vous connaîtrez la vérité, et vous affranchirez la vérité.', 'veritas', 'nōminātīvus (veritas, subiectum), vos accūsātīvus', 'veritatem obiectum, vos subiectum', 'Ce n\'est plus la vérité qui libère.', 'casus', 'd.3.nom.sg', 'Veritas (-as) nōminātīvus est; liberabit tertia persōna: veritas liberat.'),
       D('vous connaîtrez les vérités, et la vérité vous affranchira.', 'veritatem', 'accūsātīvus singulāris (veritatem)', 'plūrālis (veritates)', 'Plusieurs vérités.', 'numerus', 'd.3.acc.sg', 'Veritatem singulāre est.'),
       D('vous connaîtrez la vérité, et la vérité t\'affranchira.', 'vos', 'accūsātīvus plūrālis (vos)', 'singulāris (te)', 'Un seul homme affranchi.', 'numerus', '', 'Vos plūrāle est; te esset singulāre.')]),
    I('th-casus-recti', '1SA 16:7', 'Dominus autem intuetur cor.', 'mais l’Éternel regarde au cœur.',
      T('cor', 'cor', 'd.3.acc.sg', 'accūsātīvus singulāris neutrī, obiectum'),
      [D('mais le cœur regarde l\'Éternel.', 'cor', 'accūsātīvus (cor, obiectum)', 'nōminātīvus (cor, subiectum)', 'Le cœur devient celui qui regarde.', 'casus', 'd.3.acc.sg', 'Cor neutrum est: nōminātīvus et accūsātīvus eādem fōrmā; Dominus (-us) nōminātīvus subiectum est, ergō cor obiectum.'),
       D('mais les seigneurs regardent au cœur.', 'Dominus', 'nōminātīvus singulāris (Dominus)', 'plūrālis (domini)', 'Plusieurs seigneurs.', 'numerus', 'd.2.nom.sg', 'Dominus et intuetur singulāria sunt.'),
       D('mais l\'Éternel regarde aux cœurs.', 'cor', 'singulāris (cor)', 'plūrālis (corda)', 'Plusieurs cœurs.', 'numerus', 'd.3.acc.sg', 'Cor singulāre est; corda esset plūrāle.')]),
    I('th-casus-recti', 'JOH 13:34', 'sicut dilexi vos, ut et vos diligatis invicem.', 'comme je vous ai aimés, vous aussi, aimez-vous les uns les autres.',
      T('vos', 'vos', '', 'accūsātīvus plūrālis, obiectum verbī dilexi'),
      [D('comme vous m\'avez aimé, vous aussi, aimez-vous les uns les autres.', 'dilexi vos', 'vos accūsātīvus (obiectum), dilexi prīma persōna', 'vos subiectum, ego obiectum', 'Celui qui aime et celui qui est aimé sont inversés.', 'casus', '', 'Dilexi (-ī) prīma persōna est: ego amāvī; vos obiectum est.'),
       D('comme je t\'ai aimé, vous aussi, aimez-vous les uns les autres.', 'vos', 'plūrālis (vos)', 'singulāris (te)', 'Un seul disciple aimé.', 'numerus', '', 'Vos plūrāle est.'),
       D('comme je vous ai aimés, toi aussi, aime les autres.', 'diligatis', 'secunda plūrālis (diligatis)', 'singulāris (diligas)', 'Un seul est appelé à aimer.', 'numerus', 'v.subj.praes.act', 'Diligatis (-tis) plūrāle est.')]),
    I('th-casus-recti', 'MAT 10:16', 'Ecce ego mitto vos sicut oves in medio luporum.', 'Voici, je vous envoie comme des brebis au milieu des loups.',
      T('vos', 'vos', '', 'accūsātīvus plūrālis, obiectum verbī mitto'),
      [D('Voici, vous m\'envoyez comme des brebis au milieu des loups.', 'ego mitto vos', 'ego nōminātīvus (subiectum), vos accūsātīvus', 'vos subiectum, me obiectum', 'Les disciples enverraient Jésus.', 'casus', '', 'Ego nōminātīvus et mitto (-ō) prīma persōna: ego mittō, vos obiectum.'),
       D('Voici, je t\'envoie comme une brebis au milieu des loups.', 'vos', 'plūrālis (vos, oves)', 'singulāris (te, ovem)', 'Un seul envoyé.', 'numerus', '', 'Vos et oves plūrālia sunt.'),
       D('Voici, je vous envoie comme des brebis au milieu du loup.', 'luporum', 'genetīvus plūrālis (luporum)', 'singulāris (lupi)', 'Un seul loup.', 'numerus', 'd.2.gen.pl', 'Luporum (-orum) genetīvus plūrālis est.')]),
    I('th-casus-recti', 'GEN 1:27', 'Et creavit Deus hominem ad imaginem suam', 'Dieu créa l’homme à son image',
      T('hominem', 'homo', 'd.3.acc.sg', 'accūsātīvus singulāris, obiectum'),
      [D('L\'homme créa Dieu à son image', 'Deus hominem', 'Deus nōminātīvus (subiectum), hominem accūsātīvus (obiectum)', 'homo subiectum, Deum obiectum', 'Le créateur et la créature sont inversés.', 'casus', 'd.3.acc.sg', 'Deus (-us) nōminātīvus, hominem (-em) accūsātīvus: Deus creat, homo creātur.'),
       D('Dieu créa les hommes à son image', 'hominem', 'accūsātīvus singulāris (hominem)', 'plūrālis (homines)', 'Plusieurs hommes créés.', 'numerus', 'd.3.acc.sg', 'Hominem singulāre est; homines esset plūrāle.'),
       D('Dieu créa l\'homme à ses images', 'imaginem', 'accūsātīvus singulāris (imaginem)', 'plūrālis (imagines)', 'Plusieurs images.', 'numerus', 'd.3.acc.sg', 'Imaginem singulāre est.')]),
    I('th-casus-recti', 'JOH 15:12', 'Hoc est præceptum meum, ut diligatis invicem, sicut dilexi vos.', 'C’est ici mon commandement: Aimez-vous les uns les autres, comme je vous ai aimés.',
      T('vos', 'vos', '', 'accūsātīvus plūrālis, obiectum verbī dilexi'),
      [D('C\'est ici mon commandement: aimez-vous les uns les autres, comme vous m\'avez aimé.', 'dilexi vos', 'vos accūsātīvus (obiectum), dilexi prīma persōna', 'vos subiectum, me obiectum', 'Les disciples auraient aimé Jésus le premier.', 'casus', '', 'Dilexi prīma persōna est; vos obiectum.'),
       D('C\'est ici mon commandement: aimez-vous les uns les autres, comme je t\'ai aimé.', 'vos', 'plūrālis (vos)', 'singulāris (te)', 'Un seul aimé.', 'numerus', '', 'Vos plūrāle est.'),
       D('Ce sont ici mes commandements: aimez-vous les uns les autres, comme je vous ai aimés.', 'præceptum', 'nōminātīvus singulāris (hoc præceptum)', 'plūrālis (hæc præcepta)', 'Plusieurs commandements.', 'numerus', 'd.2.nom.sg', 'Hoc præceptum singulāre est.')]),
    I('th-casus-recti', 'MAT 27:46', 'Deus meus, Deus meus, ut quid dereliquisti me?', 'Mon Dieu, mon Dieu, pourquoi m’as-tu abandonné?',
      T('me', 'ego', '', 'accūsātīvus singulāris, obiectum verbī dereliquisti'),
      [D('Mon Dieu, mon Dieu, pourquoi t\'ai-je abandonné?', 'dereliquisti me', 'me accūsātīvus (obiectum), dereliquisti secunda persōna', 'ego subiectum, te obiectum', 'Celui qui abandonne et l\'abandonné sont inversés.', 'casus', 'v.ind.perf.act', 'Dereliquisti (-istī) secunda persōna est: tū relīquistī; me obiectum.'),
       D('Mes dieux, mes dieux, pourquoi m\'as-tu abandonné?', 'Deus meus', 'vocātīvus singulāris (Deus meus)', 'plūrālis (dii mei)', 'Plusieurs dieux invoqués.', 'numerus', 'd.2.nom.sg', 'Deus meus singulāre est.'),
       D('Mon Dieu, mon Dieu, pourquoi nous as-tu abandonnés?', 'me', 'singulāris (me)', 'plūrālis (nos)', 'Plusieurs abandonnés.', 'numerus', '', 'Me singulāre est; nos esset plūrāle.')]),
]

# ============================================================ th-tempus-praeteritum
ITEMS += [
    I('th-tempus-praeteritum', 'JOH 1:1', 'In principio erat Verbum, et Verbum erat apud Deum', 'Au commencement était la Parole, et la Parole était avec Dieu',
      T('erat', 'sum', 'v.fam.sum', 'indicātīvus imperfectī, tertia persōna singulāris'),
      [D('Au commencement est la Parole, et la Parole est avec Dieu', 'erat', 'imperfectum (erat)', 'praesēns (est)', 'L\'énoncé passe du passé au présent.', 'tempus', 'v.fam.sum', 'Erat imperfectum verbī sum est (era-); est esset praesēns.'),
       D('Au commencement fut la Parole, et la Parole fut avec Dieu', 'erat', 'imperfectum (erat: āctiō dūrāns)', 'perfectum (fuit)', 'Un état durable devient un fait ponctuel.', 'tempus', 'v.fam.sum', 'Erat imperfectum est; fuit esset perfectum.'),
       D('Au commencement sera la Parole, et la Parole sera avec Dieu', 'erat', 'imperfectum (erat)', 'futūrum (erit)', 'L\'énoncé est reporté dans l\'avenir.', 'tempus', 'v.fam.sum', 'Erat imperfectum est; erit esset futūrum.')]),
    I('th-tempus-praeteritum', 'GEN 1:3', 'Dixitque Deus: Fiat lux. Et facta est lux.', 'Dieu dit: Que la lumière soit! Et la lumière fut.',
      T('facta est', 'facio', 'v.ind.perf.pass', 'indicātīvus perfectī passīvī (fīō), tertia persōna singulāris'),
      [D('Dieu dit: Que la lumière soit! Et la lumière était.', 'facta est', 'perfectum (facta est)', 'imperfectum (facta erat / fiebat)', 'La lumière n\'apparaît plus : elle était déjà là.', 'tempus', 'v.ind.perf.pass', 'Facta est perfectum est: participium + est; imperfectum esset fiebat.'),
       D('Dieu dit: Que la lumière soit! Et la lumière sera.', 'facta est', 'perfectum (facta est)', 'futūrum (fiet)', 'La création est reportée.', 'tempus', 'v.ind.perf.pass', 'Facta est perfectum est; fiet esset futūrum.'),
       D('Dieu disait: Que la lumière soit! Et la lumière fut.', 'Dixitque', 'perfectum (dixit)', 'imperfectum (dicebat)', 'La parole devient répétée ou continue.', 'tempus', 'v.ind.perf.act', 'Dixit perfectum est (thema dix-); dicebat esset imperfectum.')]),
    I('th-tempus-praeteritum', 'JOH 16:33', 'In mundo pressuram habebitis: sed confidite, ego vici mundum.', 'Vous aurez des tribulations dans le monde; mais prenez courage, j’ai vaincu le monde.',
      T('vici', 'vinco', 'v.ind.perf.act', 'indicātīvus perfectī, prīma persōna singulāris'),
      [D('Vous aurez des tribulations dans le monde; mais prenez courage, je vaincs le monde.', 'vici', 'perfectum (vici)', 'praesēns (vinco)', 'La victoire n\'est plus acquise.', 'tempus', 'v.ind.perf.act', 'Vici perfectum est (thema vic-); vinco esset praesēns.'),
       D('Vous aurez des tribulations dans le monde; mais prenez courage, je vaincrai le monde.', 'vici', 'perfectum (vici)', 'futūrum (vincam)', 'La victoire est remise à plus tard.', 'tempus', 'v.ind.perf.act', 'Vici perfectum est; vincam esset futūrum.'),
       D('Vous avez des tribulations dans le monde; mais prenez courage, j\'ai vaincu le monde.', 'habebitis', 'futūrum (habebitis)', 'praesēns (habetis)', 'Les épreuves annoncées deviennent présentes.', 'tempus', 'v.ind.fut.act', 'Habebitis futūrum est (-bi-); habetis esset praesēns.')]),
    I('th-tempus-praeteritum', 'LUK 15:24', 'quia hic filius meus mortuus erat, et revixit: perierat, et inventus est.', 'car mon fils que voici était mort, et il est revenu à la vie; il était perdu, et il est retrouvé.',
      T('revixit', 'revivo', 'v.ind.perf.act', 'indicātīvus perfectī, tertia persōna singulāris'),
      [D('car mon fils que voici est mort, et il est revenu à la vie; il était perdu, et il est retrouvé.', 'mortuus erat', 'plūsquamperfectum (mortuus erat)', 'praesēns (mortuus est)', 'Le fils est déclaré mort maintenant.', 'tempus', 'v.ind.plusq.pass', 'Mortuus erat plūsquamperfectum est (participium + erat).'),
       D('car mon fils que voici était mort, et il est revenu à la vie; il était perdu, et il était retrouvé.', 'inventus est', 'perfectum (inventus est)', 'imperfectum / plūsquamperfectum (inventus erat)', 'La joie du présent devient un fait passé.', 'tempus', 'v.ind.perf.pass', 'Inventus est perfectum est: participium + est.'),
       D('car mon fils que voici était mort, et il revient à la vie; il était perdu, et il est retrouvé.', 'revixit', 'perfectum (revixit)', 'praesēns (reviviscit)', 'Le retour à la vie est en cours au lieu d\'accompli.', 'tempus', 'v.ind.perf.act', 'Revixit perfectum est (-x-, -it).')]),
    I('th-tempus-praeteritum', '2TI 4:7', 'Bonum certamen certavi, cursum consummavi, fidem servavi.', 'J’ai combattu le bon combat, j’ai achevé la course, j’ai gardé la foi.',
      T('servavi', 'servo', 'v.ind.perf.act', 'indicātīvus perfectī, prīma persōna singulāris'),
      [D('Je combats le bon combat, j\'achève la course, je garde la foi.', 'certavi', 'perfectum (certavi, consummavi, servavi)', 'praesēns (certo, consummo, servo)', 'Le bilan devient une action en cours.', 'tempus', 'v.ind.perf.act', 'Thema perfectī -āv- et dēsinentia -ī: perfectum.'),
       D('Je combattais le bon combat, j\'achevais la course, je gardais la foi.', 'certavi', 'perfectum', 'imperfectum (certabam …)', 'Le bilan devient une durée passée sans achèvement.', 'tempus', 'v.ind.perf.act', 'Perfectum rem absolūtam dīcit; imperfectum esset -ba-.'),
       D('J\'ai combattu le bon combat, j\'ai achevé la course, je garderai la foi.', 'servavi', 'perfectum (servavi)', 'futūrum (servabo)', 'La fidélité devient une promesse.', 'tempus', 'v.ind.perf.act', 'Servavi perfectum est; servabo esset futūrum.')]),
    I('th-tempus-praeteritum', 'PSA 136:1', 'Super flumina Babylonis illic sedimus et flevimus', 'Au bord des fleuves de Babylone, là nous nous sommes assis et nous avons pleuré', paed=True,
      target=T('flevimus', 'fleo', 'v.ind.perf.act', 'indicātīvus perfectī, prīma persōna plūrālis'),
      dist=[D('Au bord des fleuves de Babylone, là nous nous asseyons et nous pleurons', 'sedimus', 'perfectum (sedimus, flevimus)', 'praesēns (sedemus, flemus)', 'La scène devient présente.', 'tempus', 'v.ind.perf.act', 'Sedimus (thema sēd-) et flevimus (flēv-) perfecta sunt.'),
            D('Au bord des fleuves de Babylone, là nous étions assis et nous pleurions', 'sedimus', 'perfectum (sedimus, flevimus)', 'imperfectum (sedebamus, flebamus)', 'Un fait accompli devient un état qui dure.', 'tempus', 'v.ind.perf.act', 'Perfectum est: dēsinentia -imus post thema perfectī; imperfectum esset -bamus.'),
            D('Au bord des fleuves de Babylone, là nous nous assiérons et nous pleurerons', 'flevimus', 'perfectum (flevimus)', 'futūrum (flebimus)', 'Le deuil est annoncé au lieu d\'être raconté.', 'tempus', 'v.ind.perf.act', 'Flevimus perfectum est; flebimus esset futūrum.')],
      note='Segond rend à l\'imparfait (« nous étions assis et nous pleurions ») ; le latin a deux parfaits.'),
    I('th-tempus-praeteritum', 'MAT 28:6', 'Non est hic: surrexit enim, sicut dixit', 'Il n’est point ici; il est ressuscité, comme il l’avait dit.',
      T('surrexit', 'surgo', 'v.ind.perf.act', 'indicātīvus perfectī, tertia persōna singulāris'),
      [D('Il n\'était point ici; il est ressuscité, comme il l\'avait dit.', 'est', 'praesēns (est)', 'imperfectum (erat)', 'L\'absence devient passée.', 'tempus', 'v.fam.sum', 'Est praesēns est; erat esset imperfectum.'),
       D('Il n\'est point ici; il ressuscite, comme il l\'avait dit.', 'surrexit', 'perfectum (surrexit)', 'praesēns (surgit)', 'La résurrection serait en cours.', 'tempus', 'v.ind.perf.act', 'Surrexit perfectum est (thema surrēx-).'),
       D('Il n\'est point ici; il est ressuscité, comme il le dit.', 'dixit', 'perfectum (dixit)', 'praesēns (dicit)', 'La prédiction devient une parole présente.', 'tempus', 'v.ind.perf.act', 'Dixit perfectum est; dicit esset praesēns.')]),
    I('th-tempus-praeteritum', 'LUK 24:32', 'Nonne cor nostrum ardens erat in nobis dum loqueretur in via', 'Notre cœur ne brûlait-il pas au-dedans de nous, lorsqu’il nous parlait en chemin',
      T('erat', 'sum', 'v.fam.sum', 'indicātīvus imperfectī (ardens erat: periphrasis)'),
      [D('Notre cœur ne brûle-t-il pas au-dedans de nous, lorsqu\'il nous parle en chemin', 'erat', 'imperfectum (ardens erat, loqueretur)', 'praesēns (ardens est, loquatur)', 'Le souvenir devient une expérience présente.', 'tempus', 'v.fam.sum', 'Erat et loqueretur imperfecta sunt.'),
       D('Notre cœur n\'a-t-il pas brûlé au-dedans de nous, lorsqu\'il nous parlait en chemin', 'erat', 'imperfectum (ardens erat)', 'perfectum (arsit)', 'La brûlure durable devient ponctuelle.', 'tempus', 'v.fam.sum', 'Ardens erat āctiōnem dūrantem dīcit; perfectum esset arsit.'),
       D('Notre cœur ne brûlait-il pas au-dedans de nous, lorsqu\'il nous a parlé en chemin', 'loqueretur', 'subiūnctīvus imperfectī (loqueretur)', 'perfectum (locutus est)', 'L\'entretien devient un fait ponctuel achevé.', 'tempus', 'v.subj.imperf.act', 'Loqueretur imperfectum est (īnfīnītīvus + -tur); locutus est esset perfectum.')]),
    I('th-tempus-praeteritum', 'JOH 19:30', 'Consummatum est.', 'Tout est accompli.',
      T('Consummatum est', 'consummo', 'v.ind.perf.pass', 'indicātīvus perfectī passīvī, tertia persōna singulāris neutrī'),
      [D('Tout s\'accomplit.', 'Consummatum est', 'perfectum (consummatum est)', 'praesēns (consummatur)', 'L\'accomplissement serait en cours.', 'tempus', 'v.ind.perf.pass', 'Participium perfectī + est perfectum passīvum est; praesēns esset consummatur.'),
       D('Tout sera accompli.', 'Consummatum est', 'perfectum', 'futūrum (consummabitur)', 'L\'accomplissement est remis à plus tard.', 'tempus', 'v.ind.perf.pass', 'Consummatum est perfectum est; futūrum esset consummabitur.'),
       D('Tout s\'accomplissait.', 'Consummatum est', 'perfectum', 'imperfectum (consummabatur)', 'Un processus passé au lieu d\'un achèvement.', 'tempus', 'v.ind.perf.pass', 'Perfectum rem absolūtam dīcit; imperfectum esset -batur.')]),
    I('th-tempus-praeteritum', 'GEN 37:3', 'Israël autem diligebat Joseph super omnes filios suos', 'Israël aimait Joseph plus que tous ses autres fils',
      T('diligebat', 'diligo', 'v.ind.imperf.act', 'indicātīvus imperfectī, tertia persōna singulāris'),
      [D('Israël aima Joseph plus que tous ses autres fils', 'diligebat', 'imperfectum (diligebat)', 'perfectum (dilexit)', 'Un amour durable devient un fait ponctuel.', 'tempus', 'v.ind.imperf.act', 'Signum -ba- imperfectum ostendit; dilexit esset perfectum.'),
       D('Israël aime Joseph plus que tous ses autres fils', 'diligebat', 'imperfectum (diligebat)', 'praesēns (diligit)', 'Le récit passe au présent.', 'tempus', 'v.ind.imperf.act', 'Diligebat imperfectum est; diligit esset praesēns.'),
       D('Israël aimera Joseph plus que tous ses autres fils', 'diligebat', 'imperfectum (diligebat)', 'futūrum (diliget)', 'Le récit passe au futur.', 'tempus', 'v.ind.imperf.act', 'Diligebat imperfectum est; diliget esset futūrum.')]),
    I('th-tempus-praeteritum', 'JOH 11:35', 'Et lacrimatus est Jesus.', 'Jésus pleura.',
      T('lacrimatus est', 'lacrimor', 'v.dep', 'indicātīvus perfectī (dēpōnēns), tertia persōna singulāris'),
      [D('Jésus pleure.', 'lacrimatus est', 'perfectum (lacrimatus est)', 'praesēns (lacrimatur)', 'Les larmes deviennent présentes.', 'tempus', 'v.dep', 'Participium + est perfectum dēpōnentis est; praesēns esset lacrimatur.'),
       D('Jésus pleurait.', 'lacrimatus est', 'perfectum', 'imperfectum (lacrimabatur)', 'Un pleur ponctuel devient une durée.', 'tempus', 'v.dep', 'Lacrimatus est perfectum est; imperfectum esset -batur.'),
       D('Jésus pleurera.', 'lacrimatus est', 'perfectum', 'futūrum (lacrimabitur)', 'Les larmes sont annoncées.', 'tempus', 'v.dep', 'Perfectum est; futūrum esset lacrimabitur.')]),
    I('th-tempus-praeteritum', 'LUK 1:48', 'Quia respexit humilitatem ancillæ suæ', 'Parce qu’il a jeté les yeux sur la bassesse de sa servante.',
      T('respexit', 'respicio', 'v.ind.perf.act', 'indicātīvus perfectī, tertia persōna singulāris'),
      [D('Parce qu\'il jette les yeux sur la bassesse de sa servante.', 'respexit', 'perfectum (respexit)', 'praesēns (respicit)', 'Le regard devient présent.', 'tempus', 'v.ind.perf.act', 'Respexit perfectum est (thema respex-).'),
       D('Parce qu\'il jetait les yeux sur la bassesse de sa servante.', 'respexit', 'perfectum', 'imperfectum (respiciebat)', 'Un regard habituel au lieu d\'un acte accompli.', 'tempus', 'v.ind.perf.act', 'Perfectum est; imperfectum esset respiciebat.'),
       D('Parce qu\'il jettera les yeux sur la bassesse de sa servante.', 'respexit', 'perfectum', 'futūrum (respiciet)', 'Le regard est annoncé.', 'tempus', 'v.ind.perf.act', 'Perfectum est; futūrum esset respiciet.')]),
    I('th-tempus-praeteritum', 'PSA 129:1', 'De profundis clamavi ad te, Domine;', 'Des profondeurs j\'ai crié vers toi, Seigneur.', paed=True,
      target=T('clamavi', 'clamo', 'v.ind.perf.act', 'indicātīvus perfectī, prīma persōna singulāris'),
      dist=[D('Des profondeurs je crie vers toi, Seigneur.', 'clamavi', 'perfectum (clamavi)', 'praesēns (clamo)', 'Le cri devient présent.', 'tempus', 'v.ind.perf.act', 'Clamavi perfectum est (-āv-ī); clamo esset praesēns.'),
            D('Des profondeurs je criais vers toi, Seigneur.', 'clamavi', 'perfectum', 'imperfectum (clamabam)', 'Un cri répété au lieu d\'un cri accompli.', 'tempus', 'v.ind.perf.act', 'Perfectum est; imperfectum esset clamabam.'),
            D('Des profondeurs je crierai vers toi, Seigneur.', 'clamavi', 'perfectum', 'futūrum (clamabo)', 'Le cri est annoncé.', 'tempus', 'v.ind.perf.act', 'Perfectum est; futūrum esset clamabo.')],
      note='Segond a le présent (« je t\'invoque ») ; le latin a un parfait.'),
]

# ============================================================ th-tempus-futurum
ITEMS += [
    I('th-tempus-futurum', 'EXO 20:13', 'Non occides.', 'Tu ne tueras point.',
      T('occides', 'occido', 'v.ind.fut.act', 'indicātīvus futūrī, secunda persōna singulāris (praeceptum)'),
      [D('Tu ne tues point.', 'occides', 'futūrum (occides)', 'praesēns (occidis)', 'Le commandement devient un constat.', 'tempus', 'v.ind.fut.act', 'Occides futūrum tertiae coniugātiōnis est (-ēs); occidis esset praesēns (-is).'),
       D('Tu n\'as point tué.', 'occides', 'futūrum', 'perfectum (occidisti)', 'Le commandement devient un bilan passé.', 'tempus', 'v.ind.fut.act', 'Occides futūrum est; occidisti esset perfectum.'),
       D('Tu ne tuais point.', 'occides', 'futūrum', 'imperfectum (occidebas)', 'Le commandement devient un récit.', 'tempus', 'v.ind.fut.act', 'Futūrum est; imperfectum esset -bas.')]),
    I('th-tempus-futurum', 'MAT 5:5', 'Beati qui lugent: quoniam ipsi consolabuntur.', 'Heureux les affligés, car ils seront consolés!', fr_ref='MAT 5:4',
      target=T('consolabuntur', 'consolor', 'v.dep', 'indicātīvus futūrī (fōrma passīva), tertia persōna plūrālis'),
      dist=[D('Heureux les affligés, car ils sont consolés!', 'consolabuntur', 'futūrum (consolabuntur)', 'praesēns (consolantur)', 'La consolation est déjà là.', 'tempus', 'v.ind.fut.pass', 'Signum -bu- futūrum ostendit; consolantur esset praesēns.'),
            D('Heureux les affligés, car ils ont été consolés!', 'consolabuntur', 'futūrum', 'perfectum (consolati sunt)', 'La consolation est passée.', 'tempus', 'v.ind.fut.pass', 'Consolabuntur futūrum est; perfectum esset consolati sunt.'),
            D('Heureux ceux qui pleuraient, car ils seront consolés!', 'lugent', 'praesēns (lugent)', 'imperfectum (lugebant)', 'L\'affliction est rejetée dans le passé.', 'tempus', 'v.ind.praes.act', 'Lugent praesēns est; lugebant esset imperfectum.')],
      note='La Vulgate (5:5) et Segond (5:4) numérotent cette béatitude différemment.'),
    I('th-tempus-futurum', 'LUK 1:31', 'Ecce concipies in utero, et paries filium, et vocabis nomen ejus Jesum', 'Et voici, tu deviendras enceinte, et tu enfanteras un fils, et tu lui donneras le nom de Jésus.',
      T('paries', 'pario', 'v.ind.fut.act', 'indicātīvus futūrī, secunda persōna singulāris'),
      [D('Et voici, tu es devenue enceinte, et tu as enfanté un fils, et tu lui as donné le nom de Jésus.', 'concipies', 'futūrum (concipies, paries, vocabis)', 'perfectum (concepisti …)', 'L\'annonce devient un récit accompli.', 'tempus', 'v.ind.fut.act', 'Concipies, paries (-ēs) et vocabis (-bi-) futūra sunt.'),
       D('Et voici, tu deviens enceinte, et tu enfantes un fils, et tu lui donnes le nom de Jésus.', 'concipies', 'futūrum', 'praesēns (concipis, paris, vocas)', 'L\'annonce devient présente.', 'tempus', 'v.ind.fut.act', 'Futūra sunt; praesēns esset concipis, paris, vocas.'),
       D('Et voici, tu deviendras enceinte, et tu enfanteras un fils, et tu lui as donné le nom de Jésus.', 'vocabis', 'futūrum (vocabis)', 'perfectum (vocavisti)', 'Le nom aurait déjà été donné.', 'tempus', 'v.ind.fut.act', 'Vocabis futūrum est (-bi-); vocavisti esset perfectum.')]),
    I('th-tempus-futurum', 'GEN 1:31', 'Viditque Deus cuncta quæ fecerat, et erant valde bona.', 'Dieu vit tout ce qu’il avait fait et voici, cela était très bon.',
      T('fecerat', 'facio', 'v.ind.plusq.act', 'indicātīvus plūsquamperfectī, tertia persōna singulāris'),
      [D('Dieu vit tout ce qu\'il fit, et voici, cela était très bon.', 'fecerat', 'plūsquamperfectum (fecerat)', 'perfectum (fecit)', 'L\'antériorité de la création par rapport au regard disparaît.', 'tempus', 'v.ind.plusq.act', 'Fecerat plūsquamperfectum est (-era-); fecit esset perfectum.'),
       D('Dieu vit tout ce qu\'il fera, et voici, cela était très bon.', 'fecerat', 'plūsquamperfectum', 'futūrum (faciet)', 'Dieu regarderait une création à venir.', 'tempus', 'v.ind.plusq.act', 'Fecerat plūsquamperfectum est; faciet esset futūrum.'),
       D('Dieu voit tout ce qu\'il avait fait, et voici, cela était très bon.', 'Viditque', 'perfectum (vidit)', 'praesēns (videt)', 'Le regard devient présent.', 'tempus', 'v.ind.perf.act', 'Vidit perfectum est (thema vīd-); videt esset praesēns.')]),
    I('th-tempus-futurum', 'MAT 1:21', 'ipse enim salvum faciet populum suum a peccatis eorum.', 'c’est lui qui sauvera son peuple de ses péchés.',
      T('faciet', 'facio', 'v.ind.fut.act', 'indicātīvus futūrī, tertia persōna singulāris'),
      [D('c\'est lui qui sauve son peuple de ses péchés.', 'faciet', 'futūrum (faciet)', 'praesēns (facit)', 'Le salut annoncé devient présent.', 'tempus', 'v.ind.fut.act', 'Faciet futūrum est (-iet); facit esset praesēns.'),
       D('c\'est lui qui a sauvé son peuple de ses péchés.', 'faciet', 'futūrum', 'perfectum (fecit)', 'Le salut serait déjà accompli.', 'tempus', 'v.ind.fut.act', 'Faciet futūrum est; fecit esset perfectum.'),
       D('c\'est lui qui sauvait son peuple de ses péchés.', 'faciet', 'futūrum', 'imperfectum (faciebat)', 'Le salut devient un passé continu.', 'tempus', 'v.ind.fut.act', 'Futūrum est; imperfectum esset faciebat.')]),
    I('th-tempus-futurum', 'REV 21:4', 'et absterget Deus omnem lacrimam ab oculis eorum: et mors ultra non erit', 'Il essuiera toute larme de leurs yeux, et la mort ne sera plus',
      T('absterget', 'abstergeo', 'v.ind.fut.act', 'indicātīvus futūrī, tertia persōna singulāris'),
      [D('Il essuie toute larme de leurs yeux, et la mort n\'est plus', 'absterget', 'futūrum (absterget, erit)', 'praesēns (abstergit, est)', 'La promesse devient une réalité présente.', 'tempus', 'v.ind.fut.act', 'Absterget (-et, II coniugātiō: abstergēbit? nōn: abstergēt) et erit futūra sunt.'),
       D('Il a essuyé toute larme de leurs yeux, et la mort n\'a plus été', 'absterget', 'futūrum', 'perfectum (abstersit, fuit)', 'La promesse devient un fait passé.', 'tempus', 'v.ind.fut.act', 'Futūrum est; perfectum esset abstersit.'),
       D('Il essuiera toute larme de leurs yeux, et la mort n\'était plus', 'erit', 'futūrum (erit)', 'imperfectum (erat)', 'La fin de la mort est déplacée dans le passé.', 'tempus', 'v.fam.sum', 'Erit futūrum verbī sum est; erat esset imperfectum.')]),
    I('th-tempus-futurum', 'MAT 25:21', 'quia super pauca fuisti fidelis, super multa te constituam', 'tu as été fidèle enpeu de chose, je te confierai beaucoup',
      T('constituam', 'constituo', 'v.ind.fut.act', 'indicātīvus futūrī, prīma persōna singulāris'),
      [D('tu es fidèle en peu de chose, je te confierai beaucoup', 'fuisti', 'perfectum (fuisti)', 'praesēns (es)', 'La fidélité passée devient présente.', 'tempus', 'v.fam.sum', 'Fuisti perfectum est (fu-isti); es esset praesēns.'),
       D('tu as été fidèle en peu de chose, je t\'ai confié beaucoup', 'constituam', 'futūrum (constituam)', 'perfectum (constitui)', 'La récompense serait déjà donnée.', 'tempus', 'v.ind.fut.act', 'Constituam futūrum est (-am, III coniugātiō); constitui esset perfectum.'),
       D('tu étais fidèle en peu de chose, je te confierai beaucoup', 'fuisti', 'perfectum (fuisti)', 'imperfectum (eras)', 'Un fait accompli devient un état passé.', 'tempus', 'v.fam.sum', 'Fuisti perfectum est; eras esset imperfectum.')]),
    I('th-tempus-futurum', 'JOH 14:2', 'vado parare vobis locum.', 'Je vais vous préparer une place.',
      T('vado', 'vado', 'v.ind.praes.act', 'indicātīvus praesentis, prīma persōna singulāris'),
      [D('J\'irai vous préparer une place.', 'vado', 'praesēns (vado)', 'futūrum (vadam)', 'Le départ est remis à plus tard.', 'tempus', 'v.ind.praes.act', 'Vado praesēns est (-ō); vadam esset futūrum.'),
       D('Je suis allé vous préparer une place.', 'vado', 'praesēns', 'perfectum', 'Le départ serait déjà accompli.', 'tempus', 'v.ind.praes.act', 'Vado praesēns est.'),
       D('J\'allais vous préparer une place.', 'vado', 'praesēns', 'imperfectum (vadebam)', 'Le départ devient un récit passé.', 'tempus', 'v.ind.praes.act', 'Praesēns est; imperfectum esset vadebam.')]),
    I('th-tempus-futurum', 'LUK 23:43', 'hodie mecum eris in paradiso.', 'aujourd’hui tu seras avec moi dans le paradis.',
      T('eris', 'sum', 'v.fam.sum', 'indicātīvus futūrī, secunda persōna singulāris'),
      [D('aujourd\'hui tu es avec moi dans le paradis.', 'eris', 'futūrum (eris)', 'praesēns (es)', 'La promesse devient un présent.', 'tempus', 'v.fam.sum', 'Eris futūrum verbī sum est; es esset praesēns.'),
       D('aujourd\'hui tu étais avec moi dans le paradis.', 'eris', 'futūrum', 'imperfectum (eras)', 'La promesse devient un souvenir.', 'tempus', 'v.fam.sum', 'Eris futūrum est; eras esset imperfectum.'),
       D('aujourd\'hui tu as été avec moi dans le paradis.', 'eris', 'futūrum', 'perfectum (fuisti)', 'La promesse devient un fait passé.', 'tempus', 'v.fam.sum', 'Eris futūrum est; fuisti esset perfectum.')]),
    I('th-tempus-futurum', 'MAT 23:12', 'Qui autem se exaltaverit, humiliabitur: et qui se humiliaverit, exaltabitur.', 'Quiconque s’élèvera sera abaissé, et quiconque s’abaissera sera élevé.',
      T('humiliabitur', 'humilio', 'v.ind.fut.pass', 'indicātīvus futūrī passīvī, tertia persōna singulāris'),
      [D('Quiconque s\'est élevé a été abaissé, et quiconque s\'est abaissé a été élevé.', 'humiliabitur', 'futūrum (humiliabitur, exaltabitur)', 'perfectum (humiliatus est …)', 'La sentence devient un bilan passé.', 'tempus', 'v.ind.fut.pass', 'Humiliabitur et exaltabitur futūra sunt (-bi-tur).'),
       D('Quiconque s\'élève est abaissé, et quiconque s\'abaisse est élevé.', 'humiliabitur', 'futūrum', 'praesēns (humiliatur)', 'La sentence devient une loi présente.', 'tempus', 'v.ind.fut.pass', 'Futūrum est; praesēns esset humiliatur.'),
       D('Quiconque s\'élevait était abaissé, et quiconque s\'abaissait était élevé.', 'exaltaverit', 'futūrum exāctum (exaltaverit)', 'imperfectum (exaltabat)', 'La sentence devient un récit du passé.', 'tempus', 'v.ind.futex.act', 'Exaltaverit futūrum exāctum est (-eri-); imperfectum esset -bat.')]),
    I('th-tempus-futurum', 'GEN 12:2', 'Faciamque te in gentem magnam, et benedicam tibi, et magnificabo nomen tuum', 'Je ferai de toi une grande nation, et je te bénirai; je rendrai ton nom grand',
      T('magnificabo', 'magnifico', 'v.ind.fut.act', 'indicātīvus futūrī, prīma persōna singulāris'),
      [D('J\'ai fait de toi une grande nation, et je t\'ai béni; j\'ai rendu ton nom grand', 'Faciamque', 'futūrum (faciam, benedicam, magnificabo)', 'perfectum (feci …)', 'La promesse devient un bilan.', 'tempus', 'v.ind.fut.act', 'Faciam, benedicam (-am) et magnificabo (-bo) futūra sunt.'),
       D('Je fais de toi une grande nation, et je te bénis; je rends ton nom grand', 'Faciamque', 'futūrum', 'praesēns (facio, benedico, magnifico)', 'La promesse devient présente.', 'tempus', 'v.ind.fut.act', 'Futūra sunt; praesēns esset facio, benedico, magnifico.'),
       D('Je ferai de toi une grande nation, et je te bénirai; j\'ai rendu ton nom grand', 'magnificabo', 'futūrum (magnificabo)', 'perfectum (magnificavi)', 'La grandeur du nom serait déjà acquise.', 'tempus', 'v.ind.fut.act', 'Magnificabo futūrum est (-bō); magnificavi esset perfectum.')]),
]

# ============================================================ th-casus-obliqui
ITEMS += [
    I('th-casus-obliqui', 'LUK 2:14', 'Gloria in altissimis Deo, et in terra pax hominibus bonæ voluntatis.', 'Gloire à Dieu au plus haut des cieux, et paix sur la terre aux hommes de bonne volonté.', paed=True,
      target=T('Deo', 'deus', 'd.2.dat.sg', 'datīvus singulāris (cui glōria)'),
      dist=[D('Gloire par Dieu au plus haut des cieux, et paix sur la terre aux hommes de bonne volonté.', 'Deo', 'datīvus (Deo: cui glōria datur)', 'ablātīvus (Deo: ā quō)', 'Dieu devient la source de la gloire au lieu de son destinataire.', 'casus', 'd.2.dat.sg', 'Deo datīvus et ablātīvus eādem fōrmā sunt; glōria alicui datur, ergō datīvus.'),
            D('Gloire à Dieu au plus haut des cieux, et paix sur la terre par les hommes de bonne volonté.', 'hominibus', 'datīvus plūrālis (hominibus: quibus pāx)', 'ablātīvus (per hominēs)', 'Les hommes deviennent les auteurs de la paix.', 'casus', 'd.3.dat.pl', 'Hominibus datīvus aut ablātīvus est; pāx alicui datur, ergō datīvus.'),
            D('Gloire à Dieu au plus haut des cieux, et paix sur la terre aux hommes et à la bonne volonté.', 'bonæ voluntatis', 'genetīvus (bonæ voluntatis: quālium hominum)', 'datīvus (bonæ voluntati)', 'La bonne volonté devient un second destinataire au lieu de qualifier les hommes.', 'casus', 'd.3.gen.sg', 'Voluntatis genetīvus tertiae dēclīnātiōnis est (-is); datīvus esset voluntati.')]),
    I('th-casus-obliqui', 'JOH 8:12', 'qui sequitur me, non ambulat in tenebris, sed habebit lumen vitæ.', 'celui qui me suit ne marche pas dans les ténèbres, mais il aura la lumière de la vie.', paed=True,
      target=T('vitæ', 'vita', 'd.1.gen.sg', 'genetīvus singulāris'),
      dist=[D('celui qui me suit ne marche pas dans les ténèbres, mais il aura la lumière pour la vie.', 'vitæ', 'genetīvus (vitæ: cuius lūmen)', 'datīvus (vitæ: cui)', 'La vie devient la destinataire de la lumière au lieu de sa nature.', 'casus', 'd.1.gen.sg', 'Vitæ genetīvus et datīvus eādem fōrmā sunt; lūmen vitæ = lūmen quod vīta est.'),
            D('celui qui me suit ne marche pas dans les ténèbres, mais il aura les lumières de la vie.', 'lumen', 'accūsātīvus singulāris (lumen)', 'plūrālis (lumina)', 'Plusieurs lumières.', 'numerus', 'd.3.acc.sg', 'Lumen singulāre est.'),
            D('ceux qui me suivent ne marchent pas dans les ténèbres, mais ils auront la lumière de la vie.', 'sequitur', 'singulāris (qui sequitur, ambulat, habebit)', 'plūrālis (qui sequuntur …)', 'Plusieurs disciples au lieu d\'un.', 'numerus', 'v.dep', 'Sequitur, ambulat, habebit singulāria sunt.')],
      note='Segond a « ne marchera pas » (futur) pour ambulat (présent) ; rendu pédagogique.'),
    I('th-casus-obliqui', 'MAT 28:18', 'Data est mihi omnis potestas in cælo et in terra', 'Tout pouvoir m’a été donné dans le ciel et sur la terre.',
      T('mihi', 'ego', '', 'datīvus (cui datur)'),
      [D('Tout pouvoir a été donné par moi dans le ciel et sur la terre.', 'mihi', 'datīvus (mihi: cui datur)', 'ablātīvus auctōris (ā mē)', 'Le Christ devient celui qui donne au lieu de celui qui reçoit.', 'casus', '', 'Mihi datīvus est; auctor esset ā mē.'),
       D('Tous les pouvoirs m\'ont été donnés dans le ciel et sur la terre.', 'omnis potestas', 'singulāris (omnis potestas)', 'plūrālis (omnes potestates)', 'Plusieurs pouvoirs.', 'numerus', 'd.3.nom.sg', 'Omnis potestas singulāre est.'),
       D('Tout pouvoir m\'a été donné dans les cieux et sur la terre.', 'cælo', 'ablātīvus singulāris (cælo)', 'plūrālis (cælis)', 'Plusieurs cieux.', 'numerus', 'd.2.abl.sg', 'In cælo singulāre est.')]),
    I('th-casus-obliqui', 'JAM 4:6', 'Deus superbis resistit, humilibus autem dat gratiam.', 'Dieu résiste aux orgueilleux, Mais il fait grâce aux humbles.',
      T('humilibus', 'humilis', 'd.3.dat.pl', 'datīvus plūrālis (quibus dat)'),
      [D('Dieu résiste aux orgueilleux, mais il fait grâce par les humbles.', 'humilibus', 'datīvus (humilibus: quibus dat)', 'ablātīvus (per humilēs)', 'Les humbles deviennent le moyen de la grâce au lieu de ses destinataires.', 'casus', 'd.3.dat.pl', 'Humilibus datīvus aut ablātīvus est; dat alicui, ergō datīvus.'),
       D('Dieu résiste par les orgueilleux, mais il fait grâce aux humbles.', 'superbis', 'datīvus (superbis: quibus resistit)', 'ablātīvus (per superbōs)', 'Les orgueilleux deviennent un instrument de Dieu.', 'casus', 'd.2.dat.pl', 'Resistere datīvum regit; superbis ergō datīvus.'),
       D('Dieu résiste à l\'orgueilleux, mais il fait grâce aux humbles.', 'superbis', 'plūrālis (superbis)', 'singulāris (superbo)', 'Un seul orgueilleux.', 'numerus', 'd.2.dat.pl', 'Superbis plūrāle est.')]),
    I('th-casus-obliqui', 'LUK 1:28', 'Ave gratia plena: Dominus tecum', 'Je te salue, pleine de grâce: le Seigneur est avec toi.', paed=True,
      target=T('gratia', 'gratia', 'd.1.abl.sg', 'ablātīvus singulāris (plena gratiā: quā rē plēna)'),
      dist=[D('Je te salue, ô grâce parfaite: le Seigneur est avec toi.', 'gratia plena', 'ablātīvus (gratiā: plēna quā rē)', 'vocātīvus (gratia plena: ō plēna grātia)', 'Marie est appelée « grâce » au lieu d\'être « pleine de grâce ».', 'casus', 'd.1.abl.sg', 'Gratia sine macrō ablātīvus (gratiā) aut nōminātīvus/vocātīvus est; plena rem quā plēna est ablātīvō dīcit.'),
            D('Je te salue, pleine de grâces: le Seigneur est avec toi.', 'gratia', 'singulāris (gratiā)', 'plūrālis (gratiis)', 'Plusieurs grâces.', 'numerus', 'd.1.abl.sg', 'Gratiā singulāre est.'),
            D('Je te salue, pleine de grâce: le Seigneur est avec vous.', 'tecum', 'singulāris (tecum)', 'plūrālis (vobiscum)', 'Plusieurs interlocuteurs.', 'numerus', '', 'Tecum singulāre est; vobiscum esset plūrāle.')],
      note='Segond suit un autre texte (« toi à qui une grâce a été faite ») ; rendu pédagogique de « gratia plena ».'),
    I('th-casus-obliqui', 'JOH 6:69', 'verba vitæ æternæ habes', 'Tu as les paroles de la vie éternelle.', fr_ref='JOH 6:68',
      target=T('vitæ', 'vita', 'd.1.gen.sg', 'genetīvus singulāris'),
      dist=[D('Tu as les paroles pour la vie éternelle.', 'vitæ æternæ', 'genetīvus (vitæ æternæ: cuius verba)', 'datīvus (vitæ æternæ: cui)', 'La vie éternelle devient la destinataire des paroles.', 'casus', 'd.1.gen.sg', 'Vitæ genetīvus et datīvus eādem fōrmā sunt; verba vitæ = verba quae vītam dant.'),
            D('Tu as la parole de la vie éternelle.', 'verba', 'accūsātīvus plūrālis (verba)', 'singulāris (verbum)', 'Une seule parole.', 'numerus', 'd.2.acc.pl', 'Verba neutrum plūrāle est.'),
            D('Vous avez les paroles de la vie éternelle.', 'habes', 'secunda singulāris (habes)', 'plūrālis (habetis)', 'Plusieurs interlocuteurs.', 'numerus', 'v.ind.praes.act', 'Habes (-s) singulāre est.')],
      note='Jean 6 : la Vulgate compte un verset de plus que Segond (Vulg. 6:69 = Segond 6:68).'),
    I('th-casus-obliqui', 'MAT 6:12', 'et dimitte nobis debita nostra, sicut et nos dimittimus debitoribus nostris.', 'et remets-nous nos dettes, comme nous aussi nous les remettons à nos débiteurs.', paed=True,
      target=T('debitoribus', 'debitor', 'd.3.dat.pl', 'datīvus plūrālis (quibus dīmittimus)'),
      dist=[D('et remets par nous nos dettes, comme nous aussi nous les remettons à nos débiteurs.', 'nobis', 'datīvus (nobis: quibus dīmittitur)', 'ablātīvus (per nōs)', 'Nous devenons le moyen du pardon au lieu de ses bénéficiaires.', 'casus', '', 'Nobis datīvus aut ablātīvus est; dīmittere alicui datīvum regit.'),
            D('et remets-nous nos dettes, comme nous aussi nous les remettons par nos débiteurs.', 'debitoribus', 'datīvus (debitoribus)', 'ablātīvus (per dēbitōrēs)', 'Les débiteurs deviennent un instrument au lieu des bénéficiaires.', 'casus', 'd.3.dat.pl', 'Debitoribus datīvus est: iīs quibus dīmittimus.'),
            D('et remets-nous notre dette, comme nous aussi nous la remettons à nos débiteurs.', 'debita', 'accūsātīvus plūrālis (debita nostra)', 'singulāris (debitum nostrum)', 'Une seule dette.', 'numerus', 'd.2.acc.pl', 'Debita neutrum plūrāle est.')],
      note='Segond : « nos offenses … à ceux qui nous ont offensés » ; rendu pédagogique littéral de debita / debitoribus.'),
    I('th-casus-obliqui', 'LUK 1:38', 'Ecce ancilla Domini: fiat mihi secundum verbum tuum.', 'Voici la servante du Seigneur: qu\'il me soit fait selon ta parole.', paed=True,
      target=T('mihi', 'ego', '', 'datīvus (cui fiat)'),
      dist=[D('Voici la servante du Seigneur: qu\'il soit fait par moi selon ta parole.', 'mihi', 'datīvus (mihi: cui fiat)', 'ablātīvus auctōris (ā mē)', 'Marie deviendrait l\'auteur de ce qui s\'accomplit.', 'casus', '', 'Mihi datīvus est; auctor esset ā mē.'),
            D('Voici la servante du Seigneur: qu\'il me soit fait selon tes paroles.', 'verbum', 'accūsātīvus singulāris (verbum tuum)', 'plūrālis (verba tua)', 'Plusieurs paroles.', 'numerus', 'd.2.acc.sg', 'Verbum tuum singulāre est.'),
            D('Voici les servantes du Seigneur: qu\'il me soit fait selon ta parole.', 'ancilla', 'nōminātīvus singulāris (ancilla)', 'plūrālis (ancillæ)', 'Plusieurs servantes.', 'numerus', 'd.1.nom.sg', 'Ancilla singulāre est.')],
      note='Segond : « Je suis la servante du Seigneur » ; le latin a « Ecce ancilla Domini ».'),
    I('th-casus-obliqui', 'MAT 6:33', 'et hæc omnia adjicientur vobis.', 'et toutes ces choses vous seront données par-dessus.',
      T('vobis', 'vos', '', 'datīvus plūrālis (quibus adiiciuntur)'),
      [D('et toutes ces choses seront ajoutées par vous.', 'vobis', 'datīvus (vobis: quibus)', 'ablātīvus auctōris (ā vōbīs)', 'Les disciples deviendraient les donateurs.', 'casus', '', 'Vobis datīvus aut ablātīvus est; adiicere alicui datīvum regit.'),
       D('et toutes ces choses te seront données par-dessus.', 'vobis', 'plūrālis (vobis)', 'singulāris (tibi)', 'Un seul bénéficiaire.', 'numerus', '', 'Vobis plūrāle est.'),
       D('et toute cette chose vous sera donnée par-dessus.', 'hæc omnia', 'plūrālis (hæc omnia)', 'singulāris (hoc omne)', 'Une seule chose.', 'numerus', '', 'Hæc omnia neutrum plūrāle est.')]),
    I('th-casus-obliqui', 'MAT 25:40', 'quamdiu fecistis uni ex his fratribus meis minimis, mihi fecistis.', 'toutes les fois que vous avez fait ces choses à l’un de ces plus petits de mes frères, c’est à moi que vous les avez faites.',
      T('mihi', 'ego', '', 'datīvus (cui fēcistis)'),
      [D('toutes les fois que vous avez fait ces choses à l\'un de ces plus petits de mes frères, c\'est par moi que vous les avez faites.', 'mihi', 'datīvus (mihi: cui)', 'ablātīvus (per mē)', 'Le Christ devient l\'instrument au lieu du bénéficiaire.', 'casus', '', 'Mihi datīvus est: cui fēcistis.'),
       D('toutes les fois que tu as fait ces choses à l\'un de ces plus petits de mes frères, c\'est à moi que tu les as faites.', 'fecistis', 'plūrālis (fecistis)', 'singulāris (fecisti)', 'Un seul est jugé.', 'numerus', 'v.ind.perf.act', 'Fecistis (-istis) plūrāle est.'),
       D('toutes les fois que vous avez fait ces choses à ces plus petits de mes frères, c\'est à moi que vous les avez faites.', 'uni', 'datīvus singulāris (uni)', 'plūrālis (his)', 'Tous les petits au lieu d\'un seul.', 'numerus', '', 'Uni singulāre est: ūnī ex hīs.')]),
    I('th-casus-obliqui', 'PSA 90:11', 'Quoniam angelis suis mandavit de te, ut custodiant te in omnibus viis tuis.', 'Car il a donné ordre à ses anges à ton sujet, de te garder dans toutes tes voies.', paed=True,
      target=T('angelis', 'angelus', 'd.2.dat.pl', 'datīvus plūrālis (quibus mandāvit)'),
      dist=[D('Car il a donné ordre par ses anges à ton sujet, de te garder dans toutes tes voies.', 'angelis', 'datīvus (angelis: quibus mandat)', 'ablātīvus (per angelōs)', 'Les anges deviennent des messagers au lieu des destinataires de l\'ordre.', 'casus', 'd.2.dat.pl', 'Angelis datīvus aut ablātīvus est; mandāre alicui datīvum regit.'),
            D('Car il a donné ordre à ses anges à ton sujet, de te garder dans toute ta voie.', 'viis', 'ablātīvus plūrālis (viis)', 'singulāris (via)', 'Une seule voie.', 'numerus', 'd.1.abl.pl', 'Viis plūrāle est.'),
            D('Car il a donné ordre à son ange à ton sujet, de te garder dans toutes tes voies.', 'angelis', 'plūrālis (angelis, custodiant)', 'singulāris (angelo, custodiat)', 'Un seul ange.', 'numerus', 'd.2.dat.pl', 'Angelis et custodiant plūrālia sunt.')],
      note='Segond a le futur (« il ordonnera ») ; le latin a mandavit, parfait.'),
    I('th-casus-obliqui', 'ROM 8:28', 'diligentibus Deum omnia cooperantur in bonum', 'toutes choses concourent au bien de ceux qui aiment Dieu',
      T('diligentibus', 'diligo', 'v.part', 'datīvus plūrālis participiī (quibus omnia cooperantur)'),
      [D('toutes choses concourent au bien par ceux qui aiment Dieu', 'diligentibus', 'datīvus (diligentibus: quibus)', 'ablātīvus (per dīligentēs)', 'Ceux qui aiment Dieu deviennent le moyen au lieu des bénéficiaires.', 'casus', 'v.part', 'Diligentibus datīvus aut ablātīvus est; cooperārī alicui datīvum regit.'),
       D('toutes choses concourent au bien de celui qui aime Dieu', 'diligentibus', 'plūrālis (diligentibus)', 'singulāris (diligenti)', 'Un seul bénéficiaire.', 'numerus', 'v.part', 'Diligentibus plūrāle est.'),
       D('toute chose concourt au bien de ceux qui aiment Dieu', 'omnia', 'plūrālis (omnia cooperantur)', 'singulāris (omne cooperatur)', 'Une seule chose.', 'numerus', '', 'Omnia et cooperantur plūrālia sunt.')]),
]

# ============================================================ th-modus-imperativus
ITEMS += [
    I('th-modus-imperativus', 'MAT 11:28', 'Venite ad me omnes qui laboratis, et onerati estis, et ego reficiam vos.', 'Venez à moi, vous tous qui êtes fatigués et chargés, et je vous donnerai du repos.',
      T('Venite', 'venio', 'v.imp.praes', 'imperātīvus praesentis, secunda persōna plūrālis'),
      [D('Vous venez à moi, vous tous qui êtes fatigués et chargés, et je vous donnerai du repos.', 'Venite', 'imperātīvus (venite)', 'indicātīvus (venitis)', 'L\'appel devient un constat.', 'modus', 'v.imp.praes', 'Venite imperātīvus plūrālis est (-te); indicātīvus esset venitis.'),
       D('Viens à moi, toi qui es fatigué et chargé, et je te donnerai du repos.', 'Venite', 'plūrālis (venite, laboratis, vos)', 'singulāris (veni, laboras, te)', 'Un seul appelé.', 'numerus', 'v.imp.praes', 'Venite, laboratis, vos plūrālia sunt.'),
       D('Venez à moi, vous tous qui êtes fatigués et chargés, et il vous donnera du repos.', 'reficiam', 'prīma persōna (ego reficiam)', 'tertia (reficiet)', 'Un autre donnerait le repos.', 'persona', 'v.ind.fut.act', 'Ego reficiam prīma persōna est (-am).')]),
    I('th-modus-imperativus', 'LUK 2:10', 'Nolite timere: ecce enim evangelizo vobis gaudium magnum', 'Ne craignez point: car voici, je vous annonce une grande joie', paed=True,
      target=T('Nolite timere', 'nolo', 'v.fam.volo', 'imperātīvus negātīvus (nōlīte + īnfīnītīvus), secunda persōna plūrālis'),
      dist=[D('Vous ne voulez pas craindre: car voici, je vous annonce une grande joie', 'Nolite timere', 'imperātīvus (nolite: vetat)', 'indicātīvus (non vultis)', 'L\'interdiction de craindre devient une description.', 'modus', 'v.fam.volo', 'Nolite imperātīvus verbī nōlō est: cum īnfīnītīvō vetat; indicātīvus esset non vultis.'),
            D('Ne crains point: car voici, je t\'annonce une grande joie', 'Nolite', 'plūrālis (nolite, vobis)', 'singulāris (noli, tibi)', 'Un seul berger.', 'numerus', 'v.fam.volo', 'Nolite et vobis plūrālia sunt.'),
            D('Ne craignez point: car voici, il vous annonce une grande joie', 'evangelizo', 'prīma persōna (evangelizo)', 'tertia (evangelizat)', 'Un autre annonce.', 'persona', 'v.ind.praes.act', 'Evangelizo (-ō) prīma persōna est.')],
      note='Segond restructure la phrase (« une bonne nouvelle, qui sera … le sujet d\'une grande joie ») ; rendu pédagogique.'),
    I('th-modus-imperativus', 'MAT 7:1', 'Nolite judicare, ut non judicemini.', 'Ne jugez point, afin que vous ne soyez point jugés.',
      T('Nolite judicare', 'nolo', 'v.fam.volo', 'imperātīvus negātīvus (nōlīte + īnfīnītīvus)'),
      [D('Vous ne jugez point, afin que vous ne soyez point jugés.', 'Nolite judicare', 'imperātīvus (nolite: vetat)', 'indicātīvus (non judicatis)', 'L\'interdiction devient une description.', 'modus', 'v.fam.volo', 'Nolite + īnfīnītīvus vetat; indicātīvus esset non judicatis.'),
       D('Ne juge point, afin que tu ne sois point jugé.', 'Nolite', 'plūrālis (nolite, judicemini)', 'singulāris (noli, judiceris)', 'Un seul auditeur.', 'numerus', 'v.fam.volo', 'Nolite et judicemini plūrālia sunt.'),
       D('Ne jugez point, afin qu\'ils ne soient point jugés.', 'judicemini', 'secunda persōna (judicemini)', 'tertia (judicentur)', 'D\'autres seraient jugés.', 'persona', 'v.subj.praes.pass', 'Judicemini (-mini) secunda persōna plūrālis est.')]),
    I('th-modus-imperativus', 'MAR 5:41', 'Puella (tibi dico), surge.', 'Jeune fille, lève-toi, je te le dis.',
      T('surge', 'surgo', 'v.imp.praes', 'imperātīvus praesentis, secunda persōna singulāris'),
      [D('Jeune fille, je te le dis, elle se lève.', 'surge', 'imperātīvus (surge)', 'indicātīvus (surgit)', 'L\'ordre devient un constat sur une tierce personne.', 'modus', 'v.imp.praes', 'Surge imperātīvus singulāris est (thema nūdum); surgit esset indicātīvus.'),
       D('Jeunes filles, levez-vous, je vous le dis.', 'surge', 'singulāris (puella, tibi, surge)', 'plūrālis (puellæ, vobis, surgite)', 'Plusieurs jeunes filles.', 'numerus', 'v.imp.praes', 'Puella, tibi, surge singulāria sunt.'),
       D('Jeune fille, lève-toi, il te le dit.', 'dico', 'prīma persōna (dico)', 'tertia (dicit)', 'Un autre parlerait.', 'persona', 'v.ind.praes.act', 'Dico (-ō) prīma persōna est.')]),
    I('th-modus-imperativus', 'JOH 11:43', 'Lazare, veni foras.', 'Lazare, viens dehors!', paed=True,
      target=T('veni', 'venio', 'v.imp.praes', 'imperātīvus praesentis, secunda persōna singulāris'),
      dist=[D('Lazare, il vient dehors.', 'veni', 'imperātīvus (veni)', 'indicātīvus tertiae persōnae (venit)', 'L\'ordre devient un constat.', 'modus', 'v.imp.praes', 'Veni cum vocātīvō Lazare imperātīvus est; venit esset indicātīvus.'),
            D('Lazare, venez dehors!', 'veni', 'singulāris (veni)', 'plūrālis (venite)', 'Plusieurs appelés.', 'numerus', 'v.imp.praes', 'Veni singulāre est; venite esset plūrāle.'),
            D('Lazare, je suis venu dehors.', 'veni', 'imperātīvus (venī)', 'perfectum prīmae persōnae (vēnī)', 'Jésus raconterait sa propre sortie.', 'modus', 'v.imp.praes', 'Veni sine macrō imperātīvus (venī) aut perfectum (vēnī) est; vocātīvus Lazare imperātīvum postulat.')],
      note='Segond : « Lazare, sors! » ; le rendu pédagogique garde « veni foras ».'),
    I('th-modus-imperativus', 'MAT 14:27', 'Habete fiduciam: ego sum, nolite timere.', 'Ayez confiance: c\'est moi, ne craignez pas.', paed=True,
      target=T('Habete', 'habeo', 'v.imp.praes', 'imperātīvus praesentis, secunda persōna plūrālis'),
      dist=[D('Vous avez confiance: c\'est moi, ne craignez pas.', 'Habete', 'imperātīvus (habete)', 'indicātīvus (habetis)', 'L\'exhortation devient un constat.', 'modus', 'v.imp.praes', 'Habete imperātīvus plūrālis est (-te); habetis esset indicātīvus.'),
            D('Aie confiance: c\'est moi, ne crains pas.', 'Habete', 'plūrālis (habete, nolite)', 'singulāris (habe, noli)', 'Un seul disciple.', 'numerus', 'v.imp.praes', 'Habete et nolite plūrālia sunt.'),
            D('Ayez confiance: c\'est lui, ne craignez pas.', 'ego sum', 'prīma persōna (ego sum)', 'tertia (ille est)', 'Jésus désignerait un autre.', 'persona', 'v.fam.sum', 'Ego sum prīma persōna est.')],
      note='Segond : « Rassurez-vous, c\'est moi; n\'ayez pas peur! » ; rendu pédagogique littéral.'),
    I('th-modus-imperativus', 'LUK 10:37', 'Vade, et tu fac similiter.', 'Va, et toi, fais de même.',
      T('fac', 'facio', 'v.imp.praes', 'imperātīvus praesentis (fac), secunda persōna singulāris'),
      [D('Tu vas, et toi, fais de même.', 'Vade', 'imperātīvus (vade)', 'indicātīvus (vadis)', 'L\'envoi devient un constat.', 'modus', 'v.imp.praes', 'Vade imperātīvus est; vadis esset indicātīvus.'),
       D('Va, et toi, tu fais de même.', 'fac', 'imperātīvus (fac)', 'indicātīvus (facis)', 'L\'ordre d\'agir devient une description.', 'modus', 'v.imp.praes', 'Fac imperātīvus irregulāris est (ut dīc, dūc); facis esset indicātīvus.'),
       D('Allez, et vous, faites de même.', 'Vade', 'singulāris (vade, tu, fac)', 'plūrālis (vadite, vos, facite)', 'Plusieurs auditeurs.', 'numerus', 'v.imp.praes', 'Vade, tu, fac singulāria sunt.')]),
    I('th-modus-imperativus', 'EXO 3:5', 'solve calceamentum de pedibus tuis: locus enim, in quo stas, terra sancta est.', 'ôte ta chaussure de tes pieds, car le lieu où tu te tiens est une terre sainte.', paed=True,
      target=T('solve', 'solvo', 'v.imp.praes', 'imperātīvus praesentis, secunda persōna singulāris'),
      dist=[D('tu ôtes ta chaussure de tes pieds, car le lieu où tu te tiens est une terre sainte.', 'solve', 'imperātīvus (solve)', 'indicātīvus (solvis)', 'L\'ordre devient un constat.', 'modus', 'v.imp.praes', 'Solve imperātīvus est (thema + e); solvis esset indicātīvus.'),
            D('ôtez vos chaussures de vos pieds, car le lieu où vous vous tenez est une terre sainte.', 'solve', 'singulāris (solve, tuis, stas)', 'plūrālis (solvite, vestris, statis)', 'Plusieurs interlocuteurs.', 'numerus', 'v.imp.praes', 'Solve, tuis, stas singulāria sunt.'),
            D('ôte ta chaussure de tes pieds, car le lieu où je me tiens est une terre sainte.', 'stas', 'secunda persōna (stas)', 'prīma (sto)', 'Dieu parlerait de sa propre position.', 'persona', 'v.ind.praes.act', 'Stas (-s) secunda persōna est.')],
      note='Segond : « ôte tes souliers » (pluriel) pour calceamentum (singulier) ; rendu pédagogique.'),
    I('th-modus-imperativus', 'JOH 20:27', 'et noli esse incredulus, sed fidelis.', 'et ne sois pas incrédule, mais fidèle.', paed=True,
      target=T('noli esse', 'nolo', 'v.fam.volo', 'imperātīvus negātīvus (nōlī + īnfīnītīvus), secunda persōna singulāris'),
      dist=[D('et tu n\'es pas incrédule, mais fidèle.', 'noli esse', 'imperātīvus (noli: vetat)', 'indicātīvus (non es)', 'L\'exhortation devient un constat.', 'modus', 'v.fam.volo', 'Noli + īnfīnītīvus vetat; indicātīvus esset non es.'),
            D('et ne soyez pas incrédules, mais fidèles.', 'noli', 'singulāris (noli, incredulus)', 'plūrālis (nolite, increduli)', 'Plusieurs disciples.', 'numerus', 'v.fam.volo', 'Noli et incredulus singulāria sunt.'),
            D('et qu\'il ne soit pas incrédule, mais fidèle.', 'noli', 'secunda persōna (noli)', 'tertia (ne sit)', 'L\'exhortation viserait un tiers.', 'persona', 'v.fam.volo', 'Noli secundae persōnae imperātīvus est.')],
      note='Segond : « mais crois » ; le latin a l\'adjectif fidelis.'),
    I('th-modus-imperativus', 'PSA 50:12', 'Cor mundum crea in me, Deus, et spiritum rectum innova in visceribus meis.', 'O Dieu! Crée en moi un cœur pur, Renouvelle en moi un esprit bien disposé.',
      T('crea', 'creo', 'v.imp.praes', 'imperātīvus praesentis, secunda persōna singulāris'),
      [D('O Dieu! tu crées en moi un cœur pur, tu renouvelles en moi un esprit bien disposé.', 'crea', 'imperātīvus (crea, innova)', 'indicātīvus (creas, innovas)', 'La prière devient un constat.', 'modus', 'v.imp.praes', 'Crea et innova imperātīvī sunt (thema in -ā); creas, innovas essent indicātīvī.'),
       D('O Dieu! Crée en nous un cœur pur, renouvelle en nous un esprit bien disposé.', 'me', 'singulāris (me, meis)', 'plūrālis (nobis, nostris)', 'Une prière collective.', 'numerus', '', 'In me et meis singulāria sunt.'),
       D('O Dieu! Crée en moi un cœur pur, il renouvelle en moi un esprit bien disposé.', 'innova', 'imperātīvus (innova)', 'indicātīvus tertiae persōnae (innovat)', 'Le renouvellement serait constaté, non demandé.', 'modus', 'v.imp.praes', 'Innova imperātīvus est; innovat esset indicātīvus.')]),
    I('th-modus-imperativus', 'MAR 16:15', 'Euntes in mundum universum prædicate Evangelium omni creaturæ.', 'Allez par tout le monde, et prêchez la bonne nouvelle à toute la création.',
      T('prædicate', 'praedico', 'v.imp.praes', 'imperātīvus praesentis, secunda persōna plūrālis'),
      [D('Allant par tout le monde, vous prêchez la bonne nouvelle à toute la création.', 'prædicate', 'imperātīvus (prædicate)', 'indicātīvus (prædicatis)', 'La mission devient une description.', 'modus', 'v.imp.praes', 'Prædicate imperātīvus plūrālis est (-te); prædicatis esset indicātīvus.'),
       D('Va par tout le monde, et prêche la bonne nouvelle à toute la création.', 'prædicate', 'plūrālis (euntes, prædicate)', 'singulāris (iens, prædica)', 'Un seul envoyé.', 'numerus', 'v.imp.praes', 'Euntes et prædicate plūrālia sunt.'),
       D('Allez par tout le monde, et qu\'ils prêchent la bonne nouvelle à toute la création.', 'prædicate', 'secunda persōna (prædicate)', 'tertia (prædicent)', 'D\'autres prêcheraient.', 'persona', 'v.imp.praes', 'Prædicate secundae persōnae est.')]),
    I('th-modus-imperativus', 'PHI 4:4', 'Gaudete in Domino semper: iterum dico gaudete.', 'Réjouissez-vous toujours dans le Seigneur; je le répète, réjouissez-vous.',
      T('Gaudete', 'gaudeo', 'v.imp.praes', 'imperātīvus praesentis, secunda persōna plūrālis'),
      [D('Vous vous réjouissez toujours dans le Seigneur; je le répète, vous vous réjouissez.', 'Gaudete', 'imperātīvus (gaudete)', 'indicātīvus (gaudetis)', 'L\'exhortation devient un constat.', 'modus', 'v.imp.praes', 'Gaudete imperātīvus est (-te); gaudetis esset indicātīvus.'),
       D('Réjouis-toi toujours dans le Seigneur; je le répète, réjouis-toi.', 'Gaudete', 'plūrālis (gaudete)', 'singulāris (gaude)', 'Un seul destinataire.', 'numerus', 'v.imp.praes', 'Gaudete plūrāle est; gaude esset singulāre.'),
       D('Réjouissez-vous toujours dans le Seigneur; il le répète, réjouissez-vous.', 'dico', 'prīma persōna (dico)', 'tertia (dicit)', 'Un autre répéterait l\'exhortation.', 'persona', 'v.ind.praes.act', 'Dico (-ō) prīma persōna est.')]),
]

# ============================================================ th-vox
ITEMS += [
    I('th-vox', 'MAT 20:28', 'Sicut Filius hominis non venit ministrari, sed ministrare', 'C’est ainsi que le Fils de l’homme est venu, non pour être servi, mais pour servir',
      T('ministrari', 'ministro', 'v.inf', 'īnfīnītīvus praesentis passīvī'),
      [D('C\'est ainsi que le Fils de l\'homme est venu, non pour servir, mais pour être servi', 'ministrari', 'ministrari passīvum, ministrare āctīvum', 'vōcēs inversae', 'Le Fils viendrait pour être servi.', 'vox', 'v.inf', 'Ministrari (-rī) īnfīnītīvus passīvus est, ministrare (-re) āctīvus.'),
       D('C\'est ainsi que les Fils de l\'homme sont venus, non pour être servis, mais pour servir', 'Filius', 'singulāris (Filius, venit)', 'plūrālis (filii, venerunt)', 'Plusieurs fils.', 'numerus', 'd.2.nom.sg', 'Filius et venit singulāria sunt.'),
       D('C\'est ainsi que le Fils de l\'homme vient, non pour être servi, mais pour servir', 'venit', 'perfectum (vēnit)', 'praesēns (venit)', 'La venue devient présente.', 'tempus', 'v.ind.perf.act', 'Venit hīc perfectum est (vēnit), ut sēnsus sententiae postulat; praesēns esset venit brevī vōcālī.')]),
    I('th-vox', 'MAT 5:9', 'quoniam filii Dei vocabuntur', 'car ils seront appelés fils de Dieu',
      T('vocabuntur', 'voco', 'v.ind.fut.pass', 'indicātīvus futūrī passīvī, tertia persōna plūrālis'),
      [D('car ils appelleront les fils de Dieu', 'vocabuntur', 'passīvum (vocabuntur)', 'āctīvum (vocabunt)', 'Ils appelleraient au lieu d\'être appelés.', 'vox', 'v.ind.fut.pass', 'Dēsinentia -ntur passīvum ostendit; āctīvum esset vocabunt.'),
       D('car il sera appelé fils de Dieu', 'vocabuntur', 'plūrālis (vocabuntur)', 'singulāris (vocabitur)', 'Un seul appelé.', 'numerus', 'v.ind.fut.pass', 'Vocabuntur plūrāle est.'),
       D('car ils ont été appelés fils de Dieu', 'vocabuntur', 'futūrum (vocabuntur)', 'perfectum (vocati sunt)', 'La promesse devient passée.', 'tempus', 'v.ind.fut.pass', 'Signum -bu- futūrum ostendit.')]),
    I('th-vox', 'MAT 23:12', 'Qui autem se exaltaverit, humiliabitur: et qui se humiliaverit, exaltabitur.', 'Quiconque s’élèvera sera abaissé, et quiconque s’abaissera sera élevé.',
      T('humiliabitur', 'humilio', 'v.ind.fut.pass', 'indicātīvus futūrī passīvī, tertia persōna singulāris'),
      [D('Quiconque s\'élèvera abaissera, et quiconque s\'abaissera élèvera.', 'humiliabitur', 'passīvum (humiliabitur, exaltabitur)', 'āctīvum (humiliabit, exaltabit)', 'L\'orgueilleux abaisserait les autres au lieu d\'être abaissé.', 'vox', 'v.ind.fut.pass', 'Dēsinentia -tur passīvum ostendit; āctīvum esset -bit.'),
       D('Quiconque s\'est élevé a été abaissé, et quiconque s\'est abaissé a été élevé.', 'humiliabitur', 'futūrum', 'perfectum', 'La sentence devient un bilan.', 'tempus', 'v.ind.fut.pass', 'Humiliabitur futūrum est (-bi-).'),
       D('Ceux qui s\'élèveront seront abaissés, et ceux qui s\'abaisseront seront élevés.', 'exaltaverit', 'singulāris (qui exaltaverit, humiliabitur)', 'plūrālis (qui exaltaverint, humiliabuntur)', 'Une foule au lieu de chacun.', 'numerus', 'v.ind.futex.act', 'Exaltaverit et humiliabitur singulāria sunt.')]),
    I('th-vox', 'MAT 7:2', 'In quo enim judicio judicaveritis, judicabimini', 'Car on vous jugera du jugement dont vous jugez',
      T('judicabimini', 'iudico', 'v.ind.fut.pass', 'indicātīvus futūrī passīvī, secunda persōna plūrālis'),
      [D('Car vous jugerez du jugement dont vous jugez', 'judicabimini', 'passīvum (judicabimini)', 'āctīvum (judicabitis)', 'Les auditeurs jugeraient au lieu d\'être jugés.', 'vox', 'v.ind.fut.pass', 'Dēsinentia -mini passīvum secundae plūrālis ostendit; āctīvum esset -bitis.'),
       D('Car on te jugera du jugement dont tu juges', 'judicabimini', 'plūrālis (judicabimini, judicaveritis)', 'singulāris (judicaberis, judicaveris)', 'Un seul jugé.', 'numerus', 'v.ind.fut.pass', 'Judicabimini plūrāle est.'),
       D('Car on vous a jugés du jugement dont vous jugiez', 'judicabimini', 'futūrum (judicabimini)', 'perfectum (judicati estis)', 'Le jugement serait passé.', 'tempus', 'v.ind.fut.pass', 'Judicabimini futūrum est (-bi-).')]),
    I('th-vox', 'ISA 53:5', 'Ipse autem vulneratus est propter iniquitates nostras', 'Mais lui, il a été blessé à cause de nos iniquités.', paed=True,
      target=T('vulneratus est', 'vulnero', 'v.ind.perf.pass', 'indicātīvus perfectī passīvī, tertia persōna singulāris'),
      dist=[D('Mais lui, il a blessé à cause de nos iniquités.', 'vulneratus est', 'passīvum (vulneratus est)', 'āctīvum (vulneravit)', 'Il blesserait au lieu d\'être blessé.', 'vox', 'v.ind.perf.pass', 'Participium perfectī + est passīvum est; āctīvum esset vulneravit.'),
            D('Mais eux, ils ont été blessés à cause de nos iniquités.', 'Ipse', 'singulāris (ipse, vulneratus est)', 'plūrālis (ipsi, vulnerati sunt)', 'Plusieurs blessés.', 'numerus', 'v.ind.perf.pass', 'Ipse et vulneratus est singulāria sunt.'),
            D('Mais lui, il est blessé à cause de nos iniquités.', 'vulneratus est', 'perfectum (vulneratus est)', 'praesēns (vulneratur)', 'La blessure serait présente.', 'tempus', 'v.ind.perf.pass', 'Vulneratus est perfectum est; praesēns esset vulneratur.')],
      note='Segond : « il était blessé » ; le latin a un parfait passif.'),
    I('th-vox', 'GEN 2:23', 'hæc vocabitur Virago, quoniam de viro sumpta est.', 'On l’appellera femme, parce qu’elle a été prise de l’homme.',
      T('sumpta est', 'sumo', 'v.ind.perf.pass', 'indicātīvus perfectī passīvī, tertia persōna singulāris fēminīnī'),
      [D('On l\'appellera femme, parce qu\'elle a pris de l\'homme.', 'sumpta est', 'passīvum (sumpta est)', 'āctīvum (sumpsit)', 'Elle prendrait au lieu d\'être prise.', 'vox', 'v.ind.perf.pass', 'Sumpta est passīvum est (participium + est); āctīvum esset sumpsit.'),
       D('Celle-ci appellera « femme », parce qu\'elle a été prise de l\'homme.', 'vocabitur', 'passīvum (vocabitur)', 'āctīvum (vocabit)', 'Elle appellerait au lieu d\'être appelée.', 'vox', 'v.ind.fut.pass', 'Vocabitur (-tur) passīvum est; vocabit esset āctīvum.'),
       D('On l\'appellera femme, parce qu\'elle est prise de l\'homme.', 'sumpta est', 'perfectum (sumpta est)', 'praesēns (sumitur)', 'La prise serait présente.', 'tempus', 'v.ind.perf.pass', 'Sumpta est perfectum est; praesēns esset sumitur.')]),
    I('th-vox', 'LUK 1:32', 'hic erit magnus, et Filius Altissimi vocabitur', 'Il sera grand et sera appelé Fils du Très-Haut',
      T('vocabitur', 'voco', 'v.ind.fut.pass', 'indicātīvus futūrī passīvī, tertia persōna singulāris'),
      [D('Il sera grand et appellera le Fils du Très-Haut', 'vocabitur', 'passīvum (vocabitur)', 'āctīvum (vocabit)', 'Il appellerait au lieu d\'être appelé.', 'vox', 'v.ind.fut.pass', 'Vocabitur (-tur) passīvum est.'),
       D('Ils seront grands et seront appelés fils du Très-Haut', 'hic erit', 'singulāris (hic erit, vocabitur)', 'plūrālis (hi erunt, vocabuntur)', 'Plusieurs enfants.', 'numerus', 'v.fam.sum', 'Hic erit et vocabitur singulāria sunt.'),
       D('Il est grand et est appelé Fils du Très-Haut', 'erit', 'futūrum (erit, vocabitur)', 'praesēns (est, vocatur)', 'L\'annonce devient présente.', 'tempus', 'v.fam.sum', 'Erit et vocabitur futūra sunt.')]),
    I('th-vox', 'MAT 9:2', 'Confide fili, remittuntur tibi peccata tua.', 'Prends courage, mon enfant, tes péchés te sont pardonnés.',
      T('remittuntur', 'remitto', 'v.ind.praes.pass', 'indicātīvus praesentis passīvī, tertia persōna plūrālis'),
      [D('Prends courage, mon enfant, tes péchés te pardonnent.', 'remittuntur', 'passīvum (remittuntur)', 'āctīvum (remittunt)', 'Les péchés pardonneraient au lieu d\'être pardonnés.', 'vox', 'v.ind.praes.pass', 'Dēsinentia -ntur passīvum ostendit; āctīvum esset remittunt.'),
       D('Prends courage, mon enfant, ton péché t\'est pardonné.', 'peccata', 'plūrālis (peccata, remittuntur)', 'singulāris (peccatum, remittitur)', 'Un seul péché.', 'numerus', 'd.2.nom.pl', 'Peccata neutrum plūrāle est.'),
       D('Prends courage, mon enfant, tes péchés t\'ont été pardonnés.', 'remittuntur', 'praesēns (remittuntur)', 'perfectum (remissa sunt)', 'Le pardon serait passé.', 'tempus', 'v.ind.praes.pass', 'Remittuntur praesēns est; perfectum esset remissa sunt.')]),
    I('th-vox', 'LUK 11:9', 'Petite, et dabitur vobis; quærite, et invenietis; pulsate, et aperietur vobis.', 'Demandez, et l’on vous donnera; cherchez, et vous trouverez; frappez, et l’on vous ouvrira.',
      T('dabitur', 'do', 'v.fam.minora', 'indicātīvus futūrī passīvī, tertia persōna singulāris'),
      [D('Demandez, et vous donnerez; cherchez, et vous trouverez; frappez, et vous ouvrirez.', 'dabitur', 'passīvum (dabitur, aperietur)', 'āctīvum secundae persōnae (dabitis, aperietis)', 'Les auditeurs donneraient et ouvriraient eux-mêmes.', 'vox', 'v.ind.fut.pass', 'Dabitur et aperietur passīva sunt (-tur); vobis datīvus.'),
       D('Demandez, et l\'on vous a donné; cherchez, et vous avez trouvé; frappez, et l\'on vous a ouvert.', 'dabitur', 'futūrum (dabitur, invenietis, aperietur)', 'perfectum', 'La promesse devient un bilan.', 'tempus', 'v.ind.fut.pass', 'Dabitur, invenietis, aperietur futūra sunt.'),
       D('Demande, et l\'on te donnera; cherche, et tu trouveras; frappe, et l\'on t\'ouvrira.', 'Petite', 'plūrālis (petite, vobis, invenietis)', 'singulāris (pete, tibi, invenies)', 'Un seul auditeur.', 'numerus', 'v.imp.praes', 'Petite, vobis, invenietis plūrālia sunt.')]),
    I('th-vox', 'MAT 22:14', 'Multi enim sunt vocati, pauci vero electi.', 'Caril y a beaucoup d’appelés, mais peu d’élus.',
      T('vocati', 'voco', 'v.ind.perf.pass', 'indicātīvus perfectī passīvī (sunt vocati), tertia persōna plūrālis'),
      [D('Car beaucoup ont appelé, mais peu ont choisi.', 'vocati', 'passīvum (sunt vocati, electi)', 'āctīvum (vocaverunt, elegerunt)', 'Les hommes appelleraient et choisiraient eux-mêmes.', 'vox', 'v.ind.perf.pass', 'Sunt vocati participium perfectī passīvī + sunt est; āctīvum esset vocaverunt.'),
       D('Car il y a beaucoup d\'appelés, mais un seul élu.', 'pauci', 'plūrālis (pauci electi)', 'singulāris (unus electus)', 'Un seul élu.', 'numerus', 'd.2.nom.pl', 'Pauci plūrāle est.'),
       D('Car beaucoup seront appelés, mais peu élus.', 'sunt vocati', 'perfectum (sunt vocati)', 'futūrum (vocabuntur)', 'L\'appel serait à venir.', 'tempus', 'v.ind.perf.pass', 'Sunt vocati perfectum est; futūrum esset vocabuntur.')]),
    I('th-vox', 'MAT 28:6', 'venite, et videte locum ubi positus erat Dominus.', 'venez, et voyez le lieu où le Seigneur avait été déposé.', paed=True,
      target=T('positus erat', 'pono', 'v.ind.plusq.pass', 'indicātīvus plūsquamperfectī passīvī, tertia persōna singulāris'),
      dist=[D('venez, et voyez le lieu où le Seigneur avait déposé.', 'positus erat', 'passīvum (positus erat)', 'āctīvum (posuerat)', 'Le Seigneur déposerait au lieu d\'être déposé.', 'vox', 'v.ind.plusq.pass', 'Positus erat passīvum est (participium + erat); āctīvum esset posuerat.'),
            D('venez, et voyez les lieux où le Seigneur avait été déposé.', 'locum', 'singulāris (locum)', 'plūrālis (locos)', 'Plusieurs lieux.', 'numerus', 'd.2.acc.sg', 'Locum singulāre est.'),
            D('venez, et voyez le lieu où le Seigneur est déposé.', 'positus erat', 'plūsquamperfectum (positus erat)', 'praesēns (ponitur)', 'La déposition serait présente.', 'tempus', 'v.ind.plusq.pass', 'Positus erat plūsquamperfectum est; praesēns esset ponitur.')],
      note='Segond : « où il était couché » ; rendu pédagogique de « positus erat ».'),
    I('th-vox', 'ROM 12:21', 'Noli vinci a malo, sed vince in bono malum.', 'Ne te laisse pas vaincre par le mal, mais surmonte le mal par le bien.',
      T('vinci', 'vinco', 'v.inf', 'īnfīnītīvus praesentis passīvī'),
      [D('Ne vaincs pas le mal, mais surmonte le mal par le bien.', 'vinci', 'passīvum (vinci: ā malō)', 'āctīvum (vincere)', 'L\'interdiction porterait sur vaincre au lieu d\'être vaincu.', 'vox', 'v.inf', 'Vinci (-ī) īnfīnītīvus passīvus est; ā malō auctōrem dīcit.'),
       D('Ne vous laissez pas vaincre par le mal, mais surmontez le mal par le bien.', 'Noli', 'singulāris (noli, vince)', 'plūrālis (nolite, vincite)', 'Plusieurs destinataires.', 'numerus', 'v.fam.volo', 'Noli et vince singulāria sunt.'),
       D('Ne te laisse pas vaincre par le mal, mais surmonte les maux par le bien.', 'malum', 'singulāris (malum)', 'plūrālis (mala)', 'Plusieurs maux.', 'numerus', 'd.2.acc.sg', 'Malum singulāre est.')]),
]

# ============================================================ th-modus-subiunctivus
ITEMS += [
    I('th-modus-subiunctivus', 'GEN 1:3', 'Dixitque Deus: Fiat lux. Et facta est lux.', 'Dieu dit: Que la lumière soit! Et la lumière fut.',
      T('Fiat', 'fio', 'v.fam.fio', 'subiūnctīvus praesentis (iussīvus), tertia persōna singulāris'),
      [D('Dieu dit: La lumière se fait. Et la lumière fut.', 'Fiat', 'subiūnctīvus (fiat: iubet)', 'indicātīvus (fit)', 'L\'ordre créateur devient un constat.', 'modus', 'v.fam.fio', 'Fiat subiūnctīvus praesentis verbī fīō est (-a-); fit esset indicātīvus.'),
       D('Dieu dit: La lumière sera. Et la lumière fut.', 'Fiat', 'subiūnctīvus (fiat)', 'futūrum indicātīvī (fiet)', 'L\'ordre devient une prédiction.', 'modus', 'v.fam.fio', 'Fiat subiūnctīvus est; fiet esset futūrum indicātīvī.'),
       D('Dieu dit: Que les lumières soient! Et la lumière fut.', 'lux', 'singulāris (fiat lux)', 'plūrālis (fiant luces)', 'Plusieurs lumières.', 'numerus', 'd.3.nom.sg', 'Fiat lux singulāre est.')]),
    I('th-modus-subiunctivus', 'MAT 6:10', 'Adveniat regnum tuum; fiat voluntas tua, sicut in cælo et in terra.', 'que ton règne vienne; que ta volonté soit faite sur la terre comme au ciel.',
      T('Adveniat', 'advenio', 'v.subj.praes.act', 'subiūnctīvus praesentis (optātīvus), tertia persōna singulāris'),
      [D('Ton règne vient; que ta volonté soit faite sur la terre comme au ciel.', 'Adveniat', 'subiūnctīvus (adveniat: optat)', 'indicātīvus (advenit)', 'Le souhait devient un constat.', 'modus', 'v.subj.praes.act', 'Adveniat subiūnctīvus est (-ia-); advenit esset indicātīvus.'),
       D('que ton règne vienne; ta volonté est faite sur la terre comme au ciel.', 'fiat', 'subiūnctīvus (fiat)', 'indicātīvus (fit)', 'La demande devient une affirmation.', 'modus', 'v.fam.fio', 'Fiat subiūnctīvus est; fit esset indicātīvus.'),
       D('que tes règnes viennent; que ta volonté soit faite sur la terre comme au ciel.', 'regnum', 'singulāris (regnum tuum)', 'plūrālis (regna tua)', 'Plusieurs règnes.', 'numerus', 'd.2.nom.sg', 'Regnum tuum singulāre est.')]),
    I('th-modus-subiunctivus', 'MAT 26:39', 'Pater mi, si possibile est, transeat a me calix iste', 'Mon Père, s’il est possible, que cettecoupe s’éloigne de moi!',
      T('transeat', 'transeo', 'v.fam.eo', 'subiūnctīvus praesentis (optātīvus), tertia persōna singulāris'),
      [D('Mon Père, s\'il est possible, cette coupe s\'éloigne de moi!', 'transeat', 'subiūnctīvus (transeat: optat)', 'indicātīvus (transit)', 'La prière devient un constat.', 'modus', 'v.fam.eo', 'Transeat subiūnctīvus verbī eō est (-ea-); transit esset indicātīvus.'),
       D('Mon Père, s\'il est possible, que cette coupe s\'éloigne de nous!', 'me', 'singulāris (me)', 'plūrālis (nobis)', 'Plusieurs suppliants.', 'numerus', '', 'A me singulāre est.'),
       D('Mon Père, s\'il était possible, que cette coupe s\'éloigne de moi!', 'est', 'praesēns (est)', 'imperfectum (esset)', 'La condition devient irréelle.', 'tempus', 'v.fam.sum', 'Est praesēns indicātīvī est; esset imperfectum subiūnctīvī.')]),
    I('th-modus-subiunctivus', 'LUK 1:38', 'fiat mihi secundum verbum tuum', 'qu’il me soit fait selon ta parole',
      T('fiat', 'fio', 'v.fam.fio', 'subiūnctīvus praesentis (optātīvus), tertia persōna singulāris'),
      [D('il m\'est fait selon ta parole', 'fiat', 'subiūnctīvus (fiat: optat)', 'indicātīvus (fit)', 'L\'acceptation devient un constat.', 'modus', 'v.fam.fio', 'Fiat subiūnctīvus est; fit esset indicātīvus.'),
       D('qu\'il nous soit fait selon ta parole', 'mihi', 'singulāris (mihi)', 'plūrālis (nobis)', 'Plusieurs personnes.', 'numerus', '', 'Mihi singulāre est.'),
       D('il me sera fait selon ta parole', 'fiat', 'subiūnctīvus (fiat)', 'futūrum indicātīvī (fiet)', 'Le consentement devient une prédiction.', 'modus', 'v.fam.fio', 'Fiat subiūnctīvus est; fiet esset futūrum.')]),
    I('th-modus-subiunctivus', 'JOH 17:21', 'ut omnes unum sint, sicut tu Pater in me, et ego in te', 'afin que tous soient un, comme toi, Père, tu es en moi, et comme je suis en toi',
      T('sint', 'sum', 'v.fam.sum', 'subiūnctīvus praesentis (fīnālis: ut … sint), tertia persōna plūrālis'),
      [D('tous sont un, comme toi, Père, tu es en moi, et comme je suis en toi', 'ut omnes unum sint', 'subiūnctīvus fīnālis (ut sint: fīnis)', 'indicātīvus (sunt: affirmat)', 'Le but de la prière devient une affirmation.', 'modus', 'v.fam.sum', 'Ut + sint subiūnctīvus fīnem dīcit; sunt esset indicātīvus.'),
       D('afin que tous soient un, comme toi, Père, tu es en moi, et comme il est en toi', 'ego', 'prīma persōna (ego)', 'tertia (ille)', 'Un tiers serait dans le Père.', 'persona', '', 'Ego prīma persōna est.'),
       D('afin que tous soient un, comme toi, Père, tu étais en moi, et comme je suis en toi', 'sicut tu Pater in me', 'praesēns (ellipsis: tu es)', 'imperfectum (eras)', 'L\'union du Père et du Fils devient passée.', 'tempus', 'v.fam.sum', 'Verbum omissum praesēns est (es), ut in secundō membrō.')]),
    I('th-modus-subiunctivus', 'MAT 5:16', 'Sic luceat lux vestra coram hominibus: ut videant opera vestra bona', 'Que votre lumière luise ainsi devant les hommes, afin qu’ils voient vos bonnes œuvres',
      T('luceat', 'luceo', 'v.subj.praes.act', 'subiūnctīvus praesentis (iussīvus), tertia persōna singulāris'),
      [D('Votre lumière luit ainsi devant les hommes, afin qu\'ils voient vos bonnes œuvres', 'luceat', 'subiūnctīvus (luceat: iubet)', 'indicātīvus (lucet)', 'L\'exhortation devient un constat.', 'modus', 'v.subj.praes.act', 'Luceat subiūnctīvus est (-ea-); lucet esset indicātīvus.'),
       D('Que votre lumière luise ainsi devant les hommes, et ils voient vos bonnes œuvres', 'ut videant', 'subiūnctīvus fīnālis (ut videant)', 'indicātīvus (vident)', 'Le but devient une simple conséquence constatée.', 'modus', 'v.subj.praes.act', 'Ut + videant fīnem dīcit; vident esset indicātīvus.'),
       D('Que ta lumière luise ainsi devant les hommes, afin qu\'ils voient tes bonnes œuvres', 'vestra', 'plūrālis (vestra)', 'singulāris (tua)', 'Un seul disciple.', 'numerus', '', 'Vestra plūrāle est.')]),
    I('th-modus-subiunctivus', 'GEN 1:26', 'Faciamus hominem ad imaginem et similitudinem nostram', 'Faisons l’homme à notre image, selon notre ressemblance',
      T('Faciamus', 'facio', 'v.subj.praes.act', 'subiūnctīvus praesentis (hortātīvus), prīma persōna plūrālis'),
      [D('Nous faisons l\'homme à notre image, selon notre ressemblance', 'Faciamus', 'subiūnctīvus hortātīvus (faciamus)', 'indicātīvus (facimus)', 'La résolution devient une description.', 'modus', 'v.subj.praes.act', 'Faciamus subiūnctīvus est (-ia-); facimus esset indicātīvus.'),
       D('Faisons les hommes à notre image, selon notre ressemblance', 'hominem', 'singulāris (hominem)', 'plūrālis (homines)', 'Plusieurs hommes.', 'numerus', 'd.3.acc.sg', 'Hominem singulāre est.'),
       D('Nous ferons l\'homme à notre image, selon notre ressemblance', 'Faciamus', 'subiūnctīvus (faciamus)', 'futūrum indicātīvī (faciemus)', 'La résolution devient une prédiction.', 'modus', 'v.subj.praes.act', 'Faciamus subiūnctīvus est; faciemus esset futūrum.')]),
    I('th-modus-subiunctivus', '1JO 4:7', 'Carissimi, diligamus nos invicem: quia caritas ex Deo est.', 'Bien-aimés, aimons nous les uns les autres; car l’amour est de Dieu',
      T('diligamus', 'diligo', 'v.subj.praes.act', 'subiūnctīvus praesentis (hortātīvus), prīma persōna plūrālis'),
      [D('Bien-aimés, nous nous aimons les uns les autres; car l\'amour est de Dieu', 'diligamus', 'subiūnctīvus hortātīvus (diligamus)', 'indicātīvus (diligimus)', 'L\'exhortation devient un constat.', 'modus', 'v.subj.praes.act', 'Diligamus subiūnctīvus est (-a-); diligimus esset indicātīvus.'),
       D('Bien-aimé, aimons-nous les uns les autres; car l\'amour est de Dieu', 'Carissimi', 'plūrālis (carissimi)', 'singulāris (carissime)', 'Un seul destinataire.', 'numerus', 'd.2.voc.pl', 'Carissimi vocātīvus plūrālis est.'),
       D('Bien-aimés, aimons-nous les uns les autres; car l\'amour était de Dieu', 'est', 'praesēns (est)', 'imperfectum (erat)', 'L\'origine de l\'amour devient passée.', 'tempus', 'v.fam.sum', 'Est praesēns est.')]),
    I('th-modus-subiunctivus', 'LUK 2:15', 'Transeamus usque Bethlehem, et videamus hoc verbum, quod factum est', 'Allons jusqu’à Bethléhem, et voyons ce qui est arrivé',
      T('Transeamus', 'transeo', 'v.fam.eo', 'subiūnctīvus praesentis (hortātīvus), prīma persōna plūrālis'),
      [D('Nous allons jusqu\'à Bethléhem, et nous voyons ce qui est arrivé', 'Transeamus', 'subiūnctīvus hortātīvus (transeamus, videamus)', 'indicātīvus (transimus, videmus)', 'La décision devient un récit.', 'modus', 'v.fam.eo', 'Transeamus et videamus subiūnctīvī sunt (-ea-); indicātīvī essent transimus, videmus.'),
       D('Allons jusqu\'à Bethléhem, et voyons ce qui arrive', 'factum est', 'perfectum (factum est)', 'praesēns (fit)', 'L\'événement serait en cours.', 'tempus', 'v.ind.perf.pass', 'Factum est perfectum est.'),
       D('Allons jusqu\'à Bethléhem, et voyons ces choses qui sont arrivées', 'hoc verbum', 'singulāris (hoc verbum)', 'plūrālis (hæc verba)', 'Plusieurs événements.', 'numerus', 'd.2.acc.sg', 'Hoc verbum singulāre est.')]),
    I('th-modus-subiunctivus', 'MAT 16:24', 'Si quis vult post me venire, abneget semetipsum, et tollat crucem suam, et sequatur me.', 'Si quelqu’un veut venir après moi, qu’il renonce à lui-même, qu’il se charge de sa croix, et qu’il me suive.',
      T('sequatur', 'sequor', 'v.dep', 'subiūnctīvus praesentis (iussīvus, dēpōnēns), tertia persōna singulāris'),
      [D('Si quelqu\'un veut venir après moi, il renonce à lui-même, il se charge de sa croix, et il me suit.', 'abneget', 'subiūnctīvus iussīvus (abneget, tollat, sequatur)', 'indicātīvus (abnegat, tollit, sequitur)', 'Les conditions du disciple deviennent des constats.', 'modus', 'v.subj.praes.act', 'Abneget, tollat, sequatur subiūnctīvī sunt (-e-, -a-); indicātīvī essent abnegat, tollit, sequitur.'),
       D('Si quelqu\'un voulait venir après moi, qu\'il renonce à lui-même, qu\'il se charge de sa croix, et qu\'il me suive.', 'vult', 'praesēns (vult)', 'imperfectum (volebat)', 'La condition devient passée.', 'tempus', 'v.fam.volo', 'Vult praesēns est.'),
       D('Si quelqu\'un veut venir après moi, qu\'il renonce à lui-même, qu\'il se charge de ses croix, et qu\'il me suive.', 'crucem', 'singulāris (crucem suam)', 'plūrālis (cruces suas)', 'Plusieurs croix.', 'numerus', 'd.3.acc.sg', 'Crucem singulāre est.')]),
    I('th-modus-subiunctivus', 'JOH 14:1', 'Non turbetur cor vestrum.', 'Que votre cœur ne se trouble point.',
      T('turbetur', 'turbo', 'v.subj.praes.pass', 'subiūnctīvus praesentis passīvī (prohibitīvus), tertia persōna singulāris'),
      [D('Votre cœur ne se trouble point.', 'turbetur', 'subiūnctīvus (non turbetur: vetat)', 'indicātīvus (non turbatur)', 'L\'exhortation devient un constat.', 'modus', 'v.subj.praes.pass', 'Turbetur subiūnctīvus est (-e-); turbatur esset indicātīvus.'),
       D('Que vos cœurs ne se troublent point.', 'cor', 'singulāris (cor vestrum)', 'plūrālis (corda vestra)', 'Plusieurs cœurs.', 'numerus', 'd.3.nom.sg', 'Cor singulāre est; corda plūrāle.'),
       D('Votre cœur ne se troublera point.', 'turbetur', 'subiūnctīvus (turbetur)', 'futūrum indicātīvī (turbabitur)', 'L\'exhortation devient une prédiction.', 'modus', 'v.subj.praes.pass', 'Turbetur subiūnctīvus est; turbabitur esset futūrum.')]),
    I('th-modus-subiunctivus', 'PSA 117:24', 'Hæc est dies quam fecit Dominus; exsultemus, et lætemur in ea.', 'Voici le jour que le Seigneur a fait: exultons et réjouissons-nous en lui.', paed=True,
      target=T('exsultemus', 'exsulto', 'v.subj.praes.act', 'subiūnctīvus praesentis (hortātīvus), prīma persōna plūrālis'),
      dist=[D('Voici le jour que le Seigneur a fait: nous exultons et nous nous réjouissons en lui.', 'exsultemus', 'subiūnctīvus hortātīvus (exsultemus, lætemur)', 'indicātīvus (exsultamus, lætamur)', 'L\'appel à la joie devient un constat.', 'modus', 'v.subj.praes.act', 'Exsultemus (-e-) et lætemur subiūnctīvī sunt; indicātīvī essent exsultamus, lætamur.'),
            D('Voici le jour que le Seigneur fait: exultons et réjouissons-nous en lui.', 'fecit', 'perfectum (fecit)', 'praesēns (facit)', 'La création du jour serait en cours.', 'tempus', 'v.ind.perf.act', 'Fecit perfectum est (thema fēc-).'),
            D('Voici les jours que le Seigneur a faits: exultons et réjouissons-nous en eux.', 'dies', 'singulāris (hæc dies)', 'plūrālis (hi dies)', 'Plusieurs jours.', 'numerus', 'd.5.nom.sg', 'Hæc dies singulāre est.')],
      note='Segond paraphrase l\'exhortation (« Qu\'elle soit pour nous un sujet d\'allégresse ») ; rendu pédagogique.'),
]

# ============================================================ th-congruentia
ITEMS += [
    I('th-congruentia', 'JOH 1:14', 'Et Verbum caro factum est', 'Et la parole a été faite chair',
      T('factum', 'facio', 'v.part', 'participium perfectī, neutrum singulāre (cum Verbum congruit)'),
      [D('Et la chair a été faite Parole', 'factum', 'factum neutrum: cum Verbum (n.) congruit', 'cum caro (f.) congruēns (facta)', 'La chair deviendrait Parole au lieu de la Parole devenant chair.', 'congruentia', 'v.part', 'Factum neutrum est: subiectum Verbum (neutrum); sī caro subiectum esset, facta legerētur.'),
       D('Et les paroles ont été faites chair', 'Verbum', 'singulāris (Verbum, factum est)', 'plūrālis (verba, facta sunt)', 'Plusieurs paroles.', 'numerus', 'd.2.nom.sg', 'Verbum et factum est singulāria sunt.'),
       D('Et la Parole et la chair ont été faites', 'caro', 'caro praedicātum (nōminātīvus)', 'caro subiectum coordinātum', 'La chair deviendrait un second sujet au lieu du résultat.', 'casus', 'd.3.nom.sg', 'Caro nōminātīvus praedicātī est: Verbum factum est caro.')]),
    I('th-congruentia', 'JOH 10:11', 'Bonus pastor animam suam dat pro ovibus suis.', 'Le bon berger donne sa vie pour ses brebis.',
      T('Bonus', 'bonus', 'd.2.nom.sg', 'adiectīvum nōminātīvum masculīnum (cum pastor congruit)'),
      [D('Le berger donne sa bonne vie pour ses brebis.', 'Bonus', 'bonus cum pastor (m. nōm.) congruit', 'cum animam (f. acc.) congruēns (bonam)', 'La bonté qualifierait la vie au lieu du berger.', 'congruentia', 'd.2.nom.sg', 'Bonus masculīnum nōminātīvum est, ut pastor; animam requīreret bonam.'),
       D('Le berger donne sa vie pour ses bonnes brebis.', 'Bonus', 'bonus cum pastor congruit', 'cum ovibus (f. abl. pl.) congruēns (bonis)', 'La bonté qualifierait les brebis.', 'congruentia', 'd.2.nom.sg', 'Ovibus requīreret bonis; bonus singulāre masculīnum est.'),
       D('Le bon berger donne sa vie pour sa brebis.', 'ovibus', 'plūrālis (ovibus suis)', 'singulāris (ove sua)', 'Une seule brebis.', 'numerus', 'd.3.abl.pl', 'Ovibus plūrāle est.')]),
    I('th-congruentia', 'GEN 1:31', 'Viditque Deus cuncta quæ fecerat, et erant valde bona.', 'Dieu vit tout ce qu’il avait fait et voici, cela était très bon.',
      T('bona', 'bonus', 'd.2.nom.pl', 'adiectīvum neutrum plūrāle (cum cuncta congruit)'),
      [D('Dieu, très bon, vit tout ce qu\'il avait fait.', 'bona', 'bona cum cuncta (n. pl.) congruit', 'cum Deus (m. sg.) congruēns (bonus)', 'La bonté qualifierait Dieu au lieu de la création.', 'congruentia', 'd.2.nom.pl', 'Bona neutrum plūrāle est, ut cuncta; Deus requīreret bonus.'),
       D('Dieu vit toute chose qu\'il avait faite, et elle était très bonne.', 'cuncta', 'plūrālis (cuncta, erant)', 'singulāris (cunctum, erat)', 'Une seule chose.', 'numerus', '', 'Cuncta et erant plūrālia sunt.'),
       D('Dieu vit tout ce qui l\'avait fait, et cela était très bon.', 'quæ', 'quæ accūsātīvus (obiectum verbī fecerat)', 'nōminātīvus (subiectum)', 'La création aurait fait Dieu.', 'casus', '', 'Quæ neutrum nōminātīvus aut accūsātīvus est; fecerat subiectum Deus habet, ergō quæ obiectum.')]),
    I('th-congruentia', 'JOH 15:1', 'Ego sum vitis vera, et Pater meus agricola est.', 'Je suis le vrai cep, et mon Père est le vigneron.',
      T('vera', 'verus', 'd.1.nom.sg', 'adiectīvum fēminīnum nōminātīvum (cum vitis congruit)'),
      [D('Je suis le cep, et mon vrai Père est le vigneron.', 'vera', 'vera cum vitis (f.) congruit', 'cum Pater (m.) congruēns (verus)', 'La vérité qualifierait le Père au lieu du cep.', 'congruentia', 'd.1.nom.sg', 'Vera fēminīnum est, ut vitis; Pater requīreret verus.'),
       D('Je suis le cep, et mon Père est le vrai vigneron.', 'vera', 'vera cum vitis congruit', 'cum agricola congruēns (verus)', 'La vérité qualifierait le vigneron.', 'congruentia', 'd.1.nom.sg', 'Agricola masculīnum est: requīreret verus, nōn vera.'),
       D('Nous sommes les vrais ceps, et notre Père est le vigneron.', 'Ego sum', 'singulāris (ego sum, vitis)', 'plūrālis (nos sumus, vites)', 'Plusieurs ceps.', 'numerus', 'v.fam.sum', 'Ego sum vitis singulāre est.')]),
    I('th-congruentia', 'MAT 26:41', 'Spiritus quidem promptus est, caro autem infirma.', 'l’esprit est bien disposé, mais la chair est faible.',
      T('promptus', 'promptus', 'd.2.nom.sg', 'adiectīvum masculīnum (cum spiritus congruit)'),
      [D('l\'esprit est faible, mais la chair est bien disposée.', 'promptus', 'promptus (m.) cum spiritus, infirma (f.) cum caro', 'adiectīva inversa', 'Les qualités de l\'esprit et de la chair sont échangées.', 'congruentia', 'd.2.nom.sg', 'Promptus masculīnum est ut spiritus; infirma fēminīnum ut caro.'),
       D('les esprits sont bien disposés, mais la chair est faible.', 'Spiritus', 'singulāris (spiritus, est)', 'plūrālis (spiritus, sunt)', 'Plusieurs esprits.', 'numerus', 'd.4.nom.sg', 'Est singulāre est; spiritus hīc singulāris.'),
       D('l\'esprit est bien disposé, mais les chairs sont faibles.', 'caro', 'singulāris (caro infirma)', 'plūrālis (carnes infirmæ)', 'Plusieurs chairs.', 'numerus', 'd.3.nom.sg', 'Caro singulāre est.')]),
    I('th-congruentia', 'REV 21:5', 'Ecce nova facio omnia.', 'Voici, je fais toutes choses nouvelles.',
      T('nova', 'novus', 'd.2.acc.pl', 'adiectīvum neutrum plūrāle accūsātīvum (cum omnia congruit)'),
      [D('Voici, moi, nouvelle, je fais toutes choses.', 'nova', 'nova cum omnia (n. pl. acc.) congruit', 'fēminīnum singulāre nōminātīvum (nova: ego)', 'La nouveauté qualifierait celui qui parle.', 'congruentia', 'd.2.acc.pl', 'Nova neutrum plūrāle est ut omnia; fēminīnum singulāre eādem fōrmā, sed subiectum est masculīnum.'),
       D('Voici, je fais toute chose nouvelle.', 'omnia', 'plūrālis (omnia nova)', 'singulāris (omne novum)', 'Une seule chose.', 'numerus', '', 'Omnia neutrum plūrāle est.'),
       D('Voici, toutes les choses nouvelles agissent.', 'omnia', 'accūsātīvus (nova omnia: obiectum)', 'nōminātīvus (subiectum)', 'Les choses agiraient au lieu d\'être faites.', 'casus', '', 'Facio (-ō) prīma persōna est: ego faciō; omnia ergō obiectum.')]),
    I('th-congruentia', 'ROM 12:2', 'ut probetis quæ sit voluntas Dei bona, et beneplacens, et perfecta.', 'afin que vous discerniez quelle est la volonté de Dieu, ce qui est bon, agréable et parfait.',
      T('bona', 'bonus', 'd.1.nom.sg', 'adiectīvum fēminīnum nōminātīvum (cum voluntas congruit)'),
      [D('afin que vous discerniez quelle est la volonté du Dieu bon, agréable et parfait.', 'bona', 'bona cum voluntas (f. nōm.) congruit', 'cum Dei (m. gen.) congruēns (boni)', 'La bonté qualifierait Dieu au lieu de sa volonté.', 'congruentia', 'd.1.nom.sg', 'Bona, beneplacens, perfecta nōminātīvī fēminīnī sunt ut voluntas; Dei requīreret boni.'),
       D('afin que vous discerniez quelles sont les volontés de Dieu, bonnes, agréables et parfaites.', 'voluntas', 'singulāris (voluntas, sit)', 'plūrālis (voluntates, sint)', 'Plusieurs volontés.', 'numerus', 'd.3.nom.sg', 'Voluntas et sit singulāria sunt.'),
       D('afin que vous discerniez quelle est la volonté des dieux, bonne, agréable et parfaite.', 'Dei', 'genetīvus singulāris (Dei)', 'plūrālis (deorum)', 'Plusieurs dieux.', 'numerus', 'd.2.gen.sg', 'Dei genetīvus singulāris est.')]),
    I('th-congruentia', 'MAT 25:34', 'Venite benedicti Patris mei, possidete paratum vobis regnum', 'Venez, vous qui êtes bénis de mon Père; prenez possession du royaumequi vous a été préparé',
      T('paratum', 'paro', 'v.part', 'participium perfectī neutrum accūsātīvum (cum regnum congruit)'),
      [D('Venez, vous qui êtes bénis de mon Père; prenez possession, tout préparés, du royaume', 'paratum', 'paratum cum regnum (n.) congruit', 'cum vos congruēns (parati)', 'Ce sont les élus qui seraient préparés, non le royaume.', 'congruentia', 'v.part', 'Paratum neutrum singulāre est ut regnum; vos requīreret parati.'),
       D('Venez, vous qui êtes bénis de mon Père; prenez possession du royaume préparé par vous', 'vobis', 'datīvus (vobis: quibus parātum)', 'ablātīvus auctōris', 'Les élus auraient préparé le royaume.', 'casus', '', 'Vobis datīvus est: iīs quibus parātum est.'),
       D('Viens, toi qui es béni de mon Père; prends possession du royaume qui t\'a été préparé', 'benedicti', 'plūrālis (venite, benedicti, vobis)', 'singulāris', 'Un seul élu.', 'numerus', 'd.2.voc.pl', 'Venite, benedicti, vobis plūrālia sunt.')]),
    I('th-congruentia', 'LUK 1:42', 'Benedicta tu inter mulieres, et benedictus fructus ventris tui.', 'Tu es bénie entre les femmes, et le fruit de ton sein est béni.',
      T('benedictus', 'benedico', 'v.part', 'participium perfectī masculīnum (cum fructus congruit)'),
      [D('Tu es bénie entre les femmes bénies, et le fruit de ton sein.', 'benedictus', 'benedictus (m.) cum fructus congruit', 'cum mulieres (f. pl.) congruēns (benedictæ)', 'La bénédiction passerait aux femmes au lieu du fruit.', 'congruentia', 'v.part', 'Benedictus masculīnum singulāre est ut fructus; mulieres requīreret benedictæ.'),
       D('Tu es bénie entre les femmes, et les fruits de ton sein sont bénis.', 'fructus', 'singulāris (fructus, benedictus)', 'plūrālis (fructus, benedicti)', 'Plusieurs fruits.', 'numerus', 'd.4.nom.sg', 'Benedictus singulāre est, ergō fructus quoque.'),
       D('Tu es bénie entre les femmes, et le fruit de tes seins est béni.', 'ventris', 'genetīvus singulāris (ventris)', 'plūrālis (ventrium)', 'Plusieurs seins.', 'numerus', 'd.3.gen.sg', 'Ventris genetīvus singulāris est (-is).')]),
    I('th-congruentia', 'LUK 2:10', 'gaudium magnum, quod erit omni populo', 'une grande joie qui sera pour tout le peuple', paed=True,
      target=T('magnum', 'magnus', 'd.2.acc.sg', 'adiectīvum neutrum (cum gaudium congruit)'),
      dist=[D('une joie qui sera pour tout le grand peuple', 'magnum', 'magnum cum gaudium (n.) congruit', 'cum populo (m. dat.) congruēns (magno)', 'La grandeur qualifierait le peuple au lieu de la joie.', 'congruentia', 'd.2.acc.sg', 'Magnum neutrum est ut gaudium; populo requīreret magno.'),
            D('une grande joie qui sera pour tous les peuples', 'omni populo', 'singulāris (omni populo)', 'plūrālis (omnibus populis)', 'Plusieurs peuples.', 'numerus', 'd.2.dat.sg', 'Omni populo singulāre est.'),
            D('une grande joie qui sera par tout le peuple', 'populo', 'datīvus (populo: cui)', 'ablātīvus (per populum)', 'Le peuple deviendrait la source de la joie.', 'casus', 'd.2.dat.sg', 'Populo datīvus aut ablātīvus est; erit alicui datīvum postulat.')],
      note='Segond restructure ; rendu pédagogique du groupe « gaudium magnum quod erit omni populo ».'),
    I('th-congruentia', 'GEN 2:7', 'et factus est homo in animam viventem.', 'et l’homme devint un être vivant.',
      T('viventem', 'vivo', 'v.part', 'participium praesentis accūsātīvum fēminīnum (cum animam congruit)'),
      [D('et l\'homme vivant devint une âme.', 'viventem', 'viventem cum animam (acc.) congruit', 'cum homo (nōm.) congruēns (vivens)', 'C\'est l\'homme qui serait qualifié de vivant, non l\'âme.', 'congruentia', 'v.part', 'Viventem accūsātīvus est ut animam; homo requīreret vivens.'),
       D('et les hommes devinrent des êtres vivants.', 'homo', 'singulāris (homo, factus est)', 'plūrālis (homines, facti sunt)', 'Plusieurs hommes.', 'numerus', 'd.3.nom.sg', 'Homo et factus est singulāria sunt.'),
       D('et l\'homme fut fait dans une âme vivante.', 'in animam', 'in + accūsātīvus (mōtus: in animam)', 'in + ablātīvus (locus: in anima)', 'L\'homme serait placé dans une âme au lieu de devenir une âme.', 'casus', 'd.1.acc.sg', 'Animam accūsātīvus est: in + accūsātīvum mōtum aut mūtātiōnem dīcit; ablātīvus esset anima.')]),
    I('th-congruentia', 'LUK 1:47', 'et exsultavit spiritus meus in Deo salutari meo.', 'et mon esprit a exulté en Dieu mon Sauveur.', paed=True,
      target=T('salutari', 'salutaris', 'd.3.abl.sg', 'adiectīvum ablātīvum (cum Deo congruit)'),
      dist=[D('et mon esprit salutaire a exulté en Dieu.', 'salutari', 'salutari (abl.) cum Deo congruit', 'cum spiritus (nōm.) congruēns (salutaris)', 'La qualité de sauveur passerait à l\'esprit.', 'congruentia', 'd.3.abl.sg', 'Salutari ablātīvus est ut Deo; spiritus requīreret salutaris.'),
            D('et mon esprit a exulté dans les dieux mon salut.', 'Deo', 'singulāris (Deo)', 'plūrālis (diis)', 'Plusieurs dieux.', 'numerus', 'd.2.abl.sg', 'Deo singulāre est.'),
            D('et mon esprit a exulté en Dieu par mon salut.', 'salutari meo', 'ablātīvus congruēns cum Deo (Deus salutāris)', 'ablātīvus īnstrūmentī sēparātus (per salūtem meam)', 'Le salut deviendrait un moyen distinct de Dieu.', 'casus', 'd.3.abl.sg', 'Salutari meo cum Deo congruit: Deus quī salūtāris est.')],
      note='Segond a le présent (« se réjouit ») ; le latin a exsultavit, parfait.'),
]

# ============================================================ th-nonfinita
ITEMS += [
    I('th-nonfinita', 'MAT 5:1', 'Videns autem Jesus turbas, ascendit in montem', 'Voyant la foule, Jésus monta sur la montagne',
      T('Videns', 'video', 'v.part', 'participium praesentis āctīvī, nōminātīvus (cum Jesus congruit)'),
      [D('La foule voyant Jésus, il monta sur la montagne', 'Videns', 'videns cum Jesus (nōm.) congruit, turbas obiectum', 'cum turbas congruēns (videntes)', 'Ce serait la foule qui voit Jésus.', 'congruentia', 'v.part', 'Videns nōminātīvus singulāris est ut Jesus; turbas accūsātīvus obiectum est.'),
       D('Voyant la foule, Jésus montera sur la montagne', 'ascendit', 'perfectum (ascendit)', 'futūrum (ascendet)', 'La montée est annoncée.', 'tempus', 'v.ind.perf.act', 'Ascendit hīc perfectum est (nārrātiō); ascendet esset futūrum.'),
       D('Voyant la foule, Jésus monte sur la montagne', 'ascendit', 'perfectum (ascendit)', 'praesēns (ascendit)', 'Le récit passe au présent.', 'tempus', 'v.ind.perf.act', 'Ascendit perfectum et praesēns eādem fōrmā sunt; nārrātiō perfectum postulat (accesserunt).')]),
    I('th-nonfinita', 'ACT 20:35', 'Beatius est magis dare, quam accipere.', 'Il y a plus de bonheur à donner qu’à recevoir.',
      T('dare', 'do', 'v.inf', 'īnfīnītīvus praesentis āctīvī'),
      [D('Il y a plus de bonheur à être donné qu\'à recevoir.', 'dare', 'āctīvum (dare)', 'passīvum (dari)', 'Être donné remplacerait donner.', 'vox', 'v.inf', 'Dare (-re) īnfīnītīvus āctīvus est; dari esset passīvus.'),
       D('Il y a plus de bonheur à donner qu\'à être reçu.', 'accipere', 'āctīvum (accipere)', 'passīvum (accipi)', 'Être reçu remplacerait recevoir.', 'vox', 'v.inf', 'Accipere (-re) āctīvus est; accipi esset passīvus.'),
       D('Il y a plus de bonheur à donner qu\'à avoir reçu.', 'accipere', 'īnfīnītīvus praesentis (accipere)', 'īnfīnītīvus perfectī (accepisse)', 'Le fait d\'avoir reçu remplacerait le fait de recevoir.', 'nonfinita', 'v.inf', 'Accipere praesēns est; accepisse esset perfectum (-isse).')]),
    I('th-nonfinita', '1TI 2:4', 'qui omnes homines vult salvos fieri', 'qui veut que tous les hommes soient sauvés',
      T('fieri', 'fio', 'v.fam.fio', 'īnfīnītīvus praesentis (fīō: passīvum verbī faciō)'),
      [D('qui veut que tous les hommes sauvent', 'salvos fieri', 'salvos fieri: passīvum (fierī = fierī salvōs)', 'āctīvum (salvos facere)', 'Les hommes sauveraient au lieu d\'être sauvés.', 'vox', 'v.fam.fio', 'Fieri īnfīnītīvus passīvus verbī faciō est; āctīvum esset facere.'),
       D('qui veut que tous les hommes aient été sauvés', 'fieri', 'īnfīnītīvus praesentis (fieri)', 'īnfīnītīvus perfectī (factos esse)', 'Le salut serait déjà accompli.', 'nonfinita', 'v.fam.fio', 'Fieri praesēns est; perfectum esset factos esse.'),
       D('qui veut que tout homme soit sauvé', 'omnes homines', 'plūrālis (omnes homines)', 'singulāris (omnem hominem)', 'Un seul homme.', 'numerus', 'd.3.acc.pl', 'Omnes homines plūrāle est.')]),
    I('th-nonfinita', 'MAT 8:16', 'Vespere autem facto, obtulerunt ei multos dæmonia habentes', 'Le soir venu, on lui amena beaucoup de possédés.', paed=True,
      target=T('Vespere autem facto', 'vesper', 'v.part', 'ablātīvus absolūtus (participium perfectī)'),
      dist=[D('Ayant fait le soir, ils lui amenèrent beaucoup de possédés.', 'facto', 'ablātīvus absolūtus (vespere facto: circumstantia)', 'participium cum subiectō congruēns', 'Les gens auraient fait le soir.', 'nonfinita', 'v.part', 'Vespere facto ablātīvus absolūtus est: tempus dīcit, nōn āctiōnem subiectī.'),
            D('Le soir venu, on lui amena beaucoup de gens tenus par des démons.', 'habentes', 'participium praesentis āctīvī (habentes: quī habent)', 'passīvum (habiti)', 'Les possédés seraient tenus au lieu d\'avoir des démons.', 'vox', 'v.part', 'Habentes (-ntes) participium āctīvum est.'),
            D('Le soir venu, on lui amena un possédé.', 'multos', 'plūrālis (multos … habentes)', 'singulāris (unum … habentem)', 'Un seul possédé.', 'numerus', 'd.2.acc.pl', 'Multos plūrāle est.')],
      note='Segond : « Le soir, on amena … plusieurs démoniaques » ; rendu pédagogique de l\'ablatif absolu.'),
    I('th-nonfinita', 'MAT 14:25', 'venit ad eos ambulans super mare.', 'Jésus alla vers eux, marchant sur la mer.',
      T('ambulans', 'ambulo', 'v.part', 'participium praesentis āctīvī, nōminātīvus (cum subiectō Jesus congruit)'),
      [D('Jésus alla vers eux qui marchaient sur la mer.', 'ambulans', 'ambulans nōminātīvus (cum Jesus)', 'accūsātīvus plūrālis (cum eos: ambulantes)', 'Ce seraient les disciples qui marchent sur la mer.', 'congruentia', 'v.part', 'Ambulans nōminātīvus singulāris est; eos requīreret ambulantes.'),
       D('Jésus alla vers eux, ayant marché sur la mer.', 'ambulans', 'participium praesentis (ambulans: simul)', 'participium perfectī (ante)', 'La marche serait achevée avant la venue.', 'nonfinita', 'v.part', 'Participium praesentis āctiōnem simul factam dīcit (-ns).'),
       D('Jésus va vers eux, marchant sur la mer.', 'venit', 'perfectum (vēnit)', 'praesēns (venit)', 'Le récit passe au présent.', 'tempus', 'v.ind.perf.act', 'Venit hīc perfectum est (nārrātiō).')]),
    I('th-nonfinita', 'LUK 9:62', 'Nemo mittens manum suam ad aratrum, et respiciens retro, aptus est regno Dei.', 'Quiconque met la main à la charrue, et regarde en arrière, n’est pas propre au royaume de Dieu.',
      T('mittens', 'mitto', 'v.part', 'participium praesentis āctīvī (mittens, respiciens: quī mittit)'),
      [D('Nul, envoyé à la charrue et regardé en arrière, n\'est propre au royaume de Dieu.', 'mittens', 'participium praesentis āctīvī (mittens)', 'participium perfectī passīvī (missus)', 'L\'homme serait envoyé au lieu de mettre la main.', 'vox', 'v.part', 'Mittens (-ns) āctīvum est; missus esset passīvum.'),
       D('Nul, qui mettra la main à la charrue et regardera en arrière, ne sera propre au royaume de Dieu.', 'aptus est', 'praesēns (aptus est)', 'futūrum (aptus erit)', 'La sentence devient future.', 'tempus', 'v.fam.sum', 'Aptus est praesēns est; erit esset futūrum.'),
       D('Nul, mettant les mains à la charrue et regardant en arrière, n\'est propre au royaume de Dieu.', 'manum', 'singulāris (manum suam)', 'plūrālis (manus suas)', 'Les deux mains.', 'numerus', 'd.4.acc.sg', 'Manum singulāre est.')]),
    I('th-nonfinita', 'REV 1:8', 'qui est, et qui erat, et qui venturus est', 'celui qui est, et qui était, et qui va venir', paed=True,
      target=T('venturus est', 'venio', 'v.periph.act', 'coniugātiō periphrastica āctīva (participium futūrī + est)'),
      dist=[D('celui qui est, et qui était, et qui est venu', 'venturus est', 'participium futūrī (venturus: quī veniet)', 'perfectum (venit)', 'La venue serait passée.', 'nonfinita', 'v.periph.act', 'Venturus (-ūrus) participium futūrī est: rem ventūram dīcit.'),
            D('ceux qui sont, et qui étaient, et qui vont venir', 'qui est', 'singulāris (qui est, erat, venturus est)', 'plūrālis', 'Plusieurs personnes.', 'numerus', 'v.fam.sum', 'Est, erat, venturus est singulāria sunt.'),
            D('celui qui est, et qui sera, et qui va venir', 'erat', 'imperfectum (erat)', 'futūrum (erit)', 'Le passé devient futur.', 'tempus', 'v.fam.sum', 'Erat imperfectum est.')],
      note='Segond : « qui vient » ; rendu pédagogique du participe futur.'),
    I('th-nonfinita', 'JOB 19:25', 'et in novissimo die de terra surrecturus sum', 'et au dernier jour je me lèverai de la terre', paed=True,
      target=T('surrecturus sum', 'surgo', 'v.periph.act', 'coniugātiō periphrastica āctīva (participium futūrī + sum), prīma persōna'),
      dist=[D('et au dernier jour je me suis levé de la terre', 'surrecturus sum', 'participium futūrī (surrecturus: quī surgam)', 'perfectum (surrexi)', 'Le relèvement serait passé.', 'nonfinita', 'v.periph.act', 'Surrecturus (-ūrus) participium futūrī est; surrexi esset perfectum.'),
            D('et au dernier jour il se lèvera de la terre', 'sum', 'prīma persōna (surrecturus sum)', 'tertia (surrecturus est)', 'Un autre se lèverait.', 'persona', 'v.fam.sum', 'Sum prīma persōna est.'),
            D('et aux derniers jours je me lèverai de la terre', 'novissimo die', 'singulāris (novissimo die)', 'plūrālis (novissimis diebus)', 'Plusieurs jours.', 'numerus', 'd.5.abl.sg', 'Novissimo die singulāre est.')],
      note='Segond suit un autre texte (« il se lèvera le dernier ») ; rendu pédagogique.'),
    I('th-nonfinita', 'MAT 2:2', 'vidimus enim stellam ejus in oriente, et venimus adorare eum.', 'Car nous avons vu son étoile en Orient, et nous sommes venus pour l’adorer.',
      T('adorare', 'adoro', 'v.inf', 'īnfīnītīvus praesentis āctīvī (fīnis)'),
      [D('Car nous avons vu son étoile en Orient, et nous sommes venus pour être adorés par lui.', 'adorare', 'āctīvum (adorare eum)', 'passīvum (adorari)', 'Les mages viendraient se faire adorer.', 'vox', 'v.inf', 'Adorare (-re) āctīvus est; adorari esset passīvus.'),
       D('Car nous avons vu son étoile en Orient, et nous sommes venus pour l\'avoir adoré.', 'adorare', 'īnfīnītīvus praesentis (adorare)', 'īnfīnītīvus perfectī (adoravisse)', 'L\'adoration serait déjà accomplie.', 'nonfinita', 'v.inf', 'Adorare praesēns est; adoravisse esset perfectum.'),
       D('Car nous voyons son étoile en Orient, et nous venons pour l\'adorer.', 'vidimus', 'perfectum (vidimus, venimus)', 'praesēns (videmus, venimus)', 'Le récit passe au présent.', 'tempus', 'v.ind.perf.act', 'Vidimus perfectum est (thema vīd-); venimus hīc perfectum (vēnimus).')]),
    I('th-nonfinita', 'MAT 5:17', 'non veni solvere, sed adimplere.', 'je suis venu non pour abolir, mais pour accomplir.',
      T('adimplere', 'adimpleo', 'v.inf', 'īnfīnītīvus praesentis āctīvī (fīnis)'),
      [D('je suis venu non pour être aboli, mais pour être accompli.', 'solvere', 'āctīvum (solvere, adimplere)', 'passīvum (solvi, adimpleri)', 'Le Christ serait aboli ou accompli au lieu d\'agir.', 'vox', 'v.inf', 'Solvere et adimplere (-re) āctīvī sunt; passīvī essent solvi, adimpleri.'),
       D('je viens non pour abolir, mais pour accomplir.', 'veni', 'perfectum (vēnī)', 'praesēns (venio)', 'La venue devient présente.', 'tempus', 'v.ind.perf.act', 'Veni (vēnī) perfectum prīmae persōnae est.'),
       D('je suis venu non pour avoir aboli, mais pour accomplir.', 'solvere', 'īnfīnītīvus praesentis (solvere)', 'īnfīnītīvus perfectī (solvisse)', 'L\'abolition serait déjà faite.', 'nonfinita', 'v.inf', 'Solvere praesēns est; solvisse esset perfectum.')]),
    I('th-nonfinita', 'HEB 11:1', 'Est autem fides sperandarum substantia rerum', 'Or la foi est une ferme assurance des choses qu’on espère',
      T('sperandarum', 'spero', 'v.ger', 'gerundīvum genetīvum plūrāle (rērum sperandārum: quae spērantur)'),
      [D('Or la foi est une ferme assurance des choses qui espèrent', 'sperandarum', 'gerundīvum passīvum (sperandarum: quae spērantur)', 'participium praesentis āctīvum (sperantium)', 'Les choses espéreraient au lieu d\'être espérées.', 'nonfinita', 'v.ger', 'Gerundīvum (-nd-) sēnsum passīvum habet; āctīvum esset sperantium.'),
       D('Or la foi est une ferme assurance de la chose qu\'on espère', 'rerum', 'plūrālis (sperandarum rerum)', 'singulāris (sperandæ rei)', 'Une seule chose.', 'numerus', 'd.5.gen.pl', 'Rerum genetīvus plūrālis est (-rum).'),
       D('Or la foi était une ferme assurance des choses qu\'on espère', 'Est', 'praesēns (est)', 'imperfectum (erat)', 'La définition devient passée.', 'tempus', 'v.fam.sum', 'Est praesēns est.')]),
    I('th-nonfinita', 'LUK 23:34', 'Dividentes vero vestimenta ejus, miserunt sortes.', 'Ils se partagèrent ses vêtements, en tirant au sort.',
      T('Dividentes', 'divido', 'v.part', 'participium praesentis āctīvī, nōminātīvus plūrālis'),
      [D('Ses vêtements partagés, ils tirèrent au sort.', 'Dividentes', 'participium praesentis āctīvī (dividentes: quī dīvidunt)', 'participium perfectī passīvī (divisa)', 'Le partage deviendrait subi et achevé.', 'vox', 'v.part', 'Dividentes (-ntes) āctīvum praesēns est; divisa esset passīvum perfectum.'),
       D('Ayant partagé ses vêtements, ils tirèrent au sort.', 'Dividentes', 'participium praesentis (simul)', 'participium perfectī (ante)', 'Le partage serait terminé avant le tirage au sort.', 'nonfinita', 'v.part', 'Participium praesentis āctiōnem simul factam dīcit.'),
       D('Ils se partagèrent son vêtement, en tirant au sort.', 'vestimenta', 'plūrālis (vestimenta)', 'singulāris (vestimentum)', 'Un seul vêtement.', 'numerus', 'd.2.acc.pl', 'Vestimenta neutrum plūrāle est.')]),
]


# ============================================================ lexicon (token key -> lemma)
def _lex(spec: str) -> dict[str, str]:
    out = {}
    for line in spec.strip().splitlines():
        lemma, forms = line.split(':', 1)
        for f in forms.split():
            out[f] = lemma.strip()
    return out


LEX: dict[str, str] = _lex("""
a: a ab
abnego: abneget
abstergeo: absterget
accipio: accipere
ad: ad
adiicio: adiicientur
adimpleo: adimplere
adoro: adorare
advenio: adveniat
aedifico: aedificabo
Aegyptus: aegypti
aeternus: aeternae aeternum
agricola: agricola
altissimus: altissimi altissimis
ambulo: ambulans ambulat
amo: amo
ancilla: ancilla ancillae
angelus: angelis
anima: anima animam
annuntio: annuntiat
aperio: aperietur
aptus: aptus
apud: apud
aratrum: aratrum
ardeo: ardens
ascendo: ascendit
audio: audiunt audivi
autem: autem
ave: ave
Babylon: babylonis
beatus: beati beatius
benedico: benedicam benedicta benedicti benedictus
beneplacens: beneplacens
Bethlehem: bethlehem
bonus: bona bonae bono bonum bonus
caecus: caecus
caelum: caeli caelo caelum
calceamentum: calceamentum
calix: calix
carus: carissimi
caritas: caritas
caro: caro
cado: cecidit
certamen: certamen
certo: certavi
clamo: clamavi
cognosco: cognoscetis cognosco cognovistis
commendo: commendo
complaceo: complacui
concipio: concipies
confido: confide confidite
consolor: consolabuntur
constituo: constituam
consummo: consummatum consummavi
cooperor: cooperantur
cor: cor corde
coram: coram
creo: crea creavit
creatura: creaturae
crux: crucem
cum: cum
cunctus: cuncta
cursus: cursum
custodio: custodiant
do: dabitur dare daret dat data
daemonium: daemonia
de: de
debitum: debita
debitor: debitoribus
deus: dei deo deum deus
depono: deposuit
derelinquo: dereliquisti
dico: dicam dico dixi dixit dixitque
dies: die dies
dignus: dignus
dilectus: dilectus
diligo: dilexi dilexit diligamus diligatis diligebat diligentibus
dimitto: dimitte dimittimus
divido: dividentes
dominus: domine domini domino dominum dominus
dum: dum
is: ea eas ei eius eorum eos eum
ecce: ecce
ecclesia: ecclesiam
educo: eduxi
ego: ego me mecum mei mihi
eligo: electi
enarro: enarrant
enim: enim
sum: erant erat eris erit esse essem est estis sum sunt fuisti sint sit
ergo: ergo
et: et
eo: euntes ibo
evangelium: evangelium
evangelizo: evangelizo
ex: ex
exalto: exaltabitur exaltaverit exaltavit
exsicco: exsiccatum
exsulto: exsultavit exsultemus
facio: fac faciamque faciamus faciet facio facta facto factum factus fecerat feci fecistis fecit
femina: feminam
fio: fiat fieri
fidelis: fidelis
fides: fidem fides
fiducia: fiduciam
filius: fili filii filios filium filius
firmamentum: firmamentum
fleo: flevimus
flos: flos
flumen: flumina
foenum: foenum
foras: foras
frater: fratribus
fructus: fructus
gaudeo: gaudete
gaudium: gaudium
gens: gentem gentes
gloria: gloria gloriam
gratia: gratia gratiam
habeo: habebit habebitis habentes habes habete
hic: haec hanc hic his hoc
hodie: hodie
homo: hominem homines hominibus hominis homo
humilis: humiles humilibus
humilio: humiliabitur humiliaverit
humilitas: humilitatem
Jesus: iesum iesus
ille: illic
imago: imaginem
in: in
incredulus: incredulus
infirmus: infirma
iniquitas: iniquitates
innovo: innova
inter: inter
intro: intres
intueor: intuetur
invenio: invenietis inventus
invicem: invicem
Joseph: ioseph
ipse: ipse ipsi
Israel: israel
iste: iste
iterum: iterum
iudico: iudicabimini iudicare iudicaveritis iudicemini
iudicium: iudicio
laboro: laboratis
lacrima: lacrimam
lacrimor: lacrimatus
laetor: laetemur
laudo: laudate
Lazarus: lazare
libero: liberabit
locus: locum locus
loquor: loqueretur
luceo: luceat
lugeo: lugent
lumen: lumen
lupus: luporum
lux: lux
magis: magis
magnus: magnam magnum magnus
magnifico: magnificabo magnificat
malum: malo malum
mando: mandavit
maneo: manet
manus: manum manus manuum
mare: mare
masculus: masculum
meus: mea meae meam meis meo meum meus mi
medium: medio
minimus: minimis
ministro: ministrare ministrari
mitto: miserunt mitte mittens mitto
modo: modo
mons: montem
mors: mors
morior: mortuus
mulier: mulieres
multus: multa multi multos
mundus: mundi mundo mundum
nemo: nemo
nos: nobis nos
nolo: noli nolite
nomen: nomen
non: non
nonne: nonne
nosco: nosti
noster: nostra nostram nostras nostri nostris nostrum
novus: nova
novissimus: novissimo
offero: obtulerunt
occido: occides
oculus: oculis
omnis: omnem omnes omni omnia omnibus omnis
onero: onerati
opus: opera
oriens: oriente
ovis: oves ovibus
pacificus: pacifici
palmes: palmites
paradisus: paradiso
paro: parare paratum
pario: paries
pastor: pastor
pater: pater patrem patris
paucus: pauca pauci
pax: pax
peccatum: peccata peccatis
pecco: peccavi
pes: pedibus
perfectus: perfecta
pereo: perierat
peto: petite
petra: petram
plenus: plena
populus: populi populo populum populus
pono: positus
possibilis: possibile
possideo: possidete
post: post
potens: potentes
potestas: potestas
praeceptum: praeceptum
praedico: praedicate
praetereo: praeteribunt
pressura: pressuram
principium: principio
prior: prior
pro: pro
probo: probetis
profundum: profundis
promptus: promptus
propter: propter
puella: puella
pulso: pulsate
qui: quae qui quo quod
quaero: quaerite
quam: quam
quamdiu: quamdiu
quia: quia
quis: quid quis
quidem: quidem
quoniam: quoniam
rectus: rectum
reficio: reficiam
regnum: regno regnum
remitto: remittuntur
res: rerum
resisto: resistit
respicio: respexit respiciens
retro: retro
revivo: revixit
salutaris: salutari
salvus: salvos salvum
sanctus: sancta
scio: scio scis
sui: se semetipsum
secundum: secundum
sed: sed
sedes: sede
sedeo: sedimus
semper: semper
sequor: sequatur sequitur
servo: servavi
si: si
sic: sic
sicut: sicut
similiter: similiter
similitudo: similitudinem
solus: soli
solvo: solve solvere
sors: sortes
spero: sperandarum
spiritus: spiritum spiritus
sto: stas
stella: stellam
suus: suae suam suis suos suum
sub: sub
substantia: substantia
sumo: sumpta
super: super
superbus: superbis
surgo: surgam surge surrecturus surrexit
tantus: tanto
tu: te tecum tibi tu
tectum: tectum
tempus: tempore
tenebrae: tenebris
terra: terra
timeo: timere timui
tollo: tollat
transeo: transeamus transeat transibunt
tuus: tua tuam tuas tui tuis tuum tuus
turba: turbas
turbo: turbetur
ubi: ubi
ultra: ultra
unus: uni unum
unigenitus: unigenitum
universus: universum
usque: usque
ut: ut
uterus: utero
vado: vade vado
valde: valde
venio: veni venimus venire venit venite venturus
venter: ventris
verus: vera
verbum: verba verbum
veritas: veritas veritatem
vero: vero
vesper: vespere
vestimentum: vestimenta
vester: vestra vestrum
via: via viis
vinco: vici vince vinci
video: videamus videant videbunt videns video videte vidimus viditque
vir: viro
Virago: virago
viscera: visceribus
vita: vitae
vitis: vitis
vivo: viventem
vos: vobis vobiscum vos
voco: vocabis vocabitur vocabuntur vocati
vox: vocem
voluntas: voluntas voluntatis
volo: vult
vulnero: vulneratus
""")

GLOSS: dict[str, str] = {
    'a': 'de, par, loin de (prép. + abl.)', 'abnego': 'renier, renoncer à', 'abstergeo': 'essuyer', 'accipio': 'recevoir', 'ad': 'vers, à (prép. + acc.)',
    'adiicio': 'ajouter, donner par surcroît', 'adimpleo': 'accomplir, remplir', 'adoro': 'adorer', 'advenio': 'venir, arriver', 'aedifico': 'bâtir',
    'Aegyptus': 'Égypte', 'aeternus': 'éternel', 'agricola': 'cultivateur, vigneron', 'altissimus': 'très haut, le Très-Haut', 'ambulo': 'marcher',
    'amo': 'aimer', 'ancilla': 'servante', 'angelus': 'ange, messager', 'anima': 'âme, souffle, vie', 'annuntio': 'annoncer, manifester',
    'aperio': 'ouvrir', 'aptus': 'propre à, apte', 'apud': 'auprès de (prép. + acc.)', 'aratrum': 'charrue', 'ardeo': 'brûler', 'ascendo': 'monter',
    'audio': 'entendre, écouter', 'autem': 'mais, or, quant à', 'ave': 'salut ! (salutation)', 'Babylon': 'Babylone', 'beatus': 'heureux, bienheureux',
    'benedico': 'bénir', 'beneplacens': 'agréable, qui plaît', 'Bethlehem': 'Bethléem', 'bonus': 'bon', 'caecus': 'aveugle', 'caelum': 'ciel',
    'calceamentum': 'chaussure', 'calix': 'coupe', 'carus': 'cher, bien-aimé', 'caritas': 'amour, charité', 'caro': 'chair', 'cado': 'tomber',
    'certamen': 'combat', 'certo': 'combattre', 'clamo': 'crier', 'cognosco': 'connaître', 'commendo': 'confier, remettre', 'complaceo': 'se complaire, trouver son plaisir',
    'concipio': 'concevoir', 'confido': 'avoir confiance', 'consolor': 'consoler', 'constituo': 'établir, préposer', 'consummo': 'accomplir, achever',
    'cooperor': 'coopérer, concourir', 'cor': 'cœur', 'coram': 'devant, en présence de (prép. + abl.)', 'creo': 'créer', 'creatura': 'créature, création',
    'crux': 'croix', 'cum': 'avec (prép. + abl.) ; lorsque (conj.)', 'cunctus': 'tout, tout entier', 'cursus': 'course', 'custodio': 'garder',
    'do': 'donner', 'daemonium': 'démon', 'de': 'de, au sujet de (prép. + abl.)', 'debitum': 'dette', 'debitor': 'débiteur', 'deus': 'Dieu, dieu',
    'depono': 'déposer, renverser', 'derelinquo': 'abandonner', 'dico': 'dire', 'dies': 'jour', 'dignus': 'digne', 'dilectus': 'bien-aimé',
    'diligo': 'aimer', 'dimitto': 'remettre, pardonner, laisser aller', 'divido': 'partager', 'dominus': 'seigneur, maître', 'dum': 'pendant que',
    'is': 'il, elle, lui ; ce, cet', 'ecce': 'voici', 'ecclesia': 'assemblée, Église', 'educo': 'faire sortir', 'ego': 'je, moi', 'eligo': 'choisir, élire',
    'enarro': 'raconter', 'enim': 'car, en effet', 'sum': 'être', 'ergo': 'donc', 'et': 'et, aussi', 'eo': 'aller', 'evangelium': 'évangile, bonne nouvelle',
    'evangelizo': 'annoncer une bonne nouvelle', 'ex': 'de, hors de (prép. + abl.)', 'exalto': 'élever', 'exsicco': 'dessécher', 'exsulto': 'exulter',
    'facio': 'faire', 'femina': 'femme', 'fio': 'devenir, être fait, se faire', 'fidelis': 'fidèle', 'fides': 'foi', 'fiducia': 'confiance', 'filius': 'fils',
    'firmamentum': 'firmament, étendue', 'fleo': 'pleurer', 'flos': 'fleur', 'flumen': 'fleuve', 'foenum': 'herbe, foin', 'foras': 'dehors', 'frater': 'frère',
    'fructus': 'fruit', 'gaudeo': 'se réjouir', 'gaudium': 'joie', 'gens': 'nation, peuple', 'gloria': 'gloire', 'gratia': 'grâce', 'habeo': 'avoir, tenir',
    'hic': 'ce, celui-ci', 'hodie': 'aujourd\'hui', 'homo': 'homme, être humain', 'humilis': 'humble', 'humilio': 'abaisser, humilier', 'humilitas': 'bassesse, humilité',
    'Jesus': 'Jésus', 'ille': 'celui-là ; là (illic)', 'imago': 'image', 'in': 'dans, en (+ abl.) ; vers, contre (+ acc.)', 'incredulus': 'incrédule', 'infirmus': 'faible',
    'iniquitas': 'iniquité', 'innovo': 'renouveler', 'inter': 'entre, parmi (prép. + acc.)', 'intro': 'entrer', 'intueor': 'regarder, considérer', 'invenio': 'trouver',
    'invicem': 'les uns les autres, mutuellement', 'Joseph': 'Joseph', 'ipse': 'lui-même, même', 'Israel': 'Israël', 'iste': 'ce, celui-là', 'iterum': 'de nouveau',
    'iudico': 'juger', 'iudicium': 'jugement', 'laboro': 'peiner, travailler', 'lacrima': 'larme', 'lacrimor': 'pleurer', 'laetor': 'se réjouir', 'laudo': 'louer',
    'Lazarus': 'Lazare', 'libero': 'libérer, affranchir', 'locus': 'lieu', 'loquor': 'parler', 'luceo': 'luire, briller', 'lugeo': 'pleurer, être dans le deuil',
    'lumen': 'lumière', 'lupus': 'loup', 'lux': 'lumière', 'magis': 'plus, davantage', 'magnus': 'grand', 'magnifico': 'glorifier, exalter, rendre grand',
    'malum': 'mal', 'mando': 'ordonner, confier', 'maneo': 'demeurer, rester', 'manus': 'main', 'mare': 'mer', 'masculus': 'homme, mâle', 'meus': 'mon, mien',
    'medium': 'milieu', 'minimus': 'le plus petit', 'ministro': 'servir', 'mitto': 'envoyer ; jeter (sortes)', 'modo': 'maintenant, seulement', 'mons': 'montagne',
    'mors': 'mort', 'morior': 'mourir', 'mulier': 'femme', 'multus': 'nombreux, beaucoup', 'mundus': 'monde', 'nemo': 'personne, nul', 'nos': 'nous',
    'nolo': 'ne pas vouloir ; ne … pas (défense)', 'nomen': 'nom', 'non': 'ne … pas', 'nonne': 'est-ce que … ne … pas ?', 'nosco': 'connaître, savoir',
    'noster': 'notre', 'novus': 'nouveau', 'novissimus': 'dernier', 'offero': 'présenter, amener', 'occido': 'tuer', 'oculus': 'œil', 'omnis': 'tout, chaque',
    'onero': 'charger', 'opus': 'œuvre, ouvrage', 'oriens': 'orient, levant', 'ovis': 'brebis', 'pacificus': 'pacifique, qui procure la paix', 'palmes': 'sarment',
    'paradisus': 'jardin, paradis', 'paro': 'préparer', 'pario': 'enfanter', 'pastor': 'berger', 'pater': 'père', 'paucus': 'peu nombreux, peu', 'pax': 'paix',
    'peccatum': 'péché', 'pecco': 'pécher', 'pes': 'pied', 'perfectus': 'parfait', 'pereo': 'périr, être perdu', 'peto': 'demander', 'petra': 'pierre, roc',
    'plenus': 'plein', 'populus': 'peuple', 'pono': 'poser, déposer', 'possibilis': 'possible', 'possideo': 'posséder, prendre possession', 'post': 'après, derrière (prép. + acc.)',
    'potens': 'puissant', 'potestas': 'pouvoir', 'praeceptum': 'commandement', 'praedico': 'prêcher, proclamer', 'praetereo': 'passer', 'pressura': 'tribulation, oppression',
    'principium': 'commencement', 'prior': 'le premier (de deux)', 'pro': 'pour, en faveur de (prép. + abl.)', 'probo': 'éprouver, discerner', 'profundum': 'profondeur, abîme',
    'promptus': 'prompt, bien disposé', 'propter': 'à cause de (prép. + acc.)', 'puella': 'jeune fille', 'pulso': 'frapper', 'qui': 'qui, que, lequel', 'quaero': 'chercher',
    'quam': 'que (comparaison) ; combien', 'quamdiu': 'toutes les fois que, aussi longtemps que', 'quia': 'parce que, que', 'quis': 'qui ? quoi ? quelqu\'un', 'quidem': 'certes',
    'quoniam': 'parce que, car', 'rectus': 'droit', 'reficio': 'refaire, donner du repos', 'regnum': 'règne, royaume', 'remitto': 'remettre, pardonner', 'res': 'chose',
    'resisto': 'résister', 'respicio': 'regarder, jeter les yeux sur', 'retro': 'en arrière', 'revivo': 'revivre', 'salutaris': 'salutaire ; Sauveur', 'salvus': 'sauf, sauvé',
    'sanctus': 'saint', 'scio': 'savoir', 'sui': 'se, soi', 'secundum': 'selon (prép. + acc.)', 'sed': 'mais', 'sedes': 'siège, trône', 'sedeo': 's\'asseoir, être assis',
    'semper': 'toujours', 'sequor': 'suivre', 'servo': 'garder', 'si': 'si', 'sic': 'ainsi', 'sicut': 'comme', 'similiter': 'de même', 'similitudo': 'ressemblance',
    'solus': 'seul', 'solvo': 'délier, ôter, abolir', 'sors': 'sort', 'spero': 'espérer', 'spiritus': 'esprit, souffle', 'sto': 'se tenir debout', 'stella': 'étoile',
    'suus': 'son, sa, leur (réfléchi)', 'sub': 'sous (prép.)', 'substantia': 'substance, assurance', 'sumo': 'prendre', 'super': 'sur, au-dessus de', 'superbus': 'orgueilleux',
    'surgo': 'se lever', 'tantus': 'si grand ; tanto tempore : depuis si longtemps', 'tu': 'tu, toi', 'tectum': 'toit', 'tempus': 'temps', 'tenebrae': 'ténèbres', 'terra': 'terre',
    'timeo': 'craindre', 'tollo': 'prendre, porter, enlever', 'transeo': 'passer, s\'éloigner', 'tuus': 'ton, tien', 'turba': 'foule', 'turbo': 'troubler', 'ubi': 'où',
    'ultra': 'plus loin, désormais', 'unus': 'un, un seul', 'unigenitus': 'unique, fils unique', 'universus': 'tout entier', 'usque': 'jusque', 'ut': 'afin que, que ; comme',
    'uterus': 'sein, ventre', 'vado': 'aller', 'valde': 'très', 'venio': 'venir', 'venter': 'ventre, sein', 'verus': 'vrai', 'verbum': 'parole, mot', 'veritas': 'vérité',
    'vero': 'mais, en vérité', 'vesper': 'soir', 'vestimentum': 'vêtement', 'vester': 'votre', 'via': 'voie, chemin', 'vinco': 'vaincre', 'video': 'voir', 'vir': 'homme, mari',
    'Virago': 'Virago (nom donné à la femme, tiré de vir)', 'viscera': 'entrailles', 'vita': 'vie', 'vitis': 'vigne, cep', 'vivo': 'vivre', 'vos': 'vous', 'voco': 'appeler',
    'vox': 'voix', 'voluntas': 'volonté', 'volo': 'vouloir', 'vulnero': 'blesser', 'praedicate': 'prêcher',
}
