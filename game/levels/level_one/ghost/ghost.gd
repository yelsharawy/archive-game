extends Node2D

@export var npc_name := "ghost"

@export var lines: Array[String]

@export var lines_has_anvil: Array[String]

@export var lines_has_crowbar: Array[String]

func speak() -> void:
	var possible_lines: Array[String]
	if Inventory.has_item(&"anvil"):
		possible_lines.append_array(lines_has_anvil)
	if Inventory.has_item(&"crowbar") and not Events.has_event_happened(&"moved_shelf"):
		possible_lines.append_array(lines_has_crowbar)
	if possible_lines.is_empty():
		possible_lines = lines

	var line: String = possible_lines.pick_random()
	DialogueDisplay.npc_remark(npc_name, line)
