extends Node3D
class_name Enemy

@onready var body_pivot = $BodyPivot

@export var hp : int = 5
@export var speed : float = 30.0

@export var body_colors : Array[Color] = []

var velocity : Vector3
var rotation_quat : Quaternion


func _ready() -> void:
	velocity = -global_basis.z * speed
	rotation_quat = body_pivot.transform.basis.get_rotation_quaternion()
	set_colors()

func set_colors():
	for i in body_pivot.get_child_count():
		var body_part = body_pivot.get_child(i)
		body_part.set_instance_shader_parameter("body_color", body_colors[i])


func take_damage(amount : float):
	hp -= amount
	if hp <= 0:
		die()
	else:
		blink()

func blink():
	for i in body_pivot.get_child_count():
		var body_part : MeshInstance3D = body_pivot.get_child(i)
		body_part.set_instance_shader_parameter("body_color", Color.WHITE)
		await get_tree().create_timer(0.075).timeout
		body_part.set_instance_shader_parameter("body_color", body_colors[i])

func die():
	pass