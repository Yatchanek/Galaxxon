extends Enemy
class_name FirstBoss

enum State {
	ENTRY,
	FIGHT
}

@onready var left_raycast : RayCast3D = $LeftRaycast
@onready var right_raycast : RayCast3D = $RightRaycast

var activated : bool = false

var target_velocity : Vector3

var current_state : State

func _ready() -> void:
	super()
	rotate_x(PI)
	velocity = Vector3.ZERO
	set_physics_process(false)
	speed = 5
	current_state = State.ENTRY
	show()
	var tw : Tween = create_tween()
	tw.tween_property(self, "position:z", -30, 2.0)
	tw.finished.connect(_on_entry_finished)

func _physics_process(delta: float) -> void:
	velocity = lerp(velocity, target_velocity, 0.05)
	#rotation_quat = Quaternion(Vector3.FORWARD, PI / 16 * sign(velocity.x))

	#body_pivot.rotation = body_pivot.basis.get_rotation_quaternion().slerp(rotation_quat, 0.025).get_euler()

	position += velocity * delta

	if left_raycast.is_colliding() or right_raycast.is_colliding():
		target_velocity.x *= -1
		if left_raycast.enabled:
			right_raycast.enabled = true
			left_raycast.enabled = false
		elif right_raycast.enabled:
			left_raycast.enabled = true
			right_raycast.enabled = false

func take_damage(amount : float):
	if !activated:
		return
	hp -= amount

	EventBus.boss_health_changed.emit(hp / 2500.0 * 100.0)

	if is_instance_valid(self):
		EventBus.enemy_hit.emit(self, amount)
	if hp <= 0:
		die()
	else:
		blink()


func activate():
	current_state = State.FIGHT
	activated = true
	set_physics_process(true)
	target_velocity = Vector3.RIGHT * speed
	$AnimationPlayer.play("Fight")


func die():
	super()
	EventBus.boss_defeated.emit()
	$AnimationPlayer.stop()

func _on_entry_finished():
	EventBus.boss_entered.emit()
	activate()
