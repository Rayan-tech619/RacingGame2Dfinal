extends Area2D

# Referencias a nodos hijos
@onready var punto_salida = $"Punto de salida"
@onready var sonido_teleport = $SonidoTP

# Variable de control local (cada portal tiene la suya)
var bloqueado = false 

func _on_body_entered(body):
	# Verificamos que el nombre contenga "jugador" y que este portal no esté en cooldown
	if body.name.to_lower().contains("jugador") and not bloqueado:
		viajar(body)

func viajar(body):
	bloqueado = true 
	
	# REPRODUCCIÓN DEL SONIDO
	if sonido_teleport:
		sonido_teleport.play() 
	
	# --- 1. ENTRADA AL PORTAL (Efecto de succión) ---
	if body is RigidBody2D:
		body.freeze = true 
	
	var tween_in = create_tween().set_parallel(true)
	# Se encoge y se mueve al centro del portal actual
	tween_in.tween_property(body, "scale", Vector2(0, 0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween_in.tween_property(body, "global_position", global_position, 0.4)
	
	await tween_in.finished
	
	# Verificamos que el jugador no haya sido eliminado durante la espera
	if not is_instance_valid(body): 
		bloqueado = false
		return

	# --- 2. TELETRANSPORTE ---
	# Posicionamos al jugador en el destino
	body.global_position = punto_salida.global_position
	
	# --- 3. SALIDA (Efecto de aparición) ---
	var tween_out = create_tween()
	tween_out.tween_property(body, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	await tween_out.finished
	
	# --- 4. LANZAMIENTO (El "Escupitajo") ---
	if is_instance_valid(body) and body is RigidBody2D:
		body.freeze = false 
		# Dirección basada en la rotación del Punto de Salida
		var direccion = Vector2.RIGHT.rotated(punto_salida.global_rotation)
		body.apply_central_impulse(direccion * 1200) 
	
	# Cooldown de 1 segundo para este portal específico
	await get_tree().create_timer(1.0).timeout 
	bloqueado = false
