class_name Interactable
extends Node2D

signal hovered()
signal unhovered()
signal clicked()

@export var one_time_use := false
@export var _required_item: StringName = &""
@export var missing_required_responses: PackedStringArray = ["I need something to use this..."]
@export var wrong_item_responses: PackedStringArray = ["That won't work here..."]

# NOTE: accessed by the Inventory if this Interactable is used on an Item.
# the inventory will change the click area's z index to be on top of everything else
var click_area: Area2D

var _is_hovered: bool = false

var _used := false

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

func area_input(viewport: Node, ev: InputEvent, _shape: int) -> void:
	if one_time_use and _used:
		return
	if ev.is_action_pressed(&"mouse_click_primary"):
		if Inventory.is_item_active(_required_item):
			if one_time_use:
				_used = true
			clicked.emit()
			viewport.set_input_as_handled()
		elif Inventory.is_any_item_active():
			DialogueDisplay.player_remark(wrong_item_responses[randi_range(0, wrong_item_responses.size() - 1)])
		else:
			DialogueDisplay.player_remark(missing_required_responses[randi_range(0, missing_required_responses.size() - 1)])
