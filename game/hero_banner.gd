class_name HeroBanner
extends HeroPortrait

var artwork: Texture2D
var panel_art := false
var panel_info := false

func _ready() -> void:
	var key := ("character_panel_" if panel_art else "banner_") + hero
	var folder := "character_panels" if panel_art else "banners"
	if not library.textures.has(key):
		var presentation: Dictionary = library.painted.get("presentation", {}).get(hero, {})
		var path: String = "res://art/" + presentation.banner if presentation.has("banner") else "res://art/%s/%s.png" % [folder,hero]
		var source: Texture2D = load(path)
		if panel_art and presentation.has("panel_region"):
			var texture := AtlasTexture.new()
			texture.atlas = source
			var rect: Array = presentation.panel_region
			texture.region = Rect2(rect[0],rect[1],rect[2],rect[3])
			library.textures[key] = texture
		else: library.textures[key] = source
	artwork = library.textures[key]
	super._ready()

func _build_accessories() -> void:
	pass # Banners are single painted images, not the Ryn portrait mesh.

func _draw() -> void:
	if artwork == null: return
	if panel_art:
		draw_rect(Rect2(Vector2.ZERO,size),Color("08212b"))
		var featured: bool = library.painted.get("presentation", {}).has(hero)
		var scale := maxf(size.x/artwork.get_width(),642.0/artwork.get_height()) * (1.08 if panel_info and not featured else 1.0)
		var extent := artwork.get_size()*scale
		draw_texture_rect(artwork,Rect2(Vector2((size.x-extent.x)*.5,-65 if panel_info and not featured else 0),extent),false,palette_tint)
		if interactive and touch_glow > 0:
			draw_arc(pointer_origin,18+(1-touch_glow)*16,0,TAU,40,Color(1,.85,.5,touch_glow*.6),1.5,true)
		return
	var factor := maxf(size.x / artwork.get_width(), size.y / artwork.get_height()) * 1.035
	var dimensions := artwork.get_size() * factor
	var drift := motion * .12 if interactive else Vector2.ZERO
	draw_texture_rect(artwork, Rect2((size-dimensions)*.5+drift, dimensions), false, palette_tint)
	draw_rect(Rect2(Vector2.ONE, size-Vector2.ONE*2), Color("ac9863"), false, 1)
