# UI Design V2 — presentation system and handoff

Owner assignment, 2026-11-08: UI, screen layouts, navigation and scene backgrounds
belong to the UI workstream. Another contributor owns character identity, clothing,
weapons, poses, personality and ability design. This delivery does not change hero
contracts, combat behavior, stats, unlocks, source artwork or canonical identities.

## Design tokens

Runtime source: `game/ui_design_v2.gd` (`UIDesignV2`). Gallery reuses its color
constants; Home, Showcase and Reveal use its panels, buttons, text and artwork view.
Legacy screens retain their existing layouts. This is a system for migrating UI
incrementally, not a claim that every screen already uses V2.

| Token | Value / rule |
| --- | --- |
| Navy | #0C152B, screen and overlay foundation |
| Panel | #14233C, cards and information surfaces |
| Gold | #DFBD79, identity, selected states and borders |
| Ivory | #F6EDDB, primary text |
| Muted | #A4B3C9, secondary text |
| Accent | #31557F, blue emphasis reserved for selection |
| Typeface | Packaged Playfair Display Bold via UIFonts/ Typography; no system fonts |
| Type scale | 30–32 title; 20–23 section; 14–16 body/action; 12–13 secondary |
| Spacing | 8 px base; 16 px internal margin; 24 px screen gutters |
| Buttons | 44 px minimum hit height for new Home/Showcase/Reveal actions; primary gold-brown, secondary navy |
| Corners | 10 px panels/actions; thin warm or slate border |
| Canvas | 540 × 960 logical pixels; navigation below y876; content above y864 |

Chips/card labels stay as real Controls. Text wraps, scrolls or is truncated with a
tooltip; no labels or resource counters are baked into artwork. Generic reveal
rings are presentation effects, not a character pose, skill or combat event.

## Delivered screens

| Screen | Entry / behavior | UI source |
| --- | --- | --- |
| Gallery | Heroes → Gallery, or Home → Heroes/Gallery; 4 compact columns, detail mode, real ownership/filter state | `game/hero_gallery.gd` |
| Showcase | Tap any Gallery card or Home View; inspect owned and locked heroes, switch portraits, Information/Skills tabs | `game/hero_showcase.gd` |
| Reveal | Actual committed x1/x10 results or Replay latest; Next, Summary, Skip, hero details | `game/summon_reveal.gd` |
| Home | Startup page24; persistent header Home action; Gallery, Summon, Journey, Formation, Bag, Missions, AFK and More | `game/home_screen.gd` |

Home is separate from Journey (page0). The five existing bottom navigation routes
remain functional. Header Home returns to page24; More on Home opens Utilities.
Startup read-only/unfinished-battle prompts remain in place. Going Home during an
active battle pauses it; returning to Journey resumes only the pause owned by
navigation. Model snapshots are unchanged.

Showcase is a full-height modal with canonical illustration, identity, affinity,
role, acquisition source, scrollable information/skill copy, right-side tabs and
an independently scrollable portrait strip. Equipment/Wardrobe route to existing
guarded management pages. Bond/Story explicitly remain disabled; no invented
biography, favorite grant or Bond progress is shown.

Reveal takes a deep copy of committed history. Its presentation never calls RNG,
spends resources, grants rewards or changes pity. New/duplicate labels use the
recorded result, including the existing 10 matching fragments for duplicate heroes
or spirits. Summary is scrollable. Closing or opening details is safe: the latest
batch remains replayable from Summon. Reduced-effects and battery-saver options
suppress the new reveal animation. Static illustration remains visible.

Home cycles only owned portraits in session memory (`home_hero`); this is not a
saved favorite and does not change avatar, formation or build. It reuses existing
canonical landscape banners as composite illustrations; the close crop is a
presentation choice, not a new full-body pose. Home also links to Caelan's explicitly labeled design preview via the separate
CharacterPreviews registry. It is not a playable/owned hero entry. There are no fake Mail/Pass/Event
reward claims or new payment/banner services.

## Earlier UI pieces included in the handoff

These are presentation modules to keep with UI maintenance, not character design:

| Module | UI responsibility |
| --- | --- |
| `game/formation_screen.gd` | Four hero slot layout, roster cards and spirit selector |
| `game/team_battle_ui.gd` | Four hero HUD cards, independent spirit Ultimate and battle rendering positions |
| `game/journey_screen.gd` | Journey layout and four-hero preview |
| `game/character_screen.gd` | Existing management UI and Gallery entry; retains its guarded upgrade/equipment routes |

`game/core/formation.gd` remains a model/compatibility component, outside the visual
handoff. UI and character sources are separated by module and documented inputs;
existing art files are not physically moved and their `.uid`/provenance stays intact.

## Separate workstreams and asset boundary

| UI workstream owns | Character workstream owns |
| --- | --- |
| Tokens, widgets, layout, crop/framing, navigation and read-only display | Hero identity, canonical name/title, appearance and outfit design |
| Home/Showcase/Reveal backgrounds and generic UI transition effects | Weapons, anatomy, pose sheets and character animation source art |
| Rendering real role/skill/acquisition data and lock states | Role/skill design and reviewed character contract changes |
| Screen tests and UI handoff | Canonical artwork provenance and character acceptance |

Existing `art/banners/*.png`, portraits, sprite sheets and `hero_contracts.json`
remain character-owned inputs. This patch changes no bytes under `art/` or
`game/data/`. Do not move or rename them for UI organization. The UI artifact
boundary is the source-file manifest above, tokens, integration in `game/main.gd`,
and UI tests/docs. Save/economy/combat code remains outside this handoff.

For replacement art, keep stable hero IDs and the validated `art.banner` contract.
Supply canonical source/provenance through the established art workflow. The UI
can frame the new texture without changing identity, ownership or stats. A future
separate-background/transparent-character composition needs canonical compatible
art; this delivery does not cut out or redraw pixels from character illustrations.

## Verification and limits

Delivery checks on Godot 4.6.3/Linux/X11: 21 relevant suites pass — ui_design_v2,
collection_ui, english_ui, character_design, character_ui, journey_ui, ui_flow,
team_flow, settings_ui, utilities_ui, player_profile, summon_ui, summon_batch,
recruitment, hero_contract, animation_gallery, regression, mechanics, campaign,
team_ui and formation_layout. Import, verify_repo and validate_english pass.
Rendered Home, owned/locked/skill Showcase, hero/duplicate Reveal and summary
captures were inspected. This is targeted verification; the entire 45-suite runner
is not claimed as executed for this delivery.


`tests/ui_design_v2.gd` covers startup Home, action routing, owned/locked Showcase,
real skill copy, disabled Bond/Story, guarded management routing, committed Reveal,
reduced motion, read-only browsing, pending-run pause/resume and control bounds.
`collection_ui` also exercises real hero/duplicate reveals, details, replay and
reload without additional spending/grants. `journey_ui` explicitly navigates to
Journey now that startup is Home. Synthetic swipe tests use scaled screen input.

Use `python3 tools/check_project.py --tests ui_design_v2 collection_ui english_ui
journey_ui ui_flow team_flow` on X11/Xvfb. Captures remain under ignored
`work/checks/`; they are not character-art deliverables. Linux rendering does not
verify real-phone touch, FPS, texture RAM or heat. No APK or public release is
created by this UI delivery.
