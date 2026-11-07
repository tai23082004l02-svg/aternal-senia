class_name BattleView
extends Node2D

var library: FrameLibrary
var battle: BattleModel
var preview: Dictionary
var selected_stage: Dictionary
var clock := 0.0
var hero_frame: Dictionary

func setup(frames: FrameLibrary) -> void:
	library = frames

func _process(delta: float) -> void:
	clock += delta
	queue_redraw()

func _draw() -> void:
	if library == null or preview.is_empty():
		return
	var active := battle != null and battle.state != "idle"
	var visual_time: float = battle.time if active else clock
	var stats: Dictionary = battle.stats if active else preview
	var stage: Dictionary = battle.stage if active else selected_stage
	draw_texture_rect(library.textures["bg_" + stage.zone], Rect2(0, 178, 540, 330), false)
	var foot := Vector2(142, 475)
	var pose := "idle"
	var elapsed := clock
	if active:
		pose = "hurt" if battle.hurt_left > 0 and battle.state != "lost" else battle.hero_pose
		elapsed = battle.hero_pose_time if pose != "idle" else battle.time
		if battle.move_clock > 0:
			foot.x += sin(battle.move_clock * PI / .8) * 30
	hero_frame = library.frame_at(stats.hero, pose, elapsed)
	_shadow(foot, 39)
	var tint := Color.WHITE
	if active and battle.hurt_left > 0:
		tint = Color("ffbdb5")
	draw_texture_rect(library.textures[hero_frame.file], Rect2(foot - Vector2(96, 216) * .88, Vector2(192, 240) * .88), false, tint)
	# Weapon socket is part of each authored frame; view never applies damage.
	if pose != "death":
		var hand := foot + (Vector2(hero_frame.hand[0], hero_frame.hand[1]) - Vector2(96, 216)) * .88
		draw_set_transform(hand, deg_to_rad(hero_frame.angle), Vector2(.88, .88))
		draw_texture(library.textures[stats.weapon + ".svg"], -Vector2(32, 128))
		draw_set_transform(Vector2.ZERO)
	var companion := Vector2(61, 352 + sin(visual_time * 2) * 6)
	var companion_color := Color("96e5d4") if stats.assist == "lumi" else Color("edb77a")
	draw_circle(companion, 22, Color(companion_color, .09))
	draw_circle(companion, 10, companion_color)
	draw_arc(companion, 17, visual_time, visual_time + PI * 1.2, 24, companion_color, 1)
	if active and battle.assist_flash > 0:
		draw_line(companion, foot + Vector2(0, -65) if stats.assist == "lumi" else Vector2(391, 412), Color(companion_color, battle.assist_flash), 3)
	var wave: int = battle.wave if active else 0
	var enemy_key: String = "enemy_" + (["slime", "wolf", ["golem", "guardian", "wolf", "bird", "guardian"][int(stage.id) - 1]][wave])
	var enemy_foot := Vector2(391, 477)
	_shadow(enemy_foot, 43)
	var enemy_tint := Color.WHITE
	if active and battle.enemy_hurt > 0:
		enemy_tint = Color("fff0c9")
	if active and battle.move_clock > 0:
		enemy_tint.a = 0
	if active and battle.state == "won":
		enemy_tint.a = .18
	var scale_factor := 1.03 if wave == 2 else .8
	draw_texture_rect(library.textures[enemy_key], Rect2(enemy_foot - Vector2(96, 216) * scale_factor, Vector2(192, 240) * scale_factor), false, enemy_tint)
	if active and battle.shield:
		draw_arc(enemy_foot + Vector2(0, -85), 68, 0, TAU, 64, Color("94cbf2"), 4)
	if active and battle.guard_left > 0:
		draw_arc(foot + Vector2(0, -70), 65, -PI * .7, PI * .7, 40, Color("9de7e1"), 5)
	if active and battle.enemy_clock > 2 and battle.state == "battle" and battle.move_clock <= 0:
		draw_arc(enemy_foot + Vector2(0, -4), 53, PI, PI + PI * (battle.enemy_clock - 2), 32, Color("f7ad89"), 5)
	if active:
		for action in battle.actions:
			if action.kind == "damage" and action.elapsed >= action.marker - .04 and action.elapsed <= action.marker + .18:
				var col := Color("baf4ee") if action.skill else Color("f5dfac")
				draw_arc(Vector2(287, 384), 80, -.9, .9, 32, col, 8 if action.burst else 4)
		for event in battle.events:
			var age: float = battle.time - event.time
			if age > .85 or event.kind in ["wave", "result"]:
				continue
			var pos := Vector2(391 if event.target == 1 else 142, 311 - age * 48)
			var col := Color("ade6d3") if event.kind in ["heal", "guard"] else Color("f3d49c")
			if event.kind == "hurt":
				col = Color("ffa99c")
			col.a = 1 - age / .85
			draw_string(ThemeDB.fallback_font, pos - Vector2(20, 0), event.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, col)

func _shadow(pos: Vector2, radius: float) -> void:
	draw_set_transform(pos, 0, Vector2(1, .2))
	draw_circle(Vector2.ZERO, radius, Color(0, 0, 0, .25))
	draw_set_transform(Vector2.ZERO)
