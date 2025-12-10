extends Control  # O el tipo de nodo que sea tu nodo raíz

# Rutas a las escenas
const WORLD_SCENE_PATH = "res://World.tscn"  # Cambia la ruta si es diferente

func _ready():
	# Conectar botones (si no lo haces desde la señal en el editor)
	$Button("pressed", self, "_on_Button_pressed")
	$Button3.connect("pressed", self, "_on_Button_pressed")

# Función que se llama al presionar "Jugar"
func _on_Button_pressed():
	if ResourceLoader.exists(WORLD_SCENE_PATH):
		get_tree().change_scene(WORLD_SCENE_PATH)
	else:
		print("Error: No se encontró la escena World.tscn en la ruta:", WORLD_SCENE_PATH)

# Función que se llama al presionar "Salir"
func _on_ButtonSalir_pressed():
	get_tree().quit()
