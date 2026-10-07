extends Node2D

var combatantOne: Character
var combatantTwo: Character

@onready var cursor: Node2D = $"../SubViewportContainer/SubViewport/Cursor"
@onready var ui_manager: CanvasLayer = $"../UI Manager"

const TILE_SIZE = 16

enum state { selectWeapons, selectTechniques, inactive }

var currentState: state = state.inactive
var selectedWeaponName: String = ""
var ignoreInputThisFrame: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ignoreInputThisFrame:
		ignoreInputThisFrame = false
		return

	match currentState:
		state.selectWeapons:
			if Input.is_action_just_pressed("inputUpW"):
				ui_manager.scrollSelectorActionMenu(false)
			if Input.is_action_just_pressed("InputDownS"):
				ui_manager.scrollSelectorActionMenu(true)
			if Input.is_action_just_pressed("InteractKey"):
				selectedWeaponName = ui_manager.getSelection()
				updateState(state.selectTechniques)

		state.selectTechniques:
			if Input.is_action_just_pressed("inputUpW"):
				ui_manager.scrollSelectorActionMenu(false)
			if Input.is_action_just_pressed("InputDownS"):
				ui_manager.scrollSelectorActionMenu(true)

func setCombatants(One: Character, Two: Character):
	combatantOne = One
	combatantTwo = Two

# Distance between the combatants in tiles (Manhattan distance).
func getCombatantDistance() -> int:
	var diff = combatantTwo.global_position - combatantOne.global_position
	return int(round((abs(diff.x) + abs(diff.y)) / TILE_SIZE))

# Returns true if the weapon has at least one technique usable at the given distance.
func weaponHasTechniqueInRange(weapon, distance: int) -> bool:
	if weapon == null:
		return false
	for technique in weapon.getListOfAllTechniques():
		if technique.minAttackRange <= distance and distance <= technique.attackRange:
			return true
	return false

# Returns every equipped weapon that has a technique the target is in range for.
func getWeaponsInRange() -> Array:
	var distance = getCombatantDistance()
	var result: Array = []
	for weapon in combatantOne.handInv.hand_slots:
		if weapon != null and weaponHasTechniqueInRange(weapon, distance):
			result.append(weapon)
	return result

func getCombatantOneNumberOfAttacks() -> int:
	var combatantOneAgility = combatantOne.calculateAgility()
	print(combatantOneAgility)
	print(combatantOne.agility.getValue())

	var combatantTwoAgility = combatantTwo.calculateAgility()
	print(combatantTwoAgility)
	print(combatantTwo.agility.getValue())

	if combatantTwoAgility >= combatantOneAgility:
		return 1
	else:
		return 1 + (combatantOneAgility - combatantTwoAgility) / 8

func chooseTechniques(unit: Character):
	print("Choose from the following techniques:")
	var techniques = unit.getEquippedWeapon().getListOfAllTechniques()

	for i in range(techniques.size()):
		print(str(i + 1) + ". " + techniques[i].name)

	print("You can make this many attacks: ", getCombatantOneNumberOfAttacks())

	var validInput = false
	while not validInput:
		if Input.is_action_just_pressed("Input1"):
			print("You have selected ", techniques[0].name)
			validInput = true
		elif Input.is_action_just_pressed("Input2"):
			print("You have selected ", techniques[1].name)
			validInput = true

		await get_tree().process_frame

func updateState(newState: state):
	match currentState:
		state.inactive:
			if newState == state.selectWeapons:
				var weaponsInRange = getWeaponsInRange()

				if weaponsInRange.size() > 1:
					ui_manager.openWeaponMenu(combatantOne, weaponsInRange)
					currentState = state.selectWeapons
					ignoreInputThisFrame = true
				elif weaponsInRange.size() == 1:
					ui_manager.openWeaponMenu(combatantOne, weaponsInRange)
					selectedWeaponName = weaponsInRange[0].getName()
					ui_manager.openTechniqueMenu(combatantOne, selectedWeaponName, getCombatantDistance(), true)
					currentState = state.selectTechniques
					ignoreInputThisFrame = true
				else:
					ui_manager.openWeaponMenu(combatantOne, [])
					currentState = state.selectWeapons

		state.selectWeapons:
			if newState == state.selectTechniques:
				ui_manager.openTechniqueMenu(combatantOne, selectedWeaponName, getCombatantDistance(), true)
				currentState = newState
