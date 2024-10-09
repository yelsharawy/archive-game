class_name Item
extends Node2D

## Fires whenever the item is picked up from the world.
signal picked_up()

@export var id: StringName = &"NAME_ME"

var clickable := false:
	get:
		return _click_area.visible
	set(value):
		_click_area.visible = value

var _click_area: Area2D
var _sprite: Sprite2D

func _ready() -> void:
	if not _click_area:
		_click_area = ComponentUtil.get_one_child_of_type(self, Area2D)
	if not _sprite:
		_sprite = ComponentUtil.get_one_child_of_type(self, Sprite2D)

	_click_area.input_event.connect(_area_input)

## Called by Inventory
func _emit_picked_up() -> void:
	picked_up.emit()

func _area_input(_viewport: Node, ev: InputEvent, _shape: int) -> void:
	if ev.is_action_pressed(&"mouse_click_primary"):
		# let the inventory handle the behavior of clicking an item
		# NOTE: not using a signal because i just. please can this be simple
		# and explicit
		Inventory._item_clicked(self)
