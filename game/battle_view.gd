class_name BattleView
extends Node2D

var library: FrameLibrary
var battle: BattleModel
var preview: Dictionary
var selected_stage: Dictionary
var home_card := false
var clock := 0.0
var world_time := 0.0
var post_time := 0.0
var hero_frame: Dictionary
var effects := CombatEffects.new()
var tracked_battle: BattleModel
var world: WorldLayer
var pose: Dictionary = {}

class WorldLayer extends Node2D:
	var view: BattleView
	func _draw() -> void:
		view.draw_world(self)

func setup(frames: FrameLibrary) -> void:
	library = frames

func _ready() -> void:
	var clip := Control.new()
	clip.position = Vector2(0, 178)
	clip.size = Vector2(540, 330)
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(clip)
	world = WorldLayer.new()
	world.view = self
	world.position = Vector2(0, -178)
	clip.add_child(world)

func _process(delta: float) -> void:
	clock += delta
	if tracked_battle != battle:
		tracked_battle = battle
		post_time = 0
		effects.reset(battle.run.id if battle != null else "")
	if battle != null:
		if battle.state != "battle" and not battle.paused:
			post_time += delta * battle.speed
		world_time = battle.time + post_time
		effects.consume(battle, world_time)
		pose = CombatPresentation.hero(battle, world_time)
	else:
		world_time = clock
		pose = {"state": "idle", "time": clock, "offset": Vector2.ZERO, "marker": -1.0, "duration": -1.0}
	if is_instance_valid(world):
		world.position = Vector2(0, -178) + (effects.shake() if battle != null else Vector2.ZERO)
		world.queue_redraw()

func draw_world(canvas: CanvasItem) -> void:
	if library == null or preview.is_empty() or pose.is_empty():
		return
	var active := battle != null and battle.state != "idle"
	var stats: Dictionary = battle.stats if active else preview
	var stage: Dictionary = battle.stage if active else selected_stage
	canvas.draw_texture_rect(library.textures["bg_" + stage.zone], Rect2(-4, 174, 548, 338), false)
	EnvironmentMotion.draw_motes(canvas, stage.zone, world_time, false)
	var hero_foot: Vector2 = (Vector2(142, 475) if active else Vector2(385, 490)) + pose.offset
	var enemy_foot := Vector2(391, 477)
	if active:
		effects.draw(canvas, library, true, hero_foot, enemy_foot)
		_telegraph(canvas, hero_foot)
	_shadow(canvas, hero_foot, 36)
	hero_frame = library.motion_frame(stats.hero, pose.state, pose.time, pose.marker, pose.duration)
	var look: Array = stats.get("look_tint", [1, 1, 1, 1])
	var tint := Color(look[0], look[1], look[2], look[3])
	if active and battle.hurt_left > .18:
		tint *= Color("ffd3c4")
	library.draw_actor(canvas, hero_frame, hero_foot, stats.weapon, tint, pose.state != "death")
	_companion(canvas, stats)
	if active: _enemy(canvas, stage, enemy_foot)
	elif not home_card: _home_caption(canvas, stats, stage)
	if active:
		if battle.guard_left > 0 or battle.barrier > 0:
			CombatEffects.stamp(canvas, library, "guard_arc", hero_foot + Vector2(34, -78), Vector2(125, 177), .55)
		if battle.shield:
			CombatEffects.stamp(canvas, library, "guard_arc", enemy_foot + Vector2(-30, -83), Vector2(166, 205), .43)
		effects.draw(canvas, library, false, hero_foot, enemy_foot)
	EnvironmentMotion.draw_motes(canvas, stage.zone, world_time, true)

func _companion(canvas: CanvasItem, stats: Dictionary) -> void:
	var flash: float = battle.assist_flash if battle != null else 0.0
	var motion := EnvironmentMotion.companion(world_time, flash, stats.assist == "ash")
	var companion: Vector2 = motion.position
	if battle == null: companion.x += 217
	var color := Color("96e5d4") if stats.assist == "lumi" else Color("edb77a")
	if library.textures.has("companion_" + stats.assist):
		canvas.draw_set_transform(companion, motion.angle, motion.scale)
		canvas.draw_texture_rect(library.textures["companion_" + stats.assist], Rect2(Vector2(-40, -40), Vector2(80, 80)), false)
		canvas.draw_set_transform(Vector2.ZERO)
	else:
		canvas.draw_circle(companion, 11, color)
	if battle != null and battle.assist_flash > 0:
		CombatEffects.stamp(canvas, library, "motes", companion, Vector2.ONE * (45 + battle.assist_flash * 30), battle.assist_flash)

func _enemy(canvas: CanvasItem, stage: Dictionary, enemy_foot: Vector2) -> void:
	var active := battle != null and battle.state != "idle"
	var wave: int = (2 if battle.is_boss() else battle.wave % 2) if active else 0
	var alpha := 1.0
	if active and battle.move_clock > 0:
		wave = 2 if active and stage.has("waves") and stage.waves[maxi(0, battle.wave - 1)].boss else maxi(0, (battle.wave - 1) % 2)
		var age := .8 - battle.move_clock
		alpha = 1 - smoothstep(0, .29, age)
		enemy_foot += Vector2(4 * age, 12 * age)
	if active and battle.state == "won":
		alpha = 1 - smoothstep(0, .48, post_time)
		enemy_foot.y += post_time * 12
	if alpha <= 0:
		return
	var enemy_type: String = ["slime", "wolf", ["golem", "guardian", "mirror", "bird", "sentinel"][int(stage.get("base_stage", stage.id)) - 1]][wave]
	if active and stage.has("waves"):
		var index := maxi(0, battle.wave - 1) if battle.move_clock > 0 else battle.wave
		enemy_type = stage.waves[index].get("enemy_type", enemy_type)
		if battle.is_boss() and enemy_type == "wolf": enemy_type = "mirror"
	var key := "enemy_" + enemy_type
	var spec: Dictionary = library.enemy_specs.get(enemy_type, {"anchor": [96, 216], "scale": 1.03 if wave == 2 else .8})
	var texture: Texture2D = library.textures[key]
	if enemy_type == "golem":
		var sample := CombatPresentation.guardian(battle, world_time) if active else {"state": "idle", "time": clock}
		spec = library.guardian_frame(sample.state, sample.time)
		texture = library.textures[spec.file]
	if library.painted.get("enemy_clips", {}).has(enemy_type):
		var sample := CombatPresentation.guardian(battle, world_time) if active else {"state": "idle", "time": clock}
		spec = library.enemy_frame(enemy_type, sample.state, sample.time)
		texture = library.textures[spec.file]
	var impact_age := 1000.0
	for effect in effects.items:
		if effect.kind in ["impact", "critical", "burst"] and effect.event.wave == (battle.wave - 1 if battle.move_clock > 0 else battle.wave):
			impact_age = minf(impact_age, world_time - effect.start)
	if impact_age >= 0 and impact_age < .18:
		enemy_foot.x += sin(impact_age / .18 * PI) * 6
	_shadow(canvas, enemy_foot, 42, alpha)
	var size_factor: float = spec.scale
	var anchor := Vector2(spec.anchor[0], spec.anchor[1])
	var color := Color(1, .95, .84, alpha) if impact_age >= 0 and impact_age < .055 else (Color(.85, .91, 1, alpha) if enemy_type == "sentinel" else Color(1, 1, 1, alpha))
	canvas.draw_texture_rect(texture, Rect2(enemy_foot - anchor * size_factor, texture.get_size() * size_factor), false, color)
	if active and wave == 2 and battle.enemy_clock >= 2 and battle.state == "battle" and battle.move_clock <= 0:
		var charge := clampf(battle.enemy_clock - 2, 0, 1)
		CombatEffects.stamp(canvas, library, "cast_orb", enemy_foot + Vector2(-10, -93), Vector2.ONE * (22 + charge * 24), .3 + charge * .3)

func _telegraph(canvas: CanvasItem, hero_foot: Vector2) -> void:
	if battle.state != "battle" or battle.move_clock > 0 or battle.enemy_clock < 2:
		return
	var progress := clampf(battle.enemy_clock - 2, 0, 1)
	var size := Vector2(174, 69) if battle.is_boss() else Vector2(125, 43)
	CombatEffects.stamp(canvas, library, "telegraph", hero_foot + Vector2(0, -1), size, .28 + progress * .47)
	canvas.draw_set_transform(hero_foot, 0, Vector2(1, .30))
	canvas.draw_arc(Vector2.ZERO, size.x * .41, -PI / 2, -PI / 2 + TAU * progress, 48, Color(1, .69, .38, .65), 3, true)
	canvas.draw_set_transform(Vector2.ZERO)

func _shadow(canvas: CanvasItem, pos: Vector2, radius: float, alpha: float = 1) -> void:
	canvas.draw_set_transform(pos, 0, Vector2(1, .2))
	canvas.draw_circle(Vector2.ZERO, radius, Color(0, 0, 0, .24 * alpha))
	canvas.draw_set_transform(Vector2.ZERO)

func _home_caption(canvas: CanvasItem, stats: Dictionary, stage: Dictionary) -> void:
	for i in range(27):
		canvas.draw_rect(Rect2(i*10, 178, 10, 330), Color(.015, .04, .065, .72 * (1-i/27.0)))
	var font := ThemeDB.fallback_font
	canvas.draw_string(font, Vector2(27, 230), "CHUYẾN ĐI", HORIZONTAL_ALIGNMENT_LEFT, -1, 29, Color("f2e3bb"))
	canvas.draw_string(font, Vector2(27, 266), "CỦA ÁNH SÁNG", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("e4c58e"))
	canvas.draw_line(Vector2(28, 284), Vector2(126, 284), Color("c2a572"), 1)
	canvas.draw_string(font, Vector2(28, 320), stage.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("c8ddda"))
	canvas.draw_string(font, Vector2(28, 347), "Một lời hứa. Một bình minh mới.", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("a0bab8"))
	canvas.draw_string(font, Vector2(28, 474), str(stats.hero).to_upper() + "  /  " + str(stats.assist).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e4c58e"))
