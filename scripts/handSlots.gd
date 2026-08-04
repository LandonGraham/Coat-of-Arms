extends Resource

class_name HandSlots

@export var hand_slots: Array[Weapon]

func getMinAttackRange():
	var minRange: int
	if hand_slots.is_empty():
		return 0
	else:
		minRange = hand_slots[0].getMinRange()
		for weapon in hand_slots:
			if weapon.getMinRange() <= minRange:
				minRange = weapon.getMinRange()
	return minRange
	
func getMaxAttackRange():
	var maxRange: int
	if hand_slots.is_empty():
		return 0
	else: 
		maxRange = hand_slots[0].getMaxRange()
		for weapon in hand_slots:
			if weapon.getMaxRange() >= maxRange:
				maxRange = weapon.getMaxRange()
	return maxRange
