extends Control
class_name HUD

@onready var score_label : Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var health_bar : ProgressBar = %HealthBar
@onready var shield_bar : ProgressBar = %ShieldBar

func _ready() -> void:
    EventBus.score_changed.connect(_on_score_changed)
    EventBus.player_hp_changed.connect(_on_health_changed)
    EventBus.shield_hp_changed.connect(_on_shield_changed)
    print("HUD ready")

func _on_score_changed(score : int):
    score_label.text = "Score: %d" % score

func _on_shield_changed(value : float):
    shield_bar.value = value

func _on_health_changed(value : float):
    health_bar.value = value
    health_bar.modulate = Color.GREEN
    if value < 66.0:
        health_bar.modulate = Color.YELLOW
    if value < 33.0:
        health_bar.modulate = Color.RED