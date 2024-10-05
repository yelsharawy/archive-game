extends Node

var _stack: Array[PackedScene]

@onready var texture_button: TextureButton = $TextureButton

var game_root: Node:
	get:
		return game_root
	set(value):
		if game_root == value:
			return
		for node in _autoloads:
			_reparent_autoload.call_deferred(node)
		game_root = value

var _current_scene: Node = null

var _autoloads: Array[Node]

## Register an autoload that should be reparented to the game's virtual root node
func register_game_autoload(autoload: Node) -> void:
	assert(_autoloads.find(autoload) == -1,
		str("autoload already registered, this is untested but maybe fine.",
		" use dictionary instead of array?"))
	_autoloads.append(autoload)
	_reparent_autoload.call_deferred(autoload)

func switch_scene(new_scene: PackedScene) -> void:
	if _current_scene:
		game_root.remove_child(_current_scene)
	_current_scene = new_scene.instantiate()
	game_root.add_child(_current_scene)

func _reparent_autoload(autoload: Node) -> void:
	if not autoload.get_parent():
		game_root.add_child(autoload)
	else:
		autoload.reparent(game_root, false)

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
	register_game_autoload(self)

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
