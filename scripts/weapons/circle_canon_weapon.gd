extends CannonWeapon
class_name CircleCannonWeapon

@export var in_bullet : bool = true
@export var muzzle_count : int = 8

func _ready() -> void:
    super()
    set_muzzles()
    if in_bullet:
        set_process(false)

func set_muzzles():
    var angle_increment : float = TAU / muzzle_count
    var angle : float = 0.0
    for i : int in muzzle_count:
        var muzzle : Marker3D = Marker3D.new()
        muzzle.position = Vector3(cos(angle), 0, sin(angle))
        muzzle.rotate_y(angle)
        angle += angle_increment
        add_child(muzzle)