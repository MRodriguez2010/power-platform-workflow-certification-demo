"""Render a portable package with your own non-secret site/library identifiers."""
import json,zipfile
from pathlib import Path
root=Path(__file__).resolve().parents[1]
cfg=json.loads((root/'config.local.json').read_text())
replacements={'__SHAREPOINT_SITE_URL__':cfg['site'],'__EXCEL_SOURCE__':cfg['excel_source'],'__EXCEL_DRIVE__':cfg['excel_drive']}
if any('YOUR-' in v for v in replacements.values()): raise SystemExit('Replace all example identifiers first')
with zipfile.ZipFile(root/'flow/import-template.zip') as src,zipfile.ZipFile(root/'configured-import.zip','w',zipfile.ZIP_DEFLATED) as dst:
 for name in src.namelist():
  text=src.read(name).decode()
  for old,new in replacements.items():text=text.replace(old,new)
  json.loads(text)
  dst.writestr(name,text)
print('Created configured-import.zip. Select your connections during import. No credentials are stored.')
