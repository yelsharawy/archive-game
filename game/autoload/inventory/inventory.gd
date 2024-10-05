extends Node

const TIME_TO_INVENTORY_TWEEN: float = 1

@export var _virtual_position_top: Node2D
@export var _virtual_position_bottom: Node2D
# all items will have a z-index bigger than this area
@export var _bottomost_clickable: Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var _items: Dictionary
var _active_item: Item
var _item_inventory_events: Dictionary
# the original z index of the items, by id. restored if the item gets placed back
# into the world
var _item_click_area_z_index: Dictionary
# dictionary mapping each item by id to its one tween
var _item_tween: Dictionary

func _ready() -> void:
	sprite_2d.visible = false
	SceneStack.register_game_autoload(self)

func set_visible(value: bool) -> void:
	sprite_2d.visible = value

## This is how items enter the inventory, adding an entry in all the dictionaries
## that track its original state
func pick_up(item: Item) -> void:
	assert(item.id != &"NAME_ME", "Name the item you just picked up please")
	if _items.has(item.id):
		push_error("Attempt to register item called ", item.id, " twice, ignoring second attempt")
		return

	# register new callback: now when this item is clicked, it becomes
	# active item and hovers around the cursor
	var new_clicked_event := func() -> void:
		assert(item != _active_item, "click event recieved for the item that was following mouse cursor")
		if _active_item:
			_active_item.interactable.visible = true
			_active_item.get_parent().reparent(_virtual_position_top, true)
		_active_item = item
		_active_item.get_parent().reparent(self, true)
		_active_item.interactable.visible = false
		_resolve_virtual_positions()
	# store callback so it can be de-registered later
	_item_inventory_events[item.id] = new_clicked_event
	item.interactable.clicked.connect(new_clicked_event)

	# reparent to the inventory and tween it into the new position
	var item_virtual_position = Node2D.new()
	_virtual_position_top.add_child(item_virtual_position)
	item.reparent(item_virtual_position, true)

	# store reference to the item for easy lookup in places like place_down
	_items[item.id] = item
	_item_click_area_z_index[item.id] = item.interactable.click_area.z_index
	# resolving virtual position after storing z index, since this function
	# will modify the z index
	_resolve_virtual_positions()

## This is the way that items leave the inventory, removing their entries from
## the item-original-state tracking dictionaries
func place_down(target: Node) -> void:
	if not _active_item:
		return
	var id = _active_item.id
	_active_item._place_in_world(target, true)
	_active_item.interactable.clicked.disconnect(_item_inventory_events[_active_item.id])
	_active_item.interactable.click_area.z_index = _item_click_area_z_index[_active_item.id]
	_item_inventory_events.erase(_active_item.id)
	_items.erase(_active_item.id)
	_item_click_area_z_index.erase(_active_item.id)
	var tween = _item_tween.get(_active_item.id)
	if tween:
		tween.kill()
		_item_tween.erase(_active_item.id)

## Check if an item is currently being held (appearing under the cursor)
func is_item_active(item: StringName) -> bool:
	return item.is_empty() or item == _active_item.id

func release_active_item() -> void:
	_active_item.interactable.visible = true
	_active_item.get_parent().reparent(_virtual_position_top, true)
	_active_item = null
	_resolve_virtual_positions()

## Take the items that should be in the inventory and correctly space them out
## called whenever a player removes or adds an item from the inventory bar
func _resolve_virtual_positions() -> void:
	var num_items = _virtual_position_top.get_child_count()

	var top_y = _virtual_position_top.global_position.y
	var bot_y = _virtual_position_bottom.global_position.y

	var spacing = (bot_y - top_y) / num_items

	for idx in num_items:
		var child: Node2D = _virtual_position_top.get_child(idx)
		var item := child.get_child(0) as Item
		var item_original_position := item.global_position
		child.position.x = 0
		child.position.y = idx * spacing
		assert(item, "_resolve_virtual_positions expects virtual positions to have one child: an item")
		item.interactable.click_area.z_index = _bottomost_clickable.z_index + idx + 1
		item.global_position = item_original_position
		_tween_item_to_zero(item)

func _tween_item_to_zero(item: Item) -> void:
	var tween = _item_tween.get(item.id)
	if tween:
		tween.kill()
	tween = create_tween()
	_item_tween[item.id] = tween
	tween.tween_property(item, "position", Vector2.ZERO, TIME_TO_INVENTORY_TWEEN)
	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)

func _input(event: InputEvent) -> void:
	if _active_item and event is InputEventMouseMotion:
		# move item without tweening when tracking the cursor
		_active_item.get_parent().global_position = event.global_position
