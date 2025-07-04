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
	flow_speed = Globals.scroll_speed / bkg.mesh.size.y
	EventBus.enemy_destroyed.connect(_on_enemy_destroyed)
	EventBus.building_destroyed.connect(_on_building_destroyed)
	EventBus.player_died.connect(_on_player_died)
	EventBus.waves_ended.connect(_on_waves_ended)


func _process(delta: float) -> void:

	distance += flow_speed * delta

	bkg.mesh.material.set_shader_parameter("dist", distance)

	if transforming:
		galaga_camera.transform = galaga_camera.transform.interpolate_with(zaxxon_camera.transform, 0.05)
		player.body_pivot.transform = player.body_pivot.transform.interpolate_with(Transform3D.IDENTITY, 0.05)

		if galaga_camera.transform.is_equal_approx(zaxxon_camera.transform):
			transforming = false
			transforming_done()


func spawn_explosion(pos : Vector3):
	var explosion : GPUParticles3D = explosion_scene.instantiate()
	explosion.position = pos
	add_child(explosion)


func spawn_explosion_on_moving_element(element : Node3D, pos : Vector3):
	var explosion : GPUParticles3D = explosion_scene.instantiate()
	explosion.position = pos
	element.add_child(explosion)	

func _on_enemy_destroyed(enemy : Enemy):
	score += enemy.score_value
	EventBus.score_changed.emit(score)
	spawn_explosion(enemy.global_position)


func _on_building_destroyed(building : Node3D, building_parent : Node3D):
	spawn_explosion_on_moving_element(building_parent, building.position)


func _on_player_died():
	$Tube.set_physics_process(false)
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
	tw.tween_property(player, "position:z", 0.0, 1.0)
	tw.tween_property(player, "position:x", 0.0, 1.0)
	tw.tween_property(self, "flow_speed", 5.0/220.0, 1.0)
	tw.tween_property(bkg.mesh, "size", Vector2(240.0, 220.0), 1.0)



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
