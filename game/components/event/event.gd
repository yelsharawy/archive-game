extends Node2D

@export var event_name: StringName = &"NAME_ME"
@export var data: Dictionary

func happen() -> void:
	assert(event_name != &"NAME_ME", "please name this event IN THE EDITOR NOT IN THIS SCRIPT")
	Events.record_event(event_name, data)
