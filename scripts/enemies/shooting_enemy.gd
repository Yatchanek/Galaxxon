extends Enemy
class_name ShootingEnemy

@export var turning : bool = false

var angle : float = 0.0

func _ready() -> void:
	super()
	set_process(turning)

func _process(delta: float) -> void:
	angle += delta * 4.0


func _physics_process(delta: float) -> void:
	velocity = -global_basis.z.rotated(Vector3.UP, PI / 6 * sin(angle)) * speed
	position += velocity * delta

	if (velocity.x > 0 and position.x > 40) or (velocity.x < 0 and position.x < -40) or (velocity.y > 0 and position.y < 2):
		queue_free()

func die():
	EventBus.enemy_destroyed.emit(self)
	set_physics_process(false)
	hitbox.disable()
	hurtbox.disable()
	queue_free()