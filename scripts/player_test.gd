class_name Character
extends CharacterBody2D

#-------functional variabels--

@export var isPlayable: bool = true

const tile_size: Vector2 = Vector2(16, 16) #const determining how big, in pixels, a tile is (used for moving 16 pixels with the tween function)
var sprite_node_pos_tween: Tween
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var movementTile = preload("res://scenes/movement_tile.tscn")
@onready var attackTile = preload("res://scenes/movement_tile2.tscn")

@onready var movement_tile_layer: Node2D = $"../../MovementTileLayer"
@onready var attack_tile_layer: Node2D = $"../../AttackTileLayer"

enum State{idle, selected, moved, turnFinished}
var currentState: State
var validPoints: Array[Vector2] = []
var validAttackPoints: Array[Vector2] = []
var positionWhenSelected: Vector2
@export var portrait: Texture2D

#--------Variables-----------

#------Inventory variables-------

@export var inv: Inv
@export var armorInv: ArmorInventory
@export var handInv: HandSlots

#-------Character info-----------

@export var firstName: String
@export var fullName: String
@export var height: int
@export var gender: String
@export var experiencePoints: int
var weight: int
var movement: int

@export var weaponRange: int

#-----Character Portraits----

@export var Neutral: Texture2D
@export var Happy: Texture2D
@export var Sad: Texture2D
@export var Surprised: Texture2D
@export var Angry: Texture2D
@export var Blush: Texture2D

#-----character stats--------

var fortitude = Stat.new("Fortitude", 1, 50)
var body = Stat.new("Body", 20, 50)
var dexterity = Stat.new("Dexterity", 1, 50)
var agility = Stat.new("Agility", 12, 50)
var mind = Stat.new("Mind", 1, 50)
var luck = Stat.new("Luck", 1, 50)

#------weapon skills--------

var swords = Skill.new("Swords", 1, 0)
var spears = Skill.new("Spears", 1, 0)
var axes = Skill.new("Axes", 1, 0)
var bludgeons = Skill.new("Bludgeons", 1, 0)
var daggers = Skill.new("Daggers", 1, 0)
var bows = Skill.new("Bows", 1, 0)
var firearms = Skill.new("Firearms", 1, 0)
var unarmed = Skill.new("Unarmed", 1, 0)

#-----character skills-------

var armor = Skill.new("Armor", 1, 0)
var shields = Skill.new("Shields", 1, 0)
var riding = Skill.new("Riding", 1, 0)
var medicine = Skill.new("Medicine", 1, 0)
var grappling = Skill.new("Grappling", 1, 0)
var stealth = Skill.new("Stealth", 1, 0)

#----functions------

func getFirstName()-> String:
	return firstName

func calculateWeight():
	var returnWeight: int = 0
	
	for item in inv.items: #iterates through the character's inventory, adding each items weight to the total
		if item != null:
			returnWeight += item.weight
			
	for item in handInv.hand_slots: #iterates through the character's hand inventory, adding each item's weight to the total
		if item != null:
			returnWeight += item.weight
			
	for slot in armorInv.armorInventory: #iterates through the character's armor slots, adding each item, top and bottom, to the total
		if slot != null:
			if slot.bottomLayer != null:
				returnWeight += slot.bottomLayer.weight
			if slot.upperLayer != null: 
				returnWeight += slot.upperLayer.weight
	return returnWeight

func calculateAgility():
	var weightSlowDown = (max(0, calculateWeight()-(body.getValue()/2))) #formula for determining combat how much weight slows a character down by. Total weight - body/2, ie every 2 points of body mitigate 1 weight.
	var combatSpeed = max(0, agility.getValue()-weightSlowDown) #formula for determining combat speed. Agility - unmitigated weight. Both formulas cannot be lower than 0.
	#print ("Current combat speed is: ", combatSpeed)
	return combatSpeed

func calculateWeaponRange():
	var highestRange: int = 0
	for item in handInv.hand_slots:
		if item != null:
			for technique in item.listOfTecnhiques:
				if technique.attackRange >= highestRange:
					highestRange = technique.attackRange
	return highestRange

func setStatValue(name: String, val:int):
	match name:
		"Fortitude": 
			fortitude.setValue(val)
		"Body": 
			body.setValue(val)
		"Dexterity": 
			dexterity.setValue(val)
		"Agility": 
			agility.setValue(val)
		"Mind": 
			mind.setValue(val)
		"Luck": 
			luck.setValue(val)

func getEquippedWeapon() -> Weapon:
	if handInv.hand_slots.size() > 0:
		return handInv.hand_slots[0]
	else:
		return null
		
func calculateMovement():
	if calculateAgility() == 0:
		return 3
	else:
		return 3 + (calculateAgility()/8)

func getValidMovementPoints():

	validPoints.clear()

	var terrainController = $"../../Terrain Controller"

	if terrainController == null:
		push_error("TerrainController not found.")
		return

	var movement = calculateMovement()

	var directions = [
		Vector2(16,0),
		Vector2(-16,0),
		Vector2(0,16),
		Vector2(0,-16)
	]

	# Queue used for searching
	var open = []

	# Stores the cheapest movement cost to every position
	var costs = {}

	open.push_back(global_position)
	costs[global_position] = 0

	while open.size() > 0:

		var current = open.pop_front()

		for dir in directions:

			var next = current + dir

			# Skip blocked tiles
			if terrainController.blocksMovement(next):
				continue

			var movementCost = terrainController.getMovementCost(next)

			var newCost = costs[current] + movementCost

			if newCost > movement:
				continue

			if !costs.has(next) or newCost < costs[next]:
				costs[next] = newCost
				open.push_back(next)

	# Convert global positions into offsets from the player
	for position in costs.keys():

		#if position == global_position:
			#continue

		validPoints.append(position - global_position)
	createMovementTiles(validPoints, true)
	getAttackTiles()
	createMovementTiles(validAttackPoints, false)
	
func getAttackTiles():
	validAttackPoints.clear()
	
	if handInv.hand_slots[0] != null or handInv.hand_slots[1] != null:
		var attackSet : Dictionary = {}

		var minRange = handInv.getMinAttackRange()
		var maxRange = handInv.getMaxAttackRange()

		var tiles : Array[Vector2] = []

		if minRange == maxRange:
			tiles.append_array(getTilesAtDistance(maxRange))
		else:
			for distance in range(minRange, maxRange + 1):
				tiles.append_array(getTilesAtDistance(distance))
		for moveTile in validPoints:
			for offset in tiles:
				attackSet[moveTile + offset] = true
				
		for moveTile in validPoints:
			if attackSet.has(moveTile):
				attackSet.erase(moveTile)
		
		for point in attackSet.keys():
			validAttackPoints.append(point)
	else:
		pass
	
func getTilesAtDistance(distance : int) -> Array[Vector2]:
	var tiles : Array[Vector2] = []

	for x in range(-distance, distance + 1):

		var y = distance - abs(x)

		tiles.append(Vector2(x * 16, y * 16))

		if y != 0:
			tiles.append(Vector2(x * 16, -y * 16))

	return tiles


func getStandingAttackTiles():
	validAttackPoints.clear()
	
	if handInv.hand_slots[0] != null or handInv.hand_slots[1] != null:
	
		var attackSet: Dictionary = {}
		var minRange = handInv.getMinAttackRange()
		var maxRange = handInv.getMaxAttackRange()
		
		var tiles: Array[Vector2] = []
		
		if minRange == maxRange:
			tiles.append_array(getTilesAtDistance(maxRange))
		else:
			for distance in range(minRange, maxRange + 1):
				tiles.append_array(getTilesAtDistance(distance))
		
		# Add all attack tiles without excluding movement tiles
		for offset in tiles:
			attackSet[offset] = true
		
		for point in attackSet.keys():
			validAttackPoints.append(point)
	
		# Create only the attack tiles (red)
		createMovementTiles(validAttackPoints, false)
	else:
		pass

func createMovementTiles(validPoints: PackedVector2Array, flag: bool): #Function logic: Creates attack and movement tiles using a list of valid tiles and a flag. If the flag is true, the function uses the provided array to create movement tiles. If the flag is false, it uses the provided array to create attack tiles.
	for item in validPoints:
		if flag == true:
			var tile = movementTile.instantiate()
			movement_tile_layer.add_child(tile)
			tile.global_position = global_position + item
		elif flag == false:
			var tile = attackTile.instantiate()
			attack_tile_layer.add_child(tile)
			tile.global_position = global_position + item
	#for child in movement_tile_layer.get_children():
		#print(child.name)

func destroyMovementTiles():
	for tile in movement_tile_layer.get_children():
		tile.destroyThisTile()
	for attacktile in attack_tile_layer.get_children():
		attacktile.destroyThisTile()
	
func _move(dir: Vector2): #Function that controls cursor movement
	
	global_position += dir * tile_size
	$AnimatedSprite2D.global_position -= dir * tile_size
	
	if sprite_node_pos_tween: #Tween function that allows smooth tile based movement
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($AnimatedSprite2D, "global_position", global_position, 0.120).set_trans(Tween.TRANS_SINE)
	
func _physics_process(delta: float) -> void:
	pass

func updateState(newState: State):
	match currentState:
		
		State.idle:
			
			if newState == State.selected:
				currentState = State.selected
				positionWhenSelected = position
				getValidMovementPoints()
		
		State.selected:
			
			if newState == State.idle:
				var tween = create_tween()
				destroyMovementTiles()
				tween.tween_property(self, "position", positionWhenSelected, .08)
				currentState = State.idle
			
			if newState == State.moved:
				destroyMovementTiles()
				getStandingAttackTiles()
				currentState = State.moved
		
		State.moved:
			
			if newState == State.idle:
				var tween = create_tween()
				destroyMovementTiles()
				tween.tween_property(self, "position", positionWhenSelected, .08)
				currentState = State.idle
			
			if newState == State.turnFinished:
				destroyMovementTiles()
				currentState = State.idle
				
func getPortrait():
	return portrait
