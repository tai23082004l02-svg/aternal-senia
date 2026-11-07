class_name MissionScreen
extends VBoxContainer
var game
var tabs: Array[Button] = []
var shown_key := -1
var refresh_clock := 0.0

func _ready() -> void:
	custom_minimum_size.x = 492
	add_theme_constant_override("separation", 12)
	text("NHIỆM VỤ & PHẦN THƯỞNG", 23, Color("e5cd9e"))
	var strip := HBoxContainer.new()
	strip.add_theme_constant_override("separation", 6)
	add_child(strip)
	for i in range(3):
		var button: Button = game._button(strip, ["Hằng ngày", "Hằng tuần", "Tiến trình"][i], Vector2.ZERO, Vector2(160, 46), game._mission_tab.bind(i))
		button.add_theme_font_size_override("font_size", 16)
		if i == game.mission_tab: button.modulate = Color("f2d08e")
		tabs.append(button)
	if game.mission_tab == 2:
		permanent()
		return
	var period := "daily" if game.mission_tab == 0 else "weekly"
	var section: Dictionary = MissionBoard.state(game.store.profile)[period]
	shown_key = int(section.key)
	var points := MissionBoard.points(section, period)
	text("Điểm hoạt động %s · %d/100" % ["hôm nay" if period == "daily" else "tuần này", points], 18, Color("e5cd9e"))
	var progress := ProgressBar.new()
	progress.custom_minimum_size.y = 12
	progress.show_percentage = false
	progress.add_theme_stylebox_override("background", game._style(Color("243c45"), Color("3e5558"), 6))
	progress.add_theme_stylebox_override("fill", game._style(Color("c2a469"), Color("d8bd85"), 6))
	progress.value = points
	add_child(progress)
	var chests := HBoxContainer.new()
	chests.add_theme_constant_override("separation", 6)
	add_child(chests)
	for threshold in MissionBoard.CHESTS:
		var claimed: bool = threshold in section.chests
		var button: Button = game._button(chests, "%d điểm\n%s" % [threshold, "Đã nhận" if claimed else ("Nhận quà" if points >= threshold else "Chưa đạt")], Vector2.ZERO, Vector2(93, 58), game._mission_chest.bind(period, threshold))
		button.add_theme_font_size_override("font_size", 12)
		if points >= threshold and not claimed: button.modulate = Color("f2d08e")
	var final_reward := MissionBoard.chest_reward(period, 100)
	text("Mốc 100: %d vàng · %d tinh thạch · %d VIP EXP" % [final_reward.gold, final_reward.shards, final_reward.vip], 13, Color("e5cd9e"))
	text("Làm mới 00:00 UTC mỗi ngày" if period == "daily" else "Làm mới thứ Hai, 00:00 UTC", 13)
	text("VIP EXP đã tích lũy: %d · Mốc lên cấp chờ cấu hình" % MissionBoard.state(game.store.profile).vip_exp, 13)
	var done := 0
	for task in MissionBoard.TASKS[period]:
		if section.counts[task.id] >= task.target: done += 1
	text("Hoàn thành %d/5 · Mỗi nhiệm vụ +20 hoạt động" % done, 15)
	for task in MissionBoard.TASKS[period]:
		var count: int = section.counts[task.id]
		var claimed: bool = task.id in section.claimed
		card(task.name, "%d/%d · %d vàng · %d tinh thạch · %d VIP EXP" % [count, task.target, task.gold, task.shards, task.vip], "Đã nhận" if claimed else ("Nhận thưởng" if count >= task.target else "Đến làm"), game._mission_claim.bind(period, task.id) if count >= task.target else game._mission_go.bind(task.id), claimed or game._locked())

func permanent() -> void:
	text("Mốc hành trình vĩnh viễn · Giữ tiến trình đã nhận", 14)
	for quest in game.catalog.data.quests:
		var count: int = mini(game.store.profile.metrics[quest.metric], quest.target)
		var claimed: bool = quest.id in game.store.profile.claimed
		card(quest.name, "%d/%d · %d vàng · %d tinh thạch" % [count, quest.target, quest.gold, quest.shards], "Đã nhận" if claimed else ("Nhận thưởng" if count >= quest.target else "Chưa đạt"), game._quest.bind(quest.id), claimed or count < quest.target or game.store.read_only)
	game._button(self, "Bộ sưu tập & Thành tựu →", Vector2.ZERO, Vector2(492, 46), game._select_tab.bind(8))

func card(title: String, reward: String, action: String, callback: Callable, disabled: bool) -> void:
	var box := PanelContainer.new()
	box.add_theme_stylebox_override("panel", game._style(Color("152d38"), Color("465553"), 12))
	add_child(box)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 12)
	box.add_child(margin)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	margin.add_child(body)
	var heading := Label.new()
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.text = title
	heading.add_theme_font_size_override("font_size", 18)
	body.add_child(heading)
	var detail := Label.new()
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.text = reward
	detail.add_theme_font_size_override("font_size", 13)
	detail.modulate = Color("b3c4bd")
	body.add_child(detail)
	game._button(body, action, Vector2.ZERO, Vector2(440, 40), callback).disabled = disabled

func text(value: String, font_size: int, color: Color = Color("b3c4bd")) -> void:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = color
	add_child(label)

func _process(delta: float) -> void:
	if game.mission_tab == 2: return
	refresh_clock += delta
	if refresh_clock < 1: return
	refresh_clock = 0
	var period := "daily" if game.mission_tab == 0 else "weekly"
	if int(MissionBoard.state(game.store.profile)[period].key) != shown_key:
		game._refresh_panel()
