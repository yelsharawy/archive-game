extends Node2D

@export var _interactable: Interactable
@export var _degrees_rotated: float = 125
@export var _animation_duration: float = 1

func _ready() -> void:
	if not _interactable:
		_interactable = ComponentUtil.get_one_child_of_type(self, Interactable)
	_interactable.clicked.connect(_rotate_down)

func _rotate_down() -> void:
	_interactable.clicked.disconnect(_rotate_down)

	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_rotation_degrees", _degrees_rotated, _animation_duration)
	tween.set_trans(Tween.TRANS_BOUNCE)
