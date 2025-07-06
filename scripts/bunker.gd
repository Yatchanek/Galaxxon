extends Building
class_name Bunker

@onready var turret_body : MeshInstance3D = $BodyParts/TurretBody
@onready var turret_pivot : Node3D = $BodyParts/TurretBody/TurretPivot
@onready var cannon : PulseCannon = $BodyParts/TurretBody/TurretPivot/PulseCannon


var rotation_quat : Quaternion

func _ready() -> void:
	super()
	set_process(false)
	cannon.set_process(false)
	rotation_quat = turret_pivot.basis.get_rotation_quaternion()

func _process(delta: float) -> void:
	var under_player_pos : Vector3 = Vector3(Globals.player.global_position.x, turret_body.global_position.y, Globals.player.global_position.z)
	turret_body.global_transform = turret_body.global_transform.interpolate_with(turret_body.global_transform.looking_at(under_player_pos), 0.09)
	var angle_diff : float = turret_pivot.global_position.direction_to(Globals.player.global_position).signed_angle_to(turret_pivot.global_position.direction_to(under_player_pos + Vector3.UP * turret_pivot.position.y), turret_pivot.global_basis.x)
	rotation_quat = Quaternion(turret_pivot.basis.x, -angle_diff)

	turret_pivot.rotation = turret_pivot.basis.get_rotation_quaternion().slerp(rotation_quat, 0.075).get_euler()

	turret_pivot.rotation.x = clamp(turret_pivot.rotation.x, -PI / 12, PI / 4)


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	if is_inside_tree():
		set_process(false)
		cannon.set_process(false)

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	if is_inside_tree():
		set_process(true)
		cannon.set_process(true)