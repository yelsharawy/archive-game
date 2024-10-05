extends Control

@export var button_parent: Control
@export var level_scenes: Array[PackedScene]

func _ready() -> void:
	var idx := 0
	for button in button_parent.get_children():
		var b := button as Button
		if not b:
			push_warning("non button child of button parent in level select")

		b.pressed.connect(func() -> void:
			SceneStack.push(level_scenes[idx])
			)
		idx += 1
