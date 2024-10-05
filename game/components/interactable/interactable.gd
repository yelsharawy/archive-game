class_name Interactable
extends Node2D

signal hovered()
signal unhovered()
signal clicked()

@export var _required_item: StringName = &""

# NOTE: accessed by the Inventory if this Interactable is used on an Item.
# the inventory will change the click area's z index to be on top of everything else
var click_area: Area2D

var _is_hovered: bool = false

## Whether the mouse is hovering over this item
var is_hovered: bool:
	get:
		return _is_hovered

func _ready() -> void:
	click_area = ComponentUtil.get_one_child_of_type(self, Area2D)

	click_area.input_event.connect(area_input)
	click_area.mouse_entered.connect(func():
		hovered.emit()
		_is_hovered = true)
	click_area.mouse_exited.connect(func():
		unhovered.emit()
		_is_hovered = false)

func area_input(viewport: Node, ev: InputEvent, shape: int) -> void:
	if Inventory.is_item_active(_required_item) and ev.is_action_pressed(&"mouse_click_primary"):
		clicked.emit()
