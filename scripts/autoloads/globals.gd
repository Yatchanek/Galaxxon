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
}

var game_mode : GameMode = GameMode.GALAGA
var scroll_speed : float = 5.0

var player : Player

var RNG : RandomNumberGenerator
var POWERUP_RNG : RandomNumberGenerator

func _ready() -> void:
    RNG = RandomNumberGenerator.new()
    POWERUP_RNG = RandomNumberGenerator.new()
    RNG.seed = 05152065
    POWERUP_RNG.seed = 05152006