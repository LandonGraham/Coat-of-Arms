extends Node2D

@export var empty_icon: Texture2D
@export var emptyLabel: Texture2D

@onready var item_icon_sprite: TextureRect = $"Background Sprite/Item Icon Sprite"
@onready var item_name_label: Label = $"Background Sprite/Item Name"

func set_item(item: invItem) -> void:
	item_icon_sprite.texture = item.texture
	item_name_label.text = item.name

func set_empty() -> void:
	item_icon_sprite.texture = empty_icon
	item_name_label.text = ""
