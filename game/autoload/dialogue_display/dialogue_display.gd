extends Control

@export var label: Label
@onready var reset_timer: Timer = $ResetTimer
@export var player_font_settings: LabelSettings
@export var npc_font_settings: LabelSettings

func _ready() -> void:
	SceneStack.register_game_autoload(self)
	label.text = ""
	reset_timer.one_shot = true
	reset_timer.timeout.connect(clear_display)
	SceneStack.scene_switched.connect(clear_display)

func clear_display() -> void:
	reset_timer.stop() # in case its called externally
	label.text = ""

func player_remark(remark: String, time: float = 2) -> void:
	label.text = remark
	label.label_settings = player_font_settings
	reset_timer.start(time)

func npc_remark(npc_name: String, remark: String, time: float = 2) -> void:
	label.text = npc_name + ": " + remark
	label.label_settings = npc_font_settings
	reset_timer.start(time)
