class_name Item
extends Node2D

var interactable: Interactable
var _sprite: Sprite2D
@export var id: StringName = &"NAME_ME"

## Called by the Inventory when a player tries to put the active
## item down on something
func _place_in_world(new_parent: Node, keep_transform: bool) -> void:
	interactable.clicked.connect(_pick_up)
	reparent(new_parent, keep_transform)

func _ready() -> void:
	if not interactable:
		interactable = ComponentUtil.get_one_child_of_type(self, Interactable)
	if not _sprite:
		_sprite = ComponentUtil.get_one_child_of_type(self, Sprite2D)
	# z index is modified from Inventory, but it only touches this Item's z index and assumes
	# that interactable and sprite will be children
	assert(interactable.z_index == z_index, "Different z index for item's area and sprite and root will cause unexpected behavior")
	assert(_sprite.z_index == z_index, "Different z index for item's area and sprite and root will cause unexpected behavior")
	interactable.clicked.connect(_pick_up)

func _pick_up() -> void:
	interactable.clicked.disconnect(_pick_up)
	Inventory.pick_up(self)
