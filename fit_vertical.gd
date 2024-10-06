@tool
extends Control

@export var update: bool:
	set(value):
		update_min_size()

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_min_size()

func update_min_size() -> void:
	var min_y = 0
	for child in get_children():
		if child is Control:
			min_y = max(min_y, child.get_combined_minimum_size().y)
	self.custom_minimum_size.y = min_y
