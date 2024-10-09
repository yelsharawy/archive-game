extends Node

enum InputHandleType {
	UNHANDLED,
	WORLD_GOOD,
	WORLD_BAD,
	INVENTORY_ITEM_CLICKED,
}

const TIME_TO_INVENTORY_TWEEN: float = 0.1
const BAD_ITEM_REMARKS: Array[String] = [
	"No good.",
	"Nothing to that.",
	"Whatever.",
]

## Called whenever the user tries to use an item on something but it is not a
## valid item (using the crowbar on a NPC, for example). Not called until the
## button is released.
signal item_used_on_nothing(item: Item)
signal item_picked_up(item: Item)
## Called when an item is used on an Interactable, but it didn't meet those
## requirements.
signal bad_item_use(item: Item)
## Called whenever the player correctly uses and item on an Interactable
signal good_item_use(item: Item)

@export var _virtual_position_top: Node2D
@export var _virtual_position_bottom: Node2D
# all items will have a z-index bigger than this area
@export var _bottomost_clickable: Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var click_swallow_area: Area2D = $Sprite2D/ClickSwallowArea

var _items: Dictionary
var _active_item: Item
# the original z index of the items, by id. restored if the item gets placed back
# into the world
var _item_click_area_z_index: Dictionary
# dictionary mapping each item by id to its one tween
var _item_tween: Dictionary

# input state for left mouse click. needed so that we can catch the click
# happening at input start and then wait to see if anyone "used" the click
# at the end of the frame
var _click_input_handle_type := InputHandleType.UNHANDLED
var _click_release_callback: Callable:
	get:
		return _click_release_callback
	set(value):
		_click_release_callback = value

func _ready() -> void:
	sprite_2d.visible = false
	SceneStack.register_game_autoload(self)
	# keep ourselves at the bottom of the scene tree, so we get input before game
	SceneStack.scene_switched.connect(func() -> void:
		get_parent().move_child(self, get_parent().get_child_count())
		# always release on scene switch
		_release_active_item()
		)

	# always release active item after clicking
	# also provide some default dialogue if no interactable recieved the click
	item_used_on_nothing.connect(func(_item: Item) -> void:
		if _active_item:
			DialogueDisplay.player_remark(BAD_ITEM_REMARKS.pick_random())
		_release_active_item()
		)
	bad_item_use.connect(func(_item: Item) -> void:
		_release_active_item()
		)
	good_item_use.connect(func(_item: Item) -> void:
		_release_active_item()
		)

	item_picked_up.connect(func(_item: Item) -> void:
		$PickupSound.play()
		)

## Called from Interactable elements to declare a click as having been
## successful or not.
func set_click_handled_good(is_good: bool) -> void:
	if is_good:
		_click_input_handle_type = InputHandleType.WORLD_GOOD
	else:
		_click_input_handle_type = InputHandleType.WORLD_BAD

## Called from interactable elements to register a function to be called when
## the player releases their mouse. This function only persists for the current
## mouse click.
func set_release_callback(callback: Callable) -> void:
	if OS.is_debug_build() and not _click_release_callback.is_null():
		# BUG: some kind of horrible framerate dependent thing going on here.
		# in theory this should never happen, since we have sorting + etc on
		# for area2Ds, so only one should get input per given click. but sometimes
		# things will try to overwrite. sorting is a new feature, so maybe its
		# a bug?
		push_warning("Someone already got the click? idk but we're gonna overwrite. Sometimes this",
		" happens for no good reason. I think it's when you have to many clicks in quick succession?")
	_click_release_callback = callback

func set_visible(value: bool) -> void:
	sprite_2d.visible = value

func get_active_item() -> StringName:
	return _active_item.id if _active_item else &""

## This is how items enter the inventory, adding an entry in all the dictionaries
## that track its original state
func pick_up(item: Item) -> void:
	assert(item.id != &"NAME_ME", "Name the item you just picked up please")
	if _items.has(item.id):
		push_error("Attempt to register item called ", item.id, " twice, ignoring second attempt")
		return

	# reparent to the inventory, with a virtual position parent node2d
	var item_virtual_position = Node2D.new()
	_virtual_position_top.add_child(item_virtual_position)
	item.reparent(item_virtual_position, true)

	# store reference to the item for easy lookup in places like place_down
	_items[item.id] = item
	_item_click_area_z_index[item.id] = item.z_index
	# resolving virtual position after storing z index, since this function
	# will modify the z index
	_resolve_virtual_positions()
	# we emit and so does the item itself
	item_picked_up.emit(item)
	item._emit_picked_up()

## This is the way that items leave the inventory, removing their entries from
## the item-original-state tracking dictionaries
func place_down(target: Node) -> void:
	if not _active_item:
		return
	var id = _active_item.id
	# remove the virtual parent node2d that gets created when items enter the inventory
	_active_item.get_parent().queue_free()

	# reparent and reenable
	_active_item.clickable = true
	_active_item.reparent(target, true)

	# restore z index for the placed item
	_active_item.z_index = _item_click_area_z_index[_active_item.id]

	# erase cache (not erasing tween cuz i think I'd have to wait for it to be over?)
	_items.erase(_active_item.id)
	_item_click_area_z_index.erase(_active_item.id)

	_tween_item_to_zero(_active_item)
	_active_item = null

func has_item(item: StringName) -> bool:
	return _items.has(item)

## Check if an item is currently being held (appearing under the cursor)
## If item is &"" and there is no active item, this returns true
func is_item_active(item: StringName) -> bool:
	assert(item != &"ANYITEM_OR_EMPTYHAND") # these ids are both legacy, handled by Interactable now
	assert(item != &"ANYITEM")
	if not _active_item:
		return item.is_empty()
	else:
		return item == _active_item.id

## Check if there is an item active or not
func is_any_item_active() -> bool:
	return _active_item != null

## Called by items when they are clicked. Inventory handles what should happen
## at that point.
func _item_clicked(item: Item) -> void:
	assert(item != _active_item, "click event recieved for the item that was following mouse cursor")
	assert(_click_input_handle_type == InputHandleType.UNHANDLED,
		str("Somebody else handled this but didn't set the release callback? ",
		"Overwriting their set_click_handled_good call"))

	# check if the clicked item is one in the inventory
	if _items.has(item.id):
		assert(_items[item.id] == item, "multiple items with the same id detected")

		# if another item is active, we have to send it back into the
		# inventory. this is where crafting/combining would happen if we had
		# that
		if _active_item:
			_active_item.clickable = true
			_active_item.get_parent().reparent(_virtual_position_top, true)
			# NOTE: no need to animate/tween here, that is done by:
			# _resolve_virtual_positions

		# make the clicked inventory item become our new active item
		_active_item = item
		_active_item.get_parent().reparent(self, true)
		_active_item.clickable = false
		_resolve_virtual_positions()
	else:
		pick_up(item)

	_click_input_handle_type = InputHandleType.INVENTORY_ITEM_CLICKED

func _release_active_item() -> void:
	if not is_instance_valid(_active_item):
		return
	var item := _active_item
	var reenable = func() -> void:
		item.clickable = true
	_active_item.get_parent().reparent(_virtual_position_top, true)
	_active_item = null
	_resolve_virtual_positions()
	# wait for a bit before reenabling to prevent spam-clicking causing the
	# player to pick up the same item again.
	# NOTE: not using a callback on the completion of the animation tween here.
	# this is because tweens can be killed indiscriminately, (for example if the
	# player reorganizes their inventory while the tween for the releasing item
	# is still going, causing a different tween to overwrite that one)
	get_tree().create_timer(0.1).timeout.connect(reenable)

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
		item.z_index = _bottomost_clickable.z_index + idx + 1
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
	# input cleanup, we can find failed
	if event.is_action_released(&"mouse_click_primary"):
		if not _click_release_callback.is_null():
			_click_release_callback.call()

		# emit signal for the type of usage
		match _click_input_handle_type:
			InputHandleType.UNHANDLED:
				# no Interactable caught the click
				item_used_on_nothing.emit(_active_item)
			InputHandleType.WORLD_GOOD:
				good_item_use.emit(_active_item)
			InputHandleType.WORLD_BAD:
				bad_item_use.emit(_active_item)
			InputHandleType.INVENTORY_ITEM_CLICKED:
				pass

		# reset variable for the next click
		_click_input_handle_type = InputHandleType.UNHANDLED
		# null callable do nothing on release by default
		_click_release_callback = Callable()

	# make item in use hover at cursor position
	if _active_item and event is InputEventMouseMotion:
		# move item without tweening when tracking the cursor
		_active_item.get_parent().global_position = event.global_position
