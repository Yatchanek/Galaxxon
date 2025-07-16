extends Area3D
class_name PowerUp

enum PowerUpType {
	PRIMARY_WEAPON,
	SECONDARY_WEAPON,
	HEALTH,
	SHIELD
}


@export var powerup_type : PowerUpType = PowerUpType.PRIMARY_WEAPON
@export var weapon_type : Enums.WeaponType

@export var weapon_materials : Dictionary[Enums.WeaponType, Resource] = {}
@export var weapon_texts : Dictionary[Enums.WeaponType, String] = {}
@export var other_materials : Dictionary[PowerUpType, Resource] = {}
@export var other_texts : Dictionary[PowerUpType, String] = {}

@onready var body : MeshInstance3D = $Body
@onready var letters : Node3D = $Body/Letters

var on_moving_element : bool = false

func _ready() -> void:
	if powerup_type <= PowerUpType.SECONDARY_WEAPON:	
		body.set_surface_override_material(0, weapon_materials[weapon_type])
		set_letters(weapon_texts[weapon_type])

	else:
		body.set_surface_override_material(0, other_materials[powerup_type])
		set_letters(other_texts[powerup_type])


	if powerup_type == PowerUpType.SECONDARY_WEAPON:
		body.scale *= 0.75
		$CollisionShape3D.shape.size *= 0.75

	if Globals.game_mode == Globals.GameMode.GALAGA:
		body.rotate_x(-PI / 2)

	if on_moving_element:
		body.scale *= 1.25
		$CollisionShape3D.shape.size *= 1.25


func set_letters(text : String):
	for letter : MeshInstance3D in letters.get_children(): 
		letter.mesh.text = text

func _process(delta: float) -> void:
		if !on_moving_element:
			rotate_z(-PI * 0.5 * delta)
			position.z += Globals.scroll_speed * delta
		else:
			rotate_y(-PI * 0.5 * delta)
