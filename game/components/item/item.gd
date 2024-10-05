class_name Item
extends Node2D

@export var interactable: Interactable

func _ready() -> void:
	interactable.clicked.connect(func() -> void:
		Inventory.pick_up(self))
