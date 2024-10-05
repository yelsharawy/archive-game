extends Node

func pick_up(item: Item) -> void:
	item.reparent(self, true)
