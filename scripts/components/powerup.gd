extends Area3D
class_name PowerUp

enum PowerUpType {
    PRIMARY_WEAPON,
    SECONDARY_WEAPON
}

@export var powerup_type : PowerUpType = PowerUpType.PRIMARY_WEAPON
@export var weapon_type : Weapon.WeaponType

@export var materials : Dictionary[Weapon.WeaponType, Resource] = {}
@export var texts : Dictionary[Weapon.WeaponType, String] = {}

@onready var body : MeshInstance3D = $Body
@onready var letters : Node3D = $Body/Letters

var on_moving_element : bool = false

func _ready() -> void:
    body.set_surface_override_material(0, materials[weapon_type])
    for letter : MeshInstance3D in letters.get_children():
        letter.mesh.text = texts[weapon_type]

    if powerup_type == PowerUpType.SECONDARY_WEAPON:
        body.scale *= 0.75
        $CollisionShape3D.shape.size *= 0.75

    if Globals.game_mode == Globals.GameMode.GALAGA:
        body.rotate_x(-PI / 2)

    if on_moving_element:
        body.scale *= 2.0
        $CollisionShape3D.shape.size *= 2.0

func _process(delta: float) -> void:
        if !on_moving_element:
            rotate_z(-PI * 0.5 * delta)
            position.z += Globals.scroll_speed * delta
        else:
            rotate_y(-PI * 0.5 * delta)
