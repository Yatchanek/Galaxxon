extends Bullet
class_name MegaBomb

@export var hurtbox_scene : PackedScene

var elapsed_time : float = 0.0

func _ready() -> void:
    set_physics_process(false)
    

func _physics_process(delta: float) -> void:
    super(delta)

    elapsed_time += delta
    if elapsed_time >= 2.0:
        explode()
        elapsed_time = 0.0


func explode():
    velocity = Vector3.ZERO
    set_physics_process(false)

    elapsed_time = 0.0
    EventBus.mega_bomb_exploded.emit(global_position)
    stop()
    await get_tree().create_timer(1.0).timeout
    if is_inside_tree():
        return_to_pool()
        return

func start():
    velocity = -global_basis.z * speed
    set_physics_process(true)
    hitbox.enable()

func stop():
    super()

    elapsed_time = 0.0
