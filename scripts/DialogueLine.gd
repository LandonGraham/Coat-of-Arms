extends Resource
class_name DialogueLine

var speaker: Character
var text: String
var position: String #Left or right

func _init(p_speaker: Character = null, p_text: String = " ", p_position: String = "Left"):
	speaker = p_speaker
	text = p_text
	position = p_position
