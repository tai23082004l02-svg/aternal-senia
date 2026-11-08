# Caelan playable integration · 0.38.0 / save v13

Implemented after the owner explicitly requested applying the character design to
the game. Existing UI V2/Home/Gallery/Showcase/Reveal and four-hero formation are
retained; changes to presentation are limited to the new art adapter, recruit action
and bounded fifth-hero controls. No character source PNG was changed.

## Play now

Clear **Forest Entrance** (stage1), open **Heroes → Gallery → Caelan**, then
**Recruit Caelan · Free** in the existing Showcase. Confirm recruitment. It adds
ownership atomically and plays the existing reveal. It never auto-assigns formation,
changes wallet/pity/history or mints equipment. Repeat recruitment, failed writes,
pending and read-only profiles cannot grant him again. Caelan is excluded from the
Standard Summon pool, preserving all existing odds, prices and pity.

Caelan can be selected in the existing four-hero Formation, equipped with existing
sword-class gear, leveled, trained, awakened/evolved, assigned an outfit/avatar and
viewed on Home. Earn **2 Caelan Fragments** for winning **Dawn Triad (103)** with
Caelan in the saved squad. The source appears on Awakening; actual gains appear
in victory rewards. It is part of the same run-ID-protected atomic settlement:
losses, retrying a failed save and settling twice do not duplicate fragments.

## Implemented combat

| Hero | New-run behavior |
| --- | --- |
|Caelan|Base HP285 / ATK17 / DEF6 / crit8%;12% personal damage reduction. **Shield Line** every5.5s before weapon cooldown scaling: strike at125% ATK × existing skill scaling, shield the living ally with lowest HP ratio for14% max HP /5s. **Unbroken Dawn** at100 Energy:22% max-HP shield /6s for every living ally. **Dawnward**: while alive in front slot0 or1, other allies take12% less damage.|
|Ryn|Existing stats, crit,10% damage reduction and AoE/self-shield Ultimate remain. **Ember Guard** adds8% max-HP self shield /4s to her basic skill.|
|Lyra|Existing stats/+8% skill multiplier remain. **Flare Thrust** cooldown4.3s before weapon scaling. Direct non-spirit/non-DoT hits gain35% damage below30% target HP. **Twilight Comet** is440% ATK × skill scaling against one living foe with lowest HP ratio, with no self heal.|

Shields use max(current,new), not additive stacking, and do not revive dead heroes.
Kit fields are copied into pending snapshots. Old snapshot v1/v2 and singleton
runs retain their old stats/kit; no resnapshot or recalculation happens during load.
All damage, shields, targeting, energy and rewards remain in the model. Rendering
reads markers only. No SDK or paid audio generation is introduced.

## Original art integration

`art/caelan/manifest.json` is merged by FrameLibrary; the metadata builder is called
by the complete art pipeline. All16 poses have reviewed region/anchor/hand/grip/
angle metadata and seven animation states. Caelan uses the separate sword prop
through a presentation-only signature override; equipment UID/stat/category remain
those of the actual equipped sword. The blue shield is intrinsic character art,
not another gear slot. Defeat hides the attached sword.

The existing character panel, face icon, Gallery, Showcase and Reveal use the
original illustration with source regions. Caelan's inset adapts his full-body art
to the existing Showcase; existing heroes retain their presentation. The fifth
hero uses the existing horizontal portrait strip. Supplies' hero picker uses a
three-column grid to stay inside the mobile width. Source hashes are verified by
`tools/validate_caelan_art.py`; no source pixels were edited.

## Migration and preservation

Save schema13 keeps `user://first_light_v2.json` and project name. Source v2–v12
passes the former four-hero validation/migration chain before empty Caelan maps are
added. Optional training/evolution/outfit maps extend only when present. His build
starts LV1 /skills[1,1,1], no assigned gear, zero fragments and no ownership until
recruited. All old hero investment, item UIDs, next_uid, currency, summon counters,
history/latest batch, claims, formation and pending snapshots are retained.

Reading does not overwrite the source; the next successful commit preserves its
original bytes as backup. Invalid/future saves stay read-only. Non-neutral Caelan
state unexpectedly present in an old schema is rejected rather than reset.
Current v13 corruption is never repaired by silently adding missing hero data.

## Verification

`caelan` covers source v12 with team snapshot v1/v2 and singleton pending, original
backup bytes, corrupt/future rejection, free recruitment rollback/repeat guards,
actual existing sword equip, four-LV1-hero opening victory, front-row aura, shield
selection/team barrier, Ryn self shield, Lyra single target/no self heal/35% bonus,
fragment reward rollback/idempotency and all16 source regions.
`caelan_ui` renders Gallery, Showcase, recruitment, existing management pages and
four-hero battle/shields. `caelan_gallery` renders every pose with attached sword.
The existing roster, collection, UI V2, save, economy, campaign and combat suites
are regressions. Screenshots/logs stay in ignored work/checks.

Linux/X11/Mesa checks do not establish real Android touch/FPS/thermal performance.
The remaining19 launch heroes and Bond/story systems are not implemented here.
