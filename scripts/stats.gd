extends VBoxContainer

@onready var applausescounter: Label = $applausescounter

func _on_game_app_update(counter) -> void:
	if str(counter) == "1":
		applausescounter.text = str(counter) + " Applause"
	else:
		applausescounter.text = str(counter) + " Applauses"
