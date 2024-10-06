extends Node2D

signal correct_pin_entered()
signal button_pressed()

@export var pin: String = "1234"

@onready var label: Label = $Label

func _ready() -> void:
	for child in get_children():
		if not child is Interactable:
			continue
		if not child.name.begins_with("Interactable"):
			push_warning("weird names for safe door buttons: ", child.name)
			continue
		var suffix := child.name.trim_prefix("Interactable")
		if suffix.is_valid_int():
			var idx := suffix.to_int()
			child.clicked.connect(func() -> void:
				button_pressed.emit()
				if label.text.length() < 4:
					label.text += str(idx)
					if label.text.length() == 4:
						_check_valid()
				)
		elif suffix == "Clear":
			child.clicked.connect(func() -> void:
				button_pressed.emit()
				label.text = ""
				)
		else:
			push_warning("weird name for safe door button: ", child.name)

func _check_valid() -> void:
	if label.text == pin:
		correct_pin_entered.emit()
		# disable all buttons
		for child in get_children():
			if child is Interactable:
				child.visible = false
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale:x", 0, 0.5).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(func() -> void: visible = false)
	else:
		label.text = ""
