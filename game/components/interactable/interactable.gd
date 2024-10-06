class_name Interactable
extends Node2D

signal hovered()
signal unhovered()
signal clicked()
signal clicked_emptyhand()

@export var one_time_use := false
## &"ANYITEM" is a required item name that can be used by interactables to
## allow any item to be clicked.
## &"ANYITEM_OR_EMPTYHAND" is a required item name that can be used by
## interactables to make sure they always emit clicked, no matter what
## the player clicks on them with.
@export var _required_item: StringName = &""
@export var _required_event: StringName = &""
@export var responses: Responses

var _click_area: Area2D
var _is_hovered: bool = false
var _used := false

## Whether the mouse is hovering over this item
var is_hovered: bool:
	get:
		return _is_hovered

func _ready() -> void:
	_click_area = ComponentUtil.get_one_child_of_type(self, Area2D)

	_click_area.input_event.connect(area_input)
	_click_area.mouse_entered.connect(func():
		hovered.emit()
		_is_hovered = true)
	_click_area.mouse_exited.connect(func():
		unhovered.emit()
		_is_hovered = false)

func area_input(viewport: Node, ev: InputEvent, _shape: int) -> void:
	if one_time_use and _used:
		return
	if not _required_event.is_empty() and not Events.has_event_happened(_required_event):
		return
	if ev.is_action_pressed(&"mouse_click_primary"):
		if Inventory.is_item_active(_required_item):
			if not Inventory.is_any_item_active():
				clicked_emptyhand.emit()
			_used = true
			clicked.emit()
			viewport.set_input_as_handled()
		elif Inventory.is_any_item_active():
			var custom_reply: Variant = responses.special_item_responses.get(Inventory.get_active_item(), null)
			if custom_reply is String:
				DialogueDisplay.player_remark(custom_reply)
			elif custom_reply is Dictionary:
				DialogueDisplay.npc_remark(custom_reply["npc_name"], custom_reply["remark"])
			else:
				var response := responses.wrong_item_responses[randi_range(0, responses.wrong_item_responses.size() - 1)]
				DialogueDisplay.player_remark(response)
		else:
			DialogueDisplay.player_remark(responses.missing_required_responses[randi_range(0, responses.missing_required_responses.size() - 1)])
