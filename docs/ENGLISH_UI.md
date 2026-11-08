# English interface and typography

English is the primary language for all game screens, dialogue, catalog names,
notifications, and error messages. Runtime locale and fallback are `en`.
Player-entered names are Unicode data and are never translated. Existing saves,
IDs, file paths, numeric stats, costs, rewards, RNG, and unlock rules are unchanged.
Legacy pending battles render enemy names through `legacy_enemy_names.json` aliases
without rewriting the stored encounter or snapshot.
The project name remains unchanged so Godot continues to use the same save folder.

## Font roles

| Content | Bundled font |
| --- | --- |
| Stage, chapter, and boss names; display headings | Playfair Display Bold |
| Play, Battle, Summon and primary actions | Be Vietnam Pro Bold |
| HP, ATK, DEF, Power and compact stat readouts | Be Vietnam Pro SemiBold |
| Skill and item descriptions; body copy and text input | Be Vietnam Pro Regular |
| Menus, navigation and character lists | Be Vietnam Pro Medium |

`game/ui_fonts.gd` loads the bundled resources lazily, supporting clean imports
and standalone test runners. `game/typography.gd` is the Typography autoload. It sets the English locale and
applies bundled fonts when controls enter the tree. `configure()` registers stage,
chapter, boss, and roster names. Label metadata `font_role` can explicitly select
`display`, `bold`, `semibold`, `medium`, or `regular` when a control needs a specific
role. Dynamically drawn battle numbers use the same bundled fonts.

Use English source copy for new UI and display data. Continue using `tr()` where
present so additional translations remain possible. Keep technical IDs and saved
player data independent of display text. Descriptions should wrap; long menus
use SwipeScroll. Do not bake text into artwork or silently clip required actions.

## Font sources and licenses

Files in `art/fonts/` come from the official Google Fonts repository. The two
SIL Open Font License files are bundled with the fonts. `provenance.json` records
source URLs and SHA-256 hashes. Be Vietnam Pro ships in static weights 400, 500,
600, and 700. Playfair Display Bold is a static instance at `wght=700` of the
retained official variable font, produced with fontTools 4.61.1:

```python
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
font = TTFont('art/fonts/PlayfairDisplay.ttf')
font = instantiateVariableFont(font, {'wght': 700}, updateFontNames=True)
font.save('art/fonts/PlayfairDisplay-Bold.ttf')
```

The game does not download fonts or depend on system font availability.

## Validation

```bash
python3 tools/validate_english.py
python3 tools/verify_repo.py
# On X11/Xvfb, with writable XDG directories where required:
python3 tools/check_project.py --tests english_ui journey_ui player_profile settings_ui summon_ui
```

`english_ui` checks primary locale, font assignments, menu/settings/profile copy,
read-only browsing, and Unicode player-name persistence. It captures rendered
screens under ignored `work/checks/english_ui/`. The static validator checks
runtime strings/data for remaining Vietnamese copy (including known ASCII-only
phrases), font provenance hashes, and bundled licenses.
