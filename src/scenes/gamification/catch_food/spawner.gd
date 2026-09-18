extends Node2D
signal spawned_item

@export var max_active_items: int = 10
@export var spawn_interval: float = 1.0
@export var collectable_scene: PackedScene
@export var use_parabola: bool = false

@onready var timer: Timer = $Timer

var active_items: int = 0


func _ready() -> void:
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_spawn_timer_timeout)
	timer.start()


func _on_spawn_timer_timeout() -> void:
	if active_items >= max_active_items:
		return
	# Emitir señal de spawn al manager
	spawned_item.emit()
	var spawn_position := global_position# + Vector2(
		#randi_range(-50, 50),
		#randi_range(-10, 10)
	#)

	if use_parabola:
		spawn_from_side(
			spawn_position,
			Vector2(1 * randi_range(-400,400), -250)
		)
	else:
		spawn_item(spawn_position)


func spawn_item(spawn_position: Vector2) -> void:
	var item := collectable_scene.instantiate()
	item.global_position = spawn_position
	item.apply_central_impulse(Vector2(0,-100))
	get_parent().add_child(item)
	active_items += 1


func spawn_from_side(spawn_position: Vector2, impulse: Vector2) -> void:
	var item := collectable_scene.instantiate()
	item.global_position = spawn_position
	get_parent().add_child(item)
	item.apply_central_impulse(impulse)
	active_items += 1
