extends Enemy
class_name AimingEnemy

@export var turning : bool = false
@onready var body : MeshInstance3D = $BodyPivot/Body

func _ready() -> void:
	super()
	

func _process(delta: float) -> void:
	body.look_at(EventBus.player.global_position)


func _physics_process(delta: float) -> void:
	velocity = -global_basis.z * speed
	position += velocity * delta

	if (velocity.x > 0 and position.x > 40) or (velocity.x < 0 and position.x < -40) or (velocity.y > 0 and position.y < 2):
		queue_free()

func die():
	EventBus.enemy_destroyed.emit(self)
	set_physics_process(false)
	hitbox.disable()
	hurtbox.disable()
	queue_free()