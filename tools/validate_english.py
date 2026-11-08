"""Check English UI coverage, bundled font integrity, and required font weights."""
from pathlib import Path
import hashlib
import json
import re
import struct

ROOT = Path(__file__).resolve().parents[1]
VIETNAMESE = re.compile(r"[àáảãạăâầấẩẫậằắẳẵặèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđĐ]", re.I)
LEGACY_ASCII = re.compile(r"\b(?:Tinh linh|Tinh anh|Mua1?|Xem VIP|Xem ›|Kho tinh linh)\b", re.I)
STRINGS = re.compile(r'"(?:\\.|[^"\\])*"')
errors = []
for path in (ROOT / "game").rglob("*.gd"):
    for token in STRINGS.findall(path.read_text()):
        try:
            value = json.loads(token)
        except ValueError:
            continue
        if VIETNAMESE.search(value) or LEGACY_ASCII.search(value):
            errors.append(f"{path.relative_to(ROOT)}: untranslated UI string {value!r}")


def check_data(value, path):
    if isinstance(value, str):
        if VIETNAMESE.search(value) or LEGACY_ASCII.search(value):
            errors.append(f"{path}: untranslated display data {value!r}")
    elif isinstance(value, dict):
        for key, item in value.items():
            check_data(item, f"{path}/{key}")
    elif isinstance(value, list):
        for index, item in enumerate(value):
            check_data(item, f"{path}/{index}")


for path in (ROOT / "game/data").glob("*.json"):
    check_data(json.loads(path.read_text()), str(path.relative_to(ROOT)))
font_root = ROOT / "art/fonts"
for record in json.loads((font_root / "provenance.json").read_text()):
    data = (font_root / record["file"]).read_bytes()
    if hashlib.sha256(data).hexdigest() != record["sha256"]:
        errors.append("Font provenance hash mismatch: " + record["file"])
for name, expected in {"BeVietnamPro-Regular.ttf": 400, "BeVietnamPro-Medium.ttf": 500,
                       "BeVietnamPro-SemiBold.ttf": 600, "BeVietnamPro-Bold.ttf": 700,
                       "PlayfairDisplay-Bold.ttf": 700}.items():
    data = (font_root / name).read_bytes()
    count = struct.unpack_from(">H", data, 4)[0]
    weights = []
    for index in range(count):
        tag, _, offset, _ = struct.unpack_from(">4sIII", data, 12 + index * 16)
        if tag == b"OS/2":
            weights.append(struct.unpack_from(">H", data, offset + 4)[0])
    if weights != [expected]:
        errors.append(f"Incorrect font weight for {name}: {weights}")
for family in ["BeVietnamPro", "PlayfairDisplay"]:
    if not (font_root / (family + "-OFL.txt")).is_file():
        errors.append("Missing font license: " + family)
if errors:
    raise SystemExit("\n".join(errors))
print("PASS: English runtime copy/catalogue, official font provenance hashes and OFL licenses")
