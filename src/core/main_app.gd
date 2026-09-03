# res://src/core/main_app.gd
extends Node

# Captura del contenedor responsivo
@onready var scene_container: Control = $SceneContainer

# Variable de control de la escena activa en memoria
var current_scene: Node = null

func _ready() -> void:
	# 1. Suscribir el orquestador central al EventBus global
	EventBus.navigation_requested.connect(_on_navigation_requested)
	
	# 2. Cargar de manera segura la escena inicial del menú
	_on_navigation_requested("res://src/scenes/main/menu_panel.tscn")

func _on_navigation_requested(target_scene_path: String) -> void:
	# A. Liberar de forma segura la escena activa previa para evitar fugas de memoria
	if current_scene:
		current_scene.queue_free()
		current_scene = null # Limpieza de referencia para el recolector de basura
		
	# B. Cargar dinámicamente el recurso físico desde el FileSystem
	var new_scene_resource = load(target_scene_path)
	
	if new_scene_resource:
		# Instanciar el componente de software interactivo
		current_scene = new_scene_resource.instantiate()
		# Inyectar el componente dentro de la vista contenedora responsiva
		scene_container.add_child(current_scene)
	else:
		printerr("Error crítico de arquitectura: No se pudo cargar el recurso de escena en la ruta: ", target_scene_path)
