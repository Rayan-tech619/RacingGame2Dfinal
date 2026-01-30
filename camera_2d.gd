extends Camera2D

@export var zoom_normal := Vector2(0.1, 0.1)
@export var zoom_acelerar := Vector2(0.2, 0.2) # más chico = más cerca
@export var velocidad_zoom := 5.0

func _process(delta):
	if Input.is_action_pressed("ui_right"):
		zoom = zoom.lerp(zoom_acelerar, velocidad_zoom * delta)
	else:
		zoom = zoom.lerp(zoom_normal, velocidad_zoom * delta)
