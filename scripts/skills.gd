extends Resource
class_name Skill

var skillName: String
var skillValue: int
var skillProgress: int

func _init(p_name: String = "Unknown", p_int = 0, p_int2 = 0):
	skillName = p_name
	skillValue = p_int
	skillProgress = p_int2

func getName() -> String:
	return skillName
	
func getValue() -> int:
	return skillValue
	
func getProgress() -> int:
	return skillProgress
	
func setName(toSet: String):
	skillName = toSet
	
func setValue(toSet: int):
	skillValue = toSet
	
func setProgress(toSet: int):
	skillProgress = toSet
