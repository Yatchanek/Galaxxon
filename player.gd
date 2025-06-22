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

@export var world : World 
@export var steering_mode : SteeringMode = SteeringMode.GALAGA
@export var controller_type : ControllerType = ControllerType.KEYBOARD


@onready var body : MeshInstance3D = $Body
var velocity : Vector3 = Vector3.ZERO



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
			body.transform = body.transform.interpolate_with(target_transform, 0.1)
		else:
			body.transform = body.transform.interpolate_with(Transform3D.IDENTITY, 0.1)

	else:
		var direction : Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if direction.x != 0:
			velocity.x = move_toward(velocity.x, direction.x * HORIZONTAL_SPEED, ACCELERATION * delta)
			var target_transform : Transform3D = Transform3D.IDENTITY.rotated(Vector3.FORWARD, PI / 5 * direction.x)
			body.transform = body.transform.interpolate_with(target_transform, 0.1)
		else:
			velocity.x = move_toward(velocity.x, direction.x * HORIZONTAL_SPEED, ACCELERATION * 3.0 * delta)
			body.transform = body.transform.interpolate_with(Transform3D.IDENTITY, 0.1)

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
	position.x = clamp(position.x, -31, 31)
	position.z = clamp(position.z, -33, 0)
	position.y = clamp(position.y, -3.5, 15)
