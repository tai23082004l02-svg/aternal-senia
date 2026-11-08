class_name MissionScreen
extends VBoxContainer
var game
var tabs: Array[Button] = []
var chest_buttons: Dictionary = {}
var claim_buttons: Dictionary = {}
var shown_key := -1
var refresh_clock := 0.0
const GOLD := Color("e7c277")

func _ready() -> void:
	custom_minimum_size.x = 492
	add_theme_constant_override("separation", 10)
	var heading := words(self, "MISSIONS & REWARDS", 23, Color("ffe3a0"))
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var rule := GoldRule.new()
	rule.custom_minimum_size.y = 8
	add_child(rule)
	var strip := HBoxContainer.new()
	strip.add_theme_constant_override("separation", 6)
	add_child(strip)
	for i in range(3):
		var button: Button = game._button(strip, ["Daily", "Weekly", "Progress"][i], Vector2.ZERO, Vector2(160, 46), game._mission_tab.bind(i))
		button.add_theme_font_size_override("font_size", 16)
		game.icons.apply(button, ["daily", "weekly", "achievement"][i], 23)
		button.add_theme_stylebox_override("normal", frame(Color("4e4025") if i == game.mission_tab else Color("102c39"), GOLD if i == game.mission_tab else Color("8a7954"), i == game.mission_tab))
		if i == game.mission_tab: button.add_theme_color_override("font_color", Color("ffe8ad"))
		tabs.append(button)
	if game.mission_tab == 2:
		permanent()
		return
	var period := "daily" if game.mission_tab == 0 else "weekly"
	var state := MissionBoard.state(game.store.profile)
	var section: Dictionary = state[period]
	shown_key = int(section.key)
	var points := MissionBoard.points(section, period)
	var board := OrnatePanel.new()
	board.forest = game.frames.textures["bg_forest"]
	board.add_theme_stylebox_override("panel", frame(Color("102b34"), GOLD))
	add_child(board)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	board.add_child(content)
	icon_line(content, "light", "Activity %s · %d/100" % ["today" if period == "daily" else "this week", points], 18, GOLD)
	var progress := ActivityBar.new()
	progress.value = points
	progress.custom_minimum_size.y = 14
	progress.show_percentage = false
	progress.add_theme_stylebox_override("background", bar_style(Color("08212c"), Color("a1b5b4")))
	var fill := bar_style(Color("e7b948"), Color("fff0a8"))
	fill.shadow_color = Color(1, .65, .16, .35)
	fill.shadow_size = 6
	progress.add_theme_stylebox_override("fill", fill)
	content.add_child(progress)
	var chests := HBoxContainer.new()
	chests.add_theme_constant_override("separation", 6)
	content.add_child(chests)
	for threshold in MissionBoard.CHESTS:
		chest_buttons[threshold] = chest(chests, period, threshold, points >= threshold, threshold in section.chests)
	var reward := MissionBoard.chest_reward(period, 100)
	icon_line(content, "gift", "100-point reward: %d Gold · %d Crystals · %d VIP EXP" % [reward.gold, reward.shards, reward.vip], 12, GOLD)
	icon_line(content, "daily", "Resets daily at 00:00 UTC" if period == "daily" else "Resets Monday at 00:00 UTC", 12)
	icon_line(content, "vip_exp", "VIP EXP: %d · Level thresholds pending" % state.vip_exp, 12)
	var done := 0
	for task in MissionBoard.TASKS[period]:
		if section.counts[task.id] >= task.target: done += 1
	var ribbon := OrnatePanel.new()
	ribbon.add_theme_stylebox_override("panel", frame(Color("0e2935"), Color("af935a")))
	add_child(ribbon)
	var summary := words(ribbon, "Completed %d/5 · +20 Activity per mission" % done, 14, Color("f5dba5"))
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for task in MissionBoard.TASKS[period]:
		var count: int = section.counts[task.id]
		var claimed: bool = task.id in section.claimed
		var ready: bool = count >= task.target
		var reward_text := "%d/%d · %d Gold · %d Crystals · %d VIP EXP" % [count, task.target, task.gold, task.shards, task.vip]
		claim_buttons[task.id] = card(task.name, reward_text, "Claimed" if claimed else ("Claim Rewards" if ready else "Go"), game._mission_claim.bind(period, task.id) if ready else game._mission_go.bind(task.id), claimed or game._locked(), {"offline":"afk","wins":"slash","kills":"boss","enhance":"training","summon":"summon"}[task.id], count, task.target, claimed, ready, true)

func chest(parent: Control, period: String, threshold: int, reached: bool, claimed: bool) -> Button:
	var button: Button = game._button(parent, "", Vector2.ZERO, Vector2(86, 122), game._mission_chest.bind(period, threshold))
	var ready := reached and not claimed
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_stylebox_override("normal", frame(Color("173b30") if ready else Color("122e3d"), GOLD if ready else Color("9c895e"), ready))
	button.tooltip_text = "%d points · %s" % [threshold, "Claimed" if claimed else ("Claim Gift" if reached else "Not reached")]
	var body := VBoxContainer.new()
	body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	body.offset_left = 5
	body.offset_right = -5
	body.offset_top = 6
	body.offset_bottom = -6
	body.add_theme_constant_override("separation", 4)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(body)
	var picture := icon(body, "chest_open" if claimed else "chest", 51)
	picture.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var caption := words(body, "%d points" % threshold, 14, Color("ffdfa1") if reached else Color("e0e6df"))
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var status := words(body, "✓ Claimed" if claimed else ("Claim Gift" if reached else "Not reached"), 11, Color("bceac6") if reached else Color("abbec5"))
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_stylebox_override("normal", frame(Color("244d31") if reached else Color("29414d"), Color("80af70") if reached else Color("627c84"), false, 7, 3))
	return button

func permanent() -> void:
	words(self, "JOURNEY PROGRESS · PERMANENT REWARDS", 13, GOLD)
	for quest in game.catalog.data.quests:
		var count: int = mini(game.store.profile.metrics[quest.metric], quest.target)
		var claimed: bool = quest.id in game.store.profile.claimed
		var ready: bool = count >= quest.target
		claim_buttons[quest.id] = card(quest.name, "%d/%d · %d Gold · %d Crystals" % [count, quest.target, quest.gold, quest.shards], "Claimed" if claimed else ("Claim Rewards" if ready else "Not reached"), game._quest.bind(quest.id), claimed or not ready or game.store.read_only, "achievement", count, quest.target, claimed, ready, false)
	var collection: Button = game._button(self, "Collection & Achievements →", Vector2.ZERO, Vector2(492, 46), game._select_tab.bind(8))
	game.icons.apply(collection, "achievement", 25)

func card(title: String, reward: String, action: String, callback: Callable, disabled: bool, picture: String, count: int, target: int, claimed: bool, ready: bool, activity: bool) -> Button:
	var box := OrnatePanel.new()
	box.add_theme_stylebox_override("panel", frame(Color("102e39"), Color("c9aa69") if ready else Color("8e805f")))
	box.custom_minimum_size.y = 88
	add_child(box)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)
	var artwork := icon(row, picture, 47)
	artwork.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	body.add_theme_constant_override("separation", 6)
	row.add_child(body)
	words(body, title, 17, Color("f5e7c8"))
	words(body, reward, 11, Color("b8d0cf"))
	if not ready:
		var progress := ProgressBar.new()
		progress.show_percentage = false
		progress.custom_minimum_size.y = 8
		progress.value = float(count) / maxi(1, target) * 100
		progress.add_theme_stylebox_override("background", bar_style(Color("08212b"), Color("72959b")))
		progress.add_theme_stylebox_override("fill", bar_style(Color("d9b665"), Color("f5db94")))
		body.add_child(progress)
	var actions := VBoxContainer.new()
	actions.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	actions.custom_minimum_size.x = 112
	row.add_child(actions)
	if activity:
		var points := words(actions, "✦ +20", 14, GOLD)
		points.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var button: Button = game._button(actions, action, Vector2.ZERO, Vector2(112, 40), callback)
	button.add_theme_font_size_override("font_size", 13)
	button.disabled = disabled
	var fill := Color("24502f") if claimed else (Color("79602c") if ready else Color("254655"))
	var border := Color("8ab66a") if claimed else (GOLD if ready else Color("91adbc"))
	button.add_theme_stylebox_override("normal", frame(fill, border, ready and not disabled, 10, 6))
	button.add_theme_stylebox_override("disabled", frame(fill.darkened(.2), border.darkened(.2), false, 10, 6))
	button.add_theme_color_override("font_disabled_color", Color("b4d2bb") if claimed else Color("8ea1a6"))
	return button

func icon(parent: Node, key: String, size_px: int) -> TextureRect:
	var picture := TextureRect.new()
	picture.texture = game.icons.textures[key]
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.custom_minimum_size = Vector2.ONE * size_px
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(picture)
	return picture

func icon_line(parent: Node, key: String, value: String, font_size: int, color: Color = Color("c7d7d0")) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 7)
	parent.add_child(row)
	icon(row, key, 19)
	var label := words(row, value, font_size, color)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func words(parent: Node, value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = color
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func frame(fill: Color, border: Color, glow: bool = false, radius: int = 12, inset: int = 12) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = inset
	style.content_margin_right = inset
	style.content_margin_top = 9 if inset > 6 else inset
	style.content_margin_bottom = 9 if inset > 6 else inset
	if glow:
		style.shadow_color = Color(1, .64, .16, .35)
		style.shadow_size = 7
	return style

func bar_style(fill: Color, border: Color) -> StyleBoxFlat:
	return frame(fill, border, false, 7, 0)

func _process(delta: float) -> void:
	if game.mission_tab == 2: return
	refresh_clock += delta
	if refresh_clock < 1: return
	refresh_clock = 0
	var period := "daily" if game.mission_tab == 0 else "weekly"
	if int(MissionBoard.state(game.store.profile)[period].key) != shown_key: game._refresh_panel()

class GoldRule extends Control:
	func _draw() -> void:
		var center := size * .5
		var gold := Color("d9b66d")
		draw_line(Vector2(size.x * .18, center.y), Vector2(size.x * .44, center.y), gold, 1, true)
		draw_line(Vector2(size.x * .56, center.y), Vector2(size.x * .82, center.y), gold, 1, true)
		draw_colored_polygon(PackedVector2Array([center+Vector2(0,-4), center+Vector2(5,0), center+Vector2(0,4), center+Vector2(-5,0)]), gold)

class OrnatePanel extends PanelContainer:
	var forest: Texture2D
	func _draw() -> void:
		if forest != null:
			draw_texture_rect(forest, Rect2(Vector2(5,5), size-Vector2(10,10)), false, Color(1,1,1,.14))
		var color := Color("dabb79")
		for corner in [Vector2(5,5),Vector2(size.x-5,5),Vector2(5,size.y-5),size-Vector2(5,5)]:
			var direction := Vector2(1 if corner.x < size.x * .5 else -1, 1 if corner.y < size.y * .5 else -1)
			draw_polyline(PackedVector2Array([corner+Vector2(direction.x*16,0),corner+Vector2(direction.x*5,0),corner+Vector2(0,direction.y*5),corner+Vector2(0,direction.y*16)]), color, 1, true)

class ActivityBar extends ProgressBar:
	func _draw() -> void:
		if value <= 0: return
		var point := Vector2(clampf(size.x * value / 100, 4, size.x-4), size.y*.5)
		draw_circle(point, 3, Color("fff1b7"))
		draw_line(point-Vector2(0,6),point+Vector2(0,6),Color("ffe8a5"),1,true)
