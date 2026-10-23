#!/usr/bin/env python3
"""Pure release signature checks; no signing identity or macOS tools required."""
import importlib.util
from pathlib import Path
import sys

spec = importlib.util.spec_from_file_location(
    'release_signature', Path(__file__).resolve().parents[1] / 'scripts/verify-release-signature.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
COMPONENTS = module.COMPONENTS
signature_problems = module.signature_problems
TEAM = '8C4YAMZSGP'
SIGNED = '''Identifier=io.github.akachick113.vkey
Format=app bundle with Mach-O universal (x86_64 arm64)
CodeDirectory v=20500 size=2377 flags=0x10000(runtime) hashes=63+7 location=embedded
Signature size=9097
Authority=Apple Development: akachick113@gmail.com (BCHZ2Y26CN)
Authority=Apple Worldwide Developer Relations Certification Authority
Authority=Apple Root CA
Timestamp=Oct 22, 2026 at 11:32:12
Info.plist entries=35
TeamIdentifier=8C4YAMZSGP
'''
ADHOC = '''Identifier=Autoupdate-5555494467dcbc6056da3300b22db5f67fff8b2d
Format=Mach-O universal (x86_64 arm64)
CodeDirectory v=20500 size=1044 flags=0x10002(adhoc,runtime) hashes=21+7 location=embedded
Signature=adhoc
Info.plist=not bound
TeamIdentifier=not set
'''


def good():
    return dict.fromkeys(COMPONENTS, SIGNED)


def only_component(details, component):
    problems = signature_problems(details, TEAM)
    assert problems and all(p.startswith(component + ':') for p in problems), problems
    return problems


def case65_allComponentsSigned():
    assert signature_problems(good(), TEAM) == []


def case66_adhocHelperRejected():
    for helper in COMPONENTS[:4]:
        details = good()
        details[helper] = ADHOC
        only_component(details, helper)
        # Either marker independently identifies an ad-hoc signature.
        details[helper] = SIGNED.replace('runtime)', 'adhoc,runtime)')
        assert any('ad-hoc' in p for p in only_component(details, helper))
        details[helper] = SIGNED + 'Signature=adhoc\n'
        assert any('ad-hoc' in p for p in only_component(details, helper))


def case67_wrongTeamRejected():
    details = good()
    details['.'] = SIGNED.replace('TeamIdentifier=' + TEAM, 'TeamIdentifier=CF5' + 'PGH3KGK')
    only_component(details, '.')
    problems = signature_problems(good(), 'XXXXXXXXXX')
    assert len(problems) == len(COMPONENTS)
    assert all(any(p.startswith(c + ':') for p in problems) for c in COMPONENTS)


def case68_missingComponentRejected():
    details = good()
    del details[COMPONENTS[1]]
    only_component(details, COMPONENTS[1])
    details = good()
    details[COMPONENTS[2]] = None
    only_component(details, COMPONENTS[2])


def case69_runtimeAndTimestampRequired():
    details = good()
    details['.'] = SIGNED.replace('flags=0x10000(runtime)', 'flags=0x0(none)')
    assert any('runtime' in p for p in only_component(details, '.'))
    details = good()
    details[COMPONENTS[4]] = '\n'.join(line for line in SIGNED.splitlines() if not line.startswith('Timestamp='))
    assert any('Timestamp' in p for p in only_component(details, COMPONENTS[4]))


def case70_universalAppRequired():
    thin = SIGNED.replace('Format=app bundle with Mach-O universal (x86_64 arm64)',
                          'Format=app bundle with Mach-O thin (arm64)')
    details = good()
    details['.'] = thin
    only_component(details, '.')
    details = good()
    details[COMPONENTS[0]] = thin.replace('app bundle with ', '')
    assert signature_problems(details, TEAM) == []


if __name__ == '__main__':
    cases = [case65_allComponentsSigned, case66_adhocHelperRejected, case67_wrongTeamRejected,
             case68_missingComponentRejected, case69_runtimeAndTimestampRequired, case70_universalAppRequired]
    for case in cases:
        try:
            case()
        except AssertionError as error:
            print(f'FAIL: {case.__name__}: {error}', file=sys.stderr)
            sys.exit(1)
    print('PASS: 6 release signature tests')
