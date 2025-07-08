extends Node3D
class_name World

@export var explosion_scene : PackedScene
@export var tube_scene : PackedScene

@onready var player : Player = $Player
@onready var galaga_camera : Camera3D = $GalagaCamera
@onready var zaxxon_camera : Camera3D = $ZaxxonCamera
@onready var bkg : MeshInstance3D = $Background

@onready var top_border : CollisionShape3D = $WorldBorders/TopBorder
@onready var left_border : CollisionShape3D = $WorldBorders/LeftBorder
@onready var right_border : CollisionShape3D = $WorldBorders/RighBorder
@onready var back_border: CollisionShape3D  = $WorldBorders/BackBorder
@onready var left_top_border : CollisionShape3D = $WorldBorders/LeftTopBorder
@onready var right_top_border : CollisionShape3D = $WorldBorders/RightTopBorder

var score : int = 0

var flow_speed : float

var distance : float = 0.0


var transforming : bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_C:
			transforming = true

func _ready() -> void:
	left_top_border.set_deferred("disabled", true)
	right_top_border.set_deferred("disabled", true)
	back_border.shape.plane.d = -2

	flow_speed = Globals.scroll_speed / bkg.mesh.size.y
	EventBus.enemy_destroyed.connect(_on_enemy_destroyed)
	EventBus.building_destroyed.connect(_on_building_destroyed)
	EventBus.player_died.connect(_on_player_died)
	EventBus.waves_ended.connect(_on_waves_ended)



func _process(delta: float) -> void:
	distance += flow_speed * delta

	bkg.mesh.material.set_shader_parameter("dist", distance)



func spawn_explosion(pos : Vector3):
	var explosion : GPUParticles3D = explosion_scene.instantiate()
	explosion.amount = randi_range(16, 24)
	explosion.position = pos
	add_child(explosion)


func spawn_explosion_on_moving_element(element : Node3D, pos : Vector3, exp_scale : Vector3):
	var explosion : GPUParticles3D = explosion_scene.instantiate()
	explosion.amount = randi_range(16, 32)
	explosion.position = pos
	explosion.scale = exp_scale
	explosion.local_coords = true
	element.add_child(explosion)	

func _on_enemy_destroyed(enemy : Node3D):
	score += enemy.score_value
	EventBus.score_changed.emit(score)
	spawn_explosion(enemy.global_position)


func _on_building_destroyed(building : Node3D, building_parent : Node3D):
	spawn_explosion_on_moving_element(building_parent, building.position + Vector3.UP * 3.0, Vector3.ONE * 2)


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
	tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.set_parallel()
	tw.tween_property(player, "position:z", 0.0, 1.0)
	tw.tween_property(player, "position:x", 0.0, 1.0)
	tw.tween_property(player, "transform", Transform3D.IDENTITY, 1.0)
	if Globals.game_mode == Globals.GameMode.GALAGA:
		tw.tween_property(galaga_camera, "transform", $ZaxxonCameraPos.transform, 1.0)
	
		tw.tween_property(self, "flow_speed", 5.0/180.0, 1.0)
		tw.tween_property(bkg.mesh, "size", Vector2(240.0, 180.0), 1.0)
	else:
		tw.tween_property(galaga_camera, "transform", $GalagaCameraPos.transform, 1.0)
	
		tw.tween_property(self, "flow_speed", 5.0/60, 1.0)
		tw.tween_property(bkg.mesh, "size", Vector2(80.0, 60.0), 1.0)		
	
	tw.finished.connect(transforming_done)

	left_top_border.set_deferred("disabled", false)
	right_top_border.set_deferred("disabled", false)
	top_border.set_deferred("disabled", true)
	back_border.shape.plane.d = -40


func transforming_done():
	transforming = false
	if Globals.game_mode == Globals.GameMode.GALAGA:
		Globals.game_mode = Globals.GameMode.ZAXXON
		player.steering_mode = player.SteeringMode.ZAXXON
		var tube : Segment = tube_scene.instantiate()
		tube.position = Vector3(-34.5, -5, -93)
		tube.tree_exited.connect(_on_waves_ended)
		add_child.call_deferred(tube)
	else:
		Globals.game_mode = Globals.GameMode.GALAGA
		player.steering_mode = player.SteeringMode.GALAGA
		$SpawnManager.start()
	player.enable()



func remove_bullets():
	BulletPool.collect_all()

func get_projected_mouse_position() -> Vector3:
	var projected_pos : Vector3 = Vector3.ZERO
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()

	var from : Vector3 = galaga_camera.project_ray_origin(mouse_pos)
	
	projected_pos = Vector3(from.x, player.global_position.y, from.z)

	return projected_pos
