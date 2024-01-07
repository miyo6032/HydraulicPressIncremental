extends Label

func _ready():
    var tween = create_tween()
    var random_pos = position + Vector2(randf_range(+200, +400), randf_range(-200, -400))
    tween.tween_property(self, "position", random_pos, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
    tween.tween_callback(queue_free)
