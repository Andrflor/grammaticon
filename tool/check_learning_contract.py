#!/usr/bin/env python3
"""Check the actual skill contract; source books are breadth guidelines only."""
import argparse
import json
from audit_skill_graph import audit

parser = argparse.ArgumentParser()
parser.add_argument('--catalog-only', action='store_true')
args = parser.parse_args()
report = audit()
errors = list(report['errors'])
if not args.catalog_only:
    for place, counts in report['places'].items():
        if counts['questions'] < 200000:
            errors.append(f'{place}: {counts["questions"]} questions; requested order of magnitude is hundreds of thousands')
    if not report['coverageComplete']:
        errors.append('The independent reading and production curricula do not yet cover the requested conceptual and lexical breadth of Latin')
print(json.dumps({
    'mode': 'catalog-only' if args.catalog_only else 'full-objective',
    'catalog': report['places'], 'validationPassed': not errors,
    'objectiveComplete': None if args.catalog_only else not errors,
    'errors': errors,
}, ensure_ascii=False, indent=2))
raise SystemExit(bool(errors))
