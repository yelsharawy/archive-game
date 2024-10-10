extends Node2D

# dictionary of Input.CursorShape keys to dictionary values. each inner dictionary
# is the set of areas that want to be hovered
var _hovers_by_shape := {
	Input.CursorShape.CURSOR_ARROW: {}
}
# get the initial cursor shape of an area. in case its changed by the time we remove it
var _initial_shape_by_area := {}

#const CURSOR_POINTER = preload("res://assets/programmer/ui/cursor-pointer.png")
#const CURSOR_ARROW = preload("res://assets/programmer/ui/cursor-arrow.png")
#
#func _ready() -> void:
	#Input.set_custom_mouse_cursor(CURSOR_POINTER, Input.CURSOR_POINTING_HAND, Vector2(11, 5))
	#Input.set_custom_mouse_cursor(CURSOR_ARROW, Input.CURSOR_ARROW)

func cursor_display_always_pointer() -> Input.CursorShape:
	return Input.CursorShape.CURSOR_POINTING_HAND

func display_for_area(area: Area2D, get_cursor_shape := cursor_display_always_pointer) -> void:
	area.mouse_entered.connect(_on_interactable_hovered.bind(get_cursor_shape, area))
	area.mouse_exited.connect(_on_interactable_unhovered.bind(get_cursor_shape, area))
	# cover all of our bases
	area.tree_exited.connect(_on_interactable_unhovered.bind(get_cursor_shape, area))

func _evaluate_cursor() -> void:
	var cshape := Input.CURSOR_ARROW

	var test := PackedVector2Array()
	# vector2 comparison happens by comparing X first, then y.
	# in this case, x is the number of areas requesting that cursor type and
	# y is the numeric representation of the Input.CursorShape enum value
	for c: Input.CursorShape in _hovers_by_shape.keys():
		test.append(Vector2(_hovers_by_shape[c].size(), c))
	# sort so that each entry is [ # of areas, Input.Cursorshape ] in ascending
	# order of number of areas
	test.sort()

	var last := test[test.size() - 1]
	# sort only is used if the biggest item actually had some magnitude,
	# otherwise we arbitrarily sorted zeroes
	if last.x >= 1:
		cshape = (last.y as int) as Input.CursorShape

	Input.set_default_cursor_shape(cshape)

func _on_interactable_hovered(get_cursor_shape: Callable, area: Area2D) -> void:
	var cshape: Input.CursorShape = get_cursor_shape.call()
	if not _hovers_by_shape.has(cshape):
		_hovers_by_shape[cshape] = {}
	if _initial_shape_by_area.has(area):
		# this shape already registered, remove it from its original
		var initial_shape: Input.CursorShape = _initial_shape_by_area[area]
		assert(_hovers_by_shape.has(initial_shape) and _hovers_by_shape[initial_shape].has(area),
		"_initial_shape_by_area was not properly updated to match _hovers_by_shape")
		_hovers_by_shape[initial_shape].erase(area)
	_initial_shape_by_area[area] = cshape
	_hovers_by_shape[cshape][area] = true
	_evaluate_cursor()

func _on_interactable_unhovered(get_cursor_shape: Callable, area: Area2D) -> void:
	if not _initial_shape_by_area.has(area):
		# already removed
		return
	var cshape: Input.CursorShape = _initial_shape_by_area[area]
	_initial_shape_by_area.erase(area)
	_hovers_by_shape[cshape].erase(area)
	_evaluate_cursor()
