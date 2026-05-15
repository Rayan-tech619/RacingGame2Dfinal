extends RigidBody2D

# =====================
# VARIABLES DE DISPARO
# =====================
@export var misil_escena = preload("res://misil.tscn")
var puede_disparar = true 

@onready var punto_disparo = get_node_or_null("CarBody/PuntoDisparo")
# --- SISTEMA DE AUDIO ---
@onready var sfx_explosion = $sfx_explosion  # Añade esta línea arriba
@onready var sfx_estatico = $estatico
@onready var sfx_acceleracion = $acceleracion
@onready var sfx_boost = $accelerar2
var ya_esta_sonando = false

# =====================
# VARIABLES DE MOVIMIENTO
# =====================
var ruedas = []
var vivo = true 
var velocidad = 120000
var torque_aire = 1800000     
var torque_suelo = 500000
var fuerza_enderezar = 4000000000 

# 👉 BOOST (Doble Tap original)
var boost_activo = false
var tiempo_boost = 0.0
var duracion_boost = 1.5
var fuerza_boost = 240000

# 👉 DOBLE TAP
var ultimo_tap = 0.0
var ventana_tap = 0.25

# =====================
# READY
# =====================
func _ready():
	if sfx_estatico:
		sfx_estatico.play()
		sfx_estatico.volume_db = 0.0 # Que se escuche el motor encendido
	mass = 17
	gravity_scale = 7
	angular_damp = 3.0 
	
	if has_node("RuedasUnidas1"): ruedas.append($RuedasUnidas1)
	if has_node("RuedasUnidas2"): ruedas.append($RuedasUnidas2)
	
	for r in ruedas:
		if r is RigidBody2D:
			r.can_sleep = false
			r.add_collision_exception_with(self)

# =====================
# PHYSICS (Movimiento y Disparo)
# =====================
func _physics_process(delta):
	if freeze or not vivo: return 

	if Input.is_action_just_pressed("ui_accept") and puede_disparar:
		disparar_misil()

	var right_pressed = Input.is_action_just_pressed("ui_right")
	var right_hold = Input.is_action_pressed("ui_right")
	var left = Input.is_action_pressed("ui_left")

	if right_pressed:
		var ahora = Time.get_ticks_msec() / 1000.0
		if ahora - ultimo_tap < ventana_tap:
			_activar_boost()
		ultimo_tap = ahora

	if boost_activo:
		tiempo_boost -= delta
		if tiempo_boost <= 0: boost_activo = false

	if right_hold:
		for r in ruedas:
			r.apply_torque_impulse(velocidad * delta * 60)
		if boost_activo:
			var fuerza_dir = Vector2(transform.x.x, 0).normalized()
			apply_central_impulse(fuerza_dir * fuerza_boost * delta)
	elif left:
		for r in ruedas:
			r.apply_torque_impulse(-velocidad * delta * 60)

	if right_hold:
		apply_torque_impulse((torque_suelo if _en_suelo() else torque_aire) * delta)
	if left:
		apply_torque_impulse(-(torque_suelo if _en_suelo() else torque_aire) * delta)

	if not _en_suelo() and Input.is_action_pressed("enderezar"):
		var diferencia = wrapf(0 - rotation, -PI, PI)
		apply_torque(diferencia * fuerza_enderezar * delta)

# =====================
# SISTEMA DE MUERTE
# =====================
func _on_detector_de_muerte_area_entered(area: Area2D) -> void:
	if not vivo: return
	var nombre = area.name.to_lower()
	
	if "deteccion" in nombre or "activar" in nombre or "diamante" in nombre or "portal" in nombre or "punto" in nombre:
		return 
	
	if area.name == "BocaColision":
		ser_devorado(area.global_position) 
		return

	explotar()

func explotar():
	if not vivo: return
	var pos_muerte = global_position
	
	# REPRODUCIR SONIDO DE EXPLOSIÓN
	if sfx_explosion:
		sfx_explosion.pitch_scale = randf_range(0.8, 1.2) # Variación aleatoria
		sfx_explosion.play()
	
	_preparar_muerte()
	_aplicar_camara_cinematica(pos_muerte)
	
	var exp = misil_escena.instantiate()
	get_parent().add_child(exp)
	exp.global_position = pos_muerte
	exp.scale = Vector2(8, 8)
	if exp.has_method("explotar"): exp.explotar()
	
	crear_pedacitos_escombros(pos_muerte)
	
	# Detenemos los sonidos del motor para que no sigan sonando tras morir
	sfx_estatico.stop()
	sfx_acceleracion.stop()
	sfx_boost.stop()

	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

func ser_devorado(pos_objetivo):
	if not vivo: return
	var pos_coche = global_position
	_preparar_muerte()
	_aplicar_camara_cinematica(pos_objetivo)
	crear_pedacitos_escombros(pos_coche)

func _aplicar_camara_cinematica(objetivo):
	var cam = get_viewport().get_camera_2d()
	if cam:
		var old_tweens = get_tree().get_processed_tweens()
		for t in old_tweens: t.kill()
		cam.top_level = true
		cam.position_smoothing_enabled = false
		cam.global_position = objetivo
		var tw_cam = create_tween()
		tw_cam.tween_property(cam, "zoom", cam.zoom * 1.03, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func crear_pedacitos_escombros(pos):
	for i in range(12):
		var p = Sprite2D.new()
		if has_node("CarBody"): p.texture = $CarBody.texture
		p.region_enabled = true
		p.region_rect = Rect2(randi()%60, randi()%30, 10, 10)
		get_parent().add_child(p)
		p.global_position = pos
		var tw = create_tween().set_parallel(true)
		var dir = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized() * randf_range(300, 600)
		tw.tween_property(p, "global_position", p.global_position + dir, 0.8).set_trans(Tween.TRANS_QUAD)
		tw.tween_property(p, "modulate:a", 0, 0.8)
		tw.tween_property(p, "scale", Vector2(0,0), 0.8)
		tw.chain().kill()

func _preparar_muerte():
	vivo = false 
	freeze = true
	linear_velocity = Vector2.ZERO 
	angular_velocity = 0
	if has_node("CarBody"): $CarBody.visible = false
	for r in ruedas:
		r.visible = false
		r.process_mode = PROCESS_MODE_DISABLED
	collision_layer = 0
	collision_mask = 0

func _activar_boost():
	boost_activo = true
	tiempo_boost = duracion_boost

func _en_suelo():
	for r in ruedas:
		if r.get_contact_count() > 0: return true
	return false

func disparar_misil():
	if not vivo: return
	puede_disparar = false
	var m = misil_escena.instantiate()
	m.scale = Vector2(5, 5)
	m.global_position = punto_disparo.global_position if punto_disparo else global_position
	m.rotation = rotation
	get_parent().add_child(m)
	await get_tree().create_timer(0.6).timeout
	puede_disparar = true
	
# =====================
# LÓGICA DE AUDIO DINÁMICO
# =====================
func _process(delta):
	if not vivo:
		for s in [sfx_estatico, sfx_acceleracion, sfx_boost]: s.stop()
		return

	var input_acel = Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")

	if input_acel:
		if not ya_esta_sonando:
			sfx_acceleracion.play()
			sfx_boost.play()
			ya_esta_sonando = true

		if boost_activo:
			# --- ESTADO TURBO ---
			# En lugar de subir el pitch a 1.7, lo dejamos en 1.4 pero subimos el volumen
			sfx_boost.volume_db = lerp(sfx_boost.volume_db, 6.0, 0.1) 
			sfx_acceleracion.volume_db = lerp(sfx_acceleracion.volume_db, -30.0, 0.1)
			
			# No subas de 1.4 o 1.5, si no, suena a juguete
			sfx_boost.pitch_scale = lerp(sfx_boost.pitch_scale, 1.45, 0.05)
		else:
			# --- ESTADO NORMAL ---
			sfx_boost.volume_db = lerp(sfx_boost.volume_db, -40.0, 0.1)
			sfx_acceleracion.volume_db = lerp(sfx_acceleracion.volume_db, 2.0, 0.05)
			sfx_acceleracion.pitch_scale = lerp(sfx_acceleracion.pitch_scale, 1.15, 0.02)
			
			# Tono de motor normal
			sfx_acceleracion.pitch_scale = lerp(sfx_acceleracion.pitch_scale, 1.1, 0.02)
	else:
		# --- ESTADO PARADO ---
		sfx_boost.volume_db = lerp(sfx_boost.volume_db, -45.0, 0.05)
		sfx_acceleracion.volume_db = lerp(sfx_acceleracion.volume_db, -45.0, 0.05)
		sfx_estatico.volume_db = lerp(sfx_estatico.volume_db, 0.0, 0.05)
		
		if ya_esta_sonando and sfx_acceleracion.volume_db < -35:
			sfx_acceleracion.stop()
			sfx_boost.stop()
			ya_esta_sonando = false
