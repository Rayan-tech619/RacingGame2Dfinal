extends RigidBody2D

var ruedas = []
var velocidad = 8000
var fuerza_aerea = 200000   # fuerza alta para volteretas

func _ready():
	ruedas = get_tree().get_nodes_in_group("ruedas")

func _physics_process(delta):
	var right = Input.is_action_pressed("ui_right")
	var left  = Input.is_action_pressed("ui_left")

	# Movimiento normal de ruedas
	if right:
		for r in ruedas:
			r.apply_torque_impulse(velocidad * delta * 60)

	if left:
		for r in ruedas:
			r.apply_torque_impulse(-velocidad * delta * 60)

	# VOLTERETAS en el aire
	if not _en_suelo():
		if left:
			apply_torque_impulse(-fuerza_aerea * delta) # forward
		if right:
			apply_torque_impulse(fuerza_aerea * delta)  # backward

func _en_suelo():
	for r in ruedas:
		if r.get_contact_count() > 0:
			return true
	return false
	
