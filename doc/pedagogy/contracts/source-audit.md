# Source audit

Confirmed scope: Familia Romana, Fabellae Latinae, Fabulae Syrae, Epitome Historiae Sacrae. Roma Aeterna is excluded.

The initial 361-row placeholder inventory is now a 356-unit source map after checking the numbered Fabulae Syrae selections. Its row count is not evidence of pedagogical coverage; most source requirements remain unaudited.

On 2026-09-10 publisher search results identified the official Familia Romana Latin–English Vocabulary PDF. Direct web retrieval returned HTTP 403. The publisher pages for Fabulae Syrae and Epitome also returned HTTP 403. These responses establish an access limitation, not a content inventory.

Official locations identified:
- https://www.hackettpublishing.com/pdfs/Familia_Romana_Latin-English_Vocabulary.pdf
- https://hackettpublishing.com/lingua-latina-per-se-illustrata-series/lingua-latina-fabulae-syrae
- https://hackettpublishing.com/lingua-latina-per-se-illustrata-series/lingua-latina-epitome-historiae-sacrae

Next: obtain accessible authoritative indices and check their edition/scope; record requirements without copying textbook sentences, modern translations or exercises into the game.

Direct HTTPS downloads with curl succeeded for the public publisher PDF and both product pages. The PDF has 40 pages; page 2 was rendered and visually checked against text extraction. `familia-romana-lexical-candidates.json` records Latin headwords and source pages only, excluding English definitions. Entry normalization, disambiguation of senses and coverage mapping remain pending. Product pages exposed no PDF preview links in their HTML.

## Additional verified evidence

- The [official Vivarium Novum description of Fabulae Syrae](https://vivariumnovum.it/scolastica/latino/letture-complementari/fabulae-syrae) explicitly states **50** myths/legends and reinforcement from Familia Romana XXVI. This confirms the unit count only; it does not establish a verified per-story inventory.
- Fabellae Latinae readings 1–6 have now been inspected for learning requirements. Their inventory distinguishes quantity/stem contrasts, possession, pronoun reference, case roles, commands and question expectations. Question mappings remain partial; no reading is certified fully covered.
- Evidence in `coverage.json` names concrete card addresses and question IDs, plus the requirement keys they support. The completion checker rejects unresolved references and refuses to accept a unit marked verified with empty or unmapped inventories.

## Fabellae Latinae: complete reading pass, unfinished lexical review

All 30 reading bodies in the publisher PDF have been consulted. `fabellae-surface-inventory.json` records unordered forms and counts from the bodies (8,689 tokens; 2,072 distinct extracted forms), excluding headings and the separate character list. It includes no sentences or translations. Extraction may retain split-word or spelling anomalies; contextual normalization is unfinished.

Every reading now has a draft of salient constructions, lexical senses and reading demands in `coverage.json`. The lexeme lists for later readings are selected additions, not full inventories. `fabellae-construction-index.json` collects 246 provisional requirement labels, of which 18 currently have explicitly declared partial question evidence. Labels still require consolidation; these counts are neither a final card count nor proof of coverage.

The new requirements distinguish, among other things, personal agent versus instrument, active/passive/deponent readings, time of an infinitive relative to its reporting verb, participle agreement, the two supines, Roman date and numeral conventions, and dialogue claims versus narrative facts. None of the 30 readings is marked fully covered. The full completion gate remains failed.

## Fabulae Syrae and Epitome reference access

The reference texts are now accessible for read-only pedagogical analysis. They are kept outside the repository under `/tmp`; no reference prose, translations, exercises or illustrations are installed as game content.

- **Fabulae Syrae**: the university-hosted [2010 reference PDF](https://elearning.jcu.cz/pluginfile.php/561884/mod_resource/content/1/F%C4%81bul%C3%A6%20Syr%C3%A6.pdf) identifies ISBN 978-88-95611-29-7. Its contents page was rendered and inspected: nine chapter groups XXVI–XXXIV, each with five numbered selections. The [publisher description](https://hackettpublishing.com/lingua-latina-per-se-illustrata-series/lingua-latina-fabulae-syrae) advertises fifty myths. The audit now follows the **45 actual numbered selections**, retaining the advertised count as separate metadata and the edition/count comparison as pending. Five never-audited placeholder rows were removed; no authored or verified coverage was removed. `fabulae-syrae-source-map.json` records titles, chapter associations and page anchors. `fabulae-syrae-lexical-candidates.json` contains 678 rough index headword candidates requiring OCR and entry-boundary review; this is not a vocabulary coverage count.
- **Epitome Historiae Sacrae**: the [2009 reference PDF](https://librinostri.catholica.cz/download/EpitomeHistoriaeSacrae-2009.pdf) matches the editor, year and ISBN identified by the [official publisher](https://vivariumnovum.it/scolastica/latino/letture-complementari/epitome-historiae-sacrae). Its structure is 209 Old Testament paragraphs and 37 New Testament paragraphs. `epitome-source-map.json` records all paragraph page anchors. The final headings XXXVI–XXXVII were visually inspected. OCR numeral repairs are documented; the prose, quantities, lexical senses and construction requirements are not yet audited.

These source maps establish what must be inspected, not what the game already teaches. No source unit in either book is marked covered.
