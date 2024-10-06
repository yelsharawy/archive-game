extends Control

@onready var button: Button = $CenterContainer/VBoxContainer/Button
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

@export var level_select: PackedScene

func _ready() -> void:
	button.pressed.connect(func() -> void:
		get_parent().add_child(level_select.instantiate())
		queue_free()
	)

	var move_index := func() -> void:
		get_parent().move_child(self, get_parent().get_child_count() - 1)

	move_index.call_deferred()
