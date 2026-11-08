# English interface and typography

English is the primary language for all game screens, dialogue, catalog names,
notifications, and error messages. Runtime locale and fallback are `en`.
Player-entered names are Unicode data and are never translated. Existing saves,
IDs, file paths, numeric stats, costs, rewards, RNG, and unlock rules are unchanged.
Legacy pending battles render enemy names through `legacy_enemy_names.json` aliases
without rewriting the stored encounter or snapshot.
The project name remains unchanged so Godot continues to use the same save folder.

## Unified interface font

All interface text uses **Playfair Display Bold**: stage/chapter/boss names,
buttons, menus, character lists, HP/ATK/Power readouts, descriptions, text input,
rich text, tooltips, and drawn combat text. English remains the primary language.

`game/ui_fonts.gd` loads the bundled font lazily for clean imports and standalone
test runners. All legacy role names (`display`, `bold`, `semibold`, `medium`,
`regular`) resolve to the same Playfair Display Bold resource, so existing screen
code stays compatible. The Typography autoload applies it to text controls.
The Be Vietnam Pro source files and licenses are retained but are not used by UI.

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

`english_ui` checks primary locale, uniform Playfair Display Bold assignments, menu/settings/profile copy,
read-only browsing, and Unicode player-name persistence. It captures rendered
screens under ignored `work/checks/english_ui/`. The static validator checks
runtime strings/data for remaining Vietnamese copy (including known ASCII-only
phrases), font provenance hashes, and bundled licenses.
