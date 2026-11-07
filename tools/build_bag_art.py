"""Register preserved original inventory/forge illustration panels."""
from pathlib import Path
import json,hashlib,struct
root=Path(__file__).resolve().parents[1]
path=root/'art/bag/scenes.png'
raw=path.read_bytes()
assert struct.unpack('>II',raw[16:24])==(1536,1024)
(path.parent/'provenance.json').write_text(json.dumps(dict(date='2026-11-07',method='Original image generation referenced the project equipment style; two reviewed1536x512 illustrations, treasure forest and forge. Source PNG preserved byte-for-byte, no pixel edits.',sources=[dict(file='art/bag/scenes.png',sha256=hashlib.sha256(raw).hexdigest())]),indent=2)+'\n')
