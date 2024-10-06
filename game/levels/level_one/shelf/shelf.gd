extends Node2D

func _ready() -> void:
	await get_tree().create_timer(3).timeout
	Comments.post(Comments.create(0, "crowbar sometimes doesnt work on the shelf?", "user2348972374"))
