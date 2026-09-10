"""Authored occupational vocabulary introduced with the subordinate-clause unit.

Principal noun forms determine inflection; no gender or case is guessed from a
French gloss. This pool replaces, rather than multiplies, the elementary pool.
"""
PEOPLE = [
    ('medicus', 'medicus', 'medicī', '2', 'le médecin'),
    ('mercator', 'mercātor', 'mercātōris', '3', 'le marchand'),
    ('faber', 'faber', 'fabrī', '2', 'l’artisan'),
    ('sutor', 'sūtor', 'sūtōris', '3', 'le cordonnier'),
    ('pistor', 'pistor', 'pistōris', '3', 'le boulanger'),
    ('cocus', 'cocus', 'cocī', '2', 'le cuisinier'),
    ('pastor', 'pāstor', 'pāstōris', '3', 'le berger'),
    ('discipulus', 'discipulus', 'discipulī', '2', 'l’élève'),
    ('arbiter', 'arbiter', 'arbitrī', '2', 'l’arbitre'),
    ('legatus', 'lēgātus', 'lēgātī', '2', 'l’envoyé'),
    ('nuntius', 'nūntius', 'nūntiī', '2', 'le messager'),
    ('viator', 'viātor', 'viātōris', '3', 'le voyageur'),
    ('venator', 'vēnātor', 'vēnātōris', '3', 'le chasseur'),
    ('ianitor', 'iānitor', 'iānitōris', '3', 'le portier'),
    ('tabellarius', 'tabellārius', 'tabellāriī', '2', 'le courrier'),
    ('minister', 'minister', 'ministrī', '2', 'le serviteur'),
    ('tribunus', 'tribūnus', 'tribūnī', '2', 'le tribun'),
    ('imperator', 'imperātor', 'imperātōris', '3', 'le commandant'),
    ('custos', 'custōs', 'custōdis', '3', 'le gardien'),
    ('captivus', 'captīvus', 'captīvī', '2', 'le prisonnier'),
    ('latro', 'latrō', 'latrōnis', '3', 'le brigand'),
    ('pirata', 'pīrāta', 'pīrātae', '1', 'le pirate'),
    ('auriga', 'aurīga', 'aurīgae', '1', 'le cocher'),
    ('gladiator', 'gladiātor', 'gladiātōris', '3', 'le gladiateur'),
]


def forms(nom, gen, decl):
    if decl == '1':
        stem = gen[:-2]
        endings = ['a', 'am', 'ae', 'ae', 'ā', 'ae', 'ās', 'ārum', 'īs', 'īs']
    elif decl == '2':
        stem = gen[:-1]
        endings = ['', 'um', 'ī', 'ō', 'ō', 'ī', 'ōs', 'ōrum', 'īs', 'īs']
    else:
        stem = gen[:-2]
        endings = ['', 'em', 'is', 'ī', 'e', 'ēs', 'ēs', 'um', 'ibus', 'ibus']
    selectors = ['nom.sg', 'acc.sg', 'gen.sg', 'dat.sg', 'abl.sg',
                 'nom.pl', 'acc.pl', 'gen.pl', 'dat.pl', 'abl.pl']
    result = [{'sel': key, 's': stem + ending} for key, ending in zip(selectors, endings)]
    result[0]['s'] = nom
    return result
