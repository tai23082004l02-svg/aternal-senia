class_name SummonReveal
extends RefCounted

# Present a deep copy of committed results. No RNG, summon, spending or grants.
static func artwork(game, result: Dictionary) -> Texture2D:
	if result.kind == "hero": return HeroContract.art_texture(game.catalog.find_row("heroes", result.id),"reveal")
	if result.kind == "spirit": return game.frames.textures.get("companion_" + result.id)
	return game.icons.textures.get(result.id, game.icons.textures.get("equipment"))

static func show_batch(game, entries: Array, index: int = 0) -> void:
	var results: Array = entries.duplicate(true)
	if results.is_empty(): return
	if index >= results.size():
		show_summary(game, results)
		return
	var result: Dictionary = results[index]
	var surface := UIDesignV2.overlay(game, "SummonReveal")
	UIDesignV2.text(surface, "SUMMON REVEAL", Vector2(16, 12), Vector2(300, 24), 14, UIDesignV2.GOLD)
	UIDesignV2.text(surface, "%d / %d" % [index + 1, results.size()], Vector2(16, 42), Vector2(100, 24), 14)
	UIDesignV2.button(game, surface, "Skip to summary", Vector2(312, 12), Vector2(164, 44), show_summary.bind(game, results)).name = "RevealSkip"
	var aura := RevealAura.new()
	aura.position = Vector2(8, 60)
	aura.size = Vector2(476, 560)
	aura.animate = not game.presentation_options.reduced_effects and not game.presentation_options.battery_saver
	aura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	surface.add_child(aura)
	var image := UIDesignV2.art(surface, artwork(game, result), Vector2(8, 60), Vector2(476, 550), result.kind == "hero")
	image.name = "RevealArtwork"
	UIDesignV2.shade(surface,Vector2(8,430),Vector2(476,240),Color("0b143000"),Color("0b1430ff"))
	# Header stays above the full illustration.
	surface.move_child(surface.get_child(0),surface.get_child_count()-1)
	surface.move_child(surface.get_child(0),surface.get_child_count()-1)
	surface.move_child(surface.get_child(0),surface.get_child_count()-1)
	if aura.animate:
		image.modulate.a = 0
		image.create_tween().tween_property(image, "modulate:a", 1.0, .35)
	var name_label := UIDesignV2.text(surface, game._entity_name(result.kind, result.id), Vector2(16, 574), Vector2(460, 48), 32)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var rarity := UIDesignV2.text(surface, "★★★★★" if result.kind == "hero" else Recruitment.label(result.kind, result.id, game.catalog), Vector2(16, 544), Vector2(460, 24), 18, UIDesignV2.GOLD)
	rarity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var detail: String = game.tr("Equipment added to your bag.")
	if result.kind != "item": detail = game.tr("Duplicate · 10 matching Fragments") if result.get("duplicate", false) else game.tr("New companion acquired")
	var receipt := UIDesignV2.text(surface, detail, Vector2(16, 638), Vector2(460, 46), 16, UIDesignV2.GOLD)
	receipt.name = "RevealReceipt"
	receipt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if result.kind == "hero":
		var row: Dictionary = game.catalog.find_row("heroes", result.id)
		UIDesignV2.text(surface, str(row.element).capitalize() + " · " + row.role, Vector2(16, 692), Vector2(460, 26), 15, UIDesignV2.MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		UIDesignV2.button(game, surface, "Hero details", Vector2(16, 764), Vector2(216, 52), HeroShowcase.show.bind(game, result.id)).name = "RevealDetails"
	else:
		UIDesignV2.button(game, surface, "Close", Vector2(16, 764), Vector2(216, 52), game._close_modal).name = "RevealClose"
	UIDesignV2.button(game, surface, "Next" if index + 1 < results.size() else "Summary", Vector2(244, 764), Vector2(232, 52), show_batch.bind(game, results, index + 1), true).name = "RevealNext"

## Explicit illustration viewer; never impersonates a committed summon result.
static func show_art_preview(game, id: String) -> void:
	var row := CharacterPreviews.find(id)
	if row.is_empty(): return
	var surface := UIDesignV2.overlay(game,"ArtRevealPreview")
	UIDesignV2.art(surface,load(row.art.banner),Vector2.ZERO,Vector2(492,840))
	var aura := RevealAura.new()
	aura.position = Vector2(8,40)
	aura.size = Vector2(476,530)
	aura.animate = not game.presentation_options.reduced_effects and not game.presentation_options.battery_saver
	aura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	surface.add_child(aura)
	UIDesignV2.shade(surface,Vector2(0,440),Vector2(492,400),Color("0b143000"),Color("0b1430ff"))
	UIDesignV2.shade(surface,Vector2.ZERO,Vector2(492,80),Color("0b1430ee"),Color("0b143000"))
	UIDesignV2.text(surface,"ART PREVIEW · NOT A SUMMON RESULT",Vector2(16,16),Vector2(460,40),13,UIDesignV2.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UIDesignV2.text(surface,row.name,Vector2(16,580),Vector2(460,56),40).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UIDesignV2.text(surface,"Moonlight Mage",Vector2(16,640),Vector2(460,32),18,UIDesignV2.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UIDesignV2.text(surface,"Visual design preview. This character is not recruitable.",Vector2(36,690),Vector2(420,48),15).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UIDesignV2.button(game,surface,"View details",Vector2(16,764),Vector2(216,52),HeroShowcase.show.bind(game,id))
	UIDesignV2.button(game,surface,"Close preview",Vector2(244,764),Vector2(232,52),game._close_modal,true).name = "ArtPreviewClose"

static func show_summary(game, entries: Array) -> void:
	var results: Array = entries.duplicate(true)
	var surface := UIDesignV2.overlay(game, "SummonSummary")
	UIDesignV2.text(surface, "Summon results", Vector2(16, 16), Vector2(460, 42), 30)
	UIDesignV2.text(surface, game.tr("%d rewards received · newest first") % results.size(), Vector2(16, 66), Vector2(460, 30), 15, UIDesignV2.GOLD)
	var scroller := SwipeScroll.new()
	scroller.position = Vector2(16, 112)
	scroller.size = Vector2(460, 544)
	scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	surface.add_child(scroller)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 8)
	scroller.add_child(rows)
	for result in results:
		var line := PanelContainer.new()
		line.custom_minimum_size = Vector2(440, 96)
		line.add_theme_stylebox_override("panel", UIDesignV2.panel())
		rows.add_child(line)
		var content := HBoxContainer.new()
		content.add_theme_constant_override("separation", 12)
		line.add_child(content)
		var image := TextureRect.new()
		image.texture = artwork(game, result)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if result.kind == "hero" else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.custom_minimum_size = Vector2(68, 80)
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(image)
		var description := Label.new()
		description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.add_theme_font_size_override("font_size", 15)
		description.text = game._entity_name(result.kind, result.id) + " · " + Recruitment.label(result.kind, result.id, game.catalog)
		if result.get("duplicate", false): description.text += "\n" + game.tr("Duplicate · 10 matching Fragments")
		elif result.kind != "item": description.text += "\n" + game.tr("New companion")
		content.add_child(description)
	UIDesignV2.button(game, surface, "Close", Vector2(16, 764), Vector2(460, 52), game._close_modal, true).name = "SummaryClose"

class RevealAura extends Control:
	var elapsed := 0.0
	var animate := true
	func _process(delta: float) -> void:
		if not animate: return
		elapsed += delta * .16
		queue_redraw()
	func _draw() -> void:
		var center := size / 2
		for radius in [118.0, 150.0, 183.0]:
			draw_arc(center, radius, 0, TAU, 96, Color(.87,.72,.4,.4), 1, true)
		for i in range(16):
			var angle := TAU * i / 16 + elapsed
			draw_line(center + Vector2.from_angle(angle) * 95, center + Vector2.from_angle(angle) * 194, Color(.87,.72,.4,.24), 1, true)
