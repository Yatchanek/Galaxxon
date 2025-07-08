extends Node3D
class_name WaveSpawner


@onready var timer : Timer = $Timer
@onready var enemy_path : EnemyPath = $EnemyPath


@export var enemy_scene : Dictionary[Globals.EnemyType, PackedScene] = {}
@export var path_follow_scene : PackedScene

var waves : Array[WaveData] = []

@export var total_waves : int = 5
var current_wave : int = 0

var last_wave_spawned : bool = false

var enemies_spawned : int = 0

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
	var roll : float = randf()
	var num_waves : int = 1
	if roll > 0.8:
		num_waves = 2
	if roll > 0.99:
		num_waves = 3


	for i in num_waves:
		var x_coord : int = snappedi(randi_range(-26, 26), 5)
		while !check_available(x_coord):
			x_coord = snappedi(randi_range(-26, 26), 5)
		
		var wave_data : WaveData = WaveData.new()
		wave_data.x_coord = x_coord
		
		roll = randf()
		if roll < 0.35:
			set_wave_data(wave_data,  Globals.EnemyType.BASIC_ENEMY)
		elif roll < 0.45:
			set_wave_data(wave_data,  Globals.EnemyType.DIAGONAL_ENEMY)

		elif roll < 0.55:
			set_wave_data(wave_data,  Globals.EnemyType.AIMING_ENEMY)

		elif enemy_path.can_spawn:
			enemy_path.can_spawn = false
			set_wave_data(wave_data,  Globals.EnemyType.BASIC_PATH_ENEMY)

		else:
			set_wave_data(wave_data,  Globals.EnemyType.BASIC_ENEMY)

		
		waves.append(wave_data)
		current_wave += 1
		enemies_spawned += wave_data.enemy_count
		if current_wave == total_waves:
			timer.stop()
			last_wave_spawned = true
			break

func set_wave_data(wave_data : WaveData, enemy_type : Globals.EnemyType):
	wave_data.enemy_type = enemy_type
	if enemy_type == Globals.EnemyType.BASIC_ENEMY:
		wave_data.enemy_count = randi_range(3, 5)
		if randf() < 0.25:
			wave_data.turning = true
		wave_data.spawn_interval = 1.25
	elif enemy_type == Globals.EnemyType.DIAGONAL_ENEMY:
		wave_data.enemy_count = randi_range(2, 5)
		wave_data.turn_threshold = randi_range(-20, -10)
		wave_data.spawn_interval = 1.5		
	elif enemy_type == Globals.EnemyType.AIMING_ENEMY:
		wave_data.enemy_count = randi_range(1, 3)
		wave_data.spawn_interval = 2.25
	elif enemy_type == Globals.EnemyType.BASIC_PATH_ENEMY:
		enemy_path.redraw()
		enemy_path.position.z = randf_range(-20, -30)
		wave_data.enemy_count = randi_range(3, 6)
		wave_data.enemy_type = Globals.EnemyType.BASIC_PATH_ENEMY
		wave_data.spawn_interval = 1.75		

	wave_data.time_left = wave_data.spawn_interval

func _on_enemy_tree_exit():
	enemies_spawned -= 1
	if last_wave_spawned and enemies_spawned == 0:
		if is_inside_tree():
			await get_tree().create_timer(2.0).timeout
			EventBus.waves_ended.emit()

func _on_timer_timeout() -> void:
	if (randf() < 0.17 and waves.size() < 4) or waves.is_empty():
		generate_wave()		


func start():
	current_wave = 0
	timer.start()
	set_process(true)
		
func stop():
	set_process(false)