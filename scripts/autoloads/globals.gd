extends Node
class_name Globals

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

static var game_mode : GameMode = GameMode.GALAGA
static var scroll_speed : float = 5.0

static var player : Player