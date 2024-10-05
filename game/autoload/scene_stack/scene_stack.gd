extends Node

var _stack: Array[PackedScene]

@onready var texture_button: TextureButton = $TextureButton


var game_root: Node
var _current_scene: Node = null

func switch_scene(new_scene: PackedScene) -> void:
	if _current_scene:
		game_root.remove_child(_current_scene)
	_current_scene = new_scene.instantiate()
	game_root.add_child(_current_scene)

func _ready() -> void:
	texture_button.pressed.connect(func() -> void:
		if _stack.is_empty():
			return
		_stack.pop_back()
		
		switch_scene(_stack.back())
		
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
	
	switch_scene(new)

func is_root() -> bool:
	return _stack.is_empty()

func pop() -> void:
	_stack.pop_back()
	if is_root():
		return
	
	switch_scene(_stack.back())
