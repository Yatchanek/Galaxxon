extends CannonWeapon

func set_muzzles():
	for muzzle in get_children():
			muzzle.queue_free()
	var muzzle : Marker3D = Marker3D.new()
	add_child(muzzle)
	var interval : float = 2.5
	for i : int in wrapi((power_level - 1), 0, 3) * 2:
		muzzle = Marker3D.new()
		if i >= 2:
			interval = 2.0
		muzzle.position.x = ((i / 2) + 1) * interval * pow(-1, i)
		muzzle.position.z = ((i / 2) + 1) * 0.75
		add_child(muzzle)

	bullet_power = (power_level - 1) / 3 + 1

func shoot():
	if disabled:
		return
	can_shoot = false
	for muzzle : Marker3D in get_children():
		BulletPool.release_from_pool(muzzle, is_player_weapon, bullet_power, bullet_type, bullet_speed, muzzle.get_index() > 0)