class_name FrameLibrary
extends RefCounted

var manifest: Dictionary
var painted: Dictionary
var textures: Dictionary = {}
var sources: Dictionary = {}
var weapon_specs: Dictionary = {}
var enemy_specs: Dictionary = {}

func _init() -> void:
	manifest = JSON.parse_string(FileAccess.get_file_as_string("res://art/clips.json"))
	painted = JSON.parse_string(FileAccess.get_file_as_string("res://art/painted/manifest.json"))
	for hero in painted.heroes:
		manifest.heroes[hero] = painted.heroes[hero]
	for hero in manifest.heroes:
		for clip in manifest.heroes[hero].values():
			for frame in clip.frames:
				if not textures.has(frame.file):
					textures[frame.file] = _region(frame.atlas, frame.region) if frame.has("atlas") else _source(frame.file)
	for type in ["sword", "spear", "staff"]:
		for rank in [1, 2]:
			var key := "%s_%d.svg" % [type, rank]
			textures[key] = _source(key)
	for weapon in painted.weapons:
		weapon_specs[weapon] = painted.weapons[weapon]
		textures[weapon + ".svg"] = _source(painted.weapons[weapon].file)
	for key in ["slime", "wolf", "golem", "guardian", "bird"]:
		textures["enemy_" + key] = _source("enemy_" + key + ".svg")
	for key in painted.enemies:
		var spec: Dictionary = painted.enemies[key]
		enemy_specs[key] = spec
		textures["enemy_" + key] = _region(spec.atlas, spec.region)
	for key in ["forest", "ruins", "lake", "mountain", "tower"]:
		textures["bg_" + key] = _source("bg_" + key + ".svg")
	for key in painted.backgrounds:
		textures["bg_" + key] = _source(painted.backgrounds[key])
	for key in painted.companions:
		textures["companion_" + key] = _source(painted.companions[key])

func _source(path: String) -> Texture2D:
	if not sources.has(path):
		sources[path] = load("res://art/" + path)
	return sources[path]

func _region(path: String, rect: Array) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = _source(path)
	atlas.region = Rect2(rect[0], rect[1], rect[2], rect[3])
	atlas.filter_clip = true
	return atlas

func frame_at(hero: String, state: String, elapsed: float) -> Dictionary:
	var clip: Dictionary = manifest.heroes[hero].get(state, manifest.heroes[hero].idle)
	var duration := 0.0
	for frame in clip.frames:
		duration += frame.duration
	var cursor := fmod(maxf(0, elapsed), duration) if clip.loop else minf(maxf(0, elapsed), duration - .00001)
	for frame in clip.frames:
		if cursor < frame.duration:
			return frame
		cursor -= frame.duration
	return clip.frames.back()

# Shared by runtime, portrait and review tools so sockets use one transform.
# No simulation commands or damage are called by this renderer.
func draw_actor(canvas: CanvasItem, frame: Dictionary, foot: Vector2, weapon: String, tint: Color = Color.WHITE, show_weapon: bool = true, scale_override: float = -1) -> void:
	var size_data: Array = frame.get("size", [192, 240])
	var anchor_data: Array = frame.get("anchor", [96, 216])
	var dimensions := Vector2(size_data[0], size_data[1])
	var anchor := Vector2(anchor_data[0], anchor_data[1])
	var factor: float = frame.get("render_scale", .88) if scale_override < 0 else scale_override
	var origin := foot - anchor * factor
	canvas.draw_texture_rect(textures[frame.file], Rect2(origin, dimensions * factor), false, tint)
	if not show_weapon:
		return
	var hand := foot + (Vector2(frame.hand[0], frame.hand[1]) - anchor) * factor
	var spec: Dictionary = weapon_specs.get(weapon, {"anchor": [32, 128], "scale": 1, "tint": [1, 1, 1, 1]})
	var weapon_factor: float = factor * spec.scale
	var color: Array = spec.tint
	canvas.draw_set_transform(hand, deg_to_rad(frame.angle), Vector2.ONE * weapon_factor)
	canvas.draw_texture(textures[weapon + ".svg"], -Vector2(spec.anchor[0], spec.anchor[1]), Color(color[0], color[1], color[2], color[3]) * tint)
	canvas.draw_set_transform(Vector2.ZERO)
	if frame.has("grip_rect"):
		var grip: Array = frame.grip_rect
		var region := Rect2(grip[0], grip[1], grip[2], grip[3])
		canvas.draw_texture_rect_region(textures[frame.file], Rect2(origin + region.position * factor, region.size * factor), region, tint)
