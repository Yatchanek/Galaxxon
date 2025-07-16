extends Node3D


@export var bullet_scenes : Dictionary[Enums.BulletType, PackedScene] = {}

var pool : Dictionary[Enums.BulletType, Array] = {}

@export var bullet_count : Dictionary[Enums.BulletType, int] = {}


func _ready() -> void:
	for type : Enums.BulletType in bullet_scenes.keys():
		if !pool.has(type):
			pool[type] = []
		for i in bullet_count[type]:
			var projectile : Projectile = bullet_scenes[type].instantiate()
			projectile.type = type
			projectile.ready.connect(return_to_pool.bind(projectile))
			add_child.call_deferred(projectile)



func release_from_pool(spawning_spot : Marker3D, is_player_bullet : bool = false, power_level : int = 1, bullet_type : Enums.BulletType = Enums.BulletType.BASIC_BULLET, bullet_speed : int = 50, is_subweapon : bool = false):
	if pool[bullet_type].is_empty():
		return
	var bullet : Projectile = pool[bullet_type].pop_back()
	bullet.global_transform = spawning_spot.global_transform
	bullet.visible = true
	bullet.initialize(bullet_type, bullet_speed, power_level, is_player_bullet, is_subweapon)
	bullet.start()

func return_to_pool(bullet : Projectile):
	bullet.stop()
	bullet.visible = false
	bullet.position = Vector3(0, 0, 100)
	pool[bullet.type].append(bullet)
		

func collect_all():
	for bullet : Projectile in get_children():
		return_to_pool(bullet)