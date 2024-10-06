extends Node

signal scene_switched()

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

var _known_scenes: Dictionary
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
		# pause the current scene
		_current_scene.process_mode = Node.PROCESS_MODE_DISABLED
		# make current scene invisble
		if _current_scene is Node2D:
			_current_scene.visible = false
		elif _current_scene is Control:
			_current_scene.visible = false

	if _known_scenes.has(new_scene):
		var cached_scene: Node = _known_scenes[new_scene]

		cached_scene.process_mode = Node.PROCESS_MODE_INHERIT
		if cached_scene is Node2D:
			cached_scene.visible = true
		elif cached_scene is Control:
			cached_scene.visible = true

		_current_scene = cached_scene
	else:
		_current_scene = new_scene.instantiate()
		# cache the created node version of the scene for later
		_known_scenes[new_scene] = _current_scene
		if game_root:
			game_root.add_child(_current_scene)
		else:
			# running game solo, "game_root" is just scene root
			get_tree().root.add_child(_current_scene)
	scene_switched.emit()

func _reparent_autoload(autoload: Node) -> void:
	if not autoload.get_parent():
		game_root.add_child(autoload)
	else:
		autoload.reparent(game_root, false)

func _ready() -> void:
	texture_button.pressed.connect(func() -> void:
		pop()
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

func pop() -> void:
	assert(_current_scene == _known_scenes[_stack.back()])
	_stack.pop_back()
	assert(not _stack.is_empty())
	switch_scene(_stack.back())
