extends Node3D

signal OnTextBegin
signal OnTextEnd

@export
var DiaPassages: Array[String]
var index: int = -1

var CurrentText: String = ""
var CurrentCharIdx: int = 0

func _ready() -> void:
	$CurrentText.text = ""
	$Timer.timeout.connect(_write_char)

func object_interacted() -> void:
	print("Text triggered via interaction")
	continue_text()

func begin_text():
	OnTextBegin.emit()
	_write_char()
	$Timer.start()
	
func continue_text():
	CurrentText = ""
	$Timer.stop()
	index += 1
	CurrentCharIdx = 0
	if index < DiaPassages.size():
		begin_text()
	else:		end_text()
	
func end_text():
	$CurrentText.text = ""
	OnTextEnd.emit()

func _write_char():
	CurrentText += DiaPassages[index][CurrentCharIdx]
	$CurrentText.text = CurrentText
	CurrentCharIdx += 1
	
	if (CurrentCharIdx == DiaPassages[index].length()):
		$Timer.stop()
