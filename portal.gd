extends Area2D

@onready var punto_salida = $"Punto de salida"
@onready var sonido_teleport = $SonidoTP

static var bloqueado_global = false 

func _on_body_entered(body):
	# Verificamos que sea el jugador y que el portal no esté en cooldown
	if body.name.to_lower().contains("jugador") and not bloqueado_global:
		viajar(body)

func viajar(body):
	bloqueado_global = true 
	
	# REPRODUCCIÓN DEL SONIDO
	if sonido_teleport:
		sonido_teleport.play() 
	
	# --- 1. ENTRADA AL PORTAL (Efecto de succión) ---
	if body is RigidBody2D:
		body.freeze = true 
	
	var tween_in = create_tween().set_parallel(true)
	# Se encoge y se mueve al centro del portal
	tween_in.tween_property(body, "scale", Vector2(0, 0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween_in.tween_property(body, "global_position", global_position, 0.4)
	
	await tween_in.finished
	
	# --- 2. TELETRANSPORTE ---
	# Movemos el cuerpo al punto de destino
	body.global_position = punto_salida.global_position
	
	# --- 3. SALIDA (Efecto de aparición) ---
	var tween_out = create_tween()
	tween_out.tween_property(body, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	await tween_out.finished
	
	# --- 4. LANZAMIENTO (El "Escupitajo") ---
	if body is RigidBody2D:
		body.freeze = false 
		# Calculamos la dirección basada en la rotación del punto de salida
		var direccion = Vector2.RIGHT.rotated(punto_salida.global_rotation)
		body.apply_central_impulse(direccion * 1200) # Un poco más de fuerza
	
	# Cooldown para evitar bucles infinitos entre portales
	await get_tree().create_timer(1.0).timeout 
	bloqueado_global = false
