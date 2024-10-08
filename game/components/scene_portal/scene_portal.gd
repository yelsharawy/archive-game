## A node which has a clickable/hoverable area, and optionally a visual sprite.
## When clicked on, it pushes a new scene to the scene stack
class_name ScenePortal
extends Node2D

@export var scene: PackedScene
@export var interactable: Interactable

func _ready() -> void:
	if not interactable:
		interactable = ComponentUtil.get_one_child_of_type(self, Interactable)

	interactable.allow_emptyhand_if_required = true
	interactable.clicked_emptyhand.connect(func() -> void:
		SceneStack.push(scene))
