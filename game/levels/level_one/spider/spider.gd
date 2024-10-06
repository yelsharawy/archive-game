extends Node2D

@export var lines: Array[String]

@onready var spider_npc: Sprite2D = $SpiderSprite
@onready var spiders_item: Item = $Item

func interacted() -> void:
	if Inventory.is_item_active(&"potion_spider"):
		spider_npc.visible = false
		spiders_item.visible = true
		Inventory.place_down(self) # put the potion spider here
		Inventory.pick_up(spiders_item)
		# hide the potion spider
		for child in get_children():
			if child is Item:
				child.visible = false
		return

	DialogueDisplay.npc_remark("big spider", lines.pick_random())
