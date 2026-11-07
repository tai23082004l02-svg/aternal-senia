class_name FrameLibrary
extends RefCounted

var manifest: Dictionary
var painted: Dictionary
var textures: Dictionary = {}
var sources: Dictionary = {}
var weapon_specs: Dictionary = {}
var enemy_specs: Dictionary = {}
var vfx_manifest: Dictionary

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
	for key in painted.get("portraits", {}):
		textures["portrait_" + key] = _source(painted.portraits[key].file)
		for layer in painted.portraits[key].get("layers", {}):
			textures["portrait_" + key + "_" + layer] = _source(painted.portraits[key].layers[layer])

	for clips in painted.get("guardian_clips", {}).values():
		for frame in clips.frames:
			if not textures.has(frame.file):
				textures[frame.file] = _region(frame.atlas, frame.region)
	vfx_manifest = JSON.parse_string(FileAccess.get_file_as_string("res://art/combat/manifest.json"))
	for key in vfx_manifest.effects:
		textures["fx_" + key] = _region(vfx_manifest.atlas, vfx_manifest.effects[key].region)

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

func clip_length(clip: Dictionary) -> float:
	var duration := 0.0
	for frame in clip.frames:
		duration += frame.duration
	return duration

func sample_clip(clip: Dictionary, elapsed: float, smooth_weapon: bool = false) -> Dictionary:
	var duration := clip_length(clip)
	var cursor := fmod(maxf(0, elapsed), duration) if clip.loop else minf(maxf(0, elapsed), duration - .00001)
	for i in range(clip.frames.size()):
		var frame: Dictionary = clip.frames[i]
		if cursor < frame.duration:
			var result := frame.duplicate()
			if smooth_weapon and frame.has("angle"):
				var next: Dictionary = clip.frames[(i + 1) % clip.frames.size()] if clip.loop or i + 1 < clip.frames.size() else frame
				var phase := smoothstep(0, 1, cursor / frame.duration)
				result.angle = rad_to_deg(lerp_angle(deg_to_rad(frame.angle), deg_to_rad(next.angle), phase))
			return result
		cursor -= frame.duration
	return clip.frames.back()

func motion_frame(hero: String, state: String, elapsed: float, marker: float = -1, action_duration: float = -1) -> Dictionary:
	var clip: Dictionary = manifest.heroes[hero].get(state, manifest.heroes[hero].idle)
	var mapped := elapsed
	if marker > 0 and action_duration > marker and clip.has("hit_time"):
		var length := clip_length(clip)
		if elapsed < marker:
			mapped = elapsed / marker * float(clip.hit_time)
		else:
			mapped = float(clip.hit_time) + (elapsed - marker) / (action_duration - marker) * (length - float(clip.hit_time))
	return sample_clip(clip, mapped, true)

func guardian_frame(state: String, elapsed: float) -> Dictionary:
	return sample_clip(painted.guardian_clips.get(state, painted.guardian_clips.idle), elapsed)

# Shared by runtime, portrait and review tools so sockets use one transform.
# No simulation commands or damage are called by this renderer.
func draw_actor(canvas: CanvasItem, frame: Dictionary, foot: Vector2, weapon: String, tint: Color = Color.WHITE, show_weapon: bool = true, scale_override: float = -1) -> void:
	var size_data: Array = frame.get("size", [192, 240])
	var anchor_data: Array = frame.get("anchor", [96, 216])
	var dimensions := Vector2(size_data[0], size_data[1])
	var anchor := Vector2(anchor_data[0], anchor_data[1])
	var factor: float = frame.get("render_scale", .88) if scale_override < 0 else scale_override
	var origin := foot - anchor * factor
	if frame.has("source_anchor") and frame.has("trim_offset"):
		var source: Array = frame.source_anchor
		var offset: Array = frame.trim_offset
		origin = foot + (Vector2(offset[0], offset[1]) - Vector2(source[0], source[1])) * factor
	canvas.draw_texture_rect(textures[frame.file], Rect2(origin, dimensions * factor), false, tint)
	if not show_weapon or frame.get("embedded_weapon", false):
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
