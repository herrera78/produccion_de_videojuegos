# res://src/core/main_app.gd
extends Node

# Captura del contenedor responsivo
@onready var scene_container: Control = $SceneContainer
var navigation_history: Array[String] = []

# Variable de control de la escena activa en memoria
var current_scene: Node = null

func _ready() -> void:
	# 1. Suscribir el orquestador central al EventBus global
	EventBus.navigation_requested.connect(_on_navigation_requested)
	
	# 2. Cargar de manera segura la escena inicial del menú
	_on_navigation_requested("res://src/scenes/main/menu_panel.tscn",false)

func _on_navigation_requested(target_scene: String,discard_previous: bool) -> void:
	var target_packed : PackedScene = load(target_scene) 
	if discard_previous:
		if navigation_history.size() > 0:
			navigation_history.pop_back()
	else:
		navigation_history.append(target_packed.resource_path)
	print("Historial de navegación: ", navigation_history)
	if current_scene:
		current_scene.queue_free()
		current_scene = null
	if target_packed:
		current_scene = target_packed.instantiate()
		scene_container.add_child(current_scene)
	else:
		printerr("Error: no se proporcionó una escena de navegación válida.")
