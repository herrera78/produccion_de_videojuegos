# res://step_1_base.gd
extends Control

@onready var btn_ingrediente_1: Button = $VBoxContainer/GridContainer/BtnIngrediente1
@onready var btn_ingrediente_2: Button = $VBoxContainer/GridContainer/BtnIngrediente2
@onready var lbl_status_local: Label = $VBoxContainer/LblStatusLocal
@onready var btn_volver: Button = $VBoxContainer/BtnVolver

func _ready() -> void:
	# Conexiones locales del GridContainer
	btn_ingrediente_1.pressed.connect(_on_ingrediente_selected.bind("Base Tradicional", 1500))
	btn_ingrediente_2.pressed.connect(_on_ingrediente_selected.bind("Base Integral", 2000))
	
	# Conexión del botón de salida/regreso
	btn_volver.pressed.connect(_on_btn_volver_pressed)

func _on_ingrediente_selected(nombre_base: String, costo: int) -> void:
	lbl_status_local.text = "Selección local: %s (+$%d)" % [nombre_base, costo]
	print("Seleccionado de forma local: ", nombre_base)

func _on_btn_volver_pressed() -> void:
	# Navegación básica y acoplada heredada (será refactorizada en el Lab 2)
	get_tree().change_scene_to_file("res://src/scenes/main/menu_panel.tscn")
