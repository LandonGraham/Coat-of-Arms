extends CanvasLayer


@onready var dialogue_box: Control = $DialogueBox
@onready var label: Label = $DialogueBox/Label
@onready var speaker_name_label: Label = $"DialogueBox/Speaker Name Label"
@onready var portrait: TextureRect = $DialogueBox/PortraitLeft
@onready var background: Sprite2D = $DialogueBox/Background
@onready var upper: Sprite2D = $DialogueBox/Upper
@onready var lower: Sprite2D = $DialogueBox/Lower

var dialogue_read_rate: float = 0.03
var dialogue_tween: Tween

var dialogue_lines: Array[DialogueLine] = []
var current_line_index: int = 0
var is_dialogue_active: bool = false

@export var speaker_one: Character
@export var speaker_two: Character

enum state{inactive, reading, done_reading, waiting_for_input}
var current_state: state

func _ready() -> void:
	current_state = state.inactive
	dialogue_box.visible = false
	background.visible = false
	upper.visible = false
	lower.visible = false
	portrait.texture = null
	
	var test_dialogue: Array[DialogueLine]
	
	test_dialogue = parse_dialogue_string("""[Spyros, Neutral] "Hark, woman! I should prefer not to harm you. Lay down your weapon and go in peace!"
[Elsbeth, Neutral] "I would just as little enjoy killing a Brother of the cloth."
[Spyros, Neutral] "A respect for the faith is a rare trait to see in a bandit."
[Elsbeth, Angry] "I- You mistake me, Brother. I am no bandit, not like these others."
[Spyros, Angry] "A prisoner then? Or God forbid, you do not mean to say you are their slave?" 
[Elsbeth, Surprised] "No- no, not that. I only meant that- well, that I'm only here because I haven't another choice."
[Spyros, Sad] "I should hope that is also the case for your companions, then."
[Elsbeth, Angry] "I would not extend your sympathy to them. They wanted to kill you, and the other priests you travel with."
[Spyros, Neutral] "Tell me then, how does a woman find herself in such company?"
[Elsbeth, Sad] "I'm running from someone who seeks to do me harm. I'm a good shot with a bow, so I found a place here." 
[Spyros, Happy] "It is the faithful's sworn duty to protect women. Quiver your arrow and retreat behind our lines, and should this 'someone' arrive looking for you, you will be under my protection."
[Elsbeth, Happy] "Better that I help you defeat them. As I said, I know how to use this bow." 
[Spyros, Surprised] "It would not be right to ask you to fight, my lady."
[Elsbeth, Angry] "These are dangerous men, Brother, and you are greatly outnumbered! Now is not the time to worry about my safety compared to your own!"
[Spyros, Neutral] "...Very well, but- Do try to stay behind the rest of us."
""")

	start_dialogue(test_dialogue)
	
func start_dialogue(lines: Array[DialogueLine]):
	# Pause the game
	get_tree().paused = false
	dialogue_lines = lines
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
	
	#update_portraits(current_line)
	
	label.text = current_line.text
	label.visible_ratio = 0.0
	
	current_state = state.reading
	
	update_portraits(current_line)
	tween_dialogue()
	
func update_portraits(current_line: DialogueLine):
	if current_line.speaker:
		# Get the portrait texture based on expression
		var portrait_texture = get_portrait_by_expression(current_line.speaker, current_line.expression)
		portrait.texture = portrait_texture
		portrait.visible = true
		upper.visible = true
		lower.visible = true
		background.visible = true
	else:
		portrait.texture = null
	
func get_portrait_by_expression(character: Character, expression: String) -> Texture2D:
	match expression.to_lower():
		"neutral":
			return character.Neutral
		"happy":
			return character.Happy
		"sad":
			return character.Sad
		"angry":
			return character.Angry
		"surprised":
			return character.Surprised
		"blush":
			return character.Blush
		_:
			return character.Neutral
			
func split_dialogue_if_needed(lines: Array[DialogueLine]) -> Array[DialogueLine]:
	var split_lines: Array[DialogueLine] = []
	var max_chars = 150
	var new_line = ""
	
	for line in lines:
		var words = line.text.split(" ")
		for word in words:
			if (new_line + word).length() > max_chars:
				new_line += "-"
				split_lines.append(DialogueLine.new(line.speaker, new_line, line.position, line.expression))
				new_line = "-"
				new_line += word
				new_line += " "
			else:
				new_line += word
				new_line += " "
		split_lines.append(DialogueLine.new(line.speaker, new_line, line.position, line.expression))
		new_line = ""
	
	return split_lines
	
func parse_dialogue_string(dialogue_text: String) -> Array[DialogueLine]:
	var lines: Array[DialogueLine] = []
	
	# Split by newlines to get individual dialogue entries
	var entries = dialogue_text.split("\n")
	
	for entry in entries:
		entry = entry.strip_edges()
		if entry.is_empty():
			continue
		
		# Match pattern: [Speaker, Expression] "Text"
		var regex = RegEx.new()
		regex.compile(r"\[([^\],]+),\s*([^\]]+)\]\s*\"([^\"]*)\"")
		
		var match = regex.search(entry)
		if match:
			var speaker_name = match.get_string(1).strip_edges()
			var expression = match.get_string(2).strip_edges()
			var text = match.get_string(3)
			
			# Find the character by name
			var speaker = find_character_by_name(speaker_name)
			
			# Determine position (alternate left/right, or based on character)
			var position = "left" if lines.size() % 2 == 0 else "right"
			
			lines.append(DialogueLine.new(speaker, text, position, expression))
	return split_dialogue_if_needed(lines)

func find_character_by_name(name: String) -> Character:
	# Search your scene for a character with matching name
	var root = get_tree().root
	return find_character_recursive(root, name)

func find_character_recursive(node: Node, name: String) -> Character:
	if node is Character and node.firstName == name:
		return node
	
	for child in node.get_children():
		var result = find_character_recursive(child, name)
		if result:
			return result
	
	return null
	
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
	await dialogue_tween.finished
	current_state = state.done_reading
