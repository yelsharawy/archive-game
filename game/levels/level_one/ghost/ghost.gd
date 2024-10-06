extends Node2D

@export var npc_name := "ghost"

@export var lines: Array[String]

@export var lines_has_anvil: Array[String]

@export var lines_has_crowbar: Array[String]

var _commented := false

func speak() -> void:
	var possible_lines: Array[String]
	if Inventory.has_item(&"anvil"):
		possible_lines.append_array(lines_has_anvil)
	if Inventory.has_item(&"crowbar") and not Events.has_event_happened(&"moved_shelf"):
		if _commented:
			return
		Comments.post(Comments.create(0, lines_has_crowbar.pick_random(), "user8237490234"))
		DialogueDisplay.npc_remark(npc_name, "---------")
		_commented = true
		return
	if possible_lines.is_empty():
		possible_lines = lines

	var line: String = possible_lines.pick_random()
	DialogueDisplay.npc_remark(npc_name, line)
