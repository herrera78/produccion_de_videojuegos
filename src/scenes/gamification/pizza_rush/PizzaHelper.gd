extends Node2D

const PizzaState = preload("res://src/scenes/gamification/pizza_rush/pizza.gd").PizzaState

enum AgentState {
	BUSCANDO,
	MOVIENDOSE,
	INTERACTUANDO,
	SIN_ENERGIA
}

@export var speed: float = 120.0
@export var interact_distance: float = 60.0
@export var interact_cooldown: float = 0.35
@export var energy_max: float = 100.0
@export var energy_drain: float = 3.0
@export var energy_cost: float = 10.0
@export var energy_regen: float = 20.0
@export var scan_speed: float = 3.0
@export var ray_length: float = 2000.0

@onready var sprite: Sprite2D = $Sprite
@onready var raycast: RayCast2D = $RayCast2D
@onready var energy_bar: ProgressBar = $EnergyBar
@onready var energy_fill: StyleBoxFlat = StyleBoxFlat.new()

var current_state: AgentState = AgentState.BUSCANDO
var target: Node2D = null
var cooldown: float = 0.0
var energy: float = 0.0
var wander_timer: float = 0.0
var wander_dir: Vector2 = Vector2.RIGHT
var scan_angle: float = 0.0


func _ready() -> void:
	energy = energy_max
	wander_timer = randf_range(1.0, 3.0)
	raycast.target_position = Vector2(ray_length, 0.0)
	energy_fill.set_corner_radius_all(3)
	energy_bar.add_theme_stylebox_override("fill", energy_fill)
	transition_state(AgentState.BUSCANDO)


func _physics_process(delta: float) -> void:
	cooldown = max(cooldown - delta, 0.0)
	match current_state:
		AgentState.BUSCANDO:
			process_buscando(delta)
		AgentState.MOVIENDOSE:
			process_moviendo(delta)
		AgentState.INTERACTUANDO:
			process_interactuando()
		AgentState.SIN_ENERGIA:
			process_sin_energia(delta)
	update_energy_bar()


func update_energy_bar() -> void:
	energy_bar.max_value = energy_max
	energy_bar.value = energy
	energy_fill.bg_color = Color(0.2, 0.9, 0.3).lerp(Color(0.9, 0.2, 0.1), 1.0 - energy / energy_max)


func transition_state(new_state: AgentState) -> void:
	current_state = new_state
	match current_state:
		AgentState.BUSCANDO:
			sprite.modulate = Color(1.0, 0.8, 0.2, 1.0)
		AgentState.MOVIENDOSE:
			sprite.modulate = Color(0.2, 0.8, 1.0, 1.0)
		AgentState.INTERACTUANDO:
			sprite.modulate = Color(0.8, 0.8, 0.2, 1.0)
		AgentState.SIN_ENERGIA:
			sprite.modulate = Color(0.25, 0.25, 0.25, 1.0)


func is_valid_target(pizza: Node2D) -> bool:
	if pizza == null or not is_instance_valid(pizza):
		return false
	if not pizza.has_method("interact_agent"):
		return false
	return pizza.current_state == PizzaState.CONGELADA or pizza.current_state == PizzaState.COCINANDO


func process_buscando(delta: float) -> void:
	energy = max(energy - energy_drain * 0.5 * delta, 0.0)
	if energy <= 0.0:
		transition_state(AgentState.SIN_ENERGIA)
		return
	wander_timer -= delta
	if wander_timer <= 0.0:
		wander_timer = randf_range(1.0, 3.0)
		wander_dir = Vector2.from_angle(randf() * TAU)
	global_position += wander_dir * speed * 0.4 * delta
	var scan_angle_new := fmod(scan_angle + scan_speed * delta, TAU)
	scan_angle = scan_angle_new
	raycast.rotation = scan_angle
	sprite.rotation = scan_angle + PI / 2.0
	var collider = raycast.get_collider()
	if collider is Node2D and is_valid_target(collider) and energy >= energy_cost:
		target = collider
		transition_state(AgentState.MOVIENDOSE)


func process_moviendo(delta: float) -> void:
	energy = max(energy - energy_drain * delta, 0.0)
	if energy <= 0.0:
		transition_state(AgentState.SIN_ENERGIA)
		return
	if not is_valid_target(target):
		target = null
		transition_state(AgentState.BUSCANDO)
		return
	var dir: Vector2 = target.global_position - global_position
	sprite.rotation = dir.angle() + PI / 2.0
	if dir.length() <= interact_distance:
		transition_state(AgentState.INTERACTUANDO)
		return
	global_position += dir.normalized() * speed * delta


func process_interactuando() -> void:
	if not is_valid_target(target):
		target = null
		transition_state(AgentState.BUSCANDO)
		return
	if cooldown <= 0.0:
		target.interact_agent()
		sprite.frame = 1 - sprite.frame
		energy = max(energy - energy_cost, 0.0)
		cooldown = interact_cooldown
		if energy <= 0.0:
			transition_state(AgentState.SIN_ENERGIA)


func process_sin_energia(delta: float) -> void:
	energy = min(energy + energy_regen * 0.5 * delta, energy_max)
	if energy >= energy_max:
		transition_state(AgentState.BUSCANDO)
