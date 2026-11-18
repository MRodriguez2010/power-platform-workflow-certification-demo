"""Reconcile saved native receipts; this does not execute Microsoft flows."""
from pathlib import Path
import json
root=Path(__file__).resolve().parents[1]
expected=json.loads((root/'validation/expected-baseline.json').read_text())
actual={}
for p in (root/'validation/baseline').glob('*.json'):
 d=json.loads(p.read_text()); key=d.get('RequestId',d.get('ResponseId',d.get('EmployeeId')))
 assert key not in actual, f'Duplicate receipt: {key}'
 actual[key]=d.get('Status',d.get('Route'))
assert actual==expected, {'expected':expected,'actual':actual}
print(f'{len(expected)} native baseline outcomes match. This is evidence reconciliation, not a new cloud run.')
