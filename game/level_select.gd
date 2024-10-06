extends Control

@export var button_parent: Control
@export var level_scenes: Array[PackedScene]

func _ready() -> void:
	
	# hack to make tihs scene go away1`
	SceneStack._current_scene = self
	
	var idx := 0
	for button in button_parent.get_children():
		var b := button as Button
		if not b:
			push_warning("non button child of button parent in level select")

		b.pressed.connect(func() -> void:
			SceneStack.push(level_scenes[idx])
			visible = false
			)
		idx += 1
