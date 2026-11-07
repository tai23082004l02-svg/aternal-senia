class_name FrameLibrary
extends RefCounted

var manifest: Dictionary
var textures: Dictionary = {}

func _init() -> void:
	manifest = JSON.parse_string(FileAccess.get_file_as_string("res://art/clips.json"))
	for hero in manifest.heroes:
		for clip in manifest.heroes[hero].values():
			for frame in clip.frames:
				if not textures.has(frame.file):
					textures[frame.file] = load("res://art/" + frame.file)
	for type in ["sword", "spear", "staff"]:
		for rank in [1, 2]:
			var key := "%s_%d.svg" % [type, rank]
			textures[key] = load("res://art/" + key)
	for key in ["slime", "wolf", "golem", "guardian", "bird"]:
		textures["enemy_" + key] = load("res://art/enemy_" + key + ".svg")
	for key in ["forest", "ruins", "lake", "mountain", "tower"]:
		textures["bg_" + key] = load("res://art/bg_" + key + ".svg")

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
