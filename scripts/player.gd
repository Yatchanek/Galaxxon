extends Node3D
class_name Player

enum SteeringMode {
	GALAGA,
	ZAXXON
}

enum ControllerType {
	KEYBOARD,
	MOUSE
}

const HORIZONTAL_SPEED : int = 40
const VERTICAL_SPEED : int = 40
const ACCELERATION : float = 100.0

@export var cannon_weapon_scene : PackedScene
@export var laser_weapon_scene : PackedScene

@export var body_colors : Array[Color] = []

@export var world : World 
@export var steering_mode : SteeringMode = SteeringMode.GALAGA
@export var controller_type : ControllerType = ControllerType.KEYBOARD


@onready var body_pivot : Node3D = $BodyPivot
@onready var body : MeshInstance3D = $BodyPivot/Body
@onready var wings : MeshInstance3D = $BodyPivot/Wings
@onready var shoot_timer : Timer = $ShootTimer
@onready var main_weapon_slot : Node3D = $MainWeaponSlot

var velocity : Vector3 = Vector3.ZERO


var spread_fire : bool = true

var current_weapon : Weapon

var hp : float = 20


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_Q and !event.is_echo():
			current_weapon.upgrade()
		if event.pressed and event.keycode == KEY_Z and !event.is_echo():
			if current_weapon is CannonWeapon:
				current_weapon.change_spread()
		if event.pressed and event.keycode == KEY_P:
			current_weapon.queue_free()
			if current_weapon is CannonWeapon:
				var new_weapon : LaserWeapon = laser_weapon_scene.instantiate()
				main_weapon_slot.add_child(new_weapon)
				current_weapon = new_weapon
			else:
				var new_weapon : CannonWeapon = cannon_weapon_scene.instantiate()
				main_weapon_slot.add_child(new_weapon)
				current_weapon = new_weapon

func _ready() -> void:
	current_weapon = main_weapon_slot.get_child(0)
	

func _physics_process(delta: float) -> void:
	if controller_type == ControllerType.MOUSE:
		var target_pos : Vector3 = world.get_projected_mouse_position() - Vector3.FORWARD * body.mesh.size.z * 0.5
		var distance_to_target : float = global_position.distance_squared_to(target_pos)
		var damping : float = 1.0
		var threshold : float = 5.0
		if distance_to_target < threshold:
			damping = remap(distance_to_target, 0.15, threshold, 0.0, 1.0)
			
		if distance_to_target > 0.1:
			var target_velocity : Vector3 = (target_pos - global_position).normalized() * HORIZONTAL_SPEED * damping
			velocity = lerp(velocity, target_velocity, 0.25)
		else:
			velocity = Vector3.ZERO

		if abs(velocity.x) > 0.1:
			var target_transform : Transform3D = Transform3D.IDENTITY.rotated(Vector3.FORWARD, PI / 5 * sign(velocity.x))
			body_pivot.transform = body_pivot.transform.interpolate_with(target_transform, 0.1)
		else:
			body_pivot.transform = body_pivot.transform.interpolate_with(Transform3D.IDENTITY, 0.1)

	else:
		var direction : Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if direction.x != 0:
			velocity.x = move_toward(velocity.x, direction.x * HORIZONTAL_SPEED, ACCELERATION * delta)
			var target_transform : Transform3D = Transform3D.IDENTITY.rotated(Vector3.FORWARD, PI / 5 * direction.x)
			body_pivot.transform = body_pivot.transform.interpolate_with(target_transform, 0.1)
		else:
			velocity.x = move_toward(velocity.x, direction.x * HORIZONTAL_SPEED, ACCELERATION * 3.0 * delta)
			body_pivot.transform = body_pivot.transform.interpolate_with(Transform3D.IDENTITY, 0.1)

		if direction.y != 0:
			if steering_mode == SteeringMode.GALAGA:
				velocity.z = move_toward(velocity.z, direction.y * VERTICAL_SPEED, ACCELERATION * delta)
			else:
				velocity.y = move_toward(velocity.y, direction.y * VERTICAL_SPEED, ACCELERATION * delta)
		else:
			if steering_mode == SteeringMode.GALAGA:
				velocity.z = move_toward(velocity.z, 0, ACCELERATION * 3.0 * delta)
			else:
				velocity.y = move_toward(velocity.y, 0, ACCELERATION * 3.0 * delta)


	position += velocity * delta
	position.x = clamp(position.x, -23, 23)
	position.z = clamp(position.z, -40, 0)
	position.y = clamp(position.y, -3.5, 15)


func take_damage(amount : float):
	hp -= amount
	EventBus.player_hp_changed.emit(hp)
	if hp <= 0:
		die()
	else:
		blink()

func blink():
	for i in body_pivot.get_child_count():
		var body_part : MeshInstance3D = body_pivot.get_child(i)
		body_part.set_instance_shader_parameter("body_color", Color.RED)
		await get_tree().create_timer(0.1).timeout
		body_part.set_instance_shader_parameter("body_color", body_colors[i])

func die():
	set_physics_process(false)
	$BodyPivot/Body/Hitbox.disable()
	EventBus.player_died.emit()