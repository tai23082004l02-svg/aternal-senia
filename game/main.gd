extends Node2D

const Catalog = preload("res://game/core/catalog.gd")
const Store = preload("res://game/core/progress.gd")
const Battle = preload("res://game/core/battle.gd")
const Frames = preload("res://game/core/frame_library.gd")
const View = preload("res://game/battle_view.gd")
const NAV_PAGES := [22, 1, 2, 20, 4]
const NAV_LABELS := ["Formation", "Equipment", "Bag", "Shop", "More"]
var catalog: GameCatalog
var store: ProgressStore
var team_ui: TeamBattleUI
var formation_slot := 0
var formation_roster_offset := 0
var next_team_options: Dictionary = {}
var battle: BattleModel
var frames: FrameLibrary
var view: BattleView
var ui: Control
var mission_tab := 0
var dungeon_group := "resource"
var dungeon_selected := ""
var dungeon_difficulty := 1
var dungeon_list_offset := 0
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
var tab := 24
var home_hero := ""
var selected_stage := 1
var selected_item := ""
var equipment_target := ""
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
var presentation_options: Dictionary = GameOptions.DEFAULTS.duplicate(true)
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
var supply_selected := ""
var supply_group := "all"
var supply_hero := ""
var bag_sort := 0
var bag_selecting := false
var bag_selected: Array[String] = []
var forge_page := 0
var forge_count := 1
var bag_kind := "all"
var bag_rarity := 0
var bag_spirit_rarity := 0
var selected_spirit := "lumi"
var character_inspected := ""
var character_page := 0
var character_skill_view := "overview"
var character_talent_focus := "focus"
var character_outfit_preview := ""
var summon_kind := 0
var shop_page := 0
var currency_labels: Dictionary = {}
var journey_wallet_frames: Array[Panel] = []

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
	_apply_presentation()
	_refresh_panel()
	if store.read_only:
		_dialog("Progress Protected", store.error, [{"text": "Got It", "call": _close_modal}])
	elif not store.profile.pending.is_empty():
		_dialog("Unfinished Battle", "Resume restarts this battle with the same saved heroes, equipment, and random seed.", [{"text": "Continue", "call": _resume}, {"text": "Abandon · No rewards", "call": _abandon}])
	else:
		_notify("Explore Gallery, or open Journey to prepare your team.")

func _build_ui() -> void:
	add_child(MenuBackdrop.new())
	ui = Control.new()
	ui.size = Vector2(540, 960)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var theme := Theme.new()
	theme.default_font_size = 16
	theme.default_font = UIFonts.font("regular")
	theme.set_font("font", "Button", UIFonts.font("medium"))
	theme.set_font("font", "LineEdit", UIFonts.font("regular"))
	theme.set_font("font", "OptionButton", UIFonts.font("medium"))
	theme.set_font("font", "ItemList", UIFonts.font("medium"))
	var normal := UIDesignV2.panel()
	var hover := UIDesignV2.panel(true)
	theme.set_stylebox("normal", "Button", normal)
	theme.set_stylebox("hover", "Button", hover)
	theme.set_stylebox("pressed", "Button", UIDesignV2.panel(true))
	theme.set_stylebox("disabled", "Button", _style(Color("10182b"), Color("40465d"), 7))
	theme.set_color("font_color", "Button", Color("ede5d0"))
	theme.set_color("font_disabled_color", "Button", Color("74858c"))
	theme.set_color("font_color", "Label", Color("dedfd5"))
	ui.theme = theme
	add_child(ui)
	profile_button = _button(ui, "", Vector2(24, 17), Vector2(332, 61), _show_player_profile)
	profile_button.flat = true
	profile_button.tooltip_text = "Profile & VIP"
	profile_avatar = PlayerProfilePanel.RoundAvatar.new()
	profile_avatar.position = Vector2(3, 3)
	profile_avatar.size = Vector2(54, 54)
	profile_avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	profile_button.add_child(profile_avatar)
	profile_name = _label(profile_button, "", Vector2(70, 4), 20, Color("ecdfbc"))
	profile_name.size = Vector2(246, 29)
	profile_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	profile_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	profile_vip = _label(profile_button, "VIP · Inactive  ›", Vector2(70, 35), 13, Color("e1c38d"))
	profile_vip.size = Vector2(270, 22)
	profile_vip.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	profile_vip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wallet = _label(ui, "", Vector2(24, 88), 14, Color("e1c38d"))
	wallet.visible = false
	for i in range(3):
		var capsule := Panel.new()
		capsule.position = Vector2(20 + i * 168, 83)
		capsule.size = Vector2(160, 34)
		capsule.mouse_filter = Control.MOUSE_FILTER_IGNORE
		capsule.add_theme_stylebox_override("panel", UIDesignV2.panel())
		ui.add_child(capsule)
		journey_wallet_frames.append(capsule)
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
	mute_button = _button(ui, "Sound: On", Vector2(422, 25), Vector2(94, 34), _toggle_sound)
	var home_button: Button = _button(ui, "Home", Vector2(358, 25), Vector2(56, 44), _select_tab.bind(24))
	home_button.tooltip_text = "Home"
	home_button.add_theme_font_size_override("font_size", 12)
	stage_label = _label(ui, "", Vector2(24, 143), 19, Color("eee8d6"))
	stage_label.set_meta("font_role", "display")
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
	skill_group_labels.append(_label(ui, "HEROES", Vector2(24, 583), 11, Color("e5cd9e")))
	skill_group_labels.append(_label(ui, "SPIRIT", Vector2(356, 583), 11, Color("a2e5d6")))
	for i in range(3):
		skill_buttons.append(_button(ui, "", Vector2(24 + i * 166, 598), Vector2(160, 44), _skill.bind(i)))
		icons.apply(skill_buttons[i], ["slash", "heal", "spirit"][i], 28)
		skill_buttons[i].add_theme_font_size_override("font_size", 12)
	attack_button = _button(ui, "Attack", Vector2(24, 651), Vector2(82, 36), _attack)
	guard_button = _button(ui, "Guard", Vector2(112, 651), Vector2(113, 36), _guard)
	icons.apply(guard_button, "guard", 22)
	guard_button.add_theme_font_size_override("font_size", 13)
	auto_button = _button(ui, "Auto Attack", Vector2(231, 651), Vector2(99, 36), _toggle_auto)
	pause_button = _button(ui, "Stop", Vector2(336, 651), Vector2(90, 36), _toggle_pause)
	speed_button = _button(ui, "×1", Vector2(432, 651), Vector2(84, 36), _speed)
	for i in range(5):
		tabs.append(_button(ui, NAV_LABELS[i], Vector2(24 + i * 99, 876), Vector2(93, 56), _bottom_navigation.bind(i)))
		icons.tab(tabs[i], ["formation", "equipment", "bag", "shop", "more"][i])
	for control in [attack_button, guard_button, auto_button, pause_button, speed_button]:
		control.custom_minimum_size.y = 44
		control.size.y = 44
	scroll = SwipeScroll.new()
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
	team_ui = TeamBattleUI.new()
	team_ui.game = self
	ui.add_child(team_ui)

func _style(fill: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	# Unify legacy dark teal panels with the celestial navy theme.
	if fill.v < .5 and fill.g > fill.r:
		fill = Color.from_hsv(.64,.62,maxf(fill.v,.12),fill.a)
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
	status_label.text = message if message_time > 0 else ("Use Map to change stages · Open Bag to prepare" if battle == null else ("Auto attacks and basic skills · Tap enemies to target · Toggle AUTO ULT" if battle is TeamBattle else "Auto attacks + tap combo · Guard reduces damage by 80% for 0.7 seconds"))

func _refresh_hud() -> void:
	var p: Dictionary = store.profile
	profile_name.text = PlayerIdentity.state(p).name
	profile_vip.text = "VIP · %d EXP · Unranked ›" % MissionBoard.state(p).vip_exp
	profile_avatar.update_avatar(frames, PlayerIdentity.state(p).avatar)
	wallet.text = ""
	for key in currency_labels:
		currency_labels[key].text = "%d %s" % [p[key], {"gold": "Gold", "shards": "Crystals", "xp": "XP"}[key]]
	if battle is TeamBattle:
		mute_button.text = "Sound: On" if p.settings.sound else "Sound: Off"
		return
	var active := battle != null
	var stats: Dictionary = battle.stats if active else catalog.stats(p)
	var hero := catalog.find_row("heroes", stats.hero)
	hp_label.text = "%s · %d / %d HP" % [hero.name, battle.hp if active else stats.hp, stats.hp]
	hp_bar.value = (battle.hp if active else stats.hp) / stats.hp * 100
	enemy_label.text = "%s · %d / %d" % [(battle.stage.boss if battle.is_boss() else "Dark") if active else "Dark", battle.enemy_hp if active else 55, battle.enemy_max if active else 55]
	if active and battle.move_clock > 0:
		enemy_label.text = "Advancing to the next wave…"
	enemy_bar.value = battle.enemy_hp / battle.enemy_max * 100 if active else 100
	sp_bar.value = battle.sp if active else 100
	stage_label.text = "%s%s" % [catalog.find_row("stages", selected_stage).name, (" · %d/%d" % [battle.wave + 1, battle.wave_count()]) if active else ""]
	warning_label.text = battle.warning() if active else "Four heroes. One spirit. A new dawn."
	var can_play := active and battle.state == "battle" and modal == null and not battle.paused
	skill_group_labels[0].text = "HERO · " + catalog.find_row("heroes", battle.stats.hero if active else p.hero).name
	skill_group_labels[1].text = "SPIRIT · " + catalog.find_row("assists", battle.stats.assist if active else p.assist).name
	for i in range(3):
		var def: Dictionary = catalog.data.skills[i]
		var cd: float = battle.cooldowns[i] if active else 0.0
		skill_buttons[i].text = def.name + (" · %ds" % ceili(cd) if cd > 0 else " · %d SP" % (25 if active and i == 2 and battle.variant("flow") else def.cost))
		skill_buttons[i].disabled = not can_play or cd > 0 or battle.sp < (25 if i == 2 and battle.variant("flow") else def.cost) or not battle.actions.is_empty() or battle.move_clock > 0 if active else true
	attack_button.disabled = not can_play
	guard_button.disabled = not can_play or (active and battle.guard_cd > 0)
	guard_button.text = "Guard · %ds" % ceili(battle.guard_cd) if active and battle.guard_cd > 0 else "Guard"
	pause_button.disabled = not active or battle.state != "battle"
	pause_button.text = "Continue" if active and battle.paused else "Stop"
	auto_button.text = "Auto: On" if not active or battle.auto_attack else "Auto: Off"
	speed_button.text = "×%d" % (battle.speed if active else p.settings.speed)
	mute_button.text = "Sound: On" if p.settings.sound else "Sound: Off"

func _bottom_navigation(index: int) -> void:
	if index < 0 or index >= NAV_PAGES.size() or result_transition: return
	if index == 1:
		character_page = 1
		character_outfit_preview = ""
	_select_tab(NAV_PAGES[index])

func _select_tab(index: int) -> void:
	if index == 6:
		character_page = 5
		index = 1
	if index == 7:
		selected_spirit = store.profile.assist
		index = 18
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
	_style_currency_shell()
	team_ui.visible = campaign and battle is TeamBattle
	view.visible = campaign and fighting and not battle is TeamBattle
	for control in [hp_label, enemy_label, warning_label, hp_bar, enemy_bar, sp_bar, guard_button, attack_button, pause_button, auto_button, speed_button, stage_label, tap_target]:
		control.visible = campaign and fighting and not battle is TeamBattle
	stage_label.visible = campaign and fighting and not battle is TeamBattle
	for control in skill_buttons:
		control.visible = campaign and fighting and not battle is TeamBattle
	for control in skill_group_labels:
		control.visible = campaign and fighting and not battle is TeamBattle
	scroll.position.y = 710 if campaign and fighting else 132
	scroll.size.y = 150 if campaign and fighting else 732
	scroll.visible = not (campaign and battle is TeamBattle)
	scroll.set_deferred("scroll_vertical", previous_scroll)
	for i in range(tabs.size()):
		tabs[i].visible = true
		tabs[i].position.y = 876
		var section := -1
		if tab == 22: section = 22
		elif tab == 1 and character_page == 1: section = 1
		elif tab in [2,17,18,19]: section = 2
		elif tab in [20,11]: section = 20
		elif tab in [3,4,5,8,10,13,15,16,21]: section = 4
		tabs[i].modulate = Color("ffe3a1") if NAV_PAGES[i] == section else Color("b8c2d8")
	if tab in [23, 24]:
		for capsule in journey_wallet_frames:
			capsule.show()
			capsule.add_theme_stylebox_override("panel", UIDesignV2.panel())
	for navigation in tabs:
		for state in ["normal","pressed","focus"]:
			navigation.add_theme_stylebox_override(state,StyleBoxEmpty.new())
		var glow := StyleBoxFlat.new()
		glow.bg_color = Color("d6ad5a18")
		glow.set_corner_radius_all(6)
		navigation.add_theme_stylebox_override("hover",glow)
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
		13: _spirit_tree_panel()
		15: _map_panel()
		16: _journal_panel()
		17: _equipment_detail_panel()
		18: _spirit_inventory_detail()
		19: _forge_panel()
		20: _shop_panel()
		21: _dungeons_panel()
		22: _formation_panel()
		23: _gallery_panel()
		24:
			var home := HomeScreen.new()
			home.game = self
			panel.add_child(home)
		_: _expansion_panel(tab)

func _style_currency_shell() -> void:
	for capsule in journey_wallet_frames:
		capsule.visible = true
		capsule.add_theme_stylebox_override("panel",UIDesignV2.panel())

func _text(text: String, font_size: int = 15, color: Color = Color("c0d0cb")) -> void:
	var label := _label(panel, text, Vector2.ZERO, font_size, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = 460

func _row(text: String, callback: Callable, disabled: bool = false) -> Button:
	var b := _button(panel, text, Vector2.ZERO, Vector2(464, 44), callback)
	icons.action(b, callback)
	b.disabled = disabled
	return b

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
		_text("%s · Level %d   /   %s accompanying" % [catalog.find_row("heroes", p.hero).name, p.heroes[p.hero].level, catalog.find_row("assists", p.assist).name], 17, Color("e5cd9e"))
	if _locked() and battle != null and battle.state == "battle":
		_row("Retreat · No rewards", _confirm_abandon)
	else:
		_row("ENTER STAGE · " + catalog.find_row("stages", selected_stage).name, _enter_stage.bind(selected_stage), _locked())
	var supplies := store.offline_preview(int(Time.get_unix_time_from_system()))
	var shortcuts := HBoxContainer.new()
	shortcuts.add_theme_constant_override("separation", 6)
	panel.add_child(shortcuts)
	for entry in [["Map", _select_tab.bind(15), "journey"], ["Summon", _select_tab.bind(11), "spirit"], ["Supplies +%d" % supplies, _offline, "gold"]]:
		var button := _button(shortcuts, entry[0], Vector2.ZERO, Vector2(156, 50), entry[1])
		icons.apply(button, entry[2], 23)
		button.add_theme_font_size_override("font_size", 13)
		if entry[2] == "gold": button.disabled = supplies <= 0 or store.read_only

func _choose_stage(id: int) -> void:
	selected_stage = id
	battle = null
	view.battle = null
	_refresh_panel()

func _confirm_caelan() -> void:
	_dialog(tr("Recruit Caelan?"),tr("Forest Entrance cleared. Welcome the Dawn Vanguard to your collection for free."),[{"text":tr("Recruit"),"call":_recruit_caelan},{"text":tr("Cancel"),"call":_close_modal}])


func _recruit_caelan() -> void:
	_close_modal()
	if not Recruitment.recruit_caelan(store):
		_outcome(false, "")
		return
	_refresh_panel()
	audio.play("rarity_reveal")
	SummonReveal.show_batch(self,[{"kind":"hero","id":"caelan","rarity":5,"duplicate":false}])


func _gallery_panel() -> void:
	var gallery := HeroGallery.new()
	gallery.game = self
	panel.add_child(gallery)

func _open_gallery_hero(id: String) -> void:
	character_inspected = id
	character_page = 0
	_select_tab(1)

func _heroes_panel() -> void:
	if character_inspected == "" or catalog.find_row("heroes", character_inspected).is_empty():
		character_inspected = store.profile.hero
	var screen := CharacterScreen.new()
	screen.game = self
	screen.hero = character_inspected
	screen.section = character_page
	panel.add_child(screen)

func _equipment_detail_panel() -> void:
	var item := EquipmentSystem.item_for(store.profile, selected_item)
	if item.is_empty():
		_row("← Equipment Bag", _bag_open.bind("equipment"))
		_text("This equipment is no longer in your bag.")
		return
	var screen := EquipmentDetailScreen.new()
	screen.game = self
	screen.item = item
	screen.definition = catalog.find_row("items", item.base)
	panel.add_child(screen)

func _quests_panel() -> void:
	var screen := MissionScreen.new()
	screen.game = self
	panel.add_child(screen)

func _mission_tab(index: int) -> void:
	mission_tab = clampi(index, 0, 2)
	scroll.scroll_vertical = 0
	_refresh_panel()

func _mission_claim(period: String, id: String) -> void:
	_outcome(MissionBoard.claim(store, period, id), "Resources and VIP EXP claimed.", "quest_claim")

func _mission_chest(period: String, threshold: int) -> void:
	var section: Dictionary = MissionBoard.state(store.profile)[period]
	var reward := MissionBoard.chest_reward(period, threshold)
	var can_claim: bool = threshold not in section.chests and MissionBoard.points(section, period) >= threshold and not _locked()
	var column := _dialog("%d-POINT CHEST" % threshold, "%d Gold · %d Crystals · %d VIP EXP\n\n%s" % [reward.gold, reward.shards, reward.vip, "Claimed" if threshold in section.chests else ("Reward ready to claim" if can_claim else "Not enough Activity Points")], [{"text":"Close", "call":_close_modal}])
	var button := _button(column, "Claim Chest", Vector2.ZERO, Vector2(400, 46), _mission_claim_chest.bind(period, threshold))
	button.disabled = not can_claim
	column.move_child(button, column.get_child_count() - 2)

func _mission_claim_chest(period: String, threshold: int) -> void:
	_close_modal()
	_outcome(MissionBoard.claim(store, period, "", threshold), "Activity chest claimed.", "quest_claim")

func _mission_go(id: String) -> void:
	match id:
		"offline": _offline()
		"enhance": _select_tab(2)
		"summon": _select_tab(11)
		_: _select_tab(0)

func _journal_panel() -> void:
	_row("BOSS GUIDE →", _select_tab.bind(10))
	_text("JOURNEY JOURNAL", 17, Color("e5cd9e"))
	for stage in catalog.data.stages:
		for part in ["before", "after"]:
			var key := "%d_%s" % [stage.id, part]
			if key in store.profile.seen_story:
				_art_card(stage.name + (" · Beginning" if part == "before" else " · Ending"), stage[part], "bg_" + stage.zone, _replay_story.bind(stage[part]))
	_text("The world, characters, and dialogue here are original. Research into Eternal Senia 2 informs data organization; this is not a restoration of its original algorithms.")

func _notify(text: String) -> void:
	message = text
	message_time = 7

func _outcome(success: bool, text: String, cue: String = "confirm") -> void:
	if success:
		audio.play(cue)
	_notify(text if success else (store.error if not store.error.is_empty() else "Requirements not met or the battle has not ended."))
	_refresh_panel()

func _hero(id: String) -> void:
	if store.change_hero(id):
		character_inspected = id
		battle = null
		view.battle = null
		_outcome(true, "Hero switched.")
	else:
		_outcome(false, "")

func _assist(id: String) -> void:
	_outcome(store.change_assist(id), "Companion switched.", "spirit_select")

func _upgrade(kind: String, index: int) -> void:
	_outcome(store.upgrade(kind, index), "Upgraded. New stats apply from the next battle.", "upgrade")

func _item_detail(uid: String) -> void:
	equipment_target = store.profile.hero
	selected_item = uid
	_select_tab(17)

func _character_item_detail(uid: String, hero: String) -> void:
	selected_item = uid
	equipment_target = hero
	_select_tab(17)

func _equip(uid: String) -> void:
	_outcome(store.equip(uid), "Equipped.", "equip")

func _unequip(uid: String) -> void:
	_outcome(store.unequip(uid), "Equipment returned to your bag.", "equip")

func _enhance(uid: String, rank_up: bool) -> void:
	_outcome(store.enhance(uid, rank_up), "Equipment upgraded.", "forge")

func _forge(id: String) -> void:
	_outcome(store.forge(id), "Crafted a new equipment copy.", "forge")

func _dismantle_confirm(uid: String) -> void:
	_dialog("Dismantle equipment?", "Unequipped items will become Crystals. This cannot be undone.", [{"text": "Dismantle", "call": _dismantle.bind(uid)}, {"text": "Keep", "call": _close_modal}])

func _dismantle(uid: String) -> void:
	_close_modal()
	var success := store.dismantle(uid)
	if success:
		selected_item = ""
		bag_section = "equipment"
		tab = 2
	_outcome(success, "Equipment dismantled.", "dismantle")

func _quest(id: String) -> void:
	_outcome(store.claim_quest(id), "Mission rewards claimed.", "quest_claim")

func _offline() -> void:
	_outcome(store.claim_offline(int(Time.get_unix_time_from_system())), "Supplies claimed. Rewards use device time, up to 2 hours.", "reward")

func _enter_stage(id: int) -> void:
	if _locked() or not store.can_enter(id):
		return
	selected_stage = id
	var stage := catalog.find_row("stages", id)
	_dialog(stage.name, stage.before + "\n\nBring up to 4 heroes and 1 spirit. AI moves freely in the arena: melee heroes approach, ranged heroes keep distance, and enemies attack nearby heroes. Auto Ultimate is optional. Defeat occurs when the team falls or 180 seconds elapse."+Supplies.hint(store.profile), [{"text": "Enter Battle", "call": _begin}, {"text":"Formation", "call":_open_formation}, {"text": "Keep Preparing", "call": _close_modal}])

func _begin() -> void:
	_close_modal()
	store.mark_story("%d_before" % selected_stage)
	var team_options := next_team_options.duplicate()
	next_team_options = {}
	if not store.begin_run(selected_stage, team_options):
		_outcome(false, "")
		return
	_select_tab(0)
	_resume()

func _resume() -> void:
	_close_modal()
	if store.profile.pending.has("team"):
		battle = ArenaBattle.new(catalog) if store.profile.pending.team.version == 3 else TeamBattle.new(catalog)
	else:
		battle = Battle.new(catalog)
	battle.start(store.profile.pending)
	battle.speed = mini(2, store.profile.settings.speed) if battle is TeamBattle else store.profile.settings.speed
	selected_stage = int(battle.run.stage)
	view.battle = null if battle is TeamBattle else battle
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
	var queued_before: int = store.profile.bag_rewards.size()
	var fragments_before: Dictionary = store.profile.collection_fragments.items.duplicate()
	var supply_before: Dictionary = store.profile.supplies.counts.duplicate(true)
	var caelan_fragments_before: int = Recruitment.state(store.profile).fragments.caelan
	var old_uids: Array = []
	for item in store.profile.items:
		old_uids.append(item.uid)
	if not store.settle(battle.run.id, won, battle.kills, battle.time):
		_dialog("Unable to save results", store.error + "\nYour battle is preserved. Try saving again; rewards cannot be claimed twice.", [{"text": "Retry Save", "call": _retry_settle}])
		return
	if won:
		var stage: Dictionary = battle.stage
		var loot := "Equipment saved in Unclaimed Loot." if store.profile.bag_rewards.size() > queued_before else ""
		for id in store.profile.collection_fragments.items:
			var amount: int = store.profile.collection_fragments.items[id] - fragments_before[id]
			if amount > 0: loot = "Duplicate equipment: +%d %s Fragments" % [amount, catalog.find_row("items", id).name]
		for item in store.profile.items:
			if item.uid not in old_uids:
				loot = "Equipment received: " + catalog.find_row("items", item.base).name
		for id in Supplies.ORDER:
			var gained: int = store.profile.supplies.counts[id]-supply_before[id]
			if gained>0: loot += "\n+%d × %s" % [gained,Supplies.NAMES[id]]
		var caelan_gained: int = Recruitment.state(store.profile).fragments.caelan-caelan_fragments_before
		if caelan_gained > 0: loot += "\n" + tr("+%d Caelan Fragments") % caelan_gained
		_queue_result("VICTORY", "%s\n\n+%d Gold · +%d XP · +%d Crystals\n%s" % [(stage.after + ("\n+%d Spirit Cores · Best score %d" % [stage.cores, store.profile.expansion.records[str(stage.id)].score] if stage.get("kind") == "challenge" else "")), store.profile.gold - gold_before, stage.xp, store.profile.shards - shards_before, loot], [{"text": "Back to Journey", "call": _return_to_camp}, {"text": "Retry", "call": _replay}])
	else:
		_queue_result("THE LIGHT ENDURES", (battle.defeat_reason + "\nTry changing formation, upgrading heroes or equipment, or adjusting Ultimates." if battle is TeamBattle else "No rewards claimed. Upgrade your weapon, switch companions, or time your Guard."), [{"text": "Prepare Again", "call": _return_to_camp}, {"text": "Try Again", "call": _replay}])
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
	if battle is TeamBattle and battle.state == "won":
		var next_stage := _next_team_stage()
		if next_stage > 0:
			var next_definition := catalog.find_row("stages", next_stage)
			if battle.auto_next and not Formation.encounter(next_definition).important:
				next_team_options = {"auto_ult":battle.auto_ultimate, "auto_next":battle.auto_next}
				_return_to_camp()
				selected_stage = next_stage
				_begin()
				return
			if battle.auto_next and Formation.encounter(next_definition).important:
				payload.body += "\n\nStop before the chapter boss to prepare your team."
			payload.actions.insert(0, {"text":"Prepare next stage →", "call":_prepare_team_next.bind(next_stage)})
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
	_dialog("Retreat?", "No rewards for this battle. Saved progress is preserved.", [{"text": "Retreat", "call": _abandon}, {"text": "Resume Battle", "call": _cancel_abandon}])

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
	var next: int = (battle.speed % 2 + 1) if battle is TeamBattle else int(store.profile.settings.speed) % 3 + 1
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
	_dialog("Journal", text, [{"text": "Close", "call": _close_modal}])

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
	medal.texture = frames.textures["icon_victory" if title == "VICTORY" else "icon_cores"]
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
	if modal is SettingsScreen:
		modal.finish()
		return
	if is_instance_valid(modal):
		ui.remove_child(modal)
		modal.queue_free()
	modal = null

func _on_button(action: Callable) -> void:
	var method := action.get_method()
	if method in ["_select_tab", "_bag_open", "_mission_tab", "_forge_tab", "_character_section", "_shop_section", "_select_summon_kind", "_dungeon_filter", "_dungeon_show", "_dungeon_difficulty", "_supply_open", "_supply_filter", "_supply_hero"]:
		audio.play("menu_open")
	elif method in ["_close_modal", "_cancel_audio_settings", "_dungeon_back"]:
		audio.play("menu_back")
	elif method not in ["_attack", "_skill", "_guard"]:
		audio.play("ui_click")
	action.call()

func _sync_audio() -> void:
	if not audio_menu_open:
		audio.apply_profile(store.profile)
	var zone: String = catalog.find_row("stages", selected_stage).zone
	audio.context(zone, battle != null and battle.paused, tab == 0, tab == 0 and battle != null and battle.state == "battle")

func _apply_presentation(values: Dictionary = {}) -> void:
	presentation_options = GameOptions.state(store.profile) if values.is_empty() else values.duplicate(true)
	Engine.max_fps = 30 if presentation_options.battery_saver else presentation_options.fps_limit
	view.options = presentation_options
	view.effects.show_numbers = presentation_options.damage_numbers
	view.effects.reduced = presentation_options.reduced_effects or presentation_options.quality == "low" or presentation_options.battery_saver
	view.effects.lighting = presentation_options.lighting

func _play_events() -> void:
	audio.consume(battle)

func _audio_settings() -> void:
	if modal != null or result_transition: return
	SettingsScreen.open(self,"audio",false)

func _audition() -> void:
	audio.audition()

func _apply_audio_settings() -> void:
	if modal is SettingsScreen: modal.save()

func _cancel_audio_settings() -> void:
	_close_modal()

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
	_row("← Back to " + ("hero" if page in [6, 7] else "journey"), _select_tab.bind(1 if page in [6, 7] else 0))
	var p: Dictionary = store.profile
	match page:
		5:
			_text("CHALLENGES", 21, Color("e5cd9e"))
			_text("Hunt bosses for Spirit Cores to evolve companions. Score = enemies defeated × 100 + up to 300 speed points. No tickets spent; defeat grants no rewards.")
			for stage in catalog.data.stages:
				if stage.get("kind") != "challenge": continue
				var record: Dictionary = p.expansion.records.get(str(stage.id), {})
				_text(stage.name + " · %d waves · +%d Cores" % [stage.waves.size(), stage.cores], 18, Color("e5cd9e"))
				_text("%d Gold · %d XP · 2 Crystals + loot" % [stage.gold, stage.xp])
				if not record.is_empty(): _text("Best: %d points · Fastest %.1f simulated seconds" % [record.score, record.time])
				_stage_entry(stage)
			_text("STORY CHAPTERS", 21, Color("e5cd9e"))
			_text("Each chapter has one main stage and two sequential memory stages. New branches have their own first-clear rewards, loot, and dialogue.")
			for chapter in catalog.data.chapters:
				_text("%d · %s" % [chapter.id, chapter.name], 18, Color("e5cd9e"))
				_stage_entry(catalog.find_row("stages", chapter.id))
				for id in [6 + (chapter.id - 1) * 2, 7 + (chapter.id - 1) * 2]: _stage_entry(catalog.find_row("stages", id))
		8:
			_text("COLLECTION & ACHIEVEMENTS", 21, Color("e5cd9e"))
			_text("Discovered weapons and armor remain recorded after dismantling. Achievements can be claimed once and are saved with your resources.")
			for achievement in catalog.data.achievements:
				var count := Expansion.metric(p, achievement.metric)
				_text("%s · %d/%d" % [achievement.name, mini(count, achievement.target), achievement.target], 18, Color("e5cd9e"))
				_row("Claimed" if achievement.id in p.expansion.claimed else "Claim %d Gold + %d Crystals + %d Cores" % [achievement.gold, achievement.shards, achievement.cores], _achievement.bind(achievement.id), store.read_only or achievement.id in p.expansion.claimed or count < achievement.target)
			_text("EQUIPMENT DISCOVERED · %d/%d" % [p.expansion.discovered.size(), catalog.data.items.size()], 18, Color("e5cd9e"))
			for item in catalog.data.items:
				_text(("✓ " if item.id in p.expansion.discovered else "○ Undiscovered · ") + item.name + " · " + item.passive)
			_text("BOSS DEFEATED", 18, Color("e5cd9e"))
			for stage in catalog.data.stages:
				if stage.id <= 5: _text(("✓ " if stage.id in p.cleared else "○ ") + stage.boss)
			_text("COMPANION", 18, Color("e5cd9e"))
			for assist in catalog.data.assists:
				_text("%s · %s · Rank %d" % [assist.name, "Unlocked" if store.available_assist(assist.id) else "Locked", p.expansion.ranks[assist.id]])

func _stage_entry(stage: Dictionary) -> void:
	var available := store.can_enter(stage.id)
	var requirement := ""
	if not available:
		var id: int = stage.requires[0] if stage.has("requires") else stage.id - 1
		requirement = " · Clear " + catalog.find_row("stages", id).name
	if not requirement.is_empty(): _text(requirement.trim_prefix(" · "), 14)
	_art_card(stage.name, "%d Gold · %d XP" % [stage.gold, stage.xp], "bg_" + stage.zone, _enter_stage.bind(stage.id), _locked() or not available, stage.id in store.profile.cleared)

func _talent(id: String) -> void:
	_outcome(Expansion.talent(store, id), "Skill branch updated.", "upgrade")

func _rank_assist() -> void:
	_outcome(Expansion.rank_up(store), "Companion evolved!", "upgrade")

func _achievement(id: String) -> void:
	_outcome(Expansion.claim(store, id), "Achievement claimed.", "reward")

func _training_panel() -> void:
	_row("← Back to Heroes", _select_tab.bind(1))
	var p: Dictionary = store.profile
	var points := AttributeTraining.allocation(p, p.hero)
	var remaining := AttributeTraining.remaining(p, p.hero)
	var stats := catalog.stats(p)
	_text("ATTRIBUTE POINTS · " + catalog.find_row("heroes", p.hero).name, 21, Color("e5cd9e"))
	_text("Each level after LV 1 grants 2 points for this hero. %d points available. Add, remove, or refund points for free outside battle." % remaining)
	_text("HP %.0f · ATK %.1f · DEF %.2f" % [stats.hp, stats.atk, stats.defense], 18, Color("e5cd9e"))
	for stat in AttributeTraining.ATTRIBUTES:
		var row: Dictionary = AttributeTraining.ATTRIBUTES[stat]
		_text("%s · %d points · Total +%s" % [row.name, points[stat], str(points[stat] * row.bonus)], 18, Color("e5cd9e"))
		_row("+1 point · +%s %s" % [str(row.bonus), row.name], _train_attribute.bind(stat, 1), _locked() or remaining <= 0)
		_row("−1 point · Refund 1 point", _train_attribute.bind(stat, -1), _locked() or points[stat] <= 0)
	_row("Refund all points · Free", _reset_attributes, _locked() or remaining == (p.heroes[p.hero].level - 1) * 2)
	if not p.pending.is_empty():
		_text("A battle is unfinished: points are locked to the build used at entry.")

func _train_attribute(stat: String, amount: int) -> void:
	_outcome(AttributeTraining.change(store, stat, amount), "Attribute Points updated.", "upgrade")

func _reset_attributes() -> void:
	_outcome(AttributeTraining.reset(store), "Attribute Points refunded.")

func _boss_guide_panel() -> void:
	_row("← Back to Journal", _select_tab.bind(4))
	_text("BOSS GUIDE", 21, Color("e5cd9e"))
	_text("Details unlock when the chapter path opens. These stats belong to the main-stage boss; memories and side stages have their own stats.")
	var elements := {"nature": "Natural", "fire": "Fire", "water": "Water", "light": "Light", "dark": "Dark"}
	var counters := {"nature": "Fire", "fire": "Water", "water": "Natural", "light": "Dark", "dark": "Light"}
	var hints := {
		"smash": "Heavy attacks: Guard just before the warning ring fills to reduce damage by 80%. Save healing skills for low HP.",
		"shield": "Shields: Spirit skills break shields. Attacks without shield penetration deal only 35% damage while a shield is active.",
		"counter": "Counter: stop using damage skills while the boss charges. Basic attacks and Guard help you wait out the danger."
	}
	for stage in catalog.data.stages:
		if stage.id > 5:
			continue
		if not store.can_enter(stage.id):
			_text("Chapter %d · Locked · Clear the previous chapter" % stage.id)
			continue
		_text(stage.boss + (" · Defeated" if stage.id in store.profile.cleared else " · Undefeated"), 19, Color("e5cd9e"))
		_text(stage.name + " · " + elements[stage.element])
		_text("HP %d · ATK %d · %s weapons deal 20%% more damage" % [stage.boss_hp, stage.boss_atk, counters[stage.element]])
		_text(hints[stage.mechanic])
		var drops: Array[String] = []
		for id in stage.drops:
			drops.append(catalog.find_row("items", id).name)
		_text("Possible drops: " + ", ".join(drops), 14)

func _rarity(kind: String, id: String) -> String:
	return Recruitment.label(kind, id, catalog, store.profile)

func _entity_name(kind: String, id: String) -> String:
	return catalog.find_row({"hero": "heroes", "spirit": "assists", "item": "items"}[kind], id).name

func _summon_panel() -> void:
	var screen := SummonScreen.new()
	screen.game = self
	panel.add_child(screen)

func _select_summon_kind(index: int) -> void:
	summon_kind = clampi(index, 0, 2)
	_refresh_panel()

func _summon_confirm(count: int) -> void:
	if summon_kind != 0 or _locked(): return
	_dialog("Summon ×%d?" % count, "Cost: %d Gold.\nEach summon advances its own pity counter. Equipment is kept as individual copies; duplicate heroes and spirits become 10 Fragments. If the bag cannot hold the entire summon batch, no Gold is spent." % (Recruitment.PRICE * count), [{"text": "Summon", "call": _summon_execute.bind(count)}, {"text": "Cancel", "call": _close_modal}])

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
	_summon_sound(Recruitment.state(store.profile).history.slice(0, 10))
	SummonReveal.show_batch(self, Recruitment.state(store.profile).history.slice(0, 10))

func _summon_sound(results: Array) -> void:
	var rare := false
	for result in results:
		var rarity := Recruitment.rarity(result.kind,result.id,catalog)
		if rarity >= (2 if result.kind == "spirit" else 5): rare = true
	# One reveal for the complete committed batch; viewing history is silent.
	audio.play("rarity_reveal" if rare else "summon_reveal")

func _replay_summon() -> void:
	var batch: Dictionary = Recruitment.state(store.profile).get("last_batch", {})
	if not batch.is_empty(): SummonReveal.show_batch(self, batch.entries)

func _summon_history() -> void:
	SummonScreen.show_results(self, "SUMMON HISTORY", Recruitment.state(store.profile).history)

func _summon_rates() -> void:
	var text := "Equipment is kept as individual copies. Duplicate heroes and spirits become 10 matching Fragments.\nStandard: 70% · Advanced: 25% · Premium: 5%. After 19 summons without Premium, summon 20 guarantees that group. Summon groups are independent of rarity.\n"
	for tier in [1, 2, 3]:
		var candidates := Recruitment.pool(catalog, tier)
		var total := 0
		for entry in candidates: total += int(entry.weight)
		text += "\n" + Recruitment.GROUP_NAMES[tier] + ":\n"
		for entry in candidates:
			text += "%s [%s]: %.2f%% within the group\n" % [_entity_name(entry.kind, entry.id), _rarity(entry.kind, entry.id), float(entry.weight) / total * 100]
	SummonScreen.show_text(self, "STANDARD SUMMON RATES", text)

func _summon() -> void:
	if not Recruitment.summon(store):
		_outcome(false, "")
		return
	_refresh_panel()
	var result: Dictionary = store.profile.recruitment.history[0]
	_summon_sound([result])
	SummonReveal.show_batch(self, [result])

func _batch_level() -> void:
	_outcome(Recruitment.level_batch(store), "Hero leveled up.", "upgrade")

func _awaken() -> void:
	_outcome(Recruitment.awaken(store), "Hero awakened.", "upgrade")

func _spirit_tree_panel() -> void:
	_row("← Back to Heroes", _select_tab.bind(1))
	var p: Dictionary = store.profile
	var b: Dictionary = SpiritSkills.builds(p)[p.assist]
	_text("SPIRIT TREE · " + catalog.find_row("assists", p.assist).name, 22, Color("a2e5d6"))
	_text("Companion level %d/20 · Active skill level %d/10" % [p.assists[p.assist], b.level])
	_text("Active skill levels and branches are saved per spirit. Switching heroes does not change this tree. Switch learned branches for free; choose one branch per tier.")
	_text("◆ ROOT · Shield-breaking Spirit · Level %d/10" % b.level, 18, Color("e5cd9e"))
	_row("Upgrade spirit skill · %d Gold" % (b.level * 25), _upgrade.bind("skill", 2), _locked() or b.level >= 10 or p.gold < b.level * 25)
	_text("│\n├─ TIER 1 · Companion level 4", 17, Color("a2e5d6"))
	for id in ["nova", "flow"]:
		var row := catalog.find_row("talents", id)
		_text(row.name + " · " + row.description)
		_row(("✓ Deselect · " if b.selected == id else ("Select · " if id in b.learned else "Learn · ")) + row.name + ("" if id in b.learned else " · 80 Gold + 3 Crystals"), _spirit_talent.bind(id), _locked() or p.assists[p.assist] < 4 or (id not in b.learned and (p.gold < 80 or p.shards < 3)))
	_text("│\n└─ TIER 2 · Companion level 6 + one tier 1 branch", 17, Color("a2e5d6"))
	for id in SpiritSkills.ADVANCED:
		var row: Dictionary = SpiritSkills.ADVANCED[id]
		_text(row.name + " · " + row.description)
		_row(("✓ Deselect · " if b.advanced == id else ("Select · " if id in b.advanced_learned else "Learn · ")) + row.name + ("" if id in b.advanced_learned else " · 100 Gold + 3 Crystals"), _spirit_talent.bind(id), _locked() or p.assists[p.assist] < 6 or b.selected == "" or (id not in b.advanced_learned and (p.gold < 100 or p.shards < 3)))

func _spirit_talent(id: String) -> void:
	_outcome(SpiritSkills.choose(store, id), "Spirit skill tree updated.", "upgrade")

func _map_panel() -> void:
	_row("← Back to Battle", _select_tab.bind(0))
	_text("JOURNEY MAP", 23, Color("e5cd9e"))
	for stage in catalog.data.stages:
		if stage.id > 5: continue
		_art_card(stage.name, "%d Gold · %d XP" % [stage.gold, stage.xp], "bg_" + stage.zone, _map_stage.bind(stage.id), _locked() or not store.can_enter(stage.id), stage.id == selected_stage)
	_row("Story & Side Stages →", _select_tab.bind(5))

func _map_stage(id: int) -> void:
	_choose_stage(id)
	_select_tab(0)

func _more_panel() -> void:
	var screen := UtilitiesScreen.new()
	screen.game = self
	panel.add_child(screen)

func _utility_mail() -> void:
	_dialog("MAILBOX", "Your mailbox is empty.\n\nSystem gifts, notices, and compensation will appear here when the mailbox service becomes available.", [{"text": "Close", "call": _close_modal}])

func _utility_giftcode() -> void:
	var column := _dialog("REDEEM GIFT CODE", "Enter a local gift code. The admin code unlocks all implemented content and maximizes progression. Development previews and unavailable services stay locked.", [{"text": "Close", "call": _close_modal}])
	var input := LineEdit.new()
	input.name = "GiftCodeInput"
	input.placeholder_text = "Enter gift code"
	input.max_length = 64
	input.editable = not _locked()
	input.custom_minimum_size.y = 46
	column.add_child(input)
	column.move_child(input, 2)
	var redeem := _button(column, "Redeem", Vector2.ZERO, Vector2(400, 46), func(): _giftcode_confirm(input.text))
	redeem.name = "RedeemGiftCode"
	redeem.disabled = _locked()
	column.move_child(redeem, 3)
	input.text_submitted.connect(_giftcode_confirm)
	if input.editable: input.grab_focus.call_deferred()

func _giftcode_confirm(code: String) -> void:
	if result_transition: return
	if not AdminUnlock.eligible(store,code):
		_notify(store.error)
		return
	_dialog("Unlock all implemented content?", "ADMIN: all playable heroes, spirits and stages; maximum hero/spirit progression and learned skills; every equipment type; at least 1,000,000 Gold, Crystals and XP; 10,000 of each supply and Cores. Existing equipment is upgraded; overflow goes to Unclaimed Loot. Current formation, outfits and history stay intact. One use per save.", [{"text":"Unlock all","call":_redeem_gift_code.bind(code)},{"text":"Cancel","call":_utility_giftcode}])

func _redeem_gift_code(code: String) -> void:
	if result_transition: return
	if AdminUnlock.redeem(store,code):
		_close_modal()
		_refresh_panel()
		_notify("Admin unlock saved. All implemented content is available. Check Bag and Unclaimed Loot for equipment.")
	else:
		_notify(store.error)

func _utility_settings() -> void:
	SettingsScreen.open(self,"home",true)

func _utility_help() -> void:
	SummonScreen.show_text(self, "HELP & SUPPORT", "HOW TO PLAY\nChoose heroes and equipment before entering a stage. Heroes attack automatically. Use hero and spirit Ultimates, choose a target, and adjust battle speed.\n\nUpgrade heroes in Heroes; manage equipment and materials in Bag. Check summon rates before summoning.\n\nREPORT A BUG\nInclude your game version, device, steps to reproduce, and a screenshot or video. Back up your save before reinstalling.\n\nVersion: " + str(ProjectSettings.get_setting("application/config/version", "")) + "\n\nStudio: ZORVYKA Games\nSupport: zorvykagames@gmail.com\nYou choose whether to send an email; the game never sends your data automatically.")

func _bag_open(section: String) -> void:
	bag_section = section
	_select_tab(2)

func _bag_type_count() -> int:
	var types := {}
	for item in store.profile.items: types[item.base] = true
	return types.size()

func _bag_help() -> void:
	SummonScreen.show_text(self,"BAG GUIDE","Equipment can have multiple copies with the same name. Each has its own UID, enhancement, and rank. The bag holds 40 items.\n\nE: equipped by a hero. Choose Dismantle to select multiple copies; equipped items are protected.\n\nFusion: keep one copy and consume two +0 copies of the same item and rank to gain one rank, up to rank 3.\n\nDuplicate heroes and spirits still become 10 matching Fragments. Legacy Equipment Fragments are preserved. Drops from a full bag go to Unclaimed Loot.")

func _bag_sort_next() -> void:
	bag_sort = (bag_sort+1)%3
	_refresh_panel()

func _bag_select_mode() -> void:
	bag_selecting = not bag_selecting
	bag_selected.clear()
	_refresh_panel()

func _bag_toggle_uid(uid: String) -> void:
	if _locked(): return
	for hero in store.profile.heroes.values():
		if uid in hero.equipment.values(): return
	if uid in bag_selected: bag_selected.erase(uid)
	else: bag_selected.append(uid)
	_refresh_panel()

func _bag_dismantle_confirm() -> void:
	if _locked() or bag_selected.is_empty(): return
	var lines: Array[String] = []
	var amount := 0
	for uid in bag_selected:
		var item := EquipmentSystem.item_for(store.profile,uid)
		if item.is_empty(): return
		amount += 1+int(item.rank)
		lines.append("%s +%d · Rank %d · %s" % [catalog.find_row("items",item.base).name,item.enhance,item.rank,uid])
	_dialog("Dismantle %d equipment items?" % bag_selected.size(),"Receive %d Crystals. Selected copies and all their upgrades will be consumed.\n\n" % amount+"\n".join(lines),[{"text":"Dismantle","call":_bag_dismantle_execute.bind(bag_selected.duplicate())},{"text":"Cancel","call":_close_modal}])

func _bag_dismantle_execute(uids: Array) -> void:
	_close_modal()
	var ok := store.dismantle_many(uids)
	if ok:
		bag_selected.clear()
		bag_selecting = false
	_outcome(ok,"Selected copies dismantled.","dismantle")

func _bag_claim_loot() -> void:
	_outcome(store.claim_bag_rewards(),"Loot moved into free bag slots.","reward")

func _bag_spirit_select(id: String) -> void:
	selected_spirit = id
	_refresh_panel()

func _bag_upgrade_spirit(id: String) -> void:
	_outcome(store.upgrade_assist(id),"Upgraded "+catalog.find_row("assists",id).name,"upgrade")

func _bag_material_detail(key: String) -> void:
	var title := "MATERIALS"
	var lines: Array[String] = []
	match key:
		"gold": lines.append("Gold: %d\nUsed to upgrade, craft, and summon." % store.profile.gold)
		"shards": lines.append("Crystals: %d\nUsed to enhance, rank up, craft, and learn skills." % store.profile.shards)
		"xp": lines.append("XP: %d\nUsed with Gold to level up heroes." % store.profile.xp)
		"cores": lines.append("Spirit Cores: %d\nUsed to evolve heroes and spirits." % store.profile.expansion.cores)
		"fragments":
			for row in catalog.data.heroes: lines.append("%s Fragments: %d" % [row.name,Recruitment.state(store.profile).fragments[row.id]])
		"spirit":
			for row in catalog.data.assists: lines.append("%s Fragments: %d" % [row.name,store.profile.collection_fragments.spirits[row.id]])
		"weapon_category":
			for row in catalog.data.items: lines.append("%s Fragments: %d" % [row.name,store.profile.collection_fragments.items[row.id]])
	SummonScreen.show_text(self,title,"\n\n".join(lines))

func _forge_tab(index: int) -> void:
	forge_page = index
	_refresh_panel()

func _forge_batch_confirm(id: String) -> void:
	if _locked(): return
	var count := forge_count
	_dialog("Craft %d × %s?" % [count,catalog.find_row("items",id).name],"Requires %d Gold + %d Crystals and %d bag slots. Each copy has independent upgrades." % [65*count,3*count,count],[{"text":"Craft","call":_forge_batch_execute.bind(id,count)},{"text":"Cancel","call":_close_modal}])

func _forge_batch_execute(id: String, count: int) -> void:
	_close_modal()
	_outcome(store.forge(id,count),"Crafted %d equipment copies." % count,"forge")

func _forge_fuse_confirm(uid: String) -> void:
	if _locked(): return
	var donors := store.fusion_donors(uid)
	var item := EquipmentSystem.item_for(store.profile,uid)
	if donors.size() != 2 or item.is_empty(): return
	_dialog("Fuse "+catalog.find_row("items",item.base).name+"?","Keep %s +%d and increase rank %d → %d.\nConsume two +0 copies: %s. Consumed copies cannot be recovered." % [uid,item.enhance,item.rank,item.rank+1,", ".join(donors)],[{"text":"Fuse","call":_forge_fuse_execute.bind(uid,donors)},{"text":"Cancel","call":_close_modal}])

func _forge_fuse_execute(uid: String, donors: Array) -> void:
	_close_modal()
	_outcome(store.fuse(uid,donors),"Fusion complete. The main copy's enhancement is preserved.","equipment_fuse")


func _supply_open(id: String = "") -> void:
	if id!="" and id not in Supplies.ORDER: return
	supply_selected = id
	_bag_open("supplies")

func _supply_filter(group: String) -> void:
	if group not in ["all","consumable","upgrade","spirit","ticket"]: return
	supply_group = group
	supply_selected = ""
	_refresh_panel()

func _supply_hero(id: String) -> void:
	if not store.available_hero(id): return
	supply_hero = id
	_refresh_panel()

func _supply_source(id: String) -> void:
	_select_tab(21)
	_dungeon_show(id)

func _supply_milestones() -> void:
	var column := _dialog("PROGRESS GIFTS","Claim each milestone once. Players who cleared stages in earlier versions remain eligible.",[{"text":"Close","call":_close_modal}])
	var names := {"story_1":"Material Choice Chest ×1","story_2":"Standard Ticket ×1","story_3":"AFK Hourglass ×1"}
	for id in Supplies.MILESTONES:
		var row: Dictionary = Supplies.MILESTONES[id]
		var claimed: bool = id in store.profile.supplies.claimed
		var action := _button(column,("Claimed · " if claimed else "Clear stage %d · " % row.stage)+names[id],Vector2.ZERO,Vector2(400,44),_supply_confirm.bind("claim",id,0))
		action.add_theme_font_size_override("font_size",14)
		action.disabled = Supplies.busy(store) or claimed or row.stage not in store.profile.cleared
		column.move_child(action,column.get_child_count()-2)

func _supply_confirm(kind: String, id: String = "", value: int = 0) -> void:
	if Supplies.busy(store): return
	var text := ""
	match kind:
		"buy":
			if id not in Supplies.SHOP: return
			text = "Buy 1 "+Supplies.NAMES[id]+" for %d Gold." % Supplies.SHOP[id]
		"claim":
			if id not in Supplies.MILESTONES: return
			text = "Receive 1 "+Supplies.NAMES[Supplies.MILESTONES[id].item]+". This milestone can only be claimed once."
		"chest":
			if id not in Supplies.CHEST: return
			text = "Use 1 chest to receive %d × %s. You choose the reward; it is not random." % [Supplies.CHEST[id],Supplies.NAMES[id]]
		"stone":
			var item := EquipmentSystem.item_for(store.profile,id)
			if item.is_empty(): return
			text = "%s +%d → +%d\nRequires %d Gold + 1 Radiant Forge Stone. No Crystals consumed.\nKeep: %s." % [catalog.find_row("items",item.base).name,item.enhance,item.enhance+1,(item.enhance+1)*20,id]
		"train":
			if value not in [0,1] or not store.available_hero(id): return
			var level: int = store.profile.heroes[id].skills[value]
			text = "%s · Skill %d\nLV %d → LV %d. Requires %d Memory Shards. No Gold consumed." % [catalog.find_row("heroes",id).name,value+1,level,level+1,level]
		"seed": text = "Use 3 Ancient Tree Seeds to receive 1 Spirit Core."
		"hourglass": text = "Use 1 AFK Hourglass to receive %d Gold (2 hours). Preserves accumulated AFK time." % store.offline_amount(7200)
		"ticket":
			if value not in [1,10]: return
			text = "Spend %d Standard Summon Tickets for %d summons from the existing pool. No Gold spent. A full bag or failed save will not consume tickets." % [value,value]
		"select":
			if id not in [""]+Supplies.SUPPORT: return
			text = "Clear the prepared item without consuming the potion." if id=="" else "Prepare 1 "+Supplies.NAMES[id]+". Selecting does not consume it. Consumed when the run begins, even on defeat. Never used automatically in the next run."
		_: return
	_dialog("CONFIRM ITEM",text,[{"text":"Confirm","call":_supply_execute.bind(kind,id,value)},{"text":"Cancel","call":_close_modal}])

func _supply_execute(kind: String, id: String = "", value: int = 0) -> void:
	_close_modal()
	var ok := false
	match kind:
		"buy": ok = Supplies.buy(store,id)
		"claim": ok = Supplies.claim(store,id)
		"chest": ok = Supplies.open_chest(store,id)
		"stone": ok = store.enhance(id,false,true)
		"train": ok = Supplies.train(store,id,value)
		"seed": ok = Supplies.refine_seed(store)
		"hourglass": ok = Supplies.hourglass(store)
		"select": ok = Supplies.select_support(store,id)
		"ticket":
			ok = Recruitment.summon(store,value,true)
			if ok:
				_refresh_panel()
				_refresh_hud()
				_summon_sound(Recruitment.state(store.profile).history.slice(0,value))
				SummonReveal.show_batch(self,Recruitment.state(store.profile).history.slice(0,value))
				return
		_: return
	var cue := "forge" if kind=="stone" else ("upgrade" if kind in ["train","seed"] else "reward")
	var result_text := "Item processed."
	if ok:
		match kind:
			"buy": result_text = "Purchased 1 "+Supplies.NAMES[id]+"."
			"claim": result_text = "Received "+Supplies.NAMES[Supplies.MILESTONES[id].item]+"."
			"chest": result_text = "Received %d × %s." % [Supplies.CHEST[id],Supplies.NAMES[id]]
			"stone": result_text = "Enhanced the selected equipment copy."
			"train": result_text = "Upgraded 1 skill level for "+catalog.find_row("heroes",id).name+"."
			"seed": result_text = "Received 1 Spirit Core."
			"hourglass": result_text = "Received %d Gold from the AFK Hourglass." % store.offline_amount(7200)
			"select": result_text = "Prepared item cleared." if id=="" else "Prepared "+Supplies.NAMES[id]+". Potion not consumed yet."
	_outcome(ok,result_text,cue)

func _items_panel() -> void:
	var screen := BagScreen.new()
	screen.game = self
	panel.add_child(screen)

func _equipment_inventory() -> void:
	var p: Dictionary = store.profile
	_text("%d types · %d equipment items" % [_bag_type_count(),p.items.size()], 16, Color("b4c8bf"))
	var filters := HBoxContainer.new()
	panel.add_child(filters)
	for is_rarity in [false, true]:
		var select := OptionButton.new()
		select.custom_minimum_size = Vector2(214, 44)
		var titles: Array = ["All Rarities"] if is_rarity else ["All Equipment", "Weapon", "Armor", "Boots", "Accessory"]
		if is_rarity:
			for tier in Recruitment.RARITIES: titles.append(Recruitment.RARITIES[tier].name)
		for title in titles: select.add_item(title)
		select.selected = ([0] + Recruitment.RARITIES.keys()).find(bag_rarity) if is_rarity else ["all", "weapon", "armor", "boots", "accessory"].find(bag_kind)
		select.item_selected.connect(_bag_filter.bind(is_rarity))
		filters.add_child(select)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 8)
	panel.add_child(grid)
	var sort_button := _button(filters,"↕",Vector2.ZERO,Vector2(48,44),_bag_sort_next)
	sort_button.tooltip_text = ["Sort: Rarity","Sort: Enhancement","Sort: Newest"][bag_sort]
	var items: Array = p.items.duplicate()
	if bag_sort == 2: items.reverse()
	else: items.sort_custom(func(a, b):
		if bag_sort == 1 and a.enhance != b.enhance: return a.enhance > b.enhance
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
		var card := _button(grid, "", Vector2.ZERO, Vector2(158, 202), _bag_toggle_uid.bind(item.uid) if bag_selecting else _item_detail.bind(item.uid))
		card.disabled = bag_selecting and not owner.is_empty()
		card.tooltip_text = def.name + " · " + _rarity("item", item.base) + (" · " + owner if owner != "" else "")
		card.add_theme_stylebox_override("normal", _style(Color("112532"), Color(Recruitment.RARITIES[def.rarity].color).darkened(.4), 12))
		var art := EquipmentArt.add_to(card, self, def.id, def.rarity, 144)
		art.position = Vector2(7, 0)
		var title: Label = _label(card, def.name + " +%d" % item.enhance, Vector2(5, 140), 13, Recruitment.color("item", def.id, catalog))
		title.size = Vector2(148, 40)
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var note: Label = _label(card, owner if owner != "" else _rarity("item", item.base), Vector2(5, 180), 10)
		note.size.x = 148
		note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		note.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var badge := _label(card,("✓" if item.uid in bag_selected else "○") if bag_selecting else ("E" if not owner.is_empty() else "+%d" % item.enhance),Vector2(127,7),14,Color("f4d486"))
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		shown += 1
	if shown == 0: _text("No equipment matches this filter.")
	_text("%d items shown · Tap to inspect or equip" % shown, 13)

func _bag_filter(index: int, is_rarity: bool) -> void:
	if is_rarity: bag_rarity = ([0] + Recruitment.RARITIES.keys())[index]
	else: bag_kind = ["all", "weapon", "armor", "boots", "accessory"][index]
	_refresh_panel()

func _open_spirit(id: String) -> void:
	selected_spirit = id
	_select_tab(18)

func _spirit_inventory_detail() -> void:
	_row("← Spirit Collection", _bag_open.bind("spirits"))
	var p: Dictionary = store.profile
	var spirit := catalog.find_row("assists", selected_spirit)
	_text(spirit.name + " · " + _rarity("spirit", spirit.id), 24, Recruitment.color("spirit", spirit.id, catalog))
	_text("%s Fragments · %d" % [spirit.name, p.collection_fragments.spirits[spirit.id]], 16, Color("a2e5d6"))
	var image := TextureRect.new()
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.texture = frames.textures["companion_" + spirit.id]
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.custom_minimum_size = Vector2(0, 170)
	panel.add_child(image)
	if not store.available_assist(spirit.id):
		_text("Locked · Clear chapter %d or obtain through summons." % (spirit.unlock - 1))
		_row("Go to Summon →", _select_tab.bind(11))
		return
	_text("%s · Level %d/20 · Evolution %d/3" % [spirit.role, p.assists[spirit.id], p.expansion.ranks[spirit.id]])
	_row("✓ Accompanying" if p.assist == spirit.id else "Choose companion", _assist.bind(spirit.id), _locked() or p.assist == spirit.id)
	if p.assist == spirit.id:
		_row("Upgrade · %d Gold" % (p.assists[p.assist] * 35), _upgrade.bind("assist", 0), _locked() or p.assists[p.assist] >= 20 or p.gold < p.assists[p.assist] * 35)
		_row("Spirit skill tree →", _select_tab.bind(13))
		_row("Evolve Spirit →", _select_tab.bind(7))

func _forge_panel() -> void:
	var screen := BagScreen.new()
	screen.game = self
	panel.add_child(screen)

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
	_dialog(offer.name, "Buy for %d Gold?" % offer.gold, [{"text": "Buy", "call": _shop_buy.bind(id)}, {"text": "Cancel", "call": _close_modal}])

func _shop_buy(id: String) -> void:
	_close_modal()
	_outcome(LocalShop.buy(store, id), "Items received from the Gold Shop.", "reward")

func _show_ryn_portrait() -> void:
	var column := _dialog("RYN · Flamefeather Lancer", "Tap or drag and release to preview movement.", [{"text": "Close", "call": _close_modal}])
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
	var screen := DungeonScreen.new()
	screen.game = self
	panel.add_child(screen)

func _dungeon_filter(group: String) -> void:
	if group not in DungeonWorld.GROUPS: return
	dungeon_group = group
	dungeon_selected = ""
	dungeon_list_offset = 0
	scroll.scroll_vertical = 0
	_refresh_panel()

func _dungeon_show(id: String) -> void:
	if DungeonWorld.new().find(id).is_empty(): return
	if not panel.get_children().is_empty() and panel.get_child(0) is DungeonScreen:
		var current: DungeonScreen = panel.get_child(0)
		if is_instance_valid(current.list_scroll): dungeon_list_offset = current.list_scroll.scroll_vertical
	dungeon_selected = id
	dungeon_difficulty = 1
	scroll.scroll_vertical = 0
	_refresh_panel()

func _dungeon_back() -> void:
	dungeon_selected = ""
	scroll.scroll_vertical = 0
	_refresh_panel()

func _dungeon_difficulty(index: int) -> void:
	dungeon_difficulty = clampi(index,0,2)
	var current: ScrollContainer = panel.find_child("DungeonContentScroll",true,false)
	var offset := current.scroll_vertical if current != null else 0
	_refresh_panel()
	current = panel.find_child("DungeonContentScroll",true,false)
	if current != null: current.set_deferred("scroll_vertical",offset)

func _dungeon_enter(id: String) -> void:
	var row := DungeonWorld.new().find(id)
	if row.is_empty() or row.stage == 0 or _locked(): return
	if not store.can_enter(row.stage): return
	_enter_stage(row.stage)

func _dungeon_help() -> void:
	_dialog("DUNGEON WORLD","15 dungeons across Resources, Tactics, Boss Hunt, and Conquest.\n\nThree dungeons are playable with real rewards. Upcoming locations preview scenery, enemies, and mechanics; stats, reward attempts, and sweeps will arrive with their playable stages.\n\nThe Endless Tower is planned for 100 floors, potentially expanding to 500. Rankings require accounts and a server.",[{"text":"Close","call":_close_modal}])

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
	_outcome(success, "Enhanced equipment and leveled up the hero.", "upgrade")

func _character_stars(id: String) -> void:
	_outcome(Recruitment.awaken(store, id), "Hero gained an Awakening Star.", "upgrade")

func _character_evolve(id: String) -> void:
	_outcome(HeroEvolution.evolve(store, id), "Hero evolved.", "upgrade")

func _character_equip(uid: String, id: String) -> void:
	_outcome(store.equip(uid, id), "Equipped to hero.", "equip")

func _character_unequip(uid: String, id: String) -> void:
	_outcome(store.unequip(uid, id), "Equipment unequipped.", "equip")

func _character_skill_level(hero: String, index: int) -> void:
	_outcome(store.upgrade("skill", index, hero), "Hero skill upgraded.", "upgrade")

func _character_talent(hero: String, id: String) -> void:
	_outcome(Expansion.talent(store, id, hero), "Skill tree updated.", "upgrade")

func _preview_character_outfit(id: String) -> void:
	if id not in Wardrobe.LOOKS: return
	character_outfit_preview = id
	_refresh_panel()

func _apply_character_outfit(hero: String, id: String) -> void:
	_outcome(Wardrobe.apply(store, hero, id), "Palette applied.")

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

func _show_player_profile() -> void:
	if battle != null:
		message = "Open your profile after the battle ends."
		message_time = 3
		return
	PlayerProfilePanel.show_profile(self)

func _show_vip(tier: int = 1) -> void:
	PlayerProfilePanel.show_vip(self, tier)

func _journey_afk() -> void:
	var amount := store.offline_preview(int(Time.get_unix_time_from_system()))
	var column := _dialog("AFK SUPPLIES", "Available: %d Gold\nRate: %d Gold/min · Up to 2 hours\n\nProduction scales with unlocked main story chapters. Rewards use accumulated device time." % [amount, store.unlocked_stage() * 2], [{"text":"Close", "call":_close_modal}])
	var button := _button(column, "Claim %d Gold" % amount, Vector2.ZERO, Vector2(400, 46), _journey_claim_afk)
	button.disabled = amount <= 0 or _locked()
	column.move_child(button, column.get_child_count() - 2)

func _journey_claim_afk() -> void:
	_close_modal()
	_offline()

func _journey_auto() -> void:
	if _locked(): return
	_dialog("AUTO BATTLE SELECTED STAGE", "Heroes use basic attacks and skills automatically. Toggle Auto Ultimate and Auto Advance in Formation; stop before chapter bosses. No sweeps or instant rewards.", [{"text":"Formation Settings", "call":_open_formation}, {"text":"Start", "call":_begin}, {"text":"Cancel", "call":_close_modal}])

func _formation_panel() -> void:
	var screen := FormationScreen.new()
	screen.game = self
	screen.slot = formation_slot
	panel.add_child(screen)

func _formation_slot(index: int) -> void:
	formation_slot = index
	_refresh_panel()

func _formation_assign(index: int, id: String) -> void:
	_outcome(Formation.assign(store, index, id), "Formation updated.")

func _formation_option(enabled: bool, key: String) -> void:
	_outcome(Formation.option(store, key, enabled), "Formation options saved.")

func _next_team_stage() -> int:
	if battle == null or battle.stage.get("kind", "") == "challenge": return 0
	var order := []
	for chapter in catalog.data.chapters:
		for row in JourneyScreen.chapter_stages(catalog, catalog.find_row("stages", chapter.id)): order.append(row.id)
	var index: int = order.find(selected_stage)
	for i in range(index + 1, order.size()):
		if order[i] not in store.profile.cleared and store.can_enter(order[i]): return int(order[i])
	return 0

func _prepare_team_next(id: int) -> void:
	_return_to_camp()
	selected_stage = id
	_select_tab(22)

func _open_formation() -> void:
	_close_modal()
	_select_tab(22)

func _formation_spirits() -> void:
	var column := _dialog("SELECT SPIRIT", "Spirits support the whole team without using a hero slot.", [{"text":"Close", "call":_close_modal}])
	for spirit in catalog.data.assists:
		var button := _button(column, ("✓ " if store.profile.assist == spirit.id else "") + spirit.name, Vector2.ZERO, Vector2(400, 46), _formation_choose_spirit.bind(spirit.id))
		icons.apply(button, "spirit", 24)
		button.disabled = _locked() or not store.available_assist(spirit.id)
		column.move_child(button, column.get_child_count() - 2)

func _formation_choose_spirit(id: String) -> void:
	_close_modal()
	_assist(id)

func _character_help() -> void:
	_dialog("HEROES", "Select a portrait on the left to inspect. Progression includes leveling, evolution, and awakening with Fragments. Skills have their own list and talent tree.\n\nEquipment, stats, and upgrade requirements reflect your current profile.", [{"text":"Close","call":_close_modal}])

func _character_skill_view(key: String) -> void:
	if key not in ["overview","tree"]: return
	character_skill_view = key
	_refresh_panel()

func _character_talent_focus(id: String) -> void:
	character_talent_focus = id
	_refresh_panel()

func _character_gear_picker(id: String, slot_name: String) -> void:
	var column := _dialog("SELECT EQUIPMENT", "Choose equipment for " + catalog.find_row("heroes",id).name, [{"text":"Close","call":_close_modal}])
	column.get_child(2).size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	column.get_child(2).add_theme_font_size_override("font_size",14)
	var scroller := SwipeScroll.new()
	scroller.custom_minimum_size = Vector2(400,240)
	scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroller)
	column.move_child(scroller,3)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroller.add_child(list)
	for item in store.profile.items:
		var row := catalog.find_row("items",item.base)
		if row.slot != slot_name or slot_name == "weapon" and row.category != catalog.category(id): continue
		var equipped: bool = store.profile.heroes[id].equipment[slot_name] == item.uid
		var b := _button(list,("✓ " if equipped else "") + row.name + " +%d" % item.enhance,Vector2.ZERO,Vector2(380,44),_character_choose_gear.bind(item.uid,id,false))
		icons.apply(b,item.base,28)
		b.disabled = _locked() or not store.available_hero(id) or equipped
	var uid: String = store.profile.heroes[id].equipment[slot_name]
	if not uid.is_empty():
		var remove := _button(list,"Unequip to bag",Vector2.ZERO,Vector2(380,44),_character_choose_gear.bind(uid,id,true))
		remove.disabled = _locked() or not store.available_hero(id)

func _character_choose_gear(uid: String, id: String, remove: bool) -> void:
	_close_modal()
	if remove: _character_unequip(uid,id)
	else: _character_equip(uid,id)
