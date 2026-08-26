extends Resource

class_name HandSlots

@export var hand_slots: Array[Weapon]
@export var equipped_weapon: Weapon
var two_handing: bool

func equip(item: Weapon) -> bool:
	if getNumberOfItems() < 2: 
		hand_slots.append(Weapon)
		return true
	else:
		return false
		
func twoHand():
	if getNumberOfItems() < 2:
		if not hand_slots.is_empty():
			if hand_slots[0].handsMaximum == 2:
				equipped_weapon = hand_slots[0]
				hand_slots[0].isBeingTwoHanded = true
				two_handing = true
			else:
				two_handing = false
				hand_slots[0].isBeingTwoHanded = false

func getNumberOfItems():
	var numberOfItems = 0
	for item in hand_slots:
		if item != null:
			numberOfItems += 1
	return numberOfItems
	
func getItems():
	var listOfItems = []
	for item in hand_slots:
		if item != null:
			listOfItems.append(item)
	return listOfItems

func getMinAttackRange():
	var minRange: int
	if hand_slots.is_empty():
		return 0
	else:
		if hand_slots[0] != null:
			minRange = hand_slots[0].getMinRange()
		for weapon in hand_slots:
			if weapon != null and weapon.getMinRange() <= minRange:
				minRange = weapon.getMinRange()
	return minRange
	
func getMaxAttackRange():
	var maxRange: int
	if hand_slots.is_empty():
		return 0
	else: 
		if hand_slots[0] != null:
			maxRange = hand_slots[0].getMaxRange()
		for weapon in hand_slots:
			if weapon != null and weapon.getMaxRange() >= maxRange:
				maxRange = weapon.getMaxRange()
	return maxRange
