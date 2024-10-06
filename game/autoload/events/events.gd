extends Node

var _events: Dictionary

func record_event(event_name: StringName, data: Dictionary) -> void:
	_events[event_name] = data

func get_event(event_name: StringName) -> Dictionary:
	return _events[event_name]

func has_event_happened(event_name: StringName) -> bool:
	return _events.has(event_name)
