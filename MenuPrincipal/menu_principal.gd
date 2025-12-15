extends Control

const WORLD_SCENE_PATH = "res://world.tscn"

func _ready():
	$VBoxContainer/Button.pressed.connect(_on_Button_pressed)
	$VBoxContainer/Button3.pressed.connect(_on_ButtonSalir_pressed)

func _on_Button_pressed():
	if ResourceLoader.exists(WORLD_SCENE_PATH):
		get_tree().change_scene_to_file(WORLD_SCENE_PATH)
	else:
		print("Error: No se encontró la escena:", WORLD_SCENE_PATH)

func _on_ButtonSalir_pressed():
	get_tree().quit()
