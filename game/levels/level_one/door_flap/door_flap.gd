extends Node2D

# TODO: make animation play when this signal is emitted, place down door handle
signal correct_item_placed()

@export var place_location: Node2D

func _ready() -> void:
	assert(place_location.get_child_count() == 0, "no children under place location pls")

func interacted() -> void:
	# if theres already an item childed to it, dont place. could get fucked up 
	if place_location.get_child_count() == 0:
		if Inventory.is_item_active(&"spiders"):
			correct_item_placed.emit()
		Inventory.place_down(place_location)
