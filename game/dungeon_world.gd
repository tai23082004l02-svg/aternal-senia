class_name DungeonWorld
extends RefCounted
## Presentation catalogue: future dungeons never enter GameCatalog or a save.
const GROUPS := ["all","resource","tactic","boss","endless","seasonal"]
const LABELS := ["All","Resources","Tactics","Boss","Conquest","Events"]
static var sources: Dictionary = {}
var entries: Array = []

func _init() -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://game/data/dungeon_world.json"))
	if data is Dictionary: entries = data.get("entries",[])

func find(id: String) -> Dictionary:
	for row in entries:
		if row.id == id: return row
	return {}

func filtered(group: String) -> Array:
	if group == "all": return entries
	return entries.filter(func(row): return row.group == group)

static func artwork(index: int, enemy: bool = false) -> AtlasTexture:
	var sheets: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/dungeons/manifest.json"))
	var spec: Dictionary = sheets["enemies" if enemy else "worlds"]
	var path: String = "res://"+spec.file
	if not sources.has(path): sources[path] = load(path)
	var rectangle: Array = spec.regions[index]
	var texture := AtlasTexture.new()
	texture.atlas = sources[path]
	texture.region = Rect2(rectangle[0],rectangle[1],rectangle[2],rectangle[3])
	texture.filter_clip = true
	return texture

static func team_power(game) -> int:
	var result := 0.0
	for id in Formation.state(game.store.profile,game.catalog).slots:
		if id.is_empty(): continue
		var stats: Dictionary = game.catalog.stats(game.store.profile,id)
		result += stats.hp + stats.atk*5 + stats.defense*8
	return roundi(result)
