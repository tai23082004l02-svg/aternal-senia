# Celestial UI 0.39 — Selena presentation

Owner-authorized replacement of the existing UI presentation, 2026-11-08.
Reference: the eight-screen character-collection mockup and navy/gold UI kit
provided in chat. This document supersedes the visual/layout portions of
[UI Design V2](UI_DESIGN_V2.md); runtime class names remain stable.

## Delivered presentation

- Home: the original vertical Selena illustration, balanced top crop, side menu,
  three diamond-framed character/summon/adventure actions (gold luminous center Summon) and live navigation shortcuts.
  The default Selena feature is explicitly a **design preview**. Cycling selects
  owned hero illustrations in session memory only; no favorite/profile/save write.
- Shared shell: navy panels, warm gold borders, bevel highlights, corner ornaments,
  real currency capsules and a continuous framed bottom navigation without separate button boxes. New vector menu
  glyphs replace the previous textured navigation icons; inventory/combat item
  icons retain their validated atlases. Typography remains packaged English
  Playfair Display Bold.
- Gallery: taller four-column portrait cards, owned/locked/preview disclosure,
  live filters and the existing nested swipe scrolling. Owned count excludes
  design previews. The Selena card is not an ownership or acquisition entry.
- Showcase: taller illustrated overlay, top identity, six right-side tabs,
  lower information/skill panel and portrait carousel. Equipment/Wardrobe retain
  their guarded management routes. Selena's gameplay tabs remain disabled.
- Summon: left banner rail, taller Selena illustration with top-aligned face,
  immediate live prices/x1/x10 actions, rates/history/pool and ticket access.
  Selena is explicitly **not in the pool**. Premium/event remain unavailable.
  The surrounding Shop section strip is hidden only on the Summon section;
  global navigation and its Home button still work.
- Reveal: taller art, gold aura, lower fade, identity and safe continue/summary.
  Actual summon results still come exclusively from committed Recruitment history.
  Selena has a separate labeled **art reveal preview**, accessible from her
  Showcase, which neither spends nor grants anything.
- Battle: four portrait HUD cards with health/energy, a separate spirit control,
  navy panels, bounded buttons and unchanged combat/targeting/action logic.

The previous Home layout, Showcase crop branch, shell artwork renderer and
Summon GoldTrim implementation were replaced in place; no old/new UI toggle or
second set of menu routes is shipped. Legacy pending-singleton combat rendering
remains necessary for existing saves. Referenced art/builder/provenance inputs
are retained; no source PNG was altered, moved or regenerated.

## Selena boundary

`selena_preview` lives only in `game/data/character_previews.json`. This is not a
runtime hero ID and does not rename planning Selene/H03. No combat stats, kit,
fragments, ownership, banner odds or acquisition changes were introduced. Original
source hashes remain recorded in `art/selena/provenance.json`. Pose/expression/
weapon sheets remain design sources, not imported combat animations.

Bond, character stories, paid services and unconfigured banners retain real lock
states. The static mockup's example balances, roster totals and UR/SSR badges are
not fabricated in the game. The UI uses the current five-hero runtime catalogue.

## Validation and limits

Use `python3 tools/check_project.py` on X11/Xvfb. `selena_ui` verifies preview
routing, labeled art reveal, no summon eligibility, session-only Home cycling,
read-only browsing and no profile mutation. Existing collection/summon/battle/UI
suites cover scrolling, transaction safety and old pending battles. All new render
captures stay in ignored `work/checks/`. This is a Godot/Linux UI delivery; it does
not establish Android touch/FPS/thermal performance or add Bond/Story gameplay.

Verification for this delivery: Godot 4.6.3 import, repository validator and
English validator pass. All 49 default suites pass on Linux/X11 (dummy display,
Mesa llvmpipe). After the final diamond/continuous-bottom-bar changes, seven
relevant suites pass again: selena_ui, ui_design_v2, ui_flow, mobile_inventory,
summon_ui, team_ui and character_previews. Home, Selena Showcase/art reveal,
Gallery, Summon and Battle captures were visually inspected. No Android APK or
real-phone performance claim is included.
