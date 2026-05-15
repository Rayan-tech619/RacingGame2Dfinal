extends Area2D

@export var velocidad = 800
var explotando = false

# --- REFERENCIA AL SONIDO ---
@onready var sfx_explosion = $sfx_explosion_misil

func _ready():
	scale = Vector2(5, 5)
	$AnimatedSprite.play("vuelo")

func _physics_process(delta):
	if not explotando:
		position += transform.x * velocidad * delta

# DETECTA SUELO Y PAREDES
func _on_body_entered(body):
	if explotando: return
	# Ignoramos al jugador para que no explote en nuestra cara
	if body.name.to_lower().contains("jugador"): return
	explotar()

# DETECTA PLANTAS/ENEMIGOS
func _on_area_entered(area):
	if explotando: return
	
	if "planta" in area.name.to_lower() or area.is_in_group("enemigos"):
		if area.has_method("morir"):
			area.morir()
		else:
			area.queue_free()
		
		explotar()

func explotar():
	if explotando: return
	explotando = true
	
	# 1. Lógica física: se para y deja de detectar choques
	velocidad = 0
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	# 2. Lógica visual: Animación
	$AnimatedSprite.play("explosion")
	
	# 3. Lógica de Audio: ¡AQUÍ ESTÁ EL TRUCO!
	if sfx_explosion:
		# Le damos un pitch aleatorio para que suene mejor (menos aspiradora)
		sfx_explosion.pitch_scale = randf_range(1.1, 1.3)
		sfx_explosion.play()
	
	# 4. Esperamos a que la animación termine
	await $AnimatedSprite.animation_finished
	
	# 5. Si el sonido sigue sonando, esperamos a que termine antes de borrar el misil
	if sfx_explosion and sfx_explosion.playing:
		visible = false # Lo escondemos para que parezca que ya se ha ido
		await sfx_explosion.finished
	
	queue_free()
