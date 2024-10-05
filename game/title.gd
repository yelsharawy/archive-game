extends Control

@onready var button: Button = $CenterContainer/VBoxContainer/Button
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

@export var level_select: PackedScene

func _ready() -> void:
	button.pressed.connect(func() -> void:
		get_tree().change_scene_to_packed(level_select)
		)
	quit_button.pressed.connect(func() -> void:
		get_tree().quit()
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
