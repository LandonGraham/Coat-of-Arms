extends Node2D

const tile_size: Vector2 = Vector2(16, 16) #Size of the tile that the cursor will move
var sprite_node_pos_tween: Tween

@export var selectable_units: Node2D #A variable meant to point to the Units node in the scene tree, whose children are the units currently on the map
@export var hoverable_units: Node2D 
var selected_character: Character = null #Character type defined in Player_Test.gd script
var selectable_character: Character = null
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ui_manager: CanvasLayer = $"../../../UI Manager"
@onready var movement_tile_layer: Node2D = $"../MovementTileLayer"
@export var camera_2d: Camera2D

enum state{selecting, selected, invMenu, actionMenu}
var currentState: state

func _move(dir: Vector2):

	global_position += dir * tile_size
	$AnimatedSprite2D.global_position -= dir * tile_size

	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()

	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property(
		$AnimatedSprite2D,
		"global_position",
		global_position,
		0.12
	).set_trans(Tween.TRANS_SINE)

	# Notify the camera after every movement.
	camera_2d.cursor_moved(global_position)

func try_select_character(): #The try select character function looks at the tile where the cursor currently is, and returns the Character type of any unit in the same tile.
	#if selected_character != null:
		#selected_character = null
		#return null
		for unit in selectable_units.get_children():
			if unit is Character and unit.global_position == global_position:
				return unit
		for unit in hoverable_units.get_children():
			if unit is Character and unit.global_position == global_position:
				return unit
		return null
				
func select_character(unit: Character) -> void: #Select character changes the selected character variable to the parameter unit.
		selected_character = unit
		unit.updateState(unit.State.selected)
	
func isValidTile(testPosition: Vector2) -> bool:
	
	if selected_character == null:
		return false
	else:
		for tile in selected_character.validPoints:
			if selected_character.positionWhenSelected + tile == testPosition:
				return true
	return false	

func findCharacterPortrait():
	selectable_character = try_select_character()
	if selectable_character != null: #Every time the cursor is moved, it checks to see if its hovering over a selectable character.
		animated_sprite_2d.play("HoveringSelectable")
		ui_manager.displayPortrait(selectable_character)
	else:
		ui_manager.removePortrait()
		animated_sprite_2d.play("Idle")

func _physics_process(delta: float) -> void:
	match currentState:
		state.selecting:
			if !sprite_node_pos_tween or !sprite_node_pos_tween.is_running(): #movement controls, WASD and arrows.
				if Input.is_action_pressed("inputUpW"):
					_move(Vector2(0, -1))
					findCharacterPortrait()
				elif Input.is_action_pressed("InputDownS"):
					_move(Vector2(0, 1))
					findCharacterPortrait()
				elif Input.is_action_pressed("inputLeftA"):
					_move(Vector2(-1, 0))
					findCharacterPortrait()
				elif Input.is_action_pressed("InputRightD"):
					_move(Vector2(1, 0))
					findCharacterPortrait()
						
				if Input.is_action_just_pressed("InteractKey"): #When pressing space, tries to select a character if there is one available.
					var unit: Character = try_select_character()
					if unit != null:
						select_character(unit)
						animated_sprite_2d.play("Selected")
						currentState = state.selected
						ui_manager.removePortrait()
		state.selected:
			if !sprite_node_pos_tween or !sprite_node_pos_tween.is_running(): #movement controls, WASD and arrows.
				if Input.is_action_pressed("inputUpW"):
					if isValidTile(position + Vector2(0, -16)):
						selected_character._move(Vector2(0, -1))
						selected_character.animated_sprite_2d.play("Run Up")
						_move(Vector2(0, -1))
						animated_sprite_2d.play("Idle")
				elif Input.is_action_pressed("InputDownS"):
					if isValidTile(position + Vector2(0, 16)):
						selected_character._move(Vector2(0, 1))
						selected_character.animated_sprite_2d.play("Run Down")
						_move(Vector2(0, 1))
						animated_sprite_2d.play("Idle")
				elif Input.is_action_pressed("inputLeftA"):
					if isValidTile(position + Vector2(-16, 0)):
						selected_character._move(Vector2(-1, 0))
						selected_character.animated_sprite_2d.play("Run Left")
						_move(Vector2(-1, 0))
						animated_sprite_2d.play("Idle")
				elif Input.is_action_pressed("InputRightD"):
					if isValidTile(position + Vector2(16, 0)):
						selected_character._move(Vector2(1, 0))
						selected_character.animated_sprite_2d.play("Run Right")
						_move(Vector2(1, 0))
						animated_sprite_2d.play("Idle")
				else:
					selected_character.animated_sprite_2d.play("Idle")
				if Input.is_action_just_pressed("backKey"):
					selected_character.destroyMovementTiles()
					selected_character.updateState(selected_character.State.idle)
					findCharacterPortrait()
					currentState = state.selecting
				elif Input.is_action_just_pressed("InteractKey"):
					ui_manager.openActionMenu(selected_character)
					selectable_character.updateState(selectable_character.State.moved)
					currentState = state.actionMenu
				elif Input.is_action_just_pressed("testInput"):
					ui_manager.displayInventory(selected_character)
					currentState = state.invMenu
		state.actionMenu:
			if Input.is_action_just_pressed("backKey"):
				ui_manager.closeActions()
				selected_character.updateState(selected_character.State.idle)
				currentState = state.selecting
			if Input.is_action_just_pressed("inputUpW"):
				ui_manager.scrollSelectorActionMenu(false)
			if Input.is_action_just_pressed("InputDownS"):
				ui_manager.scrollSelectorActionMenu(true)
