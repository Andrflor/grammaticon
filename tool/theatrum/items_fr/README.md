# Theatrum batch items (v2 format)

One file per worksheet: `tool/theatrum/work/sheet_NNN.md` → `tool/theatrum/items_fr/batch_NNN.py`.
Validate with

    python3 tool/theatrum/build_content.py --only tool/theatrum/items_fr/batch_NNN.py

until it prints `ok`. Never edit the validator, the lexicon or the corpus files.

## Format

```python
ITEMS = [
    Q('th-tempus-praeteritum', 'GEN 1:1',                     # trial, Clementine reference
      target=('creavit', 'v:ind.perf.act.3.sg'),              # decisive word + its feature (copy it from TOK)
      dist=[
        ("Au commencement, Dieu crée les cieux et la terre.",  'creavit', 'tempus', 'v:ind.praes.act.3.sg', "la création est présentée comme en cours"),
        ("Au commencement, Dieu créera les cieux et la terre.", 'creavit', 'tempus', 'v:ind.fut.act.3.sg',  "la création est annoncée au lieu d'être racontée"),
        ("Au commencement, Dieu créait les cieux et la terre.", 'creavit', 'tempus', 'v:ind.imperf.act.3.sg', "un fait accompli devient une action qui dure"),
      ],
      # optional:
      # la='exact substring of the Latin verse'   (default: the whole verse)
      # fr='exact substring of the Segond verse'  (default 'LSG' = the whole Segond verse; only with the whole Latin verse)
      # paed=True, fr='your own faithful French'  (when Segond does not render the Latin; never attributed to Segond)
      # fr_ref='PSA 23:1'                          (when the aligned Segond verse differs from the default mapping)
      # gloss={'Ghimel': 'guimel (lettre hébraïque)', 'Moyses': 'Moïse'}   (French meaning for every word marked [NO GLOSS] or `=?`)
      # lemma={'dicit': 'dico2'}                   (force the lemma of a word when the lexicon offers several)
      # note='Segond a le présent pour un parfait latin ; rendu pédagogique.'
    ),
]
```

`Q` is provided by the builder; do not import anything.

## Rules (all enforced or spot-checked)

1. **Latin**: the passage is the whole verse (default) or an exact contiguous substring (`la=`). Max 240 characters; for a longer verse take a clause.
2. **French rendering**: `fr='LSG'` uses the whole Segond verse (exact); `fr='…'` must be an exact substring of the Segond verse; otherwise `paed=True` with your own faithful rendering. The rendering must render the **target word with the right morphology** (tense, number, person, voice, case). If Segond changes it (tense, number, person, textual variant), either pick another target word that Segond renders faithfully, or write `paed=True` and explain in `note`. Never attribute your wording to Segond.
3. **Target**: `(word, feature)`. The feature must be one the worksheet lists for that word in `TOK` (e.g. `videbunt=uideo{v:ind.fut.act.3.pl}`). Prefer finite verbs; nouns/adjectives for `casus`/`numerus`/`congruentia`.
4. **Distractors**: exactly three `(text, span, distinction, wrong, shift)`.
   * `text`: the correct rendering with the **minimal** French change that expresses the misreading. Agreement may propagate (ils verront → il verra). Grammatical, natural French. It must **change the meaning**; it must not be a paraphrase, a synonym swap or a vocabulary change.
   * `span`: the Latin word misread (may differ from the target).
   * `distinction`: `numerus | persona | tempus | vox | modus | casus | congruentia | nonfinita`.
   * `wrong`: the misread feature; it must differ from the span's correct feature **only in the named dimension** (numerus: sg↔pl; persona: 1/2/3; tempus: tense; vox: act↔pass; modus: mood; casus: case). When the span is not the target, write `'okfeature>wrongfeature'` (e.g. `'n:acc.sg>n:nom.sg'`). The lexicon must be able to form the misread form (the validator fetches it as the contrast form). For `congruentia`/`nonfinita` you may write a free Latin description prefixed with `!` (e.g. `'!cum caro (f.) congruēns'`).
   * `shift`: one short French phrase saying how the meaning changed.
5. **Level**: a trial only allows some distinctions (its own plus those of its prerequisites):

   | trial | allowed distinctions |
   |---|---|
   | th-numerus | numerus |
   | th-persona | persona, numerus |
   | th-casus-recti | casus, numerus |
   | th-tempus-praeteritum | tempus, persona, numerus |
   | th-tempus-futurum | tempus, persona, numerus |
   | th-casus-obliqui | casus, numerus |
   | th-congruentia | congruentia, casus, numerus |
   | th-modus-imperativus | modus, persona, numerus |
   | th-vox | vox, tempus, persona, numerus |
   | th-modus-subiunctivus | modus, tempus, persona, numerus |
   | th-nonfinita | nonfinita, vox, tempus, persona, numerus, congruentia, casus |

   Choose the trial from the target: perfect/imperfect/present verb → `th-tempus-praeteritum`; future/pluperfect → `th-tempus-futurum`; imperative → `th-modus-imperativus`; subjunctive → `th-modus-subiunctivus`; passive → `th-vox`; participle/infinitive → `th-nonfinita`; noun case → `th-casus-recti` (nom/acc/abl) or `th-casus-obliqui` (gen/dat/abl); adjective agreement → `th-congruentia`; number of a noun/verb → `th-numerus`; person → `th-persona`. Spread the verses over the trials.
6. **Glosses**: every word marked `[NO GLOSS]` or `=?` needs `gloss={...}` (proper names: the French form used by Segond; Hebrew letters: e.g. `'aleph (lettre hébraïque)'`).
7. **Skip** a verse that has no usable target (a bare list of names, no verb or declined word) and list it in a comment at the top of the file: `# skipped: 1CH 1:1 (list of names)`.
8. Do not invent analyses: only use features the worksheet shows; the validator rejects the rest.
