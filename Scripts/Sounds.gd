extends AudioStreamPlayer

var sounds = [preload("res://Sound/SCD_FM_02.wav")]
@onready
var mySon = $MySon

func loadSound(path):
	sounds.append(load(path))

func playSound(id):
	mySon.reparent(get_tree().current_scene)
	mySon.stream = sounds[id]
	mySon.play()
	
