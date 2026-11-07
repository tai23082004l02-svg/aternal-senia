class_name CombatEffects
extends RefCounted

const CAP := 96
var run_id := ""
var cursor := 0
var items: Array[Dictionary] = []
var emitted := 0
var now := 0.0

func reset(id: String = "") -> void:
	run_id = id
	cursor = 0
	items.clear()
	emitted = 0

func consume(battle: BattleModel, world_time: float) -> void:
	if run_id != battle.run.id:
		reset(battle.run.id)
	now = world_time
	for event in battle.events:
		if event.id <= cursor:
			continue
		cursor = event.id
		var visual: Dictionary = event.get("visual", {})
		match event.kind:
			"action":
				if visual.skill:
					_add("cast", event, visual.marker + .12, 0, battle.speed)
				if visual.kind == "damage":
					_add("slash", event, .24 if not visual.burst else .34, maxf(0, visual.marker - .055), battle.speed)
			"hit", "critical":
				_add("burst" if visual.get("burst", false) else ("critical" if event.kind == "critical" else "impact"), event, .4 if visual.get("burst", false) else .25, 0, battle.speed)
				_add("number", event, .72 * battle.speed, 0, battle.speed)
			"heal":
				_add("heal", event, 1.05, 0, battle.speed)
				_add("number", event, .8 * battle.speed, 0, battle.speed)
			"guard":
				_add("block" if event.cue == "guard_hit" else "guard", event, .38, 0, battle.speed)
			"hurt":
				_add("hurt", event, .24, 0, battle.speed)
				_add("number", event, .72 * battle.speed, 0, battle.speed)
			"warning":
				_add("counter", event, .45, 0, battle.speed)
			"sound":
				var kind: String = {"shield_on": "shield_on", "shield_break": "shatter", "boss_slam": "slam", "enemy_down": "dissolve"}.get(event.cue, "")
				if not kind.is_empty():
					_add(kind, event, .62, 0, battle.speed)
	items = items.filter(func(item): return now - item.start < item.duration)

func _add(kind: String, event: Dictionary, duration: float, delay: float, speed: int) -> void:
	if items.size() >= CAP:
		items.pop_front()
	items.append({"kind": kind, "start": event.time + delay, "duration": duration, "event": event.duplicate(true), "speed": speed})
	emitted += 1

func shake() -> Vector2:
	var offset := Vector2.ZERO
	for item in items:
		var age: float = now - item.start
		if age < 0 or age > .15:
			continue
		var strength: float = {"impact": 1.2, "critical": 2.1, "burst": 2.1, "block": 1.4, "slam": 2.8}.get(item.kind, 0.0)
		var fade := 1 - age / .15
		offset += Vector2(sin(age * 110 + item.event.id), cos(age * 133 + item.event.id)) * strength * fade
	return offset.limit_length(3.2)

func draw(canvas: CanvasItem, library: FrameLibrary, floor_layer: bool, hero_foot: Vector2, enemy_foot: Vector2) -> void:
	for item in items:
		var age: float = now - item.start
		if age < 0 or age >= item.duration:
			continue
		var p: float = age / item.duration
		var fade := pow(1 - p, 1.4)
		var event: Dictionary = item.event
		var visual: Dictionary = event.get("visual", {})
		var aim := CombatPresentation.target(int(visual.get("presentation_wave", event.wave)))
		if floor_layer:
			match item.kind:
				"heal":
					stamp(canvas, library, "heal_ring", hero_foot + Vector2(0, 1), Vector2(178, 85) * (.85 + .15 * sin(p * PI)), .7 * sin(p * PI))
				"cast":
					stamp(canvas, library, "heal_ring", hero_foot, Vector2(110, 45) * (.7 + .3 * p), .3 * fade)
				"slam":
					stamp(canvas, library, "shockwave", hero_foot + Vector2(0, -2), Vector2(85 + 180 * p, 33 + 52 * p), .85 * fade)
				"block", "guard":
					stamp(canvas, library, "heal_ring", hero_foot, Vector2(95 + 55 * p, 32 + 15 * p), .35 * fade)
			continue
		match item.kind:
			"slash":
				var variant: int = int(visual.get("combo", 1)) % 3
				var key: String = "slash_double" if visual.get("burst", false) or variant == 0 else ("slash_gold" if variant == 1 else "slash_teal")
				var center := Vector2(287 + p * 48, aim.y - 6)
				stamp(canvas, library, key, center, Vector2(205 + p * 30, 105), .82 * sin(p * PI), -.10 + variant * .08)
			"impact", "critical", "burst":
				var large: bool = item.kind != "impact"
				var size := (82.0 if large else 48.0) * (.7 + .8 * p)
				stamp(canvas, library, "burst" if item.kind == "burst" else "impact", aim, Vector2.ONE * size, .95 * fade, p * .4)
				for i in range(4 if large else 2):
					var direction := Vector2.from_angle(-2.5 + i * 1.1 + float(event.id % 3) * .12)
					stamp(canvas, library, "motes", aim + direction * (15 + p * 55), Vector2.ONE * (18 - p * 7), .65 * fade)
			"cast":
				stamp(canvas, library, "cast_orb", hero_foot + Vector2(39, -87), Vector2.ONE * (20 + p * 20), .5 * sin(p * PI), -p * .8)
			"heal":
				for i in range(3):
					var x := sin(i * 2.2 + p * 4) * (22 + i * 9)
					stamp(canvas, library, "petals", hero_foot + Vector2(x, -35 - p * 105), Vector2(40, 60), .8 * sin(p * PI), .15 * sin(i + p * 3))
				if event.cue == "lumi":
					stamp(canvas, library, "heal_ribbon", hero_foot + Vector2(-30, -90), Vector2(125, 55), .6 * fade, .35)
			"guard", "shield_on":
				var pos := hero_foot + Vector2(35, -80) if item.kind == "guard" else enemy_foot + Vector2(-28, -88)
				stamp(canvas, library, "guard_arc", pos, Vector2(105 + 25 * p, 150 + 20 * p), .25 * fade)
			"block":
				stamp(canvas, library, "impact", hero_foot + Vector2(50, -80), Vector2.ONE * (52 + 25 * p), .75 * fade, .5)
				stamp(canvas, library, "shards", hero_foot + Vector2(52 + p * 22, -75 - p * 15), Vector2(55, 55), .6 * fade)
			"shatter":
				if p < .25:
					stamp(canvas, library, "shield_crack", enemy_foot + Vector2(-28, -85), Vector2(155, 195), .6 * (1 - p * 4))
				for i in range(3):
					stamp(canvas, library, "shards", enemy_foot + Vector2(-25 + cos(i * 2.5) * p * 90, -85 - sin(i + .4) * p * 60 + p * p * 90), Vector2.ONE * (60 - 18 * p), .9 * fade, i + p)
			"slam":
				stamp(canvas, library, "dust", hero_foot + Vector2(0, -18 - p * 12), Vector2(110 + 100 * p, 65 + 25 * p), .75 * fade)
			"dissolve":
				stamp(canvas, library, "motes", aim + Vector2(0, -35 * p), Vector2(75, 75) * (1 + p), .6 * fade)
			"hurt":
				stamp(canvas, library, "impact", hero_foot + Vector2(10, -75), Vector2.ONE * (32 + p * 20), .45 * fade, .7)
			"counter":
				stamp(canvas, library, "slash_teal", hero_foot + Vector2(12, -70), Vector2(95, 110), .5 * fade, -.6)
			"number":
				_number(canvas, item, hero_foot, aim, p)

func _number(canvas: CanvasItem, item: Dictionary, hero_foot: Vector2, aim: Vector2, p: float) -> void:
	var event: Dictionary = item.event
	var critical: bool = event.kind == "critical"
	var anchor := aim if event.target == 1 else hero_foot + Vector2(0, -128)
	var color := Color("a7ecd6") if event.kind == "heal" else (Color("ffb7a3") if event.kind == "hurt" else Color("f5dc9d"))
	var alpha := 1 - smoothstep(.55, 1, p)
	color.a = alpha
	var font_size := 27 if critical else 21
	var pos := anchor + Vector2(-13 + (event.id % 3 - 1) * 15, -24 - p * 41 - (event.id % 2) * 9)
	canvas.draw_string_outline(ThemeDB.fallback_font, pos, event.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 3, Color(0, .04, .06, alpha * .85))
	canvas.draw_string(ThemeDB.fallback_font, pos, event.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

static func stamp(canvas: CanvasItem, library: FrameLibrary, key: String, center: Vector2, size: Vector2, alpha: float, rotation: float = 0) -> void:
	if alpha <= 0:
		return
	canvas.draw_set_transform(center, rotation)
	canvas.draw_texture_rect(library.textures["fx_" + key], Rect2(-size * .5, size), false, Color(1, 1, 1, clampf(alpha, 0, 1)))
	canvas.draw_set_transform(Vector2.ZERO)
