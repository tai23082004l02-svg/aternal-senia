class_name EquipmentArt
extends Control

var game
var item_id := ""
var rarity := 3
static var frames: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if frames.is_empty():
		var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/equipment/manifest.json"))
		var source: Texture2D = load("res://art/" + manifest.atlas)
		for key in manifest.frames:
			var rect: Array = manifest.frames[key].region
			var region := AtlasTexture.new()
			region.atlas = source
			region.region = Rect2(rect[0], rect[1], rect[2], rect[3])
			region.filter_clip = true
			frames[int(key)] = region
	var border := TextureRect.new()
	border.texture = frames[rarity]
	border.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	border.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(border)
	var icon := TextureRect.new()
	icon.texture = game.icons.textures[item_id]
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.anchor_left = .18
	icon.anchor_top = .18
	icon.anchor_right = .82
	icon.anchor_bottom = .82
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(icon)

static func add_to(parent: Node, owner_game, id: String, tier: int, dimension: int) -> EquipmentArt:
	var art := EquipmentArt.new()
	art.game = owner_game
	art.item_id = id
	art.rarity = tier
	art.custom_minimum_size = Vector2.ONE * dimension
	art.size = Vector2.ONE * dimension
	parent.add_child(art)
	return art
