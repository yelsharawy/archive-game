extends Button

@export var text_edit: TextEdit

func post_comment() -> void:
	var text = text_edit.text
	if text:
		Comments.post(Comments.create(0,text,"the_player_42"))
		text_edit.clear()
