extends Node2D

# Called when the node enters the scene tree for the first time.
class_name MapTile

@export var tileTexture: Texture2D

@onready var sprite := $Sprite2D

enum restrictionTypes{infantry, cavalry, flying}

@export var restrictedTypes: Array[restrictionTypes]
@export var movementReq: int
@export var blocksMovement: bool

func _ready():
	sprite.texture = tileTexture
