class_name AdminUnlock
extends RefCounted
## Owner-requested local development code. A single atomic, recorded grant.
const CODE := "admin"
const RESOURCES := 1000000
const MATERIALS := 10000

static func eligible(store: ProgressStore, code: String) -> bool:
	if code.strip_edges().to_lower() != CODE:
		store.error = "Unknown gift code."
		return false
	if store.read_only:
		store.error = "This save is read-only."
		return false
	if not store.profile.pending.is_empty():
		store.error = "Finish or retreat from the current battle before redeeming this code."
		return false
	if CODE in store.profile.get("redeemed_codes",[]):
		store.error = "The admin code has already been redeemed on this save."
		return false
	return true

static func redeem(store: ProgressStore, code: String) -> bool:
	if not eligible(store,code): return false
	var p := store.profile.duplicate(true)
	if not p.has("formation"): p.formation = Formation.state(p,store.catalog)
	var present: Array = p.bag_rewards.duplicate()
	for item in p.items:
		if item.base not in present: present.append(item.base)
	var missing: Array = []
	for row in store.catalog.data.items:
		if row.id not in present: missing.append(row.id)
	if missing.size() > ProgressStore.BAG_CAP-p.items.size()+128-p.bag_rewards.size():
		store.error = "Not enough room for all equipment. Clear space in Bag and Unclaimed Loot first."
		return false
	Recruitment.ensure(store,p)
	for key in ["gold","shards","xp"]: p[key] = maxi(int(p[key]),RESOURCES)
	p.expansion.cores = maxi(int(p.expansion.cores),MATERIALS)
	for id in Supplies.ORDER: p.supplies.counts[id] = maxi(int(p.supplies.counts[id]),MATERIALS)
	if not p.has("evolution"): p.evolution = HeroEvolution.fresh(store.catalog)
	for hero in store.catalog.data.heroes:
		if hero.id not in p.recruitment.heroes: p.recruitment.heroes.append(hero.id)
		p.heroes[hero.id].level = 100
		p.heroes[hero.id].skills = [10,10,10]
		p.recruitment.awakening[hero.id] = 5
		p.recruitment.fragments[hero.id] = maxi(int(p.recruitment.fragments[hero.id]),MATERIALS)
		p.evolution[hero.id] = 3
		var learned: Array = p.expansion.builds[hero.id].learned
		for talent in store.catalog.data.talents:
			if talent.id not in learned: learned.append(talent.id)
	SpiritSkills.ensure(p)
	for spirit in store.catalog.data.assists:
		if spirit.id not in p.recruitment.spirits: p.recruitment.spirits.append(spirit.id)
		p.assists[spirit.id] = 20
		p.expansion.ranks[spirit.id] = 3
		var build: Dictionary = p.expansion.spirit_skills[spirit.id]
		build.level = 10
		build.learned = ["nova","flow"]
		build.advanced_learned = SpiritSkills.ADVANCED.keys()
		p.collection_fragments.spirits[spirit.id] = maxi(int(p.collection_fragments.spirits[spirit.id]),MATERIALS)
	for stage in store.catalog.data.stages:
		if stage.id not in p.cleared: p.cleared.append(stage.id)
	for row in store.catalog.data.items:
		if row.id not in p.expansion.discovered: p.expansion.discovered.append(row.id)
	for base in missing:
		if p.items.size() < ProgressStore.BAG_CAP:
			if not store._add_item(p,base): return false
		else: p.bag_rewards.append(base)
	for item in p.items:
		item.enhance = EquipmentSystem.MAX_ENHANCE
		item.rank = 3
	p["redeemed_codes"] = [CODE]
	return store.commit(p)
