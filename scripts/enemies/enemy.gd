extends Node3D
class_name Enemy

@onready var body_pivot = $BodyPivot

@export var hitbox : HitBox
@export var hurtbox : HurtBox
@export var hp : float = 5
@export var speed_coefficient : float = 2.0

@export var score_value : int = 100

@export var body_colors : Array[Color] = []

var speed : float
var velocity : Vector3
var rotation_quat : Quaternion

var can_blink : bool = true

var carries_powerup : bool = false

func _ready() -> void:
	carries_powerup = Globals.POWERUP_RNG.randf() < 0.1
	speed = Globals.scroll_speed * speed_coefficient
	velocity = -global_basis.z * speed
	rotation_quat = body_pivot.transform.basis.get_rotation_quaternion()
	set_colors()

func set_colors():
	for body_part : MeshInstance3D in body_pivot.get_children():
		body_colors.append(body_part.get_surface_override_material(0).albedo_color)


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
	pass