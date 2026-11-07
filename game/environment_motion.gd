class_name EnvironmentMotion
extends RefCounted

# Deterministic presentation only: no RNG, simulation commands or allocated nodes.
static func companion(time: float, flash: float, fiery: bool) -> Dictionary:
	var pulse := clampf(flash, 0, 1)
	return {
		"position": Vector2(61 + sin(time * 1.7) * 3 + pulse * 14, 352 + sin(time * 2) * 5 - pulse * 9),
		"scale": Vector2(1 + sin(time * 3.4) * .025, 1 - sin(time * 3.4) * .025) * (1 + pulse * .08),
		"angle": sin(time * 1.7) * (.055 if fiery else .035)
	}

static func draw_motes(canvas: CanvasItem, zone: String, time: float, foreground: bool) -> void:
	var warm := zone == "ruins" or zone == "tower"
	var color := Color("ffc17a") if warm else Color("b2e4d9")
	var count := 9 if foreground else 15
	for i in range(count):
		var seed_value := float(i * 79 + (31 if foreground else 0))
		var speed := 8.0 if foreground else 3.5
		var x := fposmod(seed_value * 7.3 + time * (4 if warm else 1.5), 560) - 10
		var y := 506 - fposmod(seed_value * 3.7 + time * speed, 322)
		x += sin(time * .65 + seed_value) * 9
		var fade := sin(clampf((y - 178) / 330, 0, 1) * PI)
		color.a = (.35 if foreground else .19) * fade * (.65 + .35 * sin(time * 1.8 + seed_value))
		canvas.draw_circle(Vector2(x, y), 1.7 if foreground else 1.1, color)
		if warm and foreground:
			canvas.draw_line(Vector2(x, y + 3), Vector2(x, y), Color(color, color.a * .45), 1, true)
