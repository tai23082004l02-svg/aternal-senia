extends SceneTree

var checks := 0
var failed := false
var book := GameCatalog.new()
var store: ProgressStore
var serial := 0

func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		push_error("FAIL: " + label)
		failed = true

func make_battle(weapon: String = "", variants: Array = [], assist: String = "lumi", rank: int = 1) -> BattleModel:
	serial += 1
	var stats := book.stats(store.profile)
	stats.weapon_trait = weapon
	stats.variants = variants
	stats.assist = assist
	stats.assist_rank = rank
	stats.crit = 0
	var b := BattleModel.new(book)
	b.start({"id": "fixture_%d" % serial, "stage": 2, "seed": 7, "stats": stats})
	b.auto_attack = false
	b.enemy_hp = 10000
	b.enemy_max = 10000
	return b

func step(b: BattleModel, seconds: float) -> void:
	for i in range(ceili(seconds * 60)): b.advance(1.0 / 60)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var dir := "user://first_light_tests/expansion_%d/" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(dir)
	store = ProgressStore.new(book, dir + "save.json")
	check(book.errors.is_empty() and book.data.stages.size() == 18, "18 stages validated")
	check(not store.can_enter(6) and not store.can_enter(101), "Branches and trial locked")
	check(not Expansion.talent(store, "focus"), "Talent level and cost gate")
	var p := store.profile.duplicate(true)
	p.gold = 10000
	p.shards = 100
	p.xp = 10000
	p.heroes.eira.level = 4
	p.cleared = [1, 2, 3, 4, 5]
	p.assists.lumi = 6
	p.assists.ash = 6
	p.expansion.cores = 20
	check(store.commit(p), "Valid extended fixture")
	store.fail_writes = true
	var original := store.profile.duplicate(true)
	check(not Expansion.talent(store, "focus") and not Expansion.rank_up(store), "Failed writes rejected")
	check(store.profile == original, "Failed writes preserve all resources")
	store.fail_writes = false
	check(Expansion.talent(store, "focus"), "Learn first branch")
	var gold: int = store.profile.gold
	check(Expansion.talent(store, "breaker"), "Learn alternate branch")
	check(store.profile.expansion.builds.eira.selected[0] == "breaker", "Mutually exclusive branch")
	check(Expansion.talent(store, "focus") and store.profile.gold == gold - 40, "Free reselection after learning")
	check(Expansion.rank_up(store) and Expansion.rank_up(store), "Companion rank two and three")
	check(not Expansion.rank_up(store), "Rank cap")
	check(store.begin_run(6), "First route opens from chapter")
	check(not Expansion.talent(store, "focus") and not Expansion.rank_up(store), "Build locked in run")
	var snapshot: Dictionary = store.profile.pending.stats.duplicate(true)
	var reloaded := ProgressStore.new(book, store.path)
	check(reloaded.profile.pending.stats == snapshot, "Snapshot survives reload")
	check(store.settle(store.profile.pending.id, true, 3, 25), "Branch settles")
	check(store.can_enter(7), "Second route opens after first route")
	check(store.unlocked_stage() == 5, "Branch clear does not alter main progression")
	check(store.begin_run(101), "Boss hunt opens")
	var id: String = store.profile.pending.id
	check(store.settle(id, true, 1, 20), "Hunt rewards and score")
	var settled := store.profile.duplicate(true)
	check(store.settle(id, true, 1, 20) and store.profile == settled, "No duplicate cores or score")
	check(store.profile.expansion.records["101"].score == 340, "Score formula")
	check(Expansion.claim(store, "trial_100") and not Expansion.claim(store, "trial_100"), "Milestone claims once")
	var invalid := store.profile.duplicate(true)
	invalid.expansion.builds.eira.selected[0] = "nova"
	check(not store.commit(invalid), "Reject wrong skill slot")
	invalid = store.profile.duplicate(true)
	invalid.expansion.ranks.ash = 4
	check(not store.commit(invalid), "Reject corrupted rank")
	invalid = store.profile.duplicate(true)
	invalid.expansion.records["1"] = {"score": 1, "time": 1}
	check(not store.commit(invalid), "Reject invalid challenge record")
	# Migration retains old pending run; current save path and backup remain stable.
	var legacy := store.profile.duplicate(true)
	legacy.version = 2
	legacy.erase("expansion")
	var file := FileAccess.open(dir + "legacy.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	var migrated := ProgressStore.new(book, dir + "legacy.json")
	check(not migrated.read_only and migrated.profile.version == ProgressStore.VERSION and migrated.profile.gold == legacy.gold, "v2 migration preserves wallet")
	check(migrated.setting("speed", 2) and FileAccess.file_exists(migrated.path + ".bak"), "Migration writes with original backup")
	check(JSON.parse_string(FileAccess.get_file_as_string(migrated.path + ".bak")).version == 2, "Original v2 backup retained")
	check(store.begin_run(101), "Begin migration pending fixture")
	var pending_v2 := store.profile.duplicate(true)
	pending_v2.version = 2
	pending_v2.erase("expansion")
	for key in ["variants", "assist_rank", "weapon_trait"]: pending_v2.pending.stats.erase(key)
	file = FileAccess.open(dir + "pending_v2.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(pending_v2))
	file.close()
	var old_pending := ProgressStore.new(book, dir + "pending_v2.json")
	check(old_pending.profile.pending == pending_v2.pending and not old_pending.read_only, "v2 pending snapshot retained")
	var old_battle := BattleModel.new(book)
	old_battle.start(old_pending.profile.pending)
	check(old_battle.stats.get("variants", []).is_empty(), "Old snapshot gets no new build buffs mid-run")
	check(store.settle(store.profile.pending.id, false, 0, 0), "Abort fixture")
	var cores_before: int = store.profile.expansion.cores
	check(store.begin_run(101), "Begin defeat fixture")
	check(store.settle(store.profile.pending.id, false, 0, 15) and store.profile.expansion.cores == cores_before, "Defeat awards no cores")
	check(store.begin_run(101), "Begin retry fixture")
	var pending_id: String = store.profile.pending.id
	store.fail_writes = true
	original = store.profile.duplicate(true)
	check(not store.settle(pending_id, true, 1, 30) and store.profile == original, "Failed settle preserves pending and wallet")
	store.fail_writes = false
	check(store.settle(pending_id, true, 1, 30), "Retry settles once")
	check(store.profile.expansion.records["101"].score == 340, "Slower run does not lower best score")
	check(store.forge("armor_1"), "New equipment records discovery")
	var uid: String = store.profile.items.back().uid
	check(store.dismantle(uid) and "armor_1" in store.profile.expansion.discovered, "Discovery survives dismantle")
	# Individual combat effects use identical noncritical fixtures.
	var plain := make_battle()
	var focus := make_battle("", ["focus"])
	plain.skill(0); focus.skill(0)
	step(plain, .3); step(focus, .3)
	check(focus.enemy_hp < plain.enemy_hp, "Focus damage")
	var breaker := make_battle("", ["breaker"])
	breaker.wave = 2; breaker._spawn(); breaker.skill(0); step(breaker, .3)
	check(breaker.shield_broken and not breaker.shield, "Slash breaks shield at hit marker")
	var healer := make_battle("", ["restoration"])
	plain = make_battle()
	healer.hp = 1; plain.hp = 1
	healer.skill(1); plain.skill(1); step(healer, .4); step(plain, .4)
	check(healer.hp > plain.hp, "Restoration power")
	var protected := make_battle("", ["barrier"])
	protected.skill(1); step(protected, .4)
	check(protected.barrier > 0, "Heal barrier appears at marker")
	var hp_before: float = protected.hp
	protected._take_damage(10)
	check(protected.hp == hp_before, "Barrier absorbs damage")
	check(protected.events.back().kind == "guard", "Absorbed hit displays block rather than minus zero")
	step(protected, 5.1)
	check(protected.barrier == 0, "Barrier expires")
	var flow := make_battle("", ["flow"])
	flow.skill(2)
	check(flow.sp == 75 and is_equal_approx(flow.cooldowns[2], 9.6), "Flow cost and cooldown")
	var nova := make_battle("", ["nova"])
	plain = make_battle(); nova.skill(2); plain.skill(2)
	step(nova, .55); step(plain, .55)
	check(nova.enemy_hp < plain.enemy_hp, "Nova damage")
	var lumi := make_battle("", [], "lumi", 3)
	lumi.hp = 1; lumi.assist_clock = 4; step(lumi, .02)
	check(lumi.barrier > 0 and lumi.hp > 1, "Lumi evolution grants heal and protection")
	var ash := make_battle("", [], "ash", 3)
	ash.assist_clock = 2.2; step(ash, .02)
	check(ash.marked, "Ash marks after assist hit")
	ash._hit(1, false)
	check(not ash.marked, "Mark consumed once")
	var spring := make_battle("spring")
	spring.sp = 20; spring._hit(1, false)
	check(spring.sp == 22, "Sword SP effect")
	var riposte := make_battle("riposte")
	riposte.guard(); riposte._take_damage(10)
	check(riposte.empowered > 0, "Sword guard empowerment")
	riposte._hit(1, false)
	check(riposte.empowered == 0, "Empowerment consumed once")
	var execute := make_battle("execute")
	plain = make_battle()
	execute.enemy_hp = 20; plain.enemy_hp = 20
	execute._hit(10, false); plain._hit(10, false)
	check(execute.enemy_hp < plain.enemy_hp, "Spear execute")
	var pierce := make_battle("pierce")
	plain = make_battle()
	pierce.shield = true; plain.shield = true
	pierce._hit(10, false); plain._hit(10, false)
	check(pierce.enemy_hp < plain.enemy_hp, "Spear shield penetration")
	var mending := make_battle("mending")
	plain = make_battle(); mending.hp = 1; plain.hp = 1
	mending.skill(1); plain.skill(1); step(mending, .4); step(plain, .4)
	check(mending.hp > plain.hp, "Staff healing")
	var conduit := make_battle("conduit")
	plain = make_battle(); conduit.skill(0); plain.skill(0)
	step(conduit, .3); step(plain, .3)
	check(is_equal_approx(conduit.sp - plain.sp, 4), "Staff refunds once at marker")
	if failed:
		quit(1)
		return
	print("PASS: %d expansion checks: branches, talents, companions, weapons, trials, collection, migration and transactions" % checks)
	quit()
