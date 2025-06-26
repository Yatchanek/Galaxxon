extends Weapon
class_name CannonWeapon

func _ready() -> void:
	set_muzzles()

func upgrade():
	super()
	set_muzzles()

func change_spread():
	spread_fire = !spread_fire
	set_muzzles()

func set_muzzles():
	for muzzle in get_children():
		muzzle.queue_free()
	var interval : float = 1.0
	var num_muzzles : int = wrapi(power_level, 1, 4)
	if num_muzzles % 2 == 0:
		for i in num_muzzles:
			var muzzle : Marker3D = Marker3D.new()
			muzzle.position.x = -interval * 0.5 - interval * (num_muzzles / 2 - 1) + i * interval
			if num_muzzles > 2 and spread_fire:
				muzzle.rotate_y((num_muzzles / 2) * PI / 16 -  i * PI / 16)
			add_child(muzzle)
	else:
		for i in num_muzzles:
			var muzzle : Marker3D = Marker3D.new()
			muzzle.position.x = -interval * ((num_muzzles - 1) / 2) + i * interval
			if num_muzzles > 2 and spread_fire:
				muzzle.rotate_y(((num_muzzles - 1) / 2) * PI / 16 -  i * PI / 16)
			add_child(muzzle)	

	bullet_power = power_level / 4 + 1

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
		BulletPool.release_from_pool(muzzle, is_player_weapon, bullet_power)
