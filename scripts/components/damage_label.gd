extends Label
class_name DamageLabel

func _ready() -> void:
    var tw : Tween = create_tween()
    tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    tw.tween_property(self, "position:y", -80.0, 0.6).as_relative()
    tw.parallel().tween_property(self, "scale", Vector2(2.0, 2.0), 0.2)
    tw.parallel().tween_property(self, "scale", Vector2.ZERO, 0.4).set_delay(0.25)

    tw.finished.connect(queue_free)