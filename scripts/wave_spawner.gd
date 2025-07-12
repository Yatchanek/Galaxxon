extends Node3D
class_name WaveSpawner


@onready var timer : Timer = $Timer
@onready var enemy_path : EnemyPath = $EnemyPath


@export var enemy_scene : Dictionary[Globals.EnemyType, PackedScene] = {}
@export var path_follow_scene : PackedScene

@export var enemy_data : Array[EnemyData] = []

var waves : Array[WaveData] = []

@export var total_waves : int = 999
var current_wave : int = 0

var last_wave_spawned : bool = false

var enemies_spawned : int = 0

var prev_enemy_data : EnemyData

func _ready() -> void:
	pass


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
	var boss : Enemy = enemy_scene[Globals.EnemyType.FIRST_BOSS].instantiate()
	boss.position = Vector3(0, 0, -45)
	boss.tree_exited.connect(_on_boss_defeated)
	add_child.call_deferred(boss)


func spawn_enemy(wave_data : WaveData):
	if wave_data.enemy_type < Globals.EnemyType.BASIC_PATH_ENEMY:
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


	for i in num_waves:
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
				if data.enemy_type >= Globals.EnemyType.BASIC_PATH_ENEMY:
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

func set_wave_data(wave_data : WaveData, data : EnemyData):
	wave_data.enemy_type = data.enemy_type
	wave_data.enemy_count = Globals.RNG.randi_range(data.min_amount, data.max_amount)
	wave_data.spawn_interval = data.spawn_frequency

	if data.enemy_type == Globals.EnemyType.BASIC_ENEMY:
		if Globals.RNG.randf() < 0.25:
			wave_data.turning = true
	elif data.enemy_type == Globals.EnemyType.DIAGONAL_ENEMY:
		wave_data.turn_threshold = Globals.RNG.randi_range(data.min_turn_threshold, data.max_turn_threshold)

	elif wave_data.enemy_type == Globals.EnemyType.BASIC_PATH_ENEMY:
		enemy_path.redraw()
		enemy_path.position.z = Globals.RNG.randf_range(-20, -30)

	wave_data.time_left = wave_data.spawn_interval

func _on_enemy_tree_exit():
	enemies_spawned -= 1
	if last_wave_spawned and enemies_spawned == 0:
		if is_inside_tree():
			await get_tree().create_timer(2.0).timeout
			spawn_boss()

func _on_timer_timeout() -> void:
	if (Globals.RNG.randf() < 0.17 and waves.size() < 4) or waves.is_empty():
		generate_wave()		


func start():
	last_wave_spawned = false
	current_wave = 0
	enemies_spawned = 0
	timer.start()
	set_process(true)
		
func stop():
	set_process(false)
	waves = []


func _on_boss_defeated():
	if is_inside_tree():
		await get_tree().create_timer(2.0).timeout
		EventBus.waves_ended.emit()