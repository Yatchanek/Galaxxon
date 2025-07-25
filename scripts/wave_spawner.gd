extends Node3D
class_name WaveSpawner

enum SpawnType {
	ENEMY,
	ASTEROID
}

@onready var timer : Timer = $Timer
@onready var enemy_path : EnemyPath = $EnemyPath


@export var enemy_scene : Dictionary[Enums.EnemyType, PackedScene] = {}
@export var path_follow_scene : PackedScene

@export var enemy_data : Array[EnemyData] = []

var waves : Array[WaveData] = []

@export var total_waves : int = 1
var current_wave : int = 0

var last_wave_spawned : bool = false

var enemies_spawned : int = 0

var asteroids_to_spawn : int = 0

var prev_enemy_data : EnemyData

var currently_spawning : SpawnType

var current_stage : int = 0

var stage_ended : bool = false

func _ready() -> void:
	currently_spawning = SpawnType.ENEMY
	set_process(false)



func _process(delta: float) -> void:
	for i in range(waves.size() -1, -1, -1):
		var wave_data : WaveData = waves[i]
		wave_data.time_left -= delta
		if wave_data.time_left <= 0:
			wave_data.enemy_count -= 1
			spawn_enemy(wave_data)
			wave_data.time_left += wave_data.spawn_interval
			if wave_data.enemy_count == 0:
				waves.erase(wave_data)



func spawn_boss():
	var boss : Enemy = enemy_scene[Enums.EnemyType.FIRST_BOSS].instantiate()
	boss.position = Vector3(0, 0, -45)
	boss.tree_exited.connect(_on_boss_defeated)
	add_child.call_deferred(boss)


func spawn_asteroid():
	enemies_spawned += 1
	var asteroid : Asteroid = enemy_scene[Enums.EnemyType.ASTEROID].instantiate()
	asteroid.tree_exited.connect(_on_enemy_tree_exit)
	asteroid.position = Vector3(Globals.RNG.randf_range(-25, 25), 0, -40)
	add_child.call_deferred(asteroid)



func spawn_enemy(wave_data : WaveData):
	if wave_data.enemy_type < Enums.EnemyType.BASIC_PATH_ENEMY:
		var enemy : Enemy = enemy_scene[wave_data.enemy_type].instantiate()
		enemy.position = Vector3(wave_data.x_coord, 0, -50)
		enemy.rotate_y(PI)
		if enemy is SineEnemy:
			enemy.yawing = wave_data.yawing
			enemy.rolling = wave_data.rolling
			enemy.turning = wave_data.turning
		elif enemy is DiagonalEnemy:
			enemy.turn_threshold = wave_data.turn_threshold

		enemy.tree_exited.connect(_on_enemy_tree_exit)
		add_child.call_deferred(enemy)
	else:
		var path_follow : EnemyPathFollow = path_follow_scene.instantiate()
		var enemy : PathEnemy = enemy_scene[wave_data.enemy_type].instantiate()
		enemy.tree_exited.connect(_on_enemy_tree_exit)
		path_follow.tree_exited.connect(enemy_path._on_enemy_exited)

		if enemy_path.inverse:
			enemy.rotate_y(PI)

		path_follow.speed = enemy.flight_time
		path_follow.add_child(enemy)
		enemy_path.add_child.call_deferred(path_follow)
		
		

func check_available(x_coord : int) -> bool:
	for wave_data in waves:
		if wave_data.x_coord == x_coord:
			return false
	
	return true


func generate_wave():
	var roll : float = Globals.RNG.randf()
	var num_waves : int = 1
	if roll > 0.8:
		num_waves = 2
	if roll > 0.99:
		num_waves = 3

	#print("Number of waves:", num_waves)
	for i in num_waves:
		#print("Iteration:", i)
		if last_wave_spawned:
			break
		var x_coord : int = snappedi(Globals.RNG.randi_range(-30, 30), 5)
		while !check_available(x_coord):
			x_coord = snappedi(Globals.RNG.randi_range(-30, 30), 5)
		
		var wave_data : WaveData = WaveData.new()
		wave_data.x_coord = x_coord
		
		roll = Globals.RNG.randf()
		var total_chance : float = 0
		var chosen : bool = false
		for data : EnemyData in enemy_data:
			if chosen:
				break
			total_chance += data.spawn_chance
			if roll < total_chance:
				if data.enemy_type >= Enums.EnemyType.BASIC_PATH_ENEMY:
					if enemy_path.can_spawn and prev_enemy_data != data:
						enemy_path.can_spawn = false
						set_wave_data(wave_data, data)
						chosen = true
						prev_enemy_data = data
					else:
						data = enemy_data[0]
						set_wave_data(wave_data, data)
						prev_enemy_data = data
						chosen = true
				else:
					set_wave_data(wave_data, data)
					chosen = true
					prev_enemy_data = data

		if !chosen:
			set_wave_data(wave_data, enemy_data[0])
			prev_enemy_data = enemy_data[0]

		waves.append(wave_data)
		current_wave += 1
		enemies_spawned += wave_data.enemy_count
		if current_wave == total_waves:
			timer.stop()
			last_wave_spawned = true
			#print("Last wave spawned")
	#print("Enemies spawned", enemies_spawned)		

func set_wave_data(wave_data : WaveData, data : EnemyData):
	wave_data.enemy_type = data.enemy_type
	wave_data.enemy_count = Globals.RNG.randi_range(data.min_amount, data.max_amount)
	wave_data.spawn_interval = data.spawn_frequency

	if data.enemy_type == Enums.EnemyType.BASIC_ENEMY:
		if Globals.RNG.randf() < 0.25:
			wave_data.turning = true
	elif data.enemy_type == Enums.EnemyType.DIAGONAL_ENEMY:
		wave_data.turn_threshold = Globals.RNG.randi_range(data.min_turn_threshold, data.max_turn_threshold)

	elif wave_data.enemy_type == Enums.EnemyType.BASIC_PATH_ENEMY:
		enemy_path.redraw()
		enemy_path.position.z = Globals.RNG.randf_range(-20, -30)

	wave_data.time_left = wave_data.spawn_interval



func setup_next_stage():
	#print("Setup next stage")
	current_stage += 1
	if current_stage % 5 == 0:
		#print("Spawn boss")
		spawn_boss()

	else:
		await get_tree().create_timer(2.0).timeout
		EventBus.waves_ended.emit()

		# if currently_spawning == SpawnType.ENEMY:
		# 	var roll : float = Globals.RNG.randf()
		# 	if current_stage > 3 and roll < 0.2:
		# 		launch_asteroid_field()
		# 		#print("Launching asteroids")
				
		# 	elif roll < 0.7 or current_stage <= 3:
		# 		total_waves = 1#Globals.RNG.randi_range(5, 10)
		# 		launch_normal_waves()
				
		# 		#print("Launching normal waves")
		# 	else:	
		# 		await get_tree().create_timer(2.0).timeout
		# 		EventBus.waves_ended.emit()
		# 		#print("Going isometric")

		# else:
		# 	var roll : float = Globals.RNG.randf()
		# 	if roll < 0.7 or current_stage <= 3:
		# 		total_waves = 1#Globals.RNG.randi_range(5, 10)
		# 		launch_normal_waves()
		# 		#print("Launching normal waves")

		# 	else:
		# 		await get_tree().create_timer(2.0).timeout
		# 		EventBus.waves_ended.emit()				
		# 		#print("Going isometric")


func launch_asteroid_field():
	currently_spawning = SpawnType.ASTEROID
	asteroids_to_spawn = 30
	await get_tree().create_timer(1.0).timeout
	timer.wait_time = 0.5
	timer.start()


func launch_normal_waves():
	last_wave_spawned = false
	current_wave = 0
	enemies_spawned = 0
	currently_spawning = SpawnType.ENEMY
	timer.wait_time = 2.0
	timer.start()
	#print("Launching waves")
	set_process(true)


func _on_enemy_tree_exit():
	enemies_spawned -= 1
	#prints("Enemies spawned:", enemies_spawned)
	if last_wave_spawned and enemies_spawned == 0:
		if is_inside_tree():
			stage_ended = true
			#print("Stage ended")
			timer.start(2.0)



func _on_timer_timeout() -> void:
	if stage_ended:
		stage_ended = false
		setup_next_stage()
	else:
		if currently_spawning == SpawnType.ENEMY:
			if (Globals.RNG.randf() < 0.17 and waves.size() < 4) or waves.is_empty():
				generate_wave()
		else:
			if asteroids_to_spawn > 0:
				spawn_asteroid()
				asteroids_to_spawn -= 1
	

func start():
	#print("Starting")
	last_wave_spawned = false
	current_wave = 0
	enemies_spawned = 0
	setup_next_stage()

		
func stop():
	set_process(false)
	waves = []


func _on_boss_defeated():
	if is_inside_tree():
		stage_ended = true
		timer.start(2.0)
