extends Enemy
class_name DiagonalEnemy

var desired_velocity : Vector3
var turned : bool = false

var elapsed_time : float = 0
var turn_threshold : int = -20

func _ready() -> void:
	super()
	desired_velocity = velocity
	turn_threshold = randf_range(-25.0, -10.0)


func set_colors():
	for surface : int in $BodyPivot/Body.get_surface_override_material_count():
		body_colors.append($BodyPivot/Body.get_surface_override_material(surface).albedo_color)

func _physics_process(delta: float) -> void:
	elapsed_time += delta
	if turned:
		speed_coefficient = clamp(speed_coefficient + 2.0 * delta, 0.0, 3.0)
		desired_velocity = desired_velocity.normalized() * Globals.scroll_speed * speed_coefficient
		velocity = lerp(velocity, desired_velocity, 0.025)
	
		body_pivot.rotation = body_pivot.basis.get_rotation_quaternion().slerp(rotation_quat, 0.025).get_euler()

	position += velocity * delta

	if !turned and elapsed_time > 2.0 and position.y > turn_threshold:
		turned = true
		$BodyPivot/Engine.lifetime = 1.5
		if position.x >= 0:
			desired_velocity = velocity.rotated(Vector3.UP, -PI / 3)
			rotation_quat = Quaternion(Vector3.UP, -PI / 3) * Quaternion(Vector3.FORWARD, PI / 6)
		else:
			desired_velocity = velocity.rotated(Vector3.UP, PI / 3)
			rotation_quat = Quaternion(Vector3.UP, PI / 3)  * Quaternion(Vector3.FORWARD, -PI / 6)


	if position.z > 5 or position.x < -35 or position.x > 35:
		queue_free()


func blink():
	if !can_blink:
		return
	for surface : int in $BodyPivot/Body.get_surface_override_material_count():
		var tw : Tween = create_tween()
		tw.tween_property($BodyPivot/Body.get_surface_override_material(surface), "albedo_color", Color.WHITE, 0.1)
		tw.tween_property($BodyPivot/Body.get_surface_override_material(surface), "albedo_color", body_colors[surface], 0.1)		

		if surface == $BodyPivot/Body.get_surface_override_material_count() - 1:
			tw.finished.connect(func(): can_blink = true)


func die():
	EventBus.enemy_destroyed.emit(self)
	set_physics_process(false)
	hurtbox.disable()
	hitbox.disable()
	queue_free()