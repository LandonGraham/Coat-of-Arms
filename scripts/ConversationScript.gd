extends Resource

class_name Conversation

@export var conversation_id: String
@export var conversation_name: String
@export var lines: Array[DialogueLine] = [ ]

func _init(p_id: String = "", p_name: String = "", p_lines: Array[DialogueLine] = []):
	conversation_id = p_id
	conversation_name = p_name
	lines = p_lines

@export var conversation_raw: String
