extends invItem

class_name Weapon

enum weaponType{sword, axe, spear, bludgeon, dagger, bow, firearm, artillery, unarmed}
enum damageType{pierce, slash, strike, magic}

@export var listOfTecnhiques: Array[Techniques]

@export var handsMinimum: int
@export var handsMaximum: int
@export var baseDamage: int

@export var pierceMultiplier: float
@export var slashMultiplier: float
@export var strikeMultiplier: float

func getMinRange():
	var lowest: int
	if listOfTecnhiques.is_empty():
		return 0
	else:
		lowest = listOfTecnhiques[0].minAttackRange
		for technique in listOfTecnhiques:
			if technique.minAttackRange <= lowest:
				lowest = technique.minAttackRange
	return lowest
			
func getMaxRange():
	var highest: int
	if listOfTecnhiques.is_empty():
		return 0
	else: 
		highest = listOfTecnhiques[0].attackRange
		for technique in listOfTecnhiques:
			if technique.attackRange >= highest:
				highest = technique.attackRange
	return highest
	
func getListOfAllTechniques():
	return listOfTecnhiques
	
func getListOfUseableTecnhiques(unit: Character):
	pass
		
