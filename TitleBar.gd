extends Control

var following = false
var dragging_start_position: Vector2i

var set_unmax_pos = false
var unmaximized_pos: Vector2i

func close() -> void:
	get_tree().quit()

func minimize() -> void:
	get_window().mode = Window.MODE_MINIMIZED

func toggle_fullscreen() -> void:
	var window = get_window()
	if window.mode == Window.MODE_WINDOWED:
		unmaximized_pos = window.position
		window.mode = Window.MODE_MAXIMIZED
	else:
		window.mode = Window.MODE_WINDOWED
		set_unmax_pos = true

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.double_click:
			toggle_fullscreen()
			return
		if event.get_button_index() == 1:
			following = !following
			dragging_start_position = Vector2i(event.global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var window = get_window()
	if set_unmax_pos:
		if window.position != Vector2i.ZERO:
			set_unmax_pos = false
		else:
			window.position = unmaximized_pos
		return
	if following:
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			following = false
			return
		var delPos = Vector2i(get_global_mouse_position()) - dragging_start_position
		window.position += Vector2i(delPos)
