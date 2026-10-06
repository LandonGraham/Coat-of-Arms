extends CanvasLayer


@onready var dialogue_box: Control = $DialogueBox
@onready var label: RichTextLabel = $DialogueBox/Label
@onready var speaker_name_label: Label = $"DialogueBox/Speaker Name Label"
@onready var portrait: TextureRect = $DialogueBox/PortraitLeft
@onready var background: Sprite2D = $DialogueBox/Background
@onready var upper: Sprite2D = $DialogueBox/Upper
@onready var lower: Sprite2D = $DialogueBox/Lower
@onready var speaker_name_background: TextureRect = $"DialogueBox/Speaker Name Background"

var dialogue_read_rate: float = 0.025
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
	speaker_name_background.visible = false
	
	var test_dialogue: Array[DialogueLine]
	#
	test_dialogue = parse_dialogue_string("""
	"As his companions Bode and Zarislov engaged the bandits, Spyros drew his own sword, readying himself to join the fray. As he looked around at their assailants, he spied a woman among them, a dark haired youth sporting a bow in her hands and a sword at her hip."
[Spyros, Neutral] "Hark, woman! I should prefer not to harm you. Lay down your weapon and go in peace!"
[Elsbeth, Neutral] "I would just as little enjoy killing a Brother of the cloth."
[Spyros, Surprised] "A respect for the faith is a rare trait to see in a bandit."
[Elsbeth, Angry] "I- You mistake me, Brother. I am no bandit, not like these others."
[Spyros, Surprised] "A prisoner then? Or God forbid, you do not mean to say you are their slave?" 
[Elsbeth, Sad] "No- no, not that. I only meant that- I haven't the time to explain it all! I'm only here because I haven't another choice."
[Spyros, Sad] "I should hope that is also the case for your companions, then."
[Elsbeth, Angry] "I would not extend your sympathy to them. They wanted to kill you, and the other priests you travel with."
[Spyros, Neutral] "Not your friends then, I take it?"
[Elsbeth, Angry] "Friends? Hardly. Wish you priests had arrived sooner, I might not be in this mess."
[Spyros, Neutral] "Tell me then, how does a woman find herself in such company?"
[Elsbeth, Sad] "Not happily. I'm running from someone. I'm a good shot, and these bandits offer protection enough." 
[Spyros, Happy] "It is the faithful's sworn duty to protect women. Quiver your arrow and retreat behind our lines, and should this 'someone' arrive looking for you, you will be under my protection."
[Elsbeth, Happy] "Better that I help you rout them. As I said, I know how to use this bow." 
[Spyros, Surprised] "It would not be right to ask you to fight, my lady."
[Elsbeth, Angry] "These are dangerous men, Brother, and you are greatly outnumbered! Now is not the time to worry about my safety compared to your own!"
[Spyros, Neutral] "...Very well, but- Do try to stay behind the rest of us."
"Queue Chapter 1 or 2 or whenever this dialogue would take place in the story. Just use your imagination and picture gameplay here."
[Spyros, Neutral] "I apologize for that violent display you found yourself in. Are you alright?"
"Elsbeth did not seem to hear his question, and for a moment she paced around the field, observing the bodies of her former companions."
[Elsbeth, Sad] "I only wish that they would have heeded me from the beginning."
[Spyros, Neutral] "Violence is never our first instinct. Killing, even less so."
[Elsbeth, Sad] "Of that I have no doubt. I should be thanking you, I suppose. I cannot call them 'friends', not in truth."
[Spyros, Neutral] "My name is Spyros. I am a Brother of Uller Friary, along with my companions Bode and Zarislov."
[Elsbeth, Sad] "...Elsbeth."
[Spyros, Neutral] "If I may ask, what drove you to the company of these ruffians?"
"Elsbeth sighed, and began idly playing with the pommel of the sword she wore at her hip."
[Elsbeth, Neutral] "My family are farmers. Our homestead was maybe ten or fifteen leagues from here. The land we work is rich with game, so my brothers taught me how to hunt with a bow. My mother died when I was young, so I never really had someone to teach me homemaking."
"She seemed to suddenly quiet and look down towards the ground."
[Spyros, Sad] "I am sorry to hear of your mother. I would not wish to deprive your family of a daughter as well, though. Perhaps we might return to your homestead, if your father could accomodate us. Bode and I could even give you some lessons on cooking and cleaning that you aren't like to pick up teaching yourself."
[Elsbeth, Angry] "What? No, that isn't- I have little desire to return there. Allow me to continue, Brother. My father cared little for me. To a family of isolated farmers, a girl was of no use. My father hoped he might find someone more well off than us to marry me to."
[Spyros, Neutral] "Marrying is a daughter's duty. A lovely maiden like you would have commanded a hefty dowry, I am certain." 
[Elsbeth, Angry] "Well, my father shared that hope. He'd offer me up to anyone who rode by. Old men, married men, it made no difference. One day, a man in a shiny cuirass was staying with us for a night. He said he was a knight, and was on his way west to serve some lordling. He had this badge, or maybe it was a medal. Whatever it was, my father could not take his eyes off of it. I think it might have been an old war trophy. My father offered the knight my hand in marriage for the medal."
[Spyros, Sad] "I gather that he did not accept. Unfortunate, then. It would be quite a beneficial arrangement for a serf's daughter to wed a knight."
[Elsbeth, Neutral] "The unfortunate part is that he [i]did[/i] accept. He grabbed me by the chin and looked me up and down, said he liked the look of me. He said 'Serving my new lord, I can afford a second wife.'"
"Elsbeth studied Spyros's expression, and found he was entirely unsurprised by the notion of having more than one wife. She must have been staring awkwardly at him for a moment, as Spyros briefly glanced to check and see if something was behind him."
[Spyros, Neutral] "Is that... a distasteful notion to you?" 
"Elsbeth opened her mouth with an angry expression, but stopped herself before she spoke. With a sigh, her face turned to dejection."
[Elsbeth, Sad] "I know that noblemen take more than one wife, here or there, but that simply isn't something that happens in my walk of life. But, no, I suppose that wasn't what upset me. He asked me if I was obedient- said he hated how often he had to discipline his lady wife already."
"Spyros did not say anything in response to that, electing instead to let her finish before he spoke again."
[Elsbeth, Angry] "He was already drunk by the time he arrived, and he uncorked a bottle of our wine without asking. He was brusque and mean and sour and old. I didn't want to be his first wife, much less his second. He was too drunk to pay me any more attention before passing out in our stable. My father kept telling me about how I needed to do anything he told me, that it was what God intended for me, and that this was the best thing I could do to help the family. That night, I slipped the knight's sword from his scabbard and ran away."
"She let her hand slip off of the sword's pommel, a flash of guilt present in her eyes."
[Spyros, Neutral] "...I see."
[Elsbeth, Sad] "Well, I guess after that I had nowhere to go. I just walked south, and eventually fell in with those men you fought."
[Spyros, Neutral] "I cannot speak to whether or not God intended you to wed that knight. But, what I do know, is that he [i]was[/i] a knight. He is owed deference by his lessers."
[Elsbeth, Angry] "Deference!? Just what is it that you're saying, Brother!?"
[Spyros, Angry] "A serf's daughter cannot simply steal a knight's blade. You are a woman grown, so it is your right to deny him your hand if that is your wish. But thievery, well, that is another thing entirely."
[Elsbeth, Angry] "What do rights have to do with it? What do [i]you[/i] think would happen if I had denied him? That my father would tell me he loves me, regardless of it all? Do you not see I had no other options?"
[Spyros, Neutral] "Please, do not mistake my meaning. Yes, I realize now that your taking of that sword was a mistake made under duress. I am not the one you wronged, but I forgive you for it all the same."
"Elsbeth pouted and turned her head away from Spyros. She slowly drew the blade from her hip and slowly began turning it over in her hands, getting a feel for the weight."
[Elsbeth, Sad] "I figured I could sell it for a handsome sum... But... I do not want to be a sinner, not really."
"After taking another shameful look at the blade, Elsbeth wordlessly flipped it around in her hand and tentatively offered the hilt to Spyros. The young friar accepted it with jubilance, and offered her a smile as recompense."
[Spyros, Happy] "I shall sever you from this burden. Fret not, my dear maid. Returning home may not be your desire, but there are other options."
[Spyros, Sad] "In truth, I too cannot return to my home."
[Elsbeth, Surprised] "You mean the friary?"
[Spyros, Sad] "Yes. It has been my home for more than half my life, but now... I am being tested, it seems. It is not always easy to know which path to take. You must trust in God, yes, but that trust must not come at the expense of your trust in yourself. And so, I carry on."
[Elsbeth, Neutral] "Brother, if you do not mind me asking... Where are you from? You are not from here, I should think."
[Spyros, Happy] "What gave you that impression?"
[Elsbeth, Happy] "Well, you are... Very, very pale."
"Spyros's smile faded somewhat at that, and his eyes narrowed. An unconscious defense, and one luckily unnoticed by Elsbeth."
[Elsbeth, Happy] "My father told me that the people of Ibin have skin as brown as dirt, with characters to match. But I've never seen an Ibinese person before. Though if Ibin is dark, then surely you must come from the north."
"Spyros was almost charmed by her naive reasoning. He knew he should not lie to her, but he hardly wanted to burden her with the truth of his affliction either."
[Spyros, Neutral] "Thesigia, originally. Yes, it is to the north."
[Elsbeth, Happy] "If the friary is lost to you, will you be returning to Thesigia?"
[Spyros, Sad] "I did not think I would ever say it, but yes, I suppose I do intend to return." 
[Elsbeth, Happy] "I want to make up for all of this. The stealing, the bandits. I think it would be better to do so with a man of the cloth rather than by my lonesome. Would you accept my company in your travels?"
"Spyros rubbed his chin in contemplation. His instincts were screaming at him to refuse her, but her story had moved his heart."
[Spyros, Happy] "I would be remiss not to once again emphasize the danger in accompanying me. You are skilled with that bow, I know, but a warrior you are not."
[Elsbeth, Happy] "I would not have lasted in a group of bandits if I could not take care of myself. I insist, you haven't a thing to worry about with me." 
[Spyros, Happy] "Then you are welcome, Elsbeth. I am Spyros Kokontos. Come, I shall introduce you to the others."
""")


	#start_dialogue(test_dialogue)
	
func start_dialogue(lines: Array[DialogueLine]):
	# Pause the game
	get_tree().paused = true
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
		speaker_name_background.visible = true
	else:
		portrait.texture = null
		portrait.visible = false
		upper.visible = false
		lower.visible = false
		background.visible = false
		speaker_name_background.visible = false
		speaker_name_label.text = " "
	
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
			
#func split_dialogue_if_needed(lines: Array[DialogueLine]) -> Array[DialogueLine]:
	#var split_lines: Array[DialogueLine] = []
	#var max_chars = 150
	#var new_line = ""
	#
	#for line in lines:
		#var words = line.text.split(" ")
		#for word in words:
			#if (new_line + word).length() > max_chars:
				#new_line += "-"
				#split_lines.append(DialogueLine.new(line.speaker, new_line, line.position, line.expression))
				#new_line = "-"
				#new_line += word
				#new_line += " "
			#else:
				#new_line += word
				#new_line += " "
		#split_lines.append(DialogueLine.new(line.speaker, new_line, line.position, line.expression))
		#new_line = ""
	#
	#return split_lines
	
func split_dialogue_if_needed(lines: Array[DialogueLine]) -> Array[DialogueLine]:
	var split_lines: Array[DialogueLine] = []
	var max_chars = 150
	
	for line in lines:
		# Split by sentences (periods, exclamation marks, question marks)
		var sentences = []
		var current_sentence = ""
		var is_narrator: bool = line.speaker == null
		
		for char in line.text:
			current_sentence += char
			if char in ['.', '!', '?']:
				sentences.append(current_sentence.strip_edges())
				current_sentence = ""
		
		# Add any remaining text
		if current_sentence.strip_edges() != "":
			sentences.append(current_sentence.strip_edges())
		
		# Now combine sentences into lines
		var new_line = ""
		for sentence in sentences:
			if (new_line + " " + sentence).length() <= max_chars and new_line != "":
				new_line += " " + sentence
			else:
				if new_line != "":
					if is_narrator:
						new_line = "[i]" + new_line + "[/i]"
					split_lines.append(DialogueLine.new(line.speaker, new_line, line.position, line.expression))
				new_line = sentence
		
		# Append final line
		if new_line != "":
			if is_narrator:
				new_line = "[i]" + new_line + "[/i]"
			split_lines.append(DialogueLine.new(line.speaker, new_line, line.position, line.expression))
	
	
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
		else:
			var narrator_regex = RegEx.new()
			narrator_regex.compile(r"\"([^\"]*)\"")
			var narrator_match = narrator_regex.search(entry)
			if narrator_match:
				var text = narrator_match.get_string(1)
				lines.append(DialogueLine.new(null, text, "left", "neutral"))
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
