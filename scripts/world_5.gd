extends Node2D

func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://interface.tscn")


func _process(delta: float) -> void:
	$jugador/CanvasLayer/Label.text = "Diamantes: " + str(Contador.Diamantes)


func _on_area_2d_2_body_entered_world_5(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://interfaz_victoria_final.tscn")
