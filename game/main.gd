extends Node2D

const Catalog = preload("res://game/core/catalog.gd")
const Store = preload("res://game/core/progress.gd")
const Battle = preload("res://game/core/battle.gd")
const Frames = preload("res://game/core/frame_library.gd")
const View = preload("res://game/battle_view.gd")
var catalog: GameCatalog
var store: ProgressStore
var battle: BattleModel
var frames: FrameLibrary
var view: BattleView
var ui: Control
var wallet: Label
var status_label: Label
var stage_label: Label
var hp_label: Label
var enemy_label: Label
var warning_label: Label
var hp_bar: ProgressBar
var enemy_bar: ProgressBar
var sp_bar: ProgressBar
var skill_buttons: Array[Button] = []
var guard_button: Button
var attack_button: Button
var pause_button: Button
var auto_button: Button
var speed_button: Button
var mute_button: Button
var tabs: Array[Button] = []
var panel: VBoxContainer
var tab := 0
var selected_stage := 1
var selected_item := ""
var modal: Control
var result_shown := false
var message := ""
var message_time := 0.0
var audio_players: Array[AudioStreamPlayer] = []
var sounds: Dictionary = {}
var last_audio_id := 0
var scroll: ScrollContainer
var tap_target: Button
var details_paused := false

func _ready() -> void:
	catalog = Catalog.new()
	if not catalog.errors.is_empty():
		push_error(str(catalog.errors))
		return
	store = Store.new(catalog)
	frames = Frames.new()
	view = View.new()
	view.setup(frames)
	add_child(view)
	view.preview = catalog.stats(store.profile)
	view.selected_stage = catalog.data.stages[0]
	for key in ["hit", "heal", "win", "hurt"]:
		sounds[key] = load("res://art/" + key + ".wav")
	for i in range(4):
		var player := AudioStreamPlayer.new()
		player.volume_db = -12
		add_child(player)
		audio_players.append(player)
	_build_ui()
	_refresh_panel()
	if store.read_only:
		_dialog("Tiến trình được bảo vệ", store.error, [{"text": "Đã hiểu", "call": _close_modal}])
	elif not store.profile.pending.is_empty():
		_dialog("Trận chưa hoàn tất", "Tiếp tục sẽ chạy lại từ đầu trận với cùng nhân vật, trang bị và hạt ngẫu nhiên đã lưu.", [{"text": "Tiếp tục", "call": _resume}, {"text": "Bỏ trận · không thưởng", "call": _abandon}])
	else:
		_notify("Chọn một khu vực để bắt đầu. Tap nhân vật hoặc nút Đánh để nối combo.")

func _build_ui() -> void:
	ui = Control.new()
	ui.size = Vector2(540, 960)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var theme := Theme.new()
	theme.default_font_size = 16
	var normal := _style(Color("192d3b"), Color("3a505a"), 10)
	var hover := _style(Color("304953"), Color("bca57a"), 10)
	theme.set_stylebox("normal", "Button", normal)
	theme.set_stylebox("hover", "Button", hover)
	theme.set_stylebox("pressed", "Button", _style(Color("425951"), Color("d8c69d"), 10))
	theme.set_stylebox("disabled", "Button", _style(Color("14232f"), Color("283943"), 10))
	theme.set_color("font_color", "Button", Color("ede5d0"))
	theme.set_color("font_disabled_color", "Button", Color("74858c"))
	theme.set_color("font_color", "Label", Color("dedfd5"))
	ui.theme = theme
	add_child(ui)
	_label(ui, "FIRST LIGHT", Vector2(24, 22), 30, Color("ecdfbc"))
	_label(ui, "ATERNAL SENIA  /  HÀNH TRÌNH BÌNH MINH", Vector2(25, 61), 12, Color("93b0ae"))
	wallet = _label(ui, "", Vector2(24, 96), 17, Color("e1c38d"))
	mute_button = _button(ui, "Âm: bật", Vector2(422, 25), Vector2(94, 34), _toggle_sound)
	stage_label = _label(ui, "", Vector2(24, 143), 19, Color("eee8d6"))
	var tap := Button.new()
	tap_target = tap
	tap.position = Vector2(50, 250)
	tap.size = Vector2(200, 255)
	tap.flat = true
	tap.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tap.pressed.connect(_attack)
	ui.add_child(tap)
	hp_label = _label(ui, "", Vector2(24, 510), 13)
	enemy_label = _label(ui, "", Vector2(286, 510), 13)
	hp_bar = _bar(Vector2(24, 535), Vector2(226, 7), Color("86cfb9"))
	enemy_bar = _bar(Vector2(286, 535), Vector2(230, 7), Color("d49a99"))
	sp_bar = _bar(Vector2(24, 548), Vector2(226, 4), Color("a1badb"))
	warning_label = _label(ui, "", Vector2(24, 562), 14, Color("efba8f"))
	for i in range(3):
		skill_buttons.append(_button(ui, "", Vector2(24 + i * 166, 590), Vector2(160, 52), _skill.bind(i)))
	attack_button = _button(ui, "Đánh", Vector2(24, 651), Vector2(82, 36), _attack)
	guard_button = _button(ui, "Thủ thế", Vector2(112, 651), Vector2(113, 36), _guard)
	auto_button = _button(ui, "Tự đánh", Vector2(231, 651), Vector2(99, 36), _toggle_auto)
	pause_button = _button(ui, "Dừng", Vector2(336, 651), Vector2(90, 36), _toggle_pause)
	speed_button = _button(ui, "×1", Vector2(432, 651), Vector2(84, 36), _speed)
	for i in range(5):
		tabs.append(_button(ui, ["Hành trình", "Nhân vật", "Trang bị", "Nhiệm vụ", "Nhật ký"][i], Vector2(24 + i * 99, 706), Vector2(93, 38), _select_tab.bind(i)))
	scroll = ScrollContainer.new()
	scroll.position = Vector2(24, 758)
	scroll.size = Vector2(492, 151)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ui.add_child(scroll)
	panel = VBoxContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_constant_override("separation", 9)
	scroll.add_child(panel)
	status_label = _label(ui, "", Vector2(24, 923), 12, Color("9bb5b3"))
	status_label.size = Vector2(492, 32)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _style(fill: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style

func _label(parent: Node, text: String, pos: Vector2 = Vector2.ZERO, font_size: int = 16, color: Color = Color("dedfd5")) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = color
	parent.add_child(label)
	return label

func _button(parent: Node, text: String, pos: Vector2, dimensions: Vector2, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.custom_minimum_size = dimensions
	button.size = dimensions
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _bar(pos: Vector2, dimensions: Vector2, color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = pos
	bar.show_percentage = false
	var background := StyleBoxFlat.new()
	background.bg_color = Color("233944")
	background.set_corner_radius_all(3)
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	ui.add_child(bar)
	bar.size = dimensions
	return bar

func _physics_process(delta: float) -> void:
	if store == null or ui == null:
		return
	if battle != null:
		battle.advance(delta)
		if battle.state in ["won", "lost"] and not result_shown:
			_finish()
		_play_events()
	_refresh_hud()
	message_time = maxf(0, message_time - delta)
	status_label.text = message if message_time > 0 else "Tự đánh + tap combo · Thủ thế giảm 80% sát thương trong 0,7 giây"

func _refresh_hud() -> void:
	var p: Dictionary = store.profile
	wallet.text = "%d VÀNG     %d TINH THẠCH     %d KINH NGHIỆM" % [p.gold, p.shards, p.xp]
	var active := battle != null
	var stats: Dictionary = battle.stats if active else catalog.stats(p)
	var hero := catalog.find_row("heroes", stats.hero)
	hp_label.text = "%s · %d / %d HP" % [hero.name, battle.hp if active else stats.hp, stats.hp]
	hp_bar.value = (battle.hp if active else stats.hp) / stats.hp * 100
	enemy_label.text = "%s · %d / %d" % [(battle.stage.boss if battle.wave == 2 else "Bóng tối") if active else "Bóng tối", battle.enemy_hp if active else 55, battle.enemy_max if active else 55]
	enemy_bar.value = battle.enemy_hp / battle.enemy_max * 100 if active else 100
	sp_bar.value = battle.sp if active else 100
	stage_label.text = "%02d / %s%s" % [selected_stage, catalog.find_row("stages", selected_stage).name, (" · %d/3" % (battle.wave + 1)) if active else ""]
	warning_label.text = battle.warning() if active else "Một kiếm sĩ. Một tinh linh. Một bình minh mới."
	var can_play := active and battle.state == "battle" and modal == null and not battle.paused
	for i in range(3):
		var def: Dictionary = catalog.data.skills[i]
		var cd: float = battle.cooldowns[i] if active else 0.0
		skill_buttons[i].text = def.name + (" · %ds" % ceili(cd) if cd > 0 else " · %d SP" % def.cost)
		skill_buttons[i].disabled = not can_play or cd > 0 or battle.sp < def.cost or not battle.actions.is_empty() or battle.move_clock > 0 if active else true
	attack_button.disabled = not can_play
	guard_button.disabled = not can_play or (active and battle.guard_cd > 0)
	guard_button.text = "Thủ · %ds" % ceili(battle.guard_cd) if active and battle.guard_cd > 0 else "Thủ thế"
	pause_button.disabled = not active or battle.state != "battle"
	pause_button.text = "Tiếp tục" if active and battle.paused else "Dừng"
	auto_button.text = "Tự: bật" if not active or battle.auto_attack else "Tự: tắt"
	speed_button.text = "×%d" % (battle.speed if active else p.settings.speed)
	mute_button.text = "Âm: bật" if p.settings.sound else "Âm: tắt"

func _select_tab(index: int) -> void:
	if battle != null and battle.state == "battle":
		if index != 0 and not battle.paused:
			battle.paused = true
			details_paused = true
		elif index == 0 and details_paused:
			battle.paused = false
			details_paused = false
	tab = index
	scroll.scroll_vertical = 0
	_refresh_panel()

func _refresh_panel() -> void:
	if panel == null:
		return
	var previous_scroll := scroll.scroll_vertical
	for child in panel.get_children():
		panel.remove_child(child)
		child.queue_free()
	var campaign := tab == 0
	view.visible = campaign
	for control in [hp_label, enemy_label, warning_label, hp_bar, enemy_bar, sp_bar, guard_button, attack_button, pause_button, auto_button, speed_button, stage_label, tap_target]:
		control.visible = campaign
	for control in skill_buttons:
		control.visible = campaign
	scroll.position.y = 758 if campaign else 208
	scroll.size.y = 151 if campaign else 696
	scroll.set_deferred("scroll_vertical", previous_scroll)
	for i in range(tabs.size()):
		tabs[i].position.y = 706 if campaign else 150
		tabs[i].modulate = Color("e3c998") if i == tab else Color.WHITE
	view.preview = catalog.stats(store.profile)
	view.selected_stage = catalog.find_row("stages", selected_stage)
	match tab:
		0: _campaign_panel()
		1: _heroes_panel()
		2: _items_panel()
		3: _quests_panel()
		4: _journal_panel()

func _text(text: String, font_size: int = 15, color: Color = Color("c0d0cb")) -> void:
	var label := _label(panel, text, Vector2.ZERO, font_size, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = 460

func _row(text: String, callback: Callable, disabled: bool = false) -> Button:
	var b := _button(panel, text, Vector2.ZERO, Vector2(464, 40), callback)
	b.disabled = disabled
	return b

func _locked() -> bool:
	return not store.profile.pending.is_empty() or store.read_only

func _campaign_panel() -> void:
	if _locked() and battle != null and battle.state == "battle":
		_row("Rút lui · không nhận thưởng", _confirm_abandon)
	else:
		_row("VÀO ẢI · " + catalog.find_row("stages", selected_stage).name, _enter_stage.bind(selected_stage), _locked())
	for stage in catalog.data.stages:
		var available: bool = stage.id <= store.unlocked_stage()
		_row("%02d   %s   %s" % [stage.id, stage.name, "✓" if stage.id in store.profile.cleared else ("Mở" if available else "Khóa")], _choose_stage.bind(int(stage.id)), not available or _locked())
	var supplies := store.offline_preview(int(Time.get_unix_time_from_system()))
	_row("Tiếp tế: %d vàng · nhận (tối đa 2 giờ)" % supplies, _offline, supplies <= 0 or store.read_only)
	_text("Thưởng mỗi lần thắng + loot. Lần đầu có thêm vàng. Túi đầy: loot đổi thành 3 tinh thạch.")

func _choose_stage(id: int) -> void:
	selected_stage = id
	battle = null
	view.battle = null
	_refresh_panel()

func _heroes_panel() -> void:
	var p: Dictionary = store.profile
	var hero := catalog.find_row("heroes", p.hero)
	var unit: Dictionary = p.heroes[p.hero]
	var stats := catalog.stats(p)
	_text("%s · %s · cấp %d" % [hero.name, hero.title, unit.level], 18, Color("e5cd9e"))
	_text("ATK %d · HP %d · Thủ %d · Chí mạng %d%%" % [stats.atk, stats.hp, stats.defense, stats.crit * 100])
	_text(hero.passive)
	var portrait := HeroPortrait.new()
	portrait.library = frames
	portrait.hero = p.hero
	portrait.weapon = stats.weapon
	portrait.custom_minimum_size = Vector2(180, 205)
	panel.add_child(portrait)
	_row("Tăng cấp · %d vàng + %d XP" % [unit.level * 30, unit.level * 15], _upgrade.bind("hero", 0), _locked() or unit.level >= 100 or p.gold < unit.level * 30 or p.xp < unit.level * 15)
	for h in catalog.data.heroes:
		_row(("✓ " if p.hero == h.id else "") + h.name + " · " + h.title + (" · Khóa sau ải %d" % (h.unlock - 1) if not store.available_hero(h.id) else ""), _hero.bind(h.id), _locked() or not store.available_hero(h.id) or p.hero == h.id)
	for i in range(3):
		_row("%s cấp %d · nâng %d vàng" % [catalog.data.skills[i].name, unit.skills[i], unit.skills[i] * 25], _upgrade.bind("skill", i), _locked() or unit.skills[i] >= 10 or p.gold < unit.skills[i] * 25)
	_text("TRỢ CHIẾN", 16, Color("e5cd9e"))
	for assist in catalog.data.assists:
		_row(("✓ " if p.assist == assist.id else "") + assist.name + " · " + assist.role, _assist.bind(assist.id), _locked() or assist.unlock > store.unlocked_stage() or p.assist == assist.id)
	_row("Nâng trợ chiến cấp %d · %d vàng" % [p.assists[p.assist], p.assists[p.assist] * 35], _upgrade.bind("assist", 0), _locked() or p.assists[p.assist] >= 20 or p.gold < p.assists[p.assist] * 35)

func _items_panel() -> void:
	var p: Dictionary = store.profile
	_text("TÚI ĐỒ %d / %d · vũ khí + giáp theo từng nhân vật" % [p.items.size(), Store.BAG_CAP], 16, Color("e5cd9e"))
	for item in p.items:
		var def := catalog.find_row("items", item.base)
		var owner := ""
		for h in p.heroes:
			if item.uid in p.heroes[h].equipment.values():
				owner = catalog.find_row("heroes", h).name
		_row("%s%s +%d · bậc %d %s" % ["▸ " if item.uid == selected_item else "", def.name, item.enhance, item.rank, "[" + owner + "]" if not owner.is_empty() else ""], _item_detail.bind(item.uid))
		if selected_item != item.uid:
			continue
		var mult: float = 1 + item.enhance * .18 + (item.rank - 1) * .5
		_text("  UID %s · ATK +%d / HP +%d / Thủ +%d" % [item.uid, def.atk * mult, def.hp * mult, def.defense * mult])
		_text("  " + def.passive)
		if owner.is_empty() and (def.slot == "armor" or def.category == catalog.category(p.hero)):
			var candidate: Dictionary = p.duplicate(true)
			candidate.heroes[p.hero].equipment[def.slot] = item.uid
			var old_stats := catalog.stats(p)
			var new_stats := catalog.stats(candidate)
			_text("  Nếu mặc: ATK %d→%d · HP %d→%d · Thủ %d→%d" % [old_stats.atk, new_stats.atk, old_stats.hp, new_stats.hp, old_stats.defense, new_stats.defense])
		if owner == catalog.find_row("heroes", p.hero).name:
			_row("Tháo về túi", _unequip.bind(item.uid), _locked())
		_row("Trang bị cho " + catalog.find_row("heroes", p.hero).name, _equip.bind(item.uid), _locked() or not owner.is_empty() or (def.slot == "weapon" and def.category != catalog.category(p.hero)))
		_row("Cường hóa · %d vàng + 1 tinh thạch" % ((item.enhance + 1) * 20), _enhance.bind(item.uid, false), _locked() or item.enhance >= 10 or p.gold < (item.enhance + 1) * 20 or p.shards < 1)
		_row("Tiến bậc · %d vàng + %d tinh thạch" % [item.rank * 80, item.rank * 4], _enhance.bind(item.uid, true), _locked() or item.rank >= 3 or p.gold < item.rank * 80 or p.shards < item.rank * 4)
		_row("Phân giải · +%d tinh thạch" % (1 + item.rank), _dismantle_confirm.bind(item.uid), _locked() or not owner.is_empty())
	_text("LÒ RÈN · 65 vàng + 3 tinh thạch / món", 16, Color("e5cd9e"))
	for def in catalog.data.items:
		_row("Rèn · " + def.name, _forge.bind(def.id), _locked() or p.gold < 65 or p.shards < 3 or p.items.size() >= Store.BAG_CAP)

func _quests_panel() -> void:
	for quest in catalog.data.quests:
		var count: int = mini(int(store.profile.metrics[quest.metric]), int(quest.target))
		_text("%s · %d/%d" % [quest.name, count, quest.target], 17, Color("e5cd9e"))
		_row("Đã nhận" if quest.id in store.profile.claimed else "Nhận · %d vàng + %d tinh thạch" % [quest.gold, quest.shards], _quest.bind(quest.id), quest.id in store.profile.claimed or count < quest.target or store.read_only)
	_text("Nhiệm vụ được lưu vĩnh viễn; không nhận lại khi khởi động game.")

func _journal_panel() -> void:
	_text("NHẬT KÝ HÀNH TRÌNH", 17, Color("e5cd9e"))
	for stage in catalog.data.stages:
		for part in ["before", "after"]:
			var key := "%d_%s" % [stage.id, part]
			if key in store.profile.seen_story:
				_row(stage.name + (" · Khởi đầu" if part == "before" else " · Kết thúc"), _replay_story.bind(stage[part]))
	_text("Thế giới, nhân vật và hội thoại ở đây là nội dung mới. Nghiên cứu Eternal Senia 2 giúp tổ chức dữ liệu; không khẳng định phục hồi thuật toán gốc.")

func _notify(text: String) -> void:
	message = text
	message_time = 7

func _outcome(success: bool, text: String) -> void:
	_notify(text if success else (store.error if not store.error.is_empty() else "Chưa đủ điều kiện hoặc trận chưa kết thúc."))
	_refresh_panel()

func _hero(id: String) -> void:
	if store.change_hero(id):
		battle = null
		view.battle = null
		_outcome(true, "Đã đổi nhân vật.")
	else:
		_outcome(false, "")

func _assist(id: String) -> void:
	_outcome(store.change_assist(id), "Đã đổi trợ chiến.")

func _upgrade(kind: String, index: int) -> void:
	_outcome(store.upgrade(kind, index), "Đã nâng cấp. Chỉ số mới được áp dụng từ trận tiếp theo.")

func _item_detail(uid: String) -> void:
	selected_item = uid
	_refresh_panel()

func _equip(uid: String) -> void:
	_outcome(store.equip(uid), "Đã trang bị.")

func _unequip(uid: String) -> void:
	_outcome(store.unequip(uid), "Đã tháo trang bị về túi.")

func _enhance(uid: String, rank_up: bool) -> void:
	_outcome(store.enhance(uid, rank_up), "Đã nâng trang bị.")

func _forge(id: String) -> void:
	_outcome(store.forge(id), "Đã rèn một món mới.")

func _dismantle_confirm(uid: String) -> void:
	_dialog("Phân giải trang bị?", "Món đồ chưa trang bị sẽ đổi thành tinh thạch. Không thể lấy lại món cũ.", [{"text": "Phân giải", "call": _dismantle.bind(uid)}, {"text": "Giữ lại", "call": _close_modal}])

func _dismantle(uid: String) -> void:
	_close_modal()
	_outcome(store.dismantle(uid), "Đã phân giải trang bị.")

func _quest(id: String) -> void:
	_outcome(store.claim_quest(id), "Đã nhận thưởng nhiệm vụ.")

func _offline() -> void:
	_outcome(store.claim_offline(int(Time.get_unix_time_from_system())), "Đã nhận tiếp tế. Đồng hồ máy ảnh hưởng lượng nhận; tối đa 2 giờ.")

func _enter_stage(id: int) -> void:
	if _locked():
		return
	selected_stage = id
	var stage := catalog.find_row("stages", id)
	_dialog(stage.name, stage.before + "\n\nMẹo: Tinh linh phá khiên. Ngưng kỹ năng khi boss phản đòn. Thủ thế ngay trước đòn nặng.", [{"text": "Tiến vào", "call": _begin}, {"text": "Chuẩn bị thêm", "call": _close_modal}])

func _begin() -> void:
	_close_modal()
	store.mark_story("%d_before" % selected_stage)
	if not store.begin_run(selected_stage):
		_outcome(false, "")
		return
	_resume()

func _resume() -> void:
	_close_modal()
	battle = Battle.new(catalog)
	battle.start(store.profile.pending)
	battle.speed = store.profile.settings.speed
	selected_stage = int(battle.run.stage)
	view.battle = battle
	result_shown = false
	details_paused = false
	last_audio_id = 0
	_refresh_panel()

func _finish() -> void:
	result_shown = true
	var won := battle.state == "won"
	var gold_before: int = store.profile.gold
	var shards_before: int = store.profile.shards
	var old_uids: Array = []
	for item in store.profile.items:
		old_uids.append(item.uid)
	if not store.settle(battle.run.id, won, battle.kills):
		_dialog("Chưa lưu được kết quả", store.error + "\nTrận vẫn được giữ. Hãy thử ghi lại; không nhận thưởng hai lần.", [{"text": "Thử lưu lại", "call": _retry_settle}])
		return
	if won:
		_play_sound("win")
		var stage: Dictionary = battle.stage
		var loot := "Túi đầy · loot đã đổi thành 3 tinh thạch"
		for item in store.profile.items:
			if item.uid not in old_uids:
				loot = "Nhận trang bị: " + catalog.find_row("items", item.base).name
		_dialog("CHIẾN THẮNG", "%s\n\n+%d vàng · +%d XP · +%d tinh thạch\n%s" % [stage.after, store.profile.gold - gold_before, stage.xp, store.profile.shards - shards_before, loot], [{"text": "Về hành trình", "call": _return_to_camp}, {"text": "Đánh lại", "call": _replay}])
	else:
		_dialog("ÁNH SÁNG CHƯA TẮT", "Chưa nhận thưởng. Hãy nâng vũ khí, đổi trợ chiến hoặc dùng Thủ thế đúng nhịp.", [{"text": "Chuẩn bị lại", "call": _return_to_camp}, {"text": "Thử lại", "call": _replay}])
	_refresh_panel()

func _retry_settle() -> void:
	_close_modal()
	result_shown = false
	_finish()

func _return_to_camp() -> void:
	_close_modal()
	battle = null
	view.battle = null
	tab = 0
	_refresh_panel()

func _replay() -> void:
	_return_to_camp()
	_enter_stage(selected_stage)

func _confirm_abandon() -> void:
	if battle != null:
		battle.paused = true
	_dialog("Rút lui?", "Trận này không có thưởng. Tiến trình đã lưu được giữ nguyên.", [{"text": "Rút lui", "call": _abandon}, {"text": "Tiếp tục trận", "call": _cancel_abandon}])

func _cancel_abandon() -> void:
	_close_modal()
	if battle != null:
		battle.paused = false

func _abandon() -> void:
	if not store.profile.pending.is_empty():
		if not store.settle(store.profile.pending.id, false, battle.kills if battle != null else 0):
			_notify(store.error)
			return
	_return_to_camp()

func _attack() -> void:
	if battle != null and modal == null:
		battle.attack()

func _skill(index: int) -> void:
	if battle != null and modal == null:
		battle.skill(index)

func _guard() -> void:
	if battle != null and modal == null:
		battle.guard()

func _toggle_auto() -> void:
	if battle != null:
		battle.auto_attack = not battle.auto_attack

func _toggle_pause() -> void:
	if battle != null and modal == null:
		battle.paused = not battle.paused

func _speed() -> void:
	var next: int = int(store.profile.settings.speed) % 3 + 1
	if store.setting("speed", next) and battle != null:
		battle.speed = next

func _toggle_sound() -> void:
	store.setting("sound", not store.profile.settings.sound)

func _replay_story(text: String) -> void:
	_dialog("Nhật ký", text, [{"text": "Đóng", "call": _close_modal}])

func _dialog(title: String, body: String, actions: Array) -> void:
	_close_modal()
	modal = Control.new()
	modal.size = Vector2(540, 960)
	ui.add_child(modal)
	var shade := ColorRect.new()
	shade.color = Color(0.025, .05, .08, .88)
	shade.size = modal.size
	modal.add_child(shade)
	var box := PanelContainer.new()
	box.position = Vector2(34, 245)
	box.size = Vector2(472, 450)
	box.add_theme_stylebox_override("panel", _style(Color("172d38"), Color("bda97f"), 18))
	modal.add_child(box)
	var margin := MarginContainer.new()
	for key in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(key, 18)
	box.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	margin.add_child(column)
	var heading := _label(column, title, Vector2.ZERO, 25, Color("e5cd9e"))
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var label := _label(column, body, Vector2.ZERO, 18)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for action in actions:
		_button(column, action.text, Vector2.ZERO, Vector2(400, 46), action.call)

func _close_modal() -> void:
	if is_instance_valid(modal):
		ui.remove_child(modal)
		modal.queue_free()
	modal = null

func _play_events() -> void:
	for event in battle.events:
		if event.id <= last_audio_id:
			continue
		last_audio_id = event.id
		if event.kind in ["hit", "critical", "heal", "hurt"]:
			_play_sound("hit" if event.kind == "critical" else event.kind)

func _play_sound(key: String) -> void:
	if not store.profile.settings.sound:
		return
	for player in audio_players:
		if not player.playing:
			player.stream = sounds[key]
			player.play()
			break

func _exit_tree() -> void:
	for player in audio_players:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
