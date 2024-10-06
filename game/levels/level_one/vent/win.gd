extends Node2D

func win() -> void:
	await get_tree().create_timer(3).timeout
	Comments.post(Comments.create(0, "game sucks, you can't win...", "user2348972374"))
