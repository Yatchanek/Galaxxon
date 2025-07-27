extends Control
class_name HUD

@onready var score_label : Label = %ScoreLabel
@onready var health_bar : ProgressBar = %HealthBar
@onready var shield_bar : ProgressBar = %ShieldBar
@onready var boss_health_bar : ProgressBar = %BossHealthBar
@onready var mega_bombs_container : VBoxContainer = %MegaBombsContainer
@onready var stage_completed_label : Label = %StageCompletedLabel

var elapsed_time : float = 0.0

func _ready() -> void:
    EventBus.score_changed.connect(_on_score_changed)
    EventBus.player_hp_changed.connect(_on_health_changed)
    EventBus.shield_hp_changed.connect(_on_shield_changed)
    EventBus.boss_entered.connect(_on_boss_entered)
    EventBus.boss_health_changed.connect(_on_boss_health_changed)
    EventBus.boss_defeated.connect(_on_boss_defeated)
    EventBus.mega_bombs_changed.connect(_on_mega_bombs_changed)
    EventBus.stage_ended.connect(_on_stage_ended)

    set_process(false)

func _process(delta: float) -> void:
    elapsed_time += delta
    if elapsed_time >= 1.5:
        stage_completed_label.hide()
        elapsed_time = 0.0
        set_process(false)


func _on_mega_bombs_changed(amount: int):
    for i in mega_bombs_container.get_child_count():
        mega_bombs_container.get_child(i).visible = i < amount

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


func _on_stage_ended():
    stage_completed_label.show()
    set_process(true)