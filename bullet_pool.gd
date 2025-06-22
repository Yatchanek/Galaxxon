extends Node3D

@export var bullet_scene : PackedScene

var pool : Array[Bullet] = []

@export var bullet_count : int = 20


func _ready() -> void:
	for i in bullet_count:
		var bullet : Bullet = bullet_scene.instantiate()
		return_to_pool(bullet)
		add_child.call_deferred(bullet)


func release_from_pool(spawning_spot : Marker3D, for_player : bool = false):
	if pool.is_empty():
		return
	var bullet : Bullet = pool.pop_back()
	bullet.global_transform = spawning_spot.global_transform
	bullet.visible = true
	bullet.adjust_collision(for_player)
	bullet.start()

func return_to_pool(bullet : Bullet):
	bullet.stop()
	bullet.visible = false
	bullet.position = Vector3(0, 10, 0)
	pool.append(bullet)
		
