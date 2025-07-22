extends Weapon
class_name CannonWeapon

@export var bullet_type : Enums.BulletType

func _ready() -> void:
	super()
	set_muzzles()

func upgrade():
	super()
	set_muzzles()

func set_spread(active : bool):
	spread_fire = active
	set_muzzles()


func set_muzzles():
	pass


func _process(delta: float) -> void:
	if is_player_weapon:
		if Input.is_action_pressed("fire") and can_shoot:
			shoot()
	elif can_shoot: 
		shoot()

	if !can_shoot:
		elapsed_time += delta
		if elapsed_time >= fire_rate:
			can_shoot = true
			elapsed_time -= fire_rate

func shoot():
	if disabled:
		return
	can_shoot = false
	for muzzle : Marker3D in get_children():
		BulletPool.release_from_pool(muzzle, is_player_weapon, bullet_power, bullet_type, bullet_speed, is_subweapon)