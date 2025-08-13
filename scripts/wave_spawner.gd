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
@export var island_scene : PackedScene

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

var last_stage_was_isometric : bool = false

var stages_from_last_isometric : int = 0

var max_lines_in_wave : int = 1

var distance_from_last_island : float = 0.0

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
	boss.position = Vector3(0, 5, -45)
	boss.tree_exited.connect(_on_boss_defeated)
	add_child.call_deferred(boss)
	timer.stop()


func spawn_asteroid():
	enemies_spawned += 1
	var asteroid : Asteroid = enemy_scene[Enums.EnemyType.ASTEROID].instantiate()
	asteroid.tree_exited.connect(_on_enemy_tree_exit)
	asteroid.position = Vector3(Globals.RNG.randf_range(-25, 25), 5, -40)
	add_child.call_deferred(asteroid)


func spawn_island():
	if stages_from_last_isometric == 0 or Globals.game_mode == Globals.GameMode.ZAXXON:
		return
	var island : Island = island_scene.instantiate()
	island.position.x = Globals.RNG.randf_range(-30, 30)
	island.position.y = -25
	island.position.z = -60
	distance_from_last_island = 0.0
	add_child.call_deferred(island)
	$IslandTimer.start()


func spawn_enemy(wave_data : WaveData):
	if wave_data.enemy_data.enemy_type < Enums.EnemyType.BASIC_PATH_ENEMY:
		var enemy : Enemy = enemy_scene[wave_data.enemy_data.enemy_type].instantiate()
		enemy.position = Vector3(wave_data.x_coord, 5, -50)
		enemy.hp = ceil(min(wave_data.enemy_data.base_hp * (1.0 + 0.1 * current_stage / 3), wave_data.enemy_data.base_hp * 5))
		enemy.rotate_y(PI)
		if enemy is SineEnemy or enemy is ShootingEnemy:
			enemy.yawing = wave_data.yawing
			enemy.rolling = wave_data.rolling
			enemy.turning = wave_data.turning
		elif enemy is DiagonalEnemy:
			enemy.turn_threshold = wave_data.turn_threshold

		enemy.tree_exited.connect(_on_enemy_tree_exit)
		add_child.call_deferred(enemy)
	else:
		var path_follow : EnemyPathFollow = path_follow_scene.instantiate()
		var enemy : PathEnemy = enemy_scene[wave_data.enemy_data.enemy_type].instantiate()
		enemy.tree_exited.connect(_on_enemy_tree_exit)
		path_follow.tree_exited.connect(enemy_path._on_enemy_exited)

		if enemy_path.inverse:
			enemy.rotate_y(PI)

		path_follow.speed = enemy.flight_time
		path_follow.add_child(enemy)
		enemy_path.add_child.call_deferred(path_follow)
		
		

func check_available(x_coord : int) -> bool:
	for wave_data in waves:
		if abs(wave_data.x_coord - x_coord) <= 1:
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
		
		
		var total_chance : float = 0
		var chosen : bool = false
		var available_enemies : Array[EnemyData] = []
		var total_weight : float = 0
		for data : EnemyData in enemy_data:
			if current_stage >= data.min_stage:
				available_enemies.append(data)
				total_weight += data.spawn_chance
		roll = Globals.RNG.randf_range(0, total_weight)
		for data : EnemyData in available_enemies:
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
			print("Timer stopped")
	#print("Enemies spawned", enemies_spawned)		

func set_wave_data(wave_data : WaveData, data : EnemyData):
	wave_data.enemy_data = data
	wave_data.enemy_count = Globals.RNG.randi_range(data.min_amount, data.max_amount)
	wave_data.spawn_interval = data.spawn_frequency

	if data.enemy_type == Enums.EnemyType.BASIC_ENEMY or data.enemy_type == Enums.EnemyType.SHOOTING_ENEMY:
		if Globals.RNG.randf() < 0.25:
			wave_data.turning = true
	elif data.enemy_type == Enums.EnemyType.DIAGONAL_ENEMY:
		wave_data.turn_threshold = Globals.RNG.randi_range(data.min_turn_threshold, data.max_turn_threshold)

	elif data.enemy_type == Enums.EnemyType.BASIC_PATH_ENEMY:
		enemy_path.redraw()
		enemy_path.position.z = Globals.RNG.randf_range(-20, -30)

	wave_data.time_left = wave_data.spawn_interval



func setup_next_stage():
	current_stage += 1
	timer.stop()

	if current_stage % 99 == 0:
		#print("Spawn boss")
		spawn_boss()

	else:
		if currently_spawning == SpawnType.ENEMY:
			var roll : float = Globals.RNG.randf()				
			if roll < 0.5:
				total_waves = Globals.RNG.randi_range(2, 5)
				launch_normal_waves()
				stages_from_last_isometric += 1
				
			elif current_stage >= 2 and stages_from_last_isometric > 3:
				stages_from_last_isometric = 0
				timer.stop()
				await get_tree().create_timer(2.0).timeout
				EventBus.waves_ended.emit()
				print("Going isometric")
			else:
				total_waves = Globals.RNG.randi_range(2, 5)
				print("Waves from last else")
				stages_from_last_isometric += 1
				launch_normal_waves()			
			
		else:
			var roll : float = Globals.RNG.randf()
			if roll < 0.65 or current_stage <= 3:
				total_waves = Globals.RNG.randi_range(5, 10)
				launch_normal_waves()
				stages_from_last_isometric += 1
				#print("Launching normal waves II")

			elif current_stage >= 2 and stages_from_last_isometric > 3:
				await get_tree().create_timer(2.0).timeout
				stages_from_last_isometric = 0
				timer.stop()
				EventBus.waves_ended.emit()				
				#print("Going isometric II")
			else:
				total_waves = Globals.RNG.randi_range(5, 10)
				launch_normal_waves()
				stages_from_last_isometric += 1	


func launch_asteroid_field():
	currently_spawning = SpawnType.ASTEROID
	asteroids_to_spawn = 30
	await get_tree().create_timer(1.0).timeout
	timer.wait_time = 0.5
	timer.start()


func launch_normal_waves():
	print("Launching normal waves")
	last_wave_spawned = false
	current_wave = 0
	enemies_spawned = 0
	currently_spawning = SpawnType.ENEMY
	timer.wait_time = 2.0
	timer.start()
	set_process(true)
	last_stage_was_isometric = false


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
		EventBus.stage_ended.emit()
		print("Stage ended, launching next stage")
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
	last_wave_spawned = false
	current_wave = 0
	enemies_spawned = 0
	setup_next_stage()
	$IslandTimer.start()
		
func stop():
	set_process(false)
	waves = []


func _on_boss_defeated():
	if is_inside_tree():
		stage_ended = true
		timer.start(2.0)


func _on_island_timer_timeout() -> void:
	distance_from_last_island += Globals.scroll_speed * $IslandTimer.wait_time

	if distance_from_last_island > 100 or (distance_from_last_island > 50 and Globals.RNG.randf() < 0.1):
		spawn_island()
		print("Spawn Island")
	else:
		$IslandTimer.start()
