extends Node3D

signal OnTextBegin
signal OnTextEnd

#array of g_billboard_passages 
@export var DiaPassages: Resource
var index: int = -1

var CurrentText: String = ""
var CurrentCharIdx: int = 0

var line_finished = false

const passages_script = preload("res://script/interactables/g_billboard_passages.gd")

func _ready() -> void:
	$CurrentText.text = ""
	$Timer.timeout.connect(_write_char)
	
	if !DiaPassages:
		var msg: Array[String] = [
			"Oh, I seem to have misplaced my script. Goodness, this is embarassing!",
		 	"Please tell Hex about this, she can make me a new one.", 
			"You may want to screenshot this next bit for her.",
			"ACTOR: %s, PREV_SCRIPT: %s, UUID: %s" % [name, "%TODO!!!%", str(get_instance_id()),],
			"*Suddenly, you hear Hex's voice...*",
			"\"And don't forget to say Thank You on the way out!\""
			]
		
		var t = Resource.new()
		t.set_script(passages_script)
		t.branch_end = true
		t.set_passages(msg)
		DiaPassages = t

func object_interacted() -> void:
	print("Text triggered via interaction")
	continue_text()

func begin_text():
	OnTextBegin.emit()
	_write_char()
	$Timer.start()
	
func continue_text():
	line_finished = false
	CurrentText = ""
	$Timer.stop()
	index += 1
	CurrentCharIdx = 0
	if index < DiaPassages.Passages.size():
		begin_text()
	else:		end_text()
	
func end_text():
	if DiaPassages.branch_end:
		$CurrentText.text = ""
		OnTextEnd.emit()
	else:
		var lines= ""
		for i in range(0, DiaPassages.Options.size()):
			lines += "%s\n" % DiaPassages.Options[i]
		print(lines)

func _write_char():
	CurrentText += DiaPassages.Passages[index][CurrentCharIdx]
	$CurrentText.text = CurrentText
	CurrentCharIdx += 1
	
	if (CurrentCharIdx == DiaPassages.Passages[index].length()):
		$Timer.stop()
		line_finished = true
		if line_finished:
			print("line finished")
				
