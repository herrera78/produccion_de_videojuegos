extends Node2D

@export var PIZZA_SCENE : PackedScene

func _ready():
	spawn_pizza()

func spawn_pizza():
	var pizza = PIZZA_SCENE.instantiate()
	add_child(pizza)
	pizza.global_position = global_position
