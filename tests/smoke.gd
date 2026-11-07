extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	game.gold = 0
	game.level = 1
	game._start()
	game._skill(0)
	var after_hit: float = game.enemy_hp
	game._skill(0)
	assert(game.enemy_hp == after_hit, "Cooldown must block repeated casts")
	game.hp = 1
	game._skill(1)
	assert(game.hp == 66, "Heal must restore HP")
	for i in range(3):
		game._damage(9999)
	assert(game.state == "won")
	assert(game.gold == 40)
	game._damage(9999)
	assert(game.gold == 40, "Reward must settle once")
	game._upgrade()
	assert(game.level == 2 and game.gold == 10)
	game._load_progress()
	assert(game.level == 2 and game.gold == 10)
	game._start()
	game.hp = 1
	game.enemy_clock = 2.79
	game._physics_process(0.02)
	assert(game.state == "lost")
	print("PASS: cooldown, heal, waves, reward, upgrade, save/load, defeat")
	quit()
