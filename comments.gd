@tool
extends VBoxContainer

@export var comments: Array[Comment]:
	set(value):
		comments.resize(value.size())
		comments = value
		for i in comments.size():
			if not comments[i]:
				comments[i] = Comment.new()
				comments[i].resource_name = "New Comment"
				comments[i].changed.connect(generate_children)
		generate_children()

var default_comment_scene: PackedScene = load("res://default_comment.tscn")

@export var reload_children: bool:
	set(value):
		for comment in comments:
			if comment.changed.is_connected(generate_children):
				comment.changed.disconnect(generate_children)
			comment.changed.connect(generate_children)
		generate_children()

func generate_children() -> void:
	for n in self.get_children():
		self.remove_child(n)
		n.queue_free()
	
	for comment in comments:
		var node = default_comment_scene.instantiate()
		if node is MarginContainer:
			node.add_theme_constant_override("margin_left", comment.depth * 20)
		else:
			assert(false, "expected comment to be MarginContainer")
		var content = node.get_child(0)
		if content is RichTextLabel:
			content.text = ""
			content.append_text(comment.content)
			content.append_text("\n— ")
			content.append_text(comment.username)
		else:
			assert(false, "expected only child of comment to be RichTextLabel")
		self.add_child(node)
		#add_child(node,false,Node.INTERNAL_MODE_FRONT)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#generate_children()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
