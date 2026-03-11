extends Node

var nivel_maximo = 1

func desbloquear_nivel(nivel):
	if nivel >= nivel_maximo:
		nivel_maximo = nivel + 1
