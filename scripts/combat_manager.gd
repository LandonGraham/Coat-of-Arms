extends Node2D

var combatantOne: Character
var combatantTwo: Character

@onready var cursor: Node2D = $"../SubViewportContainer/SubViewport/Cursor"

enum state{selectTechniques, inactive}

var currentState: state = state.inactive

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func setCombatants(One: Character, Two: Character):
	combatantOne = One
	combatantTwo = Two
	
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
		return 1 + (combatantOneAgility-combatantTwoAgility) /8
	
func chooseTechniques(unit: Character):
	
	print("Choose from the following techniques:")
	var techniques = unit.getEquippedWeapon().getListOfAllTechniques()
	
	for i in range(techniques.size()):
		print(str(i + 1) + ". " + techniques[i].name)
	
	print("You can make this many attacks: ", getCombatantOneNumberOfAttacks())
	
	var validInput = false
	while not validInput:
		if Input.is_action_just_pressed("Input1"):
			print ("You have selected ", techniques[0].name)
			validInput = true
		elif Input.is_action_just_pressed("Input2"):
			print ("You have selected ", techniques[1].name)
			validInput = true
		
		await get_tree().process_frame
		
	
func updateState(newState: state):
	match currentState:
		
		state.inactive:
			
			if newState == state.selectTechniques:
				chooseTechniques(combatantOne)
				currentState = newState
