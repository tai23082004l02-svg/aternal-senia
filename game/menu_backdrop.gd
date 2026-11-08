class_name MenuBackdrop
extends Control
var art: Texture2D = preload("res://art/selena/selena_splash_art.png")
var old_tab := -1
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(540,960)
	z_index = -10
func _process(_delta: float) -> void:
	var current: int = get_parent().tab
	if current != old_tab:
		old_tab = current
		queue_redraw()
func _draw() -> void:
	draw_texture_rect(art,Rect2(-50,0,640,960),false)
	if old_tab != 24: draw_rect(Rect2(0,0,540,960),Color("070e27e8"))
	draw_rect(Rect2(0,0,540,128),Color("080f29dd"))
	draw_rect(Rect2(8,870,524,66),Color("080f29f5"))
	draw_rect(Rect2(0,936,540,24),Color("080f29ff"))
	for x in [8,532]:
		draw_line(Vector2(x,880),Vector2(x,925),Color("a9956355"),1,true)
	for x in [122,221,320,419]:
		draw_line(Vector2(x,884),Vector2(x,924),Color("a9956325"),1,true)
	for y in [126,870,936]:
		draw_line(Vector2(14,y),Vector2(526,y),Color("a9956388"),1,true)
		var c := Vector2(270,y)
		draw_colored_polygon(PackedVector2Array([c+Vector2(-6,0),c+Vector2(0,-3),c+Vector2(6,0),c+Vector2(0,3)]),UIDesignV2.GOLD)
