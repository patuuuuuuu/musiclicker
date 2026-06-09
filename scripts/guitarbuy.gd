extends TextureButton

<<<<<<< Updated upstream
@onready var preco_atual = $preco

var compravel = false

=======
>>>>>>> Stashed changes
func _ready() -> void:
	$escurecer.modulate.a = 0.6
	
func _on_game_app_update(counter) -> void:
	if counter >= 1200:
		$escurecer.modulate.a = 0.0
<<<<<<< Updated upstream
		compravel = true

func _on_pressed() -> void:
	if compravel:
		preco_atual.text = " -"
=======
>>>>>>> Stashed changes
