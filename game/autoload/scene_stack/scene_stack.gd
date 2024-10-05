extends Node

var _stack: Array[PackedScene]

@onready var texture_button: TextureButton = $TextureButton

func _ready() -> void:
	texture_button.pressed.connect(func() -> void:
		if _stack.is_empty():
			return
		get_tree().change_scene_to_packed(_stack.back())
		_stack.pop_back()
		if _stack.size() <= 1:
			texture_button.visible = false
		)
	texture_button.visible = false

func push(new: PackedScene) -> void:
	if not is_instance_valid(new):
		push_error("Invalid scene passed to SceneStack")
		return

	if _stack.is_empty():
		Inventory.set_visible(true)
	elif _stack.size() >= 1:
		texture_button.visible = true
	_stack.append(new)
	get_tree().change_scene_to_packed(new)

func is_root() -> bool:
	return _stack.is_empty()

func pop() -> void:
	_stack.pop_back()
	if is_root():
		return
	get_tree().current_scene = _stack.back().instantiate
