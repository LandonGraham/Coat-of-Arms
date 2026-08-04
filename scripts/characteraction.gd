extends Node2D

@onready var label: Label = $Label
@onready var icon: TextureRect = $Icon

func setIcon(texture: Texture2D):
	pass
	
func setLabel(text: String):
	if text != null:
		label.text = text
	else:
		pass
