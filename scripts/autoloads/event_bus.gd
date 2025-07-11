extends Node

signal enemy_hit(enemy : Node3D, damage : float)
signal enemy_destroyed(enemy: Enemy)
signal path_enemy_exited()
signal building_destroyed(building : Node3D)
signal score_changed(score : int)
signal player_hp_changed(value : float)
signal shield_hp_changed(value : float)
signal player_died

signal waves_ended

var player : Player