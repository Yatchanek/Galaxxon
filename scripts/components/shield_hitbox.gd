extends HitBox
class_name ShieldHitBox


func _on_area_entered(area:Area3D) -> void:
	if area is HurtBox:
		if area.switched_off:
			return
		if area.instadeath:
			actor.take_damage(1000000)
		else:
			var dir : Vector3 = area.global_position.direction_to(actor.global_position)
			actor.take_damage(area.damage, dir)

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