extends Node2D

@export var _degrees_rotated: float = 125
@export var _animation_duration: float = 1

func _rotate_down() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_rotation_degrees", _degrees_rotated, _animation_duration)
	tween.set_trans(Tween.TRANS_BOUNCE)
