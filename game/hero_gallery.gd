class_name HeroGallery
extends VBoxContainer

const GOLD := Color("dfbd79")
const IVORY := Color("f6eddb")
const MUTED := Color("9aaec2")
var game
var affinity := "All"
var ownership := "All"
var role := "All"
var detailed := false
var cards: GridContainer
var scroller: SwipeScroll
var visible_ids: Array[String] = []
var card_buttons: Dictionary = {}
var affinity_buttons: Dictionary = {}
var pickers: Dictionary = {}
var collection_count: Label
var result_count: Label
var empty_state: Label
var view_button: Button

func _ready() -> void:
	custom_minimum_size = Vector2(492, 700)
	add_theme_constant_override("separation", 10)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	add_child(header)
	var back: Button = game._button(header, "‹", Vector2.ZERO, Vector2(44, 48), game._select_tab.bind(1))
	back.name = "GalleryBack"
	back.tooltip_text = tr("Back to Heroes")
	decorate(back)
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(titles)
	text(titles, "Gallery", 30, IVORY)
	text(titles, "THE HERO COLLECTION", 11, GOLD)
	collection_count = text(header, "", 14, GOLD)
	collection_count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var line := HSeparator.new()
	line.modulate = GOLD
	add_child(line)
	var tabs := SwipeScroll.new()
	tabs.name = "AffinityTabs"
	tabs.custom_minimum_size = Vector2(492, 48)
	tabs.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	add_child(tabs)
	var affinities := HBoxContainer.new()
	affinities.add_theme_constant_override("separation", 6)
	tabs.add_child(affinities)
	var values: Array[String] = ["All"]
	for row in game.catalog.data.heroes:
		if str(row.element) not in values: values.append(str(row.element))
	for value in values:
		var button: Button = game._button(affinities, value.capitalize(), Vector2.ZERO, Vector2(88, 44), set_filter.bind("affinity", value))
		button.add_theme_font_size_override("font_size", 14)
		button.tooltip_text = tr("All affinities") if value == "All" else tr(value.capitalize())
		affinity_buttons[value] = button
	var info := HBoxContainer.new()
	add_child(info)
	result_count = text(info, "", 13, MUTED)
	result_count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text(info, "Tap a portrait to discover", 12, MUTED)
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", game._style(Color("0c172bd9"), Color("4f5369"), 12))
	frame.custom_minimum_size = Vector2(492, 452)
	add_child(frame)
	scroller = SwipeScroll.new()
	scroller.name = "GalleryScroll"
	scroller.custom_minimum_size = Vector2(480, 440)
	scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroller.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	frame.add_child(scroller)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroller.add_child(content)
	cards = GridContainer.new()
	cards.columns = 4
	cards.add_theme_constant_override("h_separation", 8)
	cards.add_theme_constant_override("v_separation", 12)
	content.add_child(cards)
	empty_state = text(content, "No heroes match these filters.\nTry another affinity or reset your filters.", 16, MUTED)
	empty_state.custom_minimum_size = Vector2(456, 200)
	empty_state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_state.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	empty_state.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)
	add_child(controls)
	view_button = game._button(controls, "Details", Vector2.ZERO, Vector2(88, 44), toggle_view)
	view_button.name = "GalleryView"
	view_button.add_theme_font_size_override("font_size", 13)
	view_button.tooltip_text = tr("Switch between compact portraits and detailed cards")
	decorate(view_button)
	for field in ["ownership", "role"]:
		var picker := OptionButton.new()
		picker.name = field.capitalize() + "Filter"
		picker.custom_minimum_size = Vector2(190 if field == "ownership" else 194, 44)
		picker.add_theme_font_size_override("font_size", 13)
		var options: Array[String] = ["All"]
		if field == "ownership": options.append_array(["Owned", "Locked"])
		else:
			for row in game.catalog.data.heroes:
				if str(row.role) not in options: options.append(str(row.role))
		for value in options:
			picker.add_item(tr("All heroes" if field == "ownership" else "All roles") if value == "All" else tr(value))
		picker.set_meta("values", options)
		picker.tooltip_text = tr("Ownership" if field == "ownership" else "Combat role")
		picker.item_selected.connect(func(index): set_filter(field, options[index]))
		controls.add_child(picker)
		pickers[field] = picker
		decorate(picker)
	var footer := HBoxContainer.new()
	add_child(footer)
	var note := text(footer, "Locked heroes can be previewed.", 12, MUTED)
	note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var reset: Button = game._button(footer, "Reset filters", Vector2.ZERO, Vector2(118, 36), reset_filters)
	reset.name = "GalleryReset"
	reset.add_theme_font_size_override("font_size", 12)
	decorate(reset)
	rebuild()

func _draw() -> void:
	draw_style_box(game._style(Color("0b1429ec"), Color("4f5369"), 12), Rect2(Vector2(-6, -4), size + Vector2(12, 8)))

func text(parent: Node, value: String, font_size: int, color: Color) -> Label:
	var item: Label = game._label(parent, tr(value), Vector2.ZERO, font_size, color)
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return item

func decorate(button: BaseButton, selected: bool = false) -> void:
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	button.add_theme_stylebox_override("normal", game._style(Color("234c78") if selected else Color("15243b"), GOLD if selected else Color("52627a"), 8))
	button.add_theme_stylebox_override("hover", game._style(Color("294465"), GOLD, 8))
	button.add_theme_stylebox_override("pressed", game._style(Color("365b83"), GOLD, 8))
	button.add_theme_stylebox_override("focus", game._style(Color("15243b00"), IVORY, 8))
	button.add_theme_color_override("font_color", IVORY)

func set_filter(field: String, value: String) -> void:
	if field not in ["affinity", "role", "ownership"]: return
	set(field, value)
	rebuild()

func reset_filters() -> void:
	affinity = "All"
	ownership = "All"
	role = "All"
	rebuild()

func toggle_view() -> void:
	detailed = not detailed
	view_button.text = tr("Compact" if detailed else "Details")
	rebuild()

func rebuild() -> void:
	for child in cards.get_children():
		cards.remove_child(child)
		child.queue_free()
	visible_ids.clear()
	card_buttons.clear()
	cards.columns = 2 if detailed else 4
	for value in affinity_buttons: decorate(affinity_buttons[value], value == affinity)
	for field in pickers:
		var values: Array = pickers[field].get_meta("values")
		pickers[field].select(maxi(0, values.find(get(field))))
	var rows: Array = game.catalog.data.heroes.duplicate()
	rows.sort_custom(func(a,b): return a.gallery_order < b.gallery_order)
	var owned_count := 0
	for row in rows:
		var owned: bool = game.store.available_hero(row.id)
		if owned: owned_count += 1
		if affinity != "All" and row.element != affinity: continue
		if role != "All" and row.role != role: continue
		if ownership == "Owned" and not owned or ownership == "Locked" and owned: continue
		visible_ids.append(row.id)
		var card := Button.new()
		card.name = "Hero_" + row.id
		card.custom_minimum_size = Vector2(226, 238) if detailed else Vector2(109, 184)
		card.clip_contents = true
		decorate(card)
		var border: StyleBoxFlat = game._style(Color("142039"), GOLD if owned else Color("616b81"), 9)
		border.set_border_width_all(2)
		card.add_theme_stylebox_override("normal", border)
		card.tooltip_text = "%s · %s · %s\n%s\n%s" % [row.name, str(row.element).capitalize(), row.role, tr("Owned" if owned else "Not owned"), row.acquisition]
		card.pressed.connect(game._on_button.bind(showcase.bind(row.id)))
		cards.add_child(card)
		card_buttons[row.id] = card
		var portrait := GalleryPortrait.new()
		portrait.texture = load(row.art.banner)
		portrait.locked = not owned
		portrait.position = Vector2(3, 3)
		portrait.size = Vector2(card.custom_minimum_size.x - 6, 162 if detailed else 121)
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(portrait)
		var badge := text(card, str(row.element).capitalize(), 10, IVORY)
		badge.position = Vector2(7, 7)
		badge.add_theme_stylebox_override("normal", game._style(Color("101a32e8"), Color("82704d"), 4))
		var name_label := text(card, row.name, 15 if detailed else 13, IVORY)
		name_label.position = Vector2(4, 168 if detailed else 125)
		name_label.size = Vector2(card.custom_minimum_size.x - 8, 22)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		var status := text(card, "Owned" if owned else "◇ Locked", 11, Color("a8d8cb") if owned else MUTED)
		status.position = Vector2(4, 192 if detailed else 148)
		status.size.x = card.custom_minimum_size.x - 8
		status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if detailed:
			var role_label := text(card, row.role + " · 5★", 12, GOLD)
			role_label.position = Vector2(4, 215)
			role_label.size.x = card.custom_minimum_size.x - 8
			role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		else:
			var stars := text(card, "★★★★★", 10, GOLD)
			stars.position = Vector2(4, 165)
			stars.size.x = card.custom_minimum_size.x - 8
			stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	collection_count.text = tr("Owned %d / %d") % [owned_count, rows.size()]
	result_count.text = tr("%d heroes shown") % visible_ids.size()
	empty_state.visible = visible_ids.is_empty()
	scroller.scroll_vertical = 0

class GalleryPortrait extends Control:
	var texture: Texture2D
	var locked := false
	func _draw() -> void:
		if texture == null: return
		var dimensions := texture.get_size()
		var height := dimensions.y * .86
		var width := minf(dimensions.x, height * size.x / size.y)
		var source := Rect2(clampf(dimensions.x * .54 - width / 2, 0, dimensions.x - width), 0, width, height)
		draw_texture_rect_region(texture, Rect2(Vector2.ZERO, size), source, Color(.55,.57,.67) if locked else Color.WHITE)
		if locked: draw_rect(Rect2(Vector2.ZERO, size), Color(.06,.08,.18,.18))

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
