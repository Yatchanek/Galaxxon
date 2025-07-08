extends Node3D
class_name PathEnemy

@onready var body_pivot : Node3D = $BodyPivot

@export var flight_time : float
@export var hitbox : HitBox
@export var hurtbox : HurtBox
@export var hp : float = 5

@export var score_value : int = 100

@export var body_colors : Array[Color] = []

var rotation_quat : Quaternion

var can_blink : bool = true

func _ready() -> void:
	rotation_quat = body_pivot.transform.basis.get_rotation_quaternion()
	for body_part : MeshInstance3D in body_pivot.get_children():
		body_colors.append(body_part.get_surface_override_material(0).albedo_color)
			
func _process(delta: float) -> void:
	if -global_basis.z.cross(Vector3.RIGHT).y > 0:
		rotation_quat = Quaternion(Vector3.BACK, -PI / 8)
		rotation_quat *= Quaternion(Vector3.RIGHT, -PI / 8)
	else:
		rotation_quat = Quaternion(Vector3.BACK, PI / 8)
		rotation_quat *= Quaternion(Vector3.RIGHT, PI / 8)

	body_pivot.rotation = body_pivot.basis.get_rotation_quaternion().slerp(rotation_quat, delta).get_euler()


func take_damage(amount : float):
	hp -= amount
	if hp <= 0:
		die()
	else:
		blink()

func blink():
	if !can_blink:
		return
	for i in body_pivot.get_child_count():
		var body_part : MeshInstance3D = body_pivot.get_child(i)
		var tw : Tween = create_tween()
		tw.tween_property(body_part.get_surface_override_material(0), "albedo_color", Color.WHITE, 0.05)
		tw.tween_property(body_part.get_surface_override_material(0), "albedo_color", body_colors[i], 0.05)
		if i == body_pivot.get_child_count() - 1:
			tw.finished.connect(func(): can_blink = true)					


func die():
	EventBus.enemy_destroyed.emit(self)
	set_physics_process(false)
	hurtbox.disable()
	hitbox.disable()
	queue_free()