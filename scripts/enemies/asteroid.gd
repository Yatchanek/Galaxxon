@tool
extends Enemy
class_name Asteroid

@export var meshes : Array[ArrayMesh] = []

var rot_x : float
var rot_y : float
var rot_z : float

var rot_speed_x : float
var rot_speed_y : float
var rot_speed_z : float

func _ready() -> void:

	rot_x = randf_range(-PI, PI)
	rot_y = randf_range(-PI, PI)
	rot_y = randf_range(-PI, PI)

	$BodyPivot/Body.mesh = meshes[randi_range(0, 4)]

	#print(meshes.pick_random())

	speed = Globals.scroll_speed * speed_coefficient
	velocity = global_basis.z * speed
	rotation_quat = body_pivot.transform.basis.get_rotation_quaternion()
	set_colors()

func set_colors():
	body_colors.append($BodyPivot/Body.material_override.albedo_color)


func _process(delta: float) -> void:
	rotation_quat *= Quaternion(Vector3.RIGHT, delta * rot_x)
	rotation_quat *= Quaternion(Vector3.UP, delta * rot_y)
	rotation_quat *= Quaternion(Vector3.FORWARD, delta * rot_z)


	body_pivot.rotation = body_pivot.basis.get_rotation_quaternion().slerp(rotation_quat, 1.0).get_euler()


func _physics_process(delta: float) -> void:
	position += velocity * delta

	if position.z > 5:
		queue_free()


func blink():
	if !can_blink:
		return
	var tw : Tween = create_tween()
	tw.tween_property($BodyPivot/Body.material_override, "albedo_color", Color.WHITE, 0.1)
	tw.tween_property($BodyPivot/Body.material_override, "albedo_color", body_colors[0], 0.1)		

	tw.finished.connect(func(): can_blink = true)

func die():
	EventBus.enemy_destroyed.emit(self)
	set_physics_process(false)
	hurtbox.disable()
	hitbox.disable()
	queue_free()