# Local admin unlock code

Implemented at the owner's request in 0.39.1. Open **More → Redeem Gift Code**,
enter **admin**, choose **Redeem**, review the grant, then choose **Unlock all**.
Input is case-insensitive and ignores leading/trailing whitespace. Canceling the
confirmation changes nothing. The code is local and available in this build;
this is not a server authorization system or a payment entitlement.

One successful redemption per save grants the currently implemented content:

- All five runtime heroes, including Caelan, and both spirits.
- Hero level100, three skill levels10, awakening5 and evolution3. Hero fragments
  reach at least10,000; all existing talent branches become learned. Allocated
  attribute points are retained; leveling makes remaining points available.
- Spirit level20, rank3, skill level10, both branches and both advanced branches
  learned. Active build selections remain unchanged; spirit fragments reach10,000.
- All18 runtime stages are marked cleared, allowing their gated routes and story
  journal content. No fabricated challenge scores or leaderboard records are made.
- At least1,000,000 each of Gold, Crystals and XP, and10,000 Cores and each of the
  eight supplies. Existing larger balances are preserved.
- Each of44 equipment base types is discovered and represented in Bag or Unclaimed
  Loot. Existing UID/base/equipment assignments remain intact; gear in Bag is
  upgraded to+15/rank3. Missing types fill free Bag slots, then the existing
  Unclaimed Loot queue. Queued items use normal claim rules and arrive at+0/rank1.
  The40-item Bag and128-entry queue limits are unchanged. Insufficient total space
  rejects the whole grant, allowing retry after clearing space.

Hero/assist selection, formation, active branches, outfits, identity, settings,
transactions, recruitment seed/pity/history, settlement and claimed rewards are
preserved. An implicit old formation is materialized before unlocking new heroes
so it does not fill itself from the newly owned roster.

Selena remains a design preview. Bond, character-story gameplay, unconfigured
premium/event banners, unfinished dungeons, payments, ads and server services stay
unavailable. This code cannot turn design-only assets into implemented gameplay.

## Save and validation

Save schema remains v13. Optional `redeemed_codes: ["admin"]` is validated and
committed in the same transaction as the grant. Old saves without the field remain
valid. Repeated redemption after reload is rejected. Pending battles and read-only
saves are rejected in the model as well as disabled in the UI. The existing
validate/write/verify/backup/rename transaction owns persistence; a failed save
changes neither RAM grants nor the redemption marker. No automatic redemption
occurs on startup or when viewing the input dialog.

Tests: `admin_unlock` covers content, caps, UID/formation/history preservation,
reload/repeat, invalid marker/code, pending/read-only/full-capacity rejection and
write-failure rollback. `admin_unlock_ui` covers entry, confirmation/cancel,
success/repeat and disabled pending/read-only controls. Render captures remain in
ignored `work/checks/`. Linux UI validation does not establish mobile keyboard or
real-device performance.

Delivery checks: Godot4.6.3 import, repo validator, English validator and16
relevant suites pass: admin_unlock, admin_unlock_ui, utilities_ui, regression,
recruitment, summon_batch, bag_inventory, supplies, unique_collection,
equipment_sets, additional_equipment, settings_ui, team_flow, hero_contract,
supplies_ui and additional_equipment_ui. Entry and confirmation captures were
visually inspected on Linux/X11.
