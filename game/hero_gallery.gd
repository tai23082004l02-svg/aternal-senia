class_name HeroGallery
extends VBoxContainer

var game
var affinity := "All"
var ownership := "All"
var role := "All"
var cards: VBoxContainer
var visible_ids: Array[String] = []

func _ready() -> void:
	custom_minimum_size = Vector2(492, 700)
	add_theme_constant_override("separation", 12)
	game._label(self, tr("HERO GALLERY"), Vector2.ZERO, 26, Color("e5cd9e"))
	game._label(self, tr("Discover the current collection"), Vector2.ZERO, 15)
	var filters := HBoxContainer.new()
	add_child(filters)
	for field in ["affinity", "role", "ownership"]:
		var picker := OptionButton.new()
		picker.name = field.capitalize() + "Filter"
		picker.custom_minimum_size = Vector2(156, 44)
		picker.add_theme_font_size_override("font_size", 14)
		var values: Array[String] = ["All"]
		if field == "ownership": values.append_array(["Owned", "Locked"])
		else:
			for row in game.catalog.data.heroes:
				var value: String = str(row.element if field == "affinity" else row.role)
				if value not in values: values.append(value)
		for value in values:
			var label: String = {"affinity":"All affinities", "role":"All roles", "ownership":"All heroes"}[field] if value == "All" else (value.capitalize() if field == "affinity" else value)
			picker.add_item(tr(label))
		picker.tooltip_text = tr(field.capitalize())
		picker.item_selected.connect(func(index): set_filter(field, values[index]))
		filters.add_child(picker)
	var scroller := SwipeScroll.new()
	scroller.custom_minimum_size = Vector2(492, 550)
	scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroller)
	cards = VBoxContainer.new()
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards.add_theme_constant_override("separation", 12)
	scroller.add_child(cards)
	game._button(self, tr("← Hero management"), Vector2.ZERO, Vector2(492, 44), game._select_tab.bind(1))
	rebuild()

func set_filter(field: String, value: String) -> void:
	if field not in ["affinity", "role", "ownership"]: return
	set(field, value)
	rebuild()

func rebuild() -> void:
	for child in cards.get_children():
		cards.remove_child(child)
		child.queue_free()
	visible_ids.clear()
	var rows: Array = game.catalog.data.heroes.duplicate()
	rows.sort_custom(func(a,b): return a.gallery_order < b.gallery_order)
	for row in rows:
		var owned: bool = game.store.available_hero(row.id)
		if affinity != "All" and row.element != affinity: continue
		if role != "All" and row.role != role: continue
		if ownership == "Owned" and not owned or ownership == "Locked" and owned: continue
		visible_ids.append(row.id)
		var card := HBoxContainer.new()
		card.custom_minimum_size = Vector2(470, 160)
		cards.add_child(card)
		var portrait := TextureRect.new()
		portrait.texture = load(row.art.banner)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		portrait.custom_minimum_size = Vector2(110, 160)
		portrait.clip_contents = true
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if not owned: portrait.modulate = Color(.65,.65,.7)
		card.add_child(portrait)
		var detail := VBoxContainer.new()
		detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_child(detail)
		game._label(detail, row.name + " · 5★", Vector2.ZERO, 20, Color("e5cd9e"))
		game._label(detail, str(row.element).capitalize() + " · " + row.role, Vector2.ZERO, 14)
		game._label(detail, tr("Owned") if owned else tr("Not owned"), Vector2.ZERO, 14)
		var source: Label = game._label(detail, row.acquisition, Vector2.ZERO, 13)
		source.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		source.custom_minimum_size.x = 320
		game._button(detail, tr("View %s") % row.name, Vector2.ZERO, Vector2(320, 40), showcase.bind(row.id))
	if visible_ids.is_empty(): game._label(cards, tr("No heroes match these filters."), Vector2.ZERO, 18)

func showcase(id: String) -> void:
	var row: Dictionary = game.catalog.find_row("heroes", id)
	if row.is_empty(): return
	var column: VBoxContainer = game._dialog(row.name + " · 5★", row.acquisition, [{"text":tr("Hero details"), "call":func(): game._close_modal(); game._open_gallery_hero(id)}, {"text":tr("Close"), "call":game._close_modal}])
	var image := TextureRect.new()
	image.texture = load(row.art.banner)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.custom_minimum_size = Vector2(400, 280)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(image)
	column.move_child(image, 1)
	column.get_child(0).hide()
	column.get_parent().get_parent().position.y = 100
	column.get_parent().get_parent().set_deferred("size", Vector2(472, 720))
