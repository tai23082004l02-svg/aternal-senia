class_name SettingsScreen
extends Control

const TITLES := {"home":"SETTINGS", "audio":"AUDIO & VOLUME", "graphics":"GRAPHICS & DISPLAY", "auto":"AUTO BATTLE", "notifications":"NOTICES", "account":"ACCOUNT & DATA", "other":"ABOUT & SUPPORT", "restore":"RESTORE DATA"}
const AUDIO_DEFAULTS := {"sound":true,"music_volume":.35,"sfx_volume":.8,"ui_volume":.8,"ambience_volume":.35}
const GRAPHICS := ["quality","fps_limit","lighting","screen_shake","damage_numbers","battery_saver"]
var game
var page := "home"
var from_hub := true
var draft: Dictionary
var formation: Dictionary
var box: PanelContainer
var body: VBoxContainer
var notice: Label
var controls: Dictionary = {}
var sliders: Dictionary = {}
var percent_labels: Dictionary = {}
var primary: Button
var paused_battle
var owns_pause := false
var finished := false
var restore_candidate: Dictionary = {}
var name_input: LineEdit
var avatar_choice: OptionButton
var avatar_ids: Array[String] = []

static func open(owner_game,initial: String = "home",hub: bool = true) -> void:
	if owner_game.result_transition: return
	owner_game._close_modal()
	var screen := SettingsScreen.new()
	screen.game = owner_game
	screen.page = initial
	screen.from_hub = hub
	owner_game.modal = screen
	owner_game.ui.add_child(screen)

func _ready() -> void:
	size = Vector2(540,960)
	paused_battle = game.battle
	owns_pause = paused_battle != null and paused_battle.state == "battle" and not paused_battle.paused
	if owns_pause: paused_battle.paused = true
	game.audio_menu_open = true
	game.audio_menu_paused = owns_pause
	var shade := ColorRect.new()
	shade.size = size
	shade.color = Color(.01,.025,.04,.82)
	add_child(shade)
	box = PanelContainer.new()
	box.position = Vector2(34,100)
	box.size = Vector2(472,760)
	box.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
	add_child(box)
	read_saved()
	render(page)

func read_saved() -> void:
	draft = GameOptions.state(game.store.profile)
	for key in AUDIO_DEFAULTS: draft[key] = game.store.profile.settings.get(key,AUDIO_DEFAULTS[key])
	draft.ui_volume = game.store.profile.settings.get("ui_volume",draft.sfx_volume)
	draft.speed = mini(2,game.store.profile.settings.speed)
	formation = Formation.state(game.store.profile,game.catalog).duplicate(true)

func navigate(next: String) -> void:
	game.audio.cancel_preview()
	game.audio.apply_profile(game.store.profile)
	game._apply_presentation()
	read_saved()
	render(next)

func render(next: String) -> void:
	page = next
	controls.clear()
	sliders.clear()
	percent_labels.clear()
	for child in box.get_children():
		box.remove_child(child)
		child.queue_free()
	box.position.y = 130 if page == "home" else 90
	box.size.y = 700 if page == "home" else 780
	var area := Control.new()
	box.add_child(area)
	var backdrop := TextureRect.new()
	backdrop.texture = load("res://art/settings/window.png")
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_SCALE
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	area.add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var layout := VBoxContainer.new()
	area.add_child(layout)
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.offset_left = 20
	layout.offset_right = -20
	layout.offset_top = 16
	layout.offset_bottom = -20
	layout.add_theme_constant_override("separation",9)
	var top := HBoxContainer.new()
	layout.add_child(top)
	var back := button(top,"‹",go_back,Vector2(42,38))
	back.disabled = page == "home"
	if page == "home": back.modulate.a = 0.0
	var gem := TextureRect.new()
	gem.texture = game.icons.textures.cores
	gem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	gem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	gem.custom_minimum_size = Vector2(42,42)
	gem.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(gem)
	button(top,"×",game._close_modal,Vector2(42,38)).tooltip_text = tr("Close Settings")
	label(layout,tr(TITLES[page]),23,Color("f1d18e"),true)
	if page == "home": label(layout,tr("Customize your experience and player profile."),13,Color("e7deca"),true)
	var scroll := SwipeScroll.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",9)
	scroll.add_child(body)
	match page:
		"home": home()
		"audio": audio_page()
		"graphics": graphics_page()
		"auto": auto_page()
		"notifications": notifications_page()
		"account": account_page()
		"other": other_page()
		"restore": restore_page()
	notice = label(body,"",12,Color("f1c793"),true)
	game.audio_notice = notice
	var divider := HSeparator.new()
	layout.add_child(divider)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation",12)
	layout.add_child(footer)
	if page in ["audio","graphics","auto","notifications"]:
		button(footer,tr("↶ Defaults"),reset_page,Vector2(180,44)).size_flags_horizontal = Control.SIZE_EXPAND_FILL
		primary = button(footer,tr("✓ SAVE"),save,Vector2(180,44),true)
		primary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		primary.disabled = game.store.read_only or page == "auto" and not game.store.profile.pending.is_empty()
	elif page == "account":
		primary = button(footer,tr("✓ Save Profile"),save,Vector2(380,44),true)
		primary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		primary.disabled = game.store.read_only
	elif page == "restore":
		button(footer,tr("Cancel"),go_back,Vector2(160,44)).size_flags_horizontal = Control.SIZE_EXPAND_FILL
		primary = button(footer,tr("Restore"),save,Vector2(180,44),true)
		primary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		primary.disabled = game.store.read_only or not game.store.profile.pending.is_empty()
	else:
		button(footer,tr("Close"),game._close_modal,Vector2(380,44)).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if page == "audio": preview_audio()
	if page == "graphics": preview_graphics()

func label(parent: Node,value: String,font_size: int = 14,color: Color = Color("d0ded8"),center: bool = false) -> Label:
	var item := Label.new()
	item.text = value
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.add_theme_font_size_override("font_size",font_size)
	item.add_theme_color_override("font_color",color)
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if center: item.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(item)
	return item

func style(gold: bool = false) -> StyleBoxFlat:
	var result: StyleBoxFlat = game._style(Color("594725") if gold else Color(.035,.13,.17,.93),Color("e5c381") if gold else Color("7f958b"),14)
	result.set_content_margin_all(9)
	if gold:
		result.shadow_color = Color(1,.68,.2,.28)
		result.shadow_size = 6
	return result

func button(parent: Node,value: String,callback: Callable,minimum: Vector2 = Vector2(0,44),gold: bool = false) -> Button:
	var item: Button = game._button(parent,value,Vector2.ZERO,minimum,callback)
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_theme_stylebox_override("normal",style(gold))
	item.add_theme_font_size_override("font_size",16)
	return item

func card() -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel",style())
	body.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation",5)
	panel.add_child(content)
	return content

func home() -> void:
	for entry in [["audio","Audio & Volume","settings"],["graphics","Graphics & Display","light"],["auto","Auto Battle","slash"],["notifications","Notifications","mail"],["account","Account & Data","hero"],["other","About, language & support","journal"]]:
		var row := button(body,tr(entry[1])+"  ›",navigate.bind(entry[0]),Vector2(0,57))
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		game.icons.apply(row,entry[2],30)

func toggle(key: String,title: String,description: String,disabled: bool = false,value: Variant = null) -> CheckButton:
	var content := card()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",10)
	content.add_child(row)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(copy)
	label(copy,tr(title),16,Color("f0d395"))
	if not description.is_empty(): label(copy,tr(description),12)
	var control := GoldSwitch.new()
	control.button_pressed = bool(draft.get(key,false)) if value == null else bool(value)
	control.disabled = disabled
	row.add_child(control)
	controls[key] = control
	control.toggled.connect(func(enabled):
		draft[key] = enabled
		if page == "audio": preview_audio()
		if page == "graphics": preview_graphics())
	return control

func audio_page() -> void:
	game.sound_sliders.clear()
	game.sound_labels.clear()
	game.sound_enabled = toggle("sound","Game Audio","Disable to mute all audio.")
	for entry in [["music_volume","Music"],["sfx_volume","Skill Effects"],["ui_volume","UI Sounds"],["ambience_volume","Forest Ambience"]]:
		var content := card()
		var line := HBoxContainer.new()
		content.add_child(line)
		label(line,tr(entry[1]),16,Color("f0d395"))
		var value := label(line,"",14,Color("f6d489"))
		value.size_flags_horizontal = Control.SIZE_SHRINK_END
		value.custom_minimum_size.x = 42
		var slider := HSlider.new()
		slider.min_value = 0
		slider.max_value = 1
		slider.step = .01
		slider.custom_minimum_size = Vector2(0,24)
		slider.value = draft[entry[0]]
		var track := StyleBoxFlat.new()
		track.bg_color = Color("132d3a")
		track.content_margin_top = 5
		track.content_margin_bottom = 5
		track.set_corner_radius_all(5)
		track.set_border_width_all(1)
		track.border_color = Color("a59160")
		slider.add_theme_stylebox_override("slider",track)
		var fill := track.duplicate()
		fill.bg_color = Color("e2bf68")
		slider.add_theme_stylebox_override("grabber_area",fill)
		slider.add_theme_stylebox_override("grabber_area_highlight",fill)
		content.add_child(slider)
		var knob := DiamondKnob.new()
		knob.slider = slider
		knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slider.add_child(knob)
		knob.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		slider.value_changed.connect(func(_v): knob.queue_redraw(); preview_audio())
		sliders[entry[0]] = slider
		percent_labels[entry[0]] = value
		game.sound_sliders[entry[0]] = slider
		game.sound_labels[entry[0]] = value
	toggle("voice_unavailable","Character Voices","Character voice packs are not available yet.",true,false)
	label(body,tr("Audio pauses automatically when the app is in the background."),12,Color("cbd9d1"),true)
	button(body,tr("Preview sound effects"),game._audition,Vector2(0,36))

func preview_audio() -> void:
	if not controls.has("sound") or sliders.size() != 4: return
	draft.sound = controls.sound.button_pressed
	for key in sliders:
		draft[key] = sliders[key].value
		percent_labels[key].text = "%d%%" % roundi(sliders[key].value*100)
	game.audio.configure(draft.sound,draft.sfx_volume,draft.ambience_volume,draft.music_volume,draft.ui_volume)

func choice(key: String,title: String,entries: Array,values: Array,locked: bool = false) -> void:
	var content := card()
	label(content,tr(title),16,Color("f0d395"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",6)
	content.add_child(row)
	for i in range(entries.size()):
		var option := button(row,("✓ " if draft[key] == values[i] else "")+tr(entries[i]),choose.bind(key,values[i]),Vector2(0,36),draft[key] == values[i])
		option.disabled = locked
		option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		option.add_theme_font_size_override("font_size",13)

func choose(key: String,value: Variant) -> void:
	draft[key] = value
	render(page)

func graphics_page() -> void:
	choice("quality","2D effect detail",["Low","Medium","Cao"],["low","medium","high"])
	choice("fps_limit","Frame Rate Limit",["30 FPS","60 FPS"],[30,60])
	toggle("lighting","Lighting Effects","Decorative light particles and magical effects.")
	toggle("screen_shake","Screen Shake","Light camera shake on hits; not device vibration.")
	toggle("damage_numbers","Damage Numbers","Damage and healing numbers in battle.")
	toggle("battery_saver","Battery Saver","Limit to 30 FPS and reduce decorative effects.")
	label(body,tr("Does not change source artwork quality or damage timing."),12,Color("c4d4cd"),true)

func preview_graphics() -> void:
	var values := GameOptions.state(game.store.profile)
	for key in GameOptions.DEFAULTS: values[key] = draft[key]
	game._apply_presentation(values)

func auto_page() -> void:
	var locked: bool = game.store.read_only or not game.store.profile.pending.is_empty()
	draft.auto_ult = formation.auto_ult if not draft.has("auto_ult") else draft.auto_ult
	draft.auto_next = formation.auto_next if not draft.has("auto_next") else draft.auto_next
	toggle("auto_ult","Auto Ultimate","Use when Energy is full; applies to new battles.",locked)
	toggle("prioritize_heal","Prioritize healing at low HP","Mira's basic skill heals the lowest-HP ally below 85% HP.",locked)
	toggle("auto_next","Advance after victory","Continue only after rewards are saved.",locked)
	toggle("boss_fixed","Stop before major bosses","Current rules are always active.",true,true)
	toggle("sweep_unavailable","3★ Dungeon Sweep","Dungeon stars and sweeps are not available yet.",true,false)
	choice("speed","Default Battle Speed",["x1","x2"],[1,2],locked)
	toggle("reduced_effects","Reduced Skill Effects","Reduce decorative effects while keeping movement and battle cues.",locked)
	if locked: label(body,tr("Adjust auto battle options after the battle ends."),12,Color("edc585"),true)

func notifications_page() -> void:
	toggle("notify_rewards","In-game Reward Reminders","Show claimable reward badges in the Utilities menu.")
	toggle("afk_push_unavailable","AFK Storage Full Reminder","Notifications while the game is closed are not supported yet.",true,false)
	toggle("event_push_unavailable","Event Notifications","Event services and push notifications are not available yet.",true,false)
	label(body,tr("Does not request notification permissions or add background services."),12,Color("c4d4cd"),true)

func account_page() -> void:
	var identity := PlayerIdentity.state(game.store.profile)
	var content := card()
	var avatar := PlayerProfilePanel.RoundAvatar.new()
	avatar.custom_minimum_size = Vector2(66,66)
	avatar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(avatar)
	avatar.update_avatar(game.frames,identity.avatar)
	name_input = LineEdit.new()
	name_input.text = identity.name
	name_input.max_length = 20
	name_input.custom_minimum_size.y = 38
	name_input.editable = not game.store.read_only
	content.add_child(name_input)
	avatar_choice = OptionButton.new()
	avatar_ids.clear()
	for hero in game.catalog.data.heroes:
		if not game.store.available_hero(hero.id): continue
		avatar_ids.append(hero.id)
		avatar_choice.add_item(tr(hero.name))
	avatar_choice.selected = maxi(0,avatar_ids.find(identity.avatar))
	avatar_choice.disabled = game.store.read_only
	content.add_child(avatar_choice)
	label(content,tr("Version: %s · Local save") % ProjectSettings.get_setting("application/config/version"),12,Color("e2d0a6"),true)
	button(body,tr("Back up to file  ›"),file_picker.bind(true)).disabled = game.store.read_only or not game.store.profile.pending.is_empty()
	button(body,tr("Restore from backup  ›"),file_picker.bind(false)).disabled = game.store.read_only or not game.store.profile.pending.is_empty()
	button(body,tr("Copy Support Information"),copy_support)
	label(body,tr("Account linking, cloud saves, and server account IDs are not available. Gift codes and service policies have not been configured."),12,Color("bccfcb"),true)
	label(body,tr("File backups store progress on your device; they do not sign you into an online account."),12,Color("c4d4cd"),true)

func copy_support() -> void:
	DisplayServer.clipboard_set("Aternal Senia / "+str(ProjectSettings.get_setting("application/config/version"))+" / "+OS.get_name()+" / local save v"+str(game.store.profile.version))
	notice.text = tr("Version, operating system, and save type copied. Save contents are not copied.")

func file_picker(exporting: bool) -> void:
	var dialog := FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE if exporting else FileDialog.FILE_MODE_OPEN_FILE
	dialog.filters = PackedStringArray(["*.json ; First Light backup"])
	dialog.current_dir = ProjectSettings.globalize_path("user://")
	if exporting: dialog.current_file = "first-light-backup.json"
	dialog.use_native_dialog = true
	add_child(dialog)
	dialog.file_selected.connect(func(path):
		dialog.queue_free()
		if exporting:
			notice.text = tr("Data backed up.") if GameOptions.export_backup(game.store,path) else tr("Unable to write backup. Check the path and write permissions.")
		else:
			restore_candidate = GameOptions.read_backup(game.store,path)
			if restore_candidate.is_empty(): notice.text = tr("Invalid backup: oversized or contains an unfinished battle.")
			else: render("restore"))
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered_ratio(.8)

func restore_page() -> void:
	label(body,tr("This replaces local progress with the selected backup. Continue only if this is the data you want to use."),16,Color("f1d18e"))
	label(body,tr("Name: %s\nGold: %d\nXP: %d\nEquipment: %d\nSave version: %d") % [PlayerIdentity.state(restore_candidate).name,restore_candidate.gold,restore_candidate.xp,restore_candidate.items.size(),restore_candidate.version],15)
	label(body,tr("Cannot restore during an unfinished battle. Invalid files will not overwrite your current save."),13)

func other_page() -> void:
	var studio := card()
	label(studio,tr("ZORVYKA Games"),22,Color("f0d395"),true)
	label(studio,tr("Game Development Studio"),14,Color("c4d4cd"),true)
	label(studio,"zorvykagames@gmail.com",16,Color("f0d395"),true)
	button(studio,tr("Copy Support Email"),copy_email)
	var content := card()
	label(content,tr("Primary language: English"),17,Color("f0d395"))
	label(content,tr("English is the primary interface language. Player names remain unchanged and support Unicode."),13)
	label(card(),tr("Help & Bug Reports\nInclude your version, device, steps to reproduce, and screenshots or video. You choose whether to send an email; the game never sends your data automatically."),14)
	label(card(),tr("Terms & Privacy\nNo online service policy page has been configured. The game saves locally; this screen adds no server or SDK."),13)

func copy_email() -> void:
	DisplayServer.clipboard_set("zorvykagames@gmail.com")
	notice.text = tr("ZORVYKA Games support email copied.")

func reset_page() -> void:
	match page:
		"audio":
			for key in AUDIO_DEFAULTS: draft[key] = AUDIO_DEFAULTS[key]
		"graphics":
			for key in GRAPHICS: draft[key] = GameOptions.DEFAULTS[key]
		"auto":
			draft.auto_ult = true
			draft.auto_next = false
			draft.prioritize_heal = true
			draft.reduced_effects = false
			draft.speed = 1
		"notifications": draft.notify_rewards = true
	render(page)

func save() -> void:
	var success := false
	if page == "account":
		success = PlayerIdentity.save(game.store,name_input.text,avatar_ids[avatar_choice.selected])
	elif page == "restore":
		success = GameOptions.restore_backup(game.store,restore_candidate)
		if success:
			finish()
			game.selected_stage = 1
			game._return_to_camp()
			return
	else:
		var values := {}
		var options := {}
		match page:
			"audio":
				for key in AUDIO_DEFAULTS: values[key] = draft[key]
			"graphics":
				for key in GRAPHICS: values[key] = draft[key]
			"auto":
				values = {"speed":draft.speed,"reduced_effects":draft.reduced_effects,"prioritize_heal":draft.prioritize_heal}
				options = {"auto_ult":draft.auto_ult,"auto_next":draft.auto_next}
			"notifications": values.notify_rewards = draft.notify_rewards
		success = GameOptions.save(game.store,values,options)
	if not success:
		notice.text = game.store.error if not game.store.error.is_empty() else tr("Unable to save. Try again or close to discard changes.")
		return
	game.audio.play("confirm")
	game._refresh_panel()
	game._refresh_hud()
	if from_hub: navigate("home")
	else: finish()

func go_back() -> void:
	if page == "restore": navigate("account")
	elif from_hub: navigate("home")
	else: finish()

func finish() -> void:
	if finished: return
	finished = true
	game.audio.cancel_preview()
	game.audio.apply_profile(game.store.profile)
	game._apply_presentation()
	game.audio_menu_open = false
	game.audio_menu_paused = false
	game.sound_sliders.clear()
	game.sound_labels.clear()
	if owns_pause and game.battle == paused_battle and paused_battle != null and paused_battle.state == "battle": paused_battle.paused = false
	game.modal = null
	if get_parent() != null: get_parent().remove_child(self)
	queue_free()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var viewport := get_viewport()
		if page == "home": finish()
		else: go_back()
		viewport.set_input_as_handled()

class GoldSwitch extends CheckButton:
	func _ready() -> void:
		custom_minimum_size = Vector2(52,30)
		toggled.connect(func(_value): queue_redraw())
	func _draw() -> void:
		var skin := StyleBoxFlat.new()
		skin.bg_color = Color("157a78") if button_pressed else Color("253740")
		skin.border_color = Color("e0bf75") if button_pressed else Color("809794")
		skin.set_border_width_all(2 if has_focus() else 1)
		skin.set_corner_radius_all(15)
		draw_style_box(skin,Rect2(Vector2.ZERO,size))
		draw_circle(Vector2(size.x-15 if button_pressed else 15,size.y*.5),11,Color("f7dfa2") if button_pressed else Color("c0c8c5"))

class DiamondKnob extends Control:
	var slider: HSlider
	func _draw() -> void:
		var c := Vector2(8+(size.x-16)*slider.value,size.y*.5)
		draw_colored_polygon(PackedVector2Array([c+Vector2(0,-12),c+Vector2(8,0),c+Vector2(0,12),c+Vector2(-8,0)]),Color("e2bf73"))
		draw_colored_polygon(PackedVector2Array([c+Vector2(0,-8),c+Vector2(5,0),c+Vector2(0,8),c+Vector2(-5,0)]),Color("20beb1"))
