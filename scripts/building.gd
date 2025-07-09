extends Node3D
class_name Building

@onready var body_parts : Node3D = $BodyParts

@onready var hitbox : HitBox = $Hitbox
@onready var hurtbox : HurtBox = $Hurtbox

@export var hp : float = 20
@export var score_value : int = 100

var body_colors : Array[Color] = []
var can_blink : bool = true

var carries_powerup : bool = false

func _ready() -> void:
	carries_powerup = Globals.POWERUP_RNG.randf() < 0.1
	for body_part : MeshInstance3D in body_parts.get_children():
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
	for i in body_parts.get_child_count():
		var body_part : MeshInstance3D = body_parts.get_child(i)
		var tw : Tween = create_tween()
		tw.tween_property(body_part.get_surface_override_material(0), "albedo_color", Color.WHITE, 0.05)
		tw.tween_property(body_part.get_surface_override_material(0), "albedo_color", body_colors[i], 0.05)
		if i == body_parts.get_child_count() - 1:
			tw.finished.connect(func(): can_blink = true)

func die():
	EventBus.building_destroyed.emit(self, get_parent())
	set_process(false)
	hurtbox.disable()
	hitbox.disable()
	queue_free()


func _on_visible_on_screen_notifier_3d_screen_exited():
	if global_position.z > 0:
		print("Building out")
		queue_free()