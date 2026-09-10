extends Node2D
@export var target_items: int = 10
@export var max_spawned_items: int = 15
@export var coupon_value : int = 5000
@export var coupon_minimum_value : int = 9000

@onready var result_panel: Control = $CanvasLayer/ResultPanel
@onready var result_label: Label = $CanvasLayer/ResultPanel/ResultLabel
@onready var objective: Label = $CanvasLayer/Objective

var current_spawned_items: int = 0
var collected_items: int = 0
var game_finished : bool = false

func _ready() -> void:
	objective.text = "Ingredientes " + str(collected_items) + "/" + str(target_items)
	var spawners : Array = get_tree().get_nodes_in_group("spawner")
	for spawn in spawners:
		spawn.spawned_item.connect(_on_item_spawned)

func _on_item_spawned() -> void:
	current_spawned_items += 1
	if current_spawned_items > max_spawned_items:
		lose_game()

func _on_player_collected_food() -> void:
	collected_items += 1
	objective.text = "Ingredientes " + str(collected_items) + "/" + str(target_items)
	if collected_items >= target_items:
		win_game()

func win_game() -> void:
	if game_finished: return
	clean_game()
	var coupon: Dictionary = {
		"value": coupon_value,
		"minimum_purchase": coupon_minimum_value
	}
	EventBus.coupon_obtained.emit(coupon)
	result_label.text = "¡Cupón obtenido: $%d!" % coupon_value
	result_panel.show()
	


func lose_game() -> void:
	if game_finished: return
	clean_game()
	result_label.text = "No obtuviste el cupón."
	result_panel.show()

func clean_game() -> void:
	if game_finished: return
	
	game_finished = true
	var spawners : Array = get_tree().get_nodes_in_group("spawner")
	for spawn in spawners:
		spawn.queue_free()
	$Player.queue_free()
