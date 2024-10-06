extends Control

@export var label: Label
@onready var reset_timer: Timer = $ResetTimer

func _ready() -> void:
	label.text = ""
	reset_timer.one_shot = true
	reset_timer.timeout.connect(clear_display)
	SceneStack.scene_switched.connect(clear_display)

func clear_display() -> void:
	reset_timer.stop() # in case its called externally
	label.text = ""

func player_remark(remark: String, time: float = 2) -> void:
	label.text = remark
	reset_timer.start(time)
