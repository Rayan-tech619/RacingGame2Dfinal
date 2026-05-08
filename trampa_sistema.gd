extends Node2D

@onready var arriba = $ParteArriba
@onready var abajo = $ParteAbajo

var activa = true

# Ajusta la distancia de cierre
@export var fuerza_aplastar : float = 1100.0 
# Tiempo que la trampa se queda abierta antes de cerrarse
@export var tiempo_espera_abierta : float = 2.0
# Tiempo que se queda cerrada (aplastando)
@export var tiempo_espera_cerrada : float = 0.5

func _ready():
	# Eliminamos la conexión del sensor porque ahora es automática
	comenzar_ciclo_trampa()

func comenzar_ciclo_trampa():
	while true: # Bucle infinito para que no pare nunca
		# 1. ESPERA ANTES DE ATACAR (Tiempo para que el jugador pase)
		await get_tree().create_timer(tiempo_espera_abierta).timeout
		
		# 2. ATAQUE (Cierre rápido)
		await atacar()
		
		# 3. ESPERA CERRADA (Tensión)
		await get_tree().create_timer(tiempo_espera_cerrada).timeout
		
		# 4. ABRIR TRAMPA
		await abrir()

func atacar():
	var tween = create_tween().set_parallel(true)
	# Cierre seco y rápido
	tween.tween_property(arriba, "position:y", arriba.position.y + fuerza_aplastar, 0.15).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.tween_property(abajo, "position:y", abajo.position.y - fuerza_aplastar, 0.15).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	
	await tween.finished # Esperamos a que el tween termine

func abrir():
	var tween2 = create_tween().set_parallel(true)
	# Apertura más lenta
	tween2.tween_property(arriba, "position:y", arriba.position.y - fuerza_aplastar, 0.8).set_trans(Tween.TRANS_SINE)
	tween2.tween_property(abajo, "position:y", abajo.position.y + fuerza_aplastar, 0.8).set_trans(Tween.TRANS_SINE)
	
	await tween2.finished
