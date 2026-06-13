extends PanelContainer
class_name TreasureSellingItem

@export var treasure_variant : GE.ShapeName : 
	set(value):
		if (!GE.is_treasure(value)):
			return
		treasure_variant = value
		
		_update_ui()

@export var price := 0

@onready var treasure_sprite: ScalableTextureRect = %TreasureSprite
@onready var money_button: MoneyButton = %MoneyButton

var _context : SceneContext
var _item_ref : Item

func with_data(_ctx : SceneContext, _item : Item) -> TreasureSellingItem:
	self._item_ref = _item
	_context = _ctx
	treasure_variant = _item.type
	price = _item.price
	return self

func _ready() -> void:
	_update_ui()

func _update_ui() -> void:
	if (!is_node_ready()):
		await ready
	treasure_sprite.texture = ShapeSprite.SHAPE_DEF[treasure_variant].global.texture
	money_button.price = price


func _on_money_button_button_pressed() -> void:
	_context.inventory.money += price
	_context.inventory.items.erase(_item_ref)
	queue_free()
