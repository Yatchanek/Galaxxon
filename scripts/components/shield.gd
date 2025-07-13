extends Node3D
class_name Shield

@export var max_hp : int = 1000

@export var target : Node3D

@onready var hitbox : HitBox = $Hitbox
@onready var body : MeshInstance3D = $Body

var hp : float

var mat : ShaderMaterial

var can_blink : bool = true

var elapsed_time : float = -1.0
var angle : float = 0.0
var noise_tex : Texture2D

func _ready() -> void:
    hp = 0
    body.hide()
    hitbox.disable()
    EventBus.shield_hp_changed.emit(hp / max_hp * 100.0)
    mat = body.get_surface_override_material(0)


func recharge(amount : float):
    if hp == 0:
        body.show()
        hitbox.enable()

    hp = min(hp + amount, max_hp)

    EventBus.shield_hp_changed.emit(hp / max_hp * 100.0)

func take_damage(amount : float, dir : Vector3 = Vector3.ZERO):
    if amount <= hp:
        hp -= amount
        blink(dir)
    else:
        var remainder = amount - hp
        hp = 0
        body.hide()
        hitbox.disable()
        target.take_damage(remainder)
    EventBus.shield_hp_changed.emit(hp)

func blink(dir : Vector3 = Vector3.ZERO):
    if !can_blink:
        return
    can_blink = false
    mat.set_shader_parameter("shot_direction", dir)
    mat.set_shader_parameter("is_hit", true)
    var tw : Tween = create_tween()
    #tw.tween_property(mat, "shader_parameter/shield_color", Color.WHITE, 0.1)
    tw.parallel().tween_property(mat, "shader_parameter/alpha_threshold", 0.05, 0.1)
    #tw.tween_property(mat, "shader_parameter/shield_color", Color.CYAN, 0.1)
    tw.parallel().tween_property(mat, "shader_parameter/alpha_threshold", 0.25, 0.1)   
    tw.finished.connect(_on_blink_end)

func _on_blink_end():
    mat.set_shader_parameter("is_hit", false)
    can_blink = true