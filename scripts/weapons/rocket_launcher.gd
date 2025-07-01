extends Weapon
class_name RocketLauncher


func upgrade():
	super()

func _process(delta: float) -> void:
	if is_player_weapon:
		if Input.is_action_pressed("ui_accept") and can_shoot:
			shoot()
	
	elif can_shoot: 
		shoot()

	if !can_shoot:
		elapsed_time += delta
		if elapsed_time >= fire_rate:
			can_shoot = true
			elapsed_time -= fire_rate


func shoot():
	can_shoot = false
	for muzzle : Marker3D in get_children():
		BulletPool.release_from_pool($Muzzle, is_player_weapon, power_level, BulletPool.BulletType.ROCKET, 60, is_subweapon)
