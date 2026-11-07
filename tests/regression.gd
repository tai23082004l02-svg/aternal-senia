extends SceneTree

const Catalog = preload("res://game/core/catalog.gd")
const Store = preload("res://game/core/progress.gd")
const Battle = preload("res://game/core/battle.gd")
const Frames = preload("res://game/core/frame_library.gd")
var checks := 0
var base := "user://first_light_tests/"

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		push_error("FAIL: " + description)
		quit(1)
		assert(condition, description)

func _initialize() -> void:
	call_deferred("run")

func write(path: String, data: Variant) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func run() -> void:
	var override_dir := OS.get_environment("FIRST_LIGHT_TEST_DIR")
	if not override_dir.is_empty():
		base = override_dir.path_join("")
	DirAccess.make_dir_recursive_absolute(base)
	base += "run_%d_" % Time.get_ticks_usec()
	var book := Catalog.new()
	check(book.errors.is_empty(), "Catalog IDs and drops")
	var store := Store.new(book, base + "save.json")
	check(store.valid(store.profile), "Fresh save is valid")
	check(not store.change_hero("ryn"), "Hero unlock restriction")
	check(not store.begin_run(5), "Stage unlock restriction")
	var p: Dictionary = store.profile.duplicate(true)
	p.gold = 1500
	p.shards = 150
	p.xp = 500
	check(store.commit(p), "Persist fixture")
	store.fail_writes = true
	var original: Dictionary = store.profile.duplicate(true)
	check(not store.upgrade("hero"), "Write failure is reported")
	check(store.profile == original, "Failed upgrade preserves wallet and stats")
	store.fail_writes = false
	check(store.upgrade("hero"), "Hero upgrade")
	check(store.upgrade("skill", 0), "Skill upgrade")
	check(store.upgrade("assist"), "Assist upgrade")
	check(store.forge("sword_2"), "Forge adds UID")
	var sword: String = store.profile.items.back().uid
	check(store.enhance(sword), "Enhance equipment")
	check(store.enhance(sword, true), "Rank up equipment")
	var before_stats: Dictionary = book.stats(store.profile)
	check(store.equip(sword), "Equip compatible weapon")
	check(book.stats(store.profile).atk > before_stats.atk, "Weapon updates derived stats")
	check(not store.dismantle(sword), "Equipped weapon cannot be destroyed")
	check(not store.equip("starter_ryn"), "Wrong category cannot equip")
	check(store.forge("armor_1"), "Forge armor")
	var armor: String = store.profile.items.back().uid
	check(store.equip(armor), "Equip armor")
	check(store.unequip(armor), "Unequip into bag")
	check(store.equip(armor), "Re-equip same UID")
	check(store.dismantle("starter_eira"), "Dismantle unused gear")
	var reloaded := Store.new(book, base + "save.json")
	check(reloaded.profile == store.profile, "Reload preserves inventory and equipment")
	check(store.begin_run(1), "Start run")
	var pending: Dictionary = store.profile.pending.duplicate(true)
	check(not store.upgrade("hero"), "Upgrade locked during run")
	check(not store.equip(armor), "Equipment locked during run")
	check(not store.begin_run(1), "Cannot start second pending run")
	var combat := Battle.new(book)
	combat.start(pending)
	combat.auto_attack = false
	combat.attack_clock = .85
	check(combat.attack(), "Manual combo attack")
	var initial_hp: float = combat.enemy_hp
	combat.advance(.1)
	check(combat.enemy_hp == initial_hp, "Windup applies no early damage")
	combat.advance(.14)
	check(combat.enemy_hp < initial_hp, "Hit marker deals damage")
	var after_hit: float = combat.enemy_hp
	combat.advance(.1)
	check(combat.enemy_hp == after_hit, "Marker damage happens once")
	combat.paused = true
	var paused_time: float = combat.time
	combat.advance(.2)
	check(combat.time == paused_time, "Pause stops simulation")
	combat.paused = false
	combat.advance(.25)
	check(combat.skill(0), "Skill starts")
	check(not combat.skill(0), "Skill cannot repeat in cooldown")
	var a := Battle.new(book)
	var b := Battle.new(book)
	a.start(pending)
	b.start(pending)
	b.speed = 3
	for i in range(180):
		a.advance(1.0 / 60)
	for i in range(60):
		b.advance(1.0 / 60)
	check(is_equal_approx(a.hp, b.hp) and is_equal_approx(a.enemy_hp, b.enemy_hp) and a.wave == b.wave, "x3 preserves fixed-step result")
	var live := Battle.new(book)
	live.start(pending)
	for i in range(18000):
		if live.enemy_clock > 2.45:
			live.guard()
		if live.hp < live.stats.hp * .65:
			live.skill(1)
		else:
			live.skill(2)
			live.skill(0)
		live.advance(1.0 / 60)
		if live.state != "battle":
			break
	check(live.state == "won", "Playable three-wave battle can be won")
	check(live.kills == 3, "One kill per enemy")
	store.fail_writes = true
	var gold_before: float = store.profile.gold
	check(not store.settle(pending.id, true, live.kills), "Reward write failure")
	check(not store.profile.pending.is_empty() and store.profile.gold == gold_before, "Pending reward is retryable")
	store.fail_writes = false
	check(store.settle(pending.id, true, live.kills), "Reward settles")
	var gold_after: float = store.profile.gold
	var bag_after: int = store.profile.items.size()
	check(store.settle(pending.id, true, live.kills), "Repeated settle returns success")
	check(store.profile.gold == gold_after and store.profile.items.size() == bag_after, "No duplicate gold or loot")
	check(store.available_hero("ryn"), "Victory unlocks second hero")
	check(store.claim_quest("first"), "Quest reward")
	check(not store.claim_quest("first"), "Quest reward cannot repeat")
	check(store.change_hero("ryn") and store.change_assist("ash"), "Change unlocked hero and assist")
	check(store.mark_story("1_before"), "Story flag persists")
	check(store.setting("speed", 3) and store.setting("sound", false), "Settings persist")
	var now: int = store.profile.last_offline + 9000
	check(store.offline_preview(now) == 480, "Offline cap is two hours at stage 2")
	check(store.offline_preview(store.profile.last_offline - 90) == 0, "Backwards clock gives no reward")
	check(store.claim_offline(now), "Claim offline")
	check(not store.claim_offline(now), "Offline cannot double claim same timestamp")
	p = store.profile.duplicate(true)
	while p.items.size() < Store.BAG_CAP:
		store._add_item(p, "armor_1")
	check(store.commit(p), "Fill bag")
	check(store.begin_run(1), "Replay run")
	var shards_before: float = store.profile.shards
	check(store.settle(store.profile.pending.id, true, 3), "Full bag victory")
	check(store.profile.items.size() == Store.BAG_CAP and store.profile.shards == shards_before + 5, "Overflow converts loot, no lost reward")
	var bad: Dictionary = store.profile.duplicate(true)
	bad.items.append(bad.items[0].duplicate())
	check(not store.valid(bad), "Reject duplicate item UIDs")
	bad = store.profile.duplicate(true)
	bad.heroes.eira.equipment.weapon = "missing"
	check(not store.valid(bad), "Reject missing equipped UID")
	# Legacy migration is isolated from the player profile.
	var migration_dir := base + "legacy/"
	DirAccess.make_dir_recursive_absolute(migration_dir)
	write(migration_dir + "first_light_v1.json", {"version": 1, "gold": 123, "level": 4})
	var migrated := Store.new(book, migration_dir + "first_light_v2.json")
	check(migrated.profile.gold == 123 and migrated.profile.heroes.eira.level == 4, "v1 migration preserves wallet and level")
	check(FileAccess.file_exists(migration_dir + "first_light_v1.json"), "Original v1 file retained")
	write(base + "future.json", {"version": 99})
	var future := Store.new(book, base + "future.json")
	check(future.read_only and not future.commit(future.profile), "Future save is never overwritten")
	write(base + "broken.json", {"broken": true})
	var broken := Store.new(book, base + "broken.json")
	check(broken.read_only, "Corrupt save without backup is preserved")
	write(base + "recover.json", {"broken": true})
	write(base + "recover.json.bak", store.profile)
	var recovered := Store.new(book, base + "recover.json")
	check(not recovered.read_only and recovered.profile.gold == store.profile.gold, "Valid backup recovers corrupt save")
	var library := Frames.new()
	for hero in book.data.heroes:
		for state in ["idle", "run", "attack", "skill", "hurt", "death"]:
			var frame: Dictionary = library.frame_at(hero.id, state, 200.0)
			check(frame.has("hand") and library.textures.has(frame.file), "Frame manifest resolves " + hero.id + " / " + state)
	print("PASS: %d checks — combat, progression, inventory, persistence, migration, animation" % checks)
	quit()
