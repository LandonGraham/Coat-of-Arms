extends CanvasLayer


@onready var dialogue_box: Control = $DialogueBox
@onready var label: Label = $DialogueBox/Label
@onready var speaker_name_label: Label = $"DialogueBox/Speaker Name Label"
@onready var portrait_left: TextureRect = $DialogueBox/PortraitLeft
@onready var portrait_right: TextureRect = $DialogueBox/PortraitRight

var dialogue_read_rate: float = 0.03
var dialogue_tween: Tween

var dialogue_lines: Array[DialogueLine] = []
var current_line_index: int = 0
var is_dialogue_active: bool = false

var speaker_one: Character
var speaker_two: Character

enum state{inactive, reading, done_reading, waiting_for_input}
var current_state: state

func _ready() -> void:
	current_state = state.inactive
	dialogue_box.visible = false
	portrait_left.texture = null
	portrait_right.texture = null
	
	start_dialogue([DialogueLine.new(null, "Did you ever hear the tragedy of Darth Plagueis the Wise? I thought not. It's not a story the Jedi would tell you. It's a sith legend. Darth Plagueis was a Dark Lord of the Sith so powerful and so wise, he could use the dark side of the Force to influence the Midichlorians to create... life", "left"), DialogueLine.new(null, "And unfreezing it now!", "right")])

func start_dialogue(lines: Array[DialogueLine]):
	# Pause the game
	get_tree().paused = true
	dialogue_lines = split_dialogue_if_needed(lines)
	current_line_index = 0
	
	is_dialogue_active = true
	dialogue_box.visible = true
	display_current_line()
	
func display_current_line():
	var current_line = dialogue_lines[current_line_index]
	
	if current_line.speaker:
		speaker_name_label.text = current_line.speaker.firstName
	else:
		speaker_name_label.text = "Narrator"
	
	update_portraits(current_line)
	
	label.text = current_line.text
	label.visible_ratio = 0.0
	
	current_state = state.reading
	
	tween_dialogue()
	
func update_portraits(current_line: DialogueLine):
	portrait_left.texture = null 
	portrait_right.texture = null
	
	if current_line.speaker:
		var portrait = current_line.speaker.getPortrait() #Speaker might be null, meaning its a narrator
		if current_line.speaker_position == "left":
			portrait_left.texture = portrait
		else:
			portrait_right.texture = portrait
			
func split_dialogue_if_needed(lines: Array[DialogueLine]) -> Array[DialogueLine]:
	var split_lines: Array[DialogueLine] = []
	var max_chars = 190
	var new_line = ""
	
	for line in lines:
		var words = line.text.split(" ")
		for word in words:
			if (new_line + word).length() > max_chars:
				new_line += "-"
				split_lines.append(DialogueLine.new(line.speaker, new_line))
				new_line = "-"
				new_line += word
				new_line += " "
			else:
				new_line += word
				new_line += " "
		split_lines.append(DialogueLine.new(line.speaker, new_line))
		new_line = ""
	
	return split_lines
	
func _input(event):
	
	match current_state:
		state.inactive:
			return
		state.reading:
			if event.is_action_pressed("InteractKey"):
				if dialogue_tween:
					dialogue_tween.kill()
				label.visible_ratio = 1
				current_state = state.done_reading
		state.done_reading:
			if event.is_action_pressed("InteractKey"):
				advance_dialogue()
	
	
			
func advance_dialogue():
	if current_line_index < dialogue_lines.size()-1:
		current_line_index += 1
		display_current_line()
	else:
		get_tree().paused = false
		
		is_dialogue_active = false
		dialogue_box.visible = false
		
func tween_dialogue():
	
	var durationMod = label.text.length() * dialogue_read_rate
	
	if dialogue_tween:
		dialogue_tween.kill()

	dialogue_tween = create_tween()
	dialogue_tween.set_trans(Tween.TRANS_LINEAR)
	dialogue_tween.tween_property(label, "visible_ratio", 1.0, durationMod).set_trans(Tween.TRANS_LINEAR)
