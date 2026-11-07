class_name MenuBackdrop
extends Control

var art: Texture2D = preload("res://art/complete/shell.png")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(540, 960)
	z_index = -10

func _draw() -> void:
	draw_texture_rect(art, Rect2(0, 0, 540, 960), false)
	draw_rect(Rect2(0, 136, 540, 824), Color(.015, .035, .06, .42))
	draw_rect(Rect2(0, 0, 540, 136), Color(.025, .055, .085, .6))
	draw_line(Vector2(24, 133), Vector2(516, 133), Color("6f684d"), 1)
	draw_line(Vector2(24, 922), Vector2(516, 922), Color("3e5260"), 1)
	for x in [24, 516]:
		draw_colored_polygon(PackedVector2Array([Vector2(x, 129), Vector2(x+4, 133), Vector2(x, 137), Vector2(x-4, 133)]), Color("c2a76c"))
