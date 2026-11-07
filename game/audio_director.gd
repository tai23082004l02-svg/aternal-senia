class_name AudioDirector
extends Node

const VOICES := 12
const SFX_BUS := "FirstLightSFX"
const AIR_BUS := "FirstLightAmbience"
var manifest: Dictionary
var streams: Dictionary = {}
var players: Array[AudioStreamPlayer] = []
var slots: Array[Dictionary] = []
var ambience: AudioStreamPlayer
var enabled := true
var effects_level := .8
var air_level := .35
var world_paused := false
var run_id := ""
var cursor := 0
var variants: Dictionary = {}
var last_played: Dictionary = {}
var trace: Array[Dictionary] = []
var preview_generation := 0
var consumed := 0
var played := 0
var dropped := 0
var max_active := 0
var shutting_down := false
var owns_sfx_bus := false
var owns_air_bus := false

func _ready() -> void:
	manifest = JSON.parse_string(FileAccess.get_file_as_string("res://art/audio/manifest.json"))
	owns_sfx_bus = _make_bus(SFX_BUS)
	owns_air_bus = _make_bus(AIR_BUS)
	if owns_sfx_bus:
		var limiter := AudioEffectLimiter.new()
		limiter.ceiling_db = -3
		limiter.threshold_db = -6
		AudioServer.add_bus_effect(AudioServer.get_bus_index(SFX_BUS), limiter)
	for cue in manifest.cues.values():
		for file in cue.files:
			if not streams.has(file):
				streams[file] = load("res://art/audio/" + file)
	for i in range(VOICES):
		var player := AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		players.append(player)
		slots.append({"cue": "", "priority": -1, "started": 0, "world": false, "preview": false})
	ambience = AudioStreamPlayer.new()
	ambience.bus = AIR_BUS
	var stream: AudioStreamOggVorbis = load("res://art/audio/" + manifest.ambience.file)
	stream.loop = true
	ambience.stream = stream
	ambience.volume_db = manifest.ambience.gain_db
	add_child(ambience)
	configure(true, .8, .35)

func _make_bus(bus_name: String) -> bool:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return false
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
	AudioServer.set_bus_send(AudioServer.get_bus_index(bus_name), "Master")
	return true

func configure(master_enabled: bool, sfx: float, air: float) -> void:
	if shutting_down:
		return
	var previously_audible := enabled and effects_level > 0
	enabled = master_enabled
	effects_level = clampf(sfx, 0, 1)
	air_level = clampf(air, 0, 1)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS), linear_to_db(maxf(.00001, effects_level)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(AIR_BUS), linear_to_db(maxf(.00001, air_level)))
	AudioServer.set_bus_mute(AudioServer.get_bus_index(SFX_BUS), not enabled or effects_level <= 0)
	AudioServer.set_bus_mute(AudioServer.get_bus_index(AIR_BUS), not enabled or air_level <= 0)
	if not enabled or effects_level <= 0:
		if previously_audible:
			cancel_preview()
		for player in players:
			player.stop()
	if not enabled or air_level <= 0:
		ambience.stop()

func apply_profile(profile: Dictionary) -> void:
	configure(profile.settings.sound, profile.settings.get("sfx_volume", .8), profile.settings.get("ambience_volume", .35))

func context(zone: String, paused: bool, visible_world: bool = true) -> void:
	if shutting_down:
		return
	world_paused = paused
	for i in range(players.size()):
		if slots[i].world:
			players[i].stream_paused = paused
	var should_air := enabled and air_level > 0 and zone == "forest" and visible_world
	if should_air:
		if not ambience.playing:
			ambience.play()
		ambience.stream_paused = false
	else:
		ambience.stop()

func begin_run(id: String) -> void:
	stop_world()
	for i in range(players.size()):
		if slots[i].cue in ["victory", "defeat"]:
			players[i].stop()
	run_id = id
	cursor = 0

func consume(battle: BattleModel) -> void:
	if battle.run.id != run_id:
		begin_run(battle.run.id)
	for event in battle.events:
		if event.id <= cursor:
			continue
		cursor = event.id
		var cue: String = event.get("cue", "")
		if cue.is_empty():
			continue
		consumed += 1
		play(cue)
		trace.append({"run": run_id, "id": event.id, "cue": cue, "time": event.time, "action": event.get("action_id", 0)})
		if trace.size() > 512:
			trace.pop_front()

func play(cue: String, preview: bool = false) -> bool:
	if shutting_down:
		return false
	if not manifest.cues.has(cue):
		push_error("Audio cue missing: " + cue)
		return false
	var config: Dictionary = manifest.cues[cue]
	var world: bool = config.bus == "battle" and not preview
	if not enabled or effects_level <= 0 or (world and world_paused):
		return false
	var now := Time.get_ticks_msec()
	if now - int(last_played.get(cue, -100000)) < config.cooldown * 1000:
		dropped += 1
		return false
	var same := 0
	var active := 0
	var slot := -1
	for i in range(players.size()):
		if not players[i].playing:
			if slot < 0:
				slot = i
			continue
		active += 1
		if slots[i].cue == cue:
			same += 1
	if same >= int(config.max_instances):
		dropped += 1
		return false
	if slot < 0:
		var oldest := now + 1
		var lowest: int = int(config.priority)
		for i in range(players.size()):
			if slots[i].priority < lowest or (slots[i].priority == lowest and slots[i].started < oldest and slots[i].priority < config.priority):
				lowest = slots[i].priority
				oldest = slots[i].started
				slot = i
		if slot < 0:
			dropped += 1
			return false
		players[slot].stop()
	var variant: int = int(variants.get(cue, 0))
	variants[cue] = variant + 1
	var file: String = config.files[variant % config.files.size()]
	var player := players[slot]
	player.stream = streams[file]
	# Small deterministic presentation variation, never combat RNG or speed.
	player.pitch_scale = 1.0 + config.pitch_variation * [0, .7, -.6][variant % 3]
	player.volume_db = config.gain_db
	player.stream_paused = false
	slots[slot] = {"cue": cue, "priority": int(config.priority), "started": now, "world": world, "preview": preview}
	player.play()
	last_played[cue] = now
	played += 1
	max_active = maxi(max_active, mini(VOICES, active + 1))
	return true

func stop_world() -> void:
	for i in range(players.size()):
		if slots[i].world:
			players[i].stop()
	world_paused = false

func cancel_preview() -> void:
	preview_generation += 1
	for i in range(players.size()):
		if slots[i].preview:
			players[i].stop()

func audition() -> void:
	if not enabled or effects_level <= 0:
		return
	cancel_preview()
	var generation := preview_generation
	for cue in ["swing_sword", "impact_sword", "heal", "guard_hit", "lumi"]:
		if generation != preview_generation or not is_inside_tree():
			return
		play(cue, true)
		await get_tree().create_timer(.22 if cue == "swing_sword" else .65).timeout

func shutdown() -> void:
	shutting_down = true
	cancel_preview()
	for player in players:
		player.stop()
		player.stream = null
	if is_instance_valid(ambience):
		ambience.stop()
		ambience.stream = null

func _exit_tree() -> void:
	shutdown()
	for bus_name in [SFX_BUS, AIR_BUS]:
		if (bus_name == SFX_BUS and owns_sfx_bus) or (bus_name == AIR_BUS and owns_air_bus):
			var index := AudioServer.get_bus_index(bus_name)
			if index >= 0:
				AudioServer.remove_bus(index)
