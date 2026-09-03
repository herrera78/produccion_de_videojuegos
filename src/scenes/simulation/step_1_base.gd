# res://src/scenes/simulation/step_1_base.gd
extends Control

@onready var btn_volver: Button = $VBoxContainer/BtnVolver
@onready var btn_ingrediente1: Button = $VBoxContainer/GridContainer/BtnIngrediente1
@onready var btn_ingrediente2: Button = $VBoxContainer/GridContainer/BtnIngrediente2
@onready var lbl_status_local: Label = $VBoxContainer/LblStatusLocal

func _ready() -> void:
	# Conexiones locales del GridContainer
	btn_ingrediente1.pressed.connect(_on_ingrediente_selected.bind("Base Tradicional", 1500))
	btn_ingrediente2.pressed.connect(_on_ingrediente_selected.bind("Base Integral", 2000))
	
	btn_volver.pressed.connect(func() -> void:
		EventBus.navigation_requested.emit("res://src/scenes/main/menu_panel.tscn"))

func _on_ingrediente_selected(nombre_base: String, costo: int) -> void:
	lbl_status_local.text = "Selección local: %s (+$%d)" % [nombre_base, costo]
	print("Seleccionado de forma local: ", nombre_base)
