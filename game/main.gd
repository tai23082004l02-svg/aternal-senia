extends Node2D

const Catalog = preload("res://game/core/catalog.gd")
const Store = preload("res://game/core/progress.gd")
const Battle = preload("res://game/core/battle.gd")
const Frames = preload("res://game/core/frame_library.gd")
const View = preload("res://game/battle_view.gd")
const NAV_PAGES := [20, 1, 0, 21, 2]
var catalog: GameCatalog
var store: ProgressStore
var battle: BattleModel
var frames: FrameLibrary
var view: BattleView
var ui: Control
var mission_tab := 0
var profile_vip: Label
var profile_name: Label
var profile_button: Button
var profile_avatar: Control
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
var result_transition := false
var result_delay := 0.0
var pending_result: Dictionary = {}
var message := ""
var message_time := 0.0
var audio_players: Array[AudioStreamPlayer] = []
var audio: AudioDirector
var audio_menu_open := false
var audio_menu_paused := false
var sound_sliders: Dictionary = {}
var sound_labels: Dictionary = {}
var sound_enabled: CheckButton
var audio_notice: Label
var quit_requested := false
var scroll: ScrollContainer
var tap_target: Button
var details_paused := false
var icons := UIIcons.new()
var skill_group_labels: Array[Label] = []
var bag_section := ""
var bag_kind := "all"
var bag_rarity := 0
var bag_spirit_rarity := 0
var selected_spirit := "lumi"
var character_inspected := ""
var character_page := 0
var character_outfit_preview := ""
var summon_kind := 0
var shop_page := 0
var currency_labels: Dictionary = {}

func _ready() -> void:
	get_tree().auto_accept_quit = false
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
	audio = AudioDirector.new()
	add_child(audio)
	audio.apply_profile(store.profile)
	audio_players = audio.players
	_build_ui()
	_refresh_panel()
	if store.read_only:
		_dialog("Tiến trình được bảo vệ", store.error, [{"text": "Đã hiểu", "call": _close_modal}])
	elif not store.profile.pending.is_empty():
		_dialog("Trận chưa hoàn tất", "Tiếp tục sẽ chạy lại từ đầu trận với cùng nhân vật, trang bị và hạt ngẫu nhiên đã lưu.", [{"text": "Tiếp tục", "call": _resume}, {"text": "Bỏ trận · không thưởng", "call": _abandon}])
	else:
		_notify("Vào ải để chiến đấu. Quản lý vật phẩm trong Túi đồ.")

func _build_ui() -> void:
	add_child(MenuBackdrop.new())
	ui = Control.new()
	ui.size = Vector2(540, 960)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var theme := Theme.new()
	theme.default_font_size = 16
	var normal := _style(Color("17313e"), Color("57615b"), 12)
	var hover := _style(Color("294b56"), Color("d2bb83"), 12)
	theme.set_stylebox("normal", "Button", normal)
	theme.set_stylebox("hover", "Button", hover)
	theme.set_stylebox("pressed", "Button", _style(Color("425951"), Color("d8c69d"), 10))
	theme.set_stylebox("disabled", "Button", _style(Color("122733"), Color("35484f"), 12))
	theme.set_color("font_color", "Button", Color("ede5d0"))
	theme.set_color("font_disabled_color", "Button", Color("74858c"))
	theme.set_color("font_color", "Label", Color("dedfd5"))
	ui.theme = theme
	add_child(ui)
	profile_button = _button(ui, "", Vector2(24, 17), Vector2(332, 61), _show_player_profile)
	profile_button.flat = true
	profile_button.tooltip_text = "Hồ sơ và VIP"
	profile_avatar = PlayerProfilePanel.RoundAvatar.new()
	profile_avatar.position = Vector2(3, 3)
	profile_avatar.size = Vector2(54, 54)
	profile_avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	profile_button.add_child(profile_avatar)
	profile_name = _label(profile_button, "", Vector2(70, 4), 20, Color("ecdfbc"))
	profile_name.size = Vector2(246, 29)
	profile_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	profile_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	profile_vip = _label(profile_button, "VIP · Chưa kích hoạt  ›", Vector2(70, 35), 13, Color("e1c38d"))
	profile_vip.size = Vector2(270, 22)
	profile_vip.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	profile_vip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wallet = _label(ui, "", Vector2(24, 88), 14, Color("e1c38d"))
	wallet.visible = false
	for i in range(3):
		var key: String = ["gold", "shards", "xp"][i]
		var icon := TextureRect.new()
		icon.texture = frames.textures["icon_" + key]
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.position = Vector2(24 + i * 166, 85)
		icon.size = Vector2(28, 28)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.add_child(icon)
		currency_labels[key] = _label(ui, "", Vector2(58 + i * 166, 91), 14, Color("e1c38d"))
	mute_button = _button(ui, "Âm: bật", Vector2(422, 25), Vector2(94, 34), _toggle_sound)
	_button(ui, "≡", Vector2(374, 25), Vector2(40, 34), _select_tab.bind(4)).tooltip_text = "Menu"
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
	skill_group_labels.append(_label(ui, "NHÂN VẬT", Vector2(24, 583), 11, Color("e5cd9e")))
	skill_group_labels.append(_label(ui, "TINH LINH", Vector2(356, 583), 11, Color("a2e5d6")))
	for i in range(3):
		skill_buttons.append(_button(ui, "", Vector2(24 + i * 166, 598), Vector2(160, 44), _skill.bind(i)))
		icons.apply(skill_buttons[i], ["slash", "heal", "spirit"][i], 28)
		skill_buttons[i].add_theme_font_size_override("font_size", 12)
	attack_button = _button(ui, "Đánh", Vector2(24, 651), Vector2(82, 36), _attack)
	guard_button = _button(ui, "Thủ thế", Vector2(112, 651), Vector2(113, 36), _guard)
	icons.apply(guard_button, "guard", 22)
	guard_button.add_theme_font_size_override("font_size", 13)
	auto_button = _button(ui, "Tự đánh", Vector2(231, 651), Vector2(99, 36), _toggle_auto)
	pause_button = _button(ui, "Dừng", Vector2(336, 651), Vector2(90, 36), _toggle_pause)
	speed_button = _button(ui, "×1", Vector2(432, 651), Vector2(84, 36), _speed)
	for i in range(5):
		tabs.append(_button(ui, ["Shop", "Nhân vật", "Hành trình", "Phó bản", "Túi đồ"][i], Vector2(24 + i * 99, 876), Vector2(93, 56), _select_tab.bind(NAV_PAGES[i])))
		icons.tab(tabs[i], ["gold", "hero", "journey", "boss", "equipment"][i])
	for control in [attack_button, guard_button, auto_button, pause_button, speed_button]:
		control.custom_minimum_size.y = 44
		control.size.y = 44
	scroll = ScrollContainer.new()
	scroll.position = Vector2(24, 758)
	scroll.size = Vector2(492, 151)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ui.add_child(scroll)
	panel = VBoxContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_constant_override("separation", 9)
	scroll.add_child(panel)
	status_label = _label(ui, "", Vector2(24, 940), 11, Color("9bb5b3"))
	status_label.size = Vector2(492, 18)
	status_label.clip_text = true

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
	button.pressed.connect(_on_button.bind(action))
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
	_sync_audio()
	if battle != null:
		battle.advance(delta)
		if battle.state in ["won", "lost"] and not result_shown:
			_finish()
		_play_events()
	if result_transition:
		result_delay -= delta
		if result_delay <= 0:
			_present_result()
	_refresh_hud()
	message_time = maxf(0, message_time - delta)
	status_label.text = message if message_time > 0 else ("Chọn Bản đồ để đổi ải · Túi đồ để chuẩn bị" if battle == null else "Tự đánh + tap combo · Thủ thế giảm 80% sát thương trong 0,7 giây")

func _refresh_hud() -> void:
	var p: Dictionary = store.profile
	profile_name.text = PlayerIdentity.state(p).name
	profile_vip.text = "VIP · %d EXP · Chờ xếp hạng ›" % MissionBoard.state(p).vip_exp
	profile_avatar.update_avatar(frames, PlayerIdentity.state(p).avatar)
	wallet.text = ""
	for key in currency_labels:
		currency_labels[key].text = "%d %s" % [p[key], {"gold": "Vàng", "shards": "Tinh thạch", "xp": "XP"}[key]]
	var active := battle != null
	var stats: Dictionary = battle.stats if active else catalog.stats(p)
	var hero := catalog.find_row("heroes", stats.hero)
	hp_label.text = "%s · %d / %d HP" % [hero.name, battle.hp if active else stats.hp, stats.hp]
	hp_bar.value = (battle.hp if active else stats.hp) / stats.hp * 100
	enemy_label.text = "%s · %d / %d" % [(battle.stage.boss if battle.is_boss() else "Bóng tối") if active else "Bóng tối", battle.enemy_hp if active else 55, battle.enemy_max if active else 55]
	if active and battle.move_clock > 0:
		enemy_label.text = "Đang tiến sang đợt tiếp theo…"
	enemy_bar.value = battle.enemy_hp / battle.enemy_max * 100 if active else 100
	sp_bar.value = battle.sp if active else 100
	stage_label.text = "%s%s" % [catalog.find_row("stages", selected_stage).name, (" · %d/%d" % [battle.wave + 1, battle.wave_count()]) if active else ""]
	warning_label.text = battle.warning() if active else "Một kiếm sĩ. Một tinh linh. Một bình minh mới."
	var can_play := active and battle.state == "battle" and modal == null and not battle.paused
	skill_group_labels[0].text = "NHÂN VẬT · " + catalog.find_row("heroes", battle.stats.hero if active else p.hero).name
	skill_group_labels[1].text = "TINH LINH · " + catalog.find_row("assists", battle.stats.assist if active else p.assist).name
	for i in range(3):
		var def: Dictionary = catalog.data.skills[i]
		var cd: float = battle.cooldowns[i] if active else 0.0
		skill_buttons[i].text = def.name + (" · %ds" % ceili(cd) if cd > 0 else " · %d SP" % (25 if active and i == 2 and battle.variant("flow") else def.cost))
		skill_buttons[i].disabled = not can_play or cd > 0 or battle.sp < (25 if i == 2 and battle.variant("flow") else def.cost) or not battle.actions.is_empty() or battle.move_clock > 0 if active else true
	attack_button.disabled = not can_play
	guard_button.disabled = not can_play or (active and battle.guard_cd > 0)
	guard_button.text = "Thủ · %ds" % ceili(battle.guard_cd) if active and battle.guard_cd > 0 else "Thủ thế"
	pause_button.disabled = not active or battle.state != "battle"
	pause_button.text = "Tiếp tục" if active and battle.paused else "Dừng"
	auto_button.text = "Tự: bật" if not active or battle.auto_attack else "Tự: tắt"
	speed_button.text = "×%d" % (battle.speed if active else p.settings.speed)
	mute_button.text = "Âm: bật" if p.settings.sound else "Âm: tắt"

func _select_tab(index: int) -> void:
	if index == 11:
		shop_page = 2
		index = 20
	if index == 12:
		character_inspected = store.profile.hero
		character_page = 2
		index = 1
	if result_transition:
		return
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
	var fighting := battle != null
	view.visible = campaign and fighting
	for control in [hp_label, enemy_label, warning_label, hp_bar, enemy_bar, sp_bar, guard_button, attack_button, pause_button, auto_button, speed_button, stage_label, tap_target]:
		control.visible = campaign and fighting
	stage_label.visible = campaign and fighting
	for control in skill_buttons:
		control.visible = campaign and fighting
	for control in skill_group_labels:
		control.visible = campaign and fighting
	scroll.position.y = 710 if campaign and fighting else 132
	scroll.size.y = 150 if campaign and fighting else 732
	scroll.set_deferred("scroll_vertical", previous_scroll)
	for i in range(tabs.size()):
		tabs[i].position.y = 876
		var section: int = 20 if tab in [20, 11] else (2 if tab in [2, 17, 18, 19] else (1 if tab in [1, 6, 7, 9, 12, 13] else (21 if tab in [5, 21] else 0)))
		tabs[i].modulate = Color("e3c998") if NAV_PAGES[i] == section else Color.WHITE
	view.preview = catalog.stats(store.profile)
	view.selected_stage = catalog.find_row("stages", selected_stage)
	match tab:
		0: _campaign_panel()
		1: _heroes_panel()
		2: _items_panel()
		3: _quests_panel()
		4: _more_panel()
		9: _training_panel()
		10: _boss_guide_panel()
		11: _summon_panel()
		13: _spirit_tree_panel()
		15: _map_panel()
		16: _journal_panel()
		17: _equipment_detail_panel()
		18: _spirit_inventory_detail()
		19: _forge_panel()
		20: _shop_panel()
		21: _dungeons_panel()
		_: _expansion_panel(tab)

func _text(text: String, font_size: int = 15, color: Color = Color("c0d0cb")) -> void:
	var label := _label(panel, text, Vector2.ZERO, font_size, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = 460

func _row(text: String, callback: Callable, disabled: bool = false) -> Button:
	var b := _button(panel, text, Vector2.ZERO, Vector2(464, 44), callback)
	icons.action(b, callback)
	b.disabled = disabled
	return b

func _material_text(text: String, key: String, color: Color) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)
	var picture := TextureRect.new()
	picture.texture = icons.textures[key]
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.custom_minimum_size = Vector2(32, 32)
	row.add_child(picture)
	var label := _label(row, text, Vector2.ZERO, 18, color)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _locked() -> bool:
	return not store.profile.pending.is_empty() or store.read_only or result_transition

func _campaign_panel() -> void:
	if battle == null:
		var screen := JourneyScreen.new()
		screen.game = self
		panel.add_child(screen)
		return
	if battle == null:
		var p: Dictionary = store.profile
		_text("%s · Cấp %d   /   %s đồng hành" % [catalog.find_row("heroes", p.hero).name, p.heroes[p.hero].level, catalog.find_row("assists", p.assist).name], 17, Color("e5cd9e"))
	if _locked() and battle != null and battle.state == "battle":
		_row("Rút lui · không nhận thưởng", _confirm_abandon)
	else:
		_row("VÀO ẢI · " + catalog.find_row("stages", selected_stage).name, _enter_stage.bind(selected_stage), _locked())
	var supplies := store.offline_preview(int(Time.get_unix_time_from_system()))
	var shortcuts := HBoxContainer.new()
	shortcuts.add_theme_constant_override("separation", 6)
	panel.add_child(shortcuts)
	for entry in [["Bản đồ", _select_tab.bind(15), "journey"], ["Triệu hồi", _select_tab.bind(11), "spirit"], ["Tiếp tế +%d" % supplies, _offline, "gold"]]:
		var button := _button(shortcuts, entry[0], Vector2.ZERO, Vector2(156, 50), entry[1])
		icons.apply(button, entry[2], 23)
		button.add_theme_font_size_override("font_size", 13)
		if entry[2] == "gold": button.disabled = supplies <= 0 or store.read_only

func _choose_stage(id: int) -> void:
	selected_stage = id
	battle = null
	view.battle = null
	_refresh_panel()

func _heroes_panel() -> void:
	if character_inspected == "" or catalog.find_row("heroes", character_inspected).is_empty():
		character_inspected = store.profile.hero
	var screen := CharacterScreen.new()
	screen.game = self
	screen.hero = character_inspected
	screen.section = character_page
	panel.add_child(screen)

func _equipment_detail_panel() -> void:
	var p: Dictionary = store.profile
	_row("← Kho trang bị", _select_tab.bind(2))
	for item in p.items:
		if item.uid != selected_item: continue
		var def := catalog.find_row("items", item.base)
		var owners: Array[String] = []
		for h in p.heroes:
			if item.uid in p.heroes[h].equipment.values(): owners.append(catalog.find_row("heroes", h).name)
		var owner := ", ".join(owners)
		_item_illustration(def.id)
		_text(def.name, 24, Color(Recruitment.RARITIES[def.rarity].color))
		_text("%s · Cường hóa +%d · Bậc %d%s" % [_rarity("item", item.base), item.enhance, item.rank, " · " + owner if owner != "" else ""])
		if selected_item != item.uid:
			continue
		var mult: float = 1 + item.enhance * .18 + (item.rank - 1) * .5
		_text("ATK +%d · HP +%d · Thủ +%d" % [def.atk * mult, def.hp * mult, def.defense * mult])
		_text("  " + def.passive)
		_text("Mảnh %s · %d" % [def.name, p.collection_fragments.items[def.id]], 14)
		if item.uid not in p.heroes[p.hero].equipment.values() and (def.slot == "armor" or def.category == catalog.category(p.hero)):
			var candidate: Dictionary = p.duplicate(true)
			candidate.heroes[p.hero].equipment[def.slot] = item.uid
			var old_stats := catalog.stats(p)
			var new_stats := catalog.stats(candidate)
			_text("  Nếu mặc: ATK %d→%d · HP %d→%d · Thủ %d→%d" % [old_stats.atk, new_stats.atk, old_stats.hp, new_stats.hp, old_stats.defense, new_stats.defense])
		if item.uid in p.heroes[p.hero].equipment.values():
			_row("Tháo về túi", _unequip.bind(item.uid), _locked())
		_row("Trang bị cho " + catalog.find_row("heroes", p.hero).name, _equip.bind(item.uid), _locked() or item.uid in p.heroes[p.hero].equipment.values() or (def.slot == "weapon" and def.category != catalog.category(p.hero)))
		_row("Cường hóa · %d vàng + 1 tinh thạch" % ((item.enhance + 1) * 20), _enhance.bind(item.uid, false), _locked() or item.enhance >= 10 or p.gold < (item.enhance + 1) * 20 or p.shards < 1)
		_row("Tiến bậc · %d vàng + %d tinh thạch" % [item.rank * 80, item.rank * 4], _enhance.bind(item.uid, true), _locked() or item.rank >= 3 or p.gold < item.rank * 80 or p.shards < item.rank * 4)
		_row("Phân giải · +%d tinh thạch" % (1 + item.rank), _dismantle_confirm.bind(item.uid), _locked() or not owner.is_empty())

func _quests_panel() -> void:
	var screen := MissionScreen.new()
	screen.game = self
	panel.add_child(screen)

func _mission_tab(index: int) -> void:
	mission_tab = clampi(index, 0, 2)
	scroll.scroll_vertical = 0
	_refresh_panel()

func _mission_claim(period: String, id: String) -> void:
	_outcome(MissionBoard.claim(store, period, id), "Đã nhận tài nguyên và VIP EXP.", "reward")

func _mission_chest(period: String, threshold: int) -> void:
	var section: Dictionary = MissionBoard.state(store.profile)[period]
	var reward := MissionBoard.chest_reward(period, threshold)
	var can_claim: bool = threshold not in section.chests and MissionBoard.points(section, period) >= threshold and not _locked()
	var column := _dialog("RƯƠNG %d ĐIỂM" % threshold, "%d vàng · %d tinh thạch · %d VIP EXP\n\n%s" % [reward.gold, reward.shards, reward.vip, "Đã nhận" if threshold in section.chests else ("Đủ điểm nhận quà" if can_claim else "Chưa đủ điểm hoạt động")], [{"text":"Đóng", "call":_close_modal}])
	var button := _button(column, "Nhận rương", Vector2.ZERO, Vector2(400, 46), _mission_claim_chest.bind(period, threshold))
	button.disabled = not can_claim
	column.move_child(button, column.get_child_count() - 2)

func _mission_claim_chest(period: String, threshold: int) -> void:
	_close_modal()
	_outcome(MissionBoard.claim(store, period, "", threshold), "Đã nhận rương hoạt động.", "reward")

func _mission_go(id: String) -> void:
	match id:
		"offline": _offline()
		"enhance": _select_tab(2)
		"summon": _select_tab(11)
		_: _select_tab(0)

func _journal_panel() -> void:
	_row("SỔ TAY BOSS →", _select_tab.bind(10))
	_text("NHẬT KÝ HÀNH TRÌNH", 17, Color("e5cd9e"))
	for stage in catalog.data.stages:
		for part in ["before", "after"]:
			var key := "%d_%s" % [stage.id, part]
			if key in store.profile.seen_story:
				_art_card(stage.name + (" · Khởi đầu" if part == "before" else " · Kết thúc"), stage[part], "bg_" + stage.zone, _replay_story.bind(stage[part]))
	_text("Thế giới, nhân vật và hội thoại ở đây là nội dung mới. Nghiên cứu Eternal Senia 2 giúp tổ chức dữ liệu; không khẳng định phục hồi thuật toán gốc.")

func _notify(text: String) -> void:
	message = text
	message_time = 7

func _outcome(success: bool, text: String, cue: String = "confirm") -> void:
	if success:
		audio.play(cue)
	_notify(text if success else (store.error if not store.error.is_empty() else "Chưa đủ điều kiện hoặc trận chưa kết thúc."))
	_refresh_panel()

func _hero(id: String) -> void:
	if store.change_hero(id):
		character_inspected = id
		battle = null
		view.battle = null
		_outcome(true, "Đã đổi nhân vật.")
	else:
		_outcome(false, "")

func _assist(id: String) -> void:
	_outcome(store.change_assist(id), "Đã đổi trợ chiến.")

func _upgrade(kind: String, index: int) -> void:
	_outcome(store.upgrade(kind, index), "Đã nâng cấp. Chỉ số mới được áp dụng từ trận tiếp theo.", "upgrade")

func _item_detail(uid: String) -> void:
	selected_item = uid
	_select_tab(17)

func _equip(uid: String) -> void:
	_outcome(store.equip(uid), "Đã trang bị.", "equip")

func _unequip(uid: String) -> void:
	_outcome(store.unequip(uid), "Đã tháo trang bị về túi.", "equip")

func _enhance(uid: String, rank_up: bool) -> void:
	_outcome(store.enhance(uid, rank_up), "Đã nâng trang bị.", "forge")

func _forge(id: String) -> void:
	var owned := false
	for item in store.profile.items:
		if item.base == id: owned = true
	_outcome(store.forge(id), "Trang bị trùng: +10 mảnh " + catalog.find_row("items", id).name if owned else "Đã rèn một món mới.", "forge")

func _dismantle_confirm(uid: String) -> void:
	_dialog("Phân giải trang bị?", "Món đồ chưa trang bị sẽ đổi thành tinh thạch. Không thể lấy lại món cũ.", [{"text": "Phân giải", "call": _dismantle.bind(uid)}, {"text": "Giữ lại", "call": _close_modal}])

func _dismantle(uid: String) -> void:
	_close_modal()
	var success := store.dismantle(uid)
	if success:
		selected_item = ""
		bag_section = "equipment"
		tab = 2
	_outcome(success, "Đã phân giải trang bị.")

func _quest(id: String) -> void:
	_outcome(store.claim_quest(id), "Đã nhận thưởng nhiệm vụ.", "reward")

func _offline() -> void:
	_outcome(store.claim_offline(int(Time.get_unix_time_from_system())), "Đã nhận tiếp tế. Đồng hồ máy ảnh hưởng lượng nhận; tối đa 2 giờ.", "reward")

func _enter_stage(id: int) -> void:
	if _locked() or not store.can_enter(id):
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
	_select_tab(0)
	_resume()

func _resume() -> void:
	_close_modal()
	battle = Battle.new(catalog)
	battle.start(store.profile.pending)
	battle.speed = store.profile.settings.speed
	selected_stage = int(battle.run.stage)
	view.battle = battle
	result_shown = false
	result_transition = false
	pending_result = {}
	details_paused = false
	audio.begin_run(battle.run.id)
	_refresh_panel()

func _finish() -> void:
	result_shown = true
	var won := battle.state == "won"
	var gold_before: int = store.profile.gold
	var shards_before: int = store.profile.shards
	var fragments_before: Dictionary = store.profile.collection_fragments.items.duplicate()
	var old_uids: Array = []
	for item in store.profile.items:
		old_uids.append(item.uid)
	if not store.settle(battle.run.id, won, battle.kills, battle.time):
		_dialog("Chưa lưu được kết quả", store.error + "\nTrận vẫn được giữ. Hãy thử ghi lại; không nhận thưởng hai lần.", [{"text": "Thử lưu lại", "call": _retry_settle}])
		return
	if won:
		var stage: Dictionary = battle.stage
		var loot := ""
		for id in store.profile.collection_fragments.items:
			var amount: int = store.profile.collection_fragments.items[id] - fragments_before[id]
			if amount > 0: loot = "Trang bị trùng: +%d mảnh %s" % [amount, catalog.find_row("items", id).name]
		for item in store.profile.items:
			if item.uid not in old_uids:
				loot = "Nhận trang bị: " + catalog.find_row("items", item.base).name
		_queue_result("CHIẾN THẮNG", "%s\n\n+%d vàng · +%d XP · +%d tinh thạch\n%s" % [(stage.after + ("\n+%d lõi tinh linh · Điểm tốt nhất %d" % [stage.cores, store.profile.expansion.records[str(stage.id)].score] if stage.get("kind") == "challenge" else "")), store.profile.gold - gold_before, stage.xp, store.profile.shards - shards_before, loot], [{"text": "Về hành trình", "call": _return_to_camp}, {"text": "Đánh lại", "call": _replay}])
	else:
		_queue_result("ÁNH SÁNG CHƯA TẮT", "Chưa nhận thưởng. Hãy nâng vũ khí, đổi trợ chiến hoặc dùng Thủ thế đúng nhịp.", [{"text": "Chuẩn bị lại", "call": _return_to_camp}, {"text": "Thử lại", "call": _replay}])
	_refresh_panel()

func _queue_result(title: String, body: String, actions: Array) -> void:
	pending_result = {"title": title, "body": body, "actions": actions}
	result_transition = true
	result_delay = .65

func _present_result() -> void:
	result_transition = false
	if pending_result.is_empty():
		return
	var payload := pending_result
	pending_result = {}
	_dialog(payload.title, payload.body, payload.actions)
	_refresh_panel()

func _retry_settle() -> void:
	_close_modal()
	result_shown = false
	_finish()

func _return_to_camp() -> void:
	result_transition = false
	pending_result = {}
	audio.stop_world()
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
	if store.setting("sound", not store.profile.settings.sound):
		audio.apply_profile(store.profile)
		if store.profile.settings.sound:
			audio.play("confirm")
	else:
		_notify(store.error)

func _replay_story(text: String) -> void:
	_dialog("Nhật ký", text, [{"text": "Đóng", "call": _close_modal}])

func _dialog(title: String, body: String, actions: Array) -> VBoxContainer:
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
	var medal := TextureRect.new()
	medal.texture = frames.textures["icon_victory" if title == "CHIẾN THẮNG" else "icon_cores"]
	medal.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	medal.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	medal.custom_minimum_size = Vector2(58, 58)
	medal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(medal)
	var heading := _label(column, title, Vector2.ZERO, 25, Color("e5cd9e"))
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var label := _label(column, body, Vector2.ZERO, 18)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for action in actions:
		_button(column, action.text, Vector2.ZERO, Vector2(400, 46), action.call)
	box.set_deferred("size", Vector2(472, 450))
	return column

func _close_modal() -> void:
	if is_instance_valid(modal):
		ui.remove_child(modal)
		modal.queue_free()
	modal = null

func _on_button(action: Callable) -> void:
	if action.get_method() not in ["_attack", "_skill", "_guard"]:
		audio.play("ui_click")
	action.call()

func _sync_audio() -> void:
	if not audio_menu_open:
		audio.apply_profile(store.profile)
	var zone: String = catalog.find_row("stages", selected_stage).zone
	audio.context(zone, battle != null and battle.paused, tab == 0)

func _play_events() -> void:
	audio.consume(battle)

func _audio_settings() -> void:
	if modal != null or result_transition:
		return
	audio_menu_open = true
	audio_menu_paused = battle != null and battle.state == "battle" and not battle.paused
	if audio_menu_paused:
		battle.paused = true
	var column := _dialog("ÂM THANH", "Chỉnh mức âm, nghe thử rồi áp dụng. Trận được tạm dừng khi mở bảng này.", [{"text": "Áp dụng", "call": _apply_audio_settings}, {"text": "Hủy", "call": _cancel_audio_settings}])
	audio_notice = column.get_child(1)
	var box: PanelContainer = column.get_parent().get_parent()
	box.position.y = 175
	box.size.y = 610
	var insert := 2
	sound_enabled = CheckButton.new()
	sound_enabled.text = "Bật âm thanh"
	sound_enabled.button_pressed = store.profile.settings.sound
	column.add_child(sound_enabled)
	column.move_child(sound_enabled, insert)
	insert += 1
	sound_sliders.clear()
	sound_labels.clear()
	for key in ["sfx_volume", "ambience_volume"]:
		var label := _label(column, "")
		column.move_child(label, insert)
		insert += 1
		var slider := HSlider.new()
		slider.min_value = 0
		slider.max_value = 1
		slider.step = .01
		slider.custom_minimum_size = Vector2(400, 24)
		slider.value = store.profile.settings.get(key, .8 if key == "sfx_volume" else .35)
		column.add_child(slider)
		column.move_child(slider, insert)
		insert += 1
		sound_sliders[key] = slider
		sound_labels[key] = label
		slider.value_changed.connect(_preview_audio_levels)
	sound_enabled.toggled.connect(_preview_audio_levels)
	var preview_button := _button(column, "Nghe thử: kiếm / hồi phục / thủ thế", Vector2.ZERO, Vector2(400, 42), _audition)
	column.move_child(preview_button, insert)
	_preview_audio_levels(0)
	box.set_deferred("size", Vector2(472, 610))

func _preview_audio_levels(_value: Variant) -> void:
	for key in sound_sliders:
		sound_labels[key].text = ("Hiệu ứng" if key == "sfx_volume" else "Không gian rừng") + " · %d%%" % roundi(sound_sliders[key].value * 100)
	audio.configure(sound_enabled.button_pressed, sound_sliders.sfx_volume.value, sound_sliders.ambience_volume.value)

func _audition() -> void:
	audio.audition()

func _apply_audio_settings() -> void:
	if store.audio_settings(sound_enabled.button_pressed, sound_sliders.sfx_volume.value, sound_sliders.ambience_volume.value):
		_close_audio_settings()
		audio.play("confirm")
	else:
		_notify(store.error)
		audio_notice.text = store.error + "\nBạn có thể thử lại hoặc Hủy."

func _cancel_audio_settings() -> void:
	_close_audio_settings()

func _close_audio_settings() -> void:
	audio.cancel_preview()
	audio_menu_open = false
	audio.apply_profile(store.profile)
	_close_modal()
	if audio_menu_paused and battle != null and battle.state == "battle":
		battle.paused = false
	audio_menu_paused = false
	sound_sliders.clear()
	sound_labels.clear()

func _exit_tree() -> void:
	if is_instance_valid(audio):
		audio.shutdown()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and not quit_requested:
		_request_quit()

func _request_quit() -> void:
	quit_requested = true
	set_process(false)
	set_physics_process(false)
	if is_instance_valid(audio):
		audio.shutdown()
	await get_tree().create_timer(.2).timeout
	get_tree().quit()

func _expansion_panel(page: int) -> void:
	_row("← Trở về " + ("nhân vật" if page in [6, 7] else "hành trình"), _select_tab.bind(1 if page in [6, 7] else 0))
	var p: Dictionary = store.profile
	match page:
		5:
			_text("THỬ THÁCH", 21, Color("e5cd9e"))
			_text("Săn boss kiếm lõi tinh linh để tiến hóa đồng hành. Điểm = số quái hạ × 100 + tối đa 300 điểm tốc độ. Không tiêu vé; thua không nhận thưởng.")
			for stage in catalog.data.stages:
				if stage.get("kind") != "challenge": continue
				var record: Dictionary = p.expansion.records.get(str(stage.id), {})
				_text(stage.name + " · %d đợt · +%d lõi" % [stage.waves.size(), stage.cores], 18, Color("e5cd9e"))
				_text("%d vàng · %d XP · 2 tinh thạch + loot" % [stage.gold, stage.xp])
				if not record.is_empty(): _text("Kỷ lục %d điểm · nhanh nhất %.1f giây mô phỏng" % [record.score, record.time])
				_stage_entry(stage)
			_text("CHƯƠNG TRUYỆN", 21, Color("e5cd9e"))
			_text("Mỗi chương có một màn chính và hai màn ký ức nối tiếp. Nhánh mới có thưởng đầu, loot và đối thoại riêng.")
			for chapter in catalog.data.chapters:
				_text("%d · %s" % [chapter.id, chapter.name], 18, Color("e5cd9e"))
				_stage_entry(catalog.find_row("stages", chapter.id))
				for id in [6 + (chapter.id - 1) * 2, 7 + (chapter.id - 1) * 2]: _stage_entry(catalog.find_row("stages", id))
		6:
			_text("CÂY KỸ NĂNG · " + catalog.find_row("heroes", p.hero).name, 21, Color("e5cd9e"))
			_text("NHÂN VẬT → KỸ NĂNG GỐC → NHÁNH. Hai kỹ năng riêng của nhân vật, mỗi kỹ năng chọn một trong hai nhánh. Học một lần, đổi miễn phí ngoài trận. Kỹ năng Tinh linh có cây riêng.")
			_row("Cây kỹ năng Tinh linh →", _select_tab.bind(13))
			var build: Dictionary = p.expansion.builds[p.hero]
			for i in range(2):
				_text(catalog.data.skills[i].name.to_upper(), 18, Color("e5cd9e"))
				for row in catalog.data.talents:
					if row.slot != i: continue
					_text(row.name + " · " + row.description)
					var learned: bool = row.id in build.learned
					var selected: bool = build.selected[i] == row.id
					_row(("✓ Bỏ chọn · " if selected else ("Chọn · " if learned else "Học · ")) + row.name + ("" if learned else " · cấp %d / %d vàng + %d tinh thạch" % [row.level, row.gold, row.shards]), _talent.bind(row.id), _locked() or p.heroes[p.hero].level < row.level or (not learned and (p.gold < row.gold or p.shards < row.shards)))
		7:
			_text("TIẾN HÓA ĐỒNG HÀNH", 21, Color("e5cd9e"))
			_text("Lõi tinh linh: %d · kiếm từ phụ bản hoặc thành tựu." % p.expansion.cores)
			for assist in catalog.data.assists:
				var rank: int = p.expansion.ranks[assist.id]
				_text("%s · cấp %d · bậc %d/3" % [assist.name, p.assists[assist.id], rank], 18, Color("e5cd9e"))
				_text("Bậc 2: mỗi lần hồi máu tạo khiên 8% HP trong 5 giây. Bậc 3: lượng hồi +25%." if assist.id == "lumi" else "Bậc 2: đòn trợ chiến gây 70% sát thương qua khiên. Bậc 3: đánh dấu, đòn vũ khí tiếp theo +20% sát thương.")
				_row("✓ Đang đi cùng" if p.assist == assist.id else "Đi cùng " + assist.name, _assist.bind(assist.id), _locked() or not store.available_assist(assist.id) or p.assist == assist.id)
				if p.assist == assist.id:
					_row("Nâng cấp · %d vàng" % (p.assists[p.assist] * 35), _upgrade.bind("assist", 0), _locked() or p.assists[p.assist] >= 20 or p.gold < p.assists[p.assist] * 35)
					_row("Đã đạt bậc tối đa" if rank == 3 else "Tiến hóa · cần cấp %d / %d vàng + %d lõi" % [rank * 3, rank * 80, 2 if rank == 1 else 5], _rank_assist, _locked() or rank == 3 or p.assists[p.assist] < rank * 3 or p.gold < rank * 80 or p.expansion.cores < (2 if rank == 1 else 5))
		8:
			_text("BỘ SƯU TẬP & THÀNH TỰU", 21, Color("e5cd9e"))
			_text("Vũ khí/giáp đã tìm thấy được ghi nhớ kể cả khi phân giải. Thành tựu nhận một lần, lưu cùng tài nguyên.")
			for achievement in catalog.data.achievements:
				var count := Expansion.metric(p, achievement.metric)
				_text("%s · %d/%d" % [achievement.name, mini(count, achievement.target), achievement.target], 18, Color("e5cd9e"))
				_row("Đã nhận" if achievement.id in p.expansion.claimed else "Nhận %d vàng + %d tinh thạch + %d lõi" % [achievement.gold, achievement.shards, achievement.cores], _achievement.bind(achievement.id), store.read_only or achievement.id in p.expansion.claimed or count < achievement.target)
			_text("TRANG BỊ ĐÃ KHÁM PHÁ · %d/%d" % [p.expansion.discovered.size(), catalog.data.items.size()], 18, Color("e5cd9e"))
			for item in catalog.data.items:
				_text(("✓ " if item.id in p.expansion.discovered else "○ Chưa tìm · ") + item.name + " · " + item.passive)
			_text("BOSS ĐÃ HẠ", 18, Color("e5cd9e"))
			for stage in catalog.data.stages:
				if stage.id <= 5: _text(("✓ " if stage.id in p.cleared else "○ ") + stage.boss)
			_text("ĐỒNG HÀNH", 18, Color("e5cd9e"))
			for assist in catalog.data.assists:
				_text("%s · %s · bậc %d" % [assist.name, "Đã mở" if store.available_assist(assist.id) else "Chưa mở", p.expansion.ranks[assist.id]])

func _stage_entry(stage: Dictionary) -> void:
	var available := store.can_enter(stage.id)
	var requirement := ""
	if not available:
		var id: int = stage.requires[0] if stage.has("requires") else stage.id - 1
		requirement = " · cần qua " + catalog.find_row("stages", id).name
	if not requirement.is_empty(): _text(requirement.trim_prefix(" · "), 14)
	_art_card(stage.name, "%d vàng · %d XP" % [stage.gold, stage.xp], "bg_" + stage.zone, _enter_stage.bind(stage.id), _locked() or not available, stage.id in store.profile.cleared)

func _talent(id: String) -> void:
	_outcome(Expansion.talent(store, id), "Đã cập nhật nhánh kỹ năng.", "upgrade")

func _rank_assist() -> void:
	_outcome(Expansion.rank_up(store), "Đồng hành đã tiến hóa!", "upgrade")

func _achievement(id: String) -> void:
	_outcome(Expansion.claim(store, id), "Đã nhận thành tựu.", "reward")

func _training_panel() -> void:
	_row("← Trở về nhân vật", _select_tab.bind(1))
	var p: Dictionary = store.profile
	var points := AttributeTraining.allocation(p, p.hero)
	var remaining := AttributeTraining.remaining(p, p.hero)
	var stats := catalog.stats(p)
	_text("ĐIỂM THUỘC TÍNH · " + catalog.find_row("heroes", p.hero).name, 21, Color("e5cd9e"))
	_text("Mỗi cấp sau cấp 1 cho 2 điểm riêng cho nhân vật. Còn %d điểm. Cộng, bớt và hoàn điểm miễn phí ngoài trận." % remaining)
	_text("HP %.0f · ATK %.1f · Thủ %.2f" % [stats.hp, stats.atk, stats.defense], 18, Color("e5cd9e"))
	for stat in AttributeTraining.ATTRIBUTES:
		var row: Dictionary = AttributeTraining.ATTRIBUTES[stat]
		_text("%s · %d điểm · tổng +%s" % [row.name, points[stat], str(points[stat] * row.bonus)], 18, Color("e5cd9e"))
		_row("+1 điểm · +%s %s" % [str(row.bonus), row.name], _train_attribute.bind(stat, 1), _locked() or remaining <= 0)
		_row("−1 điểm · hoàn lại 1 điểm", _train_attribute.bind(stat, -1), _locked() or points[stat] <= 0)
	_row("Hoàn toàn bộ điểm · miễn phí", _reset_attributes, _locked() or remaining == (p.heroes[p.hero].level - 1) * 2)
	if not p.pending.is_empty():
		_text("Đang có trận chưa kết thúc: điểm đã khóa theo build lúc vào trận.")

func _train_attribute(stat: String, amount: int) -> void:
	_outcome(AttributeTraining.change(store, stat, amount), "Đã cập nhật điểm thuộc tính.", "upgrade")

func _reset_attributes() -> void:
	_outcome(AttributeTraining.reset(store), "Đã hoàn điểm thuộc tính.")

func _boss_guide_panel() -> void:
	_row("← Trở về nhật ký", _select_tab.bind(4))
	_text("SỔ TAY BOSS", 21, Color("e5cd9e"))
	_text("Mở thông tin khi đường đến chương được mở. Chỉ số dưới đây là boss màn chính; ký ức và phụ bản có chỉ số riêng.")
	var elements := {"nature": "Tự nhiên", "fire": "Lửa", "water": "Nước", "light": "Ánh sáng", "dark": "Bóng tối"}
	var counters := {"nature": "Lửa", "fire": "Nước", "water": "Tự nhiên", "light": "Bóng tối", "dark": "Ánh sáng"}
	var hints := {
		"smash": "Đòn nặng: thủ thế ngay trước khi vòng báo đầy để giảm 80% sát thương. Giữ kỹ năng hồi phục khi máu thấp.",
		"shield": "Khiên: kỹ năng Tinh linh phá khiên. Đòn không có nội tại xuyên khiên chỉ gây 35% sát thương khi khiên còn hoạt động.",
		"counter": "Phản đòn: ngưng kỹ năng gây sát thương khi boss đang tụ lực. Đòn thường và thủ thế giúp chờ qua thời điểm nguy hiểm."
	}
	for stage in catalog.data.stages:
		if stage.id > 5:
			continue
		if not store.can_enter(stage.id):
			_text("Chương %d · Chưa mở · cần vượt chương trước" % stage.id)
			continue
		_text(stage.boss + (" · Đã hạ" if stage.id in store.profile.cleared else " · Chưa hạ"), 19, Color("e5cd9e"))
		_text(stage.name + " · " + elements[stage.element])
		_text("HP %d · ATK %d · Vũ khí hệ %s tăng 20%% sát thương" % [stage.boss_hp, stage.boss_atk, counters[stage.element]])
		_text(hints[stage.mechanic])
		var drops: Array[String] = []
		for id in stage.drops:
			drops.append(catalog.find_row("items", id).name)
		_text("Có thể rơi: " + ", ".join(drops), 14)

func _rarity(kind: String, id: String) -> String:
	return Recruitment.label(kind, id, catalog, store.profile)

func _entity_name(kind: String, id: String) -> String:
	return catalog.find_row({"hero": "heroes", "spirit": "assists", "item": "items"}[kind], id).name

func _summon_panel(embedded: bool = false) -> void:
	if not embedded: _row("← Trở về hành trình", _select_tab.bind(0))
	var screen := SummonScreen.new()
	screen.game = self
	panel.add_child(screen)

func _select_summon_kind(index: int) -> void:
	summon_kind = clampi(index, 0, 2)
	_refresh_panel()

func _summon_confirm(count: int) -> void:
	if summon_kind != 0 or _locked(): return
	_dialog("Triệu hồi ×%d?" % count, "Chi phí: %d vàng.\nMỗi lượt có bảo hiểm riêng theo bộ đếm. Mỗi món sở hữu một bản. Nhận trùng đổi thành 10 mảnh đúng trang bị, nhân vật hoặc tinh linh đó." % (Recruitment.PRICE * count), [{"text": "Triệu hồi", "call": _summon_execute.bind(count)}, {"text": "Hủy", "call": _close_modal}])

func _summon_execute(count: int) -> void:
	if summon_kind != 0 or _locked(): return
	_close_modal()
	if count == 1:
		_summon()
		return
	if not Recruitment.summon(store, count):
		_outcome(false, "")
		return
	_refresh_panel()
	_refresh_hud()
	audio.play("reward")
	SummonScreen.show_results(self, "KẾT QUẢ ×10", Recruitment.state(store.profile).history.slice(0, 10))

func _summon_history() -> void:
	SummonScreen.show_results(self, "LỊCH SỬ TRIỆU HỒI", Recruitment.state(store.profile).history)

func _summon_rates() -> void:
	var text := "Sở hữu tối đa một bản mỗi món/nhân vật/tinh linh. Trùng đổi thành 10 mảnh đúng loại.\nThường: 70% · Nâng cao: 25% · Cao cấp: 5%. Sau 19 lượt chưa ra nhóm Cao cấp, lượt 20 bảo đảm nhóm này. Đây là nhóm quay, độc lập độ hiếm.\n"
	for tier in [1, 2, 3]:
		var candidates := Recruitment.pool(catalog, tier)
		var total := 0
		for entry in candidates: total += int(entry.weight)
		text += "\n" + Recruitment.GROUP_NAMES[tier] + ":\n"
		for entry in candidates:
			text += "%s [%s]: %.2f%% trong nhóm\n" % [_entity_name(entry.kind, entry.id), _rarity(entry.kind, entry.id), float(entry.weight) / total * 100]
	SummonScreen.show_text(self, "TỶ LỆ TRIỆU HỒI THƯỜNG", text)

func _summon() -> void:
	if not Recruitment.summon(store):
		_outcome(false, "")
		return
	_refresh_panel()
	audio.play("reward")
	var result: Dictionary = store.profile.recruitment.history[0]
	var detail := "Trang bị đã vào túi." if result.kind == "item" else "Đã mở khóa để chọn trong Nhân vật."
	if result["duplicate"]: detail = "Nhận trùng" + CollectionFragments.reward_suffix(result) + " · " + _entity_name(result.kind, result.id)
	var column := _dialog(Recruitment.label(result.kind, result.id, catalog) + " · " + _entity_name(result.kind, result.id), detail, [{"text": "Đóng", "call": _close_modal}])
	column.get_child(0).modulate = Recruitment.color(result.kind, result.id, catalog)
	var image := TextureRect.new()
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture = frames.textures["companion_" + result.id] if result.kind == "spirit" else icons.textures["hero" if result.kind == "hero" else "equipment"]
	image.custom_minimum_size = Vector2(0, 150)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(image)
	column.move_child(image, 1)
	image.modulate.a = 0
	image.create_tween().tween_property(image, "modulate:a", 1.0, .25)

func _batch_level() -> void:
	_outcome(Recruitment.level_batch(store), "Đã tăng cấp nhân vật.", "upgrade")

func _awaken() -> void:
	_outcome(Recruitment.awaken(store), "Nhân vật đã thức tỉnh.", "upgrade")

func _spirit_tree_panel() -> void:
	_row("← Trở về nhân vật", _select_tab.bind(1))
	var p: Dictionary = store.profile
	var b: Dictionary = SpiritSkills.builds(p)[p.assist]
	_text("CÂY TINH LINH · " + catalog.find_row("assists", p.assist).name, 22, Color("a2e5d6"))
	_text("Đồng hành cấp %d/20 · Kỹ năng chủ động cấp %d/10" % [p.assists[p.assist], b.level])
	_text("Cấp chủ động và nhánh được lưu riêng theo tinh linh. Đổi nhân vật không đổi cây này. Đổi nhánh đã học miễn phí; mỗi tầng chọn một nhánh.")
	_text("◆ GỐC · Tinh linh phá khiên · cấp %d/10" % b.level, 18, Color("e5cd9e"))
	_row("Nâng kỹ năng tinh linh · %d vàng" % (b.level * 25), _upgrade.bind("skill", 2), _locked() or b.level >= 10 or p.gold < b.level * 25)
	_text("│\n├─ TẦNG 1 · Đồng hành cấp 4", 17, Color("a2e5d6"))
	for id in ["nova", "flow"]:
		var row := catalog.find_row("talents", id)
		_text(row.name + " · " + row.description)
		_row(("✓ Bỏ chọn · " if b.selected == id else ("Chọn · " if id in b.learned else "Học · ")) + row.name + ("" if id in b.learned else " · 80 vàng + 3 tinh thạch"), _spirit_talent.bind(id), _locked() or p.assists[p.assist] < 4 or (id not in b.learned and (p.gold < 80 or p.shards < 3)))
	_text("│\n└─ TẦNG 2 · Đồng hành cấp 6 + một nhánh tầng 1", 17, Color("a2e5d6"))
	for id in SpiritSkills.ADVANCED:
		var row: Dictionary = SpiritSkills.ADVANCED[id]
		_text(row.name + " · " + row.description)
		_row(("✓ Bỏ chọn · " if b.advanced == id else ("Chọn · " if id in b.advanced_learned else "Học · ")) + row.name + ("" if id in b.advanced_learned else " · 100 vàng + 3 tinh thạch"), _spirit_talent.bind(id), _locked() or p.assists[p.assist] < 6 or b.selected == "" or (id not in b.advanced_learned and (p.gold < 100 or p.shards < 3)))

func _spirit_talent(id: String) -> void:
	_outcome(SpiritSkills.choose(store, id), "Đã cập nhật cây kỹ năng tinh linh.", "upgrade")

func _map_panel() -> void:
	_row("← Trở về chiến đấu", _select_tab.bind(0))
	_text("BẢN ĐỒ HÀNH TRÌNH", 23, Color("e5cd9e"))
	for stage in catalog.data.stages:
		if stage.id > 5: continue
		_art_card(stage.name, "%d vàng · %d XP" % [stage.gold, stage.xp], "bg_" + stage.zone, _map_stage.bind(stage.id), _locked() or not store.can_enter(stage.id), stage.id == selected_stage)
	_row("Chương truyện & Phụ bản →", _select_tab.bind(5))

func _map_stage(id: int) -> void:
	_choose_stage(id)
	_select_tab(0)

func _more_panel() -> void:
	var screen := UtilitiesScreen.new()
	screen.game = self
	panel.add_child(screen)

func _utility_mail() -> void:
	_dialog("HỘP THƯ", "Hộp thư trống.\n\nQuà hệ thống, thông báo và đền bù sẽ xuất hiện tại đây khi dịch vụ hộp thư mở.", [{"text": "Đóng", "call": _close_modal}])

func _utility_giftcode() -> void:
	var column := _dialog("ĐỔI MÃ QUÀ TẶNG", "Nhận giftcode từ các sự kiện. Hiện chưa có đợt đổi mã đang mở.", [{"text": "Đóng", "call": _close_modal}])
	var input := LineEdit.new()
	input.placeholder_text = "Nhập mã quà tặng"
	input.editable = false
	input.custom_minimum_size.y = 46
	column.add_child(input)
	column.move_child(input, 2)
	var redeem := _button(column, "Đổi mã · Chưa mở", Vector2.ZERO, Vector2(400, 46), func(): pass)
	redeem.disabled = true
	column.move_child(redeem, 3)

func _utility_settings() -> void:
	_dialog("CÀI ĐẶT", "Tùy chỉnh trải nghiệm và hồ sơ người chơi.", [{"text": "Âm thanh & mức âm lượng", "call": _audio_settings}, {"text": "Đồ họa & hiển thị", "call": _utility_graphics}, {"text": "Tài khoản & Hồ sơ", "call": _show_player_profile}, {"text": "Đóng", "call": _close_modal}])

func _utility_graphics() -> void:
	_dialog("ĐỒ HỌA & HIỂN THỊ", "Game dùng giao diện dọc, tự co theo cửa sổ.\n\nHiện dùng cấu hình đồ họa mặc định. Tùy chọn chất lượng và giới hạn FPS sẽ được bổ sung sau.", [{"text": "Về cài đặt", "call": _utility_settings}, {"text": "Đóng", "call": _close_modal}])

func _utility_help() -> void:
	SummonScreen.show_text(self, "TRỢ GIÚP & HỖ TRỢ", "HƯỚNG DẪN\nChọn nhân vật và trang bị trước khi vào ải. Dùng tinh linh phá khiên, thủ thế trước đòn mạnh của Boss.\n\nNâng cấp nhân vật ở mục Nhân vật; quản lý trang bị và nguyên liệu trong Túi đồ. Xem tỷ lệ trước khi triệu hồi.\n\nBÁO LỖI\nKhi gửi lỗi cho nhóm phát triển, kèm phiên bản game, thiết bị, các bước tái hiện và ảnh hoặc video. Giữ bản sao save trước khi cài lại.\n\nPhiên bản: " + str(ProjectSettings.get_setting("application/config/version", "")) + "\n\nKênh liên hệ và gửi báo lỗi trong game chưa được cấu hình.")

func _bag_open(section: String) -> void:
	bag_section = section
	_select_tab(2)

func _items_panel() -> void:
	var p: Dictionary = store.profile
	if bag_section == "":
		_text("TÚI ĐỒ", 25, Color("e5cd9e"))
		_text("Trang bị, tinh linh và nguyên liệu được quản lý trong các kho riêng.")
		var grid := GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 10)
		panel.add_child(grid)
		var owned := 0
		for spirit in catalog.data.assists:
			if store.available_assist(spirit.id): owned += 1
		_inventory_card(grid, "equipment", "Trang bị", "%d loại · mỗi món một bản" % p.items.size(), Color("86caff"), _bag_open.bind("equipment"), 232)
		_inventory_card(grid, "companion", "Tinh linh", "%d / %d đã mở" % [owned, catalog.data.assists.size()], Color("a2e5d6"), _bag_open.bind("spirits"), 232)
		_inventory_card(grid, "crystal", "Nguyên liệu", "Tinh thạch · lõi · mảnh", Color("d7a4ff"), _bag_open.bind("materials"), 232)
		_inventory_card(grid, "forge", "Lò rèn", "Chế tạo trang bị", Color("e5cd9e"), _select_tab.bind(19), 232)
		return
	_row("← Các kho trong Túi đồ", _bag_open.bind(""))
	match bag_section:
		"equipment": _equipment_inventory()
		"spirits":
			_text("KHO TINH LINH", 22, Color("a2e5d6"))
			_text("Chọn để xem chi tiết, đi cùng, nâng cấp hoặc mở cây kỹ năng.")
			var select := OptionButton.new()
			select.custom_minimum_size = Vector2(464, 44)
			for title in ["Tất cả tinh linh", "SR", "SSR", "UR"]: select.add_item(title)
			select.selected = bag_spirit_rarity
			select.item_selected.connect(_spirit_rarity_filter)
			panel.add_child(select)
			var shown := 0
			for spirit in catalog.data.assists:
				if bag_spirit_rarity != 0 and Recruitment.rarity("spirit", spirit.id, catalog) != bag_spirit_rarity: continue
				var available := store.available_assist(spirit.id)
				var b := _row(spirit.name + " · " + _rarity("spirit", spirit.id) + (" · cấp %d · bậc %d" % [p.assists[spirit.id], p.expansion.ranks[spirit.id]] if available else " · Chưa mở"), _open_spirit.bind(spirit.id))
				icons.apply(b, "companion", 36)
				b.add_theme_color_override("font_color", Recruitment.color("spirit", spirit.id, catalog))
				shown += 1
			if shown == 0: _text("Chưa có tinh linh phù hợp. Hệ phân loại hỗ trợ SR / SSR / UR.")
		"materials":
			_text("KHO NGUYÊN LIỆU", 22, Color("d7a4ff"))
			_material_text("Tinh thạch · %d" % p.shards, "shards", Color("86caff"))
			_text("Cường hóa, tiến bậc, rèn và học nhánh kỹ năng.")
			_material_text("Lõi tinh linh · %d" % p.expansion.cores, "cores", Color("a2e5d6"))
			_text("Dùng tiến hóa nhân vật và đồng hành; kiếm từ phụ bản hoặc thành tựu.")
			var r := Recruitment.state(p)
			for hero in catalog.data.heroes:
				_material_text("Mảnh %s · %d" % [hero.name, r.fragments[hero.id]], "fragments", Color("e5cd9e"))
			_text("Mảnh nhân vật dùng mở rộng, tăng sao đúng nhân vật đó.")
			_text("MẢNH TINH LINH", 18, Color("a2e5d6"))
			for spirit in catalog.data.assists:
				_material_text("Mảnh %s · %d" % [spirit.name, p.collection_fragments.spirits[spirit.id]], "fragments", Color("a2e5d6"))
			_text("MẢNH TRANG BỊ", 18, Color("e5cd9e"))
			for item in catalog.data.items:
				_material_text("%s · %d mảnh" % [item.name, p.collection_fragments.items[item.id]], item.id, Color("e5cd9e"))
			_text("Mảnh giữ riêng từng loại. Tính năng dùng mảnh trang bị/tinh linh chưa mở.", 13)
			_material_text("Kinh nghiệm nhân vật · %d XP" % p.xp, "xp", Color("c0d0cb"))
			_row("Cường hóa & Mở rộng →", _select_tab.bind(12))
			_row("Tiến hóa đồng hành →", _select_tab.bind(7))
			_row("Đến lò rèn →", _select_tab.bind(19))

func _inventory_card(parent: Node, key: String, title: String, subtitle: String, color: Color, action: Callable, width: int = 112) -> Button:
	var card := _button(parent, "", Vector2.ZERO, Vector2(width, 118), action)
	card.tooltip_text = title + " · " + subtitle
	card.add_theme_stylebox_override("normal", _style(Color("172733"), color.darkened(.45), 12))
	var image := TextureRect.new()
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.texture = icons.textures[key]
	if action.get_method() == "_item_detail":
		for item in store.profile.items:
			if item.uid == action.get_bound_arguments()[0]: image.texture = frames.textures["icon_" + _item_art_key(item.base)]
	elif action.get_method() == "_open_spirit": image.texture = frames.textures["companion_" + str(action.get_bound_arguments()[0])]
	image.position = Vector2((width - 40) / 2.0, 10)
	image.size = Vector2(48, 48)
	image.position.x -= 4
	image.position.y -= 4
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	card.add_child(image)
	var name_label := _label(card, title, Vector2(4, 55), 13, color)
	name_label.size = Vector2(width - 8, 36)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var detail := _label(card, subtitle, Vector2(4, 97), 10, Color("c0d0cb"))
	detail.size = Vector2(width - 8, 16)
	detail.clip_text = true
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return card

func _equipment_inventory() -> void:
	var p: Dictionary = store.profile
	_text("KHO TRANG BỊ · %d loại" % p.items.size(), 21, Color("e5cd9e"))
	var filters := HBoxContainer.new()
	panel.add_child(filters)
	for is_rarity in [false, true]:
		var select := OptionButton.new()
		select.custom_minimum_size = Vector2(235, 44)
		var titles: Array = ["Mọi độ hiếm"] if is_rarity else ["Tất cả trang bị", "Vũ khí", "Giáp"]
		if is_rarity:
			for tier in Recruitment.RARITIES: titles.append(Recruitment.RARITIES[tier].name)
		for title in titles: select.add_item(title)
		select.selected = ([0] + Recruitment.RARITIES.keys()).find(bag_rarity) if is_rarity else ["all", "weapon", "armor"].find(bag_kind)
		select.item_selected.connect(_bag_filter.bind(is_rarity))
		filters.add_child(select)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 8)
	panel.add_child(grid)
	var items: Array = p.items.duplicate()
	items.sort_custom(func(a, b):
		var ra := int(catalog.find_row("items", a.base).rarity)
		var rb := int(catalog.find_row("items", b.base).rarity)
		return ra > rb if ra != rb else str(a.uid) < str(b.uid))
	var shown := 0
	for item in items:
		var def := catalog.find_row("items", item.base)
		if bag_kind != "all" and def.slot != bag_kind: continue
		if bag_rarity != 0 and def.rarity != bag_rarity: continue
		var owners: Array[String] = []
		for hero in p.heroes:
			if item.uid in p.heroes[hero].equipment.values(): owners.append(catalog.find_row("heroes", hero).name)
		var owner := ", ".join(owners)
		var card := _inventory_card(grid, "slash" if def.slot == "weapon" else "guard", def.name, (owner if owner != "" else _rarity("item", item.base)) + " +%d" % item.enhance, Color(Recruitment.RARITIES[def.rarity].color), _item_detail.bind(item.uid))
		shown += 1
	if shown == 0: _text("Không có trang bị phù hợp bộ lọc.")
	_text("%d món hiển thị · chạm để xem hoặc trang bị" % shown, 13)

func _bag_filter(index: int, is_rarity: bool) -> void:
	if is_rarity: bag_rarity = ([0] + Recruitment.RARITIES.keys())[index]
	else: bag_kind = ["all", "weapon", "armor"][index]
	_refresh_panel()

func _open_spirit(id: String) -> void:
	selected_spirit = id
	_select_tab(18)

func _spirit_rarity_filter(index: int) -> void:
	bag_spirit_rarity = index
	_refresh_panel()

func _spirit_inventory_detail() -> void:
	_row("← Kho tinh linh", _bag_open.bind("spirits"))
	var p: Dictionary = store.profile
	var spirit := catalog.find_row("assists", selected_spirit)
	_text(spirit.name + " · " + _rarity("spirit", spirit.id), 24, Recruitment.color("spirit", spirit.id, catalog))
	_text("Mảnh %s · %d" % [spirit.name, p.collection_fragments.spirits[spirit.id]], 16, Color("a2e5d6"))
	var image := TextureRect.new()
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.texture = frames.textures["companion_" + spirit.id]
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.custom_minimum_size = Vector2(0, 170)
	panel.add_child(image)
	if not store.available_assist(spirit.id):
		_text("Chưa mở · vượt chương %d hoặc nhận từ triệu hồi." % (spirit.unlock - 1))
		_row("Đến triệu hồi →", _select_tab.bind(11))
		return
	_text("%s · cấp %d/20 · tiến hóa %d/3" % [spirit.role, p.assists[spirit.id], p.expansion.ranks[spirit.id]])
	_row("✓ Đang đi cùng" if p.assist == spirit.id else "Chọn đi cùng", _assist.bind(spirit.id), _locked() or p.assist == spirit.id)
	if p.assist == spirit.id:
		_row("Nâng cấp · %d vàng" % (p.assists[p.assist] * 35), _upgrade.bind("assist", 0), _locked() or p.assists[p.assist] >= 20 or p.gold < p.assists[p.assist] * 35)
		_row("Cây kỹ năng tinh linh →", _select_tab.bind(13))
		_row("Tiến hóa tinh linh →", _select_tab.bind(7))

func _forge_panel() -> void:
	_row("← Túi đồ", _bag_open.bind(""))
	_text("LÒ RÈN", 23, Color("e5cd9e"))
	_text("65 vàng + 3 tinh thạch / lượt. Món đã có đổi thành 10 mảnh đúng món đó. Trang bị từ Sử thi trở lên chỉ từ triệu hồi.")
	var p: Dictionary = store.profile
	for def in catalog.data.items:
		if def.get("summon_only", false): continue
		_row("Rèn · " + def.name + " · " + _rarity("item", def.id), _forge.bind(def.id), _locked() or p.gold < 65 or p.shards < 3)

func _shop_panel() -> void:
	var screen := ShopScreen.new()
	screen.game = self
	screen.selected = shop_page
	panel.add_child(screen)

func _shop_section(index: int) -> void:
	if index < 0 or index >= ShopScreen.SECTIONS.size(): return
	shop_page = index
	_refresh_panel()

func _shop_buy_confirm(id: String) -> void:
	if id not in LocalShop.OFFERS: return
	var offer: Dictionary = LocalShop.OFFERS[id]
	_dialog(offer.name, "Mua với %d vàng?" % offer.gold, [{"text": "Mua", "call": _shop_buy.bind(id)}, {"text": "Hủy", "call": _close_modal}])

func _shop_buy(id: String) -> void:
	_close_modal()
	_outcome(LocalShop.buy(store, id), "Đã nhận hàng từ cửa hàng vàng.", "reward")

func _show_ryn_portrait() -> void:
	var column := _dialog("RYN · Thương thủ hỏa vũ", "Chạm/kéo rồi thả để xem chuyển động.", [{"text": "Đóng", "call": _close_modal}])
	var view := HeroPortrait.new()
	view.library = frames
	view.hero = "ryn"
	view.interactive = store.available_hero("ryn") and Recruitment.rarity("hero", "ryn", catalog) == 5
	view.palette_tint = Wardrobe.tint(store.profile, "ryn")
	view.custom_minimum_size = Vector2(400, 480)
	column.add_child(view)
	column.move_child(view, 1)
	var box: PanelContainer = modal.get_child(1)
	box.position.y = 110
	box.set_deferred("size", Vector2(472, 730))

func _dungeons_panel() -> void:
	_text("PHÓ BẢN", 25, Color("e5cd9e"))
	_text("Thử thách để kiếm lõi tinh linh. Không tiêu vé; phần thưởng nhận khi thắng.")
	_text("Đối thủ thuộc nhóm 1–4★; tách khỏi nhân vật chơi 5★.", 13)
	for stage in catalog.data.stages:
		if stage.get("kind") != "challenge": continue
		_text(stage.name, 20, Color("e5cd9e"))
		_text("%d đợt · %d vàng · %d XP · %d lõi" % [stage.waves.size(), stage.gold, stage.xp, stage.cores])
		var record: Dictionary = store.profile.expansion.records.get(str(stage.id), {})
		if not record.is_empty(): _text("Kỷ lục %d điểm · %.1f giây" % [record.score, record.time])
		_stage_entry(stage)
	_row("Chương truyện & Ký ức →", _select_tab.bind(5))

func _inspect_character(id: String) -> void:
	if catalog.find_row("heroes", id).is_empty(): return
	character_inspected = id
	character_outfit_preview = ""
	_refresh_panel()

func _character_section(index: int) -> void:
	if index < 0 or index > 6: return
	character_page = index
	_refresh_panel()

func _character_level(id: String, count: int) -> void:
	var success: bool = store.upgrade("hero", 0, id) if count == 1 else Recruitment.level_batch(store, count, id)
	_outcome(success, "Đã cường hóa, tăng LV nhân vật.", "upgrade")

func _character_stars(id: String) -> void:
	_outcome(Recruitment.awaken(store, id), "Đã mở rộng, tăng sao nhân vật.", "upgrade")

func _character_evolve(id: String) -> void:
	_outcome(HeroEvolution.evolve(store, id), "Nhân vật đã tiến hóa.", "upgrade")

func _character_equip(uid: String, id: String) -> void:
	_outcome(store.equip(uid, id), "Đã trang bị cho nhân vật.", "equip")

func _character_unequip(uid: String, id: String) -> void:
	_outcome(store.unequip(uid, id), "Đã tháo trang bị.", "equip")

func _character_skill_level(hero: String, index: int) -> void:
	_outcome(store.upgrade("skill", index, hero), "Đã nâng kỹ năng nhân vật.", "upgrade")

func _character_talent(hero: String, id: String) -> void:
	_outcome(Expansion.talent(store, id, hero), "Đã cập nhật cây kỹ năng.", "upgrade")

func _preview_character_outfit(id: String) -> void:
	if id not in Wardrobe.LOOKS: return
	character_outfit_preview = id
	_refresh_panel()

func _apply_character_outfit(hero: String, id: String) -> void:
	_outcome(Wardrobe.apply(store, hero, id), "Đã áp dụng phối màu.")

func _art_card(title: String, description: String, key: String, action: Callable, disabled: bool = false, selected: bool = false) -> Button:
	var card := _button(panel, "", Vector2.ZERO, Vector2(464, 112), action)
	card.disabled = disabled
	card.tooltip_text = title + " · " + description
	card.add_theme_stylebox_override("normal", _style(Color("1c3741") if selected else Color("122a38"), Color("d3b574") if selected else Color("3b5360"), 14))
	card.add_theme_stylebox_override("disabled", _style(Color("172d38") if selected else Color("102430"), Color("b19b68") if selected else Color("32444e"), 14))
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 10)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)
	var art := ArtThumbnail.new()
	art.library = frames
	art.custom_minimum_size = Vector2(128 if key.begins_with("bg_") else 78, 86)
	art.clip_contents = true
	if key.begins_with("hero_"):
		art.hero = key.trim_prefix("hero_")
		art.weapon = catalog.stats(store.profile, art.hero).weapon
	else: art.key = key
	art.modulate.a = .6 if disabled and not selected else 1.0
	row.add_child(art)
	var words := VBoxContainer.new()
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.alignment = BoxContainer.ALIGNMENT_CENTER
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(words)
	var heading := _label(words, ("✓ " if selected else "") + title, Vector2.ZERO, 17, Color("ead6a6") if selected else Color("e3dfd0"))
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	heading.max_lines_visible = 2
	var body := _label(words, description, Vector2.ZERO, 13, Color("a9c4c6"))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.max_lines_visible = 3
	return card

func _item_art_key(id: String) -> String:
	if frames.textures.has("icon_" + id): return id
	return "armor_3"

func _item_illustration(id: String) -> void:
	var image := TextureRect.new()
	image.texture = frames.textures["icon_" + _item_art_key(id)]
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.custom_minimum_size = Vector2(120, 120)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(image)

func _show_player_profile() -> void:
	if battle != null:
		message = "Mở hồ sơ sau khi kết thúc trận."
		message_time = 3
		return
	PlayerProfilePanel.show_profile(self)

func _show_vip(tier: int = 1) -> void:
	PlayerProfilePanel.show_vip(self, tier)

func _journey_afk() -> void:
	var amount := store.offline_preview(int(Time.get_unix_time_from_system()))
	var column := _dialog("KHO TIẾP TẾ AFK", "Đang có: %d vàng\nTốc độ: %d vàng/phút · Tối đa 2 giờ\n\nSản lượng tăng theo chương Story chính đã mở. Thưởng dựa trên thời gian tích lũy của đồng hồ máy." % [amount, store.unlocked_stage() * 2], [{"text":"Đóng", "call":_close_modal}])
	var button := _button(column, "Nhận %d vàng" % amount, Vector2.ZERO, Vector2(400, 46), _journey_claim_afk)
	button.disabled = amount <= 0 or _locked()
	column.move_child(button, column.get_child_count() - 2)

func _journey_claim_afk() -> void:
	_close_modal()
	_offline()

func _journey_auto() -> void:
	if not JourneyScreen.auto_unlocked(store.profile) or _locked(): return
	_dialog("TỰ CHIẾN ẢI ĐANG CHỌN", "Nhân vật tự đánh trong trận thật, có thể dùng kỹ năng và thủ thế. Dừng ở kết quả trận; không quét thưởng hay tự chuyển sang ải khác.", [{"text":"Bắt đầu", "call":_begin}, {"text":"Hủy", "call":_close_modal}])
