class_name Item
extends Node2D

@export var id: StringName = &"NAME_ME"

var click_area: Area2D
var sprite: Sprite2D

## Called by the Inventory when a player tries to put the active
## item down on something
## TODO: move this to Inventory
func _place_in_world(new_parent: Node, keep_transform: bool) -> void:
	click_area.visible = true
	reparent(new_parent, keep_transform)

func _ready() -> void:
	if not click_area:
		click_area = ComponentUtil.get_one_child_of_type(self, Area2D)
	if not sprite:
		sprite = ComponentUtil.get_one_child_of_type(self, Sprite2D)

	click_area.input_event.connect(_area_input)

func _area_input(_viewport: Node, ev: InputEvent, _shape: int) -> void:
	if ev.is_action_pressed(&"mouse_click_primary"):
		# let the inventory handle the behavior of clicking an item
		Inventory._item_clicked(self)
