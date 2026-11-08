> Later update: Caelan is now playable under the owner-authorized integration. Its design-preview entry was removed; this document records the earlier cleanup. See [CAELAN_RUNTIME](CAELAN_RUNTIME.md).

# 0.38 — cleanup and delivered-character visibility

## Why Caelan did not appear

The character delivery added source artwork, a 16-pose atlas, props and metadata
under `art/caelan/`. Its manifest explicitly says character-design-only, and it did
not register a playable hero. Godot importing PNGs cannot add catalogue rows,
ownership, UI entries or acquisition rules automatically.

`game/data/character_previews.json` now explicitly registers the delivered design.
`CharacterPreviews` is a presentation registry, separate from GameCatalog, saves,
summon pools and Formation. Home links to the new design; Gallery shows it and
has a Previews filter; Showcase reads its illustration and canonical quote.
Caelan is clearly marked **Design preview · Not playable**. Skills, Equipment,
Wardrobe, Bond and Story are disabled for preview entries. There are still four
playable hero definitions; this delivery neither invents a combat kit nor grants
Caelan or fragments to saves. The proposed kit and acquisition in the character
handoff still require gameplay implementation.

## Removed and consolidated

- Removed seven uncalled UI helpers from `game/main.gd`: old material row,
  inventory card, item illustration, graphics shortcut, spirit filter and two old
  audio-setting wrappers. Current Bag/Settings/modal components remain in use.
- Removed duplicate hero-tree and spirit-evolution screen builders. Legacy page6
  routes to current Character Skills; page7 routes to current Spirit detail.
  Existing model operations, ownership checks and pending/read-only guards remain.
- Removed the unreachable standalone Summon page branch. Summon has one current
  route through Shop; banner/rates/history and real summon transactions remain.
- Removed obsolete `tests/combat_movie.gd`, `tests/visual_movie.gd` and
  `tests/team_movie.gd` plus their attached UIDs. They were recording-only legacy
  harnesses, outside the suite runner, with obsolete singleton/three-hero staging.
  Current team/UI/animation and singleton compatibility tests are retained.
- Removed about82 MB of ignored prior captures/logs under `work/checks/` before
  running fresh checks. This is local generated output, not a Git download-size
  reduction. New verification evidence is generated there again as needed.

No source character PNG, provenance, receipts, fonts, audio, save/migration code,
UID equipment, rewards or pending-run snapshots are removed. BattleModel and its
legacy renderer remain necessary to resume old singleton runs; they are not dead
UI merely because new battles use TeamBattle. Godot import caches are generated,
ignored and still needed for running the editor; deleting them does not register
new characters.

## Updating the correct Godot project

Home displays **v0.38.0**. Android exports include version and commit in the folder
name and terminal output. `tools/export_android.sh` exports committed HEAD only;
it does not overwrite an old project directory or reset player data. Close the
old project and import the exact new `project.godot` printed by the script.
See [Android/Termux](ANDROID_TERMUX.md). A project still showing0.37.0 is an old
checkout/export, not this build.

## Checks

`character_previews` covers actual art visibility, Home/Gallery/Showcase routes,
preview filtering, disabled gameplay controls, no ownership/pool/formation grant,
no save mutation, and old UI redirects. Existing collection/UI/battle/migration
checks remain available in the 46-suite runner. Caelan's independent art validator
still verifies original source PNG hashes, alpha, metadata and pose bounds.

Targeted checks passed on Godot4.6.3/Linux/X11: character_previews, ui_design_v2,
collection_ui, progression_ui, expansion_ui, english_ui, regression, team_battle,
team_ui, settings_audio, supplies_ui, shop_ui and animation_gallery (13 suites).
Project import, verify_repo, validate_english and validate_caelan_art passed;
Gallery and Caelan Showcase captures were inspected. This is not a claim that all
46 suites ran for this cleanup.

Captures and exported test projects live under ignored `work/`. No phone FPS,
physical touch or APK claim is made by this cleanup.
