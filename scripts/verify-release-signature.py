#!/usr/bin/env python3
"""Verify all nested release signatures and the universal app architecture."""
import argparse
from pathlib import Path
import re
import subprocess
import sys

SPARKLE = 'Contents/Frameworks/Sparkle.framework'
COMPONENTS = (
    SPARKLE + '/Versions/B/XPCServices/Downloader.xpc',
    SPARKLE + '/Versions/B/XPCServices/Installer.xpc',
    SPARKLE + '/Versions/B/Autoupdate',
    SPARKLE + '/Versions/B/Updater.app',
    SPARKLE,
    '.',
)


def signature_problems(details, team):
    """details: component -> codesign text, or None if missing. Return problems."""
    problems = []
    for component in COMPONENTS:
        value = details.get(component)
        if value is None:
            problems.append(f'{component}: missing component')
            continue
        fields = dict(line.split('=', 1) for line in value.splitlines() if '=' in line)
        match = re.search(r'^CodeDirectory .*?flags=0x[0-9a-fA-F]+\(([^)]*)\)', value, re.M)
        flags = set(match.group(1).split(',')) if match else set()
        if fields.get('Signature') == 'adhoc' or 'adhoc' in flags:
            problems.append(f'{component}: ad-hoc signature')
        if fields.get('TeamIdentifier') != team:
            problems.append(f'{component}: expected team {team}')
        if 'runtime' not in flags:
            problems.append(f'{component}: missing hardened runtime')
        if 'Timestamp' not in fields:
            problems.append(f'{component}: missing Timestamp')
        if component == '.' and not all(arch in fields.get('Format', '') for arch in ('x86_64', 'arm64')):
            problems.append(f'{component}: app must be universal (x86_64 arm64)')
    return problems


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('app', type=Path)
    parser.add_argument('--team', default='8C4YAMZSGP')
    args = parser.parse_args()
    details = {}
    failures = []
    for component in COMPONENTS:
        path = args.app / component
        if not path.exists():
            details[component] = None
            continue
        result = subprocess.run(['codesign', '-dv', '--verbose=2', str(path)], capture_output=True, text=True)
        details[component] = result.stderr
        if result.returncode:
            failures.append(f'{component}: codesign inspection failed: {result.stderr.strip()}')
    failures.extend(signature_problems(details, args.team))
    result = subprocess.run(['codesign', '--verify', '--deep', '--strict', str(args.app)], capture_output=True, text=True)
    if result.returncode:
        failures.append(f'.: strict verification failed: {result.stderr.strip()}')
    if failures:
        print('\n'.join(failures), file=sys.stderr)
        return 1
    print(f'PASS: release signatures (6 components, team {args.team}, universal)')
    return 0


if __name__ == '__main__':
    sys.exit(main())
