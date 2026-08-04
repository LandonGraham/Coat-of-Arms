extends Resource
class_name Stat

var statName: String
var statValue: int
var statGrowthRate: int

func _init(p_name: String = "Unknown", p_int = 0, p_int2 = 50):
	statName = p_name
	statValue = p_int
	statGrowthRate = p_int2

func getName():
	return statName
	
func getValue():
	return statValue
	
func getGrowthRate():
	return statGrowthRate
	
func setValue(toSet: int):
	statValue = toSet

func setName(toSet: String):
	statName = toSet
	
func setGrowthRate(toSet: int):
	statGrowthRate = toSet
	
func randomNumber():
	return randi_range(1, statGrowthRate)

func tryStatIncrease():
	if randomNumber() < statGrowthRate:
		return true;
	else:
		return false;

func increaseStat():
	if tryStatIncrease():
		statValue += 1
