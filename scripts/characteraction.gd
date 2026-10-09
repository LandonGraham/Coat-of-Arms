extends Control

@onready var label: Label = $Label
@onready var icon: TextureRect = $Icon

var pending_text: String = ""

func _ready() -> void:
	if pending_text != "":
		label.text = pending_text

func setIcon(texture: Texture2D):
	icon.texture = texture
	
func setLabel(text: String):
	pending_text = text
	if is_node_ready():
		label.text = text
