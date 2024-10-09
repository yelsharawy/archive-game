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

var required_item: StringName:
	get:
		return _required_item

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
	# click failed
	Inventory.set_click_handled_good(true)

# load a custom item reply, or use fallback from responses.wrong_item_responses
func _play_bad_item_response() -> void:
	var custom_reply: Variant = responses.special_item_responses.get(Inventory.get_active_item(), null)
	if custom_reply is String:
		DialogueDisplay.player_remark(custom_reply)
	elif custom_reply is Dictionary:
		DialogueDisplay.npc_remark(custom_reply["npc_name"], custom_reply["remark"])
	else:
		DialogueDisplay.player_remark(_random_line(responses.wrong_item_responses))
	Inventory.set_click_handled_good(false)

func _play_random_missing_required_item_response() -> void:
	DialogueDisplay.player_remark(_random_line(responses.missing_required_responses))
	# if we respond with dialogue, we dont want the inventory also doing the generic "nothing there to use this item on" dialogue
	Inventory.set_click_handled_good(false)

func area_input(_viewport: Node, ev: InputEvent, _shape: int) -> void:
	if not _required_event.is_empty() and not Events.has_event_happened(_required_event):
		return

	if ev.is_action_pressed(&"mouse_click_primary"):
		if not _required_item.is_empty():
			var anyitem := _required_item == &"ANYITEM"
			if anyitem:
				if Inventory.is_any_item_active() or allow_emptyhand_if_required:
					Inventory.set_release_callback(_valid_click)
				else:
					# you need some item, any item
					Inventory.set_release_callback(_play_random_missing_required_item_response)
			else:
				if Inventory.is_item_active(_required_item):
					Inventory.set_release_callback(_valid_click)
				elif allow_emptyhand_if_required and not Inventory.is_any_item_active():
					Inventory.set_release_callback(_valid_click)
				else:
					Inventory.set_release_callback(_play_random_missing_required_item_response)
		else:
			# behavior when _required_item is blank. in this case, emptyhand is
			# required
			if Inventory.is_any_item_active():
				# you must use emptyhand, play the same responses as if you were
				# using the wrong item on something that does require an item.
				# TODO: custom responses for emptyhand interactables, like maybe
				# "I dont need anything special to use this" or "I need to use
				# my bare hands".
				Inventory.set_release_callback(_play_bad_item_response)
			else:
				Inventory.set_release_callback(_valid_click)
