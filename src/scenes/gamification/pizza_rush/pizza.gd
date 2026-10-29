extends CharacterBody2D

enum PizzaState {
	CONGELADA,
	DISPONIBLE,
	ARRASTRANDO,
	COCINANDO,
	LISTA,
	ENTREGADA
}

@onready var timer: Timer = $Timer
@onready var sprite: Sprite2D = $Sprite2D
@onready var outline_sprite: Sprite2D = $OutlineSprite

var heat_material: ShaderMaterial

var current_state: PizzaState = PizzaState.CONGELADA
var previous_state: PizzaState = PizzaState.CONGELADA
var mouse_over: bool = false
var cooking_duration: float = 15.0
var frozen_duration: float = 15.0


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	timer.timeout.connect(_on_timer_timeout)
	sprite.modulate = Color(0.1, 0.3, 1.0)
	heat_material = sprite.material
	sprite.material = null
	outline_sprite.visible = false
	timer.start(frozen_duration)
	animate_enter_frozen()


func _on_mouse_entered() -> void:
	mouse_over = true
	_refresh_effects()


func _on_mouse_exited() -> void:
	mouse_over = false
	_refresh_effects()


func _refresh_effects() -> void:
	outline_sprite.visible = is_interactable() and mouse_over
	if heat_material:
		sprite.material = heat_material if current_state == PizzaState.COCINANDO else null


func is_interactable() -> bool:
	match current_state:
		PizzaState.CONGELADA, PizzaState.DISPONIBLE, PizzaState.COCINANDO, PizzaState.LISTA:
			return true
		_:
			return false


func _on_timer_timeout() -> void:
	match current_state:
		PizzaState.CONGELADA:
			change_state(PizzaState.DISPONIBLE)
		PizzaState.COCINANDO:
			var oven = get_oven()
			if change_state(PizzaState.LISTA):
				if oven:
					oven.deactivate()


func change_state(next_state: PizzaState) -> bool:
	var valid_transition := false
	match current_state:
		PizzaState.CONGELADA:
			valid_transition = next_state == PizzaState.DISPONIBLE
		PizzaState.DISPONIBLE:
			valid_transition = next_state == PizzaState.ARRASTRANDO
		PizzaState.ARRASTRANDO:
			valid_transition = (next_state == PizzaState.COCINANDO or next_state == PizzaState.ENTREGADA or next_state == PizzaState.DISPONIBLE or next_state == PizzaState.LISTA)
		PizzaState.COCINANDO:
			valid_transition = next_state == PizzaState.LISTA
		PizzaState.LISTA:
			valid_transition = next_state == PizzaState.ARRASTRANDO
		PizzaState.ENTREGADA:
			valid_transition = false
	if not valid_transition:
		return false
	previous_state = current_state
	current_state = next_state
	play_transition_animation(previous_state, current_state)
	_refresh_effects()
	if current_state == PizzaState.COCINANDO:
		timer.start(cooking_duration)
	return true


func _physics_process(delta: float) -> void:
	match current_state:
		PizzaState.CONGELADA:
			process_congelada(delta)
		PizzaState.DISPONIBLE:
			process_disponible(delta)
		PizzaState.ARRASTRANDO:
			process_arrastrando(delta)
		PizzaState.COCINANDO:
			process_cocinando(delta)
		PizzaState.LISTA:
			process_lista(delta)
		PizzaState.ENTREGADA:
			process_entregada(delta)


func handle_click() -> bool:
	match current_state:
		PizzaState.CONGELADA, PizzaState.COCINANDO:
			var is_cooking := current_state == PizzaState.COCINANDO
			var duration := cooking_duration if is_cooking else frozen_duration
			var start_color := Color(1.0, 0.912, 0.897) if is_cooking else Color(0.05, 0.2, 1.0)
			var end_color := Color(1.0, 0.463, 0.0) if is_cooking else Color.WHITE
			var next_state := PizzaState.LISTA if is_cooking else PizzaState.DISPONIBLE
			var new_time = max(timer.time_left - 1.0, 0.1)
			timer.start(new_time)
			animate_interaction()
			var progress = 1.0 - (timer.time_left / duration)
			sprite.modulate = start_color.lerp(end_color, progress)
			if timer.time_left <= 0.1:
				change_state(next_state)
			return true
		_:
			return false


func process_congelada(delta: float) -> void:
	if mouse_over and Input.is_action_just_pressed("interact"):
		handle_click()
	var progress = 1.0 - (timer.time_left / frozen_duration)
	sprite.modulate = Color(0.05, 0.2, 1.0).lerp(Color(1.0, 1.0, 1.0), progress)


func process_disponible(delta: float) -> void:
	velocity.y += 980.0 * delta
	move_and_slide()
	if mouse_over and Input.is_action_just_pressed("interact"):
		velocity = Vector2.ZERO
		change_state(PizzaState.ARRASTRANDO)


func process_arrastrando(delta: float) -> void:
	global_position = get_global_mouse_position()
	scale.x = lerp(scale.x, 1.18, 0.15)
	scale.y = lerp(scale.y, 0.84, 0.15)
	if Input.is_action_just_released("interact"):
		release_pizza()

func release_pizza() -> void:
	var delivery_area = get_delivery_area()
	var oven = get_oven()
	if delivery_area and previous_state == PizzaState.LISTA:
		if change_state(PizzaState.ENTREGADA):
			delivery_area.confirm_delivery()
	elif oven and previous_state == PizzaState.DISPONIBLE:
		if change_state(PizzaState.COCINANDO):
			oven.activate()
	elif previous_state == PizzaState.LISTA:
		change_state(PizzaState.LISTA)
	else:
		change_state(PizzaState.DISPONIBLE)


func get_oven() -> Area2D:
	for area in $InteractionArea.get_overlapping_areas():
		if area.is_in_group("oven"):
			return area
	return null


func get_delivery_area() -> Area2D:
	for area in $InteractionArea.get_overlapping_areas():
		if area.is_in_group("delivery"):
			return area
	return null


func process_cocinando(delta: float) -> void:
	if mouse_over and Input.is_action_just_pressed("interact"):
		handle_click()
	var progress = 1.0 - (timer.time_left / cooking_duration)
	sprite.modulate = Color(1.0, 0.912, 0.897, 1.0).lerp(Color(1.0, 0.463, 0.0, 1.0), progress)


func process_lista(delta: float) -> void:
	velocity.y += 980.0 * delta
	move_and_slide()
	if mouse_over and Input.is_action_just_pressed("interact"):
		velocity = Vector2.ZERO
		change_state(PizzaState.ARRASTRANDO)


func process_entregada(delta: float) -> void:
	pass


func animate_enter_frozen() -> void:
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.25)


func animate_interaction() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.12, 0.88), 0.06)
	tween.tween_property(self, "scale", Vector2(0.95, 1.05), 0.06)
	tween.tween_property(self, "scale", Vector2.ONE, 0.08)


func animate_frozen_to_available() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "rotation", rotation + TAU, 0.35)
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.12)
	tween.chain().tween_property(self, "scale", Vector2(0.95, 1.05), 0.08)
	tween.chain().tween_property(self, "scale", Vector2.ONE, 0.12)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.35)


func animate_available_to_dragging() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 0.9), 0.08)
	tween.tween_property(self, "scale", Vector2(0.95, 1.05), 0.08)
	tween.tween_property(self, "scale", Vector2.ONE, 0.08)


func animate_dragging_to_available() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.12)


func animate_dragging_to_cooking() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.12, 0.88), 0.08)
	tween.tween_property(self, "scale", Vector2(0.96, 1.04), 0.08)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)


func animate_cooking_to_ready() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(0.92, 0.92), 0.08)
	tween.tween_property(self, "scale", Vector2.ONE, 0.12)
	sprite.modulate = Color(0.922, 0.302, 0.075, 1.0)


func animate_ready_to_dragging() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.08, 0.92), 0.07)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)


func animate_delivery() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.25)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.25)
	await tween.finished
	queue_free()

func interact_agent() -> bool:
	return handle_click()


func play_transition_animation(from_state: PizzaState, to_state: PizzaState) -> void:
	match [from_state, to_state]:
		[PizzaState.CONGELADA, PizzaState.DISPONIBLE]:
			animate_frozen_to_available()
		[PizzaState.DISPONIBLE, PizzaState.ARRASTRANDO]:
			animate_available_to_dragging()
		[PizzaState.ARRASTRANDO, PizzaState.DISPONIBLE]:
			animate_dragging_to_available()
		[PizzaState.ARRASTRANDO, PizzaState.COCINANDO]:
			animate_dragging_to_cooking()
		[PizzaState.COCINANDO, PizzaState.LISTA]:
			animate_cooking_to_ready()
		[PizzaState.LISTA, PizzaState.ARRASTRANDO]:
			animate_ready_to_dragging()
		[PizzaState.ARRASTRANDO, PizzaState.ENTREGADA]:
			animate_delivery()
