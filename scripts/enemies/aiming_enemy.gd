extends Enemy
class_name AimingEnemy

@export var turning : bool = false
@onready var body : MeshInstance3D = $BodyPivot/Body

func _ready() -> void:
	super()
	

func _process(_delta: float) -> void:
	body.look_at(EventBus.player.global_position)


func _physics_process(delta: float) -> void:
	velocity = -global_basis.z * speed
	position += velocity * delta

	if position.x > 35 or position.x < -35 or position.z > 5:
		queue_free()

func die():
	EventBus.enemy_destroyed.emit(self)
	set_physics_process(false)
	hitbox.disable()
	hurtbox.disable()
	queue_free()