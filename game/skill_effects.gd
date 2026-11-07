class_name SkillEffects
extends RefCounted

# Layered animation of existing original textures. Read-only and bounded;
# all phases derive from event time, never wall clock or combat RNG.
static func draw(canvas: CanvasItem, library: FrameLibrary, kind: String, p: float, floor_layer: bool, hero: Vector2, aim: Vector2, visual: Dictionary) -> void:
	var fade := pow(1 - p, 1.5)
	match kind:
		"cast":
			var heal: bool = visual.get("kind") == "heal"
			var burst: bool = visual.get("burst", false)
			var color := Color("9cf2d7") if heal or burst else Color("ffe2a4")
			if floor_layer:
				circle(canvas, hero, 38 + p * 13, p * 1.8, color, .35 * sin(p * PI))
			else:
				for i in range(4):
					var angle := i * TAU / 4 + p * TAU
					var pos := hero + Vector2(cos(angle) * 33, -68 + sin(angle) * 19 - p * 15)
					CombatEffects.stamp(canvas, library, "motes", pos, Vector2.ONE * (12 + p * 7), .55 * sin(p * PI), angle, color)
		"radiant_release":
			if floor_layer:
				circle(canvas, aim + Vector2(0, 70), 24 + p * 65, -p, Color("ffd78d"), .45 * fade)
			else:
				# Two crossing arcs followed by a brief central light pillar.
				for i in range(2):
					CombatEffects.stamp(canvas, library, "slash_gold", aim, Vector2(145 + p * 85, 75), .85 * fade, -.7 if i == 0 else .7)
				CombatEffects.stamp(canvas, library, "cast_orb", aim, Vector2(35 + 55 * p, 150 + p * 30), .52 * fade, 0, Color("ffe6b0"))
				for i in range(6):
					var angle := i * TAU / 6 + .3
					CombatEffects.stamp(canvas, library, "motes", aim + Vector2.from_angle(angle) * (18 + p * 95), Vector2.ONE * 19 * (1 - p * .5), .7 * fade, angle, Color("ffe6b0"))
		"restoration_release":
			if floor_layer:
				circle(canvas, hero, 46 + p * 13, -p * 1.3, Color("9df1d4"), .65 * sin(p * PI))
			else:
				for i in range(5):
					var phase := fposmod(p + i * .19, 1)
					var x := sin(i * 2.4 + p * 3) * 45
					CombatEffects.stamp(canvas, library, "heal_ribbon", hero + Vector2(x, -20 - phase * 145), Vector2(23, 58), .45 * sin(phase * PI) * sin(p * PI), .15 * sin(i + p * 2))
				CombatEffects.stamp(canvas, library, "heal_ring", hero + Vector2(0, -65 - p * 30), Vector2(125, 55), .55 * sin(p * PI), p * .15)
		"spirit_release":
			if floor_layer:
				CombatEffects.stamp(canvas, library, "shockwave", aim + Vector2(0, 65), Vector2(70 + p * 175, 25 + p * 50), .65 * fade, 0, Color("a7f1e6"))
			else:
				canvas.draw_line(Vector2(61, 352), aim, Color(.52, .95, .88, .3 * fade), 3, true)
				CombatEffects.stamp(canvas, library, "cast_orb", aim, Vector2.ONE * (65 + p * 115), .72 * fade, -p * .8, Color("a2f2ea"))
				for i in range(8):
					var angle := i * TAU / 8 + p * .7
					var pos := aim + Vector2.from_angle(angle) * (25 + p * 100)
					CombatEffects.stamp(canvas, library, "shards", pos, Vector2(20, 32) * (1 - .45 * p), .7 * fade, angle + p, Color("b3f8f1"))

static func circle(canvas: CanvasItem, center: Vector2, radius: float, rotation: float, tint: Color, alpha: float) -> void:
	canvas.draw_set_transform(center, 0, Vector2(1, .32))
	var color := Color(tint, alpha)
	canvas.draw_arc(Vector2.ZERO, radius, 0, TAU, 48, color, 1.5, true)
	for i in range(6):
		var angle := rotation + i * TAU / 6
		canvas.draw_arc(Vector2.ZERO, radius * .78, angle, angle + .37, 8, color, 2, true)
		canvas.draw_line(Vector2.from_angle(angle) * (radius - 3), Vector2.from_angle(angle) * (radius + 3), color, 2, true)
	canvas.draw_set_transform(Vector2.ZERO)
