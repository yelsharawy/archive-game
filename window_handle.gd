extends Control

@export_range(-1,1) var size_scale_x: int
@export_range(-1,1) var size_scale_y: int
@export_range(0,1) var pos_scale_x: int
@export_range(0,1) var pos_scale_y: int

var dragging = false
var drag_start: Vector2i

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			dragging = !dragging
			drag_start = Vector2i(event.global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if dragging:
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			dragging = false
			return
		var window = get_window()
		var cursor_pos = Vector2i(get_global_mouse_position())
		var cursor_delta = cursor_pos - drag_start
		var size_delta = Vector2i(size_scale_x, size_scale_y) * cursor_delta
		var pos_delta = Vector2i(pos_scale_x, pos_scale_y) * cursor_delta
		
		window.size += size_delta
		window.position += pos_delta
		drag_start = cursor_pos - pos_delta
