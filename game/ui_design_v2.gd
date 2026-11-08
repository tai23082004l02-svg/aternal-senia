class_name UIDesignV2
extends RefCounted
## Presentation tokens only. Character identity, art and mechanics live elsewhere.
const NAVY := Color("0c152b")
const PANEL := Color("14233c")
const GOLD := Color("dfbd79")
const IVORY := Color("f6eddb")
const MUTED := Color("a4b3c9")
const ACCENT := Color("31557f")
const TYPE_TITLE := 30
const TYPE_BODY := 16
const TYPE_SMALL := 13
const RADIUS := 10
const GUTTER := 24
const SPACE := 8
const HIT := 44

static func panel(primary: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("79552b") if primary else PANEL
	style.border_color = GOLD if primary else Color("596881")
	style.set_border_width_all(1)
	style.set_corner_radius_all(RADIUS)
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
	surface.position = Vector2(24, 96)
	surface.size = Vector2(492, 768)
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
