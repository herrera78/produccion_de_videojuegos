# res://src/core/event_bus.gd
extends Node

# Señal global para solicitar el cambio de entornos interactivos
signal navigation_requested(target_scene_path: String)

# Señal global para notificar la modificación de parámetros lógicos
signal parameter_changed(param_name: String, value: Variant)
