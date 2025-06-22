extends Node3D
class_name PathEnemySpawner

@export var path_enemy_scene : PackedScene
@export var sine_enemy_scene : PackedScene
@export var enemy_count : int = 10
@export var time_to_cross : float = 7.0

@onready var path : EnemyPath = $EnemyPath
@onready var timer : Timer = $Timer

var curve_length : float


func _ready() -> void:
	curve_length = path.curve.get_baked_length()
	if enemy_count > 0:
		timer.start()

func spawn_enemy():
	var enemy : SineEnemy = sine_enemy_scene.instantiate()
	if randf() < 0.5:
		enemy.position = Vector3(randf_range(-35, 35), 0, -40)
		enemy.rotate_y(PI)
	else:
		enemy.position = Vector3(-40 * pow(-1, randi() % 2), 0, -25)
		enemy.rotate_y(PI / 2 * sign(enemy.position.x)) 
	# if enemy.position.x > 0:
	# 	enemy.rotate(Vector3.UP, PI / 2)
	# else:
	# 	enemy.rotate(Vector3.UP, -PI / 2)

	get_parent().add_child.call_deferred(enemy)
	# var enemy : PathEnemy = path_enemy_scene.instantiate()
	# enemy.speed = curve_length / time_to_cross
	# enemy.max_distance = curve_length
	# path.add_child.call_deferred(enemy)
	enemy_count -= 1
	if enemy_count > 0:
		timer.start()

func _on_timer_timeout() -> void:
	spawn_enemy()
