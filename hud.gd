extends Control
class_name HUD

@onready var score_label : Label = $ScoreLabel


func _ready() -> void:
    EventBus.score_changed.connect(_on_score_changed)


func _on_score_changed(score : int):
    score_label.text = "Score: %d" % score