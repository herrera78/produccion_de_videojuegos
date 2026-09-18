extends Node

@export var target_pizzas : int = 5
@export var coupon_value : int = 5000
@export var coupon_minimum_value : int = 9000
var pizzas_delivered : int = 0
@onready var delivery_area : Area2D = $DeliveryArea
@onready var timer_gameover : Timer = $TimerGameover
@onready var lbl_timer : Label = $CanvasLayer/LabelTimeCounter
@onready var lbl_pizza_count : Label = $CanvasLayer/LabelPizzaCount


func _ready():
	delivery_area.pizza_delivered.connect(_on_pizza_delivered)
	timer_gameover.timeout.connect(_on_general_timer_timeout)
	timer_gameover.start()

func _process(delta: float) -> void:
	lbl_timer.text = "Tiempo: %d" % timer_gameover.time_left

func _on_pizza_delivered():
	pizzas_delivered += 1
	lbl_pizza_count.text = "Pizzas: %d / %d" % [
	pizzas_delivered,
	target_pizzas
	]
	if pizzas_delivered < target_pizzas:
		var spawns : Array = get_tree().get_nodes_in_group("pizza_spawn")
		spawns.pick_random().spawn_pizza()
		
	if pizzas_delivered >= target_pizzas:
		finish_game()


func _on_general_timer_timeout() -> void:
	hide_hud()
	timer_gameover.stop()
	show_panel("Pedido incompleto", "Se agotó el tiempo.", "Pizzas entregadas: " + str(pizzas_delivered) + " / " + str(target_pizzas))
	
	print("gameover")


func finish_game() -> void:
	hide_hud()
	timer_gameover.stop()
	show_panel("¡Pedido completado!", "Has entregado todas las pizzas.", "Pizzas entregadas: " + str(pizzas_delivered) + " / " + str(target_pizzas))
	var coupon: Dictionary = {
		"value": coupon_value,
		"minimum_purchase": coupon_minimum_value
	}
	EventBus.coupon_obtained.emit(coupon)
	print("Partida completada")

func hide_hud() -> void:
	lbl_timer.hide()
	lbl_pizza_count.hide()

func show_panel(title : String, desc: String, count:String) -> void:
	$CanvasLayer/Panel.show()
	$CanvasLayer/Panel/VBoxContainer/LabelTitle.text = title
	$CanvasLayer/Panel/VBoxContainer/LabelDesc.text = desc
	$CanvasLayer/Panel/VBoxContainer/LabelCount.text = count
