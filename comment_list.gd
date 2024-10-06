@tool
extends VBoxContainer

var title_label: RichTextLabel:
	get:
		var parent = get_parent()
		if parent:
			return parent.find_child("CommentsTitle", false)
		else:
			return null
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

signal comment_added
var since_last_add: float = -INF

var default_comment_scene: PackedScene = load("res://default_comment.tscn")

@export var reload_children: bool:
	set(value):
		for comment in comments:
			if comment.changed.is_connected(generate_children):
				comment.changed.disconnect(generate_children)
			comment.changed.connect(generate_children)
		generate_children()

func add_new(comment: Comment) -> void:
	comments.append(comment)
	comment.changed.connect(generate_children)
	generate_children()
	comment_added.emit()
	since_last_add = 0

func format_label() -> void:
	if since_last_add <= 6:
		var result = '[b][font_size="30px"]Comments[/font_size][/b] (%d)' % comments.size()
		if fmod(since_last_add, 1.0) < 0.5:
			result = '[bgcolor="yellow"]' + result
		title_label.text = result

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
			content.append_text("\n— [color=blue][url]")
			content.add_text(comment.username)
		else:
			assert(false, "expected only child of comment to be RichTextLabel")
		self.add_child(node)
		#add_child(node,false,Node.INTERNAL_MODE_FRONT)


func _ready() -> void:
	Comments.posted.connect(add_new)

func _process(delta: float) -> void:
	since_last_add += delta
	format_label()
