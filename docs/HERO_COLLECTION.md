# Hero contracts, Gallery and Summon Reveal

> Update0.38/save13: Caelan is the fifth playable hero. The original four-hero/v12 sections below describe the foundation milestone; current acquisition, skills and migration are in [CAELAN_RUNTIME](CAELAN_RUNTIME.md).

Implemented for the four existing heroes. The approved 24-hero launch roster is
still a production target; the planning registry is not imported into runtime.
No character art, identity, stat, unlock milestone, summon price, probability,
pity, duplicate conversion or equipment ownership was changed.

## Runtime data contract

`game/data/catalog.json` remains the source for ID, name, rarity, stats and unlock.
`game/data/hero_contracts.json` version 1 supplies weapon category, gallery order,
role, acquisition text, banner path, summon group, skill descriptions and combat
behavior. `GameCatalog` merges only the allowed contract fields; contracts cannot
replace IDs, stats or ownership. `HeroContract` validates implemented capabilities.

Current mappings: Eira/eira/sword/Light Duelist; Ryn/ryn/spear/Fire Bruiser;
Mira/mira/staff/Water Healer; Lyra/lyra/spear/Fire Striker. All are base 5★.
The roles describe their current behavior; launch ability concepts remain separate.

Current supported abilities: damage or adaptive healing basic skill, damage or
team-heal Ultimate, optional self shield and incoming-damage multiplier. These
preserve the existing formulas, timing, RNG, targeting and effects. New status
systems, bow/gun renderers, Storm/Shadow mapping and balancing need separate work;
unsupported contracts fail validation instead of silently becoming swords.

New team snapshots copy the combat contract into stats. TeamBattle uses that
snapshot, never the current catalogue, during a pending run. Pre-contract snapshots
use frozen compatibility defaults for the original four heroes. Snapshot validation
rejects malformed contracts. Legacy singleton BattleModel stays unchanged.

## Save compatibility and migration plan

Schema stays v12: there is no new ownership or Bond state and no roster expansion
in this change. Existing v2–v11 migrations, corrupt/future read-only handling,
backups, UID gear, seeds and pending snapshots remain intact. Opening Gallery,
filtering, showcase, closing/skip/replay never commits progress.

A successful summon atomically adds optional `recruitment.last_batch` with
`end_count` and 1 or 10 deep-copied entries from committed history. Old v12 files
without it load normally and have replay disabled. It is written in the same
transaction as cost/RNG/pity/rewards, so failed writes do not expose a new batch.
Validation requires it to match the latest history exactly. Replay reads this
record after reload; it never calls summon or grants rewards. It restarts the
presentation rather than persisting an animation cursor. Older batches remain
available in history. Only the latest batch is retained for replay.

Before expanding the roster or adding Bond, a dedicated migration must:

1. Validate the full source save against its source roster/schema before conversion.
2. Keep eira/ryn/mira/lyra IDs and all legacy stage IDs; map Hxx planning IDs
   explicitly. Runtime names for other heroes remain subject to implementation review.
3. Add level-1/skills/equipment/build/fragments/awakening defaults for new hero IDs
   without adding ownership, spending currency or granting starter gear to old saves.
4. Extend optional training/evolution/outfit maps only if those maps already exist;
   preserve all existing values, gear UIDs, pool counters/history and claims.
5. Preserve pending snapshots byte-for-value; apply new data only to new runs.
6. Version the migration and validate the complete candidate before atomic commit;
   preserve original/backup/future/corrupt files. Exercise all supported source versions.

Catalogue-driven Recruitment/HeroEvolution/Wardrobe defaults are prepared for an
expanded roster, but adding catalogue rows alone is not a migration. This patch
intentionally does not claim the remaining 20 heroes can be imported safely yet.

## Gallery visual refresh — 2026-11-08

The Gallery now uses a navy panel, warm gold borders, four-column portrait cards,
a live owned/total counter and horizontally scrollable affinity tabs derived from
runtime heroes. Owned heroes have gold borders; locked portraits are dimmed and
labeled, but remain clickable for preview. The Details control switches to a
2-column view with combat roles. Ownership/role filters combine with affinity;
Reset filters restores all three. Empty results have an explicit message.

The card area uses the existing SwipeScroll; filters and navigation stay outside
it. The four existing canonical banner textures are cropped at draw time without
modifying source artwork. Actual catalogue order, ownership, acquisition sources
and showcase/details routing are preserved. No planned heroes, rate-up banner,
Bond state or ownership rewards are added. The current total is 4, not the planned
24. Tests use 20 extra fixture rows only to verify a 24-entry scroll and then
restore the real catalogue; this is not runtime content or device performance QA.
Native touch gestures over cards are checked for inner scrolling and canceled
preview clicks. Synthetic input converts viewport positions with the window screen
transform, so scaled desktop windows receive the intended gesture coordinates.

Gallery refresh validation: `collection_ui`, `swipe_scroll`, `english_ui`,
`ui_flow`, `animation_gallery` and `hero_contract` pass on Godot 4.6.3/Linux/X11,
plus resource/link and English/font validators. Compact, detailed, empty and
24-entry scroll captures were reviewed under ignored `work/checks/collection_ui/`.
Physical phone touch, texture RAM, FPS and heat remain unverified.

## V2 Showcase / Reveal handoff

[UI_DESIGN_V2](UI_DESIGN_V2.md) is the presentation handoff, separate from character
contracts and source artwork. Showcase now has full illustration, right-side tabs,
read-only Information/Skills, guarded Equipment/Wardrobe routing and portrait
navigation. Bond/Story stay locked. Reveal and its summary use V2 panels/controls,
recorded result labels and reduced-motion handling. Home links to Gallery and
Showcase; it never changes formation or avatar when cycling portraits.

## Delivered character previews —0.38 (historical milestone)

Caelan has since been promoted to a playable runtime hero; his duplicate preview entry is removed. See CAELAN_RUNTIME for current behavior. The generic preview mechanism is retained.

Caelan's original illustration is now registered separately for Home/Gallery/
Showcase. Gallery shows4 hero definitions +1 design preview, with a Previews
filter; ownership totals and summon pools remain based on the four playable hero
definitions. Preview entries have no management/skill actions or invented stats.
See [cleanup and update guide](CLEANUP_0_38.md).

## Player flow

Heroes → Gallery opens the current four-hero collection. Filter by affinity,
role and owned/locked state. Showcase displays canonical artwork and real current
acquisition sources; Hero details returns to the existing management screen.
Locked heroes remain inspectable, with mutations guarded by existing ownership.
There is no invented biography, Bond reward, favorite grant or placeholder hero.

Gold x1, gold x10 and ticket summons all use the same committed-results reveal.
Next advances the copied batch, Skip opens its scrollable summary. Replay latest
results on the summon screen works after restart. History remains a separate,
silent view. No reveal or replay invokes RNG or spends resources.

## Verification

`hero_contract` covers v12 roundtrip, old/new pending seeded-combat equivalence,
invalid contract/snapshot rejection and durable batch validation.
`collection_ui` covers combined filters, locked showcase, read-only browsing,
skip/close/reload/replay with exact profile equality and render captures.
`summon_batch` checks x10 equals ten singles for all economy and RNG state;
only the deliberately different latest-batch presentation record is compared separately.
Use existing migration, recruitment, supplies, character and team suites as regressions.
Real Android touch/performance testing remains required.
