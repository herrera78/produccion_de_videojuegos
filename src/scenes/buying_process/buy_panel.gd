# res://src/scenes/simulation/step_1_base.gd
extends Control

@onready var btn_base1: Button = $VBoxContainer/GridContainer/BtnBase1
@onready var btn_base2: Button = $VBoxContainer/GridContainer/BtnBase2
@onready var btn_item1: Button = $VBoxContainer/GridContainer/BtnItem1
@onready var btn_item2: Button = $VBoxContainer/GridContainer/BtnItem2
@onready var lbl_total: Label = $VBoxContainer/LblTotal

func _ready() -> void:
	# Conexiones locales del GridContainer
	btn_base1.pressed.connect(_on_base_pressed.bind("base_1"))
	btn_base2.pressed.connect(_on_base_pressed.bind("base_2"))
	btn_item1.pressed.connect(_on_item_pressed.bind("item_1"))
	btn_item2.pressed.connect(_on_item_pressed.bind("item_2"))
	EventBus.total_changed.connect(_on_total_changed)
	_on_total_changed(GlobalManager.current_total)

func _on_base_pressed(base_name : String) -> void:
	EventBus.base_selected.emit(base_name)

func _on_item_pressed(item_name : String) -> void:
	EventBus.item_added.emit(item_name)

func _on_total_changed(new_total: int) -> void:
	lbl_total.text = "Total: $" + str(new_total)
