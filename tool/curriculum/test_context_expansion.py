"""Editorial regression checks for generated inflections and authored contrasts."""
import unittest
import context_expansion as content


class ContextExpansionTest(unittest.TestCase):
    def test_principal_forms_and_quantity(self):
        verbs = {v.id: v for v in content.VERBS + content.STATES}
        # External grammatical expectations, including the short active vowel
        # vs long passive vowel and the fourth-conjugation linking vowel.
        for lemma, tense, plural, passive, expected in [
            ('porto', 'present', False, False, 'portat'),
            ('porto', 'present', False, True, 'portātur'),
            ('porto', 'present', True, True, 'portantur'),
            ('porto', 'imperfect', False, True, 'portābātur'),
            ('porto', 'future', False, True, 'portābitur'),
            ('taceo', 'present', False, True, 'tacētur'),
            ('taceo', 'imperfect', False, True, 'tacēbātur'),
            ('lego', 'future', False, True, 'legētur'),
            ('lego', 'perfect', False, False, 'lēgit'),
            ('lego', 'pluperfect', False, False, 'lēgerat'),
            ('aperio', 'present', False, False, 'aperit'),
            ('aperio', 'present', True, False, 'aperiunt'),
            ('aperio', 'present', False, True, 'aperītur'),
            ('aperio', 'present', True, True, 'aperiuntur'),
            ('aperio', 'imperfect', False, False, 'aperiēbat'),
            ('aperio', 'future', False, True, 'aperiētur'),
        ]:
            with self.subTest(lemma=lemma, tense=tense, plural=plural, passive=passive):
                self.assertEqual(verbs[lemma].form(tense, plural, passive), expected)

    def test_no_untranslated_words_or_colliding_answers(self):
        banks = content.banks()
        self.assertGreater(len(banks), 100)
        for address, questions in banks.items():
            for question in questions:
                self.assertTrue(question['vocabulary'])
                self.assertFalse(set(question['vocabulary']) - content.LEXICON.keys(), address)
                accepted = {c['text'] for c in question['choices'] if c['id'] in question['accepted']}
                wrong = {c['text'] for c in question['choices'] if c['id'] not in question['accepted']}
                self.assertEqual(len(accepted), 1)
                self.assertTrue(wrong)
                self.assertFalse(accepted & wrong)
                for choice in question['choices']:
                    outcome = question['outcomes'][choice['id']]
                    self.assertTrue(outcome['feedback'])
                    if choice['id'] not in question['accepted']:
                        self.assertTrue(outcome['observed'])


if __name__ == '__main__':
    unittest.main()
