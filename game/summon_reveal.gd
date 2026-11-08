class_name SummonReveal
extends RefCounted

# Presentation owns a copy of already committed results, never a summon request.
static func show_batch(game, entries: Array, index: int = 0) -> void:
	var results: Array = entries.duplicate(true)
	if results.is_empty(): return
	if index >= results.size():
		show_summary(game, results)
		return
	var result: Dictionary = results[index]
	var title: String = game._entity_name(result.kind, result.id)
	var detail: String = game.tr("Equipment added to your bag.")
	if result.kind != "item": detail = game.tr("Duplicate · 10 matching Fragments") if result.get("duplicate", false) else game.tr("New companion acquired")
	var column: VBoxContainer = game._dialog("%d / %d · %s" % [index + 1, results.size(), title], Recruitment.label(result.kind,result.id,game.catalog) + "\n" + detail, [
		{"text":game.tr("Next") if index + 1 < results.size() else game.tr("Summary"), "call":show_batch.bind(game,results,index+1)},
		{"text":game.tr("Skip to summary"), "call":show_summary.bind(game,results)}])
	column.get_child(0).hide()
	var image := TextureRect.new()
	image.name = "RevealArtwork"
	if result.kind == "hero": image.texture = load(game.catalog.find_row("heroes", result.id).art.banner)
	elif result.kind == "spirit": image.texture = game.frames.textures.get("companion_" + result.id)
	else: image.texture = game.icons.textures.get(result.id, game.icons.textures.get("equipment"))
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.custom_minimum_size = Vector2(400, 300)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(image)
	column.move_child(image, 1)
	column.get_parent().get_parent().position.y = 100
	column.get_parent().get_parent().set_deferred("size", Vector2(472, 720))
	image.modulate.a = 0
	image.create_tween().tween_property(image, "modulate:a", 1.0, .3)

static func show_summary(game, entries: Array) -> void:
	var column: VBoxContainer = game._dialog(game.tr("SUMMON RESULTS"), game.tr("%d rewards received · newest first") % entries.size(), [{"text":game.tr("Close"), "call":game._close_modal}])
	column.get_child(0).hide()
	column.get_child(2).size_flags_vertical = Control.SIZE_FILL
	var scroller := SwipeScroll.new()
	scroller.custom_minimum_size = Vector2(400, 420)
	scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 12)
	scroller.add_child(rows)
	for result in entries:
		var line := HBoxContainer.new()
		rows.add_child(line)
		var image := TextureRect.new()
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.custom_minimum_size = Vector2(64, 72)
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if result.kind == "hero": image.texture = load(game.catalog.find_row("heroes", result.id).art.banner)
		elif result.kind == "spirit": image.texture = game.frames.textures.get("companion_" + result.id)
		else: image.texture = game.icons.textures.get(result.id, game.icons.textures.get("equipment"))
		line.add_child(image)
		var description := Label.new()
		description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.add_theme_font_size_override("font_size", 16)
		description.text = game._entity_name(result.kind,result.id) + " · " + Recruitment.label(result.kind,result.id,game.catalog)
		if result.get("duplicate",false): description.text += "\n" + game.tr("Duplicate · 10 matching Fragments")
		elif result.kind != "item": description.text += "\n" + game.tr("New companion")
		line.add_child(description)
	column.add_child(scroller)
	column.move_child(scroller, column.get_child_count()-2)
	column.get_parent().get_parent().position.y = 100
	column.get_parent().get_parent().set_deferred("size",Vector2(472,720))
