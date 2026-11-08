# Arena · hero exhibition · 0.41.0

Open **Dungeons → Arena · AI vs AI**. This is a local graphics/practice mode,
separate from campaign runs, dungeon rewards, ownership and saved formation.

- Pick 1–4 distinct runtime heroes for each side. A hero may appear on both sides.
  All five runtime heroes can be previewed, including unowned heroes; previews
  such as Selena are not silently made playable.
- Current hero builds supply stats, weapons, outfits and skill kits. Practice HP
  can be multiplied by 1/3/5 (default 3) only inside the exhibition. This does not
  change character progression. No spirits or consumables are used.
- Enable full starting Energy to inspect Ultimates quickly. Both sides use AI;
  Start/Pause/Resume, x1/x2, Replay and Setup are available. Seeded replays use the
  same initial builds and options while those inputs remain unchanged.
- A match ends on elimination or a 180-second draw. No fees, rewards, drops,
  achievements, missions or settlement are issued. Setup survives navigation in
  RAM; leaving the page discards the current exhibition.

`ArenaLabScreen` is page25 and owns its `ArenaExhibition`, never `game.battle`.
Existing campaign battles pause through normal navigation and resume normally.
The exhibition never calls `begin_run`, `settle`, unlock or commit. Read-only or
pending profiles can still be viewed safely because no profile mutation is made.

`ArenaExhibition` reuses movement/AI, action markers and hero skill behavior from
TacticalArenaBattle/TeamBattle for both sides. Hero defenses, shields, healing,
energy and ranged projectile collisions are simulated. This exhibition is for
presentation, not a PvP balance benchmark: it has separate hero-versus-hero damage
routing, no stage armor/Boss rules, spirits, or equipment burn/mark procs. Campaign
combat and save/team snapshot versions are unchanged.

The original generated background is `art/arena/celestial_courtyard.png`, copied
byte-for-byte with its SHA256 and generation brief in `provenance.json`. No text,
characters or controls are baked into the art. The renderer uses existing hero
PNGs, weapon/grip transforms and existing effect textures; it does not resolve
hits or consume combat RNG. Settings control damage numbers/reduced effects.
The existing ElevenLabs cues play without generation or new paid requests.

Verification: `arena_exhibition` covers 1v1, 4v4, mirror matches, termination,
seed/x2 consistency, invalid selections, HP/position bounds and unchanged profile
bytes. `arena_lab_ui` covers entry, setup, rendered courtyard/4v4, pause/speed,
render immutability and campaign isolation. Also run dungeon_world, arena_tactics,
arena_battle, team_ui, team_flow, ui_flow and audio. Outputs stay in work/checks.
Desktop rendering does not establish real-phone touch/FPS or final combat balance.
