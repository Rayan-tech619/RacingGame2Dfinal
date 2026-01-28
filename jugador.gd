extends RigidBody2D

# VARIABLES
var ruedas = []
var velocidad = 30000        # torque de ruedas
var fuerza_aerea = 1500000   # torque en el aire
@export var fuerza_salto = 300  # fuerza de salto ajustable
var jump = false              # para detectar salto

func _ready():
	# Agarrar todas las ruedas del grupo "ruedas"
	ruedas = get_tree().get_nodes_in_group("ruedas")

func _physics_process(delta):
	# --- INPUTS ---
	var right = Input.is_action_pressed("ui_right")
	var left  = Input.is_action_pressed("ui_left")
	jump = Input.is_action_just_pressed("salto")   # ESPACIO para saltar

	# --- MOVIMIENTO RUEDAS ---
	if right:
		for r in ruedas:
			r.apply_torque_impulse(velocidad * delta * 60)
	if left:
		for r in ruedas:
			r.apply_torque_impulse(-velocidad * delta * 60)

	# --- VOLTERETAS EN EL AIRE ---
	if not _en_suelo():
		if left:
			apply_torque_impulse(-fuerza_aerea * delta)
		if right:
			apply_torque_impulse(fuerza_aerea * delta)

	# --- SALTO ---
	if jump and _en_suelo():
		sleeping = false
		linear_velocity.y = -fuerza_salto

	# --- RESET SI SE VOLTEA ---
	if Input.is_action_just_pressed("reset_car"):
		rotation = 10
		angular_velocity = 20
		linear_velocity = Vector2.ZERO
		position.y -= 10   # levantar ligeramente para no chocar con el suelo


# --- FUNCIONES AUXILIARES ---

# Detecta si las ruedas están tocando el suelo
func _en_suelo():
	for r in ruedas:
		if r.get_contact_count() > 0:
			return true
	return false
