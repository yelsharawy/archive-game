extends Node

signal posted(comment: Comment)

func post(comment: Comment) -> void:
	posted.emit(comment)

func create(depth: int, content: String, username: String) -> Comment:
	var result = Comment.new()
	result.resource_name = "New Comment"
	result.depth = depth
	result.content = content
	result.username = username
	return result
