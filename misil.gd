extends Area2D

@export var velocidad = 800
var explotando = false

func _ready():
	# El tamaño medio que pediste
	scale = Vector2(5, 5)
	$AnimatedSprite.play("vuelo")

func _physics_process(delta):
	if not explotando:
		position += transform.x * velocidad * delta

# ESTA FUNCIÓN DETECTA EL SUELO Y PAREDES (StaticBody2D, TileMap)
func _on_body_entered(body):
	if explotando: return
	# Si toca cualquier cosa sólida, explota
	explotar()

# ESTA FUNCIÓN DETECTA LAS PLANTAS (Otras Area2D)
func _on_area_entered(area):
	if explotando: return
	
	# Si lo que toca es una planta o enemigo
	if "planta" in area.name.to_lower() or area.is_in_group("enemigos"):
		if area.has_method("morir"):
			area.morir()
		else:
			area.queue_free() # Si no tiene método morir, la borramos
		
		explotar()

func explotar():
	if explotando: return
	explotando = true
	velocidad = 0 # Se para en seco para la explosión
	$AnimatedSprite.play("explosion")
	
	await $AnimatedSprite.animation_finished
	queue_free()
