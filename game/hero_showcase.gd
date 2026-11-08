class_name HeroShowcase
extends RefCounted
## Read-only presentation; management actions route to the existing guarded UI.
static func show(game, id: String, section: String = "Information") -> void:
	var row: Dictionary = game.catalog.find_row("heroes", id)
	if row.is_empty(): row = CharacterPreviews.find(id)
	if row.is_empty(): return
	var preview: bool = row.get("preview", false)
	if preview: section = "Information"
	var surface := UIDesignV2.overlay(game, "HeroShowcase")
	surface.set_meta("hero_id", id)
	if row.art.get("inset_showcase",false):
		UIDesignV2.art(surface, HeroContract.art_texture(row,"showcase"), Vector2(8,108), Vector2(338,380))
	else:
		var illustration := UIDesignV2.art(surface, load(row.art.banner), Vector2(8,112) if preview else Vector2(8,8), Vector2(476,376) if preview else Vector2(476,480))
		if preview: illustration.focus.y = 0
	var veil := ColorRect.new()
	veil.position = Vector2(8, 8)
	veil.size = Vector2(476, 100)
	veil.color = Color("091327b8")
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	surface.add_child(veil)
	UIDesignV2.button(game, surface, "‹", Vector2(16, 16), Vector2(44, 44), game._close_modal).name = "ShowcaseBack"
	UIDesignV2.text(surface, row.name, Vector2(72, 12), Vector2(230, 40), 30)
	UIDesignV2.text(surface, "★★★★★", Vector2(72, 53), Vector2(160, 22), 17, UIDesignV2.GOLD)
	UIDesignV2.text(surface, str(row.element).capitalize() + " · " + row.role, Vector2(72, 78), Vector2(250, 24), 14)
	UIDesignV2.button(game, surface, "Home", Vector2(398, 16), Vector2(78, 44), func(): game._close_modal(); game._select_tab(24)).name = "ShowcaseHome"
	for i in range(6):
		var name_text: String = ["Information", "Skills", "Equipment", "Wardrobe", "Bond · Locked", "Story · Locked"][i]
		var action: Callable = show.bind(game, id, "Skills" if i == 1 else "Information")
		if i in [2,3]: action = manage.bind(game, id, 1 if i == 2 else 6)
		var button := UIDesignV2.button(game, surface, name_text, Vector2(354, 120 + i * 51), Vector2(122, 44), action, section == name_text)
		button.name = "ShowcaseTab%d" % i
		button.add_theme_font_size_override("font_size", 12)
		if i >= 4 or preview and i >= 1:
			button.disabled = true
			button.tooltip_text = game.tr("Not available yet")
	var detail := Panel.new()
	detail.position = Vector2(8, 488)
	detail.size = Vector2(476, 156)
	detail.add_theme_stylebox_override("panel", UIDesignV2.panel())
	surface.add_child(detail)
	var scroller := SwipeScroll.new()
	scroller.position = Vector2(12, 8)
	scroller.size = Vector2(452, 140)
	scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail.add_child(scroller)
	var body := VBoxContainer.new()
	body.custom_minimum_size.x = 430
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroller.add_child(body)
	var owned: bool = not preview and game.store.available_hero(id)
	var heading := Label.new()
	heading.text = game.tr("Skills") if section == "Skills" else row.title
	heading.add_theme_font_size_override("font_size", 20)
	heading.add_theme_color_override("font_color", UIDesignV2.GOLD)
	body.add_child(heading)
	if id == "caelan" and not owned:
		var recruit := UIDesignV2.button(game,body,"Recruit Caelan · Free",Vector2.ZERO,Vector2(430,44),game._confirm_caelan,true)
		recruit.name = "RecruitCaelan"
		recruit.disabled = game._locked() or 1 not in game.store.profile.cleared
	var copy := Label.new()
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.add_theme_font_size_override("font_size", 14)
	copy.text = (game.tr("Basic skill") + "\n" + row.skill_descriptions.basic + "\n\n" + game.tr("Ultimate") + "\n" + row.skill_descriptions.ultimate) if section == "Skills" else ((game.tr("Owned") if owned else game.tr("Not owned")) + " · 5★\n" + row.acquisition)
	if preview: copy.text = game.tr("Design preview · Not playable") + "\n" + row.acquisition + "\n\n“" + row.quote + "”"
	if owned and section == "Information":
		var stats: Dictionary = game.catalog.stats(game.store.profile, id)
		copy.text += "\n\nLV%d · HP %.0f · ATK %.0f · DEF %.2f" % [game.store.profile.heroes[id].level, stats.hp, stats.atk, stats.defense]
	body.add_child(copy)
	var strip := SwipeScroll.new()
	strip.position = Vector2(16, 658)
	strip.size = Vector2(460, 94)
	strip.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	surface.add_child(strip)
	var portraits := HBoxContainer.new()
	portraits.add_theme_constant_override("separation", 8)
	strip.add_child(portraits)
	var heroes: Array = game.catalog.data.heroes.duplicate()
	heroes.append_array(CharacterPreviews.rows())
	heroes.sort_custom(func(a,b): return a.gallery_order < b.gallery_order)
	for hero in heroes:
		var button := UIDesignV2.button(game, portraits, "", Vector2.ZERO, Vector2(96, 86), show.bind(game, hero.id), hero.id == id)
		button.tooltip_text = hero.name
		button.name = "ShowcaseHero_" + hero.id
		UIDesignV2.art(button, HeroContract.art_texture(hero,"card"), Vector2(3, 3), Vector2(90, 55))
		UIDesignV2.text(button, hero.name, Vector2(4, 59), Vector2(88, 20), 12).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

static func manage(game, id: String, page: int) -> void:
	if game.catalog.find_row("heroes", id).is_empty(): return
	game._close_modal()
	game._open_gallery_hero(id)
	game._character_section(page)
