extends Node3D
class_name Player

enum SteeringMode {
	GALAGA,
	ZAXXON
}

enum ControllerType {
	KEYBOARD,
	MOUSE
}

const HORIZONTAL_SPEED : int = 40
const VERTICAL_SPEED : int = 40
const ACCELERATION : float = 100.0

@export var pulse_cannon_scene : PackedScene
@export var laser_weapon_scene : PackedScene
@export var vulcan_cannon_scene : PackedScene
@export var rocket_launcher_scene : PackedScene
@export var hitbox : HitBox

@export var weapon_scenes : Dictionary[Enums.WeaponType, PackedScene] = {}

@export var body_colors : Array[Color] = []

@export var world : World 
@export var steering_mode : SteeringMode = SteeringMode.GALAGA
@export var controller_type : ControllerType = ControllerType.KEYBOARD


@onready var body_pivot : Node3D = $BodyPivot
@onready var body : MeshInstance3D = $BodyPivot/Body
@onready var wings : MeshInstance3D = $BodyPivot/Wings
@onready var shoot_timer : Timer = $ShootTimer
@onready var main_weapon_slot : Node3D = $MainWeaponSlot
@onready var sub_weapon_slot_left : Node3D = $SecondaryWeaponSlots/Subslot
@onready var sub_weapon_slot_right : Node3D = $SecondaryWeaponSlots/Subslot2
@onready var shield : Shield = $Shield
@onready var mega_bomb_launch_spot : Marker3D = %MegaBombLaunchSpot

@onready var sub_weapon_slots : Array[Node3D] = [$SecondaryWeaponSlots/Subslot, $SecondaryWeaponSlots/Subslot2]

var velocity : Vector3 = Vector3.ZERO

var spread_fire : bool = true

var dead : bool = false

var current_weapon : Weapon
var secondary_weapon_left : Weapon
var secondary_weapon_right : Weapon

var last_sub_updated : int = 0

const max_hp : int = 200
var hp : float = 20

const max_mega_bombs : int = 3
var mega_bombs : int = 0

var controls_disabled : bool = false

var can_blink : bool = true

var rotation_quat : Quaternion

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		# if event.pressed and event.keycode == KEY_Q and !event.is_echo():
		# 	current_weapon.upgrade()
		# if event.pressed and event.keycode == KEY_Z and !event.is_echo():
		# 	if current_weapon is CannonWeapon:
		# 		current_weapon.change_spread()
		# if event.pressed and event.keycode == KEY_P:
		# 	current_weapon.queue_free()
		# 	if current_weapon is PulseCannon:
		# 		var new_weapon : LaserWeapon = laser_weapon_scene.instantiate()
		# 		main_weapon_slot.add_child(new_weapon)
		# 		current_weapon = new_weapon
		# 	elif current_weapon is LaserWeapon:
		# 		var new_weapon : VulcanCannon = vulcan_cannon_scene.instantiate()
		# 		main_weapon_slot.add_child(new_weapon)
		# 		current_weapon = new_weapon
		# 	elif current_weapon is VulcanCannon:
		# 		var new_weapon : RocketLauncher = rocket_launcher_scene.instantiate()
		# 		main_weapon_slot.add_child(new_weapon)
		# 		current_weapon = new_weapon
		# 	else:
		# 		var new_weapon : PulseCannon = pulse_cannon_scene.instantiate()
		# 		main_weapon_slot.add_child(new_weapon)
		# 		current_weapon = new_weapon


func _ready() -> void:
	rotation_quat = body_pivot.basis.get_rotation_quaternion()
	for surface : int in $BodyPivot/Body.get_surface_override_material_count():
		body_colors.append($BodyPivot/Body.get_surface_override_material(surface).albedo_color)
	current_weapon = main_weapon_slot.get_child(0)
	hp = max_hp
	EventBus.mega_bombs_changed.emit(mega_bombs)
	EventBus.player_hp_changed.emit(hp / max_hp * 100.0)
	EventBus.player = self
	Globals.player = self


func _physics_process(delta: float) -> void:
	if !controls_disabled:
		var direction : Vector2
		if steering_mode == SteeringMode.GALAGA:
			direction = Input.get_vector("left", "right", "forward", "backward")
		else:
			direction = Input.get_vector("left", "right", "up", "down")

		if direction.x != 0:
			velocity.x = move_toward(velocity.x, direction.x * HORIZONTAL_SPEED, ACCELERATION * delta)
			rotation_quat = Quaternion(Vector3.FORWARD, PI / 5 * direction.x)

		else:
			velocity.x = move_toward(velocity.x, direction.x * HORIZONTAL_SPEED, ACCELERATION * 3.0 * delta)
			rotation_quat = Quaternion(Vector3.FORWARD, 0)

		if direction.y != 0:
			if steering_mode == SteeringMode.GALAGA:
				velocity.z = move_toward(velocity.z, direction.y * VERTICAL_SPEED, ACCELERATION * delta)
			else:
				if position.y > 0 and position.y < 20:
					rotation_quat *= Quaternion(Vector3.RIGHT, PI / 16 * direction.y)
				
				velocity.y = move_toward(velocity.y, direction.y * VERTICAL_SPEED, ACCELERATION * delta)
		else:
			if steering_mode == SteeringMode.GALAGA:
				velocity.z = move_toward(velocity.z, 0, ACCELERATION * 3.0 * delta)
			else:
				velocity.y = move_toward(velocity.y, 0, ACCELERATION * 3.0 * delta)

		body_pivot.rotation = body_pivot.basis.get_rotation_quaternion().slerp(rotation_quat, 0.1).get_euler()
		position += velocity * delta
		position.x = clamp(position.x, -30, 30)
		position.z = clamp(position.z, -35, 0)
		position.y = clamp(position.y, 0, 20)


		if Input.is_action_just_pressed("megabomb"):
			launch_megabomb()

func disable():
	controls_disabled = true
	velocity = Vector3.ZERO
	current_weapon.disable()
	for slot : Node3D in sub_weapon_slots:
		if slot.get_child_count() > 0:
			var weapon : Weapon = slot.get_child(0)
			weapon.disable()

func enable():
	controls_disabled = false
	current_weapon.enable()
	for slot : Node3D in sub_weapon_slots:
		if slot.get_child_count() > 0:
			var weapon : Weapon = slot.get_child(0)
			weapon.enable()


func launch_megabomb():
	if mega_bombs <= 0:
		return
	else:
		mega_bombs -= 1
		BulletPool.release_from_pool(mega_bomb_launch_spot, true, 1, Enums.BulletType.MEGA_BOMB, 10, false)


func take_damage(amount : float):
	if dead:
		return
	hp -= amount
	EventBus.player_hp_changed.emit(hp / max_hp * 100.0)
	if hp <= 0:
		die()
	else:
		pass
		blink()

func blink():
	if !can_blink: 
		return
	for surface : int in $BodyPivot/Body.get_surface_override_material_count():
		var tw : Tween = create_tween()
		tw.tween_property($BodyPivot/Body.get_surface_override_material(surface), "albedo_color", Color.RED, 0.1)
		tw.tween_property($BodyPivot/Body.get_surface_override_material(surface), "albedo_color", body_colors[surface], 0.1)		


		tw.finished.connect(func(): can_blink = true)

func die():
	dead = true
	set_physics_process(false)
	hitbox.disable()
	EventBus.player_died.emit()

func _on_collector_area_entered(area: PowerUp) -> void:
	if area.powerup_type == PowerUp.PowerUpType.HEALTH:
		hp = min(hp + 50, max_hp)
		EventBus.player_hp_changed.emit(hp / max_hp * 100.0)

	elif area.powerup_type == PowerUp.PowerUpType.SHIELD:
		shield.recharge(25)

	elif area.powerup_type == PowerUp.PowerUpType.MEGA_BOMB:
		mega_bombs = clamp(mega_bombs + 1, 0, max_mega_bombs)
		EventBus.mega_bombs_changed.emit(mega_bombs)

	elif area.powerup_type == PowerUp.PowerUpType.PRIMARY_WEAPON:
		if area.weapon_type == current_weapon.type:
			current_weapon.upgrade()
		else:
			current_weapon.queue_free()
			var new_weapon : Weapon = weapon_scenes[area.weapon_type].instantiate()
			new_weapon.is_player_weapon = true
			current_weapon = new_weapon
			main_weapon_slot.add_child(new_weapon)
			
	else:
		if !secondary_weapon_left:
			var new_weapon : Weapon = weapon_scenes[area.weapon_type].instantiate()
			new_weapon.is_subweapon = true
			new_weapon.is_player_weapon = true
			sub_weapon_slot_left.add_child(new_weapon)
			secondary_weapon_left = new_weapon
		elif !secondary_weapon_right:
			var new_weapon : Weapon = weapon_scenes[area.weapon_type].instantiate()
			new_weapon.is_subweapon = true
			new_weapon.is_player_weapon = true
			sub_weapon_slot_right.add_child(new_weapon)
			secondary_weapon_right = new_weapon
		else:
			if area.weapon_type == secondary_weapon_left.type:
				secondary_weapon_left.upgrade()
			elif area.weapon_type == secondary_weapon_right.type:
				secondary_weapon_right.upgrade()
			else:
				var new_weapon : Weapon = weapon_scenes[area.weapon_type].instantiate()
				new_weapon.is_subweapon = true
				new_weapon.is_player_weapon = true
				if last_sub_updated % 2 == 0:
					secondary_weapon_left.queue_free()
					sub_weapon_slot_left.add_child(new_weapon)
					secondary_weapon_left = new_weapon
				else:
					secondary_weapon_right.queue_free()
					sub_weapon_slot_right.add_child(new_weapon)
					secondary_weapon_right = new_weapon

				last_sub_updated += 1	
	
	area.queue_free()

