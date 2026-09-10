#!/usr/bin/env python3
"""Bundle one authored design and compile the shared runtime. No content generation."""
import argparse
import json
import hashlib
import re
from pathlib import Path
import shutil
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--design', required=True, help='Path to the design game.json')
parser.add_argument('--target', choices=['linux', 'web', 'apk'], default='linux')
parser.add_argument('--release', action='store_true')
args = parser.parse_args()
manifest = Path(args.design)
design = json.loads(manifest.read_text())
if not re.fullmatch(r'[a-zA-Z0-9_-]+', design.get('id', '')):
    parser.error('The design ID must be a plain folder identifier')
registry = json.loads((manifest.parent / design['assets']).read_text())
asset_entries = {str(p.parent) + '/' for p in manifest.parent.rglob('*') if p.is_file()}
asset_entries.update(v['path'] for v in registry.values())
pubspec = Path('pubspec.yaml')
original = pubspec.read_text()
start = original.index('  assets:\n')
end = original.index('  # END DESIGN ASSETS', start)
selected = original[:start] + '  assets:\n' + ''.join('    - ' + p + '\n' for p in sorted(asset_entries)) + original[end:]
try:
    pubspec.write_text(selected)
    # Flutter's incremental asset copy can leave undeclared files from an earlier design.
    subprocess.run(['flutter', 'clean'], check=True)
    subprocess.run(['flutter', 'pub', 'get', '--offline'], check=True)
    command = ['flutter', 'build', args.target, '--no-pub', '--release' if args.release else '--debug', '--dart-define=GAME_DESIGN=' + str(manifest)]
    subprocess.run(command, check=True)
    if args.target == 'linux':
        source = Path('build/linux/x64') / ('release' if args.release else 'debug') / 'bundle'
        destination = Path('dist') / design['id'] / 'linux'
    elif args.target == 'web':
        source = Path('build/web')
        destination = Path('dist') / design['id'] / 'web'
    else:
        source = Path('build/app/outputs/flutter-apk')
        destination = Path('dist') / design['id'] / 'apk'
    if destination.exists():
        shutil.rmtree(destination)
    shutil.copytree(source, destination)
    digest = hashlib.sha256()
    for path in sorted(Path('lib').rglob('*.dart')):
        digest.update(str(path).encode())
        digest.update(path.read_bytes())
    (destination / 'design-build.json').write_text(json.dumps({
        'design': design['id'], 'revision': design['revision'],
        'manifest': str(manifest), 'engineSha256': digest.hexdigest(),
        'manifestSha256': hashlib.sha256(manifest.read_bytes()).hexdigest(),
    }, indent=2) + '\n')
    print('Built design', design['id'], 'at', destination.resolve())
finally:
    pubspec.write_text(original)
