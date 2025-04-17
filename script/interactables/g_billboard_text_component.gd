extends Node3D

signal OnTextBegin
signal OnTextEnd
signal OnTextInterrupted

const mouse_over_prompt = "Press 'E' to speak"

enum state {
	inactive,
	speaking,
	line_finished,
	awaiting_response,
}

#array of g_billboard_passages 
@export var passage_root: Resource
func set_passage_root(new_root):
	passage_root = new_root
	

var player_interacting: Node3D = null

var current_passage: Resource = null
var prev_passage: Resource = null
var index: int = -1

var CurrentText: String = ""
var CurrentCharIdx: int = 0
var current_state: state

var has_late_init = false

const passages_script = preload("res://script/interactables/g_billboard_passages.gd")

func _ready() -> void:
	$CurrentText.text = ""
	$TypewriteTimer.timeout.connect(_write_char)
	%TimeoutTimer.timeout.connect(_reset_self)
		
	index = -1
		

func _process(delta: float) -> void:
	if has_late_init == false:
		current_passage = passage_root
		has_late_init = true

func object_interacted(modifier: int = 0, _player = null) -> void:
	print("Text triggered via interaction with modifer %s" % str(modifier))
	if (player_interacting == null):
		return
		 
	
	if current_state == state.awaiting_response: #Done with current passage
		if modifier == 0 or modifier > current_passage.Options.size(): return #if modifier is invalid.
		current_passage = current_passage.Options[modifier-1]
		current_state = state.speaking
		index = -1
		player_interacting.clear_player_input_prompt()
		continue_text()
	#if current_state == state.line_finished or current_state == state.inactive: #Not done with current passage
	else:
		current_state = state.speaking
		continue_text()

func begin_text():
	
	OnTextBegin.emit()
	_write_char()
	$TypewriteTimer.start()
	
func continue_text():
	if !current_passage:
		current_passage = create_errorproofer_passage()
	
	current_state = state.speaking
	CurrentText = ""
	$TypewriteTimer.stop()
	index += 1
	CurrentCharIdx = 0
	if index < current_passage.Passages.size():
		begin_text()
	else:	end_text()
	
func end_text():
	if current_passage.branch_end:
		_reset_self()
		OnTextEnd.emit()
	else:
		var lines= ""
		var range = current_passage.Options.size()
		range = range if range < 5 else 5
		for i in range(0, range):
			lines += "%s: %s\n" % [str(i+1), current_passage.Options[i].SelectionText]
		
		player_interacting.set_player_input_prompt(lines)
		current_state = state.awaiting_response

func _write_char():
	CurrentText += current_passage.Passages[index][CurrentCharIdx]
	$CurrentText.text = CurrentText
	CurrentCharIdx += 1
	
	if (CurrentCharIdx == current_passage.Passages[index].length()):
		$TypewriteTimer.stop()
		current_state = state.line_finished
		print("line finished")
				

func create_errorproofer_passage() -> Resource:
	var prev_pass_str = "null"
	if (prev_passage != null): prev_pass_str = prev_passage.name
	var msg: Array[String] = [
		"Oh, I seem to have misplaced my script. Goodness, this is embarassing!",
	 	"Please tell Hex about this, she can make me a new one.", 
		"You may want to screenshot this next bit for her.",
		"ACTOR: %s, PREV_LINES: %s, UUID: %s" % [name, prev_pass_str, str(get_instance_id()),],
		"*Suddenly, you hear Hex's voice...*",
		"\"And don't forget to say Thank You on the way out!\""
		]
	
	var t = Resource.new()
	t.set_script(passages_script)
	t.branch_end = true
	t.set_passages(msg)
	return t
	
func player_mouseover(player):
	if current_state == state.inactive:
		$CurrentText.text = mouse_over_prompt
	%TimeoutTimer.stop()
	player_interacting = player

func player_mouseover_end(player):
	if current_state == state.inactive:
		$CurrentText.text = ""
	%TimeoutTimer.start()
	if state.inactive:
		player_interacting = null

func _reset_self():
	index = -1
	CurrentCharIdx = 0
	prev_passage = current_passage
	current_passage = passage_root
	current_state = state.inactive
	$CurrentText.text = ""
	player_interacting = null
