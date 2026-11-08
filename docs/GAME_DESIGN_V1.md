# Aternal Senia — Game Design V1.0 & Codex Delivery Plan

> OWNER-APPROVED PRODUCT DIRECTION · 2026-11-08 · DESIGN DOCUMENT, NOT RUNTIME
>
> **Read this after `AGENTS.md` and `docs/GAME_STATE.md`, before planning new character/collection work.** The six product decisions in section 1 are approved. All implementation details, tuning numbers, art concepts, schemas and proposed lore below remain proposals pending technical review or owner sign-off. This document **does not authorize Codex to modify gameplay, assets, economy, saves, SDKs or content** without an explicit scoped task.

## 1. Approved decisions — binding product direction

1. **24 launch heroes, 12 male and 12 female.** Use the 24-entry roster from `docs/LAUNCH_CONTENT_MATRIX.md` and `docs/launch/CONTENT_REGISTRY_DRAFT.json` as the planning baseline. Do not silently replace existing hero identities.
2. **Every hero has 5★ base rarity.** Level, awakening, evolution, spirit rarity, gear tiers and summon-pool probability groups are separate concepts. Do not introduce R/SR/SSR/UR tiers for heroes without new approval.
3. **Character Gallery and Summon Reveal are top-priority experiences.** The game's product identity is anime character collection first, accessible idle/auto-battle RPG second.
4. **Add a Bond System.** Design character affinity/progression and unlockable character-centric rewards. Combat bonuses, costs and milestones are NOT approved.
5. **Short, character-centered stories.** Lore supports character identity, relationships, regions and encounters. The canceled `The World That Forgot Tomorrow` is not canon.
6. **Continue on the existing repository and Godot foundation.** No rebuild or new repository by default. Preserve existing runtime behavior until scoped changes pass review.

The earlier **Full Content Launch** decision remains: build and QA internally in increments; do not publicly soft-launch a four-hero game as a gate to producing the approved roster.

## 2. Product pillars and experience

**Working positioning:** Anime Hero Collection Idle Fantasy RPG for English-language Android portrait users, initially targeting the US. Working creative line: *Collect Beauty. Build Legends.* This is a creative proposal, not an approved store tagline.

Primary player loop: **Discover hero → obtain hero → develop bond and identity → build squad and progress → earn collection resources → discover more heroes**.

- Character art and recognizability drive discovery and desire to collect.
- Collection presentation and reveal should feel polished without misleading rarity/odds.
- Combat must remain meaningful: three owned heroes + one spirit, readable skills, role synergy and real rewards.
- All UI text remains English with the packaged typography rules in `docs/ENGLISH_UI.md`.
- Character visuals should have distinctive silhouettes, facial features, costumes, weapons, accent palettes and consistent anime art direction. Follow `docs/CHARACTER_BIBLE.md` for Eira/Ryn/Mira/Lyra; Ryn and Lyra are distinct.

## 3. Launch roster contract

The draft roster, grouped by affinity (planning affinity is NOT proof of runtime support):

| Affinity | Four heroes |
|---|---|
| Light | Eira, Caelan, Selene, Lucien |
| Fire | Ryn, Lyra, Varik, Seraphine |
| Water | Mira, Iona, Eldrin, Kieran |
| Nature | Nara, Fenric, Halden, Orla |
| Storm | Kaia, Zeph, Talos, Aveline |
| Shadow | Vespera, Rook, Orin, Dorian |

Validate exactly **24 unique hero entries and 12/12 gender distribution** against the registry. `Hxx` IDs are planning IDs, NOT runtime/save IDs. Preserve the existing four hero IDs and their canonical identities. The detailed acquisition schedule in the draft matrix is **not yet approved as runtime progression**. Before adding heroes, specify eligibility, weapon renderer, combat ability spec, rewards, UI, ownership and save migration.

**Character art deliverables (proposed acceptance contract):** full illustration, collection card/portrait, face icon, battle action pack (idle/attack/hit/skill/ultimate/defeat as applicable), recognizable weapon, and showcase/reveal presentation. Require concept approval → final illustration approval → in-game asset validation. Establish a quality benchmark with Eira, Ryn and one new hero before mass production. No bulk generation before benchmark approval.

## 4. Character Gallery and Showcase — proposed feature spec

- Show all 24 planned heroes; distinguish **owned / locked** without implying locked heroes are playable.
- Filter by affinity, combat role and ownership; support scrolling/touch, accessibility and mobile portrait.
- Hero detail shows full art, identity, skills, acquisition sources, outfit preview, Bond progress and short biography when data exists.
- Allow choosing a favorite for home-screen display only after explicit confirmation; merely opening/filtering/viewing must not mutate formation, wallet or ownership.
- All unavailable features and acquisition sources must be clearly labeled; no fake playable buttons or fabricated drops.
- Avoid loading all high-resolution portraits simultaneously; measure texture RAM, frame time and device heat.

**Acceptance:** exact 24 entries from validated design data (when approved for runtime), no duplicate IDs, proper locked state, no unintended saves/transactions, English UI, real touch and performance checks.

## 5. Summon Reveal — proposed feature spec

Flow: **request → validate cost/pool → atomic summon commit → present results → optional individual hero reveal → batch summary / continue**.

- Existing `Recruitment` model owns RNG, pity, x1/x10 and transaction; UI effects NEVER generate results or grant items.
- Present new ownership vs duplicate conversion accurately; currently hero/spirit duplicates convert to **10 ID-specific fragments**. Do not change without approved balancing.
- Support skip and x10 summary; interrupted/restarted presentation must never reroll, repay or double-grant rewards.
- Preserve current normal-banner economy (120 gold or one ticket per pull; 20-pull high-group guarantee) until a separate approved simulation/spec changes it. The pool's 70/25/5 groups are not hero rarity tiers.
- Premium/event banners, paid summons and rate-up remain unavailable unless separately specified and implemented with disclosure, secure transactions and store compliance.

**Acceptance:** existing recruitment/summon tests pass; atomicity and rollback on failed writes; skip/close/resume and duplicate tests added; UI correctly reflects committed result.

## 6. Bond System — proposed, not yet balanced

**Design intention:** optional non-combat character attachment, not another mandatory power stat.

Suggested initial design: **five Bond milestones** (proposal, not final numbers): introduction/profile; personal dialogue; short character story; illustration or expression; cosmetic showcase frame/title/effect. Possible XP sources: battle participation, character quest and bounded gifts from real rewards. Do not grant combat buffs or sell Bond XP by default.

**Technical contract to specify before coding:**
- Canonical hero ID keys, ownership guard, max level, XP thresholds and unlock ledger.
- Exactly-once event crediting and reward claims; no repeat grants from replay, resume or settlement retries.
- Save schema migration from v12, including old saves and future/read-only cases; preserve existing `user://first_light_v2.json`, UID, pending snapshots and transaction history.
- UI for locked/owned character state, rewards and story entries.
- Tests for migration, idempotency, tampered data, offline time and duplicate claims.

**Acceptance:** no gameplay stats change without approval; old saves load; rewards/XP cannot be multiplied by restarting or replaying; all claims committed transactionally.

## 7. Narrative and collection identity — proposed creative brief

A short region-linked conflict can provide a shared background, with each hero receiving a motive, at least one meaningful relationship and one memorable character event. The concept of seven regions linked by a broken ancient light is **only a proposal**, NOT approved canon. Avoid lengthy mandatory dialogue; favor brief region opening, character beats and boss payoff. Do not revive the canceled story bible.

Proposed character design contract per hero: planning ID, canonical runtime ID mapping, adult character identity, silhouette, palette, weapon, role, combat kit concept, acquisition, relationships, short narrative beat, art references, production status, asset licensing/provenance and test checklist.

## 8. Related launch content and economy — approval boundaries

The launch matrix proposes **12 spirits, 12 gear sets / 48 set pieces, 7 regions / 84 campaign encounters, 12 bosses and 8 playable dungeons**. These remain **draft production targets**, not automatically approved by the six hero-focused decisions and not implemented content. Current runtime is substantially smaller; consult `docs/GAME_STATE.md` and actual HEAD.

Rewarded ads and IAP must be real, voluntary/verified and store-compliant before release. Cosmetic outfits should not confer combat stats (design recommendation). No unapproved changes to summon odds, pity, shop pricing, VIP, reward grants or paywalls. Model free-player progression, collection completion and resource supply before approving a new economy.

## 9. Implementation roadmap — gated internal work packages

**WP01 — READ-ONLY architecture audit (NEXT TASK):** inspect actual code, data, scenes, test suite, mobile constraints and save/recruitment pipeline. Produce file-level dependencies, reuse/refactor recommendations, risks and questions. **No repo changes.**

**WP02 — Character data contract:** design mapping for 24 heroes, 5★ invariants, affinity validation, skills, acquisition and save migrations. Approval gate before runtime changes.

**WP03 — Visual quality benchmark:** prototype Eira, Ryn and one new hero with complete art/animation/portrait/showcase pipeline; owner approves benchmark before mass production.

**WP04 — Gallery & Showcase:** UI, filters, locked previews, favorite and character detail. Tests for no mutation and mobile performance.

**WP05 — Summon Reveal:** presentation around existing committed recruitment results, skip/x10/resume/duplicates; regression tests for transaction safety.

**WP06 — Bond & short stories:** approved XP/milestones, unlock ledger, migration, UI, narrative and tests.

**WP07 — Full content production:** implement approved roster and remaining launch matrix in internally testable batches, including combat, spirits, gear, regions, bosses and dungeons. Internal slices are NOT public soft launches.

**WP08 — Balance, monetization, Android QA and release:** economy simulation, ads/IAP with real verification, device testing, privacy/store readiness, release candidate.

WP04–WP06 can be planned concurrently after WP02, but merge only after dependencies and migration tests pass. Every WP needs explicit scope, acceptance criteria and owner authorization; this document does not authorize autonomous implementation.

## 10. Engineering invariants and verification

- Engine Godot 4.6.3; current game 0.37.0, save v12 at planning time. Check current HEAD, not just this snapshot.
- Preserve `ProgressStore` migrations, backup, pending runs, deterministic snapshots, equipment UID, ownership and idempotent reward settlement.
- Existing `TeamBattle` supports up to 3 heroes + 1 spirit, up to 4 enemies; legacy `BattleModel` still supports pending singleton saves.
- UI reads model results; renderer/audio do not mutate wallet, RNG, HP or loot.
- Do not import `docs/launch/CONTENT_REGISTRY_DRAFT.json` into `game/data/catalog.json` directly.
- Respect `AGENTS.md`, `docs/SYSTEMS.md`, `docs/TESTING.md` and `docs/CHARACTER_BIBLE.md`.
- Use targeted tests: `recruitment`, `summon_batch`, `summon_ui`, `character_design`, `character_ui`, `wardrobe`, `ui_flow`, `swipe_scroll`, `regression`, `mechanics` and new Bond/migration tests. Run repo validators and Godot import/full suite as appropriate. CI/Linux/Xvfb results do not prove real Android device performance.
- Do not commit generated check outputs, secrets, or user's real save.

## 11. Open decisions requiring owner approval

1. Exact Bond XP curve, milestones, rewards, gift sources and caps.
2. Gallery layout/art benchmark and hero favorite behavior.
3. Summon reveal timing, presentation variants, replay policy and any future banner economics.
4. Ability specification, new affinity interactions and runtime ID mapping for 24 heroes.
5. Canonical region narrative and character relationships.
6. Final production scope for spirits, gear, regions, bosses, dungeons and cosmetics.
7. IAP SKUs, ads placement, disclosures, pricing, verification and launch readiness.

## 12. Codex handoff — next instruction

**Perform WP01 as READ-ONLY.** Read `AGENTS.md`, `docs/GAME_STATE.md`, `docs/SYSTEMS.md`, `docs/INDEX.md`, `docs/TESTING.md`, `docs/CHARACTER_BIBLE.md`, `docs/LAUNCH_CONTENT_MATRIX.md`, `docs/launch/CONTENT_REGISTRY_DRAFT.json` and this file. Inspect actual Godot code and report:
1. Existing modules/scenes to reuse for 24-hero Gallery, Showcase, Summon Reveal and Bond.
2. Modules needing refactoring, exact paths and dependency order.
3. Save v12 migration, summon transaction, performance and asset risks.
4. Schema/API proposals and acceptance tests per WP.
5. All contradictions between proposed design and runtime, with owner decisions required.

**Do not modify, create, delete, commit, push, open PR, change economy, import registry, enable SDKs or claim tests passed without execution. Return the audit only and wait for the next scoped implementation task.**
