class_name ArtThumbnail
extends Control

var library: FrameLibrary
var key := ""
var hero := ""
var weapon := ""
var tint := Color.WHITE

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	if library == null: return
	draw_style_box(_frame(), Rect2(Vector2.ZERO, size))
	if not hero.is_empty():
		library.draw_actor(self, library.frame_at(hero, "idle", 0), Vector2(size.x*.5,size.y*.95), weapon, tint, true, size.y / 320)
	elif library.textures.has(key):
		var inset := 5.0
		var rect := Rect2(Vector2.ONE * inset, size - Vector2.ONE * inset * 2)
		draw_texture_rect(library.textures[key], rect, false, tint)

func _frame() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("142837")
	box.border_color = Color("5c5e50")
	box.set_border_width_all(1)
	box.set_corner_radius_all(12)
	return box
