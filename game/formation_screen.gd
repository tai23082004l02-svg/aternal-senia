class_name FormationScreen
extends VBoxContainer
var game
var slot := 0
func _ready() -> void:
	custom_minimum_size.x = 492
	add_theme_constant_override("separation", 12)
	game._label(self, "ĐỘI HÌNH · 3 TƯỚNG + 1 TINH LINH", Vector2.ZERO, 21, Color("e5cd9e"))
	var info := Label.new()
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.text = "Chọn ô rồi chọn nhân vật. Không khóa nghề; hàng trước được ưu tiên chịu đòn. Có thể vào trận khi chưa đủ ba tướng."
	add_child(info)
	var f := Formation.state(game.store.profile)
	for i in range(3):
		var id: String = f.slots[i]
		var name: String = game.catalog.find_row("heroes", id).get("name", "Trống")
		var button: Button = game._button(self, ["Hàng trước", "Hàng sau", "Ô hỗ trợ"][i] + " · " + name, Vector2.ZERO, Vector2(492, 55), game._formation_slot.bind(i))
		if not id.is_empty():
			var face := CharacterScreen.Face.new()
			face.frames = game.frames
			face.hero = id
			face.position = Vector2(10, 3)
			face.size = Vector2(48, 48)
			face.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(face)
		if i == slot: button.modulate = Color("f2cf86")
	for hero in game.catalog.data.heroes:
		var owned: bool = game.store.available_hero(hero.id)
		var button: Button = game._button(self, "%s · LV%d%s" % [hero.name, game.store.profile.heroes[hero.id].level, "" if owned else " · Chưa sở hữu"], Vector2.ZERO, Vector2(492, 46), game._formation_assign.bind(slot, hero.id))
		button.disabled = not owned or game._locked()
	game._button(self, "Bỏ nhân vật khỏi ô", Vector2.ZERO, Vector2(492, 42), game._formation_assign.bind(slot, "")).disabled = game._locked()
	game._label(self, "TINH LINH · Không chiếm ô tướng", Vector2.ZERO, 17, Color("e5cd9e"))
	for spirit in game.catalog.data.assists:
		var button: Button = game._button(self, ("✓ " if game.store.profile.assist == spirit.id else "") + spirit.name + " · Hỗ trợ toàn đội", Vector2.ZERO, Vector2(492, 42), game._assist.bind(spirit.id))
		button.disabled = not game.store.available_assist(spirit.id) or game._locked()
	for key in ["auto_ult", "auto_next"]:
		var check := CheckButton.new()
		check.text = "Tự dùng Ultimate" if key == "auto_ult" else "Tự sang ải tiếp khi thắng (dừng trước Boss chương)"
		check.add_theme_font_size_override("font_size", 14)
		check.button_pressed = f[key]
		check.disabled = game._locked()
		check.toggled.connect(game._formation_option.bind(key))
		add_child(check)
	game._button(self, "Nâng cấp nhân vật →", Vector2.ZERO, Vector2(492, 46), game._select_tab.bind(1))
	game._button(self, "Về Hành trình", Vector2.ZERO, Vector2(492, 46), game._select_tab.bind(0))
