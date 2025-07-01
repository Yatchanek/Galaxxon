extends Node3D
class_name World

@export var explosion_scene : PackedScene

@onready var player : Player = $Player
@onready var galaga_camera : Camera3D = $GalagaCamera
@onready var zaxxon_camera : Camera3D = $ZaxxonCamera
@onready var bkg : MeshInstance3D = $Background

var score : int = 0

var flow_speed : float

var distance : float = 0.0


var transforming : bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_C:
			transforming = true

func _ready() -> void:
	flow_speed = 5.0 / bkg.mesh.size.y
	EventBus.enemy_destroyed.connect(_on_enemy_destroyed)
	EventBus.player_died.connect(_on_player_died)
	EventBus.waves_ended.connect(_on_waves_ended)


func _process(delta: float) -> void:

	distance += flow_speed * delta

	bkg.mesh.material.set_shader_parameter("dist", distance)

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
	explosion.finished.connect(remove_bullets)
	add_child(explosion)

	await get_tree().create_timer(2.0).timeout
	remove_bullets()
	get_tree().reload_current_scene()


func _on_waves_ended():
	player.disable()
	transforming = true
	var tw : Tween = create_tween()
	tw.set_parallel()
	tw.tween_property(galaga_camera, "transform", zaxxon_camera.transform, 1.0)
	tw.tween_property(player, "position:z", 0.0, 1.0)
	tw.tween_property(bkg.mesh.material, "shader_parameter/mesh_size", Vector2(175.0, 250.0), 1.0)
	tw.tween_property(self, "flow_speed", 5.0/250.0, 1.0)
	tw.tween_property(bkg.mesh, "size", Vector2(175.0, 250.0), 1.0)

	tw.finished.connect(transforming_done)


func transforming_done():
	Globals.game_mode = Globals.GameMode.ZAXXON
	player.steering_mode = player.SteeringMode.ZAXXON
	player.enable()
	$Tube.set_physics_process(true)

func remove_bullets():
	BulletPool.collect_all()

func get_projected_mouse_position() -> Vector3:
	var projected_pos : Vector3 = Vector3.ZERO
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()

	var from : Vector3 = galaga_camera.project_ray_origin(mouse_pos)
	
	projected_pos = Vector3(from.x, player.global_position.y, from.z)

	return projected_pos
