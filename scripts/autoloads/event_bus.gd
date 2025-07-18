extends Node

signal enemy_hit(enemy : Node3D, damage : float)
signal enemy_destroyed(enemy: Enemy)
signal path_enemy_exited()
signal building_destroyed(building : Node3D)
signal score_changed(score : int)
signal player_hp_changed(value : float)
signal shield_hp_changed(value : float)
signal boss_entered
signal boss_health_changed(value : float)
signal mega_bomb_exploded(pos : Vector3)
signal boss_defeated
signal player_died

signal waves_ended

var player : Player