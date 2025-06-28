extends Node

signal enemy_destroyed(enemy: Enemy)
signal score_changed(score : int)
signal player_hp_changed(value : float)
signal player_died

var player : Player