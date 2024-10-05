extends Node

var _stack: Array[PackedScene]

func push(new: PackedScene) -> void:
	if not is_instance_valid(new):
		push_error("Invalid scene passed to SceneStack")
		return
	_stack.append(new)
	get_tree().current_scene = new.instantiate()

func is_root() -> bool:
	return _stack.is_empty()

func pop() -> void:
	_stack.pop_back()
	if is_root():
		return
	get_tree().current_scene = _stack.back().instantiate
