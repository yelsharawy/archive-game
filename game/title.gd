extends Control

@onready var button: Button = $CenterContainer/VBoxContainer/Button
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

@export var level_select: PackedScene

func _ready() -> void:
	button.pressed.connect(func() -> void:
		get_parent().add_child(level_select.instantiate())
		queue_free()
	)
	quit_button.pressed.connect(func() -> void:
		get_tree().quit()
	)
