extends Node

enum GameMode {
    GALAGA,
    ZAXXON
}

enum EnemyType {
	BASIC_ENEMY,
	DIAGONAL_ENEMY,
	SHOOTING_ENEMY,
	AIMING_ENEMY,
    BASIC_PATH_ENEMY,
    FIRST_BOSS,
}

var enemy_data : Dictionary[EnemyType, Dictionary] = {
    EnemyType.BASIC_ENEMY : {
        "first_spawn": 1,
        "weight" : 0.5,
    },
    EnemyType.DIAGONAL_ENEMY : {
        "first_spawn": 1,
        "weight" : 0.25, 
    },
    EnemyType.SHOOTING_ENEMY : {
        "first_spawn": 3,
        "weight" : 0.1, 
    },  
    EnemyType.AIMING_ENEMY : {
        "first_spawn": 5,
        "weight" : 0.075, 
    }, 
    EnemyType.BASIC_PATH_ENEMY : {
        "first_spawn": 4,
        "weight" : 0.2, 
    },     
}


var game_mode : GameMode = GameMode.GALAGA
var scroll_speed : float = 5.0

var player : Player

var RNG : RandomNumberGenerator
var POWERUP_RNG : RandomNumberGenerator

func _ready() -> void:
    RNG = RandomNumberGenerator.new()
    POWERUP_RNG = RandomNumberGenerator.new()
    RNG.seed = 1357908
    POWERUP_RNG.seed = 9753124


func reset_rng():
    RNG.seed = 1357908
    POWERUP_RNG.seed = 9753124   