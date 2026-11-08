class_name JourneyScreen
extends VBoxContainer
var game
var challenge: Button
var auto_play: Button
var progress_text: Label

static func chapter_stages(book: GameCatalog, stage: Dictionary) -> Array:
	var chapter: int = stage.get("base_stage", stage.id)
	var rows := []
	for row in book.data.stages:
		if row.get("kind", "") != "challenge" and (row.id == chapter or row.get("base_stage", -1) == chapter): rows.append(row)
	return rows

static func stage_code(book: GameCatalog, stage: Dictionary) -> String:
	if stage.get("kind", "") == "challenge": return "DUNGEONS"
	var rows := chapter_stages(book, stage)
	for i in range(rows.size()):
		if rows[i].id == stage.id: return "%d-%d" % [stage.get("base_stage", stage.id), i + 1]
	return str(stage.id)

const GOLD := Color("f6d27a")
const IVORY := Color("f8f3e3")
const TEAL := Color("1e6f73")

func _ready() -> void:
	custom_minimum_size.x = 492
	add_theme_constant_override("separation", 10)
	var p: Dictionary = game.store.profile
	var stage: Dictionary = game.catalog.find_row("stages", game.selected_stage)
	var chapter: int = stage.get("base_stage", stage.id)
	var rows := chapter_stages(game.catalog, stage)
	var cleared := 0
	for row in rows:
		if row.id in p.cleared: cleared += 1
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", game._style(Color("08232f"), GOLD.darkened(.25), 20))
	add_child(card)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	card.add_child(content)
	var scene := Control.new()
	scene.custom_minimum_size = Vector2(470, 238)
	scene.clip_contents = true
	scene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(scene)
	var preview := FormationPreview.new()
	preview.frames = game.frames
	preview.book = game.catalog
	preview.profile = p
	preview.stage = stage
	preview.size = Vector2(470, 238)
	scene.add_child(preview)
	var badge := text("STAGE %s · %s" % [stage_code(game.catalog, stage), "CLEARED" if stage.id in p.cleared else ("DUNGEONS" if stage.get("kind", "") == "challenge" else "STORY")], 14, GOLD, content)
	badge.add_theme_stylebox_override("normal", game._style(Color("123b43"), GOLD.darkened(.3), 16))
	var title := text(stage.name, 32, IVORY, content)
	title.set_meta("font_role", "display")
	title.add_theme_font_override("font", UIFonts.font("display"))
	divider(content)
	var spirit: Dictionary = game.catalog.find_row("assists", p.assist)
	var team_names: Array[String] = []
	for id in Formation.state(p, game.catalog).slots:
		if not id.is_empty(): team_names.append(game.catalog.find_row("heroes", id).name)
	text(" / ".join(team_names) + " / " + spirit.name + " accompanying", 14, IVORY, content)
	var power := 0
	for id in Formation.state(p, game.catalog).slots:
		if id.is_empty(): continue
		var member: Dictionary = game.catalog.stats(p, id)
		power += int(member.hp + member.atk * 10 + member.defense * 6)
	var recommended := int(stage.enemy_hp * 2 + stage.boss_atk * 8)
	var stats := HBoxContainer.new()
	stats.alignment = BoxContainer.ALIGNMENT_CENTER
	stats.add_theme_constant_override("separation", 12)
	content.add_child(stats)
	for value in ["Power  %d" % power, "Recommended  %d" % recommended]:
		var pill := text(value, 18, GOLD, stats)
		pill.custom_minimum_size = Vector2(220, 38)
		pill.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		pill.add_theme_stylebox_override("normal", game._style(Color("10383e"), Color("a68e5c"), 18))
	text("First clear: %d Gold · %d XP · 2 Crystals" % [stage.gold + stage.first_gold, stage.xp] if stage.id not in p.cleared else "Replay: %d Gold · %d XP · 2 Crystals" % [stage.gold, stage.xp], 14, IVORY, content)
	var chapter_row: Dictionary = game.catalog.find_row("chapters", chapter)
	text("Chapter %d · %s" % [chapter, chapter_row.get("name", stage.name)] if stage.get("kind", "") != "challenge" else stage.name, 12, Color("a8c2bd"), content)
	progress_text = text("Chapter progress · %d/%d stages" % [cleared, rows.size()] if not rows.is_empty() else "Challenge Dungeon", 12, Color("a8c2bd"), content)
	var progress := ProgressBar.new()
	progress.custom_minimum_size.y = 4
	progress.show_percentage = false
	progress.value = float(cleared) / maxi(1, rows.size()) * 100
	progress.add_theme_stylebox_override("background", game._style(Color("233c46"), Color("3a5357"), 2))
	progress.add_theme_stylebox_override("fill", game._style(GOLD, GOLD, 2))
	content.add_child(progress)
	challenge = game._button(self, "BATTLE", Vector2.ZERO, Vector2(492, 64), game._enter_stage.bind(stage.id))
	challenge.tooltip_text = "Challenge stage " + stage_code(game.catalog, stage)
	style_action(challenge, true)
	game.icons.apply(challenge, "slash", 30)
	challenge.disabled = game._locked() or not game.store.can_enter(stage.id)
	auto_play = game._button(self, "Auto Battle & Ultimate", Vector2.ZERO, Vector2(492, 48), game._journey_auto)
	style_action(auto_play, false)
	auto_play.disabled = challenge.disabled
	var shortcuts := HBoxContainer.new()
	shortcuts.add_theme_constant_override("separation", 8)
	add_child(shortcuts)
	for entry in [["Map", game._select_tab.bind(15), "journey"], ["Formation", game._select_tab.bind(22), "hero"], ["AFK\nUp to 2 hours", game._journey_afk, "afk"]]:
		var button: Button = game._button(shortcuts, entry[0], Vector2.ZERO, Vector2(158, 54), entry[1])
		button.add_theme_font_size_override("font_size", 14)
		button.add_theme_stylebox_override("normal", game._style(Color("10353e"), Color("b59d68"), 14))
		game.icons.apply(button, entry[2], 26)
	divider(self)

func style_action(button: Button, primary: bool) -> void:
	var fill := Color("edc36c") if primary else TEAL.darkened(.22)
	var style: StyleBoxFlat = game._style(fill, Color("ffe5a3"), 16)
	style.set_border_width_all(2)
	style.shadow_color = Color(0.9, .65, .22, .18) if primary else Color(0, .7, .65, .1)
	style.shadow_size = 5
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", game._style(fill.lightened(.12), IVORY, 16))
	button.add_theme_stylebox_override("pressed", game._style(fill.darkened(.18), GOLD, 16))
	button.add_theme_stylebox_override("focus", game._style(Color(0,0,0,0), IVORY, 16))
	button.add_theme_color_override("font_color", Color("352510") if primary else IVORY)
	button.add_theme_color_override("font_hover_color", Color("352510") if primary else IVORY)
	button.add_theme_color_override("font_pressed_color", Color("352510") if primary else IVORY)
	button.add_theme_font_size_override("font_size", 25 if primary else 21)
	var trim := ActionTrim.new()
	trim.primary = primary
	button.add_child(trim)
	trim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	trim.mouse_filter = Control.MOUSE_FILTER_IGNORE

func divider(parent: Node) -> void:
	var ornament := Label.new()
	ornament.text = "──────────  ◇  ──────────"
	ornament.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ornament.add_theme_font_size_override("font_size", 12)
	ornament.modulate = GOLD.darkened(.2)
	ornament.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(ornament)

func text(value: String, font_size: int, color: Color = Color("b8c9c2"), parent: Node = self) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = tr(value)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

class ActionTrim extends Control:
	var primary := false
	func _draw() -> void:
		var ink := Color("fff0ba") if primary else Color("82bbb1")
		ink.a = .65
		var w := size.x
		var h := size.y
		draw_polyline(PackedVector2Array([Vector2(24,5),Vector2(w-24,5),Vector2(w-8,h/2),Vector2(w-24,h-5),Vector2(24,h-5),Vector2(8,h/2),Vector2(24,5)]), ink, 1, true)
		for x in [17.0, w-17]:
			draw_colored_polygon(PackedVector2Array([Vector2(x,h/2-7),Vector2(x+4,h/2),Vector2(x,h/2+7),Vector2(x-4,h/2)]), ink)

class FormationPreview extends Control:
	var frames: FrameLibrary
	var book: GameCatalog
	var profile: Dictionary
	var stage: Dictionary
	var elapsed := 0.0
	func _ready() -> void: mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _process(delta: float) -> void:
		elapsed += delta
		queue_redraw()
	func _draw() -> void:
		draw_texture_rect(frames.textures["bg_" + stage.zone], Rect2(Vector2.ZERO, size), false)
		var slots: Array = Formation.state(profile, book).slots
		var feet := [Vector2(340, 164), Vector2(340, 244), Vector2(156, 164), Vector2(156, 244)]
		for slot in [2, 0, 3, 1]:
			var id: String = slots[slot]
			if id.is_empty(): continue
			var stats := book.stats(profile, id)
			var look: Array = stats.get("look_tint", [1,1,1,1])
			frames.draw_actor(self, frames.frame_at(id, "idle", elapsed), feet[slot], stats.weapon, Color(look[0],look[1],look[2],look[3]), true, .5)
		var spirit := Vector2(270, 100 + sin(elapsed * 2) * 5)
		draw_texture_rect(frames.textures["companion_" + profile.assist], Rect2(spirit - Vector2(30,30), Vector2(60,60)), false)
