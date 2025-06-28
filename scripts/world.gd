extends Node3D
class_name World

enum GameMode {
	GALAGA,
	ZAXXON
}

@export var game_mode : GameMode = GameMode.GALAGA
@export var explosion_scene : PackedScene

@onready var player : Player = $Player
@onready var galaga_camera : Camera3D = $GalagaCamera
@onready var zaxxon_camera : Camera3D = $ZaxxonCamera
@onready var bkg : MeshInstance3D = $Background

var score : int = 0

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_C:
			set_process(true)

func _ready() -> void:
	set_process(false)
	EventBus.enemy_destroyed.connect(_on_enemy_destroyed)
	EventBus.player_died.connect(_on_player_died)
	if game_mode == GameMode.GALAGA:
		bkg.mesh.size = Vector2(60.0, 50.0)
		bkg.mesh.material.set_shader_parameter("mesh_size", Vector2(60.0, 50.0))
		galaga_camera.current = true
		zaxxon_camera.current = false
	else:
		bkg.mesh.size = Vector2(175.0, 250.0)
		bkg.mesh.material.set_shader_parameter("mesh_size", Vector2(175.0, 250.0))
		galaga_camera.current = false
		zaxxon_camera.current = true

func _process(delta: float) -> void:
	galaga_camera.transform = galaga_camera.transform.interpolate_with(zaxxon_camera.transform, 0.05)
	if galaga_camera.transform.is_equal_approx(zaxxon_camera.transform):
		galaga_camera.transform = zaxxon_camera.transform
		set_process(false)

func _on_enemy_destroyed(enemy : Enemy):
	score += enemy.score_value
	EventBus.score_changed.emit(score)
	var explosion : GPUParticles3D = explosion_scene.instantiate()
	explosion.position = enemy.position
	add_child(explosion)


func _on_player_died():
	player.hide()
	var explosion : GPUParticles3D = explosion_scene.instantiate()
	explosion.position = player.position
	add_child(explosion)

	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

func get_projected_mouse_position() -> Vector3:
	var projected_pos : Vector3 = Vector3.ZERO
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()

	var from : Vector3 = galaga_camera.project_ray_origin(mouse_pos)
	
	projected_pos = Vector3(from.x, player.global_position.y, from.z)

	return projected_pos
