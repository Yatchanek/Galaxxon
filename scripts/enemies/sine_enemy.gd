extends Enemy
class_name SineEnemy



var angle : float = 0.0
var angle_2 : float = 0.0

func _ready() -> void:
	super()
	set_process(turning)
	if turning:
		rolling = true
		yawing = true


func set_colors():
	for surface : int in $BodyPivot/Body.get_surface_override_material_count():
		body_colors.append($BodyPivot/Body.get_surface_override_material(surface).albedo_color)

func _process(delta: float) -> void:
	angle += delta * 2.0


func _physics_process(delta: float) -> void:
	velocity = -global_basis.z.rotated(Vector3.UP, PI / 6 * sin(angle)) * speed
	position += velocity * delta
	
	if yawing:
		rotation_quat = Quaternion(Vector3.UP, PI / 6 * sin(angle))

	if rolling:
		if -global_basis.z.cross(velocity).y > 0:
			if yawing:
				rotation_quat *= Quaternion(Vector3.BACK, PI / 8 + PI / 12 * abs(velocity.z) / speed)
			else:
				rotation_quat = Quaternion(Vector3.BACK, PI / 8 + PI / 12 * abs(velocity.z) / speed)
		else:
			if yawing:
				rotation_quat *= Quaternion(Vector3.BACK, -PI / 8 - PI / 12 * abs(velocity.z) / speed)
			else:
				rotation_quat = Quaternion(Vector3.BACK, -PI / 8 - PI / 12 * abs(velocity.z) / speed)

	body_pivot.rotation = body_pivot.transform.basis.get_rotation_quaternion().slerp(rotation_quat, 0.05).get_euler()


	if position.x > 35 or position.x < -35 or position.z > 5:
		queue_free()


func blink():
	if !can_blink:
		return
	can_blink = false
	for surface : int in $BodyPivot/Body.get_surface_override_material_count():
		var tw : Tween = create_tween()
		tw.tween_property($BodyPivot/Body.get_surface_override_material(surface), "emission_energy_multiplier", 1.0, 0.1)
		tw.tween_property($BodyPivot/Body.get_surface_override_material(surface), "emission_energy_multiplier", 0.0, 0.1)		

		if surface == $BodyPivot/Body.get_surface_override_material_count() - 1:
			tw.finished.connect(func(): can_blink = true)

func die():
	EventBus.enemy_destroyed.emit(self)
	set_physics_process(false)
	hurtbox.disable()
	hitbox.disable()
	queue_free()