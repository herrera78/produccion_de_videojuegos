extends Control
enum PizzaHalf {
	LEFT,
	RIGHT
}

var selected_half: PizzaHalf = PizzaHalf.LEFT
var left_ingredient: IngredientData
var right_ingredient: IngredientData

@onready var left_flavor_rect: TextureRect = $LeftFlavor
@onready var right_flavor_rect: TextureRect = $RightFlavor
@onready var left_half_button : Button =  $LeftFlavor/Button
@onready var right_half_button : Button =  $RightFlavor/Button
@onready var left_selection: ColorRect = $LeftFlavor/Selection
@onready var right_selection: ColorRect = $RightFlavor/Selection

func _ready() -> void:
	left_half_button.pressed.connect(_on_left_half_pressed)
	right_half_button.pressed.connect(_on_right_half_pressed)
	update_selection_visual()

func _on_left_half_pressed() -> void:
	selected_half = PizzaHalf.LEFT
	update_selection_visual()

func _on_right_half_pressed() -> void:
	selected_half = PizzaHalf.RIGHT
	update_selection_visual()

# Señal que recibiremos desde buy panel.
func _on_ingredient_selected(ingredient: IngredientData) -> void:
	if ingredient == null:
		return
	EventBus.ingredient_selected.emit(ingredient.id, selected_half)
	match selected_half:
		PizzaHalf.LEFT:
			left_ingredient = ingredient
			left_flavor_rect.texture = ingredient.texture
		PizzaHalf.RIGHT:
			right_ingredient = ingredient
			right_flavor_rect.texture = ingredient.texture
	animate_pizza_update()

func animate_pizza_update() -> void:
	var target := left_flavor_rect if selected_half == PizzaHalf.LEFT else right_flavor_rect
	target.scale = Vector2(0.85, 0.85)
	target.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(target, "scale", Vector2.ONE, 0.18)
	tween.tween_property(target, "modulate", Color.WHITE, 0.18)

func update_selection_visual() -> void:
	var selected_selection := (
		left_selection
		if selected_half == PizzaHalf.LEFT
		else right_selection
	)

	var other_selection := (
		right_selection
		if selected_half == PizzaHalf.LEFT
		else left_selection
	)

	var selected_flavor := (
		left_flavor_rect
		if selected_half == PizzaHalf.LEFT
		else right_flavor_rect
	)

	var other_flavor := (
		right_flavor_rect
		if selected_half == PizzaHalf.LEFT
		else left_flavor_rect
	)

	var tween := create_tween()
	tween.set_parallel(true)

	# Flash de color: aparece y luego queda muy transparente
	tween.tween_property(
		selected_selection,
		"color",
		Color(1.0, 0.85, 0.3, 0.35),
		0.10
	)

	tween.tween_property(
		selected_selection,
		"color",
		Color(1.0, 0.85, 0.3, 0.08),
		0.20
	).set_delay(0.10)

	# La otra mitad pierde su selección
	tween.tween_property(
		other_selection,
		"color",
		Color(1.0, 1.0, 1.0, 0.0),
		0.12
	)

	# Flash de escala: crece y vuelve a su tamaño normal
	tween.tween_property(
		selected_flavor,
		"scale",
		Vector2(1.04, 1.04),
		0.10
	)

	tween.tween_property(
		selected_flavor,
		"scale",
		Vector2.ONE,
		0.10
	).set_delay(0.10)

	tween.tween_property(
		other_flavor,
		"scale",
		Vector2.ONE,
		0.10
	)
