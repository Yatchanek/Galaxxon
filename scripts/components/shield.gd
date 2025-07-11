extends Node3D
class_name Shield

@export var max_hp : int = 100

@export var target : Node3D

@onready var hitbox : HitBox = $Hitbox
@onready var body : MeshInstance3D = $Body

var hp : float

var mat : ShaderMaterial

var can_blink : bool = true

func _ready() -> void:
    hp = 0
    body.hide()
    hitbox.disable()
    print("Calling event bus")
    EventBus.shield_hp_changed.emit(hp / max_hp * 100.0)
    mat = body.get_surface_override_material(0)


func replenish(amount : float):
    if hp == 0:
        body.show()
        hitbox.enable()

    hp = min(hp + amount, max_hp)

    EventBus.shield_hp_changed.emit(hp)

func take_damage(amount):
    if amount <= hp:
        hp -= amount
        blink()
    else:
        var remainder = amount - hp
        hp = 0
        body.hide()
        hitbox.disable()
        target.take_damage(remainder)
    EventBus.shield_hp_changed.emit(hp)

func blink():
    var tw : Tween = create_tween()
    tw.tween_property(mat, "shader_parameter/shield_color", Color.WHITE, 0.1)
    tw.parallel().tween_property(mat, "shader_parameter/alpha_threshold", 0.25, 0.1)
    tw.tween_property(mat, "shader_parameter/shield_color", Color.CYAN, 0.1)
    tw.parallel().tween_property(mat, "shader_parameter/alpha_threshold", 0.5, 0.1)    