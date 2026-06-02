extends ColorRect

@onready var posicionando = $"../../.."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if posicionando.instrumento_sendo_posicionado:
		$".".modulate.a = 0.5
	else:
		$".".modulate.a = 0.0
