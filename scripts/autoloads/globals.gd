extends Node
class_name Globals

enum GameMode {
    GALAGA,
    ZAXXON
}

static var game_mode : GameMode = GameMode.GALAGA
static var scroll_speed : float = 5.0