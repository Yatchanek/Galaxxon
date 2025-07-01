extends CannonWeapon
class_name VulcanCannon

var angle : float = 0.0

var max_offset : float = 1.0

func _ready() -> void:
	super()
	if is_subweapon:
		max_offset = 0.5

func _process(delta: float) -> void:
	super(delta)
	angle += 2 * TAU * delta
	position.x = sin(angle) * max_offset


func set_muzzles():
	var muzzle : Marker3D = Marker3D.new()
	add_child(muzzle)
	bullet_power = power_level
