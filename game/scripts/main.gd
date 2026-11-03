extends Node3D

func _ready() -> void:
	var resource: DialogueResource = load("res://dialogue/welcome.dialogue")
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, "start")
	if line == null:
		push_error("Welcome dialogue failed to load")
		get_tree().quit(1)
		return
	$UI/Title.text = "DREAMLAND\n" + line.text
	print("Dreamland: GLB scene and dialogue ready")
