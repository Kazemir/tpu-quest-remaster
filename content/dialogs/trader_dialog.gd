@tool
class_name TraderDialog
extends Control

@export var trade_data: TradeData

@onready var caption_label = %CaptionLabel
@onready var items_container = %ItemsContainer

var trader_item = preload("res://content/dialogs/trader_item.tscn")

var current_trade_element: int = 0

func _on_ready():
	if trade_data == null:
		return
	caption_label.text = trade_data.name
	
	for child in items_container.get_children():
		items_container.remove_child(child)
	
	for item_data in trade_data.items:
		var new_item = trader_item.instantiate() as TraderItem
		new_item.data = item_data
		items_container.add_child(new_item)
	
	update()

func _process(delta):
	if trade_data == null or Engine.is_editor_hint():
		return
	
	var new_trade_element = current_trade_element
	if Input.is_action_just_pressed("move_left"):
		new_trade_element -= 1
	elif Input.is_action_just_pressed("move_right"):
		new_trade_element += 1
	elif Input.is_action_just_pressed("action"):
		if GameManager.isHealthMaxed():
			return
		var item = items_container.get_child(current_trade_element) as TraderItem
		if GameManager.getMoney() < item.data.price:
			return
		GameManager.spendMoney(item.data.price)
		GameManager.addHealth(item.data.item_healin_power)
		return
	elif Input.is_action_just_pressed("escape"):
		DialogManager.hide_dialog()
		return
	else:
		return

	if new_trade_element < 0:
		new_trade_element = trade_data.items.size() - 1
	elif new_trade_element >= trade_data.items.size():
		new_trade_element = 0
		
	if new_trade_element != current_trade_element:
		current_trade_element = new_trade_element
		update()

func update():
	for i in range(items_container.get_child_count()):
		var item = items_container.get_child(i) as TraderItem
		item.set_selected(i == current_trade_element)
