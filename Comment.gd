class_name Comment
extends Resource

@export var depth: int:
	set(value):
		depth = value
		changed.emit()
@export_multiline var content: String:
	set(value):
		content = value
		changed.emit()
@export var username: String:
	set(value):
		username = value
		changed.emit()
