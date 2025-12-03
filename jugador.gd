extends RigidBody2D

var ruedas = []
var velocidad = 5000

func _ready() -> void:
	ruedas = get_tree().get_nodes_in_group("ruedas")

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_right"):
		for rueda in ruedas:
			rueda.apply_torque_impulse(velocidad * delta * 60)
			
			
	if Input.is_action_pressed("ui_left"):
		for rueda in ruedas:
			rueda.apply_torque_impulse(velocidad * delta * -60)
