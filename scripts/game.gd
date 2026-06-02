extends Control
#SAVE
const save_path = "user://userdata.save"
#BASE
var applauses = 0
var app_per_click = 10

signal app_update

#SFX
@onready var sfx_clap_1: AudioStreamPlayer = $sfx/sfx_clap1
@onready var sfx_clap_2: AudioStreamPlayer = $sfx/sfx_clap2
@onready var sfx_clap_3: AudioStreamPlayer = $sfx/sfx_clap3
@onready var sfx_clap_4: AudioStreamPlayer = $sfx/sfx_clap4
@onready var sfx_clap_5: AudioStreamPlayer = $sfx/sfx_clap5

#MUSICA
var bpm = 120
var bps = 60.0 / bpm
var instrumentos_ativos = []

#INSTRUMENTOS
@onready var area_limite = $AreaPosicionamento
@onready var container_instrumentos = $instrumentos
@onready var molde_piano = $instrumentos/piano
@onready var molde_bass = $instrumentos/bass

var instrumento_sendo_posicionado = null

var tem_piano = false
var tem_bass = false

#FUNCTIONS
func _ready() -> void:
	#esconder moldes de instrumentos
	molde_piano.visible = false
	molde_bass.visible = false
	
	#load_data()
	emit_signal("app_update", applauses)
	

func save_data():
	
	var instrumentos_salvos = []
	var ativos = get_tree().get_nodes_in_group("instrumentos_ativos")
	
	for instr in ativos:
		if instr != molde_piano and instr != molde_bass:
			# Busca a etiqueta que colocamos. Se não achar, ignora ou avisa.
			var tipo = instr.get_meta("tipo_instrumento", "desconhecido")
			
			if tipo != "desconhecido":
				var info = {
					"pos_x": instr.position.x,
					"pos_y": instr.position.y,
					"tipo": tipo
				}
				instrumentos_salvos.append(info)
			
	var data = {
		"applauses": applauses,
		"tem_piano": tem_piano,
		"tem_bass": tem_bass,
		"app_per_click": app_per_click,
		"instrumentos_salvos": instrumentos_salvos,
		
	}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(data)
	file.close()
	
func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data = file.get_var()
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			applauses = data.get("applauses", 0)
			tem_piano = data.get("tem_piano", false)
			tem_bass = data.get("tem_bass", false)
			app_per_click = data.get("app_per_click", 1)
			
			# Recriar os instrumentos nas posições salvas
			var salvos = data.get("instrumentos_salvos", [])
			for item in salvos:
				recriar_instrumento_salvo(item)
			
	else:
		save_data()
		
#RECRIAR INSTRUMENTOS JA COMPRADOS
func recriar_instrumento_salvo(dados):
	var novo_instr
	if dados["tipo"] == "piano":
		novo_instr = molde_piano.duplicate()
		novo_instr.set_meta("tipo_instrumento", "piano")
	else:
		novo_instr = molde_bass.duplicate()
		novo_instr.set_meta("tipo_instrumento", "bass")
	
	novo_instr.visible = true
	container_instrumentos.add_child(novo_instr)
	novo_instr.position = Vector2(dados["pos_x"], dados["pos_y"])
	novo_instr.add_to_group("instrumentos_ativos")
	
	# Play no áudio correto
	novo_instr.get_node("AudioStreamPlayer").play()
	
#UPDATEAR APLAUSOS
func update_applauses():
	emit_signal("app_update", applauses)

#APLAUDIR LOGICA
func applaude():
	applauses += app_per_click
	update_applauses()
	save_data()
	
	#SFX
	var whichclap = randi_range(1, 5)
	
	if whichclap == 1:
		sfx_clap_1.pitch_scale = randf_range(0.9, 1.1)
		sfx_clap_1.play()
	if whichclap == 2:
		sfx_clap_2.pitch_scale = randf_range(0.9, 1.1)
		sfx_clap_2.play()
	if whichclap == 3:
		sfx_clap_3.pitch_scale = randf_range(0.9, 1.1)
		sfx_clap_3.play()
	if whichclap == 4:
		sfx_clap_4.pitch_scale = randf_range(0.9, 1.1)
		sfx_clap_4.play()
	if whichclap == 5:
		sfx_clap_5.pitch_scale = randf_range(0.9, 1.1)
		sfx_clap_5.play()

#APLAUDIR CLICK
func _on_click_button_down() -> void:
	if not instrumento_sendo_posicionado:
		applaude()
		#applauses += 50000
	
#NOVO INSTRUMENTO
func adicionar_instrumento(novo_instrumento):
	
	novo_instrumento.add_to_group("instrumentos_ativos")
	
	var player = novo_instrumento.get_node("AudioStreamPlayer")
	
	# Sincroniza o novo som com o tempo decorrido do primeiro som que já estiver tocando
	var ativos = get_tree().get_nodes_in_group("instrumentos_ativos")
	
	if ativos.size() > 0:
		var tempo_atual = ativos[0].get_node("AudioStreamPlayer").get_playback_position()
		player.play(tempo_atual)
	else:
		player.play()
	
	novo_instrumento.add_to_group("instrumentos_ativos")
	if not instrumentos_ativos.has(novo_instrumento):
		instrumentos_ativos.append(novo_instrumento)

func _process(_delta):
	
	if instrumento_sendo_posicionado:
		instrumento_sendo_posicionado.global_position = get_global_mouse_position()
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if esta_na_area_permitida():
				adicionar_instrumento(instrumento_sendo_posicionado)
				instrumento_sendo_posicionado = null

func esta_na_area_permitida() -> bool:
	
	var mouse_pos = get_global_mouse_position()
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collision_mask = 2
	query.collide_with_areas = true
	
	var resultado = space_state.intersect_point(query)
	
	return resultado.size() > 0
	
func finalizar_posicionamento():
	var audio = instrumento_sendo_posicionado.get_node("AudioStreamPlayer")
	
	#SINCRONIZAR
	var ativos = get_tree().get_nodes_in_group("instrumentos_ativos")
	
	if ativos.size() > 0:
		var tempo_atual = ativos[0].get_node("AudioStreamPlayer").get_playback_position()
		audio.play(tempo_atual)
	else:
		audio.play()
	
	instrumento_sendo_posicionado.add_to_group("instrumentos_ativos")
	instrumento_sendo_posicionado = null

#COLOCAR INSTRUMENTOS
func _on_pianobuy_pressed() -> void:
	
	if applauses >= 100 and not tem_piano:
		var novo_piano = molde_piano.duplicate()
		novo_piano.set_meta("tipo_instrumento", "piano") # ETIQUETA AQUI
		novo_piano.visible = true
		container_instrumentos.add_child(novo_piano)
		instrumento_sendo_posicionado = novo_piano
		tem_piano = true
		applauses -= 100
		app_per_click += 1
		update_applauses()

func _on_bassbuy_pressed() -> void:

	if applauses >= 300 and not tem_bass:
		var novo_bass = molde_bass.duplicate()
		novo_bass.set_meta("tipo_instrumento", "bass") # ETIQUETA AQUI
		novo_bass.visible = true
		container_instrumentos.add_child(novo_bass)
		instrumento_sendo_posicionado = novo_bass
		tem_bass = true
		applauses -= 300
		app_per_click += 3
		update_applauses()
		
