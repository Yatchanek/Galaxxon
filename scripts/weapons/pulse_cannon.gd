extends CannonWeapon
class_name PulseCannon


var angle : float = 0.0


func set_muzzles():
	var muzzle_count : int = wrapi(power_level, 1, 4)
	for muzzle in get_children():
		muzzle.queue_free()

	var interval : float = 1.0
	if muzzle_count % 2 == 0:
		for i in muzzle_count:
			var muzzle : Marker3D = Marker3D.new()
			muzzle.position.x = -interval * 0.5 - interval * (muzzle_count / 2 - 1) + i * interval
			if muzzle_count > 2 and spread_fire:
				muzzle.rotate_y((muzzle_count / 2) * PI / 16 -  i * PI / 16)
			add_child(muzzle)
	else:
		for i in muzzle_count:
			var muzzle : Marker3D = Marker3D.new()
			muzzle.position.x = -interval * ((muzzle_count - 1) / 2) + i * interval
			if muzzle_count > 2 and spread_fire:
				muzzle.rotate_y(((muzzle_count - 1) / 2) * PI / 16 -  i * PI / 16)
			add_child(muzzle)	
	bullet_power = power_level / 4 + 1
