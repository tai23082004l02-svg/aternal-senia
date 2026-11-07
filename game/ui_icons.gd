class_name UIIcons
extends RefCounted

var manifest: Dictionary
var sources: Dictionary = {}
var textures: Dictionary = {}

func _init() -> void:
	manifest = JSON.parse_string(FileAccess.get_file_as_string("res://art/icons/manifest.json"))
	for key in manifest.regions:
		var spec: Dictionary = manifest.regions[key]
		if not sources.has(spec.atlas): sources[spec.atlas] = load("res://art/" + spec.atlas)
		var texture := AtlasTexture.new()
		texture.atlas = sources[spec.atlas]
		texture.region = Rect2(spec.region[0], spec.region[1], spec.region[2], spec.region[3])
		texture.filter_clip = true
		textures[key] = texture
	for key in manifest.aliases: textures[key] = textures[manifest.aliases[key]]

func apply(button: Button, key: String, width: int = 28) -> void:
	button.tooltip_text = button.text
	button.icon = textures[key]
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width", width)
	button.clip_text = true
	button.add_theme_constant_override("h_separation", 6)
	button.add_theme_color_override("icon_disabled_color", Color(.55, .61, .64, .5))
	button.add_theme_color_override("icon_focus_color", Color("ffe2a4"))

func tab(button: Button, key: String) -> void:
	var title := button.text
	button.tooltip_text = title
	button.text = ""
	button.custom_minimum_size = Vector2(93, 56)
	button.size = Vector2(93, 56)
	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.texture = textures[key]
	icon.position = Vector2(31, 3)
	icon.size = Vector2(31, 31)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(icon)
	var label := Label.new()
	label.text = title
	label.position = Vector2(0, 33)
	label.size = Vector2(93, 19)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(label)

func action(button: Button, callback: Callable) -> void:
	var key := ""
	var method := callback.get_method()
	var args := callback.get_bound_arguments()
	if method == "_select_tab" and not args.is_empty():
		key = {0: "journey", 1: "hero", 2: "equipment", 3: "quest", 4: "settings", 5: "journey", 6: "talents", 7: "companion", 8: "achievement", 9: "training", 10: "boss", 11: "summon", 12: "training", 13: "companion", 15: "journey", 16: "journal", 19: "forge", 20: "gold", 21: "boss"}.get(args[0], "")
	elif method == "_upgrade" and not args.is_empty():
		key = {"hero": "training", "skill": "talents", "assist": "companion"}.get(args[0], "")
	else:
		key = {"_hero": "hero", "_assist": "companion", "_equip": "equipment", "_unequip": "equipment", "_item_detail": "equipment", "_enhance": "crystal", "_forge": "forge", "_dismantle_confirm": "forge", "_quest": "quest", "_offline": "gold", "_talent": "talents", "_rank_assist": "companion", "_achievement": "quest", "_choose_stage": "journey", "_enter_stage": "journey", "_train_attribute": "training", "_reset_attributes": "training", "_replay_story": "journal"}.get(method, "")
	if not key.is_empty():
		apply(button, key)
	elif method in ["_character_level", "_batch_level", "_train_attribute", "_reset_attributes"]:
		apply(button, "training", 22)
	elif method in ["_character_stars", "_awaken"]:
		apply(button, "awakening", 22)
	elif method == "_character_evolve":
		apply(button, "evolution", 22)
	elif method in ["_character_talent", "_character_skill_level", "_spirit_talent"]:
		apply(button, "talents", 22)
	elif method in ["_apply_character_outfit", "_preview_character_outfit"]:
		apply(button, "wardrobe", 22)
	elif method in ["_character_equip", "_character_unequip"]:
		apply(button, "equipment", 22)
