extends CanvasLayer

@onready var itemSlotScene = preload("res://scenes/UI Item Slot.tscn")
@onready var actionScene = preload("res://scenes/characteraction.tscn")
@onready var attack_tile_layer: Node2D = $"../SubViewportContainer/SubViewport/AttackTileLayer"
@onready var enemy_units: Node2D = $"../SubViewportContainer/SubViewport/Enemy Units"

var inventorySlots = []
var actionNodes = []
var testArray  = []
var selectorPosition: int
var selectorInitPosition: int

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

	actionNodes.clear()
	testArray.clear()

	testArray.append("Wait")

	if determineAttackAction(unit):
		testArray.push_front("Attack")
		
	testArray.push_front("Talk")
	testArray.push_front("Items")
		
	var positionMod = 0
	if testArray.is_empty() != true:
		$"Selector".visible = true
		#$"Selector".position = Vector2(1500, 150)#Vector2((unit.position.x+16)*6, (unit.position.y-16)*6)
		for item in testArray:
			var actionInstance = actionScene.instantiate()
			$"Action Display".add_child(actionInstance)
			actionInstance.position = Vector2(1650, 100+positionMod)
			actionInstance.setLabel(item)
			actionNodes.append(actionInstance)
			positionMod+= 150
		selectorInitPosition = (actionNodes[0].position.y)+70
		$"Selector".position.y = selectorInitPosition
		selectorPosition = 0
		
	#if unit has weapon, add attack action
	
func scrollSelectorActionMenu(toggle: bool):
	var tween = create_tween()
	if toggle == true: #a true input means the selector is moving up the array, which is visibly down the action menu
		if selectorPosition+1 > actionNodes.size() -1:
			selectorPosition = 0
			tween.tween_property($"Selector", "position:y", (selectorInitPosition), 0.1)

		else:
			selectorPosition += 1
			tween.tween_property($"Selector", "position:y", (actionNodes[selectorPosition].position.y)+70, 0.1)

	elif toggle == false: #a false input means the selector is moving down the array, which is visibly up the action menu
		if selectorPosition-1 < 0:
			selectorPosition = actionNodes.size()-1
			tween.tween_property($"Selector", "position:y", (actionNodes[selectorPosition].position.y)+70, 0.1)

		else:
			selectorPosition -= 1
			tween.tween_property($"Selector", "position:y", (actionNodes[selectorPosition].position.y)+70, 0.1)

			
			
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
