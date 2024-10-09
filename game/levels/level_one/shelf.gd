extends Sprite2D

@export var movement: Vector2 = Vector2(30, 30)
@export var time: float = 2

signal shelf_began_moving()

func move_shelf() -> void:
	shelf_began_moving.emit()
	get_tree().create_tween().tween_property(self, "position", movement, time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
