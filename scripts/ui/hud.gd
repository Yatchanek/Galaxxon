extends Control
class_name HUD

@onready var score_label : Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var health_bar : ProgressBar = $MarginContainer/VBoxContainer/HealthBar

func _ready() -> void:
    EventBus.score_changed.connect(_on_score_changed)
    EventBus.player_hp_changed.connect(_on_health_changed)

func _on_score_changed(score : int):
    score_label.text = "Score: %d" % score

func _on_health_changed(value : float):
    health_bar.value = value
    health_bar.modulate = Color.GREEN
    if value < 0.66:
        health_bar.modulate = Color.YELLOW
    if value < 0.33:
        health_bar.modulate = Color.RED