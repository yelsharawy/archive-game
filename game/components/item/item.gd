class_name Item
extends Node2D

@export var interactable: Interactable
@export var id: StringName = &"NAME_ME"

## Called by the Inventory when a player tries to put the active
## item down on something
func _place_in_world(new_parent: Node, keep_transform: bool) -> void:
	interactable.clicked.connect(_pick_up)
	reparent(new_parent, keep_transform)

func _ready() -> void:
	interactable.clicked.connect(_pick_up)

func _pick_up() -> void:
	interactable.clicked.disconnect(_pick_up)
	Inventory.pick_up(self)
