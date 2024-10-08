class_name Interactable
extends Node2D

## Fires if this object was clicked on while holding a valid item.
signal clicked()
## Fires if the user clicks on this and was holding nothing.
signal clicked_emptyhand()
## Fires if the user clicks on this with a valid item, but not if they pressed
## when holding nothing.
signal clicked_item()

@export var one_time_use := false
## If there is a required item, then this setting takes effect and allows either
## that item OR emptyhand. This is useful because scene portals will only
## activate if the user pressed with emptyhand, so you can have something on the
## clicked_item signal which will only fire if the user uses a 
@export var allow_emptyhand_if_required := false
## The required item ID, or ANYITEM if any item that is not emptyhand is needed
@export var _required_item: StringName = &""
@export var _required_event: StringName = &""
@export var responses: Responses

var _click_area: Area2D

func _ready() -> void:
	_click_area = ComponentUtil.get_one_child_of_type(self, Area2D)

	_click_area.input_event.connect(area_input)
	_click_area.mouse_entered.connect(_hovered)
	_click_area.mouse_exited.connect(_unhovered)

func _hovered() -> void:
	pass

func _unhovered() -> void:
	pass

func _random_line(a: Array[String]) -> String:
	assert(not a.is_empty())
	return a[randi_range(0, a.size() - 1)]

func _valid_click() -> void:
	# emit signals, propagating this info is our main job
	if not Inventory.is_any_item_active():
		clicked_emptyhand.emit()
	else:
		clicked_item.emit()
	clicked.emit()

	if one_time_use:
		_click_area.input_event.disconnect(area_input)

	# let the Inventory know that someone got the click so it can know when a
	# click failed. NOTE: not needed right now?
	Inventory.set_click_as_handled()

# load a custom item reply, or use fallback from responses.wrong_item_responses
func _play_bad_item_response() -> void:
	var custom_reply: Variant = responses.special_item_responses.get(Inventory.get_active_item(), null)
	if custom_reply is String:
		DialogueDisplay.player_remark(custom_reply)
	elif custom_reply is Dictionary:
		DialogueDisplay.npc_remark(custom_reply["npc_name"], custom_reply["remark"])
	else:
		DialogueDisplay.player_remark(_random_line(responses.wrong_item_responses))

func _play_random_missing_required_item_response() -> void:
	DialogueDisplay.player_remark(_random_line(responses.missing_required_responses))

func area_input(_viewport: Node, ev: InputEvent, _shape: int) -> void:
	if not _required_event.is_empty() and not Events.has_event_happened(_required_event):
		return

	if ev.is_action_pressed(&"mouse_click_primary"):
		var anyitem := _required_item == &"ANYITEM"

		# first case: we require a specific item
		if not _required_item.is_empty():

			# three possible ways this could match
			var valid_specific_item = not anyitem and Inventory.is_item_active(_required_item)
			var valid_anyitem = anyitem and Inventory.is_any_item_active()
			var valid_emptyhand = allow_emptyhand_if_required and not Inventory.is_any_item_active()

			if valid_specific_item or valid_anyitem or valid_emptyhand:
				_valid_click()

		# second case: some item is active, but its not a specific required item
		elif Inventory.is_any_item_active():
			_play_bad_item_response()

		# last case: no item is active
		else:
			_play_random_missing_required_item_response()
