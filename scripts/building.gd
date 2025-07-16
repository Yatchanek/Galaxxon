extends Node3D
class_name Building

@onready var body_parts : Node3D = $BodyParts

@onready var hitbox : HitBox = $Hitbox
@onready var hurtbox : HurtBox = $Hurtbox

@export var hp : float = 20
@export var score_value : int = 100

var body_colors : Array[Color] = []
var can_blink : bool = true

var carries_powerup : bool = false
var powerup_type : PowerUp.PowerUpType = PowerUp.PowerUpType.PRIMARY_WEAPON
var powerup_weapon_type : Enums.WeaponType = Enums.WeaponType.PULSE_CANNON

func _ready() -> void:
	carries_powerup = Globals.POWERUP_RNG.randf() < 0.175
	if carries_powerup:
		set_powerup()
	for body_part : MeshInstance3D in body_parts.get_children():
		body_colors.append(body_part.get_surface_override_material(0).albedo_color)


func set_powerup():
	var roll : float = Globals.POWERUP_RNG.randf()
	if roll < 0.4:
		powerup_type = PowerUp.PowerUpType.PRIMARY_WEAPON
	elif roll < 0.75:
		powerup_type = PowerUp.PowerUpType.SECONDARY_WEAPON
	elif roll < 0.9:
		powerup_type = PowerUp.PowerUpType.HEALTH
	else:
		powerup_type = PowerUp.PowerUpType.SHIELD

	if powerup_type <= PowerUp.PowerUpType.SECONDARY_WEAPON:	
		powerup_weapon_type = Globals.POWERUP_RNG.randi_range(Enums.WeaponType.PULSE_CANNON, Enums.WeaponType.SONIC_CANNON) as Enums.WeaponType


func take_damage(amount : float):
	hp -= amount
	if is_instance_valid(self):
		EventBus.enemy_hit.emit(self, amount)
	if hp <= 0:
		die()
	else:
		blink()

func blink():
	if !can_blink:
		return
	for i in body_parts.get_child_count():
		var body_part : MeshInstance3D = body_parts.get_child(i)
		var tw : Tween = create_tween()
		tw.tween_property(body_part.get_surface_override_material(0), "albedo_color", Color.WHITE, 0.05)
		tw.tween_property(body_part.get_surface_override_material(0), "albedo_color", body_colors[i], 0.05)
		if i == body_parts.get_child_count() - 1:
			tw.finished.connect(func(): can_blink = true)

func die():
	EventBus.building_destroyed.emit(self, get_parent())
	set_process(false)
	hurtbox.disable()
	hitbox.disable()
	queue_free()


func _on_visible_on_screen_notifier_3d_screen_exited():
	if global_position.z > 0:
		queue_free()