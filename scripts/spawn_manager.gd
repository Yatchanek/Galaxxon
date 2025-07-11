extends Node3D
class_name SpawnManager

@onready var wave_spawner : WaveSpawner = $WaveSpawner
@onready var enemy_path : EnemyPath = $EnemyPath

var total_waves : int = 5
var current_wave : int = 0