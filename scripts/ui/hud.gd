extends Control
class_name HUD

@onready var score_label : Label = %ScoreLabel
@onready var health_bar : ProgressBar = %HealthBar
@onready var shield_bar : ProgressBar = %ShieldBar
@onready var boss_health_bar : ProgressBar = %BossHealthBar


func _ready() -> void:
    EventBus.score_changed.connect(_on_score_changed)
    EventBus.player_hp_changed.connect(_on_health_changed)
    EventBus.shield_hp_changed.connect(_on_shield_changed)
    EventBus.boss_entered.connect(_on_boss_entered)
    EventBus.boss_health_changed.connect(_on_boss_health_changed)
    EventBus.boss_defeated.connect(_on_boss_defeated)

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

func _on_boss_entered():
    boss_health_bar.value = 100
    boss_health_bar.show()

func _on_boss_health_changed(value : float):
    boss_health_bar.value = value


func _on_boss_defeated():
    boss_health_bar.hide()