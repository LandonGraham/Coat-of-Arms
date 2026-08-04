extends CanvasLayer

@onready var itemSlotScene = preload("res://scenes/UI Item Slot.tscn")
@onready var actionScene = preload("res://scenes/characteraction.tscn")
@onready var attack_tile_layer: Node2D = $"../SubViewportContainer/SubViewport/AttackTileLayer"
@onready var enemy_units: Node2D = $"../SubViewportContainer/SubViewport/Enemy Units"

var inventorySlots = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Portrait Display".visible = false
	$"Selector".visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func createHandInventoryUI(unit: Character):
	var positionMod = 200
	if unit.handInv == null:
		return
	for item in unit.handInv.hand_slots:
		var slotInstance = itemSlotScene.instantiate()
		add_child(slotInstance)
		slotInstance.position = Vector2(500, positionMod)
		positionMod += 83
		
		if item != null:
			slotInstance.set_item(item)
		else:
			slotInstance.set_empty()

func displayInventory(unit: Character):
	var positionMod = 200
	for item in unit.inv.items:
		var slotInstance = itemSlotScene.instantiate()
		add_child(slotInstance)
		inventorySlots.append(slotInstance)
		slotInstance.position = Vector2(500, positionMod)
		positionMod += 83
		
		if item != null:
			slotInstance.set_item(item)
		else:
			slotInstance.set_empty()
			
func closeInventory():
	for slot in inventorySlots:
		if is_instance_valid(slot):
			slot.queue_free()
			
func closeActions():
	var direct_children: Array[Node] = $"Action Display".get_children()
	for child in direct_children:
		child.queue_free()
	$"Selector".visible = false
	
func determineAttackAction(unit: Character) -> bool:
	var threatenedUnits: Array[Node] = getThreatenedUnits(unit)
	if threatenedUnits.is_empty():
		return false
	else:
		return true

func getThreatenedUnits(unit: Character) -> Array[Node]:
	var threatenedTiles: Array[Node]
	var enemyUnits: Array [Node]
	enemyUnits = enemy_units.get_children()
	threatenedTiles = attack_tile_layer.get_children()
	var threatenedUnits: Array[Node]
	
	if threatenedTiles.is_empty() == true:
		threatenedUnits.clear()
	else:
		for enemy in enemyUnits:
			for tile in threatenedTiles:
				if enemy.global_position == tile.global_position:
					threatenedUnits.append(enemy)
	return threatenedUnits
	
	
func openActionMenu(unit: Character):
	#var testArray = ["Attack", "Grapple", "Magic", "Items", "Wait"]
	var testArray  = ["Wait"]
	
	if determineAttackAction(unit):
		testArray.push_front("Attack")
		
	var positionMod = 0
	if testArray.is_empty() != true:
		$"Selector".visible = true
		$"Selector".position = Vector2(1500, 100)#Vector2((unit.position.x+16)*6, (unit.position.y-16)*6)
		for item in testArray:
			var actionInstance = actionScene.instantiate()
			$"Action Display".add_child(actionInstance)
			actionInstance.position = Vector2(($"Selector".position.x+100),(($"Selector".position.y))+positionMod)
			actionInstance.setLabel(item)
			positionMod+= 150
	#if unit has weapon, add attack action
	
func displayPortrait(unit: Character):
	if unit != null:
		$"Portrait Display".texture = unit.getPortrait()
		$"Portrait Display".visible = true
		$"Portrait Display/AnimationPlayer".play("FadeIn")
func removePortrait():
	$"Portrait Display/AnimationPlayer".play("FadeOut")
	await $"Portrait Display/AnimationPlayer".animation_finished
	$"Portrait Display".texture = null
	$"Portrait Display".visible = false
