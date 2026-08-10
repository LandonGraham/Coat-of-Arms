extends Node2D

const tile_size: Vector2 = Vector2(16, 16) #Size of the tile that the cursor will move
var sprite_node_pos_tween: Tween

@export var selectable_units: Node2D #A variable meant to point to the Units node in the scene tree, whose children are the units currently on the map
@export var hoverable_units: Node2D #A variable that points to the Enemy units node in the scene tree, whose children are the enemy units currently on the map.


var selected_character: Character = null #Character type defined in Player_Test.gd script
var selectable_character: Character = null
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ui_manager: CanvasLayer = $"../../../UI Manager"
@onready var movement_tile_layer: Node2D = $"../MovementTileLayer"
@export var camera_2d: Camera2D

enum state{selecting, selected, invMenu, actionMenu, selectingTargets}
var currentState: state
var currentTargetIndex: int = 0
var targets: Array[Character] = []

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
	
func movetoPosition(pos: Vector2, duration: float):
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()

	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property(
		$AnimatedSprite2D,
		"global_position",
		pos,
		duration
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
				
func getCharacterValidTargets(unit: Character) -> Array[Character]:
	targets = []
	unit.getStandingAttackTiles()
	var offset_x = unit.global_position.x
	var offset_y = unit.global_position.y
	for enemy in hoverable_units.get_children():
		for tile in unit.validAttackPoints:
			if enemy.global_position.x == (tile.x + offset_x) and enemy.global_position.y == (tile.y + offset_y):
				targets.append(enemy)
	return targets
	
func goToFirstTarget(unit: Character):
	targets = getCharacterValidTargets(unit)
	if targets.is_empty():
		pass
	else:
		movetoPosition(targets[0].global_position, 0.06)
		currentTargetIndex = 0
	
func scrollBetweenPotentialAttackers(unit: Character, dir: String):
	if targets.is_empty():
		pass
	else:
		if dir == "advance":
			currentTargetIndex += 1
			if currentTargetIndex >= targets.size():
				currentTargetIndex = 0
		
		if dir == "retreat":
			currentTargetIndex -= 1
			if currentTargetIndex < 0:
				currentTargetIndex = targets.size()-1
				
		movetoPosition(targets[currentTargetIndex].global_position, 0.06)
	
	for tile in unit.validAttackPoints:
		pass
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
					selected_character.updateState(selected_character.State.idle)
					findCharacterPortrait()
					currentState = state.selecting
				elif Input.is_action_just_pressed("InteractKey"):
					await selectable_character.updateState(selectable_character.State.moved)
					ui_manager.openActionMenu(selected_character)
					currentState = state.actionMenu
				#elif Input.is_action_just_pressed("testInput"):
					#ui_manager.displayInventory(selected_character)
					#currentState = state.invMenu
		
		state.actionMenu:
			
			if Input.is_action_just_pressed("InteractKey"):
				match ui_manager.getSelection():
					
					"Wait":
						selected_character.updateState(selected_character.State.turnFinished)
						ui_manager.closeActions()
						currentState = state.selecting
						
					"Items":
						ui_manager.closeActions()
						ui_manager.displayInventory(selected_character)
						currentState = state.invMenu
						
					"Attack":
						ui_manager.closeActions()
						currentState = state.selectingTargets
						goToFirstTarget(selected_character)
					
			if Input.is_action_just_pressed("backKey"):
				ui_manager.closeActions()
				selected_character.updateState(selected_character.State.idle)
				currentState = state.selecting
				
			if Input.is_action_just_pressed("inputUpW"):
				ui_manager.scrollSelectorActionMenu(false)
				
			if Input.is_action_just_pressed("InputDownS"):
				ui_manager.scrollSelectorActionMenu(true)
		
		state.selectingTargets:
			
			if Input.is_action_just_pressed("backKey"):
				movetoPosition(selected_character.global_position, 0.06)
				ui_manager.openActionMenu(selected_character)
				currentState = state.actionMenu
				
			if Input.is_action_just_pressed("inputUpW"):
				scrollBetweenPotentialAttackers(selected_character, "advance")
			if Input.is_action_just_pressed("InputRightD"):
				scrollBetweenPotentialAttackers(selected_character, "advance")
			if Input.is_action_just_pressed("InputDownS"):
				scrollBetweenPotentialAttackers(selected_character, "retreat")
			if Input.is_action_just_pressed("inputLeftA"):
				scrollBetweenPotentialAttackers(selected_character, "retreat")
				
			
		state.invMenu:
			
			if Input.is_action_just_pressed("backKey"):
				ui_manager.closeInventory()
				ui_manager.openActionMenu(selected_character)
				currentState = state.actionMenu
