class_name HeroBanner
extends HeroPortrait

var artwork: Texture2D

func _ready() -> void:
	var key := "banner_" + hero
	if not library.textures.has(key): library.textures[key] = load("res://art/banners/%s.png" % hero)
	artwork = library.textures[key]
	super._ready()

func _build_accessories() -> void:
	pass # Banners are single painted images, not the Ryn portrait mesh.

func _draw() -> void:
	if artwork == null: return
	var factor := maxf(size.x / artwork.get_width(), size.y / artwork.get_height()) * 1.035
	var dimensions := artwork.get_size() * factor
	var drift := motion * .12 if interactive else Vector2.ZERO
	draw_texture_rect(artwork, Rect2((size-dimensions)*.5+drift, dimensions), false, palette_tint)
	draw_rect(Rect2(Vector2.ONE, size-Vector2.ONE*2), Color("ac9863"), false, 1)
