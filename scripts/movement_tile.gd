extends Node2D

@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("FadeIn")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func destroyThisTile():
	animation_player.play("FadeOut")
	await animation_player.animation_finished
	queue_free()
