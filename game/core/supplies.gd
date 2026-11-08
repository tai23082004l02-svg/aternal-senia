class_name Supplies
extends RefCounted
## Stackable items have their own ledger; never enter equipment/fragment pools.
const ORDER := ["forge_stone","memory_shard","ancient_seed","normal_ticket","material_chest","rage_potion","ward_potion","afk_hourglass"]
const NAMES := {"forge_stone":"Đá Rèn Sáng","memory_shard":"Mảnh Ký Ức","ancient_seed":"Hạt Giống Cổ Thụ","normal_ticket":"Vé Triệu Hồi Thường","material_chest":"Rương Lựa Chọn Nguyên Liệu","rage_potion":"Thuốc Cuồng Nộ","ward_potion":"Thuốc Hộ Vệ","afk_hourglass":"Đồng Hồ Cát AFK"}
const GROUPS := {"forge_stone":"upgrade","memory_shard":"upgrade","ancient_seed":"spirit","normal_ticket":"ticket","material_chest":"ticket","rage_potion":"consumable","ward_potion":"consumable","afk_hourglass":"consumable"}
const SUPPORT := ["rage_potion","ward_potion"]
const SHOP := {"rage_potion":60,"ward_potion":60}
const CHEST := {"forge_stone":3,"memory_shard":2,"ancient_seed":3}
const DROPS := {101:{"ancient_seed":1},102:{"memory_shard":2},103:{"forge_stone":2}}
const MILESTONES := {"story_1":{"stage":1,"item":"material_chest"},"story_2":{"stage":2,"item":"normal_ticket"},"story_3":{"stage":3,"item":"afk_hourglass"}}
static var atlas: Texture2D
static var icon_regions: Dictionary = {}

static func fresh() -> Dictionary:
	var counts := {}
	for id in ORDER: counts[id] = 0
	return {"counts":counts,"selected":"","claimed":[]}

static func valid(store, value: Variant) -> bool:
	if not value is Dictionary or not value.get("counts") is Dictionary or value.counts.size()!=ORDER.size(): return false
	for id in ORDER:
		if not store._whole(value.counts.get(id),0,1e12): return false
	if value.get("selected") not in [""]+SUPPORT: return false
	if value.selected != "" and value.counts[value.selected]<1: return false
	if not value.get("claimed") is Array or not Expansion.unique(value.claimed): return false
	for id in value.claimed:
		if id not in MILESTONES: return false
	return true

static func valid_run(store, run: Dictionary) -> bool:
	if not run.has("support"): return true
	var support = run.support
	return support is Dictionary and support.get("id") in SUPPORT and store._number(support.get("multiplier"),1.1,1.1) and run.has("team")

static func count(p: Dictionary, id: String) -> int:
	return int(p.get("supplies",fresh()).counts.get(id,0))

static func icon(id: String) -> AtlasTexture:
	if atlas == null:
		atlas = load("res://art/supplies/icons.png")
		icon_regions = JSON.parse_string(FileAccess.get_file_as_string("res://art/icons/manifest.json")).regions
	var region: Array = icon_regions[id].region
	var texture := AtlasTexture.new()
	texture.atlas = atlas
	texture.region = Rect2(region[0],region[1],region[2],region[3])
	texture.filter_clip = true
	return texture

static func busy(store) -> bool:
	return store.read_only or not store.profile.pending.is_empty()

static func buy(store, id: String) -> bool:
	if busy(store) or id not in SHOP or store.profile.gold<SHOP[id]: return false
	var p: Dictionary = store.profile.duplicate(true)
	p.gold -= SHOP[id]
	p.supplies.counts[id] += 1
	return store.commit(p)

static func claim(store, id: String) -> bool:
	if busy(store) or id not in MILESTONES or id in store.profile.supplies.claimed: return false
	var row: Dictionary = MILESTONES[id]
	if row.stage not in store.profile.cleared: return false
	var p: Dictionary = store.profile.duplicate(true)
	p.supplies.counts[row.item] += 1
	p.supplies.claimed.append(id)
	return store.commit(p)

static func open_chest(store, choice: String) -> bool:
	if busy(store) or choice not in CHEST or count(store.profile,"material_chest")<1: return false
	var p: Dictionary = store.profile.duplicate(true)
	p.supplies.counts.material_chest -= 1
	p.supplies.counts[choice] += CHEST[choice]
	return store.commit(p)

static func train(store, hero: String, index: int) -> bool:
	if busy(store) or not store.available_hero(hero) or index not in [0,1]: return false
	var level: int = store.profile.heroes[hero].skills[index]
	if level>=10 or count(store.profile,"memory_shard")<level: return false
	var p: Dictionary = store.profile.duplicate(true)
	p.supplies.counts.memory_shard -= level
	p.heroes[hero].skills[index] += 1
	return store.commit(p)

static func refine_seed(store) -> bool:
	if busy(store) or count(store.profile,"ancient_seed")<3: return false
	var p: Dictionary = store.profile.duplicate(true)
	p.supplies.counts.ancient_seed -= 3
	p.expansion.cores += 1
	return store.commit(p)

static func hourglass(store) -> bool:
	if busy(store) or count(store.profile,"afk_hourglass")<1: return false
	var p: Dictionary = store.profile.duplicate(true)
	p.supplies.counts.afk_hourglass -= 1
	p.gold += store.offline_amount(7200)
	# This accelerates2h; leave the real idle-time pool/cursor untouched.
	MissionBoard.record(p,"offline")
	return store.commit(p)

static func select_support(store, id: String) -> bool:
	if busy(store) or id not in [""]+SUPPORT or (id!="" and count(store.profile,id)<1): return false
	var p: Dictionary = store.profile.duplicate(true)
	p.supplies.selected = id
	return store.commit(p)

static func prepare(p: Dictionary) -> bool:
	var id: String = p.supplies.selected
	if id=="": return true
	if id not in SUPPORT or p.supplies.counts[id]<1: return false
	var key := "atk" if id=="rage_potion" else "defense"
	for unit in p.pending.team.units: unit.stats[key] *= 1.1
	p.pending.stats = p.pending.team.units[0].stats.duplicate(true)
	p.pending.support = {"id":id,"multiplier":1.1}
	p.supplies.counts[id] -= 1
	# One chosen run only: auto-next/replay must not silently spend stock.
	p.supplies.selected = ""
	return true

static func award(p: Dictionary, stage: int) -> void:
	for id in DROPS.get(stage,{}):
		p.supplies.counts[id] += DROPS[stage][id]

static func hint(p: Dictionary) -> String:
	var id: String = p.supplies.selected
	return "" if id=="" else "\n\nVật phẩm chuẩn bị: "+NAMES[id]+" ×1. Tiêu hao khi bắt đầu; chỉ áp dụng một lượt, kể cả thua. Tải lại trận không trừ thêm."
