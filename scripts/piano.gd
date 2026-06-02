extends Sprite2D

@onready var posicionando = $"../.."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if posicionando.instrumento_sendo_posicionado:
		if posicionando.instrumento_sendo_posicionado == self:
			if not posicionando.esta_na_area_permitida():
				modulate = Color.RED
			else:
				modulate = Color.WHITE
		else:
			pass
