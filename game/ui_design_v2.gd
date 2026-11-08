class_name UIDesignV2
extends RefCounted
## Presentation tokens only. Character identity, art and mechanics live elsewhere.
const NAVY := Color("0b1430")
const PANEL := Color("14244a")
const GOLD := Color("efcf88")
const IVORY := Color("f6eddb")
const MUTED := Color("a4b3c9")
const ACCENT := Color("4166c6")
const TYPE_TITLE := 30
const TYPE_BODY := 16
const TYPE_SMALL := 13
const RADIUS := 10
const GUTTER := 24
const SPACE := 8
const HIT := 44

static func panel(primary: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("b47b36") if primary else Color("122345ed")
	style.border_color = GOLD if primary else Color("8e8ba8")
	style.set_border_width_all(2)
	style.border_blend = true
	style.shadow_color = Color("f4b84b26") if primary else Color("02081788")
	style.shadow_size = 5 if primary else 3
	style.set_corner_radius_all(7)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style

static func card_frame(owned: bool) -> StyleBoxFlat:
	var style := panel()
	style.border_color = GOLD if owned else Color("616b81")
	style.set_border_width_all(2)
	return style

static func text(parent: Node, value: String, pos: Vector2, dimensions: Vector2, font_size: int = 16, color: Color = IVORY) -> Label:
	var item := Label.new()
	item.text = parent.tr(value)
	item.position = pos
	item.size = dimensions
	item.add_theme_font_override("font", UIFonts.font("display"))
	item.add_theme_font_size_override("font_size", font_size)
	item.add_theme_color_override("font_color", color)
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(item)
	return item

static func button(game, parent: Node, value: String, pos: Vector2, dimensions: Vector2, action: Callable, primary: bool = false) -> Button:
	var item: Button = game._button(parent, game.tr(value), pos, dimensions, action)
	item.add_theme_font_size_override("font_size", 14)
	item.add_theme_font_override("font", UIFonts.font("display"))
	item.add_theme_stylebox_override("normal", panel(primary))
	item.add_theme_stylebox_override("hover", panel(true))
	item.add_theme_stylebox_override("pressed", panel(true))
	item.add_theme_stylebox_override("focus", panel(true))
	item.add_theme_color_override("font_color", IVORY)
	item.add_theme_color_override("font_shadow_color", Color("050a16"))
	item.add_theme_constant_override("shadow_offset_y", 1)
	ornament(item, primary)
	item.mouse_filter = Control.MOUSE_FILTER_PASS
	return item

static func overlay(game, screen_name: String) -> Control:
	game._close_modal()
	var modal := Control.new()
	modal.name = screen_name
	modal.size = Vector2(540, 960)
	game.ui.add_child(modal)
	game.modal = modal
	var shade := ColorRect.new()
	shade.color = Color("050a16ed")
	shade.size = modal.size
	modal.add_child(shade)
	var surface := Panel.new()
	surface.position = Vector2(24, 24)
	surface.size = Vector2(492, 840)
	surface.add_theme_stylebox_override("panel", panel())
	modal.add_child(surface)
	return surface

static func art(parent: Node, texture: Texture2D, pos: Vector2, dimensions: Vector2, cover: bool = true) -> Artwork:
	var image := Artwork.new()
	image.texture = texture
	image.cover = cover
	image.position = pos
	image.size = dimensions
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image

class Artwork extends Control:
	var texture: Texture2D
	var cover := true
	var focus := Vector2(.54, .12)
	var region := Rect2()
	func _draw() -> void:
		if texture == null: return
		var source_rect := region if region.has_area() else Rect2(Vector2.ZERO, texture.get_size())
		var source := source_rect.size
		if cover:
			var crop := source
			if source.x / source.y > size.x / size.y: crop.x = source.y * size.x / size.y
			else: crop.y = source.x * size.y / size.x
			draw_texture_rect_region(texture, Rect2(Vector2.ZERO, size), Rect2(source_rect.position + (source - crop) * focus, crop))
		else:
			var dimensions := source * minf(size.x / source.x, size.y / source.y)
			draw_texture_rect(texture, Rect2((size - dimensions) / 2, dimensions), false)

## Vector ornaments stay crisp at phone scale; all labels remain live controls.
static func ornament(parent: Control, bright: bool = false) -> void:
	if parent.has_node("CelestialTrim"): return
	var trim := CelestialTrim.new()
	trim.name = "CelestialTrim"
	trim.bright = bright
	trim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(trim)
	trim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

class CelestialTrim extends Control:
	var bright := false
	func _draw() -> void:
		var c := Color("ffe4a5") if bright else Color("c6ad7899")
		var w := size.x
		var h := size.y
		# Glass highlight and inner gold bevel, with transparent center for text.
		draw_polygon(PackedVector2Array([Vector2(8,3),Vector2(w-8,3),Vector2(w-3,h*.46),Vector2(3,h*.46)]),PackedColorArray([Color(1,.88,.6,.13),Color(1,.88,.6,.13),Color(.4,.6,1,0),Color(.4,.6,1,0)]))
		draw_line(Vector2(12,h-4),Vector2(w-12,h-4),Color("f9d98744"),1,true)
		for x in [5.0,w-5]:
			var sign_x := 1.0 if x < w/2 else -1.0
			for y in [5.0,h-5]:
				var sign_y := 1.0 if y < h/2 else -1.0
				draw_polyline(PackedVector2Array([Vector2(x,y+sign_y*10),Vector2(x,y),Vector2(x+sign_x*10,y)]),c,1,true)
		if w > 110:
			for y in [2.0,h-2]:
				var center := Vector2(w/2,y)
				draw_colored_polygon(PackedVector2Array([center+Vector2(-4,0),center+Vector2(0,-2),center+Vector2(4,0),center+Vector2(0,2)]),c)

static func shade(parent: Node, pos: Vector2, dimensions: Vector2, top: Color, bottom: Color) -> void:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([top,bottom])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(.5,0)
	texture.fill_to = Vector2(.5,1)
	var rect := TextureRect.new()
	rect.texture = texture
	rect.position = pos
	rect.size = dimensions
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)

static func glyph(parent: Node, key: String, pos: Vector2, dimensions: Vector2) -> MenuGlyph:
	var icon := MenuGlyph.new()
	icon.key = key
	icon.position = pos
	icon.size = dimensions
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(icon)
	return icon

class MenuGlyph extends Control:
	var key := "summon"
	func stroke(points: Array, color: Color = GOLD, width: float = 1.8) -> void:
		var path := PackedVector2Array()
		for point in points: path.append(Vector2(point[0],point[1]) * size / 40.0)
		draw_polyline(path,color,width,true)
	func _draw() -> void:
		var center := size/2
		# A faint halo belongs to the menu symbol, never to the hit area.
		draw_circle(center,minf(size.x,size.y)*.43,Color("e4b9650b"))
		match key:
			"hero":
				draw_arc(Vector2(.5,.31)*size,size.x*.14,0,TAU,24,GOLD,1.8,true)
				stroke([[9,32],[11,25],[17,22],[20,25],[23,22],[29,25],[31,32],[9,32]])
				stroke([[5,18],[5,8],[13,4]],Color("fbe5b9aa"),1)
				stroke([[35,18],[35,8],[27,4]],Color("fbe5b9aa"),1)
			"summon":
				stroke([[20,2],[24,15],[37,20],[24,24],[20,38],[16,24],[3,20],[16,15],[20,2]])
				stroke([[20,10],[23,20],[20,30],[17,20],[20,10]],IVORY,1)
			"journey":
				stroke([[5,31],[11,19],[17,25],[24,11],[36,31],[5,31]])
				stroke([[24,11],[24,3],[34,6],[24,9]],IVORY,1.4)
				stroke([[10,35],[30,35]],GOLD,1)
			"quest", "journal":
				stroke([[8,7],[17,7],[20,10],[23,7],[32,7],[32,32],[23,32],[20,35],[17,32],[8,32],[8,7]])
				stroke([[20,10],[20,30]],IVORY,1)
				stroke([[11,14],[16,14]],GOLD,1)
				stroke([[24,14],[29,14]],GOLD,1)
			"gold", "gift":
				stroke([[6,15],[34,15],[34,23],[6,23],[6,15]])
				stroke([[9,23],[9,34],[31,34],[31,23]])
				stroke([[20,15],[20,34]],IVORY,2)
				stroke([[20,15],[11,12],[12,6],[17,7],[20,15],[23,7],[28,6],[29,12],[20,15]])
			"equipment", "boss":
				stroke([[10,5],[30,28],[33,26],[35,30],[29,35],[25,32],[28,29],[7,8],[10,5]])
				stroke([[30,5],[10,28],[7,26],[5,30],[11,35],[15,32],[12,29],[33,8],[30,5]])
			"settings":
				for i in range(8):
					var angle := TAU*i/8
					draw_line(center+Vector2.from_angle(angle)*size.x*.29,center+Vector2.from_angle(angle)*size.x*.42,GOLD,3,true)
				draw_arc(center,size.x*.27,0,TAU,32,GOLD,1.8,true)
				draw_arc(center,size.x*.1,0,TAU,24,IVORY,1.8,true)
			_:
				stroke([[6,16],[10,7],[30,7],[34,16],[6,16],[6,21],[34,21],[34,16]])
				stroke([[9,21],[9,34],[31,34],[31,21]])
				stroke([[17,34],[17,26],[23,26],[23,34]],IVORY,1.4)

class HomeCrest extends Control:
	var primary := false
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		var c := Vector2(size.x/2,49 if primary else 48)
		var radius := 55.0 if primary else 45.0
		if primary:
			for i in range(10):
				draw_circle(c,radius+20-i*2,Color(1,.66,.18,.012+i*.001))
		var points := PackedVector2Array([c+Vector2(0,-radius),c+Vector2(radius,0),c+Vector2(0,radius),c+Vector2(-radius,0)])
		draw_polygon(points,PackedColorArray([Color("ffd57b") if primary else Color("385c9c"),Color("b67b29") if primary else Color("122c56"),Color("dca844") if primary else Color("0b1a36"),Color("dcb567") if primary else Color("243f72")]))
		var edge := points.duplicate()
		edge.append(points[0])
		draw_polyline(edge,Color("ffe3a1") if primary else Color("a8b5d2"),2,true)
		var inner := PackedVector2Array()
		for point in points: inner.append(c+(point-c)*.82)
		inner.append(inner[0])
		draw_polyline(inner,Color("fff0bd99") if primary else Color("668ec199"),1,true)
		for direction in [-1,1]:
			var p := c+Vector2(direction*radius,0)
			draw_colored_polygon(PackedVector2Array([p+Vector2(-4,0),p+Vector2(0,-6),p+Vector2(4,0),p+Vector2(0,6)]),GOLD)
		draw_line(c+Vector2(0,-radius-7),c+Vector2(0,-radius+9),Color("fff4d9"),1,true)
		draw_line(c+Vector2(-6,-radius+1),c+Vector2(6,-radius+1),Color("fff4d9"),1,true)
