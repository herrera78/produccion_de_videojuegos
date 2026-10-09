# buy_panel_interactive .gd
extends Control
@onready var lbl_total: Label = $IngredientScroll/VBoxContainer/LblTotal
@onready var ingredient_list: Container = $IngredientScroll/VBoxContainer/IngredientList

func _ready() -> void:
	for ingredient in GlobalManager.ingredients:
		var button := Button.new()
		button.text = ingredient.display_name
		button.pressed.connect(_on_ingredient_selected.bind(ingredient))
		ingredient_list.add_child(button)
	# Señal para actualizar el precio
	EventBus.pizza_total_changed.connect(_on_total_changed)
	_on_total_changed(GlobalManager.pizza_total)

func _on_ingredient_selected(ingredient : IngredientData):
	$PizzaComposition._on_ingredient_selected(ingredient)

func _on_total_changed(new_total: int) -> void:
	lbl_total.text = "Total: $" + str(new_total)
