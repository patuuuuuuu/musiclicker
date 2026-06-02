extends TextureButton

func _ready() -> void:
	$escurecer.modulate.a = 0.6
	
func _on_game_app_update(counter) -> void:
	if counter >= 100:
		$escurecer.modulate.a = 0.0
