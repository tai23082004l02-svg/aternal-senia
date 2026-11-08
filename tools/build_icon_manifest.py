"""Register reviewed icon cells without modifying source PNG pixels."""
from pathlib import Path
import hashlib
import json
import struct

ROOT = Path(__file__).resolve().parents[1]
SHEETS = {
    **{key: [kind+'_'+key for kind in ['sword','spear','staff','armor','boots','accessory']] for key in ['grove','storm','moon']},
    'gear': ['boots_3','boots_4','boots_5','boots_6','boots_7','accessory_4','accessory_5','accessory_6','accessory_7','sword_dawn','spear_ember','staff_tide','set_dawn','set_ember','set_tide','boots_category'],
    'navigation': ['journey', 'hero', 'equipment', 'quest', 'journal', 'slash', 'heal', 'spirit', 'guard', 'training', 'talents', 'companion', 'boss', 'forge', 'gold_ui', 'crystal_ui'],
    'systems': ['mail', 'gift', 'settings', 'help', 'achievement', 'wardrobe', 'evolution', 'awakening', 'summon', 'afk', 'daily', 'weekly', 'chest', 'chest_open', 'vip', 'event'],
    'equipment': ['sword_1', 'sword_2', 'spear_1', 'spear_2', 'staff_1', 'staff_2', 'armor_1', 'armor_2', 'armor_3', 'armor_uncommon', 'armor_4', 'armor_5', 'armor_6', 'armor_7', 'weapon_category', 'armor_category'],
    'resources': ['gold', 'shards', 'xp', 'cores', 'fragments', 'potion', 'victory', 'training_item', 'slash_spell', 'heal_spell', 'burst', 'ticket', 'fire', 'water', 'light', 'vip_exp'],
}
ALIASES = {'crystal': 'shards', 'shop': 'gold', 'utilities': 'settings', 'dungeon': 'boss', 'collection': 'achievement'}


def build():
    regions, sources = {}, []
    for sheet, names in SHEETS.items():
        path = ROOT / 'art/icons' / (sheet + '.png')
        raw = path.read_bytes()
        assert raw[:8] == b'\x89PNG\r\n\x1a\n'
        width, height = struct.unpack('>II', raw[16:24])
        # Preserve the reviewed grid for each atlas; added sets use3x2 cells.
        columns, rows = (3, 2) if sheet in ['grove','storm','moon'] else (4, 4)
        xs = [round(width * i / columns) for i in range(columns+1)]
        ys = [round(height * i / rows) for i in range(rows+1)]
        for i, name in enumerate(names):
            x, y = i % columns, i // columns
            assert name not in regions
            regions[name] = {'atlas': 'icons/' + sheet + '.png', 'region': [xs[x], ys[y], xs[x+1]-xs[x], ys[y+1]-ys[y]], 'sheet': sheet, 'cell': i}
        sources.append({'file': 'art/icons/' + sheet + '.png', 'size': [width, height], 'sha256': hashlib.sha256(raw).hexdigest()})
    manifest = {'version': 1, 'regions': regions, 'aliases': ALIASES}
    (ROOT / 'art/icons/manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    provenance = {'date': '2026-11-08', 'method': 'Original image generation referenced art/ui/icons.png. Five reviewed 4x4 and three 3x2 source atlases, retained byte-for-byte. No pixel edits or extracted reference-game assets.', 'sources': sources}
    (ROOT / 'art/icons/provenance.json').write_text(json.dumps(provenance, indent=2) + '\n')
    return manifest


if __name__ == '__main__':
    print('Registered %d original icon cells' % len(build()['regions']))
