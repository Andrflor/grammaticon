# self-test of the v2 format (kept as the reference example)
ITEMS = [
    Q('th-tempus-praeteritum', 'GEN 1:1',
      target=('creavit', 'v:ind.perf.act.3.sg'),
      dist=[
        ("Au commencement, Dieu crée les cieux et la terre.", 'creavit', 'tempus', 'v:ind.praes.act.3.sg', "la création est présentée comme en cours"),
        ("Au commencement, Dieu créera les cieux et la terre.", 'creavit', 'tempus', 'v:ind.fut.act.3.sg', "la création est annoncée au lieu d'être racontée"),
        ("Au commencement, Dieu créait les cieux et la terre.", 'creavit', 'tempus', 'v:ind.imperf.act.3.sg', "un fait accompli devient une action qui dure"),
      ],
      note="Segond a « les cieux » pour cælum (singulier) ; la cible est le verbe."),
    Q('th-numerus', 'GEN 1:5',
      target=('Appellavitque', 'v:ind.perf.act.3.sg'),
      la='Appellavitque lucem Diem, et tenebras Noctem',
      fr='Dieu appela la lumière jour, et il appela les ténèbres nuit',
      dist=[
        ("Dieu appela les lumières jour, et il appela les ténèbres nuit", 'lucem', 'numerus', 'n:acc.sg>n:acc.pl', "plusieurs lumières"),
        ("Ils appelèrent la lumière jour, et ils appelèrent les ténèbres nuit", 'Appellavitque', 'numerus', 'v:ind.perf.act.3.pl', "plusieurs acteurs au lieu de Dieu seul"),
        ("Dieu appela la lumière jours, et il appela les ténèbres nuit", 'Diem', 'numerus', 'n:acc.sg>n:acc.pl', "plusieurs jours"),
      ]),
]
