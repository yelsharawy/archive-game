extends Button

@export var text_edit: TextEdit

func post_comment() -> void:
	if text_edit.text:
		Comments.post(Comments.create(0,text_edit.text,"the_player_42"))
		text_edit.clear()
