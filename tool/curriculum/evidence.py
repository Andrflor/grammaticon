"""Identity of the assessed stimulus, separate from background scenario variety.

Changing an unassessed actor/location does not provide a new grammar item. Fixed
constructions need independently authored contrasting stimuli before mastery can
be certified. Do not lower minItems just to make an unfinished bank pass.
"""
FOCUS_BINDINGS = {
    'partitive-group': ['a'],
    'possession-gift': ['a'],
    'double-dative': ['b'],
    'double-accusative-teach': ['a', 'b'],
    'ablative-comparison': ['b'],
    'partitive-selection': ['b'],
    'two-datives-recipient': ['b'],
    'teach-person': ['b'],
    'comparison-ablative': ['b'],
}

def evidence_item(frame, bindings):
    return '|'.join([frame['id']] + [bindings[key].id for key in FOCUS_BINDINGS.get(frame['id'], [])])
