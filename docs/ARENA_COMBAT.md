# AI Arena combat · 0.40.1

Owner-requested conversion of Aternal Senia combat to a freely moving 2D AI arena,
using the combat approach of the owner's `Live-Youtube-American` / Down Arena.
Implemented in Godot; no JavaScript engine, character art or audio was imported.

## Behavioral presets · 0.40.1

Applied at the owner's request as a practical first pass, ahead of future character
redesign/balance. Upgradeable stats, skill cooldowns, gear and economy stay unchanged.
New team snapshotv4 freezes each hero's AI preset separately from `stats`.

| Hero | Speed / range (arena units) | Aggression | Pursuit | Combo | Counter | Recklessness | Switch | Reaction |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Eira | 120 / 51 | 80 | 80 | 75 | 65 | 55 | 25 | 70 |
| Ryn | 110 / 54 | 70 | 70 | 60 | 65 | 60 | 25 | 65 |
| Lyra | 128 / 51 | 85 | 85 | 75 | 60 | 65 | 30 | 70 |
| Mira | 110 / 170 | 30 | 35 | 50 | 70 | 25 | 25 | 75 |
| Caelan | 104 / 56 | 60 | 60 | 55 | 70 | 45 | 25 | 65 |

Percentages govern decisions, not damage or bonus dodge stats. AI reviews targets
at 0.6-second intervals; manual focus wins. Pursuit creates a brief approach window
after a landed hit. Combo/counter can reduce idle decision waiting, while respecting
active actions and existing skill cooldowns. Counter opportunities follow avoided
or fully absorbed attacks. Low-HP retreat decisions begin below 40% HP. Caelan may
intercept enemies near a wounded ally without forcing aggro or adding defenses.
Movement evasion rolls reaction once per warning with a 4.5-second cooldown; it
never grants invulnerability. Speeds/ranges are scaled for Senia's smaller arena.

Files: `arena_tactics.gd` supplies presets/validation; `tactical_arena_battle.gd`
runs them. `arena_tactics` tests snapshots, unchanged progression stats/cooldowns,
combo/counter/focus, and deterministic speed modes. Historical v3 retains the
original arena rules below. This is not a final balance pass.

## Original v3 player behavior

- Keep up to four owned heroes and one support spirit, existing campaign/dungeon
  encounters, hero kits, equipment stats, summon economy and rewards.
- The two front/two back slots now define **starting positions**, rather than an
  enemy hit order. Enemies chase the nearest living hero. Heroes choose the nearest
  enemy, with a tapped enemy taking priority while it remains alive.
- Melee heroes close to attack range. Staff users keep distance and fire aimed,
  non-homing magic bolts, with travel time and swept collision against enemies.
  Healing/support retains the existing team rules.
- Enemy attacks commit to a ground circle when charged. Only heroes inside the
  circle at the hit marker take the attack. Idle AI can move out, with a 3.5-second
  movement-dodge cooldown; casting heroes finish their action. This movement does
  not grant invulnerability. Existing stat-based evasion remains separate.
- Hero attacks check range again at their hit marker; melee also checks the committed attack direction. Damage Ultimates have a
  235-unit range; support Ultimates retain team coverage. Requesting a ready
  damage Ultimate out of range queues it: the hero approaches and casts in range,
  without spending energy before the cast. Auto Ultimate uses the same rules.
- Existing Boss shield/counter/reinforcements and spirit support remain. An
  established magic bolt may still hit after its caster dies; wave transitions
  and battle end clear outstanding bolts.
- Pause, x1/x2, manual Ultimate, focus targeting, retreat and Auto Advance remain.
  Auto Advance still waits for atomic settlement and stops before important Bosses.

## Implementation and compatibility

`game/core/arena_battle.gd` extends `TeamBattle`. It owns positions, facing,
movement, proximity targeting, crowd separation, warning circles and projectiles.
Simulation uses the existing fixed step of 1/60 second. All positions are logical
feet coordinates within `(48,120)`–`(492,302)` in the existing portrait battlefield.
Speeds and collision/range values live in this versioned simulation, not the view.

`game/team_battle_ui.gd` reads positions, sorts actors by foot Y, renders their
facing/running poses, warnings, bolts and HP/energy bars. Touch targeting reads the
same model positions. Floating numbers keep their hit position. The renderer
never advances positions, resolves damage or consumes combat RNG. Original PNGs
and provenance remain unchanged; `FrameLibrary.draw_actor` adds optional facing
with the same weapon/grip transform.

`Formation.snapshot()` now creates **team snapshot v4**. `main._resume()` selects:

| Pending snapshot | Model |
| --- | --- |
| No team (legacy singleton) | BattleModel |
| Team v1 / v2 | TeamBattle, historical non-spatial behavior |
| Team v3 | ArenaBattle, original arena rules |
| Team v4 | TacticalArenaBattle, frozen per-hero behavioral presets |

Save schema stays **v13**, at `user://first_light_v2.json`. No migration rewrites
pending snapshots, stats, seed, options, potion buffs or encounter data. Resume
continues the existing behavior of restarting from the saved initial run/seed;
it does not persist current arena coordinates or a manual command issued mid-run.
Run identity, atomic entry costs and idempotent settlement are unchanged.

## Verification

- `arena_battle`: approach before damage, out-of-range whiffs, nearest targets and
  focus fallback, area hits/escape, ranged retreat and bolt travel, bounded finite
  positions, seed/x1/x2 equality, pause, settlement and legacy v1/v2 snapshots.
- `team_matrix` now runs ArenaBattle for 108 roster/encounter combinations;
  `team_campaign` runs all 15 Story stages using earned progression.
- `arena_ui`: actual new-run dispatch, rendered combat/warnings, dynamic touch
  targeting, renderer immutability, and v1/v2 resume without save writes.
- Existing `team_battle` retains historical TeamBattle coverage. `team_ui`,
  `team_flow` and `ui_flow` exercise the production route for new runs.

Screenshots/logs belong in ignored `work/checks`. Desktop software-rendered QA
does not establish touch performance, FPS, battery use or balance on a real phone.
The existing directional art is mirrored for facing; this is not newly drawn
eight-direction animation. Broader hero/encounter balance remains future work.
