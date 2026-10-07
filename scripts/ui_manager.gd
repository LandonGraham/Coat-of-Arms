extends CanvasLayer

@onready var itemSlotScene = preload("res://scenes/UI Item Slot.tscn")
@onready var actionScene = preload("res://scenes/characteraction.tscn")
@onready var attack_tile_layer: Node2D = $"../SubViewportContainer/SubViewport/AttackTileLayer"
@onready var enemy_units: Node2D = $"../SubViewportContainer/SubViewport/Enemy Units"

var inventorySlots = []
var actionNodes = []
var testArray = []
var selectorPosition: int
var selectorInitPosition: int
var selectorOffset = 60

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"PortraitDisplay".visible = false
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
	actionNodes.clear()
	$"Selector".visible = false

func determineAttackAction(unit: Character) -> bool:
	var threatenedUnits: Array[Node] = getThreatenedUnits(unit)
	if threatenedUnits.is_empty():
		return false
	else:
		return true

func determineTalkAction(unit: Character) -> bool:
	return false

func determineGrappleAction(unit: Character) -> bool:
	if unit.grappling.getValue() >= 10:
		return true
	else:
		return false

func getThreatenedUnits(unit: Character) -> Array[Node]:
	var enemyUnitsArray: Array[Node] = enemy_units.get_children()
	var threatenedUnits: Array[Node] = []

	if enemyUnitsArray.is_empty():
		return threatenedUnits

	for enemy in enemyUnitsArray:
		for attackOffset in unit.validAttackPoints:
			if enemy.global_position == unit.global_position + attackOffset:
				threatenedUnits.append(enemy)
				break

	return threatenedUnits

func openActionMenu(unit: Character):
	actionNodes.clear()
	testArray.clear()

	testArray.append("Wait")
	testArray.push_front("Items")

	if determineGrappleAction(unit) and determineAttackAction(unit):
		testArray.push_front("Grapple")

	if determineAttackAction(unit):
		testArray.push_front("Attack")

	if determineTalkAction(unit):
		testArray.push_front("Talk")

	var positionMod = 0

	if testArray.is_empty() != true:
		$"Selector".visible = true
		for item in testArray:
			var actionInstance = createActionLabel(Vector2(1600, 100 + positionMod), item)
			$"Action Display".add_child(actionInstance)
			actionNodes.append(actionInstance)
			positionMod += 120
		selectorInitPosition = actionNodes[0].position.y + selectorOffset
		$"Selector".position.y = selectorInitPosition
		selectorPosition = 0

func openWeaponMenu(unit: Character, weapons: Array = []):
	actionNodes.clear()

	var positionMod = 0
	var weaponList = weapons
	if weaponList.is_empty():
		weaponList = []
		for weapon in unit.handInv.hand_slots:
			if weapon != null:
				weaponList.append(weapon)

	for weapon in weaponList:
		displayNewAction(createActionLabel(Vector2(1600, 100 + positionMod), weapon.getName()))
		positionMod += 120

	if actionNodes.is_empty() != true:
		$"Selector".visible = true
		selectorInitPosition = actionNodes[0].position.y + selectorOffset
		$"Selector".position.y = selectorInitPosition
		selectorPosition = 0

func openTechniqueMenu(unit: Character, weaponName: String, distance: int = -1, preserveExistingLabels: bool = false):
	var positionMod = 0
	var listOfTechniques = []

	for weapon in unit.handInv.getItems():
		if weapon != null and weapon.name == weaponName:
			for technique in weapon.getListOfAllTechniques():
				if distance < 0 or (technique.minAttackRange <= distance and distance <= technique.attackRange):
					listOfTechniques.append(technique)
			break

	if listOfTechniques.is_empty():
		return

	if not preserveExistingLabels:
		closeActions()
	else:
		var weaponLabelIndex := -1
		for i in range(actionNodes.size()):
			if is_instance_valid(actionNodes[i]) and actionNodes[i].label.text == weaponName:
				weaponLabelIndex = i
				break

		if weaponLabelIndex != -1:
			for i in range(actionNodes.size() - 1, weaponLabelIndex, -1):
				if is_instance_valid(actionNodes[i]):
					actionNodes[i].queue_free()
				actionNodes.remove_at(i)
		else:
			closeActions()

	var selectorXOffset = -60
	if not actionNodes.is_empty() and is_instance_valid(actionNodes[0]):
		selectorXOffset = $"Selector".position.x - actionNodes[0].position.x

	for technique in listOfTechniques:
		displayNewAction(createActionLabel(Vector2(1200, 100 + positionMod), technique.name))
		positionMod += 120

	$"Selector".visible = true
	selectorInitPosition = actionNodes[0].position.y + selectorOffset
	$"Selector".position = Vector2(actionNodes[0].position.x + selectorXOffset, selectorInitPosition)
	selectorPosition = 0

func displayNewAction(p_instance: Node2D):
	$"Action Display".add_child(p_instance)
	actionNodes.append(p_instance)

func createActionLabel(p_postion: Vector2, p_text: String):
	var new_instance = actionScene.instantiate()
	new_instance.position = p_postion
	new_instance.setLabel(p_text)
	return new_instance

func scrollSelectorActionMenu(toggle: bool):
	var tween = create_tween()
	if toggle == true:
		if selectorPosition + 1 > actionNodes.size() - 1:
			selectorPosition = 0
			tween.tween_property($"Selector", "position:y", selectorInitPosition, 0.1)
		else:
			selectorPosition += 1
			tween.tween_property($"Selector", "position:y", actionNodes[selectorPosition].position.y + selectorOffset, 0.1)
	elif toggle == false:
		if selectorPosition - 1 < 0:
			selectorPosition = actionNodes.size() - 1
			tween.tween_property($"Selector", "position:y", actionNodes[selectorPosition].position.y + selectorOffset, 0.1)
		else:
			selectorPosition -= 1
			tween.tween_property($"Selector", "position:y", actionNodes[selectorPosition].position.y + selectorOffset, 0.1)

func getSelection():
	var selectedAction = actionNodes[selectorPosition].label.text
	return selectedAction

func displayPortrait(unit: Character):
	if unit != null:
		$"PortraitDisplay/Portrait".texture = unit.getPortrait()
		$"PortraitDisplay".visible = true
		$"PortraitDisplay/AnimationPlayer".play("FadeIn")
		$"PortraitDisplay/HP Label".text = "HP: " + str(unit.currentHitPoints) + "/" + str(unit.fortitude.getValue())
		$"PortraitDisplay/Name Label".text = unit.getFirstName()

func removePortrait():
	$"PortraitDisplay/AnimationPlayer".play("FadeOut")
	await $"PortraitDisplay/AnimationPlayer".animation_finished
	$"PortraitDisplay/Portrait".texture = null
	$"PortraitDisplay".visible = false
