extends Area2D

@onready var punto_salida = $"Punto de salida"
@onready var sonido_teleport = $SonidoTP

static var bloqueado_global = false 

func _on_body_entered(body):
	if body.name == "jugador" and not bloqueado_global:
		viajar(body)

func viajar(body):
	bloqueado_global = true 
	
	if sonido_teleport:
		sonido_teleport.play() 
	
	# --- 1. ENTRADA AL PORTAL ---
	if body is RigidBody2D:
		body.freeze = true # Congelamos para evitar que las ruedas se muevan solas
	
	var tween_in = create_tween().set_parallel(true)
	tween_in.tween_property(body, "scale", Vector2(0, 0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween_in.tween_property(body, "global_position", global_position, 0.4)
	
	await tween_in.finished
	
	# --- 2. TELETRANSPORTE INVISIBLE ---
	# Lo movemos al punto de salida pero sigue en escala 0
	body.global_position = punto_salida.global_position
	
	# --- 3. SALIDA (Agrandándose y luego soltando) ---
	var tween_out = create_tween()
	# El coche sale de 0 a 1 de forma elástica
	tween_out.tween_property(body, "scale", Vector2(1, 1), 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Esperamos a que la animación de "agrandarse" casi termine
	await tween_out.finished
	
	# --- 4. ACTIVAR FÍSICAS (El "Escupitajo") ---
	if body is RigidBody2D:
		body.freeze = false # Solo ahora soltamos las ruedas
		# Le damos un pequeño impulso para que no se quede pegado al portal
		var impulso = Vector2.RIGHT.rotated(punto_salida.rotation) * 800
		body.apply_central_impulse(impulso)
	
	# Cooldown para no entrar en bucle
	await get_tree().create_timer(1.5).timeout 
	bloqueado_global = false
