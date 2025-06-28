extends Node3D
class_name WaveSpawner

enum EnemyType {
	BASIC_ENEMY,
	DIAGONAL_ENEMY,
	SHOOTING_ENEMY,
	AIMING_ENEMY,
}

@export var enemy_scene : Dictionary[EnemyType, PackedScene] = {}

var waves : Array[WaveData] = []

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
	var enemy : Enemy = enemy_scene[wave_data.enemy_type].instantiate()
	enemy.position = Vector3(wave_data.x_coord, 0, -50)
	enemy.rotate_y(PI)
	if enemy is SineEnemy:
		enemy.yawing = wave_data.yawing
		enemy.rolling = wave_data.rolling
		enemy.turning = wave_data.turning
	elif enemy is DiagonalEnemy:
		enemy.turn_threshold = wave_data.turn_threshold

	get_parent().add_child.call_deferred(enemy)

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
		var x_coord : int = snappedi(randi_range(-20, 20), 5)
		while !check_available(x_coord):
			x_coord = snappedi(randi_range(-20, 20), 5)
		
		var wave_data : WaveData = WaveData.new()
		wave_data.x_coord = x_coord
		wave_data.enemy_count = randi_range(1, 5)
		roll = randf()
		if roll < 0.35:
			wave_data.enemy_type = EnemyType.BASIC_ENEMY
			if randf() < 0.25:
				wave_data.yawing = true
				wave_data.rolling = true
				wave_data.turning = true
			wave_data.spawn_interval = 1.25
		elif roll < 0.7:
			wave_data.enemy_type = EnemyType.DIAGONAL_ENEMY
			wave_data.turn_threshold = randi_range(-20, -10)
			wave_data.spawn_interval = 1.5

		else:
			wave_data.enemy_type = EnemyType.AIMING_ENEMY
			#wave_data.turning = randf() < 0.25
			wave_data.spawn_interval = 2.25

		wave_data.time_left = wave_data.spawn_interval
		waves.append(wave_data)


func _on_timer_timeout() -> void:
	if randf() < 0.15 or waves.is_empty():
		generate_wave()		
	
		
func stop():
	set_process(false)