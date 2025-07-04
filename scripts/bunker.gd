extends Node3D
class_name Bunker

@onready var turret_body : MeshInstance3D = $BodyParts/TurretBody
@onready var body_parts : Node3D = $BodyParts
@onready var cannon : PulseCannon = $BodyParts/TurretBody/Turret/PulseCannon


@onready var hitbox : HitBox = $Hitbox
@onready var hurtbox : HurtBox = $Hurtbox

var hp : float = 20

var body_colors : Array[Color] = []
var can_blink : bool = true

func _ready() -> void:
	for body_part : MeshInstance3D in body_parts.get_children():
		body_colors.append(body_part.get_instance_shader_parameter("body_color"))
	set_process(false)
	cannon.set_process(false)

func _process(delta: float) -> void:
	turret_body.global_transform = turret_body.global_transform.interpolate_with(turret_body.global_transform.looking_at(Globals.player.global_position), 0.09)


func take_damage(amount : float):
	hp -= amount
	if hp <= 0:
		die()
	else:
		blink()
	print(hp)

func blink():
	if !can_blink:
		return
	for i in body_parts.get_child_count():
		var body_part : MeshInstance3D = body_parts.get_child(i)
		var tw : Tween = create_tween()
		tw.tween_property(body_part, "instance_shader_parameters/body_color", Color.WHITE, 0.05)
		tw.tween_property(body_part, "instance_shader_parameters/body_color", body_colors[i], 0.05)
		tw.finished.connect(func(): can_blink = true)

func die():
	EventBus.building_destroyed.emit(self, get_parent())
	set_process(false)
	cannon.set_process(false)
	hurtbox.disable()
	hitbox.disable()
	queue_free()


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	if is_inside_tree():
		set_process(false)
		cannon.set_process(false)

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	if is_inside_tree():
		set_process(true)
		cannon.set_process(true)