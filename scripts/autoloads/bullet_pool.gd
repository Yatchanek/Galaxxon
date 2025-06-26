extends Node3D

enum BulletType {
	BASIC_BULLET,
	ROCKET
}

@export var bullet_scenes : Dictionary[BulletType, PackedScene] = {}

var pool : Dictionary[BulletType, Array] = {}

@export var bullet_count : int = 20


func _ready() -> void:
	for i in bullet_count:
		for type : BulletType in bullet_scenes.keys():
			if !pool.has(type):
				pool[type] = []
			var projectile : Projectile = bullet_scenes[type].instantiate()
			projectile.type = type
			return_to_pool(projectile)
			add_child.call_deferred(projectile)



func release_from_pool(spawning_spot : Marker3D, for_player : bool = false, power_level : int = 1, bullet_type : BulletType = BulletType.BASIC_BULLET):
	if pool.is_empty():
		return
	var bullet : Projectile = pool[bullet_type].pop_back()
	bullet.global_transform = spawning_spot.global_transform
	bullet.visible = true
	bullet.power_level = power_level
	bullet.set_damage()
	bullet.adjust_collision(for_player)
	bullet.start()

func return_to_pool(bullet : Projectile):
	bullet.stop()
	bullet.visible = false
	bullet.position = Vector3(0, 0, 10)
	pool[bullet.type].append(bullet)
		
