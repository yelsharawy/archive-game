extends Sprite2D


func interacted() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_rotation_degrees", 125, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
