extends Node3D

@export var enemy_scene : PackedScene

var slots : Array[Vector4i] = []

func _ready() -> void:
	for i in range(-20, 21, 5):
		slots.append(Vector4i(0, 0, 0, 0))

func spawn_enemy(x_coord: float, idx : int):
	var enemy : SineEnemy = enemy_scene.instantiate()
	enemy.position = Vector3(x_coord, 0, -50)
	enemy.rotate_y(PI)
	enemy.turning = bool(slots[idx].y)
	enemy.yawing = bool(slots[idx].z)
	enemy.rolling = bool(slots[idx].w)

	get_parent().add_child.call_deferred(enemy)

func get_free_slot() -> int:
	var idx : int = -1
	var attempts : int = 0
	idx = randi() % slots.size()
	while slots[idx].x > 0:
		if attempts > 15:
			return -1
		idx = randi() % slots.size()
		attempts += 1
	
	return idx

func generate_wave():
	var roll : float = randf()
	var num_waves : int = 1
	if roll > 0.66:
		num_waves = 2
	if roll > 0.9:
		num_waves = 3
	for i in num_waves:
		var idx : int = get_free_slot()
		if idx >= 0:
			var turning : int = 0 if randf() < 0.5 else 1
			slots[idx] = Vector4i(randi_range(1, 6), turning, 0, 0)

func _on_timer_timeout() -> void:
	for i in slots.size():
		if slots[i].x > 0:
			slots[i].x -= 1
			spawn_enemy(-20 + i * 5, i)
	
	if randf() < 0.25:
		generate_wave()		
	
		
