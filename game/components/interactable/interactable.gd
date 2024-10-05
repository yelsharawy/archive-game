class_name Interactable
extends Node2D

signal hovered()
signal unhovered()
signal clicked()

var _click_area: Area2D

var _is_hovered: bool = false

## Whether the mouse is hovering over this item
var is_hovered: bool:
	get:
		return _is_hovered

func _ready() -> void:
	_click_area = ComponentUtil.get_one_child_of_type(self, Area2D)

	_click_area.input_event.connect(area_input)
	_click_area.mouse_entered.connect(func():
		hovered.emit()
		_is_hovered = true)
	_click_area.mouse_exited.connect(func():
		unhovered.emit()
		_is_hovered = false)

func area_input(viewport: Node, ev: InputEvent, shape: int) -> void:
	if ev.is_action_pressed(&"mouse_click_primary"):
		clicked.emit()
