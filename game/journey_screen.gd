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
	if stage.get("kind", "") == "challenge": return "PHÓ BẢN"
	var rows := chapter_stages(book, stage)
	for i in range(rows.size()):
		if rows[i].id == stage.id: return "%d-%d" % [stage.get("base_stage", stage.id), i + 1]
	return str(stage.id)

static func auto_unlocked(p: Dictionary) -> bool:
	return 7 in p.cleared # Story 1-3 in the current catalogue.

func _ready() -> void:
	custom_minimum_size.x = 492
	add_theme_constant_override("separation", 12)
	var p: Dictionary = game.store.profile
	var stage: Dictionary = game.catalog.find_row("stages", game.selected_stage)
	var chapter: int = stage.get("base_stage", stage.id)
	var rows := chapter_stages(game.catalog, stage)
	var cleared := 0
	for row in rows:
		if row.id in p.cleared: cleared += 1
	text("CHUYẾN ĐI CỦA ÁNH SÁNG", 14, Color("baa77f"))
	var chapter_row: Dictionary = game.catalog.find_row("chapters", chapter)
	text("Chương %d · %s" % [chapter, chapter_row.get("name", stage.name)] if stage.get("kind", "") != "challenge" else stage.name, 22, Color("e5cd9e"))
	progress_text = text("Tiến độ chương · %d/%d ải" % [cleared, rows.size()] if not rows.is_empty() else "Phó bản thử thách", 15)
	var progress := ProgressBar.new()
	progress.custom_minimum_size.y = 10
	progress.show_percentage = false
	progress.value = float(cleared) / maxi(1, rows.size()) * 100
	progress.add_theme_stylebox_override("background", game._style(Color("233c46"), Color("3a5357"), 5))
	progress.add_theme_stylebox_override("fill", game._style(Color("baa064"), Color("d9bd82"), 5))
	add_child(progress)
	var scene := Control.new()
	scene.custom_minimum_size = Vector2(492, 300)
	scene.clip_contents = true
	scene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scene)
	var view := BattleView.new()
	view.setup(game.frames)
	view.preview = game.catalog.stats(p)
	view.selected_stage = stage
	view.home_card = true
	view.position = Vector2(0, -178 * .911)
	view.scale = Vector2.ONE * .911
	scene.add_child(view)
	text("ẢI %s · %s" % [stage_code(game.catalog, stage), "ĐÃ VƯỢT" if stage.id in p.cleared else ("PHÓ BẢN" if stage.get("kind", "") == "challenge" else "STORY")], 14, Color("e5cd9e"))
	text(stage.name, 23, Color("eee6ce"))
	var hero: Dictionary = game.catalog.find_row("heroes", p.hero)
	var spirit: Dictionary = game.catalog.find_row("assists", p.assist)
	text("%s · LV%d  /  %s đồng hành" % [hero.name, p.heroes[p.hero].level, spirit.name], 15)
	var stats: Dictionary = game.catalog.stats(p)
	var power := int(stats.hp + stats.atk * 10 + stats.defense * 6)
	var recommended := int(stage.enemy_hp * 2 + stage.boss_atk * 8)
	text("Lực chiến ước tính · %d  /  Gợi ý %d" % [power, recommended], 15)
	text("Thưởng lần đầu · %d vàng + %d XP + 2 tinh thạch" % [stage.gold + stage.first_gold, stage.xp] if stage.id not in p.cleared else "Đã nhận thưởng lần đầu · Đánh lại: %d vàng + %d XP + 2 tinh thạch" % [stage.gold, stage.xp], 14, Color("e5cd9e"))
	challenge = game._button(self, "THÁCH ĐẤU ẢI " + stage_code(game.catalog, stage), Vector2.ZERO, Vector2(492, 54), game._enter_stage.bind(stage.id))
	challenge.add_theme_stylebox_override("normal", game._style(Color("76603a"), Color("cfb477"), 12))
	challenge.disabled = game._locked() or not game.store.can_enter(stage.id)
	auto_play = game._button(self, "Tự chiến ải này  →" if auto_unlocked(p) else "Tự động vượt ải · Mở sau ải 1-3", Vector2.ZERO, Vector2(492, 46), game._journey_auto)
	auto_play.disabled = not auto_unlocked(p) or challenge.disabled
	var afk: Button = game._button(self, "KHO TIẾP TẾ AFK  →\nTích lũy tối đa 2 giờ · Xem và nhận", Vector2.ZERO, Vector2(492, 66), game._journey_afk)
	afk.add_theme_font_size_override("font_size", 16)
	game.icons.apply(afk, "afk", 34)
	var shortcuts := HBoxContainer.new()
	shortcuts.add_theme_constant_override("separation", 8)
	add_child(shortcuts)
	for entry in [["Bản đồ", 15], ["Đội hình", 1]]:
		game._button(shortcuts, entry[0], Vector2.ZERO, Vector2(242, 52), game._select_tab.bind(entry[1]))

func text(value: String, font_size: int, color: Color = Color("b8c9c2")) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = color
	add_child(label)
	return label
