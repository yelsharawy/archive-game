class_name Responses
extends Resource

@export var missing_required_responses: PackedStringArray = ["I need something to use this..."]
@export var wrong_item_responses: PackedStringArray = ["That won't work here..."]

## dictionary of item names -> responses. this message will only appear for items which
## are not the correct item for this interactable. Used empty string &"" for the player
## using an empty hand.
## A response should be a dictionary with two items: npc_name, and remark. This is the NPC name and
## what they have to say.
## Alternatively, a response can be just a string for a player remark
@export var special_item_responses: Dictionary = {
	&"example_item": { npc_name = "ghost", remark = "What?" },
	&"example_item_two": "I don't know about using that here..."
}
