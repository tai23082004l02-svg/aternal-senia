class_name SummonScreen
extends Control

var game
var draw_one: Button
var draw_ten: Button
var kind_buttons: Array[Button] = []

func _ready() -> void:
	custom_minimum_size = Vector2(492, 610)
	var active: bool = game.summon_kind == 0
	var r := Recruitment.state(game.store.profile)
	if not active:
		var counter := Panel.new()
		counter.position = Vector2(0, 0)
		counter.size = Vector2(304, 72)
		counter.name = "BannerPityCounter"
		counter.add_theme_stylebox_override("panel", game._style(Color("26333f"), Color("bca57a"), 12))
		add_child(counter)
		var key := "premium" if game.summon_kind == 1 else "event"
		game._label(counter, "BẢO HIỂM · " + ("CAO CẤP" if key == "premium" else "SỰ KIỆN"), Vector2(14, 8), 13, Color("e5cd9e"))
		game._label(counter, "%d lượt · Mốc chưa cấu hình" % Recruitment.banner_pity(game.store.profile, key), Vector2(14, 35), 15)
	else:
		game._label(self, "CỔNG TRIỆU HỒI", Vector2(0, 10), 23, Color("e5cd9e"))
		game._label(self, "Chọn banner để bắt đầu", Vector2(0, 44), 14)
	var banner := Panel.new()
	banner.position = Vector2(0, 86)
	banner.size = Vector2(304, 350)
	banner.clip_contents = true
	banner.add_theme_stylebox_override("panel", game._style(Color("152936"), Color("a78b67"), 16))
	add_child(banner)
	var title: String = ["CỔNG BÌNH MINH", "TRIỆU HỒI CAO CẤP", "TRIỆU HỒI SỰ KIỆN"][game.summon_kind]
	game._label(banner, title, Vector2(14, 12), 17, Color("e5cd9e"))
	var portrait := TextureRect.new()
	portrait.texture = game.frames.textures["portrait_ryn"]
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.position = Vector2(12, 31)
	portrait.size = Vector2(280, 285)
	banner.add_child(portrait)
	game._label(banner, "Nhân vật · Tinh linh · Trang bị" if active else "SẮP RA MẮT", Vector2(14, 319), 14, Color("e5cd9e"))
	var captions := ["Triệu hồi\nthường", "Triệu hồi\ncao cấp", "Triệu hồi\nsự kiện"]
	for i in range(3):
		var button: Button = game._button(self, captions[i], Vector2(316, 86 + i * 116), Vector2(176, 102), game._select_summon_kind.bind(i))
		button.add_theme_font_size_override("font_size", 18)
		if i == game.summon_kind: button.add_theme_stylebox_override("normal", game._style(Color("35483c"), Color("ddbf7b"), 12))
		kind_buttons.append(button)
	draw_one = game._button(self, "Triệu hồi ×1\n120 vàng" if active else "Triệu hồi ×1\nChưa mở", Vector2(0, 450), Vector2(146, 66), game._summon_confirm.bind(1))
	draw_ten = game._button(self, "Triệu hồi ×10\n1.200 vàng" if active else "Triệu hồi ×10\nChưa mở", Vector2(158, 450), Vector2(146, 66), game._summon_confirm.bind(10))
	for button in [draw_one, draw_ten]: button.add_theme_font_size_override("font_size", 16)
	draw_one.disabled = not active or game._locked() or game.store.profile.gold < Recruitment.PRICE
	draw_ten.disabled = not active or game._locked() or game.store.profile.gold < Recruitment.PRICE * 10
	var rates: Button = game._button(self, "Tỷ lệ &\nquy tắc", Vector2(316, 450), Vector2(176, 66), game._summon_rates)
	rates.disabled = not active
	var history: Button = game._button(self, "────  Lịch sử triệu hồi  ↑  ────", Vector2(0, 534), Vector2(492, 48), game._summon_history)
	history.tooltip_text = "Mở tối đa 100 lượt gần nhất; mới nhất ở trên"
	game._label(self, "Banner minh họa Ryn · Xem tỷ lệ trước khi quay" if active else "Banner chưa mở; chưa tiêu tài nguyên", Vector2(2, 590), 12, Color("98aaa9"))

static func show_text(game, title: String, text: String) -> void:
	var column: VBoxContainer = game._dialog(title, "", [{"text": "Đóng", "call": game._close_modal}])
	var box: PanelContainer = column.get_parent().get_parent()
	box.position.y = 150
	box.set_deferred("size", Vector2(472, 650))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(400, 420)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var body := Label.new()
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_font_size_override("font_size", 16)
	body.text = text
	scroll.add_child(body)
	column.add_child(scroll)
	column.move_child(scroll, 1)

static func show_results(game, title: String, entries: Array) -> void:
	var lines: Array[String] = []
	for i in range(entries.size()):
		var entry: Dictionary = entries[i]
		var suffix := ""
		if entry["duplicate"]: suffix = " · +10 mảnh" if entry.kind == "hero" else " · +2 lõi"
		lines.append("%d. %s · %s%s" % [i + 1, game._rarity(entry.kind, entry.id), game._entity_name(entry.kind, entry.id), suffix])
	show_text(game, title, "Mới nhất ở trên · Lưu tối đa 100 lượt\n\n" + ("\n\n".join(lines) if not lines.is_empty() else "Chưa có lịch sử triệu hồi."))
