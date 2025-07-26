extends Resource
class_name EnemyData

@export var enemy_type : Enums.EnemyType
@export var spawn_chance : float = 0.1
@export var min_stage : int = 1
@export var min_amount : int = 1
@export var max_amount : int = 1
@export var spawn_frequency : float = 1.0
@export var min_turn_threshold : int = -20
@export var max_turn_threshold : int = -10
@export var base_hp : int = 10