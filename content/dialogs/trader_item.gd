@tool
class_name TraderItem
extends PanelContainer

@export var data: TradeItem
@export var is_selected: bool

@onready var item_icon = %ItemIcon
@onready var price_label = %PriceLabel


func _ready():
	if data == null:
		return

	item_icon.texture = data.item_icon
	price_label.text = str(data.price)
	set_selected(is_selected)


func set_selected(is_selected: bool):
	theme_type_variation = "PanelInner" if is_selected else "PanelEmpty"
