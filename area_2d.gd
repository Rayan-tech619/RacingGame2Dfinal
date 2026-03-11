extends Area2D

func _on_body_entered(body):
	if body.name == "jugador":
		Progress.desbloquear_nivel(1)
		get_tree().change_scene_to_file("res://interface.tscn")
