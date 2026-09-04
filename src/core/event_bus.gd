# res://src/core/event_bus.gd
extends Node

# Señal global para solicitar el cambio de entornos interactivos
signal navigation_requested(
	target_scene: String,
	discard_previous: bool
)

# Señal global para notificar un cambio en la base seleccionada
signal base_selected(base_name: String)
# Señal global para notificar un nuevo item añadido
signal item_added(item_id: String)
# Señal para notificar un cambio en el precio total
signal total_changed(new_total: int)
