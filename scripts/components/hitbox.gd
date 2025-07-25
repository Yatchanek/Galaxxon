extends Area3D
class_name HitBox

@export var actor : Node3D

@onready var collision_shape : CollisionShape3D = $CollisionShape3D

var active_hurtboxes : Array[HurtBox] = []

var hurtbox_timers : Array[float] = []

func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	for i in hurtbox_timers.size():
		hurtbox_timers[i] += delta
		if hurtbox_timers[i] >= active_hurtboxes[i].damage_interval:
			hurtbox_timers[i] -= active_hurtboxes[i].damage_interval
			actor.take_damage(active_hurtboxes[i].damage)


func disable():
	collision_shape.set_deferred("disabled", true)


func enable():
	collision_shape.set_deferred("disabled", false)


func _on_area_entered(area:Area3D) -> void:
	if area is HurtBox:
		if area.switched_off:
			return
		if area.instadeath:
			actor.take_damage(1000000)
		else:
			actor.take_damage(area.damage)

		if area.actor is Projectile:
			area.destroy()

		if actor is Shield:
			if area.actor is Enemy or area.actor is PathEnemy:
				area.switched_off = true

		elif area.damage_type == HurtBox.DamageType.CONTINUOUS:
			active_hurtboxes.append(area)
			hurtbox_timers.append(0.0)
			set_process(true)


func _on_area_exited(area:Area3D) -> void:
	if area is HurtBox:
		if actor is Shield:
			if area.switched_off and is_instance_valid(area):
				area.switched_off = true
			
		elif area.damage_type == HurtBox.DamageType.CONTINUOUS:
			var idx : int = active_hurtboxes.find(area)
			active_hurtboxes.remove_at(idx)
			hurtbox_timers.remove_at(idx)
			if active_hurtboxes.is_empty():
				set_process(false)


func _on_body_entered(body:Node3D) -> void:
	if actor is Projectile:
		actor.return_to_pool()
	if actor is Player:
		actor.take_damage(999999)
