extends Enemy
class_name FirstBoss

enum Cycle {
	PULSE_CANNON,
	LASERS,
	ROTATING_CANON,
}

@onready var left_raycast : RayCast3D = $LeftRaycast
@onready var right_raycast : RayCast3D = $RightRaycast

@onready var pulse_cannon : PulseCannon = %PulseCannon
@onready var left_laser : LaserWeapon = %LeftLaser
@onready var right_laser : LaserWeapon = %RightLaser

var activated : bool = false

var target_velocity : Vector3

var current_cycle : Cycle = Cycle.PULSE_CANNON

var angle : float = 0.0

var rest : bool = false

func _ready() -> void:
	super()
	rotate_x(PI)
	velocity = Vector3.ZERO
	set_physics_process(false)
	speed = 5
	show()
	var tw : Tween = create_tween()
	tw.tween_property(self, "position:z", -30, 2.0)
	tw.finished.connect(_on_entry_finished)


func _process(delta: float) -> void:
	angle += PI * delta
	pulse_cannon.rotation.y = PI / 4 * sin(angle)

func _physics_process(delta: float) -> void:
	velocity = lerp(velocity, target_velocity, 0.05)

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

	EventBus.boss_health_changed.emit(hp / 1000.0 * 100.0)

	if is_instance_valid(self):
		EventBus.enemy_hit.emit(self, amount)
	if hp <= 0:
		die()
	else:
		blink()


func change_cycle():
	var new_cycle : Cycle = randi_range(Cycle.PULSE_CANNON, Cycle.ROTATING_CANON) as Cycle
	# while new_cycle == current_cycle:
	# 	new_cycle = randi_range(Cycle.PULSE_CANNON, Cycle.ROTATING_CANON) as Cycle

	current_cycle = new_cycle
	if current_cycle == Cycle.PULSE_CANNON:
		pulse_cannon.fire_rate = 0.25
		pulse_cannon.power_level = 3
		set_process(false)
		pulse_cannon.rotation.y = 0
		pulse_cannon.set_spread(true)
		pulse_cannon.activate()
	elif current_cycle == Cycle.LASERS:
		left_laser.activate()
		right_laser.activate()
	else:
		pulse_cannon.power_level = 4
		pulse_cannon.set_spread(false)
		pulse_cannon.fire_rate = 0.175
		pulse_cannon.activate()
		set_process(true)
		
	rest = true
	$Timer.start(randf_range(3.0, 4.0))

func activate():
	activated = true
	set_physics_process(true)
	target_velocity = Vector3.RIGHT * speed
	$Timer.start()


func die():
	super()
	EventBus.boss_defeated.emit()
	#$AnimationPlayer.stop()

func _on_entry_finished():
	EventBus.boss_entered.emit()
	activate()


func _on_timer_timeout() -> void:
	if current_cycle == Cycle.PULSE_CANNON:
		pulse_cannon.deactivate()
	elif current_cycle == Cycle.LASERS:
		left_laser.stop()
		right_laser.stop()
	else:
		pulse_cannon.set_spread(false)
		pulse_cannon.deactivate()
		pulse_cannon.rotation = Vector3.ZERO
		set_process(false)

	if rest:
		rest = false
		$Timer.start(randf_range(1.0, 1.5))
		return

	change_cycle()
